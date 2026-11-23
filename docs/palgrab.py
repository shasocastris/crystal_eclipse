#!/usr/bin/env python3
"""Extract GBC palettes from a BGB screenshot (.bmp) and match them against
pokecrystal .pal files.

BGB with colour correction OFF expands 5-bit channels as (v<<3)|(v>>2), so
(pixel >> 3) recovers the exact RGB555 value.  The script verifies that
round-trip and refuses to guess if it fails.
"""
import struct, sys, collections, re, os

def read_image(path):
    """Return (w, h, Counter of RGB tuples). BMP is parsed directly so the tool
    works without PIL; anything else needs PIL."""
    if path.lower().endswith('.bmp'):
        return read_bmp(path)
    from PIL import Image
    im = Image.open(path).convert('RGB')
    return im.size[0], im.size[1], collections.Counter(im.getdata())

def read_bmp(path):
    d = open(path, 'rb').read()
    off = struct.unpack_from('<I', d, 10)[0]
    w, h = struct.unpack_from('<ii', d, 18)
    bpp = struct.unpack_from('<H', d, 28)[0]
    if bpp != 24:
        sys.exit(f"{path}: expected 24bpp, got {bpp}")
    stride = (w * 3 + 3) // 4 * 4
    px = collections.Counter()
    for y in range(abs(h)):
        base = off + y * stride
        for x in range(w):
            b, g, r = d[base + x*3: base + x*3 + 3]
            px[(r, g, b)] += 1
    return w, abs(h), px

def to555(c):
    return tuple(v >> 3 for v in c)

def from555(c):
    return tuple((v << 3) | (v >> 2) for v in c)

def parse_pal(path):
    """Yield (block, label, [4 colors]) from a pokecrystal .pal file."""
    out, block = [], "?"
    for line in open(path):
        line = line.strip()
        if line.startswith(';'):
            block = line.lstrip('; ').strip()
            continue
        m = re.match(r'RGB\s+(.*?)(?:\s*;\s*(.*))?$', line)
        if not m:
            continue
        nums = [int(n) for n in re.findall(r'\d+', m.group(1))]
        label = (m.group(2) or '').strip()
        for i in range(0, len(nums), 12):
            chunk = nums[i:i+12]
            if len(chunk) == 12:
                out.append((block, label, [tuple(chunk[j:j+3]) for j in range(0, 12, 3)]))
    return out

def cluster(path, px, tot, n=8):
    from PIL import Image
    im = Image.open(path).convert('RGB')
    q = im.quantize(colors=n, method=Image.MEDIANCUT)
    pal = q.getpalette()[:n*3]
    counts = collections.Counter(q.getdata())
    print(f"  {'share':>7}  {'hex':>8}   approximate RGB555")
    for i, _ in counts.most_common():
        r, g, b = pal[i*3:i*3+3]
        print(f"  {counts[i]/tot*100:6.2f}%  #{r:02x}{g:02x}{b:02x}   RGB {r>>3:2d},{g>>3:2d},{b>>3:2d}")
    print("\n  Treat these as DIRECTION, not values -- each is a cluster centroid and")
    print("  can be off by a step or two per channel. For exact numbers, use BGB's")
    print("  own screenshot (File > Screenshot -> a 160x144 24-bit .bmp) with colour")
    print("  correction OFF. Do not screenshot the window or re-encode as PNG/JPEG.")
    return 2

def main(bmp, palfiles):
    w, h, px = read_image(bmp)
    total = sum(px.values())
    print(f"{os.path.basename(bmp)}: {w}x{h}, {len(px)} unique colours\n")

    bad = [c for c in px if from555(to555(c)) != c]
    if len(px) > 64:
        print(f"!! {len(px)} unique colours -- a Game Boy screen has at most 56.")
        print("   This file has been rescaled or lossily re-encoded, so exact values")
        print("   are NOT recoverable. Clustering to recover intent only:\n")
        return cluster(bmp, px, sum(px.values()))
    if bad:
        print("!! COLOUR CORRECTION IS ON -- these do not round-trip through RGB555:")
        for c in bad[:8]:
            print(f"     {c} -> {to555(c)} -> {from555(to555(c))}")
        print("   Turn off colour correction in BGB (Options > Graphics) and re-shoot.\n")
        return 1
    print("Colour correction: OFF (all colours round-trip exactly through RGB555)\n")

    seen = {to555(c): n for c, n in px.items()}

    for pf in palfiles:
        entries = parse_pal(pf)
        hits = []
        for block, label, cols in entries:
            present = [c for c in cols if c in seen]
            if len(present) >= 2:
                weight = sum(seen[c] for c in present)
                hits.append((weight, block, label, cols, present))
        if not hits:
            continue
        print(f"=== {pf} ===")
        for weight, block, label, cols, present in sorted(hits, reverse=True):
            mark = ''.join('*' if c in seen else '.' for c in cols)
            body = ', '.join(f"{r:2d},{g:2d},{b:2d}" for r, g, b in cols)
            print(f"  [{mark}] {block:>16} / {label:<14} {body}   ({weight} px)")
        print()

    matched = set()
    for pf in palfiles:
        for _, _, cols in parse_pal(pf):
            matched.update(cols)
    unknown = {c: n for c, n in seen.items() if c not in matched}
    if unknown:
        print("Colours present on screen but in NONE of the .pal files given")
        print("(sprite OB pals, dynamic pals, or a palette you have not located yet):")
        for c, n in sorted(unknown.items(), key=lambda kv: -kv[1]):
            print(f"    RGB {c[0]:2d},{c[1]:2d},{c[2]:2d}   ({n} px)")
    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv[1], sys.argv[2:]))

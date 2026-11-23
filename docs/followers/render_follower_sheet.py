# Renders every follower (front frame) in its normal and shiny day palette.
# Run from the repo root: python3 docs/followers/render_follower_sheet.py [tod]
import re, sys
from PIL import Image, ImageDraw
TOD = sys.argv[1] if len(sys.argv) > 1 else 'day'
names = []
for l in open('constants/sprite_data_constants.asm'):
    if 'NUM_OW_TIME_OF_DAY_PALS' in l:
        break
    m = re.match(r'\s*ow_npc_pal_const\s+(\w+)', l)
    if m:
        names.append(m.group(1))
pal, cur = {}, None
for l in open('gfx/overworld/npc_sprites.pal'):
    if l.startswith(';'):
        cur = l[1:].strip()
        continue
    m = re.match(r'\s*RGB\s+(.*?);', l)
    if m:
        v = [int(x) * 255 // 31 for x in re.findall(r'\d+', m.group(1))]
        pal.setdefault(cur, []).append([tuple(v[i:i + 3]) for i in (0, 3, 6, 9)])
P = pal[TOD]


def colours(n):
    if n in names:
        return P[names.index(n)]
    a, b = n.split('_')
    A, B = P[names.index(a)], P[names.index(b)]
    return [A[0], A[2], B[2], A[3]]


rows = []
for l in open('data/pokemon/follower_pals.asm'):
    m = re.match(r'\s*follower_pals\s+(\w+),\s*(\w+)\s*;\s*(\w+)(.*)', l)
    if m:
        rows.append(m.groups())
ptr = {}
for l in open('gfx/following_sprite_pointers.asm'):
    m = re.match(r'\s*dba\s+(\w+)FollowerGFX\s*;\s*(\w+)(.*)', l)
    if m:
        ptr[m.group(2)] = (re.sub(r'(?<!^)([A-Z])', r'_\1', m.group(1)).lower(), 'needs art' in m.group(3))

S, COLS = 3, 8
CW, CH = 2 * 16 * S + 12, 16 * S + 22
img = Image.new('RGB', (COLS * CW, (len(rows) + COLS - 1) // COLS * CH), 'white')
d = ImageDraw.Draw(img)
for i, (n, s, sp, note) in enumerate(rows):
    f, borrowed = ptr[sp]
    src = Image.open('gfx/following/%s.png' % f).crop((0, 0, 16, 16))
    x0, y0 = (i % COLS) * CW, (i // COLS) * CH
    for k, pn in enumerate((n, s)):
        c = colours(pn)
        t = Image.new('RGB', (16, 16))
        t.putdata([c[3 - v // 85] for v in src.getdata()])
        img.paste(t.resize((16 * S, 16 * S), Image.NEAREST), (x0 + 4 + k * 16 * S, y0 + 2))
    flag = ('*' if borrowed else '') + ('!' if 'no Mystic' in note else '')
    d.text((x0 + 4, y0 + 16 * S + 4), (sp[:13] + flag), fill=(200, 0, 0) if flag else (0, 0, 0))
img.save('docs/followers/follower_sheet_%s.png' % TOD)
print('docs/followers/follower_sheet_%s.png' % TOD)

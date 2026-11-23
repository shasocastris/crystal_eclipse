"""Mock-up of water in TILESET_ICE_PATH. Builds everything in memory; writes PNGs only."""
from lib import *
S = os.environ.get('OUT', HERE)
ICE = tiles_of('ice_path'); CAVE = tiles_of('cave')
META = bytearray(open('data/tilesets/ice_path_metatiles.bin', 'rb').read())[:64 * 16]  # vanilla blocks only
ATTR = bytearray(open('data/tilesets/ice_path_attributes.bin', 'rb').read())[:64 * 16]
WATER, FALL = 0x35, 0x31  # bank 0; TilesetIcePathAnim already scrolls these two
ARCH = 0x68  # bank 0, three free tiles

def remap(tile, m):
	return unpx([[m[c] for c in r] for r in px(tile)])

WATERS = {
	'1 dark (water slot as is)': dict(pal=3, map=(0, 1, 2, 3), slot=None),
	'2 glacial (ice palette)': dict(pal=2, map=(2, 0, 1, 3), slot=None),
	'3 blue (water slot retuned)': dict(pal=3, map=(0, 1, 2, 3), slot=[(20, 28, 31), (10, 18, 29), (6, 12, 26), (0, 0, 0)]),
}

def build(water, shore):
	w = WATERS[water]
	tiles = list(ICE) + [bytes(16)] * (384 - len(ICE))
	tiles[WATER] = remap(CAVE[0x14], w['map']); tiles[FALL] = remap(CAVE[0x40], w['map'])
	pals = pals_of('ice_path')
	if w['slot']:
		pals[3] = [tuple((c << 3) | (c >> 2) for c in col) for col in w['slot']]
	W = (WATER, w['pal']); F = (FALL, w['pal'])
	if shore == 'A cave banks':
		for i, src in enumerate((0x26, 0x17, 0x15, 0x0a, 0x0b, 0x27, 0x25)):
			tiles[0x60 + i] = CAVE[src]
		N, L, R, NL, NR, iL, iR = [(0x60 + i, 6) for i in range(7)]
		Sb = None
	else:  # native Ice Path ledge tiles (bank 1)
		N, L, R = (0x3a, 14), (0x1c, 14), (0x18, 14)
		NL, NR, iL, iR = (0x4d, 14), (0x48, 14), (0x4d, 14), (0x48, 14)
		Sb = None
	meta, attr = bytearray(META), bytearray(ATTR)
	ids = {}
	def add(name, cells):
		ids[name] = len(meta) // 16
		meta.extend(c[0] for c in cells); attr.extend(c[1] for c in cells)
	add('w', [W] * 16); add('f', [F] * 16)
	def bank(n, l, r):
		c = [W] * 16
		if n: c[0:4] = [N] * 4
		if l:
			for k in (0, 4, 8, 12): c[k] = L
		if r:
			for k in (3, 7, 11, 15): c[k] = R
		if n and l: c[0] = NL
		if n and r: c[3] = NR
		return c
	for n in (0, 1):
		for l in (0, 1):
			for r in (0, 1):
				if n or l or r: add(f'b{n}{l}{r}', bank(n, l, r))
	c = [W] * 16; c[0] = iL; add('iL', c)
	c = [W] * 16; c[3] = iR; add('iR', c)
	c = [W] * 16; c[0] = iL; c[3] = iR; add('iLR', c)
	add('fw', [F] * 16)  # same art, WALL collision: a fall out of solid rock must not be climbable
	# Water cave mouth: johto a9/aa mirrored top to bottom. The arch tiles are lit (glow palette).
	for i, src in enumerate((0x69, 0x6a, 0x6b)):
		tiles[ARCH + i] = remap(tiles_of('johto')[src], (1, 2, 3, 0))
	fill = lambda r, c: (META[0x19 * 16 + r * 4 + c], ATTR[0x19 * 16 + r * 4 + c])
	A = lambda i: (ARCH + i, 4 | 0x40)
	add('mL', [fill(0, 0), (0x1c, 14), W, W, fill(1, 0), (0x1c, 14), W, W, fill(2, 0), fill(2, 1), A(0), A(1)] + [fill(3, c) for c in range(4)])
	add('mR', [W, W, (0x18, 14), fill(0, 3), W, W, (0x18, 14), fill(1, 3), A(1), A(2), fill(2, 2), fill(2, 3)] + [fill(3, c) for c in range(4)])
	add('sp', [(0x1a, 14)] * 8 + [F] * 8)  # spring out of a plateau's front rim
	return tiles, meta, attr, pals, ids

DEMO = """
############
####ff######
#..wwww...##
#..wwww..II#
#...www..II#
#.o.www....#
#IIwwww....#
#IIwww.....#
###ww#######
""".split()
BASE = {'#': 0x19, '.': 0x02, 'I': 0x1f, 'o': 0x20}

def blocks_of(ids):
	g = DEMO; h, wd = len(g), len(g[0])
	at = lambda x, y: g[y][x] if 0 <= y < h and 0 <= x < wd else '#'
	land = lambda x, y: at(x, y) in '#.o'
	out = []
	for y in range(h):
		for x in range(wd):
			c = g[y][x]
			if c == 'f': out.append(ids['f']); continue
			if c != 'w': out.append(BASE[c] if not (c == '.' and (x + y) % 3 == 0) else 0x09); continue
			n, l, r = land(x, y - 1), land(x - 1, y), land(x + 1, y)
			if n or l or r: out.append(ids[f'b{int(n)}{int(l)}{int(r)}']); continue
			il, ir = land(x - 1, y - 1), land(x + 1, y - 1)
			out.append(ids['iLR' if il and ir else 'iL' if il else 'iR' if ir else 'w'])
	return out, wd

def demo(water, shore, scale=2):
	tiles, meta, attr, pals, ids = build(water, shore)
	bl, wd = blocks_of(ids)
	img = Image.new('RGB', (wd * 32, len(bl) // wd * 32))
	for i, b in enumerate(bl):
		draw_block(img, (i % wd) * 32, (i // wd) * 32, b, meta, attr, tiles, pals)
	return img.resize((img.width * scale, img.height * scale), Image.NEAREST)

def board(cells, name):
	"""cells: [(title, image)] laid out left to right with captions."""
	wd = sum(i.width for _, i in cells) + 12 * (len(cells) + 1); ht = max(i.height for _, i in cells) + 40
	out = Image.new('RGB', (wd, ht), (30, 30, 34)); d = ImageDraw.Draw(out); x = 12
	for t, i in cells:
		d.text((x, 8), t, fill=(255, 255, 255)); out.paste(i, (x, 28)); x += i.width + 12
	out.save(f'{S}/{name}.png'); print(name, out.size)

if __name__ == '__main__':
	for sh, tag in (('A cave banks', 'A'), ('B native ledges', 'B')):
		board([(f'{sh} / water {w}', demo(w, sh)) for w in WATERS], f'water_{tag}')
	t, m, a, p, ids = build('3 blue (water slot retuned)', 'A cave banks')
	n = len(m) // 16
	atlas(m[64 * 16:], a[64 * 16:], t, p, cols=8, scale=3, label=False).save(f'{S}/new_blocks_A.png')
	print(ids)

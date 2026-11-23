# luster.py OUT.png — greenhouse options built from Polished Coral's Luster City tiles,
# rendered into Celadon City with Crystal Eclipse's real palettes. Run from the repo root.
import sys, os
sys.path.insert(0, 'utils')
import render_overworld as R
from PIL import Image

CORAL = os.path.abspath('../polishedcoral')
HERE = os.getcwd()

def coral_inputs():
	os.chdir(CORAL)
	e = R.ENGINES['coral']('summer', 'day')
	meta, attr, vram, pals = e.render_inputs(e.load_maps()['LusterCityBusiness'])
	os.chdir(HERE)
	return meta, attr, vram

META, ATTR, VRAM = coral_inputs()

def cell(b, r, c):
	"""(tile pixels as rows of 0-3, attr) for row r, col c of Coral block b"""
	i = b * 16 + r * 4 + c
	t, a = META[i], ATTR[i]
	tile = VRAM[((a >> 3) & 1) * 256 + t] or R.BLANK_TILE
	px = [list(row) for row in tile]
	if a & 0x20:
		px = [row[::-1] for row in px]
	if a & 0x40:
		px = px[::-1]
	return px, a & 7

def strip(blocks, r):
	return [cell(b, r, c) for b in blocks for c in range(4)]

def glassify(row, glass_row):
	"""Swap plain pale roof cells (Coral tile $4d) for glass cells"""
	return [g if px == cell(0xac, 1, 0)[0] else (px, p) for (px, p), g in zip(row, glass_row)]

CAP, WALL, ENTRY = [0xab, 0xac, 0xb0], [0xaa, 0x9c, 0xe3], [0x5b, 0x8a, 0x0d]
GLASS = [[cell(0x9c, r, c) for c in range(4)] for r in range(4)]  # 32x32 periodic texture

def glaze(rows, pal):
	"""Fill the cap's flat pale top (flood fill from its middle) with curtain-wall glass"""
	H = len(rows) * 8
	color = lambda x, y: rows[y // 8][x // 12 * 0 + x // 8][0][y % 8][x % 8]
	inside, todo = set(), [(48, 10)]
	while todo:
		x, y = todo.pop()
		if (x, y) in inside or not (0 <= x < 96 and 0 <= y < H) or color(x, y) != 0:
			continue
		inside.add((x, y))
		todo += [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
	out = []
	for ty, row in enumerate(rows):
		new = []
		for tx, (px, p) in enumerate(row):
			px = [r[:] for r in px]
			hit = False
			for j in range(8):
				for i in range(8):
					if (tx * 8 + i, ty * 8 + j) in inside:
						gx, gy = (tx * 8 + i) % 32, (ty * 8 + j + 4) % 32
						px[j][i] = GLASS[gy // 8][gx // 8][0][gy % 8][gx % 8]
						hit = True
			new.append((px, pal if hit else p))
		out.append(new)
	return out

def option(n):
	cap = [strip(CAP, r) for r in (0, 1, 3)]
	if n == 1:
		cap = glaze(cap, 3)
	elif n == 2:
		cap = glaze(cap, 0)
	if n == 3:
		return glaze(cap, 3) + [strip(WALL, r) for r in (0, 1, 2)] + [strip(ENTRY, r) for r in (2, 3)]
	return cap + [strip(WALL, r) for r in (0, 1)] + [strip(ENTRY, r) for r in (1, 2, 3)]

def building(rows, pals):
	img = Image.new('RGB', (96, 64))
	for ty, row in enumerate(rows):
		for tx, (px, p) in enumerate(row):
			for j in range(8):
				for i in range(8):
					img.putpixel((tx * 8 + i, ty * 8 + j), pals[p][px[j][i]])
	return img

if __name__ == '__main__':
	out = []
	for season, time in (('summer', 'day'), ('summer', 'nite')):
		e = R.ENGINES['cse'](season, time)
		m = e.load_maps()['CeladonCity']
		pals = e.render_inputs(m)[3]
		city = R.render_map(e, m)
		for n in range(4):
			c = city.copy()
			c.paste(building(option(n), pals), (32, 13 * 32))
			out.append(c.crop((0, 12 * 32 + 16, 8 * 32, 15 * 32 + 16)))
	pw, ph = out[0].size
	sheet = Image.new('RGB', (4 * (pw + 6), 2 * (ph + 6)), (255, 255, 255))
	for i, p in enumerate(out):
		sheet.paste(p, ((i % 4) * (pw + 6), (i // 4) * (ph + 6)))
	sheet.resize((sheet.width * 2, sheet.height * 2), Image.NEAREST).save(sys.argv[1])

# draft.py OUT.png — greenhouse exterior options composited into Celadon City
# Run from the repo root.
import sys, math
sys.path.insert(0, 'utils')
import render_overworld as R
from PIL import Image

c5 = lambda r, g, b: (r * 255 // 31, g * 255 // 31, b * 255 // 31)
PAL = {  # Kanto day, plus Celadon's roof group
	'gray':   [c5(27,31,27), c5(21,21,21), c5(13,13,13), c5(7,7,7)],
	'green':  [c5(22,31,10), c5(12,25,1),  c5(5,14,0),   c5(7,7,7)],
	'water':  [c5(31,31,31), c5(8,12,31),  c5(1,4,31),   c5(7,7,7)],
	'roof':   [c5(27,31,27), c5(19,31,15), c5(31,22,2),  c5(7,7,7)],
	'yellow': [c5(27,31,27), c5(31,31,7),  c5(31,16,1),  c5(7,7,7)],
	'brown':  [c5(27,31,27), c5(24,18,7),  c5(20,15,3),  c5(7,7,7)],
}
W = 96

def roof():
	# 0 light, 1 glass, 2 frame, 3 outline
	g = [[1] * W for _ in range(32)]
	for y in range(32):
		for x in range(W):
			if x % 16 == 0:
				g[y][x] = 2
	# streaks, alternating per pane
	for p in range(6):
		x0 = p * 16
		back = [11, 13] if p % 2 == 0 else [6]
		front = [14, 16, 19] if p % 2 == 0 else [10, 12]
		for y in range(1, 13):
			for s in back:
				x = x0 + s - y + 3
				if x0 < x < x0 + 16:
					g[y][x] = 0
		for y in range(17, 29):
			for s in front:
				x = x0 + s - (y - 17)
				if x0 < x < x0 + 16 and (s != front[0] or y % 2):
					g[y][x] = 0
	for x in range(W):
		g[0][x] = 3
		g[1][x] = 2
		g[14][x], g[15][x], g[16][x] = 2, 0, 2  # ridge
		g[17][x] = 2 if x % 16 < 3 else g[17][x]
		g[29][x], g[30][x], g[31][x] = 2, 0, 3  # gutter
	# hipped ends: diagonal outline, side glass shaded darker
	for y in range(14):
		inset = 13 - y
		for x in range(inset + 9):
			for xx in (x, W - 1 - x):
				if x < inset:
					g[y][xx] = 0
				elif x == inset:
					g[y][xx] = 3
				elif x == inset + 8:
					g[y][xx] = 2
				elif y > 1:
					g[y][xx] = 2 if (x + y) % 2 else 1
	for y in range(14, 32):
		g[y][0] = g[y][W - 1] = 3
	return g

def plants(variant):
	# 16x24 pane in the green palette: 0 glass, 1 leaf, 2 shade, 3 outline
	g = [[0] * 16 for _ in range(24)]
	def blob(cx, cy, r):
		for y in range(24):
			for x in range(1, 16):
				d = math.hypot(x - cx, (y - cy) * 1.1)
				if d <= r:
					edge = d > r - 1
					lower = (x - cx) + (y - cy) > r * 0.6
					hi = (x - cx) + (y - cy) < -r * 0.8 and not edge
					g[y][x] = 2 if edge or lower else (0 if hi else 1)
	def stem(x, y0, y1):
		for y in range(y0, y1):
			g[y][x] = 2
	if variant == 0:
		stem(5, 12, 20); stem(11, 9, 20)
		blob(11, 7, 5.5); blob(5, 11, 4.5); blob(13, 15, 3.5)
	else:
		stem(8, 8, 20); stem(3, 14, 20)
		blob(8, 5, 4.5); blob(4, 13, 3.8); blob(11, 12, 4.2)
	for x in range(16):
		g[20][x] = 2
		g[21][x] = 3 if x % 8 in (1, 6) else 2
		g[22][x] = 2
		g[23][x] = 3
		g[0][x] = 2
	for y in range(24):
		g[y][0] = 2
	for x in range(2, 15, 6):  # glint on the glass above the plants
		pass
	return g

def kanto_tile(t, im=Image.open('gfx/tilesets/kanto.png').convert('L')):
	lv = {255: 0, 170: 1, 85: 2, 0: 3}
	x, y = (t % 16) * 8, (t // 16) * 8
	return [[lv[im.getpixel((x + i, y + j))] for i in range(8)] for j in range(8)]

def building(roof_pal, doors=(4, 6)):
	H = 64
	g = [[0] * W for _ in range(H)]
	r = roof()
	for y in range(32):
		g[y] = r[y][:]
	pl = [plants(0), plants(1)]
	for y in range(24):
		for x in range(W):
			g[32 + y][x] = pl[(x // 16) % 2][y][x % 16]
	for y in range(32, 56):
		g[y][0] = g[y][W - 1] = 3
	pals = [[roof_pal] * 12 for _ in range(4)] + [['green'] * 12 for _ in range(3)] + [['gray'] * 12]
	base = [0x1d] + [0x1a] * 10 + [0x3c]
	special = {(7, c): (t, 'gray') for c, t in enumerate(base)}
	for c in doors:
		special[(6, c)] = (0x0b, 'yellow'); special[(6, c + 1)] = (0x0c, 'yellow')
		special[(7, c)] = (0x1b, 'brown'); special[(7, c + 1)] = (0x1c, 'brown')
	img = Image.new('RGB', (W, H))
	tiles = set()
	for ty in range(8):
		for tx in range(12):
			if (ty, tx) in special:
				t, p = special[(ty, tx)]
				px = kanto_tile(t)
			else:
				p = pals[ty][tx]
				px = [[g[ty * 8 + j][tx * 8 + i] for i in range(8)] for j in range(8)]
				k = tuple(map(tuple, px))
				flips = {k, tuple(r[::-1] for r in k)}
				if not flips & tiles:
					tiles.add(k)
			for j in range(8):
				for i in range(8):
					img.putpixel((tx * 8 + i, ty * 8 + j), PAL[p][px[j][i]])
	return img, len(tiles)

if __name__ == '__main__':
	e = R.ENGINES['cse']('summer', 'day')
	city = R.render_map(e, e.load_maps()['CeladonCity'])
	crop = (0, 12 * 32, 8 * 32, 16 * 32)
	panels = [city.crop(crop)]
	for rp in ('water', 'roof', 'gray'):
		c = city.copy()
		b, n = building(rp)
		print(rp, 'new tiles', n)
		c.paste(b, (32, 13 * 32))
		panels.append(c.crop(crop))
	pw, ph = panels[0].size
	sheet = Image.new('RGB', (pw * 2 + 8, ph * 2 + 8), (255, 255, 255))
	for i, p in enumerate(panels):
		sheet.paste(p, ((i % 2) * (pw + 8), (i // 2) * (ph + 8)))
	sheet.resize((sheet.width * 3, sheet.height * 3), Image.NEAREST).save(sys.argv[1])

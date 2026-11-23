# draft2.py OUT.png — Phipps-style greenhouse: bell-hipped ribbed glass roof, front dome with
# lantern, white mullioned facade, opaque glass. Run from the repo root.
import sys, math
sys.path.insert(0, 'utils')
import render_overworld as R
from PIL import Image

W, H = 96, 64
CX = 47.5
SLOT = {'gray': 0, 'green': 2, 'water': 3, 'yellow': 4, 'brown': 5, 'roof': 6}

def art():
	g = [[0] * W for _ in range(H)]
	glass = [[False] * W for _ in range(H)]  # drawn in the glass palette
	# main roof, y 0-39: bell profile, ribs converging to the ridge
	def hw(y):
		return 25 + 22 * math.sin(min(y, 30) / 30 * math.pi / 2)
	for y in range(40):
		h = hw(y)
		for x in range(W):
			d = x - CX
			if abs(d) > h:
				continue
			glass[y][x] = True
			edge = abs(d) > h - 1
			f = d / h  # -1..1 across the roof
			rib = abs((f * 9) - round(f * 9)) * h / 9 < 0.5
			if y == 0 or edge:
				c = 3
			elif y == 1:
				c = 2
			elif rib:
				c = 2
			elif y in (14, 27):
				c = 2 if x % 2 else 1
			else:
				c = 1
				s = x + y
				if s in (34, 36, 37, 70, 72, 73, 106, 108, 109) and 3 < y < 36:
					c = 0
				elif abs(f) > 0.78 and (x + y) % 2:
					c = 2
			g[y][x] = c
		if y >= 37:  # eave
			for x in range(W):
				if glass[y][x]:
					g[y][x] = (2, 0, 3)[y - 37]
	# facade, y 40-55: white frames, round tracery, dark panes (gray palette)
	for y in range(40, 56):
		for x in range(W):
			px, py = x % 16, y - 40
			c = 0
			if py == 0:
				c = 1
			elif 1 <= py <= 6:
				r = math.hypot(px - 7.5, py - 3.5)
				c = 2 if 2.0 < r <= 3.2 else (1 if r <= 0.8 else 0)
			elif 8 <= py <= 15 and (2 <= px <= 6 or 9 <= px <= 13):
				c = 2 if (px + py) % 7 else 1
			elif py == 7:
				c = 1
			if x in (0, W - 1) or py == 15 and c == 0:
				c = 3 if x in (0, W - 1) else 1
			g[y][x] = c
	# dome, centred, x 24-71, y 22-47
	cy, rx, ry = 47.5, 23.5, 25
	for y in range(22, 48):
		t = (cy - y) / ry
		if t > 1:
			continue
		w = rx * math.sqrt(max(0, 1 - t * t))
		for x in range(24, 72):
			d = x - CX
			if abs(d) > w + 0.5:
				continue
			glass[y][x] = True
			edge = abs(d) > w - 0.6
			lat = y in (31, 38, 44)
			mer = False
			if w > 1:
				phi = math.asin(max(-1, min(1, d / w)))
				mer = abs((phi / (math.pi / 10)) - round(phi / (math.pi / 10))) * w * math.pi / 10 < 0.55
			if edge:
				c = 3
			elif lat or mer:
				c = 2
			elif d < -4 and (x - y) % 9 in (0, 1) and y < 42:
				c = 0
			elif d > w * 0.55 and (x + y) % 2:
				c = 2
			else:
				c = 1
			g[y][x] = c
	# lantern finial, y 12-22
	shape = [
		"....#....",
		"...#.#...",
		"...#.#...",
		"..#...#..",
		".#.#.#.#.",
		"#.#.#.#.#",
		"#.......#",
		"#.#.#.#.#",
		".#######.",
		"..#####..",
		"...###...",
	]
	for j, row in enumerate(shape):
		for i, ch in enumerate(row):
			x, y = 44 + i, 12 + j
			if ch == '#':
				g[y][x] = 3
			elif row.find('#') < i < row.rfind('#'):
				g[y][x] = 0
	return g, glass

def entrance(g):
	# drum, canopy and glass doors, x 24-71, y 48-63 (gray palette)
	for y in range(48, 64):
		for x in range(24, 72):
			inside = 32 <= x < 64
			if y >= 56 and not inside:
				continue
			c = 0
			if y == 48:
				c = 3
			elif inside and y in (49, 50):
				c = 3 if y == 49 else (2 if x % 3 else 3)  # canopy slats
			elif inside and y >= 51:
				dx = x - 32
				if dx in (0, 31) or y == 51:
					c = 3
				elif dx % 8 in (0, 7):
					c = 1
				else:
					c = 2 if (dx + y) % 6 else 1
			elif not inside:
				dx = x - 24 if x < 32 else 71 - x
				c = 3 if dx == 0 else (2 if 2 <= dx <= 5 and 50 <= y <= 54 else (1 if y == 55 else 0))
			g[y][x] = c

def cells(glass_pal, door_cols=(4, 5, 6, 7)):
	g, glass = art()
	entrance(g)
	out = [[None] * 12 for _ in range(8)]
	for ty in range(8):
		for tx in range(12):
			pal = 'gray'
			if any(glass[ty * 8 + j][tx * 8 + i] for j in range(8) for i in range(8)) and ty < 6:
				pal = glass_pal
			px = [[g[ty * 8 + j][tx * 8 + i] for i in range(8)] for j in range(8)]
			if pal != 'gray' and ty >= 5:  # facade bits in a dome tile: keep them white/black
				for j in range(8):
					for i in range(8):
						if not glass[ty * 8 + j][tx * 8 + i] and px[j][i] in (1, 2):
							px[j][i] = 0
			out[ty][tx] = ('art', pal, px)
	base = [0x1d] + [0x1a] * 10 + [0x3c]
	for tx, t in enumerate(base):
		if tx not in door_cols:
			out[7][tx] = ('kanto', 'gray', t)
	return out

def kanto_tile(t, im=Image.open('gfx/tilesets/kanto.png').convert('L')):
	lv = {255: 0, 170: 1, 85: 2, 0: 3}
	x, y = (t % 16) * 8, (t // 16) * 8
	return [[lv[im.getpixel((x + i, y + j))] for i in range(8)] for j in range(8)]

def building(glass_pal, pals):
	img = Image.new('RGB', (W, H))
	uniq = set()
	for ty, row in enumerate(cells(glass_pal)):
		for tx, (kind, pal, data) in enumerate(row):
			px = kanto_tile(data) if kind == 'kanto' else data
			if kind == 'art':
				k = tuple(map(tuple, px))
				if not {k, tuple(r[::-1] for r in k)} & uniq:
					uniq.add(k)
			for j in range(8):
				for i in range(8):
					img.putpixel((tx * 8 + i, ty * 8 + j), pals[SLOT[pal]][px[j][i]])
	return img, len(uniq)

if __name__ == '__main__':
	opts = ('roof', 'water', 'gray')
	rows = []
	for season, time in (('summer', 'day'), ('summer', 'nite'), ('winter', 'day')):
		e = R.ENGINES['cse'](season, time)
		m = e.load_maps()['CeladonCity']
		pals = e.render_inputs(m)[3]
		city = R.render_map(e, m)
		row = []
		for rp in opts:
			c = city.copy()
			b, n = building(rp, pals)
			c.paste(b, (32, 13 * 32))
			row.append(c.crop((0, 12 * 32, 8 * 32, 16 * 32)))
		rows.append(row)
	print('unique art tiles:', n)
	pw, ph = rows[0][0].size
	sheet = Image.new('RGB', (3 * (pw + 6), 3 * (ph + 6)), (255, 255, 255))
	for j, row in enumerate(rows):
		for i, p in enumerate(row):
			sheet.paste(p, (i * (pw + 6), j * (ph + 6)))
	sheet.resize((sheet.width * 2, sheet.height * 2), Image.NEAREST).save(sys.argv[1])

# draft3.py OUT.png — the greenhouse as a plain Kanto building whose walls (and optionally roof)
# are Battle Tower glass. Columns: lavender/grey glass x brick-roof/glass-roof; rows: day, nite.
# Run from the repo root.
import sys, subprocess, io
sys.path.insert(0, 'utils')
import render_overworld as R
from PIL import Image

SLOT = {'gray': 0, 'green': 2, 'water': 3, 'yellow': 4, 'brown': 5, 'roof': 6}
ORIG = Image.open(io.BytesIO(subprocess.run(['git', 'show', '03a767715~1:gfx/tilesets/kanto.png'],
	capture_output=True, check=True).stdout)).convert('L')
LV = {255: 0, 170: 1, 85: 2, 0: 3}

def kanto(t):
	x, y = (t % 16) * 8, (t // 16) * 8
	return [[LV[ORIG.getpixel((x + i, y + j))] for i in range(8)] for j in range(8)]

def pane(w, h, streaks, frame_bottom=True):
	# Battle Tower window: mullion and shadow at top-left, light streaks, frame line below
	g = [[1] * w for _ in range(h)]
	for y in range(h):
		for x in range(w):
			if x == 0:
				g[y][x] = 3
			elif y == 0 or x == 1:
				g[y][x] = 2
			elif any(x + y == s for s in streaks) or any(x + y == s + 1 for s in streaks[:1]):
				g[y][x] = 0
		if frame_bottom and y == h - 1:
			g[y] = [3] * w
	return g

def wall():
	# x 8-87, y 32-55 in building pixels; 16px panes, a sill, short lower panes
	g = [[0] * 80 for _ in range(24)]
	for p in range(5):
		up = pane(16, 16, [9, 12] if p % 2 == 0 else [14, 17])
		lo = pane(16, 8, [6] if p % 2 else [11], frame_bottom=False)
		for y in range(16):
			for x in range(16):
				g[y][p * 16 + x] = up[y][x]
		for y in range(8):
			for x in range(16):
				g[16 + y][p * 16 + x] = lo[y][x]
	return g

def glass_roof():
	# x 8-87, y 5-23: rafters every 16px, one glazing bar, streaks
	g = [[1] * 80 for _ in range(19)]
	for y in range(19):
		for x in range(80):
			px = x % 16
			if px == 0:
				g[y][x] = 2
			elif y == 9:
				g[y][x] = 2
			elif y in (0, 10) and px < 3:
				g[y][x] = 2
			elif (px + y) in ((13, 15) if (x // 16) % 2 == 0 else (8, 10)) and y < 9:
				g[y][x] = 0
			elif (px + y - 10) in ((12, 14) if (x // 16) % 2 else (7, 9)) and y > 10:
				g[y][x] = 0
	return g

ROOF_BLOCKS = [[0x4c] + [0x4e] * 10 + [0x4d],
	[0x5a] + [0x5e] * 10 + [0x5a],
	[0x5a] + [0x5e] * 10 + [0x5a],
	[0x5c] + [0x5f] * 10 + [0x5d]]

def cells(glass_pal, glass_top, door=4):
	out = [[None] * 12 for _ in range(8)]
	for ty in range(4):
		for tx in range(12):
			t = ROOF_BLOCKS[ty][tx]
			px = kanto(t)
			if ty == 1 or ty == 2:
				flip = tx == 11
				if flip:
					px = [r[::-1] for r in px]
			out[ty][tx] = ('gray', px)
	if glass_top:
		r = glass_roof()
		for ty in range(3):
			for tx in range(1, 11):
				px = [row[:] for row in out[ty][tx][1]]
				for j in range(8):
					y = ty * 8 + j
					if 5 <= y < 24:
						for i in range(8):
							px[j][i] = r[y - 5][(tx - 1) * 8 + i]
				out[ty][tx] = (glass_pal, px)
	w = wall()
	for ty in range(4, 7):
		for tx in range(1, 11):
			out[ty][tx] = (glass_pal, [[w[(ty - 4) * 8 + j][(tx - 1) * 8 + i] for i in range(8)] for j in range(8)])
		out[ty][0] = ('gray', kanto(0x0f))
		out[ty][11] = ('gray', kanto(0x1f))
	out[6][door] = ('yellow', kanto(0x0b))
	out[6][door + 1] = ('yellow', kanto(0x0c))
	base = [0x1d] + [0x1a] * 10 + [0x3c]
	for tx, t in enumerate(base):
		out[7][tx] = ('gray', kanto(t))
	out[7][door] = ('brown', kanto(0x1b))
	out[7][door + 1] = ('brown', kanto(0x1c))
	return out

def building(glass_pal, glass_top, pals):
	img = Image.new('RGB', (96, 64))
	for ty, row in enumerate(cells(glass_pal, glass_top)):
		for tx, (pal, px) in enumerate(row):
			for j in range(8):
				for i in range(8):
					img.putpixel((tx * 8 + i, ty * 8 + j), pals[SLOT[pal]][px[j][i]])
	return img

if __name__ == '__main__':
	opts = [('water', False), ('water', True), ('gray', False), ('gray', True)]
	rows = []
	for season, time in (('summer', 'day'), ('summer', 'nite')):
		e = R.ENGINES['cse'](season, time)
		m = e.load_maps()['CeladonCity']
		pals = e.render_inputs(m)[3]
		city = R.render_map(e, m)
		row = []
		for gp, top in opts:
			c = city.copy()
			c.paste(building(gp, top, pals), (32, 13 * 32))
			row.append(c.crop((0, 12 * 32 + 16, 8 * 32, 15 * 32 + 16)))
		rows.append(row)
	pw, ph = rows[0][0].size
	sheet = Image.new('RGB', (2 * (pw + 6), 4 * (ph + 6)), (255, 255, 255))
	for j, row in enumerate(rows):
		for i, p in enumerate(row):
			sheet.paste(p, ((i % 2) * (pw + 6), (j * 2 + i // 2) * (ph + 6)))
	sheet.resize((sheet.width * 3, sheet.height * 3), Image.NEAREST).save(sys.argv[1])

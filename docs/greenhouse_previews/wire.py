# wire.py — writes the greenhouse art into the Kanto tileset and Celadon City.
# Run once from the repo root against a clean kanto.png / metatiles / attributes.
import sys
sys.path.insert(0, 'docs/greenhouse_previews')
import draft
from PIL import Image

GRAY, GREEN, YELLOW, BROWN, ROOF = 0, 2, 4, 5, 6
BANK1, XFLIP, YFLIP = 0x08, 0x20, 0x40
DOOR_COL = 4  # building column; step (4,29) on the map

W = 96
g = draft.roof() + [[0] * W for _ in range(32)]
pl = [draft.plants(0), draft.plants(1)]
for y in range(24):
	for x in range(W):
		g[32 + y][x] = pl[(x // 16) % 2][y][x % 16]
for y in range(32, 56):
	g[y][0] = g[y][W - 1] = 3

# (tile, attr) for each of the 12x8 cells
cells = [[None] * 12 for _ in range(8)]
new_tiles = []  # pixel tuples, index = bank 1 tile id
lookup = {}
for ty in range(8):
	for tx in range(12):
		if ty == 7 or (ty == 6 and tx in (DOOR_COL, DOOR_COL + 1)):
			continue
		px = tuple(tuple(g[ty * 8 + j][tx * 8 + i] for i in range(8)) for j in range(8))
		if px not in lookup:
			tid = len(new_tiles)
			new_tiles.append(px)
			for flip, f in ((XFLIP, lambda p: tuple(r[::-1] for r in p)),
					(YFLIP, lambda p: p[::-1]),
					(XFLIP | YFLIP, lambda p: tuple(r[::-1] for r in p[::-1]))):
				lookup.setdefault(f(px), (tid, flip))
			lookup[px] = (tid, 0)
		tid, flip = lookup[px]
		pal = ROOF if ty < 4 else GREEN
		cells[ty][tx] = (tid, pal | BANK1 | flip)
base = [0x1d] + [0x1a] * 10 + [0x3c]
for tx, t in enumerate(base):
	cells[7][tx] = (t, GRAY)
c = DOOR_COL
cells[6][c], cells[6][c + 1] = (0x0b, YELLOW), (0x0c, YELLOW)
cells[7][c], cells[7][c + 1] = (0x1b, BROWN), (0x1c, BROWN)
print('new bank 1 tiles:', len(new_tiles))

# kanto.png: append rows; png index 128 + id is bank 1 tile id
png = Image.open('gfx/tilesets/kanto.png').convert('L')
assert png.size == (128, 64), png.size
rows = (len(new_tiles) + 15) // 16
out = Image.new("L", (128, 64 + rows * 8), 255)
out.paste(png, (0, 0))
shade = [255, 170, 85, 0]
for i, px in enumerate(new_tiles):
	x0, y0 = (i % 16) * 8, 64 + (i // 16) * 8
	for j in range(8):
		for k in range(8):
			out.putpixel((x0 + k, y0 + j), shade[px[j][k]])
out.save('gfx/tilesets/kanto.png')

# six blocks: roof row then wall row, left to right
meta = bytearray(open('data/tilesets/kanto_metatiles.bin', 'rb').read())
attr = bytearray(open('data/tilesets/kanto_attributes.bin', 'rb').read())
first = len(meta) // 16
assert first == 0x84, hex(first)
for by in range(2):
	for bx in range(3):
		for i in range(16):
			t, a = cells[by * 4 + i // 4][bx * 4 + i % 4]
			meta.append(t)
			attr.append(a)
open('data/tilesets/kanto_metatiles.bin', 'wb').write(meta)
open('data/tilesets/kanto_attributes.bin', 'wb').write(attr)

coll = open('data/tilesets/kanto_collision.asm').read()
for b in range(first, first + 6):
	q = ['WALL'] * 4
	if b == first + 4:
		q[2] = 'DOOR'
	coll += '\ttilecoll %s ; %02x\n' % (', '.join(q), b)
open('data/tilesets/kanto_collision.asm', 'w').write(coll)

blk = bytearray(open('maps/CeladonCity.ablk', 'rb').read())
for by in range(2):
	for bx in range(3):
		blk[(13 + by) * 20 + 1 + bx] = first + by * 3 + bx
open('maps/CeladonCity.ablk', 'wb').write(blk)
print('blocks %02x-%02x' % (first, first + 5))

# wire2.py — writes the Phipps-style greenhouse (draft2.py, grey glass) into the Kanto tileset
# and Celadon City. Restores the tileset files from HEAD first, so it can be re-run.
import sys, subprocess
sys.path.insert(0, 'docs/greenhouse_previews')
import draft2
from PIL import Image

FILES = ['gfx/tilesets/kanto.png', 'data/tilesets/kanto_metatiles.bin',
	'data/tilesets/kanto_attributes.bin', 'data/tilesets/kanto_collision.asm', 'maps/CeladonCity.ablk']
subprocess.run(['git', 'checkout', 'HEAD', '--'] + FILES, check=True)

SLOT = draft2.SLOT
BANK1, XFLIP, YFLIP = 0x08, 0x20, 0x40
GLASS = 'gray'

cells = [[None] * 12 for _ in range(8)]
new_tiles, lookup = [], {}
for ty, row in enumerate(draft2.cells(GLASS)):
	for tx, (kind, pal, data) in enumerate(row):
		if kind == 'kanto':
			cells[ty][tx] = (data, SLOT[pal])
			continue
		px = tuple(map(tuple, data))
		if px not in lookup:
			tid = len(new_tiles)
			new_tiles.append(px)
			lookup[px] = (tid, 0)
			for flip, f in ((XFLIP, lambda p: tuple(r[::-1] for r in p)),
					(YFLIP, lambda p: p[::-1]),
					(XFLIP | YFLIP, lambda p: tuple(r[::-1] for r in p[::-1]))):
				lookup.setdefault(f(px), (tid, flip))
		tid, flip = lookup[px]
		cells[ty][tx] = (tid, SLOT[pal] | BANK1 | flip)
assert len(new_tiles) <= 128
print('new bank 1 tiles:', len(new_tiles))

# png index 128 + id is VRAM bank 1 tile id
png = Image.open('gfx/tilesets/kanto.png').convert('L')
assert png.size == (128, 64), png.size
out = Image.new('L', (128, 64 + (len(new_tiles) + 15) // 16 * 8), 255)
out.paste(png, (0, 0))
shade = [255, 170, 85, 0]
for i, px in enumerate(new_tiles):
	x0, y0 = (i % 16) * 8, 64 + (i // 16) * 8
	for j in range(8):
		for k in range(8):
			out.putpixel((x0 + k, y0 + j), shade[px[j][k]])
out.save('gfx/tilesets/kanto.png')

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
	if b == first + 4:  # bottom middle: steps (4,29) and (5,29)
		q[2] = q[3] = 'DOOR'
	coll += '\ttilecoll %s ; %02x\n' % (', '.join(q), b)
open('data/tilesets/kanto_collision.asm', 'w').write(coll)

blk = bytearray(open('maps/CeladonCity.ablk', 'rb').read())
for by in range(2):
	for bx in range(3):
		blk[(13 + by) * 20 + 1 + bx] = first + by * 3 + bx
open('maps/CeladonCity.ablk', 'wb').write(blk)
print('blocks %02x-%02x' % (first, first + 5))

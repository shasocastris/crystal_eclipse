"""Candidate looks for the water cave mouth (mirror of johto a9/aa) and the dais spring. PNG only."""
from lib import *
import mock
S = os.environ.get('OUT', HERE)
J = tiles_of('johto')
def variant(pal, rm, flip=True):
	tiles, meta, attr, pals, ids = mock.build('1 dark (water slot as is)', 'B native ledges')
	for i, src in enumerate((0x69, 0x6a, 0x6b)): tiles[0x60 + i] = mock.remap(J[src], rm)
	W = (0x35, 3); F = lambda r, c: (mock.META[0x19 * 16 + r * 4 + c], mock.ATTR[0x19 * 16 + r * 4 + c])
	A = lambda i: (0x60 + i, pal | (0x40 if flip else 0))
	L = [F(0, 0), (0x1c, 14), W, W, F(1, 0), (0x1c, 14), W, W, F(2, 0), F(2, 1), A(0), A(1), F(3, 0), F(3, 1), F(3, 2), F(3, 3)]
	R = [W, W, (0x18, 14), F(0, 3), W, W, (0x18, 14), F(1, 3), A(1), A(2), F(2, 2), F(2, 3), F(3, 0), F(3, 1), F(3, 2), F(3, 3)]
	SP = [(0x1a, 14)] * 8 + [(0x31, 3)] * 8
	for n, c in (('mL', L), ('mR', R), ('sp', SP)):
		ids[n] = len(meta) // 16; meta.extend(x[0] for x in c); attr.extend(x[1] for x in c)
	g = [[0x19, 0x02, ids['b010'], ids['b001'], 0x02, 0x19], [0x19, 0x19, ids['b010'], ids['b001'], 0x19, 0x19],
		[0x19, 0x19, ids['mL'], ids['mR'], 0x19, 0x19], [0x19] * 6]
	d = [[0x04, 0x05, 0x05, 0x05, 0x05, 0x06], [0x08, 0x09, 0x09, 0x09, 0x09, 0x0a],
		[0x0c, 0x12, ids['sp'], ids['sp'], 0x12, 0x0e], [0x02, 0x02, ids['b010'], ids['b001'], 0x02, 0x02]]
	img = Image.new('RGB', (6 * 32, 8 * 32 + 8), (30, 30, 34))
	for y, row in enumerate(g + d):
		for x, b in enumerate(row): draw_block(img, x * 32, y * 32 + (8 if y >= 4 else 0), b, meta, attr, tiles, pals)
	return img.resize((img.width * 3, img.height * 3), Image.NEAREST)
mock.S = S
mock.board([('a: arch flipped, ice pal', variant(6, (0, 1, 2, 3))), ('b: arch flipped, glow pal', variant(4, (0, 1, 2, 3))),
	('c: glow pal, slot lit', variant(4, (1, 2, 3, 0))), ('d: ice pal, slot lit', variant(6, (1, 2, 3, 0)))], 'mouth_options')

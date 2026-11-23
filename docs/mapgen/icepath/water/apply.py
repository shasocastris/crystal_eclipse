"""Writes the chosen water (option B banks, dark water) into TILESET_ICE_PATH. Rerunning appends only blocks not there yet.

Touches gfx/tilesets/ice_path.png (tiles $31 waterfall, $35 water) and appends blocks $40-$4b to
data/tilesets/ice_path_{metatiles,attributes}.bin and ice_path_collision.asm.
"""
import sys
sys.exit('apply.py is retired: shasocastris reworked blocks 40-53 by hand on 2026-11-11; running it would overwrite them.')
from lib import *
import mock
from PIL import Image
meta_p, attr_p, coll_p = (f'data/tilesets/ice_path_{n}' for n in ('metatiles.bin', 'attributes.bin', 'collision.asm'))
have = os.path.getsize(meta_p) // 16
tiles, meta, attr, pals, ids = mock.build('1 dark (water slot as is)', 'B native ledges')
im = Image.open('gfx/tilesets/ice_path.png')
new_tiles = ([mock.WATER, mock.FALL] if have == 64 else []) + ([mock.ARCH + i for i in range(3)] if have <= 0x4d else [])
for t in new_tiles:
	for y, row in enumerate(px(tiles[t])):
		for x, c in enumerate(row):
			im.putpixel(((t % 16) * 8 + x, (t // 16) * 8 + y), 255 - c * 85)
im.save('gfx/tilesets/ice_path.png')
open(meta_p, 'wb').write(meta); open(attr_p, 'wb').write(attr)
names = {v: k for k, v in ids.items()}
COLL = {'f': ['WATERFALL'] * 4, 'fw': ['WALL'] * 4, 'mL': ['WALL', 'WARP_SURF_DOWN', 'WALL', 'WALL'],
	'mR': ['WARP_SURF_DOWN', 'WALL', 'WALL', 'WALL'], 'sp': ['FLOOR', 'FLOOR', 'WALL', 'WALL']}
with open(coll_p, 'a') as f:
	for b in range(have, len(meta) // 16):
		c = COLL.get(names[b], ['WATER'] * 4)
		f.write(f'\ttilecoll {", ".join(c)} ; {b:02x}\n')
print({k: hex(v) for k, v in ids.items()})

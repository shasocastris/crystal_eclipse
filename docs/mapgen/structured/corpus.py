"""Load Johto maps + Johto block collision from the repo (read-only)."""
import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import os, re
REPO = f'{_REPO_ROOT}'

def _r(p): return open(os.path.join(REPO, p)).read()

def camel_to_const(n):
	s = re.sub(r'(?<=[a-z])(?=[A-Z0-9])|(?<=[0-9])(?=[A-Z])', '_', n).upper()
	return s

def load_collision():
	coll = []
	for line in _r('data/tilesets/johto_collision.asm').splitlines():
		m = re.match(r'\s*tilecoll\s+(\w+),\s*(\w+),\s*(\w+),\s*(\w+)', line)
		if m: coll.append(tuple(m.groups()))
	return coll

WALKABLE = {'FLOOR','TALL_GRASS','LONG_GRASS','01','CHERRY_LEAVES','UP_WALL','DOWN_WALL','LEFT_WALL','RIGHT_WALL','LADDER','DOOR','CAVE'}
def qclass(c):
	if c.startswith('HOP_'): return 'hop_' + c[4:].lower()
	if c in ('WATER','WHIRLPOOL') : return 'water'
	if c.startswith('WARP') or c in ('DOOR','CAVE','LADDER'): return 'warp'
	if c in ('FLOOR','01','CHERRY_LEAVES','UP_WALL','DOWN_WALL','LEFT_WALL','RIGHT_WALL'): return 'floor'
	if c in ('TALL_GRASS','LONG_GRASS'): return 'grass'
	if c == 'CUT_TREE': return 'cut'
	if c == 'HEADBUTT_TREE': return 'tree'
	return 'wall'

def load_maps():
	sizes = {}
	for m in re.finditer(r'map_const\s+(\w+),\s*(\d+),\s*(\d+)', _r('constants/map_constants.asm')):
		sizes[m.group(1)] = (int(m.group(2)), int(m.group(3)))
	names = re.findall(r'^\s*map\s+(\w+),\s*TILESET_JOHTO,', _r('data/maps/maps.asm'), re.M)
	blk = _r('data/maps/blocks.asm')
	out = {}
	for n in names:
		m = re.search(n + r'_Blocks:\s*\n\s*INCBIN\s+"([^"]+)"', blk)
		if not m: continue
		c = camel_to_const(n)
		if c not in sizes:
			c2 = [k for k in sizes if k.replace('_','') == n.upper()]
			if not c2: continue
			c = c2[0]
		w, h = sizes[c]
		data = open(os.path.join(REPO, m.group(1)), 'rb').read()
		if len(data) != w*h: continue
		out[n] = (w, h, data)
	return out

if __name__ == '__main__':
	ms = load_maps(); print(len(ms), sorted(ms))
	print(len(load_collision()))

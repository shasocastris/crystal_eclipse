"""Load TILESET_JOHTO training maps, per-block collision, and walkability checks."""
import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import os, re
from collections import deque

REPO = f'{_REPO_ROOT}'


def _read(p):
	return open(os.path.join(REPO, p)).read()


def _snake(name):
	# RuinsOfAlphOutside -> RUINS_OF_ALPH_OUTSIDE ; Route30 -> ROUTE_30 ; DragonsDenB1F -> DRAGONS_DEN_B1F
	s = re.sub(r'(?<=[a-z])(?=[A-Z0-9])', '_', name)
	s = re.sub(r'(?<=[0-9])(?=[A-Z][a-z])', '_', s)
	return s.upper()


def load_maps(exclude=('DragonsDenB1F',)):
	"""Return {name: (w, h, bytes)} for every TILESET_JOHTO map."""
	names = re.findall(r'^\s*map (\w+),\s*TILESET_JOHTO,', _read('data/maps/maps.asm'), re.M)
	dims = {m[0]: (int(m[1]), int(m[2]))
		for m in re.findall(r'map_const (\w+),\s*(\d+),\s*(\d+)', _read('constants/map_constants.asm'))}
	blk = _read('data/maps/blocks.asm')
	files = {}
	labels = []
	for line in blk.splitlines():
		m = re.match(r'^(\w+)_Blocks:', line)
		if m:
			labels.append(m.group(1))
			continue
		m = re.search(r'INCBIN "([^"]+)"', line)
		if m:
			for l in labels:
				files[l] = m.group(1)
			labels = []
	out = {}
	for n in names:
		if n in exclude:
			continue
		key = _snake(n)
		if key not in dims or n not in files:
			print('skip', n, key in dims, n in files)
			continue
		w, h = dims[key]
		data = open(os.path.join(REPO, files[n]), 'rb').read()
		if len(data) != w * h:
			print('size mismatch', n, len(data), w * h)
			continue
		out[n] = (w, h, data)
	return out


# ---- collision ----------------------------------------------------------

def _consts():
	c = {}
	for m in re.findall(r'DEF COLL_(\w+)\s+EQU \$([0-9a-f]+)', _read('constants/collision_constants.asm')):
		c[m[0]] = int(m[1], 16)
	return c


def _perms():
	"""collision byte -> 'L', 'W'(water), 'X'(wall)."""
	txt = _read('data/collision/collision_permissions.asm')
	rows = re.findall(r'^\s*db (\w+)', txt, re.M)
	return ['L' if r.startswith('LAND') else 'W' if r.startswith('WATER') else 'X' for r in rows]


CONST = _consts()
PERM = _perms()
HOPS = {CONST[k]: k for k in CONST if k.startswith('HOP_')}


def block_collision():
	"""list[block] -> (TL, TR, BL, BR) collision bytes."""
	out = []
	for m in re.findall(r'tilecoll (\w+), (\w+), (\w+), (\w+)', _read('data/tilesets/johto_collision.asm')):
		out.append(tuple(CONST[x] if x in CONST else int(x, 16) for x in m))
	return out


COLL = block_collision()


def quad_grid(blocks, w):
	"""Expand a block map into a 2x-size grid of collision bytes."""
	h = len(blocks) // w
	g = [[0] * (w * 2) for _ in range(h * 2)]
	for i, b in enumerate(blocks):
		x, y = i % w, i // w
		tl, tr, bl, br = COLL[b]
		g[y * 2][x * 2], g[y * 2][x * 2 + 1] = tl, tr
		g[y * 2 + 1][x * 2], g[y * 2 + 1][x * 2 + 1] = bl, br
	return g


DIRS = {'UP': (0, -1), 'DOWN': (0, 1), 'LEFT': (-1, 0), 'RIGHT': (1, 0)}


def _hop_ok(name, dx, dy):
	need = name[4:]  # HOP_DOWN_LEFT -> DOWN_LEFT
	parts = need.split('_')
	return any(DIRS[p] == (dx, dy) for p in parts)


def reachable(blocks, w, starts, surf=False):
	"""BFS over 2x2-tile step cells. Ledges are one-way (land two cells on)."""
	g = quad_grid(blocks, w)
	H, W = len(g), len(g[0])
	def ok(c):
		p = PERM[c] if c < len(PERM) else 'X'
		return p == 'L' or (surf and p == 'W')
	seen = set()
	q = deque()
	for s in starts:
		if ok(g[s[1]][s[0]]):
			seen.add(s); q.append(s)
	while q:
		x, y = q.popleft()
		for dx, dy in DIRS.values():
			nx, ny = x + dx, y + dy
			if not (0 <= nx < W and 0 <= ny < H):
				continue
			c = g[ny][nx]
			if c in HOPS:
				if not _hop_ok(HOPS[c], dx, dy):
					continue
				nx, ny = nx + dx, ny + dy  # jump over the ledge
				if not (0 <= nx < W and 0 <= ny < H) or not ok(g[ny][nx]) or g[ny][nx] in HOPS:
					continue
			elif not ok(c):
				continue
			if (nx, ny) not in seen:
				seen.add((nx, ny)); q.append((nx, ny))
	return seen, g


def edge_cells(g, side):
	H, W = len(g), len(g[0])
	if side == 'N': return [(x, 0) for x in range(W)]
	if side == 'S': return [(x, H - 1) for x in range(W)]
	if side == 'W': return [(0, y) for y in range(H)]
	return [(W - 1, y) for y in range(H)]


def walk_report(blocks, w):
	"""Which map edges are open, and whether each open edge reaches each other one (both directions)."""
	g = quad_grid(blocks, w)
	open_sides = {}
	for s in 'NSWE':
		cells = [c for c in edge_cells(g, s) if PERM[g[c[1]][c[0]]] == 'L' and g[c[1]][c[0]] not in HOPS]
		if cells:
			open_sides[s] = cells
	res = {}
	land = sum(1 for row in g for c in row if PERM[c] == 'L')
	for a, cells in open_sides.items():
		seen, _ = reachable(blocks, w, cells)
		for b, cells_b in open_sides.items():
			if a != b:
				res[a + '->' + b] = any(c in seen for c in cells_b)
		res[a + '_cover'] = len(seen) / max(1, land)
	return open_sides.keys(), res

#!/usr/bin/env python3
"""Structure-first procedural map generator for TILESET_JOHTO.

Pipeline:
  1. skeleton  -> semantic grid (TREE/GRASS/TALL/PATH/WATER/LEDGE/...) built the
                  way a designer would: exits, a winding main path, clearings,
                  side branches with items, a one-way ledge shortcut, ponds,
                  Cut / Surf gated pockets, trainer spots.
  2. autotile  -> real Johto block ids (pond edges, ledge ends, building stamps,
                  quadrant-level tree fringe).
  3. verify    -> quadrant-level BFS using johto_collision.asm (ledges one-way,
                  surf / cut as optional abilities).

  python3 structgen.py forest  --seed 3 --out DIR
  python3 structgen.py lake    --seed 7 --out DIR
  python3 structgen.py town    --seed 1 --out DIR
"""
import argparse, heapq, json, math, os, random, sys
from collections import deque

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from corpus import load_collision, qclass

# ---------------------------------------------------------------- semantics
TREE, GRASS, TALL, PATH, FLOWER, WATER, LEDGE, SIGN, BUILD, CUT, PSIGN, FENCE = \
	'T', 'G', 't', 'P', 'F', 'W', 'L', 'S', 'B', 'C', 's', 'f'
OPEN = {GRASS, TALL, PATH, FLOWER}
SEM_COLOR = {TREE: (24, 92, 40), GRASS: (140, 210, 90), TALL: (60, 160, 60),
	PATH: (226, 214, 170), FLOWER: (240, 140, 180), WATER: (70, 110, 230),
	LEDGE: (150, 90, 30), SIGN: (255, 255, 255), PSIGN: (255, 255, 255),
	BUILD: (200, 60, 120), CUT: (255, 150, 0), FENCE: (120, 120, 120)}

# ---------------------------------------------------------------- block ids
B_GRASS, B_PATH, B_TALL, B_FLOWER, B_FOREST = 0x02, 0x01, 0x03, 0x04, 0x05
B_SIGN_GRASS, B_SIGN_PATH = 0x47, 0x45
# tree quadrant mask (TL,TR,BL,BR bits 8,4,2,1) -> block; from johto_collision
TREE_MASK = {0b1111: 0x05, 0b1100: 0x5d, 0b1110: 0x5c, 0b1101: 0x5e,
	0b1010: 0x60, 0b0101: 0x62, 0b1011: 0x64, 0b0011: 0x65, 0b0111: 0x66,
	0b1000: 0x3c, 0b0100: 0x3d, 0b0010: 0x3e, 0b0001: 0x3f, 0: 0x02}
# cut gates: which travel axis they block
CUT_VERT = [0x63, 0x5b]   # blocks N<->S travel (a full row of cut+tree)
CUT_HORZ = [0x67, 0x5f]   # blocks E<->W travel
# pond (block-level 8-neighbour autotile, derived from corpus adjacency)
POND = dict(tl=0x54, top=0x76, tr=0x55, left=0x58, mid=0x35, right=0x59,
	inner_tl=0x79, inner_tr=0x7a)
LEDGE_ON = {GRASS: 0x57, PATH: 0x56}
LEDGE_END_R = {GRASS: 0x4b, PATH: 0x5a}   # ledge on left half, rounded tip
# building stamps: rows of blocks, door = (dx,dy) of block whose bottom is a door
STAMPS = {
	'pokecenter': ([[0x18, 0x19], [0x1a, 0x1b]], (0, 1)),
	'mart':       ([[0x18, 0x19], [0x16, 0x17]], (0, 1)),
	'gym':        ([[0x18, 0x1f, 0x19], [0x1c, 0x1d, 0x1e]], (1, 1)),
	'house':      ([[0x18, 0x19], [0x16, 0x1e]], (0, 1)),
	'house2':     ([[0x18, 0x19], [0x1a, 0x11]], (0, 1)),
	'cottage':    ([[0x14, 0x15]], (0, 0)),
}
FENCE_L, FENCE_M, FENCE_R = 0x48, 0x49, 0x4a

DIRS = [(0, -1), (1, 0), (0, 1), (-1, 0)]


# ---------------------------------------------------------------- utilities
class Noise:
	"""Seeded value noise, bilinear, a few octaves. Returns ~[0,1]."""
	def __init__(self, rng, w, h, scale=4.0, octaves=2):
		self.layers = []
		for o in range(octaves):
			s = scale / (2 ** o)
			gw, gh = int(w / s) + 3, int(h / s) + 3
			self.layers.append((s, [[rng.random() for _ in range(gw)] for _ in range(gh)], 0.5 ** o))
	def __call__(self, x, y):
		tot = norm = 0
		for s, g, amp in self.layers:
			fx, fy = x / s, y / s
			ix, iy = int(fx), int(fy)
			tx, ty = fx - ix, fy - iy
			tx, ty = tx * tx * (3 - 2 * tx), ty * ty * (3 - 2 * ty)
			a = g[iy][ix] * (1 - tx) + g[iy][ix + 1] * tx
			b = g[iy + 1][ix] * (1 - tx) + g[iy + 1][ix + 1] * tx
			tot += amp * (a * (1 - ty) + b * ty); norm += amp
		return tot / norm


class MapPlan:
	def __init__(self, w, h, seed, fill=TREE):
		assert (w + 6) * (h + 6) <= 1300, 'map buffer limit'
		self.w, self.h = w, h
		self.rng = random.Random(seed)
		self.seed = seed
		self.g = [[fill] * w for _ in range(h)]
		self.exits = []        # dicts: side, cells[(x,y)]
		self.events = []       # dicts: kind, x, y (block coords), extra
		self.stamps = []       # (name, x, y)
		self.locked = set()    # cells autotile/fringe must not touch
		self.spine = set()     # main path + branch cells (no fringe trees)
		self.notes = []
		self.keep_tree = set()  # trees that must stay (ledge / spur flanks)
		self.cut_dir = {}

	def inb(self, x, y): return 0 <= x < self.w and 0 <= y < self.h
	def get(self, x, y, oob=None): return self.g[y][x] if self.inb(x, y) else oob
	def set(self, x, y, v):
		if self.inb(x, y) and ((x, y) not in self.keep_tree or v == TREE): self.g[y][x] = v
	def cells(self):
		for y in range(self.h):
			for x in range(self.w): yield x, y
	def n4(self, x, y):
		for dx, dy in DIRS:
			if self.inb(x + dx, y + dy): yield x + dx, y + dy

	# ---------------- path finding over a cost function
	def dijkstra(self, starts, goal, cost):
		dist = {s: 0 for s in starts}; prev = {}
		pq = [(0, s) for s in starts]
		while pq:
			d, c = heapq.heappop(pq)
			if c == goal: break
			if d > dist.get(c, 1e18): continue
			for n in self.n4(*c):
				k = cost(c, n)
				if k is None: continue
				nd = d + k
				if nd < dist.get(n, 1e18):
					dist[n] = nd; prev[n] = c; heapq.heappush(pq, (nd, n))
		if goal not in dist: return None
		out = [goal]
		while out[-1] in prev: out.append(prev[out[-1]])
		return out[::-1]


# ---------------------------------------------------------------- skeleton
def edge_cell(p, side, t):
	"""t in [0,1] along the side, kept off the corners."""
	if side in 'NS':
		x = max(2, min(p.w - 3, int(round(t * (p.w - 1)))))
		return (x, 0 if side == 'N' else p.h - 1)
	y = max(2, min(p.h - 3, int(round(t * (p.h - 1)))))
	return (0 if side == 'W' else p.w - 1, y)


def add_exit(p, side, t, width=2):
	x, y = edge_cell(p, side, t)
	cells = []
	for i in range(width):
		c = (x + i, y) if side in 'NS' else (x, y + i)
		cells.append(c)
	p.exits.append(dict(side=side, cells=cells))
	return cells


def carve_main_path(p, noise, waypoints=2, wiggle=0.35, margin=1):
	"""Winding path through random waypoints between exits."""
	a, b = p.exits[0]['cells'], p.exits[1]['cells']
	horiz = p.exits[0]['side'] in 'WE'
	pts = [a[0]]
	for i in range(waypoints):
		f = (i + 1) / (waypoints + 1)
		if horiz:
			x = int(a[0][0] + (b[0][0] - a[0][0]) * f)
			side = 1 if i % 2 else -1
			y = p.h // 2 + side * int((p.h - 2 * margin - 2) * wiggle) + p.rng.randint(-1, 1)
			y = max(margin + 1, min(p.h - margin - 2, y))
		else:
			y = int(a[0][1] + (b[0][1] - a[0][1]) * f)
			span = int((p.w - 2 * margin - 2) * wiggle)
			side = 1 if i % 2 else -1
			cx = p.w // 2 + side * span
			x = max(margin + 1, min(p.w - margin - 2, cx + p.rng.randint(-1, 1)))
		pts.append((x, y))
	pts.append(b[0])
	exitcells = {c for e in p.exits for c in e['cells']}

	def cost(c, n):
		x, y = n
		if n not in exitcells and (x < margin or y < margin or x >= p.w - margin or y >= p.h - margin):
			return None
		k = 1 + 6 * noise(x, y) ** 2
		if p.get(x, y) == PATH: k *= 0.6
		return k
	path = []
	for s, t in zip(pts, pts[1:]):
		seg = p.dijkstra([s], t, cost)
		path += seg if not path else seg[1:]
	for c in path:
		p.set(*c, PATH); p.spine.add(c)
	prune_stubs(p)
	p.waypoints = pts[1:-1]
	for e in p.exits:              # exits fully open, connected to the path
		for c in e['cells']:
			p.set(*c, PATH); p.spine.add(c)
		inward = {'N': (0, 1), 'S': (0, -1), 'W': (1, 0), 'E': (-1, 0)}[e['side']]
		for c in e['cells']:
			x, y = c[0] + inward[0], c[1] + inward[1]
			if p.get(x, y) == TREE: p.set(x, y, GRASS)
	return path


def prune_stubs(p):
	"""Waypoint detours can leave dead-end path stubs; demote them to grass."""
	exitcells = {c for e in p.exits for c in e['cells']}
	changed = True
	while changed:
		changed = False
		for x, y in list(p.cells()):
			if p.g[y][x] == PATH and (x, y) not in exitcells and \
					sum(p.get(*n) == PATH for n in p.n4(x, y)) <= 1:
				p.g[y][x] = GRASS; p.spine.discard((x, y)); changed = True


def rooms(p, r=(1.2, 2.3), margin=1):
	"""Open a small clearing at each waypoint so the trail has 'rooms'."""
	for (cx, cy) in getattr(p, 'waypoints', []):
		rx, ry = p.rng.uniform(*r), p.rng.uniform(*r)
		for x, y in p.cells():
			if margin <= x < p.w - margin and margin <= y < p.h - margin and p.g[y][x] == TREE \
					and (x, y) not in p.keep_tree and ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1:
				p.g[y][x] = GRASS


def widen(p, path, prob=0.6, margin=1):
	"""Open a grass shoulder beside the path so it reads as a walkway."""
	for (x, y) in path:
		for dx, dy in DIRS:
			nx, ny = x + dx, y + dy
			if margin <= nx < p.w - margin and margin <= ny < p.h - margin and p.get(nx, ny) == TREE \
					and p.rng.random() < prob:
				p.set(nx, ny, GRASS)


def clearings(p, noise, thresh=0.62, margin=1):
	"""Noise blobs that touch open ground become grass clearings."""
	for _ in range(2):
		for x, y in list(p.cells()):
			if margin <= x < p.w - margin and margin <= y < p.h - margin and p.g[y][x] == TREE \
					and (x, y) not in p.keep_tree and noise(x, y) > thresh and any(p.g[ny][nx] in OPEN for nx, ny in p.n4(x, y)):
				p.g[y][x] = GRASS


def tall_grass(p, noise, thresh=0.55, gauntlet=True):
	for x, y in p.cells():
		if p.g[y][x] == GRASS and (x, y) not in p.spine and noise(x, y) > thresh:
			p.g[y][x] = TALL
	if gauntlet:          # one stretch where the path itself runs through grass
		spine = [c for c in p.spine if p.get(*c) == PATH and c not in {c for e in p.exits for c in e['cells']}]
		spine.sort(key=lambda c: (c[1], c[0]))
		if len(spine) > 8:
			i = p.rng.randint(len(spine) // 4, len(spine) * 3 // 4)
			cx, cy = spine[i]
			for x, y in p.cells():
				if abs(x - cx) + abs(y - cy) <= p.rng.choice((1, 2)) and p.g[y][x] in (PATH, GRASS) and not near_exit(p, x, y, 2):
					p.g[y][x] = TALL
			p.notes.append(f'grass gauntlet at {cx},{cy}')


def near_exit(p, x, y, r):
	return any(abs(x - ex) + abs(y - ey) <= r for e in p.exits for ex, ey in e['cells'])


def flowers(p, n=3):
	cand = [(x, y) for x, y in p.cells() if p.g[y][x] == GRASS and (x, y) not in p.spine]
	p.rng.shuffle(cand)
	for x, y in cand[:n]:
		p.g[y][x] = FLOWER
		for nx, ny in p.n4(x, y):
			if p.g[ny][nx] == GRASS and (nx, ny) not in p.spine and p.rng.random() < 0.4:
				p.g[ny][nx] = FLOWER


def tree_run(p, x, y, dx, dy, n):
	return all(p.get(x + dx * i, y + dy * i) == TREE for i in range(1, n + 1))


def side_branches(p, count=2, length=(3, 6), margin=1):
	"""Dead-end grass spurs off the main path, each ending in an item."""
	made = 0
	cand = [c for c in p.spine if p.get(*c) == PATH]
	p.rng.shuffle(cand)
	for (x, y) in cand:
		if made >= count: break
		for dx, dy in p.rng.sample(DIRS, 4):
			L = p.rng.randint(*length)
			cells = [(x + dx * i, y + dy * i) for i in range(1, L + 1)]
			ok = all(margin <= cx < p.w - margin and margin <= cy < p.h - margin and p.get(cx, cy) == TREE
				for cx, cy in cells)
			# corridor must be flanked by trees so it stays a spur
			ok = ok and all(p.get(cx + dy, cy + dx) == TREE and p.get(cx - dy, cy - dx) == TREE for cx, cy in cells[1:])
			if not ok: continue
			for c in cells:
				p.set(*c, GRASS); p.spine.add(c)
				p.keep_tree |= {(c[0] + dy, c[1] + dx), (c[0] - dy, c[1] - dx)}
			ex, ey = cells[-1]
			p.events.append(dict(kind='item', x=ex, y=ey, note='dead-end spur'))
			made += 1
			break
	return made


def ledge_shortcut(p, minlen=3, maxlen=10, mingain=6):
	"""Straight N->S corridor through the forest with a ledge in it, linking
	two path cells whose walking distance is much longer. Only the ledge row
	needs tree flanks: that row is what makes the corridor one-way."""
	best = None
	for (x, y) in [c for c in p.spine if p.get(*c) in OPEN and c[1] >= 1]:
		for ty in range(y + minlen + 1, min(p.h - 1, y + maxlen + 2)):
			col = [(x, yy) for yy in range(y + 1, ty)]
			if p.get(*col[-1]) != TREE or col[-1] in p.keep_tree: break
			if p.get(x, ty) not in OPEN: continue
			rows = [c for c in col[1:-1] if p.get(c[0] - 1, c[1]) == TREE and p.get(c[0] + 1, c[1]) == TREE]
			if not rows: break
			gain = walk_dist(p, (x, y), (x, ty))
			if gain is not None and gain - (ty - y) >= mingain:
				mid = min(rows, key=lambda c: abs(c[1] - (y + ty) / 2))
				score = gain - (ty - y)
				if best is None or score > best[0]: best = (score, x, y, ty, mid[1])
			break
	if not best:
		p.notes.append('ledge shortcut: no site'); return False
	score, x, y, ty, ly = best
	for yy in range(y + 1, ty):
		p.set(x, yy, LEDGE if yy == ly else GRASS); p.spine.add((x, yy))
	p.keep_tree |= {(x + s, yy) for yy in range(y + 1, ty) for s in (-1, 1) if p.get(x + s, yy) == TREE}
	p.notes.append(f'ledge shortcut at x={x} rows {y}->{ty} saves {score} steps')
	return True


def sem_escapes(p, start):
	"""Semantic-level check: from start, can you walk to every exit?
	Ledges are crossable downward only."""
	seen = {start}; dq = deque([start])
	while dq:
		x, y = dq.popleft()
		for dx, dy in DIRS:
			n = (x + dx, y + dy)
			if n in seen or not p.inb(*n): continue
			t = p.get(*n)
			if t in OPEN or (t == LEDGE and dy == 1):
				if t == LEDGE: n = (n[0], n[1] + 1)
				if p.inb(*n) and n not in seen and p.get(*n) in OPEN:
					seen.add(n); dq.append(n)
	return all(any(c in seen for c in e['cells']) for e in p.exits)


def ledge_bands(p, count=2, minrun=2, maxrun=6):
	"""Classic GSC ledge: a horizontal lip across a clearing, capped by trees
	at both ends, open above and below. Built on non-path ground only."""
	made = 0
	rows = list(range(2, p.h - 2)); p.rng.shuffle(rows)
	for y in rows:
		if made >= count: break
		x = 1
		while x < p.w - 1:
			if p.get(x - 1, y) == TREE and p.get(x, y) in (GRASS, TALL):
				run = []
				xx = x
				while p.get(xx, y) in (GRASS, TALL) and (xx, y) not in p.spine: run.append(xx); xx += 1
				if minrun <= len(run) <= maxrun and p.get(xx, y) == TREE \
						and all(p.get(c, y - 1) in OPEN and p.get(c, y + 1) in OPEN for c in run) \
						and all(abs(y - ly) > 2 for ly in getattr(p, 'ledge_rows', [])):
					for c in run: p.set(c, y, LEDGE)
					if not all(sem_escapes(p, (c, y + 1)) for c in run):
						for c in run: p.set(c, y, GRASS)
						x = xx; continue
					p.keep_tree |= {(x - 1, y), (xx, y)}
					p.ledge_rows = getattr(p, 'ledge_rows', []) + [y]
					p.notes.append(f'ledge band row {y} x={run[0]}..{run[-1]}')
					made += 1
					break
				x = xx
			x += 1
	return made


def walk_dist(p, a, b):
	seen = {a: 0}; q = deque([a])
	while q:
		c = q.popleft()
		if c == b: return seen[c]
		for n in p.n4(*c):
			if n not in seen and p.get(*n) in OPEN | {LEDGE}:
				seen[n] = seen[c] + 1; q.append(n)
	return None


def pond(p, size=(3, 2), near_open=True, tries=200, island_item=False):
	pw, ph = size
	for _ in range(tries):
		x = p.rng.randint(1, p.w - pw - 1); y = p.rng.randint(1, p.h - ph - 1)
		rect = [(x + i, y + j) for j in range(ph) for i in range(pw)]
		if not all(p.get(*c) in (TREE, GRASS, TALL) and c not in p.spine for c in rect): continue
		ring = [(x + i, y + j) for j in range(-1, ph + 1) for i in range(-1, pw + 1) if (x + i, y + j) not in rect]
		if any((c in p.spine and p.get(*c) == LEDGE) or p.get(*c) in (BUILD, SIGN, FENCE) for c in ring): continue
		if near_open and not any(p.get(*c) in OPEN for c in ring): continue
		for c in rect: p.set(*c, WATER)
		p.notes.append(f'pond {pw}x{ph} at {x},{y}')
		return (x, y)
	return None


def cut_pocket(p, depth=(3, 5)):
	"""A hidden clearing behind a Cut tree. The corridor flanks and the ring
	around the room are pinned as trees so later passes can't leak into it."""
	free = lambda c: p.get(*c) == TREE and c not in p.keep_tree
	cand = [c for c in p.spine if p.get(*c) in OPEN]
	p.rng.shuffle(cand)
	for (x, y) in cand:
		for dx, dy in p.rng.sample(DIRS, 4):
			D = p.rng.randint(*depth)
			cells = [(x + dx * i, y + dy * i) for i in range(1, D + 1)]
			ex, ey = cells[-1]
			room = [(ex + i, ey + j) for i in (-1, 0, 1) for j in (-1, 0, 1)]
			ring = [(ex + i, ey + j) for i in range(-2, 3) for j in range(-2, 3) if max(abs(i), abs(j)) == 2]
			flanks = [(cx + s * dy, cy + s * dx) for cx, cy in cells for s in (1, -1)]
			if not all(2 <= cx < p.w - 2 and 2 <= cy < p.h - 2 for cx, cy in cells + room): continue
			if not all(free(c) for c in cells + room): continue
			if not all(p.get(*c) == TREE for c in flanks + ring if c not in cells): continue
			gx, gy = cells[0]
			p.set(gx, gy, CUT); p.locked.add((gx, gy))
			p.cut_dir[(gx, gy)] = (dx, dy)
			for c in room:
				if p.rng.random() < 0.75: p.set(*c, TALL if p.rng.random() < 0.4 else GRASS)
			for c in cells[1:]: p.set(*c, GRASS); p.spine.add(c)
			p.spine.add((ex, ey))
			p.keep_tree |= {c for c in flanks + ring if c not in cells}
			p.events.append(dict(kind='item', x=ex, y=ey, note='behind Cut tree'))
			p.notes.append(f'cut pocket gate at {gx},{gy}')
			return True
	p.notes.append('cut pocket: no site')
	return False


def signs(p):
	"""A route sign just inside each exit, on grass beside the path."""
	for e in p.exits:
		ex, ey = e['cells'][0]
		inward = {'N': (0, 1), 'S': (0, -1), 'W': (1, 0), 'E': (-1, 0)}[e['side']]
		best = None
		for d in range(1, 5):
			for c in [(ex + inward[0] * d + ox, ey + inward[1] * d + oy) for ox in (-2, -1, 1, 2) for oy in (-2, -1, 1, 2)]:
				if p.get(*c) in (GRASS, TALL, TREE) and c not in p.spine and not near_exit(p, *c, 0) \
						and 1 <= c[0] < p.w - 1 and 1 <= c[1] < p.h - 1 \
						and p.get(c[0], c[1] + 1) in (PATH, GRASS) and p.get(c[0] + 1, c[1]) in OPEN | {TREE}:
					best = c; break
			if best: break
		if best:
			p.set(*best, SIGN); p.locked.add(best)
			p.events.append(dict(kind='sign', x=best[0], y=best[1]))


def trainer_spots(p, n=3):
	"""Grass cells beside the path with a straight view along open ground."""
	spots = []
	for x, y in p.cells():
		if p.g[y][x] not in (GRASS, PATH) or near_exit(p, x, y, 4): continue
		for dx, dy in DIRS:
			run = 0
			while p.get(x + dx * (run + 1), y + dy * (run + 1)) in (PATH, GRASS, TALL) and run < 4: run += 1
			if run >= 3: spots.append((run + p.rng.random(), x, y, (dx, dy)))
	spots.sort(reverse=True)
	chosen = []
	for _, x, y, d in spots:
		if all(abs(x - cx) + abs(y - cy) >= 6 for cx, cy, _ in chosen):
			chosen.append((x, y, d))
		if len(chosen) >= n: break
	face = {(0, -1): 'UP', (0, 1): 'DOWN', (1, 0): 'RIGHT', (-1, 0): 'LEFT'}
	for x, y, d in chosen:
		p.events.append(dict(kind='trainer', x=x, y=y, facing=face[d], sight=3))


# ---------------------------------------------------------------- legalise
def fix_water(p):
	"""Remove water shapes the pond tileset can't draw (1-wide necks, double
	concave corners) by turning the offending water cell back to land."""
	land = lambda x, y: p.get(x, y, WATER) != WATER
	changed = True
	while changed:
		changed = False
		for x, y in p.cells():
			if p.g[y][x] != WATER: continue
			l, r, u = land(x - 1, y), land(x + 1, y), land(x, y - 1)
			ul, ur = land(x - 1, y - 1), land(x + 1, y - 1)
			bad = (l and r) or (not u and not l and not r and ul and ur) \
				or (not u and l and ur and not r) or (not u and r and ul and not l)
			# lone water row under land with nothing below is fine; but a cell
			# whose only water neighbour is below reads as a stub
			if bad:
				p.g[y][x] = GRASS; changed = True


# ---------------------------------------------------------------- autotile
def autotile(p):
	rng = random.Random(p.seed * 7919 + 1)
	out = [[0] * p.w for _ in range(p.h)]
	water = lambda x, y: p.get(x, y, WATER) == WATER
	for x, y in p.cells():
		s = p.g[y][x]
		if s == TREE: b = B_FOREST
		elif s == GRASS: b = B_GRASS
		elif s == TALL: b = B_TALL
		elif s == PATH: b = B_PATH
		elif s == FLOWER: b = B_FLOWER
		elif s == SIGN: b = B_SIGN_GRASS
		elif s == PSIGN: b = B_SIGN_PATH
		elif s == WATER:
			u, l, r = water(x, y - 1), water(x - 1, y), water(x + 1, y)
			if not u:
				b = POND['tl'] if not l else POND['tr'] if not r else POND['top']
			elif not l: b = POND['left']
			elif not r: b = POND['right']
			elif not water(x - 1, y - 1): b = POND['inner_tl']
			elif not water(x + 1, y - 1): b = POND['inner_tr']
			else: b = POND['mid']
		elif s == LEDGE:
			ground = PATH if PATH in (p.get(x, y - 1), p.get(x, y + 1)) else GRASS
			b = LEDGE_ON[ground]
			if p.get(x + 1, y) in OPEN and p.get(x - 1, y) != LEDGE:
				b = LEDGE_END_R[ground]   # free right end -> half ledge with tip
		elif s == CUT:
			dx, dy = p.cut_dir[(x, y)]
			# put the blocking row/column on the far side so you walk up to it
			if dy == -1: b = 0x5b
			elif dy == 1: b = 0x63
			elif dx == 1: b = 0x5f
			else: b = 0x67
		elif s == FENCE: b = FENCE_M
		elif s == BUILD: b = 0  # filled by stamps
		else: b = B_GRASS
		out[y][x] = b
	for name, sx, sy in p.stamps:
		rows, _ = STAMPS[name]
		for j, row in enumerate(rows):
			for i, b in enumerate(row): out[sy + j][sx + i] = b
	for x, y in p.cells():          # fence ends
		if p.g[y][x] == FENCE:
			if p.get(x - 1, y) != FENCE: out[y][x] = FENCE_L
			elif p.get(x + 1, y) != FENCE: out[y][x] = FENCE_R
	return out


def fringe(p, blocks, coll, density=0.55, decor=0.04):
	"""Soften forest edges: grass cells next to forest get partial-tree blocks
	(trees in the quadrants facing the forest). Each change is kept only if
	it doesn't break reachability. Also sprinkles lone headbutt trees."""
	rng = random.Random(p.seed * 31 + 5)
	base = reach_signature(p, blocks, coll)
	cand = []
	for x, y in p.cells():
		if p.g[y][x] != GRASS or (x, y) in p.spine or (x, y) in p.locked: continue
		if any(p.get(nx, ny) in (SIGN, PSIGN, BUILD, LEDGE, CUT) for nx, ny in p.n4(x, y)): continue
		t = lambda dx, dy: p.get(x + dx, y + dy, TREE) == TREE
		m = 0
		if t(0, -1): m |= 0b1100
		if t(0, 1): m |= 0b0011
		if t(-1, 0): m |= 0b1010
		if t(1, 0): m |= 0b0101
		if m == 0:
			if rng.random() < decor: m = rng.choice([0b1000, 0b0100, 0b0010, 0b0001])
			else: continue
		if m == 0b1111 or rng.random() > density: continue
		if m not in TREE_MASK:      # diagonal masks don't exist
			m = rng.choice([m & 0b1100, m & 0b0011]) or m & 0b1010
		cand.append((x, y, TREE_MASK.get(m, B_GRASS)))
	rng.shuffle(cand)
	kept = 0
	for x, y, b in cand:
		old = blocks[y][x]; blocks[y][x] = b
		lost = bin([k for k, v in TREE_MASK.items() if v == b][0]).count('1')
		sig = reach_signature(p, blocks, coll)
		if sig[:-1] != base[:-1] or sig[-1] != base[-1] - lost: blocks[y][x] = old
		else: kept += 1; base = sig
	p.notes.append(f'fringe: {kept}/{len(cand)} partial-tree blocks kept')


# ---------------------------------------------------------------- walkability
def quad_grid(blocks, coll):
	h, w = len(blocks), len(blocks[0])
	q = [[None] * (2 * w) for _ in range(2 * h)]
	for y in range(h):
		for x in range(w):
			c = coll[blocks[y][x]]
			q[2 * y][2 * x], q[2 * y][2 * x + 1] = qclass(c[0]), qclass(c[1])
			q[2 * y + 1][2 * x], q[2 * y + 1][2 * x + 1] = qclass(c[2]), qclass(c[3])
	return q


HOP = {'hop_down': [(0, 1)], 'hop_right': [(1, 0)], 'hop_left': [(-1, 0)],
	'hop_down_right': [(0, 1), (1, 0)], 'hop_down_left': [(0, 1), (-1, 0)]}
LANDQ = {'floor', 'grass', 'warp'} | set(HOP)


def bfs(q, starts, surf=False, cut=False):
	H, W = len(q), len(q[0])
	ok = lambda c: c in LANDQ or (surf and c == 'water') or (cut and c == 'cut')
	seen = set(s for s in starts if ok(q[s[1]][s[0]])); dq = deque(seen)
	while dq:
		x, y = dq.popleft()
		here = q[y][x]
		for dx, dy in DIRS:
			nx, ny = x + dx, y + dy
			if here in HOP and (dx, dy) in HOP[here]:
				nx, ny = x + 2 * dx, y + 2 * dy      # jump over the ledge lip
				if 0 <= nx < W and 0 <= ny < H and q[ny][nx] in LANDQ and (nx, ny) not in seen:
					seen.add((nx, ny)); dq.append((nx, ny))
				continue
			if not (0 <= nx < W and 0 <= ny < H) or (nx, ny) in seen: continue
			if ok(q[ny][nx]):
				seen.add((nx, ny)); dq.append((nx, ny))
	return seen


def qdist(q, a, b):
	"""Steps from a to b on foot (ledges one-way); None if impossible."""
	H, W = len(q), len(q[0])
	dist = {a: 0}; dq = deque([a])
	while dq:
		c = dq.popleft()
		if c == b: return dist[c]
		x, y = c; here = q[y][x]
		for dx, dy in DIRS:
			if here in HOP and (dx, dy) in HOP[here]: n = (x + 2 * dx, y + 2 * dy)
			else: n = (x + dx, y + dy)
			if 0 <= n[0] < W and 0 <= n[1] < H and n not in dist and q[n[1]][n[0]] in LANDQ:
				dist[n] = dist[c] + 1; dq.append(n)
	return None


def softlocks(p, q, reach):
	"""Reachable quadrants from which no exit can be reached on foot."""
	H, W = len(q), len(q[0])
	rev = {}
	for (x, y) in reach:
		here = q[y][x]
		for dx, dy in DIRS:
			if here in HOP and (dx, dy) in HOP[here]: n = (x + 2 * dx, y + 2 * dy)
			else: n = (x + dx, y + dy)
			if 0 <= n[0] < W and 0 <= n[1] < H and q[n[1]][n[0]] in LANDQ:
				rev.setdefault(n, []).append((x, y))
	ok = set(c for e in p.exits for c in exit_quads(p, e)); dq = deque(ok)
	while dq:
		c = dq.popleft()
		for m in rev.get(c, []):
			if m not in ok: ok.add(m); dq.append(m)
	return reach - ok


def exit_quads(p, e):
	out = []
	for x, y in e['cells']:
		qs = [(2 * x + i, 2 * y + j) for i in (0, 1) for j in (0, 1)]
		side = e['side']
		qs = [c for c in qs if (side == 'N' and c[1] == 0) or (side == 'S' and c[1] == 2 * p.h - 1)
			or (side == 'W' and c[0] == 0) or (side == 'E' and c[0] == 2 * p.w - 1)]
		out += qs
	return out


def event_quads(e):
	return [(2 * e['x'] + i, 2 * e['y'] + j) for i in (0, 1) for j in (0, 1)]


def reach_signature(p, blocks, coll):
	q = quad_grid(blocks, coll)
	sig = []
	for e in p.exits:
		r = bfs(q, exit_quads(p, e))
		sig.append(tuple(bool(r & set(exit_quads(p, o))) for o in p.exits))
		sig.append(tuple(bool(r & set(event_quads(ev))) for ev in p.events if ev['kind'] in ('item', 'trainer')))
	sig.append(len(bfs(q, exit_quads(p, p.exits[0]), cut=True, surf=True)))
	return sig


def verify(p, blocks, coll):
	q = quad_grid(blocks, coll)
	res = dict(exits={}, items=[], trainers=[], doors=[])
	for i, e in enumerate(p.exits):
		r = bfs(q, exit_quads(p, e))
		for j, o in enumerate(p.exits):
			if i != j:
				res['exits'][f"{e['side']}{i}->{o['side']}{j}"] = bool(r & set(exit_quads(p, o)))
	start = exit_quads(p, p.exits[0])
	modes = [('walk', {}), ('cut', dict(cut=True)), ('surf', dict(surf=True)), ('cut+surf', dict(cut=True, surf=True))]
	reach = {m: bfs(q, start, **kw) for m, kw in modes}
	for ev in p.events:
		if ev['kind'] not in ('item', 'trainer'): continue
		need = next((m for m, _ in modes if reach[m] & set(event_quads(ev))), 'UNREACHABLE')
		res['items' if ev['kind'] == 'item' else 'trainers'].append(dict(x=ev['x'], y=ev['y'], needs=need, note=ev.get('note', '')))
	for name, sx, sy in p.stamps:
		dx, dy = STAMPS[name][1]
		bx, by = sx + dx, sy + dy
		c = coll[blocks[by][bx]]
		qx = 2 * bx + (1 if c[3] == 'DOOR' else 0)
		below = (qx, 2 * by + 2)
		res['doors'].append(dict(stamp=name, x=bx, y=by, reachable=below in reach['walk']))
	res['walkable_quadrants'] = len(reach['walk'])
	res['softlock_quadrants'] = len(softlocks(p, q, reach['walk']))
	res['ledges'] = []
	for y in range(p.h):
		x = 0
		while x < p.w:
			if p.g[y][x] == LEDGE:
				top, bot = (2 * x, 2 * y), (2 * x, 2 * y + 2)
				up = qdist(q, bot, top)
				res['ledges'].append(dict(x=x, y=y, hop=2, walk_back=up))
				while x < p.w and p.g[y][x] == LEDGE: x += 1
			x += 1
	return res


# ---------------------------------------------------------------- output
def save(p, blocks, outdir, name, ref='Route30', scale=2):
	os.makedirs(outdir, exist_ok=True)
	flat = bytes(b for row in blocks for b in row)
	open(os.path.join(outdir, name + '.ablk'), 'wb').write(flat)
	sys.path.insert(0, os.path.dirname(HERE))
	cwd = os.getcwd()
	import render_ablk as R
	from PIL import Image, ImageDraw
	os.chdir(R.REPO)  # the renderer reads repo-relative paths
	eng, refm = R.engine_and_ref(ref, 'summer', 'day')
	R.render(flat, p.w, eng, refm, False, scale).save(os.path.join(outdir, name + '.png'))
	R.render(flat, p.w, eng, refm, True, 1).save(os.path.join(outdir, name + '_grid.png'))
	os.chdir(cwd)
	# semantic layer
	C = 12
	img = Image.new('RGB', (p.w * C, p.h * C)); d = ImageDraw.Draw(img)
	for x, y in p.cells():
		d.rectangle([x * C, y * C, x * C + C - 1, y * C + C - 1], fill=SEM_COLOR.get(p.g[y][x], (0, 0, 0)))
	for e in p.exits:
		for x, y in e['cells']:
			d.rectangle([x * C + 2, y * C + 2, x * C + C - 3, y * C + C - 3], outline=(255, 0, 255), width=2)
	for ev in p.events:
		cx, cy = ev['x'] * C + C // 2, ev['y'] * C + C // 2
		col = {'item': (255, 230, 0), 'trainer': (230, 30, 30), 'sign': (0, 0, 0)}[ev['kind']]
		d.ellipse([cx - 3, cy - 3, cx + 3, cy + 3], fill=col, outline=(0, 0, 0))
	img = img.resize((p.w * 32, p.h * 32), Image.NEAREST)
	img.save(os.path.join(outdir, name + '_sem.png'))
	grid = Image.open(os.path.join(outdir, name + '_grid.png'))
	view = Image.new('RGB', (grid.width * 2 + 8, grid.height), (0, 0, 0))
	view.paste(grid, (0, 0)); view.paste(img, (grid.width + 8, 0))
	view.save(os.path.join(outdir, name + '_view.png'))
	coll = load_collision()
	res = verify(p, blocks, coll)
	meta = dict(name=name, w=p.w, h=p.h, seed=p.seed, exits=p.exits, events=p.events,
		stamps=p.stamps, notes=p.notes, verify=res)
	json.dump(meta, open(os.path.join(outdir, name + '.json'), 'w'), indent=1)
	return res


# ---------------------------------------------------------------- presets
def gen_forest(seed, w=14, h=30):
	"""Vertical forest trail: N->S, winding, ledge shortcut, cut pocket, pond."""
	p = MapPlan(w, h, seed)
	nz = Noise(p.rng, w, h, 5, 2); nz2 = Noise(p.rng, w, h, 3, 2); nz3 = Noise(p.rng, w, h, 4, 1)
	add_exit(p, 'N', p.rng.uniform(0.25, 0.75), 1)
	add_exit(p, 'S', p.rng.uniform(0.25, 0.75), 1)
	path = carve_main_path(p, nz, waypoints=3, wiggle=0.35)
	ledge_shortcut(p)
	side_branches(p, 1)
	cut_pocket(p)
	widen(p, path, 0.45)
	rooms(p)
	clearings(p, nz2, 0.62)
	ledge_bands(p, 2)
	pond(p, (3, 2))
	tall_grass(p, nz3, 0.6)
	flowers(p, 2)
	fix_water(p)
	signs(p)
	trainer_spots(p, 3)
	return p


def gen_lake(seed, w=34, h=12):
	"""Horizontal lakeside route: W->E along a shore, lake to the south with an
	island item (Surf), forest and grass to the north."""
	p = MapPlan(w, h, seed)
	nz = Noise(p.rng, w, h, 6, 2); nz2 = Noise(p.rng, w, h, 3, 2); nz3 = Noise(p.rng, w, h, 4, 1)
	# shoreline: smoothed random walk; water below it reaches the south edge
	shore = []; s = h - 4
	for x in range(w):
		s += p.rng.choice([-1, 0, 0, 0, 1]); s = max(h - 6, min(h - 3, s)); shore.append(s)
	shore = [round(sum(shore[max(0, i - 2):i + 3]) / len(shore[max(0, i - 2):i + 3])) for i in range(w)]
	lake_x0, lake_x1 = p.rng.randint(3, 6), w - p.rng.randint(4, 8)
	for x in range(lake_x0, lake_x1):
		for y in range(shore[x], h): p.set(x, y, WATER)
	add_exit(p, 'W', 0.35, 2)
	add_exit(p, 'E', p.rng.uniform(0.3, 0.6), 2)
	# path wants to hug the shore: cheap near the waterline
	def shore_noise(x, y):
		d = abs(y - (shore[x] - 2)) if lake_x0 <= x < lake_x1 else 3
		return min(1, 0.15 * d + 0.5 * nz(x, y))
	path = carve_main_path(p, shore_noise, waypoints=2, wiggle=0.3)
	for c in path:
		if p.get(*c) == WATER: p.set(*c, PATH)
	widen(p, path, 0.5)
	for x in range(w):           # beach strip of grass between path and water
		for y in range(h - 1):
			if p.get(x, y + 1) == WATER and p.get(x, y) == TREE and p.rng.random() < 0.6:
				p.set(x, y, GRASS)
	clearings(p, nz2, 0.58)
	ledge_shortcut(p, minlen=3)
	ledge_bands(p, 2)
	# island with an item
	for _ in range(40):
		ix = p.rng.randint(lake_x0 + 2, max(lake_x0 + 2, lake_x1 - 4))
		iy = p.rng.choice([h - 2, h - 3])
		if all(p.get(ix + i, iy + j) == WATER for i in range(-2, 4) for j in (-2, -1, 0, 1) if p.inb(ix + i, iy + j)):
			for i in (0, 1): p.set(ix + i, iy, GRASS)
			p.events.append(dict(kind='item', x=ix + 1, y=iy, note='island (Surf)'))
			p.notes.append(f'island at {ix},{iy}')
			break
	side_branches(p, 2)
	tall_grass(p, nz3, 0.55)
	flowers(p, 3)
	fix_water(p)
	signs(p)
	trainer_spots(p, 4)
	return p


def gen_town(seed, w=20, h=16):
	"""Small town: tree ring, a 2-wide main street W->E, a north road, a
	southern side street; PC + Mart near the middle, houses spread out with
	door paths; a fenced garden, a pond, tree clumps."""
	p = MapPlan(w, h, seed)
	rng = p.rng
	for x, y in p.cells():
		if 1 <= x < w - 1 and 1 <= y < h - 1: p.g[y][x] = GRASS
	streety = rng.randint(h // 2 - 3, h // 2 - 1)
	add_exit(p, 'W', streety / (h - 1), 1)
	add_exit(p, 'E', (streety + 1) / (h - 1), 1)
	add_exit(p, 'N', rng.uniform(0.3, 0.7), 1)
	def road(a, b):
		(x0, y0), (x1, y1) = a, b
		for x in range(min(x0, x1), max(x0, x1) + 1): p.set(x, y0, PATH); p.spine.add((x, y0))
		for y in range(min(y0, y1), max(y0, y1) + 1): p.set(x1, y, PATH); p.spine.add((x1, y))
	for e in p.exits[:2]:
		e['cells'] = [(e['cells'][0][0], streety if e['side'] == 'W' else streety + 1)]
	for x in range(0, w):
		for y in (streety, streety + 1):
			if 0 < x < w - 1 or (x, y) in [c for e in p.exits for c in e['cells']]:
				p.set(x, y, PATH); p.spine.add((x, y))
	nx = p.exits[2]['cells'][0][0]
	road((nx, 0), (nx, streety))
	# southern side street: down from the main street, then along
	sx0 = rng.randint(4, w - 5); sy1 = rng.randint(h - 5, h - 4)
	road((sx0, streety + 1), (sx0, sy1))
	x1 = rng.choice([3, w - 4]) if rng.random() < 0.8 else sx0
	road((sx0, sy1), (x1, sy1)); road((x1, sy1), (sx0, sy1))
	p.notes.append(f'main street rows {streety}-{streety + 1}, side street x={sx0} -> row {sy1}')
	order = ['pokecenter', 'mart', 'gym', 'house', 'house2', 'cottage', 'cottage']
	cx = w / 2
	def free(sx, sy, sw, sh):
		for j in range(-1, sh + 1):
			for i in range(-1, sw + 1):
				x, y = sx + i, sy + j
				inside = 0 <= i < sw and 0 <= j < sh
				if inside and not (2 <= x < w - 2 and 1 <= y < h - 2): return False
				if inside and p.get(x, y) != GRASS: return False
				if not inside and p.get(x, y) in (BUILD, SIGN): return False
		return True
	for k, name in enumerate(order):
		rows, (ddx, ddy) = STAMPS[name]
		sh, sw = len(rows), len(rows[0])
		cands = []
		for sy in range(1, h - sh - 1):
			for sx in range(2, w - sw - 1):
				if not free(sx, sy, sw, sh): continue
				door = (sx + ddx, sy + ddy + 1)
				if p.get(*door) not in (GRASS, PATH): continue
				rd = min(abs(door[0] - a) + abs(door[1] - b) for a, b in p.spine if p.get(a, b) == PATH)
				if rd > 3: continue
				crowd = sum(1 for _, bx, by in p.stamps if abs(bx - sx) + abs(by - sy) < 5)
				central = abs(sx + sw / 2 - cx) / w * (6 if k < 3 else -2)
				cands.append((rd + 2.5 * crowd + central + rng.random() * 3, sx, sy))
		if not cands: p.notes.append(f'no lot for {name}'); continue
		cands.sort(); _, sx, sy = cands[0]
		for j in range(sh):
			for i in range(sw): p.set(sx + i, sy + j, BUILD)
		p.stamps.append((name, sx, sy))
		dxc, dyc = sx + ddx, sy + ddy + 1
		tgt = min((c for c in p.spine if p.get(*c) == PATH), key=lambda c: abs(c[0] - dxc) + abs(c[1] - dyc))
		seg = p.dijkstra([(dxc, dyc)], tgt, lambda c, n: None if p.get(*n) in (BUILD, TREE, SIGN) else 1)
		for c in seg or []:
			p.set(*c, PATH); p.spine.add(c)
		if name in ('pokecenter', 'mart'): continue
		# a sign beside some houses
		if rng.random() < 0.5:
			for c in [(sx - 1, sy + sh - 1), (sx + sw, sy + sh - 1)]:
				if p.get(*c) == GRASS and 1 < c[0] < w - 2 and p.get(c[0], c[1] + 1) in (GRASS, PATH):
					p.set(*c, SIGN); p.locked.add(c); p.events.append(dict(kind='sign', x=c[0], y=c[1])); break
	# town sign at the west entrance, on the path (45 is a path-floor sign)
	for c in [(2, streety - 1), (3, streety - 1), (2, streety + 2), (3, streety + 2)]:
		if p.get(*c) == GRASS:
			p.set(*c, SIGN); p.locked.add(c); p.events.append(dict(kind='sign', x=c[0], y=c[1], note='town sign')); break
	# a fenced flower garden
	for _ in range(200):
		gx, gy, gw = rng.randint(2, w - 7), rng.randint(2, h - 4), rng.randint(3, 5)
		box = [(gx + i, gy + j) for i in range(gw) for j in (0, 1)]
		ring = [(gx + i, gy + j) for i in range(-1, gw + 1) for j in (-1, 2)]
		if all(p.get(*c) == GRASS and c not in p.spine for c in box) and \
				not any(p.get(*c) in (BUILD, SIGN) for c in ring):
			for i in range(gw):
				p.set(gx + i, gy, FLOWER); p.set(gx + i, gy + 1, FENCE)
			p.notes.append(f'fenced garden at {gx},{gy}')
			break
	pond(p, (rng.randint(2, 4), 2), near_open=True)
	# tree clumps in leftover open grass far from roads
	for x, y in p.cells():
		if p.g[y][x] == GRASS and (x, y) not in p.spine and rng.random() < 0.35 \
				and min(abs(x - a) + abs(y - b) for a, b in p.spine) >= 2 \
				and not any(p.get(a, b) in (BUILD, SIGN, FENCE, FLOWER, WATER) for a, b in p.n4(x, y)):
			p.g[y][x] = TREE
	flowers(p, 3)
	fix_water(p)
	return p


PRESETS = {'forest': (gen_forest, 'Route30'), 'lake': (gen_lake, 'Route30'), 'town': (gen_town, 'CherrygroveCity')}


def build(kind, seed, outdir, name=None, **kw):
	fn, ref = PRESETS[kind]
	p = fn(seed, **kw)
	blocks = autotile(p)
	fringe(p, blocks, load_collision(), density=0.55 if kind != 'town' else 0.3)
	name = name or f'{kind}_s{seed}'
	res = save(p, blocks, outdir, name, ref)
	return p, res


if __name__ == '__main__':
	ap = argparse.ArgumentParser()
	ap.add_argument('kind', choices=PRESETS)
	ap.add_argument('--seed', type=int, default=1)
	ap.add_argument('--out', default=os.path.join(HERE, 'out'))
	ap.add_argument('--w', type=int); ap.add_argument('--h', type=int)
	a = ap.parse_args()
	kw = {k: v for k, v in (('w', a.w), ('h', a.h)) if v}
	p, res = build(a.kind, a.seed, os.path.abspath(a.out), **kw)
	print(json.dumps(dict(notes=p.notes, verify=res), indent=1))

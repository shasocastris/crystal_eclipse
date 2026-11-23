#!/usr/bin/env python3
"""Example-based Wave Function Collapse for TILESET_JOHTO block maps.

Two models, both learned from the existing Johto maps:
  tiled    -- legal 4-neighbour block pairs, weighted by block frequency
  overlap  -- NxN block windows (N=2 or 3); neighbouring windows must agree
             on their overlap, so every NxN area of the output was seen in a
             real map.

Constraints (all optional):
  --border      outer ring forced to the tree-wall block set
  --exits N,S   2-block-wide gaps in the border plus a pre-carved random
                path between them whose cells may only use fully walkable blocks
"""
import argparse, os, random, sys, time
from collections import Counter, defaultdict
import mapdata as md

HERE = os.path.dirname(os.path.abspath(__file__))

TRAIN_SETS = {
	'inland': ['Route29', 'Route30', 'Route31', 'Route32', 'Route35', 'Route36', 'Route37',
		'Route38', 'Route39', 'Route42', 'Route43', 'Route44', 'Route45', 'Route46', 'BlackthornPass'],
	'towns': ['CherrygroveCity', 'VioletCity', 'OlivineCity', 'EcruteakCity', 'MahoganyTown',
		'BlackthornCity', 'NewBarkTown', 'CianwoodCity'],
	'forest': ['Route29', 'Route30', 'Route31', 'Route36', 'Route37', 'Route38', 'Route43', 'Route46'],
}

TREE_BORDER = {0x05}          # solid tree wall
DX = [(0, -1), (1, 0), (0, 1), (-1, 0)]  # N E S W
OPP = [2, 3, 0, 1]


def full_land_blocks():
	"""Blocks whose four step cells are plain walkable land (no ledge, no water)."""
	out = set()
	for b, q in enumerate(md.COLL):
		if all(md.PERM[c] == 'L' and c not in md.HOPS for c in q):
			out.add(b)
	return out


def bits(m):
	while m:
		low = m & -m
		yield low.bit_length() - 1
		m ^= low


class Solver:
	"""Generic WFC over 'patterns' with per-direction compat bitmasks."""

	def __init__(self, n_pat, weights, compat, W, H, rng):
		self.P, self.w, self.compat = n_pat, weights, compat
		self.W, self.H, self.rng = W, H, rng
		self.full = (1 << n_pat) - 1
		self.grid = [self.full] * (W * H)
		self.cache = [dict() for _ in range(4)]
		# group patterns with identical compat masks: support() then ORs per group
		self.groups = []
		for d in range(4):
			g = defaultdict(int)
			for p in range(n_pat):
				g[compat[d][p]] |= 1 << p
			self.groups.append([(m, c) for c, m in g.items()])

	def support(self, mask, d):
		c = self.cache[d]
		r = c.get(mask)
		if r is None:
			r = 0
			for gm, cm in self.groups[d]:
				if mask & gm:
					r |= cm
			if len(c) < 200000:
				c[mask] = r
		return r

	def restrict(self, i, mask):
		new = self.grid[i] & mask
		if new == self.grid[i]:
			return True
		self.grid[i] = new
		return new != 0 and self.propagate([i])

	def propagate(self, stack):
		g, W, H = self.grid, self.W, self.H
		while stack:
			i = stack.pop()
			x, y = i % W, i // W
			for d, (dx, dy) in enumerate(DX):
				nx, ny = x + dx, y + dy
				if not (0 <= nx < W and 0 <= ny < H):
					continue
				j = ny * W + nx
				if g[j] == self.full and g[i] == self.full:
					continue
				new = g[j] & self.support(g[i], d)
				if new != g[j]:
					if not new:
						g[j] = 0
						return False
					g[j] = new
					stack.append(j)
		return True

	def entropy(self, m):
		n = m.bit_count()
		if n <= 1:
			return None
		if n > 64:
			return n  # cheap proxy for big sets
		import math
		ws = [self.w[p] for p in bits(m)]
		s = sum(ws)
		return math.log(s) - sum(w * math.log(w) for w in ws) / s

	def run(self):
		g = self.grid
		while True:
			best, bi = None, -1
			for i, m in enumerate(g):
				e = self.entropy(m)
				if e is None:
					continue
				e += self.rng.random() * 1e-3
				if best is None or e < best:
					best, bi = e, i
			if bi < 0:
				return True
			opts = list(bits(g[bi]))
			p = self.rng.choices(opts, weights=[self.w[o] for o in opts])[0]
			g[bi] = 1 << p
			if not self.propagate([bi]):
				return False


# ---- models ---------------------------------------------------------------

def train(names):
	maps = md.load_maps()
	return [maps[n] for n in names]


def tiled_model(samples):
	freq = Counter()
	adj = [defaultdict(set) for _ in range(4)]
	for w, h, d in samples:
		for y in range(h):
			for x in range(w):
				b = d[y * w + x]
				freq[b] += 1
				for k, (dx, dy) in enumerate(DX):
					nx, ny = x + dx, y + dy
					if 0 <= nx < w and 0 <= ny < h:
						adj[k][b].add(d[ny * w + nx])
	tiles = sorted(freq)
	idx = {t: i for i, t in enumerate(tiles)}
	compat = [[0] * len(tiles) for _ in range(4)]
	for k in range(4):
		for t in tiles:
			m = 0
			for u in adj[k][t]:
				m |= 1 << idx[u]
			compat[k][idx[t]] = m
	return tiles, [freq[t] for t in tiles], compat


def overlap_model(samples, N):
	freq = Counter()
	for w, h, d in samples:
		for y in range(h - N + 1):
			for x in range(w - N + 1):
				freq[tuple(d[(y + j) * w + x + i] for j in range(N) for i in range(N))] += 1
	pats = sorted(freq)
	# compat[d][p] = patterns q that may sit one step in direction d from p
	def agrees(p, q, dx, dy):
		for j in range(N):
			for i in range(N):
				i2, j2 = i - dx, j - dy
				if 0 <= i2 < N and 0 <= j2 < N and p[j * N + i] != q[j2 * N + i2]:
					return False
		return True
	# index patterns by their overlap strip to avoid O(P^2)
	compat = [[0] * len(pats) for _ in range(4)]
	for k, (dx, dy) in enumerate(DX):
		def key_q(q):  # part of q that overlaps p when q is at offset (dx,dy)
			return tuple(q[j * N + i] for j in range(N) for i in range(N)
				if 0 <= i + dx < N and 0 <= j + dy < N)
		def key_p(p):
			return tuple(p[j * N + i] for j in range(N) for i in range(N)
				if 0 <= i - dx < N and 0 <= j - dy < N)
		buckets = defaultdict(int)
		for qi, q in enumerate(pats):
			buckets[key_q(q)] |= 1 << qi
		for pi, p in enumerate(pats):
			compat[k][pi] = buckets.get(key_p(p), 0)
	return pats, [freq[p] for p in pats], compat


# ---- constraints ------------------------------------------------------------

def carve_path(W, H, rng, width=2, run=(3, 7)):
	"""Polyline from the top edge to the bottom edge: vertical runs of random
	length joined by horizontal jogs. Returns the set of (x, y) cells."""
	cells = set()
	lo, hi = 1, W - 1 - width
	x = rng.randint(lo + 1, hi - 1)
	y = 0
	while y < H:
		n = min(rng.randint(*run), H - y)
		for yy in range(y, y + n):
			for k in range(width):
				cells.add((x + k, yy))
		y += n
		if y >= H:
			break
		nx = rng.randint(lo, hi)
		for xx in range(min(x, nx), max(x, nx) + width):
			for k in range(width):
				if y - 1 + k < H:
					cells.add((xx, y - 1 + k))
		x = nx
	return cells


def generate(model, W, H, seed, border=False, exits=False, path_set=None, N=1, tries=50, verbose=True, width=2, axis='ns'):
	pats, weights, compat = model
	rng = random.Random(seed)
	if N == 1:
		tile_of = lambda p, ox, oy: pats[p]
	else:
		tile_of = lambda p, ox, oy: pats[p][oy * N + ox]
	PW, PH = W - N + 1, H - N + 1
	# per-offset index: which patterns have tile t at (ox, oy)
	by_tile = defaultdict(int)
	for p in range(len(pats)):
		for oy in range(N):
			for ox in range(N):
				by_tile[(ox, oy, tile_of(p, ox, oy))] |= 1 << p
	def tiles_mask(ox, oy, allowed):
		m = 0
		for t in allowed:
			m |= by_tile.get((ox, oy, t), 0)
		return m
	walk = full_land_blocks()
	for attempt in range(tries):
		s = Solver(len(pats), weights, compat, PW, PH, rng)
		fixed = {}
		path = set()
		if exits:
			if axis == 'ns':
				path = carve_path(W, H, rng, width)
			else:  # carve in a transposed frame, then flip the cells back
				path = {(y, x) for x, y in carve_path(H, W, rng, width)}
			for c in path:
				fixed[c] = path_set or walk
		if border:
			for y in range(H):
				for x in range(W):
					if (x in (0, W - 1) or y in (0, H - 1)) and (x, y) not in path:
						fixed[(x, y)] = TREE_BORDER
		ok = True
		for (x, y), allowed in fixed.items():
			px, py = min(x, PW - 1), min(y, PH - 1)
			if not s.restrict(py * PW + px, tiles_mask(x - px, y - py, allowed)):
				ok = False
				break
		if ok and s.run():
			out = bytearray(W * H)
			for y in range(H):
				for x in range(W):
					px, py = min(x, PW - 1), min(y, PH - 1)
					p = s.grid[py * PW + px].bit_length() - 1
					out[y * W + x] = tile_of(p, x - px, y - py)
			if verbose:
				print(f'  seed {seed}: solved on attempt {attempt + 1}')
			return bytes(out), path
	if verbose:
		print(f'  seed {seed}: gave up after {tries} attempts')
	return None, None


def main():
	ap = argparse.ArgumentParser()
	ap.add_argument('--model', choices=['tiled', 'overlap'], default='tiled')
	ap.add_argument('-N', type=int, default=2)
	ap.add_argument('--train', default='inland', help='inland | forest | all | comma list of maps')
	ap.add_argument('--size', default='13x27')
	ap.add_argument('--border', action='store_true')
	ap.add_argument('--exits', action='store_true')
	ap.add_argument('--road', action='store_true', help='path cells must be road block 01 (else any walkable block)')
	ap.add_argument('--width', type=int, default=2)
	ap.add_argument('--axis', choices=['ns', 'ew'], default='ns', help='exits on north/south or east/west edges')
	ap.add_argument('--boost', default='', help='hex=factor[,..]: scale weight of patterns containing a block, e.g. 03=4')
	ap.add_argument('--seeds', default='1')
	ap.add_argument('--out', default=os.path.join(HERE, 'out'))
	ap.add_argument('--tag', default='')
	ap.add_argument('--tries', type=int, default=50)
	ap.add_argument('--render', action='store_true')
	ap.add_argument('--keep-valid', action='store_true', help='only save maps whose exits connect and whose entrances are reachable')
	ap.add_argument('--grid', action='store_true')
	a = ap.parse_args()
	W, H = map(int, a.size.split('x'))
	a.out = os.path.abspath(a.out)
	assert (W + 6) * (H + 6) <= 1300, 'map too big for the buffer'
	if a.train == 'all':
		names = list(md.load_maps())
	else:
		names = TRAIN_SETS.get(a.train) or a.train.split(',')
	samples = train(names)
	t0 = time.time()
	if a.model == 'tiled':
		model, N = tiled_model(samples), 1
	else:
		model, N = overlap_model(samples, a.N), a.N
	if a.boost:
		pats, weights, compat = model
		for item in a.boost.split(','):
			b, f = item.split('=')
			b, f = int(b, 16), float(f)
			weights = [w * f if (p == b if N == 1 else b in p) else w for p, w in zip(pats, weights)]
		model = (pats, weights, compat)
	print(f'{a.model} N={N}: {len(model[0])} patterns from {len(samples)} maps ({time.time() - t0:.1f}s)')
	os.makedirs(a.out, exist_ok=True)
	if a.render:
		sys.path.insert(0, os.path.dirname(HERE))
		import render_ablk as ra
		eng, ref = ra.engine_and_ref('Route30', 'summer', 'day')
	for seed in [int(s) for s in a.seeds.split(',')] if ',' in a.seeds else range(int(a.seeds.split('-')[0]), int(a.seeds.split('-')[-1]) + 1):
		t0 = time.time()
		blocks, path = generate(model, W, H, seed, a.border, a.exits, path_set={0x01} if a.road else None, N=N, tries=a.tries, width=a.width, axis=a.axis)
		if blocks is None:
			continue
		sides, rep = md.walk_report(blocks, W)
		if a.keep_valid:
			import evaluate
			links = [k for k in rep if '->' in k]
			good, total = evaluate.doors_ok(blocks, W)
			if not links or not all(rep[k] for k in links) or good != total:
				print(f'  seed {seed}: rejected (links/entrances)')
				continue
		name = f'{a.model}{N if N > 1 else ""}_{a.train}{a.tag}_{W}x{H}_s{seed}'
		open(os.path.join(a.out, name + '.ablk'), 'wb').write(blocks)
		print(f'  {name}: {time.time() - t0:.1f}s open={"".join(sides)} ' +
			' '.join(f'{k}={v if isinstance(v, bool) else round(v, 2)}' for k, v in sorted(rep.items())))
		if a.render:
			ra.render(blocks, W, eng, ref, grid=a.grid).save(os.path.join(a.out, name + '.png'))


if __name__ == '__main__':
	main()

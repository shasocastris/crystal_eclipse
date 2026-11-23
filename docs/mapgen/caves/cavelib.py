"""Cave toolkit for TILESET_CAVE: terrain grid (H/L/W) -> autotiled .ablk, collision BFS, render.

Terrain classes per 32x32 block cell:
  H = high rock / plateau (light texture, block 09 and its edges)
  L = low cave floor (dark texture, block 02)
  W = water (low level, Surf)
Edge rules were mined from the 18 vanilla TILESET_CAVE maps (see mine.py).
"""
import os, re, random
from collections import deque
from common import R, REPO, D

OUT = D + '/caves'
H, L, W = 'H', 'L', 'W'

# ---------------------------------------------------------------- collision
def load_collision():
	coll = []
	for line in open(REPO + '/data/tilesets/cave_collision.asm'):
		m = re.match(r'\s*tilecoll\s+(\w+),\s*(\w+),\s*(\w+),\s*(\w+)', line)
		if m: coll.append(m.groups())
	return coll
COLL = load_collision()
WARPS = {'LADDER', 'CAVE', 'WARP_CARPET_DOWN', 'STAIRCASE'}
LANDISH = {'FLOOR', 'UP_WALL', 'TALL_GRASS'} | WARPS

def quad_grid(blocks, w):
	h = len(blocks) // w
	q = [[None] * (w * 2) for _ in range(h * 2)]
	for i, b in enumerate(blocks):
		bx, by = i % w, i // w
		tl, tr, bl, br = COLL[b]
		q[by*2][bx*2], q[by*2][bx*2+1], q[by*2+1][bx*2], q[by*2+1][bx*2+1] = tl, tr, bl, br
	return q

def bfs(blocks, w, starts, surf=False):
	"""Quadrant BFS. UP_WALL can't be entered moving down. Hops are one-way down.
	Returns set of reachable (qx,qy)."""
	q = quad_grid(blocks, w)
	QH, QW = len(q), len(q[0])
	seen = set(); dq = deque()
	for s in starts:
		seen.add(s); dq.append(s)
	while dq:
		x, y = dq.popleft()
		c = q[y][x]
		if c in WARPS and (x, y) not in starts: continue  # stepping on a warp leaves the map
		for dx, dy in ((1,0),(-1,0),(0,1),(0,-1)):
			nx, ny = x+dx, y+dy
			if not (0 <= nx < QW and 0 <= ny < QH) or (nx, ny) in seen: continue
			t = q[ny][nx]
			if t == 'UP_WALL' and dy == 1: continue
			if c == 'UP_WALL' and dy == -1: continue  # UP_WALL = wall on the quadrant's top edge
			if c == 'HOP_DOWN' and dy == 1:  # standing on a ledge: jump over the next quadrant
				tgt = (nx, ny + 1)
				if ny + 1 < QH and tgt not in seen and q[tgt[1]][tgt[0]] in LANDISH:
					seen.add(tgt); dq.append(tgt)
				continue
			if t == 'HOP_DOWN':
				if dy != -1:  # can step onto a ledge sideways or from above, not from below
					seen.add((nx, ny)); dq.append((nx, ny))
				continue
			ok = t in LANDISH or (surf and t in ('WATER',))
			if c == 'WATER' and t in LANDISH: ok = True
			if ok:
				seen.add((nx, ny)); dq.append((nx, ny))
	return seen

# ---------------------------------------------------------------- terrain cleanup
def at(g, x, y, default=H):
	if 0 <= y < len(g) and 0 <= x < len(g[0]): return g[y][x]
	return default

def opn(c): return c in (L, W)

def thin_cells(g):
	hgt, wid = len(g), len(g[0]); out = []
	for y in range(hgt):
		for x in range(wid):
			if g[y][x] != H: continue
			n, s = opn(at(g,x,y-1)), opn(at(g,x,y+1))
			e, w_ = opn(at(g,x+1,y)), opn(at(g,x-1,y))
			if n and s: out.append((x, y, 'v'))
			elif e and w_: out.append((x, y, 'h'))
			pass
	return out

def sanitize(g, protect=(), rng=None, thicken=0.0):
	"""Rock (H) must be >=2 thick between open cells, horizontally and vertically.
	Thin rock is either thickened (an adjacent open cell becomes rock, prob=thicken)
	or removed (becomes floor). Iterate to fixpoint."""
	for it in range(200):
		bad = [c for c in thin_cells(g) if (c[0], c[1]) not in protect]
		if not bad: break
		for x, y, k in bad:
			if g[y][x] != H: continue
			if rng and rng.random() < thicken and it < 20:
				if k == 'v': cand = [(x, y+1), (x, y-1)]
				elif k == 'h': cand = [(x+1, y), (x-1, y)]
				else: cand = [(x, y+1)]
				nx, ny = rng.choice(cand)
				if 0 < ny < len(g)-1 and 0 < nx < len(g[0])-1 and g[ny][nx] == L and (nx, ny) not in protect:
					g[ny][nx] = H; continue
			g[y][x] = L
	return g

# ---------------------------------------------------------------- autotile
def tile_H(g, x, y):
	n, e, s, w_ = (opn(at(g,x,y-1)), opn(at(g,x+1,y)), opn(at(g,x,y+1)), opn(at(g,x-1,y)))
	if s:
		return 0x0c if w_ else 0x0e if e else 0x0d
	if n:
		return 0x04 if w_ else 0x06 if e else 0x05
	if w_: return 0x08
	if e: return 0x0a
	if opn(at(g,x+1,y+1)): return 0x10
	if opn(at(g,x-1,y+1)): return 0x11
	return 0x09

def tile_W(g, x, y):
	n, e, s, w_ = at(g,x,y-1), at(g,x+1,y), at(g,x,y+1), at(g,x-1,y)
	if n == L and w_ == L: return 0x3e
	if n == L and e in (L,): return 0x3d
	if n == L: return 0x27
	if w_ == L: return 0x26
	if e == L: return 0x25
	return 0x0f

def autotile(g):
	out = []
	for y in range(len(g)):
		for x in range(len(g[0])):
			c = g[y][x]
			out.append(tile_H(g,x,y) if c == H else tile_W(g,x,y) if c == W else 0x02)
	return bytearray(out)

# decoration: single boulders 28/29/2a/2b and clusters, only on L cells not on the main path
BOULDERS = [0x28, 0x29, 0x2a, 0x2b]
def decorate(g, blocks, rng, keep=set(), density=0.12):
	wid = len(g[0])
	for y in range(len(g)):
		for x in range(wid):
			if g[y][x] != L or (x, y) in keep: continue
			if blocks[y*wid+x] != 0x02: continue
			# prefer cells hugging a wall
			nearwall = sum(at(g,x+dx,y+dy) == H for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)))
			if rng.random() < density * (1.5 if nearwall else 0.6):
				blocks[y*wid+x] = rng.choice(BOULDERS)
	return blocks

# ---------------------------------------------------------------- features
def place_exit_down(g, blocks, x, y):
	"""L cell (x,y) with rim below: warp mat. 24 = floor + WARP_CARPET_DOWN (BR quad); rim -> 23 (mat)."""
	wid = len(g[0])
	blocks[y*wid+x] = 0x24
	if at(g, x, y+1) == H: blocks[(y+1)*wid+x] = 0x23
	return (x*2+1, y*2+1)

def place_cave_up(g, blocks, x, y):
	"""H cell (x,y) that tiles as 0d (floor below): cave mouth 13, CAVE warp in BR quad."""
	wid = len(g[0])
	blocks[y*wid+x] = 0x13
	return (x*2+1, y*2+1)

def place_ladder(g, blocks, x, y, high=False):
	"""Ladder (LADDER coll in BR quad). 1f on low floor, 07 on high floor."""
	wid = len(g[0])
	blocks[y*wid+x] = 0x07 if high else 0x1f
	return (x*2+1, y*2+1)

def place_stairs(g, blocks, x, y):
	"""Swap a 0d cliff (low floor to the south) for 12 = stairs in BR quad, linking low->high."""
	wid = len(g[0])
	assert blocks[y*wid+x] == 0x0d, hex(blocks[y*wid+x])
	blocks[y*wid+x] = 0x12

# ---------------------------------------------------------------- io
_ENG = None
def engine(ref='UnionCave1F'):
	global _ENG
	if _ENG is None: _ENG = R.engine_and_ref(ref, 'summer', 'day')
	return _ENG

def save(name, blocks, w, grid=False, mark=None):
	eng, ref = engine()
	open(f'{OUT}/{name}.ablk', 'wb').write(bytes(blocks))
	img = R.render(bytes(blocks), w, eng, ref, grid=grid, scale=1)
	if mark:
		from PIL import ImageDraw
		d = ImageDraw.Draw(img)
		for (qx, qy) in mark:
			d.rectangle([qx*16+5, qy*16+5, qx*16+10, qy*16+10], fill=(255, 220, 0))
	img.save(f'{OUT}/{name}.png')
	return f'{OUT}/{name}.png'

def overlay_reach(name, blocks, w, reach, warps):
	"""Debug image: reachable quadrants tinted green, warps red."""
	from PIL import Image
	eng, ref = engine()
	img = R.render(bytes(blocks), w, eng, ref).convert('RGBA')
	ov = Image.new('RGBA', img.size, (0,0,0,0))
	from PIL import ImageDraw
	d = ImageDraw.Draw(ov)
	for (x, y) in reach:
		d.rectangle([x*16, y*16, x*16+15, y*16+15], fill=(0,255,0,70))
	for (x, y) in warps:
		d.rectangle([x*16+3, y*16+3, x*16+12, y*16+12], outline=(255,0,0,255), width=2)
	Image.alpha_composite(img, ov).convert('RGB').save(f'{OUT}/{name}_reach.png')

# ---------------------------------------------------------------- ledges
def start_of(blocks, w, wp):
	q = quad_grid(blocks, w)
	return (wp[0], wp[1] + 1) if q[wp[1]][wp[0]] == 'CAVE' else wp

def strongly_connected(blocks, w, pts):
	"""Every point reaches every other (so no one-way soft lock). CAVE warps are entered from below."""
	q = quad_grid(blocks, w)
	for a in pts:
		r = bfs(blocks, w, {start_of(blocks, w, a)})
		for b_ in pts:
			if start_of(blocks, w, b_) not in r: return False
	return True

def add_ledges(g, blocks, w, pts, rng, n=1):
	"""Cut one-way ledges (39 = HOP_DOWN over a WALL half) across passages, keeping every
	point in pts mutually reachable. Returns list of ledge runs placed."""
	hh = len(g); runs = []
	for y in range(2, hh - 2):
		x = 1
		while x < w - 1:
			ok = lambda xx: g[y][xx] == L and g[y-1][xx] == L and g[y+1][xx] == L and blocks[y*w+xx] == 0x02 \
				and blocks[(y-1)*w+xx] in (0x02, 0x28, 0x29, 0x2a, 0x2b) and blocks[(y+1)*w+xx] == 0x02
			if ok(x) and g[y][x-1] == H:
				x2 = x
				while x2 + 1 < w and ok(x2 + 1): x2 += 1
				if g[y][x2+1] == H and x2 - x <= 3: runs.append((y, x, x2))
				x = x2 + 1
			else: x += 1
	rng.shuffle(runs); placed = []
	for y, x0, x1 in runs:
		if len(placed) >= n: break
		if any(abs(y - py) <= 2 and not (x1 < px0 - 1 or x0 > px1 + 1) for py, px0, px1 in placed): continue
		saved = bytes(blocks)
		for x in range(x0, x1 + 1): blocks[y*w+x] = 0x39
		before = bfs(bytearray(saved), w, {start_of(saved, w, pts[0])})
		after = bfs(blocks, w, {start_of(blocks, w, pts[0])})
		if strongly_connected(blocks, w, pts) and len(after) >= len(before) - 8:
			placed.append((y, x0, x1))
		else:
			blocks[:] = saved
	return placed

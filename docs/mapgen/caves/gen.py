#!/usr/bin/env python3
"""Procedural TILESET_CAVE floors. Usage: python3 gen.py [seed]
Writes <name>.ablk / <name>.png / <name>_reach.png into this directory."""
import os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cavelib import *

def blank(w, h, c=H): return [[c] * w for _ in range(h)]

def border(g, k=1):
	hh, ww = len(g), len(g[0])
	for y in range(hh):
		for x in range(ww):
			if x < k or y < k or x >= ww - k or y >= hh - k: g[y][x] = H

def carve(g, x, y, bw, bh, c=L):
	for yy in range(y, y + bh):
		for xx in range(x, x + bw):
			if 0 < yy < len(g) - 1 and 0 < xx < len(g[0]) - 1: g[yy][xx] = c

def components(g, ok):
	hh, ww = len(g), len(g[0]); lab = {}; comps = []
	for y in range(hh):
		for x in range(ww):
			if (x, y) in lab or not ok(g[y][x]): continue
			comp = []; st = [(x, y)]; lab[(x, y)] = len(comps)
			while st:
				cx, cy = st.pop(); comp.append((cx, cy))
				for dx, dy in ((1,0),(-1,0),(0,1),(0,-1)):
					nx, ny = cx+dx, cy+dy
					if 0 <= nx < ww and 0 <= ny < hh and (nx, ny) not in lab and ok(g[ny][nx]):
						lab[(nx, ny)] = len(comps); st.append((nx, ny))
			comps.append(comp)
	return comps

def stamp_pillars(g, rng, n, sizes=((2, 2), (3, 2), (2, 3), (4, 2))):
	hh, ww = len(g), len(g[0])
	def free(x0, y0, bw, bh, pad=1):
		return all(at(g, x, y) == L for y in range(y0 - pad, y0 + bh + pad) for x in range(x0 - pad, x0 + bw + pad))
	for _ in range(n):
		for _ in range(100):
			bw, bh = rng.choice(sizes)
			x0, y0 = rng.randint(2, ww - bw - 2), rng.randint(2, hh - bh - 3)
			if free(x0, y0, bw, bh, 1):
				carve(g, x0, y0, bw, bh, H); break

def check_buffer(w, h):
	assert (w + 6) * (h + 6) <= 1300, (w, h)

def report(name, blocks, w, warps, surf_needed=False):
	"""BFS from the first warp; every warp must be reachable (walking, or surfing if allowed)."""
	q = quad_grid(blocks, w)
	sx, sy = warps[0]
	start = (sx, sy + 1) if q[sy][sx] == 'CAVE' else (sx, sy)
	reach = bfs(blocks, w, {start}, surf=surf_needed)
	reach |= {wp for wp in warps if q[wp[1]][wp[0]] == 'CAVE' and (wp[0], wp[1] + 1) in reach}
	ok = all(wp in reach for wp in warps)
	overlay_reach(name, blocks, w, reach, warps)
	return ok, len(reach)

def find_exit_down(g, cands):
	"""L cell whose south neighbour is H and that H is a plain rim (N open only)."""
	for x, y in cands:
		if g[y][x] == L and at(g, x, y+1) == H and at(g, x-1, y) == L and at(g, x+1, y) == L \
		   and at(g, x-1, y+1) == H and at(g, x+1, y+1) == H and at(g, x, y+2) == H:
			return x, y
	return None

def ensure_bottom_alcove(g):
	"""Guarantee an exit-down spot: extend the lowest floor cell straight down as a 3-wide alcove."""
	hh, ww = len(g), len(g[0])
	cells = [(x, y) for y in range(hh) for x in range(2, ww - 2) if g[y][x] == L]
	x, y = max(cells, key=lambda p: (p[1], -abs(p[0] - ww // 2)))
	for yy in range(y, hh - 2):
		for xx in (x - 1, x, x + 1): g[yy][xx] = L
	return [(x, hh - 3)]

def ensure_top_alcove(g):
	hh, ww = len(g), len(g[0])
	cells = [(x, y) for y in range(hh) for x in range(2, ww - 2) if g[y][x] == L]
	x, y = min(cells, key=lambda p: (p[1], abs(p[0] - ww // 2)))
	for yy in range(2, y + 1):
		for xx in (x - 1, x, x + 1): g[yy][xx] = L
	return [(x, 1)]

def endpoints(g, bot_rows, top_rows):
	"""Autotile, then find (or carve) a south exit mat and a north cave mouth."""
	hh, ww = len(g), len(g[0])
	cand_b = lambda: [(x, y) for y in bot_rows for x in range(ww)]
	cand_t = lambda: [(x, y) for y in top_rows for x in range(ww)]
	for x in range(ww): g[hh - 2][x] = H
	sanitize(g)
	if not find_exit_down(g, cand_b()): ensure_bottom_alcove(g); sanitize(g)
	b = autotile(g)
	if not find_cave_up(g, b, cand_t()): ensure_top_alcove(g); sanitize(g); b = autotile(g)
	assert not thin_cells(g), thin_cells(g)
	bottom = find_exit_down(g, cand_b()); top = find_cave_up(g, b, cand_t())
	return b, bottom, top

def find_cave_up(g, blocks, cands):
	w = len(g[0])
	for x, y in cands:
		if g[y][x] == H and blocks[y*w+x] == 0x0d and at(g, x, y+1) == L:
			return x, y
	return None

# ------------------------------------------------------------------ A: winding tunnel
def jitter_line(g, rng, p0, p1, width):
	"""Carve from p0 to p1 moving one block at a time, randomly choosing the axis (staircase-ish wiggle)."""
	(x, y), (tx, ty) = p0, p1
	carve(g, x, y, width, width)
	while (x, y) != (tx, ty):
		if x != tx and (y == ty or rng.random() < 0.55): x += 1 if tx > x else -1
		else: y += 1 if ty > y else -1
		carve(g, x, y, width, width)

def winding_tunnel(seed, w=14, h=28):
	"""Switchback tunnel: waypoints alternate left/right while climbing; 1-2 block wide passages,
	a couple of dead-end pockets for items, and occasional small chambers."""
	rng = random.Random(seed); check_buffer(w, h)
	g = blank(w, h)
	pts = []; y = h - 3; side = rng.choice((0, 1))
	pts.append((rng.randint(3, w - 5), h - 3))
	while y > 4:
		y -= rng.randint(3, 5)
		y = max(y, 2)
		x = rng.randint(1, 3) if side == 0 else rng.randint(w - 5, w - 3)
		pts.append((x, y)); side ^= 1
	pts.append((rng.randint(3, w - 5), 2))
	for i in range(len(pts) - 1):
		jitter_line(g, rng, pts[i], pts[i + 1], 2 if rng.random() < 0.5 else 1)
		if 0 < i and rng.random() < 0.6:  # chamber at a bend
			cx, cy = pts[i]; carve(g, max(1, cx - 1), max(1, cy - 1), 3, 3)
	pockets = []
	for _ in range(2):  # dead-end side pockets
		px, py = rng.choice(pts[1:-1])
		dx = 3 if px < w // 2 else -3
		tgt = (max(1, min(w - 2, px + dx)), max(1, min(h - 3, py + rng.choice((-2, 2)))))
		jitter_line(g, rng, (px, py), tgt, 1); pockets.append(tgt)
	sanitize(g, rng=rng, thicken=0.5); border(g); sanitize(g)
	comps = sorted(components(g, lambda c: c == L), key=len, reverse=True)
	for c in comps[1:]:
		for x, y in c: g[y][x] = H
	b, bottom, top = endpoints(g, range(h - 3, h - 6, -1), range(0, 4))
	warps = []
	if bottom: warps.append(place_exit_down(g, b, *bottom))
	if top: warps.append(place_cave_up(g, b, *top))
	keep = {bottom, top}
	if top: keep.add((top[0], top[1] + 1))
	decorate(g, b, rng, keep=keep)
	return g, b, w, warps

# ------------------------------------------------------------------ B: CA cavern with lake
def ca_cavern(seed, w=20, h=18, fill=0.50, iters=4, n_pillars=4):
	rng = random.Random(seed); check_buffer(w, h)
	# elliptical mask: open-biased in the middle, rock-biased toward the edges
	def p_rock(x, y):
		dx, dy = (x - (w - 1) / 2) / (w / 2), (y - (h - 1) / 2) / (h / 2)
		r = (dx * dx + dy * dy) ** 0.5
		return fill * 0.55 + max(0.0, r - 0.55) * 1.6
	g = [[H if rng.random() < p_rock(x, y) else L for x in range(w)] for y in range(h)]
	border(g)
	for _ in range(iters):
		ng = [row[:] for row in g]
		for y in range(1, h - 1):
			for x in range(1, w - 1):
				walls = sum(at(g, x+dx, y+dy) == H for dx in (-1,0,1) for dy in (-1,0,1) if dx or dy)
				ng[y][x] = H if walls >= 5 else L if walls <= 3 else g[y][x]
		g = ng; border(g)
	# keep the largest open component, fill the rest
	comps = sorted(components(g, lambda c: c == L), key=len, reverse=True)
	for c in comps[1:]:
		for x, y in c: g[y][x] = H
	sanitize(g, rng=rng, thicken=0.6); border(g); sanitize(g)
	comps = sorted(components(g, lambda c: c == L), key=len, reverse=True)
	for c in comps[1:]:
		for x, y in c: g[y][x] = H
	# rock pillars (>=2x2 so they autotile) and one stair-plateau island
	def free(x0, y0, bw, bh, pad=1):
		return all(at(g, x, y) == L for y in range(y0 - pad, y0 + bh + pad) for x in range(x0 - pad, x0 + bw + pad))
	plateau = None
	for _ in range(300):
		bw, bh = 4, 3
		x0, y0 = rng.randint(2, w - bw - 2), rng.randint(2, h - bh - 3)
		if free(x0, y0, bw, bh, 1):
			carve(g, x0, y0, bw, bh, H); plateau = (x0, y0, bw, bh); break
	for _ in range(n_pillars):
		for _ in range(100):
			bw, bh = rng.choice(((2, 2), (3, 2), (2, 3)))
			x0, y0 = rng.randint(2, w - bw - 2), rng.randint(2, h - bh - 2)
			if free(x0, y0, bw, bh, 1):
				carve(g, x0, y0, bw, bh, H); break
	protect = set()
	if plateau:
		x0, y0, bw, bh = plateau
		protect = {(x, y) for x in range(x0, x0 + bw) for y in range(y0, y0 + bh)}
	# lake: grow a blob from the open cell with the most open space around it
	def space(x, y):
		return sum(at(g, x+dx, y+dy) == L for dx in range(-2, 3) for dy in range(-2, 3))
	opens = [(x, y) for y in range(h) for x in range(w) if g[y][x] == L]
	cx, cy = max(opens, key=lambda p: space(*p) + rng.random())
	lake = {(cx, cy)}; target = max(8, len(opens) // 5)
	frontier = [(cx, cy)]
	while len(lake) < target and frontier:
		px, py = rng.choice(frontier)
		dx, dy = rng.choice(((1,0),(-1,0),(0,1),(0,-1)))
		nx, ny = px+dx, py+dy
		if g[ny][nx] == L and (nx, ny) not in lake and space(nx, ny) >= 16 \
		   and all(at(g, nx+ax, ny+ay) != H or (nx+ax, ny+ay) not in protect for ax in (-1,0,1) for ay in (-1,0,1)):
			lake.add((nx, ny)); frontier.append((nx, ny))
		elif rng.random() < 0.02: frontier.remove((px, py))
	for x, y in lake: g[y][x] = W
	# smooth the lake: drop 1-wide spurs, fill 1-cell bays
	for _ in range(4):
		for y in range(1, h - 1):
			for x in range(1, w - 1):
				nw = sum(at(g, x+dx, y+dy) == W for dx, dy in ((1,0),(-1,0),(0,1),(0,-1)))
				if g[y][x] == W and nw <= 1: g[y][x] = L
				elif g[y][x] == L and nw >= 3: g[y][x] = W
				elif g[y][x] == W and at(g, x-1, y) != W and at(g, x+1, y) != W: g[y][x] = L
				elif g[y][x] == W and at(g, x, y-1) != W and at(g, x, y+1) != W: g[y][x] = L
	# the walking area must stay connected around the lake: drop lake cells that cut it
	for _ in range(30):
		comps = components(g, lambda c: c == L)
		if len(comps) <= 1: break
		small = min(comps, key=len)
		# turn the lake cell touching the small component back into floor
		fixed = False
		for x, y in small:
			for dx, dy in ((1,0),(-1,0),(0,1),(0,-1)):
				if at(g, x+dx, y+dy) == W:
					g[y+dy][x+dx] = L; fixed = True; break
			if fixed: break
		if not fixed: break
	b, bottom, top = endpoints(g, range(h - 3, h - 6, -1), range(0, 4))
	warps = []
	if bottom: warps.append(place_exit_down(g, b, *bottom))
	if top: warps.append(place_cave_up(g, b, *top))
	keep = {bottom, top, (top[0], top[1]+1) if top else None}
	if plateau:
		x0, y0, bw, bh = plateau
		sx = x0 + rng.randint(1, bw - 2); sy = y0 + bh - 1
		if b[sy*w+sx] == 0x0d and g[sy+1][sx] == L:
			place_stairs(g, b, sx, sy); keep.add((sx, sy + 1))
			warps.append((sx*2+1, sy*2+1))  # not a warp: stair quadrant, checked for reachability
		item_spot = (x0*2+2, y0*2+2)
	decorate(g, b, rng, keep=keep, density=0.08)
	print('ledges', add_ledges(g, b, w, warps, rng, n=2))
	if plateau: warps.append(item_spot)
	return g, b, w, warps

# ------------------------------------------------------------------ C/D: two floors linked by ladders
def rooms_and_corridors(rng, w, h, n_rooms=7, forced=(), loops=1, rsize=((2, 5), (2, 4))):
	"""Classic dungeon: random rects (block units), L-shaped 2-wide corridors between centres
	(minimum-spanning-ish: each room joins its nearest earlier room)."""
	g = blank(w, h); rooms = list(forced)
	tries = 0
	while len(rooms) < n_rooms and tries < 400:
		tries += 1
		rw, rh = rng.randint(*rsize[0]), rng.randint(*rsize[1])
		rx, ry = rng.randint(1, w - rw - 1), rng.randint(1, h - rh - 1)
		if any(rx < ox + ow + 2 and ox < rx + rw + 2 and ry < oy + oh + 2 and oy < ry + rh + 2 for ox, oy, ow, oh in rooms):
			continue
		rooms.append((rx, ry, rw, rh))
	for r in rooms: carve(g, *r)
	cen = [(x + ww // 2, y + hh // 2) for x, y, ww, hh in rooms]
	edges = []
	for i in range(1, len(rooms)):
		j = min(range(i), key=lambda k: abs(cen[k][0] - cen[i][0]) + abs(cen[k][1] - cen[i][1]))
		edges.append((i, j))
	for _ in range(loops):
		i, j = rng.sample(range(len(rooms)), 2); edges.append((i, j))
	for i, j in edges:
		(x0, y0), (x1, y1) = cen[i], cen[j]
		cw = 2 if rng.random() < 0.3 else 1
		if rng.random() < 0.5:
			carve(g, min(x0, x1), y0, abs(x1 - x0) + cw, cw); carve(g, x1, min(y0, y1), cw, abs(y1 - y0) + cw)
		else:
			carve(g, x0, min(y0, y1), cw, abs(y1 - y0) + cw); carve(g, min(x0, x1), y1, abs(x1 - x0) + cw, cw)
	return g, rooms

def two_floor(seed, w=20, h=18):
	"""1F is split by a rock wall into entrance half (south) and exit half (north).
	Ladder A (south half) and ladder B (north half) both drop to B1F, which connects them."""
	rng = random.Random(seed); check_buffer(w, h)
	# --- 1F: two independent cave halves
	g1 = blank(w, h)
	mid = h // 2
	for (y0, y1) in ((1, mid - 1), (mid + 1, h - 1)):
		sub, _ = rooms_and_corridors(rng, w, y1 - y0 + 1, n_rooms=4, loops=0)
		for yy in range(y1 - y0 + 1):
			for xx in range(w):
				if 0 < y0 + yy < h - 1 and sub[yy][xx] == L: g1[y0 + yy][xx] = L
	sanitize(g1, rng=rng, thicken=0.7); border(g1); sanitize(g1)
	# ladders: pick floor cells in each half
	def pick(g, ys):
		c = [(x, y) for y in ys for x in range(2, w - 2) if g[y][x] == L
		     and at(g, x, y+1) == L and at(g, x+1, y) == L and at(g, x-1, y) == L and at(g, x, y-1) == L]
		return rng.choice(c)
	south = components(g1, lambda c: c == L)
	south = [c for c in south if any(y > mid for x, y in c)]
	north = [c for c in components(g1, lambda c: c == L) if all(y < mid for x, y in c)]
	# keep only the biggest component per half
	for half in (south, north):
		half.sort(key=len, reverse=True)
		for c in half[1:]:
			for x, y in c: g1[y][x] = H
	sanitize(g1)
	lA = pick(g1, range(mid + 1, h - 3)); lB = pick(g1, range(2, mid - 1))
	b1 = autotile(g1)
	bottom = find_exit_down(g1, [(x, y) for y in range(h - 2, mid, -1) for x in range(w)])
	top = find_cave_up(g1, b1, [(x, y) for y in range(0, mid) for x in range(w)])
	warps1 = [place_exit_down(g1, b1, *bottom)]
	if top: warps1.append(place_cave_up(g1, b1, *top))
	warps1 += [place_ladder(g1, b1, *lA), place_ladder(g1, b1, *lB)]
	decorate(g1, b1, rng, keep={bottom, top, (top[0], top[1]+1) if top else None, lA, lB, (lA[0]+1, lA[1]), (lB[0]+1, lB[1])}, density=0.08)
	# --- B1F: rooms with forced rooms around both ladder positions, all connected
	forced = [(max(1, lA[0] - 1), max(1, lA[1] - 1), 3, 3), (max(1, lB[0] - 1), max(1, lB[1] - 1), 3, 3)]
	g2, rooms = rooms_and_corridors(rng, w, h, n_rooms=9, forced=forced, loops=2)
	sanitize(g2, rng=rng, thicken=0.7); border(g2); sanitize(g2)
	comps = sorted(components(g2, lambda c: c == L), key=len, reverse=True)
	for c in comps[1:]:
		for x, y in c: g2[y][x] = H
	b2 = autotile(g2)
	warps2 = [place_ladder(g2, b2, *lA), place_ladder(g2, b2, *lB)]
	decorate(g2, b2, rng, keep={lA, lB, (lA[0]+1, lA[1]), (lB[0]+1, lB[1])}, density=0.1)
	return (g1, b1, warps1), (g2, b2, warps2), w


# ------------------------------------------------------------------ E: underground river (Surf + waterfall)
def river_cave(seed, w=20, h=18):
	"""Cavern split by a north-south river that pours in through a waterfall (2c) in the north wall.
	Entrance mat on the west bank, cave mouth on the east bank: Surf required to cross."""
	rng = random.Random(seed); check_buffer(w, h)
	def p_rock(x, y):
		dx, dy = (x - (w - 1) / 2) / (w / 2), (y - (h - 1) / 2) / (h / 2)
		return 0.22 + max(0.0, (dx*dx + dy*dy) ** 0.5 - 0.6) * 1.8
	g = [[H if rng.random() < p_rock(x, y) else L for x in range(w)] for y in range(h)]
	border(g)
	for _ in range(4):
		ng = [r[:] for r in g]
		for y in range(1, h - 1):
			for x in range(1, w - 1):
				k = sum(at(g, x+dx, y+dy) == H for dx in (-1,0,1) for dy in (-1,0,1) if dx or dy)
				ng[y][x] = H if k >= 5 else L if k <= 3 else g[y][x]
		g = ng; border(g)
	for x in range(w): g[h - 2][x] = H
	# river: meandering 2-wide channel, x drifts by at most 1 per row
	rx = w // 2 - 1 + rng.randint(-2, 2); fall = rx
	river = []
	for y in range(1, h - 2):
		if y > 3 and rng.random() < 0.45: rx = max(5, min(w - 7, rx + rng.choice((-1, 1))))
		wd = 2 if y < 4 else rng.choice((2, 2, 3))
		for x in range(rx, rx + wd): river.append((x, y))
	falls = {(fall + dx, y) for dx in (0, 1) for y in (0, 1, 2)}
	for x, y in river: g[y][x] = W
	stamp_pillars(g, rng, 5)
	# little island with an item in the river
	sanitize(g, protect=set(river), rng=rng, thicken=0.6); border(g)
	for x, y in falls: g[y][x] = W
	for x in range(w): g[h - 2][x] = H
	sanitize(g, protect=set(river) | falls)
	west = max((c for c in components(g, lambda c: c == L) if sum(x for x, _ in c) / len(c) < fall), key=len)
	east = max((c for c in components(g, lambda c: c == L) if sum(x for x, _ in c) / len(c) > fall), key=len)
	for c in components(g, lambda c: c == L):
		if c is not west and c is not east and set(c) != set(west) and set(c) != set(east):
			for x, y in c: g[y][x] = H
	sanitize(g, protect=set(river) | falls)
	b = autotile(g)
	for x, y in falls: b[y*w+x] = 0x2c
	ws, es = set(west), set(east)
	bottom = find_exit_down(g, [(x, y) for y in range(h - 3, h - 7, -1) for x in range(w) if (x, y) in ws])
	top = find_cave_up(g, b, [(x, y) for y in range(0, h) for x in range(w - 1, -1, -1) if (x, y + 1) in es])
	if not bottom or not top: return None
	warps = [place_exit_down(g, b, *bottom), place_cave_up(g, b, *top)]
	decorate(g, b, rng, keep={bottom, top, (top[0], top[1] + 1)}, density=0.08)
	return g, b, w, warps

if __name__ == '__main__':
	seed = int(sys.argv[1]) if len(sys.argv) > 1 else 1
	g, b, w, warps = winding_tunnel(seed)
	save(f'tunnel_{seed}', b, w); print('tunnel', report(f'tunnel_{seed}', b, w, warps), warps)
	g, b, w, warps = ca_cavern(seed)
	save(f'cavern_{seed}', b, w); print('cavern', report(f'cavern_{seed}', b, w, warps), warps)
	r = river_cave(seed)
	if r:
		g, b, w, warps = r
		save(f'river_{seed}', b, w)
		walk = bfs(b, w, {warps[0]}); surf = bfs(b, w, {warps[0]}, surf=True)
		print('river walk-reaches-mouth', (warps[1][0], warps[1][1] + 1) in walk,
		      'surf-reaches-mouth', (warps[1][0], warps[1][1] + 1) in surf, warps)
		overlay_reach(f'river_{seed}', b, w, surf, warps)
	(g1, b1, w1), (g2, b2, w2), w = two_floor(seed)
	save(f'twofloor_{seed}_1F', b1, w); save(f'twofloor_{seed}_B1F', b2, w)
	print('1F', report(f'twofloor_{seed}_1F', b1, w, w1), w1)
	print('B1F', report(f'twofloor_{seed}_B1F', b2, w, w2), w2)

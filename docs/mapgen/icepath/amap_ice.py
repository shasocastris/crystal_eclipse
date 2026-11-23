#!/usr/bin/env python3
"""Local amap.py variant for TILESET_ICE_PATH: models ice sliding, pits, Rock Smash rocks.

  python3 amap_ice.py FILE.amap [--time nite --suffix _nite]

Extra obj kind: `rock` (Rock Smash rock). Reports reachability in two modes
(walk, +smash) and prints the shortest slide route between `exit` lines.
"""
import os, sys, argparse
from collections import deque
HERE = os.path.dirname(os.path.abspath(__file__))
MAPGEN = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(MAPGEN, 'handmade')); sys.path.insert(0, MAPGEN)
import amap

LAND = amap.WALK | {'PIT'}
DIRS = {'D': (0, 1), 'U': (0, -1), 'R': (1, 0), 'L': (-1, 0)}

def ok(g, x, y, blocked):
	if not (0 <= y < len(g) and 0 <= x < len(g[0])) or (x, y) in blocked:
		return False
	c = g[y][x]
	return c in LAND or c in amap.HOPS or c == 'ICE'

def step(g, x, y, d, blocked):
	"""One input from (x,y) in direction d -> resting cell, or None."""
	dx, dy = d
	c = g[y][x]
	if amap.EDGE.get(c) == d:
		return None
	nx, ny = x + dx, y + dy
	if c in amap.HOPS:
		if d in amap.HOPS[c]:
			nx, ny = x + 2 * dx, y + 2 * dy
		elif d == (0, -1) or True:
			pass
	if not ok(g, nx, ny, blocked):
		return None
	n = g[ny][nx]
	if amap.EDGE.get(n) == (-dx, -dy):
		return None
	if n in amap.HOPS and d == (0, -1):
		return None  # cannot climb a ledge from below
	while g[ny][nx] == 'ICE':
		tx, ty = nx + dx, ny + dy
		if not ok(g, tx, ty, blocked) or amap.EDGE.get(g[ty][tx]) == (-dx, -dy):
			break
		nx, ny = tx, ty
	return nx, ny

def reach(g, start, blocked=()):
	prev = {start: None}
	dq = deque([start])
	while dq:
		p = dq.popleft()
		for name, d in DIRS.items():
			q = step(g, p[0], p[1], d, blocked)
			if q and q not in prev:
				prev[q] = (p, name)
				dq.append(q)
	return prev

def route(prev, tgt):
	out = []
	while prev.get(tgt):
		tgt, n = prev[tgt]
		out.append(n)
	return ''.join(reversed(out))

def covered(g, prev):
	"""Resting cells plus every ice cell slid across."""
	return set(prev)

def report(g, objs, exits):
	out = []
	solid = {(o['x'], o['y']) for o in objs if o['kind'] in ('trainer', 'npc', 'item', 'sign')}
	rocks = {(o['x'], o['y']) for o in objs if o['kind'] == 'rock'}
	for o in objs:
		c = g[o['y']][o['x']]
		if o['kind'] != 'sign' and c not in LAND and c != 'ICE':
			out.append(f"  WARN {o['kind']} {o['label']} at {o['x']},{o['y']} sits on {c}")
	for mode, blk in (('walk', solid | rocks), ('+smash', solid)):
		res = {n: reach(g, (x, y), blk) for n, x, y in exits}
		for n1, x1, y1 in exits:
			for n2, x2, y2 in exits:
				if n1 != n2:
					r = res[n1]
					out.append(f"  {mode:7s} {n1}->{n2}: " + (f"{len(route(r, (x2, y2)))} inputs {route(r, (x2, y2))}" if (x2, y2) in r else 'NO'))
		r0 = res[exits[0][0]]
		for o in objs:
			adj = [(o['x'] + dx, o['y'] + dy) for dx, dy in DIRS.values()]
			hit = [a for a in adj if a in r0]
			if o['kind'] == 'hidden':
				hit = [a for a in adj + [(o['x'], o['y'])] if a in r0]
			if not hit:
				out.append(f"  {mode:7s} {o['kind']} {o['label']} NOT reachable from {exits[0][0]}")
			elif mode == 'walk':
				out.append(f"  {o['kind']:7s} {o['label']:22s} {len(route(r0, hit[0])):3d} inputs from {exits[0][0]}")
	ice = sum(r.count('ICE') for r in g)
	out.append(f'  ice cells {ice}')
	return '\n'.join(out)

def main():
	ap = argparse.ArgumentParser()
	ap.add_argument('src'); ap.add_argument('--time', default='day'); ap.add_argument('--suffix', default='')
	a = ap.parse_args()
	src = os.path.abspath(a.src)
	ref, w, h, data, objs, exits, tileset = amap.parse(src)
	base = os.path.splitext(src)[0]
	open(base + '.ablk', 'wb').write(data)
	print(f'{os.path.basename(base)}: {w}x{h} blocks, buffer {(w+6)*(h+6)} / 1300')
	g = amap.cells(w, h, data, amap.load_coll(tileset))
	print(report(g, objs, exits))
	import render_ablk as ra
	from PIL import ImageDraw
	eng, refm = ra.engine_and_ref(ref, 'summer', a.time)
	# CSE.pals() in utils/render_overworld.py skips LoadSpecialMapPalette, so apply ice_path.pal here
	ro = ra.ro
	ice = [list(p) for p in ro.palettes_of(ro.parse_rgb('gfx/tilesets/ice_path.pal'))[:8]]
	eng.pals = lambda m: ice
	img = ra.render(data, w, eng, refm, scale=2)
	img.save(base + a.suffix + '.png')
	if a.suffix:
		return
	ra.render(data, w, eng, refm, grid=True, scale=2).save(base + '_grid.png')
	d = ImageDraw.Draw(img)
	col = dict(amap.COLORS, rock=(150, 150, 150))
	solid = {(o['x'], o['y']) for o in objs if o['kind'] != 'hidden'}
	for o in objs:
		dd = {'up': (0, -1), 'down': (0, 1), 'left': (-1, 0), 'right': (1, 0)}.get(o['face'])
		x, y = o['x'], o['y']
		for _ in range(o['rng'] if dd else 0):
			x, y = x + dd[0], y + dd[1]
			if not ok(g, x, y, solid):
				break
			d.rectangle([x * 32 + 10, y * 32 + 10, x * 32 + 21, y * 32 + 21], outline=col[o['kind']], width=2)
	for o in objs:
		cx, cy = o['x'] * 32 + 16, o['y'] * 32 + 16
		d.ellipse([cx - 11, cy - 11, cx + 11, cy + 11], fill=col.get(o['kind'], (255, 255, 255)), outline=(0, 0, 0), width=2)
		d.text((cx + 12, cy - 14), o['label'], fill=(255, 255, 255), stroke_width=2, stroke_fill=(0, 0, 0))
	for n, x, y in exits:
		d.rectangle([x * 32 + 2, y * 32 + 2, x * 32 + 29, y * 32 + 29], outline=(0, 255, 255), width=3)
		d.text((x * 32 + 4, y * 32 + 8), n, fill=(0, 255, 255), stroke_width=2, stroke_fill=(0, 0, 0))
	img.save(base + '_marked.png')

if __name__ == '__main__':
	main()

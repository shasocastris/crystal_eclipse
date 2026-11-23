#!/usr/bin/env python3
"""river.py FILE.amap -- reachability for a map with ice AND water (the player has Surf and Waterfall).

Water is entered from any adjacent land or ice cell; a climbable waterfall carries the player to the
water beyond it; leaving water onto ice starts a slide. Reports routes from the first exit, objects that
cannot be reached, trap states (cells with no way back to the first exit) and what is still reachable
with the ice removed.
"""
import sys
from collections import deque
import amap_ice as A
amap = A.amap
SURF = {'WATER', 'WARP_SURF_DOWN', 'WARP_SURF_UP', 'WARP_SURF_LEFT', 'WARP_SURF_RIGHT'}
DIRS = A.DIRS

def moves(g, p, blocked, ice=True):
	x, y = p
	H, W = len(g), len(g[0])
	at = lambda a, b: g[b][a] if 0 <= b < H and 0 <= a < W else None
	for name, (dx, dy) in DIRS.items():
		nx, ny = x + dx, y + dy
		n = at(nx, ny)
		if at(x, y) in SURF:
			if n == 'WATERFALL' and dx == 0:
				while at(nx, ny) == 'WATERFALL':
					ny += dy
				if at(nx, ny) in SURF:
					yield name, (nx, ny)
			elif n in SURF:
				yield name, (nx, ny)
			elif n == 'ICE' and ice and (nx, ny) not in blocked:
				while at(nx + dx, ny + dy) == 'ICE' and (nx + dx, ny + dy) not in blocked:
					nx, ny = nx + dx, ny + dy
				t = at(nx + dx, ny + dy)
				if (t in A.LAND or t in amap.HOPS) and (nx + dx, ny + dy) not in blocked and amap.EDGE.get(t) != (-dx, -dy):
					nx, ny = nx + dx, ny + dy
				yield name, (nx, ny)
			elif n in A.LAND and (nx, ny) not in blocked:
				yield name, (nx, ny)
		else:
			if n in SURF:
				yield name, (nx, ny)
				continue
			if not ice and (n == 'ICE' or at(x, y) == 'ICE'):
				continue
			q = A.step(g, x, y, (dx, dy), blocked)
			if q:
				yield name, q

def reach(g, start, blocked, ice=True):
	prev = {start: None}
	dq = deque([start])
	while dq:
		p = dq.popleft()
		for name, q in moves(g, p, blocked, ice):
			if q not in prev:
				prev[q] = (p, name); dq.append(q)
	return prev

def main():
	ref, w, h, data, objs, exits, ts = amap.parse(sys.argv[1])
	g = amap.cells(w, h, data, amap.load_coll(ts))
	solid = {(o['x'], o['y']) for o in objs if o['kind'] in ('trainer', 'npc', 'item', 'sign')}
	rocks = {(o['x'], o['y']) for o in objs if o['kind'] == 'rock'}
	n0, sx, sy = exits[0]
	for mode, blk in (('walk', solid | rocks), ('+smash', solid)):
		r = reach(g, (sx, sy), blk)
		for n, x, y in exits[1:]:
			print(f'  {mode:7s} {n0}->{n}: ' + (f'{len(A.route(r, (x, y)))} inputs {A.route(r, (x, y))}' if (x, y) in r else 'NO'))
		for o in objs:
			adj = [(o['x'] + dx, o['y'] + dy) for dx, dy in DIRS.values()] + ([(o['x'], o['y'])] if o['kind'] == 'hidden' else [])
			if not any(a in r for a in adj):
				print(f"  {mode:7s} {o['kind']} {o['label']} NOT reachable")
		if mode == '+smash':
			# trap states: build the reverse graph and flood back from the start
			back = {}
			for p in r:
				for _, q in moves(g, p, blk):
					back.setdefault(q, []).append(p)
			ok = {(sx, sy)}; dq = deque(ok)
			while dq:
				for p in back.get(dq.popleft(), ()):
					if p not in ok:
						ok.add(p); dq.append(p)
			traps = sorted(set(r) - ok)
			print(f'  trap states: {len(traps)}', traps[:12])
			r2 = reach(g, (sx, sy), blk, ice=False)
			print('  with no ice, still reachable:', ', '.join(n for n, x, y in exits[1:] if (x, y) in r2) or 'none of the exits')

if __name__ == '__main__':
	main()

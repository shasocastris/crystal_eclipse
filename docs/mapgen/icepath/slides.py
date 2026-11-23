#!/usr/bin/env python3
"""slides.py FILE.amap X Y [X Y ...] -- fewest ice slides from the first exit to each cell, with the route."""
import sys
from collections import deque
import river, amap_ice as A
amap = A.amap
ref, w, h, data, objs, exits, ts = amap.parse(sys.argv[1])
g = amap.cells(w, h, data, amap.load_coll(ts))
solid = {(o['x'], o['y']) for o in objs if o['kind'] in ('trainer', 'npc', 'item', 'sign')}
s = (exits[0][1], exits[0][2])
cost = {s: 0}; prev = {s: None}; dq = deque([s])
while dq:
	p = dq.popleft()
	for name, q in river.moves(g, p, solid):
		c = cost[p] + (1 if g[q[1]][q[0]] == 'ICE' or g[p[1]][p[0]] == 'ICE' else 0)
		if q not in cost or c < cost[q]:
			cost[q] = c; prev[q] = p
			(dq.append if c > cost[p] else dq.appendleft)(q)
a = list(map(int, sys.argv[2:]))
for t in zip(a[::2], a[1::2]):
	if t not in cost: print(t, 'unreachable'); continue
	path = [t]
	while prev[path[-1]]: path.append(prev[path[-1]])
	print(t, cost[t], 'slides:', ' '.join(f'{x},{y}' for x, y in reversed(path) if g[y][x] == 'ICE' or (x, y) == t))

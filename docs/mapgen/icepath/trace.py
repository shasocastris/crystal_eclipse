#!/usr/bin/env python3
"""trace.py FILE.amap X1 Y1 X2 Y2 -- print the resting cells of the shortest route (obj cells block)."""
import sys, amap_ice as A
amap = A.amap
ref, w, h, data, objs, exits, ts = amap.parse(sys.argv[1])
g = amap.cells(w, h, data, amap.load_coll(ts))
blk = {(o['x'], o['y']) for o in objs if o['kind'] != 'hidden'}
s = tuple(map(int, sys.argv[2:4])); t = tuple(map(int, sys.argv[4:6]))
prev = A.reach(g, s, blk)
if t not in prev: sys.exit('unreachable')
path = [t]
while prev[path[-1]]: path.append(prev[path[-1]][0])
path.reverse()
out = []
for a, b in zip(path, path[1:]):
	n = abs(a[0]-b[0]) + abs(a[1]-b[1])
	out.append(f"{prev[b][1]}{'*'+str(n) if n > 1 else ''}->{b[0]},{b[1]}")
print(' '.join(out)); print('slides:', sum('*' in o for o in out))

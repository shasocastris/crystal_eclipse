#!/usr/bin/env python3
"""crop.py MAP W Y0 Y1 [X0 X1] OUT -- render a crop of a vanilla map with grid, 2x."""
import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../../../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import sys, os
OUT = os.path.abspath(sys.argv[-1])
MAPGEN = f'{_REPO_ROOT}/docs/mapgen'
sys.path.insert(0, MAPGEN)
import render_ablk as ra
m, w = sys.argv[1], int(sys.argv[2])
a = [int(x) for x in sys.argv[3:-1]]
y0, y1 = a[0], a[1]
x0, x1 = (a[2], a[3]) if len(a) > 2 else (0, w)
d = open(f'{_REPO_ROOT}/maps/{m}.ablk', 'rb').read()
sub = bytes(d[y * w + x] for y in range(y0, y1) for x in range(x0, x1))
eng, ref = ra.engine_and_ref(m, 'summer', 'day')
ra.render(sub, x1 - x0, eng, ref, grid=True, scale=2).save(OUT)
print(OUT)

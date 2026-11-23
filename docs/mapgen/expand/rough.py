#!/usr/bin/env python3
"""Roughen forest edges of an .amap: rough.py IN.amap OUT.amap [--seed N] [--p 0.5] [--scatter 0.04]
Grass cells (',') touching forest ('T') get a small-tree block on that side; open grass gets
occasional single trees. Cells listed in 'keep X Y' lines (block coords) are left alone."""
import random, sys, argparse
ap = argparse.ArgumentParser(); ap.add_argument('src'); ap.add_argument('dst')
ap.add_argument('--seed', type=int, default=1); ap.add_argument('--p', type=float, default=0.5)
ap.add_argument('--scatter', type=float, default=0.04)
a = ap.parse_args(); rnd = random.Random(a.seed)
# char -> block; quadrant trees (TL TR BL BR)
TREES = {'!': '3c', '?': '3d', '@': '3e', '$': '3f', '&': '64', '+': '62', '|': '60', '<': '5d', '>': '5e', '%': '61', '/': '5c'}
UP = '!?<'      # trees in top half: forest above
DOWN = '&@$'    # bottom half: forest below
LEFT = '!@|'    # left half: forest to the left
RIGHT = '+?$>'  # right half: forest to the right
SCAT = '!?@$/%'
lines = open(a.src).read().split('\n')
gi = lines.index('grid:'); ge = lines.index('end', gi)
g = [list(r) for r in lines[gi + 1:ge]]
keep = {(int(l.split()[1]), int(l.split()[2])) for l in lines if l.startswith('keep ')}
h, w = len(g), len(g[0])
src = [r[:] for r in g]
def at(x, y): return src[y][x] if 0 <= x < w and 0 <= y < h else 'T'
for y in range(h):
	for x in range(w):
		if src[y][x] != ',' or (x, y) in keep: continue
		opts = []
		if at(x, y - 1) == 'T': opts.append(UP)
		if at(x, y + 1) == 'T': opts.append(DOWN)
		if at(x - 1, y) == 'T': opts.append(LEFT)
		if at(x + 1, y) == 'T': opts.append(RIGHT)
		if opts:
			if rnd.random() < a.p: g[y][x] = rnd.choice(rnd.choice(opts))
		elif all(at(x + dx, y + dy) == ',' for dx in (-1, 0, 1) for dy in (-1, 0, 1)) and rnd.random() < a.scatter:
			g[y][x] = rnd.choice(SCAT)
out = lines[:gi] + ['key ' + ' '.join(f'{k}={v}' for k, v in TREES.items())] + ['grid:'] + [''.join(r) for r in g] + lines[ge:]
open(a.dst, 'w').write('\n'.join(out))

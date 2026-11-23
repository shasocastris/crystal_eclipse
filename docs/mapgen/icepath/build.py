#!/usr/bin/env python3
"""Quadrant sketch (one char per 16x16 cell) -> ice_path_hollow.amap grid.

RETIRED for the Hollow 2026-11-11: both floors are now hand-edited in the build and the .amap files
come from from_build.py. The sketches are in superseded/, and the water block ids below (4c-50)
predate shasocastris's renumbering (see CONTEXT.md). Usable for a NEW Ice Path map once the ids are fixed.
'#' rock, '.' floor, 'i' ice, 'w' water, 'f' waterfall (banks autotiled); OVR pins whole blocks.
Rewrites the grid section of the .amap only; header and obj lines live in head.txt / tail.txt.
"""
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
# build.py [DIR [NAME]]: sources in DIR (default: here), writes DIR/NAME.amap (default ice_path_hollow)
DIR = os.path.join(HERE, sys.argv[1]) if len(sys.argv) > 1 else HERE
NAME = sys.argv[2] if len(sys.argv) > 2 else 'ice_path_hollow'
SK = open(os.path.join(DIR, 'sketch.txt')).read().split('\n')
SK = [r for r in SK if r and not r.startswith(';')]
OVR = {}
for line in open(os.path.join(DIR, 'overrides.txt')):
	w = line.split('#')[0].split()
	if len(w) >= 3:
		for i, hx in enumerate(w[2:]):
			OVR[(int(w[0]) + i, int(w[1]))] = int(hx, 16)
ROCK = {'....': 0x02, '#...': 0x20, '.#..': 0x22, '..#.': 0x21, '...#': 0x23, '##..': 0x15, '..##': 0x1d,
	'#.#.': 0x18, '.#.#': 0x1a, '###.': 0x14, '##.#': 0x16, '#.##': 0x1c, '.###': 0x1e, '####': 0x19}
ICE = {'iiii': 0x1f, '#iii': 0x2c, 'ii#i': 0x2d, 'i#ii': 0x2e, 'iii#': 0x2f}
WET = {'wwww': 'w', 'ffff': 'f'}
NOBANK = set('wfP')  # a neighbour that is water, a fall or a pinned block (mouth, spring) gets no bank
BANK = {(0, 0, 0): 0x40, (0, 0, 1): 0x42, (0, 1, 0): 0x43, (0, 1, 1): 0x44, (1, 0, 0): 0x45, (1, 0, 1): 0x46, (1, 1, 0): 0x47, (1, 1, 1): 0x48}

def quad(bx, by):
	return SK[by*2][bx*2:bx*2+2] + SK[by*2+1][bx*2:bx*2+2]

def wet(bx, by):
	q = quad(bx, by)
	if q == 'ffff':
		return 0x41
	if q != 'wwww':
		return None
	def land(x, y, ice_ok):
		n = quad(x, y)
		return not (n[0] in NOBANK or (ice_ok and 'i' in n))
	# banks west and east wherever it is not water; a north bank only against rock or floor
	return BANK[(int(land(bx, by-1, True)), int(land(bx-1, by, False)), int(land(bx+1, by, False)))]
W = len(SK[0]) // 2; H = len(SK) // 2
CH = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
sym = {0x19: '#', 0x02: '.', 0x1f: 'i'}
rows = []
for by in range(H):
	r = ''
	for bx in range(W):
		q = quad(bx, by)
		b = OVR.get((bx, by)) or wet(bx, by) or ICE.get(q) or ROCK.get(q)
		if b is None:
			sys.exit(f'block {bx},{by}: no block for {q!r}')
		if b not in sym:
			sym[b] = next(c for c in CH if c not in sym.values())
		r += sym[b]
	rows.append(r)
keys = ' '.join(f'{c}={b:02x}' for b, c in sorted(sym.items()))
out = open(os.path.join(DIR, 'head.txt')).read()
out += 'tileset ice_path\nref IcePath1F\n'
ks = keys.split()
for i in range(0, len(ks), 12):
	out += 'key ' + ' '.join(ks[i:i+12]) + '\n'
out += 'grid:\n' + '\n'.join(rows) + '\nend\n' + open(os.path.join(DIR, 'tail.txt')).read()
open(os.path.join(DIR, NAME + '.amap'), 'w').write(out)

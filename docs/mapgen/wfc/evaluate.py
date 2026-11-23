#!/usr/bin/env python3
"""Score generated .ablk files: walkability, door access, and how 'seen' the
local structure is (share of 2x2 / 3x3 / 4x4 windows that occur verbatim in
any real Johto map -- higher = more plausible, but 4x4 near 100% = copying)."""
import glob, os, re, sys
import mapdata as md

maps = md.load_maps()


def windows(d, w, h, n):
	return {tuple(d[(y + j) * w + x + i] for j in range(n) for i in range(n))
		for y in range(h - n + 1) for x in range(w - n + 1)}


SEEN = {n: set().union(*(windows(d, w, h, n) for w, h, d in maps.values())) for n in (2, 3, 4)}
ENTRANCES = {md.CONST[k] for k in ('DOOR', 'CAVE', 'STAIRCASE')}


def doors_ok(blocks, w):
	g = md.quad_grid(blocks, w)
	sides, _ = md.walk_report(blocks, w)
	starts = [c for s in sides for c in md.edge_cells(g, s)]
	seen, _ = md.reachable(blocks, w, starts)
	doors = [(x, y) for y, row in enumerate(g) for x, c in enumerate(row) if c in ENTRANCES]
	good = sum(1 for x, y in doors if (x, y + 1) in seen)
	return good, len(doors)


def score(path):
	m = re.search(r'_(\d+)x(\d+)_', os.path.basename(path))
	w, h = int(m.group(1)), int(m.group(2))
	d = open(path, 'rb').read()
	out = {}
	for n in (2, 3, 4):
		ws = [tuple(d[(y + j) * w + x + i] for j in range(n) for i in range(n))
			for y in range(h - n + 1) for x in range(w - n + 1)]
		out[f'seen{n}'] = sum(1 for x in ws if x in SEEN[n]) / len(ws)
	sides, rep = md.walk_report(d, w)
	links = [k for k in rep if '->' in k]
	out['links'] = f'{sum(rep[k] for k in links)}/{len(links)}'
	out['doors'] = '%d/%d' % doors_ok(d, w)
	return out


if __name__ == '__main__':
	files = sys.argv[1:] or sorted(glob.glob(os.path.join(os.path.dirname(__file__), 'out', '*.ablk')))
	for f in files:
		s = score(f)
		print(f'{os.path.basename(f)[:-5]:42s} seen2={s["seen2"]:.2f} seen3={s["seen3"]:.2f} '
			f'seen4={s["seen4"]:.2f} links={s["links"]:5s} entrances={s["doors"]}')

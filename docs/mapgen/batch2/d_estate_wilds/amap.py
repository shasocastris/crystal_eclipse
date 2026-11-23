#!/usr/bin/env python3
"""ASCII map authoring for the Johto tileset.

  python3 amap.py SOURCE.amap [--time nite] [--season winter]

Source format (one file per map):
  # comment
  ref Route30            -- map whose palette/group/tileset the renderer borrows
  tileset mansion        -- collision file to check against (default johto); any
                            tileset other than johto starts with an empty legend
  key X=05               -- legend override/addition (char -> block hex); many per line ok
  grid:                  -- then one row of characters per block row
  ...
  end
  obj KIND X Y LABEL [FACING [RANGE]]  -- step coords (2 per block); KIND in
        trainer npc item hidden sign warp tree fruit
  exit NAME X Y          -- edge/warp cell that must be reachable

Writes NAME.ablk, NAME.png (2x), NAME_grid.png (with block ids),
NAME_marked.png (objects + sightlines), and prints a reachability report.
"""
import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../../../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import os, re, sys, argparse
from collections import deque

HERE = os.path.dirname(os.path.abspath(__file__))
MAPGEN = f'{_REPO_ROOT}/docs/mapgen'
REPO = f'{_REPO_ROOT}'

BASE = {
	'T': 0x05,  # forest wall
	'.': 0x01,  # path / dirt
	',': 0x02,  # short grass
	'"': 0x03,  # tall grass (encounters)
	'*': 0x04,  # flowers
	'~': 0x35,  # water
	'(': 0x54, '^': 0x76, ')': 0x55,  # pond top-left / top / top-right shore
	'[': 0x58, ']': 0x59,             # pond left / right shore
	'{': 0x79, '}': 0x7a,             # pond inner corners (notch top-left / top-right)
	'_': 0x56,  # path ledge (hop down)
	'=': 0x57,  # grass ledge (hop down)
	'o': 0x0a,  # boulder / rock pile
	'#': 0x61,  # cluster of 4 headbutt trees
	'S': 0x47,  # sign on grass
	's': 0x45,  # sign on path
	'C': 0x73,  # cave mouth in cliff
	'%': 0x71,  # mountain dirt floor
}

def load_coll(tileset='johto'):
	coll = {}
	for line in open(os.path.join(REPO, f'data/tilesets/{tileset}_collision.asm')):
		m = re.match(r'\s*tilecoll\s+(\w+),\s*(\w+),\s*(\w+),\s*(\w+)\s*;\s*([0-9a-f]+)', line)
		if m:
			coll[int(m.group(5), 16)] = [m.group(i) for i in range(1, 5)]
	return coll

def parse(path):
	legend = dict(BASE)
	ref, rows, objs, exits, tileset = 'Route30', [], [], [], 'johto'
	mode = None
	for raw in open(path):
		line = raw.rstrip('\n')
		if mode == 'grid':
			if line.strip() == 'end':
				mode = None
			else:
				rows.append(line.rstrip())
			continue
		s = line.split('#', 1)[0].strip() if not line.startswith('key') else line.strip()
		if not s:
			continue
		w = s.split()
		if w[0] == 'ref':
			ref = w[1]
		elif w[0] == 'tileset':
			tileset = w[1]
			if tileset != 'johto':
				legend = {}
		elif w[0] == 'key':
			for kv in w[1:]:
				k, v = kv.rsplit('=', 1)
				legend[k] = int(v, 16)
		elif w[0] == 'grid:':
			mode = 'grid'
		elif w[0] == 'obj':
			objs.append(dict(kind=w[1], x=int(w[2]), y=int(w[3]), label=w[4],
				face=w[5] if len(w) > 5 else None, rng=int(w[6]) if len(w) > 6 else 0))
		elif w[0] == 'exit':
			exits.append((w[1], int(w[2]), int(w[3])))
	width = max(len(r) for r in rows)
	data = bytearray()
	for y, r in enumerate(rows):
		if len(r) != width:
			sys.exit(f'row {y} has width {len(r)}, expected {width}: {r!r}')
		for x, c in enumerate(r):
			if c not in legend:
				sys.exit(f'unknown char {c!r} at {x},{y}')
			data.append(legend[c])
	return ref, width, len(rows), bytes(data), objs, exits, tileset

WALK = {'FLOOR', '01', 'TALL_GRASS', 'LONG_GRASS', 'DOOR', 'LADDER', 'CAVE',
	'WARP_CARPET_LEFT', 'WARP_CARPET_RIGHT', 'WARP_CARPET_UP', 'WARP_CARPET_DOWN',
	'UP_WALL', 'DOWN_WALL', 'LEFT_WALL', 'RIGHT_WALL'}
HOPS = {'HOP_DOWN': [(0, 1)], 'HOP_LEFT': [(-1, 0)], 'HOP_RIGHT': [(1, 0)],
	'HOP_DOWN_LEFT': [(0, 1), (-1, 0)], 'HOP_DOWN_RIGHT': [(0, 1), (1, 0)]}
WATER = {'WATER', 'WARP_SURF_LEFT', 'WARP_SURF_RIGHT', 'WATERFALL'}
EDGE = {'UP_WALL': (0, -1), 'DOWN_WALL': (0, 1), 'LEFT_WALL': (-1, 0), 'RIGHT_WALL': (1, 0)}

def cells(w, h, data, coll):
	g = [[None] * (w * 2) for _ in range(h * 2)]
	for i, b in enumerate(data):
		bx, by = i % w, i // w
		q = coll[b]
		g[by * 2][bx * 2], g[by * 2][bx * 2 + 1], g[by * 2 + 1][bx * 2], g[by * 2 + 1][bx * 2 + 1] = q
	return g

def kind(c, cut, surf):
	if c in WALK or c in HOPS:
		return 'land'
	if c == 'CUT_TREE' and cut:
		return 'land'
	if c in WATER and surf:
		return 'water'
	return None

def reach(g, start, cut=False, surf=False, blocked=()):
	H, W = len(g), len(g[0])
	seen = {start}
	dq = deque([start])
	while dq:
		x, y = dq.popleft()
		c = g[y][x]
		for dx, dy in ((0, 1), (0, -1), (1, 0), (-1, 0)):
			if EDGE.get(c) == (dx, dy):
				continue
			nx, ny = x + dx, y + dy
			if c in HOPS and (dx, dy) in HOPS[c]:
				nx, ny = x + 2 * dx, y + 2 * dy
			if not (0 <= nx < W and 0 <= ny < H) or (nx, ny) in seen or (nx, ny) in blocked:
				continue
			n = g[ny][nx]
			if EDGE.get(n) == (-dx, -dy):
				continue
			if kind(n, cut, surf) is None:
				continue
			if n in HOPS and not (c in HOPS and (dx, dy) in HOPS[c]):
				pass  # walking onto a ledge cell sideways is allowed (LAND_TILE)
			seen.add((nx, ny))
			dq.append((nx, ny))
	return seen

def report(g, objs, exits):
	out = []
	blocked = {(o['x'], o['y']) for o in objs if o['kind'] in ('trainer', 'npc', 'item', 'sign', 'tree', 'fruit')}
	for o in objs:
		c = g[o['y']][o['x']] if 0 <= o['y'] < len(g) and 0 <= o['x'] < len(g[0]) else 'OOB'
		if o['kind'] in ('trainer', 'npc', 'item', 'hidden') and c not in WALK and c not in HOPS:
			out.append(f"  WARN {o['kind']} {o['label']} at {o['x']},{o['y']} sits on {c}")
	for mode, cut, surf in (('walk', False, False), ('+cut', True, False), ('+cut+surf', True, True)):
		mat = []
		for n1, x1, y1 in exits:
			r = reach(g, (x1, y1), cut, surf, blocked)
			mat.append(''.join('Y' if (x2, y2) in r else '.' for _, x2, y2 in exits))
		out.append(f'  {mode:10s} ' + '  '.join(f'{n}:{m}' for (n, _, _), m in zip(exits, mat)))
	# items / NPCs reachable?
	if exits:
		allr = reach(g, exits[0][1:], True, True, blocked) | reach(g, exits[0][1:], True, True)
		for o in objs:
			if o['kind'] in ('hidden',):
				if (o['x'], o['y']) not in allr:
					out.append(f"  WARN hidden {o['label']} unreachable")
			elif o['kind'] in ('trainer', 'npc', 'item', 'tree', 'fruit', 'sign'):
				adj = [(o['x'] + dx, o['y'] + dy) for dx, dy in ((0, 1), (0, -1), (1, 0), (-1, 0))]
				if not any(a in allr for a in adj):
					out.append(f"  WARN {o['kind']} {o['label']} not reachable from {exits[0][0]}")
	if exits:
		r0 = reach(g, exits[0][1:], False, False, blocked)
		r1 = reach(g, exits[0][1:], True, False, blocked)
		for o in objs:
			adj = {(o['x'] + dx, o['y'] + dy) for dx, dy in ((0, 0), (0, 1), (0, -1), (1, 0), (-1, 0))}
			if not adj & r0:
				out.append(f"  gated: {o['kind']} {o['label']} needs " + ('Cut' if adj & r1 else 'Surf'))
	walkable = sum(1 for r in g for c in r if kind(c, False, False))
	grass = sum(1 for r in g for c in r if c == 'TALL_GRASS')
	out.append(f'  walkable cells {walkable}, tall grass cells {grass}')
	return '\n'.join(out)

COLORS = {'trainer': (230, 30, 30), 'npc': (40, 110, 255), 'item': (255, 200, 0),
	'hidden': (255, 140, 0), 'sign': (160, 60, 200), 'warp': (0, 200, 120),
	'tree': (120, 60, 20), 'fruit': (255, 90, 180)}

def sight(g, o, blocked):
	d = {'up': (0, -1), 'down': (0, 1), 'left': (-1, 0), 'right': (1, 0)}.get(o['face'])
	if not d or not o['rng']:
		return []
	cells_ = []
	x, y = o['x'], o['y']
	for _ in range(o['rng']):
		x, y = x + d[0], y + d[1]
		if not (0 <= y < len(g) and 0 <= x < len(g[0])) or (x, y) in blocked:
			break
		if kind(g[y][x], False, False) is None:
			break
		cells_.append((x, y))
	return cells_

def main():
	ap = argparse.ArgumentParser()
	ap.add_argument('src'); ap.add_argument('--time', default='day'); ap.add_argument('--season', default='summer')
	ap.add_argument('--suffix', default='')
	a = ap.parse_args()
	src = os.path.abspath(a.src)
	ref, w, h, data, objs, exits, tileset = parse(src)
	base = os.path.splitext(src)[0]
	open(base + '.ablk', 'wb').write(data)
	(W6, H6) = (w + 6, h + 6)
	print(f'{os.path.basename(base)}: {w}x{h} blocks, buffer {(W6)*(H6)} / 1300')
	coll = load_coll(tileset)
	g = cells(w, h, data, coll)
	print(report(g, objs, exits))
	sys.path.insert(0, MAPGEN)
	cwd = os.getcwd()
	import render_ablk as ra
	from PIL import ImageDraw
	eng, refm = ra.engine_and_ref(ref, a.season, a.time)
	sfx = a.suffix
	img = ra.render(data, w, eng, refm, scale=2)
	img.save(base + sfx + '.png')
	if sfx:
		return
	ra.render(data, w, eng, refm, grid=True, scale=2).save(base + '_grid.png')
	d = ImageDraw.Draw(img)
	blocked = {(o['x'], o['y']) for o in objs if o['kind'] in ('trainer', 'npc', 'item', 'sign', 'tree', 'fruit')}
	for o in objs:
		col = COLORS.get(o['kind'], (255, 255, 255))
		for (sx, sy) in sight(g, o, blocked):
			d.rectangle([sx * 32 + 10, sy * 32 + 10, sx * 32 + 21, sy * 32 + 21], outline=col, width=2)
	for o in objs:
		col = COLORS.get(o['kind'], (255, 255, 255))
		cx, cy = o['x'] * 32 + 16, o['y'] * 32 + 16
		d.ellipse([cx - 11, cy - 11, cx + 11, cy + 11], fill=col, outline=(0, 0, 0), width=2)
		d.text((cx + 12, cy - 14), o['label'], fill=(255, 255, 255), stroke_width=2, stroke_fill=(0, 0, 0))
	for n, x, y in exits:
		d.rectangle([x * 32 + 2, y * 32 + 2, x * 32 + 29, y * 32 + 29], outline=(0, 255, 255), width=3)
		d.text((x * 32 + 4, y * 32 + 8), n, fill=(0, 255, 255), stroke_width=2, stroke_fill=(0, 0, 0))
	img.save(base + '_marked.png')

if __name__ == '__main__':
	main()

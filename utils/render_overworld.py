#!/usr/bin/env python3
"""Render every connected group of outdoor maps to its own PNG.

Maps are placed by walking the `connection` entries in data/maps/attributes.asm,
so each PNG is one connected region (Johto, Kanto, each Orange island chain...).
Run `make` first: tile graphics are read from the built .2bpp files.

Usage: python utils/render_overworld.py [--out DIR] [--season S] [--time T]
"""

import argparse
import os
import re
import sys
from collections import deque

from PIL import Image

SEASONS = ['spring', 'summer', 'autumn', 'winter']
TIMES = ['morn', 'day', 'nite', 'eve']
OUTDOOR_ENVS = {'TOWN', 'ROUTE'}
ROOF_TILESETS = {'TILESET_JOHTO', 'TILESET_JOHTO_MODERN', 'TILESET_BATTLE_TOWER_OUTSIDE'}
ROOF_FIRST_TILE = 0x0a
ROOF_LENGTH = 9
REGION_NAMES = {'NewBarkTown': 'johto', 'PalletTown': 'kanto', 'ValenciaIsland': 'orange_islands'}


def read(path):
	with open(path) as f:
		return f.read()


def strip_comment(line):
	return line.split(';', 1)[0].strip()


def parse_args_list(s):
	return [a.strip() for a in s.split(',')]


def parse_map_constants():
	"""MAP_CONST -> (group number, width, height)"""
	maps = {}
	group = 0
	for line in read('constants/map_constants.asm').splitlines():
		line = strip_comment(line)
		if line.startswith('newgroup'):
			group += 1
		elif line.startswith('map_const'):
			name, w, h = parse_args_list(line[len('map_const'):])
			maps[name] = (group, int(w), int(h))
	return maps


def parse_map_headers():
	"""MapLabel -> (tileset const, environment, palette)"""
	maps = {}
	for line in read('data/maps/maps.asm').splitlines():
		line = strip_comment(line)
		if not line.startswith('map '):
			continue
		args = parse_args_list(line[4:])
		maps[args[0]] = (args[1], args[2], args[6])
	return maps


def parse_attributes():
	"""MapLabel -> {'const': MAP_CONST, 'conns': [(dir, MapLabel, offset)]}"""
	maps = {}
	cur = None
	for line in read('data/maps/attributes.asm').splitlines():
		line = strip_comment(line)
		if line.startswith('map_attributes'):
			args = parse_args_list(line[len('map_attributes'):])
			cur = maps[args[0]] = {'const': args[1], 'conns': []}
		elif line.startswith('connection') and cur is not None:
			args = parse_args_list(line[len('connection'):])
			if len(args) == 5:  # legacy form: offset is \4 - \5
				offset = eval_int(args[3]) - eval_int(args[4])
			else:
				offset = eval_int(args[3])
			cur['conns'].append((args[0], args[1], offset))
	return maps


def eval_int(s):
	s = s.replace('$', '0x')
	return int(eval(s, {'__builtins__': {}}))


def parse_blocks():
	"""MapLabel -> .ablk path"""
	blocks = {}
	labels = []
	for line in read('data/maps/blocks.asm').splitlines():
		line = strip_comment(line)
		m = re.match(r'(\w+)_Blocks:', line)
		if m:
			labels.append(m.group(1))
			continue
		m = re.match(r'INCBIN\s+"([^"]+)"', line)
		if m:
			for label in labels:
				blocks[label] = m.group(1)
			labels = []
	return blocks


def parse_tilesets():
	"""TILESET_CONST -> {'gfx': .2bpp path, 'meta': path, 'attr': path}"""
	names = []
	for line in read('data/tilesets.asm').splitlines():
		line = strip_comment(line)
		m = re.match(r'tileset\s+Tileset(\w+)', line)
		if m:
			names.append(m.group(1))
	consts = []
	for line in read('constants/tileset_constants.asm').splitlines():
		m = re.match(r'\s*const\s+(TILESET_\w+)', line)
		if m:
			consts.append(m.group(1))
	# const_def starts at 0 with TILESET_JOHTO at 1; Tileset0 is entry 0
	consts = ['TILESET_0'] + consts

	files = {}
	labels = []
	for line in read('gfx/tilesets.asm').splitlines():
		line = strip_comment(line)
		m = re.match(r'(\w+)::', line)
		if m:
			labels.append(m.group(1))
			continue
		m = re.match(r'INCBIN\s+"([^"]+)"', line)
		if m:
			for label in labels:
				files[label] = m.group(1)
			labels = []

	def unlz(path):
		return path[:-3] if path.endswith('.lz') else path

	tilesets = {}
	for const, name in zip(consts, names):
		gfx = unlz(files[f'Tileset{name}vTiles2GFX'])
		gfx = re.sub(r'\.vtiles2$', '', gfx)
		tilesets[const] = {
			'gfx': gfx,
			'meta': unlz(files[f'Tileset{name}Meta']),
			'attr': unlz(files[f'Tileset{name}Attr']),
		}
	return tilesets


def parse_rgb_lines(text):
	"""Every RGB macro's colours, in order, as 8-bit tuples."""
	colors = []
	for line in text.splitlines():
		line = strip_comment(line)
		if not line.startswith('RGB'):
			continue
		nums = [int(n) for n in re.findall(r'\d+', line[3:])]
		for i in range(0, len(nums), 3):
			colors.append(tuple((c << 3) | (c >> 2) for c in nums[i:i + 3]))
	return colors


def parse_env_colors():
	"""environment table name -> list of 8-byte rows"""
	tables = {}
	cur = None
	for line in read('data/maps/environment_colors.asm').splitlines():
		line = strip_comment(line)
		m = re.match(r'\.(\w+):', line)
		if m:
			cur = tables[m.group(1)] = []
			continue
		if cur is not None and line.startswith('db'):
			cur.append([eval_int(x) for x in parse_args_list(line[2:])])
	return tables


ENV_TABLE = {
	'TOWN': 'OutdoorColors', 'ROUTE': 'OutdoorColors', 'INDOOR': 'IndoorColors',
	'CAVE': 'DungeonColors', 'ENVIRONMENT_5': 'Env5Colors', 'GATE': 'IndoorColors',
	'DUNGEON': 'DungeonColors',
}


def parse_roof_groups():
	"""group number -> roof png name (or None)"""
	text = read('data/maps/roofs.asm')
	roof_names = re.findall(r'const ROOF_(\w+)', text)
	roof_files = re.findall(r'INCBIN "gfx/tilesets/roofs/(\w+)\.2bpp"', text)
	by_const = dict(zip(roof_names, roof_files))
	body = text.split('MapGroupRoofs:', 1)[1].split('Roofs:', 1)[0]
	groups = []
	for line in body.splitlines():
		line = strip_comment(line)
		if line.startswith('db'):
			v = line[2:].strip()
			groups.append(None if v == '-1' else by_const[v[len('ROOF_'):]])
	return groups


def load_2bpp(path):
	"""list of tiles, each 8 rows of 8 colour indexes"""
	data = open(path, 'rb').read()
	tiles = []
	for t in range(len(data) // 16):
		rows = []
		for y in range(8):
			lo, hi = data[t * 16 + y * 2], data[t * 16 + y * 2 + 1]
			rows.append([((lo >> (7 - x)) & 1) | (((hi >> (7 - x)) & 1) << 1) for x in range(8)])
		tiles.append(rows)
	return tiles


class Renderer:
	def __init__(self, season, time):
		self.season = SEASONS.index(season)
		self.time = time
		self.tilesets = parse_tilesets()
		self.bg_pal = parse_rgb_lines(read('gfx/tilesets/bg_tiles.pal'))
		self.env_colors = parse_env_colors()
		roof_file = 'roofs_winter.pal' if season == 'winter' else 'roofs.pal'
		self.roof_pal = parse_rgb_lines(read(f'gfx/tilesets/{roof_file}'))
		self.roof_groups = parse_roof_groups()
		self.gfx_cache = {}
		self.block_cache = {}

	def palettes(self, env, group, map_palette):
		time = self.time
		fixed = {'PALETTE_DAY': 'day', 'PALETTE_NITE': 'nite', 'PALETTE_MORN': 'morn', 'PALETTE_EVE': 'eve'}
		if map_palette in fixed:
			time = fixed[map_palette]
		t = TIMES.index(time)
		rows = self.env_colors[ENV_TABLE[env]]
		row = rows[(self.season * 4 if env in OUTDOOR_ENVS else 0) + t]
		pals = [self.bg_pal[i * 4:i * 4 + 4] for i in row]
		if env in OUTDOOR_ENVS:
			# RoofPals: per group, morn/day, nite, eve rows of colours 1-2
			roof_row = {0: 0, 1: 0, 2: 1, 3: 2}[t]
			base = group * 6 + roof_row * 2
			pals[6] = [pals[6][0], self.roof_pal[base], self.roof_pal[base + 1], pals[6][3]]
		return pals

	def tile_gfx(self, tileset, group):
		key = (tileset, group)
		if key not in self.gfx_cache:
			tiles = load_2bpp(self.tilesets[tileset]['gfx'])
			roof = self.roof_groups[group] if group < len(self.roof_groups) else None
			if tileset in ROOF_TILESETS and roof:
				roof_tiles = load_2bpp(f'gfx/tilesets/roofs/{roof}.2bpp')
				for i, rt in enumerate(roof_tiles[:ROOF_LENGTH]):
					tiles[ROOF_FIRST_TILE + i] = rt
			self.gfx_cache[key] = tiles
		return self.gfx_cache[key]

	def render_map(self, info):
		"""Image of one map, w*32 x h*32 pixels"""
		tileset, env, group = info['tileset'], info['env'], info['group']
		tiles = self.tile_gfx(tileset, group)
		pals = self.palettes(env, group, info['palette'])
		meta = open(self.tilesets[tileset]['meta'], 'rb').read()
		attr = open(self.tilesets[tileset]['attr'], 'rb').read()
		blocks = open(info['ablk'], 'rb').read()
		w, h = info['w'], info['h']

		block_imgs = {}
		img = Image.new('RGB', (w * 32, h * 32))
		for by in range(h):
			for bx in range(w):
				b = blocks[by * w + bx]
				if b not in block_imgs:
					block_imgs[b] = self.render_block(b, meta, attr, tiles, pals)
				img.paste(block_imgs[b], (bx * 32, by * 32))
		return img

	def render_block(self, b, meta, attr, tiles, pals):
		img = Image.new('RGB', (32, 32))
		px = img.load()
		for i in range(16):
			off = b * 16 + i
			t = meta[off] if off < len(meta) else 0
			a = attr[off] if off < len(attr) else 0
			pal = pals[a & 7]
			bank = (a >> 3) & 1
			xflip, yflip = a & 0x20, a & 0x40
			if bank:
				idx = 128 + t if t < 128 else 256 + (t - 128)
			else:
				idx = t if t < 128 else None  # $80+ in bank 0 is the font
			tile = tiles[idx] if idx is not None and idx < len(tiles) else None
			ox, oy = (i % 4) * 8, (i // 4) * 8
			for y in range(8):
				sy = 7 - y if yflip else y
				for x in range(8):
					sx = 7 - x if xflip else x
					px[ox + x, oy + y] = pal[tile[sy][sx]] if tile else (255, 0, 255)
		return img


def build_maps():
	consts = parse_map_constants()
	headers = parse_map_headers()
	attrs = parse_attributes()
	blocks = parse_blocks()
	maps = {}
	for label, a in attrs.items():
		if label not in headers or label not in blocks:
			continue
		group, w, h = consts[a['const']]
		tileset, env, palette = headers[label]
		maps[label] = {
			'label': label, 'group': group, 'w': w, 'h': h, 'tileset': tileset,
			'env': env, 'palette': palette, 'ablk': blocks[label], 'conns': a['conns'],
		}
	return maps


def place(maps, start, seen):
	"""BFS from start; returns {label: (x, y)} in blocks and any mismatches"""
	pos = {start: (0, 0)}
	conflicts = []
	queue = deque([start])
	while queue:
		cur = queue.popleft()
		cx, cy = pos[cur]
		cm = maps[cur]
		for direction, target, offset in cm['conns']:
			if target not in maps:
				continue
			tm = maps[target]
			if direction == 'north':
				p = (cx + offset, cy - tm['h'])
			elif direction == 'south':
				p = (cx + offset, cy + cm['h'])
			elif direction == 'west':
				p = (cx - tm['w'], cy + offset)
			else:
				p = (cx + cm['w'], cy + offset)
			if target in pos:
				if pos[target] != p:
					conflicts.append(f'{cur} -> {direction} {target}: {p} vs {pos[target]}')
				continue
			pos[target] = p
			seen.add(target)
			queue.append(target)
	return pos, conflicts


def main():
	ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
	ap.add_argument('--out', default='overworld')
	ap.add_argument('--season', choices=SEASONS, default='summer')
	ap.add_argument('--time', choices=TIMES, default='day')
	ap.add_argument('--min-maps', type=int, default=1,
		help='skip regions with fewer maps than this')
	args = ap.parse_args()

	os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
	maps = build_maps()
	renderer = Renderer(args.season, args.time)
	os.makedirs(args.out, exist_ok=True)

	# Make connections undirected for grouping, so a one-way link still joins
	links = {k: set() for k in maps}
	for k, m in maps.items():
		for _, t, _ in m['conns']:
			if t in maps:
				links[k].add(t)
				links[t].add(k)

	outdoor = [k for k, m in maps.items() if m['env'] in OUTDOOR_ENVS or links[k]]
	seen = set()
	regions = []
	for label in outdoor:  # attributes.asm order, so New Bark leads Johto
		if label in seen:
			continue
		comp = {label}
		q = deque([label])
		while q:
			for n in links[q.popleft()]:
				if n not in comp:
					comp.add(n)
					q.append(n)
		seen |= comp
		regions.append((label, comp))

	for start, comp in regions:
		if len(comp) < args.min_maps:
			continue
		pos, conflicts = place(maps, start, set())
		missing = comp - set(pos)
		if missing:  # only reachable through one-way links into the region
			conflicts.append(f'unplaced (no outgoing path from {start}): {sorted(missing)}')
		xs = [pos[k][0] for k in pos] + [pos[k][0] + maps[k]['w'] for k in pos]
		ys = [pos[k][1] for k in pos] + [pos[k][1] + maps[k]['h'] for k in pos]
		minx, miny = min(xs), min(ys)
		img = Image.new('RGB', ((max(xs) - minx) * 32, (max(ys) - miny) * 32), (0, 0, 0))
		for k, (x, y) in pos.items():
			img.paste(renderer.render_map(maps[k]), ((x - minx) * 32, (y - miny) * 32))
		name = next((n for anchor, n in REGION_NAMES.items() if anchor in comp), None)
		out = args.out
		if name is None:
			name = re.sub(r'(?<!^)(?=[A-Z0-9])(?<![0-9])', '_', start).lower()
			if len(comp) == 1:  # reached only by warp, e.g. National Park
				out = os.path.join(args.out, 'standalone')
				os.makedirs(out, exist_ok=True)
		path = os.path.join(out, f'{name}.png')
		img.save(path, optimize=True)
		print(f'{path}: {len(pos)} maps, {img.width}x{img.height}')
		for c in conflicts:
			print(f'  warning: {c}', file=sys.stderr)


if __name__ == '__main__':
	main()

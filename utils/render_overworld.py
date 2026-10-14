#!/usr/bin/env python3
"""Render every connected group of outdoor maps to its own PNG.

Maps are placed by walking their map connections, so each PNG is one connected
region (Johto, Kanto, an island chain...). Maps reached only by warp land in
standalone/. Tile graphics come from built .2bpp files where they exist, so
run `make` first; a tileset with no .2bpp is read from its .png instead.

Works on this repo and, with --repo, on a few other pokecrystal-based hacks;
each gets a loader that mirrors how its engine fills VRAM and palettes:
  cse       CrystalShireEngine (Crystal Eclipse)
  peridot   Pokemon Peridot
  polished  Polished Crystal
  prism     Pokemon Prism (the released 2017 source)

Usage: python utils/render_overworld.py [--repo DIR] [--out DIR] [--season S] [--time T]
"""

import argparse
import os
import re
import sys
from collections import deque

from PIL import Image

SEASONS = ['spring', 'summer', 'autumn', 'winter']
TIMES = ['morn', 'day', 'nite', 'eve']
FIXED_PALETTES = {'PALETTE_MORN': 0, 'PALETTE_DAY': 1, 'PALETTE_NITE': 2, 'PALETTE_EVE': 3, 'PALETTE_DARK': 3}
OUTDOOR_ENVS = {'TOWN', 'ROUTE'}
BLANK_TILE = [[0] * 8 for _ in range(8)]


# --- parsing helpers --------------------------------------------------------

def read(path):
	with open(path) as f:
		return f.read()


def cond_true(cond):
	"""Evaluate an if/elif condition, treating every DEF() as undefined."""
	expr = re.sub(r'\bDEF\s*\(\s*\w+\s*\)', 'False', cond)
	expr = expr.replace('&&', ' and ').replace('||', ' or ').replace('!', ' not ')
	try:
		return bool(eval(expr, {'__builtins__': {}}))
	except Exception:
		return True  # macro-body conditions and the like: take the first branch


def asm_lines(path):
	"""Comment-stripped, non-empty lines, skipping macro definitions and
	untaken if/else branches (e.g. Polished Crystal's MONOCHROME palettes)."""
	stack = []  # (this branch taken, some branch already taken)
	for line in read(path).splitlines():
		line = line.split(';', 1)[0].strip()
		if not line or 'MACRO' in line:
			continue
		word = line.split(None, 1)[0].lower()
		rest = line[len(word):].strip()
		if word == 'if':
			live = all(t for t, _ in stack)
			taken = live and cond_true(rest)
			stack.append((taken, taken))
		elif word == 'elif' and stack:
			_, done = stack[-1]
			taken = not done and all(t for t, _ in stack[:-1]) and cond_true(rest)
			stack[-1] = (taken, done or taken)
		elif word == 'else' and stack:
			_, done = stack[-1]
			stack[-1] = (not done and all(t for t, _ in stack[:-1]), True)
		elif word == 'endc' and stack:
			stack.pop()
		elif all(t for t, _ in stack):
			yield line


def args_of(line, keyword):
	return [a.strip() for a in line[len(keyword):].split(',')]


def eval_int(s):
	s = s.replace('$', '0x').replace('%', '0b')
	return int(eval(s, {'__builtins__': {}}))


LABEL_RE = r'(\w+)::?'
INCLUDE_RE = r'(?:INCBIN|INCLUDE)\s+"([^"]+)"'


def labelled_incbins(path, label_re=LABEL_RE):
	"""label -> INCBIN/INCLUDE path for each run of labels before an include."""
	files = {}
	labels = []
	for line in asm_lines(path):
		m = re.match(label_re + r'\s*(?:' + INCLUDE_RE + r')?$', line)
		if m:
			labels.append(m.group(1))
			if not m.group(2):
				continue
			line = f'INCBIN "{m.group(2)}"'
		m = re.match(INCLUDE_RE, line)
		if m:
			for label in labels:
				files[label] = m.group(1)
		labels = []
	return files


def rgb_of(line):
	nums = [int(n) for n in re.findall(r'\d+', line[3:])]
	return [tuple((c << 3) | (c >> 2) for c in nums[i:i + 3]) for i in range(0, len(nums), 3)]


def parse_rgb(path):
	"""Every colour of every RGB line, in order, as 8-bit tuples."""
	colors = []
	for line in asm_lines(path):
		if line.startswith('RGB'):
			colors += rgb_of(line)
		else:
			m = re.match(INCLUDE_RE, line)
			if m and m.group(1).endswith('.pal'):
				colors += parse_rgb(m.group(1))
	return colors


def labelled_colors(path):
	"""label -> colours of the RGB lines (and included .pal files) under it."""
	tables = {}
	colors = None
	for line in asm_lines(path):
		m = re.match(LABEL_RE + '$', line)
		if m:
			if colors is None or colors:  # consecutive labels share one table
				colors = []
			tables[m.group(1)] = colors
			continue
		if colors is None:
			continue
		if line.startswith('RGB'):
			colors += rgb_of(line)
		else:
			m = re.match(INCLUDE_RE, line)
			if m and m.group(1).endswith('.pal'):
				colors += parse_rgb(m.group(1))
	return tables


def palettes_of(colors):
	return [colors[i:i + 4] for i in range(0, len(colors) - 3, 4)]


def parse_env_colors(path):
	"""environment table name -> list of 8-byte rows"""
	tables = {}
	cur = None
	for line in asm_lines(path):
		m = re.match(r'\.(\w+):?$', line)
		if m:
			if not cur:  # consecutive labels share one table
				cur = tables[m.group(1)] = cur if cur is not None else []
			else:
				cur = tables[m.group(1)] = []
		elif cur is not None and line.startswith('db'):
			row = args_of(line, 'db')
			if len(row) == 8 and all(re.fullmatch(r'\$?[0-9a-fA-F]+', x) for x in row):
				cur.append([eval_int(x) for x in row])
	return tables


ENV_TABLE = {
	'TOWN': 'OutdoorColors', 'ROUTE': 'OutdoorColors', 'INDOOR': 'IndoorColors',
	'CAVE': 'DungeonColors', 'ENVIRONMENT_5': 'Env5Colors', 'GATE': 'IndoorColors',
	'DUNGEON': 'DungeonColors', 'ISOLATED': 'IsolatedColors', 'PERM_5': 'Perm5Colors',
}


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


def put(vram, start, tiles):
	"""Write tiles into VRAM in place; a short tileset must not shift the rest."""
	for i, tile in enumerate(tiles):
		vram[start + i] = tile


def load_png_tiles(path):
	"""Tiles from a grayscale tileset PNG, lightest shade as colour 0."""
	im = Image.open(path).convert('L')
	px = im.load()
	tiles = []
	for ty in range(im.height // 8):
		for tx in range(im.width // 8):
			tiles.append([[3 - round(px[tx * 8 + x, ty * 8 + y] * 3 / 255) for x in range(8)] for y in range(8)])
	return tiles


def load_tiles(stem):
	"""Tiles for a graphic given its path without extension."""
	if os.path.exists(stem + '.2bpp'):
		return load_2bpp(stem + '.2bpp')
	return load_png_tiles(stem + '.png')


def gfx_stem(path):
	"""gfx/tilesets/johto.2bpp.vtiles2.lz -> gfx/tilesets/johto"""
	return re.sub(r'\.(2bpp|png).*$', '', path)


def unlz(path):
	return re.sub(r'\.lzp?$', '', path)


def snake(name):
	return re.sub(r'(?<!^)(?=[A-Z])|(?<=[A-Za-z])(?=[0-9])', '_', name).lower()


# --- shared pokecrystal-style map data --------------------------------------

def parse_map_constants(path='constants/map_constants.asm'):
	"""MAP_CONST -> (group, number in group, width, height)"""
	maps = {}
	group = num = 0
	for line in asm_lines(path):
		if line.startswith('newgroup'):
			group += 1
			num = 0
		elif line.startswith('map_const'):
			name, w, h = args_of(line, 'map_const')[:3]
			num += 1
			maps[name] = (group, num, eval_int(w), eval_int(h))
	return maps


def parse_map_headers(path='data/maps/maps.asm'):
	"""MapLabel -> args of its `map` line"""
	return {a[0]: a for a in (args_of(l, 'map ') for l in asm_lines(path) if l.startswith('map '))}


def parse_attributes(path='data/maps/attributes.asm'):
	"""MapLabel -> (MAP_CONST, [(direction, MapLabel, offset)])"""
	maps = {}
	conns = None
	for line in asm_lines(path):
		if line.startswith('map_attributes'):
			a = args_of(line, 'map_attributes')
			conns = []
			maps[a[0]] = (a[1], conns)
		elif line.startswith('connection') and conns is not None:
			a = args_of(line, 'connection')
			if len(a) >= 6:  # legacy form: offset is \4 - \5
				offset = eval_int(a[3]) - eval_int(a[4])
			else:
				offset = eval_int(a[3])
			conns.append((a[0], a[1], offset))
	return maps


def parse_blocks(path='data/maps/blocks.asm'):
	"""MapLabel -> block file"""
	return {k.rsplit('_', 1)[0]: unlz(v) for k, v in labelled_incbins(path, r'(\w+_(?:Blocks|BlockData)):?:?$').items()}


def parse_roof_groups(path='data/maps/roofs.asm', files=None):
	"""Roof graphic per map group, or None. Roof files default to the
	INCBINs that follow the ROOF_* constants in the same file."""
	text = read(path)
	if files is None:
		files = dict(zip(re.findall(r'const ROOF_(\w+)', text), re.findall(r'INCBIN "([^"]+)"', text)))
	groups = []
	in_table = False
	for line in asm_lines(path):
		if line.startswith('MapGroupRoofs'):
			in_table = True
		elif re.match(r'Roofs\b', line):
			break
		elif in_table and line.startswith('db'):
			v = line[2:].strip()
			groups.append(None if v == '-1' else unlz(files[v[len('ROOF_'):]]))
	return groups


def tileset_table(path='constants/tileset_constants.asm'):
	"""TILESET_* -> TilesetName, pairing the constants with data/tilesets.asm."""
	consts = re.findall(r'^\s*const\s+(TILESET_\w+)', read(path), re.M)
	names = tileset_names()
	if names and names[0] == '0':  # pret's unused entry 0
		consts = ['TILESET_0'] + consts
	return dict(zip(consts, names))


def tileset_names(path='data/tilesets.asm'):
	return [m.group(1) for m in (re.match(r'tileset\s+Tileset(\w+)', l) for l in asm_lines(path)) if m]


class PokecrystalEngine:
	"""Common ground for engines that kept pret's map data files."""

	region_names = {}
	outdoor_envs = OUTDOOR_ENVS

	def __init__(self, season, time):
		self.season = SEASONS.index(season)
		self.time = TIMES.index(time)
		self.cache = {}

	def load_maps(self):
		consts = parse_map_constants()
		headers = parse_map_headers()
		blocks = parse_blocks()
		maps = {}
		for label, (const, conns) in parse_attributes().items():
			if label not in headers or label not in blocks:
				continue
			group, num, w, h = consts[const]
			hdr = headers[label]
			maps[label] = {
				'label': label, 'const': const, 'group': group, 'num': num, 'w': w, 'h': h,
				'tileset': hdr[1], 'env': hdr[2], 'palette': self.map_palette(hdr),
				'blocks': blocks[label], 'conns': conns, 'outdoor': hdr[2] in self.outdoor_envs,
				'header': hdr,
			}
		return maps

	def map_palette(self, hdr):
		return hdr[6]

	def time_of(self, m):
		return FIXED_PALETTES.get(m['palette'], self.time)

	def cached(self, key, fn):
		if key not in self.cache:
			self.cache[key] = fn()
		return self.cache[key]

	def env_pals(self, bg_pal, env, t, season_rows=False):
		rows = self.env_colors[ENV_TABLE[env]]
		row = rows[(self.season * 4 if season_rows else 0) + t]
		return [list(bg_pal[i]) for i in row]


class CSE(PokecrystalEngine):
	region_names = {'NewBarkTown': 'johto', 'PalletTown': 'kanto', 'ValenciaIsland': 'orange_islands'}
	ROOF_TILESETS = {'TILESET_JOHTO', 'TILESET_JOHTO_MODERN', 'TILESET_BATTLE_TOWER_OUTSIDE'}

	@staticmethod
	def detect():
		return os.path.exists('gfx/tilesets.asm') and 'vtiles2' in read('gfx/tilesets.asm')

	def __init__(self, season, time):
		super().__init__(season, time)
		files = labelled_incbins('gfx/tilesets.asm')
		self.tilesets = {}
		for const, name in tileset_table().items():
			self.tilesets[const] = {
				'gfx': gfx_stem(files[f'Tileset{name}vTiles2GFX']),
				'meta': unlz(files[f'Tileset{name}Meta']),
				'attr': unlz(files[f'Tileset{name}Attr']),
			}
		self.bg_pal = palettes_of(parse_rgb('gfx/tilesets/bg_tiles.pal'))
		self.env_colors = parse_env_colors('data/maps/environment_colors.asm')
		roofs = 'roofs_winter.pal' if season == 'winter' else 'roofs.pal'
		self.roof_pal = parse_rgb(f'gfx/tilesets/{roofs}')
		self.roof_groups = parse_roof_groups()

	def vram(self, m):
		def build():
			tiles = load_tiles(self.tilesets[m['tileset']]['gfx'])
			vram = [None] * 512
			put(vram, 0, tiles[0:128])  # vTiles2, bank 0
			put(vram, 256, tiles[128:384])  # vTiles5 then vTiles4, bank 1
			roof = self.roof_groups[m['group']] if m['group'] < len(self.roof_groups) else None
			if m['tileset'] in self.ROOF_TILESETS and roof:
				put(vram, 0x0a, load_2bpp(roof)[:9])
			return vram
		key = ('vram', m['tileset'], m['group'] if m['tileset'] in self.ROOF_TILESETS else None)
		return self.cached(key, build)

	def pals(self, m):
		t = self.time_of(m)
		env = m['env']
		pals = self.env_pals(self.bg_pal, env, t, season_rows=env in OUTDOOR_ENVS)
		if env in OUTDOOR_ENVS:
			row = {0: 0, 1: 0, 2: 1, 3: 2}[t]  # RoofPals: morn/day, nite, eve
			base = m['group'] * 6 + row * 2
			pals[6][1:3] = self.roof_pal[base:base + 2]
		return pals

	def render_inputs(self, m):
		ts = self.tilesets[m['tileset']]
		meta = self.cached(ts['meta'], lambda: open(ts['meta'], 'rb').read())
		attr = self.cached(ts['attr'], lambda: open(ts['attr'], 'rb').read())
		return meta, attr, self.vram(m), self.pals(m)


class Peridot(PokecrystalEngine):
	ROOF_TILESETS = {'TILESET_JOHTO', 'TILESET_JOHTO_CITY', 'TILESET_MOUNTAIN', 'TILESET_PARK',
		'TILESET_POKEMON_LEAGUE_OUTSIDE'}
	ROOF_ENVS = {'TOWN', 'ROUTE', 'ENVIRONMENT_5'}
	# LoadSpecialMapPalette: tileset -> (palette file, has a time-of-day axis)
	SPECIAL_PALS = {
		'TILESET_BATTLE_TOWER': ('battle_tower', False), 'TILESET_ICE_PATH': ('ice_path', False),
		'TILESET_CASTLE': ('castle', False), 'TILESET_HOUSE': ('house', False),
		'TILESET_RADIO_TOWER': ('radio_tower', False), 'TILESET_MANSION': ('mansion_1', False),
		'TILESET_POKECOM_CENTER': ('pokecom_center', False), 'TILESET_TOWER': ('tower', False),
		'TILESET_GATE': ('gate', False), 'TILESET_GAME_CORNER': ('game_corner', False),
		'TILESET_LAB': ('lab', True), 'TILESET_PORT': ('port', True),
		'TILESET_MOUNTAIN': ('mountain', True), 'TILESET_VOLCANO': ('volcano', True),
		'TILESET_CAVE': ('cave', True), 'TILESET_TUNNEL': ('cave', True),
		'TILESET_FACILITY': ('facility', True), 'TILESET_LIGHTHOUSE': ('lighthouse', True),
		'TILESET_ROOF': ('roof', True), 'TILESET_ELITE_FOUR_ROOM': ('elite_four_room', True),
		'TILESET_CHAMPIONS_ROOM': ('champions_room', True), 'TILESET_POKEMON_LEAGUE': ('pokemon_league', True),
		'TILESET_POKEMON_LEAGUE_OUTSIDE': ('pokemon_league_outside', True),
		'TILESET_LOST_LAND': ('lost_land', True), 'TILESET_CYBERSPACE': ('cyberspace', True),
	}

	@staticmethod
	def detect():
		return os.path.isdir('gfx/tilesets_pals')

	def __init__(self, season, time):
		super().__init__(season, time)
		files = labelled_incbins('gfx/tilesets.asm')
		self.tilesets = {}
		for const, name in tileset_table().items():
			self.tilesets[const] = {
				'gfx': gfx_stem(files[f'Tileset{name}GFX']),
				'meta': unlz(files[f'Tileset{name}Meta']),
				'attr': unlz(files[f'Tileset{name}Attr']),
			}
		self.bg_pal = palettes_of(parse_rgb('gfx/tilesets_pals/bg_tiles.pal'))
		self.env_colors = parse_env_colors('data/maps/environment_colors.asm')
		self.roof_pal = parse_rgb('gfx/tilesets_pals/roofs.pal')
		self.roof_groups = parse_roof_groups()
		consts = parse_map_constants()
		self.victory_port_group = consts.get('VICTORY_PORT', (None,))[0]

	def vram(self, m):
		def build():
			tiles = load_tiles(self.tilesets[m['tileset']]['gfx'])
			vram = [None] * 512
			put(vram, 0, tiles[0:127])  # LoadTilesetGFX copies $7f tiles, not $80
			put(vram, 256, tiles[128:256])
			roof = self.roof_groups[m['group']] if m['group'] < len(self.roof_groups) else None
			if m['tileset'] in self.ROOF_TILESETS and roof:
				rt = load_2bpp(roof)
				for row in range(3):  # a 3x3 block at $00, $10, $20
					put(vram, row * 0x10, rt[row * 3:row * 3 + 3])
			return vram
		key = ('vram', m['tileset'], m['group'] if m['tileset'] in self.ROOF_TILESETS else None)
		return self.cached(key, build)

	def special_pals(self, m, t):
		ts = m['tileset']
		genesis = 'genesis_island', True
		if ts == 'TILESET_ICE_PATH' and m['env'] == 'INDOOR':
			return None
		if ts == 'TILESET_PORT' and self.victory_port_group in (m['group'], m['num']):
			special = genesis  # the map-number compare is the engine's, kept as is
		elif ts in self.SPECIAL_PALS:
			special = self.SPECIAL_PALS[ts]
		elif m['const'] == 'GENESIS_ISLAND':
			special = genesis
		else:
			return None
		name, timed = special
		pals = palettes_of(self.cached(name, lambda: parse_rgb(f'gfx/tilesets_pals/{name}.pal')))
		return [list(p) for p in pals[(t * 8 if timed else 0):][:8]]

	def pals(self, m):
		t = self.time_of(m)
		pals = self.special_pals(m, t) or self.env_pals(self.bg_pal, m['env'], t)
		if m['env'] in self.ROOF_ENVS:
			base = m['group'] * 4 + (2 if t >= 2 else 0)  # RoofPals: morn/day, nite
			pals[6][1:3] = self.roof_pal[base:base + 2]
		return pals

	render_inputs = CSE.render_inputs


class Polished(PokecrystalEngine):
	region_names = {'NewBarkTown': 'johto', 'PalletTown': 'kanto', 'ShamoutiIsland': 'orange_islands'}
	outdoor_envs = {'TOWN', 'ROUTE', 'ISOLATED'}
	NO_ROOF_PAL_TILESETS = {'TILESET_SNOWTOP_MOUNTAIN', 'TILESET_FOREST'}

	@staticmethod
	def detect():
		return os.path.exists('data/maps/palettes.asm') and 'SpecialBGPalettes' in read('data/maps/palettes.asm')

	def __init__(self, season, time):
		super().__init__(season, time)
		files = labelled_incbins('data/tilesets.asm')
		consts = re.findall(r'^\s*(?:const\s+(TILESET_\w+)|DEF (NO_ROOF_TILESETS))', read('constants/tileset_constants.asm'), re.M)
		roofed = [c for c, _ in consts[:[d for _, d in consts].index('NO_ROOF_TILESETS')]]
		self.roof_tilesets = set(roofed)
		self.tilesets = {}
		for const, name in tileset_table().items():
			self.tilesets[const] = {
				'gfx': [files.get(f'Tileset{name}GFX{i}') for i in range(3)],
				'meta': unlz(files[f'Tileset{name}Meta']),
				'attr': unlz(files[f'Tileset{name}Attr']),
			}
		self.bg_pal = palettes_of(parse_rgb('gfx/tilesets/bg_tiles.pal'))
		self.env_colors = parse_env_colors('data/maps/environment_colors.asm')
		self.roof_pal = parse_rgb('gfx/tilesets/roofs.pal')
		roof_files = labelled_incbins('gfx/misc.asm')
		gfx_labels = re.findall(r'fardw (\w+RoofGFX)', read('engine/tilesets/mapgroup_roofs.asm'))
		roof_consts = re.findall(r'const ROOF_(\w+)', read('constants/tileset_constants.asm'))
		self.roof_groups = parse_roof_groups(files={c: roof_files[g] for c, g in zip(roof_consts, gfx_labels)})
		self.colors = {}
		for path in ('data/maps/palettes.asm', 'engine/tilesets/tileset_palettes.asm'):
			self.colors.update(labelled_colors(path))
		self.special = []
		for line in asm_lines('data/maps/palettes.asm'):
			if line.startswith('special_bg_pal'):
				a = args_of(line, 'special_bg_pal')
				kind = a[0]
				if kind in ('map', 'landmark', 'tileset'):
					self.special.append((kind, a[1], a[2], a[3]))

	def map_palette(self, hdr):
		return hdr[7]

	@staticmethod
	def gfx_tiles(path):
		"""Tiles of one tileset part; the .vramN files are slices of a .2bpp."""
		if path is None:
			return []  # the GFX2 terminator: nothing is loaded
		path = unlz(path)
		if os.path.exists(path):
			return load_2bpp(path)
		m = re.match(r'(.*\.2bpp)\.vram(\d)(p?)$', path)
		if m:
			n = 128 - (m.group(3) == 'p')
			start = 0 if m.group(2) == '0' else n + 128 * (int(m.group(2)) - 1)
			return load_tiles(gfx_stem(m.group(1)))[start:start + 128]
		return load_tiles(gfx_stem(path))

	def vram(self, m):
		roofed = m['tileset'] in self.roof_tilesets
		def build():
			gfx0, gfx1, gfx2 = (self.gfx_tiles(p) for p in self.tilesets[m['tileset']]['gfx'])
			vram = [None] * 512
			put(vram, 0, gfx0[:127])
			put(vram, 256, gfx1[:127])
			put(vram, 384, gfx2[:127])
			roof = self.roof_groups[m['group']] if m['group'] < len(self.roof_groups) else None
			if roofed and roof:
				put(vram, 0x0a, load_2bpp(roof)[:9])
			return vram
		return self.cached(('vram', m['tileset'], m['group'] if roofed else None), build)

	def special_pals(self, m, t):
		hdr = m['header']
		for kind, key, mode, label in self.special:
			value = {'map': m['const'], 'landmark': hdr[4], 'tileset': m['tileset']}[kind]
			if value != key:
				continue
			if mode == 'PAL_SPECIAL':
				return None  # code-driven (Pokecenter, Mart, grotto); all indoors
			pals = palettes_of(self.colors[label])
			if mode != 'PAL_SINGLE':  # overcast weather is not modelled
				pals = pals[t * 8:]
			return [list(p) for p in pals[:8]]
		return None

	def pals(self, m):
		t = self.time_of(m)
		pals = self.env_pals(self.bg_pal, m['env'], t)
		special = self.special_pals(m, t)
		if special:
			pals[:7] = special[:7]
		if m['env'] in self.outdoor_envs and m['tileset'] not in self.NO_ROOF_PAL_TILESETS:
			base = m['group'] * 6 + {0: 0, 1: 0, 2: 1, 3: 2}[t] * 2  # morn/day, nite, eve
			pals[6][1:3] = self.roof_pal[base:base + 2]
		return pals

	render_inputs = CSE.render_inputs


class Prism(PokecrystalEngine):
	"""Pokemon Prism's 2017 source: pre-rename pokecrystal file layout."""
	ROOF_TILESETS = {'TILESET_NALJO_1', 'TILESET_NALJO_2', 'TILESET_NALJO_3'}
	NO_ROOF_PAL_TILESETS = {'TILESET_ESPO_FOREST', 'TILESET_OLCAN_ISLE'}

	@staticmethod
	def detect():
		return os.path.exists('maps/second_map_headers.asm')

	def __init__(self, season, time):
		super().__init__(season, time)
		consts = re.findall(r'^\s*const\s+(TILESET_\w+)', read('constants/tilemap_constants.asm'), re.M)
		names = [m.group(1) for m in (re.match(r'tileset\s+Tileset(\w+)', l) for l in asm_lines('tilesets/tileset_headers.asm')) if m]
		files = labelled_incbins('tilesets/tilesets.asm')
		self.tilesets = {}
		for const, name in zip(consts, names[1:]):  # const_value = 1; Tileset00 is entry 0
			self.tilesets[const] = {
				'gfx': gfx_stem(files[f'Tileset{name}GFX']),
				'meta': unlz(files[f'Tileset{name}Meta']),
				'attr': unlz(files[f'Tileset{name}Attr']),
			}
		self.bg_pal = palettes_of(parse_rgb('tilesets/bg.pal'))
		self.env_colors = parse_env_colors('engine/color.asm')
		self.roof_pal = parse_rgb('tilesets/roof.pal')
		roof_files = re.findall(r'INCBIN "([^"]+)"', read('tilesets/roofs.asm'))
		self.roof_groups = []
		in_table = False
		for line in asm_lines('tilesets/roofs.asm'):
			if line.startswith('MapGroupRoofs'):
				in_table = True
			elif line.startswith('Roofs'):
				break
			elif in_table and line.startswith('db'):
				n = eval_int(line[2:])
				self.roof_groups.append(roof_files[n] if n >= 0 else None)

	def load_maps(self):
		consts = {}
		group = num = 0
		for line in asm_lines('constants/map_dimension_constants.asm'):
			if line.startswith('newgroup'):
				group += 1
				num = 0
			elif line.startswith('mapgroup'):
				name, h, w = args_of(line, 'mapgroup')[:3]
				num += 1
				consts[name] = (group, num, eval_int(w), eval_int(h))
		headers = {a[0]: a for a in (args_of(l, 'map_header ') for l in asm_lines('maps/map_headers.asm')
			if l.startswith('map_header '))}
		blocks = parse_blocks('maps/blockdata.asm')
		maps = {}
		conns = None
		for line in asm_lines('maps/second_map_headers.asm'):
			if line.startswith('map_header_2'):
				label, const = args_of(line, 'map_header_2')[:2]
				conns = []
				if label not in headers or label not in blocks:
					continue
				group, num, w, h = consts[const]
				hdr = headers[label]
				maps[label] = {
					'label': label, 'const': const, 'group': group, 'num': num, 'w': w, 'h': h,
					'tileset': hdr[1], 'env': hdr[2], 'palette': hdr[6], 'blocks': blocks[label],
					'conns': conns, 'outdoor': hdr[2] in OUTDOOR_ENVS, 'header': hdr,
				}
			elif line.startswith('connection') and conns is not None:
				# connection dir, MAP_CONST, MapLabel, x/y, offset, strip length, this map
				a = args_of(line, 'connection')
				conns.append((a[0], a[2], eval_int(a[3]) - eval_int(a[4])))
		return maps

	def vram(self, m):
		roofed = m['tileset'] in self.ROOF_TILESETS
		def build():
			tiles = load_tiles(self.tilesets[m['tileset']]['gfx'])
			vram = [None] * 512
			put(vram, 0, tiles[:127])
			put(vram, 256, tiles[128:255])
			roof = self.roof_groups[m['group']] if m['group'] < len(self.roof_groups) else None
			if roofed and roof:
				put(vram, 0x0a, load_tiles(gfx_stem(roof))[:9])
			return vram
		return self.cached(('vram', m['tileset'], m['group'] if roofed else None), build)

	def pals(self, m):
		t = self.time_of(m)
		ts = m['tileset']
		special = {  # LoadSpecialMapPalette
			'TILESET_TRAINER_HOUSE': ('battle_tower', False),
			'TILESET_TUNOD': ('tunod', True),
			'TILESET_ESPO_FOREST': ('espo_forest', True),
			'TILESET_OLCAN_ISLE': ('olcan_isle' if m['const'] == 'OLCAN_ISLE' else 'tunod', True),
		}.get(ts)
		if special:
			pals = palettes_of(self.cached(special[0], lambda: parse_rgb(f'tilesets/{special[0]}.pal')))
			pals = [list(p) for p in pals[(t * 8 if special[1] else 0):][:8]]
		else:
			pals = self.env_pals(self.bg_pal, m['env'], t)
		# every map gets its group's roof colours, indoors too, except in darkness
		if ts not in self.NO_ROOF_PAL_TILESETS and t != 3:
			base = m['group'] * 4 + (2 if t == 2 else 0)
			pals[6][1:3] = self.roof_pal[base:base + 2]
		return pals

	render_inputs = CSE.render_inputs


ENGINES = {'cse': CSE, 'peridot': Peridot, 'polished': Polished, 'prism': Prism}


# --- rendering --------------------------------------------------------------

def render_block(b, meta, attr, vram, pals):
	img = Image.new('RGB', (32, 32))
	px = img.load()
	for i in range(16):
		off = b * 16 + i
		t = meta[off] if off < len(meta) else 0
		a = attr[off] if off < len(attr) else 0
		pal = pals[a & 7]
		tile = vram[((a >> 3) & 1) * 256 + t] or BLANK_TILE
		xflip, yflip = a & 0x20, a & 0x40
		ox, oy = (i % 4) * 8, (i // 4) * 8
		for y in range(8):
			row = tile[7 - y if yflip else y]
			for x in range(8):
				px[ox + x, oy + y] = pal[row[7 - x if xflip else x]]
	return img


def render_map(engine, m):
	"""Image of one map, w*32 x h*32 pixels"""
	meta, attr, vram, pals = engine.render_inputs(m)
	blocks = open(m['blocks'], 'rb').read()
	w, h = m['w'], m['h']
	block_imgs = {}
	img = Image.new('RGB', (w * 32, h * 32))
	for by in range(h):
		for bx in range(w):
			b = blocks[by * w + bx]
			if b not in block_imgs:
				block_imgs[b] = render_block(b, meta, attr, vram, pals)
			img.paste(block_imgs[b], (bx * 32, by * 32))
	return img


def connection_delta(cm, direction, tm, offset):
	"""Where a connected map sits relative to the current one, in blocks."""
	return {
		'north': (offset, -tm['h']),
		'south': (offset, cm['h']),
		'west': (-tm['w'], offset),
		'east': (cm['w'], offset),
	}[direction]


def place(maps, start):
	"""BFS from start; returns {label: (x, y)} in blocks and any mismatches.
	A one-way connection is walked backwards too, so a map that only links
	into the region still gets placed."""
	edges = {k: [] for k in maps}
	for k, m in maps.items():
		for direction, target, offset in m['conns']:
			if target in maps and target != k:  # Navel Rock wraps onto itself
				dx, dy = connection_delta(m, direction, maps[target], offset)
				edges[k].append((target, dx, dy, f'{k} -> {direction} {target}'))
				edges[target].append((k, -dx, -dy, None))
	pos = {start: (0, 0)}
	conflicts = []
	for backwards in (False, True):  # backwards only for what forwards missed
		queue = deque(pos)
		while queue:
			cur = queue.popleft()
			cx, cy = pos[cur]
			for target, dx, dy, name in edges[cur]:
				if not name and not backwards:
					continue
				p = (cx + dx, cy + dy)
				if target in pos:
					if name and pos[target] != p and not backwards:
						conflicts.append(f'{name}: {p} vs {pos[target]}')
					continue
				pos[target] = p
				queue.append(target)
	return pos, conflicts


def main():
	ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
	ap.add_argument('--out', default='overworld')
	ap.add_argument('--repo', default=os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'),
		help='disassembly to render (default: this one)')
	ap.add_argument('--engine', choices=ENGINES, help='default: detected from the repo')
	ap.add_argument('--season', choices=SEASONS, default='summer', help='engines with seasons only')
	ap.add_argument('--time', choices=TIMES, default='day', help="eve is Peridot's 'dark'")
	ap.add_argument('--min-maps', type=int, default=1,
		help='skip regions with fewer maps than this')
	args = ap.parse_args()

	args.out = os.path.abspath(args.out)
	os.chdir(args.repo)
	name = args.engine or next((n for n, e in ENGINES.items() if e.detect()), None)
	if name is None:
		sys.exit(f'{args.repo}: unrecognised engine; pass --engine')
	engine = ENGINES[name](args.season, args.time)
	maps = engine.load_maps()
	os.makedirs(args.out, exist_ok=True)

	# Make connections undirected for grouping, so a one-way link still joins
	links = {k: set() for k in maps}
	for k, m in maps.items():
		for _, t, _ in m['conns']:
			if t in maps and t != k:
				links[k].add(t)
				links[t].add(k)

	outdoor = [k for k, m in maps.items() if m['outdoor'] or links[k]]
	seen = set()
	regions = []
	for label in outdoor:  # map data order, so New Bark leads Johto
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
		pos, conflicts = place(maps, start)
		xs = [pos[k][0] for k in pos] + [pos[k][0] + maps[k]['w'] for k in pos]
		ys = [pos[k][1] for k in pos] + [pos[k][1] + maps[k]['h'] for k in pos]
		minx, miny = min(xs), min(ys)
		img = Image.new('RGB', ((max(xs) - minx) * 32, (max(ys) - miny) * 32), (0, 0, 0))
		for k, (x, y) in pos.items():
			img.paste(render_map(engine, maps[k]), ((x - minx) * 32, (y - miny) * 32))
		region = next((n for anchor, n in engine.region_names.items() if anchor in comp), None)
		out = args.out
		if region is None:
			region = snake(start)
			if len(comp) == 1:  # reached only by warp, e.g. National Park
				out = os.path.join(args.out, 'standalone')
				os.makedirs(out, exist_ok=True)
		path = os.path.join(out, f'{region}.png')
		img.save(path, optimize=True)
		print(f'{path}: {len(pos)} maps, {img.width}x{img.height}')
		for c in conflicts:
			print(f'  warning: {c}', file=sys.stderr)


if __name__ == '__main__':
	main()

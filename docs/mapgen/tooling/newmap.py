#!/usr/bin/env python3
"""Print the snippets needed to register a new map in Crystal Eclipse.

READ-ONLY with respect to the repo: it parses constants to validate and to
find insertion points, then PRINTS what to paste where. It never writes into
the repo. --blank writes a filled .ablk, but only outside the repo.

  python3 newmap.py Route50 --size 10x27 --group CHERRYGROVE --tileset johto \
      --env ROUTE --landmark LANDMARK_ROUTE_30 --music MUSIC_ROUTE_30 \
      --border 05 --conn north:Route30:0 --conn south:CherrygroveCity:-5 \
      --fish FISHGROUP_POND --grass --blank /tmp/.../Route50.ablk

  --group NEWGROUP:ORCHARD  creates a new map group (prints the 5 extra tables)
  --landmark NEW:ORCHARD_ROAD:"ORCHARD ROAD"  appends a new landmark
"""
import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import argparse, os, re, sys

REPO = f'{_REPO_ROOT}'
MAP_BUFFER = 1300          # ram/wram.asm wOverworldMapBlocks:: ds 1300
PAD = 3                    # MAP_CONNECTION_PADDING_WIDTH (constants/gfx_constants.asm)
ENVS = 'TOWN ROUTE INDOOR CAVE ENVIRONMENT_5 GATE DUNGEON'.split()


def rd(rel):
	with open(os.path.join(REPO, rel), encoding='utf-8') as f:
		return f.read().split('\n')


def const_name(pascal):
	s = re.sub(r'(?<=[a-z])(?=[A-Z0-9])|(?<=[0-9])(?=[A-Z])', '_', pascal)
	return s.upper()


def find_line(lines, pat, start=0):
	r = re.compile(pat)
	for i in range(start, len(lines)):
		if r.search(lines[i]):
			return i
	return None


def parse_groups():
	"""{GROUP: (newgroup_line, endgroup_line, [map consts])} from map_constants.asm"""
	L = rd('constants/map_constants.asm')
	groups, cur = {}, None
	for i, l in enumerate(L):
		m = re.match(r'\s*newgroup (\w+)', l)
		if m:
			cur = m.group(1); groups[cur] = [i, None, []]; continue
		m = re.match(r'\s*map_const (\w+),\s*(\d+),\s*(\d+)', l)
		if m and cur:
			groups[cur][2].append((m.group(1), int(m.group(2)), int(m.group(3))))
		if re.match(r'\s*endgroup', l) and cur:
			groups[cur][1] = i; cur = None
	return groups, L


def all_map_dims(groups):
	return {c: (w, h) for g in groups.values() for c, w, h in g[2]}


def section(title):
	print('\n' + '=' * 78 + '\n' + title + '\n' + '=' * 78)


def main():
	ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
	ap.add_argument('name', help='PascalCase map name, e.g. Route50')
	ap.add_argument('--size', required=True, help='WxH in blocks')
	ap.add_argument('--group', required=True, help='existing group (e.g. CHERRYGROVE) or NEWGROUP:NAME')
	ap.add_argument('--tileset', default='johto')
	ap.add_argument('--env', default='ROUTE', choices=ENVS)
	ap.add_argument('--landmark', required=True, help='LANDMARK_X or NEW:CONST:"SIGN NAME"')
	ap.add_argument('--music', default='MUSIC_ROUTE_30')
	ap.add_argument('--palette', default='PALETTE_AUTO')
	ap.add_argument('--fish', default='FISHGROUP_NONE')
	ap.add_argument('--phone-off', action='store_true', help='TRUE = no phone calls here')
	ap.add_argument('--border', default='05', help='border block hex')
	ap.add_argument('--weather', default=None, help='OW_WEATHER_* (optional 5th arg)')
	ap.add_argument('--conn', action='append', default=[], help='dir:MapName:offset (offset in blocks)')
	ap.add_argument('--grass', action='store_true', help='print a grass wild table stub')
	ap.add_argument('--water', action='store_true', help='print a water wild table stub')
	ap.add_argument('--scene', action='store_true', help='map needs a scene var')
	ap.add_argument('--spawn', metavar='X,Y', help='add a Fly spawn at step coords X,Y')
	ap.add_argument('--blank', metavar='PATH', help='write a WxH .ablk filled with --border (outside repo only)')
	a = ap.parse_args()

	w, h = map(int, a.size.lower().split('x'))
	C = const_name(a.name)
	problems, notes = [], []

	# ---- validation against the repo ------------------------------------
	need = (w + 2 * PAD) * (h + 2 * PAD)
	if need > MAP_BUFFER:
		problems.append(f'(W+6)*(H+6) = {need} > {MAP_BUFFER} (wOverworldMapBlocks). Shrink or split the map.')
	if w < 5 or h < 5:
		notes.append('Outdoor maps narrower/shorter than a screen (5x5 blocks... really 10x9 for no edge-scroll) show border; fine for houses, odd for routes.')

	groups, MC = parse_groups()
	dims = all_map_dims(groups)
	if C in dims:
		problems.append(f'{C} already exists in constants/map_constants.asm')
	newgroup = a.group.startswith('NEWGROUP:')
	gname = a.group.split(':', 1)[1] if newgroup else a.group
	if not newgroup and gname not in groups:
		problems.append(f'group {gname} not found; choose one of: ' + ', '.join(groups))
	if newgroup and gname in groups:
		problems.append(f'group {gname} already exists')

	t = a.tileset.lower()
	meta = os.path.join(REPO, f'data/tilesets/{t}_metatiles.bin')
	if not os.path.exists(meta):
		problems.append(f'no data/tilesets/{t}_metatiles.bin')
		nblocks = 256
	else:
		nblocks = os.path.getsize(meta) // 16
		attr = os.path.join(REPO, f'data/tilesets/{t}_attributes.bin')
		if not os.path.exists(attr) or os.path.getsize(attr) != os.path.getsize(meta):
			problems.append(f'{t}_attributes.bin missing or size != metatiles.bin (Polished Map++ will show nothing)')
	if 'TILESET_' + t.upper() not in open(os.path.join(REPO, 'constants/tileset_constants.asm')).read():
		problems.append(f'TILESET_{t.upper()} not in constants/tileset_constants.asm')
	border = int(a.border, 16)
	if border >= nblocks:
		problems.append(f'border block ${border:02x} >= {nblocks} blocks in {t}')

	LC = '\n'.join(rd('constants/landmark_constants.asm'))
	newlm = a.landmark.startswith('NEW:')
	if newlm:
		_, lmc, *lmname = a.landmark.split(':')
		lmconst = lmc if lmc.startswith('LANDMARK_') else 'LANDMARK_' + lmc
		lmname = (lmname[0] if lmname else lmc.replace('_', ' ')).strip('"')
		if len(lmname.replace('<BSP>', ' ')) > 17:
			notes.append('landmark names are limited by the 18-tile map-name popup; use <BSP> to break two words')
	else:
		lmconst = a.landmark
		if not re.search(r'const ' + re.escape(lmconst) + r'\b', LC):
			problems.append(f'{lmconst} not in constants/landmark_constants.asm')

	ev = rd('constants/event_flags.asm')
	free_ev = sum(1 for l in ev if re.match(r'\s*const_skip', l))

	conns = []
	for c in a.conn:
		d, m, off = c.split(':')
		mc = const_name(m)
		if mc not in dims:
			problems.append(f'connection target {mc} not found')
		else:
			tw, th = dims[mc]
			# overlap sanity: the shared edge must overlap at least 1 block
			if d in ('north', 'south'):
				lo, hi = max(0, int(off)), min(w, int(off) + tw)
			else:
				lo, hi = max(0, int(off)), min(h, int(off) + th)
			if hi - lo < 1:
				problems.append(f'{d} connection to {m} offset {off} does not overlap')
		conns.append((d, m, mc, int(off)))
	order = {'north': 0, 'south': 1, 'west': 2, 'east': 3}
	conns.sort(key=lambda x: order[x[0]])
	opposite = {'north': 'south', 'south': 'north', 'west': 'east', 'east': 'west'}

	section(f'{a.name} ({C}) {w}x{h} blocks, group {gname}, tileset {t}')
	print(f'map buffer: (W+6)*(H+6) = {need} / {MAP_BUFFER}')
	print(f'{t}: {nblocks} metatiles; border ${border:02x}')
	print(f'free event-flag slots (const_skip in constants/event_flags.asm): {free_ev}')
	for p in problems:
		print('PROBLEM:', p)
	for n in notes:
		print('note:', n)

	# ---- 1. map_constants -----------------------------------------------
	section('1. constants/map_constants.asm')
	if newgroup:
		last = max(g[1] for g in groups.values())
		print(f'insert after line {last + 1} (last "endgroup"), before "DEF NUM_MAP_GROUPS":\n')
		print(f'\n\tnewgroup {gname:<54}; {len(groups) + 1}')
		print(f'\tmap_const {C + ",":<44} {w:>2}, {h:>2} ;  1')
		print('\tendgroup')
	else:
		ng, eg, ms = groups[gname]
		print(f'APPEND at the end of group {gname} (insert before line {eg + 1}, its "endgroup").')
		print('Never insert mid-group: map numbers are saved (player location, spawns).\n')
		print(f'\tmap_const {C + ",":<44} {w:>2}, {h:>2} ; {len(ms) + 1:>2}')

	# ---- 2. maps.asm ----------------------------------------------------
	section('2. data/maps/maps.asm  (map header)')
	camel = ''.join(p.capitalize() for p in gname.split('_'))
	phone = 'TRUE' if a.phone_off else 'FALSE'
	row = f'\tmap {a.name}, TILESET_{t.upper()}, {a.env}, {lmconst}, {a.music}, {phone}, {a.palette}, {a.fish}'
	if newgroup:
		print(f'a) MapGroupPointers: append   dw MapGroup_{camel:<12}; {len(groups) + 1}')
		print('b) after the last assert_table_length NUM_*_MAPS block, add:\n')
		print(f'MapGroup_{camel}:\n\ttable_width MAP_LENGTH\n{row}\n\tassert_table_length NUM_{gname}_MAPS')
	else:
		MA = rd('data/maps/maps.asm')
		i = find_line(MA, rf'assert_table_length NUM_{gname}_MAPS')
		print(f'insert before line {i + 1} ("assert_table_length NUM_{gname}_MAPS"):\n' if i is not None else '')
		print(row)
	print('\nenv: TOWN/ROUTE get seasonal palettes, roof palettes and weather; CAVE/DUNGEON allow Dig/Escape Rope.')

	# ---- 3. attributes --------------------------------------------------
	section('3. data/maps/attributes.asm  (border, connections, optional weather)')
	dirs = ' | '.join(d.upper() for d, *_ in conns) or '0'
	wx = f', {a.weather}' if a.weather else ''
	print(f'\tmap_attributes {a.name}, {C}, ${border:02x}, {dirs}{wx}')
	for d, m, mc, off in conns:
		print(f'\tconnection {d}, {m}, {mc}, {off}')
	if conns:
		print('\nRECIPROCAL edits on the neighbours (add the direction flag to their map_attributes too):')
		for d, m, mc, off in conns:
			print(f'\t; in {m}: add {opposite[d].upper()} and\n\tconnection {opposite[d]}, {a.name}, {C}, {-off}')
		print('Connections must be listed north, south, west, east in each map.')

	# ---- 4. blocks ------------------------------------------------------
	section('4. data/maps/blocks.asm  ("Map Blocks 3", pinned bank $2c, ~5.8 KB free)')
	BL = rd('data/maps/blocks.asm')
	i = max(j for j, l in enumerate(BL) if l.strip() == 'ENDSECTION')
	print(f'insert before line {i + 1} (final ENDSECTION):\n')
	print(f'{a.name}_Blocks:\n\tINCBIN "maps/{a.name}.ablk"\n')
	print(f'Block data costs {w * h} bytes of that bank.')

	# ---- 5. scripts -----------------------------------------------------
	section('5. data/maps/scripts.asm + maps/' + a.name + '.asm')
	print('"Map Scripts 29" sits in bank $08 with 2 bytes free. Start a new floating section:\n')
	print(f'SECTION "Map Scripts 30", ROMX\n\nINCLUDE "maps/{a.name}.asm"\n\nENDSECTION')
	print(f'\n--- maps/{a.name}.asm ---')
	print(f"""\tobject_const_def

{a.name}_MapScripts:
\tdef_scene_scripts

\tdef_callbacks

{a.name}_MapEvents:
\tdb 0, 0 ; filler

\tdef_warp_events

\tdef_coord_events

\tdef_bg_events

\tdef_object_events
""")
	print('Remember: every text/line/cont/para string <= 18 characters.')

	# ---- 6. scenes ------------------------------------------------------
	if a.scene:
		section('6. data/maps/scenes.asm + ram/wram.asm')
		print(f'\tscene_var {C + ",":<46} w{a.name}SceneID')
		print('WRAM: the scene block ends right before saved wEventFlags; DO NOT append.')
		print('Rename a dead var instead: candidates seen 2026-10-28 are the "ds 3" at')
		print('ram/wram.asm ~2579 and wGoldenrodPokecenter1FSceneID (~2609, no references).')
		print('Without a scene_var entry, setscene/setmapscene silently do nothing.')

	# ---- 7. landmark ----------------------------------------------------
	section('7. landmarks')
	if newlm:
		nm = re.sub(r'\W', '', lmname.title().replace('<Bsp>', '')) + 'Name'
		print('constants/landmark_constants.asm: append after the last ORANGE landmark,')
		print('BEFORE "DEF ORANGE_LANDMARK_LAST" only if it is an Orange place. A Johto/Kanto')
		print('landmark has no free slot: inserting renumbers saved CaughtData and the')
		print('KANTO_LANDMARK/LANDMARK_VICTORY_ROAD ranges RegionCheck/GetRegion use.')
		print('Appending after ORANGE_LANDMARK_LAST makes it >= ORANGE_LANDMARK -> "Orange"!')
		print('=> for Johto/Kanto maps prefer reusing an existing landmark, or extend')
		print('   home/region.asm RegionForLandmark + engine/overworld/landmarks.asm RegionCheck.')
		print(f'\n\tconst {lmconst}')
		print(f'\ndata/maps/landmarks.asm: matching row (town-map px coords) + name:\n\tlandmark  X,  Y, {nm}\n{nm}: db "{lmname}@"')
	else:
		print(f'reusing {lmconst}: nothing to add. The map-name popup only shows on a landmark change.')

	# ---- 8. wild --------------------------------------------------------
	if a.grass or a.water:
		section('8. wild data')
		print('Base tables johto_grass/kanto_grass are INCLUDEd inside "bankA" (fixed bank $0a, ~10 B free).')
		print('Growing bankA forces rgblink to repack floating sections; the M3 lesson was that')
		print('repacking around $0a corrupted map loads. Safer: season tables in bank $75')
		print('(data/wild/season_grass_data.asm, ~11 KB free) with all four seasons filled,')
		print('accepting that the Pokedex AREA (FindNest) only scans the base tables.')
		if a.grass:
			print(f'\n\tdef_grass_wildmons {C}\n\tdb 10 percent ; encounter rate')
			for tod in ('morn', 'day', 'nite'):
				print(f'\t; {tod}')
				for _ in range(7):
					print('\tdbw 3, RATTATA')
			print('\tend_grass_wildmons')
		if a.water:
			print(f'\n\tdef_water_wildmons {C}\n\tdb 4 percent ; encounter rate\n' + '\tdbw 20, TENTACOOL\n' * 3 + '\tend_water_wildmons')

	# ---- 9. new group extras -------------------------------------------
	if newgroup:
		section('9. per-map-group tables (asserts catch most of these)')
		n = len(groups) + 1
		print(f'data/maps/roofs.asm MapGroupRoofs:       db -1 ; {n} ({camel})')
		print(f'data/maps/sgb_roof_pal_inds.asm:          db PREDEFPAL_ROUTES ; {n} ({camel})')
		print('gfx/tilesets/roofs.pal + roofs_winter.pal: one more 2-palette (morn/day + nite) block')
		print(f'engine/events/weather.asm MapGroupSizes:  db NUM_{gname}_MAPS   (assert-checked)')
		print('constants/map_constants.asm: NUM_MAP_GROUPS updates itself.')

	# ---- 10. fly / spawn ------------------------------------------------
	if a.spawn:
		x, y = a.spawn.split(',')
		section('10. Fly point')
		print(f'constants/map_data_constants.asm: append  const SPAWN_{C} (before NUM_SPAWNS) and FLY_{C}')
		print(f'data/maps/spawn_points.asm:          spawn {C + ",":<26} {x}, {y}')
		print(f'data/maps/flypoints.asm:             db {lmconst}, SPAWN_{C}')
		print(f'constants/engine_flags.asm: append ENGINE_FLYPOINT_{C} at the END (not beside the others)')
		print('data/events/engine_flags.asm: matching row; unlock via callback (see maps/ValenciaIsland.asm).')
		print('ram/wram.asm wVisitedSpawns: shrink the reservation after it by one byte per byte gained.')

	section('11. not needed in this engine / optional')
	print('- outdoor sprite sets: none; GetUsedSprites loads from the object_events.')
	print('- radio (data/radio/*), phone contacts, treemon_maps, swarm tables: optional.')
	print('- blackoutmod / healing: only if the map has a Pokemon Center.')
	print('- rebuild: make -j"$(nproc)" && make crystal_debug ; then utils/optimize.py diff.')

	if a.blank:
		p = os.path.realpath(a.blank)
		if p.startswith(os.path.realpath(REPO) + os.sep):
			sys.exit('refusing to write inside the repo')
		with open(p, 'wb') as f:
			f.write(bytes([border]) * (w * h))
		print(f'\nwrote {p} ({w * h} bytes)')
	return 1 if problems else 0


if __name__ == '__main__':
	sys.exit(main())

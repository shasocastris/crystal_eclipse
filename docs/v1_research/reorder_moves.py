#!/usr/bin/env python3
"""Sort the move constants by type and rewrite every positional move table to match.

Usage: python docs/v1_research/reorder_moves.py [--stable] [--check]

Helper only, never committed (shasocastris's rule): it lives in the untracked docs/.

Order: type (constants/type_constants.asm order), then category (physical,
special, status), then power, highest first. --stable keeps the current order
within each type instead. NO_MOVE stays 0 and STRUGGLE goes last in NORMAL.

Rows are swapped slot by slot, so the MOVE_TABLE_SPLIT index, every SECTION
and every table size stay the same. The positional tables are:
  constants/move_constants.asm   const list
  data/moves/moves.asm           move rows
  data/moves/names.asm           li rows
  data/moves/descriptions.asm    description pointers (bodies are by label)
  data/moves/animations_part1.asm anim_ptr rows (slot 0 is NO_MOVE)
  data/moves/animations_part2.asm anim_ptr rows

Each list gets a `; TYPE` comment line above the first move of every type;
those lines are stripped and rewritten on every run.

Re-run it after adding a move. Renumbering moves breaks existing saves.
--check exits 1 if the files are not already in order.
"""

import os
import re
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')

CONSTANTS = 'constants/move_constants.asm'
MOVES = 'data/moves/moves.asm'
NAMES = 'data/moves/names.asm'
DESCRIPTIONS = 'data/moves/descriptions.asm'
ANIMS_1 = 'data/moves/animations_part1.asm'
ANIMS_2 = 'data/moves/animations_part2.asm'

CATEGORIES = ['PHYSICAL', 'SPECIAL', 'STATUS']


def type_names():
	with open(os.path.join(ROOT, 'constants/type_constants.asm')) as f:
		return [m.group(1) for m in (re.match(r'\s*const\s+(\w+)', l) for l in f) if m]


TYPES = type_names()
MARKER = re.compile(r'\s*; (' + '|'.join(TYPES) + r')( \(continued\))?$')


def read(path):
	with open(os.path.join(ROOT, path)) as f:
		return [l for l in f.read().split('\n') if not MARKER.match(l)]


def add_markers(lines, rows, moves, type_of, split=None):
	"""Insert a `; TYPE` line above each row whose move starts a new type.
	rows[k] is a line index; moves[k] is (move, previous move) in global order.
	Row `split` begins the Gen 2 half; a type that runs across it gets a
	`; TYPE (continued)` line there."""
	starts = []
	for k, i in enumerate(rows):
		name, prev = moves[k][0], moves[k][1]
		if name == 'NO_MOVE':
			continue
		if type_of(name) != (type_of(prev) if prev != 'NO_MOVE' else None):
			starts.append((i, type_of(name)))
		elif k == split:
			starts.append((i, type_of(name) + ' (continued)'))
	for i, t in reversed(starts):
		lines.insert(i, f'\t; {t}')
	return lines


def write(path, lines):
	with open(os.path.join(ROOT, path), 'w') as f:
		f.write('\n'.join(lines))


def slots(lines, regex):
	return [i for i, line in enumerate(lines) if re.match(regex, line)]


def main():
	stable = '--stable' in sys.argv
	check = '--check' in sys.argv

	consts = read(CONSTANTS)
	const_slots, old = [], []
	for i, line in enumerate(consts):
		if line.startswith('DEF NUM_ATTACKS'):
			break
		m = re.match(r'\s*const\s+(\w+)', line)
		if m:
			const_slots.append(i)
			old.append(m.group(1))
	assert old[0] == 'NO_MOVE'
	count = len(old) - 1

	tables = {}
	for path, regex in ((MOVES, r'\s*move\s'), (NAMES, r'\s*li\s+"'), (DESCRIPTIONS, r'\s*dw\s+\w+Description\b')):
		lines = read(path)
		rows = slots(lines, regex)
		assert len(rows) == count, f'{path}: {len(rows)} rows for {count} moves'
		tables[path] = (lines, rows)
	anims_1, anims_2 = read(ANIMS_1), read(ANIMS_2)
	anim_rows_1 = slots(anims_1, r'\s*anim_ptr\s')
	anim_rows_2 = slots(anims_2, r'\s*anim_ptr\s')
	assert len(anim_rows_1) + len(anim_rows_2) == count + 1, 'anim_ptr rows must cover NO_MOVE..last move'

	# Each move's row in each table, keyed by name.
	entry = {name: {} for name in old}
	for path, (lines, rows) in tables.items():
		for k, i in enumerate(rows):
			entry[old[k + 1]][path] = lines[i]
	anim_lines = [anims_1[i] for i in anim_rows_1] + [anims_2[i] for i in anim_rows_2]
	for k, name in enumerate(old):
		entry[name]['anim'] = anim_lines[k]

	# The move rows must still line up with the constants.
	for name in old[1:]:
		tag = re.match(r'\s*(\w+)', entry[name][MOVES].rsplit(';', 1)[-1]).group(1)
		assert tag == name, f'{MOVES}: row tagged {tag} sits in the {name} slot'

	types = TYPES
	fields = {name: [x.strip() for x in entry[name][MOVES].split(';')[0].split('move', 1)[1].split(',')] for name in old[1:]}

	def key(name):
		_, power, type_, category = fields[name][:4]
		if stable:
			return (types.index(type_),)
		return (types.index(type_), CATEGORIES.index(category), -int(power))

	body = sorted((n for n in old[1:] if n != 'STRUGGLE'), key=key)
	new = ['NO_MOVE'] + body
	last_normal = max(i for i, n in enumerate(new) if n != 'NO_MOVE' and fields[n][2] == 'NORMAL')
	new.insert(last_normal + 1, 'STRUGGLE')
	assert sorted(new) == sorted(old)

	if check:
		if new != old:
			print('moves are not in type order; run docs/v1_research/reorder_moves.py')
			sys.exit(1)
		print('moves are in type order')
		return

	type_of = lambda name: fields[name][2]
	pairs = [(new[k], new[k - 1] if k else 'NO_MOVE') for k in range(len(new))]

	width = max(len(n) for n in new)
	for k, i in enumerate(const_slots):
		consts[i] = f'\tconst {new[k]:<{width}} ; {k:02x}'
	split = len(anim_rows_1)  # the first Gen 2 move
	write(CONSTANTS, add_markers(consts, const_slots, pairs, type_of, split))

	for path, (lines, rows) in tables.items():
		for k, i in enumerate(rows):
			lines[i] = entry[new[k + 1]][path]
		write(path, add_markers(lines, rows, pairs[1:], type_of, None if path == NAMES else split - 1))

	ordered = [entry[n]['anim'] for n in new]
	for k, i in enumerate(anim_rows_1):
		anims_1[i] = ordered[k]
	for k, i in enumerate(anim_rows_2):
		anims_2[i] = ordered[len(anim_rows_1) + k]
	write(ANIMS_1, add_markers(anims_1, anim_rows_1, pairs, type_of))
	write(ANIMS_2, add_markers(anims_2, anim_rows_2, pairs[len(anim_rows_1):], type_of, 0))

	moved = sum(a != b for a, b in zip(old, new))
	print(f'{count} moves, {moved} renumbered')


if __name__ == '__main__':
	main()

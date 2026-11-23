#!/usr/bin/env python3
"""Lint enemy trainer parties in data/trainers/parties.asm.

Checks:
  error    underleveled  the species can't exist yet at this level
                         (Lv.20 Pidgeot; Pidgeotto evolves at 36)
  error    should-evolve an ungated level/stat evolution is already due
                         (Lv.40 Pidgeotto)
  warning  not-final     the species still has an evolution (item, happiness,
                         or a level not reached yet)
  error    illegal-move  the move isn't in the species' level-up list at or
                         below this level, its TM/HM/tutor list, or its Safari
                         tutor row; pre-evolutions count the same way
  error    dup-move      the same move appears twice
  error    unknown       a species with no evos_attacks/base_stats entry

Only TRAINERTYPE_MOVES / ITEM_MOVES parties carry explicit moves; NORMAL and
ITEM parties fill from the level-up learnset, so they get evolution checks only.

Usage:
  utils/trainer_lint.py                  # everything
  utils/trainer_lint.py --errors-only    # hide not-final warnings
  utils/trainer_lint.py --min-level 30   # not-final only at Lv.30 and up
  utils/trainer_lint.py --trainer FALKNER --trainer BUGSY
  utils/trainer_lint.py --suggest        # propose a legal fix for each error
  utils/trainer_lint.py --new-vs HEAD    # only findings HEAD doesn't have

Exits 1 when any error is reported.
"""

import argparse
import os
import re
import subprocess
import sys
from collections import Counter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PARTIES = 'data/trainers/parties.asm'
EVOS_FILES = [
	'data/pokemon/evos_attacks_kanto.asm',
	'data/pokemon/evos_attacks_johto.asm',
	'data/pokemon/evos_attacks_extra.asm',
]
# Files whose changes can change this linter's results.
WATCHED = re.compile(r'(^|/)data/(trainers/parties\.asm|pokemon/evos_attacks[^/]*\.asm'
                     r'|pokemon/base_stats(\.asm|/[^/]+\.asm)|pokemon/safari_move_tutor_moves\.asm)$'
                     r'|(^|/)engine/events/safari_move_tutor\.asm$')


class Source:
	"""Reads repo files from the working tree, or from a git ref."""

	def __init__(self, ref=None):
		self.ref = ref

	def read(self, path):
		if self.ref is None:
			with open(os.path.join(ROOT, path), encoding='utf-8') as f:
				return f.read()
		return subprocess.run(['git', 'show', f'{self.ref}:{path}'], cwd=ROOT,
		                      capture_output=True, text=True, check=True).stdout


def strip(line):
	return line.split(';', 1)[0].strip()


def args_of(line, op):
	return [a.strip() for a in line[len(op):].split(',')]


def species_order(src):
	"""Species constants in index order (stops at the Unown forms block)."""
	order = []
	for line in src.read('constants/pokemon_constants.asm').splitlines():
		s = strip(line)
		if s.startswith('const_def') and order:
			break
		m = re.match(r'const\s+(\w+)$', s)
		if m:
			order.append(m.group(1))
	return order


def parse_evos_attacks(src, species):
	labels = []
	bodies = {}
	cur = None
	for path in EVOS_FILES:
		for line in src.read(path).splitlines():
			s = strip(line)
			m = re.match(r'dw\s+(\w+EvosAttacks)$', s)
			if m:
				labels.append(m.group(1))
				continue
			m = re.match(r'(\w+EvosAttacks):', s)
			if m:
				cur = m.group(1)
				bodies[cur] = []
				continue
			if cur and s:
				bodies[cur].append(s)
	if len(labels) != len(species):
		sys.exit(f'evos pointer count {len(labels)} != species count {len(species)}')

	evos, learnset = {}, {}
	for sp, label in zip(species, labels):
		ev, ls = [], []
		gated = False
		in_evos = True
		for s in bodies[label]:
			if in_evos:
				if s == 'db 0':
					in_evos = False
				elif 'EVOLVE_REGION' in s or 'EVOLVE_LOCATION' in s:
					gated = True
				elif s.startswith('map_id'):
					pass
				else:
					op, rest = s.split(None, 1)
					a = [x.strip() for x in rest.split(',')]
					kind = a[0].replace('EVOLVE_', '')
					lvl = int(a[1]) if kind in ('LEVEL', 'STAT') else None
					ev.append({'kind': kind, 'level': lvl, 'into': a[-1], 'gated': gated,
					           'detail': a[1]})
					gated = False
			else:
				if s == 'db 0':
					break
				a = args_of(s, 'dbw')
				# LEARN_EVO_MOVE: learned on evolving into this species
				ls.append((0 if a[0] == 'LEARN_EVO_MOVE' else int(a[0]), a[1]))
		evos[sp], learnset[sp] = ev, ls
	return evos, learnset


def parse_tmhm(src, species):
	files = []
	for line in src.read('data/pokemon/base_stats.asm').splitlines():
		m = re.match(r'\s*INCLUDE\s+"(data/pokemon/base_stats/[^"]+)"', line)
		if m:
			files.append(m.group(1))
	if len(files) != len(species):
		sys.exit(f'base_stats count {len(files)} != species count {len(species)}')
	tmhm = {}
	for sp, path in zip(species, files):
		moves = set()
		for line in src.read(path).splitlines():
			s = strip(line)
			if s.startswith('tmhm'):
				moves |= {m for m in args_of(s, 'tmhm') if m}
		tmhm[sp] = moves
	return tmhm


def parse_safari_tutor(src):
	tutor = {}
	for line in src.read('data/pokemon/safari_move_tutor_moves.asm').splitlines():
		s = strip(line)
		if s.startswith('safari_tutor_move '):
			a = args_of(s, 'safari_tutor_move')
			tutor.setdefault(a[0], set()).add(a[1])
	return tutor


# Fixed-list tutors in engine/events/safari_move_tutor.asm: species list -> move.
LIST_TUTORS = {'OutrageTutorSpecies': 'OUTRAGE', 'ExtremespeedTutorSpecies': 'EXTREMESPEED'}


def parse_list_tutors(src, tutor):
	cur = None
	for line in src.read('engine/events/safari_move_tutor.asm').splitlines():
		s = strip(line)
		m = re.match(r'(\w+):$', s)
		if m:
			cur = LIST_TUTORS.get(m.group(1))
		elif cur and s.startswith('dw '):
			sp = s[3:].strip()
			if sp != '-1':
				tutor.setdefault(sp, set()).add(cur)
		elif s:
			cur = None if not s.startswith('dw') else cur
	return tutor


def parse_moves(src):
	"""MOVE -> (type, category, power), from the ;NAME comment on each row."""
	info = {}
	for line in src.read('data/moves/moves.asm').splitlines():
		if ';' not in line or not strip(line).startswith('move '):
			continue
		a = args_of(strip(line), 'move')
		name = line.split(';', 1)[1].split(',')[0].strip()
		info[name] = (a[2], a[3], int(a[1]))
	return info


def parse_parties(src):
	"""Trainer dicts: name, label, line, type, mons[{line, level, species, moves}]."""
	trainers = []
	tr = None
	mon = None
	lines = src.read(PARTIES).splitlines()
	for n, raw in enumerate(lines, 1):
		s = strip(raw)
		if not s:
			continue
		m = re.match(r'db\s+"([^"]*)@"\s*,\s*(.+)$', s)
		if m:
			prev = lines[n - 2]
			label = prev.split(';', 1)[1].strip() if 'next_list_item' in prev and ';' in prev else m.group(1)
			tr = {'name': m.group(1), 'label': label, 'line': n,
			      'type': m.group(2), 'mons': []}
			trainers.append(tr)
			mon = None
			continue
		if tr is None:
			continue
		if s == 'db -1':
			tr = None
			continue
		m = re.match(r'db\s+(\d+)$', s)
		if m:
			mon = {'line': n, 'level': int(m.group(1)), 'species': None, 'words': []}
			tr['mons'].append(mon)
			continue
		if mon is not None and s.startswith('dw'):
			words = args_of(s, 'dw')
			if mon['species'] is None:
				mon['species'] = words[0]
				mon['species_line'] = n
			else:
				mon['words'].append((n, words))
	for tr in trainers:
		has_item = 'ITEM' in tr['type']
		has_moves = 'MOVES' in tr['type']
		for mon in tr['mons']:
			rest = mon.pop('words')
			if has_item and rest:
				rest = rest[1:]
			mon['moves'] = None
			if has_moves and rest:
				mon['moves_line'] = rest[0][0]
				mon['moves'] = [w for _, ws in rest for w in ws]
	return trainers


class Dex:
	def __init__(self, src):
		self.species = species_order(src)
		self.evos, self.learnset = parse_evos_attacks(src, self.species)
		self.tmhm = parse_tmhm(src, self.species)
		self.tutor = parse_list_tutors(src, parse_safari_tutor(src))
		self.moves = parse_moves(src)
		self.prevos = {}
		for sp, ev in self.evos.items():
			for e in ev:
				self.prevos.setdefault(e['into'], []).append((sp, e))
		self._min = {}

	def min_level(self, sp):
		"""Lowest level at which sp can legally exist."""
		if sp not in self._min:
			self._min[sp] = 1
			best = None
			for pre, e in self.prevos.get(sp, []):
				lv = max(self.min_level(pre), e['level'] or 1)
				best = lv if best is None else min(best, lv)
			self._min[sp] = best or 1
		return self._min[sp]

	def line_of(self, sp, seen=None):
		"""sp and all of its pre-evolutions."""
		seen = seen if seen is not None else set()
		if sp in seen:
			return seen
		seen.add(sp)
		for pre, _ in self.prevos.get(sp, []):
			self.line_of(pre, seen)
		return seen

	def legal_moves(self, sp, level):
		ok = {}
		for s in self.line_of(sp):
			for lv, mv in self.learnset[s]:
				if lv <= level:
					ok.setdefault(mv, f'{s} Lv.{lv}')
			for mv in self.tmhm[s]:
				ok.setdefault(mv, f'{s} TM/HM')
			for mv in self.tutor.get(s, ()):
				ok.setdefault(mv, f'{s} Safari tutor')
		return ok

	def replacements(self, bad, legal, taken):
		"""Legal moves ranked by closeness to `bad`: type, category, then power."""
		btype, bcat, bpow = self.moves.get(bad, (None, None, 0))
		bstatus = bpow == 0

		def score(mv):
			t, c, p = self.moves.get(mv, (None, None, 0))
			if (p == 0) != bstatus:
				return None
			# power 1 = variable (Return, Seismic Toss...); call it 70
			gap = abs((70 if p == 1 else p) - (70 if bpow == 1 else bpow))
			return gap + 40 * (t != btype) + 15 * (c != bcat)

		ranked = sorted((s, mv) for mv in legal if mv not in taken
		                for s in [score(mv)] if s is not None)
		return [mv for _, mv in ranked]

	def describe(self, mv):
		t, c, p = self.moves.get(mv, ('?', '?', 0))
		return f'{mv} [{t.lower()} {c.lower()}{" " + str(p) if p else ""}]'


def lint(dex, trainers, opts, suggest=False):
	"""Return [(trainer, severity, code, where, message, suggestion)]."""
	found = []
	for tr in trainers:
		for mon in tr['mons']:
			sp, lvl = mon['species'], mon['level']
			where = f"{PARTIES}:{mon.get('species_line', mon['line'])}"
			tag = f'Lv.{lvl} {sp}'

			def add(sev, code, msg, fix=None, w=where):
				found.append((tr, sev, code, w, f'{tag}: {msg}', fix if suggest else None))

			if sp not in dex.evos:
				add('error', 'unknown', 'unknown species')
				continue

			need = dex.min_level(sp)
			if lvl < need:
				fix = f'raise to Lv.{need}'
				# the latest pre-evolution that is legal at this level
				pre = sorted((dex.min_level(p), p) for p in dex.line_of(sp)
				             if p != sp and dex.min_level(p) <= lvl)
				if pre:
					fix += f', or use {pre[-1][1]}'
				add('error', 'underleveled', f'can\'t exist below Lv.{need}', fix)

			due = [e for e in dex.evos[sp] if e['level'] is not None and not e['gated']
			       and lvl >= e['level']]
			if due:
				e = due[0]
				final = e['into']
				while True:  # Lv.52 Bulbasaur -> Venusaur, not Ivysaur
					nxt = [x for x in dex.evos.get(final, []) if x['level'] is not None
					       and not x['gated'] and lvl >= x['level']]
					if not nxt:
						break
					final = nxt[0]['into']
				add('error', 'should-evolve', f'evolves into {e["into"]} at Lv.{e["level"]}',
				    f'use {final} (moves stay legal)')
			elif dex.evos[sp] and lvl >= opts.min_level:
				how = ', '.join(sorted({
					f'{e["into"]} ({"Lv." + str(e["level"]) if e["level"] else e["kind"].lower() + " " + e["detail"]})'
					for e in dex.evos[sp]}))
				add('warning', 'not-final', f'not fully evolved -> {how}')

			if mon['moves'] is None:
				continue
			mwhere = f"{PARTIES}:{mon['moves_line']}"
			ok = dex.legal_moves(sp, lvl)
			moves = [m for m in mon['moves'] if m not in ('NO_MOVE', '0')]
			taken = {m for m in moves if m in ok}
			seen = set()
			for mv in moves:
				dup = mv in seen
				seen.add(mv)
				if not dup and mv in ok:
					continue
				fix = None
				if suggest:
					cands = dex.replacements(mv, ok, taken)
					if cands:
						taken.add(cands[0])
						fix = '-> ' + dex.describe(cands[0])
						if len(cands) > 1:
							fix += '  (alt: ' + ', '.join(cands[1:3]) + ')'
					else:
						fix = 'no unused legal move left'
				if dup:
					add('error', 'dup-move', f'{mv} listed twice', fix, mwhere)
					continue
				hint = ''
				later = [(lv, s) for s in dex.line_of(sp) for lv, m in dex.learnset[s] if m == mv]
				if later:
					lv, s = min(later)
					hint = f' (learns it at Lv.{lv}' + (f' as {s}' if s != sp else '') + ')'
				add('error', 'illegal-move', f'can\'t know {mv}{hint}', fix, mwhere)
	return found


def changed_files(ref):
	out = subprocess.run(['git', 'diff', '--name-only', ref, '--'], cwd=ROOT,
	                     capture_output=True, text=True, check=True).stdout.split()
	out += subprocess.run(['git', 'ls-files', '--others', '--exclude-standard', 'data/'],
	                      cwd=ROOT, capture_output=True, text=True, check=True).stdout.split()
	return out


def main():
	ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
	ap.add_argument('--errors-only', action='store_true', help='hide warnings')
	ap.add_argument('--min-level', type=int, default=0,
	                help='only warn not-final at this level or above')
	ap.add_argument('--trainer', action='append', help='only this trainer name (repeatable)')
	ap.add_argument('--suggest', action='store_true', help='propose a legal fix for each error')
	ap.add_argument('--new-vs', metavar='REF',
	                help='only report findings REF does not already have; '
	                     'does nothing if no watched file differs from REF')
	opts = ap.parse_args()

	src = Source()
	if opts.new_vs and not any(WATCHED.search(f) for f in changed_files(opts.new_vs)):
		return 0

	def run(s, suggest):
		trs = parse_parties(s)
		if opts.trainer:
			wanted = {t.upper() for t in opts.trainer}
			trs = [t for t in trs if t['name'].upper() in wanted]
		return lint(Dex(s), trs, opts, suggest)

	found = run(src, opts.suggest)
	if opts.errors_only:
		found = [f for f in found if f[1] != 'warning']
	if opts.new_vs:
		old = Counter((f[0]['label'], f[2], f[4]) for f in run(Source(opts.new_vs), False))
		fresh = []
		for f in found:
			k = (f[0]['label'], f[2], f[4])
			if old[k]:
				old[k] -= 1
			else:
				fresh.append(f)
		found = fresh

	errors = warnings = 0
	last = None
	for tr, sev, code, where, msg, fix in found:
		if tr is not last:
			print(f"{tr['label']}  ({PARTIES}:{tr['line']})")
			last = tr
		print(f'  {where}: {sev} {code}: {msg}')
		if fix:
			print(f'      fix: {fix}')
		if sev == 'error':
			errors += 1
		else:
			warnings += 1

	if found or not opts.new_vs:
		print(f'\n{errors} error(s), {warnings} warning(s)'
		      + (f' new vs {opts.new_vs}' if opts.new_vs else ''))
	return 1 if errors else 0


if __name__ == '__main__':
	sys.exit(main())

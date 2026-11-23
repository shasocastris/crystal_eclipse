#!/usr/bin/env python3
"""Flag trainer Pokémon with two or more damaging moves of the same type.

Status moves are ignored, and so is HIDDEN_POWER (its type comes from DVs).

Findings:
  error    dup-type   an explicit moveset (TRAINERTYPE_MOVES / ITEM_MOVES)
  warning  dup-type   an auto-filled moveset (NORMAL / ITEM), simulated like
                      FillMoves: the last four distinct level-up moves at or
                      below the mon's level, evolution moves included.
                      Fixing one means switching the party to explicit moves.

Usage:
  utils/move_type_lint.py                  # everything
  utils/move_type_lint.py --errors-only    # explicit movesets only
  utils/move_type_lint.py --suggest        # propose a legal move of a new type
  utils/move_type_lint.py --new-vs HEAD    # only findings HEAD doesn't have
  utils/move_type_lint.py --trainer FALKNER

Exits 1 when any error is reported.
"""

import argparse
import sys
from collections import Counter

from trainer_lint import PARTIES, WATCHED, Dex, Source, changed_files, parse_parties

VARIABLE_TYPE = {'HIDDEN_POWER'}


def autofill(dex, sp, lvl):
	moves = []
	for lv, mv in dex.learnset[sp]:
		if lv > lvl:
			break
		if mv in moves:
			continue
		if len(moves) == 4:
			moves.pop(0)
		moves.append(mv)
	return moves


def damaging(dex, mv):
	return mv not in VARIABLE_TYPE and dex.moves.get(mv, (None, None, 0))[2] > 0


def suggest(dex, sp, lvl, moves, drop):
	"""Legal damaging move of a type the set doesn't hit yet, closest to `drop`."""
	_, dcat, dpow = dex.moves[drop]
	have = {dex.moves[m][0] for m in moves if m != drop and damaging(dex, m)}
	cands = []
	for mv in dex.legal_moves(sp, lvl):
		if mv in moves or not damaging(dex, mv):
			continue
		t, c, p = dex.moves[mv]
		if t in have or t == dex.moves[drop][0]:
			continue
		p = 70 if p == 1 else p
		cands.append((abs(p - (70 if dpow == 1 else dpow)) + 15 * (c != dcat), mv))
	return [mv for _, mv in sorted(cands)]


def lint(dex, trainers, want_suggest):
	found = []
	for tr in trainers:
		for mon in tr['mons']:
			sp, lvl = mon['species'], mon['level']
			if sp not in dex.evos:
				continue
			explicit = mon['moves'] is not None
			moves = [m for m in (mon['moves'] if explicit else autofill(dex, sp, lvl))
			         if m not in ('NO_MOVE', '0')]
			by_type = {}
			for mv in moves:
				if damaging(dex, mv):
					by_type.setdefault(dex.moves[mv][0], []).append(mv)
			line = mon['moves_line'] if explicit else mon.get('species_line', mon['line'])
			for t, mvs in by_type.items():
				if len(mvs) < 2:
					continue
				desc = ', '.join(f'{m} {dex.moves[m][2]}' for m in mvs)
				msg = f'Lv.{lvl} {sp}: {len(mvs)} {t.lower()} moves ({desc})'
				if not explicit:
					msg += ' [auto-filled]'
				fix = None
				if want_suggest:
					drop = min(mvs, key=lambda m: dex.moves[m][2])
					c = suggest(dex, sp, lvl, moves, drop)
					fix = (f'replace {drop} -> {dex.describe(c[0])}'
					       + (f'  (alt: {", ".join(c[1:3])})' if len(c) > 1 else '')
					       if c else f'no legal damaging move of another type for {drop}')
				found.append((tr, 'error' if explicit else 'warning', f'{PARTIES}:{line}', msg, fix))
	return found


def main():
	ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
	ap.add_argument('--errors-only', action='store_true', help='explicit movesets only')
	ap.add_argument('--suggest', action='store_true', help='propose a replacement move')
	ap.add_argument('--trainer', action='append', help='only this trainer name (repeatable)')
	ap.add_argument('--new-vs', metavar='REF',
	                help='only report findings REF does not already have; '
	                     'does nothing if no watched file differs from REF')
	opts = ap.parse_args()

	if opts.new_vs and not any(WATCHED.search(f) for f in changed_files(opts.new_vs)):
		return 0

	def run(src, sug):
		trs = parse_parties(src)
		if opts.trainer:
			wanted = {t.upper() for t in opts.trainer}
			trs = [t for t in trs if t['name'].upper() in wanted]
		found = lint(Dex(src), trs, sug)
		return [f for f in found if not (opts.errors_only and f[1] == 'warning')]

	found = run(Source(), opts.suggest)
	if opts.new_vs:
		old = Counter((f[0]['label'], f[3]) for f in run(Source(opts.new_vs), False))
		fresh = []
		for f in found:
			k = (f[0]['label'], f[3])
			if old[k]:
				old[k] -= 1
			else:
				fresh.append(f)
		found = fresh

	errors = warnings = 0
	last = None
	for tr, sev, where, msg, fix in found:
		if tr is not last:
			print(f"{tr['label']}  ({PARTIES}:{tr['line']})")
			last = tr
		print(f'  {where}: {sev} dup-type: {msg}')
		if fix:
			print(f'      fix: {fix}')
		errors += sev == 'error'
		warnings += sev == 'warning'

	if found or not opts.new_vs:
		print(f'\n{errors} error(s), {warnings} warning(s)'
		      + (f' new vs {opts.new_vs}' if opts.new_vs else ''))
	return 1 if errors else 0


if __name__ == '__main__':
	sys.exit(main())

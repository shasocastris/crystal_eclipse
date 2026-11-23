#!/usr/bin/env python3
"""List pre-evolution level-up moves an evolved form drops or delays.

Compares each species' level-up learnset (data/pokemon/evos_attacks_*.asm)
with every pre-evolution's. This is a review list, not a pass/fail check:
plenty of gaps are deliberate, so every finding needs a human call.

Findings:
  missing   the pre-evo learns it by level-up; the evolved form can't learn
            it at all (not level-up, TM/HM/tutor or Safari tutor)
  tm-only   the evolved form only gets it from a TM/HM/tutor
  later     the evolved form learns it at a higher level than the pre-evo
            (only gaps of --min-delta levels or more; default 10)

Usage:
  utils/learnset_lint.py                     # everything
  utils/learnset_lint.py --only missing      # one kind (repeatable)
  utils/learnset_lint.py --min-delta 1       # every `later`, however small
  utils/learnset_lint.py --species BUTTERFREE --species BEEDRILL

Always exits 0.
"""

import argparse
import re
import sys

from trainer_lint import Dex, EVOS_FILES, Source


def label_lines(src, species):
	"""species -> 'file:line' of its *EvosAttacks label."""
	order, where = [], {}
	for path in EVOS_FILES:
		for n, line in enumerate(src.read(path).splitlines(), 1):
			m = re.match(r'\s*dw\s+(\w+EvosAttacks)\b', line)
			if m:
				order.append(m.group(1))
			m = re.match(r'(\w+EvosAttacks):', line)
			if m:
				where[m.group(1)] = f'{path}:{n}'
	return {sp: where.get(lbl, '?') for sp, lbl in zip(species, order)}


def lvl_str(lv):
	return 'evo' if lv == 0 else f'Lv.{lv}'


def main():
	ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
	ap.add_argument('--only', action='append', choices=['missing', 'tm-only', 'later'])
	ap.add_argument('--min-delta', type=int, default=10,
	                help='report `later` only when this many levels later (default 10)')
	ap.add_argument('--species', action='append', help='only this evolved species (repeatable)')
	opts = ap.parse_args()

	src = Source()
	dex = Dex(src)
	where = label_lines(src, dex.species)
	kinds = set(opts.only or ['missing', 'tm-only', 'later'])
	wanted = {s.upper() for s in opts.species} if opts.species else None

	counts = {'missing': 0, 'tm-only': 0, 'later': 0}
	for sp in dex.species:
		ancestors = dex.line_of(sp) - {sp}
		if not ancestors or (wanted and sp not in wanted):
			continue
		mine = {}
		for lv, mv in dex.learnset[sp]:
			mine.setdefault(mv, lv)
		other = dex.tmhm[sp] | dex.tutor.get(sp, set())

		# move -> earliest (level, ancestor); nearest-to-earliest is what matters
		pre = {}
		for anc in ancestors:
			for lv, mv in dex.learnset[anc]:
				if mv not in pre or lv < pre[mv][0]:
					pre[mv] = (lv, anc)

		out = []
		for mv, (plv, anc) in sorted(pre.items(), key=lambda x: (x[1][0], x[0])):
			if mv in mine:
				# an evolution move (level 0) counts as Lv.1
				delta = max(mine[mv], 1) - max(plv, 1)
				if delta >= opts.min_delta:
					out.append(('later', f'{mv}: {anc} {lvl_str(plv)}, {sp} {lvl_str(mine[mv])} '
					                     f'(+{delta})'))
			elif mv in other:
				out.append(('tm-only', f'{mv}: {anc} {lvl_str(plv)}, {sp} TM/HM/tutor only'))
			else:
				out.append(('missing', f'{mv}: {anc} {lvl_str(plv)}, {sp} can\'t learn it'))

		out = [o for o in out if o[0] in kinds]
		if out:
			anc_s = ', '.join(sorted(ancestors))
			print(f'{sp}  <- {anc_s}  ({where[sp]})')
			for kind, msg in out:
				print(f'  {kind:8} {msg}')
				counts[kind] += 1

	print('\n' + ', '.join(f'{v} {k}' for k, v in counts.items() if k in kinds))
	return 0


if __name__ == '__main__':
	sys.exit(main())

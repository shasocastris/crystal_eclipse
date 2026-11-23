"""Coverage matrix: what each species can learn, per type and category, through
which channel, now and under docs/movepool/proposal.py.

  matrix.py SPECIES...      type x category grid (best move, power, channel)
  matrix.py --gaps          per final form: lean, STAB, coverage count, party intent
  matrix.py --move MOVE     who learns MOVE and how
  --now                     ignore the proposal
"""
import sys, re
from pathlib import Path
from collections import defaultdict
sys.path.insert(0, 'utils'); sys.path.insert(0, 'docs/movepool')
from trainer_lint import Source, Dex, parse_parties
import proposal as P

src = Source(); dex = Dex(src)
args = sys.argv[1:]
NOW = '--now' in args

# ---- channels
CH = {}
for l in Path('constants/item_constants.asm').read_text().splitlines():
    m = re.match(r'\s*add_(tm|hm|mt)\s+(\w+)', l)
    if m: CH[m.group(2)] = m.group(1).upper()

def stats(sp):
    t = Path(f'data/pokemon/base_stats/{sp.lower()}.asm').read_text()
    st = [int(x) for x in re.search(r'db\s+(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+)', t).groups()]
    ty = re.search(r'db (\w+), (\w+) ; type', t).groups()
    return st, set(ty)

def line_of(sp):  # sp + prevos + evolutions (whole family)
    fam = set(dex.line_of(sp))
    frontier = list(fam)
    while frontier:
        s = frontier.pop()
        for e in dex.evos.get(s, []):
            if e['into'] not in fam: fam.add(e['into']); frontier.append(e['into'])
    return fam

def levelup_learners(move):
    out = set()
    for sp in dex.species:
        if any(m == move for s in dex.line_of(sp) for _, m in dex.learnset[s]): out.add(sp)
    return out

# ---- compat (tm/hm/tutor), with proposal applied
compat = {sp: set(dex.tmhm[sp]) for sp in dex.species}
if not NOW:
    channel_of_new = {}
    for old, new in P.TM_SWAPS.items():
        for sp in compat: compat[sp].discard(old)
        CH[new] = 'TM'; CH.pop(old, None)
    for mv in P.TUTOR_DROP:
        for sp in compat: compat[sp].discard(mv)
        CH.pop(mv, None)
    for mv in P.TUTOR_ADD: CH[mv] = 'MT'
    for mv, who in list(P.GRANTS.items()) + list(P.EXTRA.items()):
        for w in who:
            if w.endswith('!'):
                if w[:-1] not in dex.species: sys.exit(f'unknown species {w} for {mv}')
                compat[w[:-1]].add(mv); continue
            targets = levelup_learners(mv) if w == 'LEVELUP' else (dex.line_of(w) if w in dex.species else None)
            if targets is None: sys.exit(f'unknown species {w} for {mv}')
            for sp in targets:
                # evolutions inherit: grant the final and everything after w in the line
                compat[sp].add(mv)
            if w != 'LEVELUP':
                for sp in line_of(w):
                    if w in dex.line_of(sp): compat[sp].add(mv)

def pool(sp):
    """move -> channel label (best channel)."""
    out = {}
    for s in dex.line_of(sp):
        for lv, mv in dex.learnset[s]:
            out.setdefault(mv, f'L{lv}' if s == sp else f'L{lv}*')
        for mv in compat[s]:
            out.setdefault(mv, CH.get(mv, '?'))
        for mv in dex.tutor.get(s, ()):
            out.setdefault(mv, 'Safari')
    return out

def damaging(mv):
    t, c, p = dex.moves.get(mv, (None, None, 0))
    return p > 1

TYPES = ['NORMAL', 'FIGHTING', 'FLYING', 'POISON', 'GROUND', 'ROCK', 'BUG', 'GHOST', 'STEEL',
         'FIRE', 'WATER', 'GRASS', 'ELECTRIC', 'PSYCHIC_TYPE', 'ICE', 'DRAGON', 'DARK', 'FAIRY']

def best(pl, ty, cat):
    c = [(dex.moves[m][2], m) for m in pl if damaging(m) and dex.moves[m][0] == ty and dex.moves[m][1] == cat]
    return max(c) if c else None

def lean(st):
    a, s = st[1], st[4]
    return 'PHYSICAL' if a - s > 10 else 'SPECIAL' if s - a > 10 else 'MIXED'

def grid(sp):
    st, ty = stats(sp); pl = pool(sp)
    print(f"\n{sp}  {'/'.join(sorted(t.lower() for t in ty))}  Atk {st[1]} / SpA {st[4]}  ({lean(st).lower()})")
    print(f"  {'type':<9} {'physical':<28} {'special':<28}")
    for t in TYPES:
        cells = []
        for c in ('PHYSICAL', 'SPECIAL'):
            b = best(pl, t, c)
            cells.append(f"{b[1]} {b[0]} {pl[b[1]]}" if b else '-')
        mark = '*' if t in ty else ' '
        print(f" {mark}{t.replace('_TYPE','').lower():<9} {cells[0]:<28} {cells[1]:<28}")

# ---- party intent: wrong-category attacks trainers gave this species
KEEP = set('''THIEF SELFDESTRUCT EXPLOSION ROLLOUT RAPID_SPIN SUPER_FANG SEISMIC_TOSS NIGHT_SHADE
DRAGON_RAGE SONICBOOM FALSE_SWIPE FURY_CUTTER REVERSAL FLAIL COUNTER MIRROR_COAT PRESENT RETURN
FRUSTRATION HIDDEN_POWER BIND WRAP FIRE_SPIN WHIRLPOOL CLAMP ICY_WIND MUD_SLAP PURSUIT
QUICK_ATTACK EXTREMESPEED MACH_PUNCH ICE_SHARD HYPER_BEAM'''.split())
intent = defaultdict(set)
for tr in parse_parties(src):
    for m in tr['mons']:
        if m['moves']: intent[m['species']] |= set(m['moves'])

def gaps():
    rows = []
    for sp in dex.species:
        if dex.evos.get(sp): continue
        try: st, ty = stats(sp)
        except Exception: continue
        ln = lean(st); pl = pool(sp)
        cats = ['PHYSICAL', 'SPECIAL'] if ln == 'MIXED' else [ln]
        stab = max((best(pl, t, c) or (0, '-')) for t in ty for c in cats)
        cov = sorted({t for t in TYPES if t not in ty for c in cats if (best(pl, t, c) or (0,))[0] >= 70})
        wrong = []
        for mv in sorted(intent.get(sp, ())):
            if mv in KEEP or not damaging(mv): continue
            t, c, p = dex.moves[mv]
            if ln != 'MIXED' and c != ln:
                b = best(pl, t, ln)
                wrong.append(f"{mv}->{b[1] if b else 'none'}")
        rows.append((sp, ln, stab, cov, wrong))
    for sp, ln, stab, cov, wrong in rows:
        flag = '!' if stab[0] < 70 else ' '
        print(f"{flag}{sp:<15} {ln[:4].lower():<5} STAB {stab[1]} {stab[0]:<4} cov {len(cov):>2}"
              + (f"  party: {', '.join(wrong)}" if wrong else ''))

def who(move):
    rows = defaultdict(list)
    for sp in dex.species:
        ch = pool(sp).get(move)
        if ch: rows[ch if not ch.startswith('L') else 'level-up'].append(sp)
    for ch, sps in rows.items():
        print(f"{ch} ({len(sps)}): {' '.join(sps)}")

if '--gaps' in args: gaps()
elif '--move' in args: who(args[args.index('--move') + 1])
else:
    for sp in [a for a in args if not a.startswith('--')]: grid(sp)

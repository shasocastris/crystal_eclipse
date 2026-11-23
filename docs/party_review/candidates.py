"""Propose replacements for illegal / wrong-category moves in explicit-move parties."""
import sys
sys.path.insert(0, 'docs/party_review'); sys.argv = [sys.argv[0]]
from view import dex, stats, parse_parties, src

KEEP = set('''THIEF SELFDESTRUCT EXPLOSION ROLLOUT RAPID_SPIN SUPER_FANG SEISMIC_TOSS NIGHT_SHADE
DRAGON_RAGE SONICBOOM FALSE_SWIPE FURY_CUTTER REVERSAL FLAIL COUNTER MIRROR_COAT PRESENT RETURN
FRUSTRATION HIDDEN_POWER BIND WRAP FIRE_SPIN WHIRLPOOL CLAMP ICY_WIND MUD_SLAP PURSUIT
QUICK_ATTACK EXTREMESPEED MACH_PUNCH ICE_SHARD'''.split())

def pow_(m): return dex.moves.get(m, (0, 0, 0))[2]

for tr in parse_parties(src):
    for mon in tr['mons']:
        sp, lv, mv = mon['species'], mon['level'], mon['moves']
        if not mv: continue
        st, ty = stats(sp)
        types = set(ty or ())
        legal = dex.legal_moves(sp, lv)
        a, s = st[1], st[4]
        lean = 'PHYSICAL' if a > s else 'SPECIAL'
        diff = abs(a - s)
        out = []
        for m in mv:
            t, c, p = dex.moves.get(m, ('?', '?', 0))
            illegal = m not in legal
            stab = t in types
            wrong = p > 1 and c != lean and m not in KEEP and (diff > 25 or (stab and diff > 15))
            if lean == 'PHYSICAL' and m == 'HYPER_BEAM' and 'LANCE' in tr['label']: wrong = False
            if not (illegal or wrong): continue
            pool = [x for x in legal if x not in mv and pow_(x) > 1 and dex.moves[x][1] == lean]
            same = sorted((x for x in pool if dex.moves[x][0] == t), key=pow_, reverse=True)
            stabs = sorted((x for x in pool if dex.moves[x][0] in types), key=pow_, reverse=True)
            other = sorted(pool, key=pow_, reverse=True)
            sug = same[:2] or (stabs[:1] + other[:3])
            out.append(f"{m}{'(ILL)' if illegal else ''} -> {'/'.join(sug) or '?'}")
        if out:
            print(f"{tr['label'][:30]:<30} L{lv:<3}{sp:<11}{lean[:4]} {a}/{s} | {' ; '.join(out)}")

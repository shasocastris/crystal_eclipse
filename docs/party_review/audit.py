"""Flag explicit-move party mons: illegal moves, wrong-category attacks, overdue evolutions."""
import sys, re
sys.path.insert(0, 'docs/party_review'); sys.argv = [sys.argv[0]]
from view import dex, stats, parse_parties, src

for tr in parse_parties(src):
    for mon in tr['mons']:
        sp, lv, mv = mon['species'], mon['level'], mon['moves']
        flags = []
        st, ty = stats(sp)
        if mv:
            legal = dex.legal_moves(sp, lv)
            bad = [m for m in mv if m not in legal]
            if bad: flags.append('illegal ' + ','.join(bad))
            if st:
                a, s = st[1], st[4]
                lean = 'PHYSICAL' if a - s > 15 else 'SPECIAL' if s - a > 15 else None
                if lean:
                    wrong = [m for m in mv if dex.moves.get(m, (0, 0, 0))[2] > 1 and dex.moves[m][1] not in (lean, 'STATUS')]
                    if wrong: flags.append(f'wrongcat({lean[:4].lower()} {a}/{s}) ' + ','.join(f"{m}:{dex.moves[m][0].lower()[:4]}" for m in wrong))
        for e in dex.evos.get(sp, []):
            if (e['level'] and lv >= e['level'] + 10) or (not e['level'] and lv >= 50):
                flags.append(f"overdue->{e['into']}"); break
        if flags:
            print(f"{tr['label'][:34]:<34} Lv{lv:<3}{sp:<11} {'; '.join(flags)}")

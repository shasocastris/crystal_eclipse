"""Annotated view of trainer parties: python3 docs/party_review/view.py GROUP_OR_LABEL_PREFIX..."""
import sys, re
from pathlib import Path
sys.path.insert(0, 'utils')
from trainer_lint import Source, Dex, parse_parties, PARTIES

src = Source(); dex = Dex(src)

def stats(sp):
    p = Path(f'data/pokemon/base_stats/{sp.lower()}.asm')
    if not p.exists(): return None, None
    t = p.read_text()
    st = [int(x) for x in re.search(r'db\s+(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+)', t).groups()]
    ty = re.search(r'db (\w+), (\w+) ; type', t).groups()
    return st, ty

def groups():
    """label -> group name, from the *Group: labels in parties.asm."""
    out, g = {}, None
    for line in Path(PARTIES).read_text().splitlines():
        m = re.match(r'(\w+)Group:', line)
        if m: g = m.group(1)
        m = re.search(r'next_list_item ; (.*)', line)
        if m and g: out[m.group(1).strip()] = g
    return out

def items_of(tr):
    lines = Path(PARTIES).read_text().splitlines()
    res = []
    for mon in tr['mons']:
        it = lines[mon['species_line']].strip()  # line after species (0-based = species_line)
        res.append(it.split()[1] if 'ITEM' in tr['type'] and it.startswith('dw') else '')
    return res

def show(tr):
    print(f"\n== {tr['label']}  [{tr['type'].replace('TRAINERTYPE_', '')}]  parties.asm:{tr['line']}")
    for mon, item in zip(tr['mons'], items_of(tr)):
        sp, lv = mon['species'], mon['level']
        st, ty = stats(sp)
        lean = ''
        if st:
            a, s = st[1], st[4]
            lean = 'phys' if a - s > 10 else 'spec' if s - a > 10 else 'mixed'
            lean = f"Atk {a}/SpA {s} {lean}"
        types = '/'.join(dict.fromkeys(t.lower() for t in ty)) if ty else '?'
        fin = '' if not dex.evos.get(sp) else '  (not final)'
        print(f"  Lv{lv:<3} {sp:<12} {types:<16} {lean:<24} {item}{fin}")
        legal = dex.legal_moves(sp, lv)
        if mon['moves']:
            print('        ' + ', '.join(dex.describe(m) + ('' if m in legal else ' !ILLEGAL') for m in mon['moves']))
        else:
            ls = [m for l, m in dex.learnset[sp] if l <= lv][-4:]
            print('        (auto) ' + ', '.join(dex.describe(m) for m in ls))
        if '-v' in sys.argv:
            best = {}
            for m in legal:
                t, c, p = dex.moves.get(m, ('?', '?', 0))
                if p > 1: best.setdefault(c, []).append((p, m, t))
            for c in ('PHYSICAL', 'SPECIAL'):
                top = sorted(best.get(c, []), reverse=True)[:8]
                print(f"        best {c.lower()[:4]}: " + ', '.join(f"{m} {t.lower()[:4]} {p}" for p, m, t in top))

args = [a for a in sys.argv[1:] if not a.startswith('-')]
gmap = groups()
for tr in parse_parties(src):
    if any(tr['label'].startswith(a) or gmap.get(tr['label']) == a for a in args):
        show(tr)

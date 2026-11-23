import re, sys
sys.path.insert(0, "utils")
from trainer_lint import Source, Dex, parse_parties
TYPE = sys.argv[1]
src = Source(); dex = Dex(src); trainers = parse_parties(src)
tm = {}
for l in open("constants/item_constants.asm"):
    m = re.match(r"\s*add_(tm|hm|mt)\s+(\w+)", l)
    if m: tm[m.group(2)] = m.group(1).upper()
bt = open("data/battle_tower/parties.asm").read()
cur = None
for l in open("data/moves/moves.asm"):
    if re.match(r"\t; \w+$", l): cur = l.strip()[2:]
    m = re.match(r"\tmove (\w+),\s*(\d+),\s*(\w+),\s*(\w+),\s*(\d+),\s*(\d+),\s*(\d+).*;(\w+)", l)
    if not m or cur != TYPE: continue
    eff, pw, ty, cat, acc, pp, ch, name = m.groups()
    lv = [sp for sp in dex.species if any(mv == name for _, mv in dex.learnset[sp])]
    tmn = sum(name in dex.tmhm[sp] for sp in dex.species)
    tut = [sp for sp, s in dex.tutor.items() if name in s]
    par = sum(1 for tr in trainers for mo in tr['mons'] if mo['moves'] and name in mo['moves'])
    btn = len(re.findall(r"\b%s\b" % name, bt))
    print(f"{name:14} {ty:8} {cat:8} {pw:>3} {acc:>3}% {pp:>2}pp {eff.replace('EFFECT_',''):22} {ch:>3}% | lvl {len(lv):3} {tm.get(name,''):2} {tmn if tm.get(name) else '':>3} tut {len(tut)} | parties {par:3} bt {btn}")

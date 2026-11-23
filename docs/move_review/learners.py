import sys, re
sys.path.insert(0, "utils")
from trainer_lint import Source, Dex, parse_parties
src = Source(); dex = Dex(src); trainers = parse_parties(src)
files = [m.group(1) for m in re.finditer(r'INCLUDE\s+"(data/pokemon/base_stats/[^"]+)"', src.read("data/pokemon/base_stats.asm"))]
types = {sp: re.search(r"db (\w+), (\w+) ; type", src.read(p)).groups() for sp, p in zip(dex.species, files)}
for mv in sys.argv[1:]:
    print(f"## {mv}")
    for sp in dex.species:
        lv = [l for l, m in dex.learnset[sp] if m == mv]
        if lv or mv in dex.tmhm[sp] or mv in dex.tutor.get(sp, set()):
            other = [f"{m}@{l}" for l, m in dex.learnset[sp] if m != mv and dex.moves.get(m, ("",))[0] == "POISON" and dex.moves[m][1] == "PHYSICAL"]
            print(f"  {sp:12} {'/'.join(dict.fromkeys(types[sp])):16} lv {lv} {'TM' if mv in dex.tmhm[sp] else ''} poison-phys: {other}")
    print("  parties:", [f"{t['label']}:{m['species']}" for t in trainers for m in t['mons'] if m['moves'] and mv in m['moves']])

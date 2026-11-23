import sys, json
sys.path.insert(0, sys.argv[1])
from mvlib import const_order, TABLES, rd
names = [n for n, _ in const_order()]
out = {}
for t in TABLES[1:]:
    ent = t.entries()
    assert len(ent) == len(names), (t.kind, len(ent), len(names))
    for n, (p, ln) in zip(names, ent):
        out.setdefault(n, {})[t.kind] = rd(p)[ln].strip()
for n, d in out.items():
    # moves row must name itself
    assert d["moves"].split(";")[1].split(",")[0].strip() == n, (n, d["moves"])
print(json.dumps(out, indent=0, sort_keys=True))

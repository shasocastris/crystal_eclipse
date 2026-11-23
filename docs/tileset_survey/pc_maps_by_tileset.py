import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import re,collections,sys
R=f'{_ROMHACKS}/polishedcrystal/'
order=[m.group(1) for m in re.finditer(r'^\s*const (TILESET_\w+)',open(R+'constants/tileset_constants.asm').read(),re.M)]
d=collections.defaultdict(list)
for m in re.finditer(r'^\s*map (\w+), (TILESET_\w+), (\w+), \w+, (\w+)',open(R+'data/maps/maps.asm').read(),re.M):
    d[m.group(2)].append((m.group(1),m.group(3),m.group(4)))
for t in order:
    ms=d[t]
    env=collections.Counter(e for _,e,_ in ms)
    print(f"\n## {t[8:]} — {len(ms)} maps ({', '.join(f'{k} {v}' for k,v in env.items())})")
    print(', '.join(n for n,_,_ in ms))

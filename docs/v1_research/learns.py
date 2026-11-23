import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import re,sys,glob
R=f'{_REPO_ROOT}'
def camel(sp): return sp.title().replace('_','')
lv={}
for f in glob.glob(f'{R}/data/pokemon/evos_attacks_*.asm'):
    cur=None
    for l in open(f):
        m=re.match(r'(\w+)EvosAttacks:',l)
        if m: cur=m.group(1).lower(); lv[cur]=set(); continue
        m=re.match(r'\s*learnset\s+\d+,\s*(\w+)',l) or re.match(r'\s*db\s+\d+,\s*(\w+)',l) or re.match(r'\s*dbw\s+\d+,\s*(\w+)',l)
        if m and cur: lv[cur].add(m.group(1))
def tm(sp):
    for l in open(f'{R}/data/pokemon/base_stats/{sp.lower()}.asm'):
        if l.strip().startswith('tmhm'): return set(x.strip() for x in l.strip()[4:].split(','))
    return set()
pp={}
for l in open(f'{R}/data/moves/moves.asm'):
    m=re.match(r'\s*move\s+\w+,\s*\d+,\s*\w+,\s*\w+,\s*\d+,\s*(\d+).*;\s*(\w+)',l)
    if m: pp[m.group(2)]=int(m.group(1))
sp=sys.argv[1]
L=lv.get(sp.lower().replace('_',''),set()); T=tm(sp)
print(sp,'level:',sorted(L)); print('tm:',sorted(T))
for mv in sys.argv[2:]: print(mv, 'LV' if mv in L else '', 'TM' if mv in T else '', pp.get(mv))

import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import re,sys
sys.path.insert(0,'/tmp/claude-1000/-home-bryan-Documents-Romhacks-crystal-eclipse/2d70e333-cae6-412c-bf2d-cf4827cd6419/scratchpad')
import btstats
R=f'{_REPO_ROOT}'
pp={}
for l in open(f'{R}/data/moves/moves.asm'):
    m=re.match(r'\s*move\s+\w+,\s*\d+,\s*\w+,\s*\w+,\s*\d+,\s*(\d+).*;\s*(\w+)',l)
    if m: pp[m.group(2)]=int(m.group(1))
REPL={2274:('AMPHAROS',['THUNDERBOLT','FIRE_PUNCH','THUNDER_WAVE','HYPER_BEAM']),
      2412:('MAMOSWINE',['BLIZZARD','HYPER_BEAM','EARTHQUAKE','ICY_WIND']),
      2553:('LANTURN',['REST','SURF','THUNDERBOLT','THUNDER_WAVE']),
      3085:('ELECTIVIRE',['THUNDERBOLT','CROSS_CHOP','BODY_SLAM','HYPER_BEAM']),
      3732:('CHARIZARD',['FLAMETHROWER','AIR_SLASH','STEEL_WING','HYPER_BEAM'])}
p=f'{R}/data/battle_tower/parties.asm'
L=open(p).read().split('\n')
for ln,sp,evs,dvs,lvl,st in btstats.entries():
    if ln not in REPL: continue
    i=ln-1; new,mv=REPL[ln]
    st=btstats.calc(btstats.base(new),dvs,evs,lvl)
    L[i]=f'\tdw {new}'
    L[i+2]='\tdw '+', '.join(mv)
    L[i+9]='\tdb '+', '.join(str(pp[m]) for m in mv)+' ; PP'
    L[i+14]=f'\tbigdw {st[0]} ; HP'
    for k,(v,n) in enumerate(zip(st,['Max HP','Atk','Def','Spd','SAtk','SDef'])):
        L[i+15+k]=f'\tbigdw {v} ; {n}'
    assert L[i+21].startswith('\tdname'), L[i+21]
    L[i+21]=f'\tdname "{new}", MON_NAME_LENGTH'
    print(ln,new,st)
open(p,'w').write('\n'.join(L))

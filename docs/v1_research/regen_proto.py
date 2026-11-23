#!/usr/bin/env python3
"""Prototype: reorder move constants by type via slot substitution.
Reads repo, writes rewritten copies to ./out (never touches the repo)."""
import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import re,os
R=f'{_REPO_ROOT}/'
OUT=os.path.dirname(os.path.abspath(__file__))+'/out/'
def lines(p): return open(R+p).read().split('\n')
# 1. constants: entry slots = 'const X' lines between const_def and GEN2_MOVES
mc=lines('constants/move_constants.asm')
cslots=[];C=[]
for i,l in enumerate(mc):
    if re.match(r'DEF GEN2_MOVES',l): break
    m=re.match(r'\s*const\s+(\w+)',l)
    if m: cslots.append(i);C.append(m.group(1))
N=len(C)-1
# positional tables: (path, slot regex, first index)
T=[('data/moves/moves.asm',r'\s*move\s',1),
   ('data/moves/names.asm',r'\s*li\s+"',1),
   ('data/moves/descriptions.asm',r'\s*dw\s+\w+Description\b',1),
   ('data/moves/animations_gen1.asm',r'\s*anim_ptr\s',0),
   ('data/moves/animations_gen2.asm',r'\s*anim_ptr\s',None)]
rows={};files={}
k0=0
for p,rx,first in T:
    L=lines(p);sl=[i for i,l in enumerate(L) if re.match(rx,l)]
    files[p]=(L,sl)
anim=files['data/moves/animations_gen1.asm'][1]+[None]
# entries per move name
ent={n:{} for n in C}
for p,rx,first in T[:3]:
    L,sl=files[p]; assert len(sl)==N,(p,len(sl))
    for j,i in enumerate(sl): ent[C[j+1]][p]=L[i]
aL1,s1=files['data/moves/animations_gen1.asm'];aL2,s2=files['data/moves/animations_gen2.asm']
alines=[aL1[i] for i in s1]+[aL2[i] for i in s2]; assert len(alines)==N+1
for j,n in enumerate(C): ent[n]['anim']=alines[j]
# type of each move from moves.asm
typ={n:[x.strip() for x in ent[n]['data/moves/moves.asm'].split(';')[0].split(',')][2] for n in C[1:]}
order=[re.match(r'\s*const\s+(\w+)',l).group(1) for l in lines('constants/type_constants.asm') if re.match(r'\s*const\s+\w+',l)]
body=sorted([n for n in C[1:] if n!='STRUGGLE'],key=lambda n:order.index(typ[n]))
new=['NO_MOVE']+body
new.insert(max(i for i,n in enumerate(new) if typ.get(n)=='NORMAL')+1,'STRUGGLE')
# write constants with real hex comments
w=max(len(n) for n in new)
for j,i in enumerate(cslots): mc[i]=f'\tconst {new[j]:<{w}} ; {j:02x}'
os.makedirs(OUT+'constants',exist_ok=True); os.makedirs(OUT+'data/moves',exist_ok=True)
open(OUT+'constants/move_constants.asm','w').write('\n'.join(mc))
for p,rx,first in T[:3]:
    L,sl=files[p]
    for j,i in enumerate(sl): L[i]=ent[new[j+1]][p]
    open(OUT+p,'w').write('\n'.join(L))
na=[ent[n]['anim'] for n in new]
for j,i in enumerate(s1): aL1[i]=na[j]
for j,i in enumerate(s2): aL2[i]=na[len(s1)+j]
open(OUT+'data/moves/animations_gen1.asm','w').write('\n'.join(aL1))
open(OUT+'data/moves/animations_gen2.asm','w').write('\n'.join(aL2))
print('N',N,'gen1 slots',len(s1)-1,'gen2 slots',len(s2))

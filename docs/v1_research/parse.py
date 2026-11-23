import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import re,collections
R=f'{_REPO_ROOT}/'
def consts():
    out=[];gen1=None
    for l in open(R+'constants/move_constants.asm'):
        if 'GEN1_MOVES' in l and 'DEF' in l: gen1=len(out)-1
        if 'GEN2_MOVES' in l and 'DEF' in l: break
        m=re.match(r'\s*const\s+(\w+)',l)
        if m: out.append(m.group(1))
    return out,gen1
C,G1=consts()
print('NUM_ATTACKS',len(C)-1,hex(len(C)-1),'GEN1_MOVES',G1,hex(G1))
mv=[]
for l in open(R+'data/moves/moves.asm'):
    m=re.match(r'\s*move\s+([^;]*);\s*(\w+)',l)
    if m:
        f=[x.strip() for x in m.group(1).split(',')]
        mv.append((m.group(2),f))
print('moves.asm entries',len(mv))
bad=[(i+1,C[i+1],n) for i,(n,f) in enumerate(mv) if C[i+1]!=n]
print('comment mismatches',bad[:10])
nm=[re.match(r'\s*li\s+"(.*)"',l).group(1) for l in open(R+'data/moves/names.asm') if re.match(r'\s*li\s+"',l)]
ds=[re.match(r'\s*dw\s+(\w+)',l).group(1) for l in open(R+'data/moves/descriptions.asm') if re.match(r'\s*dw\s+\w+Description\b',l)]
an=[re.match(r'\s*anim_ptr\s+(\w+)',l).group(1) for f in ('animations_gen1.asm','animations_gen2.asm') for l in open(R+'data/moves/'+f) if re.match(r'\s*anim_ptr\s',l)]
print('names',len(nm),'desc ptrs',len(ds),'anims',len(an))
types=collections.Counter(f[2] for n,f in mv)
order=[re.match(r'\s*const\s+(\w+)',l).group(1) for l in open(R+'constants/type_constants.asm') if re.match(r'\s*const\s+\w+',l)]
print('type order:',order)
for t in order:
    if types[t]: print(f'  {t:14}{types[t]}')
print('other:',{k:v for k,v in types.items() if k not in order})
cat=collections.Counter((f[2],f[3]) for n,f in mv)
st=[n for n,f in mv if f[3]=='STATUS']
print('STATUS count',len(st))
print('NO_MOVE idx0 =',C[0], 'STRUGGLE id', C.index('STRUGGLE'))
import json;json.dump({'C':C,'mv':mv,'nm':nm,'ds':ds,'an':an},open('cur.json','w'))

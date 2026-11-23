# Move the split between the two move-table halves to the end of BUG.
import re
def fix(path, end_pat):
    L = open(path).read().split('\n')
    c = next(i for i,l in enumerate(L) if l.strip() == '; BUG (continued)')
    rows = L[c+1:c+4]
    assert '; GHOST' in L[c+4], (path, L[c+4])
    del L[c:c+4]
    e = max(i for i,l in enumerate(L[:c]) if re.match(end_pat, l))
    L[e:e] = rows
    open(path,'w').write('\n'.join(L))
for p in ['data/moves/moves.asm','data/moves/descriptions.asm']:
    fix(p, r'\.IndirectEnd::')
# animations: gen2 rows go to the end of gen1's table (separate files)
g2 = open('data/moves/animations_gen2.asm').read().split('\n')
assert g2[1].strip() == '; BUG (continued)'
rows = g2[2:5]; del g2[1:5]
open('data/moves/animations_gen2.asm','w').write('\n'.join(g2))
g1 = open('data/moves/animations_gen1.asm').read().split('\n')
e = g1.index('.IndirectEnd::'); g1[e:e] = rows
open('data/moves/animations_gen1.asm','w').write('\n'.join(g1))
# constants: DEF line moves below STRING_SHOT
C = open('constants/move_constants.asm').read().split('\n')
d = next(i for i,l in enumerate(C) if l.startswith('DEF GEN1_MOVES'))
defl = C.pop(d); assert C[d].strip() == '; BUG (continued)'; C.pop(d)
s = next(i for i,l in enumerate(C) if 'const STRING_SHOT' in l)
C.insert(s+1, defl)
open('constants/move_constants.asm','w').write('\n'.join(C))

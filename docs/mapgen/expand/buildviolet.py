import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
V=open(f'{_REPO_ROOT}/maps/VioletCity.ablk','rb').read()
CH={'T':0x05,'.':0x01,',':0x02,'"':0x03,'*':0x04,'~':0x35,'(':0x54,'^':0x76,')':0x55,'[':0x58,']':0x59,
    'S':0x47,'s':0x45,'#':0x61,'U':0x65,'c':0x2c,'d':0x2d,'e':0x2e,'f':0x2f,'1':0x14,'2':0x15,
    'a':0x18,'b':0x19,'g':0x1a,'h':0x1b,'m':0x16,'n':0x17,'G':0x0e,'q':0x48,'w':0x49,'p':0x4a,
    'r':0x70,'R':0x6b,'v':0x72,'V':0x6d}
L={0:'TTTTTT',1:'T,cdTT',2:'T,efTT',3:'T,.,,T',4:'......',5:'T,,,.T',6:'Tcd,.T',7:'Tef,.T',8:'T.,,..'}
Rq={0:'TTTTTTT',1:'T,,,cdT',2:'T,,,efT',3:'T,,,.,T',4:'T,*,.,T',5:'TT,,.,T',6:'Tcd,.,T',7:'Tef,.,T',8:'T.,,.,T'}
rows=[]
for y in range(9):
    rows.append([CH[c] for c in L[y]]+list(V[y*20+4:y*20+19])+[CH[c] for c in Rq[y]])
S=[
'T'+'.'*26+'T',
'TT#UU'+',,,,,,,'+'s'+'..'+',,,,,,,,,,,,'+'T',
'rR'+','+'cd'+',,'+'cd'+',,,,'+'..'+',,'+'ab'+',,'+'ab'+',,,,T',
'vV'+','+'ef'+',,'+'ef'+',,,,'+'..'+',,'+'mn'+',,'+'gh'+'....G',
'TT'+','+'.'+',,,'+'.'+',,,,,'+'..'+',,'+'.'+',,,'+'.'+',,,,,'+'T',
'T'+'.'*26+'T',
'T,12,cd,,cd,,..,*,#,,*,,#,*T',
'T,.,,ef,,ef,,..,,,,,,,,,,,,T',
'T,........,,,..,qwwwwwwwwp,T',
'T,,(^^^^),,,,..,"""""""""",T',
'T,*[~~~~]*,,,..,"""""""""",T',
'T,,[~~~~],#,,..,"""""""""",T',
'T,*,,,,,,*,,,..,qwwwwwwwwp,T',
'TT,,*,,#,,,,,..,,,,*,,,,,,TT',
'T'*13+'..'+'T'*13,
]
for i,s in enumerate(S):
    assert len(s)==28,(i+9,len(s),s); rows.append([CH[c] for c in s])
for r in rows: assert len(r)==28,len(r)
# emit amap with generated keys
used=sorted({b for r in rows for b in r})
pool=[c for c in 'ABCDEFHIJKLMNOPQWXYZabcdefghijklmnopqrstuvwxyz0123456789!?@$&+|<>/%=_-:;{}']
rev={v:k for k,v in CH.items()}
keymap={}
for b in used:
    if b in rev and rev[b] not in keymap.values(): keymap[b]=rev[b]
for b in used:
    if b not in keymap:
        c=next(c for c in pool if c not in keymap.values()); keymap[b]=c
keys=' '.join(f'{c}={b:02x}' for b,c in keymap.items())
grid='\n'.join(''.join(keymap[b] for b in r) for r in rows)
open('violet_base.amap','w').write(f'''# Violet City (expanded) base grid
ref VioletCity
key {keys}
grid:
{grid}
end
exit W 0 9
exit S 27 47
exit GATE 55 24
exit SproutTower 27 5
exit Gym 22 17
exit Academy 34 17
''')
print(len(rows),'rows')

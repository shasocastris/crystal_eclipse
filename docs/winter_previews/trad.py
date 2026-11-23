import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
# Second pass on the traditional roofs, after roofs/snow.png. Writes trad.json.
import json
from PIL import Image
R=f'{_REPO_ROOT}/'
LV={255:0,170:1,85:2,0:3}
W=Image.open(R+'gfx/tilesets/seasonal/johto_winter.png').convert('L')
S=Image.open(R+'gfx/tilesets/roofs/snow.png').convert('L')
get=lambda t:[LV[v] for v in W.crop(((t%16)*8,(t//16)*8,(t%16)*8+8,(t//16)*8+8)).getdata()]
eave=[LV[v] for v in S.crop((8,0,16,8)).getdata()]
rows=lambda s:[ '.-o#'.index(c) for c in ''.join(s.split())]
O={}
O[0x53]=rows('''oo.ooo.o ........ ........ ......-. ........ ..-..... ........ -.-.-.-.''')
O[0x52]=rows('oo.ooo.o')+eave[8:]
for t,keep,new in ((0x51,range(0,5),range(5,8)),(0x54,range(3,8),range(0,3))):
    p=get(t)
    for y in range(8):
        for x in new: p[y*8+x]=O[0x52][y*8+x]
    O[t]=p
# rims: speckle between the two rim lines on alternate rows
for t in (0x41,0x44,0x31,0x34):
    p=get(t)
    for y in range(1,8,2):
        for x in range(8):
            if p[y*8+x]==0 and 0<x<7 and p[y*8+x-1]==3: p[y*8+x]=1; break
    O[t]=p
json.dump({str(k):v for k,v in O.items()},open('trad.json','w'))
ch='.-o#'
for grp in ([0x31,0x53,0x34],[0x41,0x53,0x44],[0x51,0x52,0x54]):
    for y in range(8): print(''.join(''.join(ch[v] for v in O[t][y*8:y*8+8]) for t in grp))
    print()

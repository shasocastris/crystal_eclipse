import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
# Winter drafts for TILESET_PARK. Writes park_ov.json {park tile: 64 levels}.
import json
from PIL import Image
R=f'{_REPO_ROOT}/'
LV={255:0,170:1,85:2,0:3}
P=Image.open(R+'gfx/tilesets/park.png').convert('L')
S=Image.open(R+'gfx/tilesets/roofs/snow.png').convert('L')
W=Image.open(R+'gfx/tilesets/seasonal/johto_winter.png').convert('L')
def tile(img,t,cols=16,row0=0): x,y=(t%cols)*8,(t//cols-row0)*8; return [LV[v] for v in img.crop((x,y,x+8,y+8)).getdata()]
g5=tile(W,0x05)
O={}
O[0x01]=g5                       # grass == johto $05
O[0x04]=tile(W,0x04)             # tall grass == johto $04
for r,row in enumerate((2,1,0)):  # roof: $1x ridge, $2x middle, $3x eave
    for c in range(3): O[0x10+r*16+c]=tile(S,row*3+c,3)
trunk={0x2d,0x2e,0x3d,0x3e}
for t in [0x0c,0x0d,0x0e,0x0f,0x1c,0x1d,0x1e,0x1f,0x2c,0x2f,0x3c,0x3f]:
    O[t]=[g5[i] if v in (0,1) else (0 if v==2 else 3) for i,v in enumerate(tile(P,t))]
# big tufts: tips above the snow line, buried below, a drift line at the base
for t in (0x3a,0x3b,0x4a,0x4b):
    p=tile(P,t); q=[]
    for i,v in enumerate(p):
        y=i//8+(8 if t>=0x4a else 0)
        if v==2: q.append(2 if y<12 else 1)
        elif v==1: q.append(1 if y==15 else 0)
        else: q.append(v)
    O[t]=q
json.dump({str(k):v for k,v in O.items()},open('park_ov.json','w'))

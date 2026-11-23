import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
# Kanto roofs from roofs/snow.png. kroof.py in_sheet out_sheet
import sys
from PIL import Image
R=f'{_REPO_ROOT}/'
LV={255:0,170:1,85:2,0:3}; G=[255,170,85,0]
S=Image.open(R+'gfx/tilesets/roofs/snow.png').convert('L')
W=Image.open(sys.argv[1]).convert('L')
snow=lambda i:[LV[v] for v in S.crop(((i%3)*8,(i//3)*8,(i%3)*8+8,(i//3)*8+8)).getdata()]
get=lambda t:[LV[v] for v in W.crop(((t%16)*8,(t//16)*8,(t%16)*8+8,(t//16)*8+8)).getdata()]
def put(t,px):
    for i,v in enumerate(px): W.putpixel(((t%16)*8+i%8,(t//16)*8+i//8),G[v])
mirror=lambda px:[px[(i//8)*8+7-i%8] for i in range(64)]
EAVE,MIDR=1,5                                   # snow.png slots: eave middle, middle right
put(0x17,snow(EAVE))
put(0x19,snow(MIDR))
put(0x15,mirror(snow(MIDR)))
lip=[0,0,1,0,1,0,1,0]                            # eave's snow lip, row 2
for t in (0x16,0x18):
    p=get(t)
    for x in range(8):
        if p[16+x]==0: p[16+x]=lip[x]
        if p[24+x]==0 and x%2==0: p[24+x]=1
    put(t,p)
def speckle(t,side):
    # one light pixel just inside the slope line on alternate rows
    p=get(t)
    for y in range(1,8,2):
        row=p[y*8:y*8+8]
        xs=[x for x in range(8) if row[x]>=2]
        if not xs: continue
        x=(max(xs)+2) if side=='L' else (min(xs)-2)
        if 0<=x<8 and row[x]==0: p[y*8+x]=1
    put(t,p)
speckle(0x05,'L'); speckle(0x06,'L'); speckle(0x08,'R'); speckle(0x09,'R')
W.save(sys.argv[2])

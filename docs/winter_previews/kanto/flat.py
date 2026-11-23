import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
# Flat-roof front edge from roofs/snow.png's eave.
from PIL import Image
R=f'{_REPO_ROOT}/'
LV={255:0,170:1,85:2,0:3}; G=[255,170,85,0]
S=Image.open(R+'gfx/tilesets/roofs/snow.png').convert('L')
W=Image.open(R+'gfx/tilesets/seasonal/kanto_winter.png').convert('L')
eave=[LV[v] for v in S.crop((8,0,16,8)).getdata()]
get=lambda t:[LV[v] for v in W.crop(((t%16)*8,(t//16)*8,(t%16)*8+8,(t//16)*8+8)).getdata()]
def put(t,px):
    for i,v in enumerate(px): W.putpixel(((t%16)*8+i%8,(t//16)*8+i//8),G[v])
put(0x5f,eave)
for t,cols in ((0x5c,range(5,8)),(0x5d,range(0,3))):
    p=get(t)
    for y in range(8):
        for x in cols: p[y*8+x]=eave[y*8+x]
    put(t,p)
W.save(R+'gfx/tilesets/seasonal/kanto_winter.png')
ch='.-o#'
for t in (0x5c,0x5f,0x5d):
    print('$%02x'%t); [print(''.join(ch[v] for v in get(t)[r*8:r*8+8]) if False else '') for r in range(0)]

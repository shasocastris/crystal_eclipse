import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
# Winter drafts for trees and mountains. Writes overrides.json {tile: [64 levels 0-3]}.
import json,sys
from PIL import Image
R=f'{_REPO_ROOT}/'
LV={255:0,170:1,85:2,0:3}
J=Image.open(R+'gfx/tilesets/johto.png').convert('L')
def get(t): return [LV[v] for v in J.crop(((t%16)*8,(t//16)*8,(t%16)*8+8,(t//16)*8+8)).getdata()]
def remap(t,mp): return [mp[v] for v in get(t)]
def snowcap(px,solid=(2,3)):
    # paint white on foliage/rock pixels whose pixel above is light (0/1) -> snow on top faces
    out=px[:]
    for y in range(8):
        for x in range(8):
            v=px[y*8+x]
            above=px[(y-1)*8+x] if y else None
            if v in solid and above is not None and above in (0,1): out[y*8+x]=0
    return out
O={}
mode=sys.argv[1] if len(sys.argv)>1 else 'a'
# trees: light cyan -> white, keep blue/dark (snow-laden)
for t in (0x1e,0x1f,0x2e,0x2f,0x3e,0x3f):
    O[t]=remap(t,{0:0,1:0,2:2,3:3}) if mode=='a' else snowcap(remap(t,{0:0,1:0,2:2,3:3}))
# ground fill / path: white with sparse light specks
p=get(0x3c); O[0x3c]=[1 if v==2 and (i%8+i//8)%3==0 else (3 if v==3 else 0) for i,v in enumerate(p)]
# rocky edges and cave mouths: light -> white, keep mid/dark (snow-dusted rock)
for t in (0x2b,0x2c,0x2d,0x3b,0x3d,0x4b,0x4c,0x4d,0x5c,0x46,0x47,0x56,0x57):
    O[t]=remap(t,{0:0,1:0,2:2,3:3})
json.dump({str(k):v for k,v in O.items()},open('overrides.json','w'))

import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
# Winter cherry canopy drafts. cherry.py MODE out.json ; writes overrides keyed by png tile index.
import json,sys
from PIL import Image
R=f'{_REPO_ROOT}/'
LV={255:0,170:1,85:2,0:3}
J=Image.open(R+'gfx/tilesets/johto.png').convert('L')
def get(t): return [LV[v] for v in J.crop(((t%16)*8,(t//16)*8,(t%16)*8+8,(t//16)*8+8)).getdata()]
mode=sys.argv[1]; O={}
corners={0xc0,0xc3,0xf0,0xf3}
for r in range(4):
    for c in range(4):
        t=0xc0+r*16+c; p=get(t)
        if t in corners: q=[{0:0,1:1,2:0,3:3}[v] for v in p]          # grass dots stay, fringe snows
        elif mode=='a': q=[{0:0,1:0,2:0,3:3}[v] for v in p]          # blossom -> snow, dark stays
        else:                                                         # thicken branches under snow
            q=[]
            for i,v in enumerate(p):
                if v==3: q.append(3)
                elif v==2:
                    below=p[i+8] if i+8<64 else 0
                    q.append(3 if below==3 and (i//8)%2 else 0)
                else: q.append(0)
        O[t]=q
json.dump({str(k):v for k,v in O.items()},open(sys.argv[2],'w'))

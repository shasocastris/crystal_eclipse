import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
# Winter grass drafts. grass.py MODE out.json
import json,sys
from PIL import Image
R=f'{_REPO_ROOT}/'
LV={255:0,170:1,85:2,0:3}
J=Image.open(R+'gfx/tilesets/johto.png').convert('L')
get=lambda t:[LV[v] for v in J.crop(((t%16)*8,(t//16)*8,(t%16)*8+8,(t//16)*8+8)).getdata()]
mode=sys.argv[1]; O={}
# grass: light checker -> snow, mid pixels -> light specks
O[0x05]=[{0:0,1:0,2:1,3:3}[v] for v in get(0x05)]
p=get(0x04); q=[]
for i,v in enumerate(p):
    y=i//8
    if v==2: q.append(2 if y < (5 if mode=='a' else 4) else 1)   # stalk tips above the snow line
    elif v==1: q.append(1 if (mode=='b' and y==7) else 0)
    else: q.append(v)
O[0x04]=q
json.dump({str(k):v for k,v in O.items()},open(sys.argv[2],'w'))
ch='.-o#'
for t in (4,5):
    print('$%02x'%t); [print(''.join(ch[v] for v in O[t][r*8:r*8+8])) for r in range(8)]

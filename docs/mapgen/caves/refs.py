from common import *
import re
eng, ref = R.engine_and_ref('UnionCave1F','summer','day')
dm=dims(); bp=blockpaths()
names=[l.split()[1].rstrip(',') for l in open(REPO+'/data/maps/maps.asm') if 'TILESET_CAVE,' in l]
dm2={k.replace('_',''):v for k,v in dm.items()}
def const(n): return n.upper()
from collections import Counter
cnt=Counter()
for n in names:
    c=const(n)
    if c not in dm2: print('nodim',n,c); continue
    w,h=dm2[c]; data=open(bp[n],'rb').read()
    cnt.update(data)
    R.render(data,w,eng,ref,grid=True,scale=1).save(D+f'/caves/ref/{n}.png'); print(n,w,h)
print(sorted(cnt.items(), key=lambda x:-x[1]))

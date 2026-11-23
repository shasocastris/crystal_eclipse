import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../../../../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import sys
sys.path.insert(0,f'{_REPO_ROOT}/docs/mapgen/handmade')
import amap
ref,w,h,data,objs,exits,ts=amap.parse(sys.argv[1])
coll=amap.load_coll(ts)
g=amap.cells(w,h,data,coll)
ex={(x,y):n for n,x,y in exits}
for y in range(len(g)):
    for x in range(len(g[0])):
        if g[y][x]=='DOOR':
            below=g[y+1][x] if y+1<len(g) else 'OOB'
            print(f'door {x},{y} block {x//2},{y//2} below={below} listed={ex.get((x,y))}')
for (x,y),n in ex.items():
    if g[y][x]!='DOOR' and 0<x<len(g[0])-1 and 0<y<len(g)-1: print('nondoor exit',n,x,y,g[y][x])

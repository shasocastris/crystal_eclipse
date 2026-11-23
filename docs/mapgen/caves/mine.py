from common import *
from collections import Counter, defaultdict
dm=dims(); dm2={k.replace('_',''):v for k,v in dm.items()}; bp=blockpaths()
names=[l.split()[1].rstrip(',') for l in open(REPO+'/data/maps/maps.asm') if 'TILESET_CAVE,' in l]
LOW={0x02,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f,0x20,0x21,0x22,0x24,0x28,0x29,0x2a,0x2b}
WATER={0x0f,0x25,0x26,0x27,0x32,0x33,0x3d,0x3e,0x2c}
RUB={0x2d,0x2e,0x2f}
def cls(b):
    if b in LOW: return 'L'
    if b in WATER: return 'W'
    if b in RUB: return 'R'
    if b>=0x40 and b<0x48: return '?'
    return 'H'
stats=defaultdict(Counter)
for n in names:
    w,h=dm2[n.upper()]; d=open(bp[n],'rb').read()
    g=[[d[y*w+x] for x in range(w)] for y in range(h)]
    def c(x,y):
        if 0<=x<w and 0<=y<h: return cls(g[y][x])
        return '.'
    for y in range(h):
        for x in range(w):
            k=c(x,y)+':'+''.join(c(x+dx,y+dy) for dx,dy in [(0,-1),(1,0),(0,1),(-1,0),(1,-1),(1,1),(-1,1),(-1,-1)])
            stats[k][g[y][x]]+=1
import sys
for k in sorted(stats):
    if k[0] in 'HW' and 'R' not in k:
        print(k, ' '.join(f'{b:02x}x{n}' for b,n in stats[k].most_common(5)))

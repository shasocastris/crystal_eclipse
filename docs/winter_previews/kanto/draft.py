import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
# Kanto winter drafts -> kov.json {tile: 64 levels}
import json,os
CAP=os.environ.get('CAP')=='1'
from PIL import Image
R=f'{_REPO_ROOT}/'
LV={255:0,170:1,85:2,0:3}
def tl(I,t): return [LV[v] for v in I.crop(((t%16)*8,(t//16)*8,(t%16)*8+8,(t//16)*8+8)).getdata()]
K=Image.open(R+'gfx/tilesets/kanto.png').convert('L'); JW=Image.open(R+'gfx/tilesets/seasonal/johto_winter.png').convert('L')
get=lambda t:tl(K,t)
O={}
# grass, same map as johto $05
G=get(0x2c); GW=tl(JW,0x05); O[0x2c]=GW   # johto's approved winter grass, so both regions match
# tall grass, johto $04 rule: stalk tips above y=4, buried below, drift on the bottom row
q=[]
for i,v in enumerate(get(0x52)):
    y=i//8
    if v==2: q.append(2 if y<4 else 1)
    elif v==1: q.append(1 if y==7 else 0)
    else: q.append(v)
O[0x52]=q
# trees as 2x2 units: grass around the canopy (pixels matching $2c reached from the outer edge) -> winter grass;
# canopy -> johto tree map (light -> snow, keep blue/dark)
def tree(tl_,tr,bl,br):
    ts=[tl_,tr,bl,br]; P=[[0]*16 for _ in range(16)]
    for k,t in enumerate(ts):
        d=get(t)
        for i,v in enumerate(d): P[(k//2)*8+i//8][(k%2)*8+i%8]=v
    gp=lambda x,y:G[(y%8)*8+x%8]
    seen=set(); st=[(x,y) for x in range(16) for y in (0,15)]+[(x,y) for y in range(16) for x in (0,15)]
    st=[(x,y) for x,y in st if P[y][x]==gp(x,y) and P[y][x]!=3]
    while st:
        x,y=st.pop()
        if (x,y) in seen: continue
        seen.add((x,y))
        for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)):
            nx,ny=x+dx,y+dy
            if 0<=nx<16 and 0<=ny<16 and (nx,ny) not in seen and P[ny][nx]==gp(nx,ny) and P[ny][nx]!=3: st.append((nx,ny))
    for k,t in enumerate(ts):
        out=[]
        for i in range(64):
            x,y=(k%2)*8+i%8,(k//2)*8+i//8; v=P[y][x]
            if (x,y) in seen: out.append(GW[(y%8)*8+x%8])
            elif v==2 and CAP and y>0 and P[y-1][x] in (0,1) and (x,y-1) not in seen: out.append(0)
            else: out.append({0:0,1:0,2:2,3:3}[v])
        O[t]=out
tree(0x40,0x41,0x50,0x51); tree(0x2d,0x2e,0x3d,0x3e)
# mountain ground = johto $3c (identical art); its top-edge variant gets the same rule
sp=lambda p:[1 if v==2 and (i%8+i//8)%3==0 else (3 if v==3 else 0) for i,v in enumerate(p)]
O[0x11]=tl(JW,0x3c); O[0x01]=sp(get(0x01))
# cliffs, ledges, rocky shores, sand: light -> snow, keep mid/dark
for t in (0x37,0x24,0x27,0x33,0x54,0x34,0x36,0x04,0x1e,0x02,0x35,0x13,0x30):
    O[t]=[{0:0,1:0,2:2,3:3}[v] for v in get(t)]
# cave mouth = johto $46/$47/$56/$57 (identical art)
for k,j in ((0x48,0x46),(0x49,0x47),(0x58,0x56),(0x59,0x57)): O[k]=tl(JW,j)
# roofs: surface -> snow; keep outline, and a mid rim along it
def snowroof(p,mask=None):
    out=p[:]
    for i,v in enumerate(p):
        if mask is not None and i not in mask: continue
        x,y=i%8,i//8
        if v==3: continue
        adj=any(0<=x+dx<8 and 0<=y+dy<8 and p[(y+dy)*8+x+dx]==3 for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)))
        out[i]=2 if (adj and v in (1,2)) else 0
    return out
def flood(p,x0,y0):
    seen=set(); st=[y0*8+x0]
    while st:
        i=st.pop()
        if i in seen or p[i]==3: continue
        seen.add(i); x,y=i%8,i//8
        for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)):
            if 0<=x+dx<8 and 0<=y+dy<8: st.append((y+dy)*8+x+dx)
    return seen
for t in (0x05,0x06,0x07,0x08,0x09,0x15,0x16,0x17,0x18,0x19,0x38,0x12,0x53,0x4e,0x5e,0x5f):
    O[t]=snowroof(get(t))
for t,cols in ((0x4c,range(4,8)),(0x5c,range(4,8)),(0x4d,range(0,4)),(0x5d,range(0,4))):
    O[t]=snowroof(get(t),{y*8+x for y in range(8) for x in cols})   # flat-roof side posts: roof side only
O[0x25]=snowroof(get(0x25),flood(get(0x25),1,0))
O[0x29]=snowroof(get(0x29),flood(get(0x29),6,0))
if os.environ.get('PAVE')=='1':
    O[0x5b]=[0 if v==1 and (i%8+2*(i//8))%4 else v for i,v in enumerate(get(0x5b))]
if os.environ.get('POST')=='1':
    for t in (0x2a,0x2b): O[t]=[0 if v==1 and i//8<5 else v for i,v in enumerate(get(t))]
json.dump({str(k):v for k,v in O.items()},open(os.environ.get('OUT','kov.json'),'w'))
ch='.-o#'
ks=sorted(O)
for k in range(0,len(ks),8):
    grp=ks[k:k+8]; print('   '.join('$%02x    '%t for t in grp))
    for r in range(8): print('   '.join(''.join(ch[v] for v in O[t][r*8:r*8+8]) for t in grp))
    print()

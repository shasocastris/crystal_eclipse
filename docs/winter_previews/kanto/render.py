import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
# render.py MAP overrides.json|- out.png [x y w h]  -> orig (top/left) vs winter side by side
import sys,re,json,os
from PIL import Image
R=f'{_REPO_ROOT}/'
name,ov,out=sys.argv[1:4]; crop=list(map(int,sys.argv[4:8])) if len(sys.argv)>4 else None
mc=open(R+'constants/map_constants.asm').read()
g=0; grp={}; dims={}
for line in mc.splitlines():
    if line.strip().startswith('newgroup'): g+=1
    mm=re.match(r'\s*map_const (\w+),\s*(\d+),\s*(\d+)',line)
    if mm: grp[mm[1]]=g; dims[mm[1]]=(int(mm[2]),int(mm[3]))
const=[k for k in dims if k.replace('_','')==name.upper()][0]
w,h=dims[const]
rp=re.findall(r'RGB (\d+),(\d+),(\d+), (\d+),(\d+),(\d+) ; morn/day',open(R+'gfx/tilesets/roofs.pal').read())[grp[const]]
rp=list(map(int,rp))
c5=lambda *v:tuple(x*255//31 for x in v)
W=c5(27,31,27); D=c5(7,7,7)
base=[[W,c5(21,21,21),c5(13,13,13),D],[W,c5(31,19,24),c5(30,10,6),D],
   [c5(22,31,10),c5(12,25,1),c5(5,14,0),D],[c5(23,23,31),c5(18,19,31),c5(13,12,31),D],
   [W,c5(31,31,7),c5(31,16,1),D],[W,c5(24,18,7),c5(20,15,3),D],
   [W,c5(*rp[:3]),c5(*rp[3:]),D],[c5(31,31,16),c5(31,31,16),c5(14,9,0),c5(0,0,0)]]
win=[p[:] for p in base]; win[2]=[W,c5(1,27,27),c5(5,17,31),D]
LV={255:0,170:1,85:2,0:3}
J=Image.open(R+'gfx/tilesets/kanto.png').convert('L')
T0={i:[LV[v] for v in J.crop(((i%16)*8,(i//16)*8,(i%16)*8+8,(i//16)*8+8)).getdata()] for i in range(128)}
T1=dict(T0)
if ov!='-':
    for k,v in json.load(open(ov)).items(): T1[int(k)]=v
m=open(R+'data/tilesets/kanto_metatiles.bin','rb').read(); a=open(R+'data/tilesets/kanto_attributes.bin','rb').read()
blk=open(R+f'maps/{name}.ablk','rb').read()
def draw(tiles,P):
    img=Image.new('RGB',(w*32,h*32)); px=img.load()
    for by in range(h):
        for bx in range(w):
            b=blk[by*w+bx]
            for i in range(16):
                tt,at=m[b*16+i],a[b*16+i]; d=tiles[tt]; pal=P[at&7]
                for y in range(8):
                    for x in range(8):
                        sx=7-x if at&0x20 else x; sy=7-y if at&0x40 else y
                        px[bx*32+(i%4)*8+x,by*32+(i//4)*8+y]=pal[d[sy*8+sx]]
    if crop: img=img.crop((crop[0]*32,crop[1]*32,(crop[0]+crop[2])*32,(crop[1]+crop[3])*32))
    return img
A=draw(T0,base); B=draw(T1,win)
side = A.size[0] <= A.size[1]*1.3
o=Image.new('RGB',(A.size[0]*2+8,A.size[1]) if side else (A.size[0],A.size[1]*2+8),(40,40,40))
o.paste(A,(0,0)); o.paste(B,(A.size[0]+8,0) if side else (0,A.size[1]+8))
S=int(os.environ.get('SCALE','2'))
o.resize((o.size[0]*S,o.size[1]*S),Image.NEAREST).save(out)

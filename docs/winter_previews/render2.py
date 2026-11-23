import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
# render2.py MAP overrides.json|- roofwinter.png|- out.png [x y w h]
import sys,re,json
from PIL import Image
R=f'{_REPO_ROOT}/'
name,ov,rw,out=sys.argv[1:5]; crop=list(map(int,sys.argv[5:9])) if len(sys.argv)>5 else None
const=[k for k in re.findall(r'map_const (\w+),',open(R+'constants/map_constants.asm').read()) if k.replace('_','')==name.upper()][0]
w,h=map(int,re.search(rf'map_const {const},\s*(\d+),\s*(\d+)',open(R+'constants/map_constants.asm').read()).groups())
c5=lambda *v:tuple(x*255//31 for x in v)
P=[[c5(27,31,27),c5(21,21,21),c5(13,13,13),c5(7,7,7)],[c5(27,31,27),c5(31,19,24),c5(30,10,6),c5(7,7,7)],
   [c5(27,31,27),c5(1,27,27),c5(5,17,31),c5(7,7,7)],[c5(23,23,31),c5(18,19,31),c5(13,12,31),c5(7,7,7)],
   [c5(27,31,27),c5(31,31,7),c5(31,16,1),c5(7,7,7)],[c5(27,31,27),c5(24,18,7),c5(20,15,3),c5(7,7,7)],
   [c5(27,31,27),c5(1,27,27),c5(5,17,31),c5(7,7,7)],[c5(31,31,16),c5(31,31,16),c5(14,9,0),c5(0,0,0)]]
LV={255:0,170:1,85:2,0:3}
def t(img,i,cols=16): x,y=(i%cols)*8,(i//cols)*8; return [LV[v] for v in img.crop((x,y,x+8,y+8)).getdata()]
J=Image.open(R+'gfx/tilesets/johto.png').convert('L'); tiles={i:t(J,i) for i in range(256)}
if rw!='-':
    W=Image.open(rw).convert('L')
    for k,d in enumerate([0x31,0x32,0x33,0x34,0x36,0x41,0x42,0x43,0x44,0x48,0x51,0x52,0x53,0x54]): tiles[d]=t(W,k,5)
    S=Image.open(R+'gfx/tilesets/roofs/snow.png').convert('L')
    for k in range(9): tiles[0x0a+k]=t(S,k,3)
if ov!='-':
    for k,v in json.load(open(ov)).items(): tiles[int(k)]=v
m=open(R+'data/tilesets/johto_metatiles.bin','rb').read(); a=open(R+'data/tilesets/johto_attributes.bin','rb').read()
blk=open(R+f'maps/{name}.ablk','rb').read()
img=Image.new('RGB',(w*32,h*32)); px=img.load()
for by in range(h):
    for bx in range(w):
        b=blk[by*w+bx]
        for i in range(16):
            tt,at=m[b*16+i],a[b*16+i]; d=tiles[tt+(128 if at&8 else 0)]; pal=P[at&7]
            for y in range(8):
                for x in range(8):
                    sx=7-x if at&0x20 else x; sy=7-y if at&0x40 else y
                    px[bx*32+(i%4)*8+x,by*32+(i//4)*8+y]=pal[d[sy*8+sx]]
if crop: img=img.crop((crop[0]*32,crop[1]*32,(crop[0]+crop[2])*32,(crop[1]+crop[3])*32))
img.resize((img.size[0]*2,img.size[1]*2),Image.NEAREST).save(out)

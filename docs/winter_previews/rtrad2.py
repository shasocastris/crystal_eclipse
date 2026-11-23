import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
# rtrad.py MAP x y w h out.png overrides.json|- recolor(0/1)
import sys,re,json
from PIL import Image
R=f'{_REPO_ROOT}/'
name=sys.argv[1]; x0,y0,cw,chh=map(int,sys.argv[2:6]); out=sys.argv[6]; ov=sys.argv[7]; rec=sys.argv[8]=='1'
const=[k for k in re.findall(r'map_const (\w+),',open(R+'constants/map_constants.asm').read()) if k.replace('_','')==name.upper()][0]
w,h=map(int,re.search(rf'map_const {const},\s*(\d+),\s*(\d+)',open(R+'constants/map_constants.asm').read()).groups())
c5=lambda *v:tuple(x*255//31 for x in v)
P=[[c5(27,31,27),c5(21,21,21),c5(13,13,13),c5(7,7,7)],[c5(27,31,27),c5(31,19,24),c5(30,10,6),c5(7,7,7)],
   [c5(27,31,27),c5(1,27,27),c5(5,17,31),c5(7,7,7)],[c5(23,23,31),c5(18,19,31),c5(13,12,31),c5(7,7,7)],
   [c5(27,31,27),c5(31,31,7),c5(31,16,1),c5(7,7,7)],[c5(27,31,27),c5(24,18,7),c5(20,15,3),c5(7,7,7)],
   [c5(27,31,27),c5(1,27,27),c5(5,17,31),c5(7,7,7)],[c5(31,31,16),c5(31,31,16),c5(14,9,0),c5(0,0,0)]]
LV={255:0,170:1,85:2,0:3}
J=Image.open(R+'gfx/tilesets/johto.png').convert('L'); Wn=Image.open(R+'gfx/tilesets/seasonal/johto_winter.png').convert('L')
t=lambda img,i,y0=0:[LV[v] for v in img.crop(((i%16)*8,(i//16-y0)*8,(i%16)*8+8,(i//16-y0)*8+8)).getdata()]
tiles={i:t(J,i) for i in range(256)}
for i in [0x04,0x05,0x1e,0x1f,0x2b,0x2c,0x2d,0x2e,0x2f,0x31,0x34,0x36,0x3b,0x3c,0x3d,0x3e,0x3f,0x41,0x44,0x46,0x47,0x48,0x4b,0x4c,0x4d,0x51,0x52,0x53,0x54,0x56,0x57,0x5c]: tiles[i]=t(Wn,i)
S=Image.open(R+'gfx/tilesets/roofs/snow.png').convert('L')
for k in range(9): tiles[0x0a+k]=[LV[v] for v in S.crop(((k%3)*8,(k//3)*8,(k%3)*8+8,(k//3)*8+8)).getdata()]
if ov!='-':
    for k,v in json.load(open(ov)).items(): tiles[int(k)]=v
REC={0x31,0x32,0x33,0x34,0x36,0x41,0x42,0x43,0x44,0x48,0x51,0x52,0x53,0x54}
m=bytearray(open(R+"data/tilesets/johto_metatiles.bin","rb").read()); a=open(R+'data/tilesets/johto_attributes.bin','rb').read()
import os
if os.environ.get('OPT2'):
    def setrow(b,r,mp):
        for c in range(4):
            t=m[b*16+r*4+c]
            if t in mp: m[b*16+r*4+c]=mp[t]
    for b,top in ((0x2c,2),(0x2d,2),(0x2a,2),(0x96,0),(0x97,0)):
        setrow(b,top,{0x53:0x20})
        setrow(b,top+1,{0x53:0x21,0x41:0x30,0x44:0x35})
    REC|={0x20,0x21,0x30,0x35}
blk=open(R+f'maps/{name}.ablk','rb').read()
img=Image.new('RGB',(cw*32,chh*32)); px=img.load()
for by in range(chh):
    for bx in range(cw):
        b=blk[(y0+by)*w+x0+bx]
        for i in range(16):
            tt,at=m[b*16+i],a[b*16+i]; pal=at&7
            if rec and not at&8 and ((tt in REC and pal==5) or (0x0a<=tt<=0x12 and pal==6)): pal=2
            d=tiles[tt+(128 if at&8 else 0)]
            for y in range(8):
                for x in range(8):
                    sx=7-x if at&0x20 else x; sy=7-y if at&0x40 else y
                    px[bx*32+(i%4)*8+x,by*32+(i//4)*8+y]=P[pal][d[sy*8+sx]]
img.resize((img.size[0]*3,img.size[1]*3),Image.NEAREST).save(out)

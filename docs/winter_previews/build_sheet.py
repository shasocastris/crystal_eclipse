import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
# Builds gfx/tilesets/seasonal/johto_winter.png as a sheet of johto.png rows $1x-$5x.
import json
from PIL import Image
R=f'{_REPO_ROOT}/'
G=[255,170,85,0]; LV={255:0,170:1,85:2,0:3}
old=Image.open(R+'gfx/tilesets/seasonal/johto_winter.png').convert('L')
M=Image.open(R+'gfx/tilesets/johto_modern.png').convert('L')
out=Image.new('L',(128,40),255)
def put(t,px):
    x,y=(t%16)*8,(t//16-1)*8
    for i,v in enumerate(px): out.putpixel((x+i%8,y+i//8),G[v])
def grab(img,i,cols):
    x,y=(i%cols)*8,(i//cols)*8; return [LV[v] for v in img.crop((x,y,x+8,y+8)).getdata()]
for k,t in enumerate([0x31,0x32,0x33,0x34,0x36,0x41,0x42,0x43,0x44,0x48,0x51,0x52,0x53,0x54]): put(t,grab(old,k,5))
for k,v in json.load(open('ov_a.json')).items(): put(int(k),v)
for t in (0x13,0x15): put(t,[{0:0,1:0,2:2,3:3}[v] for v in grab(M,t,16)])  # modern tree middles
out.save(R+'gfx/tilesets/seasonal/johto_winter.png')

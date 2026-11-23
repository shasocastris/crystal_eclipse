import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import sys
from PIL import Image
R=f'{_REPO_ROOT}/'
LV={255:0,170:1,85:2,0:3}
K=Image.open(R+'gfx/tilesets/kanto.png').convert('L')
g=lambda t:[LV[v] for v in K.crop(((t%16)*8,(t//16)*8,(t%16)*8+8,(t//16)*8+8)).getdata()]
m=open(R+'data/tilesets/kanto_metatiles.bin','rb').read(); a=open(R+'data/tilesets/kanto_attributes.bin','rb').read()
def comp(blocks):
    W=len(blocks)*32; G=[[0]*W for _ in range(32)]; T=[[0]*W for _ in range(32)]
    for k,b in enumerate(blocks):
        for i in range(16):
            t,at=m[b*16+i],a[b*16+i]; d=g(t)
            for y in range(8):
                for x in range(8):
                    sx=7-x if at&0x20 else x; sy=7-y if at&0x40 else y
                    G[(i//4)*8+y][k*32+(i%4)*8+x]=d[sy*8+sx]; T[(i//4)*8+y][k*32+(i%4)*8+x]=(t,at&7)
    return G,T
if __name__=='__main__':
    ch='.-o#'
    G,T=comp([int(x,16) for x in sys.argv[1:]])
    for y,row in enumerate(G):
        print(' '.join(''.join(ch[v] for v in row[c:c+8]) for c in range(0,len(row),8)))
        if y%8==7: print()

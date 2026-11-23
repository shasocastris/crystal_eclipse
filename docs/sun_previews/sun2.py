import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
# Sun palette candidates, using the game's weather_dim math on day palettes.
import re
from PIL import Image, ImageDraw
R=f'{_REPO_ROOT}/'
LV={255:0,170:1,85:2,0:3}
def roofpal(group):
    rp=re.findall(r'RGB (\d+),(\d+),(\d+), (\d+),(\d+),(\d+) ; morn/day',open(R+'gfx/tilesets/roofs.pal').read())[group]
    rp=list(map(int,rp)); return [(27,31,27),tuple(rp[:3]),tuple(rp[3:]),(7,7,7)]
GREEN={'summer':[(22,31,10),(12,25,1),(5,14,0),(7,7,7)],'spring':[(18,31,10),(8,26,7),(0,14,5),(7,7,7)]}
def pals(season,group):
    return [[(27,31,27),(21,21,21),(13,13,13),(7,7,7)],[(27,31,27),(31,19,24),(30,10,6),(7,7,7)],GREEN[season],
            [(23,23,31),(18,19,31),(13,12,31),(7,7,7)],[(27,31,27),(31,31,7),(31,16,1),(7,7,7)],
            [(27,31,27),(24,18,7),(20,15,3),(7,7,7)],roofpal(group),[(31,31,16),(31,31,16),(14,9,0),(0,0,0)]]
def sun(p,b,t):
    if b==8: return p
    lift=[x*(8-b)//8 for x in t]
    return [[tuple(min(31,(c[i]*b)>>3)+0 if False else min(31,((c[i]*b)>>3)+lift[i]) for i in range(3)) for c in pal] for pal in p]
def render(ts,name,mapw,crop,P):
    J=Image.open(R+f'gfx/tilesets/{ts}.png').convert('L'); n=(J.size[0]//8)*(J.size[1]//8)
    T={i:[LV[v] for v in J.crop(((i%16)*8,(i//16)*8,(i%16)*8+8,(i//16)*8+8)).getdata()] for i in range(n)}
    m=open(R+f'data/tilesets/{ts}_metatiles.bin','rb').read(); a=open(R+f'data/tilesets/{ts}_attributes.bin','rb').read()
    blk=open(R+f'maps/{name}.ablk','rb').read(); x0,y0,w,h=crop
    img=Image.new('RGB',(w*32,h*32)); px=img.load()
    c8=lambda c:tuple(v*255//31 for v in c)
    for by in range(h):
        for bx in range(w):
            b=blk[(y0+by)*mapw+x0+bx]
            for i in range(16):
                t,at=m[b*16+i],a[b*16+i]; d=T.get(t+(128 if at&8 else 0),T[0]); pal=P[at&7]
                for y in range(8):
                    for x in range(8):
                        sx=7-x if at&0x20 else x; sy=7-y if at&0x40 else y
                        px[bx*32+(i%4)*8+x,by*32+(i//4)*8+y]=c8(pal[d[sy*8+sx]])
    return img
def keepdark(p,b,t):
    q=sun(p,b,t)
    return [pl[:3]+[p[k][3]] for k,pl in enumerate(q)]
def vivid(p,k=3,up=2):
    # push each channel away from the colour's grey by k/8, plus a small lift; darkest kept
    out=[]
    for pal in p:
        np=[]
        for j,c in enumerate(pal):
            if j==3: np.append(c); continue
            g=sum(c)//3
            np.append(tuple(max(0,min(31,v+((v-g)*k)//8+up)) for v in c))
        out.append(np)
    return out
OPTS=[('clear (today)',8,(0,0,0)),('A  7, 31/31/24  subtle warm',7,(31,31,24)),('B  6, 31/30/20  golden',6,(31,30,20)),
      ('C  6, 31/28/14  amber',6,(31,28,14)),('D  7, 31/31/31  white lift',7,(31,31,31)),('E  B, darkest kept',-1,None),('F  vivid',-2,None)]
SCENES=[('johto','CherrygroveCity',20,(8,3,8,6),'spring',26),('johto','CherrygroveCity',20,(8,3,8,6),'summer',26),('kanto','PalletTown',10,(0,0,10,6),'summer',13)]
cols=[]
for ts,name,mw,crop,season,grp in SCENES:
    def tr(p,b,t):
        if b==-1: return keepdark(p,6,(31,30,20))
        if b==-2: return vivid(p)
        return sun(p,b,t)
    col=[render(ts,name,mw,crop,tr(pals(season,grp),b,t)) for _,b,t in OPTS]
    cols.append((f'{name} {season}',col))
cw=max(c[1][0].size[0] for c in cols); ch=cols[0][1][0].size[1]
LW=230; W=Image.new('RGB',(LW+len(cols)*(cw+8),20+len(OPTS)*(ch+8)),(40,40,40)); d=ImageDraw.Draw(W)
for k,(title,col) in enumerate(cols):
    d.text((LW+k*(cw+8)+4,4),title,fill=(255,255,255))
    for r,im in enumerate(col): W.paste(im,(LW+k*(cw+8),20+r*(ch+8)))
for r,(lab,_,_) in enumerate(OPTS): d.text((6,20+r*(ch+8)+ch//2),lab,fill=(255,255,255))
W.save('sun_options.png'); print(W.size)

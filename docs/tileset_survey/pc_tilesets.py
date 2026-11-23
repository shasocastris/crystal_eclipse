import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import re,os,sys,collections
R=f'{_ROMHACKS}/polishedcrystal/'
src=open(R+'data/tilesets.asm').read()
consts=[m.group(1) for m in re.finditer(r'^\s*tileset (\w+)',src,re.M)]
# label -> file
lab={}
pend=[]
for line in src.splitlines():
    m=re.match(r'\s*(\w+)::(?:\s*INCBIN "([^"]+)")?',line)
    if not m: continue
    pend.append(m.group(1))
    if m.group(2):
        for p in pend: lab[p]=m.group(2)
        pend=[]
empty=set(pend)
def tiles(f):
    # f like gfx/tilesets/x.2bpp.vram0.lzp or x.2bpp.lzp
    m=re.match(r'(.*\.2bpp)(?:\.vram(\d)(p?))?\.lzp$',f)
    d=open(R+m.group(1),'rb').read()
    if m.group(2) is not None:
        v=int(m.group(2)); d=d[v*128*16:(v+1)*128*16]
    n=len(d)//16
    ts=[d[i*16:(i+1)*16] for i in range(n)]
    return ts
rows=[]
for c in consts:
    slots=[]
    for s in ('GFX0','GFX1','GFX2'):
        f=lab.get(c+s)
        slots.append((f,tiles(f)) if f else (None,[]))
    mf=lab[c+'Meta'].replace('.lzp','')
    af=lab[c+'Attr'].replace('.lzp','')
    meta=open(R+mf,'rb').read(); attr=open(R+af,'rb').read()
    nb=len(meta)//16
    blocks=[(meta[i*16:i*16+16],attr[i*16:i*16+16]) for i in range(nb)]
    uniq=len(set(blocks))
    used=set()
    for i in range(len(meta)):
        used.add((meta[i], (attr[i]>>3)&1))
    rows.append((c,slots,nb,uniq,used,mf))
    
for c,slots,nb,uniq,used,mf in rows:
    cnt=[len(t) for f,t in slots]
    nonblank=[sum(1 for x in t if len(set(x))>1 or x[0] not in (0,)) for f,t in slots]
    # used tile refs by slot: slot0 = bank0 id<0x80, slot1 = bank1 id<0x80, slot2 = bank1 id>=0x80
    u0=sum(1 for t,b in used if b==0 and t<0x80); u1=sum(1 for t,b in used if b==1 and t<0x80); u2=sum(1 for t,b in used if b==1 and t>=0x80)
    ux=sum(1 for t,b in used if b==0 and t>=0x80)
    print(f"{c[7:]:20} {cnt[0]:4} {cnt[1]:4} {cnt[2]:4} {sum(cnt):4} | nb {nonblank[0]:3} {nonblank[1]:3} {nonblank[2]:3} | used {u0:3} {u1:3} {u2:3} x{ux:3} | blocks {nb:3} uniq {uniq:3} | {' / '.join(os.path.basename(f or '-').replace('.lzp','') for f,_ in slots)}")

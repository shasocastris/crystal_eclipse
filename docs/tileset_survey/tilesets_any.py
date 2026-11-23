import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import re,os,sys,collections
from PIL import Image
repo=sys.argv[1]; R=f'{_ROMHACKS}/'+repo+'/'
CFG={'crystal_eclipse':(['gfx/tilesets.asm'],['vTiles2GFX','vTiles5GFX','vTiles4GFX']),
     'polishedcoral':(['data/tilesets.asm'],['GFX0','GFX1','GFX2']),
     'JohtoLegends':(['gfx/tilesets.asm'],['GFX'])}
files,gl=CFG[repo]
lab={};pend=[]
for f in files:
    for line in open(R+f):
        m=re.match(r'\s*(?:DEF\s+)?(\w+)\s+EQU\s+0',line)
        if m: lab[m.group(1)]=None; continue
        m=re.match(r'\s*(\w+)::?\s*$',line) or re.match(r'\s*(\w+)::?\s*(?=INC)',line)
        if m: pend.append(m.group(1))
        m=re.search(r'INC(?:BIN|LUDE) "([^"]+)"',line)
        if m:
            for p in pend: lab[p]=m.group(1)
            pend=[]
tbl=[m.group(1) for m in re.finditer(r'^\s*tileset (\w+)',open(R+'data/tilesets.asm').read(),re.M) if m.group(1)!='Tileset0']
ctext=open(R+'constants/tileset_constants.asm').read().split('NUM_TILESETS')[0]
consts=[m.group(1) for m in re.finditer(r'^\s*const (TILESET_\w+)',ctext,re.M)]
assert len(tbl)==len(consts),(len(tbl),len(consts))
pc={}
def png(base):
    if base not in pc:
        im=Image.open(R+base+'.png').convert('L'); w,h=im.size; px=im.load(); mx=max(im.getdata())
        ts=[]
        for ty in range(h//8):
            for tx in range(w//8):
                ts.append(tuple(px[tx*8+x,ty*8+y] for y in range(8) for x in range(8)))
        pc[base]=(ts,mx)
    return pc[base]
def tiles(f):
    if not f: return []
    m=re.match(r'(.*)\.2bpp(?:\.(?:vram|vtiles)(\d))?(?:\.lz)?$',f)
    ts,mx=png(m.group(1))
    v=m.group(2)
    if v is None: return ts,mx
    i={'0':0,'1':1,'2':2}[v] if 'vram' in f else {'2':0,'5':1,'4':2}[v]
    return ts[i*128:(i+1)*128],mx
maps=collections.defaultdict(list)
for m in re.finditer(r'^\s*map (\w+),\s*(TILESET_\w+),\s*(\w+)',open(R+'data/maps/maps.asm').read(),re.M):
    maps[m.group(2)].append((m.group(1),m.group(3)))
print(f"# {repo}: {len(consts)} tilesets, {sum(len(v) for v in maps.values())} maps\n")
print("| Tileset | GFX0 | GFX1 | GFX2 | Drawn | Used | Blocks | Maps | gfx |")
out=[]
for c,t in zip(consts,tbl):
    sl=[]
    if repo=='JohtoLegends':
        ts,mx=tiles(lab[t+'GFX']); sl=[(ts[:128],mx),(ts[128:256],mx),([],0)]
        src=lab[t+'GFX']
    else:
        for g in gl:
            r=tiles(lab.get(t+g)); sl.append(r if r else ([],0))
        src=lab.get(t+gl[0]) or ''
    nb=[sum(1 for x in ts if any(p!=mx for p in x)) for ts,mx in sl]
    def raw(f):
        f=f.replace('.lz','')
        return open(R+f,'rb').read()
    meta=raw(lab[t+'Meta']); attr=raw(lab[t+'Attr'])
    assert len(meta)==len(attr),(t,len(meta),len(attr))
    used=set((meta[i],(attr[i]>>3)&1) for i in range(len(meta)))
    u=[sum(1 for i,b in used if b==0 and i<0x80),sum(1 for i,b in used if b==1 and i<0x80),sum(1 for i,b in used if b==1 and i>=0x80)]
    ux=sum(1 for i,b in used if b==0 and i>=0x80)
    base=os.path.basename(src).split('.')[0]
    print(f"| {c[8:]} | {nb[0]} | {nb[1]} | {nb[2]} | {sum(nb)} | {sum(u)}{'+x%d'%ux if ux else ''} | {len(meta)//16} | {len(maps[c])} | {base} |")
    env=collections.Counter(e for _,e in maps[c])
    out.append(f"\n## {c[8:]} — {len(maps[c])} maps ({', '.join(f'{k} {v}' for k,v in env.items())})\n"+', '.join(n for n,_ in maps[c]))
print('\n'.join(out))

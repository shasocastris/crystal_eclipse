import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import re,os,sys,glob,collections
B=f'{_ROMHACKS}/'
CFG={'polishedcrystal':(['data/tilesets.asm'],'polishedcrystal-3.2.3.map'),
 'crystal_eclipse':(['gfx/tilesets.asm'],'crystal_eclipse.map'),
 'polishedcoral':(['data/tilesets.asm'],'coral-in-progress.map'),
 'JohtoLegends':(['gfx/tilesets.asm'],'johtolegendsv0.1.map')}
for repo,(fs,mp) in CFG.items():
    R=B+repo+'/'
    paths=set()
    for f in fs:
        for m in re.finditer(r'INC(?:BIN|LUDE) "([^"]+)"',open(R+f).read()): paths.add(m.group(1))
    cat=collections.Counter(); miss=[]
    for p in sorted(paths):
        if p.endswith('collision.asm'):
            n=len(re.findall(r'^\s*tilecoll',open(R+p).read(),re.M))*4; cat['collision']+=n; continue
        if not os.path.exists(R+p): miss.append(p); continue
        s=os.path.getsize(R+p)
        k='gfx' if p.startswith('gfx/') else 'metatiles' if 'metatiles' in p else 'attributes' if 'attributes' in p else 'collision' if 'collision' in p else 'other:'+p
        cat[k]+=s
    # raw gfx size
    # map blocks
    txt=''
    for f in glob.glob(R+'data/maps/*.asm')+glob.glob(R+'maps/*.asm')[:0]:
        txt+=open(f).read()
    bl=set(re.findall(r'INCBIN "(maps/[^"]+)"',txt))
    bsz=sum(os.path.getsize(R+p) for p in bl if os.path.exists(R+p)); bm=[p for p in bl if not os.path.exists(R+p)]
    print(f"== {repo}: tileset files {len(paths)} missing {len(miss)} {miss[:3]}")
    for k,v in cat.items(): print(f"   {k:12} {v:8}")
    print(f"   TOTAL tileset {sum(cat.values())}")
    print(f"   map blocks: {len(bl)} files, {bsz} bytes, missing {len(bm)} {bm[:2]}")
    print('   '+' | '.join(l.strip() for l in open(R+mp).read().split('\n')[1:3]))

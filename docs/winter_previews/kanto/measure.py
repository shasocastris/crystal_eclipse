import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import re,collections
R=f'{_REPO_ROOT}/'
mc=open(R+'constants/map_constants.asm').read()
dims={k:(int(w),int(h)) for k,w,h in re.findall(r'map_const (\w+),\s*(\d+),\s*(\d+)',mc)}
maps=[(n,e) for n,t,e in re.findall(r'map\s+(\w+),\s*(TILESET_\w+),\s*(\w+)',open(R+'data/maps/maps.asm').read()) if t=='TILESET_KANTO' and e in('TOWN','ROUTE')]
print(len(maps),[n for n,e in maps])
m=open(R+'data/tilesets/kanto_metatiles.bin','rb').read(); a=open(R+'data/tilesets/kanto_attributes.bin','rb').read()
tc=collections.Counter(); tp=collections.defaultdict(collections.Counter); tb=collections.defaultdict(collections.Counter)
bc=collections.Counter()
for n,e in maps:
    const=re.sub(r'([a-z])([A-Z0-9])',r'\1_\2',n).upper()
    const=[k for k in dims if k.replace('_','')==n.upper()][0]
    w,h=dims[const]; blk=open(R+f'maps/{n}.ablk','rb').read()
    for b in blk[:w*h]:
        bc[b]+=1
        for i in range(16):
            t=m[b*16+i]+(128 if a[b*16+i]&8 else 0); tc[t]+=1; tp[t][a[b*16+i]&7]+=1; tb[t][b]+=1
tot=sum(tc.values())
PN='GRAY RED GREEN WATER YELLOW BROWN ROOF TEXT'.split()
cum=0
for t,c in tc.most_common():
    cum+=c
    print('$%02x %5.2f%% cum%5.1f  %s  blocks:%s'%(t,100*c/tot,100*cum/tot,' '.join(f'{PN[p]}:{n}' for p,n in tp[t].most_common()),' '.join('%02x'%b for b,_ in tb[t].most_common(12))))

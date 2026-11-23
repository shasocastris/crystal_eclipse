import sys
def load(p):
    d={}
    for l in open(p):
        if l.startswith(';') or not l.strip(): continue
        p=l.split()
        if len(p)!=2 or ":" not in p[0]: continue
        b,ad=p[0].split(":"); d[p[1]]=(int(b,16),int(ad,16))
    return d
old,new=load(sys.argv[1]),load(sys.argv[2])
bad=0
# SRAM: absolute addresses
for n,(b,a) in old.items():
    if 0xa000<=a<0xc000:
        if n not in new: print("SRAM gone:",n,hex(a)); continue
        if new[n]!=(b,a): print("SRAM MOVED",n,hex(a),hex(new[n][1])); bad+=1
for n,(b,a) in new.items():
    if 0xa000<=a<0xc000 and n not in old: print("SRAM new:",n,hex(a))
# saved WRAM blocks: offsets
for s,e in [('wPlayerData','wPlayerDataEnd'),('wCurMapData','wCurMapDataEnd'),('wPokemonData','wPokemonDataEnd')]:
    os_,oe=old[s][1],old[e][1]; ns,ne=new[s][1],new[e][1]
    print(f"{s}: old {os_:04x}-{oe:04x} new {ns:04x}-{ne:04x} len {oe-os_} -> {ne-ns}")
    if oe-os_!=ne-ns: bad+=1
    for n,(b,a) in old.items():
        if b==old[s][0] and os_<=a<oe and not n.startswith(('.','wPlayerData','wCurMapData','wPokemonData')) and '.' not in n:
            if n not in new: print("  saved label gone:",n,hex(a-os_)); continue
            if new[n][1]-ns!=a-os_: print("  OFFSET MOVED",n); bad+=1
print("BAD",bad)

import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import json,re
R=f'{_REPO_ROOT}/'
d=json.load(open('cur.json'));C=d['C'];mv=d['mv']
order=[re.match(r'\s*const\s+(\w+)',l).group(1) for l in open(R+'constants/type_constants.asm') if re.match(r'\s*const\s+\w+',l)]
typ={n:f[2] for n,f in mv}
rest=[n for n in C[1:] if n!='STRUGGLE']
new=['NO_MOVE']+sorted(rest,key=lambda n:order.index(typ[n]))  # stable
# STRUGGLE: last NORMAL
lastN=max(i for i,n in enumerate(new) if typ.get(n)=='NORMAL')
new.insert(lastN+1,'STRUGGLE')
assert sorted(new)==sorted(C)
ni={n:i for i,n in enumerate(new)}
start={}
for i,n in enumerate(new[1:],1):
    start.setdefault(typ[n],i)
print('type start ids:',{t:hex(v) for t,v in start.items()})
for n in ['KARATE_CHOP','STRUGGLE','SKETCH','ROLLOUT','FLY','DIG','VITAL_THROW','RECOVER','ICY_WIND','BLIZZARD','SUBSTITUTE','CURSE']:
    print(f'{n:12} old {C.index(n):#05x} new {ni[n]:#05x}')
print('>=0x100 after:',new[256:])
gen1_old=[n for n in C[1:142]]
print('old-gen1 moves (<=STRUGGLE) count',len(gen1_old))

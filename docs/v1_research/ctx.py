import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import json,re,os,collections
R=f'{_REPO_ROOT}/'
C=json.load(open('cur.json'))['C']
ns=sorted(set(C[1:]),key=len,reverse=True)
pat=re.compile(r'(?<![\w.])('+'|'.join(ns)+r')(?![\w.])')
ctx=collections.Counter(); hits=collections.defaultdict(list)
for d,_,fs in os.walk(R):
    if 'rgbds' in d or '/.git' in d: continue
    for f in fs:
        if not f.endswith('.asm'): continue
        p=os.path.join(d,f)[len(R):]
        if p.startswith(('data/moves/','constants/move_constants')): continue
        for i,l in enumerate(open(R+p,errors='ignore')):
            c=l.split(';')[0]
            for m in pat.finditer(c):
                op=c.strip().split()[0] if c.strip() else ''
                # skip things like ANIM text labels
                k=op
                ctx[k]+=1
                if op not in ('dw','dp','tmhm','dbw','learnset','egg_moves'): hits[op].append(f'{p}:{i+1}: {c.strip()}')
print(ctx.most_common(40))
for op,v in hits.items():
    print('==',op,len(v))
    for x in v[:200]:
        if op not in ('db',) or True: pass
    for x in v[:12]: print('  ',x)

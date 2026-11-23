import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import re,os,sys
root=f'{_REPO_ROOT}'
names=[]
for l in open(root+'/constants/move_constants.asm'):
    m=re.match(r'\s*const\s+(\w+)',l)
    if m and not m.group(1).startswith('ANIM_'): names.append(m.group(1))
ns=set(names)
pat=re.compile(r'\b('+'|'.join(sorted(ns,key=len,reverse=True))+r')\b')
for d,_,fs in os.walk(root):
    if 'rgbds' in d or '/.git' in d: continue
    for f in fs:
        if not f.endswith('.asm'): continue
        p=os.path.join(d,f)
        L=open(p,errors='ignore').read().split('\n')
        for i,l in enumerate(L):
            code=l.split(';')[0]
            if re.search(r'\bcp\b',code) and pat.search(code):
                nxt=' | '.join(x.strip() for x in L[i+1:i+4])
                if re.search(r'\b(jr|jp|jmp|ret|call)\s+(c|nc),',nxt) or re.search(r'\bret\s+n?c\b',nxt):
                    print(f'{p[len(root)+1:]}:{i+1}: {code.strip()}  -> {nxt}')

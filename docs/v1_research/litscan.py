import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import re,os
root=f'{_REPO_ROOT}'
for d,_,fs in os.walk(root):
    if 'rgbds' in d or '/.git' in d or '/tools' in d: continue
    for f in fs:
        if not f.endswith('.asm'): continue
        p=os.path.join(d,f);L=open(p,errors='ignore').read().split('\n')
        for i,l in enumerate(L):
            c=l.split(';')[0]
            if re.search(r'GetMoveIDFromIndex|GetMoveIndexFromID|GetMoveName|LockMoveID|GetMoveAddress|GetMoveAttr|GetMoveData|GetMoveByte',c):
                for j in range(max(0,i-6),i):
                    cj=L[j].split(';')[0]
                    if re.search(r'\bld\s+(hl|bc|de|a|l|c|e),\s*(\$[0-9a-fA-F]+|%[01]+|\d+)\s*$',cj.strip()):
                        print(f'{p[len(root)+1:]}:{j+1}: {cj.strip()}  ... {c.strip()} @{i+1}')

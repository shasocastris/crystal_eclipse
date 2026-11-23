import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import re,sys
def parse(p):
    banks={};cur=None
    for l in open(p):
        m=re.match(r'^ROMX bank #(\d+):',l)
        if m: cur=int(m.group(1)); banks[cur]={'secs':[],'free':0}; continue
        if l and not l[0].isspace(): cur=None if not l.startswith('ROMX') else cur
        if cur is None: continue
        m=re.search(r'SECTION: .*\["(.*)"\]',l)
        if m: banks[cur]['secs'].append(m.group(1))
        m=re.search(r'TOTAL EMPTY: \$([0-9a-f]+)',l)
        if m: banks[cur]['free']=int(m.group(1),16)
    return banks
r=parse(f'{_REPO_ROOT}/crystal_eclipse.map')
d=parse(f'{_REPO_ROOT}/crystal_eclipse_debug.map')
for b in sorted(r):
    print(f"${b:02x} rel={r[b]['free']:5d} dbg={d.get(b,{'free':-1})['free']:5d} | {'; '.join(r[b]['secs'])[:150]}")

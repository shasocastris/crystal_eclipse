import re,sys
def run(path):
    v=0;named=0;skip=0;gaps=0;unused=0
    for l in open(path):
        s=l.split(';')[0].strip()
        c=l.split(';',1)[1] if ';' in l else ''
        m=re.match(r'const_def\s*(\S+)?',s)
        if m: v=int(m.group(1).replace('$','0x'),0) if m.group(1) else 0; continue
        m=re.match(r'const_next\s+(\S+)',s)
        if m:
            n=int(m.group(1).replace('$','0x'),0); gaps+=n-v; v=n; continue
        m=re.match(r'const_skip\s*(\S+)?',s)
        if m: k=int(m.group(1)) if m.group(1) else 1; skip+=k; v+=k; continue
        m=re.match(r'const\s+(\w+)',s)
        if m:
            named+=1; v+=1
            if re.search(r'unused',c,re.I): unused+=1
    return v,named,skip,gaps,unused
for p in sys.argv[1:]:
    print(p, "final=%d named=%d skip=%d next_gaps=%d named_marked_unused=%d"%run(p))

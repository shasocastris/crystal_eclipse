import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
# Shared helper for the expanded-route builders: mix hand rows with vanilla hex.
CH = {'T':0x05,'.':0x01,',':0x02,'"':0x03,'*':0x04,'~':0x35,'(':0x54,'^':0x76,')':0x55,
      '[':0x58,']':0x59,'{':0x79,'}':0x7a,'_':0x56,'=':0x57,'o':0x0a,'#':0x61,'S':0x47,
      's':0x45,'C':0x73,
      'q':0x48,'w':0x49,'p':0x4a,'c':0x2c,'d':0x2d,'e':0x2e,'f':0x2f,'1':0x14,'2':0x15,
      'g':0x08,'h':0x09,'i':0x10,'j':0x11,'k':0x0b,
      'A':0x6a,'N':0x70,'K':0x6b,'L':0x68,'M':0x71,'J':0x69,'b':0x6c,'m':0x72,'n':0x6d,
      'W':0x6f,'E':0x6e,'B':0x89,'P':0x06,'H':0x43,'Q':0x36,'r':0x31,'R':0x32}
ROUGH = set('!?@$&+|<>%/')
POOL = [c for c in 'DFGIOUVXYZatuvxyz0356789:;-' if c not in CH and c not in ROUGH]

def vanilla(name, w):
    d = open(f'{_REPO_ROOT}/maps/{name}.ablk', 'rb').read()
    return [list(d[y*w:(y+1)*w]) for y in range(len(d)//w)]

def row(s):
    return [CH[c] for c in s]

def emit(fn, rows, W, head, tail):
    for i, r in enumerate(rows): assert len(r) == W, (i, len(r))
    rev = {v: k for k, v in CH.items()}
    used = sorted({b for r in rows for b in r})
    km = {}
    for b in used:
        km[b] = rev[b] if b in rev else POOL.pop(0)
    keys = ' '.join(f'{c}={b:02x}' for b, c in km.items() if c not in '.,"*T~()^[]{}_=o#SsC')
    g = '\n'.join(''.join(km[b] for b in r) for r in rows)
    open(fn, 'w').write(head + f'key {keys}\ngrid:\n{g}\nend\n' + tail)

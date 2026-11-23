import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import re, sys, os
R = f'{_REPO_ROOT}'
def base(sp):
    f = f'{R}/data/pokemon/base_stats/{sp.lower()}.asm'
    if not os.path.exists(f): return None
    for l in open(f):
        m = re.match(r'\s*db\s+(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+)', l)
        if m: return [int(x) for x in m.groups()]
def calc(b, dvs, evs, L):
    a, d, s, c = dvs
    hpdv = (a&1)<<3 | (d&1)<<2 | (s&1)<<1 | (c&1)
    dv = [hpdv, a, d, s, c, c]
    out = []
    for i in range(6):
        v = ((b[i]+dv[i])*2 + evs[i]//4) * L // 100
        out.append(v + (L + 10 if i == 0 else 5))
    return out
def entries():
    lines = open(f'{R}/data/battle_tower/parties.asm').read().split('\n')
    i = 0
    while i < len(lines):
        m = re.match(r'\tdw ([A-Z_0-9]+)$', lines[i])
        if m and i+1 < len(lines) and lines[i+2].startswith('\tdw ') and ',' in lines[i+2]:
            blk = lines[i:i+22]
            sp = m.group(1)
            evs = [int(x) for x in re.findall(r'\d+', blk[6].split(';')[0])]
            dvs = [int(x) for x in re.findall(r'\d+', blk[8].split(';')[0])]
            L = int(re.findall(r'\d+', blk[12])[0])
            st = [int(re.findall(r'\d+', blk[k])[0]) for k in (15,16,17,18,19,20)]  # maxhp atk def spd sat sdf
            yield i+1, sp, evs, dvs, L, st
            i += 22
        else:
            i += 1
if __name__ == '__main__':
    bad = 0; n = 0
    for ln, sp, evs, dvs, L, st in entries():
        b = base(sp); n += 1
        if b is None: print('nobase', ln, sp); continue
        c = calc(b, dvs, evs, L)
        if c != st:
            bad += 1
            if '-v' in sys.argv: print(ln, sp, st, c)
    print(n, 'entries', bad, 'mismatch')

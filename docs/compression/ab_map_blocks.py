"""A/B: for every map, lay out its blocks + connections on the baseline and new ROM and compare."""
import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import os, re, sys, pickle
H = f'{_REPO_ROOT}/docs/regression/harness'
sys.path.insert(0, H)
from fixtures import fixture

def maps():
    out, grp, num = [], 0, 0
    for l in open(f'{_REPO_ROOT}/constants/map_constants.asm'):
        if re.match(r'\s+newgroup\s', l):
            grp += 1; num = 0
        m = re.match(r'\s+map_const\s+(\w+),\s*(\d+),\s*(\d+)', l)
        if m:
            num += 1; out.append((m.group(1), grp, num, int(m.group(2)), int(m.group(3))))
    return out

def dump(rom):
    g = fixture('debug_party', rom=rom)
    assert g.run_until('PlayerEvents', 600)
    base = g.state(); res = {}
    for name, grp, num, w, h in maps():
        g.load(base)
        g.write('wMapGroup', grp); g.write('wMapNumber', num)
        try:
            g.call('CopyMapPartialAndAttributes')
            assert (g.read('wMapWidth'), g.read('wMapHeight')) == (w, h), name
            g.write('wOverworldMapBlocks', bytes(1300))
            g.call('ChangeMap')
            g.call('FillMapConnections')
            res[name] = bytes(g.read('wOverworldMapBlocks', 1300))
        except Exception as e:
            res[name] = 'ERR %r' % (e,)
    return res

if __name__ == '__main__':
    a = dump(sys.argv[1]); b = dump(sys.argv[2])
    bad = [n for n in a if a[n] != b[n]]
    err = [n for n in a if isinstance(a[n], str) or isinstance(b[n], str)]
    nonzero = sum(1 for n in a if not isinstance(a[n], str) and any(a[n]))
    print('maps', len(a), 'non-empty', nonzero, 'mismatch', len(bad), 'errors', len(err))
    for n in bad[:20]:
        print(' ', n, a[n][:60] if isinstance(a[n], str) else '', b[n][:60] if isinstance(b[n], str) else '')
    for n in err[:10]: print(' ERR', n, a[n] if isinstance(a[n], str) else '', b[n] if isinstance(b[n], str) else '')

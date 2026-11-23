"""A/B the Battle Tower level menu on two debug ROMs.
Timing differs (the old menu typed its own text), so each step records the screens that held still."""
import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import sys
R=f'{_REPO_ROOT}'
sys.path.insert(0, R+'/docs/regression/harness')
from fixtures import fixture
import suite_scenes as S
from visual import text_rows
from game import mon_write, species_id

def scr(g):
    return tuple(r.rstrip('·') for r in text_rows(g)[:18])
def stable(g, frames=900, hold=5):
    """Distinct screens that stayed unchanged for `hold` samples of 10 frames."""
    out, last, n = [], None, 0
    for _ in range(frames // 10):
        g.frames(10); s = scr(g)
        if s == last:
            n += 1
            if n == hold and (not out or out[-1] != s): out.append(s)
        else: last, n = s, 0
    return out
def party(g, lvl, uber):
    for s in range(3):
        mon_write(g, s, 'MON_LEVEL', lvl)
        sp = species_id(g, 'MEWTWO' if (uber and s == 1) else 'RATTATA')
        mon_write(g, s, 'MON_SPECIES', sp); g.write('wPartySpecies+%d' % s, sp)

def run(rom, shots):
    out = {}
    g = fixture('debug_party', rom=rom)
    S._tower_to_level_menu(g)
    out['open'] = stable(g, 600)
    base = g.state()
    if shots: g.screenshot(shots + '_open.png')
    seq = []
    for _ in range(12):
        g.press('up', hold=4, after=30); seq.append(scr(g)[9])
    for _ in range(12):
        g.press('down', hold=4, after=30); seq.append(scr(g)[9])
    out['scroll'] = seq
    g.load(base); g.press('b', hold=4, after=0); out['b_prompt'] = stable(g, 600)
    if shots: g.screenshot(shots + '_cancel.png')
    st = g.state()
    g.press('a', hold=4, after=0); out['cancel_yes'] = (stable(g, 900), g.read('wScriptVar'))
    g.load(st); g.press('b', hold=4, after=0); out['cancel_b'] = stable(g, 900)
    g.load(st); g.press('down', hold=4, after=30); g.press('a', hold=4, after=0); out['cancel_no'] = stable(g, 900)
    g.load(base); g.press('down', hold=4, after=30); g.press('a', hold=4, after=0); out['cancel_entry'] = stable(g, 600)
    for uber in (False, True):
        for lvl in (10, 40, 60, 70, 100):
            for pl in (5, 40, 65, 70, 100):
                g.load(base); party(g, pl, uber)
                for _ in range(lvl // 10 - 1): g.press('up', hold=4, after=30)
                g.press('a', hold=4, after=0)
                a = stable(g, 500)
                g.press('a', hold=4, after=0)   # the uber text has a second page
                out[('pick', uber, lvl, pl)] = (a, stable(g, 900), g.read('wScriptVar'), g.read('wcd4f'))
    return out

a = run(sys.argv[1], sys.argv[3] + '/old' if len(sys.argv) > 3 else None)
b = run(sys.argv[2], sys.argv[3] + '/new' if len(sys.argv) > 3 else None)
bad = 0
for k in a:
    if a[k] != b[k]:
        bad += 1; print('== DIFF', k)
        for tag, v in (('old', a[k]), ('new', b[k])):
            print('--', tag)
            for item in (v if isinstance(v, (list, tuple)) and v and not isinstance(v[0], str) else [v]):
                if isinstance(item, list):
                    for s_ in item: print('\n'.join(s_)); print('.')
                else: print(item)
print('steps', len(a), 'differing', bad)

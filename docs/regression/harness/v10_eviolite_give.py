"""EVIOLITE is a normal held item (GIVE/TOSS/QUIT), driven through the real menus.

    runner.py v10_eviolite_give --jobs 1
"""
import os

from consts import value
from game import mon_read, mon_write
from gb import HERE
from overworld import finish, in_control, item_qty, pick_party, set_item, wait_for, warp
from registry import check, test
from visual import text_rows

S = 'v10_eviolite_give'
OUT = os.path.join(HERE, '..', 'v10', 'eviolite_give')


def _shot(g, name):
    os.makedirs(OUT, exist_ok=True)
    g.screenshot(os.path.join(OUT, name + '.png'))


def _item_id(g, name):
    return g.call('GetItemIDFromIndex', hl=value(name))['a']


def _cursor_line(g):
    for r in text_rows(g):
        if '>' in r:
            return r[r.index('>'):]
    return ''


def _choose(g, word, tries=10):
    for _ in range(30):
        if _cursor_line(g):
            break
        g.frames(10)
    for _ in range(tries):
        if word in _cursor_line(g):
            g.press('a', after=40)
            return
        g.press('down', after=10)
    raise AssertionError('%r not found in menu: %r' % (word, text_rows(g)))


def _setup(g, item):
    warp(g, 'ROUTE_34', 11, 14)
    g.write('wNumItems', 0)
    g.write('wItems', 0xff)
    set_item(g, item, 1)
    mon_write(g, 0, 'MON_ITEM', 0)
    g.write('wCurPocket', 0)
    g.write('wItemsPocketCursor', 1)
    g.write('wItemsPocketScrollPosition', 0)


def _pack_submenu(g, item):
    _setup(g, item)
    g.press('start', after=30)
    _choose(g, 'PACK')
    g.frames(60)
    g.press('a', after=30)
    rows = text_rows(g)
    return [w for w in ('USE', 'GIVE', 'TOSS', 'SEL', 'QUIT') if any(w in r[12:] for r in rows)]


@test(S)
def give_menu_options(g):
    """Pack submenu: EVIOLITE and LEFTOVERS both offer GIVE/TOSS/QUIT."""
    base = g.state()
    out = {}
    for item in ('EVIOLITE', 'LEFTOVERS'):
        g.load(base)
        out[item] = _pack_submenu(g, item)
        _shot(g, 'menu_' + item)
    check(out['EVIOLITE'] == ['GIVE', 'TOSS', 'QUIT'], 'EVIOLITE menu wrong', out=out)
    check(out['LEFTOVERS'] == ['GIVE', 'TOSS', 'QUIT'], 'LEFTOVERS menu changed', out=out)
    return out


@test(S)
def give_from_pack(g):
    """Pack > EVIOLITE > GIVE > lead: the lead holds it and the bag is empty."""
    opts = _pack_submenu(g, 'EVIOLITE')
    check('GIVE' in opts, 'no GIVE', opts=opts)
    _choose(g, 'GIVE')
    check(any('To which' in r for r in text_rows(g)), 'party menu never opened', screen=text_rows(g))
    pick_party(g, 0)
    g.frames(60)
    _shot(g, 'pack_given')
    for _ in range(20):
        g.press('b', after=20)
        if in_control(g, 10):
            break
    held = mon_read(g, 0, 'MON_ITEM')[0]
    want = _item_id(g, 'EVIOLITE')
    check(held == want and item_qty(g, 'EVIOLITE') == 0, 'EVIOLITE not given',
          held=held, want=want, qty=item_qty(g, 'EVIOLITE'))
    return {'held': held}


@test(S)
def give_from_party_menu(g):
    """POKEMON > lead > ITEM > GIVE > EVIOLITE: no "can't be held", the lead holds it."""
    _setup(g, 'EVIOLITE')
    g.press('start', after=30)
    _choose(g, 'MON')
    g.frames(40)
    pick_party(g, 0)
    _choose(g, 'ITEM')
    _choose(g, 'GIVE')
    g.frames(60)
    rows_pack = text_rows(g)
    g.press('a', after=60)
    rows = text_rows(g)
    _shot(g, 'party_given')
    cant = any("held" in r and "can" in r.lower() for r in rows)
    finish(g, 'b', 60)
    held = mon_read(g, 0, 'MON_ITEM')[0]
    want = _item_id(g, 'EVIOLITE')
    check(not cant and held == want and item_qty(g, 'EVIOLITE') == 0, 'party-menu give failed',
          held=held, want=want, screen=rows, pack=rows_pack)
    return {'held': held}

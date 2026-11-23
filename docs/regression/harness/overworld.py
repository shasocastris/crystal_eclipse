"""Overworld helpers for scene tests: warp, face, talk, prompts, items, happiness.

Prompts are found with breakpoints on the routines that wait for input (YesNoBox,
PartyMenuSelect), so a test answers the exact menu it expects instead of counting frames.
"""
from consts import resolve, value
from game import mon_write
from registry import check

DIRS = {'down': 0x00, 'up': 0x04, 'left': 0x08, 'right': 0x0c}


def in_control(g, max_frames=30, stable=8):
    """True when the overworld loop runs with no script and the map is in HANDLE state for `stable`
    PlayerEvents calls in a row (one free call happens between a script ending and a scene script
    deferring a new one)."""
    run = 0
    for _ in range(max_frames + stable):
        if not g.run_until('PlayerEvents', max_frames):
            return False
        if g.read('wScriptRunning') == 0 and g.read('wMapStatus') == 2:
            run += 1
            if run >= stable:
                return True
        else:
            run = 0
            max_frames -= 1
            if max_frames <= 0:
                return False
    return False


def settle(g, frames=600):
    """Run until the player has control (no key presses)."""
    for _ in range(frames // 10):
        if in_control(g, 10):
            return True
    return False


def warp(g, map_name, x, y, before=None, surf=False):
    """Warp to MAP at (x, y) the way Script_warp does. `before(g)` runs right before the map
    loads, so flags it sets are seen by the map's callbacks."""
    v = resolve('GROUP_' + map_name, 'MAP_' + map_name)
    check(g.run_until('OverworldLoop.loop', 120), 'warp: not in the overworld loop')
    if before:
        before(g)
    g.write('wMapGroup', v['GROUP_' + map_name])
    g.write('wMapNumber', v['MAP_' + map_name])
    g.write('wXCoord', x)
    g.write('wYCoord', y)
    g.write('wDefaultSpawnpoint', 0xff)
    if surf:
        g.write('wPlayerState', value('PLAYER_SURF'))
    g.write('hMapEntryMethod', value('MAPSETUP_WARP'))
    g.write('wMapStatus', 1)
    ok = settle(g, 1200)
    check(ok, 'warp: never regained control', map=map_name)
    check((g.read('wMapGroup'), g.read('wMapNumber'), g.read('wXCoord'), g.read('wYCoord')) ==
          (v['GROUP_' + map_name], v['MAP_' + map_name], x, y), 'warp: wrong position', map=map_name,
          at=(g.read('wMapGroup'), g.read('wMapNumber'), g.read('wXCoord'), g.read('wYCoord')))
    return True


def face(g, direction):
    g.write('wPlayerDirection', DIRS[direction])


def wait_for(g, label, key='b', max_presses=200):
    """Advance text with `key` until the game enters `label`. Stops with no key held.
    B, not A: B advances text too, but in the overworld it cannot restart a conversation."""
    for _ in range(max_presses):
        if g.run_until(label, 6):
            return True
        g.hold(key, True)
        hit = g.run_until(label, 3)
        g.hold(key, False)
        if hit:
            return True
    return False


def finish(g, key='b', max_presses=300):
    """Advance text with `key` until the player has control again."""
    for _ in range(max_presses):
        if in_control(g, 6):
            return True
        g.press(key, hold=3, after=3)
    return False


def answer(g, yes=True):
    """Answer the yes/no box we just stopped at."""
    g.frames(4)
    if yes:
        g.press('a', hold=4, after=10)
    else:
        g.press('down', hold=4, after=6)
        g.press('a', hold=4, after=10)


def pick_party(g, slot=0, cancel=False):
    """Choose party slot (0-5) in the party menu we just stopped at, or cancel with B."""
    g.frames(20)
    if cancel:
        g.press('b', hold=4, after=20)
        return
    # the cursor remembers its last row, so steer to the slot instead of counting presses
    for _ in range(8):
        cur = g.read('wMenuCursorY') - 1
        if cur == slot:
            break
        g.press('down' if cur < slot else 'up', hold=4, after=8)
    check(g.read('wMenuCursorY') - 1 == slot, 'party cursor stuck', want=slot, at=g.read('wMenuCursorY') - 1)
    g.press('a', hold=4, after=20)


def interact(g, direction):
    """Face `direction` and press A once (starts the NPC/sign script)."""
    face(g, direction)
    g.frames(2)
    g.press('a', hold=4, after=4)


# --- inventory and party ---
def item_qty(g, item):
    idx = value(item)
    n = g.read('wNumItems')
    raw = g.read('wItems', n * 3)
    for i in range(n):
        if raw[3 * i] << 8 | raw[3 * i + 1] == idx:
            return raw[3 * i + 2]
    return 0


def set_item(g, item, qty):
    """Set the quantity of an item-pocket item (0 removes it)."""
    idx = value(item)
    n = g.read('wNumItems')
    rows = [g.read('wItems+%d' % (3 * i), 3) for i in range(n)]
    rows = [r for r in rows if (r[0] << 8 | r[1]) != idx]
    if qty:
        rows.append([idx >> 8, idx & 0xff, qty])
    flat = [b for r in rows for b in r] + [0xff]
    g.write('wNumItems', len(rows))
    g.write('wItems', flat)


def has_key_item(g, item):
    idx = value(item) & 0xff
    n = g.read('wNumKeyItems')
    return idx in g.read('wKeyItems', n) if n else False


def set_key_item(g, item, on=True):
    idx = value(item) & 0xff
    n = g.read('wNumKeyItems')
    items = [i for i in (g.read('wKeyItems', n) if n else []) if i != idx]
    if on:
        items.append(idx)
    g.write('wNumKeyItems', len(items))
    g.write('wKeyItems', items + [0xff])


def set_happiness(g, slot, h):
    mon_write(g, slot, 'MON_HAPPINESS', h)


def party_moves(g, slot):
    """Move constants (16-bit) known by a party slot."""
    from game import mon_read
    out = []
    for mid in mon_read(g, slot, 'MON_MOVES', 4):
        out.append(g.call('GetMoveIndexFromID', a=mid)['hl'] if mid else 0)
    return out


def object_hidden(g, hide_flag):
    from game import event
    return event(g, hide_flag)

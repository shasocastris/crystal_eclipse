"""v1.0 regression, area `overworld`: Silver Cave rules, travel unlocks, Fly, time, warps, palettes, maps.

Run: CE_REPO=<tree> runner.py v10_overworld --rom <tree's debug ROM> --jobs 1
Evidence goes to docs/regression/v10/overworld/.
"""
import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import os
import re

import gb
from consts import resolve, value
from fixtures import STEPS
from game import engine, event, set_engine, set_event
from overworld import face, finish, in_control, item_qty, set_item, settle, wait_for, warp
from registry import Skip, check, test
from visual import diff, text_rows

EVID = os.path.join(gb.HERE, '..', 'v10', 'overworld')
SC_MAPS = ['SILVER_CAVE_ROOM_1', 'SILVER_CAVE_ROOM_2', 'SILVER_CAVE_ROOM_3', 'SILVER_CAVE_ITEM_ROOMS',
           'SILVER_CAVE_UNDERBELLY']


def ev_path(name):
    os.makedirs(EVID, exist_ok=True)
    return os.path.join(EVID, name)


def is_head():
    return os.path.exists(os.path.join(gb.REPO, 'maps', 'SilverCaveRoom3.asm')) and \
        'RedRematchText' in open(os.path.join(gb.REPO, 'maps', 'SilverCaveRoom3.asm')).read()


def map_id(name):
    v = resolve('GROUP_' + name, 'MAP_' + name)
    return v['GROUP_' + name], v['MAP_' + name]


def here(g):
    return (g.read('wMapGroup'), g.read('wMapNumber'))


def pos(g):
    return (g.read('wXCoord'), g.read('wYCoord'))


def has_sym(g, name):
    return name in g.syms


# --- calls that need key presses (text boxes) ---
def start_call(g, label, a=0, hl=0, bc=None, de=None):
    bank, target = g.addr(label)
    ret_pc, sp = g.reg('pc'), g.reg('sp')
    ret_bank = g.rom_bank if ret_pc >= 0x4000 else -1
    g.write('hFarCallSavedA', a)
    g.write('hFarCallSavedL', hl & 0xff)
    g.write('hFarCallSavedH', hl >> 8)
    if bc is not None:
        g.set_reg('bc', bc)
    if de is not None:
        g.set_reg('de', de)
    g.set_reg('af', bank << 8)
    g.set_reg('hl', target)
    g.write(sp - 2, ret_pc & 0xff)
    g.write(sp - 1, ret_pc >> 8)
    g.set_reg('sp', sp - 2)
    g.set_reg('pc', g.syms['FarCall_hl'][1])
    return (ret_bank, ret_pc, sp)


def end_call(g, ctx, key='b', max_frames=3000, screens=None):
    """Run a start_call'd routine to its return, tapping `key` (None: no input). `screens` collects
    every distinct text screen seen on the way."""
    rb, rpc, sp = ctx
    end = g.frame + max_frames
    on = False
    while g.frame < end:
        if key:
            g.hold(key, on)
        if g.run_until((rb, rpc), 3):
            if g.reg('sp') == sp:
                if key:
                    g.hold(key, False)
                af = g.reg('af')
                return {'a': af >> 8, 'carry': bool(af & 0x10), 'bc': g.reg('bc'), 'de': g.reg('de'),
                        'hl': g.reg('hl')}
            gb._lib.sb_step(g.h)
            continue
        if screens is not None:
            s = '\n'.join(text_rows(g))
            if not screens or screens[-1] != s:
                screens.append(s)
        on = not on
    if key:
        g.hold(key, False)
    raise AssertionError('call did not return within %d frames' % max_frames)


def screen_has(screens, *words):
    return any(all(w in s for w in words) for s in screens)


def raw_warp(g, name, x, y, before=None):
    """Like overworld.warp, but returns once the map starts loading (a scene script may hold control)."""
    grp, num = map_id(name)
    check(g.run_until('OverworldLoop.loop', 120), 'warp: not in the overworld loop')
    if before:
        before(g)
    g.write('wMapGroup', grp)
    g.write('wMapNumber', num)
    g.write('wXCoord', x)
    g.write('wYCoord', y)
    g.write('wDefaultSpawnpoint', 0xff)
    g.write('hMapEntryMethod', value('MAPSETUP_WARP'))
    g.write('wMapStatus', 1)


def item_id(g, name):
    return g.call('GetItemIDFromIndex', hl=value(name))['a']


def run_queued(g):
    """Run wQueuedScript the way the start menu's callback would (memjump)."""
    g.write('wMapReentryScriptBank', g.read('wQueuedScriptBank'))
    g.write('wMapReentryScriptAddress', g.read('wQueuedScriptAddr', 2))
    g.write('wMapReentryScriptQueueFlag', 1)


def walk(g, direction, steps=1):
    for _ in range(steps):
        g.press(direction, hold=16, after=4)
        settle(g, 600)


# ======================================================================================
# Silver Cave (a26afd2c6, 1fb549fdf)
# ======================================================================================
def all_maps():
    """[(NAME, group, number)] for every map constant, in the source tree being tested."""
    src = open(os.path.join(gb.REPO, 'constants', 'map_constants.asm')).read()
    names = re.findall(r'^\s*map_const\s+(\w+)', src, re.M)
    v = resolve(*(['GROUP_' + n for n in names] + ['MAP_' + n for n in names]))
    return [(n, v['GROUP_' + n], v['MAP_' + n]) for n in names]


@test('v10_overworld')
def ow_silver_cave_gate_every_map(g):
    """IsInSilverCave over every map in the ROM: carry for exactly the 5 cave interiors (not Outside/PC)."""
    if not has_sym(g, 'IsInSilverCave'):
        raise Skip('no IsInSilverCave in this build (pre-feature)')
    saved = here(g)
    yes = []
    for n, grp, num in all_maps():
        g.write('wMapGroup', grp)
        g.write('wMapNumber', num)
        if g.call('IsInSilverCave')['carry']:
            yes.append(n)
    g.write('wMapGroup', saved[0])
    g.write('wMapNumber', saved[1])
    check(sorted(yes) == sorted(SC_MAPS), 'IsInSilverCave set is wrong', got=yes)
    return {'maps_checked': len(all_maps()), 'in_cave': yes}


SC_SPOTS = {  # a standable tile next to a warp in each map
    'SILVER_CAVE_ROOM_1': (9, 32), 'SILVER_CAVE_ROOM_2': (17, 30), 'SILVER_CAVE_ROOM_3': (10, 32),
    'SILVER_CAVE_ITEM_ROOMS': (13, 4), 'SILVER_CAVE_UNDERBELLY': (24, 31),
}
CONTROL_CAVES = {  # map: (spot, dig warp (n, map)) -- the dig destination is where an Escape Rope lands
    'UNION_CAVE_1F': ((17, 34), (1, 'ROUTE_33')),
    'ICE_PATH_1F': ((4, 18), (1, 'ROUTE_44')),
    'DIGLETTS_CAVE': ((3, 32), (10, 'VERMILION_CITY')),
}


def _set_dig(g, n, name):
    grp, num = map_id(name)
    g.write('wDigWarpNumber', [n, grp, num])


def _try_escape(g, routine, rope_qty=None):
    screens = []
    if rope_qty is not None:
        set_item(g, 'ESCAPE_ROPE', rope_qty)
        g.write('wCurItem', item_id(g, 'ESCAPE_ROPE'))
        g.write('wItemQuantityChange', 1)
    g.write('wUsingHMItem', 0)
    g.write('wCurPartyMon', 0)
    g.write('wQueuedScriptBank', 0)
    end_call(g, start_call(g, routine), screens=screens)
    return {'succeeded': g.read('wFieldMoveSucceeded'), 'queued': g.read('wQueuedScriptBank'),
            'hm_item': g.read('wUsingHMItem'), 'screens': screens,
            'rope_left': item_qty(g, 'ESCAPE_ROPE') if rope_qty is not None else None}


@test('v10_overworld')
def ow_silver_cave_no_rope_no_dig(g):
    """In each Silver Cave map (dig warp primed to Outside), Dig and the Escape Rope fail with the cave's
    text, queue nothing, keep the rope, and the player stays put in control. Dig never leaves wUsingHMItem."""
    base = g.state()
    out = {}
    for name in SC_MAPS:
        for routine in ('DigFunction', 'EscapeRopeEffect'):
            g.load(base)
            x, y = SC_SPOTS[name]
            warp(g, name, x, y)
            _set_dig(g, 2, 'SILVER_CAVE_OUTSIDE')
            r = _try_escape(g, routine, rope_qty=3 if routine == 'EscapeRopeEffect' else None)
            check(settle(g, 600), 'no control after the fail text', map=name, routine=routine)
            ctx = dict(map=name, routine=routine, succeeded=r['succeeded'], queued=r['queued'],
                       at=(here(g), pos(g)))
            check(here(g) == map_id(name) and pos(g) == (x, y), 'player left the cave', **ctx)
            check(r['succeeded'] != 1 and not r['queued'], 'escape was queued', **ctx)
            if routine == 'EscapeRopeEffect':
                check(r['rope_left'] == 3, 'Escape Rope consumed', left=r['rope_left'], **ctx)
            else:
                check(r['hm_item'] == 0, 'Dig left wUsingHMItem set (hides OAK on the next failed item)', **ctx)
            if is_head():
                check(screen_has(r['screens'], 'no paths'), 'Silver Cave fail text not shown', **ctx,
                      last=r['screens'][-1:] if r['screens'] else None)
            out['%s %s' % (name, routine)] = 'blocked'
    return out


@test('v10_overworld')
def ow_other_caves_rope_and_dig_work(g):
    """Control: in Union Cave 1F, Ice Path 1F and Mt. Moon, the Escape Rope and Dig still work: the
    rope is used up and the player lands at the dig warp's map."""
    base = g.state()
    out = {}
    for name, ((x, y), (n, dest)) in CONTROL_CAVES.items():
        for routine in ('DigFunction', 'EscapeRopeEffect'):
            g.load(base)
            warp(g, name, x, y)
            _set_dig(g, n, dest)
            r = _try_escape(g, routine, rope_qty=3 if routine == 'EscapeRopeEffect' else None)
            ctx = dict(map=name, routine=routine, succeeded=r['succeeded'], queued=r['queued'])
            check(r['queued'], 'no escape script queued in a normal cave', **ctx)
            run_queued(g)
            check(finish(g, max_presses=400), 'no control after escaping', **ctx)
            check(here(g) == map_id(dest), 'did not land at the dig destination', at=here(g), **ctx)
            if routine == 'EscapeRopeEffect':
                check(r['rope_left'] == 2, 'Escape Rope not consumed', left=r['rope_left'], **ctx)
            out['%s %s' % (name, routine)] = (here(g), pos(g))
    return out


@test('v10_overworld')
def ow_silver_cave_repel(g):
    """Repel in every Silver Cave map: CheckRepelEffect lets an encounter through, DoRepelStep keeps the
    count, using a Repel prints the cave's text and keeps it. Control (Union Cave): blocked, counts down."""
    if not has_sym(g, 'IsInSilverCave'):
        raise Skip('pre-feature build')
    base = g.state()
    out = {}
    for name in SC_MAPS + ['UNION_CAVE_1F', 'SILVER_CAVE_OUTSIDE']:
        in_cave = name in SC_MAPS
        g.load(base)
        spot = SC_SPOTS.get(name) or {'UNION_CAVE_1F': (17, 34), 'SILVER_CAVE_OUTSIDE': (18, 12)}[name]
        warp(g, name, *spot)
        g.write('wRepelEffect', 20)
        g.write('wCurPartyLevel', 2)  # far below the lead: a working Repel blocks it
        enc = g.call('CheckRepelEffect')['carry']
        for _ in range(5):
            g.call('DoRepelStep')
        left = g.read('wRepelEffect')
        set_item(g, 'REPEL', 2)
        g.write('wCurItem', item_id(g, 'REPEL'))
        screens = []
        end_call(g, start_call(g, 'RepelEffect'), screens=screens)
        r = dict(map=name, encounter=enc, after_5_steps=left, repel_after_use=g.read('wRepelEffect'),
                 repels=item_qty(g, 'REPEL'), text=screen_has(screens, 'no', 'effect here'))
        out[name] = r
        if in_cave:
            check(enc and left == 20 and r['repel_after_use'] == 20 and r['text'], 'Repel not suppressed', **r)
        else:
            check(not enc and left == 15 and not r['text'], 'Repel broken outside Silver Cave', **r)
    return out


@test('v10_overworld')
def ow_silver_cave_room1_repel_warning(g):
    """Entering Room 1 from Outside with a Repel active shows the warning once; without one, nothing."""
    if not is_head():
        raise Skip('pre-feature build')
    base = g.state()
    warp(g, 'SILVER_CAVE_OUTSIDE', 18, 12)
    g.write('wRepelEffect', 30)
    g.press('up', hold=20, after=4)
    screens = []
    for _ in range(100):
        g.frames(10)
        s = '\n'.join(text_rows(g))
        screens.append(s)
        if 'fills the cave' in s:
            break
    check(here(g) == map_id('SILVER_CAVE_ROOM_1'), 'did not enter Room 1', at=here(g))
    check(screen_has(screens, 'fills the cave'), 'no Repel warning on entering Room 1', last=screens[-1:])
    check(finish(g), 'no control after the warning')
    check(g.read('wSilverCaveRoom1SceneID') == 0, 'warning scene not reset')
    # walk back out and in without a Repel: no text
    g.load(base)
    warp(g, 'SILVER_CAVE_OUTSIDE', 18, 12)
    g.write('wRepelEffect', 0)
    g.press('up', hold=20, after=4)
    ok = settle(g, 1200)
    rows = text_rows(g)
    check(ok and here(g) == map_id('SILVER_CAVE_ROOM_1') and not any('fills the cave' in r for r in rows),
          'warning shown without a Repel', screen=rows)
    return {'warning_shown': True}


def _pokegear_from_start_menu(g):
    g.press('start', after=30)
    for _ in range(10):
        rows = text_rows(g)
        cur = g.read('wMenuCursorY')
        line = rows[2 * cur] if 2 * cur < 18 else ''
        if 'GEAR' in line:
            break
        g.press('down', after=8)
    else:
        raise AssertionError('POKEGEAR not found in the start menu')
    g.press('a', after=60)


def _exit_pokegear(g):
    for _ in range(10):
        g.press('b', after=30)
        if in_control(g, 10):
            return True
    return False


def _radio_text(g, knob):
    """Open the Pokegear radio, tune to `knob`, and return the bottom text rows."""
    _pokegear_from_start_menu(g)
    card = 3  # POKEGEARCARD_RADIO (defined in pokegear.asm, not constants/)
    for _ in range(6):
        if g.read('wPokegearCard') == card:
            break
        g.press('right', after=20)
    check(g.read('wPokegearCard') == card, 'radio card not reached', card=g.read('wPokegearCard'))
    g.write('wRadioTuningKnob', knob - 2)  # UP steps the knob by 2
    g.press('up', hold=3, after=60)
    rows = text_rows(g)
    shot = g.screenshot()
    check(_exit_pokegear(g), 'no control after closing the Pokegear')
    return rows, shot


@test('v10_overworld')
def ow_silver_cave_radio(g):
    """Pokegear radio tuned to the #MON Music frequency: out of the broadcast area in each Silver Cave
    map, a station again at Silver Cave Outside (after walking out of Room 1) and in Goldenrod."""
    g.render(True)
    base = g.state()
    knob = 28  # Pokemon Music
    out = {}
    for name in SC_MAPS + ['SILVER_CAVE_OUTSIDE', 'GOLDENROD_CITY']:
        g.load(base)
        spot = SC_SPOTS.get(name) or {'SILVER_CAVE_OUTSIDE': (18, 12), 'GOLDENROD_CITY': (14, 22)}[name]
        warp(g, name, *spot)
        if name == 'SILVER_CAVE_OUTSIDE':  # really leave the cave: walk out of Room 1's door
            warp(g, 'SILVER_CAVE_ROOM_1', 9, 32)
            g.press('down', hold=20, after=4)
            check(settle(g, 1200) and here(g) == map_id('SILVER_CAVE_OUTSIDE'), 'did not walk out', at=here(g))
        rows, shot = _radio_text(g, knob)
        shot.save(ev_path('radio_%s.png' % name.lower()))
        txt = ' '.join(rows)
        out[name] = [r.strip('·').strip() for r in rows if r.strip('· ')]
        out_of_area = 'broadcast' in txt
        if name in SC_MAPS:
            if is_head():
                check(out_of_area, 'radio still plays inside Silver Cave', map=name, rows=rows)
        else:
            check(not out_of_area and ('Music' in txt or 'MUSIC' in txt), 'radio dead outside the cave',
                  map=name, rows=rows)
    return out


# --- Red rematch ---
def _battle(g, win, limit=4000):
    """Mash A through a battle. win: foe HP 1 at each menu; lose: our HP 1, foe untouchable."""
    from battle import fast_options
    fast_options(g)
    for _ in range(limit):
        hit = g.run_until_any(['LoadBattleMenu', 'CleanUpBattleRAM', 'PartyMenuSelect', 'YesNoBox', 'HalveMoney', 'RedCredits'], 20)
        if hit in ('CleanUpBattleRAM', 'HalveMoney', 'RedCredits'):  # HalveMoney: the whiteout script after a loss
            return True
        if hit == 'YesNoBox':  # "Use next #MON?" or the like: no
            g.frames(4)
            g.press('b', after=10)
            continue
        if hit == 'PartyMenuSelect':  # send in the first mon still standing
            from game import mon_word
            alive = [i for i in range(g.read('wPartyCount')) if mon_word(g, i, 'MON_HP')]
            g.frames(20)
            if alive:
                g.write('wMenuCursorY', alive[0] + 1)
            g.press('a', after=20)
            continue
        if hit == 'LoadBattleMenu':
            if win:
                g.write('wEnemyMonHP', [0, 1])
                g.write('wEnemyMonType', [0, 0])
                g.write('wBattleMonHP', g.read('wBattleMonMaxHP', 2))
            else:
                g.write('wBattleMonHP', [0, 1])
                g.write('wEnemyMonHP', [0x03, 0xe7])
                g.write('wEnemyMonMaxHP', [0x03, 0xe7])
                g.write('wPlayerAccLevel', 1)
        g.press('a', hold=3, after=0)
    return False


def _faint_bench(g):
    from game import mon_write
    for slot in range(1, g.read('wPartyCount')):
        mon_write(g, slot, 'MON_HP', [0, 0])


def _talk_red(g, direction):
    face(g, direction)
    g.frames(2)
    g.press('a', hold=4, after=4)
    return wait_for(g, 'StartBattle', key='b', max_presses=200)


@test('v10_overworld')
def ow_red_rematch_after_whiteout(g):
    """Lose to Red: white out healed beside him at (9,10) in Room 3, facing him, with the respawn already
    back on Silver Cave Outside. Talk again: the rematch starts. Win it: Red leaves, respawn is Outside."""
    set_event(g, 'EVENT_RED_IN_MT_SILVER', False)
    before_spawn = (g.read('wLastSpawnMapGroup'), g.read('wLastSpawnMapNumber'))
    warp(g, 'SILVER_CAVE_ROOM_3', 10, 11)
    _faint_bench(g)
    check(_talk_red(g, 'up'), 'Red battle never started')
    money = g.read('wMoney', 3)
    check(_battle(g, win=False), 'losing battle never ended')
    check(finish(g, max_presses=400), 'no control after whiting out')
    g.render(True)
    g.frames(30)
    shot = g.screenshot(ev_path('red_after_whiteout_%s.png' % ('head' if is_head() else 'v09')))
    from game import mon_word
    got = dict(map=here(g), xy=pos(g), facing=g.read('wPlayerDirection'),
               spawn=(g.read('wLastSpawnMapGroup'), g.read('wLastSpawnMapNumber')),
               scene=g.read('wSilverCaveRoom3SceneID'),
               hp_full=all(mon_word(g, s, 'MON_HP') == mon_word(g, s, 'MON_MAXHP') for s in range(g.read('wPartyCount'))),
               money_before=money, money_after=g.read('wMoney', 3), spawn_before=before_spawn)
    if not is_head():
        return dict(note='v0.9 has no rematch spawn', **got)
    check(got['map'] == map_id('SILVER_CAVE_ROOM_3') and got['xy'] == (9, 10), 'not respawned beside Red', **got)
    check(got['hp_full'], 'party not healed after whiteout', **got)
    check(got['spawn'] == map_id('SILVER_CAVE_OUTSIDE'), 'respawn not reset to Silver Cave Outside', **got)
    check(got['scene'] == 0, 'rematch scene left set', **got)
    check(got['facing'] == 0x0c, 'player not facing Red', **got)
    check(not event(g, 'EVENT_RED_IN_MT_SILVER'), 'Red gone after a loss', **got)
    # rematch, win
    g.render(False)
    check(_talk_red(g, 'right'), 'Red rematch never started', **got)
    check(_battle(g, win=True), 'winning battle never ended')
    for _ in range(400):  # Red's farewell text, then the credits roll
        if event(g, 'EVENT_RED_IN_MT_SILVER'):
            break
        g.press('b', hold=3, after=3)
    g.frames(120)
    got2 = dict(map=here(g), spawn=(g.read('wLastSpawnMapGroup'), g.read('wLastSpawnMapNumber')),
                scene=g.read('wSilverCaveRoom3SceneID'), red_gone=event(g, 'EVENT_RED_IN_MT_SILVER'))
    check(got2['spawn'] == map_id('SILVER_CAVE_OUTSIDE') and got2['scene'] == 0, 'respawn/scene after win', **got2)
    check(got2['red_gone'], 'Red still there after the win', **got2)
    return dict(after_loss=got, after_win=got2)


# ======================================================================================
# Travel: Fly, cross-region Fly, weather map, overcast, ORANGE PASS (941d65f04, f2e01e5ce)
# ======================================================================================
def flypoints(g):
    """[(index, landmark, spawn, (map group, map number, x, y))] from the ROM tables."""
    from game import rom_byte
    out = []
    n = value('NUM_FLYPOINTS')
    for i in range(n):
        lm, sp = rom_byte(g, 'Flypoints', 2 * i, 2)
        out.append((i, lm, sp, tuple(rom_byte(g, 'SpawnPoints', 4 * sp, 4))))
    return out


def _unlock_fly(g, cross=True, orange=True):
    set_engine(g, 'ENGINE_STORMBADGE')
    g.write('wStatusFlags', g.read('wStatusFlags') | 1 << value('STATUSFLAGS_HALL_OF_FAME_F'))
    if has_sym(g, 'wFlyMapPage'):
        bit = 1 << value('STATUSFLAGS2_CROSS_REGION_FLY_F')
        f2 = g.read('wStatusFlags2')
        g.write('wStatusFlags2', f2 | bit if cross else f2 & ~bit & 0xff)
    if orange:
        for f in ('ENGINE_FLYPOINT_VALENCIA', 'ENGINE_FLYPOINT_SHAMOUTI'):
            try:
                set_engine(g, f)
            except Exception:
                pass


def fly_open(g):
    """Start FlyFunction (as the party menu would) and stop in the Fly map's input loop."""
    g.write('wCurPartyMon', 0)
    g.write('wQueuedScriptBank', 0)
    ctx = start_call(g, 'FlyFunction')
    return ctx, g.run_until('_FlyMap.loop', 600)


def fly_cursor(g):
    return g.read('wTownMapPlayerIconLandmark')


def fly_press(g, key):
    g.press(key, hold=2, after=12)
    check(g.run_until('_FlyMap.loop', 60), 'Fly map loop lost after %s' % key)


def fly_finish(g, ctx, key='a'):
    g.press(key, hold=2, after=2)
    end_call(g, ctx, key=None, max_frames=600)
    return g.read('wFieldMoveSucceeded')


def landing_ok(g):
    """Standing tile: land permission, not a warp collision, not on a warp_event."""
    from game import rom_byte
    coll = g.read('wPlayerTileCollision')
    perm = rom_byte(g, 'CollisionPermissionTable', coll)[0]
    warp_coll = g.call('CheckWarpCollision')['carry']
    return {'collision': coll, 'land': perm & 0x0f == 0, 'warp_tile': warp_coll}


SRC_FOR_REGION = {0: ('GOLDENROD_CITY', 14, 22), 1: ('SAFFRON_CITY', 9, 30), 2: ('VALENCIA_ISLAND', 9, 6)}


def _region_of_fp(g, i):
    k, o = value('KANTO_FLYPOINT'), value('ORANGE_FLYPOINT')
    return 0 if i < k else (1 if i < o else 2)


def _warp_events_at(map_name):
    """warp_event coordinates of a map, from its asm."""
    src = open(os.path.join(gb.REPO, 'data', 'maps', 'maps.asm')).read()
    # map constant -> file: MAP_FOO_BAR -> FooBar; match by stripping underscores, case-insensitive
    key = map_name.replace('_', '').lower()
    for camel in re.findall(r'^\s*map\s+(\w+),', src, re.M):
        if camel.lower() == key:
            asm = open(os.path.join(gb.REPO, 'maps', camel + '.asm')).read()
            return {(int(x), int(y)) for x, y in re.findall(r'warp_event\s+(\d+),\s*(\d+)', asm)}
    return set()


def _map_asm(map_name):
    src = open(os.path.join(gb.REPO, 'data', 'maps', 'maps.asm')).read()
    key = map_name.replace('_', '').lower()
    for camel in re.findall(r'^\s*map\s+(\w+),', src, re.M):
        if camel.lower() == key:
            return open(os.path.join(gb.REPO, 'maps', camel + '.asm')).read()
    return ''


def _backup_warp_for(map_name, x, y):
    """For a -1 warp (elevators, Pokecenter 2F): the backup warp the game would have saved on entry,
    i.e. the warp in the destination map that leads here. None for an ordinary warp."""
    for wx, wy, dest, num in re.findall(r'warp_event\s+(\d+),\s*(\d+),\s*(\w+),\s*(-?\d+)', _map_asm(map_name)):
        if (int(wx), int(wy)) == (x, y) and num == '-1' and dest != map_name:
            back = re.findall(r'warp_event\s+\d+,\s*\d+,\s*(\w+),', _map_asm(dest))
            return dest, (back.index(map_name) + 1 if map_name in back else 1)
    return None


def _map_name(grp, num):
    for n, gr, nu in _MAPS_CACHE.setdefault('m', all_maps()):
        if (gr, nu) == (grp, num):
            return n
    return None


_MAPS_CACHE = {}


@test('v10_overworld')
def ow_fly_every_point(g):
    """Fly through the real Fly map to every flypoint, from a town in its own region (cursor moved with
    UP): the player lands on the spawn, on a walkable non-warp tile, not on a warp_event, in control."""
    _unlock_fly(g, cross=False)
    base = g.state()
    out, bad = {}, []
    for i, lm, sp, (grp, num, x, y) in flypoints(g):
        region = _region_of_fp(g, i)
        g.load(base)
        warp(g, *SRC_FOR_REGION[region])
        ctx, ok = fly_open(g)
        check(ok, 'Fly map did not open', flypoint=i)
        for _ in range(30):
            if fly_cursor(g) == i:
                break
            fly_press(g, 'up')
        if fly_cursor(g) != i:
            bad.append((i, 'cursor never reached it'))
            continue
        succ = fly_finish(g, ctx)
        check(succ == 1, 'Fly refused', flypoint=i, succeeded=succ)
        run_queued(g)
        ctl = settle(g, 3000)
        name = _map_name(grp, num)
        r = dict(map=name, at=(here(g), pos(g)), want=((grp, num), (x, y)), control=ctl, **landing_ok(g))
        r['on_warp_event'] = (x, y) in _warp_events_at(name or '')
        out[i] = r
        if not ctl or r['at'] != r['want'] or not r['land'] or r['warp_tile'] or r['on_warp_event']:
            bad.append((i, r))
            g.render(True)
            g.frames(2)
            g.screenshot(ev_path('fly_bad_%02d_%s.png' % (i, name)))
            g.render(False)
    check(not bad, 'bad Fly landings', bad=bad)
    return {i: (r['map'], r['at'][1]) for i, r in out.items()}


@test('v10_overworld')
def ow_indigo_fly_point(g):
    """f2e01e5ce: the Indigo Plateau spawn is Route 23 (10,6), walkable, not a warp, and one step up
    enters the League's Pokecenter (the right door)."""
    fp = [f for f in flypoints(g) if f[1] == value('LANDMARK_INDIGO_PLATEAU')]
    check(fp, 'no Indigo flypoint')
    grp, num, x, y = fp[0][3]
    warp(g, 'ROUTE_23', x, y)
    r = dict(spawn=(x, y), **landing_ok(g))
    check(r['land'] and not r['warp_tile'], 'Indigo spawn tile not walkable/non-warp', **r)
    g.press('up', hold=20, after=4)
    settle(g, 1200)
    r['after_up'] = _map_name(*here(g))
    check(r['after_up'] == 'INDIGO_PLATEAU_POKECENTER_1F', 'up from the spawn is not the League door', **r)
    return r


def _fly_map_bg(g):
    return (g.read('wTilemap+%d' % (20 * 2), 20 * 16), g.read('wBGPals1', 64))


@test('v10_overworld')
def ow_fly_cross_region(g):
    """Fly map, LEFT/RIGHT: nothing without the unlock; with it, Johto<->Kanto swap pages onto a visited
    flypoint and the page is drawn as the native one (BG tilemap rows 2-17 and BG palettes equal);
    the Orange map never switches; no visited Kanto flypoint: RIGHT stays put. Then fly across."""
    if not has_sym(g, 'wFlyMapPage'):
        raise Skip('pre-feature build')
    g.render(True)
    _unlock_fly(g, cross=True)
    base = g.state()
    k = value('KANTO_FLYPOINT')
    out = {}
    # native Kanto page, cursor on the first visited Kanto flypoint
    warp(g, 'SAFFRON_CITY', 9, 30)
    ctx, ok = fly_open(g)
    check(ok, 'Kanto Fly map did not open')
    for _ in range(30):
        if fly_cursor(g) == k:
            break
        fly_press(g, 'up')
    native_kanto = _fly_map_bg(g)
    g.screenshot(ev_path('fly_kanto_native.png'))
    # without the unlock
    g.load(base)
    _unlock_fly(g, cross=False)
    warp(g, 'GOLDENROD_CITY', 14, 22)
    ctx, ok = fly_open(g)
    c0 = fly_cursor(g)
    fly_press(g, 'right')
    fly_press(g, 'left')
    out['locked'] = dict(cursor=(c0, fly_cursor(g)), page=g.read('wFlyMapPage'))
    check(fly_cursor(g) == c0 and g.read('wFlyMapPage') == 0, 'LEFT/RIGHT moved without the unlock', **out['locked'])
    # with the unlock
    g.load(base)
    warp(g, 'GOLDENROD_CITY', 14, 22)
    ctx, ok = fly_open(g)
    johto = _fly_map_bg(g)
    g.screenshot(ev_path('fly_johto_start.png'))
    fly_press(g, 'right')
    g.frames(10)
    g.screenshot(ev_path('fly_johto_to_kanto.png'))
    out['right'] = dict(cursor=fly_cursor(g), page=g.read('wFlyMapPage'),
                        start=g.read('wStartFlypoint'), end=g.read('wEndFlypoint'))
    check(out['right']['page'] == 1 and out['right']['cursor'] == k, 'RIGHT did not switch to Kanto', **out['right'])
    kt = _fly_map_bg(g)
    check(kt[0] == native_kanto[0], 'Kanto page tilemap differs from the native Kanto Fly map')
    check(kt[1] == native_kanto[1], 'Kanto page BG palettes differ from the native Kanto Fly map')
    # UP stays in Kanto
    seen = set()
    for _ in range(20):
        fly_press(g, 'up')
        seen.add(fly_cursor(g))
    out['kanto_up_range'] = sorted(seen)
    check(all(i >= k for i in seen), 'UP left Kanto after switching', seen=sorted(seen))
    fly_press(g, 'left')
    g.frames(10)
    g.screenshot(ev_path('fly_kanto_to_johto.png'))
    out['left'] = dict(cursor=fly_cursor(g), page=g.read('wFlyMapPage'))
    check(out['left']['page'] == 0 and out['left']['cursor'] < k, 'LEFT did not switch back to Johto', **out['left'])
    check(_fly_map_bg(g)[0] == johto[0], 'Johto page tilemap differs after a round trip')
    # fly across: RIGHT then A lands at the first Kanto flypoint
    fly_press(g, 'right')
    succ = fly_finish(g, ctx)
    run_queued(g)
    check(succ == 1 and settle(g, 3000), 'cross-region Fly did not complete', succeeded=succ)
    out['landed'] = (_map_name(*here(g)), pos(g))
    check(out['landed'][0] == 'PALLET_TOWN', 'cross-region Fly landed in the wrong place', **out)
    # Orange: no switch
    g.load(base)
    warp(g, 'VALENCIA_ISLAND', 9, 6)
    ctx, ok = fly_open(g)
    check(ok, 'Orange Fly map did not open')
    c0, p0 = fly_cursor(g), g.read('wFlyMapPage')
    fly_press(g, 'right')
    fly_press(g, 'left')
    out['orange'] = dict(cursor=(c0, fly_cursor(g)), page=(p0, g.read('wFlyMapPage')))
    check(fly_cursor(g) == c0 and g.read('wFlyMapPage') == p0 == value('ORANGE_REGION'), 'Orange map switched', **out['orange'])
    # no Kanto flypoint visited: RIGHT does nothing
    g.load(base)
    for f in ('PALLET', 'VIRIDIAN', 'PEWTER', 'CERULEAN', 'VERMILION', 'ROCK_TUNNEL', 'LAVENDER', 'CELADON',
              'SAFFRON', 'FUCHSIA', 'CINNABAR', 'INDIGO_PLATEAU'):
        set_engine(g, 'ENGINE_FLYPOINT_' + f, False)
    warp(g, 'GOLDENROD_CITY', 14, 22)
    ctx, ok = fly_open(g)
    c0 = fly_cursor(g)
    fly_press(g, 'right')
    out['no_kanto'] = dict(cursor=(c0, fly_cursor(g)), page=g.read('wFlyMapPage'))
    check(fly_cursor(g) == c0 and g.read('wFlyMapPage') == 0, 'switched to a Kanto with nothing visited', **out['no_kanto'])
    fly_finish(g, ctx, key='b')
    check(settle(g, 600), 'no control after cancelling Fly')
    return out


@test('v10_overworld')
def ow_fly_denied(g):
    """Fly fails (no map, no warp) indoors, inside Silver Cave, and without the STORMBADGE."""
    base = g.state()
    out = {}
    cases = [('CHERRYGROVE_POKECENTER_1F', 3, 4, True), ('SILVER_CAVE_ROOM_2', 17, 30, True),
             ('GOLDENROD_CITY', 14, 22, False)]
    for name, x, y, badge in cases:
        g.load(base)
        _unlock_fly(g)
        if not badge:
            set_engine(g, 'ENGINE_STORMBADGE', False)
        warp(g, name, x, y)
        g.write('wQueuedScriptBank', 0)
        screens = []
        end_call(g, start_call(g, 'FlyFunction'), screens=screens, max_frames=1200)
        r = dict(succeeded=g.read('wFieldMoveSucceeded'), queued=g.read('wQueuedScriptBank'),
                 fly_map=any('FLY' in s or 'Where' in s for s in screens))
        check(settle(g, 600), 'no control after a refused Fly', map=name)
        r['at'] = (_map_name(*here(g)), pos(g))
        out['%s badge=%s' % (name, badge)] = r
        check(r['succeeded'] != 1 and not r['queued'] and r['at'] == (name, (x, y)), 'Fly not refused',
              map=name, **r)
    return out


# --- Pokegear weather map ---
WEATHER_NAMES = ['-----', 'CLEAR', 'RAINY', 'SNOWY', 'STORM', 'DUSTY', 'BLOOM', 'SUNNY', 'CLOUD']


def _maps_table():
    """[(NAME, CamelName, environment, landmark)] in MapGroupPointers order (data/maps/maps.asm)."""
    if 'tbl' in _MAPS_CACHE:
        return _MAPS_CACHE['tbl']
    src = open(os.path.join(gb.REPO, 'data', 'maps', 'maps.asm')).read()
    rows = re.findall(r'^\s*map\s+(\w+),\s*\w+,\s*(\w+),\s*(\w+),', src, re.M)
    names = [n for n, _, _ in all_maps()]
    key = {n.replace('_', '').lower(): n for n in names}
    lms = resolve(*sorted({lm for _, _, lm in rows}))
    out = [(key.get(c.lower()), c, env, lms[lm]) for c, env, lm in rows]
    _MAPS_CACHE['tbl'] = out
    return out


def _first_outdoor_map(landmark):
    for n, camel, env, lm in _maps_table():
        if lm == landmark and env in ('TOWN', 'ROUTE'):
            return n, camel
    return None, None


def _pokegear_map_card(g):
    _pokegear_from_start_menu(g)
    for _ in range(6):
        if g.read('wPokegearCard') == 1:  # POKEGEARCARD_MAP
            break
        g.press('right', after=20)
    check(g.read('wPokegearCard') == 1, 'map card not reached')
    g.frames(30)


def _weather_label(g, landmark):
    from visual import text_rows as tr
    row = tr(g)[16]
    region = 0 if landmark < value('KANTO_LANDMARK') or landmark == value('LANDMARK_FAST_SHIP') else 1
    return row[1:6] if region == 0 else row[14:19]


@test('v10_overworld')
def ow_weather_map_every_landmark(g):
    """Pokegear map with the weather upgrade, opened in Johto, Kanto and the Orange Islands: UP through every
    landmark of the region. Each label is one of the nine names; each named sky matches the weather the
    player gets on arrival at that landmark's first outdoor map; the map exits cleanly."""
    if not has_sym(g, 'PokegearMap_PlaceWeather'):
        raise Skip('pre-feature build')
    g.render(True)
    set_event(g, 'EVENT_AZALEA_TOWN_SLOWPOKES', True)
    g.write('wPokegearFlags', g.read('wPokegearFlags') | 1 << value('POKEGEAR_WEATHER_MAP_F'))
    g.write('wStatusFlags', g.read('wStatusFlags') | 1 << value('STATUSFLAGS_HALL_OF_FAME_F'))
    base = g.state()
    labels, bad = {}, []
    for region, (town, x, y) in SRC_FOR_REGION.items():
        g.load(base)
        warp(g, town, x, y)
        _pokegear_map_card(g)
        g.screenshot(ev_path('weathermap_%s.png' % town.lower()))
        seen = []
        for _ in range(80):
            lm = g.read('wPokegearMapCursorLandmark')
            if lm in seen:
                break
            seen.append(lm)
            lab = _weather_label(g, lm)
            labels[lm] = lab
            if lab not in WEATHER_NAMES:
                bad.append(('garbled label', region, lm, lab))
                g.screenshot(ev_path('weathermap_bad_%d.png' % lm))
            g.press('up', hold=2, after=16)
        check(_exit_pokegear(g), 'no control after closing the Pokegear', region=region)
        check(len(seen) > 1, 'cursor did not move on the map card', region=region)
    # the oracle: arrive at each landmark's first outdoor map and read the weather
    arrivals = {}
    for lm, lab in labels.items():
        name, camel = _first_outdoor_map(lm)
        if not name:
            if lab != '-----':
                bad.append(('sky for a landmark with no outdoor map', lm, lab))
            continue
        wps = sorted(_warp_events_at(name))
        if not wps:
            continue
        g.load(base)
        try:
            warp(g, name, *wps[0])
        except AssertionError:
            continue
        got = WEATHER_NAMES[g.read('wCurWeather') + 1]
        arrivals[lm] = (name, lab, got)
        if got != lab:
            bad.append(('label != arrival weather', lm, name, lab, got))
    check(not bad, 'weather map problems', bad=bad[:20], n=len(bad))
    return {'landmarks': len(labels), 'compared': len(arrivals),
            'labels': {k: v for k, v in sorted(labels.items())}}


# --- overcast ---
@test('v10_overworld')
def ow_overcast_palette_only(g):
    """Goldenrod forced overcast vs none: BG palettes dimmed, no OAM reservation, no particles, no battle
    weather; a Route forced overcast also gives no battle weather."""
    try:
        ov = value('OW_WEATHER_OVERCAST')
    except Exception:
        raise Skip('no OW_WEATHER_OVERCAST in this build')
    import suite_weather as sw
    sw.W['overcast'] = ov
    g.render(True)
    base = g.state()
    out = {}
    for wx in ('none', 'overcast'):
        g.load(base)
        sw.warp(g, 'GOLDENROD_CITY', 14, 22, weather=wx)
        sw.wait_sign_gone(g)
        g.frames(60)
        pal = g.read('wBGPals2', 64)
        res = bool(g.read('wStateFlags') & 1 << value('FIRST_12_SPRITE_OAM_STRUCTS_RESERVED_F'))
        parts = sum(1 for e in sw.oam(g) if sw.visible(e) and e[2] in sw.weather_tiles())
        bw = g.call('GetAutomaticBattleWeather')['a']
        out[wx] = dict(cur=g.read('wCurWeather'), reserved=res, particles=parts, battle_weather=bw, pal=pal)
        g.screenshot(ev_path('overcast_goldenrod_%s.png' % wx))
    o = out['overcast']
    check(o['cur'] == ov, 'overcast not applied', cur=o['cur'])
    check(not o['reserved'] and o['particles'] == 0, 'overcast reserved OAM or drew particles', **{k: v for k, v in o.items() if k != 'pal'})
    check(o['battle_weather'] == 0, 'overcast started battle weather', bw=o['battle_weather'])
    check(o['pal'] != out['none']['pal'], 'overcast did not change the BG palettes')
    return {k: {kk: vv for kk, vv in v.items() if kk != 'pal'} for k, v in out.items()}


# --- ORANGE PASS ---
def _set_weekday(g, wd):
    cur = g.read('wCurDay') % 7
    g.write('wStartDay', (g.read('wStartDay') + (wd - cur) % 7) & 0xff)
    g.frames(4)
    settle(g, 120)


def _run_dialogue(g, yes=True, limit=400):
    """Advance a conversation with A (B would answer a yes/no box "no"), answering every yes/no with
    `yes`, until control returns. Returns the distinct screens seen."""
    from overworld import answer
    screens = []
    for _ in range(limit):
        if in_control(g, 4):
            return screens
        if g.run_until('YesNoBox', 3):
            screens.append('\n'.join(text_rows(g)))
            answer(g, yes=yes)
            continue
        s = '\n'.join(text_rows(g))
        if not screens or screens[-1] != s:
            screens.append(s)
        if g.read('wScriptRunning'):
            g.hold('a', True)
            hit = g.run_until('YesNoBox', 3)
            g.hold('a', False)
            if hit:
                screens.append('\n'.join(text_rows(g)))
                g.frames(6)
                answer(g, yes=yes)
                continue
            g.frames(3)
    raise AssertionError('dialogue never returned control')


def _talk(g, direction):
    face(g, direction)
    g.frames(2)
    g.press('a', hold=4, after=10)


@test('v10_overworld')
def ow_orange_pass(g):
    """Oak's aide gives the ORANGE PASS. With it, the Vermilion Port sailor offers the express on a Monday
    and the player arrives at Valencia Port; the Valencia sailor takes it back. Without it: turned away
    at both ports."""
    if not has_sym(g, 'VermilionPortCheckInScript'):
        raise Skip('pre-feature build')
    base = g.state()
    out = {}
    # the aide wanders on row 8: stand below and retry until the talk lands
    warp(g, 'OAKS_LAB', 1, 9)
    got = False
    for _ in range(20):
        _talk(g, 'up')
        if g.read('wScriptRunning'):
            scr = _run_dialogue(g)
            got = screen_has(scr, 'ORANGE')
            break
        g.frames(30)
    from overworld import has_key_item
    out['aide_text_mentions_pass'] = got
    with_pass = g.state()
    # Vermilion, Monday, with the pass
    warp(g, 'VERMILION_PORT', 7, 11)
    _set_weekday(g, value('MONDAY'))
    _talk(g, 'left')
    scr = _run_dialogue(g, yes=True, limit=800)
    settle(g, 2400)
    out['vermilion_with_pass'] = _map_name(*here(g))
    check(out['vermilion_with_pass'] == 'VALENCIA_PORT', 'express not taken with the ORANGE PASS', **out,
          last=scr[-2:])
    # Valencia back, with the pass
    warp(g, 'VALENCIA_PORT', 7, 11)
    _talk(g, 'left')
    scr = _run_dialogue(g, yes=True, limit=800)
    settle(g, 2400)
    out['valencia_with_pass'] = _map_name(*here(g))
    check(out['valencia_with_pass'] == 'VERMILION_PORT', 'return express not taken with the pass', **out, last=scr[-2:])
    # without the pass
    for port in ('VERMILION_PORT', 'VALENCIA_PORT'):
        g.load(base)
        warp(g, port, 7, 11)
        _set_weekday(g, value('MONDAY'))
        _talk(g, 'left')
        scr = _run_dialogue(g, yes=True, limit=800)
        settle(g, 600)
        out[port.lower() + '_no_pass'] = _map_name(*here(g))
        check(here(g) == map_id(port), 'boarded without the ORANGE PASS', port=port, at=_map_name(*here(g)))
    return out


# ======================================================================================
# Time: a clock reset keeps the season (83c1890e5)
# ======================================================================================
def _set_rtc_day(g, day):
    g.write(0x0000, 0x0a)
    g.write(0x4000, 0x0b)  # RTC DL
    g.write(0xa000, day & 0xff)
    g.write(0x4000, 0x0c)  # RTC DH: bit 0 = day bit 8; keep halt/carry clear
    g.write(0xa000, 0)
    g.write(0x6000, 0)
    g.write(0x6001 - 1, 1)
    g.write(0x0000, 0x00)


@test('v10_overworld')
def ow_clock_reset_keeps_season(g):
    """InitTime (the clock-reset path) for every season x weekday x RTC day count (0, 10, 50, 139):
    wSeason and the season derived from wCurDay are the pre-reset season, and wCurDay mod 7 is the chosen
    weekday. v0.9 is expected to fail (the bug)."""
    base = g.state()
    bad, n = [], 0
    for rtc in (0, 10, 50, 139):
        for season in range(4):
            for wd in range(7):
                g.load(base)
                _set_rtc_day(g, rtc)
                g.write('wSeason', season)
                g.write('wStringBuffer2', [wd, 10, 30, 0])
                g.call('InitTime')
                g.call('UpdateTime')
                day = g.read('wCurDay')
                got = dict(rtc=rtc, season=season, weekday=wd, wSeason=g.read('wSeason'), curday=day,
                           day_season=(day % 28) // 7, day_weekday=day % 7)
                n += 1
                if got['wSeason'] != season or got['day_season'] != season or got['day_weekday'] != wd:
                    bad.append(got)
    check(not bad, 'clock reset changed the season or weekday', n_bad=len(bad), of=n, first=bad[:6])
    return {'cases': n}


# ======================================================================================
# Warps after battles (cd89b9f5d)
# ======================================================================================
def wild_battle(g, win=True):
    """Start a wild battle from PlayerEvents (level 5 copy of party slot 1) and fight it out."""
    check(g.run_until('PlayerEvents', 60), 'not at PlayerEvents')
    g.write('wTempWildMonSpecies', g.read('wPartySpecies+1'))
    g.write('wCurPartyLevel', 5)
    g.write('wBattleType', 0)
    g.write('wOtherTrainerClass', 0)
    b, a = g.addr('WildBattleScript')
    g.write('wMapReentryScriptBank', b)
    g.write('wMapReentryScriptAddress', [a & 0xff, a >> 8])
    g.write('wMapReentryScriptQueueFlag', 1)
    check(_battle(g, win=win), 'wild battle never ended')
    check(finish(g, max_presses=300), 'no control after the wild battle')


def _stale(g):
    g.write('wWinTextPointer', [0x34, 0x55])
    g.write('wSurfingPlayerState', value('PLAYER_BIKE'))


WARP_CASES = [  # (kind, from map, x, y, direction, destination, surfing)
    ('door', 'CHERRYGROVE_CITY', 29, 4, 'up', 'CHERRYGROVE_POKECENTER_1F', False),
    ('stairs', 'PLAYERS_HOUSE_2F', 7, 1, 'up', 'PLAYERS_HOUSE_1F', False),
    ('cave', 'ROUTE_33', 11, 10, 'up', 'UNION_CAVE_1F', False),
    ('water', 'ROUTE_45', 16, 88, 'right', 'BLACKTHORN_PASS', True),
]


@test('v10_overworld')
def ow_warps_keep_player_state(g):
    """Door, stairs, cave entrance and water warp, each (a) right after a real wild battle and (b) with the
    trainer-battle/Good Rod scratch leftovers poked in: walking arrives NORMAL, surfing arrives SURF, and
    wWaterWarpState is clear afterwards. v0.9 is expected to fail (b) for land warps (the bug)."""
    base = g.state()
    out, bad = {}, []
    for kind, src, x, y, d, dest, surf in WARP_CASES:
        for variant in ('battle', 'stale'):
            g.load(base)
            warp(g, src, x, y, surf=surf)
            if variant == 'battle':
                wild_battle(g)
                if surf and g.read('wPlayerState') != value('PLAYER_SURF'):
                    bad.append((kind, variant, 'battle dropped surf before warping'))
            else:
                _stale(g)
            for _ in range(3):
                g.press(d, hold=20, after=4)
                settle(g, 1200)
                if _map_name(*here(g)) == dest:
                    break
            r = dict(at=_map_name(*here(g)), state=g.read('wPlayerState'),
                     pending=g.read('wWaterWarpState') if has_sym(g, 'wWaterWarpState') else None)
            out['%s/%s' % (kind, variant)] = r
            want = value('PLAYER_SURF') if surf else value('PLAYER_NORMAL')
            if r['at'] != dest or r['state'] != want or r['pending']:
                bad.append((kind, variant, r))
    check(not bad, 'warp changed the player state', bad=bad)
    return out


# ======================================================================================
# Heal machine vs NPC palettes (91f7ab4b7)
# ======================================================================================
def _obj_pal_state(g):
    from gb import _lib
    oam = g.read(g.addr('wShadowOAM'), 160)
    return dict(obp1=_lib.sb_read(g.h, 0xff49), obpals2=g.read((5, g.addr('wOBPals2')[1]), 64),
                oam_attrs=[oam[i * 4 + 3] & 7 for i in range(40) if 0 < oam[i * 4] < 160])


@test('v10_overworld')
def ow_heal_machine_keeps_npc_palettes(g):
    """Azalea Pokecenter (Gentleman, Fishing Guru): enter through the door (a fade), heal at the nurse,
    then OB palettes 0-6 in wOBPals2, rOBP1 and the NPCs' OAM palette numbers match the pre-heal state;
    slot 7 is restored from wOBPals1 if an NPC owns it. Screenshots before/after for shasocastris."""
    g.render(True)
    warp(g, 'AZALEA_TOWN', 15, 10)
    g.press('up', hold=20, after=4)
    check(settle(g, 1200) and _map_name(*here(g)) == 'AZALEA_POKECENTER_1F', 'did not enter the Pokecenter',
          at=_map_name(*here(g)))
    for _ in range(4):  # walk to the counter
        g.press('up', hold=16, after=4)
        settle(g, 300)
    g.frames(30)
    # the bug's precondition (commit message): after a CGB fade to black rOBP1 is left at $ff
    from gb import _lib
    _lib.sb_write(g.h, 0xff49, 0xff)
    before = _obj_pal_state(g)
    tag = 'head' if is_head() else 'v09'
    g.screenshot(ev_path('heal_before_%s.png' % tag))
    from game import mon_write, mon_word
    mon_write(g, 0, 'MON_HP', [0, 1])
    _talk(g, 'up')
    _run_dialogue(g, yes=True, limit=600)
    g.frames(60)
    after = _obj_pal_state(g)
    g.screenshot(ev_path('heal_after_%s.png' % tag))
    used = g.read((1, g.addr('wUsedObjectPals')[1]))
    npc_slots = [i for i in range(7) if used & 1 << i]
    changed = {i: (bytes(before['obpals2'][8 * i:8 * i + 8]).hex(), bytes(after['obpals2'][8 * i:8 * i + 8]).hex())
               for i in npc_slots if before['obpals2'][8 * i:8 * i + 8] != after['obpals2'][8 * i:8 * i + 8]}
    r = dict(healed=mon_word(g, 0, 'MON_HP') == mon_word(g, 0, 'MON_MAXHP'), obp1=(before['obp1'], after['obp1']),
             used_pals='{:08b}'.format(used), npc_slots_changed=changed)
    check(r['healed'], 'heal did not happen (test fault?)', **r)
    check(not changed, 'healing changed the palettes of NPC object slots', **r)
    return r


# ======================================================================================
# Visual: Ice Path / Seafoam day sprite palette (e03df73c5), Pewter museum blocks (f136b583a, 34fecc68b)
# ======================================================================================
VISUAL_SPOTS = [
    ('ICE_PATH_1F', 4, 18), ('ICE_PATH_1F', 36, 26), ('ICE_PATH_B1F', 3, 14), ('ICE_PATH_B1F', 17, 4),
    ('ICE_PATH_B2F_MAHOGANY_SIDE', None, None), ('ICE_PATH_B2F_BLACKTHORN_SIDE', None, None),
    ('ICE_PATH_B3F', None, None), ('SEAFOAM_CAVES', 10, 14),
    ('PEWTER_MUSEUM_1F', 10, 6), ('PEWTER_MUSEUM_1F', 16, 6), ('PEWTER_MUSEUM_1F', 7, 6), ('PEWTER_MUSEUM_1F', 3, 4),
    ('PEWTER_MUSEUM_2F', 7, 6), ('PEWTER_MUSEUM_2F', 3, 4), ('PEWTER_MUSEUM_2F', 10, 4),
]


@test('v10_overworld')
def ow_visual_caves_and_museum(g):
    """Screenshots of Ice Path, Seafoam Caves and the Pewter museum at fixed spots (same hour) on this ROM,
    saved as visual_<map>_<x>_<y>_<rom>.png; compared across ROMs by hand / by the report script."""
    g.render(True)
    tag = 'head' if is_head() else 'v09'
    base = g.state()
    shots = []
    for name, x, y in VISUAL_SPOTS:
        if x is None:
            x, y = sorted(_warp_events_at(name))[0]
            y += 1
        g.load(base)
        g.write('hHours', 12)
        try:
            warp(g, name, x, y)
        except AssertionError as e:
            shots.append((name, x, y, 'warp failed: %s' % e))
            continue
        g.frames(90)  # map-name sign gone
        f = 'visual_%s_%d_%d_%s.png' % (name.lower(), x, y, tag)
        g.screenshot(ev_path(f))
        shots.append((name, x, y, f, g.read('wTimeOfDayPal')))
    return shots


# ======================================================================================
# Save layout: wVisitedSpawns padding (8c86d4b2f), 00bca0e35 call/xcall changes
# ======================================================================================
SCRATCH = '/tmp/claude-1000/-home-bryan-Documents-Romhacks-crystal-eclipse/4203bf99-da66-490e-998d-1f337047b4f7/scratchpad'


@test('v10_overworld')
def ow_save_layout_matches_v09(g):
    """Every WRAM label in wGameData..wGameDataEnd sits at the same bank:address on HEAD and v0.9 (except
    labels that only exist in one build); wGameData's size is unchanged. Also: GiveNicknameHappiness is in
    PokeBallEffect's bank (now a near call) on this ROM."""
    paths = {k: os.path.join(SCRATCH, 'roms', k, 'crystal_eclipse_debug.sym') for k in ('head', 'v09')}
    if not all(os.path.exists(p) for p in paths.values()):
        raise Skip('sym files missing')
    syms = {k: gb.load_sym(p) for k, p in paths.items()}
    out = {}
    for k, s in syms.items():
        lo, hi = s['wGameData'], s['wGameDataEnd']
        out[k] = {n: v for n, v in s.items() if v[0] == lo[0] and lo[1] <= v[1] <= hi[1] and n.startswith('w')}
    common = set(out['head']) & set(out['v09'])
    moved = sorted((n, out['v09'][n], out['head'][n]) for n in common if out['v09'][n] != out['head'][n])
    only = {k: sorted(set(out[k]) - common) for k in out}
    size = {k: syms[k]['wGameDataEnd'][1] - syms[k]['wGameData'][1] for k in syms}
    near = 'GiveNicknameHappiness' not in g.syms or g.syms['GiveNicknameHappiness'][0] == g.syms['PokeBallEffect'][0]
    r = dict(moved=['%s %04x->%04x' % (n, a[1], b[1]) for n, a, b in moved][:20], n_moved=len(moved),
             only_head=only['head'], only_v09=only['v09'], size=size,
             visited_spawns=(syms['v09']['wVisitedSpawns'], syms['head']['wVisitedSpawns']),
             dig=(syms['v09']['wDigWarpNumber'], syms['head']['wDigWarpNumber']), nickname_happiness_near=near)
    check(not moved and size['head'] == size['v09'], 'save layout shifted vs v0.9', **r)
    check(near, 'GiveNicknameHappiness left PokeBallEffect\'s bank: the near call would crash', **r)
    return r


# ======================================================================================
# Broad overworld smoke
# ======================================================================================
def _changed_maps():
    import subprocess
    out = subprocess.run(['git', '-C', f'{_REPO_ROOT}', 'diff', '--name-only',
                          'v0.9..1fb549fdf', '--', 'maps/'], capture_output=True, text=True).stdout.split()
    camels = {os.path.splitext(os.path.basename(p))[0] for p in out}
    return {n for n, camel, env, lm in _maps_table() if camel in camels and n}


# Maps whose entry/step script needs answers this blind smoke can't give (quiz, elevator floor menu, static
# battle, Hall of Fame, Battle Tower room, Mr. Pokemon's scene). Same list fails on v0.9; checked by screenshot.
SCRIPTED_ENTRY = {'DRAGON_SHRINE', 'MOUNT_MOON', 'CERULEAN_BASE_3', 'HALL_OF_FAME',
                  'BATTLE_TOWER_BATTLE_ROOM', 'BATTLE_TOWER_ELEVATOR', 'MR_POKEMONS_HOUSE'}


def _crashed(g):
    pc = g.reg('pc')
    return pc == 0x0038 or 0x8000 <= pc < 0xff80  # no code runs from VRAM, SRAM or WRAM


def _textbox_open(g):
    rows = text_rows(g)
    return len(rows) > 12 and rows[12].startswith('+-') and rows[12].rstrip().endswith('+')


def _unstick(g, limit=300):
    """Get back to free control: win any battle, otherwise alternate B and A through text and menus.
    With a text box open press B (an A that closes it re-talks to the NPC in front), but every 10th
    press is still A so a yes/no that loops on NO cannot trap us."""
    end = g.frame + 8000
    for i in range(limit):
        if g.frame > end:
            return False
        if in_control(g, 6):
            return True
        if _crashed(g):
            return False
        if g.read('wBattleMode'):
            _battle(g, win=True, limit=300)
            continue
        if _textbox_open(g):
            btn = 'a' if i % 10 == 9 else 'b'
        else:
            btn = 'b' if i % 3 else 'a'
        g.press(btn, hold=3, after=3)
    return False


def _smoke_one(g, name, deep):
    wps = sorted(_warp_events_at(name))
    if not wps:
        return 'no warp_event to land on'
    x, y = wps[0]
    backup = _backup_warp_for(name, x, y)

    def set_backup(g):
        # raw_warp skips the arrival that saves the way back (GetWarpDestCoords.backup)
        grp, num = map_id(backup[0])
        g.write('wBackupWarpNumber', backup[1])
        g.write('wBackupMapGroup', grp)
        g.write('wBackupMapNumber', num)
    if name in ('BATTLE_TOWER_ELEVATOR', 'BATTLE_TOWER_BATTLE_ROOM'):
        # the 1F receptionist sets these up; level group 0 indexes past BattleTowerMons and runs away
        g.write('wBTChoiceOfLvlGroup', 1)
        g.call('ResetBattleTowerTrainersSRAM')
        # 1F saves before the challenge; each battle reloads the party from the save (LoadPokemonData)
        g.call('SavePokemonData')
    raw_warp(g, name, x, y, before=set_backup if backup else None)
    if not _unstick(g):
        return 'never reached control after loading (pc=%04x%s)' % (g.reg('pc'), ' CRASH' if _crashed(g) else '')
    steps = ('down', 'up', 'left', 'right') if deep else ('down',)
    for d in steps:
        g.press(d, hold=16, after=4)
        if not _unstick(g, 200):
            return 'no control after stepping %s (pc=%04x%s)' % (d, g.reg('pc'), ' CRASH' if _crashed(g) else '')
    if deep:
        g.press('start', after=30)
        rows = text_rows(g)
        if not any('EXIT' in r for r in rows):
            return 'start menu did not open'
        g.press('b', after=30)
        if not in_control(g, 60):
            return 'no control after closing the start menu'
    return None


@test('v10_overworld')
def ow_smoke_changed_maps(g):
    """Every map whose script/blocks changed since v0.9: land on its first warp_event, walk 4 ways, open and
    close the start menu, and get back to PlayerEvents with no crash."""
    base = g.state()
    bad, ok = {}, []
    for name in sorted(_changed_maps()):
        g.load(base)
        try:
            err = _smoke_one(g, name, deep=True)
        except AssertionError as e:
            err = str(e)
        if err and (name not in SCRIPTED_ENTRY or 'CRASH' in err):
            bad[name] = err
            g.render(True)
            g.frames(2)
            g.screenshot(ev_path('smoke_%s.png' % name.lower()))
            g.render(False)
        else:
            ok.append(name)
    check(not bad, 'maps failed the smoke test', bad=bad, ok=len(ok))
    return {'ok': len(ok), 'maps': ok}


@test('v10_overworld')
def ow_smoke_all_maps(g):
    """Every map in the ROM: land on its first warp_event, take a step, regain control without a crash."""
    base = g.state()
    bad, n = {}, 0
    for name, camel, env, lm in _maps_table():
        if not name:
            continue
        g.load(base)
        n += 1
        try:
            err = _smoke_one(g, name, deep=False)
        except AssertionError as e:
            err = str(e)
        if err and (name not in SCRIPTED_ENTRY or 'CRASH' in err) and err != 'no warp_event to land on':
            bad[name] = err
            g.render(True)
            g.frames(2)
            g.screenshot(ev_path('smokeall_%s.png' % name.lower()))
            g.render(False)
    check(not bad, 'maps failed the smoke test', bad=bad, n=n)
    return {'maps': n}

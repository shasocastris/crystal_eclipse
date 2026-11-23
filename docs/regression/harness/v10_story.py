"""v1.0 story regression: S.S.AQUA Rocket arc, Vermilion check-in, Wild Hunt gate, Route 30 Hana.

Run: CE_REPO=<tree> $PY runner.py v10_story --rom <tree ROM> --jobs 1 [-k story_...]
Findings: docs/regression/v10/story.md. Helper, not committed.
"""
import os

import fixtures
from consts import resolve, value
from game import event, set_event, engine, set_engine, mon, mon_write, mon_word
from overworld import (DIRS, answer, face, finish, in_control, interact, item_qty, set_item, settle, warp)
from registry import check, test, Skip

EVID = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'v10', 'story')


# --- script driving -------------------------------------------------------------------------
def _rev(g):
    if not hasattr(g, '_rev'):
        g._rev = {}
        for name, (b, a) in g.syms.items():
            g._rev.setdefault((b if a >= 0x4000 else 0, a), name)
    return g._rev


def text_label(g):
    """At MapTextbox: the label of the text being printed (b = bank, hl = address)."""
    b, hl = g.reg('bc') >> 8, g.reg('hl')
    return _rev(g).get((b if hl >= 0x4000 else 0, hl), '%02x:%04x' % (b, hl))


def shot(g, name):
    os.makedirs(EVID, exist_ok=True)
    g.render(True)
    g.frames(2)
    g.screenshot(os.path.join(EVID, name + '.png'))
    g.render(False)


def _battle(g, win):
    """From StartBattle to CleanUpBattleRAM. win: foe at 1 HP, Normal-typed, ours full.
    lose: ours at 1 HP with no PP (Struggle recoil), foe huge. Party should be Mewtwo only."""
    from battle import fast_options
    fast_options(g)
    labels = ['LoadBattleMenu', 'CleanUpBattleRAM', 'PartyMenuSelect', 'YesNoBox']
    for _ in range(4000):
        hit = g.run_until_any(labels, 20)
        if hit is None:  # tap A through text, watching for the labels while it is held
            g.hold('a', True)
            hit = g.run_until_any(labels, 3)
            g.hold('a', False)
            if hit is None:
                continue
        if hit == 'CleanUpBattleRAM':
            return g.read('wBattleResult') & 3
        if hit == 'PartyMenuSelect':
            alive = [i for i in range(g.read('wPartyCount')) if mon_word(g, i, 'MON_HP')]
            check(alive, 'switch menu with no mon left')
            g.frames(20)
            g.write('wMenuCursorY', alive[0] + 1)
            g.press('a', hold=4, after=20)
            continue
        if hit == 'YesNoBox':
            g.frames(4)
            g.press('b', hold=4, after=10)
            continue
        if hit == 'LoadBattleMenu':
            if win:
                g.write('wEnemyMonHP', [0, 1])
                g.write('wEnemyMonType', [0, 0])
                g.write('wBattleMonHP', g.read('wBattleMonMaxHP', 2))
            else:
                g.write('wBattleMonHP', [0, 1])
                g.write('wBattleMonPP', [0, 0, 0, 0])
                g.write('wEnemyMonHP', [0x27, 0x0f])
                g.write('wEnemyMonMaxHP', [0x27, 0x0f])
            g.hold('a', True)
            g.run_until_any(['CleanUpBattleRAM'], 3)
            g.hold('a', False)
    raise AssertionError('battle never ended')


def run_script(g, yes=(), menu=(), battle=None, max_steps=900, record=None, tick=None):
    """Drive a running script to the end: B through text, answer yes/no boxes from `yes`
    (True/False, in order), menus from `menu` (row index, or 'b'), battles with `battle`
    ('win'/'lose'). Returns a dict with the texts printed, battles fought and their results."""
    yes, menu = list(yes), list(menu)
    out = {'texts': [], 'battles': [], 'yesno': 0, 'menus': 0}
    labels = ['MapTextbox', 'YesNoBox', 'Script_verticalmenu', 'StartBattle']
    idle = 0
    for _ in range(max_steps):
        if tick:
            tick(g)
        hit = g.run_until_any(labels, 6)
        if hit is None and not (g.read('wScriptRunning') == 0 and g.read('wMapStatus') == 2 and in_control(g, 6)):
            g.hold('b', True)
            hit = g.run_until_any(labels, 3)
            g.hold('b', False)
            if hit is None:
                continue
        if hit == 'MapTextbox':
            out['texts'].append(text_label(g))
            g.frames(1)
            idle = 0
            continue
        if hit == 'YesNoBox':
            out['yesno'] += 1
            check(yes, 'unexpected yes/no box', texts=out['texts'][-3:])
            answer(g, yes.pop(0))
            idle = 0
            continue
        if hit == 'Script_verticalmenu':
            out['menus'] += 1
            check(menu, 'unexpected menu', texts=out['texts'][-3:])
            row = menu.pop(0)
            g.frames(30)
            for _ in range(0 if row == 'b' else row):
                g.press('down', hold=4, after=8)
            key = 'b' if row == 'b' else 'a'
            g.hold(key, True)
            h = g.run_until_any(['MapTextbox'], 5)
            g.hold(key, False)
            if h:
                out['texts'].append(text_label(g))
                g.frames(1)
            continue
        if hit == 'StartBattle':
            check(battle, 'unexpected battle', texts=out['texts'][-3:])
            g.frames(1)
            party = (g.read('wOtherTrainerClass'), g.read('wOtherTrainerID'))
            out['battles'].append(dict(trainer=party, result=_battle(g, battle == 'win'),
                                       map=(g.read('wMapGroup'), g.read('wMapNumber'))))
            idle = 0
            continue
        if hit is None:
            break
    else:
        raise AssertionError('script never handed back control: %s' % out['texts'][-4:])
    out['pos'] = (g.read('wXCoord'), g.read('wYCoord'))
    out['map'] = map_name(g)
    if record is not None:
        record.update(out)
    return out


_MAPS = {}


def map_name(g):
    if not _MAPS:
        import re
        from gb import REPO
        names = []
        for l in open(os.path.join(REPO, 'constants/map_constants.asm')):
            m = re.match(r'\s*map_const (\w+),', l)
            if m:
                names.append(m.group(1))
        v = resolve(*(['GROUP_' + n for n in names] + ['MAP_' + n for n in names]))
        for n in names:
            _MAPS[(v['GROUP_' + n], v['MAP_' + n])] = n
    return _MAPS.get((g.read('wMapGroup'), g.read('wMapNumber')), '?')


def step(g, direction, script=True):
    """Take one step. Returns True if a script started (coord event / trainer)."""
    face(g, direction)
    g.hold(direction, True)
    g.frames(6)
    g.hold(direction, False)
    for _ in range(40):
        g.frames(1)
        if g.read('wScriptRunning'):
            return True
    return False


def walk(g, path):
    """Walk a string of U/D/L/R steps; stop and return the index where a script starts."""
    d = {'U': 'up', 'D': 'down', 'L': 'left', 'R': 'right'}
    for i, c in enumerate(path):
        if step(g, d[c]):
            return i
        in_control(g, 20)
    return None


def solo_party(g):
    """Mewtwo alone (no Exp. Share level-ups or switch menus in scripted battles)."""
    g.write('wPartyCount', 1)
    g.write('wPartySpecies+1', 0xff)
    mon_write(g, 0, 'MON_ITEM', 0)


def set_weekday(g, wd):
    cur = g.read('wCurDay') % 7
    g.write('wStartDay', (g.read('wStartDay') + (wd - cur) % 7) & 0xff)
    g.frames(4)
    check(g.read('wCurDay') % 7 == wd, 'weekday did not stick', want=wd, got=g.read('wCurDay') % 7)


# scene ids are scene_const'd inside the map files, so not visible to consts.resolve
PORT_ASK, PORT_LEAVE_SHIP, PORT_LEAVE_EXPRESS, PORT_RAID_BLACKOUT = 0, 1, 2, 3
B1F_SAILOR_BLOCKS, B1F_NOOP = 0, 1
SHIP1F_NOOP, SHIP1F_ENTER, SHIP1F_MEET_GRANDPA = 0, 1, 2


def scene(g, name):
    return g.read('w%sSceneID' % name)


def blackout_map(g):
    return (g.read('wLastSpawnMapGroup'), g.read('wLastSpawnMapNumber'))


def map_id(name):
    v = resolve('GROUP_' + name, 'MAP_' + name)
    return (v['GROUP_' + name], v['MAP_' + name])


def obj_hidden(g, flag):
    return event(g, flag)


# --- fixtures -------------------------------------------------------------------------------
def _board_olivine(g):
    """From debug_party: board the first S.S.AQUA run at Olivine (the raid). Ends on Fast Ship 1F
    with control, after the boarding scene."""
    warp(g, 'OLIVINE_PORT', 7, 14)
    check(step(g, 'down'), 'Olivine walk-up never triggered')
    rec = run_script(g, yes=[True])
    check(rec['map'] == 'FAST_SHIP_1F', 'did not board', **rec)
    return g


fixtures.STEPS['story_raid'] = [fixtures.new_game, fixtures.debug_party, _board_olivine]


# --- S.S.AQUA: boarding and the raid flags ----------------------------------------------------
@test('story', 'story_raid')
def story_raid_starts_on_first_olivine_run(g):
    """First Olivine boarding (post-League debug save): raid flag, port blackout scene, pier spawn."""
    out = dict(raid=event(g, 'EVENT_SS_AQUA_RAID'), port_scene=scene(g, 'VermilionPort'),
               blackout=blackout_map(g), first_time=event(g, 'EVENT_FAST_SHIP_FIRST_TIME'),
               ship1f_scene=scene(g, 'FastShip1F'), petrel_hidden=event(g, 'EVENT_FAST_SHIP_PETREL'))
    check(out['raid'], 'EVENT_SS_AQUA_RAID not set', **out)
    check(out['port_scene'] == PORT_RAID_BLACKOUT, 'port scene not RAID_BLACKOUT', **out)
    check(out['blackout'] == map_id('VERMILION_PORT'), 'blackout not Vermilion Port', **out)
    check(not out['petrel_hidden'], 'Petrel hidden on the raid', **out)
    return out




def _trainer(cls, tid):
    v = resolve(cls, tid)
    return (v[cls], v[tid])


def _petrel(g, x, battle):
    """Stand at (x, 30) in the captain's cabin and step onto the row-29 trigger."""
    solo_party(g)
    warp(g, 'FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN', x, 30)
    started = step(g, 'up')
    check(started, 'row 29 trigger did not start a script', x=x)
    return run_script(g, battle=battle)


def _dock_vermilion(g):
    """Talk to the 1F door sailor once the ship has arrived; run the Vermilion arrival."""
    warp(g, 'FAST_SHIP_1F', 25, 3)
    interact(g, 'up')
    return run_script(g)


def _final_raid_state(g):
    return dict(raid=event(g, 'EVENT_SS_AQUA_RAID'), first_time=event(g, 'EVENT_FAST_SHIP_FIRST_TIME'),
                petrel_hidden=event(g, 'EVENT_FAST_SHIP_PETREL'), found_girl=event(g, 'EVENT_FAST_SHIP_FOUND_GIRL'),
                twin2_hidden=event(g, 'EVENT_FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN_TWIN_2'),
                lazy_hidden=event(g, 'EVENT_FAST_SHIP_CABINS_NNW_NNE_NE_SAILOR'),
                grandpa1f_hidden=event(g, 'EVENT_FAST_SHIP_1F_GENTLEMAN'),
                first_trip_passengers_hidden=event(g, 'EVENT_FAST_SHIP_PASSENGERS_FIRST_TRIP'),
                metal_coat=event(g, 'EVENT_GOT_METAL_COAT_FROM_GRANDPA_ON_SS_AQUA'),
                port_scene=scene(g, 'VermilionPort'), b1f_scene=scene(g, 'FastShipB1F'),
                blackout=blackout_map(g), map=map_name(g), pos=(g.read('wXCoord'), g.read('wYCoord')))


def _check_closed(st, **ctx):
    for k in ('first_time', 'petrel_hidden', 'found_girl', 'twin2_hidden', 'lazy_hidden', 'grandpa1f_hidden',
              'first_trip_passengers_hidden'):
        check(st[k], 'raid close-out flag not set: ' + k, state=st, **ctx)
    check(not st['raid'], 'EVENT_SS_AQUA_RAID still set', state=st, **ctx)
    check(st['port_scene'] == PORT_ASK, 'Vermilion Port scene not reset', state=st, **ctx)
    check(st['b1f_scene'] == B1F_NOOP, 'B1F blocker scene not cleared', state=st, **ctx)
    check(st['blackout'] == map_id('VERMILION_CITY'), 'blackout not moved back to Vermilion City', state=st, **ctx)


def _win_arc(g):
    """Fixture step: beat Petrel from the middle of row 29, dock, let Koga close the raid."""
    rec = _petrel(g, 5, 'win')
    check(rec['battles'] and rec['battles'][0]['result'] == 0, 'Petrel not beaten', **rec)
    _dock_vermilion(g)
    return g


fixtures.STEPS['story_arc_done'] = [fixtures.new_game, fixtures.debug_party, _board_olivine, _win_arc]


@test('story', 'story_raid')
def story_petrel_walks_up_from_each_column(g):
    """Row 29 at x=0, 5, 9: Petrel walks over, battles EXECUTIVEM_5, escapes, girl reunion, Metal Coat."""
    base = g.state()
    out = {}
    for x in (0, 5, 9):
        g.load(base)
        set_item(g, 'METAL_COAT', 0)
        rec = _petrel(g, x, 'win')
        st = _final_raid_state(g)
        out[x] = dict(battles=rec['battles'], pos=rec['pos'], map=rec['map'], texts=rec['texts'][:3] + rec['texts'][-2:])
        check(len(rec['battles']) == 1, 'expected one battle', x=x, **out[x])
        check(tuple(rec['battles'][0]['trainer']) == _trainer('EXECUTIVEM', 'EXECUTIVEM_5'), 'not Petrel', x=x, **out[x])
        check('PetrelShipBeforeText' in rec['texts'] and 'PetrelShipSmokeBallText' in rec['texts'], 'Petrel texts', x=x, **out[x])
        check(st['petrel_hidden'] and st['twin2_hidden'], 'Petrel/girl still shown', x=x, state=st)
        check(event(g, 'EVENT_FAST_SHIP_HAS_ARRIVED') and st['found_girl'], 'ship did not arrive', x=x, state=st)
        check(st['metal_coat'] and item_qty(g, 'METAL_COAT') == 1, 'no Metal Coat', x=x, state=st)
        check(event(g, 'EVENT_SAVED_SS_AQUA'), 'saved-ship flag not set after beating Petrel', x=x)
        check(rec['pos'] == (2, 19), 'player not at the grandpa cabin door', x=x, pos=rec['pos'])
        # no re-trigger
        warp(g, 'FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN', x, 30)
        started = step(g, 'up')
        if started:
            run_script(g)
        check(not g.read('wBattleMode') and g.read('wYCoord') == 29, 'row 29 still does something', x=x)
    return out


@test('story', 'story_arc_done')
def story_arc_win_closes_out(g):
    """After beating Petrel and docking: Koga's lines ran, every first-trip flag/scene is closed."""
    st = _final_raid_state(g)
    _check_closed(st)
    check(st['map'] == 'VERMILION_PORT' and st['pos'] == (7, 16), 'not on the pier', state=st)
    check(st['metal_coat'], 'Metal Coat flag not set', state=st)
    # Koga/ranger leave after a reload
    warp(g, 'VERMILION_PORT', 7, 10)
    check(event(g, 'EVENT_VERMILION_PORT_KOGA'), 'Koga still on the pier after reload')
    return st


@test('story', 'story_raid')
def story_arc_win_texts(g):
    """Docking after a win shows Koga's raid-over text, Koga walks down and back without a stall."""
    _petrel(g, 5, 'win')
    rec = _dock_vermilion(g)
    check('VermilionPortKogaRaidOverText' in rec['texts'], 'Koga raid text missing', texts=rec['texts'])
    return dict(texts=rec['texts'], pos=rec['pos'])


@test('story', 'story_raid')
def story_petrel_loss_whiteout(g):
    """Losing to Petrel: whiteout to the Vermilion pier, Koga's took-the-ship text, raid closed, no Metal Coat."""
    rec = _petrel(g, 5, 'lose')
    st = _final_raid_state(g)
    out = dict(battles=rec['battles'], texts=rec['texts'][-6:], state=st)
    check(rec['battles'] and rec['battles'][0]['result'] == 1, 'battle not lost', **out)
    check(st['map'] == 'VERMILION_PORT', 'whiteout did not land on Vermilion Port', **out)
    check('VermilionPortKogaTookTheShipText' in rec['texts'], 'Koga took-the-ship text missing', **out)
    _check_closed(st)
    check(not st['metal_coat'], 'Metal Coat given after a loss', **out)
    check(not event(g, 'EVENT_SAVED_SS_AQUA'), 'saved-ship flag set after a loss', **out)
    check(mon_word(g, 0, 'MON_HP') == mon_word(g, 0, 'MON_MAXHP'), 'party not healed by whiteout')
    return out


def _grunt(g, which, battle):
    solo_party(g)
    if which == 1:
        warp(g, 'FAST_SHIP_B1F', 8, 11)
        interact(g, 'right')
    elif which == 'seen':
        warp(g, 'FAST_SHIP_B1F', 9, 7)
        check(step(g, 'down'), 'grunt 1 did not see the player')
    else:
        warp(g, 'FAST_SHIP_B1F', 26, 8)
        interact(g, 'down')
    return run_script(g, battle=battle)


@test('story', 'story_raid')
def story_hold_grunts_fight_once(g):
    """B1F grunts GRUNTM_39/40: one battle each, beaten flags set, talking again is text only."""
    out = {}
    for which, tid, flag in ((1, 'GRUNTM_39', 'EVENT_BEAT_SAILOR_JEFF'), (2, 'GRUNTM_40', 'EVENT_BEAT_JUGGLER_FRITZ')):
        rec = _grunt(g, which, 'win')
        check(len(rec['battles']) == 1 and tuple(rec['battles'][0]['trainer']) == _trainer('GRUNTM', tid),
              'grunt battle wrong', which=which, rec=rec)
        check(event(g, flag), 'beaten flag not set', which=which)
        again = _grunt(g, which, None)
        check(not again['battles'], 'grunt re-fought', which=which)
        out[which] = dict(first=rec['texts'], again=again['texts'])
    return out


@test('story', 'story_raid')
def story_hold_grunt_loss_whiteout(g):
    """Grunt 1 spots the player from 3 tiles; losing to him ends the raid on the Vermilion pier."""
    rec = _grunt(g, 'seen', 'lose')
    st = _final_raid_state(g)
    check(st['map'] == 'VERMILION_PORT', 'whiteout did not land on Vermilion Port', state=st, texts=rec['texts'][-4:])
    _check_closed(st)
    return dict(state=st, texts=rec['texts'][-5:])


def _lazy_sailor(g, battle):
    solo_party(g)
    warp(g, 'FAST_SHIP_CABINS_NNW_NNE_NE', 4, 27,
         before=lambda g: set_event(g, 'EVENT_FAST_SHIP_CABINS_NNW_NNE_NE_SAILOR', False))
    interact(g, 'up')
    return run_script(g, battle=battle)


@test('story', 'story_raid')
def story_lazy_sailor_grunt_win(g):
    """The lazy sailor (GRUNTM_41): battle, no heal afterwards, leaves, B1F opens."""
    mon_write(g, 0, 'MON_HP', [0, 50])
    rec = _lazy_sailor(g, 'win')
    check(len(rec['battles']) == 1 and tuple(rec['battles'][0]['trainer']) == _trainer('GRUNTM', 'GRUNTM_41'),
          'lazy sailor battle wrong', rec=rec)
    check(event(g, 'EVENT_FAST_SHIP_LAZY_SAILOR') and scene(g, 'FastShipB1F') == B1F_NOOP, 'lazy sailor flags')
    check(event(g, 'EVENT_FAST_SHIP_CABINS_NNW_NNE_NE_SAILOR'), 'lazy sailor did not leave')
    return dict(hp_after=mon_word(g, 0, 'MON_HP'), texts=rec['texts'])


@test('story', 'story_raid')
def story_lazy_sailor_grunt_loss(g):
    """Losing to the lazy sailor must white out like the other raid trainers (it uses reloadmap)."""
    rec = _lazy_sailor(g, 'lose')
    st = _final_raid_state(g)
    out = dict(map=st['map'], hp=[mon_word(g, i, 'MON_HP') for i in range(g.read('wPartyCount'))],
               lazy_beaten=event(g, 'EVENT_FAST_SHIP_LAZY_SAILOR'), texts=rec['texts'][-5:], raid=st['raid'])
    if st['map'] != 'VERMILION_PORT':
        shot(g, 'lazy_sailor_loss')
    check(st['map'] == 'VERMILION_PORT', 'losing to the lazy sailor did not white out', **out)
    return out


@test('story', 'story_raid')
def story_raid_bed_refuses(g):
    """The cabin bed refuses to heal while the raid is on."""
    mon_write(g, 0, 'MON_HP', [0, 10])
    warp(g, 'FAST_SHIP_CABINS_SW_SSW_NW', 6, 2)
    interact(g, 'right')
    rec = run_script(g)
    check('FastShipBedNoRestText' in rec['texts'], 'bed did not refuse', texts=rec['texts'])
    check(mon_word(g, 0, 'MON_HP') == 10, 'party healed on the raid')
    return rec['texts']


# --- re-boarding after the arc -------------------------------------------------------------
@test('story', 'story_arc_done')
def story_reboard_after_arc(g):
    """After the arc: Vermilion boards the S.S.AQUA (Wed), no raid, Petrel/grunts gone, bed heals,
    row 29 is quiet; then Olivine boards back (Mon) with no raid either."""
    out = {}
    set_weekday(g, value('WEDNESDAY'))
    warp(g, 'VERMILION_PORT', 7, 10)
    check(step(g, 'down'), 'check-in did not trigger')
    rec = run_script(g, yes=[True])
    out['vermilion'] = dict(map=rec['map'], texts=rec['texts'])
    check(rec['map'] == 'FAST_SHIP_1F', 'did not board at Vermilion', **out['vermilion'])
    check(not event(g, 'EVENT_SS_AQUA_RAID') and blackout_map(g) == map_id('FAST_SHIP_CABINS_SW_SSW_NW'),
          'later voyage set up like a raid', blackout=blackout_map(g))
    check(event(g, 'EVENT_FAST_SHIP_DESTINATION_OLIVINE'), 'destination flag not Olivine')
    check(event(g, 'EVENT_FAST_SHIP_PETREL') and event(g, 'EVENT_FAST_SHIP_PASSENGERS_FIRST_TRIP'),
          'Petrel or first-trip grunts back')
    warp(g, 'FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN', 5, 30)
    if step(g, 'up'):
        r = run_script(g)
        check(not r['battles'], 'row 29 started a battle on a later trip')
    mon_write(g, 0, 'MON_HP', [0, 10])
    warp(g, 'FAST_SHIP_CABINS_SW_SSW_NW', 6, 2)
    interact(g, 'right')
    bed = run_script(g)
    out['bed'] = bed['texts']
    check(mon_word(g, 0, 'MON_HP') == mon_word(g, 0, 'MON_MAXHP'), 'bed did not heal on a later trip', texts=bed['texts'])
    check(event(g, 'EVENT_FAST_SHIP_HAS_ARRIVED'), 'bed did not bring the ship in')
    warp(g, 'FAST_SHIP_1F', 25, 3)
    interact(g, 'up')
    rec = run_script(g)
    out['olivine_arrival'] = dict(map=rec['map'], pos=rec['pos'])
    check(rec['map'] == 'OLIVINE_PORT', 'did not dock at Olivine', **out['olivine_arrival'])
    # Olivine -> Vermilion again (Monday)
    set_weekday(g, value('MONDAY'))
    warp(g, 'OLIVINE_PORT', 7, 14)
    check(step(g, 'down'), 'Olivine walk-up never triggered')
    rec = run_script(g, yes=[True])
    check(rec['map'] == 'FAST_SHIP_1F' and not event(g, 'EVENT_SS_AQUA_RAID'), 'Olivine re-board raided again')
    check(scene(g, 'VermilionPort') != PORT_RAID_BLACKOUT, 'raid blackout scene armed on a later trip')
    return out


@test('story', 'story_arc_done')
def story_janine_nod_after_save(g):
    """Janine mentions Koga's praise after a saved ship (even with no Metal Coat: full bag), the fall after a whiteout."""
    out = {}
    base = g.state()
    for case, saved, coat in (('saved', True, True), ('saved_full_bag', True, False), ('fell', False, False)):
        g.load(base)
        set_event(g, 'EVENT_SAVED_SS_AQUA', saved)
        set_event(g, 'EVENT_GOT_METAL_COAT_FROM_GRANDPA_ON_SS_AQUA', coat)
        warp(g, 'FUCHSIA_GYM', 1, 11, before=lambda g: None)
        g.write('wPlayerDirection', DIRS['up'])
        interact(g, 'up')
        rec = run_script(g)
        out[case] = rec['texts']
        want = 'JanineText_FatherPraisedYou' if saved else 'JanineText_FatherSawYouFall'
        check(want in rec['texts'], 'Janine line wrong', case=case, texts=rec['texts'])
    return out


def raw_warp(g, map_name_, x, y, before=None):
    """warp() without waiting for control, for maps whose scene script runs on entry."""
    v = resolve('GROUP_' + map_name_, 'MAP_' + map_name_)
    check(g.run_until('OverworldLoop.loop', 120), 'raw_warp: not in the overworld loop')
    if before:
        before(g)
    g.write('wMapGroup', v['GROUP_' + map_name_])
    g.write('wMapNumber', v['MAP_' + map_name_])
    g.write('wXCoord', x)
    g.write('wYCoord', y)
    g.write('wDefaultSpawnpoint', 0xff)
    g.write('hMapEntryMethod', value('MAPSETUP_WARP'))
    g.write('wMapStatus', 1)


def inject(g, label, last_talked=None):
    """Queue a map script to run as if an object was talked to (for walking NPCs)."""
    bank, addr = g.addr(label)
    check(in_control(g, 30), 'inject: not in control')
    if last_talked is not None:
        g.write('hLastTalked', last_talked)
    g.write('wMapReentryScriptBank', bank)
    g.write('wMapReentryScriptAddress', [addr & 0xff, addr >> 8])
    g.write('wMapReentryScriptQueueFlag', 1)
    for _ in range(60):
        g.frames(1)
        if g.read('wScriptRunning'):
            return True
    return False


# --- Vermilion Port check-in ---------------------------------------------------------------
def _port(g, *, ticket=True, orange=False, first_time=True, weekday=None, walk=True):
    def before(g):
        from overworld import set_key_item
        set_key_item(g, 'S_S_TICKET', ticket)
        set_key_item(g, 'ORANGE_PASS', orange)
        set_event(g, 'EVENT_FAST_SHIP_FIRST_TIME', first_time)
    warp(g, 'VERMILION_PORT', 7, 10, before=before)
    if weekday is not None:
        set_weekday(g, value(weekday))
    if walk:
        check(step(g, 'down'), 'check-in coord event did not trigger')
    else:
        warp(g, 'VERMILION_PORT', 6, 10)
        interact(g, 'down')


def _port_case(g, base, name, kw, yes=(), menu=(), want_map=None, want_texts=()):
    g.load(base)
    _port(g, **kw)
    rec = run_script(g, yes=yes, menu=menu)
    res = dict(map=rec['map'], pos=rec['pos'], texts=rec['texts'], yesno=rec['yesno'], menus=rec['menus'],
               express=event(g, 'EVENT_TEMPORARY_UNTIL_MAP_RELOAD_3'), dest_olivine=event(g, 'EVENT_FAST_SHIP_DESTINATION_OLIVINE'),
               raid=event(g, 'EVENT_SS_AQUA_RAID'))
    if want_map:
        check(rec['map'] == want_map, 'wrong destination', case=name, **res)
    for t in want_texts:
        check(t in rec['texts'], 'missing text ' + t, case=name, **res)
    if rec['map'] == 'VERMILION_PORT':
        # turned away: control back on the pier, and the check-in can be triggered again
        check(rec['pos'] in ((8, 11), (6, 10)), 'turned-away position', case=name, **res)
        if rec['pos'] == (8, 11):
            again = step(g, 'left')
            check(again, 'check-in could not be re-triggered after a refusal', case=name)
            run_script(g, yes=[False] * 3, menu=['b'] * 2)
    if rec['map'] == 'FAST_SHIP_1F':
        check(not res['raid'], 'boarding at Vermilion started a raid', case=name, **res)
        check(res['dest_olivine'], 'westbound destination flag not set', case=name, **res)
    return res


@test('story')
def story_vermilion_checkin_matrix(g):
    """Vermilion check-in: every path (first-run refusal, weekdays, ticket, Orange Pass yes/no, the
    OLIVINE/VALENCIA/CANCEL menu and B), via the coord event and by talking to the sailor."""
    base = g.state()
    out = {}
    W = 'WEDNESDAY'
    cases = [
        ('first_run_refused', dict(first_time=False, weekday=W), (), (), 'VERMILION_PORT', ['VermilionPortFirstRunText']),
        ('monday_aqua_only', dict(weekday='MONDAY'), (), (), 'VERMILION_PORT', ['VermilionPortSailWednesdayText']),
        ('friday_aqua_only', dict(weekday='FRIDAY'), (), (), 'VERMILION_PORT', ['VermilionPortSailSundayText']),
        ('wed_aqua_yes', dict(weekday=W), [True], (), 'FAST_SHIP_1F', ['VermilionPortSSTicketText']),
        ('wed_aqua_no', dict(weekday=W), [False], (), 'VERMILION_PORT', ['VermilionPortComeAgainText']),
        ('wed_no_ticket', dict(weekday=W, ticket=False), [True], (), 'VERMILION_PORT', ['VermilionPortNoTicketText']),
        ('sun_menu_olivine', dict(weekday='SUNDAY', orange=True), (), [0], 'FAST_SHIP_1F', ['VermilionPortSSTicketText']),
        ('wed_menu_valencia', dict(weekday=W, orange=True), (), [1], 'VALENCIA_PORT', ['VermilionPortOrangePassText']),
        ('wed_menu_cancel', dict(weekday=W, orange=True), (), [2], 'VERMILION_PORT', ['VermilionPortComeAgainText']),
        ('wed_menu_b', dict(weekday=W, orange=True), (), ['b'], 'VERMILION_PORT', ['VermilionPortComeAgainText']),
        ('mon_pass_yes', dict(weekday='MONDAY', orange=True), [True], (), 'VALENCIA_PORT', ['VermilionPortOrangePassText']),
        ('mon_pass_no', dict(weekday='MONDAY', orange=True), [False], (), 'VERMILION_PORT', ['VermilionPortComeAgainText']),
        ('pass_before_first_run', dict(weekday=W, orange=True, first_time=False), [True], (), 'VALENCIA_PORT', []),
        ('pass_no_ticket_wed', dict(weekday=W, orange=True, ticket=False), [True], (), 'VALENCIA_PORT', []),
        ('talk_wed_aqua_yes', dict(weekday=W, walk=False), [True], (), 'FAST_SHIP_1F', []),
        ('talk_menu_valencia', dict(weekday=W, orange=True, walk=False), (), [1], 'VALENCIA_PORT', []),
        ('talk_menu_cancel', dict(weekday=W, orange=True, walk=False), (), [2], 'VERMILION_PORT', []),
    ]
    problems = []
    for name, kw, yes, menu, want_map, want_texts in cases:
        try:
            out[name] = _port_case(g, base, name, kw, yes, menu, want_map, want_texts)
        except AssertionError as e:
            problems.append(str(e)[:400])
            shot(g, 'checkin_' + name)
    check(not problems, 'check-in paths broken', problems=problems)
    return {k: (v['map'], v['pos'], v['yesno'], v['menus']) for k, v in out.items()}


@test('story')
def story_olivine_needs_league(g):
    """Before the Hall of Fame the Olivine walk-up sailor blocks the gangway: no raid can start."""
    def before(g):
        set_event(g, 'EVENT_OLIVINE_PORT_SPRITES_BEFORE_HALL_OF_FAME', False)
        set_event(g, 'EVENT_OLIVINE_PORT_SPRITES_AFTER_HALL_OF_FAME', True)
        set_event(g, 'EVENT_BEAT_ELITE_FOUR', False)
    warp(g, 'OLIVINE_PORT', 7, 14, before=before)
    started = step(g, 'down')
    rec = run_script(g, yes=[True] * 2) if started else {'texts': [], 'map': map_name(g)}
    out = dict(started=started, texts=rec['texts'], map=map_name(g), pos=(g.read('wXCoord'), g.read('wYCoord')),
               raid=event(g, 'EVENT_SS_AQUA_RAID'))
    check(out['map'] == 'OLIVINE_PORT' and not out['raid'], 'boarded before the League', **out)
    check(out['pos'] == (7, 14), 'walked past the pre-HOF sailor', **out)
    return out


# --- Saffron foreshadowing ------------------------------------------------------------------
@test('story')
def story_saffron_foreshadowing(g):
    """Saffron cooltrainer F / youngster / lass: Rocket rumour until Petrel (EXECUTIVEM_3) is beaten."""
    out = {}
    base = g.state()
    npcs = [('SaffronCityCooltrainerFScript', 4, 'SaffronCityCooltrainerFText'),
            ('SaffronCityYoungster1Script', 6, 'SaffronCityYoungster1Text'),
            ('SaffronCityLass2Script', 8, 'SaffronCityLass2Text')]
    for beaten in (False, True):
        g.load(base)
        warp(g, 'SAFFRON_CITY', 18, 30, before=lambda g: set_event(g, 'EVENT_BEAT_ROCKET_EXECUTIVEM_3', beaten))
        for script, idx, text in npcs:
            check(inject(g, script, idx), 'script did not start', script=script)
            rec = run_script(g)
            want = text + ('_RocketGone' if beaten else '')
            out['%s_%d' % (script, beaten)] = rec['texts']
            check(want in rec['texts'], 'wrong Saffron line', script=script, beaten=beaten, texts=rec['texts'])
    return out


# --- Wild Hunt: Ecruteak gate, Dance Theater, Route 39 ------------------------------------------
HUNT_STATES = {
    'before_pryce': dict(flags=dict(EVENT_BEAT_PRYCE=0, EVENT_ECRUTEAK_WILD_HUNT=1, EVENT_QUELLED_WILD_HUNT=0,
                                    EVENT_HEALED_MOOMOO=0), hunt=False),
    'after_pryce': dict(flags=dict(EVENT_BEAT_PRYCE=1, EVENT_ECRUTEAK_WILD_HUNT=0, EVENT_QUELLED_WILD_HUNT=1,
                                   EVENT_HEALED_MOOMOO=0), hunt=False),
    'during_hunt': dict(flags=dict(EVENT_BEAT_PRYCE=1, EVENT_ECRUTEAK_WILD_HUNT=0, EVENT_QUELLED_WILD_HUNT=1,
                                   EVENT_HEALED_MOOMOO=0, EVENT_TAUROS_HERD_LEADER=1), hunt=True),
    'after_hunt': dict(flags=dict(EVENT_BEAT_PRYCE=1, EVENT_ECRUTEAK_WILD_HUNT=1, EVENT_QUELLED_WILD_HUNT=0,
                                  EVENT_HEALED_MOOMOO=1), hunt=False),
}


def _hunt_setup(state):
    st = HUNT_STATES[state]

    def before(g):
        for f, on in st['flags'].items():
            set_event(g, f, bool(on))
        set_engine(g, 'ENGINE_WILD_HUNT', st['hunt'])
    return before


GATE_OBJS = {  # hide flag of each gate object, by role
    'rangers': 'EVENT_BEAT_PRYCE', 'officer': 'EVENT_ROUTE38_GATE_OFFICER', 'morty_girls': 'EVENT_ECRUTEAK_WILD_HUNT'}


@test('story')
def story_gate_visibility_by_hunt_state(g):
    """Route 38 gate, entered from Ecruteak, in each Wild Hunt state: who is there, can you pass,
    and does Morty usher you back mid-hunt."""
    base = g.state()
    out = {}
    want = {'before_pryce': dict(rangers=True, officer=False, morty_girls=False, passes=False),
            'after_pryce': dict(rangers=False, officer=False, morty_girls=True, passes=False),
            'after_hunt': dict(rangers=False, officer=True, morty_girls=False, passes=True)}
    for state, exp in want.items():
        g.load(base)
        warp(g, 'ROUTE_38_ECRUTEAK_GATE', 8, 4, before=_hunt_setup(state))
        vis = {k: not event(g, f) for k, f in GATE_OBJS.items()}
        stop = walk(g, 'LLLLLLL')
        pos = (g.read('wXCoord'), g.read('wYCoord'))
        passes = map_name(g) == 'ROUTE_38' or pos[0] <= 1
        out[state] = dict(vis=vis, pos=pos, map=map_name(g), passes=passes, script_at=stop)
        if stop is not None:
            run_script(g)
        for k in ('rangers', 'officer', 'morty_girls'):
            check(vis[k] == exp[k], 'gate %s visibility wrong' % k, state=state, **out[state])
        check(passes == exp['passes'], 'gate passability wrong', state=state, **out[state])
    # mid-hunt re-entry: Morty sends you back to Route 38
    g.load(base)
    raw_warp(g, 'ROUTE_38_ECRUTEAK_GATE', 8, 4, before=_hunt_setup('during_hunt'))
    rec = run_script(g)
    out['during_hunt'] = dict(map=rec['map'], pos=rec['pos'], texts=rec['texts'])
    check(rec['map'] == 'ROUTE_38' and rec['pos'] == (35, 8), 'mid-hunt re-entry not ushered to Route 38',
          **out['during_hunt'])
    check('Route38EcruteakGateMortyUsherText' in rec['texts'], 'usher text missing', **out['during_hunt'])
    return out


@test('story')
def story_gate_morty_starts_hunt(g):
    """After Pryce: Morty insists (NO loops back), YES starts the hunt and walks you onto Route 38."""
    warp(g, 'ROUTE_38_ECRUTEAK_GATE', 4, 4, before=_hunt_setup('after_pryce'))
    interact(g, 'left')
    rec = run_script(g, yes=[False, True])
    out = dict(map=rec['map'], pos=rec['pos'], yesno=rec['yesno'], hunt=engine(g, 'ENGINE_WILD_HUNT'),
               leader=event(g, 'EVENT_TAUROS_HERD_LEADER'), texts=rec['texts'])
    check(rec['yesno'] == 2 and 'MortyText_Refused' in rec['texts'], 'NO did not loop back', **out)
    check(rec['map'] == 'ROUTE_38' and out['hunt'], 'hunt did not start', **out)
    return out


@test('story')
def story_route39_scene_by_hunt_state(g):
    """Route 39 scene: WILD_HUNT only while the hunt is on and the herd leader is unfought."""
    base = g.state()
    out = {}
    for name, hunt, leader, want in (('no_hunt', False, False, 2), ('hunt', True, False, 0),
                                      ('hunt_leader_fought', True, True, 2), ('after_hunt', False, True, 2)):
        g.load(base)

        def before(g):
            set_engine(g, 'ENGINE_WILD_HUNT', hunt)
            set_event(g, 'EVENT_FOUGHT_WILD_HUNT_TAUROS_17', leader)
        warp(g, 'ROUTE_39', 7, 20, before=before)
        out[name] = scene(g, 'Route39')
        check(out[name] == want, 'Route 39 scene wrong', case=name, got=out[name], want=want)
    return out


@test('story')
def story_dance_theater_by_hunt_state(g):
    """Theater: Kimono Girls gone during the hunt and back after; gentleman/cooltrainer/granny lines."""
    base = g.state()
    out = {}
    talkers = [('DanceTheaterRockSmashGuy', 6), ('DanceTheaterCooltrainerMScript', 8), ('DanceTheaterGrannyScript', 9)]
    for state in ('before_pryce', 'after_pryce', 'after_hunt'):
        g.load(base)

        def before(g, state=state):
            _hunt_setup(state)(g)
            for k in ('NAOKO', 'SAYO', 'ZUKI', 'KUNI', 'MIKI'):
                set_event(g, 'EVENT_BEAT_KIMONO_GIRL_' + k, False)
        warp(g, 'DANCE_THEATER', 5, 9, before=before)
        res = {'girls_hidden': event(g, 'EVENT_QUELLED_WILD_HUNT')}
        for script, idx in talkers:
            check(inject(g, script, idx), 'script did not start', script=script)
            res[script] = run_script(g)['texts']
        out[state] = res
        hunt = state == 'after_pryce'
        check(res['girls_hidden'] == hunt, 'girls visibility wrong', state=state)
        check(('RockSmashGuyWildHuntText' in res['DanceTheaterRockSmashGuy']) == hunt, 'gentleman line', state=state, res=res)
        check(('DanceTheaterGrannyText_WildHunt' in res['DanceTheaterGrannyScript']) == hunt, 'granny line', state=state, res=res)
    return out


# --- Route 30 Hana, Ice Path Yuki ------------------------------------------------------------
def _kimono(g, mapname, x, y, facing, flag, tid):
    solo_party(g)
    warp(g, mapname, x, y, before=lambda g: set_event(g, flag, False))
    interact(g, facing)
    first = run_script(g, battle='win')
    check(len(first['battles']) == 1 and tuple(first['battles'][0]['trainer']) == _trainer('KIMONO_GIRL', tid),
          'trainer battle wrong', first=first)
    check(event(g, flag), 'beaten flag not set')
    interact(g, facing)
    again = run_script(g)
    check(not again['battles'], 're-fought')
    return dict(first=first['texts'], again=again['texts'])


@test('story')
def story_route30_hana_once(g):
    """Kimono Girl Hana (Route 30, 22,42): fights once, then only talks."""
    return _kimono(g, 'ROUTE_30', 22, 43, 'up', 'EVENT_BEAT_KIMONO_GIRL_HANA', 'HANA')


@test('story')
def story_icepath_yuki_once(g):
    """Kimono Girl Yuki (Ice Path B3F): fights once with her Glaceons, then only talks."""
    return _kimono(g, 'ICE_PATH_B3F', 10, 4, 'up', 'EVENT_BEAT_KIMONO_GIRL_YUKI', 'YUKI')


@test('story')
def story_route30_youngster_season(g):
    """The walking Route 30 youngster gives the season line after the egg quest, directions before."""
    out = {}
    base = g.state()
    for done in (False, True):
        g.load(base)
        warp(g, 'ROUTE_30', 7, 33, before=lambda g: set_event(g, 'EVENT_GAVE_MYSTERY_EGG_TO_ELM', done))
        check(inject(g, 'Route30YoungsterScript', 5), 'youngster script did not start')
        out[done] = run_script(g)['texts']
    check('Route30YoungsterText_DirectionsToMrPokemonsHouse' in out[False], 'pre-egg line', out=out)
    check(any(t.startswith('Route30Youngster') and t.endswith('Text') and 'Directions' not in t for t in out[True]),
          'season line missing', out=out)
    return out

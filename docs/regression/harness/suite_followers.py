"""Follower Pokémon (branch 85): movement, stowing and sprite selection.

Run: runner.py suite_followers --rom <debug ROM> --jobs 1
"""
import os
import re

import gb
from consts import value
from overworld import finish, set_key_item, settle, warp
from registry import check, test
from v10_overworld import (CONTROL_CAVES, _set_dig, _try_escape, end_call, here, map_id, run_queued,
                           start_call, walk)

EVID = os.path.join(gb.HERE, '..', 'followers')


def shot(g, name):
    os.makedirs(EVID, exist_ok=True)
    g.screenshot(os.path.join(EVID, name + '.png'))


def fol(g):
    return {'vis': not g.read('wObject1Flags') & 1, 'flags': g.read('wFollowerFlags'),
            'sprite': g.read('wObject1Sprite'),
            'f': (g.read('wObject1MapX'), g.read('wObject1MapY')),
            'p': (g.read('wPlayerMapX'), g.read('wPlayerMapY'))}


def adjacent(s):
    return abs(s['f'][0] - s['p'][0]) + abs(s['f'][1] - s['p'][1]) == 1


def visible_behind(g, what):
    s = fol(g)
    check(s['vis'] and adjacent(s), what, **s)
    return s


def species_id(g, name):
    return g.call('GetPokemonIDFromIndex', hl=value(name))['a']


def set_lead(g, name, dvs=(0x55, 0x55)):
    a = species_id(g, name)
    g.write('wPartySpecies', a)
    g.write('wPartyMon1Species', a)
    g.write('wPartyMon1DVs', list(dvs))
    return a


def bike(g):
    end_call(g, start_call(g, 'BikeFunction'))
    run_queued(g)
    check(finish(g, max_presses=100), 'no control after the bike')


@test('followers')
def follower_bike(g):
    """Getting on the bike puts the follower in its ball; it stays there while riding, even across a
    warp, and comes out one step after getting off."""
    set_key_item(g, 'BICYCLE')
    warp(g, 'NEW_BARK_TOWN', 13, 6)
    walk(g, 'down', 2)
    visible_behind(g, 'no follower before the bike')
    bike(g)
    check(g.read('wPlayerState') == value('PLAYER_BIKE'), 'not on the bike')
    walk(g, 'left', 3)
    s = fol(g)
    check(not s['vis'], 'follower visible on the bike', **s)
    warp(g, 'CHERRYGROVE_CITY', 29, 4)
    check(g.read('wPlayerState') == value('PLAYER_BIKE'), 'warp took the bike away')
    walk(g, 'down', 2)
    s = fol(g)
    check(not s['vis'], 'follower came back after a warp on the bike', **s)
    bike(g)
    check(g.read('wPlayerState') == value('PLAYER_NORMAL'), 'still on the bike')
    walk(g, 'left', 1)
    g.frames(20)
    shot(g, 'bike_off')
    return visible_behind(g, 'follower missing after getting off')


@test('followers')
def follower_ice_slide(g):
    """Sliding on Ice Path ice: the follower slides after the player and ends up behind them."""
    out = {}
    for name, (x, y, d) in {'ICE_PATH_1F': (31, 7, 'left'), 'MAHOGANY_GYM': (4, 15, 'up')}.items():
        warp(g, name, x, y)
        g.write('wMornEncounterRate', [0] * 5)  # a wild battle on Ice Path is RNG luck, not a follower bug
        back = {'left': 'right', 'up': 'down'}[d]
        walk(g, d, 1)
        check(fol(g)['vis'], 'follower missing before the ice', map=name, **fol(g))
        g.press(d, hold=16, after=4)
        settle(g, 900)
        g.frames(30)
        shot(g, 'ice_' + name.lower())
        out[name] = visible_behind(g, 'follower lost after sliding (%s)' % name)
        walk(g, back, 1)
    return out


@test('followers')
def follower_escape_and_dig(g):
    """Escape Rope and Dig: the follower is hidden on landing and reappears after one step."""
    base = g.state()
    out = {}
    name = 'UNION_CAVE_1F'
    (x, y), (n, dest) = CONTROL_CAVES[name]
    for routine in ('EscapeRopeEffect', 'DigFunction'):
        g.load(base)
        warp(g, name, x, y)
        _set_dig(g, n, dest)
        r = _try_escape(g, routine, rope_qty=3 if routine == 'EscapeRopeEffect' else None)
        check(r['queued'], 'no escape queued', routine=routine)
        run_queued(g)
        check(finish(g, max_presses=400), 'no control after escaping', routine=routine)
        check(here(g) == map_id(dest), 'wrong landing', at=here(g))
        for d in ('down', 'left', 'right', 'up'):
            walk(g, d, 1)
            if fol(g)['vis']:
                break
        out[routine] = visible_behind(g, 'follower missing after %s' % routine)
    return out


@test('followers')
def follower_fly(g):
    """Fly: the follower is hidden on landing and reappears after one step."""
    warp(g, 'NEW_BARK_TOWN', 13, 6)
    walk(g, 'down', 1)
    check(g.run_until('OverworldLoop.loop', 120), 'not in the overworld loop')
    g.write('wDefaultSpawnpoint', value('SPAWN_CHERRYGROVE'))
    g.write('hMapEntryMethod', value('MAPSETUP_FLY'))
    g.write('wMapStatus', 1)
    check(settle(g, 1200), 'no control after flying')
    check(here(g) == map_id('CHERRYGROVE_CITY'), 'did not land in Cherrygrove', at=here(g))
    s = fol(g)
    check(not s['vis'], 'follower visible on landing', **s)
    for d in ('down', 'left', 'right'):
        walk(g, d, 1)
        if fol(g)['vis']:
            break
    return visible_behind(g, 'follower missing after flying')


@test('followers')
def follower_all_fainted(g):
    """After a loss that doesn't white out, nobody follows (the chosen follower has fainted)."""
    warp(g, 'NEW_BARK_TOWN', 13, 6)
    walk(g, 'down', 1)
    for i in range(g.read('wPartyCount')):
        g.write('wPartyMon1HP+%d' % (i * value('PARTYMON_STRUCT_LENGTH')), [0, 0])
    warp(g, 'CHERRYGROVE_CITY', 29, 4)
    walk(g, 'down', 1)
    s = fol(g)
    check(g.read('wObject1Sprite') != value('SPRITE_FOLLOWER'), 'a fainted mon is following', **s)
    return s


@test('followers')
def follower_unown_letters(g):
    """Unown's follower sprite follows its letter."""
    out = {}
    warp(g, 'NEW_BARK_TOWN', 13, 6)
    for dvs in ((0x00, 0x00), (0xff, 0xff), (0x5a, 0x3c)):
        set_lead(g, 'UNOWN', dvs)
        r = g.call('GetFollowerSpriteData')
        g.write('wUnownLetter', 0)
        g.call('GetUnownLetter', hl=g.addr('wPartyMon1DVs')[1])
        letter = g.read('wUnownLetter')
        want = g.addr('Unown%sFollowerGFX' % chr(ord('A') + letter - 1))
        got = ((r['hl'] >> 8), r['de'])
        check(got == want, 'wrong Unown sprite', letter=letter, got=got, want=want)
        out['%02x%02x' % dvs] = chr(ord('A') + letter - 1)
    return out


def _drive(g, party_slot=0, max_steps=600):
    """B through text, yes to questions, pick `party_slot` at a party menu, until control returns."""
    from overworld import answer, in_control, pick_party
    labels = ['YesNoBox', 'PartyMenuSelect']
    for _ in range(max_steps):
        hit = g.run_until_any(labels, 6)
        if hit is None:
            if g.read('wScriptRunning') == 0 and in_control(g, 6):
                return True
            g.hold('b', True)
            hit = g.run_until_any(labels, 3)
            g.hold('b', False)
        if hit == 'YesNoBox':
            answer(g, True)
        elif hit == 'PartyMenuSelect':
            pick_party(g, party_slot)
    return False


@test('followers')
def follower_daycare_deposit(g):
    """Leaving the lead mon at the Day-Care swaps the follower to the new lead."""
    from game import set_event
    warp(g, 'DAY_CARE', 5, 6, before=lambda g: set_event(g, 'EVENT_GOT_LUCKY_EGG'))
    walk(g, 'up', 2)
    lead = g.read('wPartySpecies')
    check(g.read('wFollowerSpriteID') == lead, 'follower is not the lead before')
    g.press('a', hold=4, after=10)
    check(_drive(g), 'Day-Care never handed back control')
    new = g.read('wPartySpecies')
    check(new != lead, 'nothing was deposited', lead=lead)
    walk(g, 'down', 1)
    got = g.read('wFollowerSpriteID')
    shot(g, 'daycare')
    check(got == new, 'follower still shows the deposited mon', got=got, new=new, old=lead)
    return {'old': lead, 'new': new}


@test('followers')
def follower_lead_change_in_script(g):
    """A script that changes the lead (simulated: party rewritten, then any script ends) reloads the
    follower's sprite."""
    from v10_story import inject, run_script
    warp(g, 'NEW_BARK_TOWN', 13, 6)
    walk(g, 'down', 1)
    old = g.read('wFollowerSpriteID')
    new = set_lead(g, 'CHARIZARD')
    check(new != old, 'lead already Charizard')
    check(inject(g, 'NewBarkTownSign'), 'sign script did not start')
    run_script(g)
    g.frames(10)
    shot(g, 'lead_change')
    got = g.read('wFollowerSpriteID')
    check(got == new, 'follower not refreshed', got=got, new=new, old=old)
    return {'old': old, 'new': new}


@test('followers')
def follower_cutscene_stow(g):
    """A cutscene NPC that would walk through the follower (New Bark teacher, follower on her side):
    the follower is stowed for the scene, nobody shares its tile, and it is back one step after."""
    from follower_watch import Watch
    from v10_story import run_script, step
    scene = 0  # SCENE_NEWBARKTOWN_TEACHER_STOPS_YOU (map-local constant)
    warp(g, 'NEW_BARK_TOWN', 4, 8, before=lambda g: g.write('wNewBarkTownSceneID', scene))
    walk(g, 'left', 2)
    s = visible_behind(g, 'no follower before the scene')
    check(s['f'][0] > s['p'][0], 'follower not on the teacher\'s side', **s)
    check(step(g, 'left'), 'teacher scene did not start')
    w = Watch()
    run_script(g, tick=w.sample)
    check(not w.result(), 'something walked through the follower', hits=w.result())
    check(not fol(g)['vis'], 'follower out at the end of the scene', **fol(g))
    for d in ('right', 'up', 'down'):
        walk(g, d, 1)
        if fol(g)['vis']:
            break
    shot(g, 'cutscene_stow')
    return visible_behind(g, 'follower missing one step after the scene')


@test('followers')
def follower_surf_to_land(g):
    """Surfing: the follower stays in its ball on the water and comes out once the player is back on land."""
    warp(g, 'CHERRYGROVE_CITY', 8, 6, surf=True)
    walk(g, 'right', 1)
    check(g.read('wPlayerState') == value('PLAYER_SURF'), 'not surfing')
    s = fol(g)
    check(not s['vis'], 'follower out on the water', **s)
    walk(g, 'right', 2)
    check(g.read('wPlayerState') == value('PLAYER_NORMAL'), 'still surfing')
    g.frames(20)
    shot(g, 'surf_to_land')
    return visible_behind(g, 'follower missing back on land')


def _party_menu(g):
    from v10_overworld import text_rows
    g.press('start', after=30)
    for _ in range(10):
        rows = text_rows(g)
        cur = g.read('wMenuCursorY')
        line = rows[2 * cur] if 2 * cur < 18 else ''
        if 'MON' in line and 'DEX' not in line:
            break
        g.press('down', after=8)
    else:
        raise AssertionError('POKEMON not found in the start menu')
    g.press('a', after=90)


def _cursor_to(g, row):
    """Party menu cursor onto 0-based `row` (wPartyCount is CANCEL)."""
    for _ in range(12):
        cur = g.read('wMenuCursorY') - 1
        if cur == row:
            return
        g.press('down' if cur < row else 'up', after=8)
    raise AssertionError('cursor never reached row %d' % row)


def _marks(g):
    from visual import tilemap
    rows = tilemap(g)
    return [i for i in range(g.read('wPartyCount')) if rows[2 + 2 * i][4] == value('FOLLOWER_MARK_TILE')]


def _close_menus(g):
    from overworld import in_control
    for _ in range(10):
        g.press('b', after=30)
        if in_control(g, 10):
            return True
    return False


def _step_out(g):
    for d in ('down', 'up', 'left', 'right'):
        walk(g, d, 1)
        if fol(g)['vis']:
            break


@test('followers')
def follower_select_choice(g):
    """SELECT in the start menu's party screen: marks a mon with F and it follows; SELECT on it again
    means no follower; CANCEL and eggs are refused."""
    out = {}
    warp(g, 'NEW_BARK_TOWN', 13, 6)
    walk(g, 'down', 1)
    _party_menu(g)
    check(_marks(g) == [0], 'lead not marked by default', marks=_marks(g))
    _cursor_to(g, 1)
    g.press('select', after=40)
    check(g.read('wFollowerSlot') == 1 and _marks(g) == [1], 'SELECT did not choose mon 2',
          slot=g.read('wFollowerSlot'), marks=_marks(g))
    shot(g, 'select_menu')
    check(_close_menus(g), 'no control after the menu')
    _step_out(g)
    s = visible_behind(g, 'chosen follower not out')
    want = g.read('wPartySpecies+1')
    check(g.read('wFollowerSpriteID') == want, 'wrong mon following', got=g.read('wFollowerSpriteID'), want=want)
    out['chosen'] = s
    _party_menu(g)
    _cursor_to(g, 1)
    g.press('select', after=40)
    check(g.read('wFollowerSlot') == 0xff and _marks(g) == [], 'SELECT again did not clear it',
          slot=g.read('wFollowerSlot'), marks=_marks(g))
    _cursor_to(g, g.read('wPartyCount'))
    g.press('select', after=40)  # CANCEL row
    check(g.read('wFollowerSlot') == 0xff, 'SELECT on CANCEL chose something')
    check(_close_menus(g), 'no control after the menu')
    walk(g, 'down', 1)
    walk(g, 'up', 1)
    check(g.read('wObject1Sprite') != value('SPRITE_FOLLOWER'), 'follower still out with none chosen', **fol(g))
    warp(g, 'CHERRYGROVE_CITY', 29, 4)
    walk(g, 'down', 1)
    check(g.read('wObject1Sprite') != value('SPRITE_FOLLOWER'), 'follower back after a warp', **fol(g))
    # an egg can't be chosen
    g.write('wPartySpecies+2', value('EGG'))
    _party_menu(g)
    _cursor_to(g, 2)
    g.press('select', after=40)
    check(g.read('wFollowerSlot') == 0xff, 'an egg was chosen', slot=g.read('wFollowerSlot'))
    _close_menus(g)
    return out


@test('followers')
def follower_fainted_comes_back(g):
    """The chosen follower faints: it's put away (the F stays) and comes back once healed."""
    from v10_story import inject, run_script
    warp(g, 'NEW_BARK_TOWN', 13, 6)
    walk(g, 'down', 1)
    visible_behind(g, 'no follower to start with')
    hp = g.read('wPartyMon1HP', 2)
    g.write('wPartyMon1HP', [0, 0])
    check(inject(g, 'NewBarkTownSign'), 'sign script did not start')
    run_script(g)
    check(g.read('wObject1Sprite') != value('SPRITE_FOLLOWER'), 'fainted follower still out', **fol(g))
    check(g.read('wFollowerSlot') == 0, 'choice lost on fainting', slot=g.read('wFollowerSlot'))
    walk(g, 'down', 1)
    check(g.read('wObject1Sprite') != value('SPRITE_FOLLOWER'), 'fainted follower back after a step', **fol(g))
    g.write('wPartyMon1HP', hp)  # healed (Pokecenter or a Revive)
    check(inject(g, 'NewBarkTownSign'), 'sign script did not start')
    run_script(g)
    _step_out(g)
    return visible_behind(g, 'healed follower did not come back')


@test('followers')
def follower_slot_on_removal(g):
    """Removing party mons (Day-Care/trade path and the PC path) and switching them keep the
    follower on its mon; removing the follower hands the slot to the mon that moves into it, or
    the one above if it was last."""
    warp(g, 'NEW_BARK_TOWN', 13, 6)
    base = g.state()
    out = {}
    cases = [  # (follower slot, removed slot, expected)
        (2, 2, 2), (5, 5, 4), (3, 1, 2), (1, 4, 1), (0xff, 0, 0xff)]
    for how in ('party', 'pc'):
        for slot, removed, want in cases:
            g.load(base)
            check(g.read('wPartyCount') == 6, 'fixture party is not full')
            g.write('wFollowerSlot', slot)
            if how == 'party':
                g.write('wCurPartyMon', removed)
                g.write('wPokemonWithdrawDepositParameter', 0)
                g.call('RemoveMonFromParty')
            else:
                g.call('RemoveStorageBoxMon', bc=removed + 1)
            got = g.read('wFollowerSlot')
            check(g.read('wPartyCount') == 5, 'mon not removed', how=how)
            check(got == want, 'wrong follower slot after removal', how=how, slot=slot, removed=removed,
                  got=got, want=want)
            out['%s %d-%d' % (how, slot, removed)] = got
    for (a, b), slot, want in (((0, 3), 0, 3), ((0, 3), 3, 0), ((0, 3), 2, 2)):
        g.load(base)
        g.write('wFollowerSlot', slot)
        g.call('SwapPartyMons', bc=a + 1, de=b + 1)
        check(g.read('wFollowerSlot') == want, 'follower did not move with its mon', swap=(a, b), slot=slot,
              got=g.read('wFollowerSlot'), want=want)
    return out


@test('followers')
def follower_double_happiness(g):
    """The active follower gains double happiness; losses, other mons, a fainted follower and
    'no follower' are unchanged, and the gain still caps at 255."""
    warp(g, 'NEW_BARK_TOWN', 13, 6)
    walk(g, 'down', 1)
    hap = lambda i: g.read('wPartyMon%dHappiness' % (i + 1))

    def change(mon, kind, start):
        g.write('wPartyMon%dHappiness' % (mon + 1), start)
        g.write('wCurPartyMon', mon)
        g.call('ChangeHappiness', bc=value(kind))
        return hap(mon) - start

    out = {}
    g.write('wFollowerSlot', 0)
    out['follower_level'] = change(0, 'HAPPINESS_GAINLEVEL', 50)
    check(out['follower_level'] == 10, 'follower level-up gain not doubled', **out)
    out['other_level'] = change(1, 'HAPPINESS_GAINLEVEL', 50)
    check(out['other_level'] == 5, 'non-follower gain changed', **out)
    out['follower_step_high'] = change(0, 'HAPPINESS_STEP', 210)
    check(out['follower_step_high'] == 0, '+0 step gain became nonzero', **out)
    out['follower_loss'] = change(0, 'HAPPINESS_FAINTED', 50)
    check(out['follower_loss'] == -1, 'follower loss changed', **out)
    out['follower_cap'] = change(0, 'HAPPINESS_YOUNGCUT3', 250)
    check(hap(0) == 255, 'gain did not cap at 255', **out)
    g.write('wFollowerSlot', 1)
    out['chosen_mon2'] = change(1, 'HAPPINESS_GAINLEVEL', 50)
    out['old_lead'] = change(0, 'HAPPINESS_GAINLEVEL', 50)
    check(out['chosen_mon2'] == 10 and out['old_lead'] == 5, 'bonus not following the choice', **out)
    hp = g.read('wPartyMon2HP', 2)
    g.write('wPartyMon2HP', [0, 0])
    out['fainted'] = change(1, 'HAPPINESS_USEDITEM', 50)
    g.write('wPartyMon2HP', hp)
    check(out['fainted'] == 5, 'fainted follower got the bonus', **out)
    g.write('wFollowerSlot', 0xff)
    out['none'] = change(0, 'HAPPINESS_GAINLEVEL', 50)
    check(out['none'] == 5, 'bonus with no follower chosen', **out)
    g.write('wFollowerSlot', 0)
    return out


# --- talking to the follower (FollowerInteractionTable, plan §4.6) ---
_TALK_OK = set('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .!?/-')


def _talk_texts(label):
    """Literal strings a FollowerInteractionTable script can print (its own and the global texts it
    writes), limited to what visual.text_rows can decode."""
    src = open(os.path.join(gb.REPO, 'engine', 'events', 'follower.asm')).read()

    def body(lab):
        m = re.search(r'^%s::?\n(.*?)(?=^[A-Za-z_]\w*::?\s*$)' % re.escape(lab), src, re.M | re.S)
        return m.group(1) if m else ''
    b = body(label)
    for ref in re.findall(r'^\s*(?:writetext|jumptext)\s+([A-Za-z_]\w*)', b, re.M):
        b += body(ref)
    lits = [t.replace('@', '').strip() for t in re.findall(r'^\s*(?:text|line|cont|para)\s+"(.*)"', b, re.M)]
    return [t for t in lits if len(t) >= 6 and set(t) <= _TALK_OK]


def _stand_spot(rom, name):
    """(x, y) on map NAME where the player can warp in and step down once with the follower landing
    behind: plain land, away from warps, coord events, NPCs and trainers' lines of sight."""
    from follower_sweep import Coll, load_tables
    _attrs, _scenes, tilesets, dims = load_tables()
    camel = next(c for c in tilesets if c.lower() == name.replace('_', '').lower())
    coll = Coll(rom, rom[:-4] + '.sym', tilesets, dims)
    asm = open(os.path.join(gb.REPO, 'maps', camel + '.asm')).read()
    avoid = {(int(x), int(y)) for x, y in re.findall(r'^\s*(?:warp_event|coord_event)\s+(\d+),\s*(\d+)', asm, re.M)}
    objs = re.findall(r'^\s*object_event\s+(\d+),\s*(\d+),.*?(OBJECTTYPE_\w+)', asm, re.M)
    w, h = dims[name]
    cx, cy = w, h

    def ok(x, y):
        if (x, y) in avoid or not coll.land(camel, name, x, y):
            return False
        for ox, oy, kind in objs:
            ox, oy = int(ox), int(oy)
            if abs(ox - x) + abs(oy - y) <= 2:
                return False
            if kind == 'OBJECTTYPE_TRAINER' and ((ox == x and abs(oy - y) <= 6) or (oy == y and abs(ox - x) <= 6)):
                return False
        return True
    spots = [(x, y) for y in range(2 * h - 1) for x in range(2 * w) if ok(x, y) and ok(x, y + 1)]
    check(spots, 'no standing spot', map=name)
    return sorted(spots, key=lambda p: abs(p[0] - cx) + abs(p[1] - cy))


def _talk(g):
    """Face the follower (behind, above the player) and talk; return every text-box line shown."""
    from overworld import in_control, interact
    from visual import text_rows

    def box():
        rows = text_rows(g)[12:18]
        return rows if rows[0].startswith('+---') and rows[-1].startswith('+---') else None
    interact(g, 'up')
    for _ in range(60):
        g.frames(4)
        if box():
            break
    else:
        return []
    seen = []
    for _ in range(150):
        g.frames(6)
        rows = box()
        if rows:
            for r in rows[1:-1]:
                r = r.strip('|').strip()
                if r and r not in seen:
                    seen.append(r)
        elif in_control(g, 4, stable=4):
            break
        g.press('b', hold=3, after=3)
    return seen


TALK_CASES = [
    # (what the row checks, species, status, events on, events off, map, weather, expected script)
    ('default (no row matches)', 'CHIKORITA', 0, (), (), 'NEW_BARK_TOWN', 'none', 'DefaultInteraction'),
    ('status: poison', 'CHIKORITA', 1 << 3, (), (), 'NEW_BARK_TOWN', 'none', 'PoisonInteraction'),
    ('species + landmark', 'SUDOWOODO', 0, (), (), 'ROUTE_36', 'none', 'Route36Interaction'),
    ('status beats species + landmark', 'SUDOWOODO', 1 << 3, (), (), 'ROUTE_36', 'none', 'PoisonInteraction'),
    ('type + landmark', 'CYNDAQUIL', 0, (), (), 'AZALEA_TOWN', 'none', 'AzaleaTownInteraction'),
    ('type + map', 'ABRA', 0, (), (), 'MR_PSYCHICS_HOUSE', None, 'MrPsychicsHouseInteraction'),
    ('event set', 'SLOWPOKE', 0, ('EVENT_CLEARED_SLOWPOKE_WELL',), (), 'SLOWPOKE_WELL_B2F', None,
     'SlowpokeWellInteraction'),
    ('event clear', 'SLOWPOKE', 0, (), ('EVENT_CLEARED_SLOWPOKE_WELL',), 'SLOWPOKE_WELL_B2F', None,
     'SlowpokeWellRocketInteraction'),
    ('Orange Islands', 'LUGIA', 0, (), (), 'SHAMOUTI_ISLAND', 'none', 'ShamoutiLegendInteraction'),
    ('Silver Cave', 'CHIKORITA', 0, (), (), 'SILVER_CAVE_ROOM_1', None, 'SilverCaveInteraction'),
    ('weather + type', 'SWINUB', 0, (), (), 'NEW_BARK_TOWN', 'snow', 'ColdIceMonInteraction'),
    ('weather, any mon', 'CHIKORITA', 0, (), (), 'NEW_BARK_TOWN', 'snow', 'SnowInteraction'),
    ('rain + Fire type', 'CYNDAQUIL', 0, (), (), 'NEW_BARK_TOWN', 'rain', 'RainFireMonInteraction'),
]


@test('followers')
def follower_interactions(g):
    """Talking to the follower runs the first FollowerInteractionTable row that matches: status rows,
    species/type with landmark or map, the event column, Orange Islands, Silver Cave, weather rows and
    the default. Each case checks for the expected script's text on screen."""
    from game import set_event
    import suite_weather
    base = g.state()
    out, bad = {}, {}
    for what, species, status, on, off, name, weather, script in TALK_CASES:
        want = _talk_texts(script)
        check(want, 'no checkable text in the script', script=script)
        g.load(base)
        sid = set_lead(g, species)
        g.write('wPartyMon1Status', status)
        for e in on:
            set_event(g, e, True)
        for e in off:
            set_event(g, e, False)
        got = None
        for x, y in _stand_spot(g.rom, name)[:6]:
            suite_weather.warp(g, name, x, y, weather=weather)
            if weather not in (None, 'none'):
                check(g.read('wCurWeather') == suite_weather.W[weather], 'weather not forced',
                      case=what, cur=g.read('wCurWeather'))
            walk(g, 'down', 1)
            s = fol(g)
            if s['vis'] and s['f'] == (s['p'][0], s['p'][1] - 1) and (g.read('wXCoord'), g.read('wYCoord')) == (x, y + 1):
                got = _talk(g)
                break
        if got is None:
            bad[what] = 'could not stand with the follower behind (%s)' % name
            continue
        check(g.read('wFollowerSpriteID') == sid, 'wrong follower species', case=what,
              got=g.read('wFollowerSpriteID'), want=sid)
        hit = [t for t in want if any(t in r for r in got)]
        out[what] = {'script': script, 'shown': got[:6], 'matched': hit[:2]}
        if not hit:
            bad[what] = {'want': script, 'shown': got[:6]}
            shot(g, 'talk_' + re.sub(r'\W+', '_', what))
    check(not bad, 'wrong or missing follower interaction', bad=bad)
    return out


@test('followers')
def static_text_command_then_char(g):
    """No text_ram / text_decimal / text_bcd is followed directly by a character macro (line, cont,
    para, next, page, done, prompt). Those emit characters, but after a text command the engine reads
    the next byte as another command: <LINE> ($4f) indexed past TextCommands and jumped into WRAM
    (18 follower interactions, fixed in 1321aa614). Use text / text_start first."""
    chars = ('line', 'cont', 'para', 'next', 'page', 'done', 'prompt')
    bad, files = [], 0
    for top in ('data', 'engine', 'home', 'maps', 'mobile', 'lib', 'audio', 'gfx'):
        for root, _dirs, names in os.walk(os.path.join(gb.REPO, top)):
            for n in names:
                if not n.endswith('.asm'):
                    continue
                files += 1
                path = os.path.join(root, n)
                lines = open(path, encoding='utf-8', errors='ignore').read().split('\n')
                for i, l in enumerate(lines):
                    if not re.match(r'\s*text_(ram|decimal|bcd)\b', l):
                        continue
                    j = i + 1
                    while j < len(lines) and (not lines[j].strip() or lines[j].strip().startswith(';')):
                        j += 1
                    if j < len(lines) and lines[j].split() and lines[j].split()[0] in chars:
                        bad.append('%s:%d %s' % (os.path.relpath(path, gb.REPO), i + 1, lines[j].strip()))
    check(not bad, 'text command followed by a character macro', hits=bad[:30], n=len(bad))
    return {'files': files}


@test('followers')
def follower_surf_turn_back(g):
    """One step onto land, the hidden follower still stands on the water behind: turning back and
    pressing A must offer Surf, not talk to the invisible follower."""
    from game import set_engine
    from overworld import interact
    set_engine(g, 'ENGINE_GLACIERBADGE')
    warp(g, 'CHERRYGROVE_CITY', 8, 6, surf=True)
    walk(g, 'right', 1)
    for _ in range(3):
        if g.read('wPlayerState') == value('PLAYER_NORMAL'):
            break
        walk(g, 'right', 1)
    check(g.read('wPlayerState') == value('PLAYER_NORMAL'), 'still surfing')
    s = fol(g)
    check(not s['vis'] and s['f'][0] == s['p'][0] - 1, 'follower not hidden on the water behind', **s)
    interact(g, 'left')
    hit = g.run_until_any(['YesNoBox'], 400)
    shot(g, 'surf_turn_back')
    check(hit == 'YesNoBox', 'no Surf prompt', **fol(g))
    return s


def _watched_scene(g, **kw):
    from follower_watch import Watch
    from v10_story import run_script
    w = Watch()
    out = run_script(g, tick=w.sample, **kw)
    check(not w.result(), 'something walked through the follower', hits=w.result())
    return out


@test('followers')
def follower_route39_herd_leader(g):
    """Wild Hunt herd leader lands on the tile right of the player: the follower there is stowed."""
    from game import set_engine, set_event
    from v10_story import step

    def before(g):
        set_engine(g, 'ENGINE_WILD_HUNT')
        set_event(g, 'EVENT_FOUGHT_WILD_HUNT_TAUROS_17', False)
    warp(g, 'ROUTE_39', 3, 5, before=before)
    walk(g, 'up', 1)
    walk(g, 'left', 1)
    s = visible_behind(g, 'no follower before the scene')
    check(step(g, 'left'), 'herd leader scene did not start', **s)
    _watched_scene(g, battle='win')
    _step_out(g)
    return visible_behind(g, 'follower missing after the scene')


@test('followers')
def follower_route39_barn_whitney(g):
    """Healing Moomoo from its right: Whitney steps onto the tile below the player and walks out."""
    from game import set_event
    from overworld import interact
    warp(g, 'ROUTE_39_BARN', 4, 5, before=lambda g: set_event(g, 'EVENT_HEALED_MOOMOO', False))
    g.write('wNumBerries', 1)
    g.write('wBerries', [value('GOLD_BERRY') & 0xff, 1, 0xff])  # berries store the index's low byte
    walk(g, 'up', 2)
    s = visible_behind(g, 'no follower before the scene')
    check(s['f'] == (s['p'][0], s['p'][1] + 1), 'follower not below the player', **s)
    interact(g, 'left')
    out = _watched_scene(g, yes=[True])
    check(any('Congratulations' in t for t in out['texts']), 'Moomoo was not healed', texts=out['texts'])
    _step_out(g)
    return visible_behind(g, 'follower missing after the scene')

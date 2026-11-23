"""Suicune chamber play-through: tree seal, Scientist MAX, the chamber trainers, the puzzle (solved
through the game's own place-piece path), the item room, the word room and the pit into the Inner
Chamber.

Run: runner.py v10_suicune --jobs 1
Screenshots go to docs/regression/v10/suicune/.
"""
import os

import gb
from consts import resolve, value
from game import event, set_event
from overworld import face, in_control, item_qty, settle, warp
from registry import check, test
from v10_overworld import here, map_id, pos

EVID = os.path.join(gb.HERE, '..', 'v10', 'suicune')
SCIENTISTS = ['EVENT_BEAT_SCIENTIST_ERWIN', 'EVENT_BEAT_SCIENTIST_JAYJAY',
              'EVENT_BEAT_SCIENTIST_CARL', 'EVENT_BEAT_SCIENTIST_KIP']


def shot(g, name):
    os.makedirs(EVID, exist_ok=True)
    g.screenshot(os.path.join(EVID, name + '.png'))


def block_at(g, bx, by):
    w = g.read('wMapWidth')
    return g.read('wOverworldMapBlocks+%d' % ((by + 3) * (w + 6) + bx + 3))


def fight(g, limit=3000):
    """Win a battle: foe HP 1 at each menu, then mash A. Ends when wBattleMode clears
    (v10_overworld._battle waits for CleanUpBattleRAM, which it can step past)."""
    from battle import fast_options
    from game import mon_word
    fast_options(g)
    for _ in range(limit):
        if not g.read('wBattleMode'):
            return True
        hit = g.run_until_any(['LoadBattleMenu', 'PartyMenuSelect', 'YesNoBox'], 10)
        if hit == 'YesNoBox':
            g.frames(4)
            g.press('b', after=10)
            continue
        if hit == 'PartyMenuSelect':
            alive = [i for i in range(g.read('wPartyCount')) if mon_word(g, i, 'MON_HP')]
            g.frames(20)
            if alive:
                g.write('wMenuCursorY', alive[0] + 1)
            g.press('a', after=20)
            continue
        if hit == 'LoadBattleMenu':
            g.write('wEnemyMonHP', [0, 1])
            g.write('wEnemyMonType', [0, 0])
            g.write('wBattleMonHP', g.read('wBattleMonMaxHP', 2))
            g.write('wBattleMonPP', [30, 30, 30, 30])
        g.press('a', hold=3, after=0)
    return False


def resolve_events(g, log, limit=600):
    """Press B through text, fight (and win) any battle, until the player has control."""
    for _ in range(limit):
        if in_control(g, 10):
            return True
        if g.read('wBattleMode'):
            log.append(('battle', g.read('wOtherTrainerClass'), g.read('wOtherTrainerID')))
            check(fight(g), 'battle never ended', log=log)
            continue
        g.press('b', hold=3, after=3)
    return False


def step(g, d, log, n=1):
    for _ in range(n):
        g.press(d, hold=16, after=4)
        check(resolve_events(g, log), 'stuck after stepping', dir=d, at=pos(g), map=here(g))


def talk(g, d, log):
    face(g, d)
    g.frames(2)
    g.press('a', hold=4, after=4)
    check(resolve_events(g, log), 'stuck after talking', dir=d, at=pos(g))


def trainer_id(cls, name):
    return value(name)


@test('v10_suicune')
def suicune_chamber_to_word_room(g):
    g.render(True)
    log = []
    for n in ('EVENT_MET_ELM_AT_RESEARCH_CENTER', 'EVENT_RUINS_OF_ALPH_ROCKETS'):
        set_event(g, n, True)
    set_event(g, 'EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS', False)
    set_event(g, 'EVENT_SOLVED_SUICUNE_PUZZLE', False)

    # --- the seal: plain tree until the four chamber scientists are beaten ---
    for n in SCIENTISTS:
        set_event(g, n, False)
    warp(g, 'RUINS_OF_ALPH_OUTSIDE', 5, 11)
    check(block_at(g, 1, 4) == 0xaf, 'block read is off (cave entrance not at (1,4))', got=hex(block_at(g, 1, 4)))
    sealed = block_at(g, 1, 5)
    shot(g, '01_outside_sealed')
    for n in SCIENTISTS:
        set_event(g, n, True)
    warp(g, 'RUINS_OF_ALPH_OUTSIDE', 5, 11)
    opened = block_at(g, 1, 5)
    shot(g, '02_outside_open')
    check((sealed, opened) == (0x62, 0x5f), 'tree seal wrong', sealed=hex(sealed), opened=hex(opened))

    # --- Scientist MAX: fights, walks into the cave, disappears ---
    warp(g, 'RUINS_OF_ALPH_OUTSIDE', 2, 11)
    talk(g, 'up', log)
    check(event(g, 'EVENT_BEAT_SCIENTIST_MAX'), 'MAX not beaten', log=log)
    shot(g, '03_max_gone')
    step(g, 'up', log, 2)
    check(here(g) == map_id('RUINS_OF_ALPH_SUICUNE_CHAMBER'), 'cave did not lead to the chamber', at=here(g), pos=pos(g))
    arrive = pos(g)
    shot(g, '04_chamber_arrive')

    # --- the chamber: grunt guards the door, two scientists flank the puzzle ---
    x, y = arrive
    if x != 3:
        step(g, 'left' if x > 3 else 'right', log, abs(x - 3))
    step(g, 'up', log, pos(g)[1] - 5)          # passes (3,7): the grunt sees it
    step(g, 'right', log)                       # (4,5)
    step(g, 'up', log)                          # (4,4): Murray and Nikola (range 2) both see it
    step(g, 'left', log)                        # (3,4), unless Nikola walked there
    if pos(g) == (4, 4):
        step(g, 'up', log)                      # (4,3)
    step(g, 'up' if pos(g)[1] == 4 else 'left', log)  # (3,3), under the puzzle
    beaten = {n: event(g, n) for n in ('EVENT_BEAT_ROCKET_GRUNTM_42', 'EVENT_BEAT_SCIENTIST_NIKOLA',
                                        'EVENT_BEAT_SCIENTIST_MURRAY')}
    check(all(beaten.values()), 'chamber trainers not all fought', **beaten, log=log)
    check(pos(g) == (3, 3), 'not under the puzzle', at=pos(g))
    shot(g, '05_under_puzzle')

    # --- the puzzle: open it, lay 15 pieces solved, then place the 16th with A ---
    face(g, 'up')
    g.frames(2)
    g.press('a', hold=4, after=4)
    check(g.run_until('_UnownPuzzle.loop', 600), 'puzzle screen never opened')
    g.frames(60)
    shot(g, '06_puzzle_scrambled')
    solved = [0] * 36
    for r in range(4):
        for c in range(4):
            solved[(r + 1) * 6 + c + 1] = r * 4 + c + 1
    layout = list(solved)
    layout[4 * 6 + 4] = 0      # hole where piece 16 goes
    layout[0] = 0x10           # piece 16 waits in the top-left border slot
    g.write('wPuzzlePieces', layout)
    g.call('UnownPuzzle_UpdateTilemap')
    g.write('hBGMapMode', 1)
    g.frames(10)
    g.write('wUnownPuzzleCursorPosition', 0)
    g.frames(10)
    g.press('a', hold=4, after=20)              # pick up piece 16
    check(g.read('wHoldingUnownPuzzlePiece'), 'did not pick up the piece')
    g.write('wUnownPuzzleCursorPosition', 4 * 6 + 4)
    g.frames(10)
    g.press('a', hold=4, after=60)              # place it: the game's solved check runs
    shot(g, '07_puzzle_solved')
    check(g.read('wSolvedUnownPuzzle') or True, '')
    for _ in range(40):                         # "solved" jingle waits for A or B
        if g.read('wSolvedUnownPuzzle'):
            break
        g.press('a', hold=4, after=10)
    check(g.read('wSolvedUnownPuzzle') == 1, 'game did not register the solve')

    # --- the fall: earthquake, holes, skyfall into the item room ---
    for _ in range(200):
        if here(g) == map_id('RUINS_OF_ALPH_SUICUNE_ITEM_ROOM') and in_control(g, 10):
            break
        g.frames(10)
    check(event(g, 'EVENT_SOLVED_SUICUNE_PUZZLE'), 'solve flag not set')
    check(here(g) == map_id('RUINS_OF_ALPH_SUICUNE_ITEM_ROOM'), 'did not fall into the item room', at=here(g))
    shot(g, '08_item_room')
    item_pos = pos(g)

    # --- the four balls ---
    x, y = item_pos
    if x != 3:
        step(g, 'left' if x > 3 else 'right', log, abs(x - 3))
    step(g, 'up', log, pos(g)[1] - 6)           # (3,6)
    talk(g, 'left', log)                        # (2,6) Mystic Dew
    step(g, 'right', log)                       # (4,6)
    talk(g, 'right', log)                       # (5,6) King's Rock
    step(g, 'up', log, 2)                       # (4,4)
    talk(g, 'right', log)                       # (5,4) Gold Leaf
    step(g, 'left', log)                        # (3,4)
    talk(g, 'left', log)                        # (2,4) Fresh Water
    got = {i: item_qty(g, i) for i in ('MYSTIC_DEW', 'SACRED_ASH', 'AMULET_COIN', 'BRIGHTPOWDER')}
    flags = {n: event(g, 'EVENT_PICKED_UP_%s_FROM_SUICUNE_ITEM_ROOM' % n)
             for n in ('MYSTIC_DEW', 'SACRED_ASH', 'AMULET_COIN', 'BRIGHTPOWDER')}
    shot(g, '09_items_taken')
    check(all(flags.values()), 'not every ball picked up', **flags)
    check(got['MYSTIC_DEW'] >= 1 and got['SACRED_ASH'] >= 1 and got['AMULET_COIN'] >= 1 and got['BRIGHTPOWDER'] >= 1,
          'wrong item counts', **got)

    # --- up through the pit into the word room ---
    step(g, 'up', log, 2)                       # (3,2), then the pit at (3,1)
    for _ in range(3):
        if here(g) == map_id('RUINS_OF_ALPH_SUICUNE_WORD_ROOM'):
            break
        step(g, 'up', log)
    check(here(g) == map_id('RUINS_OF_ALPH_SUICUNE_WORD_ROOM'), 'pit did not lead to the word room', at=here(g), pos=pos(g))
    word_arrive = pos(g)
    shot(g, '10_word_room_arrive')

    # --- walk down past the text to the exit pit at (17,21) ---
    x, y = word_arrive
    step(g, 'down', log, 3)
    shot(g, '11_word_room_text_top')
    step(g, 'down', log, 6)
    shot(g, '12_word_room_text_bottom')
    x, y = pos(g)
    step(g, 'right', log, 17 - x)
    step(g, 'down', log, 20 - pos(g)[1])
    shot(g, '13_word_room_exit')
    step(g, 'down', log)
    check(here(g) == map_id('RUINS_OF_ALPH_INNER_CHAMBER'), 'exit pit did not lead to the Inner Chamber', at=here(g), pos=pos(g))
    check(pos(g) == (2, 22), 'landed in the wrong spot', at=pos(g))
    shot(g, '14_inner_chamber')

    # --- back outside: MAX stays gone, the chamber floor stays open ---
    warp(g, 'RUINS_OF_ALPH_OUTSIDE', 2, 11)
    shot(g, '15_outside_after')
    warp(g, 'RUINS_OF_ALPH_SUICUNE_CHAMBER', 3, 5)
    shot(g, '16_chamber_after')
    return {'chamber_arrive': arrive, 'item_room_arrive': item_pos, 'word_room_arrive': word_arrive,
            'battles': log, 'items': got}


# ======================================================================================
# Shrine fight after a real solve (d99103e96 adds the all-26-Unown Eviolite)
# ======================================================================================
def _fill_bag(g, keep_free=0):
    """Fill the item pocket with distinct junk rows (no Eviolite)."""
    ev = value('EVIOLITE')
    rows, idx = [], 1
    while len(rows) < value('MAX_ITEMS') - keep_free:
        if idx != ev:
            rows.append([idx >> 8, idx & 0xff, 1])
        idx += 1
    g.write('wNumItems', len(rows))
    g.write('wItems', [b for r in rows for b in r] + [0xff])


def _shrine(g, unown, bag_full, tag):
    from overworld import has_key_item
    log = []
    g.write('wUnownDex', list(range(1, unown + 1)) + [0] * (26 - unown))
    if bag_full:
        _fill_bag(g)
    else:
        from overworld import set_item
        set_item(g, 'EVIOLITE', 0)
    warp(g, 'RUINS_OF_ALPH_OUTSIDE', 6, 26)
    check(block_at(g, 3, 12) != 0xad, 'shrine still unactivated after the solve', blk=hex(block_at(g, 3, 12)))
    shot(g, tag + '_1_before')
    g.press('right', hold=16, after=4)
    check(resolve_events(g, log, limit=1500), 'shrine scene never ended', log=log)
    shot(g, tag + '_2_after')
    r = {
        'battles': log,
        'defeated': event(g, 'EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS'),
        'execf2': event(g, 'EVENT_BEAT_ROCKET_EXECUTIVEF_2'),
        'clear_bell': has_key_item(g, 'CLEAR_BELL'),
        'scene': g.read('wRuinsOfAlphOutsideSceneID'),
        'eviolite_in_bag': item_qty(g, 'EVIOLITE'),
        'eviolite_ball_hidden': event(g, 'EVENT_RUINS_OF_ALPH_OUTSIDE_EVIOLITE'),
        'execs_hidden': event(g, 'EVENT_RUINS_OF_ALPH_OUTSIDE_EXECUTIVES'),
        'mahogany_open': event(g, 'EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_EAST'),
        'pos': pos(g),
    }
    check(len(log) == 1 and log[0][1] == value('EXECUTIVEF'), 'expected one battle with EXECUTIVEF', **r)
    check(r['defeated'] and r['execf2'] and r['clear_bell'] and r['scene'] == 1
          and r['mahogany_open'], 'shrine aftermath flags wrong', **r)
    return r


@test('v10_suicune')
def suicune_shrine_after_solve(g):
    first = suicune_chamber_to_word_room(g)
    check(event(g, 'EVENT_SOLVED_SUICUNE_PUZZLE'), 'solve flag lost')
    base = g.state()
    out = {}

    g.load(base)
    r = _shrine(g, 25, False, '20_shrine_25unown')
    check(r['eviolite_in_bag'] == 0 and r['eviolite_ball_hidden'], '25 Unown should get no Eviolite', **r)
    # the chamber trainers leave with the executives
    warp(g, 'RUINS_OF_ALPH_SUICUNE_CHAMBER', 3, 5)
    shot(g, '20_shrine_25unown_3_chamber_empty')
    from overworld import object_hidden
    check(object_hidden(g, 'EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS'), 'chamber trainers still flagged present')
    out['25_unown'] = r

    g.load(base)
    r = _shrine(g, 26, False, '21_shrine_26unown')
    check(r['eviolite_in_bag'] == 1 and r['eviolite_ball_hidden'], '26 Unown should put Eviolite in the bag', **r)
    out['26_unown'] = r

    g.load(base)
    r = _shrine(g, 26, True, '22_shrine_26unown_bagfull')
    check(r['eviolite_in_bag'] == 0 and not r['eviolite_ball_hidden'], 'full bag should leave the Eviolite ball', **r)
    # free a slot and pick up the ball at (4,26) from (5,26)
    rows = g.read('wNumItems')
    g.write('wNumItems', rows - 1)
    g.write('wItems+%d' % (3 * (rows - 1)), 0xff)
    warp(g, 'RUINS_OF_ALPH_OUTSIDE', 5, 26)
    shot(g, '22_shrine_26unown_bagfull_3_ball')
    talk(g, 'left', [])
    r['picked_up'] = item_qty(g, 'EVIOLITE')
    r['ball_hidden_after'] = event(g, 'EVENT_RUINS_OF_ALPH_OUTSIDE_EVIOLITE')
    check(r['picked_up'] == 1 and r['ball_hidden_after'], 'could not pick up the Eviolite ball', **r)
    out['26_unown_bag_full'] = r
    return out

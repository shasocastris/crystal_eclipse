"""v1.0 pass, EVIOLITE (branch 95): the battle boost (EvioliteBoost) and the evolution block (evolve.asm).

    runner.py v10_eviolite --jobs 1 [-k name]

Battle cases rewrite species/items/stats in place inside one wild battle, so every case replays the
same RNG; the boosted defense is read from bc at TruncateHL_BC (the call right after EvioliteBoost).
"""
import os

from battle import Battle, set_party_mon
from consts import value
from game import mon_read, mon_write, species_id, species_index
from gb import HERE, _lib
from overworld import finish, item_qty, set_item, wait_for, warp
from registry import check, test

S = 'v10_eviolite'
OUT = os.path.join(HERE, '..', 'v10', 'eviolite')
PROCEED = 'EvolveAfterBattle_MasterLoop.proceed'
DONE = 'EvolveAfterBattle_MasterLoop.ReturnToMap'
DEF = 101  # odd, so the +50% rounding shows: 101 -> 151


def _shot(g, name):
    os.makedirs(OUT, exist_ok=True)
    g.render(True)
    g.frames(2)
    g.screenshot(os.path.join(OUT, name + '.png'))


def _item_id(g, name):
    return g.call('GetItemIDFromIndex', hl=value(name))['a'] if name else 0


def _w16(g, label, v):
    g.write(label, [v >> 8, v & 0xff])


def _start_call(g, label):
    bank, target = g.addr(label)
    sp = g.reg('sp') - 2
    ret = g.reg('pc')
    g.write('hFarCallSavedA', 0)
    g.write('hFarCallSavedL', 0)
    g.write('hFarCallSavedH', 0)
    g.set_reg('af', bank << 8)
    g.set_reg('hl', target)
    g.write(sp, ret & 0xff)
    g.write(sp + 1, ret >> 8)
    g.set_reg('sp', sp)
    g.set_reg('pc', g.syms['FarCall_hl'][1])


# --- battle ----------------------------------------------------------------------------------
def _battle(g):
    """L50 vs L50 wild battle, both using Scratch, 999 HP each, equal flat stats."""
    set_item(g, 'EVIOLITE', 1)  # keep the item ID referenced
    b = Battle(g, enemy='SENTRET', enemy_level=50, lead='SENTRET', lead_level=50, moves=['SCRATCH'],
               enemy_moves=['SCRATCH'], enemy_hp=999, enemy_speed=1)
    _w16(g, 'wBattleMonHP', 999)
    _w16(g, 'wBattleMonMaxHP', 999)
    return b


def _setup(g, enemy, enemy_item, player, player_item, defense=DEF, player_defense=DEF):
    """Species, held items and stats for one case; the crit copies get the same values."""
    eid, pid = species_id(g, enemy), species_id(g, player)
    g.write('wTempEnemyMonSpecies', eid)
    g.write('wEnemyMonSpecies', eid)
    g.write('wPartySpecies', pid)
    mon_write(g, 0, 'MON_SPECIES', pid)
    g.write('wBattleMonSpecies', pid)
    g.write('wEnemyMonItem', _item_id(g, enemy_item))
    g.write('wBattleMonItem', _item_id(g, player_item))
    for lab in ('wBattleMonAttack', 'wPlayerAttack', 'wEnemyMonAttack', 'wEnemyAttack'):
        _w16(g, lab, 100)
    for lab in ('wEnemyMonDefense', 'wEnemyDefense'):
        _w16(g, lab, defense)
    for lab in ('wBattleMonDefense', 'wPlayerDefense'):
        _w16(g, lab, player_defense)


def _turn(g, b, seed=(0x5a, 0xa5)):
    """One turn; {'enemy'|'player': (defense bc at TruncateHL_BC, damage taken)} per defender."""
    b.choose_move(0)
    g.write('hRandomAdd', seed[0])
    g.write('hRandomSub', seed[1])
    hp0 = {'enemy': b.hp('enemy'), 'player': b.hp('player')}
    labels = ['TruncateHL_BC', 'LoadBattleMenu']
    defs, spent = {}, 0
    while spent < 3000:
        hit = g.run_until_any(labels, 20)
        if not hit:
            g.hold('a', True)
            hit = g.run_until_any(labels, 3)
            g.hold('a', False)
            spent += 23
            if not hit:
                continue
        if hit == 'LoadBattleMenu':
            break
        side = 'enemy' if g.read('hBattleTurn') == 0 else 'player'
        defs.setdefault(side, g.reg('bc'))
        _lib.sb_step(g.h)
    else:
        check(False, 'turn never returned to the menu')
    return {s: (defs.get(s), hp0[s] - b.hp(s)) for s in ('enemy', 'player')}


# (enemy, enemy item, player, player item, expected enemy defense, expected player defense)
BOOST = DEF + DEF // 2
CASES = [
    ('SENTRET', None, 'SENTRET', None, DEF, DEF),
    ('SENTRET', 'EVIOLITE', 'FURRET', None, BOOST, DEF),
    ('FURRET', 'EVIOLITE', 'SENTRET', None, DEF, DEF),     # fully evolved; attacker can evolve
    ('SENTRET', 'NUGGET', 'SENTRET', 'NUGGET', DEF, DEF),
    ('FURRET', None, 'SENTRET', 'EVIOLITE', DEF, BOOST),
    ('SENTRET', None, 'FURRET', 'EVIOLITE', DEF, DEF),     # fully evolved; attacker can evolve
    ('SENTRET', 'EVIOLITE', 'SENTRET', 'EVIOLITE', BOOST, BOOST),
    ('CHANSEY', 'EVIOLITE', 'PICHU', 'EVIOLITE', BOOST, BOOST),   # happiness evolutions
    ('ONIX', 'EVIOLITE', 'EEVEE', 'EVIOLITE', BOOST, BOOST),      # item / location evolutions
    ('CELEBI', 'EVIOLITE', 'BLISSEY', 'EVIOLITE', DEF, DEF),
]


@test(S)
def eviolite_battle_defense(g):
    """+50% defense only for a holder that can still evolve, on the right side, both sides."""
    b = _battle(g)
    base = g.state()
    out, bad = {}, []
    for e, ei, p, pi, we, wp in CASES:
        g.load(base)
        _setup(g, e, ei, p, pi)
        r = _turn(g, b)
        key = '%s@%s vs %s@%s' % (e, ei, p, pi)
        out[key] = {'enemy_def': r['enemy'][0], 'enemy_dmg': r['enemy'][1],
                    'player_def': r['player'][0], 'player_dmg': r['player'][1]}
        if (r['enemy'][0], r['player'][0]) != (we, wp):
            bad.append(dict(case=key, want=(we, wp), got=(r['enemy'][0], r['player'][0])))
    check(not bad, 'wrong defense after EvioliteBoost', bad=bad)
    # same RNG for every case: the boosted hit must do less damage than the plain one
    plain, boosted = out['SENTRET@None vs SENTRET@None'], out['SENTRET@EVIOLITE vs SENTRET@EVIOLITE']
    check(boosted['enemy_dmg'] < plain['enemy_dmg'] and boosted['player_dmg'] < plain['player_dmg'],
          'boost did not reduce damage', plain=plain, boosted=boosted)
    return out


@test(S)
def eviolite_saturation(g):
    """A boosted defense that passes $ffff is held at $ffff; the turn still completes."""
    b = _battle(g)
    base = g.state()
    cases = [(0xaaa9, 0xfffd), (0xaaaa, 0xffff), (0xaaab, 0xffff), (0xc000, 0xffff), (0xffff, 0xffff)]
    out, bad = {}, []
    for d, want in cases:
        g.load(base)
        _setup(g, 'SENTRET', 'EVIOLITE', 'SENTRET', 'EVIOLITE', defense=d, player_defense=d)
        r = _turn(g, b)
        out[hex(d)] = {'enemy_def': hex(r['enemy'][0] or 0), 'player_def': hex(r['player'][0] or 0),
                       'enemy_dmg': r['enemy'][1], 'player_dmg': r['player'][1]}
        if r['enemy'][0] != want or r['player'][0] != want:
            bad.append(dict(defense=hex(d), want=hex(want), got=out[hex(d)]))
    check(not bad, 'saturation wrong', bad=bad)
    return out


# --- holding it at all -------------------------------------------------------------------------
@test(S)
def eviolite_can_be_given(g):
    """EVIOLITE stays CANT_TOSS (never tossed/sold); giving it is covered by v10_eviolite_give."""
    out = {}
    for item in ('EVIOLITE', 'LEFTOVERS'):
        g.write('wCurItem', _item_id(g, item))
        g.call('CheckTossableItem')
        out[item] = g.read('wItemAttributeValue')
    check(out == {'EVIOLITE': 1, 'LEFTOVERS': 0}, 'tossable flags changed', out=out)
    return out


# --- evolution -----------------------------------------------------------------------------------
def _hold(g, slot, item):
    mon_write(g, slot, 'MON_ITEM', _item_id(g, item))


def _evo_target(g, slot=0, force_item=None):
    g.write('wCurPartyMon', slot)
    g.write('wForceEvolution', 1 if force_item else 0)
    if force_item:
        g.write('wCurItem', _item_id(g, force_item))
    _start_call(g, 'EvolvePokemon')
    hit = g.run_until_any([PROCEED, DONE], 300)
    check(hit, 'EvolvePokemon never decided')
    return hit == PROCEED


@test(S)
def eviolite_blocks_evolve_decision(g):
    """EvolvePokemon's decision: level, happiness and item evolutions all stop for a holder only."""
    set_item(g, 'EVIOLITE', 1)
    base = g.state()
    cases = [('SENTRET', 20, 0, None), ('EEVEE', 20, 255, None), ('PICHU', 5, 255, None),
             ('ONIX', 30, 0, 'METAL_COAT'), ('EEVEE', 20, 0, 'THUNDERSTONE')]
    out, bad = {}, []
    for sp, lvl, hap, force in cases:
        for held in (None, 'NUGGET', 'EVIOLITE'):
            g.load(base)
            set_party_mon(g, 0, species=sp, level=lvl, happiness=hap)
            _hold(g, 0, held)
            got = _evo_target(g, force_item=force)
            key = '%s%s@%s' % (sp, '+' + force if force else '', held)
            out[key] = got
            if got != (held != 'EVIOLITE'):
                bad.append(key)
    check(not bad, 'evolution decision wrong', bad=bad, out=out)
    return out


@test(S)
def eviolite_blocks_levelup_battle(g):
    """A real battle level-up 14 -> 15: Sentret evolves, unless it holds EVIOLITE."""
    warp(g, 'ROUTE_34', 11, 14)
    set_item(g, 'EVIOLITE', 1)
    base = g.state()
    out, bad = {}, []
    for held, want in ((None, 'FURRET'), ('EVIOLITE', 'SENTRET')):
        g.load(base)

        def setup(g, held=held):
            mon_write(g, 0, 'MON_EXP', [0, 15 ** 3 - 1 >> 8, 15 ** 3 - 1 & 0xff])
            _hold(g, 0, held)
        b = Battle(g, enemy='RATTATA', enemy_level=5, lead='SENTRET', lead_level=14, moves=('SCRATCH',),
                   enemy_hp=1, setup=setup)
        check(b.turn(0, stop='CleanUpBattleRAM', max_frames=8000), 'battle never ended', held=held)
        ok = finish(g, 'a', 600)
        r = dict(species=species_index(g, 0), level=mon_read(g, 0, 'MON_LEVEL')[0], control=ok,
                 item=mon_read(g, 0, 'MON_ITEM')[0])
        out[str(held)] = dict(r, species=want if r['species'] == value(want) else hex(r['species']))
        if r['species'] != value(want) or r['level'] != 15 or not ok or r['item'] != _item_id(g, held):
            bad.append(dict(held=held, want=want, **out[str(held)]))
            _shot(g, 'levelup_%s' % held)
    check(not bad, 'battle level-up wrong', bad=bad)
    return out


def _to_slot0(g):
    g.frames(20)
    for _ in range(8):
        if g.read('wMenuCursorY') == 1:
            break
        g.press('up', hold=4, after=8)
    check(g.read('wMenuCursorY') == 1, 'party cursor stuck')


def _use_on_lead(g, item):
    """DoItemEffect(item) on party slot 0; returns the first of the outcome labels reached."""
    g.write('wCurItem', _item_id(g, item))
    _start_call(g, 'DoItemEffect')
    check(wait_for(g, 'PartyMenuSelect', key='b', max_presses=60), 'party menu never opened', item=item)
    _to_slot0(g)
    tm = g.read('wTilemap', 20 * 18)
    g.hold('a', True)
    hit = g.run_until_any(['WontHaveAnyEffectMessage', PROCEED, 'UseDisposableItem'], 300)
    g.hold('a', False)
    return hit, tm


def _decode(row):
    s = ''
    for c in row:
        s += chr(c - 0x80 + 65) if 0x80 <= c <= 0x99 else ' '
    return ' '.join(s.split())


@test(S)
def eviolite_blocks_item_use(g):
    """Using an evolution item from the pack on a holder: no evolution, 'won't have any effect',
    item kept. Covers a stone and a former trade item (Metal Coat). Also records what the party menu
    shows (ABLE / NOT ABLE)."""
    warp(g, 'ROUTE_34', 11, 14)
    set_item(g, 'EVIOLITE', 1)
    base = g.state()
    out, bad = {}, []
    for sp, item, evo in (('EEVEE', 'THUNDERSTONE', 'JOLTEON'), ('ONIX', 'METAL_COAT', 'STEELIX')):
        for held in (None, 'EVIOLITE'):
            g.load(base)
            set_party_mon(g, 0, species=sp, level=30, happiness=0, moves=('SCRATCH',))
            _hold(g, 0, held)
            set_item(g, item, 3)
            hit, tm = _use_on_lead(g, item)
            menu = _decode(tm[20 * 1:20 * 3])
            if hit == 'WontHaveAnyEffectMessage':
                g.frames(30)
                _shot(g, 'use_%s_%s_%s' % (sp, item, held))
            ok = finish(g, 'a', 600)
            got = species_index(g, 0)
            key = '%s+%s@%s' % (sp, item, held)
            out[key] = dict(first=hit, species=evo if got == value(evo) else sp if got == value(sp) else hex(got),
                            qty=item_qty(g, item), control=ok, party_menu=menu)
            want = dict(first=PROCEED, species=evo, qty=2) if not held else \
                dict(first='WontHaveAnyEffectMessage', species=sp, qty=3)
            if any(out[key][k] != v for k, v in want.items()) or not ok:
                bad.append(dict(case=key, want=want, got=out[key]))
    check(not bad, 'item use on an EVIOLITE holder wrong', bad=bad)
    return out


@test(S)
def eviolite_rare_candy(g):
    """Rare Candy on a holder at 14: it levels to 15 (candy used) but stays a Sentret."""
    warp(g, 'ROUTE_34', 11, 14)
    set_item(g, 'EVIOLITE', 1)
    set_party_mon(g, 0, species='SENTRET', level=14, moves=('SCRATCH',))
    _hold(g, 0, 'EVIOLITE')
    set_item(g, 'RARE_CANDY', 5)
    g.write('wCurItem', _item_id(g, 'RARE_CANDY'))
    _start_call(g, 'DoItemEffect')
    check(wait_for(g, 'PartyMenuSelect', key='b', max_presses=60), 'party menu never opened')
    _to_slot0(g)
    g.press('a', hold=4, after=20)
    ok = finish(g, 'a', 600)
    out = dict(species=hex(species_index(g, 0)), level=mon_read(g, 0, 'MON_LEVEL')[0],
               candy=item_qty(g, 'RARE_CANDY'), control=ok)
    check(ok and species_index(g, 0) == value('SENTRET') and out['level'] == 15 and out['candy'] == 4,
          'Rare Candy on a holder wrong', **out)
    return out

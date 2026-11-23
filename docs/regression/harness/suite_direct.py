"""Direct routine calls from the debug-party fixture (overworld, paused at PlayerEvents)."""
import itertools
import random

from consts import resolve, value
from game import mon, mon_read, mon_write, mon_word, set_event, species_id
from registry import check, test


@test('direct')
def beasts_check_needs_all_three(g):
    """BeastsCheck (Rainbow Wing gate) is TRUE only when Suicune, Raikou and Entei have all taught."""
    names = ['EVENT_FOUGHT_SUICUNE', 'EVENT_FOUGHT_RAIKOU', 'EVENT_FOUGHT_ENTEI']
    seen = {}
    for combo in itertools.product([0, 1], repeat=3):
        for n, on in zip(names, combo):
            set_event(g, n, on)
        g.write('wScriptVar', 0x5a)
        g.call('BeastsCheck')
        got = g.read('wScriptVar')
        seen[''.join(map(str, combo))] = got
        check(got == (1 if all(combo) else 0), 'BeastsCheck wrong', flags=combo, wScriptVar=got)
    return seen


def _gender(g, slot):
    g.write('wCurPartyMon', slot)
    g.write('wCurPartySpecies', g.read('wPartySpecies+%d' % slot))
    g.write('wMonType', 0)
    r = g.call('GetGender')
    return None if r['carry'] else r['a']


def _shiny(g, slot):
    _, addr = g.addr(mon(g, slot, 'MON_DVS'))
    return g.call('CheckShininess', bc=addr)['carry']


def _expected_dvs(g, slot, orig, shiny):
    """Independent oracle: try the coach's three candidates against the game's own GetGender."""
    spd_spc = 0xff if shiny else 0xbf
    g0 = _gender(g, slot)
    cands = [(0xff, spd_spc), (0xff, spd_spc - 1), (0xfe, spd_spc)]
    pick = cands[0]
    if g0 is not None:
        for c in cands:
            mon_write(g, slot, 'MON_DVS', list(c))
            if _gender(g, slot) == g0:
                pick = c
                break
    mon_write(g, slot, 'MON_DVS', list(orig))
    return pick


# species chosen to cover every gender ratio: genderless, F0, F12.5, F25, F50, F75, F100
COACH_SPECIES = ['MAGNEMITE', 'TAUROS', 'CYNDAQUIL', 'GROWLITHE', 'PIKACHU', 'CLEFAIRY', 'CHANSEY']


@test('direct')
def coach_keeps_gender_and_shininess(g):
    """PerfectMonApply across species x DVs: EVs 252, gender and shininess kept, DVs as specified."""
    rng = random.Random(30)
    slot = 3
    stats = {'cases': 0, 'shiny_cases': 0}
    for sp in COACH_SPECIES:
        sid = species_id(g, sp)
        g.write('wPartySpecies+%d' % slot, sid)
        mon_write(g, slot, 'MON_SPECIES', sid)
        dv_cases = [(rng.randrange(256), rng.randrange(256)) for _ in range(12)]
        dv_cases += [(0xcc, 0xcc), (0xff, 0xff), (0x00, 0x00), (0xfe, 0xef)]
        for d0, d1 in dv_cases:
            mon_write(g, slot, 'MON_DVS', [d0, d1])
            mon_write(g, slot, 'MON_EVS', [0] * 6)
            g0, s0 = _gender(g, slot), _shiny(g, slot)
            want = _expected_dvs(g, slot, (d0, d1), s0)
            g.write('wCurPartyMon', slot)
            g.call('PerfectMonApply')
            got = tuple(mon_read(g, slot, 'MON_DVS', 2))
            ctx = dict(species=sp, dvs='%02X%02X' % (d0, d1), got='%02X%02X' % got)
            check(mon_read(g, slot, 'MON_EVS', 6) == [252] * 6, 'EVs not maxed', **ctx)
            check(_gender(g, slot) == g0, 'gender changed', before=g0, **ctx)
            check(_shiny(g, slot) == s0, 'shininess changed', before=s0, **ctx)
            check(got == want, 'unexpected DVs', want='%02X%02X' % want, **ctx)
            stats['cases'] += 1
            stats['shiny_cases'] += s0
    return stats


@test('direct')
def coach_hp_rules(g):
    """A healthy mon keeps the HP it had lost (min 1); a fainted mon stays fainted."""
    slot = 3
    out = {}
    for label, hp_lost, fainted in [('healthy', 0, False), ('hurt10', 10, False), ('fainted', None, True)]:
        mon_write(g, slot, 'MON_DVS', [0x11, 0x11])
        mon_write(g, slot, 'MON_EVS', [0] * 6)
        g.write('wCurPartyMon', slot)
        g.write('wCurPartySpecies', g.read('wPartySpecies+%d' % slot))
        g.call('RareCandy_StatBooster_GetParameters')
        g.call('UpdateStatsAfterItem')
        old_max = mon_word(g, slot, 'MON_MAXHP')
        hp = 0 if fainted else old_max - hp_lost
        mon_write(g, slot, 'MON_HP', [hp >> 8, hp & 0xff])
        g.call('PerfectMonApply')
        new_max, new_hp = mon_word(g, slot, 'MON_MAXHP'), mon_word(g, slot, 'MON_HP')
        out[label] = dict(old_max=old_max, new_max=new_max, hp=new_hp)
        check(new_max > old_max, 'max HP did not rise', case=label, **out[label])
        if fainted:
            check(new_hp == 0, 'fainted mon was revived', **out[label])
        else:
            check(new_hp == new_max - hp_lost, 'lost HP not kept', case=label, **out[label])
    return out


@test('direct')
def battle_tower_unique_checks(g):
    """CheckBTRule_Party{Species,Items}AreUnique over 3 mons: equal values fail; values that differ
    only in bit 0 pass (an `or 1` stub once made them compare equal); empty items are ignored."""
    g.write('wPartyCount', 3)
    out = {}
    for rule, field in (('CheckBTRule_PartySpeciesAreUnique', 'MON_SPECIES'), ('CheckBTRule_PartyItemsAreUnique', 'MON_ITEM')):
        cases = [((1, 2, 3), False), ((2, 3, 4), False), ((4, 5, 6), False), ((1, 2, 1), True), ((5, 5, 7), True),
                 ((2, 4, 4), True)]
        if field == 'MON_ITEM':
            cases += [((0, 0, 3), False), ((0, 2, 3), False)]
        for vals, dup in cases:
            for slot, v in enumerate(vals):
                mon_write(g, slot, field, v)
            got = g.call(rule)['carry']
            out['%s %s' % (field, vals)] = got
            check(got == dup, 'unique check wrong', rule=rule, values=vals, carry=got)
    return out


def _write_sram(g, label, v):
    """Write one SRAM byte through the MBC, the way the game does (enable, bank, write, disable)."""
    b, a = g.addr(label)
    g.write(0x0000, 0x0a)
    g.write(0x4000, b)
    g.write(a, v)
    g.write(0x0000, 0x00)


@test('direct')
def battle_tower_reward_is_a_stat_item(g):
    """The reward is stored as an offset from HP_UP: choosing then giving always yields HP Up, Protein,
    Iron or Carbos (all four seen); an out-of-range byte from an older save still gives one of them."""
    rng = random.Random(75)
    stats = [value(n) for n in ('HP_UP', 'PROTEIN', 'IRON', 'CARBOS')]
    seen = {}
    for _ in range(40):
        g.write('hRandomAdd', rng.randrange(256))
        g.write('hRandomSub', rng.randrange(256))
        g.call('BattleTower_RandomlyChooseReward')
        g.call('BattleTower_GiveReward')
        idx = g.call('GetItemIndexFromID', a=g.read('wScriptVar'))['hl']
        check(idx in stats, 'reward is not a stat item', index=idx)
        seen[idx] = seen.get(idx, 0) + 1
    check(len(seen) == 4, 'not every stat item came up', seen=seen)
    old = {}
    for byte in (4, 44, 0xff):
        _write_sram(g, 'sBattleTowerReward', byte)
        g.call('BattleTower_GiveReward')
        old[byte] = g.call('GetItemIndexFromID', a=g.read('wScriptVar'))['hl']
        check(old[byte] in stats, 'old reward byte gave a non-stat item', byte=byte, index=old[byte])
    return dict(seen={hex(k): v for k, v in seen.items()}, old_bytes={k: hex(v) for k, v in old.items()})

"""EVOLVE_LOCATION gate: Leafeon in Ilex Forest, Glaceon on Ice Path B3F (branch 83)."""
from battle import set_party_mon
from consts import resolve, value
from game import mon_word, rom_byte, species_index
from overworld import finish, party_moves, warp
from registry import check, test

SLOT = 0
PROCEED = 'EvolveAfterBattle_MasterLoop.proceed'
DONE = 'EvolveAfterBattle_MasterLoop.ReturnToMap'


def _map(g, name):
    v = resolve('GROUP_' + name, 'MAP_' + name)
    g.write('wMapGroup', v['GROUP_' + name])
    g.write('wMapNumber', v['MAP_' + name])


def _item_id(g, name):
    return g.call('GetItemIDFromIndex', hl=value(name))['a']


def _start_call(g, label):
    """g.call's setup without running: leaves the callee ready to execute."""
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


def _evo_target(g, force_item=None):
    """Run EvolvePokemon for SLOT up to its decision; species index it picked, or None."""
    g.write('wCurPartyMon', SLOT)
    g.write('wForceEvolution', 1 if force_item else 0)
    if force_item:
        g.write('wCurItem', _item_id(g, force_item))
    _start_call(g, 'EvolvePokemon')
    hit = g.run_until_any([PROCEED, DONE], 300)
    check(hit, 'EvolvePokemon never decided')
    if hit == DONE:
        return None
    bank = g.read('hTemp')
    lo, hi = rom_byte(g, (bank, g.reg('hl')), 0, 2)
    return lo | hi << 8


def _name(idx):
    return idx if idx is None else next((n for n in ('LEAFEON', 'GLACEON', 'ESPEON', 'UMBREON', 'JOLTEON',
                                                       'VAPOREON', 'FLAREON', 'SYLVEON')
                                         if value(n) == idx), hex(idx))


@test('evolve_location')
def level_up_by_location(g):
    """Any level-up on the exact map evolves; neighbouring maps and other floors do not."""
    set_party_mon(g, SLOT, species='EEVEE', level=20, happiness=0)
    base = g.state()
    cases = [
        ('ILEX_FOREST', 'LEAFEON'), ('ICE_PATH_B3F', 'GLACEON'),
        ('ICE_PATH_B2F_MAHOGANY_SIDE', None), ('ICE_PATH_B2F_BLACKTHORN_SIDE', None),
        ('ICE_PATH_B1F', None), ('ICE_PATH_1F', None), ('ILEX_FOREST_AZALEA_GATE', None),
        ('ROUTE_34_ILEX_FOREST_GATE', None), ('ROUTE_34', None),
    ]
    seen = {}
    for m, want in cases:
        g.load(base)
        _map(g, m)
        got = _name(_evo_target(g))
        seen[m] = got
        check(got == want, 'wrong evolution', map=m, want=want, got=got)
    return seen


@test('evolve_location')
def location_beats_happiness(g):
    """A happy Eevee becomes Leafeon/Glaceon on the gated maps, Espeon/Umbreon elsewhere."""
    set_party_mon(g, SLOT, species='EEVEE', level=20, happiness=255)
    base = g.state()
    seen = {}
    for tod, elsewhere in (('DAY_F', 'ESPEON'), ('NITE_F', 'UMBREON')):
        for m, want in (('ILEX_FOREST', 'LEAFEON'), ('ICE_PATH_B3F', 'GLACEON'), ('ROUTE_34', elsewhere)):
            g.load(base)
            _map(g, m)
            g.write('wTimeOfDay', value(tod))
            got = _name(_evo_target(g))
            seen['%s/%s' % (m, tod)] = got
            check(got == want, 'wrong evolution', map=m, time=tod, want=want, got=got)
    return seen


@test('evolve_location')
def stones_on_gated_maps(g):
    """Stone use skips the gated level entries; Leaf/Mist Stone no longer evolve Eevee."""
    set_party_mon(g, SLOT, species='EEVEE', level=20, happiness=0)
    base = g.state()
    want = {'THUNDERSTONE': 'JOLTEON', 'WATER_STONE': 'VAPOREON', 'FIRE_STONE': 'FLAREON',
            'SUN_STONE': 'SYLVEON', 'LEAF_STONE': None, 'MIST_STONE': None}
    seen = {}
    for m in ('ILEX_FOREST', 'ICE_PATH_B3F', 'ROUTE_34'):
        for item, w in want.items():
            g.load(base)
            _map(g, m)
            got = _name(_evo_target(g, force_item=item))
            seen['%s/%s' % (m, item)] = got
            check(got == w, 'wrong stone result', map=m, item=item, want=w, got=got)
    return seen


@test('evolve_location')
def item_results_and_registers(g):
    """DetermineEvolutionItemResults (party menu ABLE/NOT ABLE, Moon Ball) keeps c and walks the gates."""
    bank, eevee = g.addr('EeveeEvosAttacks')
    want = {'THUNDERSTONE': 'JOLTEON', 'SUN_STONE': 'SYLVEON', 'LEAF_STONE': None, 'MIST_STONE': None,
            'MOON_STONE': None}
    seen = {}
    for m in ('ILEX_FOREST', 'ICE_PATH_B3F', 'ROUTE_34'):
        _map(g, m)
        for item, w in want.items():
            g.write('wCurItem', _item_id(g, item))
            r = g.call('DetermineEvolutionItemResults', bc=bank << 8 | 0x5a, de=eevee)
            got = _name(r['de'] or None)
            seen['%s/%s' % (m, item)] = got
            check(got == w, 'wrong item result', map=m, item=item, want=w, got=got)
            check(r['bc'] & 0xff == 0x5a, 'c clobbered', map=m, item=item, bc=hex(r['bc']))
    # region gate still works next to the new code
    bank, pika = g.addr('PikachuEvosAttacks')
    g.write('wCurItem', _item_id(g, 'THUNDERSTONE'))
    for region, w in (('ORANGE_REGION', 'RAICHU_ORANGE'), ('JOHTO_REGION', 'RAICHU')):
        g.write('wCurRegion', value(region))
        r = g.call('DetermineEvolutionItemResults', bc=bank << 8, de=pika)
        check(r['de'] == value(w), 'Pikachu region gate broke', region=region, got=hex(r['de']))
    return seen


def _learnset_start(g, label):
    """Independent parse of the evo block: address of the first learnset byte."""
    bank, a = g.addr(label)
    width = {value('EVOLVE_LEVEL'): 4, value('EVOLVE_HAPPINESS'): 4, value('EVOLVE_ITEM'): 5,
             value('EVOLVE_STAT'): 5, value('EVOLVE_REGION'): 2, value('EVOLVE_LOCATION'): 3}
    while True:
        b = rom_byte(g, (bank, a))[0]
        if b == 0:
            return a + 1
        a += width[b]


@test('evolve_location')
def skip_evolutions_lands_on_learnset(g):
    """SkipEvolutions (level-up moves, givepoke, move reminder) skips gated blocks exactly."""
    out = {}
    for label, first_move in (('EeveeEvosAttacks', 'SCRATCH'), ('PikachuEvosAttacks', None),
                              ('DragonairEvosAttacks', 'WRAP'), ('LeafeonEvosAttacks', None)):
        bank, a = g.addr(label)
        r = g.call('SkipEvolutions', bc=bank << 8, hl=a)
        want = _learnset_start(g, label)
        out[label] = hex(r['hl'])
        check(r['hl'] == want, 'SkipEvolutions misaligned', label=label, got=hex(r['hl']), want=hex(want))
        if first_move:
            lvl, lo, hi = rom_byte(g, (bank, r['hl']), 0, 3)
            check((lvl, lo | hi << 8) == (1, value(first_move)), 'first learnset entry wrong', label=label)
    return out


def _evolve_scene(g, map_name, x, y, want, evo_move):
    set_party_mon(g, SLOT, species='EEVEE', level=20, happiness=0, moves=('SCRATCH', 'LEER'))
    warp(g, map_name, x, y)
    g.write('wCurPartyMon', SLOT)
    g.write('wForceEvolution', 0)
    _start_call(g, 'EvolvePokemon')
    check(finish(g, 'a', 600), 'never regained control after evolving')
    got = species_index(g, SLOT)
    check(got == value(want), 'wrong species after the scene', want=want, got=hex(got))
    moves = party_moves(g, SLOT)
    check(value(evo_move) in moves, 'evolution move not learned', want=evo_move, moves=moves)
    return {'species': want, 'moves': moves}


@test('evolve_location')
def ilex_end_to_end(g):
    """Warp into Ilex Forest: the scene leaves a Leafeon that learned Razor Leaf."""
    return _evolve_scene(g, 'ILEX_FOREST', 1, 6, 'LEAFEON', 'RAZOR_LEAF')


@test('evolve_location')
def ice_path_end_to_end(g):
    """Warp onto Ice Path B3F: the scene leaves a Glaceon that learned Icy Wind."""
    return _evolve_scene(g, 'ICE_PATH_B3F', 3, 6, 'GLACEON', 'ICY_WIND')


@test('evolve_location')
def sylveon_learns_evo_move(g):
    """Sun Stone Sylveon learns Disarming Voice, even on a location-gated map."""
    set_party_mon(g, SLOT, species='EEVEE', level=20, happiness=0, moves=('SCRATCH', 'LEER'))
    warp(g, 'ICE_PATH_B3F', 3, 6)
    g.write('wCurPartyMon', SLOT)
    g.write('wForceEvolution', 1)
    g.write('wCurItem', _item_id(g, 'SUN_STONE'))
    _start_call(g, 'EvolvePokemon')
    check(finish(g, 'a', 600), 'never regained control after evolving')
    got = species_index(g, SLOT)
    check(got == value('SYLVEON'), 'not a Sylveon', got=hex(got))
    moves = party_moves(g, SLOT)
    check(value('DISARM_VOICE') in moves, 'evolution move not learned', moves=moves)
    return {'moves': moves}


@test('evolve_location')
def b_cancel_keeps_eevee(g):
    """Holding B through the scene cancels and leaves an Eevee."""
    set_party_mon(g, SLOT, species='EEVEE', level=20, happiness=0)
    _map(g, 'ICE_PATH_B3F')
    g.write('wCurPartyMon', SLOT)
    g.write('wForceEvolution', 0)
    _start_call(g, 'EvolvePokemon')
    check(g.run_until(PROCEED, 300), 'no evolution started')
    g.hold('b', True)
    hit = g.run_until_any(['CancelEvolution', DONE], 3000)
    g.hold('b', False)
    check(hit == 'CancelEvolution', 'B did not cancel', hit=hit)
    got = species_index(g, SLOT) if finish(g, 'b', 600) else None
    check(got == value('EEVEE'), 'species changed after cancel', got=got)
    return {'hit': hit}

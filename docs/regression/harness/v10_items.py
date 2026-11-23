"""v1.0 pass, area `items`: evolution items, EVOLVE_LOCATION, evo moves, Kanto item balls, Mart cap,
auto-Repel kind and the Silver Cave coach's Star Piece.

    CE_REPO=<tree> runner.py v10_items --rom <tree's debug ROM> --jobs 1 [-k name]

Helpers are local copies (importing suite_* would register their tests too).
"""
import os
import re
import subprocess

from battle import Battle, set_party_mon
from consts import resolve, value
from game import engine, event, mon, mon_read, mon_write, rom_byte, set_engine, species_index
from gb import HERE, REPO
from overworld import answer, finish, interact, item_qty, party_moves, pick_party, set_item, settle, warp, \
    wait_for
from registry import Skip, check, test

S = 'v10_items'
OUT = os.path.join(HERE, '..', 'v10', 'items')
PROCEED = 'EvolveAfterBattle_MasterLoop.proceed'
DONE = 'EvolveAfterBattle_MasterLoop.ReturnToMap'


def _shot(g, name):
    os.makedirs(OUT, exist_ok=True)
    g.render(True)
    g.frames(2)
    g.screenshot(os.path.join(OUT, name + '.png'))


# --- constants straight from the tree under test -------------------------------------------------
_cc = {}


def _consts(path, pattern):
    """{name: value} for every name matched by `pattern` (group 1) in REPO/path, via rgbasm."""
    key = (path, pattern)
    if key in _cc:
        return _cc[key]
    names = list(dict.fromkeys(re.findall(pattern, open(os.path.join(REPO, path)).read(), re.M)))
    src = os.path.join(REPO, '_v10_items_consts.asm')
    with open(src, 'w') as f:
        f.write('INCLUDE "includes.asm"\n' + ''.join('PRINTLN "%s=", %s\n' % (n, n) for n in names))
    try:
        out = subprocess.run(['rgbasm', '-D', '_DEBUG', '-Q8', '-o', os.devnull, src],
                             cwd=REPO, capture_output=True, text=True).stdout
    finally:
        os.unlink(src)
    _cc[key] = {m[1]: int(m[2], 16) for m in re.finditer(r'^(\w+)=\$?([0-9A-Fa-f]+)$', out, re.M)}
    return _cc[key]


def _first_names(path):
    out = {}
    for k, v in _consts(path, r'^\s*const\s+(\w+)').items():
        out.setdefault(v, k)  # later const_defs (Unown letters...) reuse values
    return out


def _mon_names():
    return _first_names('constants/pokemon_constants.asm')


def _maps():
    """[(name, group, number)] for every map."""
    names = re.findall(r'^\s*map_const\s+(\w+),', open(os.path.join(REPO, 'constants/map_constants.asm')).read(),
                       re.M)
    v = resolve(*(['GROUP_' + n for n in names] + ['MAP_' + n for n in names]))
    return [(n, v['GROUP_' + n], v['MAP_' + n]) for n in names]


def _src(path):
    return open(os.path.join(REPO, path)).read()


# --- small game helpers ------------------------------------------------------------------------
def _item_id(g, name):
    return g.call('GetItemIDFromIndex', hl=value(name))['a']


def _count(g, name):
    """Bag count of an item in any pocket, via the game's own CountItemInBag."""
    g.write('wCurItem', _item_id(g, name))
    g.call('CountItemInBag')
    return g.read('wBuffer1')  # its `a` is clobbered by the bank restore despite the comment


def _set_map(g, name):
    v = resolve('GROUP_' + name, 'MAP_' + name)
    g.write('wMapGroup', v['GROUP_' + name])
    g.write('wMapNumber', v['MAP_' + name])


def _start_call(g, label, a=0):
    """Set up a far call to `label` returning to the current PC, without running it."""
    bank, target = g.addr(label)
    sp = g.reg('sp') - 2
    ret = g.reg('pc')
    g.write('hFarCallSavedA', a)
    g.write('hFarCallSavedL', 0)
    g.write('hFarCallSavedH', 0)
    g.set_reg('af', bank << 8)
    g.set_reg('hl', target)
    g.write(sp, ret & 0xff)
    g.write(sp + 1, ret >> 8)
    g.set_reg('sp', sp)
    g.set_reg('pc', g.syms['FarCall_hl'][1])


def _evo_target(g, slot=0, force_item=None):
    """EvolvePokemon up to its decision: the species index it picked, or None."""
    g.write('wCurPartyMon', slot)
    g.write('wForceEvolution', 1 if force_item else 0)
    if force_item:
        g.write('wCurItem', _item_id(g, force_item))
    _start_call(g, 'EvolvePokemon')
    hit = g.run_until_any([PROCEED, DONE], 300)
    check(hit, 'EvolvePokemon never decided')
    if hit == DONE:
        return None
    lo, hi = rom_byte(g, (g.read('hTemp'), g.reg('hl')), 0, 2)
    return lo | hi << 8


def _name(idx):
    return None if idx is None else _mon_names().get(idx, hex(idx))


def _set_exp(g, slot, exp):
    mon_write(g, slot, 'MON_EXP', [exp >> 16 & 0xff, exp >> 8 & 0xff, exp & 0xff])


def _eevee(g, slot=0, level=20, moves=('SCRATCH',), happiness=0):
    """An Eevee one exp point short of the next level (Eevee is Medium Fast: exp = n^3)."""
    set_party_mon(g, slot, species='EEVEE', level=level, happiness=happiness, moves=moves)
    _set_exp(g, slot, (level + 1) ** 3 - 1)


# =================================================================================================
# 0e9ae6837: better evolution items
# =================================================================================================
EVO_LABEL = {'GLIGAR': 'GligarEvosAttacks', 'SNEASEL': 'SneaselEvosAttacks', 'RHYDON': 'RhydonEvosAttacks',
             'EEVEE': 'EeveeEvosAttacks', 'PORYGON2': 'Porygon2EvosAttacks'}
# (species, item, HEAD result). v0.9 had Moon Stone -> Gliscor/Weavile/Sylveon, Sun Stone -> Rhyperior.
CHANGED = [
    ('GLIGAR', 'RAZOR_CLAW', 'GLISCOR'), ('GLIGAR', 'MOON_STONE', None),
    ('SNEASEL', 'RAZOR_CLAW', 'WEAVILE'), ('SNEASEL', 'MOON_STONE', None),
    ('RHYDON', 'PROTECTOR', 'RHYPERIOR'), ('RHYDON', 'SUN_STONE', None),
    ('EEVEE', 'SUN_STONE', 'SYLVEON'), ('EEVEE', 'MOON_STONE', None),
    ('PORYGON2', 'DUBIOUS_DISC', 'PORYGON_Z'),
    ('GLIGAR', 'PROTECTOR', None), ('RHYDON', 'RAZOR_CLAW', None), ('SNEASEL', 'DUBIOUS_DISC', None),
    ('PORYGON2', 'RAZOR_CLAW', None),
]


@test(S)
def items_evo_changed_items(g):
    """Each changed item evolution: new item evolves (EvolvePokemon and the party menu's ABLE check),
    the old one does nothing, the new items don't evolve the wrong mon."""
    _set_map(g, 'ROUTE_34')
    base = g.state()
    bad, seen = [], {}
    for sp, item, want in CHANGED:
        g.load(base)
        set_party_mon(g, 0, species=sp, level=50, happiness=0)
        got = _name(_evo_target(g, force_item=item))
        g.load(base)
        bank, a = g.addr(EVO_LABEL[sp])
        g.write('wCurItem', _item_id(g, item))
        r = g.call('DetermineEvolutionItemResults', bc=bank << 8, de=a)
        menu = _name(r['de'] or None)
        seen['%s+%s' % (sp, item)] = (got, menu)
        if got != want or menu != want:
            bad.append(dict(mon=sp, item=item, want=want, evolve=got, party_menu=menu))
    check(not bad, 'item evolutions wrong', bad=bad)
    return seen


def _parse_evos():
    """{label: [entries]} from the evos tables; entry = (kind, args...)."""
    out = {}
    for f in ('kanto', 'johto', 'extra'):
        cur = None
        for line in _src('data/pokemon/evos_attacks_%s.asm' % f).splitlines():
            m = re.match(r'^(\w+)EvosAttacks:', line)
            if m:
                cur = out.setdefault(m.group(1), [])
                continue
            if cur is None:
                continue
            s = line.split(';')[0].strip()
            if s.startswith('db 0'):
                cur = None
            elif (m := re.match(r'db\s+EVOLVE_REGION,\s*(\w+)', s)):
                cur.append(('region', m.group(1)))
            elif re.match(r'db\s+EVOLVE_LOCATION$', s):
                cur.append(('location', None))
            elif (m := re.match(r'map_id\s+(\w+)', s)) and cur and cur[-1] == ('location', None):
                cur[-1] = ('location', m.group(1))
            elif (m := re.match(r'dbww\s+EVOLVE_ITEM,\s*(\w+),\s*(\w+)', s)):
                cur.append(('item', m.group(1), m.group(2)))
            elif re.match(r'db\w*\s+EVOLVE_', s):
                cur.append(('other', s))
    return out


def _expect_item(entries, item, region, mapname):
    gate = None
    for e in entries:
        if e[0] in ('region', 'location'):
            gate = e
            continue
        ok = gate is None or (gate[0] == 'region' and gate[1] == region) or \
            (gate[0] == 'location' and gate[1] == mapname)
        gate = None
        if ok and e[0] == 'item' and e[1] == item:
            return e[2]
    return None


@test(S)
def items_evo_item_sweep(g):
    """Every EVOLVE_ITEM entry in the source: forcing that item on that species evolves it to what the
    table says (first match wins, gates honoured), in-game and in the party menu's ABLE check."""
    tables = _parse_evos()
    consts = _consts('constants/pokemon_constants.asm', r'^\s*const\s+(\w+)')
    norm = {c.replace('_', ''): c for c in consts}
    _set_map(g, 'ROUTE_34')
    johto = value('JOHTO_REGION')
    g.write('wCurRegion', johto)
    base = g.state()
    bad, n = [], 0
    for label, entries in tables.items():
        for e in entries:
            if e[0] != 'item':
                continue
            idx = entries.index(e)
            gate = entries[idx - 1] if idx and entries[idx - 1][0] in ('region', 'location') else None
            region = gate[1] if gate and gate[0] == 'region' else 'JOHTO_REGION'
            mapname = gate[1] if gate and gate[0] == 'location' else 'ROUTE_34'
            want = _expect_item(entries, e[1], region, mapname)
            sp = norm.get(label.upper())
            if not sp:
                bad.append(dict(label=label, err='no species constant'))
                continue
            g.load(base)
            g.write('wCurRegion', value(region))
            _set_map(g, mapname)
            set_party_mon(g, 0, species=sp, level=50, happiness=0)
            got = _name(_evo_target(g, force_item=e[1]))
            bank, a = g.addr(label + 'EvosAttacks')
            g.write('wCurItem', _item_id(g, e[1]))
            menu = _name(g.call('DetermineEvolutionItemResults', bc=bank << 8, de=a)['de'] or None)
            n += 1
            if got != want or menu != want:
                bad.append(dict(mon=sp, item=e[1], want=want, evolve=got, party_menu=menu))
    check(not bad, 'item evolution sweep mismatches', bad=bad)
    return {'entries_checked': n}


def _use_item(g, item, slot=0, key='a'):
    """DoItemEffect for `item` from the overworld, choosing party `slot`; back in control after."""
    g.write('wCurItem', _item_id(g, item))
    _start_call(g, 'DoItemEffect')
    check(wait_for(g, 'PartyMenuSelect', key='b', max_presses=60), 'party menu never opened', item=item)
    pick_party(g, slot)
    return finish(g, key, 600)


NEW_ITEMS = ('RAZOR_CLAW', 'DUBIOUS_DISC', 'PROTECTOR')


@test(S)
def items_evo_use_from_pack(g):
    """The real USE path (DoItemEffect -> party menu -> evolution scene): the mon evolves and one item
    is used up; a wrong item says no effect and is kept. Also the attribute rows: ITEM pocket, field
    USE opens the party menu."""
    attrs = _src('data/items/attributes.asm')
    for it in NEW_ITEMS:
        m = re.search(r'^; %s\n\s*item_attribute (.*)$' % it, attrs, re.M)
        check(m, 'no attribute row', item=it)
        f = [x.strip() for x in m.group(1).split(',')]
        check(f[4] == 'ITEM' and f[5] == 'ITEMMENU_PARTY', 'not usable from the pack', item=it, attr=f)
    warp(g, 'ROUTE_34', 11, 14)
    base = g.state()
    cases = [('GLIGAR', 'RAZOR_CLAW', 'GLISCOR'), ('SNEASEL', 'RAZOR_CLAW', 'WEAVILE'),
             ('RHYDON', 'PROTECTOR', 'RHYPERIOR'), ('PORYGON2', 'DUBIOUS_DISC', 'PORYGON_Z'),
             ('EEVEE', 'SUN_STONE', 'SYLVEON'), ('GLIGAR', 'MOON_STONE', None), ('RHYDON', 'SUN_STONE', None)]
    out, bad = {}, []
    for sp, item, want in cases:
        g.load(base)
        set_party_mon(g, 0, species=sp, level=50, happiness=0, moves=('SCRATCH',))
        set_item(g, item, 3)
        ok = _use_item(g, item)
        got = _name(species_index(g, 0))
        q = item_qty(g, item)
        out['%s+%s' % (sp, item)] = dict(species=got, qty=q, control=ok)
        exp = dict(species=want or sp, qty=2 if want else 3, control=True)
        if out['%s+%s' % (sp, item)] != exp:
            bad.append(dict(case='%s+%s' % (sp, item), want=exp, got=out['%s+%s' % (sp, item)]))
            _shot(g, 'use_%s_%s' % (sp, item))
    check(not bad, 'pack use wrong', bad=bad)
    return out


# =================================================================================================
# ac5272006: EVOLVE_LOCATION
# =================================================================================================
@test(S)
def items_loc_all_maps(g):
    """Every map in the game (all group/number pairs): only ILEX_FOREST gives Leafeon and only
    ICE_PATH_B3F gives Glaceon on a level-up; maps sharing either half of the id do nothing."""
    _eevee(g)
    base = g.state()
    maps = _maps()
    ilex = next(m for m in maps if m[0] == 'ILEX_FOREST')
    b3f = next(m for m in maps if m[0] == 'ICE_PATH_B3F')
    bad, hits = [], {}
    pairs = [(n, gr, nu) for n, gr, nu in maps]
    # ids that exist in no map but share one half with a gated map
    pairs += [('fake_%d_%d' % (ilex[1], 0xfe), ilex[1], 0xfe), ('fake_%d_%d' % (0xfe, ilex[2]), 0xfe, ilex[2]),
              ('fake_%d_%d' % (b3f[1], 0xfe), b3f[1], 0xfe), ('fake_%d_%d' % (0xfe, b3f[2]), 0xfe, b3f[2])]
    for n, gr, nu in pairs:
        g.load(base)
        g.write('wMapGroup', gr)
        g.write('wMapNumber', nu)
        got = _name(_evo_target(g))
        want = 'LEAFEON' if (gr, nu) == ilex[1:] else 'GLACEON' if (gr, nu) == b3f[1:] else None
        if got:
            hits[n] = got
        if got != want:
            bad.append(dict(map=n, id=(gr, nu), want=want, got=got))
    same = [n for n, gr, nu in maps if (gr == ilex[1] or nu == ilex[2] or gr == b3f[1] or nu == b3f[2])]
    check(not bad, 'location gate wrong on some maps', bad=bad[:20])
    return {'maps': len(pairs), 'evolved_on': hits, 'sharing_half_an_id': len(same)}


LOC_CASES = (('ILEX_FOREST', 1, 6, 'LEAFEON', 'RAZOR_LEAF'), ('ICE_PATH_B3F', 3, 6, 'GLACEON', 'ICY_WIND'),
             ('ROUTE_34', 11, 14, 'EEVEE', None), ('ILEX_FOREST_AZALEA_GATE', 5, 4, 'EEVEE', None))


@test(S)
def items_loc_battle_levelup(g):
    """A real wild battle on each map: Eevee (1 exp short) KOs the foe, levels up, and evolves only
    on the gated maps, learning the evolution move."""
    base = g.state()
    out, bad = {}, []
    for m, x, y, want, move in LOC_CASES:
        g.load(base)
        warp(g, m, x, y)
        b = Battle(g, enemy='RATTATA', enemy_level=5, lead='EEVEE', lead_level=20, moves=('SCRATCH',),
                   happiness=0, enemy_hp=1, setup=lambda g: _set_exp(g, 0, 21 ** 3 - 1))
        check(b.turn(0, stop='CleanUpBattleRAM', max_frames=8000), 'battle never ended', map=m)
        ok = finish(g, 'a', 600)
        got = _name(species_index(g, 0))
        lvl = mon_read(g, 0, 'MON_LEVEL')[0]
        moves = [_move_name(x) for x in party_moves(g, 0)]
        out[m] = dict(species=got, level=lvl, moves=moves)
        if got != want or lvl != 21 or not ok or (move and move not in moves):
            bad.append(dict(map=m, want=want, want_move=move, control=ok, **out[m]))
            _shot(g, 'battle_%s' % m)
    check(not bad, 'battle level-up evolution wrong', bad=bad)
    return out


def _move_name(idx):
    if not idx:
        return None
    return _first_names('constants/move_constants.asm').get(idx, hex(idx))


@test(S)
def items_loc_rare_candy(g):
    """Rare Candy from the pack on each map: level 20 -> 21, evolving only on the gated maps."""
    base = g.state()
    out, bad = {}, []
    for m, x, y, want, move in LOC_CASES:
        g.load(base)
        warp(g, m, x, y)
        _eevee(g, moves=('SCRATCH',))
        set_item(g, 'RARE_CANDY', 5)
        ok = _use_item(g, 'RARE_CANDY')
        got = _name(species_index(g, 0))
        moves = [_move_name(x) for x in party_moves(g, 0)]
        out[m] = dict(species=got, level=mon_read(g, 0, 'MON_LEVEL')[0], moves=moves, candy=item_qty(g, 'RARE_CANDY'))
        if got != want or out[m]['level'] != 21 or not ok or out[m]['candy'] != 4 or (move and move not in moves):
            bad.append(dict(map=m, want=want, control=ok, **out[m]))
            _shot(g, 'candy_%s' % m)
    check(not bad, 'Rare Candy evolution wrong', bad=bad)
    return out


@test(S)
def items_loc_party_order_and_nonlead(g):
    """Two Eevees after one battle in Ilex: the lead (leveled) evolves, an Eevee that didn't level stays."""
    warp(g, 'ILEX_FOREST', 1, 6)
    _eevee(g, slot=1, level=30)
    _set_exp(g, 1, 30 ** 3)  # mid-level: won't level from this fight's split
    mon_write(g, 1, 'MON_ITEM', 0)
    for s in range(2, 6):
        mon_write(g, s, 'MON_ITEM', 0)  # no Exp Share sharing
    b = Battle(g, enemy='RATTATA', enemy_level=5, lead='EEVEE', lead_level=20, moves=('SCRATCH',),
               happiness=0, enemy_hp=1, setup=lambda g: _set_exp(g, 0, 21 ** 3 - 1))
    check(b.turn(0, stop='CleanUpBattleRAM', max_frames=8000), 'battle never ended')
    check(finish(g, 'a', 600), 'no control after the battle')
    got = (_name(species_index(g, 0)), _name(species_index(g, 1)))
    check(got == ('LEAFEON', 'EEVEE'), 'wrong evolutions', got=got)
    return {'slots': got}


# =================================================================================================
# a24fa4daf: evolution moves
# =================================================================================================
@test(S)
def items_evo_move_full_moveset(g):
    """Leafeon with four moves: asked to forget one for Razor Leaf; declining keeps the four. An Eevee
    that already knows Razor Leaf does not get it twice."""
    warp(g, 'ILEX_FOREST', 1, 6)
    base = g.state()
    four = ('SCRATCH', 'LEER', 'GROWL', 'QUICK_ATTACK')
    _eevee(g, moves=four)
    set_item(g, 'RARE_CANDY', 5)
    g.write('wCurItem', _item_id(g, 'RARE_CANDY'))
    _start_call(g, 'DoItemEffect')
    check(wait_for(g, 'PartyMenuSelect', key='b', max_presses=60), 'party menu never opened')
    pick_party(g, 0)
    asked = wait_for(g, 'YesNoBox', key='a', max_presses=400)
    check(asked, 'never asked to forget a move')
    answer(g, yes=False)  # don't delete a move
    check(wait_for(g, 'YesNoBox', key='b', max_presses=100), 'no "stop learning?" prompt')
    answer(g, yes=True)   # stop learning Razor Leaf
    check(finish(g, 'b', 400), 'no control after the prompts')
    full = dict(species=_name(species_index(g, 0)), moves=[_move_name(x) for x in party_moves(g, 0)])
    check(full == dict(species='LEAFEON', moves=list(four)), 'declining changed the moves', **full)
    g.load(base)
    _eevee(g, moves=('RAZOR_LEAF', 'SCRATCH'))
    set_item(g, 'RARE_CANDY', 5)
    check(_use_item(g, 'RARE_CANDY'), 'no control after evolving')
    dup = dict(species=_name(species_index(g, 0)), moves=[_move_name(x) for x in party_moves(g, 0)])
    check(dup['species'] == 'LEAFEON' and dup['moves'].count('RAZOR_LEAF') == 1, 'Razor Leaf duplicated', **dup)
    return {'full': full, 'already_known': dup}


@test(S)
def items_evo_move_table(g):
    """Every Eeveelution's learnset starts with its evolution move (a24fa4daf adds Leafeon, Glaceon,
    Sylveon); read from the ROM after SkipEvolutions."""
    want = {'Vaporeon': None, 'Jolteon': None, 'Flareon': None, 'Espeon': None, 'Umbreon': None,
            'Leafeon': 'RAZOR_LEAF', 'Glaceon': 'ICY_WIND', 'Sylveon': 'DISARM_VOICE'}
    evo = value('LEARN_EVO_MOVE')
    out, bad = {}, []
    for label, w in want.items():
        bank, a = g.addr(label + 'EvosAttacks')
        hl = g.call('SkipEvolutions', bc=bank << 8, hl=a)['hl']
        lvl, lo, hi = rom_byte(g, (bank, hl), 0, 3)
        out[label] = _move_name(lo | hi << 8) if lvl == evo else None
        if w and out[label] != w:
            bad.append(dict(mon=label, want=w, got=out[label]))
    check(not bad, 'evolution moves missing', bad=bad)
    return out


# =================================================================================================
# c8628144b: Kanto item balls
# =================================================================================================
BALLS = [  # map, label, flag, item
    ('SAFARI_ZONE', 'SafariZone', 'EVENT_SAFARI_ZONE_PROTECTOR', 'PROTECTOR'),
    ('POKEMON_MANSION', 'PokemonMansion', 'EVENT_POKEMON_MANSION_DUBIOUS_DISC', 'DUBIOUS_DISC'),
    ('SEAFOAM_CAVES', 'SeafoamCaves', 'EVENT_SEAFOAM_CAVES_RAZOR_CLAW', 'RAZOR_CLAW'),
    ('ROCK_TUNNEL_B1F', 'RockTunnelB1F', 'EVENT_ROCK_TUNNEL_B1F_RAZOR_CLAW', 'RAZOR_CLAW'),
]


def _ball(mapcamel, flag):
    """(x, y, script label) of the item ball object with hide flag `flag`, and the item it gives."""
    s = _src('maps/%s.asm' % mapcamel)
    m = re.search(r'object_event\s+(\d+),\s*(\d+),\s*SPRITE_POKE_BALL,.*OBJECTTYPE_ITEMBALL,\s*0,\s*(\w+),\s*%s\s*$'
                  % flag, s, re.M)
    if not m:
        return None
    it = re.search(r'^%s:\s*\n\s*itemball\s+(\w+)' % m.group(3), s, re.M)
    return int(m.group(1)), int(m.group(2)), m.group(3), it and it.group(1)


@test(S)
def items_balls_flags(g):
    """The four new balls exist and give the right item; each flag is unique among all event flags,
    referenced by nothing but its own ball, was an unused slot in v0.9, and is clear in the fixture."""
    flags = _consts('constants/event_flags.asm', r'^\s*const\s+(EVENT_\w+)')
    byval = {}
    for k, v in flags.items():
        byval.setdefault(v, []).append(k)
    v09 = os.environ.get('V09_REPO', '/tmp/claude-1000/-home-bryan-Documents-Romhacks-crystal-eclipse/'
                         '4203bf99-da66-490e-998d-1f337047b4f7/scratchpad/wt/v09')
    old = _v09_flags(v09)
    old_vals = set(old.values())
    out, bad = {}, []
    grep_src = {}
    for d in ('maps', 'engine', 'data', 'home', 'constants'):
        for root, _, files in os.walk(os.path.join(REPO, d)):
            for f in files:
                if f.endswith('.asm'):
                    grep_src[os.path.join(root, f)] = open(os.path.join(root, f), errors='replace').read()
    for mapname, camel, flag, item in BALLS:
        b = _ball(camel, flag)
        if not b:
            bad.append(dict(flag=flag, err='no item ball with this flag'))
            continue
        x, y, script, gives = b
        refs = sorted(os.path.relpath(p, REPO) for p, t in grep_src.items() if re.search(r'\b%s\b' % flag, t))
        v = flags.get(flag)
        r = dict(at=(x, y), gives=gives, value=v, same_value=byval.get(v), refs=refs,
                 v09_slot_used=v in old_vals, set_in_fixture=event(g, flag))
        out[flag] = r
        if gives != item or v is None or len(byval[v]) != 1 or r['v09_slot_used'] or r['set_in_fixture'] or \
                set(refs) != {'constants/event_flags.asm', 'maps/%s.asm' % camel}:
            bad.append(dict(flag=flag, want_item=item, **r))
    vals = [out[f]['value'] for f in out]
    check(len(set(vals)) == len(vals), 'two balls share a flag', vals=vals)
    check(not bad, 'item ball flag problems', bad=bad)
    check(max(vals) < value('NUM_EVENTS'), 'flag past NUM_EVENTS')
    return out


def _v09_flags(repo):
    names = list(dict.fromkeys(re.findall(r'^\s*const\s+(EVENT_\w+)', open(os.path.join(repo, 'constants/event_flags.asm')).read(), re.M)))
    src = os.path.join(repo, '_v10_items_consts.asm')
    with open(src, 'w') as f:
        f.write('INCLUDE "includes.asm"\n' + ''.join('PRINTLN "%s=", %s\n' % (n, n) for n in names))
    try:
        out = subprocess.run(['rgbasm', '-D', '_DEBUG', '-Q8', '-o', os.devnull, src],
                             cwd=repo, capture_output=True, text=True).stdout
    finally:
        os.unlink(src)
    return {m[1]: int(m[2], 16) for m in re.finditer(r'^(\w+)=\$?([0-9A-Fa-f]+)$', out, re.M)}


# --- static reachability from the built ROM (map blocks + tileset collision + permissions) -------
def _camel(s):
    return ''.join(w.capitalize() for w in s.split('_'))


class MapGrid:
    def __init__(self, g, camel):
        rom_byte(g, (0, 0), 0, 0)  # loads g._rom
        self.rom = g._rom
        maps = dict(re.findall(r'^\s*map (\w+),\s*TILESET_(\w+),', _src('data/maps/maps.asm'), re.M))
        const = dict(re.findall(r'^\s*map_attributes (\w+), (\w+),', _src('data/maps/attributes.asm'), re.M))[camel]
        dims = {m[0]: (int(m[1]), int(m[2])) for m in
                re.findall(r'^\s*map_const (\w+),\s*(\d+),\s*(\d+)', _src('constants/map_constants.asm'), re.M)}
        self.w, self.h = dims[const]
        self.g, self.camel = g, camel
        from mapblocks import map_blocks
        self.blocks = map_blocks(self.rom, self._off(camel + '_Blocks'), self.w * self.h, g.syms)
        self.coll = self._off('Tileset' + _camel(maps[camel]) + 'Coll')
        self.perm = self._off('CollisionPermissionTable')
        s = _src('maps/%s.asm' % camel)
        self.warps = [(int(a), int(b)) for a, b in re.findall(r'^\s*warp_event\s+(\d+),\s*(\d+),', s, re.M)]
        self.objs = [(int(a), int(b), c, d) for a, b, c, d in
                     re.findall(r'^\s*object_event\s+(\d+),\s*(\d+),\s*(\w+),\s*(\w+),', s, re.M)]

    def _off(self, label):
        b, a = self.g.syms[label]
        return a if b == 0 else b * 0x4000 + a - 0x4000

    def cbyte(self, x, y):
        if not (0 <= x < 2 * self.w and 0 <= y < 2 * self.h):
            return None
        blk = self.blocks[(y // 2) * self.w + x // 2]
        return self.rom[self.coll + blk * 4 + (y % 2) * 2 + x % 2]

    def kind(self, x, y):
        c = self.cbyte(x, y)
        if c is None:
            return 'OOB'
        p = self.rom[self.perm + c] & 0xf
        return {0: 'LAND', 1: 'WATER'}.get(p, 'WALL')

    def reach(self, surf=False, smash=False, strength=False):
        """Tiles reachable from any warp."""
        hop = {0xa0: {(1, 0)}, 0xa1: {(-1, 0)}, 0xa2: {(0, -1)}, 0xa3: {(0, 1)}, 0xa4: {(0, 1), (1, 0)},
               0xa5: {(0, 1), (-1, 0)}, 0xa6: {(0, -1), (1, 0)}, 0xa7: {(0, -1), (-1, 0)}}
        block = set()
        for x, y, spr, mv in self.objs:
            if mv == 'SPRITEMOVEDATA_SMASHABLE_ROCK' and smash:
                continue
            if mv == 'SPRITEMOVEDATA_STRENGTH_BOULDER' and strength:
                continue
            block.add((x, y))
        ok = {'LAND'} | ({'WATER'} if surf else set())
        seen, todo = set(), [w for w in self.warps]
        seen.update(todo)
        while todo:
            x, y = todo.pop()
            c = self.cbyte(x, y)
            for d in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                if c in hop and d in hop[c]:
                    t = (x + 2 * d[0], y + 2 * d[1])
                else:
                    t = (x + d[0], y + d[1])
                    if self.kind(*t) not in ok or t in block:
                        continue
                if t not in seen and self.kind(*t) != 'OOB':
                    seen.add(t)
                    todo.append(t)
        return seen


SIDES = {'up': (0, 1), 'down': (0, -1), 'left': (1, 0), 'right': (-1, 0)}  # facing -> stand offset


def _approach(grid, x, y, reach):
    """(stand x, y, facing) next to the ball that is reachable, preferring land."""
    opts = []
    for face, (dx, dy) in SIDES.items():
        t = (x + dx, y + dy)
        if t in reach:
            opts.append((grid.kind(*t) != 'LAND', t[0], t[1], face))
    return min(opts)[1:] if opts else None


@test(S)
def items_balls_reachable(g):
    """Each new ball has a reachable neighbouring tile from the map's warps; report the HMs needed."""
    out, bad = {}, []
    for mapname, camel, flag, item in BALLS:
        b = _ball(camel, flag)
        check(b, 'ball missing', flag=flag)
        x, y = b[0], b[1]
        grid = MapGrid(g, camel)
        need = None
        for label, kw in (('none', {}), ('surf', dict(surf=True)), ('smash', dict(smash=True)),
                          ('surf+smash+strength', dict(surf=True, smash=True, strength=True))):
            a = _approach(grid, x, y, grid.reach(**kw))
            if a:
                need = (label, a)
                break
        out[mapname] = dict(ball=(x, y), ball_tile=grid.kind(x, y), needs=need and need[0],
                            stand=need and need[1])
        if not need:
            bad.append(dict(map=mapname, ball=(x, y)))
    check(not bad, 'ball walled in', bad=bad)
    return out


@test(S)
def items_balls_pickup(g):
    """Warp next to each ball, face it, press A: the item lands in the bag, the flag is set and the
    ball object is gone after reloading the map."""
    out, bad = {}, []
    base = g.state()
    for mapname, camel, flag, item in BALLS:
        b = _ball(camel, flag)
        if not b:
            bad.append(dict(map=mapname, err='no ball'))
            continue
        grid = MapGrid(g, camel)
        a = _approach(grid, b[0], b[1], grid.reach(surf=True, smash=True, strength=True))
        if not a:
            bad.append(dict(map=mapname, err='no approach'))
            continue
        sx, sy, face = a
        g.load(base)
        surf = grid.kind(sx, sy) == 'WATER'
        warp(g, mapname, sx, sy, surf=surf)
        before = _count(g, item)
        interact(g, face)
        ok = finish(g, 'b', 300)
        after = _count(g, item)
        r = dict(stand=(sx, sy), face=face, before=before, after=after, flag=event(g, flag), control=ok)
        # reload the map: the ball must stay gone
        warp(g, mapname, sx, sy, surf=surf)
        interact(g, face)
        finish(g, 'b', 300)
        r['after_reload'] = _count(g, item)
        out[mapname] = r
        if not (ok and after == before + 1 and r['flag'] and r['after_reload'] == after):
            bad.append(dict(map=mapname, **r))
            _shot(g, 'ball_%s' % mapname)
    check(not bad, 'item ball pickup failed', bad=bad)
    return out


# =================================================================================================
# d7954685a: Mart buy quantity capped at what the player can afford
# =================================================================================================
def _set_money(g, m):
    g.write('wMoney', [m >> 16 & 0xff, m >> 8 & 0xff, m & 0xff])


def _money(g):
    return int.from_bytes(bytes(g.read('wMoney', 3)), 'big')


def _cap_model(money, price, start=99):
    if price == 0:
        return start
    return min(start, max(1, money // price))


@test(S)
def items_mart_cap_unit(g):
    """Buy_CapQuantityToMoney against a model, min(99, max(1, money // price)), over the edge cases:
    exact money, zero, one short, 999999, prices whose 99x overflow 16 bits, price 0 and 65535."""
    if 'Buy_CapQuantityToMoney' not in g.syms:
        raise Skip('no Buy_CapQuantityToMoney in this build (pre-d7954685a)')
    prices = [1, 10, 100, 200, 300, 662, 663, 700, 2000, 3000, 9999, 10101, 10102, 45500, 65000, 65535, 0]
    moneys = [0, 1, 299, 300, 301, 599, 600, 2999, 3000, 29700, 29699, 65535, 65536, 98999, 99000,
              999999, 989901, 6488065]
    bad, n = [], 0
    for p in prices:
        for m in moneys + [p * k for k in (1, 2, 98, 99, 100)] + [p * k - 1 for k in (1, 2, 99, 100) if p]:
            if m > 0xffffff:
                continue
            _set_money(g, m)
            g.write('wItemQuantity', 99)
            g.call('Buy_CapQuantityToMoney', de=p)
            got = g.read('wItemQuantity')
            n += 1
            if got != _cap_model(m, p):
                bad.append(dict(money=m, price=p, want=_cap_model(m, p), got=got))
    # the selector's own max is what the caller set: a smaller start is never raised
    _set_money(g, 999999)
    g.write('wItemQuantity', 5)
    g.call('Buy_CapQuantityToMoney', de=1)
    check(g.read('wItemQuantity') == 5, 'start below the cap was changed', got=g.read('wItemQuantity'))
    check(not bad, 'cap wrong', n=len(bad), bad=bad[:15])
    return {'cases': n}


def _mart_select(g, money, item_row=0):
    """Talk to the Cherrygrove clerk, BUY, pick row `item_row`, stop in the quantity selector.
    Returns (item, price, max quantity offered)."""
    warp(g, 'CHERRYGROVE_MART', 2, 3)
    _set_money(g, money)
    interact(g, 'left')
    check(wait_for(g, 'VerticalMenu', key='b', max_presses=40), 'BUY/SELL menu never opened')
    g.frames(10)
    g.press('a', hold=4, after=10)  # BUY
    check(wait_for(g, 'ScrollingMenu', key='b', max_presses=40), 'item list never opened')
    g.frames(20)
    for _ in range(item_row):
        g.press('down', hold=4, after=8)
    g.press('a', hold=4, after=4)
    check(g.run_until('BuySellToss_InterpretJoypad', 600), 'quantity selector never opened')
    item = g.call('GetItemIndexFromID', a=g.read('wCurItem'))['hl']
    price = g.read16('wBuySellItemPrice')
    return item, price, g.read('wItemQuantity')


def _selector_max(g):
    """Press DOWN from x01: the selector wraps to its max. Returns the shown quantity."""
    g.frames(4)
    g.press('down', hold=3, after=10)
    g.run_until('BuySellToss_InterpretJoypad', 60)
    return g.read('wItemQuantityChange')


@test(S)
def items_mart_buy_e2e(g):
    """Cherrygrove Mart through the real menus. Exact money for 3: the selector tops out at 3 and
    buying 3 leaves 0. Zero money: max 1, buying says not enough money and changes nothing.
    999999: max 99. (v0.9 offers 99 every time.)"""
    base = g.state()
    out, bad = {}, []
    item, price, _ = _mart_select(g, 0)
    from visual import text_rows
    iname = _first_names('constants/item_constants.asm').get(item)
    for label, money, want_max, buy in (('exact3', 3 * price, 3, True), ('one_short', 3 * price - 1, 2, False),
                                        ('zero', 0, 1, True), ('max', 999999, 99, False),
                                        ('cap99', 99 * price, 99, True)):
        g.load(base)
        _, _, cap = _mart_select(g, money)
        shown = _selector_max(g)
        r = dict(money=money, cap=cap, selector_max=shown)
        if buy:
            have = item_qty(g, iname)
            g.press('a', hold=4, after=10)
            yes = wait_for(g, 'YesNoBox', key='b', max_presses=40)
            if yes:
                g.frames(30)  # the box ignores input for its first frames
                answer(g, yes=True)
            g.run_until('JoyWaitAorB', 300)
            g.frames(30)
            r.update(asked=yes, money_after=_money(g), bought=item_qty(g, iname) - have,
                     text=[t for t in text_rows(g)[12:] if t.strip('·')])
            want_money = money - shown * price if money >= shown * price else money
            if r['money_after'] != want_money or r['bought'] != (shown if money >= shown * price else 0):
                bad.append(dict(case=label, want_money=want_money, **r))
        out[label] = r
        if shown != want_max:
            bad.append(dict(case=label, want_max=want_max, **r))
            _shot(g, 'mart_%s' % label)
    check(not bad, 'mart quantity/money wrong', item=iname, price=price, bad=bad)
    return dict(item=iname, price=price, **out)


@test(S)
def items_mart_tm_and_rooftop(g):
    """Prices from the real tables through the cap: every standard-mart item (TMs included, decor up
    to 65000) and every rooftop-sale item, at 999999 and at 3x price. Only checks the cap, not menus."""
    if 'Buy_CapQuantityToMoney' not in g.syms:
        raise Skip('no Buy_CapQuantityToMoney in this build')
    items = set(re.findall(r'^\s*dw\s+(\w+)', _src('data/items/marts.asm'), re.M))
    items = {i for i in items if not i.startswith('Mart')}
    roof = re.findall(r'^\s*dw\s+(\w+),\s*(\d+)', _src('data/items/rooftop_sale.asm'), re.M)
    bad, seen = [], {}
    for it in sorted(items):
        g.write('wCurItem', _item_id(g, it))
        p = g.call('GetItemPrice')['de']
        seen[it] = p
        for m in (999999, 3 * p, 0):
            _set_money(g, m)
            g.write('wItemQuantity', 99)
            g.call('Buy_CapQuantityToMoney', de=p)
            if g.read('wItemQuantity') != _cap_model(m, p):
                bad.append(dict(item=it, price=p, money=m, got=g.read('wItemQuantity')))
    for it, p in roof:
        for m in (999999, 3 * int(p)):
            _set_money(g, m)
            g.write('wItemQuantity', 99)
            g.call('Buy_CapQuantityToMoney', de=int(p))
            if g.read('wItemQuantity') != _cap_model(m, int(p)):
                bad.append(dict(rooftop=it, price=p, money=m, got=g.read('wItemQuantity')))
    check(not bad, 'cap wrong for a real price', bad=bad[:10])
    return {'mart_items': len(seen), 'rooftop': len(roof), 'max_price': max(seen.values())}


# =================================================================================================
# da77fc591: auto-Repel stores the kind
# =================================================================================================
REPELS = {'REPEL': (1, 100), 'SUPER_REPEL': (2, 200), 'MAX_REPEL': (3, 250)}


def _step(g, direction='left'):
    g.press(direction, hold=16, after=4)


def _use_plain(g, item):
    g.write('wCurItem', _item_id(g, item))
    _start_call(g, 'DoItemEffect')
    return finish(g, 'b', 300)


@test(S)
def items_repel_kinds(g):
    """Per kind, no save involved: using it from the pack stores kind 1-3 and its steps; at wear-off
    "Use another?" yes re-uses the SAME kind; no keeps the item and leaves Repel off; with none of that
    kind left (other kinds in the bag) it just wears off; using one while active is refused."""
    from visual import text_rows
    warp(g, 'ROUTE_23', 10, 6)
    for it in REPELS:
        set_item(g, it, 0)
    base = g.state()
    out, bad = {}, []
    for item, (kind, steps) in REPELS.items():
        r = out[item] = {}
        # use from the pack
        g.load(base)
        set_item(g, item, 3)
        g.write('wRepelEffect', 0)
        r['use_control'] = _use_plain(g, item)
        r['use'] = (g.read('wRepelEffect'), g.read('wRepelType'), item_qty(g, item))
        if r['use'] != (steps, kind, 2):
            bad.append(dict(item=item, case='use', want=(steps, kind, 2), got=r['use']))
        # using another while active: refused, not consumed
        _use_plain(g, item)
        r['while_active'] = (g.read('wRepelEffect'), item_qty(g, item))
        if r['while_active'] != (steps, 2):
            bad.append(dict(item=item, case='while_active', got=r['while_active']))
        mid = g.state()
        # wear off -> yes
        g.write('wRepelEffect', 1)
        _step(g)
        asked = wait_for(g, 'YesNoBox', key='b', max_presses=60)
        if asked:
            answer(g, yes=True)
        finish(g, 'b', 300)
        r['yes'] = (asked, g.read('wRepelEffect'), g.read('wRepelType'), item_qty(g, item))
        if r['yes'] != (True, steps, kind, 1):
            bad.append(dict(item=item, case='yes', want=(True, steps, kind, 1), got=r['yes']))
        # wear off -> no
        g.load(mid)
        g.write('wRepelEffect', 1)
        _step(g)
        asked = wait_for(g, 'YesNoBox', key='b', max_presses=60)
        if asked:
            answer(g, yes=False)
        finish(g, 'b', 300)
        r['no'] = (asked, g.read('wRepelEffect'), item_qty(g, item))
        if r['no'] != (True, 0, 2):
            bad.append(dict(item=item, case='no', want=(True, 0, 2), got=r['no']))
        # the last one: re-used, and the pocket entry goes away
        g.load(mid)
        set_item(g, item, 1)
        g.write('wRepelEffect', 1)
        _step(g)
        asked = wait_for(g, 'YesNoBox', key='b', max_presses=60)
        if asked:
            answer(g, yes=True)
        finish(g, 'b', 300)
        r['last'] = (asked, g.read('wRepelEffect'), g.read('wRepelType'), item_qty(g, item))
        if r['last'] != (True, steps, kind, 0):
            bad.append(dict(item=item, case='last', want=(True, steps, kind, 0), got=r['last']))
        # none of this kind left, the other kinds in the bag
        g.load(mid)
        set_item(g, item, 0)
        for other in REPELS:
            if other != item:
                set_item(g, other, 5)
        g.write('wRepelEffect', 1)
        _step(g)
        asked = g.run_until('YesNoBox', 150)  # the wear-off text has printed by then too
        rows = text_rows(g)
        finish(g, 'b', 300)
        r['none_left'] = dict(asked=asked, wore_off=any('wore off' in t for t in rows),
                              effect=g.read('wRepelEffect'), others=[item_qty(g, o) for o in REPELS if o != item])
        if asked or not r['none_left']['wore_off'] or r['none_left']['effect'] or r['none_left']['others'] != [5, 5]:
            bad.append(dict(item=item, case='none_left', **r['none_left']))
            _shot(g, 'repel_none_%s' % item)
    check(not bad, 'Repel kinds wrong', bad=bad)
    return out


# =================================================================================================
# 6e4015230 / 709ce7532: debug items; the Silver Cave coach's Star Piece
# =================================================================================================
@test(S)
def items_debug_items_given(g):
    """Every giveitem in the debug radio script landed in the bag with its quantity (a full pocket
    would silently drop the new Star Piece / Dubious Disc / Razor Claw / Protector)."""
    s = _src('maps/PlayersHouse2F.asm')
    block = s[s.index('PlayersHouseRadioScript:'):s.index('else', s.index('PlayersHouseRadioScript:'))]
    want = {}
    for line in block.splitlines():
        m = re.match(r'^\s*giveitem\s+(\w+)(?:,\s*(\d+))?', line)
        if m:
            want[m.group(1)] = want.get(m.group(1), 0) + int(m.group(2) or 1)
    bad, out = [], {}
    keys = set()
    for it, q in want.items():
        got = _count(g, it)
        out[it] = got
        if got == 0:
            # key items have no quantity: check presence instead
            g.write('wCurItem', _item_id(g, it))
            if g.call('CheckItem', hl=g.addr('wNumKeyItems')[1])['carry']:
                keys.add(it)
                continue
        if got != q:
            bad.append(dict(item=it, want=q, got=got))
    check(not bad, 'debug items missing', bad=bad, items_in_pocket=g.read('wNumItems'))
    return {'items': len(want), 'key_items': sorted(keys), 'item_pocket_used': g.read('wNumItems')}


def _coach_talk(g):
    warp(g, 'SILVER_CAVE_POKECENTER_1F', 7, 3)
    interact(g, 'up')
    return wait_for(g, 'YesNoBox', key='b', max_presses=60)


@test(S)
def items_coach_star_piece(g):
    """Silver Cave coach: with Star Pieces, yes -> pick a mon -> yes takes ONE Star Piece and gives
    perfect DVs/max EVs; a second visit is "done today". Without one: "no fee", no party menu."""
    from visual import text_rows
    base = g.state()
    have = _count(g, 'STAR_PIECE')
    set_engine(g, 'ENGINE_PERFECT_MON_COACH', False)
    if have == 0:
        set_item(g, 'STAR_PIECE', 10)
        have = 10
    slot = 3
    mon_write(g, slot, 'MON_DVS', [0x00, 0x00])
    mon_write(g, slot, 'MON_EVS', [0] * 6)
    check(_coach_talk(g), 'coach never asked')
    answer(g, yes=True)
    check(wait_for(g, 'PartyMenuSelect', key='b', max_presses=60), 'no party menu')
    pick_party(g, slot)
    check(wait_for(g, 'YesNoBox', key='b', max_presses=60), 'no confirm prompt')
    answer(g, yes=True)
    check(finish(g, 'b', 600), 'no control after training')
    r = dict(star_before=have, star_after=_count(g, 'STAR_PIECE'), dvs=[hex(x) for x in mon_read(g, slot, 'MON_DVS', 2)],
             evs=mon_read(g, slot, 'MON_EVS', 6), flag=engine(g, 'ENGINE_PERFECT_MON_COACH'))
    check(r['star_after'] == have - 1 and r['evs'] == [value('MAX_EV')] * 6 and r['flag'] and
          mon_read(g, slot, 'MON_DVS')[0] & 0xf0 == 0xf0, 'coach result wrong', **r)
    # second visit: done today
    warp(g, 'SILVER_CAVE_POKECENTER_1F', 7, 3)
    interact(g, 'up')
    asked = g.run_until('YesNoBox', 200)
    finish(g, 'b', 200)
    r['second_visit_asked'] = asked
    check(not asked and _count(g, 'STAR_PIECE') == have - 1, 'second visit charged or asked', **r)
    # no Star Piece
    g.load(base)
    set_engine(g, 'ENGINE_PERFECT_MON_COACH', False)
    set_item(g, 'STAR_PIECE', 0)
    check(_coach_talk(g), 'coach never asked (no fee case)')
    answer(g, yes=True)
    menu = g.run_until('PartyMenuSelect', 200)
    g.frames(30)
    rows = text_rows(g)
    finish(g, 'b', 200)
    r['no_fee'] = dict(party_menu=menu, text=[t for t in rows[12:] if t.strip('·')])
    check(not menu, 'party menu opened without a Star Piece', **r)
    return r

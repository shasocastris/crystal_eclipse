"""Scene tests driven through real inputs: deity tutors, Rainbow Wing chain, Mewtwo, coach, gifts.

Every scene starts with overworld.warp() from the debug-party fixture; flags a map callback reads
are set in warp's `before` hook so the callback sees them.
"""
from consts import resolve, value
from game import event, mon, mon_read, mon_write, mon_word, set_event, engine, set_engine, species_id, species_index
from overworld import (answer, finish, interact, item_qty, has_key_item, party_moves, pick_party,
                       set_happiness, set_item, set_key_item, wait_for, warp, in_control)
from registry import check, test

TEACHER, UNHAPPY = 0, 3   # debug party: slot 0 Mewtwo at 255 happiness, slot 3 at 70


def _free_last_move(g, slot, teach):
    """Empty move 4 so LearnMove takes the free slot. Mewtwo already knows some tutor
    moves (Aura Sphere, Fae Blade), so a known `teach` is swapped out for move 4 first."""
    moves = mon_read(g, slot, 'MON_MOVES', 4)
    pp = mon_read(g, slot, 'MON_PP', 4)
    known = party_moves(g, slot)
    if value(teach) in known[:3]:
        i = known.index(value(teach))
        moves[i], pp[i] = moves[3], pp[3]
    mon_write(g, slot, 'MON_MOVES', moves[:3] + [0])
    mon_write(g, slot, 'MON_PP', pp[:3] + [0])


def _no_script(g, direction, frames=90):
    """Face `direction`, press A, and confirm no script starts (nothing there to talk to)."""
    interact(g, direction)
    for _ in range(frames):
        g.frames(1)
        if g.read('wScriptRunning'):
            finish(g)
            return False
    return True


def _set_party_count(g, n):
    g.write('wPartyCount', n)
    g.write('wPartySpecies+%d' % n, 0xff)


# --- deity tutors ---
# name: (map, stand x, y, facing, FOUGHT flag, hide flag, move, extra setup, surf)
DEITIES = {
    'ARTICUNO': ('SEAFOAM_CAVES', 10, 7, 'up', 'EVENT_SEAFOAM_CAVES_ARTICUNO', 'SHEER_COLD', None),
    'ZAPDOS': ('ROCK_TUNNEL_B1F', 12, 11, 'down', 'EVENT_ROCK_TUNNEL_ZAPDOS', 'INNER_LIGHT',
               lambda g: set_event(g, 'EVENT_RESTORED_POWER_TO_KANTO')),
    'MOLTRES': ('VICTORY_ROAD', 11, 50, 'left', 'EVENT_VICTORY_ROAD_MOLTRES', 'SKY_ATTACK', None),
    'LUGIA': ('WHIRL_ISLAND_LUGIA_CHAMBER', 9, 4, 'down', 'EVENT_WHIRL_ISLAND_LUGIA_CHAMBER_LUGIA', 'AEROBLAST',
              lambda g: set_key_item(g, 'SILVER_WING')),
    'HO_OH': ('TIN_TOWER_ROOF', 9, 6, 'up', 'EVENT_TIN_TOWER_ROOF_HO_OH', 'SACRED_FIRE',
              lambda g: set_key_item(g, 'RAINBOW_WING')),
    'MEW': ('SHAMOUTI_CAVE', 8, 2, 'down', 'EVENT_SHAMOUTI_CAVE_MEW', 'AURA_SPHERE',
            lambda g: set_event(g, 'EVENT_BEAT_ELITE_FOUR_REMATCH')),
    'ENTEI': ('DARK_CAVE_BLACKTHORN_ENTRANCE', 15, 9, 'down', 'EVENT_DARK_CAVE_ENTEI', 'ERUPTION', None),
    'RAIKOU': ('BURNED_TOWER_B1F', 7, 2, 'down', 'EVENT_BURNED_TOWER_B1F_RAIKOU', 'STORM_CALL',
               lambda g: [set_event(g, e) for e in ('EVENT_RELEASED_THE_BEASTS', 'EVENT_BURNED_TOWER_B1F_BEASTS_1',
                                                    'EVENT_BURNED_TOWER_B1F_BEASTS_2')]),
}


def _deity_warp(g, name):
    m, x, y, _, _, _, extra = DEITIES[name]
    warp(g, m, x, y, before=extra, surf=(name == 'LUGIA'))


def _deity_talk(g, name, yes=True, slot=TEACHER, cancel=False):
    """Talk to a deity and answer its offer. Returns the DEITYTUTOR_* code the script left."""
    interact(g, DEITIES[name][3])
    check(wait_for(g, 'YesNoBox'), 'deity never asked', deity=name)
    answer(g, yes)
    if yes:
        check(wait_for(g, 'PartyMenuSelect'), 'party menu never opened', deity=name)
        pick_party(g, slot, cancel)
    check(finish(g), 'control never returned', deity=name)
    return g.read('wScriptVar')


def _deity_scene(g, name):
    _, _, _, facing, hide, move, _ = DEITIES[name]
    fought = 'EVENT_FOUGHT_' + name
    move_idx = value(move)
    _free_last_move(g, TEACHER, move)
    set_happiness(g, TEACHER, 255)
    _deity_warp(g, name)
    check(not event(g, hide), 'deity hidden on arrival', deity=name)
    codes = {}
    for case, kw, want in [('no', dict(yes=False), 'DEITYTUTOR_CANCEL'),
                           ('cancel', dict(cancel=True), 'DEITYTUTOR_CANCEL'),
                           ('unhappy', dict(slot=UNHAPPY), 'DEITYTUTOR_NOT_HAPPY')]:
        codes[case] = _deity_talk(g, name, **kw)
        check(codes[case] == value(want), 'unexpected result', deity=name, case=case, got=codes[case])
        check(not event(g, fought) and not event(g, hide), 'refusal moved the deity on', deity=name, case=case)
        check(move_idx not in party_moves(g, UNHAPPY), 'unhappy mon learned the move', deity=name)
    codes['taught'] = _deity_talk(g, name)
    check(codes['taught'] == value('DEITYTUTOR_TAUGHT'), 'did not teach', deity=name, got=codes['taught'])
    check(move_idx in party_moves(g, TEACHER), 'move not learned', deity=name,
          moves=[hex(m) for m in party_moves(g, TEACHER)])
    check(event(g, fought), 'FOUGHT flag not set', deity=name)
    check(event(g, hide), 'deity not hidden', deity=name)
    _deity_warp(g, name)
    check(event(g, hide), 'deity back after re-warp', deity=name)
    check(_no_script(g, facing), 'deity still talks after re-warp', deity=name)
    return codes


# Parked: since 87580fe2d the deities battle again and the tutor offer is gone, so these fail by
# design. Set True once they're rewritten. deity_story_gates stays on.
DEITY_TUTOR_TESTS = False


def _deity_tutor_test(fn):
    return test('scenes')(fn) if DEITY_TUTOR_TESTS else fn


def _deity_test(name):
    def t(g):
        return _deity_scene(g, name)
    t.__name__ = 'deity_' + name.lower()
    t.__doc__ = '%s: refusals keep it; a 255-happiness mon learns its move and it leaves for good.' % name
    return _deity_tutor_test(t)


for _n in DEITIES:
    _deity_test(_n)


def _enter_tin_tower_1f(g):
    """Walk-in equivalent of the Ecruteak door. The scene runs on entry, so warp() cannot wait for control."""
    check(g.run_until('OverworldLoop.loop', 120), 'not in overworld')
    g.write('wTinTower1FSceneID', 0)
    v = resolve('GROUP_TIN_TOWER_1F', 'MAP_TIN_TOWER_1F')
    g.write('wMapGroup', v['GROUP_TIN_TOWER_1F'])
    g.write('wMapNumber', v['MAP_TIN_TOWER_1F'])
    g.write('wXCoord', 9)
    g.write('wYCoord', 15)
    g.write('wDefaultSpawnpoint', 0xff)
    g.write('hMapEntryMethod', value('MAPSETUP_WARP'))
    g.write('wMapStatus', 1)


@_deity_tutor_test
def deity_suicune(g):
    """Suicune's Tin Tower cutscene: a refusal hands control back; success teaches and ends the scene."""
    move_idx = value('LIFE_DEW')
    _free_last_move(g, TEACHER, 'LIFE_DEW')
    base = g.state()
    out, problems = {}, []
    for case, kw, want in [('no', dict(yes=False), 'DEITYTUTOR_CANCEL'),
                           ('unhappy', dict(slot=UNHAPPY), 'DEITYTUTOR_NOT_HAPPY'),
                           ('taught', {}, 'DEITYTUTOR_TAUGHT')]:
        g.load(base)
        _enter_tin_tower_1f(g)
        check(wait_for(g, 'YesNoBox', max_presses=400), 'Suicune never asked', case=case)
        yes = kw.get('yes', True)
        answer(g, yes)
        if yes:
            check(wait_for(g, 'PartyMenuSelect'), 'party menu never opened', case=case)
            pick_party(g, kw.get('slot', TEACHER))
        if case == 'taught':
            check(finish(g, max_presses=600), 'control never returned', case=case)
            break
        g.frames(60)
        code = g.read('wScriptVar')
        back = finish(g, max_presses=300)
        out[case] = dict(code=code, control=back, pos=(g.read('wXCoord'), g.read('wYCoord')),
                         scene=g.read('wTinTower1FSceneID'), wScriptRunning=g.read('wScriptRunning'))
        if code != value(want):
            problems.append(('unexpected result', case, code))
        if not back:
            problems.append(('softlock after refusal', case, out[case]))
            if g.shots:
                g.render(True)
                g.frames(2)
                g.screenshot('%s/scenes.deity_suicune_%s.png' % (g.shots, case))
                g.render(False)
    check(move_idx in party_moves(g, TEACHER), 'Life Dew not learned')
    check(event(g, 'EVENT_FOUGHT_SUICUNE'), 'FOUGHT_SUICUNE not set')
    check(g.read('wTinTower1FSceneID') == 1, 'scene not cleared', scene=g.read('wTinTower1FSceneID'))
    check(not event(g, 'EVENT_SET_WHEN_FOUGHT_HO_OH'), 'Eusine not released to Celadon')
    warp(g, 'TIN_TOWER_1F', 9, 15)
    check(event(g, 'EVENT_TIN_TOWER_1F_SUICUNE'), 'Suicune back after re-entry')
    check(not problems, 'refusal paths broken', problems=problems)
    return out


@_deity_tutor_test
def deity_suicune_retry(g):
    """After refusing Suicune the cutscene stays off (also on re-entry); talking to it teaches."""
    _free_last_move(g, TEACHER, 'LIFE_DEW')
    _enter_tin_tower_1f(g)
    check(wait_for(g, 'YesNoBox', max_presses=400), 'Suicune never asked')
    answer(g, False)
    check(finish(g, max_presses=300), 'control never returned after refusal')
    pos = (g.read('wXCoord'), g.read('wYCoord'))
    check(g.read('wTinTower1FSceneID') == 1, 'scene still on after refusal', scene=g.read('wTinTower1FSceneID'))
    after_refusal = g.state()
    # re-entry: no cutscene, Suicune still there
    warp(g, 'TIN_TOWER_1F', 9, 15)
    check(in_control(g, 120), 'cutscene ran again on re-entry')
    check(not event(g, 'EVENT_TIN_TOWER_1F_SUICUNE'), 'Suicune gone after refusal')
    # talk to it from where the refusal left us
    g.load(after_refusal)
    interact(g, 'up')
    check(wait_for(g, 'YesNoBox', max_presses=400), 'talking to Suicune did not ask', pos=pos)
    answer(g, True)
    check(wait_for(g, 'PartyMenuSelect'), 'party menu never opened')
    pick_party(g, TEACHER)
    check(finish(g, max_presses=600), 'control never returned after teaching')
    check(value('LIFE_DEW') in party_moves(g, TEACHER), 'Life Dew not learned on retry')
    check(event(g, 'EVENT_FOUGHT_SUICUNE'), 'FOUGHT_SUICUNE not set on retry')
    return dict(pos_after_refusal=pos)


@_deity_tutor_test
def deity_celebi(g):
    """Celebi: a refusal hands the GS Ball back; success takes it and Kurt comes to look."""
    move_idx = value('FAE_BLADE')
    _free_last_move(g, TEACHER, 'FAE_BLADE')

    def setup(g):
        set_event(g, 'EVENT_FOREST_IS_RESTLESS')
        set_key_item(g, 'GS_BALL')

    codes = {}
    kurt_seen = False
    for case, slot, want in [('unhappy', UNHAPPY, 'DEITYTUTOR_NOT_HAPPY'), ('taught', TEACHER, 'DEITYTUTOR_TAUGHT')]:
        warp(g, 'ILEX_FOREST', 8, 23, before=setup if case == 'unhappy' else None)
        interact(g, 'up')
        check(wait_for(g, 'YesNoBox'), 'shrine never asked', case=case)
        answer(g, True)
        check(wait_for(g, 'YesNoBox', max_presses=400), 'Celebi never asked', case=case)
        answer(g, True)
        check(wait_for(g, 'PartyMenuSelect'), 'party menu never opened', case=case)
        pick_party(g, slot)
        for _ in range(600):
            if in_control(g, 6):
                break
            kurt_seen |= not event(g, 'EVENT_ILEX_FOREST_KURT')
            g.press('b', hold=3, after=3)
        codes[case] = g.read('wScriptVar')  # the Kurt scene overwrites it after a success
        if case == 'unhappy':
            check(codes[case] == value(want), 'unexpected result', case=case, got=codes[case])
            check(has_key_item(g, 'GS_BALL'), 'GS Ball lost on refusal')
            check(event(g, 'EVENT_FOREST_IS_RESTLESS'), 'forest calmed on refusal')
            check(not kurt_seen, 'Kurt came after a refusal')
    check(move_idx in party_moves(g, TEACHER), 'Fae Blade not learned')
    check(not has_key_item(g, 'GS_BALL'), 'GS Ball kept after success')
    check(kurt_seen, 'Kurt never appeared')
    check(event(g, 'EVENT_AZALEA_TOWN_KURT') and not event(g, 'EVENT_FOREST_IS_RESTLESS'), 'flags after success')
    return codes


def _gate(g, name, flag, on):
    m, x, y, facing, hide, _, extra = DEITIES[name]

    def before(g):
        if extra:
            extra(g)
        set_event(g, flag, on)
    warp(g, m, x, y, before=before, surf=(name == 'LUGIA'))
    return event(g, hide), _no_script(g, facing)


@test('scenes')
def deity_story_gates(g):
    """Raikou/Entei need the Elite Four; Mew needs the rematch."""
    base = g.state()
    out = {}
    for name, flag in [('RAIKOU', 'EVENT_BEAT_ELITE_FOUR'), ('ENTEI', 'EVENT_BEAT_ELITE_FOUR'),
                       ('MEW', 'EVENT_BEAT_ELITE_FOUR_REMATCH')]:
        for on in (False, True):
            g.load(base)
            hidden, silent = _gate(g, name, flag, on)
            out['%s_%d' % (name, on)] = dict(hidden=hidden, silent=silent)
            check(hidden == (not on) and silent == (not on), 'gate wrong', deity=name, flag=flag, on=on,
                  hidden=hidden, silent=silent)
    return out


# --- Rainbow Wing chain ---
def _beasts(g, n):
    for i, b in enumerate(['SUICUNE', 'RAIKOU', 'ENTEI']):
        set_event(g, 'EVENT_FOUGHT_' + b, i < n)


@test('scenes')
def rainbow_wing_needs_three_beasts(g):
    """Tin Tower Sage5 (Rainbow Wing) and Eusine's Ho-Oh rumor appear only once all three beasts taught."""
    base = g.state()
    out = {}
    for n in (2, 3):
        g.load(base)

        def setup(g):
            _beasts(g, n)
            g.write('wTinTower1FSceneID', 1)
            set_event(g, 'EVENT_GOT_RAINBOW_WING', False)
            set_key_item(g, 'RAINBOW_WING', False)
        warp(g, 'TIN_TOWER_1F', 9, 2, before=setup)
        sage_hidden = event(g, 'EVENT_TIN_TOWER_1F_WISE_TRIO_2')
        silent = _no_script(g, 'up')
        out['sage_%d' % n] = dict(hidden=sage_hidden, wing=has_key_item(g, 'RAINBOW_WING'))
        if n == 2:
            check(sage_hidden and silent, 'Sage5 present with 2 beasts', **out['sage_2'])
        else:
            check(not sage_hidden, 'Sage5 hidden with 3 beasts')
            check(has_key_item(g, 'RAINBOW_WING') and event(g, 'EVENT_GOT_RAINBOW_WING'), 'no Rainbow Wing')

        g.load(base)

        def setup2(g):
            _beasts(g, n)
            set_event(g, 'EVENT_SET_WHEN_FOUGHT_HO_OH', False)
        warp(g, 'CELADON_POKECENTER_1F', 4, 4, before=setup2)
        interact(g, 'up')
        check(finish(g), 'Eusine talk never ended', beasts=n)
        gone = event(g, 'EVENT_SET_WHEN_FOUGHT_HO_OH')
        out['eusine_%d' % n] = dict(left=gone)
        check(gone == (n == 3), 'Eusine leave state wrong', beasts=n, left=gone)
    return out


# --- Mewtwo ---
@test('scenes')
def mewtwo_battle_and_flag(g):
    """Mewtwo in the Mansion starts a real battle; once fought it never returns."""
    warp(g, 'POKEMON_MANSION', 4, 12, before=lambda g: set_event(g, 'EVENT_FOUGHT_MEWTWO', False))
    check(not event(g, 'EVENT_TOHJO_FALLS_MEWTWO'), 'Mewtwo hidden with all badges')
    base = g.state()
    interact(g, 'down')
    check(wait_for(g, 'StartBattle', max_presses=60), 'no battle started')
    check(event(g, 'EVENT_FOUGHT_MEWTWO'), 'FOUGHT_MEWTWO not set before battle')
    g.frames(240)
    mode = g.read('wBattleMode')
    check(mode == 1, 'not a wild battle', wBattleMode=mode)
    check(g.read('wEnemyMonSpecies') == g.read('wPartySpecies'), 'enemy is not Mewtwo',  # slot 0 is Mewtwo
          enemy=g.read('wEnemyMonSpecies'))
    g.load(base)
    warp(g, 'POKEMON_MANSION', 4, 12, before=lambda g: set_event(g, 'EVENT_FOUGHT_MEWTWO'))
    check(event(g, 'EVENT_TOHJO_FALLS_MEWTWO'), 'Mewtwo back after being fought')
    check(_no_script(g, 'down'), 'Mewtwo still talks after being fought')
    return dict(wBattleMode=mode)


# --- Silver Cave coach ---
def _coach(g, slot=None, confirm=True):
    """Talk to the coach. slot=None: only the opening yes/no is expected."""
    interact(g, 'up')
    if not wait_for(g, 'YesNoBox', max_presses=80):
        finish(g)
        return 'no_offer'
    answer(g, True)
    if slot is None:
        finish(g)
        return g.read('wScriptVar')
    check(wait_for(g, 'PartyMenuSelect'), 'coach party menu never opened')
    pick_party(g, slot)
    if g.read('wScriptVar') == value('PERFECTMON_OK') or wait_for(g, 'YesNoBox', max_presses=15):
        answer(g, confirm)
    finish(g)
    return g.read('wScriptVar')


@test('scenes')
def coach_through_inputs(g):
    """Coach: needs a STAR PIECE, refuses eggs/Unown/perfect mons free, then once a day."""
    out = {}
    set_engine(g, 'ENGINE_PERFECT_MON_COACH', False)
    set_item(g, 'STAR_PIECE', 0)
    g.write('wPartySpecies+4', value('EGG') & 0xff)
    unown = species_id(g, 'UNOWN')
    g.write('wPartySpecies+5', unown)
    mon_write(g, 5, 'MON_SPECIES', unown)
    warp(g, 'SILVER_CAVE_POKECENTER_1F', 7, 3)

    out['no_fee'] = _coach(g, None)
    check(item_qty(g, 'STAR_PIECE') == 0 and not engine(g, 'ENGINE_PERFECT_MON_COACH'), 'no-fee path changed state')

    set_item(g, 'STAR_PIECE', 2)
    dvs = mon_read(g, 1, 'MON_DVS', 2)
    for case, slot, want in [('egg', 4, 'PERFECTMON_EGG'), ('unown', 5, 'PERFECTMON_UNOWN')]:
        out[case] = _coach(g, slot)
        check(out[case] == value(want), 'wrong refusal', case=case, got=out[case])
        check(item_qty(g, 'STAR_PIECE') == 2, 'fee taken on refusal', case=case)
    out['decline'] = _coach(g, 1, confirm=False)
    check(item_qty(g, 'STAR_PIECE') == 2 and mon_read(g, 1, 'MON_DVS', 2) == dvs, 'decline changed state')

    out['ok'] = _coach(g, 1)
    check(item_qty(g, 'STAR_PIECE') == 1, 'fee not taken once', left=item_qty(g, 'STAR_PIECE'))
    check(engine(g, 'ENGINE_PERFECT_MON_COACH'), 'daily flag not set')
    check(mon_read(g, 1, 'MON_EVS', 6) == [252] * 6, 'EVs not maxed')

    out['same_day'] = _coach(g, 1)
    check(out['same_day'] == 'no_offer' and item_qty(g, 'STAR_PIECE') == 1, 'second try same day not refused')

    set_engine(g, 'ENGINE_PERFECT_MON_COACH', False)
    out['already'] = _coach(g, 1)
    check(out['already'] == value('PERFECTMON_ALREADY'), 'perfect mon not refused', got=out['already'])
    check(item_qty(g, 'STAR_PIECE') == 1, 'fee taken for a perfect mon')
    out['dvs_after'] = '%02X%02X' % tuple(mon_read(g, 1, 'MON_DVS', 2))
    return out


# --- gifts ---
def _gift_flow(g, nickname_prompt=True):
    """After the gift's own yes: decline the nickname and let the script end."""
    if nickname_prompt:
        check(wait_for(g, 'YesNoBox', max_presses=60), 'nickname prompt never came')
        answer(g, False)


@test('scenes')
def sage_kangaskhan_needs_220(g):
    """Fuchsia sage gives Kangaskhan (L60, happiness 220) only when the lead's happiness is >= 220."""
    base = g.state()
    out = {}
    for h in (219, 220):
        g.load(base)
        _set_party_count(g, 5)
        set_happiness(g, 0, h)
        warp(g, 'FUCHSIA_POKEMON_GIVER', 2, 4)
        interact(g, 'up')
        offered = wait_for(g, 'YesNoBox', max_presses=400)
        if offered:
            answer(g, True)
            _gift_flow(g)
        finish(g)
        n = g.read('wPartyCount')
        out[h] = dict(offered=offered, party=n)
        if h < 220:
            check(not offered and n == 5 and not event(g, 'EVENT_GOT_KANGASKHAN_FROM_SAGE'), 'gave below 220', **out[h])
            continue
        check(offered and n == 6, 'no Kangaskhan at 220', **out[h])
        out[h].update(species=hex(species_index(g, 5)), level=mon_read(g, 5, 'MON_LEVEL')[0],
                      happiness=mon_read(g, 5, 'MON_HAPPINESS')[0])
        check(species_index(g, 5) == value('KANGASKHAN'), 'not Kangaskhan', **out[h])
        check(out[h]['level'] == 60 and out[h]['happiness'] == 220, 'wrong level/happiness', **out[h])
    return out


@test('scenes')
def larvitar_prize_level_25(g):
    """Game Corner Larvitar costs 8888 coins and arrives at level 25."""
    _set_party_count(g, 5)
    set_key_item(g, 'COIN_CASE')
    warp(g, 'CELADON_GAME_CORNER_PRIZE_ROOM', 4, 2, before=lambda g: g.write('wCoins', [0x27, 0x0f]))
    interact(g, 'up')
    check(wait_for(g, 'VerticalMenu'), 'prize menu never opened')
    g.frames(10)
    g.press('down', hold=4, after=8)
    g.press('down', hold=4, after=8)
    g.press('a', hold=4, after=10)
    check(wait_for(g, 'YesNoBox'), 'no purchase prompt')
    answer(g, True)
    _gift_flow(g)
    check(wait_for(g, 'VerticalMenu', max_presses=60), 'menu did not return')
    g.frames(10)
    g.press('b', hold=4, after=10)
    check(finish(g), 'control never returned')
    coins = g.read16('wCoins')
    lvl = mon_read(g, 5, 'MON_LEVEL')[0]
    sp = species_index(g, 5) if g.read('wPartyCount') == 6 else None
    out = dict(coins=coins, level=lvl, species=sp and hex(sp))
    check(sp == value('LARVITAR'), 'no Larvitar', **out)
    check(lvl == 25, 'wrong level', **out)
    check(coins == 9999 - 8888, 'wrong price', **out)
    return out


# --- NPC trade, Mystery Gift house, Battle Tower (all touched by the branch-11 link removal) ---
def _bag_total(g):
    """Sum of quantities in the item, ball and berry pockets."""
    total = 0
    # the item pocket stores a 16-bit item index per entry; balls and berries an 8-bit ID
    for count, items, size in (('wNumItems', 'wItems', 3), ('wNumBalls', 'wBalls', 2), ('wNumBerries', 'wBerries', 2)):
        n = g.read(count)
        data = g.read(items, size * n)
        total += sum(data[size - 1::size])
    return total


def _main_menu_has_continue(g):
    """Write the battery out, boot a fresh console from it and read the main menu."""
    import tempfile, os
    from suite_save import boot_to_main_menu
    from visual import text_rows
    with tempfile.TemporaryDirectory() as d:
        path = os.path.join(d, 'save.sav')
        g.save_battery(path)
        g2 = boot_to_main_menu(path, render=False)
        try:
            return any('CONTINUE' in r for r in text_rows(g2))
        finally:
            g2.close()


@test('scenes')
def npc_trade_tim(g):
    """Tim trades his Voltorb for a Krabby: species, OT ID, item and trade flag; a second talk won't trade."""
    from battle import set_party_mon
    set_party_mon(g, 1, species='KRABBY', level=20, moves=['BUBBLE'])
    tim = value('NPC_TRADE_TIM')
    warp(g, 'OLIVINE_TIMS_HOUSE', 2, 4)
    interact(g, 'up')
    check(wait_for(g, 'YesNoBox', max_presses=100), 'Tim never offered')
    answer(g, True)
    check(wait_for(g, 'PartyMenuSelect'), 'party menu never opened')
    pick_party(g, 1)
    check(finish(g, max_presses=600), 'control never returned after the trade')
    # like vanilla, the given mon is removed and the new one is added at the end
    n = g.read('wPartyCount')
    last = n - 1
    got = dict(species=hex(species_index(g, last)), ot_id=mon_word(g, last, 'MON_OT_ID'),
               item=mon_read(g, last, 'MON_ITEM')[0], flag=bool(g.read('wTradeFlags') & (1 << tim)),
               party=n, krabby_left=any(species_index(g, i) == value('KRABBY') for i in range(n)))
    check(n == 6 and not got['krabby_left'], 'party size changed or Krabby still there', **got)
    check(species_index(g, last) == value('VOLTORB'), 'did not receive Voltorb', **got)
    check(got['ot_id'] == 29189, 'wrong OT ID', **got)
    check(got['item'] == g.call('GetItemIDFromIndex', hl=value('PRZCUREBERRY'))['a'], 'wrong held item', **got)
    check(got['flag'], 'trade flag not set', **got)
    interact(g, 'up')
    check(not wait_for(g, 'PartyMenuSelect', max_presses=60), 'Tim offered a second trade')
    finish(g)
    check(species_index(g, last) == value('VOLTORB') and g.read('wPartyCount') == n, 'second talk changed the party')
    return got


def _gift_house(g, save_yes):
    """Talk to Carrie and say YES to everything except the save prompt when save_yes is False."""
    from visual import text_rows
    set_engine(g, 'ENGINE_DAILY_MYSTERY_GIFT', False)
    warp(g, 'VERMILION_MYSTERY_GIFT_HOUSE', 5, 5)
    interact(g, 'up')
    asked_save = False
    for _ in range(3):
        if not wait_for(g, 'YesNoBox', max_presses=100):
            break
        g.frames(10)
        is_save = any('game before' in r for r in text_rows(g))  # "You need to save" has scrolled off
        asked_save |= is_save
        answer(g, save_yes or not is_save)
        if is_save:
            break
    check(asked_save, 'Carrie never asked to save')
    saved = save_yes and wait_for(g, 'SavedTheGame', max_presses=100)
    check(finish(g, max_presses=600), 'control never returned')
    return saved


@test('scenes')
def mystery_gift_house(g):
    """Carrie: saying NO to the save gives nothing and keeps the daily flag clear; YES saves the game
    (a fresh boot offers CONTINUE) and gives three items; a second talk the same day gives nothing."""
    base = g.state()
    out = {}
    before = _bag_total(g)
    _gift_house(g, save_yes=False)
    out['declined'] = dict(bag=_bag_total(g) - before, flag=engine(g, 'ENGINE_DAILY_MYSTERY_GIFT'))
    check(out['declined'] == dict(bag=0, flag=False), 'declining the save still gave or flagged', **out)
    g.load(base)
    check(not _main_menu_has_continue(g), 'fixture already has a save; the save check would prove nothing')
    saved = _gift_house(g, save_yes=True)
    out['saved'] = dict(bag=_bag_total(g) - before, flag=engine(g, 'ENGINE_DAILY_MYSTERY_GIFT'),
                        saved=saved, continue_offered=_main_menu_has_continue(g))
    check(out['saved'] == dict(bag=3, flag=True, saved=True, continue_offered=True), 'gift with save went wrong', **out)
    interact(g, 'up')
    check(not wait_for(g, 'YesNoBox', max_presses=60), 'Carrie offered a second gift the same day')
    finish(g)
    check(_bag_total(g) - before == 3, 'second talk changed the bag')
    return out


def _tower_talk(g):
    """Talk to the receptionist through to the Challenge/Explanation/Cancel menu and pick Challenge."""
    interact(g, 'up')
    for _ in range(2):  # first visit: "hear about the Battle Tower?" NO
        hit = None
        for _ in range(100):
            hit = g.run_until_any(['Menu_ChallengeExplanationCancel.Load_Interpret', 'YesNoBox'], 20)
            if hit:
                break
            g.press('b', hold=3, after=0)
        check(hit, 'receptionist never reached the menu')
        if hit != 'YesNoBox':
            break
        answer(g, False)
    g.frames(20)
    g.press('a', hold=4, after=10)


@test('scenes')
def battle_tower_entry(g):
    """A 6-mon party is turned away; a valid 3-mon party is asked to save, the save happens
    (a fresh boot offers CONTINUE), the scene is back to NOOP and the level menu opens."""
    base = g.state()
    warp(g, 'BATTLE_TOWER_1F', 7, 7)
    _tower_talk(g)
    check(not wait_for(g, 'YesNoBox', max_presses=80), '6-mon party was asked to save')
    check(finish(g), 'control never returned after the refusal')
    g.load(base)
    _set_party_count(g, 3)
    for slot in range(3):
        mon_write(g, slot, 'MON_ITEM', 0)
    warp(g, 'BATTLE_TOWER_1F', 7, 7)
    _tower_talk(g)
    check(wait_for(g, 'YesNoBox', max_presses=80), 'valid party was never asked to save')
    answer(g, True)
    check(wait_for(g, 'SavedTheGame', max_presses=100), 'the game was not saved')
    check(wait_for(g, 'BattleTowerRoomMenu', max_presses=200), 'level menu never opened')
    out = dict(scene=g.read('wBattleTower1FSceneID'), continue_offered=_main_menu_has_continue(g))
    check(out['scene'] == 1, 'scene not back to NOOP', **out)  # map-local: CHECKSTATE 0, NOOP 1
    check(out['continue_offered'], 'no save on the battery', **out)
    return out


# --- Battle Tower challenge (past the level menu) ---
def _tower_to_level_menu(g):
    """Valid 3-mon L100 party, through the receptionist and the save, to the level menu."""
    _set_party_count(g, 3)
    for slot in range(3):
        mon_write(g, slot, 'MON_ITEM', 0)
    warp(g, 'BATTLE_TOWER_1F', 7, 7)
    _tower_talk(g)
    check(wait_for(g, 'YesNoBox', max_presses=80), 'valid party was never asked to save')
    answer(g, True)
    check(wait_for(g, 'BattleTowerRoomMenu', max_presses=200), 'level menu never opened')


def _pick_level(g, level):
    """The level box steps 10, 20, ... 100, CANCEL with UP; A confirms."""
    from visual import text_rows
    want = 'L·%d' % level

    def shown():
        return [r for r in text_rows(g)[:12] if 'L·' in r or 'CANCEL' in r]  # box sits mid-screen
    for _ in range(60):
        if shown():
            break
        g.frames(20)
    check(shown(), 'level box never appeared', screen=text_rows(g)[:12])
    for _ in range(12):
        if any(want + '|' in r or want + ' ' in r for r in shown()):
            break
        g.press('up', hold=4, after=30)
    check(any(want in r for r in shown()), 'level box never showed the level', level=level, box=shown())
    g.press('a', hold=4, after=20)


def _ot_party(g):
    """Opponent's party as (species index, level, hp, maxhp, first move index)."""
    n = g.read('wOTPartyCount')
    size = value('PARTYMON_STRUCT_LENGTH')
    out = []
    for i in range(n):
        base = 'wOTPartyMon1+%d' % (i * size)
        sp = g.read('%s' % base)
        lvl = g.read('wOTPartyMon1+%d' % (i * size + value('MON_LEVEL')))
        hp = g.read16('wOTPartyMon1+%d' % (i * size + value('MON_HP')))
        mhp = g.read16('wOTPartyMon1+%d' % (i * size + value('MON_MAXHP')))
        mv = g.read('wOTPartyMon1+%d' % (i * size + value('MON_MOVES')))
        out.append((g.call('GetPokemonIndexFromID', a=sp)['hl'], lvl, hp, mhp,
                    g.call('GetMoveIndexFromID', a=mv)['hl'] if mv else 0))
    return out


def _tower_battle(g, win):
    """From the room script to the end of one Battle Tower battle. Mashes A (FIGHT, first move). At every
    battle menu: win sets the foe's HP to 1 and refills ours (a miss can't let us faint); lose sets our
    HP to 1 and the foe's high, with the other two party mons fainted so one KO ends it.
    Returns the opponent's party as loaded."""
    from battle import fast_options
    check(wait_for(g, 'BattleTowerBattle', max_presses=300), 'Battle Tower battle never started')
    fast_options(g)
    party = None
    strength = None
    for _ in range(3000):
        hit = g.run_until_any(['LoadBattleMenu', 'CleanUpBattleRAM', 'PartyMenuSelect'], 20)
        if hit == 'CleanUpBattleRAM':
            return party
        if hit == 'PartyMenuSelect':  # our mon fainted: send in the first one still standing
            alive = [i for i in range(g.read('wPartyCount')) if mon_word(g, i, 'MON_HP')]
            check(alive, 'switch menu with no mon left')
            g.frames(20)
            g.write('wMenuCursorY', alive[0] + 1)
            g.press('a', hold=4, after=20)
            continue
        if hit == 'LoadBattleMenu':
            if party is None:
                party = _ot_party(g)
                if not win:  # after the battle start, which restores the party
                    for slot in (1, 2):
                        mon_write(g, slot, 'MON_HP', [0, 0])
            if win:
                g.write('wEnemyMonHP', [0, 1])
                g.write('wEnemyMonType', [0, 0])  # NORMAL: a random Ghost foe can't wall our first move
                g.write('wBattleMonHP', g.read('wBattleMonMaxHP', 2))
                # A only repeats the cursor's move: make it a damaging one with PP (a status move
                # used to run dry by the 5th opponent on some ROM layouts)
                if strength is None:
                    strength = g.call('GetMoveIDFromIndex', hl=value('STRENGTH'))['a']
                g.write('wBattleMonMoves', strength)
                g.write('wBattleMonPP', 30)
                g.write('wCurMoveNum', 0)
            else:
                g.write('wBattleMonHP', [0, 1])
                g.write('wEnemyMonHP', [0x27, 0x0f])
                g.write('wEnemyMonMaxHP', [0x27, 0x0f])
        g.press('a', hold=3, after=0)
    raise AssertionError('Battle Tower battle never ended')


def _check_opponent(party, level, k):
    check(len(party) == 3, 'opponent party size', opponent=k, party=party)
    for sp, lvl, hp, mhp, mv in party:
        ok = 0 < sp <= value('NUM_POKEMON') and lvl == level and 0 < hp == mhp and 0 < mv <= value('NUM_ATTACKS')
        check(ok, 'bad opponent mon', opponent=k, mon=(hex(sp), lvl, hp, mhp, hex(mv)))


@test('scenes')
def battle_tower_full_streak(g):
    """L100 challenge: seven opponents load valid L100 parties and are beaten; the room heals and asks to
    continue between battles; the player ends on 1F with the five-item prize and control."""
    _tower_to_level_menu(g)
    _pick_level(g, 100)
    before = _bag_total(g)
    seen = []
    for k in range(value('BATTLETOWER_STREAK_LENGTH')):
        party = _tower_battle(g, win=True)
        check(party, 'opponent party never read', opponent=k)
        _check_opponent(party, 100, k)
        seen.append([hex(p[0]) for p in party])
        check(g.read('wBattleResult') & 3 == 0, 'battle not won', opponent=k, result=g.read('wBattleResult'))
        if k < value('BATTLETOWER_STREAK_LENGTH') - 1:
            check(wait_for(g, 'YesNoBox', max_presses=300), '"next opponent?" never asked', opponent=k)
            answer(g, True)
    check(finish(g, max_presses=600), 'control never returned after the streak')
    v = resolve('GROUP_BATTLE_TOWER_1F', 'MAP_BATTLE_TOWER_1F')
    at = (g.read('wMapGroup'), g.read('wMapNumber'))
    check(at == (v['GROUP_BATTLE_TOWER_1F'], v['MAP_BATTLE_TOWER_1F']), 'not back on 1F', at=at)
    check(_bag_total(g) - before == 5, 'prize not given', bag=_bag_total(g) - before)
    return dict(opponents=seen, prize=_bag_total(g) - before)


@test('scenes')
def battle_tower_loss_returns_to_lobby(g):
    """Win one, continue, lose the next: the player is sent back to 1F with control and no prize."""
    _tower_to_level_menu(g)
    _pick_level(g, 100)
    before = _bag_total(g)
    _tower_battle(g, win=True)
    check(wait_for(g, 'YesNoBox', max_presses=300), '"next opponent?" never asked')
    answer(g, True)
    party = _tower_battle(g, win=False)
    _check_opponent(party, 100, 1)
    check(g.read('wBattleResult') & 3 == 1, 'battle not lost', result=g.read('wBattleResult'))
    check(finish(g, max_presses=600), 'control never returned after the loss')
    v = resolve('GROUP_BATTLE_TOWER_1F', 'MAP_BATTLE_TOWER_1F')
    at = (g.read('wMapGroup'), g.read('wMapNumber'))
    check(at == (v['GROUP_BATTLE_TOWER_1F'], v['MAP_BATTLE_TOWER_1F']), 'not back on 1F', at=at)
    check(_bag_total(g) == before, 'items changed after a loss')
    return dict(at=at)


def _fill_item_pocket(g):
    """MAX_ITEMS distinct non-stat items, 1 each, so the reward can neither stack nor fit."""
    stats = {value(n) for n in ('HP_UP', 'PROTEIN', 'IRON', 'CARBOS')}
    idx = [i for i in range(1, 80) if i not in stats][:value('MAX_ITEMS')]
    data = []
    for i in idx:
        data += [i >> 8, i & 0xff, 1]
    g.write('wNumItems', len(idx))
    g.write('wItems', data + [0xff])


@test('scenes')
def battle_tower_prize_with_full_pack(g):
    """Seven wins with a full item pocket: "pack is stuffed full", nothing given; after freeing a slot the
    receptionist hands over the five-item prize."""
    _fill_item_pocket(g)
    filled = _bag_total(g)
    _tower_to_level_menu(g)
    _pick_level(g, 100)
    for k in range(value('BATTLETOWER_STREAK_LENGTH')):
        _tower_battle(g, win=True)
        check(g.read('wBattleResult') & 3 == 0, 'battle not won', opponent=k)
        if k < value('BATTLETOWER_STREAK_LENGTH') - 1:
            check(wait_for(g, 'YesNoBox', max_presses=300), '"next opponent?" never asked', opponent=k)
            answer(g, True)
    check(finish(g, max_presses=600), 'control never returned with a full pack')
    full = dict(items=g.read('wNumItems'), bag=_bag_total(g), bag_before=filled)
    check(full['items'] == value('MAX_ITEMS') and full['bag'] == filled, 'bag changed with a full pack', **full)
    # free one slot: drop the last entry
    n = g.read('wNumItems')
    g.write('wNumItems', n - 1)
    g.write('wItems+%d' % (3 * (n - 1)), 0xff)
    before = _bag_total(g)
    interact(g, 'up')
    check(finish(g, max_presses=600), 'control never returned after the second talk')
    got = _bag_total(g) - before
    check(got == 5, 'prize not given after freeing a slot', got=got)
    return dict(full_pack=full, prize_after_freeing=got)

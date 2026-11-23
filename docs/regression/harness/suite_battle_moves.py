"""Legendary signature moves (branch 39) in real wild battles, plus the Metronome/Sketch exclusions.

Default setup: debug Mewtwo L100 leads (held item removed) against a wild L5 Sentret with 999 HP,
speed 1, using Splash. Chance effects are measured by replaying one saved state with varied input
timing; rates are checked within 4 sigma of the expected value."""
import math
import random

from battle import Battle, move_id, move_name
from consts import resolve, value
from game import mon_read, mon_write
from registry import check, test

C = None
SIGNATURE = ['SHEER_COLD', 'INNER_LIGHT', 'SKY_ATTACK', 'ERUPTION', 'STORM_CALL',
             'LIFE_DEW', 'AEROBLAST', 'SACRED_FIRE', 'AURA_SPHERE', 'FAE_BLADE']
WEATHER = {'none': 0, 'rain': 1, 'sun': 2, 'sand': 3, 'hail': 4}
CHANCE_50 = 50 * 0xff // 100 / 256  # `50 percent` effect chance, rolled against BattleRandom


def k():
    global C
    if C is None:
        C = resolve('PSN', 'BRN', 'FRZ', 'PAR', 'SLP_MASK', 'MAX_STAT_LEVEL', 'SUBSTATUS_CHARGED',
                    'SUBSTATUS_FLYING', 'SUBSTATUS_UNDERGROUND', 'SUBSTATUS_FLINCHED', 'SUBSTATUS_CONFUSED')
    return C


def battle(g, moves, **kw):
    opts = dict(enemy='SENTRET', enemy_level=5, moves=moves, enemy_moves=['SPLASH'], enemy_hp=999, enemy_speed=1)
    opts.update(kw)
    b = Battle(g, **opts)
    # tank the foe so a 140-power hit plus burn/sandstorm chip can't end the battle mid-measurement
    g.write('wEnemyMonStats+2', [0x03, 0xe7])
    g.write('wEnemyMonStats+8', [0x03, 0xe7])
    # a crit reads the unboosted copies instead
    g.write('wEnemyDefense', [0x03, 0xe7])
    g.write('wEnemySpDef', [0x03, 0xe7])
    return b


def trials(g, b, n, fn, slot=0, stop='LoadBattleMenu'):
    """Replay the state saved now (at the battle menu) n times with varied timing; fn(b) -> key."""
    start = g.state()
    counts = {}
    rng = random.Random(n)
    for i in range(n):
        g.load(start)
        b.choose_move(slot, i % 17, (i // 17) % 13)
        # frame delays alone leave the RNG state clumped; seed it uniformly per trial
        g.write('hRandomAdd', rng.randrange(256))
        g.write('hRandomSub', rng.randrange(256))
        b.turns += 1
        check(b.advance(stop, 3000), 'battle ended mid-trial', trial=i)
        key = fn(b)
        counts[key] = counts.get(key, 0) + 1
    g.load(start)
    return counts


def near(rate, p, n, what, **detail):
    sd = math.sqrt(p * (1 - p) / n)
    check(abs(rate - p) <= 4 * sd, what, expected=round(p, 4), observed=round(rate, 4), n=n, **detail)


# --- smoke ---
@test('battle_moves')
def smoke_damage(g):
    """The driver works: Scratch through the real menus damages the enemy, and we move first."""
    b = battle(g, ['SCRATCH'])
    check(b.turn(0), 'turn did not return to the battle menu')
    hp = b.hp('enemy')
    check(hp < 999, 'Scratch dealt no damage', enemy_hp=hp)
    check(b.player_first(), 'speed-1 enemy moved first')
    return {'damage': 999 - hp}


# --- SHEER_COLD ---
@test('battle_moves')
def sheer_cold(g):
    """OHKO with hail on a hit; a higher-level target makes it fail and no hail starts."""
    b = battle(g, ['SHEER_COLD'], enemy_level=50)
    s = g.state()
    check(b.turn(0, stop='HandleEnemyMonFaint'), 'L50 target did not faint')
    hit = dict(hp=b.hp('enemy'), weather=b.weather())
    check(hit['hp'] == 0, 'not a OHKO', **hit)
    check(hit['weather'] == (WEATHER['hail'], 5), 'no 5-turn hail after the KO', **hit)
    g.load(s)
    b.set_player(level=10)
    check(b.turn(0), 'battle ended on a failed OHKO')
    miss = dict(hp=b.hp('enemy'), weather=b.weather())
    check(miss['hp'] == 999, 'OHKO hit a higher-level target', **miss)
    check(miss['weather'][0] == 0, 'hail started on a failed OHKO', **miss)
    return {'hit': hit, 'miss': miss}


# --- INNER_LIGHT ---
@test('battle_moves')
def inner_light(g):
    """All seven stages to +6 (even from a partial start); fails once everything is maxed."""
    mx = k()['MAX_STAT_LEVEL']
    b = battle(g, ['INNER_LIGHT'])
    g.write('wPlayerStatLevels', [mx, 7, 7, 5, 7, 7, 7])
    spd0 = g.read16('wBattleMonStats+4')
    check(b.turn(0), 'turn 1 did not finish')
    st, spd1 = b.stages('player'), g.read16('wBattleMonStats+4')
    check(st == [mx] * 7, 'not all stages maxed', stages=st)
    check(spd1 > spd0, 'stats not recalculated', speed_before=spd0, speed_after=spd1)
    failed = b.turn(0, stop='BattleEffect_ButItFailed')
    check(failed, 'second use at +6 did not fail')
    b.advance('LoadBattleMenu')
    check(b.stages('player') == [mx] * 7, 'stages changed on the failed use', stages=b.stages('player'))
    return {'stages': st, 'speed': [spd0, spd1]}


# --- SKY_ATTACK ---
@test('battle_moves')
def sky_attack(g):
    """Hits on the turn it is used (no charge) and drops accuracy by two."""
    b = battle(g, ['SKY_ATTACK'])
    check(b.turn(0), 'turn did not finish')
    out = dict(hp=b.hp('enemy'), enemy_stages=b.stages('enemy'), sub3=b.substatus('player')[2])
    check(out['hp'] < 999, 'no damage on turn 1 (charging?)', **out)
    check(not out['sub3'] & 1 << k()['SUBSTATUS_CHARGED'], 'charge substatus set', **out)
    check(out['enemy_stages'][5] == 5, 'enemy accuracy not -2', **out)
    return out


# --- weather hitters ---
def _weather_hit(g, over, move, target):
    g.load(over)
    b = battle(g, [move], enemy=target)
    check(b.turn(0), 'turn did not finish', move=move, target=target)
    return dict(target=target, hp=b.hp('enemy'), weather=b.weather())


@test('battle_moves')
def eruption(g):
    """Sandstorm on a hit (count 5, 4 after the end-of-turn tick); none against an immune Flying target."""
    over = g.state()
    hit = _weather_hit(g, over, 'ERUPTION', 'SENTRET')
    check(hit['hp'] < 999 and hit['weather'] == (WEATHER['sand'], 4), 'no sandstorm after the hit', **hit)
    imm = _weather_hit(g, over, 'ERUPTION', 'PIDGEY')
    check(imm['hp'] == 999 and imm['weather'][0] == 0, 'weather/damage against a Flying target', **imm)
    return {'hit': hit, 'immune': imm}


@test('battle_moves')
def storm_call(g):
    """Rain on a hit; none against an immune Ground target."""
    over = g.state()
    hit = _weather_hit(g, over, 'STORM_CALL', 'SENTRET')
    check(hit['hp'] < 999 and hit['weather'] == (WEATHER['rain'], 4), 'no rain after the hit', **hit)
    imm = _weather_hit(g, over, 'STORM_CALL', 'SANDSHREW')
    check(imm['hp'] == 999 and imm['weather'][0] == 0, 'weather/damage against a Ground target', **imm)
    return {'hit': hit, 'immune': imm}


@test('battle_moves')
def weather_already_active(g):
    """A signature move whose weather is already up leaves the count alone; a different weather is
    replaced with a fresh 5 turns."""
    over = g.state()
    out = {}
    for move, w in [('ERUPTION', 'sand'), ('STORM_CALL', 'rain'), ('SACRED_FIRE', 'sun'), ('SHEER_COLD', 'hail')]:
        g.load(over)
        b = battle(g, [move], enemy_level=50)
        s = g.state()
        g.write('wBattleWeather', [WEATHER[w], 200])
        ko = move == 'SHEER_COLD'  # stop before the KO cleans up battle RAM; no end-of-turn tick
        check(b.turn(0, stop='HandleEnemyMonFaint' if ko else 'LoadBattleMenu'), 'turn did not finish', move=move)
        got = out[move] = b.weather()
        check(got == (WEATHER[w], 200 if ko else 199), 'active weather count was reset', move=move, weather=got)
        if move == 'ERUPTION':
            g.load(s)
            g.write('wBattleWeather', [WEATHER['rain'], 200])
            b.turn(0)
            got = out['ERUPTION_over_rain'] = b.weather()
            check(got == (WEATHER['sand'], 4), 'rain not replaced by a 5-turn sandstorm', weather=got)
    return out


# --- LIFE_DEW ---
@test('battle_moves')
def life_dew(g):
    """Heals the user to full HP and full PP and cures the user and the party; also at full HP."""
    c = k()
    over = g.state()
    out = {}
    for case in ('hurt', 'full'):
        g.load(over)
        mon_write(g, 1, 'MON_STATUS', 1 << c['PSN'])
        mon_write(g, 2, 'MON_STATUS', 1 << c['BRN'])
        b = battle(g, ['LIFE_DEW', 'SWIFT'])
        mx = b.maxhp('player')
        hp0 = mx // 4 if case == 'hurt' else mx
        # poison, not paralysis: full paralysis would skip the move
        b.set_player(hp=hp0, status=1 << c['PSN'])
        g.write('wBattleMonPP', [2, 0xc0 | 3])  # Swift with three PP Ups
        mon_write(g, 0, 'MON_PP', [2, 0xc0 | 3])
        check(b.turn(0), 'turn did not finish', case=case)
        r = out[case] = dict(maxhp=mx, before=hp0, after=b.hp('player'), status=b.status('player'),
                             party=[mon_read(g, i, 'MON_STATUS', 1)[0] for i in range(6)],
                             pp=g.read('wBattleMonPP', 2), party_pp=mon_read(g, 0, 'MON_PP', 2))
        check(r['after'] == mx, 'did not heal to full HP', case=case, **r)
        check(r['status'] == 0, 'user status not cured', case=case, **r)
        check(r['party'] == [0] * 6, 'party status not cured', case=case, **r)
        check(r['pp'] == [10, 0xc0 | 32] and r['party_pp'] == [10, 0xc0 | 32],
              'PP not refilled (Life Dew 10, Swift 20 + 3 PP Ups = 32)',
              case=case, **r)
    return out


# --- AEROBLAST ---
@test('battle_moves')
def aeroblast_flinch(g):
    """Moving first, Aeroblast's 50% flinch stops the enemy's Growl."""
    b = battle(g, ['AEROBLAST'], enemy_moves=['GROWL'])
    n = 120
    got = trials(g, b, n, lambda b: 'flinch' if b.stages('player')[0] == 7 else 'growled')
    rate = got.get('flinch', 0) / n
    near(rate, CHANCE_50, n, 'flinch rate off 50%', counts=got)
    return {'flinch_rate': round(rate, 3), 'counts': got}


# --- SACRED_FIRE ---
@test('battle_moves')
def sacred_fire(g):
    """Sun after the hit, 50% burn, and it thaws a frozen user (Swift does not)."""
    c = k()
    over = g.state()
    b = battle(g, ['SACRED_FIRE'], enemy_hp=2000)  # a capped 999 crit would KO a 999-HP foe
    n = 120
    keyf = lambda b: (b.weather(), b.status('enemy'))
    got = trials(g, b, n, keyf)
    burns = sum(v for (w, st), v in got.items() if st == 1 << c['BRN'])
    others = {str(kk): v for kk, v in got.items() if kk[1] not in (0, 1 << c['BRN'])}
    no_sun = {str(kk): v for kk, v in got.items() if kk[0] != (WEATHER['sun'], 4)}
    check(not no_sun, 'sun missing after a hit', cases=no_sun)
    check(not others, 'status other than burn', cases=others)
    near(burns / n, CHANCE_50, n, 'burn rate off 50%')
    thaw = {}
    for move in ('SACRED_FIRE', 'SWIFT'):
        g.load(over)
        b = battle(g, [move], enemy_hp=2000)
        b.set_player(status=1 << c['FRZ'])
        mon_write(g, 0, 'MON_STATUS', 1 << c['FRZ'])
        check(b.turn(0), 'turn did not finish', move=move)
        thaw[move] = (b.status('player'), b.hp('enemy') < 2000)
    check(thaw['SACRED_FIRE'] == (0, True), 'Sacred Fire did not thaw the user', **thaw)
    check(thaw['SWIFT'][0] == 1 << c['FRZ'], 'control: Swift thawed the user too', **thaw)
    return {'burn_rate': round(burns / n, 3), 'thaw': thaw}


# --- AURA_SPHERE ---
@test('battle_moves')
def aura_sphere(g):
    """Priority beats a faster foe; never misses vs +6 evasion; misses a target mid-Fly or mid-Dig."""
    c = k()
    over = g.state()
    out = {}
    for move in ('AURA_SPHERE', 'SWIFT'):
        g.load(over)
        b = battle(g, [move], enemy_speed=999, enemy_hp=2000)  # a capped 999 hit would KO
        b.set_player(speed=1)
        check(b.turn(0), 'turn did not finish', move=move)
        out[move + '_first'] = b.player_first()
    check(out['AURA_SPHERE_first'], 'Aura Sphere did not go first', **out)
    check(not out['SWIFT_first'], 'control: speed-1 Swift went first', **out)
    g.load(over)
    b = battle(g, ['AURA_SPHERE'], enemy_hp=2000)
    s = g.state()
    for case, sub3, eva in [('evasion+6', 0, 13), ('flying', 1 << c['SUBSTATUS_FLYING'], 7),
                            ('underground', 1 << c['SUBSTATUS_UNDERGROUND'], 7)]:
        g.load(s)
        g.write('wEnemySubStatus3', sub3)
        g.write('wEnemyStatLevels+6', eva)
        check(b.turn(0, stop='DoEnemyTurn'), 'enemy turn not reached', case=case)
        out[case] = 2000 - b.hp('enemy')
    check(out['evasion+6'] > 0, 'missed against +6 evasion', **out)
    check(out['flying'] == 0, 'hit a target mid-Fly', **out)
    check(out['underground'] == 0, 'hit a target mid-Dig', **out)
    return out


@test('battle_moves')
def fly_dig_moves(g):
    """Gust/Twister/Hurricane hit a target mid-Fly and miss mid-Dig; Earthquake/Magnitude the reverse; Swift neither."""
    c = k()
    over = g.state()
    out = {}
    for move in ('GUST', 'TWISTER', 'HURRICANE', 'EARTHQUAKE', 'MAGNITUDE', 'SWIFT'):
        g.load(over)
        b = battle(g, [move], enemy_hp=2000)  # Earthquake doubles underground; a capped 999 would KO
        s = g.state()
        for case, sub3 in (('fly', 1 << c['SUBSTATUS_FLYING']), ('dig', 1 << c['SUBSTATUS_UNDERGROUND'])):
            g.load(s)
            g.write('wEnemySubStatus3', sub3)
            if move == 'HURRICANE':  # 70% accurate; rain makes it sure, and is checked after Fly/Dig
                g.write('wBattleWeather', value('WEATHER_RAIN'))
                g.write('wWeatherCount', 5)
            check(b.turn(0, stop='DoEnemyTurn'), 'enemy turn not reached', move=move, case=case)
            out[f'{move}_{case}'] = 2000 - b.hp('enemy')
    hits = {m: (out[m + '_fly'] > 0, out[m + '_dig'] > 0) for m in ('GUST', 'TWISTER', 'HURRICANE', 'EARTHQUAKE', 'MAGNITUDE', 'SWIFT')}
    want = {'GUST': (True, False), 'TWISTER': (True, False), 'HURRICANE': (True, False), 'EARTHQUAKE': (False, True),
            'MAGNITUDE': (False, True), 'SWIFT': (False, False)}
    check(hits == want, 'wrong moves hit Fly/Dig targets', hits=hits, damage=out)
    return out


# --- FAE_BLADE ---
@test('battle_moves')
def fae_blade(g):
    """One of PAR, FRZ, BRN, PSN, SLP or confusion, about a sixth each; a target with a status is confused."""
    c = k()
    names = {1 << c['PAR']: 'PAR', 1 << c['FRZ']: 'FRZ', 1 << c['BRN']: 'BRN', 1 << c['PSN']: 'PSN'}

    def key(b):
        st = b.status('enemy')
        conf = bool(b.substatus('enemy')[2] & (1 << c['SUBSTATUS_CONFUSED']))
        name = 'SLP' if st and not st & ~c['SLP_MASK'] else names.get(st, hex(st) if st else '')
        return '+'.join(x for x in (name, 'CONF' if conf else '') if x) or 'none'

    b = battle(g, ['FAE_BLADE'])
    s = g.state()
    n = 180
    got = trials(g, b, n, key, stop='DoEnemyTurn')
    six = ('PAR', 'FRZ', 'BRN', 'PSN', 'SLP', 'CONF')
    check(set(got) <= set(six) | {'none'}, 'unexpected result', counts=got)
    check(got.get('none', 0) <= 3, 'nothing inflicted too often (100% chance)', counts=got)
    for st in six:
        near(got.get(st, 0) / n, 1 / 6, n, '%s share off 1/6' % st, counts=got)
    g.load(s)
    g.write('wEnemyMonStatus', 1 << c['PAR'])
    pre = trials(g, b, 20, key, stop='DoEnemyTurn')
    check(set(pre) == {'PAR+CONF'}, 'a target with a status was not confused', counts=pre)
    return {'fresh': got, 'statused': pre}


# --- Metronome / Sketch ---
@test('battle_moves')
def metronome_never_picks_signatures(g):
    """Forced: ChooseRandomMove returning each signature index is rejected and re-rolled, while
    Swift is accepted. Sampled: 150 real Metronome picks contain none of the ten."""
    b = battle(g, ['METRONOME'])
    start = g.state()
    bank, getmove = g.addr('BattleCommand_Metronome.GetMove')
    after_choose = (bank, getmove + 3)  # just past `call ChooseRandomMove`
    out = {'forced': {}}
    for name in SIGNATURE + ['SWIFT']:
        g.load(start)
        b.choose_move(0)
        check(g.run_until(after_choose, 600), 'Metronome never chose a move')
        g.set_reg('bc', value(name))
        rerolled = g.run_until((bank, getmove), 30)
        out['forced'][name] = 'rerolled' if rerolled else 'used'
        check(rerolled == (name != 'SWIFT'), 'Metronome exclusion wrong', move=name, result=out['forced'][name])
    picks = {}
    sig = {value(m) for m in SIGNATURE}
    for i in range(150):
        g.load(start)
        b.choose_move(0, delay=i % 17, delay2=(i // 17) % 13)
        check(g.run_until('ResetTurn', 600), 'Metronome did not reset the turn')
        idx = move_name(g, g.read('wCurPlayerMove'))
        picks[idx] = picks.get(idx, 0) + 1
    bad = sorted(sig & set(picks))
    check(not bad, 'Metronome picked a signature move', picks=bad)
    out['sampled'] = dict(picks=150, distinct=len(picks))
    return out


@test('battle_moves')
def sketch_fails_on_signatures(g):
    """Sketch leaves the slot unchanged for each signature move (as the foe's last move), copies Swift,
    and also fails after the foe really used Inner Light this turn."""
    b = battle(g, ['SKETCH', 'SCRATCH'])
    start = g.state()
    sketch = b.moves()[0]
    out = {}
    for name in SIGNATURE + ['SWIFT']:
        g.load(start)
        g.write('wLastEnemyCounterMove', move_id(g, name))
        check(b.turn(0), 'turn did not finish', move=name)
        slot = b.moves()[0]
        out[name] = 'copied' if slot != sketch else 'failed'
        if name == 'SWIFT':
            check(move_name(g, slot) == value('SWIFT'), 'Sketch did not copy Swift', **out)
        else:
            check(slot == sketch, 'Sketch copied a signature move', move=name, **out)
    g.load(start)
    b.set_enemy(moves=['INNER_LIGHT'], speed=999)
    check(b.turn(0), 'turn did not finish (real Inner Light)')
    out['real_INNER_LIGHT'] = 'copied' if b.moves()[0] != sketch else 'failed'
    check(out['real_INNER_LIGHT'] == 'failed', 'Sketch copied Inner Light used this turn', **out)
    check(b.stages('enemy') == [k()['MAX_STAT_LEVEL']] * 7, 'enemy Inner Light did not land', stages=b.stages('enemy'))
    return out

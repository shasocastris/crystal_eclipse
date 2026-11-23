"""Happiness-based obedience (branch 32) measured in real wild battles against the exact model in
docs/v1_research/obey_model.py. One move (Swift) so a disobedient mon can't use another move:
obey = the enemy lost HP during our action."""
import contextlib
import io
import math
import os
import random
import runpy

from battle import Battle
from gb import REPO
from registry import Skip, check, test

TRIALS = 240
SIGMAS = 4
ENEMY_HP = 2000  # above the 999 damage cap, so one hit never KOs


def _model():
    path = os.path.join(REPO, 'docs', 'v1_research', 'obey_model.py')
    if not os.path.exists(path):
        raise Skip('obey_model.py not found')
    with contextlib.redirect_stdout(io.StringIO()):
        return runpy.run_path(path)['odds']


def _measure(g, level, happiness, trials=TRIALS, tower=False):
    b = Battle(g, enemy='SENTRET', enemy_level=5, lead_level=level, happiness=happiness,
               moves=['SWIFT'], enemy_moves=['SPLASH'], enemy_hp=ENEMY_HP, enemy_speed=1)
    if tower:
        g.write('wInBattleTowerBattle', 1)
    start = g.state()
    out = {'obey': 0, 'nap': 0, 'other': 0}
    rng = random.Random(level * 256 + happiness)
    for k in range(trials):
        g.load(start)
        # vary the RNG: idle frames on both menus before pressing A
        b.choose_move(0, k % 17, (k // 17) % 13)
        # frame delays alone leave the RNG state clumped; seed it uniformly per trial
        g.write('hRandomAdd', rng.randrange(256))
        g.write('hRandomSub', rng.randrange(256))
        if not b.advance('DoEnemyTurn', 1500):
            raise AssertionError('trial %d: enemy turn never reached' % k)
        check(b.player_first(), 'enemy moved first', trial=k)
        if b.hp('enemy') < ENEMY_HP:
            out['obey'] += 1
        elif b.status('player') & 7:
            out['nap'] += 1
        else:
            out['other'] += 1
    return out


def _case(g, level, happiness, **kw):
    want = float(_model()(happiness, level)['obey'])
    got = _measure(g, level, happiness, **kw)
    n = sum(got.values())
    rate = got['obey'] / n
    sd = math.sqrt(want * (1 - want) / n)
    detail = dict(level=level, happiness=happiness, model=round(want, 4), observed=round(rate, 4),
                  trials=n, counts=got)
    if want in (0.0, 1.0):
        check(rate == want, 'obedience should be certain', **detail)
    else:
        check(abs(rate - want) <= SIGMAS * sd, 'obedience rate off the model', sigma=round(sd, 4), **detail)
    return detail


@test('obedience')
def l50_h70(g):
    """Cap 24 at L50: obeys 24/50."""
    return _case(g, 50, 70)


@test('obedience')
def l55_h110(g):
    return _case(g, 55, 110)


@test('obedience')
def l55_h159(g):
    return _case(g, 55, 159)


@test('obedience')
def l55_h160(g):
    return _case(g, 55, 160)


@test('obedience')
def l60_h219(g):
    return _case(g, 60, 219)


@test('obedience')
def l60_h220_kangaskhan(g):
    """220 happiness at L60 (the Kangaskhan gift) always obeys."""
    return _case(g, 60, 220, trials=60)


@test('obedience')
def l24_h0(g):
    """Level 24 is at the base cap: always obeys, even at 0 happiness."""
    return _case(g, 24, 0, trials=60)


@test('obedience')
def battle_tower_skips_check(g):
    """wInBattleTowerBattle set: no obedience check, so L100 at 0 happiness always obeys."""
    got = _measure(g, 100, 0, trials=60, tower=True)
    check(got['obey'] == 60, 'disobeyed in the Battle Tower', counts=got)
    return got

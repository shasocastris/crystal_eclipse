"""Branch-11 link-removal A/B: each scenario runs on the pre11 and post11 debug ROMs (deterministic
RNG, see diff_battle.py) and the traces must match. Skips when the scratchpad ROMs are missing."""
from diff_battle import C, available, compare, mon, no_flee, set_side
from registry import Skip, check, test

BIG = 900


def wild(r, party, enemy_moves=('SPLASH',), flee=False, **enemy):
    """Wild Rattata with tough fixed stats unless overridden."""
    def setup(r):
        if not flee:
            no_flee(r)
        set_side(r, 'player', hp=BIG, maxhp=BIG, atk=60, df=60, speed=100, item=0)
        e = dict(hp=BIG, maxhp=BIG, atk=60, df=60, speed=100, item=0, moves=list(enemy_moves))
        e.update(enemy)
        set_side(r, 'enemy', **e)
    r.start(party, enemy='RATTATA', enemy_level=20, setup=setup)


def turns(r, n, slot=0):
    for _ in range(n):
        if not r.move(slot):
            return


# --- move order ---
def speed_tie(r):
    wild(r, [mon(moves=['SCRATCH'])], ['SCRATCH'])
    turns(r, 6)


def priority(r):
    wild(r, [mon(moves=['QUICK_ATTACK'])], ['SCRATCH'], speed=250)
    set_side(r, 'player', speed=20)
    turns(r, 3)


def quick_claw(r):
    wild(r, [mon(moves=['SCRATCH'])], ['SCRATCH'], speed=250)
    set_side(r, 'player', speed=20, item='QUICK_CLAW')
    turns(r, 8)


# --- double KOs ---
def selfdestruct_player(r):
    wild(r, [mon(moves=['SELFDESTRUCT'])], ['SPLASH'], hp=5)
    turns(r, 1)


def selfdestruct_enemy(r):
    wild(r, [mon(moves=['SPLASH'])], ['SELFDESTRUCT'], atk=250, speed=250)
    set_side(r, 'player', hp=5, df=10)
    turns(r, 1)


def destiny_bond(r):
    wild(r, [mon(moves=['SCRATCH'])], ['DESTINY_BOND'], hp=5, speed=250)
    turns(r, 2)


def recoil_ko(r):
    wild(r, [mon(moves=['DOUBLE_EDGE'])], ['SPLASH'], hp=40)
    set_side(r, 'player', hp=3, atk=250)
    turns(r, 1)


def poison_both(first):
    def f(r):
        wild(r, [mon(moves=['SPLASH'])], ['SPLASH'], hp=1, status=1 << C('PSN'),
             speed=250 if first == 'enemy' else 20)
        set_side(r, 'player', hp=1, status=1 << C('PSN'))
        turns(r, 1)
    return f


def sandstorm_both(first):
    def f(r):
        wild(r, [mon(moves=['SANDSTORM'])], ['SPLASH'], hp=1, speed=250 if first == 'enemy' else 20)
        set_side(r, 'player', hp=1)
        turns(r, 1)
    return f


# --- end of turn ---
def leftovers(r):
    wild(r, [mon(moves=['SCRATCH'])], ['SCRATCH'], hp=300, item='LEFTOVERS')
    set_side(r, 'player', hp=300, item='LEFTOVERS')
    turns(r, 4)


def perish_song(r):
    wild(r, [mon(moves=['SPLASH'])], ['PERISH_SONG'])
    turns(r, 5)


def future_sight(r):
    wild(r, [mon(moves=['FUTURE_SIGHT', 'SPLASH'])], ['SPLASH'])
    r.move(0)
    turns(r, 3, slot=1)


def safeguard(r):
    wild(r, [mon(moves=['SAFEGUARD', 'SPLASH'])], ['TOXIC'], speed=250)
    r.move(0)
    turns(r, 6, slot=1)


def kitchen_sink(r):
    """Leftovers + sandstorm + poison + Future Sight all landing in the same end of turn."""
    # about 168 a turn off the foe (poison + sand - Leftovers) and 56 off the player: both last 4 turns
    wild(r, [mon(moves=['SANDSTORM', 'FUTURE_SIGHT', 'SPLASH'])], ['SPLASH'], item='LEFTOVERS',
         status=1 << C('PSN'))
    set_side(r, 'player', hp=600, item='LEFTOVERS')
    r.move(0)
    r.move(1)
    turns(r, 2, slot=2)


# --- switching ---
def baton_pass(r):
    wild(r, [mon(moves=['SWORDS_DANCE', 'BATON_PASS']), mon('PIDGEY', moves=['SCRATCH'])], ['HARDEN'])
    r.move(0)
    r.move(1, party_pick=1)
    turns(r, 1)


def voluntary_switch(r):
    wild(r, [mon(moves=['SCRATCH']), mon('PIDGEY', moves=['SCRATCH'])], ['SCRATCH'])
    r.switch(1)
    turns(r, 1)


def trainer(r, party, setup=None):
    def s(r):
        set_side(r, 'player', hp=BIG, maxhp=BIG, atk=60, df=60, speed=100, item=0)
        if setup:
            setup(r)
    r.start(party, trainer=('YOUNGSTER', 2), setup=s)


def roar_on_player(r):
    trainer(r, [mon(moves=['SPLASH']), mon('PIDGEY', moves=['SPLASH']), mon('RATICATE', moves=['SPLASH'])],
            lambda r: set_side(r, 'enemy', moves=['ROAR'], hp=BIG, maxhp=BIG))
    turns(r, 4)


def roar_on_trainer(r):
    trainer(r, [mon(moves=['ROAR'])], lambda r: set_side(r, 'enemy', moves=['SPLASH'], hp=BIG, maxhp=BIG))
    turns(r, 4)


def roar_wild(r):
    wild(r, [mon(moves=['ROAR'])], ['SPLASH'])
    turns(r, 1)


def trainer_next_mon(r):
    trainer(r, [mon(moves=['SCRATCH'])], lambda r: set_side(r, 'player', atk=400))
    turns(r, 6)


def trainer_ai(r):
    """Trainer's own moves and AI, long fight: catches AI/item-use divergence."""
    trainer(r, [mon(moves=['SCRATCH'])], lambda r: set_side(r, 'player', atk=15))
    turns(r, 12)


# --- misc ---
def thief_wild(r):
    wild(r, [mon(moves=['THIEF'])], ['SPLASH'], item='LEFTOVERS')
    r.move(0)
    set_side(r, 'enemy', hp=1)
    turns(r, 1)


def struggle(r):
    wild(r, [mon(moves=['SCRATCH'], pp=0)], ['SCRATCH'], pp=0)
    set_side(r, 'player', moves=['SCRATCH'], pp=0)
    for _ in range(3):
        if not r.struggle():
            return


def run_away(speed):
    def f(r):
        wild(r, [mon(moves=['SCRATCH'])], ['SPLASH'], flee=True, speed=200)
        set_side(r, 'player', speed=speed)
        for _ in range(6):
            if not r.run():
                return
    return f


SCENARIOS = {
    'speed_tie': (speed_tie, 8),
    'priority_quick_attack': (priority, 2),
    'quick_claw': (quick_claw, 8),
    'selfdestruct_player': (selfdestruct_player, 2),
    'selfdestruct_enemy': (selfdestruct_enemy, 2),
    'destiny_bond': (destiny_bond, 2),
    'recoil_ko': (recoil_ko, 2),
    'poison_ko_player_first': (poison_both('player'), 2),
    'poison_ko_enemy_first': (poison_both('enemy'), 2),
    'sandstorm_ko_player_first': (sandstorm_both('player'), 2),
    'sandstorm_ko_enemy_first': (sandstorm_both('enemy'), 2),
    'leftovers': (leftovers, 2),
    'perish_song': (perish_song, 2),
    'future_sight': (future_sight, 2),
    'safeguard': (safeguard, 3),
    'end_of_turn_stack': (kitchen_sink, 2),
    'baton_pass': (baton_pass, 2),
    'voluntary_switch': (voluntary_switch, 2),
    'roar_on_player': (roar_on_player, 4),
    'roar_on_trainer': (roar_on_trainer, 4),
    'roar_wild': (roar_wild, 2),
    'trainer_next_mon': (trainer_next_mon, 2),
    'trainer_ai': (trainer_ai, 3),
    'thief_wild': (thief_wild, 2),
    'struggle': (struggle, 2),
    'run_slow': (run_away(40), 10),
    'run_fast': (run_away(250), 4),
}


def _make(name, fn, n):
    def t(g):
        if not available():
            raise Skip('pre11/post11 ROMs not in the scratchpad')
        r = compare(fn, list(range(n)))
        r.pop('sample', None)
        check(not r['nondeterministic'], 'post11 trace depends on input timing', **r)
        check(not r['errors'], 'scenario error', **r)
        check(not r['diffs'], 'pre11 and post11 differ', **r)
        return r
    t.__name__ = t.__qualname__ = name
    return test('linkdiff')(t)


for _n, (_f, _k) in SCENARIOS.items():
    globals()['linkdiff_' + _n] = _make(_n, _f, _k)

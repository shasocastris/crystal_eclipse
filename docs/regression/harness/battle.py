"""Wild-battle driver on top of the debug_party fixture (recipe: docs/regression/battle_fixture.md).

    b = Battle(g, enemy='RATTATA', enemy_level=5, moves=['SCRATCH'], enemy_moves=['SPLASH'], enemy_hp=999)
    b.turn(0)            # FIGHT, slot 0, through the real menus; stops at the next LoadBattleMenu
    b.hp('enemy'), b.weather(), b.stages('player'), b.player_first() ...
"""
from consts import resolve, value
from game import mon, mon_write, species_id

SIDES = {'player': 'wBattleMon', 'enemy': 'wEnemyMon'}
SUB = {'player': 'wPlayerSubStatus', 'enemy': 'wEnemySubStatus'}
STAGES = {'player': 'wPlayerStatLevels', 'enemy': 'wEnemyStatLevels'}


def move_id(g, name):
    return g.call('GetMoveIDFromIndex', hl=value(name))['a']


def move_name(g, rid):
    return g.call('GetMoveIndexFromID', a=rid)['hl'] if rid else 0


def fast_options(g):
    """Animations off, set style, no text scroll, fast text."""
    v = resolve('BATTLE_SCENE', 'BATTLE_SHIFT', 'NO_TEXT_SCROLL', 'TEXT_DELAY_FAST')
    o = (1 << v['BATTLE_SCENE']) | (1 << v['BATTLE_SHIFT']) | (1 << v['NO_TEXT_SCROLL']) | v['TEXT_DELAY_FAST']
    g.write('wOptions', o)


def set_party_mon(g, slot, species=None, level=None, moves=None, happiness=None, pp=20):
    """Rewrite a party mon in place and recalculate its stats; full HP, no status."""
    if species:
        sid = species_id(g, species)
        g.write('wPartySpecies+%d' % slot, sid)
        mon_write(g, slot, 'MON_SPECIES', sid)
    if moves is not None:
        mb, mv = g.addr(mon(g, slot, 'MON_MOVES'))
        pb, pv = g.addr(mon(g, slot, 'MON_PP'))
        for i in range(4):
            rid = move_id(g, moves[i]) if i < len(moves) else 0
            g.write((mb, mv + i), rid)  # write each ID at once: GC frees unreferenced ones
            g.write((pb, pv + i), pp if rid else 0)
    if level is not None:
        mon_write(g, slot, 'MON_LEVEL', level)
    if happiness is not None:
        mon_write(g, slot, 'MON_HAPPINESS', happiness)
    g.write('wCurPartyMon', slot)
    g.write('wCurPartySpecies', g.read('wPartySpecies+%d' % slot))
    g.call('RareCandy_StatBooster_GetParameters')
    g.call('UpdateStatsAfterItem')
    maxhp = g.read(mon(g, slot, 'MON_MAXHP'), 2)
    mon_write(g, slot, 'MON_HP', maxhp)
    mon_write(g, slot, 'MON_STATUS', 0)


class BattleError(RuntimeError):
    pass


class Battle:
    def __init__(self, g, enemy='RATTATA', enemy_level=5, lead=None, lead_level=None, moves=('SCRATCH',),
                 happiness=None, enemy_moves=('SPLASH',), enemy_hp=None, enemy_speed=None, setup=None):
        """Start a wild battle from the overworld (paused at PlayerEvents) and stop at the first
        LoadBattleMenu, with the enemy's moves/HP/speed overridden. `setup(g)` runs just before the
        injection, for any extra RAM writes."""
        self.g = g
        bank, addr = g.addr('WildBattleScript')
        fast_options(g)
        set_party_mon(g, 0, species=lead, level=lead_level, moves=list(moves), happiness=happiness)
        if setup:
            setup(g)
        g.write('wTempWildMonSpecies', species_id(g, enemy))
        g.write('wCurPartyLevel', enemy_level)
        g.write('wBattleType', 0)
        g.write('wOtherTrainerClass', 0)
        g.write('wMapReentryScriptBank', bank)
        g.write('wMapReentryScriptAddress', [addr & 0xff, addr >> 8])
        g.write('wMapReentryScriptQueueFlag', 1)
        if not g.run_until('StartBattle', 600):
            raise BattleError('StartBattle never reached')
        if not self.advance('LoadBattleMenu', 3000):
            raise BattleError('first battle menu never reached')
        self.turns = 0
        # wild mons roll to flee every turn (TryEnemyFlee); a Mean Look flag on our side stops that
        cant_run = value('SUBSTATUS_CANT_RUN')
        g.write('wPlayerSubStatus5', g.read('wPlayerSubStatus5') | 1 << cant_run)
        g.write('wBattleMonItem', 0)  # no held-item side effects (King's Rock, Leftovers...)
        self.set_enemy(moves=enemy_moves, hp=enemy_hp, speed=enemy_speed)

    # --- setup after the send-out ---
    def set_enemy(self, moves=None, hp=None, speed=None, item=0):
        g = self.g
        if moves is not None:
            for i in range(4):
                rid = move_id(g, moves[i]) if i < len(moves) else 0
                g.write('wEnemyMonMoves+%d' % i, rid)
                g.write('wEnemyMonPP+%d' % i, 30 if rid else 0)
        if hp is not None:
            g.write('wEnemyMonHP', [hp >> 8, hp & 0xff])
            g.write('wEnemyMonMaxHP', [hp >> 8, hp & 0xff])
        if speed is not None:
            g.write('wEnemyMonStats+4', [speed >> 8, speed & 0xff])
        if item is not None:
            g.write('wEnemyMonItem', item)

    def set_player(self, hp=None, status=None, speed=None, level=None):
        g = self.g
        if hp is not None:
            g.write('wBattleMonHP', [hp >> 8, hp & 0xff])
        if status is not None:
            g.write('wBattleMonStatus', status)
        if speed is not None:
            g.write('wBattleMonStats+4', [speed >> 8, speed & 0xff])
        if level is not None:
            g.write('wBattleMonLevel', level)

    # --- driving ---
    def ended(self):
        return bool(self.g.read('wBattleEnded')) or self.g.read('wBattleMode') == 0

    def advance(self, label, max_frames=1500):
        """Run to `label`, tapping A through text. A is only held while the target hasn't been hit,
        and we stop before the target, so a tap never reaches a menu."""
        g = self.g
        spent = 0
        seen = g.read('wBattleMode') != 0
        while spent < max_frames:
            if g.run_until(label, 20):
                return True
            g.hold('a', True)
            hit = g.run_until(label, 3)
            g.hold('a', False)
            if hit:
                return True
            mode = g.read('wBattleMode')
            if seen and not mode and label != 'CleanUpBattleRAM':
                return False  # battle over and cleaned up before the target
            seen = seen or bool(mode)
            spent += 23
        return False

    def choose_move(self, slot, delay=0, delay2=0):
        """From LoadBattleMenu: FIGHT, then move slot `slot`, via the real menus. `delay`/`delay2`
        idle frames before each A press shift the RNG for trial-to-trial variation."""
        g = self.g
        g.write('wBattleMenuCursorPosition', 1)
        if not g.run_until('InterpretBattleMenu', 300):
            raise BattleError('battle menu not polling')
        g.frames(delay)
        if not self._tap_until('MoveSelectionScreen'):
            raise BattleError('move selection never opened')
        g.write('wCurMoveNum', slot)
        if not g.run_until('MoveSelectionScreen.interpret_joypad', 300):
            raise BattleError('move list not polling')
        g.frames(delay2)
        if not self._tap_until('DetermineMoveOrder'):
            raise BattleError('move not accepted (DetermineMoveOrder not reached)')

    def _tap_until(self, label, tries=10):
        """Tap A on a polling menu until `label` runs (the first frames of a menu drop input)."""
        g = self.g
        for _ in range(tries):
            g.frames(4)
            g.hold('a', True)
            hit = g.run_until(label, 3)
            g.hold('a', False)
            if hit or g.run_until(label, 20):
                return True
        return False

    def turn(self, slot=0, delay=0, delay2=0, stop='LoadBattleMenu', max_frames=3000):
        """One turn. Returns True when `stop` was reached, False if the battle ended first."""
        self.choose_move(slot, delay, delay2)
        self.turns += 1
        return self.advance(stop, max_frames)

    def finish(self, max_frames=6000):
        """Run to CleanUpBattleRAM (battle over); returns wBattleResult & 3 there."""
        if not self.advance('CleanUpBattleRAM', max_frames):
            raise BattleError('battle never cleaned up')
        return self.g.read('wBattleResult') & 3

    # --- readers ---
    def weather(self):
        return self.g.read('wBattleWeather'), self.g.read('wWeatherCount')

    def stages(self, side):
        return self.g.read(STAGES[side], 7)

    def status(self, side):
        return self.g.read(SIDES[side] + 'Status')

    def hp(self, side):
        return self.g.read16(SIDES[side] + 'HP')

    def maxhp(self, side):
        return self.g.read16(SIDES[side] + 'MaxHP')

    def substatus(self, side):
        return [self.g.read('%s%d' % (SUB[side], i)) for i in range(1, 6)]

    def player_first(self):
        return not self.g.read('wEnemyGoesFirst')

    def disobeyed(self):
        return bool(self.g.read('wAlreadyDisobeyed'))

    def moves(self, side='player'):
        return self.g.read(SIDES[side] + 'Moves', 4)

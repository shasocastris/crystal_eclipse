"""Branch-11 (link removal) A/B battle driver: run one scenario on the pre11 and post11 debug ROMs and
diff the traces.

    python diff_battle.py [-k NAME] [--seeds N]

Randomness: post11 has BattleRandom == Random. pre11's _BattleRandom does `jmp z, Random` when
wLinkMode is 0, so both builds draw from Random in a single-player battle. Each ROM is copied with
Random replaced by an 18-byte LCG whose state lives in hUnusedBackup (written only at the intro
menu), and the driver reseeds it right before every turn's decisive A press. Rolls then depend on
the call sequence alone, not on rDIV or frame timing, so the two builds must produce identical
traces unless the battle engine behaves differently.

Constants come from the pre11 worktree (pre11 and post11 share move/species/item numbering; the
current repo does not).
"""
import os
import re
import shutil
import subprocess
import tempfile

from gb import Game
from fixtures import fixture

SCRATCH = '/tmp/claude-1000/-home-bryan-Documents-Romhacks-crystal-eclipse/2d70e333-cae6-412c-bf2d-cf4827cd6419/scratchpad'
BUILDS = ('pre11', 'post11')
SRC = os.path.join(SCRATCH, 'worktrees', 'pre11')


def available():
    return all(os.path.exists(os.path.join(SCRATCH, 'roms', b, 'crystal_eclipse_debug.gbc')) for b in BUILDS)


# --- constants (pre11 source) ---
_C = {}


def C(*names):
    todo = [n for n in names if n not in _C]
    if todo:
        lines = ['INCLUDE "includes.asm"'] + ['PRINTLN "{0}=", {0}'.format(n) for n in todo]
        with tempfile.NamedTemporaryFile('w', suffix='.asm', dir=SCRATCH, delete=False) as f:
            f.write('\n'.join(lines) + '\n')
        try:
            out = subprocess.run(['rgbasm', '-D', '_DEBUG', '-Q8', '-o', os.devnull, f.name],
                                 cwd=SRC, capture_output=True, text=True)
        finally:
            os.unlink(f.name)
        if out.returncode:
            raise RuntimeError(out.stderr.strip()[-1500:])
        for m in re.finditer(r'^(\w+)=\$?(-?[0-9A-Fa-f]+)$', out.stdout, re.M):
            _C[m.group(1)] = int(m.group(2), 16)
    return _C[names[0]] if len(names) == 1 else [_C[n] for n in names]


# --- deterministic ROM copies ---
def det_rom(build):
    """Copy of the build's debug ROM with Random replaced by an LCG seeded through hUnusedBackup."""
    src = os.path.join(SCRATCH, 'roms', build, 'crystal_eclipse_debug')
    dst_dir = os.path.join(SCRATCH, 'roms_det', build)
    dst = os.path.join(dst_dir, 'crystal_eclipse_debug')
    if os.path.exists(dst + '.gbc') and os.path.getmtime(dst + '.gbc') >= os.path.getmtime(src + '.gbc'):
        return dst + '.gbc'
    os.makedirs(dst_dir, exist_ok=True)
    shutil.copy(src + '.sym', dst + '.sym')
    from gb import load_sym
    syms = load_sym(src + '.sym')
    rnd = syms['Random'][1]
    s, ra, rs = (syms[n][1] & 0xff for n in ('hUnusedBackup', 'hRandomAdd', 'hRandomSub'))
    rom = bytearray(open(src + '.gbc', 'rb').read())
    assert rom[rnd] == 0xc5 and rom[rnd + 17:rnd + 19] == b'\xc1\xc9', 'unexpected Random bytes in %s' % build
    # push bc / s = 5s+1 / a = swap s / hRandomAdd = hRandomSub = a / pop bc / ret
    patch = [0xc5, 0xf0, s, 0x47, 0x87, 0x87, 0x80, 0x3c, 0xe0, s, 0xcb, 0x37, 0xe0, ra, 0xe0, rs, 0xc1, 0xc9]
    rom[rnd:rnd + 18] = bytes(patch)
    open(dst + '.gbc', 'wb').write(rom)
    return dst + '.gbc'


def game(build):
    return fixture('debug_party', rom=det_rom(build))


# --- party setup (overworld, paused at PlayerEvents) ---
def mon_addr(slot, field):
    return 'wPartyMon1+%d' % (slot * C('PARTYMON_STRUCT_LENGTH') + C(field))


def sid(g, name):
    return g.call('GetPokemonIDFromIndex', hl=C(name))['a']


def mid(g, name):
    return g.call('GetMoveIDFromIndex', hl=C(name))['a'] if name else 0


def iid(g, name):
    return g.call('GetItemIDFromIndex', hl=C(name))['a'] if name else 0


def set_party(g, party):
    """party: list of dicts {species, level, moves, item, pp}. Replaces the whole party."""
    g.write('wPartyCount', len(party))
    for slot, m in enumerate(party):
        s = sid(g, m['species'])
        g.write('wPartySpecies+%d' % slot, s)
        g.write('wPartySpecies+%d' % (slot + 1), 0xff)
        g.write(mon_addr(slot, 'MON_SPECIES'), s)
        moves = list(m.get('moves', ['SCRATCH']))
        base = slot * C('PARTYMON_STRUCT_LENGTH')
        for i in range(4):
            rid = mid(g, moves[i]) if i < len(moves) else 0
            g.write('wPartyMon1+%d' % (base + C('MON_MOVES') + i), rid)  # at once: GC frees unreferenced IDs
            g.write('wPartyMon1+%d' % (base + C('MON_PP') + i), m.get('pp', 20) if rid else 0)
        g.write(mon_addr(slot, 'MON_ITEM'), iid(g, m.get('item')))
        g.write(mon_addr(slot, 'MON_LEVEL'), m.get('level', 50))
        g.write(mon_addr(slot, 'MON_EXP'), [0, 0, 0])  # below the level: a KO can't start a level-up chain
        g.write(mon_addr(slot, 'MON_HAPPINESS'), 255)
        g.write(mon_addr(slot, 'MON_DVS'), [0xaa, 0xaa])
        g.write('wCurPartyMon', slot)
        g.write('wCurPartySpecies', s)
        g.call('RareCandy_StatBooster_GetParameters')
        g.call('UpdateStatsAfterItem')
        g.write(mon_addr(slot, 'MON_HP'), g.read(mon_addr(slot, 'MON_MAXHP'), 2))
        g.write(mon_addr(slot, 'MON_STATUS'), 0)


def fast_options(g):
    bs, sh, ns, fast = C('BATTLE_SCENE', 'BATTLE_SHIFT', 'NO_TEXT_SCROLL', 'TEXT_DELAY_FAST')
    g.write('wOptions', (1 << bs) | (1 << sh) | (1 << ns) | fast)


def w16(g, label, v):
    g.write(label, [v >> 8 & 0xff, v & 0xff])


class Run:
    """One scenario on one build. Produces self.trace (list of snapshots)."""

    def __init__(self, g, seed, delay=0):
        self.g, self.seed, self.delay, self.turn = g, seed, delay, 0
        self.trace, self.done = [], False

    def reseed(self):
        self.g.write('hUnusedBackup', (self.seed * 37 + self.turn * 101 + 13) & 0xff)

    def start(self, party, enemy='RATTATA', enemy_level=10, trainer=None, setup=None):
        g = self.g
        fast_options(g)
        set_party(g, party)
        bank, addr = g.addr('WildBattleScript')
        if trainer:
            g.write('wTempWildMonSpecies', 0)
            g.write('wOtherTrainerClass', C(trainer[0]))
            g.write('wOtherTrainerID', trainer[1])
            g.write('wBattleType', C('BATTLETYPE_CANLOSE'))
            # no script set the win/loss text pointers; skip that text (used only for it)
            g.write('wDebugFlags', g.read('wDebugFlags') | (1 << C('DEBUG_BATTLE_F')))
        else:
            g.write('wTempWildMonSpecies', sid(g, enemy))
            g.write('wCurPartyLevel', enemy_level)
            g.write('wOtherTrainerClass', 0)
            g.write('wBattleType', 0)
        g.write('wMapReentryScriptBank', bank)
        g.write('wMapReentryScriptAddress', [addr & 0xff, addr >> 8])
        g.write('wMapReentryScriptQueueFlag', 1)
        if not g.run_until('StartBattle', 600):
            raise RuntimeError('StartBattle never reached')
        self.reseed()
        if not self._advance():
            raise RuntimeError('first battle menu never reached')
        if setup:
            setup(self)
        self.trace.append(self.snap('start'))

    # --- low level ---
    def _tap(self, label, tries=12):
        g = self.g
        for _ in range(tries):
            g.frames(4)
            g.hold('a', True)
            hit = g.run_until(label, 3)
            g.hold('a', False)
            if hit or g.run_until(label, 20):
                return True
        return False

    def _advance(self, party_pick=None, max_frames=8000):
        """Tap A through text to the next LoadBattleMenu (True) or the battle's end (False, with the
        final snapshot taken at CleanUpBattleRAM). party_pick: slot to choose if a party menu opens.
        Watches all targets at once, so a battle that ends or a menu that opens mid-tap isn't missed."""
        g = self.g
        targets = ['LoadBattleMenu', 'CleanUpBattleRAM']
        if party_pick is not None:
            targets.append('PartyMenuSelect')
        spent = 0
        while spent < max_frames:
            hit = g.run_until_any(targets, 20)
            if not hit:
                g.hold('a', True)
                hit = g.run_until_any(targets, 3)
                g.hold('a', False)
            if hit == 'PartyMenuSelect':
                g.write('wMenuCursorY', party_pick + 1)
                targets.remove('PartyMenuSelect')
                g.frames(1)
                continue
            if hit:
                return self._arrived(hit)
            spent += 23
        raise RuntimeError('advance: stuck (turn %d)' % self.turn)

    def _arrived(self, target):
        if target == 'CleanUpBattleRAM':
            self.done = True
            self.trace.append(self.snap('end'))
            return False
        return True

    # --- actions ---
    def move(self, slot=0, party_pick=None):
        g = self.g
        g.write('wBattleMenuCursorPosition', 1)
        if not g.run_until('InterpretBattleMenu', 300):
            raise RuntimeError('battle menu not polling')
        g.frames(self.delay)
        if not self._tap('MoveSelectionScreen'):
            raise RuntimeError('move selection never opened')
        g.write('wCurMoveNum', slot)
        if not g.run_until('MoveSelectionScreen.interpret_joypad', 300):
            raise RuntimeError('move list not polling')
        g.frames(self.delay)
        self.reseed()
        if not self._tap('DetermineMoveOrder'):
            raise RuntimeError('move not accepted')
        return self._finish_turn(party_pick)

    def struggle(self):
        """FIGHT with no PP left: the game picks Struggle without opening the move list."""
        g = self.g
        g.write('wBattleMenuCursorPosition', 1)
        if not g.run_until('InterpretBattleMenu', 300):
            raise RuntimeError('battle menu not polling')
        g.frames(self.delay)
        self.reseed()
        if not self._tap('DetermineMoveOrder'):
            raise RuntimeError('struggle not accepted')
        return self._finish_turn(None)

    def run(self):
        g = self.g
        g.write('wBattleMenuCursorPosition', 4)
        if not g.run_until('InterpretBattleMenu', 300):
            raise RuntimeError('battle menu not polling')
        g.frames(self.delay)
        self.reseed()
        if not self._tap('TryToRunAwayFromBattle'):
            raise RuntimeError('run not accepted')
        return self._finish_turn(None)

    def switch(self, slot):
        g = self.g
        g.write('wBattleMenuCursorPosition', 2)
        if not g.run_until('InterpretBattleMenu', 300):
            raise RuntimeError('battle menu not polling')
        g.frames(self.delay)
        if not self._tap('PartyMenuSelect'):
            raise RuntimeError('party menu never opened')
        g.write('wMenuCursorY', slot + 1)
        self.reseed()
        if not self._tap('TryPlayerSwitch'):
            raise RuntimeError('switch not accepted')
        return self._finish_turn(None)

    def _finish_turn(self, party_pick):
        self.turn += 1
        live = self._advance(party_pick)
        if live:
            self.trace.append(self.snap(self.turn))
        return live

    # --- trace ---
    def snap(self, tag):
        g = self.g
        r = g.read
        s = {'tag': tag}
        if tag == 'end':
            s['result'] = r('wBattleResult')
        else:
            s.update(
                first='enemy' if r('wEnemyGoesFirst') else 'player',
                p_hp=g.read16('wBattleMonHP'), e_hp=g.read16('wEnemyMonHP'),
                p_status=r('wBattleMonStatus'), e_status=r('wEnemyMonStatus'),
                p_item=r('wBattleMonItem'), e_item=r('wEnemyMonItem'),
                p_species=r('wBattleMonSpecies'), e_species=r('wEnemyMonSpecies'),
                cur_mon=r('wCurBattleMon'), ot_mon=r('wCurOTMon'),
                p_stages=r('wPlayerStatLevels', 7), e_stages=r('wEnemyStatLevels', 7),
                p_sub=r('wPlayerSubStatus1', 5), e_sub=r('wEnemySubStatus1', 5),
                weather=(r('wBattleWeather'), r('wWeatherCount')),
                perish=(r('wPlayerPerishCount'), r('wEnemyPerishCount')),
                future=(r('wPlayerFutureSightCount'), r('wEnemyFutureSightCount')),
                safeguard=(r('wPlayerSafeguardCount'), r('wEnemySafeguardCount')),
                moves=(r('wCurPlayerMove'), r('wCurEnemyMove')),
                flee=r('wNumFleeAttempts'),
            )
            if r('wBattleMode') == 2:
                s['ot_hp'] = [g.read16('wOTPartyMon1HP+%d' % (i * C('PARTYMON_STRUCT_LENGTH')))
                              for i in range(r('wOTPartyCount'))]
        n = r('wPartyCount')
        L = C('PARTYMON_STRUCT_LENGTH')
        s['party_hp'] = [g.read16('wPartyMon1HP+%d' % (i * L)) for i in range(n)]
        s['party_item'] = [r('wPartyMon1Item+%d' % (i * L)) for i in range(n)]
        s['party_status'] = [r('wPartyMon1Status+%d' % (i * L)) for i in range(n)]
        return s


def mon(species='RATTATA', level=50, moves=('SCRATCH',), item=None, pp=20):
    return dict(species=species, level=level, moves=list(moves), item=item, pp=pp)


def set_side(run, side, hp=None, maxhp=None, speed=None, atk=None, df=None, status=None, item=None,
             moves=None, pp=30, level=None):
    """Battle-mon overrides after the send-out. side 'player' or 'enemy'."""
    g = run.g
    pre = 'wBattleMon' if side == 'player' else 'wEnemyMon'
    if moves is not None:
        for i in range(4):
            rid = mid(g, moves[i]) if i < len(moves) else 0
            g.write('%sMoves+%d' % (pre, i), rid)
            g.write('%sPP+%d' % (pre, i), pp if rid else 0)
    if maxhp is not None:
        w16(g, pre + 'MaxHP', maxhp)
    if hp is not None:
        w16(g, pre + 'HP', hp)
        if side == 'player':  # keep the party copy in step so the end snapshot is comparable
            w16(g, 'wPartyMon1HP+%d' % (g.read('wCurBattleMon') * C('PARTYMON_STRUCT_LENGTH')), hp)
    for off, v in ((0, atk), (2, df), (4, speed)):
        if v is not None:
            w16(g, '%sStats+%d' % (pre, off), v)
    if status is not None:
        g.write(pre + 'Status', status)
    if item is not None:
        g.write(pre + 'Item', iid(g, item) if isinstance(item, str) else item)
    if level is not None:
        g.write(pre + 'Level', level)


def no_flee(run):
    g = run.g
    g.write('wPlayerSubStatus5', g.read('wPlayerSubStatus5') | 1 << C('SUBSTATUS_CANT_RUN'))


def diff_traces(a, b):
    out = []
    for i in range(max(len(a), len(b))):
        x = a[i] if i < len(a) else None
        y = b[i] if i < len(b) else None
        if x != y:
            if x is None or y is None:
                out.append((i, 'missing', x, y))
            else:
                keys = sorted(set(x) | set(y))
                out.append((i, {k: (x.get(k), y.get(k)) for k in keys if x.get(k) != y.get(k)}))
    return out


def run_scenario(build, fn, seed, delay=0):
    g = game(build)
    try:
        r = Run(g, seed, delay)
        err = None
        try:
            fn(r)
        except RuntimeError as e:
            err = str(e)
        return r.trace, err
    finally:
        g.close()


def compare(fn, seeds, delay_check=True):
    """Run fn on both builds for each seed. Returns a summary dict."""
    res = {'seeds': len(seeds), 'identical': 0, 'diffs': [], 'errors': [], 'nondeterministic': []}
    for sd in seeds:
        ta, ea = run_scenario('pre11', fn, sd)
        tb, eb = run_scenario('post11', fn, sd)
        if delay_check and sd == seeds[0]:
            tc, _ = run_scenario('post11', fn, sd, delay=7)
            if tc != tb:
                res['nondeterministic'].append(diff_traces(tb, tc)[:2])
        if ea or eb:
            res['errors'].append((sd, ea, eb))
        d = diff_traces(ta, tb)
        if d or ea != eb:
            res['diffs'].append((sd, d[:3]))
        else:
            res['identical'] += 1
        res.setdefault('sample', ta)
    return res


if __name__ == '__main__':
    import argparse
    import json
    import suite_linkdiff
    ap = argparse.ArgumentParser()
    ap.add_argument('-k', default='')
    ap.add_argument('--seeds', type=int, default=0, help='override per-scenario seed count')
    ap.add_argument('--show', action='store_true', help='print the pre11 trace of the first seed')
    a = ap.parse_args()
    for name, (fn, n) in suite_linkdiff.SCENARIOS.items():
        if a.k not in name:
            continue
        r = compare(fn, list(range(a.seeds or n)))
        sample = r.pop('sample', None)
        print('%-22s identical %d/%d  diffs %d  errors %d  nondet %d' % (
            name, r['identical'], r['seeds'], len(r['diffs']), len(r['errors']), len(r['nondeterministic'])))
        for x in r['diffs'][:2] + r['errors'][:2] + r['nondeterministic'][:1]:
            print('   ', json.dumps(x, default=str)[:600])
        if a.show and sample:
            for s in sample:
                print('     ', json.dumps(s, default=str)[:400])

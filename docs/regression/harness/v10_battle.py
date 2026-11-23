"""v1.0 regression, battle area: Shift removal, Fae Blade, Life Dew, nickname happiness, met level,
obedience text, plus a v0.9-vs-HEAD battle differential.

Run with CE_REPO set to the tree that built --rom (see AGENT_BRIEF.md). Tests that compare the two
builds (battle_ab_*) build their own deterministic-RNG ROM copies and ignore --rom.
"""
import json
import os
import random
import re
import shutil
import subprocess
import tempfile

import gb
from gb import Game, load_sym
from battle import Battle, fast_options, set_party_mon
from consts import resolve, value
from game import mon, mon_read, mon_write, species_index, species_id
from overworld import answer, in_control, interact, pick_party, warp
from registry import Skip, check, test
import fixtures

SUITE = 'v10_battle'
SCR = '/tmp/claude-1000/-home-bryan-Documents-Romhacks-crystal-eclipse/4203bf99-da66-490e-998d-1f337047b4f7/scratchpad'
TREES = {'v09': os.path.join(SCR, 'wt', 'v09'), 'head': os.path.join(SCR, 'wt', 'head')}
EVID = os.path.join(gb.HERE, '..', 'v10', 'battle')


def is_v09(g):
    return 'OfferSwitch' in g.syms


def step(g):
    gb._lib.sb_step(g.h)


def shot(g, name):
    os.makedirs(EVID, exist_ok=True)
    g.render(True)
    g.frames(2)
    g.screenshot(os.path.join(EVID, '%s-%s.png' % (name, 'v09' if is_v09(g) else 'head')))
    g.render(False)


# --- charmap / tilemap ---
def _ch(b):
    if 0x80 <= b <= 0x99:
        return chr(ord('A') + b - 0x80)
    if 0xa0 <= b <= 0xb9:
        return chr(ord('a') + b - 0xa0)
    if 0xf6 <= b <= 0xff:
        return chr(ord('0') + b - 0xf6)
    return {0x7f: ' ', 0x9c: ':', 0xe3: '-', 0xe8: '.', 0xe7: '!', 0xe6: '?', 0xe0: "'", 0x6e: 'L',
            0xf3: '/', 0xed: '>', 0xea: 'e'}.get(b, '~')


def tile_rows(g):
    t = g.read('wTilemap', 20 * 18)
    return [''.join(_ch(b) for b in t[r * 20:(r + 1) * 20]) for r in range(18)]


# --- text tracing ---
def _rev(g):
    if not hasattr(g, '_rev'):
        g._rev = {}
        for name, loc in g.syms.items():
            g._rev.setdefault(loc, name)
    return g._rev


def text_label(g, hit):
    hl = g.reg('hl')
    bank = g.syms['BattleText'][0] if hit == 'StdBattleTextbox' else (g.rom_bank if hl >= 0x4000 else 0)
    return _rev(g).get((bank if hl >= 0x4000 else 0, hl), '%02x:%04x' % (bank, hl))


def _fresh(g, hit):
    """False when this breakpoint hit is the same call seen again: sb_step can service an interrupt
    instead of the instruction, so the same PC is reached twice for one call."""
    key = (hit, g.reg('sp'), g.reg('hl'), g.read(g.reg('sp')) | g.read(g.reg('sp') + 1) << 8)
    last = getattr(g, '_last_hit', None)
    g._last_hit = (key, g.frame)
    return not (last and last[0] == key and g.frame - last[1] <= 2)


def advance_watch(g, stops, watch=('StdBattleTextbox',), max_frames=4000, key='a'):
    """Tap `key` through text until one of `stops` (returned) or the frame budget runs out (None).
    Records every hit of a `watch` label in g.events: StdBattleTextbox as its text label."""
    watch = [w for w in watch if w in g.syms]
    stops = [x for x in stops if x in g.syms]
    targets = stops + watch
    spent = 0
    while spent < max_frames:
        hit = g.run_until_any(targets, 20)
        if not hit:
            g.hold(key, True)
            hit = g.run_until_any(targets, 3)
            g.hold(key, False)
            spent += 23
            if not hit:
                continue
        if hit in stops:
            return hit
        if _fresh(g, hit):
            g.events.append(text_label(g, hit) if hit in ('StdBattleTextbox', 'BattleTextbox', 'PrintText') else hit)
        step(g)
    return None


# --- battles ---
def start_battle(g, enemy='SENTRET', level=5, trainer=None, lead='MEWTWO', lead_level=100, moves=('SWIFT',),
                 shift=False, battle_type=None):
    """Wild or trainer battle from the overworld, stopped at the first LoadBattleMenu. `shift` clears
    the BATTLE_SHIFT option bit (Shift style in v0.9; ignored by HEAD)."""
    g.events = []
    bank, addr = g.addr('WildBattleScript')
    fast_options(g)
    if shift:
        g.write('wOptions', g.read('wOptions') & ~(1 << value('BATTLE_SHIFT')) & 0xff)
    set_party_mon(g, 0, species=lead, level=lead_level, moves=list(moves))
    g.write('wBattleMonItem', 0)
    mon_write(g, 0, 'MON_ITEM', 0)
    if trainer:
        g.write('wTempWildMonSpecies', 0)
        g.write('wOtherTrainerClass', value(trainer[0]))
        g.write('wOtherTrainerID', trainer[1])
        g.write('wBattleType', value('BATTLETYPE_CANLOSE') if battle_type is None else battle_type)
        g.write('wDebugFlags', g.read('wDebugFlags') | (1 << value('DEBUG_BATTLE_F')))
    else:
        g.write('wTempWildMonSpecies', species_id(g, enemy))
        g.write('wCurPartyLevel', level)
        g.write('wOtherTrainerClass', 0)
        g.write('wBattleType', 0 if battle_type is None else battle_type)
    g.write('wMapReentryScriptBank', bank)
    g.write('wMapReentryScriptAddress', [addr & 0xff, addr >> 8])
    g.write('wMapReentryScriptQueueFlag', 1)
    check(g.run_until('StartBattle', 600), 'StartBattle never reached')
    b = Battle.__new__(Battle)
    b.g, b.turns = g, 0
    check(b.advance('LoadBattleMenu', 4000), 'first battle menu never reached')
    if not trainer:
        g.write('wPlayerSubStatus5', g.read('wPlayerSubStatus5') | 1 << value('SUBSTATUS_CANT_RUN'))
    g.write('wBattleMonItem', 0)
    g.events = []
    return b


def tank_enemy(g, hp=2000):
    g.write('wEnemyMonHP', [hp >> 8, hp & 0xff])
    g.write('wEnemyMonMaxHP', [hp >> 8, hp & 0xff])
    g.write('wEnemyMonStats+2', [0x03, 0xe7])  # defense
    g.write('wEnemyMonStats+8', [0x03, 0xe7])  # sp. def
    g.write('wEnemyMonStats+4', [0, 1])        # speed 1: we move first
    # a crit reads the stat-stage copies in wEnemyStats, not wEnemyMonStats: tank those too
    g.write('wEnemyDefense', [0x03, 0xe7])
    g.write('wEnemySpDef', [0x03, 0xe7])
    g.write('wEnemyMonItem', 0)


def set_enemy_moves(g, moves):
    from battle import move_id
    c = resolve('PARTYMON_STRUCT_LENGTH', 'MON_MOVES', 'MON_PP')
    ot = g.read('wCurOTMon') * c['PARTYMON_STRUCT_LENGTH']
    for i in range(4):
        rid = move_id(g, moves[i]) if i < len(moves) else 0
        g.write('wEnemyMonMoves+%d' % i, rid)
        g.write('wEnemyMonPP+%d' % i, 30 if rid else 0)
    if g.read('wBattleMode') == 2:  # trainer: the AI already chose this turn's move before the menu
        g.write('wCurEnemyMove', move_id(g, moves[0]))
        g.write('wCurEnemyMoveNum', 0)
    for i in range(4):
        rid = move_id(g, moves[i]) if i < len(moves) else 0
        if g.read('wBattleMode') == 2:  # trainer: the AI and PP use read the OT party copy
            g.write('wOTPartyMon1+%d' % (ot + c['MON_MOVES'] + i), rid)
            g.write('wOTPartyMon1+%d' % (ot + c['MON_PP'] + i), 30 if rid else 0)


def seeded_turn(g, b, slot, seed, stop, watch=('StdBattleTextbox',)):
    b.choose_move(slot, seed % 7, 0)
    rng = random.Random(seed)
    g.write('hRandomAdd', rng.randrange(256))
    g.write('hRandomSub', rng.randrange(256))
    g.events = []
    return advance_watch(g, [stop, 'CleanUpBattleRAM'], watch)


# --- interactive calls (menus, naming screen, prompts) ---
class Inputs:
    """Scripted answers for prompts met while driving a routine or scene."""

    def __init__(self, yes=(), names=(), picks=()):
        self.yes, self.names, self.picks, self.log = list(yes), list(names), list(picks), []

    def labels(self):
        return ['YesNoBox', 'NamingScreen', 'PartyMenuSelect']

    def handle(self, g, hit):
        if hit == 'YesNoBox':
            ans = self.yes.pop(0) if self.yes else False
            self.log.append(('yesno', ans))
            step(g)
            g.frames(4)
            if ans:
                g.press('a', hold=4, after=10)
            else:  # B is "no"; repeat it, as the battle box can take a while to start polling
                for _ in range(6):
                    g.press('b', hold=3, after=6)
        elif hit == 'NamingScreen':
            name = self.names.pop(0) if self.names else ''
            self.log.append(('name', name))
            step(g)
            check(g.run_until('NamingScreenJoypadLoop', 900), 'naming screen never polled')
            g.frames(30)
            for _ in name:  # the cursor starts on "A"; each press types one A
                g.press('a', hold=3, after=8)
            g.press('start', hold=3, after=10)
            g.press('a', hold=3, after=20)
        elif hit == 'PartyMenuSelect':
            slot = self.picks.pop(0) if self.picks else 0
            self.log.append(('pick', slot))
            step(g)
            pick_party(g, slot)


def drive(g, label, inputs=None, a=0, bc=None, de=None, hl=0, key='a', max_frames=12000):
    """Far-call `label` from the paused point and run it to its return, tapping `key` through text and
    answering prompts from `inputs`. Returns the callee's registers."""
    inputs = inputs or Inputs()
    bank, target = g.addr(label)
    ret_pc, sp = g.reg('pc'), g.reg('sp')
    ret = (g.rom_bank if ret_pc >= 0x4000 else 0, ret_pc)
    g.write('hFarCallSavedA', a)
    g.write('hFarCallSavedL', hl & 0xff)
    g.write('hFarCallSavedH', hl >> 8)
    if bc is not None:
        g.set_reg('bc', bc)
    if de is not None:
        g.set_reg('de', de)
    g.set_reg('af', bank << 8)
    g.set_reg('hl', target)
    sp -= 2
    g.write(sp, ret_pc & 0xff)
    g.write(sp + 1, ret_pc >> 8)
    g.set_reg('sp', sp)
    g.set_reg('pc', g.syms['FarCall_hl'][1])
    targets = [ret] + inputs.labels()
    spent = 0
    while spent < max_frames:
        hit = g.run_until_any(targets, 20)
        if hit is None:
            g.hold(key, True)
            hit = g.run_until_any(targets, 3)
            g.hold(key, False)
            spent += 23
            if hit is None:
                continue
        if hit == ret:
            if g.reg('sp') == sp + 2:
                af = g.reg('af')
                return {'a': af >> 8, 'carry': bool(af & 0x10), 'bc': g.reg('bc'), 'de': g.reg('de'),
                        'hl': g.reg('hl')}
            step(g)
            continue
        inputs.handle(g, hit)
    raise AssertionError('%s did not return (inputs log %s)' % (label, inputs.log))


def scene(g, inputs, max_presses=400):
    """After an interact(): tap B through a map script, answering prompts, until the script has run
    and the player has control again."""
    labels = inputs.labels()
    started = False
    for _ in range(max_presses):
        hit = g.run_until_any(labels, 6)
        if not hit:
            running = g.read('wScriptRunning')
            started = started or bool(running)
            if started and not running and in_control(g, 6):
                return True
            g.hold('b', True)
            hit = g.run_until_any(labels, 3)
            g.hold('b', False)
        if hit:
            started = True
            inputs.handle(g, hit)
    return False


def set_party_count(g, n):
    g.write('wPartyCount', n)
    g.write('wPartySpecies+%d' % n, 0xff)


def box_happiness(g):
    """Happiness of the mon just stored from wBufferMon, read back from its box slot."""
    box, slot = g.read('wBufferMonBox'), g.read('wBufferMonSlot')
    g.write('wBufferMonHappiness', 0)
    g.call('GetStorageBoxMon', bc=box << 8 | slot)
    return g.read('wBufferMonHappiness'), (box, slot)


# =====================================================================================
# 1. Shift battle style removed (06e73d29e, 21aade23d, d25e6cf57)
# =====================================================================================
PROMPT = ('YesNoBox', 'PlaceYesNoBox', 'OfferSwitch')


@test(SUITE)
def battle_no_switch_prompt(g):
    """Falkner's lead is KO'd with the options byte on Set and on the old Shift value: no "Will you
    switch?" prompt (HEAD), and the next mon comes out; then KO the rest, still no prompt."""
    base = g.state()
    out = {}
    for style in ('set', 'shift'):
        g.load(base)
        b = start_battle(g, trainer=('FALKNER', 1), moves=['SWIFT'], shift=style == 'shift')
        g.write('wEnemyMonHP', [0, 1])
        r = out[style] = {'option_bit6': bool(g.read('wOptions') & (1 << value('BATTLE_SHIFT'))), 'kos': []}
        for turn in range(10):  # Focus Band can leave a foe at 1 HP: repeat until it falls
            ot0 = g.read('wCurOTMon')
            b.choose_move(0)
            g.events = []
            hit = advance_watch(g, ['LoadBattleMenu', 'CleanUpBattleRAM'] + list(PROMPT), max_frames=6000)
            prompt = hit in PROMPT
            if prompt:
                r['prompt'] = turn
                r['prompt_texts'] = g.events[:]
                shot(g, 'switch_prompt_%s' % style)
                break
            if hit == 'LoadBattleMenu' and g.read('wCurOTMon') == ot0:
                continue
            r['kos'].append(dict(stop=hit, ot_mon=g.read('wCurOTMon'), texts=g.events[:]))
            if hit != 'LoadBattleMenu':
                break
            check(g.read('wCurOTMon') == ot0 + 1, 'next enemy mon not sent out', style=style, **r)
        r['ended'] = bool(r['kos']) and r['kos'][-1]['stop'] == 'CleanUpBattleRAM'
    bad = {k: v.get('prompt') for k, v in out.items() if 'prompt' in v}
    check(not bad, 'a switch prompt appeared after an enemy KO', prompts=bad, detail=out)
    check(all(v['ended'] and len(v['kos']) == 3 for v in out.values()), 'battle did not end after 3 KOs', detail=out)
    return {k: dict(bit6=v['option_bit6'], kos=len(v['kos']), ended=v['ended']) for k, v in out.items()}


@test(SUITE)
def battle_options_menu(g):
    """The Options menu lists 7 rows without BATTLE STYLE; each row's left/right changes only its own
    value, and the old BATTLE_SHIFT bit is never touched."""
    stops = ['_Option.joypad_loop']
    check(all(s in g.syms for s in stops), 'no _Option.joypad_loop label')
    bit = 1 << value('BATTLE_SHIFT')
    out = {}
    for start_bit in (0, bit):
        g.write('wOptions', (g.read('wOptions') & ~bit & 0xff) | start_bit)
        # open the menu and stop in its input loop
        s = g.state()
        bank, target = g.addr('_Option')
        ret_pc, sp = g.reg('pc'), g.reg('sp')
        g.write('hFarCallSavedA', 0)
        g.set_reg('af', bank << 8)
        g.set_reg('hl', target)
        g.write(sp - 2, ret_pc & 0xff)
        g.write(sp - 1, ret_pc >> 8)
        g.set_reg('sp', sp - 2)
        g.set_reg('pc', g.syms['FarCall_hl'][1])
        check(g.run_until('_Option.joypad_loop', 600), 'options menu never polled')
        g.frames(10)
        g.run_until('_Option.joypad_loop', 60)
        rows = tile_rows(g)
        if start_bit == 0:
            shot(g, 'options_menu')
        labels = [rows[r][2:18].strip() for r in range(2, 17, 2)]
        labels = [x for x in labels if x]
        vals = lambda: (g.read('wOptions'), g.read('wOptions2'), g.read('wTextboxFrame'), g.read('wGBPrinterBrightness'))
        per_row = []
        n_rows = 0
        for i in range(10):
            idx = g.read('wJumptableIndex')
            if i and idx == 0:
                break
            n_rows += 1
            before, t0 = vals(), tile_rows(g)
            g.press('right', hold=5, after=10)
            g.run_until('_Option.joypad_loop', 60)
            after, t1 = vals(), tile_rows(g)
            changed_rows = [r for r in range(18) if t0[r] != t1[r] and r != 0]
            g.press('left', hold=5, after=10)
            g.run_until('_Option.joypad_loop', 60)
            restored = vals() == before
            per_row.append(dict(idx=idx, label=labels[idx] if idx < len(labels) else None,
                                bytes_changed=[n for n, (x, y) in zip(('opt', 'opt2', 'frame', 'print'), zip(before, after)) if x != y],
                                rows_changed=changed_rows, restored=restored,
                                bit6_toggled=bool((before[0] ^ after[0]) & bit)))
            g.press('down', hold=5, after=10)
            g.run_until('_Option.joypad_loop', 60)
        out[start_bit] = dict(labels=labels, n_rows=n_rows, rows=per_row, bit6_end=bool(g.read('wOptions') & bit))
        g.load(s)
    o = out[0]
    check('BATTLE STYLE' not in o['labels'], 'BATTLE STYLE still listed', labels=o['labels'])
    check(o['labels'] == ['TEXT SPEED', 'BATTLE SCENE', 'SOUND', 'PRINT', 'MENU ACCOUNT', 'FRAME', 'CANCEL'],
          'unexpected option rows', labels=o['labels'])
    check(o['n_rows'] == 7, 'cursor does not wrap after 7 rows', n=o['n_rows'])
    for sb, r in out.items():
        check(not any(x['bit6_toggled'] for x in r['rows']), 'a row toggles the old BATTLE_SHIFT bit', start=sb, rows=r['rows'])
        check(r['bit6_end'] == bool(sb), 'BATTLE_SHIFT bit changed', start=sb)
        for x in r['rows'][:6]:
            val_row = 3 + 2 * x['idx']
            check(set(x['rows_changed']) <= {val_row}, 'row %s redraws outside its value line' % x['label'], row=x)
            check(x['restored'], 'right then left did not restore the setting', row=x)
    return out[0]


@test(SUITE)
def battle_no_battletype_set_refs(g):
    """Static: nothing in the source tree or .sym uses BATTLETYPE_SET / Shift-mode code; BATTLE_SHIFT is
    only defined; battle types are only used by name; Battle Tower leaves wOptions alone."""
    repo = gb.REPO
    pat = r'BATTLETYPE_SET\b|EnemySwitch_SetMode|OfferSwitch|CheckWhetherToAskSwitch|EnemyIsAboutToUseWillPlayerChangeMon|Options_BattleStyle|BATTLE STYLE'
    out = subprocess.run(['grep', '-rnE', '--include=*.asm', pat, '.'], cwd=repo, capture_output=True, text=True).stdout
    hits = [l for l in out.splitlines() if not l.startswith('./rgbds')]
    shift = subprocess.run(['grep', '-rnw', '--include=*.asm', 'BATTLE_SHIFT', '.'], cwd=repo, capture_output=True, text=True).stdout
    shift_uses = [l for l in shift.splitlines() if not l.startswith('./rgbds') and 'const BATTLE_SHIFT' not in l]
    raw = subprocess.run(['grep', '-rnEi', r'VAR_BATTLETYPE,\s*[\$%0-9]', 'maps', 'engine', 'data'], cwd=repo,
                         capture_output=True, text=True).stdout.splitlines()
    syms = [s for s in ('OfferSwitch', 'EnemySwitch_SetMode', 'CheckWhetherToAskSwitch', 'Options_BattleStyle',
                        'BattleText_EnemyIsAboutToUseWillPlayerChangeMon') if s in g.syms]
    tower = open(os.path.join(repo, 'engine/events/battle_tower/battle_tower.asm')).read()
    m = re.search(r'RunBattleTowerTrainer:(.*?)\n\S', tower, re.S)
    tower_opts = 'wOptions' in (m.group(1) if m else '')
    r = dict(source_hits=hits[:20], battle_shift_uses=shift_uses, raw_battletype_values=raw, syms=syms,
             tower_touches_options=tower_opts)
    check(not hits and not shift_uses and not raw and not syms and not tower_opts, 'Shift-mode leftovers', **r)
    return r


# =====================================================================================
# 2. Fae Blade (89b009424)
# =====================================================================================
FAE_TEXT = {'PAR': 'ParalyzedText', 'FRZ': 'GotAFrostbiteText', 'BRN': 'WasBurnedText', 'PSN': 'WasPoisonedText',
            'SLP': 'FellAsleepText', 'CONF': 'BecameConfusedText'}


def _fae_key(g):
    c = resolve('PSN', 'BRN', 'FRZ', 'PAR', 'SLP_MASK', 'SUBSTATUS_CONFUSED')
    st = g.read('wEnemyMonStatus')
    conf = bool(g.read('wEnemySubStatus3') & (1 << c['SUBSTATUS_CONFUSED']))
    names = {1 << c['PAR']: 'PAR', 1 << c['FRZ']: 'FRZ', 1 << c['BRN']: 'BRN', 1 << c['PSN']: 'PSN'}
    name = 'SLP' if st and not st & ~c['SLP_MASK'] else names.get(st, hex(st) if st else '')
    return '+'.join(x for x in (name, 'CONF' if conf else '') if x) or 'none', st


def _fae_trials(g, enemy, n, prestatus=0, level=30):
    b = start_battle(g, enemy=enemy, level=level, moves=['FAE_BLADE'])
    tank_enemy(g)
    set_enemy_moves(g, ['SPLASH'])
    if prestatus:
        g.write('wEnemyMonStatus', prestatus)
    s = g.state()
    rows = []
    for i in range(n):
        g.load(s)
        hit = seeded_turn(g, b, 0, 1000 + i, 'DoEnemyTurn', watch=('StdBattleTextbox', 'LoadMoveAnim'))
        check(hit == 'DoEnemyTurn', 'enemy turn never reached', trial=i, hit=hit)
        key, st = _fae_key(g)
        texts = [e for e in g.events if e != 'LoadMoveAnim']
        rows.append(dict(key=key, st=st, texts=texts, anims=g.events.count('LoadMoveAnim'),
                         dmg=2000 - g.read16('wEnemyMonHP')))
    g.load(s)
    return rows


@test(SUITE)
def battle_fae_blade_effects_and_text(g):
    """Seeded: each of the six effects about 1/6 of the time vs a Normal-type, each landing with its own
    text and only that text; sleep lasts 1-6 turns; a statused target is always confused. Also counts
    the move animations played per hit."""
    if is_v09(g):
        raise Skip('v0.9 Fae Blade is Tri Attack (changed on purpose)')
    n = 240
    over = g.state()
    rows = _fae_trials(g, 'SENTRET', n)
    counts, mism, anims, slp = {}, [], {}, []
    status_texts = set(FAE_TEXT.values())
    for r in rows:
        counts[r['key']] = counts.get(r['key'], 0) + 1
        want = FAE_TEXT.get(r['key'].split('+')[0]) if r['key'] != 'none' else None
        got = [t for t in r['texts'] if t in status_texts]
        if (want and got != [want]) or (not want and got):
            mism.append(r)
        anims.setdefault(r['key'], set()).add(r['anims'])
        if r['key'] == 'SLP':
            slp.append(r['st'])
    import math
    dev = {k: round((counts.get(k, 0) / n - 1 / 6) / math.sqrt((1 / 6) * (5 / 6) / n), 2) for k in FAE_TEXT}
    out = dict(counts=counts, sigma=dev, anims={k: sorted(v) for k, v in anims.items()},
               sleep_turns=sorted(set(slp)), sample_texts=rows[0]['texts'])
    check(set(counts) <= set(FAE_TEXT) | {'none'}, 'unexpected outcome', **out)
    check(counts.get('none', 0) <= 3, 'no effect too often (100% chance)', **out)
    check(all(abs(v) <= 4 for v in dev.values()), 'share off 1/6 by more than 4 sigma', **out)
    check(not mism, 'status text does not match the status inflicted', bad=mism[:3], **out)
    check(all(1 <= s <= 7 for s in slp), 'sleep counter out of range', **out)
    g.load(over)
    pre = _fae_trials(g, 'SENTRET', 20, prestatus=1 << value('PAR'))
    pk = {}
    for r in pre:
        pk[r['key']] = pk.get(r['key'], 0) + 1
    out['statused'] = pk
    out['statused_texts'] = pre[0]['texts']
    check(set(pk) == {'PAR+CONF'}, 'a statused target was not always confused', **out)
    base = out['anims'].get('PAR', [])
    one_anim = {k: v for k, v in out['anims'].items() if v != base}
    out['double_anim'] = one_anim
    check(not one_anim, 'some outcomes replay the move animation (extra LoadMoveAnim vs PAR)', **out)
    return out


@test(SUITE)
def battle_fae_blade_type_immunity(g):
    """Fae Blade lands burn, frostbite and poison on Fire, Ice, Poison, Steel and Fairy targets."""
    if is_v09(g):
        raise Skip('v0.9 Fae Blade is Tri Attack (changed on purpose)')
    out = {}
    over = g.state()
    for enemy in ('VULPIX', 'SWINUB', 'EKANS', 'MAGNEMITE', 'CLEFAIRY'):
        g.load(over)
        rows = _fae_trials(g, enemy, 90)
        c = {}
        for r in rows:
            c[r['key']] = c.get(r['key'], 0) + 1
        out[enemy] = c
    # shasocastris 2026-11-05: Fae Blade can inflict its conditions on any type
    want = {'VULPIX': ('BRN',), 'SWINUB': ('FRZ',), 'EKANS': ('PSN',), 'MAGNEMITE': ('PSN',),
            'CLEFAIRY': ('BRN', 'FRZ')}
    probs = ['%s never got %s' % (e, k) for e, ks in want.items() for k in ks if not out[e].get(k)]
    out['problems'] = probs
    check(not probs, 'Fae Blade blocked by a type immunity', **out)
    return out


# =====================================================================================
# 3. Life Dew (82d826c49)
# =====================================================================================
@test(SUITE)
def battle_life_dew_player(g):
    """Player's Life Dew: full HP, cures the user and every party status, prints LifeDewText; and
    whether the Toxic counter survives the cure."""
    c = resolve('PSN', 'BRN', 'PAR', 'SLP_MASK', 'SUBSTATUS_TOXIC')
    for slot, st in ((1, 1 << c['PSN']), (2, 1 << c['BRN']), (3, 3), (4, 1 << c['PAR'])):
        mon_write(g, slot, 'MON_STATUS', st)
    b = start_battle(g, moves=['LIFE_DEW', 'SPLASH'])
    tank_enemy(g)
    set_enemy_moves(g, ['SPLASH'])
    mx = g.read16('wBattleMonMaxHP')
    g.write('wBattleMonHP', [(mx // 4) >> 8, (mx // 4) & 0xff])
    g.write('wBattleMonStatus', 1 << c['PSN'])
    g.write('wPlayerSubStatus5', g.read('wPlayerSubStatus5') | 1 << c['SUBSTATUS_TOXIC'])
    g.write('wPlayerToxicCount', 5)
    hit = seeded_turn(g, b, 0, 7, 'LoadBattleMenu')
    party = [mon_read(g, i, 'MON_STATUS', 1)[0] for i in range(6)]
    r = dict(hp=(g.read16('wBattleMonHP'), mx), status=g.read('wBattleMonStatus'), party=party, texts=g.events,
             toxic_bit=bool(g.read('wPlayerSubStatus5') & 1 << c['SUBSTATUS_TOXIC']), toxic_count=g.read('wPlayerToxicCount'))
    check(hit == 'LoadBattleMenu', 'turn did not finish', **r)
    check(r['hp'][0] == mx and r['status'] == 0, 'user not fully healed/cured', **r)
    check(party == [0] * 6, 'party status not cured', **r)
    if not is_v09(g):
        check('LifeDewText' in g.events, 'LifeDewText not shown', **r)
    # consequence of a leftover Toxic flag: a later plain poison (Poison Powder) ticks as Toxic
    set_enemy_moves(g, ['POISONPOWDER'])
    g.write('wEnemyMonStats+4', [0, 1])
    after = g.state()
    for seed in range(8, 40):  # Poison Powder is 75% accurate: find a seed where it lands
        g.load(after)
        hit = seeded_turn(g, b, 1, seed, 'LoadBattleMenu')
        if g.read('wBattleMonStatus'):
            break
    set_enemy_moves(g, ['SPLASH'])
    hp0 = g.read16('wBattleMonHP')
    seeded_turn(g, b, 1, 99, 'LoadBattleMenu')
    hp1 = g.read16('wBattleMonHP') + (mx - hp0)
    r['after_powder'] = dict(status=g.read('wBattleMonStatus'), lost=mx - hp1, eighth=mx // 8, texts=g.events,
                             toxic_bit=bool(g.read('wPlayerSubStatus5') & 1 << c['SUBSTATUS_TOXIC']))
    check(not r['toxic_bit'], 'Life Dew leaves SUBSTATUS_TOXIC set (later plain poison would tick as Toxic)', **r)
    return r


@test(SUITE)
def battle_life_dew_enemy(g):
    """A trainer's Life Dew heals and cures its own side (its party too), and leaves the player's
    party statuses alone."""
    c = resolve('PSN', 'BRN', 'PAR', 'PARTYMON_STRUCT_LENGTH', 'MON_STATUS')
    for slot, st in ((1, 1 << c['PSN']), (2, 1 << c['BRN'])):
        mon_write(g, slot, 'MON_STATUS', st)
    b = start_battle(g, trainer=('FALKNER', 1), moves=['SPLASH'])
    set_enemy_moves(g, ['LIFE_DEW'] * 4)
    g.write('wEnemyTrainerItem1', 0)
    g.write('wEnemyTrainerItem2', 0)
    g.write('wEnemyMonHP', [0, 5])
    g.write('wEnemyMonStatus', 1 << c['PSN'])
    L, S = c['PARTYMON_STRUCT_LENGTH'], c['MON_STATUS']
    for i in (1, 2):
        g.write('wOTPartyMon1+%d' % (i * L + S), 1 << c['PAR'])
    hit = seeded_turn(g, b, 0, 3, 'LoadBattleMenu')
    r = dict(enemy_hp=(g.read16('wEnemyMonHP'), g.read16('wEnemyMonMaxHP')), enemy_status=g.read('wEnemyMonStatus'),
             ot_party=[g.read('wOTPartyMon1+%d' % (i * L + S)) for i in range(3)],
             player_party=[mon_read(g, i, 'MON_STATUS', 1)[0] for i in range(6)], texts=g.events)
    check(hit == 'LoadBattleMenu', 'turn did not finish', **r)
    check(r['enemy_hp'][0] == r['enemy_hp'][1] and r['enemy_status'] == 0, 'enemy not healed/cured', **r)
    check(r['ot_party'] == [0, 0, 0], 'enemy party not cured', **r)
    check(r['player_party'][1] == 1 << c['PSN'] and r['player_party'][2] == 1 << c['BRN'],
          "enemy Life Dew cured the player's party", **r)
    return r


# =====================================================================================
# 4. Nickname happiness (c10552542)
# =====================================================================================
def _ball_id(g, name):
    return g.call('GetItemIDFromIndex', hl=value(name))['a']


def _catch(g, yes, name='A', ball='MASTER_BALL', party=5):
    set_party_count(g, party)
    start_battle(g, enemy='SENTRET', level=5, moves=['SPLASH'])
    if ball != 'MASTER_BALL':  # make any ball a sure catch: 1 HP, asleep, catch rate 255
        g.write('wEnemyMonHP', [0, 1])
        g.write('wEnemyMonStatus', 3)
        g.write('wEnemyMonCatchRate', 255)
    g.call('LoadStandardMenuHeader')  # the pack's window, which PokeBallEffect closes
    g.write('wCurItem', _ball_id(g, ball))
    inp = Inputs(yes=[yes], names=[name])
    drive(g, 'PokeBallEffect', inp)
    if party < 6:
        n = g.read('wPartyCount')
        check(n == party + 1, 'catch did not join the party', n=n, log=inp.log, ball=ball)
        return mon_read(g, n - 1, 'MON_HAPPINESS', 1)[0], inp.log
    return box_happiness(g)[0], inp.log


@test(SUITE)
def battle_happiness_catch(g):
    """Catch: nickname -> 110; decline -> 70; yes but blank -> 70; Friend Ball + nickname keeps 200;
    party-full (box) nickname -> 110."""
    base = g.state()
    out = {}
    for case, kw, want in (('nick', dict(yes=True), 110), ('decline', dict(yes=False), 70),
                           ('blank', dict(yes=True, name=''), 70),
                           ('friend_nick', dict(yes=True, ball='FRIEND_BALL'), 200),
                           ('box_nick', dict(yes=True, party=6), 110), ('box_decline', dict(yes=False, party=6), 70)):
        g.load(base)
        h, log = _catch(g, **kw)
        out[case] = dict(got=h, want=want, log=log)
    g.load(base)
    bad = {k: v for k, v in out.items() if v['got'] != v['want']}
    check(not bad, 'wrong happiness after a catch', bad=bad, all=out)
    return out


@test(SUITE)
def battle_happiness_givepoke(g):
    """GivePoke with the nickname prompt (b=0): party and box, nickname vs decline."""
    base = g.state()
    out = {}
    for case, party, yes, want in (('party_nick', 5, True, 110), ('party_decline', 5, False, 70),
                                   ('box_nick', 6, True, 110), ('box_decline', 6, False, 70)):
        g.load(base)
        set_party_count(g, party)
        g.write('wCurPartySpecies', species_id(g, 'LARVITAR'))
        g.write('wCurPartyLevel', 10)
        g.write('wCurItem', 0)
        inp = Inputs(yes=[yes], names=['A'])
        drive(g, 'GivePoke', inp, bc=0)
        if party < 6:
            n = g.read('wPartyCount')
            h = mon_read(g, n - 1, 'MON_HAPPINESS', 1)[0] if n == party + 1 else None
        else:
            h = box_happiness(g)[0]
        out[case] = dict(got=h, want=want, log=inp.log)
    g.load(base)
    bad = {k: v for k, v in out.items() if v['got'] != v['want']}
    check(not bad, 'wrong happiness after givepoke', bad=bad, all=out)
    return out


@test(SUITE)
def battle_happiness_givepoke_scene(g):
    """Real script: the Game Corner Larvitar prize, nicknamed -> 110 (declined -> 70)."""
    from overworld import set_key_item
    base = g.state()
    out = {}
    for yes, want in ((True, 110), (False, 70)):
        g.load(base)
        set_party_count(g, 5)
        set_key_item(g, 'COIN_CASE')
        warp(g, 'CELADON_GAME_CORNER_PRIZE_ROOM', 4, 2, before=lambda g: g.write('wCoins', [0x27, 0x0f]))
        interact(g, 'up')
        from overworld import wait_for
        check(wait_for(g, 'VerticalMenu'), 'prize menu never opened')
        g.frames(10)
        g.press('down', hold=4, after=8)
        g.press('down', hold=4, after=8)
        g.press('a', hold=4, after=10)
        inp = Inputs(yes=[True, yes], names=['A'])
        labels = inp.labels() + ['VerticalMenu']
        for _ in range(400):
            hit = g.run_until_any(labels, 6)
            if hit == 'VerticalMenu':
                g.frames(10)
                g.press('b', hold=4, after=10)
                break
            if hit:
                inp.handle(g, hit)
                continue
            g.hold('b', True)
            hit = g.run_until_any(labels, 3)
            g.hold('b', False)
            if hit == 'VerticalMenu':
                g.frames(10)
                g.press('b', hold=4, after=10)
                break
            if hit:
                inp.handle(g, hit)
        scene(g, Inputs())
        n = g.read('wPartyCount')
        out[yes] = dict(n=n, species=species_index(g, n - 1) == value('LARVITAR'),
                        got=mon_read(g, n - 1, 'MON_HAPPINESS', 1)[0], want=want, log=inp.log)
    bad = {k: v for k, v in out.items() if v['got'] != v['want'] or not v['species']}
    check(not bad, 'wrong happiness for the prize Larvitar', bad=bad, all=out)
    return {str(k): v for k, v in out.items()}


@test(SUITE)
def battle_happiness_contest(g):
    """Bug-Catching Contest catch (CheckPartyFullAfterContest): party and box, nickname vs decline."""
    c = resolve('PARTYMON_STRUCT_LENGTH', 'MON_SPECIES', 'MON_HAPPINESS')
    base = g.state()
    out = {}
    for case, party, yes, want in (('party_nick', 5, True, 110), ('party_decline', 5, False, 70),
                                   ('box_nick', 6, True, 110), ('box_decline', 6, False, 70)):
        g.load(base)
        set_party_count(g, party)
        sid = species_id(g, 'SCYTHER')
        src = g.read(mon(g, 1, 'MON_SPECIES'), c['PARTYMON_STRUCT_LENGTH'])
        src[c['MON_SPECIES']] = sid
        src[c['MON_HAPPINESS']] = 70
        g.write('wContestMon', src)
        g.write('wContestMonSpecies', sid)
        inp = Inputs(yes=[yes], names=['A'])
        drive(g, 'CheckPartyFullAfterContest', inp)
        if party < 6:
            n = g.read('wPartyCount')
            h = mon_read(g, n - 1, 'MON_HAPPINESS', 1)[0] if n == party + 1 else None
        else:
            h = box_happiness(g)[0]
        out[case] = dict(got=h, want=want, log=inp.log)
    g.load(base)
    bad = {k: v for k, v in out.items() if v['got'] != v['want']}
    check(not bad, 'wrong happiness after the contest', bad=bad, all=out)
    return out


@test(SUITE)
def battle_happiness_name_rater(g):
    """Name Rater rename of a 70-happiness mon -> 110; one already above 110 keeps its value."""
    base = g.state()
    out = {}
    for case, h0, want in (('rename_70', 70, 110), ('rename_150', 150, 150)):
        g.load(base)
        mon_write(g, 1, 'MON_HAPPINESS', h0)
        warp(g, 'GOLDENROD_NAME_RATER', 2, 5)
        inp = Inputs(yes=[True, True], names=['A'], picks=[1])
        interact(g, 'up')
        ok = scene(g, inp)
        out[case] = dict(got=mon_read(g, 1, 'MON_HAPPINESS', 1)[0], want=want, log=inp.log, ok=ok)
    bad = {k: v for k, v in out.items() if v['got'] != v['want']}
    check(not bad, 'wrong happiness after the Name Rater', bad=bad, all=out)
    return out


@test(SUITE)
def battle_happiness_npc_trade(g):
    """An in-game trade's mon arrives with its OT's nickname at 70 (the player never names it)."""
    set_party_mon(g, 1, species='KRABBY', level=20, moves=['BUBBLE'])
    warp(g, 'OLIVINE_TIMS_HOUSE', 2, 4)
    inp = Inputs(yes=[True], picks=[1])
    interact(g, 'up')
    scene(g, inp, max_presses=800)
    n = g.read('wPartyCount')
    r = dict(species_ok=species_index(g, n - 1) == value('VOLTORB'), got=mon_read(g, n - 1, 'MON_HAPPINESS', 1)[0],
             log=inp.log)
    check(r['species_ok'], 'trade did not happen', **r)
    check(r['got'] == 70, 'traded mon happiness is not 70', **r)
    return r


# =====================================================================================
# 5. Stats screen met level (a39192467)
# =====================================================================================
@test(SUITE)
def battle_stats_met_level(g):
    """The stats screen's orange page shows the met level without the caught-time bits."""
    base = g.state()
    out = {}
    for t in (1, 2, 3):
        for lvl in (25, 63):
            g.load(base)
            mon_write(g, 0, 'MON_CAUGHTLEVEL', t << 6 | lvl)
            g.write('wCurPartyMon', 0)
            g.write('wMonType', 0)
            g.write('wCurPartySpecies', g.read('wPartySpecies'))
            bank, target = g.addr('StatsScreenInit')
            ret_pc, sp = g.reg('pc'), g.reg('sp')
            g.write('hFarCallSavedA', 0)
            g.set_reg('af', bank << 8)
            g.set_reg('hl', target)
            g.write(sp - 2, ret_pc & 0xff)
            g.write(sp - 1, ret_pc >> 8)
            g.set_reg('sp', sp - 2)
            g.set_reg('pc', g.syms['FarCall_hl'][1])
            g.frames(120)
            for _ in range(8):  # page right until the orange page (MET) is drawn
                rows = tile_rows(g)
                if any('MET' in x for x in rows):
                    break
                g.press('right', hold=3, after=60)
            g.frames(30)
            rows = tile_rows(g)
            m = re.search(r'(\d+)', rows[13][3:7])
            out['t%d_l%d' % (t, lvl)] = shown = int(m.group(1)) if m else rows[12:14]
            if t == 1 and lvl == 25:
                shot(g, 'stats_met_level')
    g.load(base)
    bad = {k: v for k, v in out.items() if v != int(k.split('_l')[1])}
    check(not bad, 'met level shown wrong', bad=bad, all=out)
    return out


# =====================================================================================
# 6. Obedience text (22d89f4be): static, against the happiness-only rules
# =====================================================================================
def _texts(path):
    """[(line_no, string)] for every text/line/cont/para string of a map file."""
    out = []
    for i, l in enumerate(open(path), 1):
        m = re.match(r'\s*(text|line|cont|para)\s+"(.*)"', l)
        if m:
            out.append((i, m.group(2)))
    return out


def _width(s):
    s = re.sub(r'<PLAYER>|<RIVAL>', 'XXXXXXX', s)
    s = re.sub(r'<[^>]+>', 'X', s)
    s = re.sub(r'\{[^}]+\}', 'XXX', s)
    return len(s.replace('#', 'POKé'))


@test(SUITE)
def battle_obedience_text(g):
    """No text still ties obedience to badges, levels or trades; the edited lines fit 18 columns."""
    repo = gb.REPO
    stale = []
    for root in ('maps', 'data/text'):
        for dp, _, fs in os.walk(os.path.join(repo, root)):
            for f in fs:
                if not f.endswith('.asm'):
                    continue
                p = os.path.join(dp, f)
                t = _texts(p)
                for k in range(len(t)):
                    if re.search(r'\b(dis)?obey', t[k][1], re.I):
                        ctx = ' '.join(x for _, x in t[max(0, k - 5):k + 6])
                        # 'traded or not' says trades don't matter
                        if re.search(r'BADGE|\bL\d+\b|trade', ctx, re.I) and 'traded or not' not in ctx:
                            stale.append('%s:%d: %s' % (os.path.relpath(p, repo), t[k][0], ctx))
    edited = ['maps/AzaleaGym.asm', 'maps/CianwoodGym.asm', 'maps/DragonShrine.asm', 'maps/EcruteakGym.asm',
              'maps/ElmsLab.asm']
    diff = subprocess.run(['git', 'diff', '-U0', '2f2a153e6', 'HEAD', '--'] + edited, cwd=repo,
                          capture_output=True, text=True).stdout
    long_lines = []
    for l in diff.splitlines():
        m = re.match(r'\+\s*(text|line|cont|para)\s+"(.*)"', l)
        if m and _width(m.group(2)) > 18:
            long_lines.append((m.group(2), _width(m.group(2))))
    r = dict(stale=stale, long_lines=long_lines)
    check(not long_lines, 'edited obedience text exceeds 18 columns', **r)
    check(not stale, 'text still ties obedience to badges/levels/trades', **r)
    return r


# =====================================================================================
# 7. A/B differential: v0.9 vs HEAD, deterministic RNG
# =====================================================================================
import diff_battle as DB  # noqa: E402  (module only; it registers no tests)

_CT = {}
_TREE = ['head']


def C(*names):
    tree = _TREE[0]
    todo = [n for n in names if (tree, n) not in _CT]
    if todo:
        lines = ['INCLUDE "includes.asm"'] + ['PRINTLN "{0}=", {0}'.format(n) for n in todo]
        with tempfile.NamedTemporaryFile('w', suffix='.asm', dir=TREES[tree], delete=False) as f:
            f.write('\n'.join(lines) + '\n')
        try:
            out = subprocess.run(['rgbasm', '-D', '_DEBUG', '-Q8', '-o', os.devnull, f.name],
                                 cwd=TREES[tree], capture_output=True, text=True)
        finally:
            os.unlink(f.name)
        if out.returncode:
            raise RuntimeError(out.stderr.strip()[-1500:])
        for m in re.finditer(r'^(\w+)=\$?(-?[0-9A-Fa-f]+)$', out.stdout, re.M):
            _CT[(tree, m.group(1))] = int(m.group(2), 16)
    vals = [_CT[(tree, n)] for n in names]
    return vals[0] if len(names) == 1 else vals


def det_rom(tree):
    """The tree's debug ROM with Random replaced by diff_battle's seeded LCG."""
    src = os.path.join(SCR, 'roms', tree, 'crystal_eclipse_debug')
    dst_dir = os.path.join(SCR, 'roms_det_battle', tree)
    dst = os.path.join(dst_dir, 'crystal_eclipse_debug')
    if os.path.exists(dst + '.gbc') and os.path.getmtime(dst + '.gbc') >= os.path.getmtime(src + '.gbc'):
        return dst + '.gbc'
    os.makedirs(dst_dir, exist_ok=True)
    shutil.copy(src + '.sym', dst + '.sym')
    syms = load_sym(src + '.sym')
    rnd = syms['Random'][1]
    s, ra, rs = (syms[n][1] & 0xff for n in ('hUnusedBackup', 'hRandomAdd', 'hRandomSub'))
    rom = bytearray(open(src + '.gbc', 'rb').read())
    assert rom[rnd] == 0xc5 and rom[rnd + 17:rnd + 19] == b'\xc1\xc9', 'unexpected Random bytes in %s' % tree
    patch = [0xc5, 0xf0, s, 0x47, 0x87, 0x87, 0x80, 0x3c, 0xe0, s, 0xcb, 0x37, 0xe0, ra, 0xe0, rs, 0xc1, 0xc9]
    rom[rnd:rnd + 18] = bytes(patch)
    open(dst + '.gbc', 'wb').write(rom)
    return dst + '.gbc'


class TRun(DB.Run):
    """diff_battle.Run that also records every battle text label shown during a turn."""

    def _advance(self, party_pick=None, max_frames=8000):
        g = self.g
        targets = ['LoadBattleMenu', 'CleanUpBattleRAM', 'BattleTextbox']
        if party_pick is not None:
            targets.append('PartyMenuSelect')
        spent = 0
        texts = self.__dict__.setdefault('texts', [])
        targets.append('DoBattleTransition')
        while spent < max_frames:
            hit = g.run_until_any(targets, 20)
            if not hit:
                g.hold('a', True)
                hit = g.run_until_any(targets, 3)
                g.hold('a', False)
            if hit == 'DoBattleTransition':
                # the patched LCG can loop forever in the speckle transition (some tiles are never
                # drawn): skip the transition with an immediate ret, in both builds alike
                sp = g.reg('sp')
                g.set_reg('pc', g.read(sp) | g.read(sp + 1) << 8)
                g.set_reg('sp', sp + 2)
                continue
            if hit == 'BattleTextbox':
                if _fresh(g, hit):
                    texts.append(text_label(g, hit))
                step(g)
                continue
            if hit == 'PartyMenuSelect':
                g.write('wMenuCursorY', party_pick + 1)
                targets.remove('PartyMenuSelect')
                g.frames(1)
                continue
            if hit:
                return self._arrived(hit)
            spent += 23
        raise RuntimeError('advance: stuck (turn %d)' % self.turn)

    def snap(self, tag):
        s = DB.Run.snap(self, tag)
        s['texts'] = list(self.__dict__.get('texts', []))
        self.texts = []
        # species/move runtime IDs are slot numbers allocated per build; compare by constant instead
        g = self.g
        if tag != 'end':
            s['p_species'] = g.call('GetPokemonIndexFromID', a=s['p_species'])['hl']
            s['e_species'] = g.call('GetPokemonIndexFromID', a=s['e_species'])['hl']
            s['moves'] = tuple(g.call('GetMoveIndexFromID', a=m)['hl'] if m else 0 for m in s['moves'])
            s['p_item'] = g.call('GetItemIndexFromID', a=s['p_item'])['hl'] if s['p_item'] else 0
            s['e_item'] = g.call('GetItemIndexFromID', a=s['e_item'])['hl'] if s['e_item'] else 0
            s['party_item'] = [g.call('GetItemIndexFromID', a=i)['hl'] if i else 0 for i in s['party_item']]
        return s


# scenario helpers (constants resolved per tree through DB.C, patched to C above)
BIG = 900


def wild(r, party, enemy_moves=('SPLASH',), flee=False, enemy='RATTATA', **e):
    def setup(r):
        if not flee:
            DB.no_flee(r)
        DB.set_side(r, 'player', hp=BIG, maxhp=BIG, atk=60, df=60, speed=100, item=0)
        x = dict(hp=BIG, maxhp=BIG, atk=60, df=60, speed=100, item=0, moves=list(enemy_moves))
        x.update(e)
        DB.set_side(r, 'enemy', **x)
    r.start(party, enemy=enemy, enemy_level=20, setup=setup)


def turns(r, n, slot=0):
    for _ in range(n):
        if not r.move(slot):
            return


M = DB.mon
SCENARIOS = {
    'damage_crit': (lambda r: (wild(r, [M(moves=['SLASH'])], ['SCRATCH'], speed=50), turns(r, 6)), 6),
    'speed_tie': (lambda r: (wild(r, [M(moves=['SCRATCH'])], ['SCRATCH']), turns(r, 5)), 6),
    'type_matchup': (lambda r: (wild(r, [M('PIKACHU', moves=['THUNDERSHOCK'])], ['WATER_GUN'], enemy='PSYDUCK'),
                                turns(r, 4)), 3),
    'para_sleep': (lambda r: (wild(r, [M(moves=['THUNDER_WAVE', 'SCRATCH'])], ['SLEEP_POWDER', 'SCRATCH']),
                              r.move(0), turns(r, 5, slot=1)), 4),
    'burn_poison': (lambda r: (wild(r, [M(moves=['EMBER', 'POISON_STING'])], ['SCRATCH']), turns(r, 3),
                               turns(r, 3, slot=1)), 4),
    'confuse': (lambda r: (wild(r, [M(moves=['CONFUSE_RAY', 'SCRATCH'])], ['SCRATCH']), r.move(0),
                           turns(r, 5, slot=1)), 4),
    'quick_claw': (lambda r: (wild(r, [M(moves=['SCRATCH'])], ['SCRATCH'], speed=250),
                              DB.set_side(r, 'player', speed=20, item='QUICK_CLAW'), turns(r, 6)), 4),
    'leftovers_berry': (lambda r: (wild(r, [M(moves=['SCRATCH'])], ['SCRATCH'], hp=300, item='LEFTOVERS'),
                                   DB.set_side(r, 'player', hp=300, item='BERRY'), turns(r, 6)), 3),
    'heal_bell': (lambda r: (wild(r, [M(moves=['HEAL_BELL', 'SCRATCH'])], ['POISONPOWDER', 'SCRATCH']),
                             turns(r, 2, slot=1), r.move(0), turns(r, 2, slot=1)), 3),
    'baton_pass': (lambda r: (wild(r, [M(moves=['SWORDS_DANCE', 'BATON_PASS']), M('PIDGEY', moves=['SCRATCH'])],
                                   ['HARDEN']), r.move(0), r.move(1, party_pick=1), turns(r, 1)), 2),
    'voluntary_switch': (lambda r: (wild(r, [M(moves=['SCRATCH']), M('PIDGEY', moves=['SCRATCH'])], ['SCRATCH']),
                                    r.switch(1), turns(r, 2)), 2),
    'trainer_next_mon': (lambda r: (r.start([M(moves=['SCRATCH'])], trainer=('YOUNGSTER', 2),
                                            setup=lambda r: DB.set_side(r, 'player', hp=BIG, maxhp=BIG, atk=400,
                                                                         df=60, speed=100, item=0)),
                                    turns(r, 6)), 3),
    'trainer_ai_falkner': (lambda r: (r.start([M(moves=['SCRATCH'], level=20), M('PIDGEY', moves=['SCRATCH'], level=20)],
                                              trainer=('FALKNER', 1),
                                              setup=lambda r: DB.set_side(r, 'player', hp=BIG, maxhp=BIG, atk=40,
                                                                           df=60, speed=100, item=0)),
                                      turns(r, 14)), 3),
    'trainer_ko_switch_in': (lambda r: (r.start([M(moves=['SCRATCH'])], trainer=('FALKNER', 1),
                                                setup=lambda r: DB.set_side(r, 'player', hp=BIG, maxhp=BIG, atk=999,
                                                                             df=60, speed=999, item=0)),
                                        turns(r, 5)), 2),
    'run_away': (lambda r: (wild(r, [M(moves=['SCRATCH'])], ['SPLASH'], flee=True, speed=200),
                            DB.set_side(r, 'player', speed=60), [r.run() for _ in range(4) if not r.done]), 6),
    'tri_attack': (lambda r: (wild(r, [M(moves=['TRI_ATTACK'])], ['SPLASH'], hp=BIG), turns(r, 4)), 4),
}


def run_tree(tree, fn, seed, delay=0):
    _TREE[0] = tree
    DB.C = C
    g = fixtures.fixture('debug_party', rom=det_rom(tree))
    try:
        r = TRun(g, seed, delay)
        err = None
        try:
            fn(r)
        except RuntimeError as e:
            err = str(e)
        return r.trace, err
    finally:
        g.close()


def ab(fn, seeds):
    res = {'seeds': len(seeds), 'identical': 0, 'diffs': [], 'errors': []}
    for sd in seeds:
        ta, ea = run_tree('v09', fn, sd)
        tb, eb = run_tree('head', fn, sd)
        if ea or eb:
            res['errors'].append((sd, ea, eb))
        d = DB.diff_traces(ta, tb)
        if d or ea != eb:
            res['diffs'].append((sd, d[:3]))
        else:
            res['identical'] += 1
        if sd == seeds[0]:
            res['sample_len'] = len(ta)
            res['sample_texts'] = [t for s in ta for t in s.get('texts', [])][:12]
    return res


def _make_ab(name, fn, n):
    def t(g):
        r = ab(fn, list(range(n)))
        check(not r['errors'], 'scenario error', **r)
        check(not r['diffs'], 'v0.9 and HEAD traces differ', **r)
        return r
    t.__name__ = t.__qualname__ = 'battle_ab_' + name
    return test(SUITE)(t)


for _n, (_f, _k) in SCENARIOS.items():
    globals()['battle_ab_' + _n] = _make_ab(_n, _f, _k)


@test(SUITE)
def battle_ab_determinism(g):
    """Control for the differential: HEAD with different input timing gives the same trace."""
    fn = SCENARIOS['damage_crit'][0]
    a, _ = run_tree('head', fn, 1)
    b, _ = run_tree('head', fn, 1, delay=7)
    d = DB.diff_traces(a, b)
    check(not d, 'HEAD trace depends on input timing', diff=d[:3])
    return {'turns': len(a)}


@test(SUITE)
def battle_ab_shift_prompt_v09_control(g):
    """Control: v0.9 with the Shift option asks to switch on a trainer KO; HEAD with the same byte
    doesn't. Proves the switch-prompt test can see the prompt."""
    out = {}
    for tree in ('v09', 'head'):
        _TREE[0] = tree
        DB.C = C
        gg = fixtures.fixture('debug_party', rom=det_rom(tree))
        try:
            r = TRun(gg, 0)
            r.start([M(moves=['SCRATCH'], level=50), M('PIDGEY', moves=['SCRATCH'])], trainer=('FALKNER', 1),
                    setup=lambda r: DB.set_side(r, 'player', hp=BIG, maxhp=BIG, atk=999, df=60, speed=999, item=0))
            gg.write('wOptions', gg.read('wOptions') & ~(1 << C('BATTLE_SHIFT')) & 0xff)
            gg.write('wBattleMenuCursorPosition', 1)
            gg.run_until('InterpretBattleMenu', 300)
            r._tap('MoveSelectionScreen')
            gg.write('wCurMoveNum', 0)
            gg.run_until('MoveSelectionScreen.interpret_joypad', 300)
            r._tap('DetermineMoveOrder')
            gg.events = []
            hit = advance_watch(gg, ['LoadBattleMenu', 'CleanUpBattleRAM'] + list(PROMPT), max_frames=6000)
            out[tree] = dict(stop=hit, texts=gg.events)
        finally:
            gg.close()
    check(out['v09']['stop'] in PROMPT, 'control failed: v0.9 Shift did not prompt', **out)
    check(out['head']['stop'] == 'LoadBattleMenu', 'HEAD prompted or stalled', **out)
    return out

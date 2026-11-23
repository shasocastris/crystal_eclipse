"""v1.0 audit: a save made on v0.9 loaded on this ROM (save compatibility).

The source ROM is always v0.9 (AUDIT_SRC_ROM / AUDIT_SRC_REPO override it). Run against the HEAD
ROM this is the upgrade test; run against the v0.9 ROM it is the control (v0.9 -> v0.9).
"""
import os
import re
import subprocess
import tempfile

from fixtures import fixture, mash_until_control, in_control
from gb import Game, HERE
from registry import check, test
from suite_save import save_via_menu, VOLATILE
from visual import text_rows

SCRATCH = '/tmp/claude-1000/-home-bryan-Documents-Romhacks-crystal-eclipse/4203bf99-da66-490e-998d-1f337047b4f7/scratchpad'
SRC_ROM = os.environ.get('AUDIT_SRC_ROM', SCRATCH + '/roms/v09/crystal_eclipse_debug.gbc')
SRC_REPO = os.environ.get('AUDIT_SRC_REPO', SCRATCH + '/wt/v09')
OUT = os.path.join(HERE, '..', 'v10', 'audit')

_cc = {}


def consts_of(repo, path, prefix):
    """{name: value} for every `const PREFIX...` in repo/path, resolved by rgbasm in that tree."""
    key = (repo, path, prefix)
    if key in _cc:
        return _cc[key]
    names = re.findall(r'^\s*const\s+(%s\w*)' % prefix, open(os.path.join(repo, path)).read(), re.M)
    src = os.path.join(repo, '_audit_consts.asm')
    with open(src, 'w') as f:
        f.write('INCLUDE "includes.asm"\n' + ''.join('PRINTLN "%s=", %s\n' % (n, n) for n in names))
    try:
        out = subprocess.run(['rgbasm', '-D', '_DEBUG', '-Q8', '-o', os.devnull, src],
                             cwd=repo, capture_output=True, text=True).stdout
    finally:
        os.unlink(src)
    _cc[key] = {m[1]: int(m[2], 16) for m in re.finditer(r'^(\w+)=\$?([0-9A-Fa-f]+)$', out, re.M)}
    return _cc[key]


def rom_tag(g):
    """Screenshot tag: 'control' on the source ROM, else the ROM's directory name (head, audit-fix...)."""
    if os.path.abspath(g.rom) == os.path.abspath(SRC_ROM):
        return 'control'
    return os.path.basename(os.path.dirname(os.path.abspath(g.rom)))


def flag(g, n):
    return bool(g.read('wEventFlags+%d' % (n // 8)) & (1 << (n % 8)))


def set_flag(g, n):
    lab = 'wEventFlags+%d' % (n // 8)
    g.write(lab, g.read(lab) | (1 << (n % 8)))


def boot_continue(rom, bat):
    g = Game(rom=rom, battery=bat, render=True)
    for _ in range(60):
        if g.run_until('MainMenu', 120):
            break
        g.press('start', after=10)
    else:
        raise AssertionError('never reached MainMenu')
    g.frames(40)
    menu = text_rows(g)
    return g, menu


def snapshot(g):
    """Semantic view of the save: map, party (species/move indices), bag, money, options."""
    s = {k: g.read(k) for k in ('wMapGroup', 'wMapNumber', 'wXCoord', 'wYCoord', 'wPartyCount',
                                'wOptions', 'wOptions2', 'wTextboxFrame', 'wSeason')}
    s['money'] = g.read('wMoney', 3)
    s['badges'] = g.read('wJohtoBadges', 2)
    s['party'] = [g.call('GetPokemonIndexFromID', a=g.read('wPartySpecies+%d' % i))['hl']
                  for i in range(s['wPartyCount'])]
    n = g.read('wNumItems')
    raw = g.read('wItems', 3 * n)  # id, 16-bit quantity
    s['items'] = [(g.call('GetItemIndexFromID', a=raw[3 * i])['hl'], raw[3 * i + 1:3 * i + 3]) for i in range(n)]
    k = g.read('wNumKeyItems')
    s['key_items'] = g.read('wKeyItems', k) if k else []  # raw: the pocket does not hold runtime IDs
    s['mon1_moves'] = [g.call('GetMoveIndexFromID', a=m)['hl'] for m in g.read('wPartyMon1Moves', 4)]
    return s


@test('v10_audit')
def audit_v09_save_loads(g):
    """Save on v0.9 (debug party, SHIFT battle style, a few beaten trainers), CONTINUE on this ROM:
    map, party, bag, options and every named event flag must come through; walking and re-saving work."""
    os.makedirs(OUT, exist_ok=True)
    tag = rom_tag(g)
    tgt_rom = g.rom  # g stays open: the runner screenshots it on failure
    ev_src = consts_of(SRC_REPO, 'constants/event_flags.asm', 'EVENT_')
    from gb import REPO
    ev_tgt = consts_of(REPO, 'constants/event_flags.asm', 'EVENT_')

    src = fixture('debug_party', rom=SRC_ROM, render=True)
    # a v0.9 player who chose SHIFT, and beat some trainers whose flags sit after Kimono Girl Yuki
    src.write('wOptions', src.read('wOptions') & ~(1 << 6) & 0xff)
    beaten = ['EVENT_BEAT_POKEMANIAC_LARRY', 'EVENT_BEAT_SAGE_KOJI', 'EVENT_BEAT_BIRD_KEEPER_TOBY',
              'EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS']
    for n in beaten:
        set_flag(src, ev_src[n])
    check(in_control(src), 'source not in control')
    before = snapshot(src)
    save_via_menu(src)
    s0, e0 = src.syms['wGameData'][1], src.syms['wGameDataEnd'][1]
    raw_before = src.read((1, s0), e0 - s0)
    src_flags = {n: flag(src, v) for n, v in ev_src.items()}
    with tempfile.TemporaryDirectory() as d:
        bat = os.path.join(d, 'v09.sav')
        src.save_battery(bat)
        src.close()
        tg, menu = boot_continue(tgt_rom, bat)
        tg.screenshot(os.path.join(OUT, 'save_%s_main_menu.png' % tag))
        check(any('CONTINUE' in r for r in menu), 'v0.9 save rejected: no CONTINUE', screen=menu)
        tg.press('a', after=30)
        check(mash_until_control(tg), 'CONTINUE on a v0.9 save never reached the overworld')
        tg.screenshot(os.path.join(OUT, 'save_%s_continued.png' % tag))
        after = snapshot(tg)
        s1, e1 = tg.syms['wGameData'][1], tg.syms['wGameDataEnd'][1]
        raw_after = tg.read((1, s1), e1 - s1)
        flag_diffs = []
        for n, v in ev_tgt.items():
            if n in src_flags and src_flags[n] != flag(tg, v):
                flag_diffs.append('%s %d->%d' % (n, src_flags[n], flag(tg, v)))
        new_set = [n for n, v in ev_tgt.items() if n not in src_flags and flag(tg, v)]
        # walk around the bedroom, then save again on this ROM and reload that
        for k in ('down', 'down', 'left', 'right', 'up', 'up'):
            tg.press(k, hold=16, after=16)
            check(in_control(tg, 120), 'lost control walking after load', key=k)
        save_via_menu(tg)
        bat2 = os.path.join(d, 'resaved.sav')
        tg.save_battery(bat2)
        tg.close()
        tg2, menu2 = boot_continue(tgt_rom, bat2)
        check(any('CONTINUE' in r for r in menu2), 're-saved file rejected', screen=menu2)
        tg2.press('a', after=30)
        check(mash_until_control(tg2), 're-saved file never reached the overworld')
        tg2.close()
    sem = {k: (before[k], after[k]) for k in before if before[k] != after[k]}
    raw = ['$%04x %d->%d' % (s0 + i, x, y) for i, (x, y) in enumerate(zip(raw_before, raw_after)) if x != y]
    detail = {'semantic_diffs': sem, 'flag_diffs': flag_diffs, 'new_flags_set': new_set,
              'raw_byte_diffs': len(raw), 'raw_sample': raw[:20], 'options': after['wOptions'],
              'party': after['party'], 'items': len(after['items'])}
    check(not sem and not flag_diffs, 'v0.9 save did not carry over cleanly', **detail)
    return detail


@test('v10_audit')
def audit_v09_save_ruins_of_alph(g):
    """Fresh v0.9 debug-party save (no Ruins quest done) on this ROM: the Ruins of Alph Rocket
    executives and Suicune (hide flag set at new game) must stay hidden outside the Ruins."""
    os.makedirs(OUT, exist_ok=True)
    tag = rom_tag(g)
    from gb import REPO
    from overworld import warp, settle
    ev_tgt = consts_of(REPO, 'constants/event_flags.asm', 'EVENT_')
    src = fixture('debug_party', rom=SRC_ROM)
    check(in_control(src), 'source not in control')
    save_via_menu(src)
    with tempfile.TemporaryDirectory() as d:
        bat = os.path.join(d, 'v09.sav')
        src.save_battery(bat)
        src.close()
        tg, menu = boot_continue(g.rom, bat)
        tg.press('a', after=30)
        check(mash_until_control(tg), 'CONTINUE never reached the overworld')
    names = ['EVENT_RUINS_OF_ALPH_ROCKETS', 'EVENT_RUINS_OF_ALPH_OUTSIDE_EXECUTIVES',
             'EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS', 'EVENT_ICE_PATH_1F_RIVAL']
    flags = {n: flag(tg, ev_tgt[n]) for n in names}
    warp(tg, 'RUINS_OF_ALPH_OUTSIDE', 12, 34)
    settle(tg)
    tg.frames(30)
    tg.screenshot(os.path.join(OUT, 'ruins_outside_%s.png' % tag))
    tg.close()
    check(flags['EVENT_RUINS_OF_ALPH_OUTSIDE_EXECUTIVES'] and not flags['EVENT_RUINS_OF_ALPH_ROCKETS']
          and flags['EVENT_ICE_PATH_1F_RIVAL'],
          'v0.9 save: Ruins/Ice Path story flags read wrong on this ROM', **flags)
    return flags

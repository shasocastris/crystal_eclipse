"""Save, reload and main-menu checks through the real menus."""
import os
import tempfile

from fixtures import mash_until_control
from gb import Game
from registry import check, test
from visual import FRAME_TILES, text_rows, tilemap

# bytes that legitimately change between "just saved" and "continued": play-time frames,
# the walking animation counter, and the roamer's current map (set when the map loads)
VOLATILE = {'wGameTimeFrames', 'wPlayerStepFrame', 'wRoamMons_CurMapNumber', 'wRoamMons_CurMapGroup'}


def save_via_menu(g):
    """START -> SAVE -> yes, then back to the overworld."""
    g.press('start', after=30)
    rows = text_rows(g)
    check(any('SAVE' in r for r in rows), 'SAVE not in the start menu', screen=rows)
    for _ in range(5):
        g.press('down', after=6)
    g.press('a', after=40)
    check(mash_until_control(g), 'save flow never returned control')


def boot_to_main_menu(battery, render=True):
    g = Game(battery=battery, render=render)
    for _ in range(60):
        if g.run_until('MainMenu', 120):
            break
        g.press('start', after=10)
    else:
        raise AssertionError('never reached MainMenu')
    g.frames(40)
    return g


def continue_game(g):
    g.press('a', after=30)
    check(mash_until_control(g), 'continue never reached the overworld')


def _labels(g, start, end):
    labs = sorted((a, n) for n, (b, a) in g.syms.items() if b == 1 and start <= a < end and '.' not in n)
    return labs


def _label_at(labs, a):
    best = labs[0]
    for x in labs:
        if x[0] > a:
            break
        best = x
    return best[1], a - best[0]


@test('save')
def save_and_continue_roundtrip(g):
    """Save through the menu, boot a fresh console from the battery, CONTINUE: all saved WRAM matches."""
    save_via_menu(g)
    s, e = g.syms['wGameData'][1], g.syms['wGameDataEnd'][1]
    before = g.read((1, s), e - s)
    with tempfile.TemporaryDirectory() as d:
        bat = os.path.join(d, 'a.sav')
        g.save_battery(bat)
        g2 = boot_to_main_menu(bat)
        menu = text_rows(g2)
        check(any('CONTINUE' in r for r in menu), 'no CONTINUE on the main menu (save rejected?)', screen=menu)
        continue_game(g2)
        # let the reloaded objects run once: the follower's StepType is RESET until its first frame
        g2.frames(2)
        after = g2.read((1, s), e - s)
        labs = _labels(g, s, e)
        bad = []
        for i, (x, y) in enumerate(zip(before, after)):
            if x != y:
                name, off = _label_at(labs, s + i)
                if name not in VOLATILE:
                    bad.append('%s+%d %d->%d' % (name, off, x, y))
        g2.close()
    check(not bad, 'saved data differs after reload', diffs=bad[:40])
    return {'bytes_compared': e - s}


# SRAM areas a normal save must not touch: Hall of Fame, GS Ball flag + backup, Battle Tower
SEEDS = [('sHallOfFame', 'sHallOfFameEnd'), ('sGSBallFlag', 'sCrystalData'),
         ('sGSBallFlagBackup', 'sBattleTowerChallengeState'), ('sBattleTowerChallengeState', 'sBTMonOfTrainers+12')]


@test('save')
def save_keeps_hof_gsball_tower_sram(g):
    """Seed Hall of Fame, GS Ball and Battle Tower SRAM in the battery; a save must leave them as they were."""
    save_via_menu(g)
    with tempfile.TemporaryDirectory() as d:
        bat = os.path.join(d, 'a.sav')
        g.save_battery(bat)
        data = bytearray(open(bat, 'rb').read())
        ranges = []
        for lo, hi in SEEDS:
            b, a0 = g.addr(lo)
            _, a1 = g.addr(hi)
            off = b * 0x2000 + a0 - 0xa000
            for i in range(a1 - a0):
                # the flag and its backup must agree: loading restores the flag from the backup
                data[off + i] = 0xa5 if lo.startswith('sGSBall') else (0x5a + 7 * i + a0) & 0xff
            ranges.append((lo, off, a1 - a0))
        seeded = bytes(data)
        open(bat, 'wb').write(seeded)
        g2 = boot_to_main_menu(bat, render=False)
        continue_game(g2)
        save_via_menu(g2)
        bat2 = os.path.join(d, 'b.sav')
        g2.save_battery(bat2)
        g2.close()
        out = open(bat2, 'rb').read()
    bad = [lo for lo, off, n in ranges if out[off:off + n] != seeded[off:off + n]]
    check(not bad, 'a save changed protected SRAM', regions=bad)
    return {'regions': [r[0] for r in ranges], 'bytes': sum(r[2] for r in ranges)}


@test('save')
def main_menu_lists_and_border(g):
    """Fresh battery: NEW GAME/OPTION only; after a save: CONTINUE first. Menu box uses frame tiles."""
    with tempfile.TemporaryDirectory() as d:
        empty = boot_to_main_menu(None)
        rows0 = text_rows(empty)
        img0 = empty.screenshot(os.path.join(g.shots, 'main_menu_new.png'))
        tm0 = tilemap(empty)
        empty.close()
        save_via_menu(g)
        bat = os.path.join(d, 'a.sav')
        g.save_battery(bat)
        g2 = boot_to_main_menu(bat)
        rows1 = text_rows(g2)
        g2.screenshot(os.path.join(g.shots, 'main_menu_continue.png'))
        g2.close()
    check(any('NEW GAME' in r for r in rows0) and not any('CONTINUE' in r for r in rows0),
          'fresh main menu wrong', screen=rows0)
    items = [r for r in rows1 if any(w in r for w in ('CONTINUE', 'NEW GAME', 'OPTION'))]
    check(len(items) >= 3 and 'CONTINUE' in items[0], 'saved main menu wrong', screen=rows1)
    # box border: corner and edge are frame tiles, and the top edge (y=3) is drawn dark
    check(tm0[0][0] in FRAME_TILES and tm0[0][1] in FRAME_TILES, 'menu box border tiles missing', row0=tm0[0][:4])
    px = img0.getpixel((8, 3))
    check(sum(px) < 300, 'border top edge not drawn', pixel=px)
    return {'fresh': [r.strip() for r in rows0 if r.strip()], 'saved': [r.strip() for r in items]}

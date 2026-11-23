"""Throwaway repro: door and water warps vs stale scratch RAM (bike after a door, branch 76)."""
import os
from consts import resolve, value
from overworld import settle, warp
from registry import check, test


def _where(g):
    return {'map': (g.read('wMapGroup'), g.read('wMapNumber')), 'xy': (g.read('wXCoord'), g.read('wYCoord')),
            'state': g.read('wPlayerState'), 'pending': g.read('wWaterWarpState')}


def _stale(g):
    # what a trainer battle and the Good Rod leave behind
    g.write('wWinTextPointer', [0x34, 0x55])
    g.write('wSurfingPlayerState', value('PLAYER_BIKE'))


@test('repro')
def door_after_battle_leftovers(g):
    """Stale scratch bytes no longer put the player on the bike through a door."""
    warp(g, 'ROUTE_23', 10, 6)
    _stale(g)
    g.press('up', hold=20, after=4)
    settle(g, 1200)
    w = _where(g)
    v = resolve('GROUP_INDIGO_PLATEAU_POKECENTER_1F', 'MAP_INDIGO_PLATEAU_POKECENTER_1F')
    check(w['map'] == (v['GROUP_INDIGO_PLATEAU_POKECENTER_1F'], v['MAP_INDIGO_PLATEAU_POKECENTER_1F']), 'door not taken', **w)
    check(w['state'] == value('PLAYER_NORMAL'), 'door warp changed the player state', **w)
    return w


@test('repro')
def water_warp_keeps_surfing(g):
    """Surfing through the Route 45 water warp still arrives surfing, whatever scratch RAM holds."""
    warp(g, 'ROUTE_45', 16, 88, surf=True)
    _stale(g)
    for _ in range(2):
        g.press('right', hold=20, after=4)
        settle(g, 1200)
    w = _where(g)
    v = resolve('GROUP_BLACKTHORN_PASS', 'MAP_BLACKTHORN_PASS')
    check(w['map'] == (v['GROUP_BLACKTHORN_PASS'], v['MAP_BLACKTHORN_PASS']), 'water warp not taken', **w)
    check(w['state'] == value('PLAYER_SURF'), 'not surfing after the water warp', **w)
    check(w['pending'] == 0, 'water warp state left pending', **w)
    return w


def _beast_frames(g, map_name, x, y, fought, name):
    from PIL import Image
    from game import set_event

    def before(g):
        set_event(g, 'EVENT_BEAT_ELITE_FOUR')
        set_event(g, fought, False)
        g.write('wStatusFlags', g.read('wStatusFlags') | 1 << value('STATUSFLAGS_FLASH_F'))
    g.render(True)
    warp(g, map_name, x, y, before=before)
    crops = []
    for _ in range(12):
        g.frames(6)
        crops.append(g.screenshot().crop((48, 16, 112, 80)))  # the 4x4 tiles around the beast
    sheet = Image.new('RGB', (64 * 12, 64))
    for i, c in enumerate(crops):
        sheet.paste(c, (64 * i, 0))
    sheet = sheet.resize((64 * 12 * 2, 128), Image.NEAREST)
    sheet.save(os.path.join(g.shots, name + '.png'))
    distinct = len({c.tobytes() for c in crops})
    return {'distinct_frames': distinct}


@test('repro')
def entei_sprite_frames(g):
    """Entei in Dark Cave: twelve frames, 6 apart, saved as a strip to judge by eye."""
    return _beast_frames(g, 'DARK_CAVE_BLACKTHORN_ENTRANCE', 15, 12, 'EVENT_FOUGHT_ENTEI', 'entei_frames')


@test('repro')
def raikou_sprite_frames(g):
    """Raikou in Burned Tower B1F: twelve frames, 6 apart, saved as a strip to judge by eye."""
    return _beast_frames(g, 'BURNED_TOWER_B1F', 7, 5, 'EVENT_FOUGHT_RAIKOU', 'raikou_frames')


# --- Repel: wRepelType holds 1-3 (Repel/Super/Max), so it survives a save ---
REPELS = {'REPEL': (1, 100), 'SUPER_REPEL': (2, 200), 'MAX_REPEL': (3, 250)}
SHASOCASTRIS_SAV = '/tmp/claude-1000/-home-bryan-Documents-Romhacks-crystal-eclipse/2d70e333-cae6-412c-bf2d-cf4827cd6419/scratchpad/bryan_bt.sav'


def _reload(g):
    import tempfile
    from suite_save import boot_to_main_menu, continue_game, save_via_menu
    save_via_menu(g)
    d = tempfile.mkdtemp()
    bat = os.path.join(d, 'a.sav')
    g.save_battery(bat)
    g2 = boot_to_main_menu(bat)
    continue_game(g2)
    return g2


def _step(g, direction):
    g.press(direction, hold=16, after=4)


@test('repro')
def repel_reuse_survives_save(g):
    """For each Repel: one step left, save, reload, step. "Use another?" yes uses the same kind again."""
    from overworld import answer, finish, item_qty, set_item, wait_for
    out = {}
    base = None
    for item, (kind, steps) in REPELS.items():
        if base is None:
            warp(g, 'ROUTE_23', 10, 6)
            base = g.state()
        g.load(base)
        set_item(g, item, 2)
        g.write('wRepelEffect', 1)
        g.write('wRepelType', kind)
        g2 = _reload(g)
        try:
            _step(g2, 'left')
            check(wait_for(g2, 'YesNoBox'), '"Use another?" never asked', item=item)
            answer(g2, yes=True)
            check(finish(g2), 'no control after reusing', item=item)
            r = out[item] = dict(effect=g2.read('wRepelEffect'), type=g2.read('wRepelType'), qty=item_qty(g2, item))
        finally:
            g2.close()
        check(r == dict(effect=steps, type=kind, qty=1), 'wrong Repel reused', item=item, **r)
    return out


@test('repro')
def repel_old_id_wears_off(g):
    """An old save's item ID in wRepelType (21 here) just wears off: no yes/no, control returns."""
    from overworld import finish, set_item
    from visual import text_rows
    warp(g, 'ROUTE_23', 10, 6)
    set_item(g, 'REPEL', 2)
    g.write('wRepelEffect', 1)
    g.write('wRepelType', 21)
    _step(g, 'left')
    g.frames(90)
    rows = text_rows(g)
    check(any('wore off' in r for r in rows), '"wore off" not shown', screen=rows)
    check(not any('another' in r for r in rows), 'offered another Repel for a dead ID', screen=rows)
    check(finish(g), 'no control after the text')
    check(g.read('wRepelEffect') == 0, 'Repel still active')
    return {'screen': [r for r in rows if r.strip('·')][-4:]}


@test('repro')
def repel_shasocastris_bt_save(g):
    """shasocastris's post-Battle-Tower save (Repel at 2 steps, dead ID 21): two steps, text, then walk out."""
    from registry import Skip
    from overworld import finish
    from suite_save import boot_to_main_menu, continue_game
    import shutil
    import tempfile
    if not os.path.exists(SHASOCASTRIS_SAV):
        raise Skip('save copy not present')
    d = tempfile.mkdtemp()
    sav = os.path.join(d, 'b.sav')
    shutil.copy(SHASOCASTRIS_SAV, sav)
    g2 = boot_to_main_menu(sav)
    try:
        continue_game(g2)
        for _ in range(2):
            _step(g2, 'down')
            g2.frames(30)
        check(finish(g2), 'no control after the Repel text (still hangs?)')
        _step(g2, 'down')
        settle(g2, 1200)
        v = resolve('GROUP_BATTLE_TOWER_OUTSIDE', 'MAP_BATTLE_TOWER_OUTSIDE')
        at = (g2.read('wMapGroup'), g2.read('wMapNumber'))
        check(at == (v['GROUP_BATTLE_TOWER_OUTSIDE'], v['MAP_BATTLE_TOWER_OUTSIDE']), 'did not walk out', at=at)
        return {'repel_effect': g2.read('wRepelEffect'), 'map': at}
    finally:
        g2.close()

"""Overworld weather checks (weather_seasons_finalization.md §3 A/B). Weather is forced through the
map-attributes byte at SetCurrentWeather; maps are reached with a private RAM warp."""
import os
import tempfile

from consts import resolve, value
from game import rom_byte, set_event
from registry import check, test
from suite_save import boot_to_main_menu, continue_game, save_via_menu
from visual import diff

W = {'none': 0, 'rain': 1, 'snow': 2, 'thunder': 3, 'sand': 4, 'blossom': 5, 'sun': 6}
LIGHTNING_OFF = 1 << 2  # OW_WEATHER_LIGHTNING_DISABLED_F
DO_FLY = 1 << 0         # OW_WEATHER_DO_FLY_F


def map_id(name):
    v = resolve('GROUP_' + name, 'MAP_' + name)
    return v['GROUP_' + name], v['MAP_' + name]


def warp(g, name, x, y, weather=None, season=None):
    """RAM warp (scene_routes.md §1). weather: a W key forced via wMapWeather; None lets the map decide."""
    check(g.run_until('OverworldLoop.loop', 120), 'overworld loop not reached before warp')
    grp, num = map_id(name)
    g.write('wMapGroup', grp)
    g.write('wMapNumber', num)
    g.write('wXCoord', x)
    g.write('wYCoord', y)
    g.write('wDefaultSpawnpoint', 0xff)
    g.write('hMapEntryMethod', 0xf1)
    if season is not None:
        g.write('wSeason', season)
    if weather == 'none':
        set_event(g, 'EVENT_AZALEA_TOWN_SLOWPOKES', False)  # the daily roll then gives nothing
    g.write('wMapStatus', 1)
    if weather not in (None, 'none'):
        check(g.run_until('SetCurrentWeather', 300), 'SetCurrentWeather never ran')
        g.write('wMapWeather', W[weather])
    settle(g)


def settle(g):
    for _ in range(300):
        if g.run_until('OverworldLoop.loop', 30) and g.read('wMapStatus') == 2 and not g.read('wScriptRunning'):
            break
    else:
        raise AssertionError('map never settled')
    g.frames(10)
    check(g.run_until('PlayerEvents', 60), 'not back at PlayerEvents')


def oam(g):
    raw = g.read(g.addr('wShadowOAM'), 160)
    return [tuple(raw[i * 4:i * 4 + 4]) for i in range(40)]


def visible(e):
    return 0 < e[0] < 160 and 0 < e[1] < 168


def weather_tiles():
    t = value('FIRST_VRAM1_OBJECT_STRUCT') * 12
    return {t, t + 1}


def shot(g, name):
    return g.screenshot(os.path.join(g.shots, name + '.png'))


def wait_sign_gone(g, limit=600):
    for _ in range(limit // 10):
        if not g.read('wWeatherFlags') & LIGHTNING_OFF:
            return True
        g.frames(10)
    return False


@test('weather')
def particles_own_oam_0_to_11(g):
    """Goldenrod thunderstorm: OAM 0-11 hold only particles, map objects start at 12, tiles are in VRAM."""
    g.render(True)
    warp(g, 'GOLDENROD_CITY', 14, 22, weather='thunder')
    wt = weather_tiles()
    seen, bad = 0, []
    for f in range(120):
        g.frames(1)
        o = oam(g)
        for i, e in enumerate(o):
            if not visible(e):
                continue
            if i < 12:
                seen += 1
                if e[2] not in wt:
                    bad.append((f, i, e))
            elif e[2] in wt:
                bad.append((f, i, e))
    check(g.read('wCurWeather') == W['thunder'], 'weather not applied', cur=g.read('wCurWeather'))
    check(g.read('wStateFlags') & (1 << value('FIRST_12_SPRITE_OAM_STRUCTS_RESERVED_F')), 'OAM 0-11 not reserved')
    check(not bad, 'particles and objects mixed in OAM', first=bad[:5])
    check(seen > 120, 'too few particles drawn', particle_frames=seen)
    gfx = g.read(0x8000 + min(wt) * 16, 32)
    check(any(gfx), 'weather tiles are blank in VRAM (graphics bank move?)')
    shot(g, 'weather_goldenrod_thunder')
    return {'particle_slots_seen_120f': seen}


def count_hits(g, label, frames):
    end = g.frame + frames
    n = 0
    while g.frame < end:
        if g.run_until(label, max(1, end - g.frame)):
            n += 1
    return n


@test('weather')
def goldenrod_heavy_rain_keeps_npcs(g):
    """Rain vs none at three Goldenrod spots: _UpdateSprites never runs out of OAM (no NPC dropped)."""
    base = g.state()
    out = {}
    for x, y in [(14, 22), (19, 18), (24, 28)]:
        for wx in ('none', 'rain'):
            g.load(base)
            warp(g, 'GOLDENROD_CITY', x, y, weather=wx)
            full = count_hits(g, 'InitSprites.full', 600)
            objs = sum(1 for e in oam(g)[12 if wx != 'none' else 0:] if visible(e))
            out['%d,%d %s' % (x, y, wx)] = {'oam_full_hits': full, 'object_oam_entries': objs}
            check(full == 0, 'map objects ran out of OAM (NPC disappears)', spot=(x, y), weather=wx, hits=full)
    return out


def _lightning_points(g):
    nl = g.addr('DoOverworldRain.no_lightning')
    cp1, cp2 = (nl[0], nl[1] - 12), (nl[0], nl[1] - 5)
    lb, la = g.addr('Lightning')
    flash = (lb, la + 9)
    check(rom_byte(g, cp1)[0] == 0xfe and rom_byte(g, cp2)[0] == 0xfe and rom_byte(g, flash)[0] == 0xcd,
          'lightning roll layout changed; update offsets')
    return cp1, cp2, flash


def force_strikes(g, frames, pts):
    """Make every lightning roll succeed for `frames`. Returns [(lightning-off flag set, flashed)]."""
    cp1, cp2, flash = pts
    end = g.frame + frames
    res = []
    while g.frame < end:
        if not g.run_until(cp1, max(1, end - g.frame)):
            break
        off = bool(g.read('wWeatherFlags') & (LIGHTNING_OFF | DO_FLY))
        g.set_reg('af', g.reg('af') & 0xff)  # a = 0: the roll succeeds
        if not g.run_until(cp2, 1):
            continue
        g.set_reg('af', g.reg('af') & 0xff)
        res.append((off, g.run_until(flash, 1)))
    return res


@test('weather')
def lightning_off_during_sign_and_fly(g):
    """Every lightning roll forced to strike: none flash while the map-name sign is up or DO_FLY is set,
    and they do flash once the sign has gone (control)."""
    g.render(True)
    pts = _lightning_points(g)
    warp(g, 'GOLDENROD_CITY', 14, 22, weather='thunder')
    check(g.read('wWeatherFlags') & LIGHTNING_OFF, 'map-name sign did not disable lightning')
    shot(g, 'weather_sign_thunder')
    during = []
    while g.read('wWeatherFlags') & LIGHTNING_OFF:
        r = force_strikes(g, 10, pts)
        during += [x for x in r if x[0]]
        check(len(during) < 2000, 'sign never went away')
    after = force_strikes(g, 120, pts)
    g.write('wWeatherFlags', g.read('wWeatherFlags') | DO_FLY)
    fly = force_strikes(g, 60, pts)
    g.write('wWeatherFlags', g.read('wWeatherFlags') & ~DO_FLY & 0xff)
    res = {'sign_rolls': len(during), 'sign_flashes': sum(f for _, f in during),
           'after_rolls': len(after), 'after_flashes': sum(f for _, f in after),
           'fly_rolls': len(fly), 'fly_flashes': sum(f for _, f in fly)}
    check(res['sign_rolls'] > 10, 'too few rolls while the sign was up', **res)
    check(res['sign_flashes'] == 0, 'lightning flashed during the map-name sign', **res)
    check(res['after_flashes'] > 0, 'control: forced strikes never flashed', **res)
    check(res['fly_flashes'] == 0, 'lightning flashed with DO_FLY set', **res)
    return res


@test('weather')
def overcast_survives_save_and_reload(g):
    """Pick a daily seed that makes Goldenrod wet, enter it, save, reload: same weather, same seed."""
    set_event(g, 'EVENT_AZALEA_TOWN_SLOWPOKES', True)
    warp(g, 'GOLDENROD_CITY', 14, 22)
    day = g.read('wCurDay')
    seed = None
    for s in range(256):
        g.write('wOvercastRandomDay', day)
        g.write('wOvercastSeed', s)
        grp, num = map_id('GOLDENROD_CITY')
        args = dict(bc=grp << 8 | num, de=value('TOWN') << 8 | value('JOHTO_REGION'))
        if g.call('GetOvercastWeather', **args)['a'] in (W['rain'], W['thunder']):
            seed = s
            break
    check(seed is not None, 'no seed makes Goldenrod wet')
    warp(g, 'GOLDENROD_CITY', 14, 23)  # re-enter so SetCurrentWeather rolls with this seed
    want = g.read('wCurWeather')
    check(want in (W['rain'], W['thunder']), 'rolled weather not applied', cur=want, seed=seed)
    wait_sign_gone(g)
    save_via_menu(g)
    with tempfile.TemporaryDirectory() as d:
        bat = os.path.join(d, 'a.sav')
        g.save_battery(bat)
        g2 = boot_to_main_menu(bat)
        continue_game(g2)
        g2.frames(60)
        got = dict(cur=g2.read('wCurWeather'), seed=g2.read('wOvercastSeed'), day=g2.read('wOvercastRandomDay'),
                   map=(g2.read('wMapGroup'), g2.read('wMapNumber')))
        g2.screenshot(os.path.join(g.shots, 'weather_after_reload.png'))
        parts = sum(1 for e in oam(g2)[:12] if visible(e) and e[2] in weather_tiles())
        g2.close()
    check(got['map'] == map_id('GOLDENROD_CITY'), 'reloaded somewhere else', **got)
    check(got['seed'] == seed, 'overcast seed not saved', want=seed, **got)
    check(got['cur'] == want, 'weather changed across save/reload', want=want, **got)
    check(parts > 0, 'no particles after reload', **got)
    return dict(seed=seed, weather=want, particles_after_reload=parts)


@test('weather')
def lag_frames_max_particles(g):
    """OverworldLoop iterations over 600 frames, Goldenrod with rain vs none; lag = frames - iterations."""
    base = g.state()
    out = {}
    for wx in ('none', 'rain', 'snow'):
        g.load(base)
        warp(g, 'GOLDENROD_CITY', 19, 18, weather=wx)
        wait_sign_gone(g)
        g.frames(60)
        it = count_hits(g, 'OverworldLoop.loop', 600)
        out[wx] = {'iterations': it, 'lag_frames': 600 - it}
    worst = max(out['rain']['lag_frames'], out['snow']['lag_frames'])
    check(worst <= out['none']['lag_frames'] + 6, 'weather adds lag frames', **out)
    return out


@test('weather')
def olivine_restaurant_no_snow(g):
    """Winter vs summer: Olivine City looks different (control); the restaurant background is identical
    and has no weather. Sprites may differ: winter's shorter day can make the hour MORN (rtc.asm)."""
    g.render(True)
    set_event(g, 'EVENT_AZALEA_TOWN_SLOWPOKES', True)
    base = g.state()
    imgs, bg, sprites = {}, {}, {}
    for season in (1, 3):
        for name, x, y in [('OLIVINE_CITY', 19, 18), ('OLIVINE_RESTAURANT', 3, 6)]:
            g.load(base)
            warp(g, name, x, y, season=season)
            wait_sign_gone(g)
            g.frames(30)
            key = '%s_%s' % (name.lower(), 'winter' if season == 3 else 'summer')
            imgs[key] = shot(g, 'weather_' + key)
            if name == 'OLIVINE_RESTAURANT':
                check(g.read('wCurWeather') == 0, 'weather inside the restaurant', season=season,
                      cur=g.read('wCurWeather'))
                check(not any(visible(e) and e[2] in weather_tiles() for e in oam(g)), 'particles indoors')
                bg[season] = (g.read('wBGPals1', 64), g.read('wTilemap', 360), g.read('wAttrmap', 360))
                sprites[season] = [(e[1] - 8, e[0] - 16) for e in oam(g) if visible(e)]
    city, _ = diff(imgs['olivine_city_summer'], imgs['olivine_city_winter'])
    a, b = imgs['olivine_restaurant_summer'], imgs['olivine_restaurant_winter']
    rects = sprites[1] + sprites[3]
    off_sprite = [(x, y) for x in range(160) for y in range(144) if a.getpixel((x, y)) != b.getpixel((x, y))
                  and not any(sx <= x < sx + 8 and sy <= y < sy + 16 for sx, sy in rects)]
    rest, _ = diff(a, b, out=os.path.join(g.shots, 'weather_restaurant_diff.png'))
    check(city > 500, 'control: winter did not change Olivine City', pixels=city)
    check(bg[1] == bg[3], 'restaurant BG palettes/tiles differ in winter')
    check(not off_sprite, 'restaurant background pixels differ in winter', pixels=len(off_sprite), first=off_sprite[:5])
    return {'city_pixels_changed': city, 'restaurant_sprite_pixels_changed': rest}


ROMS_DIR = os.environ.get('BASELINE_ROMS', '/tmp/claude-1000/-home-bryan-Documents-Romhacks-crystal-eclipse/'
                          '2d70e333-cae6-412c-bf2d-cf4827cd6419/scratchpad/roms')


def _mask_hud(img):
    """Blank the player's HP numbers: the debug party's stats differ between builds."""
    from PIL import ImageDraw
    img = img.copy()
    ImageDraw.Draw(img).rectangle((72, 81, 159, 95), fill=(255, 255, 255))
    return img


@test('weather')
def bank_moved_battle_anims_match(g):
    """Bite, Leech Seed, Petal Dance: every animation frame on pre11/post11 equals v09. pre11 has the
    Leech Seed/Petal Dance funcs in bank $0b; post11 and v09 in $0d, so pre11 spans the move."""
    from fixtures import fixture
    from visual import battle_anim_frames, contact_sheet
    roms = {k: os.path.join(ROMS_DIR, k, 'crystal_eclipse_debug.gbc') for k in ('v09', 'post11', 'pre11')}
    missing = [k for k, p in roms.items() if not os.path.exists(p)]
    if missing:
        from registry import Skip
        raise Skip('baseline ROMs missing: %s' % missing)
    out, bad = {}, []
    for move in ('BITE', 'LEECH SEED', 'PETAL DANCE'):
        seqs = {}
        for label, rom in roms.items():
            r = fixture('debug_party', rom=rom, render=True)
            try:
                seqs[label] = battle_anim_frames(r, move)
            finally:
                r.close()
        contact_sheet(seqs, path=os.path.join(g.shots, 'anim_%s.png' % move.replace(' ', '_').lower()))
        ref = [_mask_hud(f) for f in seqs['v09']]
        for label in ('post11', 'pre11'):
            s = [_mask_hud(f) for f in seqs[label]]
            best = None
            for shift in range(-3, 4):  # start-frame jitter between builds
                pairs = [(ref[i], s[i + shift]) for i in range(len(ref)) if 0 <= i + shift < len(s)]
                d = [i for i, (a, b) in enumerate(pairs) if diff(a, b)[0]]
                if best is None or len(d) < len(best[1]):
                    best = (shift, d, len(pairs))
            shift, differing, compared = best
            out['%s %s' % (move, label)] = {'frames': len(s), 'v09_frames': len(ref), 'shift': shift,
                                           'compared': compared, 'differing': len(differing), 'first': differing[:3]}
            if differing or abs(len(s) - len(ref)) > 3:
                bad.append('%s %s' % (move, label))
    check(not bad, 'battle animation differs from v09', which=bad, **{k: v for k, v in out.items()})
    return out

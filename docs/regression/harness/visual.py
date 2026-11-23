"""Screen helpers: tilemap text, screenshot diffs, and the same scene across several ROMs."""
import os

_CHARS = {0x7f: ' ', 0xe8: '.', 0xe7: '!', 0xe6: '?', 0xf3: '/', 0xe3: '-', 0xed: '>',
          0xba: '+', 0xbb: '-', 0xbc: '+', 0xbd: '|', 0xbe: '+', 0xbf: '+'}
for i in range(26):
    _CHARS[0x80 + i] = chr(65 + i)
    _CHARS[0xa0 + i] = chr(97 + i)
for i in range(10):
    _CHARS[0xf6 + i] = str(i)

FRAME_TILES = set(range(0xba, 0xc0))


def tilemap(g):
    """The game's 20x18 background tilemap buffer (wTilemap), as rows of tile IDs."""
    raw = g.read('wTilemap', 20 * 18)
    return [raw[r * 20:(r + 1) * 20] for r in range(18)]


def text_rows(g):
    """Tilemap decoded to text; unknown tiles show as '·'."""
    return [''.join(_CHARS.get(t, '·') for t in row) for row in tilemap(g)]


def screen_text(g):
    return '\n'.join(text_rows(g))


def diff(a, b, out=None):
    """Compare two PIL images. Returns (changed pixel count, bounding box or None)."""
    from PIL import ImageChops
    d = ImageChops.difference(a.convert('RGB'), b.convert('RGB'))
    bbox = d.getbbox()
    n = sum(1 for p in d.getdata() if p != (0, 0, 0))
    if out and bbox:
        d.point(lambda v: 255 if v else 0).save(out)
    return n, bbox


def rom_list_index(g, label, name, count=1024):
    """1-based position of `name` in a li-terminated ($50) string list in this ROM (e.g. MoveNames)."""
    with open(g.rom, 'rb') as f:
        rom = f.read()
    b, a = g.addr(label)
    p = b * 0x4000 + a - 0x4000
    want = bytes(_ENC[c] for c in name)
    for i in range(count):
        end = rom.index(0x50, p)
        if rom[p:end] == want:
            return i + 1
        p = end + 1
    raise KeyError(name)


_ENC = {v: k for k, v in _CHARS.items() if len(v) == 1 and v not in '+|·'}
_ENC[' '] = 0x7f


def battle_anim_frames(g, move, enemy_slot=1, limit=600):
    """From the debug-party fixture: teach party mon 1 `move` (by name) in slot 1, start a wild battle
    against a level 5 copy of party slot `enemy_slot`, use the move and return every frame of its
    animation (PIL images, from _PlayBattleAnim entry until it returns)."""
    idx = rom_list_index(g, 'MoveNames', move)
    g.write('wOptions', g.read('wOptions') & 0x7f)  # battle scene on
    mid = g.call('GetMoveIDFromIndex', hl=idx)['a']
    g.write('wPartyMon1Moves', mid)
    g.write('wPartyMon1PP', 10)
    if not g.run_until('PlayerEvents', 60):
        raise AssertionError('not at PlayerEvents')
    g.write('wTempWildMonSpecies', g.read('wPartySpecies+%d' % enemy_slot))
    g.write('wCurPartyLevel', 5)
    g.write('wBattleType', 0)
    g.write('wOtherTrainerClass', 0)
    b, a = g.addr('WildBattleScript')
    g.write('wMapReentryScriptBank', b)
    g.write('wMapReentryScriptAddress', [a & 0xff, a >> 8])
    g.write('wMapReentryScriptQueueFlag', 1)
    for _ in range(100):  # "Wild X appeared!" waits for A
        if g.run_until('LoadBattleMenu', 30):
            break
        g.press('a', hold=2, after=0)
    else:
        raise AssertionError('battle never reached LoadBattleMenu')
    g.write('wBattleMenuCursorPosition', 1)
    g.run_until('InterpretBattleMenu', 300)
    # hold A and release on the hit: a fixed-length press can carry past the label
    g.frames(5)
    g.hold('a')
    hit = g.run_until('MoveSelectionScreen', 120)
    g.hold('a', False)
    if not hit:
        raise AssertionError('no move selection')
    g.write('wCurMoveNum', 0)
    g.run_until('MoveSelectionScreen.interpret_joypad', 300)
    g.write('wPlayerAccLevel', 13)
    g.frames(5)
    g.hold('a')
    for _ in range(4):
        if not g.run_until('_PlayBattleAnim', 1200):
            g.hold('a', False)
            raise AssertionError('no battle animation played')
        if g.read('hBattleTurn') == 0:
            break
        g.frames(1)
    else:
        g.hold('a', False)
        raise AssertionError('player animation not found')
    g.hold('a', False)
    sp = g.reg('sp')
    ret = g.read(sp) | g.read(sp + 1) << 8
    rb = g.rom_bank if ret >= 0x4000 else -1
    frames = []
    for _ in range(limit):
        done = g.run_until((rb, ret), 1)
        frames.append(g.screenshot())
        if done:
            break
    return frames


def contact_sheet(rows, step=6, path=None):
    """rows: {label: [frames]} -> one image, a row per label, every `step`th frame."""
    from PIL import Image
    n = max(len(f) for f in rows.values())
    cols = list(range(0, n, step))
    sheet = Image.new('RGB', (160 * len(cols) // 2, 72 * len(rows)), 'white')
    for r, frames in enumerate(rows.values()):
        for c, i in enumerate(cols):
            if i < len(frames):
                sheet.paste(frames[i].resize((80, 72)), (80 * c, 72 * r))
    if path:
        sheet.save(path)
    return sheet


def across_roms(scene, roms, shots_dir, name):
    """Run scene(g) -> PIL image on each ROM (fresh fixture per ROM). Returns {rom_label: image}."""
    from fixtures import fixture
    imgs = {}
    for label, rom in roms.items():
        g = fixture('debug_party', rom=rom, render=True)
        try:
            img = scene(g)
            img.save(os.path.join(shots_dir, '%s_%s.png' % (name, label)))
            imgs[label] = img
        finally:
            g.close()
    return imgs

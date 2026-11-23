#!/usr/bin/env python3
"""Build a Ruins of Alph word room tileset that reuses the Ho-Oh room's
layout (maps/RuinsOfAlphHoOhWordRoom.ablk) but spells different text.

The Ho-Oh room's six text lines sit in block rows 3-8, columns 1-8, and
every one of those 48 blocks is unique, so rewriting those metatiles
changes the text without touching the .ablk or the collision.

usage: make_word_room.py NAME LINE1 ... LINE6   (16 chars max per line)
writes data/tilesets/NAME_word_room_{metatiles,attributes}.bin
"""
import sys

BASE = 'ho_oh_word_room'
ABLK = "maps/RuinsOfAlphSuicuneWordRoom.ablk"
W = 10
BRICK = 0x13
BANK1 = 0x08


def main():
    name, lines = sys.argv[1], sys.argv[2:]
    assert len(lines) <= 6, 'six lines at most'
    for ln in lines:
        assert len(ln) <= 16, f'{ln!r} is over 16 characters'
        assert set(ln) <= set('ABCDEFGHIJKLMNOPQRSTUVWXY '), f'{ln!r}: A-Y and spaces only'
    meta = bytearray(open(f'data/tilesets/{BASE}_metatiles.bin', 'rb').read())
    attr = bytearray(open(f'data/tilesets/{BASE}_attributes.bin', 'rb').read())
    ablk = open(ABLK, 'rb').read()

    def tiles(blk):
        return [(meta[blk * 16 + i], attr[blk * 16 + i]) for i in range(16)]

    # palette bits for letters, taken from an existing A-X letter tile
    letter_pal = next(a & ~BANK1 for t, a in zip(meta, attr) if a & BANK1)
    brick = tiles(BRICK)
    # Y is drawn with bank-0 tiles; copy them from HARMONY in the Ho-Oh room
    y_tl = None
    for blk in range(len(meta) // 16):
        t = tiles(blk)
        for col in (0, 2):
            if t[col][0] == 0x5b and t[col + 1][0] == 0x5c:
                y_tl = [t[col], t[col + 1], t[col + 4], t[col + 5]]
    assert y_tl, 'Y tiles not found'

    def letter(ch):
        if ch == 'Y':
            return y_tl
        n = ord(ch) - 65
        tl = (n // 8) * 32 + (n % 8) * 2
        a = letter_pal | BANK1
        return [(tl, a), (tl + 1, a), (tl + 16, a), (tl + 17, a)]

    lines = [ln.ljust(16) for ln in lines] + [' ' * 16] * (6 - len(lines))
    seen = set()
    for row in range(6):
        for col in range(8):
            blk = ablk[(row + 3) * W + col + 1]
            assert blk not in seen and blk != BRICK, f'block {blk:02x} is shared'
            seen.add(blk)
            out = list(brick)
            for k in range(2):
                ch = lines[row][col * 2 + k]
                if ch != ' ':
                    tl, tr, bl, br = letter(ch)
                    out[k * 2], out[k * 2 + 1], out[4 + k * 2], out[5 + k * 2] = tl, tr, bl, br
            for i, (t, a) in enumerate(out):
                meta[blk * 16 + i] = t
                attr[blk * 16 + i] = a
    open(f'data/tilesets/{name}_word_room_metatiles.bin', 'wb').write(meta)
    open(f'data/tilesets/{name}_word_room_attributes.bin', 'wb').write(attr)


if __name__ == '__main__':
    main()

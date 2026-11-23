#!/usr/bin/env python3
"""Generate a PLACEHOLDER gfx/pokegear/orange.bin for the Orange Islands page.

Uses only tiles that already exist in the shared 48-tile Town Map tileset, so it
needs no tileset expansion. Replace this whole file once shasocastris's real art lands
(see docs/orange_town_map_art_spec.md); the format is the only thing that
matters here: 20x18 raw tile ids, reading order, then a single $ff terminator.

Landmark pixel coords in data/maps/landmarks.asm must agree with what is drawn
here. tile column = x // 8, tile row = y // 8.
"""

W, H = 20, 18

SEA = 0x18
LAND = 0x11
CITY = 0x0A   # orange square with dark outline
POI = 0x0C    # red dot
ROUTE = 0x1A  # pale cream line

# frame (identical in johto.bin and kanto.bin -- do not redraw)
TL, TR, BL, BR = 0x06, 0x17, 0x26, 0x27
TOP = BOT = 0x07
SIDE = 0x16

m = [[SEA] * W for _ in range(H)]
for x in range(W):
    m[0][x] = TOP
    m[H - 1][x] = BOT
for y in range(H):
    m[y][0] = SIDE
    m[y][W - 1] = SIDE
m[0][0], m[0][W - 1] = TL, TR
m[H - 1][0], m[H - 1][W - 1] = BL, BR


def blob(x0, y0, x1, y1, tile=LAND):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            m[y][x] = tile


# Valencia -- lower left. Landmark (20, 76) -> tile (2, 9).
blob(1, 9, 4, 12)
m[9][2] = CITY

# Shamouti Island -- upper right. Landmark (100, 44) -> tile (12, 5).
blob(11, 4, 15, 7)
m[5][12] = CITY

# Shamouti Cave -- just up and right of the island. Landmark (116, 28) -> (14, 3).
blob(13, 3, 15, 3)
m[3][14] = POI

# Shamouti Passage -- the sea lane between them. Landmark (60, 68) -> tile (7, 8).
for x, y in [(5, 10), (6, 9), (7, 8), (8, 8), (9, 7), (10, 6)]:
    m[y][x] = ROUTE

out = bytearray()
for row in m:
    out.extend(row)
out.append(0xFF)
assert len(out) == W * H + 1, len(out)

with open("gfx/pokegear/orange.bin", "wb") as f:
    f.write(out)

for row in m:
    print("".join(f"{b:02x}" for b in row))
print(f"\nwrote gfx/pokegear/orange.bin ({len(out)} bytes)")

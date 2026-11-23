# Orange Islands Town Map — art spec & handoff

**Written 2026-08-23.** Everything here was measured against the files, not assumed.
Reference images live in `docs/townmap/` (untracked, like the rest of `docs/`).

| File | What it is |
|---|---|
| `docs/townmap/tileset_reference.png` | all 48 tiles, true colours, labelled with id, free slots marked |
| `docs/townmap/johto_reference.png` | the existing Johto map, rendered from `johto.bin` |
| `docs/townmap/kanto_reference.png` | the existing Kanto map |
| `docs/townmap/orange_template.png` | **draw on this** — 160x144, frame already correct, sea fill |
| `docs/townmap/orange_template_4x.png` | same, 4x nearest-neighbour, for looking at |
| `docs/townmap/orange_template.bin` | the template as a valid `.bin`, if you want to see it in-game |

---

## 1. The format (simple — this is not the hard part)

`gfx/pokegear/johto.bin` and `kanto.bin` are **raw tilemaps**: 20x18 = 360 bytes, one
byte per screen cell in reading order, then a single `$ff` terminator. 361 bytes total.
No compression, no header.

They are pulled in at `engine/pokegear/pokegear.asm:2748`:

```asm
JohtoMap:
INCBIN "gfx/pokegear/johto.bin"
KantoMap:
INCBIN "gfx/pokegear/kanto.bin"
```

Adding a third page is an `INCBIN` plus a `FillOrangeMap`. **I will write a PNG ->
`orange.bin` converter**, so you never touch the binary — you hand me a PNG.

---

## 2. What to draw

**A 160x144 PNG — 20x18 tiles.** Start from `orange_template.png`, which already has the
frame right. Draw only inside it.

### The visual language (read the two reference renders)

| Thing | How it looks | Tile(s) |
|---|---|---|
| Sea | blue with pale diagonal hatching | `$18` plain, `$08` `$09` `$19` variants |
| Land | solid green | `$11` (64/64 px green) |
| Mountains | brown | `$03` `$04` `$05` `$13` `$14` `$15` |
| Routes | pale cream lines | `$1a` and neighbours |
| Cities / towns | orange square with dark outline | `$0a` |
| Landmarks of note | red dot | `$0c`-`$0f` |
| Frame | grey border | see below |

### The frame is fixed — do not redraw it

```
corners : $06 top-left   $17 top-right   $26 bottom-left   $27 bottom-right
top row and bottom row : $07
left column and right column : $16
```

That is exactly what both existing maps do and what the template contains.

### The region label is FOUR TILES, and they are not letters

"JOHTO" is tiles `$28 $29 $2a $2b` placed at row 16, columns 15-18.
"KANTO" is tiles `$2c $2d $2e $2f` placed at row 16, columns 1-4.

Each is a **pre-rendered slice of the whole word**, roughly 1.25 letters per 8px tile —
there is no letter alphabet to reuse. An "ORANGE" (or whatever you call it) label needs
its own 4-tile strip drawn from scratch. Budget for that; see §3.

---

## 3. The tile budget — **DONE, you now have 31 free tiles**

Option A shipped (`4ff5b6838`). `PokegearGFX` moved from vTiles2 `$30` to `$50`, so the
town map owns `$00`-`$4f` instead of `$00`-`$2f`:

- The original 48 keep ids `$00`-`$2f`, so Johto, Kanto and the Orange placeholder are
  untouched and every landmark coordinate still lands where it did.
- `$30` is the blank tile. **`$31`-`$4f` are free — 31 slots.**
- A 4-tile region label now costs 13% of the budget instead of being impossible.

`TownMapGFX` also left bank `$3E` (83 bytes free) for the pinned Pokégear GFX section in
`$77`. Blank tiles compress to nothing, so the tileset only grew 358 -> 362 bytes; it will
grow properly once real art fills those slots, which is why the move happened first.

### How to hand art over

Draw on `docs/townmap/orange_template.png` (160x144), using the real palette colours from
§4. Then:

```
python3 utils/townmap_png.py docs/townmap/orange.png            # report: how many new tiles
python3 utils/townmap_png.py docs/townmap/orange.png --write    # apply
```

The report says how many new tiles the art needs and how many slots remain, without
changing anything. `--write` emits `gfx/pokegear/orange.bin`, appends the new tiles to
`gfx/pokegear/town_map.png`, and writes their palette rows.

**The tool infers each tile's palette from its colours**, so use the exact RGB values in
§4 — a cell mixing colours from two different palettes is impossible on hardware and gets
reported with its coordinates rather than silently mangled.

`docs/townmap/orange_current.png` is the placeholder rendered at 1x, if you want to paint
over it rather than start from the empty template.

## 3a. The original constraint, for reference

The Town Map tileset is **48 tiles, shared by every page**, loaded once at `vTiles2 $00`.
`PokegearGFX` is parked immediately behind it at `$30`.

- **45 of the 48 are already used** (37 by Johto, 36 by Kanto, 28 shared).
- **Exactly three are free: `$1d`, `$1e`, `$1f`.**

You may **reuse any of the 45 existing tiles freely** — all 48 are resident whichever page
is showing. What you cannot do for free is invent *new shapes*.

Three free tiles will not cover a 4-tile region label **and** new island coastlines.

### The open decision (I need this before I write any code)

There is headroom: the Pokégear uses 94 of the 128 tiles in that VRAM block, so **34 are
free**.

| Option | You get | Cost |
|---|---|---|
| **A. Grow the shared tileset** *(my recommendation)* | ~32 new tiles | I move `PokegearGFX` from `$30` to `$50` and re-author the palette map. No change to the existing pages. |
| **B. Reuse only** | 45 existing + 3 free | none — but you'd likely have to drop the region label |
| **C. Separate tileset per region** | a blank 48-tile canvas | +768 B ROM, a second palette map, a branch in `Pokegear_LoadGFX` |

Pick A unless you want the islands to look nothing like the mainland, in which case C.

---

## 4. Palettes — read this before choosing colours

**Palette is assigned per tile id, not per screen position** (`TownMapPals`,
`pokegear.asm:2618`). A tile's colours are global: you cannot reuse one land shape in a
different colour elsewhere. A new colour means a new tile.

There are six palettes, four colours each. Colour 0 is the same pale cream in all six, and
colour 3 is black except in the two POI palettes where it is red. Values are the real ones
from `gfx/pokegear/pokegear.pal`, given as 5-bit GBC and 8-bit RGB:

| Palette | c0 | c1 | c2 | c3 |
|---|---|---|---|---|
| BORDER | 28,31,20 `#E6FFA5` | 21,21,21 `#ADADAD` | 13,13,13 `#6B6B6B` | 0,0,0 `#000000` |
| EARTH | 28,31,20 `#E6FFA5` | 0,31,0 `#00FF00` | 0,0,31 `#0000FF` | 0,0,0 `#000000` |
| MOUNTAIN | 28,31,20 `#E6FFA5` | 0,31,0 `#00FF00` | 15,7,0 `#7B3A00` | 0,0,0 `#000000` |
| CITY | 28,31,20 `#E6FFA5` | 31,15,0 `#FF7B00` | 15,7,0 `#7B3A00` | 0,0,0 `#000000` |
| POI | 28,31,20 `#E6FFA5` | 0,31,0 `#00FF00` | 0,0,31 `#0000FF` | 31,0,0 `#FF0000` |
| POI_MTN | 28,31,20 `#E6FFA5` | 0,31,0 `#00FF00` | 15,7,0 `#7B3A00` | 31,0,0 `#FF0000` |

⚠️ **The CITY palette differs by player gender** — `pokegear.pal` (boy) has orange
`31,15,0` / brown `15,7,0`; `pokegear_f.pal` (girl) has blue `10,18,31` / violet
`13,06,31`. Every other palette is identical between the two. **Do not let city colour
carry meaning**, because it changes underneath you.

---

## 5. What to hand back

1. **The map PNG** — 160x144, drawn on the template.
2. **If you drew new tiles:** just draw them in place in the PNG. My converter will find
   the ones that don't match an existing tile and tell me how many new slots are needed;
   I'll cut them into the tileset.
3. **The landmark list.** For each Orange landmark: its **name** (goes in
   `data/maps/landmarks.asm` as a short string like `"VALENCIA@"`) and **where it sits**.
   Easiest: place the orange city square / red dot in the PNG and tell me what each one
   is, in order — I'll read the pixel coordinates out and write the table.
   `LANDMARK_VALENCIA_ISLAND` already exists at `$62` and currently sits at x=20, y=76.

---

## 6. Decisions **[answered 2026-08-24 — settled]**

1. **Tile budget: A — grow the shared tileset.** Move `PokegearGFX` from `$30` to `$50`
   and re-author the palette map, using the 34 free tiles in that VRAM block. Gives ~32
   new tiles. Existing Johto/Kanto pages unchanged.
2. **Fly unlocks on reaching Valencia Port.** Already wired —
   `ValenciaPortFlypointCallback` sets `ENGINE_FLYPOINT_VALENCIA` on first entry, exactly
   mirroring how Kanto gates on Indigo Plateau. Still add the no-flypoints guard
   (`pokegear.asm:2262` documents that selecting a flypoint with none enabled **crashes
   the game**).

### Still open

3. **How many islands / landmarks**, roughly. Affects the flypoint block size — needed
   before `KANTO_FLYPOINT_LAST` and the Orange flypoint block are written.

---

## 7. My next steps, in order

Layer 2 comes first — it is a hard prerequisite, because the Town Map picks which page to
open from the *current landmark* (`pokegear.asm:1804`, `cp KANTO_LANDMARK / jr nc`), and
Valencia still reports as Kanto.

1. **Layer 2 — unify `RegionCheck` and `IsInJohto`** into one three-way implementation
   (M3 doc Correction 1 recommends making the home-bank body canonical). Both have three
   callers; fixing only one leaves wild encounters, the radio and the Pokégear wrong.
2. **`KANTO_FLYPOINT_LAST`** (Correction 7) — flypoints have no explicit last-Kanto
   constant and use `NUM_FLYPOINTS - 1` instead, which silently breaks the moment an
   Orange block is appended.
3. **Region toggle** — replace `xor 1` with increment-and-wrap (Correction 6) and audit
   every `maskbits NUM_REGIONS` for the widening at 3 (Correction 2).
4. **PNG -> `.bin` converter**, so your art round-trips without hand-editing binaries.
5. **The page itself** — `FillOrangeMap`, `INCBIN`, cursor limits, page-select case,
   landmark table entries and names, and the no-flypoints crash guard.
6. Tileset expansion per your answer to §6.1.

---

## 8. State of the branch when this was written

`67-orange-islands`, HEAD `d37a559e1`. The whole Valencia integration is **uncommitted**.
Play-tested good: reaching Valencia, the arrival scene, the return trip, both borders.
Still to commit as two commits (registration, then the Vermilion branch) — see M3 doc §5.

`maps/PlayersHouse2F.asm` is modified with your own debug-menu edits (S.S.TICKET, a test
party) — left alone, not mine to commit.

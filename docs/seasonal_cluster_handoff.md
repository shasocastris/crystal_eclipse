# The seasonal cluster — context for a new session

> **Update 2026-10-14 — read this before the rest.** `core` == `68-ow-weather` now (§0's
> "37 ahead" is stale). Shipped since `ef1d25232`:
> - `4babcd6b2` / `abea25271` — **snowy roof**: `ROOF_SNOW` (`gfx/tilesets/roofs/snow.png`,
>   cut from shasocastris's johto.png bank-1 `$4c-$6e`) replaces every Johto roof in winter, including
>   `-1` groups (Ruins of Alph lab). Roof slot rows are eave `$0a-$0c`, mid, ridge `$10-$12` —
>   the png runs bottom-to-top.
> - `fa7af8241` / `73d10b766` — **winter tile patch**: `LoadWinterTiles` in
>   `engine/tilesets/mapgroup_roofs.asm`, tables in `data/tilesets/winter_tiles.asm`, art in
>   `gfx/tilesets/seasonal/johto_winter.png`. Rides the roof call — **0 B ROM0, no new hook**.
>   Covers traditional roofs `$53`, their rim `$31 $34 $41 $44 $51 $52 $54`, and `$36 $48`.
>   §2.2's ground/tree tiles can be added as more runs in the same tables.
> - Shared gate `IsOutdoorJohtoWinter` (TOWN/ROUTE + Johto + winter). Dragon's Den shrine
>   (CAVE, blocks `$2c-$2f`) correctly stays unpatched.
> - Correction: blocks `$08/$09` are the **flat dotted brown roofs** of brick houses (Olivine,
>   Ruins of Alph, routes), not "raised platforms".
> - §2.4's 48 blank bank-1 slots: 23 remain (`6189fcd9b` and `3e9563527` used the rest).
> - Later the same day: `c68bee09b` snows trees, cliffs, the `$3c` path/plateau, cave mouths
>   and the cherry canopy (bank 1, trunk `$71/$72` left brown); `johto_winter.png` is now a
>   sheet mirroring johto.png rows `$1x-$5x`; Battle Tower Outside uses the modern table (it
>   loads modern's gfx). `644945746` keeps summer roof colours in winter for groups 8/11/22
>   (walls share `PAL_BG_ROOF`) — **Kanto groups still go cyan, unasked**. `df2f95890` swaps
>   flower block `$04` for `$ae` (dead grass) in winter via WRAM metatiles.
>   `a7fa63971` grass/tall grass + cherry corners; `7f5d19a67` National Park (own sheet
>   `park_winter.png`, roof cells RED->GREEN in winter, flower beds swapped) and per-tileset
>   block-swap lists in `winter_tiles.asm`; swap state lives in the last byte of block `$ff`
>   of `wDecompressedMetatiles`. ROM0 dispatch moved to ROMX: debug Home headroom now **194 B**.
> - 2026-10-15, through `99050e7d0`: **Kanto has full winter** (gate is now region != Orange,
>   `IsOutdoorWinter`), Orange gets summer palettes (`GetPaletteSeason`), one Fast Ship colour on
>   every `TILESET_PORT`, every winter roof recoloured to icy GREEN via per-tileset 128-byte
>   lookup tables (`WinterBlockPatches` in `winter_tiles.asm`), traditional roofs redrawn from a
>   reference with winter blocks `$b0-$b4`, Kanto flowers `$74`->`$83`, and winter snow is a
>   **40% per-map daily roll**; Lake of Rage / Route 45 weather is spring-autumn only. §6's
>   design calls A and B are decided. Still open: §5 palette retune.
> - Not a bug: the Ruins of Alph shrine pad shows as cliff+water (`$9C`) until all 26 Unown
>   are caught (`22cabfb5f`). Poke `wUnownDex` `$DE36-$DE4F` to `01-1A` to test it.

**Branch:** `68-ow-weather`. **As of:** 2026-08-30, through `ef1d25232`.
**Supersedes** the "seasonal cluster" section of `docs/m0_m4_loose_ends.md`, which was written
before the tileset was measured and gets item 3 wrong (see §4).

Everything below was measured against the tree and the assembled ROM, not recalled. Numbers
that came from a script are marked where it matters.

---

## 0. Where things stand

**`core` does not contain M4.** `core` is at `00be08c06` — the exact commit `68-ow-weather`
was cut from. This branch is **37 ahead, 0 behind**. M4, the cherry trees and the fix below
all live only here. `docs/m0_m4_loose_ends.md` opens by saying M0–M4 are "shipped and
merged"; that is true of M0–M3 only.

**Ceilings, re-measured after `ef1d25232`:**

| | Free | Note |
|---|---|---|
| **ROM0, debug, above `Home`** | **180 B** | **the binding one.** `$3f4c-$3fff` |
| ROM0, release, above `Home` | 209 B | `$3f2f-$3fff` |
| WRAM0 | 10 B | fragmented: 4+4+1+1 |
| WRAMX bank 1 | 415 B | **do not use** — holds the saved block, see §7 |
| ROMX | ~467 KB | banks `$47`, `$45`, `$78` each hold ~15 KB |

The 157 bytes at `$0063-$00ff` are below the cartridge header and **can never serve `Home`**.
Check with `awk '/^ROM0 bank #0:/,/^ROMX/' crystal_eclipse_debug.map | grep Home`.

**Baselines to hold after every batch:**

- `python3 utils/optimize.py | wc -l` → **608**
- `python3 utils/farcheck.py crystal_eclipse.sym | wc -l` → **82**
  ⚠️ it *needs* the `.sym` argument; run bare it prints usage and exits 0, which reads as a pass
- Save canaries unmoved: `wEventFlags $da66`, `wSeason $dbf0`, `wVisitedSpawns $dc01`,
  `wDigWarpNumber $dc09`
- Both ROMs build (`make`, `make crystal_debug`) — check exit status, not output

---

## 1. Item 1 is done — `wOldSeason` (`ef1d25232`)

`DeferredLoadMapGraphics` skipped its graphics reload whenever `TilesetUnchanged` returned z,
which is the normal case for a map connection — both sides share a tileset. Once tiles are
patched per season that skip is wrong: the season can turn between two connected maps and the
stale tiles stay in `vTiles2`.

Three pieces:

- **`wOldSeason`** at `$cfde`, in **WRAM0** beside `wMapWeather` — deliberately *not* beside
  `wOldTileset`, which lives in `"More WRAM 1"` (WRAMX bank 1). A byte there shifts the saved
  block, the trap already documented at `ram/wram.asm:1547`.
- **The latch** in `_LoadTilesetGFX2` (`home/map.asm`), the single place that writes
  `vTiles2`. All three load paths funnel through it: full map load (`home/map.asm:1942`),
  `LoadMapGraphics` (`warp_connection.asm:331`), and the deferred
  `wPendingOverworldGraphics` counter (`events.asm:167`).
- **The compare** inline in `DeferredLoadMapGraphics` (ROMX), **not** folded into
  `TilesetUnchanged`. Its other two callers — `LoadMapTileset`, which copies the tileset
  header, and `DecompressMetatiles` — handle data the season does not touch, and keeping it
  local saves 10 ROM0 bytes.

Cost: **6 B ROM0** (debug `Home` 186 → 180) and one unsaved WRAM0 byte that filled the
existing `$cfde` gap. `optimize.py` byte-identical, `farcheck.py` 82, canaries unmoved, both
routines decoded out of the ROM with jump offsets landing on the right labels.

**Nothing to play-test.** It is latent until something patches tiles.

---

## 2. The art briefs

This is the blocking work. Everything else in the cluster is cheap once the art exists.

### 2.1 How to read these

`johto.png` is **128×128**, 16×16 tiles, 4-colour greyscale. The png grey maps to the 2bpp
colour index as **255 → 0, 170 → 1, 85 → 2, 0 → 3** (verified numerically against
`johto.2bpp`). Colour 0 is the lightest step of whatever palette the tile is drawn under.

A tile's palette is fixed by the block's attribute byte, and **no tile in `johto` or
`johto_modern` is used with two different palettes** (measured — 0 conflicts), so each tile
below has exactly one ramp to design against.

**The four seasonal `PAL_BG_GREEN` ramps and the two that have no season axis:**

```
                       colour 0      colour 1      colour 2      colour 3
GREEN summer $0a day   22,31,10      12,25,01      05,14,00      07,07,07
GREEN winter $34 morn  28,31,16      01,27,27      05,17,31      07,07,07
GREEN winter $35 day   27,31,27      01,27,27      05,17,31      07,07,07
GREEN winter $36 nite  15,14,24      00,10,22      00,07,15      00,00,00
GREEN winter $37 eve   31,21,14      01,20,20      04,13,23      06,05,05

GRAY  $08 day          27,31,27      21,21,21      13,13,13      07,07,07   no season axis
BROWN $0d day          27,31,27      24,18,07      20,15,03      07,07,07   no season axis
RED   $09 day          27,31,27      31,19,24      30,10,06      07,07,07   no season axis
```

**The single most useful fact in this document:** `PAL_BG_GRAY` and `PAL_BG_BROWN` have **no
season axis at all**, and together they are **28.1% of outdoor Johto's screen area**. The
ground and the dirt path stay grey and brown in January no matter what the palettes do. Only
the tiles can fix that. Meanwhile the GREEN winter ramp already pushes foliage to near-white
and cyan, so grass needs the least work and the tree needs the most — a dense dark canopy
rendered through `05,17,31` is exactly the "cyan paint" your own comment at `bg_tiles.pal`
`$34` predicted.

### 2.2 Winter tiles — `johto.png`, 11 tiles

Ranked by share of all **147,968** outdoor 8×8 cells across the **33** `TILESET_JOHTO`
TOWN/ROUTE maps (script-measured from the `.ablk` files, the metatile table and the attribute
table). The second percentage excludes the three Orange Islands maps that ride this tileset —
see the warning below the table, because it changes the mechanism.

| tile | png px | palette | % all 33 | % mainland 30 | what it is | what winter needs |
|---|---|---|---|---|---|---|
| `$06` | (48, 0) | GRAY | **13.9%** | 14.4% | plain ground, block `$01` | snow. Palette can't help — currently near-blank with sparse dots |
| `$3c` | (96, 24) | BROWN | **13.0%** | 13.7% | dirt path, block `$71` | snow, or trodden slush. Palette can't help |
| `$05` | (40, 0) | GREEN | 9.7% | 9.9% | grass, block `$02` | least work — the ramp already whitens it; maybe sparser dots |
| `$2e` | (112, 16) | GREEN | 5.7% | 5.6% | tree, mid-left | bare branches / snow-laden. Dense `#` today → reads cyan |
| `$2f` | (120, 16) | GREEN | 5.7% | 5.6% | tree, mid-right | ditto |
| `$04` | (32, 0) | GREEN | 3.6% | 3.9% | tall grass, block `$03` | dead stalks through snow |
| `$1e` | (112, 8) | GREEN | 3.4% | 3.4% | tree, top-left | ditto |
| `$1f` | (120, 8) | GREEN | 3.4% | 3.4% | tree, top-right | ditto |
| `$3e` | (112, 24) | GREEN | 3.4% | 3.4% | tree, bottom-left | trunk + snow at the base |
| `$3f` | (120, 24) | GREEN | 3.4% | 3.4% | tree, bottom-right | ditto |
| `$3d` | (104, 24) | BROWN | 2.5% | 2.6% | cliff / path edge | rides along free (see below) |

**= 67.7% of outdoor Johto screen area (69.3% of the mainland 30), excluding water.** Water
(`$14`, 17.3% / 15.6%) is deliberately left out — frozen water would need Surf to stop
working.

> ⚠️ **Three of those 33 maps are the Orange Islands** — `ValenciaIsland`, `ShamoutiPassage`
> and `ShamoutiIsland` all run `TILESET_JOHTO` as TOWN/ROUTE. A TOWN/ROUTE-only gate would
> therefore snow the tropics. See §3 for the region check this forces, and §8 for the
> inconsistency it exposes in the *existing* palette code.

They fall into four contiguous runs — **`$04-$06`, `$1e-$1f`, `$2e-$2f`, `$3c-$3f`** — which
is why `$3d` is free: the run `$3c-$3f` already pays for it.

**Nine of the eleven also cover `TILESET_JOHTO_MODERN`.** `johto_modern.2bpp` is
byte-identical to `johto.2bpp` for `$04 $05 $06 $1e $1f $3c $3d $3e $3f` — but **`$2e` and
`$2f` differ**, and they are the two mid-rows of the tree, i.e. the single largest piece of
the job. 68 of modern's 224 tiles match overall. So one blob serves 37 of the 83 outdoor maps
for nine tiles, and modern needs its own `$2e`/`$2f` pair if its trees are to turn as well.
`$13` and `$15` (GREEN, 4.6% each of modern's much smaller footprint) are also unique to it.
All of that is a small second run, worth doing only if Violet and Goldenrod look wrong next to
their routes.

The tree is the six tiles `$1e $1f / $2e $2f / $3e $3f`, which form block `$05` — **22.4% of
all outdoor Johto blocks on its own**. It is the one object worth the most care.

### 2.3 Winter tiles — `kanto.png`, 6–7 tiles

**Only needed if design call A in §6 changes.** Kanto gets no winter snow today, so Kanto
needs no winter tiles. `kanto.png` is 128×64, 16×8 tiles.

| tile | png px | palette | % screen | what |
|---|---|---|---|---|
| `$2c` | (96, 16) | GREEN | **18.1%** | grass ground |
| `$11` | (8, 8) | BROWN | 10.9% | path |
| `$40` | (0, 32) | GREEN | 2.4% | tree, top-left |
| `$41` | (8, 32) | GREEN | 2.4% | tree, top-right |
| `$50` | (0, 40) | GREEN | 2.4% | tree, bottom-left |
| `$51` | (8, 40) | GREEN | 2.4% | tree, bottom-right |
| `$52` | (16, 40) | GREEN | 3.4% | grass variant |

Runs: `$2c`, `$40-$41`, `$50-$52`, plus `$11`. ⚠️ Kanto has **3 tiles used with two
different palettes** — unlike Johto — so check the attribute table before patching anything
not on this list.

### 2.4 Cherry canopies — 3 × 16 tiles, *only under §4 route 2*

The block is the **4×4 tile square at `johto.png` px (0, 96) – (31, 127)**, bottom-left of
the sheet: `vTiles5 $40-$43 / $50-$53 / $60-$63 / $70-$73`, which are png tiles 192–243. All
sixteen are in **VRAM bank 1** (attribute bit 3 set) and, checked against all 176 blocks,
**all sixteen are exclusive to block `$ac`** — nothing else in Johto touches them. Patching
them is completely safe, which is better than `m0_m4_loose_ends.md` assumed.

The twelve inner tiles are `PAL_BG_RED`; the four corners are `PAL_BG_GREEN` and already
follow the season.

**Spring is drawn.** Needed: **summer, autumn, winter**, 16 tiles each. Winter is mainly
about the *shape* — bare branches — because under §4's recommendation the colour comes from
the palette, not the art.

**There are 48 completely blank tiles immediately to the right**, png rows 12–15 cols 4–15,
px (32, 96) – (127, 127) (verified: single-colour, 48 of them). Four 12-tile runs in
`vTiles5`: `$44-$4f`, `$54-$5f`, `$64-$6f`, `$74-$7f`. Convenient scratch space, and relevant
to the mechanism choice in §3.

### 2.5 What `PAL_BG_RED` actually carries

⚠️ **Read §4 first — the premise under this changed.** `PAL_BG_RED` outdoors is **not** a
minor slot. Full inventory, measured and identified:

| what it is | Johto | Modern | Kanto | seasonal recolour? |
|---|---|---|---|---|
| **brick / paving** — `johto $07`, `modern $2f`, **byte-identical art**. Block `$06` is a walkable paved road; seven WALL/DOOR blocks are **brick building walls**. Modern's is **Goldenrod City's pavement**, 918 cells all on one map, ~16% of it | 1,058 | 918 | — | **wrong.** Man-made |
| **flowers**, tile `$03` (px (24,0) in both sheets). Animated — `AnimateFlowerTile` rewrites `vTiles2 tile $03` every other tick | 284 | 20 | 880 | fine, arguably a feature |
| **cherry canopy**, 12 of block `$ac`'s cells, bank 1 | 204 | — | — | **the whole point** |
| **doormats** — `johto/modern $40`, `kanto $4f`, `battle_tower_outside $40`, all byte-identical art | 152 | 24 | 136 | **wrong.** It's a doormat |
| Poké Center sign emblem, `kanto $60` block `$72` | — | — | 9 | wrong, but 9 cells |
| shop-sign lettering, `$08/$09`, `$23/$24`, `$18/$19` | 28 | 6 | — | invisible either way |

If RED gains a season axis to serve the canopy, the flowers follow it. Redrawing the one
flower tile per season — pink blossom in spring, plain leaves in summer, dried in autumn,
snow in winter — turns that from collateral damage into a feature. 2 tiles × 4 seasons at
most, and they ride in the same patch blob.

### 2.6 Other art, lower priority

- **Autumn falling leaves**, a fifth weather type. Cheap in code if it reuses a tile slot and
  `PAL_OW_ORANGE`; the cost is the particle art. Five tables need a row and each has an
  `assert_table_length`, so a miss is a build error, not a runtime bug.
- **Sandstorm** wants a redraw (noted during M4; `c79e85503` was reverted by `2766b3998`).
- **Cherry blossom particles have never been seen in game** — the spawn path needs block
  `$ac`, which only landed in `91caa9221`.
- **Orange Islands Town Map page** is a placeholder built from the 48 shared tiles
  (`docs/townmap/make_orange_placeholder.py`), chosen so no tileset expansion was needed.
  Spec in `docs/orange_town_map_art_spec.md`.

---

## 3. The mechanism to build once art exists

**Do not build this before the art.** The costing is settled; the shape depends on how the
art arrives.

### The hook — 4 bytes of ROM0

`_LoadTilesetGFX2` (`home/map.asm:1301`) already ends with the roof dispatch, and the
`wOldSeason` latch from §1 now sits immediately above it:

```
	pop af
	ldh [rWBK], a

	; vTiles2 is now whatever the current season should see.
	ld a, [wSeason]
	ld [wOldSeason], a

	; These tilesets support dynamic per-mapgroup roof tiles.
	ld a, [wMapTileset]
	cp TILESET_JOHTO
	jr z, .load_roof
	...
```

One `farcall LoadSeasonalTiles` before `ld a, [wMapTileset]` is **4 bytes** (`rst FarCall` +
`dbw`, confirmed by decoding an existing `farcall` out of the ROM). Everything else lives in
ROMX. `_LoadTilesetGFX2` is the right hook for all of it, including the bank-1 cherry tiles,
because `vTiles5` is already loaded by the time it runs in **all three** call paths —
`LoadTilesetGFX` calls 5, 4, 2 in that order, and the deferred counter reaches `_LoadTilesetGFX2`
last (`a` hits 0 on the final decrement).

### The routine — ROMX

Model it on `LoadMapGroupRoof` (`engine/tilesets/mapgroup_roofs.asm`), which is 19 bytes plus
a `Get2bpp`, reads `wMapGroup`, and copies 9 tiles into `vTiles2 tile $0a`. The seasonal
version keys on `wSeason` and `wMapTileset` instead, and must:

- **Gate on `wEnvironment` being `TOWN` or `ROUTE`**, the same gate `LoadMapPals`
  (`engine/gfx/color.asm:977`) uses. This is what keeps winter out of `DragonsDenB1F`, the
  only non-outdoor map on these tilesets (CAVE, `TILESET_JOHTO`).
- **And gate on `wCurRegion` being `JOHTO_REGION`**, because `ValenciaIsland`,
  `ShamoutiPassage` and `ShamoutiIsland` are TOWN/ROUTE maps on `TILESET_JOHTO` and the
  environment check alone will snow them. Copy the weather path exactly — `GetOvercastWeather`
  already does this at `engine/events/overcast.asm:29-31`, comment and all: *"Johto only — the
  Orange Islands are tropical."* Two `ld`/`cp`/`jr` pairs, and it keeps the tiles consistent
  with the snow that is already suppressed there.
- **Set `rVBK` itself** before writing `vTiles5` for the cherry tiles, and restore it.
  `_LoadTilesetGFX2` has already restored `rVBK` to 0 by the time the hook runs.
- Run safely in the mid-frame deferred window — `LoadMapGroupRoof` already does exactly this
  from the same call site, so `Get2bpp` is proven there.

Suggested data format, one entry per run: `db dest_tile, count` then the 2bpp. Terminate with
`db -1`. Per-season, per-tileset tables selected by the standard pointer-table pattern
(`docs/seasons_status.md` §4) — and **seasons that don't differ point at the same table**, as
`SeasonRoofPals` already does for spring/summer/autumn.

### Where the art lives — follow the `Roofs` precedent

`data/maps/roofs.asm` `INCBIN`s five 3×3-tile pngs from `gfx/tilesets/roofs/` at 144 bytes
each. Mirror that: `gfx/tilesets/seasonal/johto_winter.png` etc., one small png per variant,
sized to the runs it carries. Clean for art, clean for the Makefile, and it keeps the variants
out of `johto.png` where a stray edit could shift live tiles.

The alternative — drawing the variants into the 48 blank `vTiles5` slots (§2.4) and making the
patch a VRAM→VRAM copy — needs no new ROM data at all, just a `(src, dst)` table, because the
blank slots are already loaded into VRAM. It is tempting and it is cheaper, but it costs a
VRAM read and ties the art to `johto.png`'s layout forever. **Recommend the separate-png
route** unless ROMX ever gets tight, which it is nowhere near.

### Budget

| | ROM |
|---|---|
| Johto + modern winter, 11 tiles + 4 run headers | ~184 B ROMX |
| modern's own `$13`/`$15` | ~40 B ROMX |
| Kanto winter, 7 tiles (only if design call A changes) | ~120 B ROMX |
| Cherry canopy, 16 tiles × 3 variants (§4 route 2) | ~768 B ROMX |
| ~~Seasonal flowers, 2 tiles × 3 seasons~~ | only under §4 route 4 |
| ~~Seasonal `PAL_BG_RED`, 12 rows in `bg_tiles.pal`~~ | **dead — see §4** |
| **`LoadSeasonalTiles` + tables** | ~120 B ROMX |
| **ROM0** | **4 B** |

~1.4 KB of ROMX against ~467 KB free, and 4 bytes of the 180 that matter. **The cluster is
art-bound, not budget-bound.**

⚠️ `jr` range: inserting code has stretched an existing `jr` past 128 bytes three times on
this branch. Prefer appending to the end of a file over converting someone else's `jr` to
`jmp`, and expect `optimize.py` to gain foldable warnings.

---

## 4. Item 3 — cherry canopies: the palette route is dead

**This section reversed twice. Read the whole thing before acting on it.**

`PAL_BG_RED` day is `27,31,27 / 31,19,24 / 30,10,06 / 07,07,07` — white, pink, red, dark. A
tile patch changes the *pattern* inside those four colours, never the colours. Out of that
ramp you can get spring pink and a believable autumn red. **You cannot get summer green.** So
the canopy wants a seasonal palette, and `PAL_BG_RED` is the only non-GREEN slot small enough
to consider.

**A first pass recommended giving RED a season axis**, on the grounds that RED is only 1.08%
of outdoor Johto and 0.79% of Kanto. **That was wrong** — it measured the slot's *size*
without identifying its *contents*. §2.5 has the inventory. RED carries, across the three
outdoor tilesets, roughly **2,000 cells of man-made masonry**: a paved coastal road on Routes
26/27/32 and Valencia, brick building walls in twelve Johto towns, and **the whole of
Goldenrod City's pavement** — one tile's art, `johto $07` == `johto_modern $2f`, doing all
three jobs. Paving and brickwork must not change colour with the season, and they cannot be
separated from the canopy without new art or a block-table split.

**So `docs/major_systems_roadmap.md` §7.5 was right all along**: there is no spare BG slot, and
a season axis on RED recolours things it must not. All eight slots are in real use
(`GRAY RED GREEN WATER YELLOW BROWN ROOF TEXT`); the smallest alternative, YELLOW, is building
windows (888 cells in Kanto alone), which is no better. The GBC has eight BG palettes and the
VRAM-bank trick buys tiles, not palettes.

**What is actually left, cheapest first:**

1. **Leave it pink all year.** The status quo. Costs nothing, and the tree is in exactly one
   town (Cherrygrove, 17 blocks).
2. **Tile patch only, inside RED's ramp.** The 16 canopy tiles are exclusive and in bank 1, so
   patching them is safe (§2.4) and cheap (~768 B ROMX, 4 B ROM0). You get spring pink, autumn
   red, and a bare winter shape for free. Summer cannot be green — but it *can* be a dense
   dark canopy in `30,10,06` and `07,07,07`, which reads as an ornamental copper tree rather
   than a broken cherry. **This is the best value if the tree is to change at all.**
3. **Move the canopy to `PAL_BG_GREEN` and give up the pink.** Zero new palettes, zero tile
   patch, zero ROM: the canopy immediately follows the existing four-season green axis.
   You lose the blossom colour — but M4's spring blossom *particles* already spawn on
   `COLL_CHERRY_LEAVES`, so spring could be carried by falling petals over a green tree
   instead of a pink canopy. Cheapest way to get a genuinely four-season tree, and it throws
   away art that is already drawn.
4. **Re-point the brick/paving tile off RED** so RED becomes cherry + flowers, then add the
   axis. This is the only route to a *green* summer canopy. It means repainting Goldenrod's
   pavement and Johto's brick walls to another slot — ~2,000 cells of the most-seen surfaces
   in the game, and Goldenrod's pink pavement is its vanilla GSC appearance. Almost certainly
   not worth it for one tree in one town.

**Not a decision to take from this document.** 2 and 3 are opposite answers to "should the
cherry tree be pink", which is shasocastris's call and not a technical one.

> **What happened to the doormats, and why they are back.** `8bb973e5b` moved tile `$40`
> bank 0 off RED to `PAL_BG_BROWN` — 24 cells in `johto`, 24 in `johto_modern`, 8 in
> `battle_tower_outside` (same mat, shared tile sheet, `gfx/tilesets.asm:356`). It was prep
> for route 4 above, so when that route died its purpose died with it, and
> **`01dd9d9db` reverted it.** The attribute files are byte-identical to `ef1d25232` again and
> every doormat in the game is red, as shipped.
>
> Two things worth keeping from the exercise, in case a mat ever does need to move:
> - **It is four tilesets, not two.** `johto $40`, `johto_modern $40`,
>   `battle_tower_outside $40` and **`kanto $4f`** are byte-identical mat art in
>   `WARP_CARPET_*` blocks — 152 + 24 + 8 + 136 outdoor cells. Miss any one and the game has
>   mats of two colours.
> - **Measure a palette against all four time-of-day rows, not one.** Tile `$40` is a 40:24
>   dither of colour indices 1 and 2, and the ground around it is index 0 of GRAY, so sharing
>   a palette with the surroundings is harmless. Worst case over the four rows, as distance
>   from the ground colour: **BROWN 10.7**, RED 9.9, WATER 8.1, GRAY 7.1, YELLOW 5.7,
>   ROOF 3.0. A first attempt picked YELLOW off the day row alone; nite YELLOW is actually
>   grey-lavender and olive-grey, within 0.7 luminance of the ground, so the mats would have
>   disappeared after dark.

## 5. Item 4 — the reverted winter palette retune

A hand-authored winter palette was tried (`21a70a1`) and reverted (`12940a1`); the saturated
version was preferred. `git revert 12940a1` restores it.

**This is a decision to revisit *after* §2.2 exists, not before.** Your own comment at
`bg_tiles.pal` `$34` states the reason exactly: Christmas collapses every outdoor palette onto
one icy ramp because *its* tileset is redrawn as snow, and on unmodified foliage that reads as
cyan paint. Winter's palette is currently doing work the tiles should do. Once the tiles do it,
the saturated ramp may well become the wrong choice — judge it with the new tiles on screen.

---

## 6. Two design calls — one line each, no art

Both are **chosen behaviour**, written up in `docs/major_systems_roadmap.md` §7.5. Propose,
don't change unprompted.

**A. Winter snow is unconditional** across outdoor Johto. A quarter of the year has no weather
variety, and the roll, the daily seed and `.SeasonWetness`'s winter row are all dead code in
Johto winter. The middle option is to let winter go through the roll at a high threshold
(~70%), so it snows most days and a clear one feels like a break. Kept as is because snow is
standing in for the absent winter tileset — **which means §2.2 landing is the trigger to
revisit this**, and it is also what decides whether §2.3 (Kanto tiles) is ever needed.

**B. Kanto gets no winter snow** — crossing the border in January goes blizzard to drizzle.
Excluding the Orange Islands is right; Kanto was excluded only because the roadmap said
"outdoor Johto".

---

## 7. Hazards that have already cost time

- **WRAMX bank 1 holds the saved block.** Adding a byte to a floating section there shifts
  `wSeason` off `$dbf0` and silently breaks the save format. New unsaved bytes go in **WRAM0**
  — that is why `wMapWeather`, `wWildMonBank` and now `wOldSeason` live there, with the reasons
  in comments at `ram/wram.asm:1546` and `:1555`. 10 bytes left.
- **`wSeason` `$dbf0` is a cache with exactly one writer**, `GetSeason`. Poke it to test
  *consumers*; poke **`wStartDay` `$d4b5` `+7`** to move the calendar, which advances the season
  by one and preserves the weekday. Never poke `$dbf0` in a test where a day passes — it
  manufactures a phantom season skip that reads as an engine bug. Cost a full session once.
- **A map's environment field does four unrelated jobs**: Dig/Escape Rope eligibility, the
  seasonal BG palette axis (`TOWN`/`ROUTE` only), roof palettes, and whether weather is
  allowed. Silver Cave is `INDOOR` *specifically* so the player cannot Dig out. Never change
  it to fix a palette problem.
- **`unreferenced.py` will suggest deleting live code.** 7 of its 21 ROM0 hits were
  unreferenced *labels fronting code reached by fallthrough* — `IndirectHL`, which `JumpTable`
  falls into, and six others. Deleting those builds fine and breaks at runtime. **Check the
  instruction before each label for an unconditional flow break.**
- **A routine that pages a bank into `$4000-$7fff` must live in ROM0**, or it swaps out its own
  code. `GetWildMonByte` carries the comment.
- **RGBDS does not error on a near `call` across banks.** It links and jumps into garbage.
  `farcheck.py` after any call between files; a routine that moved file has probably changed
  bank.
- **mtPaint's "save layers" writes a text stub, not an image** — and re-saves the file it
  references. That is how `sand.png` became four lines of text pointing into the polishedcrystal
  repo, and how that repo's own copy went greyscale → RGB.
- **Diff against `~/polishedcrystal/`**, not
  `docs/weather-particles-guide.md`, which paraphrases and is wrong in places. Don't let an
  editor write into that repo.
- **`git add -A` is wrong here.** `docs/`, `.idea/`, `.claude/`, `rgbds-1.0.0/` are untracked
  on purpose, and `maps/PlayersHouse2F.asm` holds debug edits. Stage by name. Docs in `docs/`
  are updated, never committed.
- **No emulator on this box.** Verify statically, then say plainly what needs play-testing and
  what to look for. BGB's memory view here is **16-bit little-endian** — the low byte is the
  lower address, and every symbol in this feature is a `db`, so split the word and take the low
  half.

---

## 8. Everything else still open

### Cheap at the emulator, in one sitting

Two M3 items never play-tested:

- **Whiteout on an Orange map** — where does the player wake up?
- **The day 139 → 0 wrap.** `wCurDay` has a 140-day period and `SEASON_CYCLE_DAYS` is 28; 140
  is an exact multiple, so the sequence should be continuous. Proven arithmetically over three
  RTC cycles, never watched. Reachable by poking `wStartDay` `$d4b5`.

Also unseen: **cherry blossom particles in game** (§2.6), now that block `$ac` exists.

### M3 placeholders — content, not correctness

Detail in `docs/orange_islands_implementation_context.md`.

- Town Map page art (§2.6)
- Island species are placeholders, thematically tropical, data-only to change
- Three `MUSIC_ORANGE_*` aliases
- Radio programming
- Landmark coordinates

### M4 leftovers

- **Spring blossoms region-wide** — unblocked now that `COLL_CHERRY_LEAVES` exists on real
  tiles. The argument against is screen noise: blossoms on every Johto route every spring is a
  lot. Probably no.
- **Autumn falling leaves** as a fifth weather type (§2.6).

### The Orange Islands already get the seasonal palette axis

Found while correcting the map census, **not** changed — this is shipped M2+M3 behaviour and
it is shasocastris's call.

`LoadMapPals` applies the season axis on environment alone, TOWN or ROUTE
(`engine/gfx/color.asm:977-986`), with no region check. `ValenciaIsland`, `ShamoutiPassage`
and `ShamoutiIsland` are TOWN/ROUTE, so **tropical island foliage already goes amber in
autumn and icy-cyan in winter.** The weather path deliberately does not do this —
`GetOvercastWeather` gates winter snow on `wCurRegion == JOHTO_REGION`, commented *"Johto
only — the Orange Islands are tropical"* (`engine/events/overcast.asm:29-31`).

So the two systems disagree today, and nobody noticed because the palette shift is subtle
next to falling snow. Three options: leave it (tropical islands have seasons too, just not
snowy ones); add the same region check to `LoadMapPals`; or give `ORANGE_REGION` its own
palette row set, which is the expensive one. **The tile patch in §3 must take the region
check regardless** — snow-covered tiles on Shamouti would be unmissable where the palette
shift is not.

### Cross-cutting

- **More `home/` dead code.** 201 bytes went in `df6ecc40f` and `a6be09117`; more remains,
  per-symbol hand work. ROM0 is still the ceiling. Mind the fallthrough-label trap in §7, and
  expect deletions to shorten jumps enough that `optimize.py` gains warnings to fold into the
  same commit.
- **`wOvercastReserved`** (`$dbf5-$dbf8`) has 4 of its 6 bytes unused — free headroom *inside*
  the save block, which is otherwise fixed.
- **Safari Zone move tutor** is merged (`core` at `4f534727f`); the note elsewhere saying
  otherwise is stale.

---

## 9. Measured data — don't re-derive this

All from scripts over `data/maps/maps.asm`, the `.ablk` files, `*_metatiles.bin`,
`*_attributes.bin` and the built `.2bpp`.

> ⚠️ **One measurement bug to not repeat.** A first pass parsed `maps.asm` with
> `map (\w+), (TILESET_\w+), (\w+),` — one space after each comma. The M3 Orange Islands rows
> are column-aligned with *several* spaces, so **three TILESET_JOHTO outdoor maps were silently
> dropped** and every Johto percentage below came out ~1 point high. Use
> `map\s+(\w+),\s*(TILESET_\w+),\s*(\w+)`. `ValenciaPort` was missed the same way.

**83 outdoor (TOWN/ROUTE) maps across 8 tilesets; three cover 75:**
`TILESET_KANTO` 38, `TILESET_JOHTO` 33, `TILESET_JOHTO_MODERN` 4. Then PORT 3, PARK 2, HOUSE 1,
TOWER 1, BATTLE_TOWER_OUTSIDE 1. `NationalParkBugContest` has no `.ablk`. Only non-outdoor map
on the big three: `DragonsDenB1F` (CAVE, `TILESET_JOHTO`). **Three of the 33 Johto outdoor maps
are the Orange Islands** — `ValenciaIsland`, `ShamoutiPassage`, `ShamoutiIsland`, 594 blocks
between them.

**Outdoor screen area by palette** (measured after `8bb973e5b`, which moved the doormats
from RED to BROWN):

| | GRAY | RED | GREEN | WATER | YELLOW | BROWN | ROOF |
|---|---|---|---|---|---|---|---|
| Johto (147,968 cells) | 14.97% | **1.08%** | 38.51% | 19.91% | 0.15% | 24.50% | 0.89% |
| Kanto (129,600) | 26.60% | **0.79%** | 31.14% | 13.03% | 0.69% | 26.63% | 1.13% |
| Modern (14,688) | 26.25% | 6.59% | 27.30% | 8.32% | 0.98% | 21.16% | 9.40% |

**Tiles needed to cover N% of outdoor screen area:**

| | 50% | 75% | 90% | 95% | distinct tiles |
|---|---|---|---|---|---|
| Johto | 4 | 9 | 14 | 21 | 186 |
| Kanto | 4 | 12 | 24 | 32 | 103 |
| Modern | 7 | 16 | 28 | 38 | 115 |

**Block `$05` is the tree** — 16 cells using exactly `$1e $1f / $2e $2f / $2e $2f / $3e $3f`,
all bank 0, all GREEN — and is **22.6% of all outdoor Johto block placements**. `$2e`/`$2f` are
exclusive to it; `$1e $1f $3e $3f` also appear in blocks `$2a`, `$2c-$2d`, `$3c-$3f`, `$5b-$67`,
about 18% of their usage, so redrawing them changes those too.

**Tileset geometry.** `johto.png` 128×128 = 256 tiles; `johto_modern.png` 128×112 = 224;
`kanto.png` 128×64 = 128. The Makefile splits each sheet via `tools/sub_2bpp.sh`:
**`vtiles2` = tiles 0-127, `vtiles5` = 128-255, `vtiles4` = 256-383.** A metatile byte plus
attribute bit 3 therefore addresses 256 tiles: bit 3 clear → `vTiles2` (png 0-127), bit 3 set →
`vTiles5` (png 128-255). Kanto has no bank-1 tiles at all. The cherry block is the only thing
in johto's bank-1 range above `$3f`.

**Free tile slots** (unused by any block, so safe to draw into): `vTiles2` 15 — `$20 $21 $30
$35 $5b $64 $65 $6c-$6f $7c-$7f`; `vTiles5` 52, of which 48 are the blank 12×4 rectangle in
§2.4.

**Multi-palette tiles:** johto 0, johto_modern 0, kanto 3.

### Useful addresses

| Symbol | Address | Note |
|---|---|---|
| `wSeason` | `$dbf0` | index 0-3, **saved**. Cache, one writer |
| `wSeasonalFlags` | `$dbf1` | **saved**, cleared on season change |
| `wCurRegion` | `$dbf2` | free byte-order check: `$00` in Johto |
| `wCurDay` | `$d4c4` | one byte; `mod 28` → season, `mod 7` → weekday |
| `wStartDay` | `$d4b5` | **the calendar anchor — poke this** |
| `wOldTileset` | — | WRAMX bank 1, `"More WRAM 1"` |
| **`wOldSeason`** | **`$cfde`** | **new, WRAM0, unsaved** |
| `wMapWeather` | `$cfdd` | WRAM0 on purpose |
| `wOvercastReserved` | `$dbf5-$dbf8` | 4 of 6 bytes unused |

### Where to look

| For | Read |
|---|---|
| Seasons as built; the two pokes; the spec's corrections | `docs/seasons_status.md` |
| How M4 works, every port delta | `docs/m4_weather_implementation_context.md` |
| M4 findings not specific to weather | `docs/m4_weather_handoff.md` §2 |
| Milestones, acceptance, the deferred list | `docs/major_systems_roadmap.md` §7 |
| The full deferral inventory | `docs/m0_m4_loose_ends.md` — but see §0 and §4 above |
| Orange Islands constraints | `docs/orange_islands_implementation_context.md` |

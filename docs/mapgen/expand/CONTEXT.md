# Expanded Johto: context for resuming (written 2026-11-04)

This document is self-contained: it lets a fresh session continue the "expanded Johto" map work without the old conversation. It covers the goal, the method that worked, every draft so far and how to rebuild it, the tools, what the drafts mean for the real build, and the open questions. A ready-made prompt for the next session is at the end (§12).

Everything here is in `docs/mapgen/expand/`, which is **untracked on purpose**. Never `git add -A`, never commit the helper scripts, and nothing is in the build yet. Wider map-making context (the earlier batches of new maps, tileset knowledge, the steps for adding a map to the build) is in `docs/mapgen/CONTEXT.md`. This file covers the `expand/` work only.

---

## 1. The goal

shasocastris wants an **expanded Johto**:
- The existing maps stay **recognisable** but get **larger**, with **more to explore**, both in towns and on routes.
- He's not confident drawing art himself, so the method has to work with the existing Johto tileset and need no new graphics.
- The model is `../pokefollow`, a pokecrystal fork whose Kanto (Pallet Town, Pallet Lake, Route 1, Oak Corral, Viridian City, Route 2, Pewter City) is an expanded remake of the originals.

The work so far is **design drafts only**: text-grid `.amap` files, the `.ablk` files built from them, and renders. They walk the player's route north from New Bark Town:

```
            Route 36 ── Violet City ── Route 31 (gate)
                            │              │
                         Route 32       Route 30
                                           │
New Bark ── Route 29 ── Cherrygrove ───────┘
```

## 2. Status at a glance

| Map | Vanilla | Expanded | Area | Buffer (≤1300) | Main file | All exits reachable |
|---|---|---|---|---|---|---|
| New Bark Town | 10x9 | 24x20 | 5.3x | 780 | `newbark.amap` (written by hand) | yes |
| Route 29 | 30x9 | 44x14 | 2.3x | 1000 | `route29.amap` | yes |
| Cherrygrove City | 20x11 | 28x20 | 2.5x | 884 | `cherrygrove.amap` | yes |
| Route 30 | 13x27 (this repo) | 20x40 | 2.3x | 1196 | `route30.amap` | yes |
| Violet City | 20x18 | 28x24 | 1.9x | 1020 | `violet.amap` | yes (the Rare Candy needs Surf, as in vanilla) |
| Route 31 | 20x9 | 30x14 | 2.3x | 720 | `route31.amap` | yes |
| Route 32 | 10x45 | 14x58 | 1.8x | 1280 | `route32.amap` | yes (two vanilla-style warnings, see §6) |
| Route 36 | 24x9 | 34x14 | 2.2x | 800 | `route36.amap` | yes, once the Ranger's event hides him (see §6) |

- Gallery: https://claude.ai/artifact/Gopa3NeqizhH6fJ9GTjpRL (version 6, section "Expanded Johto"), with side-by-side comparisons of all eight.
- Comparison images: `compare/<map>.png` (vanilla vs expanded) and `compare/pf_*.png` (Crystal Eclipse vs pokefollow).
- shasocastris's verdict: "excellent". He wants to come back to this soon.

## 3. What pokefollow taught us (the six rules)

Measured by rendering pokefollow's maps with its own tiles (`ref/*.png`) next to this repo's Kanto (`ref/vanilla/*.png`):

| Map | Vanilla | pokefollow | Area | What changed |
|---|---|---|---|---|
| Pallet Town | 10x9 | 24x20 | 5.3x | Same three landmarks in the same arrangement; a river with two bridges splits the town; fenced yards; ragged forest edges. |
| Route 1 | 10x18 | 19x24 | 2.5x | A winding road through a wide forest, a big tall-grass meadow, a cliff-and-river band with a bridge, and an east branch to a side map. |
| Pallet Lake / Oak Corral | — | 13x13 / 16x12 | new | Side areas on their own small maps. |
| Viridian City | 20x18 | 23x20 | 1.3x | Barely bigger but far denser: about 20 buildings against 6, a canal, a pond plaza. |
| Route 2 | 10x27 | 10x35 | 1.3x | Same width, longer, two parallel lanes. |
| Pewter City | 20x18 | 20x18 | 1.0x | Redrawn at the same size: gardens and flower beds. |

The rules:
1. **Keep the landmarks and their relative positions**, along with the connection directions. Recognition comes from layout ("the lab is top-left, the water is east"), not exact blocks.
2. **Scale by map type.** Tiny towns about 2.4x per side; routes about 2x wider and a little longer; big cities denser rather than larger.
3. **Water and bridges** are the main structuring tool.
4. **Every plot gets an edge**: a fence, hedge or flower bed.
5. **Ragged, organic edges** instead of straight walls of trees.
6. **Side areas go on separate small maps.**

## 4. The method that worked

Early drafts looked generic. These are the things that fixed that, in order of impact:

1. **Paste vanilla verbatim.** Copy vanilla block rows or chunks into the new grid unchanged (Cherrygrove's shore, Violet's north half, all of Routes 32 and 36), then add new space *around* or *between* them. It reads as the original instantly. For routes, insert whole new **bands** (rows) or **column strips** at natural seams: forest divides, or rows where the path is one block wide.
2. **Strong structure:** a brook splitting a town, hedged yards, one-block roads with path ledges (`56`), stands of wood that split a route into "rooms", ledge-terraced meadows (hop south, walk round to come back).
3. **Roughening pass** (`rough.py`): grass touching forest gets small-tree blocks, so edges look organic.
4. **Verify in a loop:** run `amap.py`, read the warnings, move objects off walls and trees, and repeat until it's clean. Then check the PNG by eye.
5. **Python builders that assert row widths.** Every builder asserts `len(row) == W`. Hand-counting characters went wrong constantly.

Coordinates: a block is 2x2 steps. `obj`/`exit` lines use **step** coordinates, so block (bx,by) covers steps (2bx..2bx+1, 2by..2by+1). The map buffer limit is `(W+6)*(H+6) <= 1300`.

Shifting vanilla data after inserting bands: if N block rows are inserted above vanilla row r, every vanilla event at or below r moves by +2N steps in y. The same applies to columns and x.

## 5. Tools (all in `expand/`, Python 3 + PIL; `make` must have run once so the gfx exist)

| Tool | Use |
|---|---|
| `amap.py SRC.amap [--time nite --suffix _nite] [--season winter]` | Copy of `../handmade/amap.py`. Builds `NAME.ablk` and renders `NAME.png`, `NAME_grid.png` (block ids), `NAME_marked.png` (objects + sightlines) and the night variant. Prints a reachability matrix (walk / +cut / +cut+surf between every pair of `exit`s) and warns about objects on walls or unreachable. |
| `rough.py IN OUT --seed N --p P --scatter S` | Ragged forest edges. Only touches `,` cells. `keep X Y` lines (block coords) protect a cell. It adds the key `!=3c ?=3d @=3e $=3f &=64 +=62 \|=60 <=5d >=5e %=61 /=5c`, so **don't use those characters for anything else** (note that `%` is *not* the mountain floor after roughening). |
| `jgrid.py` | Shared helper for the route builders. `vanilla(name, w)` returns the vanilla `.ablk` as lists of block bytes; `row(str)` converts a hand row via the `CH` legend; `emit(fn, rows, W, head, tail)` asserts widths, assigns key characters to any unknown blocks (avoiding the rough.py characters) and writes the `.amap`. |
| `meta.py NAME` | After `rough.py`: wraps `NAME.amap` with `NAME_header.txt` and appends `NAME_objs.txt` (it strips old `#` and `obj` lines first, so it can be rerun). |
| `violet_meta.py` | The Violet-only predecessor of `meta.py`. |
| `render_other.py REPO OUTDIR Map... [--grid]` | Renders named maps from another pret hack with that hack's tiles. Used for `ref/` (pokefollow) and `ref/vanilla/` (this repo). |

`jgrid.CH` legend (also the de-facto Johto block vocabulary):

```
T 05 forest     . 01 path     , 02 grass     " 03 tall grass   * 04 flowers
~ 35 water      ( 54  ^ 76  ) 55  pond top-left/top/top-right shore
[ 58 / ] 59 left/right shore      { 79 / } 7a inner corners
_ 56 path ledge = 57 grass ledge  o 0a rock pile   # 61 4-tree cluster (headbutt)
S 47 sign/grass s 45 sign/path    C 73 cave mouth
q w p 48 49 4a  picket fence (left/mid/right)
c d / e f  2c 2d / 2e 2f  cabin/old house (door = right half of 2e)
1 2  14 15  small house           g h / i j k  08 09 / 10 11 0b  W-edge gate
A N K  6a 70 6b  mountain top L/mid/R    L M J  68 71 69  mountain sides/floor
b m n  6c 72 6d  mountain bottom L/mid/R W E 6f 6e  mountain inner corners
B 89 plank bridge/jetty  P 06 pink pier walkway  H 43 pier rail  Q 36 rocky water
r R 31 32 sea rocks
```

Other blocks used: `18 19 / 1a 1b` Pokémon Center, `18 19 / 16 17` Mart, `18 19 / 16 1e` player-style house, `18 1f 19 / 1c 77 1e` Elm's lab, `18 1f 19 / 1c 1d 1e` Gym, `0e` east-edge gate block, `0c 0d / 08 09 / 1a 11` south-facing gate (Ruins of Alph), `65`/`64` hedges, `ac` cherry tree, `3c-3f` single-tree quarters, `5b` Cut tree.

## 6. Each draft in detail

Each `.amap` header has KEPT / ADDED / CONNECTIONS / TODO blocks, and the `obj` lines place the full vanilla cast plus new items. The `obj` labels are design names, not script labels.

### New Bark Town: `newbark.amap` (24x20, written by hand)
- Kept: Elm's Lab in the north-west, the player's house next to it, the neighbour's house south-west, Elm's house south-east, the sea on the east edge (to Route 27), and the west road with the teacher stop.
- Added: Bark Brook (a north–south stream) splitting the town into the vanilla quadrants, with two plank footbridges; hedged yards; two new houses; a hilltop meadow behind a ledge; a jetty for the fisher and the Surf start; Elm's research field (a hedged tall-grass plot).
- Exits: W (0,17) on rows 8–9; PIER (45,16); HILL (8,3). Doors: lab (10,11), player's house (33,11), neighbour (9,23), Elm's house (33,25), new houses (13,29) and (31,29).
- TODO: the brook runs off the north and south edges into the border block.

### Route 29: `build29.py` → `route29_base.amap` → `rough.py --seed 3 --p 0.55` → `route29.amap` (44x14)
- Kept: the west-to-east road, the Route 46 gate at the top middle, tall grass on the road at the New Bark end, one-way ledges, the fruit tree, and the full cast (Fisher, Cooltrainers, Youngster, Teacher, Tuscany, Potion).
- Added: an upper tier reached only from the gate path, with a fruit grove (west) and a woodland pond with the Fisher (east); a rest cabin (2c–2f) at (47,15) standing in for a Pokémon Center; stands of wood; south meadows below a second ledge.
- Exits: W (0,13) on row 6; E (87,17) on rows 8–9, which lines up with New Bark's W; GATE (41,1).

### Cherrygrove City: `buildcg.py` → `cherrygrove.amap` (28x20)
- Kept: vanilla's west shoreline pasted verbatim (rows 2–8, cols 0–8), the Center and Café on the north side, Guide Gent, the cherry trees, the Mystic Water fisher, the rival at the east entrance.
- Added: a north avenue to Route 30, a Mart, a second street of houses, a fishing pier, and the cherry grove (the south half) with a winding path, fruit trees and picnickers.
- Exits: N (27,0) on cols 13–14; E (55,9) on rows 4–5; PIER (8,23).
- TODO: the Pokémon Center art waits on the no-Center decision (an inn?); cherry trees stay pink in winter.

### Route 30: `build30.py` → `route30_base.amap` → `rough.py --seed 5 --p 0.55` → `route30.amap` (20x40; header re-added by hand)
- Kept: the single-lane west road (col 3) with path ledges on rows 5, 12, 16, 28 and 33 (hop going south, walk round going north), Joey near Cherrygrove, the Berry House by its pond, the signed Mr. Pokémon branch, the east tall-grass lane, Kimono Girl Hana, the fruit trees and items.
- Added: Mr. Pokémon's hilltop (a plateau behind a ledge with its own pond), a fenced berry garden, Hana's flower glade, three ledged meadows, a south-east pond with the hidden Lure Ball.
- Exits: N (6,0) and S (6,79), both on col 3; MrPokemon (31,5); BerryHouse (11,43).

### Violet City: `buildviolet.py` → `violet_base.amap` → `rough.py --seed 2 --p 0.45 --scatter 0.03` → `violet_meta.py` → `violet.amap` (28x24)
- Kept: vanilla rows 0–8, cols 4–18, pasted at cols 6–20. That's Sprout Tower between its moats, the Gym, Earl's Academy, the cemetery house and the Surf-only Rare Candy nook. Also kept: the nickname house at the same spot (3,15), the rock outcrop, the Center and the Route 31 gate (`0e`) on the east edge.
- Added: a full-width main street (row 9), an avenue (cols 13–14) from the tower to Route 32, a second street (row 14), seven old-style houses (2c–2f), a Mart, a garden pond, and Earl's practice field (fenced tall grass with Academy trainers).
- Exits: W (0,9) on row 4 → Route 36; S (27,47) on cols 13–14 → Route 32; GATE (55,24)/(55,25) → Route 31's gate. 16 door warps are listed in the file.
- Open: the south half is more open than vanilla's woods.

### Route 31: `build31.py` → `route31_base.amap` → `rough.py --seed 4 --p 0.6 --scatter 0.04` → `meta.py route31` (30x14)
- Kept: the Violet gate on the west edge (`08 09 / 10 11 0b`, warp (4,10)), the road east, the L-shaped pond above the road, Dark Cave's mouth (48,7) in the north-east rock face with its sign, the ledged tall grass south of the gate, the south opening to Route 30, the mail Fisher, Wade, Erick, the fruit tree, the Potion and the Poké Ball.
- Added: a T-junction where the lane turns south at col 18, two ledge-terraced meadows (south-west), a fenced orchard with two fruit trees, Erick's wooded pocket (south-east) with a hidden glade item, and a rock pile by the cave path.
- Exits: S (36,27) on col 18.

### Route 32: `build32.py` → `route32_base.amap` → `rough.py --seed 6 --p 0.55 --scatter 0.03` → `meta.py route32` (14x58)
- Kept: **all 45 vanilla rows, block for block, in cols 0–9.** That's the Ruins gate top-left, the rock outcrops, the Cooltrainer's corridor (col 9), the pink pier with its rails, the Center by the sea, Union Cave and the closing rock wall.
- Added:
  - Cols 10–13: a grass shelf beside the Cooltrainer's corridor, reachable only past him (block (10,4) is kept as forest so his coord event at (18,8) still blocks), plus open sea with rock islets.
  - Band 1 (new rows 12–16): a meadow with a woodland pond and a ledge.
  - Band 2 (new rows 25–28): a fisherman's cabin, door (13,55).
  - Band 3 (new rows 44–47): a jetty (89) north of the Center, with a new Fishing Guru at (20,93).
- **Vanilla row shift:** rows 0–11 +0; rows 12–19 +5 blocks (+10 steps); rows 20–34 +9 (+18); rows 35–44 +13 (+26). So: the Center warp (11,73) → (11,99); Union Cave (6,79) → (6,105); the Slowpoke Tail coord event (7,71) → (7,97).
- Exits: N (12,0) on cols 5–7; RuinsGate (4,3).
- Warnings: the hidden Great Ball sits in the trees (as in vanilla), and the Roar TM guy is behind Cut (as in vanilla).
- It's at the buffer limit (1,280). At 58 rows, 14 columns is the widest it can be, so it grew 1.8x rather than 2x.

### Route 36: `build36.py` → `route36_base.amap` → `rough.py --seed 7 --p 0.55 --scatter 0.03` → `meta.py route36` (34x14)
- Kept: all of vanilla, split at its forest divide (between vanilla cols 11 and 12). West: the National Park gate, the trainer-tips path, Suicune's spot and the path north to Route 37. East: the flower meadow, the road to Violet, the Ruins of Alph gate in its rock ledge, Arthur, Noni, the Ranger and the Rock Smash guy.
- Added:
  - An 8-column woodland inserted between the halves: a pond, a straight road (the two `5d` blocks on it were turned into path), and a ledge over a tall-grass dell.
  - Two rows on top so the Route 37 path is longer.
  - A 3-row southern band with a meadow and pond, reached through a gap opened at vanilla block (4,8).
  - Two columns on the east.
- **Vanilla shift:** y +4 steps for everything; x +16 steps for vanilla x ≥ 24. So: Park gate warps (6,12)/(6,13); Ruins gate warps (51,17)/(52,17); Suicune coord events (8,11)/(10,11).
- Exits: E (67,12) on row 6; N (14,0).
- The Ranger at (23,13) plugs the west-half choke exactly as in vanilla, where an event flag hides him. Because of him, amap reports the north exit and the TrainerTips2 sign as gated. There's no real problem.
- Sudowoodo is not an object on Route 36 in this repo.

## 7. How the maps join (connection offsets for implementation)

| Pair | Expanded geometry | Note |
|---|---|---|
| New Bark W ↔ Route 29 E | both rows 8–9 | lines up |
| Route 29 W ↔ Cherrygrove E | row 6 against rows 4–5 | needs an offset |
| Cherrygrove N ↔ Route 30 S | cols 13–14 against col 3 | needs an offset |
| Route 30 N ↔ Route 31 S | col 3 against col 18 | offset −15 |
| Route 31 ↔ Violet | gate warp pair: Route 31 (4,10) ↔ Violet (55,24/25) through the gate interior | the west edge connection is now only visual |
| Violet S ↔ Route 32 N | cols 13–14 against cols 5–7 | needs an offset |
| Violet W ↔ Route 36 E | row 4 against row 6 | offset −2 |
| Route 36 N ↔ Route 37 | col 7 | was +4; recheck |
| Route 32 S ↔ Route 33 | rock edge | visual only |
| New Bark E, Route 29 N (gate), Route 27, Route 46 | | not checked yet |

## 8. Cost of putting these in the build

- **Block data:** all eight fit where they already live.
  - Map Blocks 1 holds Routes 29, 30, 31, 32 and 36: about +1.66 KB of 3,382 B free (+346, +449, +240, +362, +260).
  - Map Blocks 2 holds New Bark, Cherrygrove and Violet: +730 B of 2,206 B free for New Bark and Cherrygrove. Violet (also in Map Blocks 2) adds another +312 B (672 against 360), for about +1,042 B in total. Recheck before implementing.
  - Map sizes go in `constants/map_constants.asm`.
- **The real work is re-pointing:**
  - every warp *into* these maps (interiors, gates, caves);
  - every `coord_event`, `bg_event` and `object_event` (use the shift tables in §6);
  - the scene scripts (New Bark's teacher stop, Cherrygrove's rival scene, the Route 32 Cooltrainer and Slowpoke Tail, the Route 36 Suicune);
  - the Fly spawn points;
  - the connection offsets in `data/maps/attributes.asm` (§7).
- **New buildings need new interiors** (houses, cabins, the Mart in Cherrygrove and Violet), or they get doorless art.
- **Text:** 18 characters per line on all map text.
- **Rendering checks:** water and brooks that run off map edges into the border; mountain corner joins; the no-Center decision (Cherrygrove, the Route 29 rest cabin, the Route 32 Center).
- **Implementation order suggestion:**
  - Do one map end to end on a new branch first, to prove the pipeline. Route 31 is small, has few scripts and only one gate.
  - Then New Bark, Route 29 and Cherrygrove together, because their connections chain.
  - Use Polished Map++ for touch-ups after copying the `.ablk` over `maps/<Map>.ablk`.

## 9. Open questions for shasocastris

1. Approve, tweak or redo each draft. Most likely to need taste calls: Violet's open south half; whether Route 32's added sea is worth it; whether Route 36's southern band should be a side map instead (rule 6).
2. Side maps: none are drafted yet (Pallet Lake-style). Candidates: Elm's field as its own map, a Dark Cave foothill off Route 31, a lakeside off Route 36.
3. The no-Center decision affects Cherrygrove, the Route 29 cabin and Route 32.
4. Seasons: cherry trees in winter; new water bodies and the winter palette.
5. Should the rest of Johto (Route 37 onward, Azalea, Goldenrod, Ecruteak, Olivine…) be expanded the same way, and in what order?
6. Fit with the other `docs/mapgen` work: the six johto_modern cities and the batch-2 outdoor maps aren't placed yet. Expanded routes might be where they attach.

## 10. Lessons and gotchas

- **Assert every row width.** Mis-counted rows were the most common error.
- **Never use rough.py's tree characters** (`! ? @ $ & + | < > % /`) for other blocks. `jgrid.emit` avoids them automatically.
- **Objects:**
  - After roughening, NPCs or items can land on trees. Run `amap.py`, then move them to a nearby `,` cell.
  - An NPC on an exit cell blocks that exit.
  - Signs use the bottom-right step of the sign block: block (bx,by) → step (2bx+1, 2by+1).
  - A door warp is the step under the door half of the building (for 2e, the right half: x = 2bx+1).
  - Mountain blocks must line up: `n` (6d, bottom-right) has to sit in the same column as the `J` (69) above it.
- **Reachability failures can come from NPCs** that vanilla hides with event flags (the Route 36 Ranger, Suicune). Remove objects one at a time to find the blocker.
- **Water without a bottom shore** (water directly above grass or path) is normal in the Johto tileset; vanilla does it too.
- **Shell:** chained `&&` steps can silently stop. Keep rebuilds as one script each, or the documented one-liners.
- **Gallery publishing:**
  - `docs/mapgen/gallery/index.html` is a **fragment**. Prepend line 1 of the live skeleton (saved at `/tmp/claude-1000/-home-bryan-Documents-Romhacks-crystal-eclipse/7590a4e3-899a-4d0c-95ff-1d9edb945fbc/scratchpad/pub/index.html`; it may be gone, so otherwise read the live artifact and take everything up to `<body>`) and append `</body></html>`.
  - Publish with `publish_files`: slug `80029bf2-a4f2-42d3-845b-c41a072f2e2f`, `base_version` = the live version (currently `1793858217-5fc0`; use `get_artifact` to confirm), plus the new `img/*.png`.

## 11. Rebuild everything

```bash
cd docs/mapgen/expand
# New Bark: hand-written
python3 amap.py newbark.amap
# Route 29 / Route 30: their .amap headers were added by hand after rough.py,
# so save the header before regenerating
python3 build29.py && python3 rough.py route29_base.amap route29.amap --seed 3 --p 0.55 && python3 amap.py route29.amap
python3 buildcg.py && python3 amap.py cherrygrove.amap
python3 build30.py && python3 rough.py route30_base.amap route30.amap --seed 5 --p 0.55 && python3 amap.py route30.amap
python3 buildviolet.py && python3 rough.py violet_base.amap violet.amap --seed 2 --p 0.45 --scatter 0.03 && python3 violet_meta.py && python3 amap.py violet.amap
for n in 31:4:0.6:0.04 32:6:0.55:0.03 36:7:0.55:0.03; do IFS=: read r s p c <<<"$n"
  python3 build$r.py && python3 rough.py route${r}_base.amap route$r.amap --seed $s --p $p --scatter $c \
  && python3 meta.py route$r && python3 amap.py route$r.amap && python3 amap.py route$r.amap --time nite --suffix _nite; done
```

Vanilla references: `python3 render_other.py ../../.. ref/vanilla Route37 --grid`. To dump a vanilla grid as hex, read `maps/<Map>.ablk` with the width from `constants/map_constants.asm`.

## 12. Prompt for the next session

Paste this to start:

> We're continuing the **expanded Johto** map design work. Read `docs/mapgen/expand/CONTEXT.md` first; it's the full handoff. Then skim `docs/mapgen/expand/README.md`, and `docs/mapgen/CONTEXT.md` only if you need the wider map-making background. Everything in `docs/` is untracked: don't commit it, and never `git add -A`.
>
> So far there are eight drafts: New Bark, Route 29, Cherrygrove, Route 30, Violet, Route 31, Route 32 and Route 36. They're text-grid `.amap` files in `docs/mapgen/expand/`, made with the same method: paste vanilla verbatim, add bands and strips, roughen with `rough.py`, then verify with `amap.py` until there are no warnings. These are design drafts only; nothing goes into the build unless I ask.
>
> Today I want to: **[pick one]**
> - (a) expand the next maps the same way: **[e.g. Route 37 and Ecruteak City / Routes 33–34 and Azalea / Goldenrod]**;
> - (b) revise drafts: **[notes]**;
> - (c) draft side maps (pokefollow's Pallet Lake / Oak Corral idea) for **[areas]**;
> - (d) plan or start implementing a draft in the build, beginning with Route 31 on a new branch.
>
> For new maps: dump and render vanilla first (`render_other.py`, hex dump), keep the landmarks and their relative layout, make sure the exits meet the neighbouring expanded drafts (§7 of the context doc), write a `buildNN.py` with `jgrid.py`, and produce a header (KEPT/ADDED/SHIFT/CONNECTIONS), the `obj` lines for the full vanilla cast, night renders and a `compare/` image. Then update `expand/README.md`, `expand/CONTEXT.md`, memory, and the gallery artifact (the publishing steps are in §10). Keep source comments short, keep map text to 18 characters per line, and don't spawn subagents unless I ask.

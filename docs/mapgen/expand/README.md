# Expanded Johto: New Bark → Violet and its routes (2026-11-04)

Goal: maps that are recognisably the originals, but larger, with more to explore. These are design drafts only; nothing is in the build. Side-by-side images are in `compare/`.

## How pokefollow expands Kanto

`../pokefollow` is a pokecrystal fork. Its Kanto maps have new art (a FRLG-style overworld) and new layouts. Vanilla here means this repo's own Kanto maps, rendered with `render_other.py`.

| Map | Vanilla | pokefollow | Area | What changed |
|---|---|---|---|---|
| Pallet Town | 10x9 | 24x20 | 5.3x | The three landmarks keep their arrangement: Red's and Blue's houses side by side, with Oak's Lab south of them. Everything else is new: a river splits the town into neighbourhoods, two wooden bridges cross it, and fenced yards surround the houses. A gated north path leads to the lab, and the town edges are ragged forest. |
| Route 1 | 10x18 | 19x24 | 2.5x | The vanilla route is a straight ladder of ledges. pokefollow's runs through a wide forest: a winding road, a big tall-grass meadow in the middle, and a cliff-and-river band in the north crossed by a bridge. An east branch leads to a side map. |
| Pallet Lake | — | 13x13 | new | A side map off Route 1's east edge: a lake with a sandy shore. |
| Oak Corral | — | 16x12 | new | A warp-only side area: a fenced pasture, a pond and a cliff. It's the "more to explore" around the lab. |
| Viridian City | 20x18 | 23x20 | 1.3x | Only slightly larger, but much denser: about 20 buildings against 6. A canal with two bridges runs along the south edge, and there's a pond plaza. The western cliff and the Route 22 gap are kept. |
| Route 2 | 10x27 | 10x35 | 1.3x | The same width, but longer. Diglett's Cave and the gate are kept. Tree masses make two parallel lanes, and there are more ledge pockets. |
| Pewter City | 20x18 | 20x18 | 1.0x | The same size, redrawn. It keeps the cliff walls on both sides, the museum at the top and the Gym. Fenced gardens and flower beds are added. |

The rules this suggests:
1. **Keep the landmarks and their relative positions**, along with the connection directions. Recognition comes from "the lab is at the top, the two houses are side by side, the water is on that side", not from the exact blocks.
2. **Scale depends on the map type.** Tiny starting towns grow about 2.4x per side (around 5x the area). Routes double their width and grow a little in length. Cities that were already big get denser rather than larger.
3. **Water and bridges are the main tool.** A river splits a town into neighbourhoods, and bridges become landmarks in their own right.
4. **Every plot gets its own edge**: fences, hedges, flower beds. That makes even an empty area read as town rather than lawn.
5. **Ragged, organic edges** instead of straight walls of trees or rocks.
6. **Side areas live on separate small maps** (Pallet Lake, Oak Corral), not on the town map itself.

## The drafts

| Map | Vanilla | Expanded | Buffer | File |
|---|---|---|---|---|
| New Bark Town | 10x9 | 24x20 (5.3x) | 780 | `newbark.amap` |
| Route 29 | 30x9 | 44x14 (2.3x) | 1000 | `route29.amap` (made from `route29_base.amap` with `rough.py --seed 3 --p 0.55`) |
| Cherrygrove City | 20x11 | 28x20 (2.5x) | 884 | `cherrygrove.amap` |
| Route 30 | 13x27 (this repo) | 20x40 (2.3x) | 1196 | `route30.amap` (from `route30_base.amap`, `rough.py --seed 5 --p 0.55`) |
| Violet City | 20x18 | 28x24 (1.9x) | 1020 | `violet.amap` (from `buildviolet.py` → `violet_base.amap`, `rough.py --seed 2 --p 0.45`, then `violet_meta.py` adds `violet_header.txt` and `violet_objs.txt`) |
| Route 31 | 20x9 | 30x14 (2.3x) | 720 | `route31.amap` (`build31.py`, `rough.py --seed 4 --p 0.6 --scatter 0.04`, `meta.py route31`) |
| Route 32 | 10x45 | 14x58 (1.8x) | 1280 | `route32.amap` (`build32.py`, `rough.py --seed 6 --p 0.55 --scatter 0.03`, `meta.py route32`) |
| Route 36 | 24x9 | 34x14 (2.2x) | 800 | `route36.amap` (`build36.py`, `rough.py --seed 7 --p 0.55 --scatter 0.03`, `meta.py route36`) |

Each `.amap` header lists what was kept, what was added, the connections and any TODOs. The `obj` lines place the vanilla NPC cast plus new items. All drafts pass the walkability check: every exit and door can be reached on foot.

- **New Bark:**
  - Kept: the lab in the north-west with the player's house next to it, the two houses to the south, water to the east, and the west road where the teacher stops you.
  - Added:
    - Bark Brook, a stream that splits the town into those four parts, with two footbridges.
    - Hedged yards and two new houses.
    - A hilltop meadow behind a ledge.
    - A jetty into the sea for the fisher and the Surf route to Route 27.
    - Elm's research field: a hedged tall-grass plot, New Bark's answer to Oak's Corral.
- **Route 29:**
  - Kept: the west-to-east road, the Route 46 gate in the middle, tall grass right at the New Bark end and on the road, ledges, the same NPCs and the Potion.
  - Added:
    - An upper level reached only from the gate path, with a fruit grove and a woodland pond where the Fisher stands.
    - A rest cabin as the stop in place of a Pokémon Center.
    - Stands of woods that break the route into rooms.
    - Meadows of tall grass below a second ledge.
- **Cherrygrove:**
  - Kept: vanilla's west shoreline, copied block for block into the top-left corner, plus Route 30 to the north, Route 29 to the east, the Center, the Café and Guide Gent.
  - Added:
    - A north avenue.
    - A Mart and a second street of houses.
    - A fishing pier for the Mystic Water fisher.
    - The cherry grove itself, with a winding path to a flower clearing and fruit trees.

- **Route 30:**
  - Kept: the single-lane west road from Cherrygrove to Route 31, with path ledges you hop heading south and walk round heading north; Joey near the Cherrygrove end; the Berry House beside its pond; the signed Mr. Pokémon branch to the north-east; the wild tall-grass lane on the east side; and Kimono Girl Hana.
  - Added:
    - Mr. Pokémon's hilltop: a plateau behind a ledge with his own pond and a winding drive.
    - A fenced berry garden.
    - Hana's tree-ringed flower glade.
    - Three ledged meadows.
    - A south-east pond hiding the Lure Ball.
- **Violet City:**
  - Kept: vanilla's north half (rows 0–8, cols 4–18), pasted block for block. That's Sprout Tower between its moats, the Gym, Earl's Academy, the cemetery house and the Rare Candy nook, which still needs Surf. Also kept: the nickname house at the same coordinates, the rock outcrop, the Center and the Route 31 gate on the east edge.
  - Added:
    - A full-width main street, a north–south avenue from the tower to Route 32, and a second street.
    - Seven old-style houses.
    - A Mart.
    - A garden pond.
    - Earl's practice field: fenced tall grass with Academy students.
  - The south half is more open than vanilla's wooded one, and could take more buildings or trees.

- **Route 31:**
  - Kept: the Violet gate on the west edge, the L-shaped pond above the road, Dark Cave's mouth in the north-east rock face, the ledged tall grass south of the gate, the opening south to Route 30, and the full cast.
  - Added: a T-junction where the Route 30 lane turns south, two ledge-terraced meadows, a fenced orchard with two fruit trees, Erick's wooded grass pocket and a hidden glade.
- **Route 32:**
  - Kept: all 45 vanilla rows, block for block, in cols 0–9. Every NPC, item, sign and scene keeps its spot, shifted down by the inserted bands (vanilla rows 12–19 +5, 20–34 +9, 35–44 +13).
  - Added: four columns east (a grass shelf past the Cooltrainer, who still blocks, and open sea with rock islets), plus three inserted bands: a meadow with a woodland pond and ledge, a fisherman's cabin before the pier, and a jetty north of the Center with a Fishing Guru.
  - It's 1.8x rather than 2x because the buffer limit (1,300) caps a 58-row map at 14 columns.
- **Route 36:**
  - Kept: all of vanilla, block for block, split at its forest divide. That's the National Park gate, Suicune's spot, the path to Route 37, the meadow, the road to Violet and the Ruins of Alph gate in its rock ledge.
  - Added: an 8-column woodland between the halves (pond, a straight road, a ledge over a tall-grass dell), a southern band with a second meadow and pond, and two more rows north for the Route 37 path.
  - The Ranger still plugs the west-half choke, as in vanilla; amap only reports the north exit as gated because of him.

## Tools added here
- `render_other.py REPO OUTDIR Map... [--grid]` renders named maps from another pret hack, with that hack's own tiles. It's used for `ref/` (pokefollow) and `ref/vanilla/`.
- `rough.py IN OUT [--seed N --p P --scatter S]` makes forest edges ragged. Grass touching a forest block gets a small-tree block on that side, and open grass gets the odd single tree. Add `keep X Y` lines to protect a cell. Rerun `amap.py` afterwards to check walkability.
- `amap.py` is a copy of `handmade/amap.py`.
- `jgrid.py` is shared by `build31/32/36.py`. It mixes hand-written rows with vanilla `.ablk` rows and assigns key characters that avoid `rough.py`'s tree keys.
- `meta.py NAME` wraps `NAME.amap` with `NAME_header.txt` and appends `NAME_objs.txt`; run it after `rough.py`.

## Open points
- **Route 30 / Violet:** Route 30's south exit is now col 3 and Cherrygrove's north avenue is cols 13–14, so the offset changes. Route 31 (not expanded) sits between Route 30's north exit (col 3) and Violet's east gate. Violet's gate warps move to (55,24/25), its Route 32 exit to cols 13–14 and its Route 36 exit stays on row 4.
- **Connection offsets:**
  - Route 29's east exit is at rows 8–9 and New Bark's west exit at rows 8–9, so that pair lines up.
  - Route 29's west exit (row 6) and Cherrygrove's east exit (rows 4–5) need a connection offset.
  - Route 27, Route 30 and Route 46 need their edges checked.
- **Warps into the expanded maps:** every interior warp back into these maps needs its coordinates updated, and so do the scene coord events (the teacher stop and the Cherrygrove rival scene) and the Fly spawn points.
- **Routes 31/32/36 connections:**
  - Route 31's south opening is col 18, against Route 30's north exit at col 3, so the offset is −15.
  - Route 32's north opening is cols 5–7, against Violet's south exit at cols 13–14.
  - Route 36's road is on row 6, against Violet's west exit on row 4, so the offset is −2. Route 37 needs rechecking.
  - Route 32's Center warp moves to (11,99) and the Slowpoke Tail coord event to (7,97). Route 36's coord events and warps shift +4 steps in y.
- **Bank space:** block data grows by 1,076 B (580 to 1,656), and it fits where the maps already live. Route 29 is in "Map Blocks 1" (+346 B of 3,382 free). New Bark and Cherrygrove are in "Map Blocks 2" (+730 B of 2,206 free). Routes 30, 31, 32 and 36 are also in "Map Blocks 1": +449, +240, +362 and +260 B. With Route 29 that comes to about 1.66 KB of the 3,382 B free, so it still fits.
- **Edges:** the brook and the sea run off the map edges into the border block, so check how that looks in game.
- **Cherrygrove's Pokémon Center art** waits on the no-Center decision.

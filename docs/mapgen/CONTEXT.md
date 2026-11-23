# Map-making: resume context (as of 2026-11-04)

Read this first when picking the new-maps work back up. It covers what exists, how it was made, what is known about the tilesets, and what still has to be decided. Nothing here touches the build: `docs/` is untracked, and no map has been added to the game yet.

- Gallery with renders of everything: https://claude.ai/artifact/Gopa3NeqizhH6fJ9GTjpRL (version 6). Republish from `docs/mapgen/gallery/index.html`: it is a fragment, so prepend the doctype/skeleton the live page has (read it first) and publish with its `img/` files.
- Tool usage: `docs/mapgen/README.md`. Integration checklist: `docs/mapgen/tooling/report.md`.
- **Ultimate aim (shasocastris, 2026-11-04):** an *expanded Johto*. Existing maps stay recognisable but get larger, with more to explore in towns and on routes. The new-map batches are a pool of ideas for that. The expanded vanilla maps are the main thread: see `expand/README.md`.
- **Status: design only, except Ice Path Hollow** (built on branch `88-ice-path-hollow`). shasocastris is deciding where the other maps go in the world. Don't implement them until he picks maps and placements.

---

## 1. What was tried, and the verdict

Four ways of making maps on TILESET_JOHTO were tried, each by its own agent (2026-10-28):

| Approach | Verdict | Where |
|---|---|---|
| Hand design as text grids (`.amap`: one character per 32x32 block, plus a key) | **Best.** Gave the most characterful maps. Every map since uses it. | `handmade/` |
| Layout-first generator: plans path, gates, ponds and buildings, then autotiles | Useful. Always playable, but generic; good for drafts. | `structured/structgen.py` |
| Cave generator (TILESET_CAVE) | Drafts only. Edges are correct, shapes blocky. | `caves/` |
| Wave function collapse learned from vanilla maps | Not worth pursuing. Maps read as mazes, and towns fail. | `wfc/` |

The workflow that works:
1. Write a grid.
2. Run `amap.py`.
3. Look at the PNG.
4. Fix seams and broken buildings.
5. Repeat until clean.
6. Finish in Polished Map++ (`/usr/local/bin/polishedmap-plusplus`, 2.7.1).

Never use plain Polished Map 4.7.1 on this repo: it drops the per-block attributes.

## 2. Tools (all in `docs/mapgen/`; `make` must have run once)

- **`render_ablk.py FILE.ablk W OUT.png [--ref Map] [--grid] [--scale 2] [--season S] [--time T]`**
  - Draws with the real tiles and palettes through `utils/render_overworld.py`.
  - `--ref` borrows an existing map's tileset, group and environment.
  - `--atlas OUT.png` draws every block of the ref map's tileset, labelled.
- **`handmade/amap.py FILE.amap`** writes:
  - the `.ablk`;
  - plain, `_grid` and `_marked` PNGs;
  - a walkability report: every `exit` line must reach every other on foot. Cut, Surf, Strength and Rock Smash gates are reported as gated.

  Its format:
  - `tileset NAME` comes before any `key` line; a non-Johto tileset clears the default legend.
  - Then `ref MapName`, the `key X=hh` lines, and the block rows between `grid:` and `end`.
  - Then `exit DIR x y` / `obj ...` lines.
  - Doors are only checked when they are also `exit` lines.
  - `--time nite --suffix _nite` and `--season winter --suffix _winter` add palette variants.
- **Variant copies:**
  - `batch2/a_routes/amap2.py` also models Strength boulders and Rock Smash rocks.
  - `batch2/d_estate_wilds/amap.py` and `batch2/e_mansion_western/amap_local.py` are local copies too.
- **Helpers:**
  - `batch2/c_urban/tools/adjm.py BLOCKHEX...`: neighbour statistics for johto_modern blocks, mined from Goldenrod, Azalea, Route 33 and Route 34.
  - `batch3/a/tools/doors.py`: lists door step coordinates and checks that the tile below each door is walkable.
- **`structured/structgen.py {forest,lake,town} --seed N`**, **`caves/gen.py SEED`**, **`wfc/`**: the generators above.
- **`tooling/newmap.py NAME --size WxH --group G --landmark L ...`**: prints the snippet for every file a new map touches. It never writes to the repo.
- **Atlases:**
  - `johto_atlas.png`: Johto, 181 blocks.
  - `handmade/atlas_*.png`.
  - `batch2/atlas_{mansion,traditional,johto_modern,museum}.png`.
  - `batch2/c_urban/ref/atlas_*.png`.

## 3. Everything designed (36 `.amap` files)

Each `.amap` header has the full design: hook, districts, buildings, gameplay beats, exits and connections, tile gaps, and usually `obj` lines for NPCs, signs and items. Sizes are in blocks; the buffer rule is (W+6)*(H+6) <= 1300.

### Batch 1: TILESET_JOHTO (`handmade/`; `concepts.md` has 8 concepts)
- **Orchard Road** (30x11, ref Route29): an east–west route through an apricorn orchard, with a fenced farmhouse and a pond nook behind Cut/Surf.
- **Hearthhollow** (20x16, ref EcruteakCity): a hot-spring village at the foot of Mt. Mortar. An inn replaces the Pokémon Center, and the spring heals for free.
- **Whisperwood Shrine** (18x16, ref LakeOfRage): a hidden grove behind a Cut tree, with tree avenues leading to a spring courtyard.

### Batch 2: twelve outdoor maps (`batch2/`)
| Map | Size | Ref | Folder | Pitch |
|---|---|---|---|---|
| Driftbank Ford | 14x36 | Route42 | a_routes | A vertical river route from Mt. Mortar meltwater. Walk it over three bridges or Surf down it. Build with `amap2.py`. |
| Mortar Foothills | 30x9 | Route42 | a_routes | Route 42's rough sibling. Lower dirt road between mesas; the upper Mt. Mortar shelf sits behind a Strength boulder, with a TM cave. |
| Stoneway | 14x28 | RuinsOfAlphOutside | a_routes | An arrow-straight walled processional road. An Unown word puzzle opens a sealed temple. |
| Pinefall Lake Campsite | 24x18 | LakeOfRage | b_lakes_coast | A ranger campground by a waterfall lake, with a fenced camp. Tutorial for the rest-and-watch mechanic. |
| Sunleaf Terraces | 20x18 | VioletCity | b_lakes_coast | A Leppa berry farm town on four terraces; the ledges are one-way hops back down. Roof colour still to be decided. |
| Tidewatch Cape | 32x14 | OlivineCity | b_lakes_coast | A sandy shore route with tide pools and a pier, ending at a beacon lighthouse on a rocky cape. |
| Silkwater City | 24x20 | GoldenrodCity (johto_modern) | c_urban | A canal city of silk-weavers. Two railed canals split it into three banks joined by bridges. Bug-type Gym (leader Kaiko), opened by a Lantern Festival quest. Still has a Pokémon Center: swap it for an inn. |
| Brinehaven | 20x20 | GoldenrodCity (johto_modern) | c_urban | Harbour and ferry port to the Orange Islands. A Rocket smuggling quest runs through the fish market and a warehouse. Its W edge matches Silkwater's E edge row for row. |
| Mulberry Gardens | 20x16 | GoldenrodCity (johto_modern) | c_urban | Silkwater's botanical park: glasshouse, a fenced Moth Meadow with night-only bugs, lily pond, fountain and bandstand. Its S exit meets Silkwater's N avenue at connection offset -2. |
| Silverbough Estate | 26x22 | EcruteakCity | d_estate_wilds | Walled manor grounds: hedge maze, apricorn orchard, and a pond boardwalk to a tea pavilion. Two fronts: `estate` (traditional) and `estate_western`, which differ only in rows 2–4. Front door at step (24,9), (25,9) on the Western front; servants' door at (37,9). |
| Reedmere Marsh | 34x14 | Route35 | d_estate_wilds | A reedy lagoon. Wade through the reeds or cross on the boardwalk. Exits W(0,14), E(67,16), N(58,0). |
| Starfall Crater | 22x20 | Route42 | d_estate_wilds | A cliff-ringed bowl reached up a canyon. A meteorite islet holds a one-time legendary encounter, and there is a cave mouth in the north face. |

### Batch 2: two mansion interiors (7 maps each; overview PNGs and warp tables in each folder)
- **Vesper Hall** (Western; `e_mansion_western/`, `vesper_overview.png`, `warps.txt`). An astronomer vanished during an eclipse, and burglars are stripping his collection. A portrait puzzle opens a secret lab.
  - 1F: foyer, dining hall, study. 15x8, tileset mansion.
  - 2F: landing, music room, trophy room. Tileset mansion.
  - Cellar: tileset mansion.
  - Gallery and library: 15x7, tileset museum.
  - Master Suite: 7x5, tileset players_house, the only interior set with beds.
  - Secret lab: 10x7, tileset facility.
  - Rooftop telescope: 7x5, tileset mansion.
  - Gaps: no grand staircase or fireplace, and the top wall looks a bit modern.
- **Oborozuki Manor** (traditional; `f_manor_traditional/`, `oborozuki_overview.png`, `warp_table.txt`). The family keeps Ecruteak's Kimono Girls; its head is Lady Sayo. You reach the boss through a Kimono Girl quartet, a dojo and a tea-ceremony puzzle tied to the season.
  - Genkan and Great Hall: 14x10.
  - East Engawa: 20x6.
  - Kagura Hall stage: 10x9.
  - Sunken Dojo: 12x8. The mini-boss is Genkuro.
  - Study 2F with a hidden room: 12x8.
  - Kura B1F storehouse: 10x7, ref CharcoalKiln.
  - Moon Shrine loft: 10x8, the only tower-tileset map.
  - Gaps: no left or up doorways, and furniture only suits tatami floors.

### Batch 3: six Goldenrod-style cities (`batch3/`, johto_modern, ref GoldenrodCity)
All six use an inn or hotel with a PC instead of a Pokémon Center. Every door and edge exit is reachable, apart from two guard-gated doors that are deliberate. Each city has day, grid, marked and night renders.

| City | Size / buffer | Folder | Pitch and story | Exits |
|---|---|---|---|---|
| **Marigold City** | 26x23 / 928 | a | Goldenrod's flashy rival, built by the Sunburst Power Co. A 3x6 Marigold Tower department store faces a fountain plaza where a 2-wide W–E boulevard crosses a 2-wide N–S avenue. Broadcast Row has a TV tower, studio and Link Center. Two Underpass kiosks lead to an underground mall. Also the Grand Marigold Hotel and Old Marigold to the south. During the Eclipse a cult drains the city's power from the tunnels; the Electric Gym (leader NOVA) stays dark until they're cleared, so a guard stands on the Gym door. 23 doors. | N/S avenue, W/E boulevard |
| **Sorrel Junction** | 28x23 / 986 | a | A railway crossroads. A fenced double main line crosses the map with two level crossings (7f). Sorrel Central is an 8x4 station with two doors, its roof against the track like Goldenrod's. Also Freight Row warehouses, a grey Signal Tower, a goods yard and siding, Station Square, a Market Street with 12 stall kiosks, Commuter Row and the Sleeper Car Inn. The Signal Tower goes dark and trains are held: recover cargo from Warehouse 2 (guard-gated), fix the tower, get a Rail Pass. 30 doors. | N Northgate Rd, S Market St, W/E Platform St. Rails leave W+E (rows 5–6) and E (rows 9–10), so neighbours must continue them or end them in a tunnel. |
| **Cinderwick City** | 26x22 / 896 | b | An ironworks city cut by the railed Cinder Canal. North of it: a fenced Ironworks with warehouses, slag heaps and the Furnace Tower (radio-tower art), plus four rows of workers' cottages. Only 5 of the 20 cottages have doors. South of it: downtown, with the Furnace Hotel, Mart plaza, Market Row, Freight Station, Cooling Pond and the Fire Gym (leader Brenna). The furnace is cold because Slugma, Magby and Koffing nested in the flue; clear the tower to open the Gym. | N/S avenue (cols 12–13), W Canal St (row 11), E road (row 15). Canal water exits W and E for Surf. |
| **Vellum City** | 26x24 / 960 | b | A university town around a formal quad: lawns, a headbutt grove and a reflecting pool. A 5x4 Great Library with a quiz puzzle inside. Campus Hill has an observatory (night comet event) and a natural history museum. Science Row has a lab and a research institute. Also dorms, a Student Union and a Lecture Hall (daily rematches), Quill Lane with the Scholars' Inn, bookshop and café, and Varsity Lake with a boathouse. No Gym. | N Univ Ave (cols 19–20), W/E College St (row 14), S (cols 12–13) |
| **Morrowmere City** | 30x22 / 1008 | c | "The city of yesterday and tomorrow." The wide natural River Mere splits the old west bank (brown roofs, the Gym, a museum, Lantern Inn) from the new east bank (towers, Magnet Train terminus, Grand Hotel). A Clock Tower stands on an island quay mid-river. The Old Bridge carries Main Street across; two short bridges reach the island; there are promenades and a fishing pier. The clock has stopped and each half blames the other: get the part from the tech firm's tower, climb the Clock Tower, and the Gym reopens. Gym type to be decided: Steel or Psychic. | W/E Main St, S park avenue, river N/S by Surf, Magnet Train. The rail at the top right runs off the edge. |
| **Vespera City** | 28x24 / 1020 | c | A seaside resort that wakes at dusk. The Grand Boulevard runs from the northern hills past Marquee Row (pillared Moonlight Theatre, Game Corner, Prize Exchange, Galleria, Mart, boutique), round a fenced fountain plaza, down to the pier. An 8x5 Colosseum and an open-air Battle Court are the battle draw; there's no Gym. Hotel Row: Twin Stars (twin towers), Bellevue, Grand Strand and the cheap Seashell Inn with a PC. A beach with a seawall, café and lifeguard hut. The beach is path-coloured because there's no sand block. | N boulevard, W/E beach promenade, S sea by Surf |

### Batch 4: anime locations (`bluemoon/`, 2026-11-09)
- **Blue Moon Falls** (20x18 / 624, ref Route30): from anime EP127 "Once in a Blue Moon", near Cherrygrove. A rock wall split by one narrow fall above a wide pool dotted with 87/a8 "offering stones"; a forested meadow approach from the S and a brook out SE (Surf). On Monday nights ("moon day"), Quagsire (follower sprite) sit on the stones, and the shore Quagsire trades a Moon Stone for a Poke Ball. The stones are solid, so stone objects and hidden items are reached by Surf. Exits: S (16,35) on foot; brook (35,35) by Surf. The waterfall channel runs off the N edge and could become a Waterfall connection later.

### Batch 5: Ice Path secret (`icepath/`, 2026-11-10)
- **Ice Path Hollow** (18x20 / 624, TILESET_ICE_PATH, ref IcePath1F): "the Washouts and the Obsessed", trainers the Dragon Shrine failed. Entered from the cave mouth over Blackthorn's waterfall (johto blocks `a9`/`aa`, steps 45,22 and 46,22), so Surf + Waterfall. Scrapyard with a frozen runnel, a 13x5 ice river (4 slides + exit, no traps), an arena, a false-shrine dais with the boss and an Outrage tutor, a Rock Smash wing, and a one-way ledge route home. Rewards and trainer teams are in the `.amap` header.
  - **Two floors since 2026-11-11 (built, same branch):** the Hollow is `IcePathHollow2F` (ladder at 17,37) and a river floor `IcePathHollow1F` (16x18, `icepath/f1/`) sits under it. The player arrives on 1F surfing (warps 7,32 and 8,32); the river runs mouth -> north -> north-east -> climbable waterfall -> upper level -> spring, and the ladder to 2F (27,5) is on the upper level. 1F has four trainers, two item balls and a hidden item. Event flags are not scarce: only the last group is full, and the `const_next` jumps leave 486 free IDs between groups (new flags go at the end of an earlier group). Both floors fight in hail and have authored snow.
  - **shasocastris reworked both floors and the water blocks by hand on 2026-11-11, so the built maps are the source of truth.** `icepath/from_build.py MapName WIDTH DIR NAME` regenerates each `.amap` (grid from the `.ablk`, exits and objects from the `.asm`, header from `head.txt`); the `.ablk` it writes round-trips byte-for-byte. The old sketches are in `icepath/superseded/`, `build.py` is retired for these two maps, and `water/apply.py` refuses to run (it would overwrite his blocks). His changes: 1F river narrowed to two blocks and re-routed, objects moved; 2F lost the Scrapyard's frozen runnel and the SW nook waterfall, the camp pool is a banked 3x2, the Tally Wall sign moved to the dais front (16,7), the Vein is 11x5 with a 5-stop route (8,23 -> 28,23 -> 28,19 -> 22,19 -> out at 22,15), and the three hidden items are at 33,5 / 5,33 / 21,19.
  - **TILESET_ICE_PATH water blocks as built (84 blocks, `00`-`53`; atlas `icepath/water/blocks_40_53.png`):** `40` open water; `41` climbable fall, no banks; `42` E bank; `43` W bank; `45` N bank; `46` NE corner; `47` NW corner; `44`, `48`-`4b` further bank and inner-corner variants (read them off the atlas); `4c`/`4d` the water cave mouth (`WARP_SURF_DOWN` on the two middle top tiles, rest WALL); `4e`/`4f` wall-fall halves with W / E bank, WALL collision (the 1F spring); `50`, `51` water with a full-height W / E bank; `52`/`53` climbable fall halves with W / E bank. No south bank by design. A fall that comes out of solid rock must be WALL collision, or Waterfall walks the player into the wall.
  - `icepath/river.py` and `slides.py` check reachability with Surf and Waterfall, and read collisions from the repo, so they follow the renumbering. As built: no trap states on either floor; on 2F only the NE wing needs Rock Smash.
  - Tools: `icepath/amap_ice.py` (amap with ice sliding, pits, `rock` objects), `icepath/trace.py` (prints a route), `icepath/from_build.py` (built map -> `.amap`), `icepath/build.py` (sketch autotiler, retired for the Hollow).
  - Ice Path grammar: boulder walls cover every quadrant mix except diagonals (`14`-`16`, `18`, `1a`, `1c`-`1e`, `20`-`23`, fill `19`); ice `1f` takes at most one rock per block (`2c`-`2f`); plateau set `04`-`0e` with steps `12`; ledges `24`-`28`; exit `29` over `2a`. Water is `40`-`53` (above). `2b`, `30`-`36`, `3c`, `3d`, `3f` are the Hall of Fame's.
  - `utils/render_overworld.py`'s `CSE.pals()` skips `LoadSpecialMapPalette`, so Ice Path renders with green ice; `amap_ice.py` applies `ice_path.pal` itself.
  - **Implemented 2026-11-10 on branch `88-ice-path-hollow`** (`maps/IcePathHollow.asm`), the first mapgen map in the build. Differences from the `.amap` header: the entrance steps are 45,23 and 46,23 (`a9`/`aa` got `WARP_SURF_UP`; `MaybeRestoreSurfState` now only re-surfs on water); its 14 event flags sit in old `const_skip` slots (flags were wrongly thought full then; the hidden items cut for that are back); every TM is already placed, so the wing holds a DRAGON SCALE; there is no `giveegg`, so the "Company" reward is a L5 HORSEA holding a DRAGON SCALE; the Johto grass table's bank is full, so the encounters are an all-season entry in `data/wild/season_grass_data.asm`.

## 3b. Expanded vanilla maps (`expand/`, 2026-11-04)
**Full handoff: `expand/CONTEXT.md`** (every draft, rebuild commands, connection offsets, the cost of implementing them, and a next-session prompt).
pokefollow (`../pokefollow`) was studied as the model: its Pallet Town, Route 1, Viridian, Route 2 and Pewter, plus the new Pallet Lake and Oak Corral. `expand/README.md` has the comparison table and the six rules it suggests: keep the landmarks and their relative layout; scale tiny towns by about 2.4x per side, widen routes, make cities denser; use water and bridges; give every plot an edge; use ragged edges; put side areas on separate maps.
- Drafts, all passing walkability:
  - `newbark.amap`: 24x20, vanilla 10x9. A brook splits the four vanilla quadrants; also a jetty, Elm's research field and a hilltop.
  - `route29.amap`: 44x14, vanilla 30x9. An upper level with a pond and fruit grove behind the gate path, a rest cabin, stands of woods and meadows below ledges.
  - `cherrygrove.amap`: 28x20, vanilla 20x11. The vanilla shoreline is pasted in verbatim; also a north avenue, a Mart, a pier and the cherry grove.
  - `route30.amap`: 20x40, this repo's 13x27. Path-ledged west road, Mr. Pokémon's hilltop, berry garden, Hana's glade, east wild lane.
  - `violet.amap`: 28x24, vanilla 20x18. The vanilla north half (tower, moats, Gym, Academy) is pasted in verbatim; also two streets, seven houses, a Mart, a garden pond and Earl's practice field.
  - `route31.amap`: 30x14, vanilla 20x9. Gate, L-pond, Dark Cave rock face kept; a T-junction south to Route 30, ledged meadows, a fenced orchard, Erick's pocket.
  - `route32.amap`: 14x58, vanilla 10x45. All 45 vanilla rows pasted in cols 0–9; four columns of grass shelf and sea east; three inserted bands (a meadow pond, a fisherman's cabin, a jetty with a Fishing Guru). It's at the buffer limit (1,280).
  - `route36.amap`: 34x14, vanilla 24x9. Vanilla split at its forest divide, with an 8-column woodland (pond, ledge, dell) inserted and a southern meadow band.
  - Builders for the routes share `expand/jgrid.py` (vanilla rows + hand rows); `expand/meta.py NAME` adds the header and objects after `rough.py`.
  - Next candidates: Route 37, Ecruteak, Routes 33/34, Azalea and Goldenrod. The connection offsets for 30–36 are listed in `expand/README.md`.
- Side-by-side images: `expand/compare/` (vanilla vs expanded, and Crystal Eclipse vs pokefollow).
- New tools:
  - `expand/render_other.py` renders maps from other hacks.
  - `expand/rough.py` makes forest edges ragged; rerun `amap.py` afterwards.
- Block data fits the existing banks: about +1.66 KB in Map Blocks 1 (Routes 29–32 and 36, of 3,382 B free) and +730 B in Map Blocks 2. The cost is in re-pointing warps, coord events, Fly spawns and connection offsets.

## 4. Placement ideas proposed so far (not decided)
- **Mt. Mortar country:**
  - Route 42 → Hearthhollow → Driftbank Ford (south) → Pinefall Lake.
  - Mortar Foothills runs east from Hearthhollow to Mahogany.
  - Starfall Crater sits up in the high ground.
- **Orchard belt:** Orchard Road → Reedmere Marsh → Silverbough Estate. The manor is either Oborozuki Manor or Vesper Hall: pick one.
- **New coast:**
  - Mulberry Gardens → Silkwater City → Brinehaven, the ferry port to the Orange Islands.
  - Tidewatch Cape hangs off Olivine or Route 40.
- **Near Violet:**
  - Sunleaf Terraces north of Route 36.
  - Stoneway off Route 32 toward the Ruins of Alph.
- **Batch 3 has no placements yet.**
  - Sorrel Junction pairs naturally with Goldenrod's Magnet Train or a new rail line, as does Morrowmere's terminus.
  - Vespera wants a coast.
  - Cinderwick's canal and Silkwater's canals are separate ideas; don't merge them by accident.
  - Batch 3 adds three Gyms (Electric, Fire, Steel/Psychic) and Silkwater adds a Bug one. Check them against the existing badge plan before committing to any.

Open decisions for shasocastris:
1. Which maps, and where.
2. Which manor.
3. Silkwater's Center, which should become an inn.
4. Gym types.
5. Whether cherry trees should stay pink in the winter palette.

## 5. Tileset knowledge gathered

**TILESET_JOHTO (181 blocks)**
- Rivers: `88`/`8a`; rapids `8e`/`8f`; waterfall foot `90`/`91`.
- Bridges: `98`/`99` is the surf-under state and `89` the walkable deck. Route 45's `changebridgeblock` scene swaps them. `89` doubles as a plank boardwalk.
- Pier: `a3`.
- Ledges: `56` path ledge, `57` grass ledge. They are standable (`COLL_HOP_*` count as land).
- Cliff stair: `81`.
- Ruins grammar: `6a`/`70`/`6b`, with `73` as the doors. Grey fence walls: `40`–`4a`.
- Long grass: `80`.
- Blocks no vanilla Johto map uses: `7b` soil beds, `7c`/`7d` tent pads, `ae` sprouts, `ad` stall. Confirm they aren't set aside for something else before relying on them.
- Cherry trees stay pink in the winter palette.

**johto_modern (132 blocks)**
- Gym front: `1c 0f 1d 1e`. Block `1d` carries the GYM sign; use it only on Gyms.
- Canal: a row of `43` (rail) above a row of `61`.
- Water: `35`; pond shore `54`/`76`/`55`/`58`/`59`; railed south bank `60`/`61`/`62`. There is no plain bottom-shore block.
- Stalls and kiosks: `67`, a one-block house with no door. Flowering street trees: `66`/`80`.
- Rails run west–east only: `7e` track and `7f` level crossing. There are no curves, north–south pieces or buffer stops, and the level crossing is light ground even on brick.
- Big buildings are composed from Goldenrod's department-store and Radio Tower pieces:
  - Grey tower: mast `21 22 22` over `25 26` / `29 2a` / `2d 2e`. Stacking `29`/`2a` twice works.
  - The only office front is `20`/`24`/`5f`, and `5f` has "PCC" baked in.
  - Brown roofs use `7b` as the middle piece. Under it, `1c 16 1e` leaves a faint line left of the door.
  - `7c`/`7d` are a pillared front that Goldenrod never uses; check their attributes.
  - The `1a` door leaves a seam on very wide fronts, and `0f` fills the wall on 4-wide hotel bottoms.
- Missing: lamps, benches, statues, crates, a real fountain (fountains are fenced ponds), sand, a bridge deck, a clock face, a stadium bowl and a smokestack.

**Interiors**
- Mansion: 64 blocks. Traditional house: 76. Museum: 38.
- The traditional set has no left or up doorways.

**Cheapest art wins**, which would unblock several maps at once:
- a plain `5f` office front;
- a sand block;
- one street-lamp or bench block;
- a bridge deck for johto_modern.

## 6. Adding a map to the build (from `tooling/report.md`; reverify before starting)
1. `constants/map_constants.asm`: add the `map_const` at the **end** of a group, keeping (W+6)(H+6) <= 1300.
2. `data/maps/maps.asm`: the header row. The environment (TOWN or ROUTE) also drives weather, seasons, roofs and Dig.
3. `data/maps/attributes.asm`: connections in N, S, W, E order, each mirrored on the neighbour. That bank has 1 byte free but floats.
4. `data/maps/blocks.asm`: "Map Blocks 3" (bank $2c) has 5,876 B free.
   - The six cities alone are 3,770 B of blocks, so check before adding many.
5. `data/maps/scripts.asm`: "Map Scripts 29" has 2 B left, so start a "Map Scripts 30".
6. Scenes: a missing `scene_var` fails silently, and scene bytes can't be appended, so reuse a dead one.
7. Landmarks: reuse where possible. Landmark ids are saved, and one appended at the end counts as Orange.
8. Wild data: bank $0a has 10 B free and is fragile. The seasonal tables in bank $75 are the safer route, still unverified.
9. A new map group needs:
   - `roofs.asm`;
   - `sgb_roof_pal_inds.asm`;
   - `roofs.pal` and `roofs_winter.pal`;
   - `MapGroupSizes` in `engine/events/weather.asm`.

   All of these are assert-checked.
10. A Fly point needs:
    - spawn and fly constants;
    - `spawn_points` and `flypoints`;
    - an `ENGINE_FLYPOINT_*` added at the end, shrinking the reserved block after `wVisitedSpawns`.
11. Event flags: 29 free `const_skip` slots.

Reference commits for adding outdoor maps: Valencia `f6a18a33b` and Shamouti `702b193c1`.

Suggested first implementation once placements are chosen:
- Use one small map end to end (Hearthhollow was the earlier suggestion) on a new branch, to prove the pipeline.
- Then batch the rest.
- Open the `.ablk` in Polished Map++ to touch up, write scripts from the `.amap` `obj` lines, and keep all map text to 18 characters per line.

## 7. Process notes for a resumed session
- The batches were made by subagents working in parallel (2 or 3 maps each) with a shared brief:
  - study the reference map's block patterns;
  - write a grid, render it, look at the PNG, and repeat until clean;
  - list every door as an exit;
  - add a night render;
  - write a full header comment.

  Subagents couldn't write report files, so they returned their summary in their final message.
- Do not reuse concepts across batches. Batch 3 was told to avoid Silkwater, Brinehaven and Mulberry.
- House rules:
  - keep helper scripts uncommitted and listed in `docs/helper_scripts.md` (already listed as `docs/mapgen/`);
  - never `git add -A`;
  - keep source comments short.
- Project memory: `project_map_making_exploration.md`.

# Helper scripts

Tools written to do or check a task. They live under `docs/`, not `utils/`; promote one to `utils/` when it becomes part of the workflow. Add any new helper to this list.

Paths are relative to the repo root. Regression fixtures and reports, and mapgen renders outside `gallery/`, are generated and stay ignored.

## Reusable

| Script | What it does | Used for |
|---|---|---|
| `docs/mapgen/` (see its `README.md`) | Map-making tools: `.ablk` renderer, text-grid map authoring (`amap.py`), layout-first and cave generators, new-map snippet printer (`newmap.py`). | Map design experiments, 2026-10-28 |
| `docs/v1_research/reorder_moves.py` | Sorts move constants by type, then category, then power. Rewrites the six positional move tables slot by slot, and writes the `; TYPE` and `; TYPE (continued)` comment lines. `--check` reports whether the order is current; `--stable` keeps the existing order within a type. **Re-run it after adding a move.** | Branch 24 |
| `docs/move_review/mvlib.py` | Library for the branch-98 move review: cut/take/put a move across the five positional tables (renumbers the constants, drops an orphaned description body, refuses a cut while anything else names the move), plus learnset add/remove/replace and party move swaps. Import it with `sys.path.insert(0, 'docs/move_review')`. | Branch 98 |
| `docs/move_review/dump.py DIR` + `compare.py A B` | Dumps every move's row from all five source tables keyed by name (`python3 docs/move_review/dump.py docs/move_review > x.json`), then diffs two dumps: removed, added and changed moves. | Branch 98 |
| `docs/move_review/move_roles.py`, `type_table.py TYPE`, `learners.py MOVE...` | Report generators for the move review: per-move learners/fallbacks, per-type usage table, learners with their physical Poison moves. Output went into `docs/move_roles.txt`. | Branch 98 review |
| `docs/v1_research/dump_moves.py ROM SYM` | Dumps every move from a built ROM, keyed by name: data, animation, description, plus the TM/HM, crit, Metronome and AI lists. Diff two dumps to prove that a reorder or refactor changed nothing. | Branches 73, 39B, 24 |
| `docs/v1_research/optdiff.sh` | Runs `utils/optimize.py` and diffs it against `.opt.old`, ignoring line numbers. | Every branch |
| `docs/v1_research/bankmix.py` | Splits each ROM bank into pinned sections (named in `layout.link`) and floating ones, to show real headroom. | V1.5 budget |
| `docs/v1_research/savecheck.py` | Compares saved WRAM/SRAM block offsets and lengths between two `.sym` files. | Branch 11 save check |
| `docs/v1_research/btstats.py` | Recomputes Battle Tower stored stats with `CalcMonStatC`'s formula and reports mismatches. | Branch 39A |
| `docs/v1_research/learns.py SPECIES MOVE...` | Shows whether a species learns each move by level-up or TM/HM, and the move's PP. | Branch 39A |
| `docs/v1_research/obey_model.py` | Exact model of `BattleCommand_CheckObedience` (enumerates `BattleRandom`). Asserts the always-obey regions and prints the obey / other-move / nap / hurt / loaf odds. Update it if the thresholds or formula change. | Branch 32 |
| `docs/v1_research/rng_loop_model.py` | Cycle-level model of the obedience `.rand1` rejection loop: `Random` reads rDIV, so calls in a tight loop are correlated. It shows the real odds stay within about half a point of cap/level, except at level 100 (about 50% against 54%). | Obedience suite triage |
| `docs/v1_research/perfect_dvs_model.py` | Model of `GetPerfectDVs` against `GetGender` and `CheckShininess`. Checks every DV pair and gender ratio for kept gender and shininess and a stable result. | Branch 30 |
| `docs/v1_research/happy_sim.py` | Happiness gain simulator. | Branch 32 research |
| `docs/v1_research/banks.py`, `consts.py`, `cpscan.py`, `litscan.py`, `parse.py`, `ctx.py` | Research scanners: bank usage, constant gaps, `cp`/literal sweeps, move-table parsing. | Roadmap research |
| `docs/v1_research/unref_ram.py` | Finds WRAM/SRAM/HRAM labels with no references. | Branch 11 |
| `docs/word_room/make_word_room.py NAME LINE...` | Writes `data/tilesets/NAME_word_room_{metatiles,attributes}.bin`: the Ho-Oh word room's layout with up to six lines of Unown text (A–Y, 16 characters a line) redrawn into its 48 text blocks. Re-run it to change the Suicune room's wording. | Suicune word room |
| `docs/palgrab.py` | Palette grabber from an earlier art session. | Weather and seasons |
| `docs/playthrough_checklist.html` | Standalone page (open from disk) listing everything the regression harness verified, plus what it couldn't, as a works/problem checklist with notes. Progress is kept in the browser's local storage; it can export and import progress and copy the problems as text. Update the `SECTIONS` list when tests are added. | v0.9 hand playthrough |

## Regression harness (`docs/regression/`, SameBoy)

Headless play-testing on SameBoy's core (`../SameBoy`, built with `make lib tester CONF=release`). Python lives in `~/Documents/Romhacks/regression-env` (a venv with Pillow). Run everything with:

```sh
cd docs/regression/harness && ./build.sh && ~/Documents/Romhacks/regression-env/bin/python runner.py [suite_x ...] [--rom PATH] [--jobs N] [-k NAME]
```

The running summary of results and bugs found is in `docs/regression/results.md`. Reports land in `docs/regression/reports/<time>-<rom id>/` (`report.md`, `report.json`, plus screenshots of failures). Fixtures (save states) are cached per ROM hash in `docs/regression/fixtures/`, because a state can't move between builds.

| File | What it does |
|---|---|
| `harness/sbshim.c`, `build.sh` | C bridge over SameBoy: frames, keys, run-until-PC for one or several targets (stops just before the instruction), single step, banked WRAM/SRAM access, registers, save states, battery. |
| `harness/gb.py` | Python `Game`: read/write by `.sym` label, `press`, `run_until(label)`, `call(label, a=, hl=…)` through the game's own `FarCall_hl`, screenshots. |
| `harness/consts.py` | Resolves assembler constants (event flags, species, items) by running rgbasm on the real includes. |
| `harness/game.py` | Event and engine flags, party-mon fields, ROM table reads, species ID conversion via the game's routines. |
| `harness/fixtures.py` | `new_game` (intro by button presses) and `debug_party` (the debug radio), cached per ROM. |
| `harness/registry.py`, `runner.py` | `@test` / `check` / `Skip`; parallel runner that auto-discovers `suite_*.py`. |
| `harness/overworld.py` | Warp to any map and tile, face, talk (B through text, YES/NO answers), party-menu slot steering, give items, set happiness; "in control" means 8 consecutive idle polls. |
| `harness/suite_*.py` | The test suites (direct calls, scenes, battle, obedience, save, weather, link-removal comparison). |
| `harness/suite_repro.py` | Branch 76 repros: a door warp with stale scratch RAM (from a trainer battle or the Good Rod) keeps the player walking; the Route 45 water warp still arrives surfing; frame strips of the Raikou and Entei statics, saved to the report's shots to judge by eye; auto-Repel across a save (each kind, an old dead ID, and a copy of shasocastris's post-Battle-Tower save, skipped when the copy is gone). |
| (branch 77 edits) | `suite_weather.py` now passes `GetOvercastWeather` its register inputs (b/c = map, d = environment, e = region) since the refactor. `suite_scenes.py`'s `_tower_battle` win mode also sets the foe's type to NORMAL, so an RNG-drawn pure-Ghost foe can't wall the first move forever. |
| `harness/suite_followers.py` | Branch 85 followers: bike stow/unstow (incl. a warp while riding), ice slides, Escape Rope/Dig/Fly reappearing, all-fainted lead, Unown letters, a script changing the lead, Day-Care deposit, cutscene stow, surf to land, SELECT choice, fainted follower returning, slot on party removal, double happiness, talking to the follower (`follower_interactions`, 13 table cases, text read from the asm, standing spot from `follower_sweep.Coll`) and a source scan for `text_ram` followed by a character macro (`static_text_command_then_char`). Added 2026-11-16: `follower_surf_turn_back` (Surf prompt with the hidden follower on the water behind), `follower_route39_herd_leader` and `follower_route39_barn_whitney`. Importing it also registers all of `v10_overworld`, so a run is 40 tests. |
| `harness/v10_suicune.py` | Suicune chamber play-through: tree seal on the four chamber scientists, Scientist MAX, grunt + Nikola + Murray, the puzzle solved through the game's own place-piece path, the four item balls, the word room and the pit to the Inner Chamber (2,22). `suicune_shrine_after_solve` continues from that real solve into the shrine fight three ways (25 Unown, 26, 26 with a full bag) and checks the Clear Bell, Eviolite, fallback ball and aftermath flags. Run with `-k suicune_chamber` or `-k suicune_shrine` (it imports `v10_overworld`, which otherwise runs too). Screenshots in `docs/regression/v10/suicune/`. |
| `harness/v10_kurt_mail.py` | SAMUEL's MAIL at Kurt's house: talking to the Dragonite only cries; talking to Kurt (from below and from his right) stows the follower, shows the letter, files it in the PC mailbox (text, SAMUEL author, type), walks the Dragonite out and brings the follower back one step later. Run with `-k samuels_mail` (it imports `v10_overworld` and `v10_suicune`). Screenshots in `docs/regression/v10/kurt_mail/`. |
| `harness/follower_watch.py` | Samples object structs during a scene and reports any frame where the follower shares a tile with the player or a visible NPC. |
| `harness/follower_sweep.py` | Triggers every cutscene with a follower and records overlaps: `coord_event`s (default), talk-triggered scripts (`--objects`), map-entry scenes (`--entry`); `--all-dirs` tries every approach, `--resume` continues a report. Writes JSON and a screenshot per scene. |
| (branch 85 edit) | `v10_story.run_script` takes an optional `tick(g)` callback, called every loop step (used by the follower sweep). |
| `baselines.md`, `battle_fixture.md`, `scene_routes.md` | Research notes the suites were built from: comparison ROM builds, the battle recipe, map routes. |

## One-off (already applied; kept only as a record)

| Script | What it did |
|---|---|
| `docs/v1_research/btreplace.py` | Replaced the five legendary Battle Tower entries (39A). |
| `docs/v1_research/strip.py` | One-off source edit of `engine/battle/core.asm` from the Beat Up removal (V1.5). |
| `docs/v1_research/bug_split.py` | Moved the table split from inside BUG to the end of BUG (24 follow-up). Applied; it only works on the old pre-rename `6b9c3f249` layout (gen1/gen2 names). |
| `docs/v1_research/proto_sort.py`, `regen_proto.py` | Prototypes of the move reorder, superseded by `reorder_moves.py`. |
| `docs/followers/import_follower_sprites.py` | Converts MysticCrystal's follower sheets to 4-level greys and regenerates `gfx/following_sprites.asm` and `gfx/following_sprite_pointers.asm` (branch 85). Rerunnable. |
| `docs/followers/render_follower_sheet.py` | Contact sheet of every follower in its normal and shiny palette for one time of day. Rerunnable. |
| `docs/regression/tile_probe.py` | Prints the 4 neighbours of a map tile (LAND/WATER/WALL, facing, objects) from the built debug ROM; used for `docs/regression/scene_routes.md`. |
| `docs/regression/harness/suite_bike_headbutt.py` | Bike headbutt on Route 29 (ram, decline, on foot, HEADBUTT mon still preferred) and the Goldenrod bike shop kid's two lines. `runner.py suite_bike_headbutt`. |

## Tileset survey (rerunnable, read-only)

| Script | What it does |
|---|---|
| `docs/tileset_survey/tilesets_any.py <repo>` | Tiles drawn/used per VRAM slot, block counts and maps per tileset for `crystal_eclipse`, `polishedcoral` or `JohtoLegends`. Feeds `docs/tileset_survey.md`. |
| `docs/tileset_survey/pc_tilesets.py`, `pc_maps_by_tileset.py` | The same for `../polishedcrystal`, whose tileset layout differs. |
| `docs/tileset_survey/sizes.py` | ROM bytes for tileset files and map layouts in all four repos, plus linker-map used/free. |

## Compression checks (branch 92)

| Script | What it does |
|---|---|
| `docs/compression/ab_map_blocks.py <old.gbc> <new.gbc>` | Lays out every map's blocks and connection strips on two debug ROMs through the SameBoy harness and compares `wOverworldMapBlocks`. Run with the `regression-env` Python. |
| `docs/compression/ab_music.py <old.gbc> <new.gbc>` | Flattens the bytecode each music channel executes on two ROMs (following calls, loops and jumps) and compares it. Needs the matching `.sym` beside each ROM. |
| `docs/compression/ab_layouts.py <old.gbc> <new.gbc>` | Applies every `SCGB_*` layout on two debug ROMs and compares the palette buffers and attrmap. Used to check the SGB removal. |
| `docs/compression/ab_tower_menu.py <old.gbc> <new.gbc>` | Drives the Battle Tower level menu on two debug ROMs and compares the screens that hold still: scrolling, cancel, and 50 level/party combinations. Takes about 15 minutes. |

## Celadon greenhouse exterior (shelved on branch `96-celadon-greenhouse`)

| Script | What it does |
|---|---|
| `docs/greenhouse_previews/draft.py <out.png>` | Draws the greenhouse art (hipped glass roof, plant walls) and composites lavender, green/orange and grey glass options into Celadon City. |
| `docs/greenhouse_previews/times.py <out.png>` | The same options in day, night and winter with the engine's real palettes. |
| `docs/greenhouse_previews/wire.py` | Superseded first version (plants behind glass). Don't run. |
| `docs/greenhouse_previews/draft2.py <out.png>` | The Phipps-style redraw: bell-hipped ribbed roof, front dome and lantern, white facade, opaque glass. Renders it in grey, lavender and green/orange for day, night and winter. |
| `docs/greenhouse_previews/wire2.py` | Restores the Kanto tileset files and `CeladonCity.ablk` from HEAD, then writes the grey draft2 art (73 VRAM bank 1 tiles, blocks `$84-$89`, door collision for steps 4 and 5). Safe to re-run. |
| `docs/greenhouse_previews/draft3.py <out.png>` | The final direction: a standard Kanto building with Battle Tower glass walls, with or without a glass roof, in lavender or grey, day and night. |
| `docs/greenhouse_previews/wire3.py` | Writes draft3 (lavender glass, glass roof; 24 VRAM bank 1 tiles, blocks `$84-$89`, door at step 4). It restores the tileset files from before `03a767715`, so it can be re-run. The warp edits were made by hand. |
| `docs/greenhouse_previews/luster.py <out.png>` | Greenhouse options composed from Polished Coral's Luster City blocks (`../polishedcoral`), rendered in Celadon with CE palettes. |
| `docs/greenhouse_previews/wire4.py` | Writes `luster.py` option 2 (47 VRAM bank 1 tiles, blocks `$84-$89`, doors at steps 4 and 5). Committed as `c1972de23` on the shelved branch. |

Scripts find the repo from their own location (`_REPO_ROOT`; sibling repos such as `../SameBoy` via `_ROMHACKS`). Some read files from the old session scratchpad (`cur.json`, `.opt.old`). Check before re-running.
| docs/party_review/view.py | Annotated party view (types, Atk/SpA lean, legality, best moves): `view.py Falkner -v` |
| docs/party_review/audit.py | Flags illegal / wrong-category moves and overdue evolutions in parties.asm |
| docs/party_review/candidates.py | Proposes right-category replacements for flagged party moves |
| docs/party_review/apply_pass1.py | One-shot: party review pass 1 (already applied; do not rerun) |
| docs/movepool/matrix.py | Coverage matrix (best move per type/category + channel), gap report, who-learns-what; applies docs/movepool/proposal.py unless `--now` |
| docs/movepool/proposal.py | TM swaps / tutor changes / compat grants as data for matrix.py |
| docs/movepool/apply_tmhm.py | One-shot: rewrote every base_stats tmhm line from proposal.py (already applied on 99-party-review; do not rerun) |

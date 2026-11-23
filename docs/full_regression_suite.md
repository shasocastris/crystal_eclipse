# Full Regression Suite

Maintained reference: 2026-10-12. This documents the campaigns actually run for
the Dex branch, including the isolated Type Matchups prototypes. It is a
reusable test specification and local execution runbook, not a claim that
every possible game state has been exhaustively tested.

For the final Type prototype results and ROM hashes, see
[Type Mode 7 Comparison](pokedex_type_mode7_comparison.md). For the critical
interrupt rule, see [Battle Animation Interrupt Timing Contract](battle_animation_interrupt_timing_contract.md).

## 1. Testing Principles

1. Freeze a production baseline and a candidate. Compare fresh evidence for
   those exact binaries, with matching symbols, maps, and source trees.
2. Do not modify the player's battery or production ROM. All fixtures, saves,
   compiled observers, and generated reports live in private test directories.
3. Separate normal-button integration tests from synthetic fixtures, direct
   helper calls, and direct animation-renderer calls. Each answers a different
   question; one cannot replace the others.
4. Test actual displayed frames and physical time. An animation can return and
   perform the same logical updates while taking much longer on screen.
5. Preserve failures, timeouts, skipped cases, baseline exceptions, and retries.
   A missing report or incomplete case set is not a pass.
6. Use independent expectations where possible: canonical order/data,
   separately transcribed chart values, known graphics, and a frozen baseline.
   Generating both implementation and oracle from the same erroneous result
   would make the test circular.
7. Rebuild/recreate fixtures after a new link. Saved CPU state contains PCs,
   banked addresses, and caller state and cannot safely be reused across ROMs.

Counts below describe the October 12 catalog: **373 species, 333 moves,
18 types, and 122 music entries including silence**. Several counts overlap,
and some are pairs or nested assertions rather than complete scenarios. Do not
add them into a misleading grand total.

## 2. Environment And Required Inputs

Commands are run from the repository root. The local native tools require:

- Python 3, Pillow, and the repository's Python modules.
- RGBDS and the normal Makefile toolchain for fresh private ROM builds.
- Clang with C11 support.
- SameBoy source at `~/Documents/GitHub/SameBoy`; runners compile its native
  core together with read-only observers or explicit fixture helpers.
- CGB boot ROM at `/Applications/SameBoy/SameBoy.app/Contents/Resources/cgb_boot.bin`.
- Sufficient disk space for two source/build trees, copied batteries, native
  checkpoints, screenshots, and compressed event traces.

Record Python/RGBDS/Clang versions and the SameBoy revision with the campaign.
Changing emulator/toolchain versions deserves a new baseline comparison rather
than mixing old and new observer results.

```sh
export PYTHONPATH=tools:.
python3 --version
rgbasm --version
clang --version
git -C ~/Documents/GitHub/SameBoy rev-parse HEAD
```

### Frozen Game Inputs

The established `type_full_regression` adapter expects a source directory with:

```text
candidate/                         matching source and linked build
pokecrystal-dex-types.gbc           immutable candidate ROM
pokecrystal-dex-types.sym           matching symbols
pokecrystal-dex-types.map           matching allocation map
pokecrystal-dex-types.sav           copied review battery
rollback-source.tar                source archive matching production
```

Conventional production `pokecrystal.gbc/.sym/.map` must also be present at the
repository root. Preparation copies these frozen baseline files into the
baseline source directory as well as the expected test aliases. This matters
for linked host tests: without those conventional filenames, a baseline may
skip tests or produce file-not-found errors while the candidate runs them.

The preparation manifest records SHA-256 values and protects production files.
Never pair an old `.sym` with a newly linked ROM. Never treat an old JSON report
as acceptance for a new ROM simply because the filename is unchanged.

### Retained Fixture Dependencies

The current local adapter is **not self-contained on a clean clone**. It uses
retained ignored build artifacts as fixture definitions:

- `build/dex-moves-search-final-review-20261011/`: `all-seen-tests.sav`,
  `legacy-input.sav`, `sort-manifest.json`, and `moves-mode-manifest.json`.
- The sort-memory source referenced by that Moves manifest, including its
  `battle-review/` donor battery and matching manifest.
- `build/dex-unown-black-20261011/unown-manifest.json` and the old ROM/symbol/save
  paths referenced for the Unown negative controls.
- The retained Type/cursor source and rollback inputs when rebuilding mode-7
  variants through `tools/build_dex_types_mode7.py`.

Follow the manifest paths before cleaning any historical build directories.
Fixture manifests provide data/setup definitions, **not historical pass
evidence**. The current campaign recreates cores, checkpoints, and assertions
against the new link.

The October 12 integration uses `--baseline-source` on `prepare` to select frozen
pre-integration ROM/symbol/map files while protecting the newly integrated root
ROM. The source archive must still match that selected baseline. Private source
snapshots also need converted graphics sidecars for native visual checks; the
integration snapshot copies current `gfx/`, including all Unown forms. A normal
ROM build alone does not necessarily generate every visual-test sidecar.
Host snapshots also require the generated `dex-area-assets`, `dex-info-assets`,
`dex-moves-assets`, `dex-moves-mode-assets` and `dex-sort-assets` directories under
their own `build/`. Missing fixture tables are setup errors, not game regressions;
correct the snapshot and rerun the affected phases before acceptance.

After approved cleanup, compact archives live under
`research_artifacts/dex-build-history-20261012/`, outside disposable builds.
Required historical fixture batteries/manifests, Unown negative-control cores,
ROMs/configs/source/converted graphics remain at their original live paths.
Other old source/reports/ROMs/saves/screenshots can be recovered from verified
family archives. Raw traces, temporary states, captured PCM and intermediate
observers are deliberately retired, not promised recoverable. Recreate fresh
evidence rather than attempting to rerun an archived report against missing
temporary checkpoints. See the integration report for actual cleanup results.
The destructive retention workflow has six isolated safety tests:

```sh
python3 -m unittest tools.test_dex_build_retention
python3 tools/cleanup_dex_builds.py --verify
```

For durable reuse on another machine, archive the batteries, source archive,
negative-control ROMs, manifests, dependency versions, and hashes together.
The adapter's fixed paths must then be parameterized/remapped explicitly.
An all-moves-seen fixture is for UI coverage; it does not replace empty/mixed
discovery fixtures or prove that gameplay discovery hooks work.

## 3. Full Campaign Execution

Use a fresh output under `build/`. Preparation rejects an existing output.
These examples use one existing final Type source and a new campaign directory:

```sh
python3 -m tools.dex_timing.type_full_regression prepare --source build/dex-types-mode7-audio-20261012/runtime --output build/regression-new-review
python3 -m tools.dex_timing.type_full_regression setup --output build/regression-new-review
python3 -m tools.dex_timing.type_full_regression dex --output build/regression-new-review
python3 -m tools.dex_timing.type_full_regression moves --output build/regression-new-review
python3 -m tools.dex_timing.type_full_regression persistence --output build/regression-new-review
python3 -m tools.dex_timing.type_full_regression discovery --output build/regression-new-review
python3 -m tools.dex_timing.type_full_regression gameplay --output build/regression-new-review
python3 -m tools.dex_timing.type_full_regression battle-discovery --output build/regression-new-review
python3 -m tools.dex_timing.type_full_regression timing --output build/regression-new-review
python3 -m tools.dex_timing.type_full_regression readiness --output build/regression-new-review
python3 -m tools.dex_timing.type_full_regression host --output build/regression-new-review
python3 -m tools.dex_timing.type_full_regression historical-host --output build/regression-new-review
python3 -m tools.dex_timing.type_full_regression gift --output build/regression-new-review
python3 -m tools.dex_timing.type_full_regression chart --output build/regression-new-review
python3 -m tools.dex_timing.type_full_regression diagnose-types --output build/regression-new-review
```

Run `discovery` before `gameplay` recreates the 100-move battle fixtures.
`readiness` depends on custom-menu fixture setup from `gameplay`. The focused
arrow/Type tests and exhaustive animations below must finish before `report`:

```sh
python3 -m tools.dex_timing.dex_arrow_cursors --output build/dex-types-mode7-audio-20261012/runtime
python3 -m tools.dex_timing.type_matchups --output build/dex-types-mode7-audio-20261012/runtime --all-models
python3 -m tools.dex_timing.type_full_regression report --output build/regression-new-review
```

For the two-variant layout, first prepare `BASE/runtime-regression` and
`BASE/precomputed-regression` using their respective source directories. Then
the campaign wrapper executes the ordered phases and stores statuses/logs:

```sh
python3 -m tools.dex_timing.type_mode7_campaign --base build/dex-types-mode7-audio-20261012 --variant runtime
python3 -m tools.dex_timing.type_mode7_campaign --base build/dex-types-mode7-audio-20261012 --variant precomputed
```

Do not rerun the full wrapper into a completed campaign merely to retry one
phase. Its optional phase selection retains previous attempt statuses/logs:

```sh
python3 -m tools.dex_timing.type_mode7_campaign --base build/dex-types-mode7-audio-20261012 --variant runtime --phases host historical-host report
```

Most established modules cap workers at six. Exhaustive renderer runs use eight
by default. Separate variants can run concurrently, but never run two writers
against the same fixture/core/report directory. Avoid editing a candidate
while its tests are running. If CPU headroom is needed, reduce workers in the
phase command definitions or run phases serially; do not silently reduce case
coverage. Child processes can keep running after a parent is interrupted.

## 4. Pokemon Dex Coverage

Primary tools: `moves_search_dex_regression`, `listing_options`,
`search_qualification`, `mode_transitions`, `unown_regression`,
`performance_regression`, and `dex_arrow_cursors` in `tools/dex_timing/`.

The main Dex qualification has 4,479 scenarios:

| Suite | Cases | Coverage |
| --- | ---: | --- |
| Listing/sort popovers | 2,238 | All 373 species, three orderings, Modern and Legacy |
| Integration | 66 | List/detail and surrounding owner handoffs |
| Modal qualification | 144 | Popover input, publication, return ownership |
| Visual qualification | 192 | Layout, graphics, palette and cursor states |
| Edge cases | 13 per style | Empty/sparse/full seen sets, sort reset/no-op, gaps |
| Navigation | 399 | Directions, paging, wrapping, controller states |
| Selected owner | 1,178 | Frontpics, animation, cry, detail paging and returns |
| Pokemon search | 144 | Type filtering/order and displayed results |
| Search/list returns | 36 | Returning to the correct species/order/style |
| Search defaults/empty | 24 | Default Bug, blank secondary type, empty results |
| Mode transitions | 32 | 192 transitions across representative indices/phases |

Additional mode-transition runs enter Unown after prior Info and Moves views.
Locked/unlocked modes and closing/reopening must remain coherent.

Important invariants:

- New/evolution, National, and alphabetical vectors match canonical data;
  "National" currently means the game's existing sequence, not promised
  official National IDs. Species ID changes need separate oracle updates.
- Selecting a different sort starts at the list beginning. A same-sort no-op
  retains selection. Minisprites, names, frontpic, caught marker, and palette
  must agree immediately, including when already at the top before re-sorting.
- Modern/Legacy paths use their intended new colored frontpic/cursor rendering,
  without stale mini tiles, category/type palettes, or missing borders.
- Search ranks unordered dual-type matches first, then Type 1-only, then
  Type 2-only results. Assert against an independent expected sequence, not
  only a result count. Empty and duplicate/identical criteria are exercised.
- Search forms, Slowpoke animation, compact badges, blinking row cursor,
  result footer, palette restoration, and all return paths remain correct.

### Unown

The current campaign has 136 scenarios, 2,212 form selections, and 126 direct
draw units. It covers empty sets, all individual letters, varying set sizes,
ascending/reversed/rotated/shuffled order, sparse sets without A, and A in the
middle. It checks letter indexing, title/footer overlays, portrait palette
bounds, solid red outside background, solid black panels, and return ownership.
Direct draw cases include the tested monochrome/color flag variants; this is
not a full physical DMG gameplay campaign.

Negative controls must detect the earlier indexing, background, and panel
defects. A checker that passes both good and intentionally bad ROMs is not a
useful acceptance oracle.

The static Unown performance prototype adds native button-to-display sweeps:
112 cases on each of CGB 0/A/B/C/D/E, both listing origins and four input
phases. Every displayed frame must be an old or new whole selection; assert
that picture/map DMA stays within VBlank, the original form/banks are restored,
and returning preserves the originating selection. Compare ordinary Modern
and Legacy selection/entry timing against the frozen production link.

Its direct decoder fixture has 156 cases: all 26 forms after prior 5-, 6-,
and 7-tile species, with original form values 1/26. Check the independent
padded base image and stack/ROM/WRAM/SRAM restoration. The intentionally stale
dimension decoder must fail the expected 104 cases. Type return checks must
inspect Unown's actual centered portrait tiles and resident font/blank bytes,
not the generic top-left portrait oracle. See
[Unown Performance Prototype](pokedex_unown_performance_prototype.md) for the
recipe, evidence, ownership contract, and this run's explicit coverage limits.

### Selected Playback And Entry Timing

For each style, exercise all 373 species in cold, paging, and warm suites:
2,238 playback cases per candidate. Check actual picture frames, timelines,
resident tiles, upload/decode services, queue ownership, and cry completion.
Idle listing checks verify 120 hover frames do not resume cache warming.

### Selected Runtime Display Qualification

The October 12 private runtime-display trial additionally removes Info glyph,
heading, number/bar and species-display tables, plus Selected Moves metadata.
It does not remove Area data or portrait scheduler plans. See
[Selected Pokemon Runtime Display Prototype](pokedex_selected_runtime_prototype.md)
for the frozen inputs, allocation delta, retained data, timing tradeoffs, and
existing host exception.

`tools/test_selected_runtime_display.py` compares linked runtime bytes against
the original display compiler and native source data: headings/stat glyphs,
all 256 numeric/bar values, all evolution text/requirements, every species'
native graph and move streams, decimal formatting, RAM boundaries, and bank
restoration. Select the candidate explicitly:

```sh
DEX_RUNTIME_SOURCE=build/selected-runtime-new/candidate python3 -m unittest tools.test_selected_runtime_display -v
```

Prepare normal-input Modern checkpoints with `performance --prepare` under
the source's `focused/modern/`; use matching ROM, symbols, and a copied battery.
The `selected_runtime` wrapper runs 746 Info scenarios, 746 Selected Moves
scenarios, and 400 rapid/held/canceled Info scenarios. Its audit explicitly
expects the integrated double-speed policy. A legacy normal-speed harness
report is not acceptance evidence for the current game.

```sh
python3 -m tools.dex_timing.selected_runtime info --source build/selected-runtime-new --jobs 6
python3 -m tools.dex_timing.selected_runtime moves --source build/selected-runtime-new --jobs 6
python3 -m tools.dex_timing.selected_runtime stress --source build/selected-runtime-new --jobs 6
python3 -m tools.dex_timing.selected_runtime inventory --source build/selected-runtime-new
```

After `type_full_regression prepare/setup`, paired timing phases use fresh
candidate/baseline Modern and Legacy checkpoints. `compare` has 1,600 page,
species, listing, and Area-return cases; `extra-timing` has 544 evolution/Moves
cases; `startup` has 16 normal-input Dex-reopen cases. The latter explicitly
selects Legacy before closing, rather than assuming a Legacy checkpoint's
battery already stores that presentation.

```sh
python3 -m tools.dex_timing.selected_runtime compare --source build/selected-runtime-new --campaign build/runtime-review-new --jobs 6
python3 -m tools.dex_timing.selected_runtime extra-timing --source build/selected-runtime-new --campaign build/runtime-review-new --jobs 6
python3 -m tools.dex_timing.selected_runtime startup --source build/selected-runtime-new --campaign build/runtime-review-new --jobs 6
python3 -m tools.dex_timing.listing_warming timing --output build/runtime-review-new --jobs 6
```

Report median matched-case differences, distributions and individual maxima,
not only differences between population medians. Separate input acceptance,
first changed pixel, complete screen, and animation/cry deadlines. At double
speed, safe preparation still proceeds at the display-frame cadence, so a ROM
saving can add page latency without changing the portrait timeline. Run the
standard Dex, Moves Search, Unown, Type return, host and full-species playback
phases on the same frozen link before accepting a runtime-rendering change.

Entry timing uses sixteen representative species, four hover durations
(0, 4, 30, 120 frames), four physical phases, both styles, and both links:
1,024 rows / 512 pairs. Retain first/complete display metrics and actual owner
reveal. Animated/blinking frame hashes can make a generic "first change"
misleading; corroborate with owner/window publication events.

Shared arrow checks exercise 1,792 counter/bank/reset cases, 52 locations, and
3,328 idle frames. Only the arrow should change between blink phases; text,
borders, and backgrounds remain static. The naming-screen box is a distinct
cursor convention and must not become an arrow.

## 5. Moves Dex, Search, And Sort Memory

Primary tools: `moves_mode`, `moves_search`, `moves_sort_memory`.

| Suite | Current Cases |
| --- | ---: |
| Native filter contracts | 1,692 |
| Normal-button control flows | 10 |
| Visual sweeps | 1,406 |
| Navigation/paging | 2,686 |
| Mode/search transitions | 11 |
| Surrounding/save flows | 2 |
| Search form polish | 1,284 |
| Naming selection cursor | 3,840 |
| Sort preference helpers | 4,096 |
| Sort preference UI | 16 |
| Sort preference save cases | 11 |

Filter contracts cover empty/mixed/all-seen sets, both sort orders, all eighteen
types plus blank, nine representative name queries, and all 333 complete move
names. Queries include case differences, substrings such as `double`, internal
matches, punctuation/space, and no-hit text. When both criteria are present,
type and case-insensitive substring matching are ANDed. Unseen moves are never
search hits. Blank criteria yield the seen subset in the selected sort order.
Check result buffers and adjacent sentinels, count/index width, bank restoration,
sort memory, the main Pokemon order, and transient move tables for corruption.

Visual/navigation tests cover both orders, seen/unseen names, stats, type and
category icons, descriptions, scrollbar, full-page left/right jumps, held keys,
wraparound, popover priority, margins, search/result footers, and returning from
results to the full list. No stale search icon may replace the category icon.
Changing sort resets position; sort preference survives the intended save/load
paths. Position remembrance is a separate feature, not implied by sort memory.

Text-entry assertions cover default uppercase, Select casing changes, A insert,
B backspace including empty/boundary cases, Start moving to End, and A confirming
End. Exercise every directional neighbor and the maximum query length derived
from `MOVE_NAME_LENGTH - 1`, including automatic End positioning at capacity.
Verify white blinking letter/command boxes against the normal naming-screen
geometry, End placement, elevated unused dashes/lowered current position,
background isolation, and restoration of menu fonts/palettes/OAM on exit.
Do not assume that changing the query's case should change matching results.

Sort helpers test all byte values across all WRAM bank selections for read/write
normalization and restoration. UI/save tests include invalid legacy values,
defaults, opposite/current selection, cold reload, and unaffected discovery bits.

## 6. Persistence And Legacy Migration

Primary tools: `move_persistence`, `move_acquisition` migration/interruption
actions, `move_persistence_report`, and `acquisition_performance`.

Current coverage per candidate:

- 2,380 bit/index helper cases and four payload snapshots.
- 1,490 cold-boot cases, including five save patterns reloaded through both
  copies; these counts include interrupted/corrupted input families.
- 152 interrupted-save-write cases and 150 interrupted-repair cases.
- Five lifecycle cases: New Game, subsequent save/reload, canceled overwrite,
  old-save preservation, and deletion/reset behavior.
- 29 acquisition-aware migration cases, with up to 288 owned Pokemon / 1,152
  move slots, plus 150 interrupted-migration cases.

Check every valid permanent move index, boundary/high-byte indexes, invalid
zero/out-of-range indexes, duplicate marks, unused bitmap bits, and incoming
bank/register preservation. Use empty, singleton, mixed boundary, alternating,
and all-seen patterns.

Cold boot must execute the actual loader rather than loading an emulator state
that already contains the expected flags. Test valid primary/backup copies,
checksum/signature/version corruption, mismatched copies, absent legacy records,
and recovery policy. Interrupt each relevant byte write/repair boundary, restart
from that battery, and require a valid recoverable result. Preserve unrelated
core-save bytes/checksums, other banks, RTC data, and buffer sentinels.

Legacy migration scans owned party, current/inactive PC boxes, and valid daycare
ownership, correctly handling packed permanent IDs, eggs, invalid counts/indexes,
and mixed saves. Its initial read-only reconstruction must not perform premature
SRAM writes; normal save/repair must produce both complete valid records.
Canceled New Game overwrite must not destroy the previous persisted discoveries.

## 7. Acquisition And Learning Discovery

`move_acquisition` has 12,276 native helper cases plus 59 positive/negative
source scenarios. The helpers test valid/invalid permanent IDs, repeated marking,
transient-ID reuse, garbage collection, party move inspection, and caller
bank/register state.

The current source inventory is defined explicitly in
`move_acquisition.qualify(..., sources=True)` and includes:

- Learning into an empty slot or replacing a move; declining; battle learning;
  transformed/other-Pokemon contexts; level and evolution learning/declining.
- TM, HM, and tutor success, already-known, incompatible, and declined cases.
- Failed ball, trainer battle, full storage, tutorial capture, party/PC success
  through surrounding capture scenarios, and enemy generation without receipt.
- Party/PC gifts, full storage failure, pre-Dex gifts, extended-ID gifts,
  normal/special/skipped Dratini gifts, and successful/declined/wrong trades.
- Egg receipt/full storage/not-ready negatives and actual hatch positives.
- Daycare man/lady retrieval and full-party negatives; service success,
  decline, insufficient-money, and full-party paths for each provider.
- Contest party/PC receipt, no catch, full storage, and pending contest catch.

Assert that a positive scenario really acquired/learned the intended move, not
merely that a helper set a bit. Negative scenarios must neither set discovery
bits nor alter an unrelated Pokemon. Recording uses permanent indexes, never
temporary IDs whose meaning can change after collection/reuse.

Policy contracts: eggs record on hatch, daycare records at retrieval without
retroactively tracking overwritten moves, and contest catches record only when
finally received. Special gifts are covered through their actual move-writing/
receipt path, including scripts bypassing ordinary LearnMove.

## 8. Battle-Use Discovery And Struggle

Primary tools: `move_battle_use`, `battle_use_campaign`, `pokedex_gift`.

The current full phase runs 4,724 native wrapper/index contracts, 400 semantic
cases (50 kinds, both actors, four phases), and eight supplemental Bide cases.
The separate Struggle award tests have sixteen initial plus sixteen repeated
awards, cold save/reload, and an assertion that awarding alone does not write SRAM.

Semantic inventory includes ordinary use, miss, immunity, failed effect,
selected-but-not-used, sleep/freeze/flinch/recharge/disable/paralysis/confusion,
switch actions, canceled selection, inability to move, Focus Punch tightening/
disruption/switching, Metronome and rejected selections, Sleep Talk success/
awake/self-only/disabled/charge-only pools, Mirror Move success/charge/failure,
Sketch use versus copy-only mutation, Mimic, Transform, borrowed moves,
Struggle, trainer/Tower/tutorial/scripted/pre-Dex contexts, scene-off behavior,
disobedience/substitution, sun SolarBeam, and each declared charge move.

Rules to assert:

- A charge move is seen on its first use, even if release never happens.
- Focus Punch is seen when focus tightens, even if disrupted.
- Called moves and their caller are both recorded when actually presented.
- Selecting an action without reaching use does not discover it.
- Sketch itself is recorded on use; converting it into another move is not
  independently treated as that copied move being used.
- Struggle is marked when the player receives the Dex, idempotently.

The battle roundtrip fixture saves actual new discoveries, cold reloads, checks
the seen bitmap, and verifies the Moves Dex display. Keep this integration step
even when direct wrapper/semantic units pass.

## 9. All Battle Animations

Primary runner: `tools/dex_timing/all_battle_animations.py`.
Native observer: `tools/dex_timing/probes/battle_animation_sweep.c`.

Supply a JSON array of configurations. Each contains `variant`, `root`, `rom`,
`sym`, `battery`, `expected_double_speed`, `expected_battle_speed`, and
`fresh_battle_fixture`. One variant must be named `production`. For the current
three-build comparison the builder supplies this file after full preparation:

```sh
python3 tools/build_dex_types_mode7.py animation-configs --output build/dex-types-mode7-audio-20261012
python3 -m tools.dex_timing.all_battle_animations prepare --output build/dex-types-mode7-audio-20261012/all-animations --configurations build/dex-types-mode7-audio-20261012/animation-inputs.json
python3 -m tools.dex_timing.all_battle_animations renderer --output build/dex-types-mode7-audio-20261012/all-animations --configurations build/dex-types-mode7-audio-20261012/animation-inputs.json --jobs 8
python3 -m tools.dex_timing.all_battle_animations native --output build/dex-types-mode7-audio-20261012/all-animations --configurations build/dex-types-mode7-audio-20261012/animation-inputs.json --jobs 6
python3 -m tools.dex_timing.all_battle_animations report --output build/dex-types-mode7-audio-20261012/all-animations --configurations build/dex-types-mode7-audio-20261012/animation-inputs.json
```

Use the same custom configuration path for every action. Default paths describe
an older investigation and are not a generic current baseline. `smoke` is useful
for debugging but is not full acceptance. `compile` refreshes observers after
observer code changes; it does not recreate linked-ROM-dependent checkpoints.

### Direct Renderer Matrix

The catalog is derived from move constants and animation pointers. Current
coverage is all 333 move entries plus 28 auxiliary entries. Each runs on both
sides and at four physical phases (0, 17,556, 35,112, 52,668 ticks). Scripts with
`anim_if_param` also run parameters 1, 2, and 3 in addition to 0: currently thirty
moves and two auxiliary entries.

This produces 3,384 move calls plus 272 auxiliary calls = **3,656 per build**,
or 10,968 across production and both candidates. Cover charge/release, Substitute,
send-out/shiny, capture/wobble context, and other auxiliary branch variants.

The fixture explicitly supplies animation ID, side, parameter, and coherent
battle/capture context, then executes the real animation routine. It does not
patch PPU state, IME, or speed to manufacture equal timing. This isolates the
renderer; it does not prove every move's damage/effect/discovery behavior.

Required comparisons:

- Returned successfully; ROM bank, WRAM bank, speed, and VBlank owner restored.
- Exact physical elapsed time for unchanged animation behavior.
- Same logical state, object/OAM/background effects, update counts, and cadence.
- Same rendered full-frame pixel hash sequence and frame count.
- No missing, unexpected, or duplicate catalog/side/parameter/phase cases.

The observer hashes actual rendered pixels. The first partial frame after a
loaded CPU checkpoint is excluded because the emulator's external pixel buffer
is not part of that checkpoint. All subsequent complete frames are included.
The renderer uses a 32-bit FNV sequence hash, not stored images of every frame;
hashes are practical regression evidence, not a mathematical no-collision proof.
Keep screenshots/traces for failing cases and representative manual review.

Native time fields use 4,194,304 physical ticks per second and 70,224 per frame
(about 16.743 ms). At double CPU speed, CPU instruction T-cycles are not the same
units as these physical ticks. Do not accidentally double/halve measured time.

### Normal Battle Input Matrix

All 333 moves also run through ordinary battle inputs on both actors at phase
zero: 666 cases per build. The established 100-move matrix adds both sides and
four phases, yielding 1,600 rows / 800 baseline-candidate pairs per full campaign.
Check actual requested-animation start/return, completed gameplay ownership,
CPU speed, menu return, discovery state, and move effects appropriate to the
fixture. Direct renderer coverage cannot substitute for these integration runs.

Current known all-move exceptions: nineteen condition-specific fixtures do not
activate the requested animation; thirteen knockout/ending/switch paths do not
return to the generic turn menu; two Sand Tomb cases hang after the animation
returns. These identities must match production. New identities are failures,
even if the total exception count stays 34. `edges` extracts invocation/return
evidence for exception diagnosis.

When a duration differs, inspect actual start alignment. The current requested
chart changes alter pre-animation scanning and therefore a few start phases.
`type_chart_phase_check` documents a chart-only ablation: keep display code,
restore only the frozen production chart plus its zero-byte end label, rebuild,
create fresh checkpoints, and rerun differing cases plus controls. Never assume
that a similar-looking delta has the same cause. An incremental build that did
not rebuild changed data is not a valid ablation.

## 10. Menus, Gameplay, Audio, And Speed

Primary orchestrator: `acquisition_regression`. Its current paired campaigns:

| Campaign | Coverage |
| --- | --- |
| Menus | Ten context reports, 1,792 input/register contracts |
| Custom menus | 464 internal cases across two links; actual pixel/timing comparison |
| Popup readiness | 148 selections, including Pack, Apricorn, TM/HM entries |
| Surrounding gameplay | 22 scenarios, eleven kinds on baseline and candidate |
| Sampled cries | 960 rows / 480 pairs |
| Battle speed transitions | 24 runs, repeated battles/learning/loss at four phases |

Menu contexts are standard, battle, mart, puzzle, and game corner. Verify allowed
button masks, new/held/repeat/overlap/release handling, rejected controls, register
preservation, menu ownership, and CPU speed. Custom inventories also compare
selected contents, frame/palette/OAM hashes, and first/complete display timing.

Gameplay scenarios cover movement/navigation, purchase, puzzle, fishing,
trainer battle, phone, level-up learning, egg hatch, PC capture, party capture,
and heal/save. Acquisition tests add actual daycare, gifts, contest, and trade
paths. This is a surrounding-gameplay sample, not every map/script/quest.

Sampled cries cover twenty species across stats, catch, faint, player send-out,
blocking playback, and stereo playback, with four phases on two links. Compare
sample blocks, waveform hashes, timer configuration, frequency, expected speed,
exhaustion/completion, and shutdown. Keep known baseline timing misses explicit;
equal misses are not newly passing cases. Listen manually to representative
samples because register/hash tests do not replace auditory review.

Normal battles must use the intended normal clock while world/menus use the
intended double clock. Repeat eight battles, return through menus, learn a move,
and exercise loss/blackout. Check clock restoration after animations, cries,
Dex views, and gameplay return rather than checking only the initial setting.

`acquisition_performance` measures valid load, small/full legacy migration,
recovery, and normal save against the baseline. Retain physical times and
protected save bytes. A CPU-host wall-clock slowdown is not a game slowdown.

## 11. Type Matchups Add-On Qualification

These checks are mandatory when Type Matchups exists in the candidate; for a
branch without that feature, record the explicit scope exclusion instead of
pretending the Type-specific adapter ran successfully.

```sh
python3 -m tools.dex_timing.type_matchups --output build/dex-types-mode7-audio-20261012/runtime --all-models
python3 -m tools.dex_timing.type_mode7_comparison measure --base build/dex-types-mode7-audio-20261012 --variant runtime
python3 -m tools.dex_timing.type_mode7_comparison audio --base build/dex-types-mode7-audio-20261012 --variant runtime
python3 -m tools.dex_timing.type_mode7_comparison audio_navigation --base build/dex-types-mode7-audio-20261012 --variant runtime
```

Repeat for `precomputed` when comparing both implementations. The ordinary full
campaign is primarily CGB E; focused Type tests additionally use revisions
0, A, B, C, and D. This does not certify all gameplay on every revision or on
physical hardware.

Type checks include eighteen selections, 72 directions, 32 starting-phase
cases, 720 held-input frames, 790,016 badge pixels per revision, and 13,164
legal full frames per variant across the six revisions. Verify 88 accent bytes
per frame, no mode-3 writes, correct palette indexes, atomic lower-panel/cursor
publication, and exactly-once frame work. Check AF/BC/DE/HL/SP, ROM/WRAM banks,
input, sound, game clock, interrupts, OAM locks, and scratch ownership.

Entry/exit checks cover eight phases each and no white flashes. Return coverage
includes 42 owner reentries, twelve closes/reopens, both styles, all Pokemon
sorts, locked/unlocked Unown, and 24 Selected picture/cry playbacks after leaving.

The independent workbook snapshot validates 324 attack/defense cells and current
128 records. Battle-routine calls cover 648 singles, 2,754 unique dual-type
combinations, and four identified/Foresight cases. Validate alphabetical badges,
Electric self-immunity, separate I rows, Steel's combined R, overflow placement,
empty rows, and exact existing art/colors/corners/borders.

Music stress uses all 122 entries, including silence, for 1,800 idle frames each,
then `SFX_MENU`, `SFX_READ_TEXT_2`, and `SFX_CHANGE_DEX_MODE` for 90 frames each.
The navigation variant uses 360 idle frames and immediate SFX with 90 held-down
frames plus release, auditing legal atomic selection frames. These use real
PlayMusic/PlaySFX calls from an explicit synthetic caller at the natural live
Type-owner boundary; they do not claim naturally traversing all music maps or
exhaustively covering arbitrarily long future command streams. No PPU/IME patch.

Measure eight entry phases and 576 direction changes per variant. Report input
acceptance, map publication, and first complete displayed change separately.
Then compare all eighteen actual screenshots between variants, normalizing only
the expected arrow blink rectangle, not arbitrary mismatched pixels.

## 12. Host Tests And Acceptance Reports

The linked host group contains the repository's Moves production, Dex scheduler,
Info, Moves, Area assets, description paging, sampled-cry shutdown, and battle
motion tests. The historical group runs `tools.test_dex_timing` against the two
matching source roots. Do not substitute only static text assertions for native
integration tests or change goldens merely to make a new feature pass.

Required acceptance for a current full run:

- Every planned phase completes, with matching ROM hashes and expected cases.
- No new native functional/visual/bank/save corruption failures.
- Complete animation catalog and native input coverage, exact phase-matched
  renderer timing/logical/pixel sequence, and unchanged baseline exception IDs.
- Unchanged normal menu/save/audio behavior; quantified latency deltas outside
  the requested feature. Investigate unexplained multi-frame changes.
- If Type exists: six-model evidence, both music stress reports, independent
  chart calls, and complete Type entry/navigation/return checks.
- Protected production ROM/symbol/map and review battery hashes unchanged.
- All retained baseline failures/skips explained, with actual baseline reruns.

The current report gates return nonzero on failed/missing acceptance, rather
than printing a false `merge_ready` value while exiting successfully. Inspect
`full-regression.json`, `phase-results.json`, and the underlying reports anyway.
The two-variant aggregator is:

```sh
python3 -m tools.dex_timing.type_mode7_report --base build/dex-types-mode7-audio-20261012
```

It additionally requires identical ordinary source paths, final ROM hashes,
complete rendered-frame evidence, both independent campaigns, six Type models,
both audio stresses, visual equivalence, and the retained chart-start-phase
investigation. This aggregator is specific to the two Type variants, not a
universal gate for an arbitrary unrelated branch.

### Known Baseline Limitations At This Reference Date

- Linked host: 85/86 pass; Info ready-handoff at LY64 fails equally on both.
- Historical host: six failures, sixteen errors, 103 skips among 187 checks,
  with the same identities on production/candidate. Detail differences are kept.
- All-move normal input: nineteen missing condition-specific setups, thirteen
  ending/menu ownership expectations, two pre-existing Sand Tomb hangs.
- Sampled cries: the same 32 known timing misses per paired link.
- Type comparison: requested chart changes explain small whole-battle duration
  differences; phase-matched rendering is exact. Long-hover Legacy Dusknoir
  Selected entry is one frame later despite unchanged median Legacy latency.
- No physical Game Boy validation, exhaustive long-duration music proof,
  hardware battery/power measurements, or every-map/every-event playthrough.

Do not grandfather a future new failure simply because its category resembles
one of these. When fixing a baseline defect, update/remove its recorded exception
only after new positive and negative evidence demonstrates the fix.

## 13. Failure Investigation And Retesting

For each failure retain the ROM hash, baseline hash, exact case parameters,
emulator model, fixture battery/checkpoint, expected and actual result, event
trace, screenshots, and first failing frame/call. Reproduce with the same
link before changing anything.

Determine whether the failure is gameplay, rendering, timing, fixture setup,
stale symbols/checkpoint, incomplete build dependency, or an outdated oracle.
Compare production in the same environment. For timing, separate pre-call start
phase, logical update count, physical gaps, and displayed pixels. Use a scoped
ablation only as diagnostic evidence, not as the review ROM.

After a game fix, rebuild and regenerate affected fixtures, then rerun the
affected suite and surrounding/full suites according to its blast radius.
After a harness-only fix, preserve the initial evidence and rerun both baseline
and candidate assertions. Do not overwrite a failed phase with a manual "pass"
without an actual successful rerun.

## 14. Reuse And Catalog Growth

For another gameplay change, freeze that branch's baseline/candidate source and
binary inputs, regenerate coherent snapshots, update adapter filenames/manifests,
and run the applicable unchanged campaigns. The current adapter carries Type
aliases and old fixture paths; it needs a thin configuration adjustment where
those do not exist. Do not alter game logic or expected outcomes merely to fit
an old adapter. Keep feature exclusions explicit in the report.

Before adding approximately eighty moves or ten species:

- Audit hardcoded 333/334 and 373/374 ranges in persistence, acquisition,
  battle-use, search, gift, navigation, and fixture generation. Update to catalog
  constants where appropriate, with an independent expected-count check.
- The 64-byte move bitmap nominally holds 512 indexes, but that alone does not
  prove every bound/buffer/layout supports a larger catalog. Search result
  buffers, sort records, permanent/transient tables, and unused-bit tests need
  explicit review. Current filter sentinels assume 666 result bytes.
- The exhaustive animation catalog derives current pointers/constants. Assert
  new expected coverage, include each new conditional parameter path, and add
  normal battle fixtures for special semantics. Keep the 100-move historical
  sample as continuity coverage rather than replacing exhaustive coverage.
- When baseline and candidate catalogs differ, compare shared entries by stable
  identity using each ROM's own ID mapping and symbols. Test newly added entries
  separately as candidate-only coverage. The current animation runner reads
  the working catalog; it must be adapted before comparing an expanded candidate
  against an older production ROM. Never call a new candidate ID in a baseline
  that lacks that entry or count such a run as a valid paired comparison. Apply
  the same shared/new partition to expanded species coverage and fixtures.
- Refresh species orders, pictures, descriptions, cries, seen/caught fixtures,
  extended-ID boundaries, Unown placement, and representative new entries.
- Regenerate Type panels and the independent expected chart when effectiveness
  intentionally changes; do not leave a stale workbook oracle in place.
- Update music-entry expectations (currently 122) if the table changes. Rerun
  worst-case command/SFX/deadline tests after audio changes. Audio bank `$3a`
  currently has only 26 free bytes in the Type prototypes; bank-local pressure
  matters even with substantial aggregate ROM space.
- Refresh legacy migration/corruption fixtures after save-format changes and
  test compatibility with genuine prior-save layouts, not only newly generated
  saves using the new layout.

## 15. Manual Release Review

Automated qualification is followed by manual review of both UI styles, all Dex
modes, Type movements/immunities/Steel overflow, search text controls, scrollbar/
popover placement, menu returns, selected animation/cry, real saves/reloads,
party/PC/daycare/egg/contest interactions, and representative battles on both
sides. Include long animations, water screen effects, charging/called moves,
and rapid mode switching. Listen to music/SFX/cries and review the reported
latency outliers. Physical CGB testing is a separate desirable release step.

Do not promote production automatically because the machine report says
`merge_ready`: that means the defined automated acceptance has cleared, not
that manual review, known separate backlog work, or user approval is complete.

## 16. Evidence Record Template

Record the following with each campaign:

```text
Date, branch/commit and dirty-source snapshot:
Baseline ROM/source/symbol/map hashes:
Candidate ROM/source/symbol/map hashes:
Fixture manifest/battery/boot-ROM hashes:
Python/RGBDS/Clang/SameBoy versions:
Emulator model(s), clock expectations and worker counts:
Exact preparation and phase commands:
Expected/actual cases and coverage per suite:
New failures, baseline exceptions, skipped/excluded scope:
Latency comparisons and critical-path instruction changes:
Failed attempts, diagnosis, correction and successful retries:
Report/trace/checkpoint/screenshot locations:
Production-input protection checks:
Manual/hardware review status and integration decision:
```

The October 12 final evidence is retained in
`build/dex-types-mode7-audio-20261012/`. Its comparison document records the
frozen outputs, full campaign results, the corrected host-baseline setup,
audio-stress fix, chart ablations, narrow Legacy latency difference, and memory
costs. Future runs should create their own dated evidence instead of silently
reusing or overwriting that reference.

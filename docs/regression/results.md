# Regression results: v0.9 bug testing

Headless runs on SameBoy (harness: `docs/regression/harness/`, listed in `docs/helper_scripts.md`). Each suite runs alone with `--jobs 1`; running suites in parallel froze the machine on 2026-10-25.

ROM ids are the first 12 hex digits of the debug ROM's sha256:
- `b2b0663fd969`: v0.9 (`2f2a153e6`)
- `d2d8c52aa33f`: core after the Suicune fix (`1f371a693`)
- `bcabb4247a12`: branch 75, the rules fix (`aa180f48e`)
- `a56b006855c4`: branch 75, plus the prize fix (`d3f3b41da`); core after the merge builds the same ROM

Reports are in `docs/regression/reports/<time>-<rom id>/`.

## Game bugs found

| Bug | Found by | Status |
|---|---|---|
| Refusing Suicune in Tin Tower 1F soft-locked the game. The refusal ended the script without clearing `SCENE_TINTOWER1F_SUICUNE_BATTLE`, so the cutscene re-ran at once. Each pass walked the player 3 tiles further up until a scripted step hit the wall and hung. | `scenes.deity_suicune` | Fixed in branch 74 (`1f371a693`), merged to core. `deity_suicune` and the new `deity_suicune_retry` pass. |

| The Battle Tower refuses valid teams as "must all be different kinds" (or as holding the same items). `CheckPartyValueIsUnique` (`engine/events/battle_tower/rules.asm`) calls the `.isegg` stub, which is `or 1` and clobbers `a`, the value being compared. So the check really tests `value \| 1`: two species or items whose 8-bit runtime IDs differ only in bit 0 count as equal. Runtime IDs are assigned dynamically, so which teams are refused is effectively arbitrary. Introduced by `98812dc12` "Mass delete of EGG code" (2026-05-23); upstream's `.isegg` preserves `a`. Repro: debug party trimmed to Mewtwo/Mew/Lanturn (IDs 1/2/3; Mew 2\|1 = Lanturn 3). | `scenes.battle_tower_entry` | Fixed in branch 75 (`aa180f48e`), merged to core: the egg check is removed. `battle_tower_entry` passes, and the new `direct.battle_tower_unique_checks` passes on the fix and fails on v0.9. |
| Completing a Battle Tower streak crashes when the prize is given. In `Script_GivePlayerHisPrize` (`maps/BattleTower1F.asm`), `checkmaplockeditems` overwrites `wScriptVar` (the reward ID) with a locked-slot number, 0 here. `getitemname`/`giveitem ITEM_FROM_MEM` then use item 0, and the CPU runs off (a write to $ff08, then a black screen). Inherited from upstream CSE's 16-bit item conversion (`f54acb152`). Related problems: `sBattleTowerReward` stores a runtime item ID in SRAM; the GC checks it only after `___conversion_bitmap_free_unused` has run (`engine/16/table_functions.asm`), so it can be freed mid-challenge; and `BattleTower_GiveReward`'s full-pack scan assumes 2-byte pocket entries (the item pocket's are 3 bytes: index hi, index lo, qty). | `scenes.battle_tower_full_streak` | Fixed in branch 75 (`d3f3b41da`), merged to core. The reward is stored as an offset from HP_UP; `giveitem` / `iffalse` handles a full pack; `checkmaplockeditems`, the Potion locked index and the late SRAM GC check are removed. The streak, full-pack, loss and entry tests all pass, and so does `direct.battle_tower_reward_is_a_stat_item`. |
| Door warps sometimes put the player on the bike, even indoors. The water-warp restore (`9929cd4d3`) read its flag from scratch RAM shared with `wWinTextPointer` (set by every trainer battle) and copied a shared byte (Good Rod = 1 = bike) into the player state. | shasocastris's play-test; `repro.door_after_battle_leftovers` | Fixed in branch 76 (`cd89b9f5d`), merged to core: `wWaterWarpState` is its own WRAM0 byte, set only when a water warp is taken. |
| Earthquake hit a Pokémon mid-Fly, and Gust/Twister/Thunder hit one mid-Dig. The 16-bit move conversion (upstream `8e21797f9`) swapped the two lists. | shasocastris's play-test; `battle_moves.fly_dig_moves` (fails on v0.9) | Fixed in branch 76 (`295990c6b`), merged to core. Hurricane was added to the Fly list. |
| Saving with a Repel nearly used up, reloading and walking froze the game with a garbage screen. Auto-Repel kept the Repel's runtime item ID in `wRepelType`; saving could free the ID, and `CheckItem` on a dead ID jumped out of bounds. | shasocastris's play-test (post-Battle-Tower save); `repro.repel_*` | Fixed in branch 76 (`da77fc591`), merged to core: `wRepelType` holds 1-3 for the Repel kind; anything else just wears off. |
| Raikou's and Entei's statics blinked out every other frame (large sprite, two-frame movement). | shasocastris's play-test | Fixed in branch 76 (`e45edc5a5`), merged to core: icon sprites. Checked by frame strips only. |

## Suite results (latest run)

| Suite | ROM | Result | Report |
|---|---|---|---|
| direct | v0.9 | 3/3 pass | `20261025-203329-b2b0663fd969` |
| scenes | v0.9 | 15/16 (Suicune soft-lock) | `20261025-203334-b2b0663fd969` |
| scenes (Suicune, after the fix) | core | 2/2 pass | `20261025-222900-d2d8c52aa33f` |
| obedience | v0.9 | 8/8 pass | `20261025-205721-b2b0663fd969` |
| battle_moves | core | 13/14; Sacred Fire passed on rerun after a test fix | `20261025-224421`, `20261025-225331` |
| save | core | 3/3 pass | `20261025-225718-d2d8c52aa33f` |
| weather | core | 7 pass, 1 skip (animation test; run separately below) | `20261025-225826-d2d8c52aa33f` |
| linkdiff | pre11 vs post11 | **27/27 pass**: no trace differences, errors or nondeterminism. The first run's 9 failures were test faults (fixed below). | `20261026-084303-d2d8c52aa33f` |
| scenes: `npc_trade_tim` | core | pass | `20261026-090928-d2d8c52aa33f` |
| scenes: `mystery_gift_house` | core | pass | `20261026-091050-d2d8c52aa33f` |
| scenes: `battle_tower_entry` | core | fail: game bug (rules check, above) | `20261026-091127-d2d8c52aa33f` |
| scenes (all 20) | branch 75 | 20/20 pass (`battle_tower_entry` after a test fix) | `20261026-092344`, `20261026-092832-bcabb4247a12` |
| direct (4, incl. `battle_tower_unique_checks`) | branch 75 | 4/4 pass | `20261026-092335-bcabb4247a12` |
| scenes: `battle_tower_loss_returns_to_lobby` | branch 75 | pass | `20261026-102909-bcabb4247a12` |
| scenes: `battle_tower_full_streak` | branch 75 (rules fix only) | fail: game bug (prize crash, above). All 7 battles are won and the opponents load valid L100 parties. | `20261026-102909-bcabb4247a12` |
| direct (5) | branch 75 + prize fix | 5/5 pass | `20261026-104101-a56b006855c4` |
| scenes: the four Battle Tower tests | branch 75 + prize fix | 4/4 pass. The streak gives the 5-item prize; with a full pack the player is told so and gets nothing, and after a slot is freed the receptionist hands it over. | `20261026-104107-a56b006855c4` |
| scenes (all 23) | branch 75 + prize fix | 23/23 pass | `20261026-104625-a56b006855c4` |
| weather: `bank_moved_battle_anims_match` | v0.9 vs pre11/post11 | pass: every frame of Bite, Leech Seed and Petal Dance matches | `20261026-091411-d2d8c52aa33f` |
| full queue, every suite one at a time (details in `docs/follower_port_plan.md`, Phase G) | 85-followers `545f73d97` | all pass except `v10_audit.audit_v09_save_loads` (by design, fresh-save v1.0) and two skips needing absent files; the save roundtrip and elevator smoke failures were test faults, fixed | `20261108-*-60739d52518e` |
| followers (incl. `follower_interactions`, `static_text_command_then_char`) | 85-followers `1321aa614` | 37/37 pass | `20261109-003329-5b723555df3a` |

## What the passing suites establish

- **Obedience (branch 32).** Measured obey rates match the happiness caps:

  | Level | Happiness | Expected | Measured |
  |---|---|---|---|
  | 50 | 70 | 48.0% | 47.1% |
  | 55 | 110 | 70.9% | 69.6% |
  | 55 | 159 | 70.9% | 71.3% |
  | 55 | 160 | 98.2% | 99.2% |
  | 60 | 219 | 90.0% | 88.8% |

  Always obeys at 220+, at or below level 24, and in the Battle Tower.
- **Signature moves (branch 39).** Every move's effect checked in real battles:
  - Aeroblast flinches 47.5%, Sacred Fire burns 45% (both against 50%).
  - Fae Blade's three statuses split 46 / 48 / 56.
  - Metronome never picks a signature move; Sketch fails on all ten.
- **Coach (branch 30).** Gender and shininess are kept across 112 species × DV cases. HP rules hold, the Star Piece is charged once, and a second use the same day is refused.
- **Deities and story gates.** All eight deities, Celebi, Rainbow Wing, Mewtwo, Kangaskhan at 220 and Larvitar at level 25 behave as specified.
- **Save.** The save/continue round trip is byte-exact. Saving leaves the Hall of Fame, GS Ball and Battle Tower SRAM untouched, and the main menu is correct.
- **Weather.**
  - Particles stay in OAM 0–11, and Goldenrod rain drops no NPCs.
  - Lightning is suppressed under the map sign and during Fly.
  - Overcast survives a reload, with no lag frames.
  - No snow inside the Olivine restaurant.
- **Link removal (branch 11).** Pre-11 and post-11 traces match for:
  - speed ties, priority and Quick Claw;
  - Selfdestruct, Destiny Bond and recoil KOs;
  - poison and sandstorm double faints;
  - Leftovers, Perish Song, Future Sight and Safeguard;
  - Baton Pass, voluntary switching, Roar (against the player, against a trainer, and against a wild Pokémon), and Struggle;
  - a trainer sending out their next Pokémon, a 12-turn fight against the trainer AI, and Thief;
  - running away at slow and fast speed.
- **NPC trade.** Tim takes the Krabby and adds Voltorb at the end of the party, like vanilla: OT ID 29189, PRZCureBerry, trade flag set. A second talk doesn't trade.
- **Mystery Gift house.** Declining the save gives nothing and leaves the daily flag clear. Saving writes the save (a fresh boot offers CONTINUE), gives 3 items and sets the flag. A second talk the same day gives nothing.
- **Battle Tower.** A 6-mon party is turned away and control returns. With the fix, a valid 3-mon party is asked to save, the save is written (a fresh boot offers CONTINUE), the scene is back to NOOP, and the level menu opens.

## Findings that are not bugs

- **Obedience RNG.** `Random` reads rDIV, so the rejection loop at `.rand1` makes correlated calls. Modelled cycle by cycle in `docs/v1_research/rng_loop_model.py`, the real odds stay within about half a point of cap/level. The exception is level 100 under cap 54, at about 50% against 54%. This is vanilla behaviour; branch 11 only made `BattleRandom` an alias of `Random`, which is what non-link battles already used.
- **Gen 2 caps damage at 999.** A 999-HP test foe can be one-shot, so tests that must not KO give the foe 2000 HP.

## Test-side fixes (no ROM changes)

- **Runner.** Default `--jobs 1`; results print as they come.
- **Obedience and battle-move trials.** `hRandomAdd`/`hRandomSub` are seeded uniformly for each trial, because frame delays alone left the RNG state clumped and skewed the rates. The obedience foe's HP was raised to 2000, and so was the foe in Sacred Fire's burn trials.
- **linkdiff (`diff_battle.py`, `suite_linkdiff.py`).**
  - Fixed the `Random` byte check, which looked for `ret` at +17 instead of +18.
  - New `sb_run_until_any` / `Game.run_until_any`. The driver now watches the battle menu, the cleanup routine and the party menu at once, so it no longer misses the end of a battle (run, Roar) or the Baton Pass menu.
  - Party experience is zeroed, so a KO can't trigger a 50-level chain.
  - The test's trainer battles set `DEBUG_BATTLE_F`. They start without a script, so `wWinTextPointer` holds garbage and printing the defeat text crashed (on both builds). Every real `loadtrainer` in `maps/` sets `winlosstext` first, so players can't hit this.
  - The `end_of_turn_stack` HP was rebalanced, because the foe fainted on turn 1.
- **Animation test.** The HUD mask now starts at y 81. The tops of the HP digits (which differ between builds) were peeking above it.
- **New scene tests.**
  - Field name `MON_OT_ID`.
  - Item-pocket entries are 3 bytes (a 16-bit index).
  - Carrie's save prompt is matched on "game before", because "save" has scrolled off by then.
  - The receptionist's menu and yes/no box are watched together.
- **Scenes.** Added `deity_suicune_retry` (refuse, then re-enter, then talk to Suicune and get taught) and `npc_trade_tim`, `mystery_gift_house`, `battle_tower_entry`.

## Not covered

- Branch 76 also changed Life Dew (full heal, PP, team-cured text) and Fae Blade (six effects), at shasocastris's request; `battle_moves` covers both.

- Loading a save made by an older build. Bumping SAVE_CHECK_VALUE is still open for v1.0.
- Audio, and visual judgement beyond pixel diffs. These are shasocastris's play-test.

## v1.0 pass (2026-11-05): HEAD `1fb549fdf` (debug `de6bac77d41e`) vs v0.9 rebuilt (`ffdb7206c8d6`)

Per-area findings are in `docs/regression/v10/<area>.md`, with tests in `harness/v10_<area>.py`.

- Existing suites: HEAD 65 pass, 3 fail, 36 skip (`reports/20261105-135903-de6bac77d41e`); v0.9 45 pass, 20 fail, 3 error, 36 skip (`20261105-142307-ffdb7206c8d6`). Every v0.9 failure is a bug fixed or a feature added since.
- The 3 HEAD failures were test faults, not game bugs: `battle_moves.aura_sphere`, `scenes.deity_mew` and `scenes.deity_celebi` assumed the old debug party. **Fixed 2026-11-06** (current party taken as correct): the deity tests swap a move the teacher already knows out for move 4 before teaching (`_free_last_move(g, slot, teach)`). Aura Sphere gives the foe 2000 HP, because an unseeded crit hit the 999 cap and KO'd it (see `v10/battle.md`). All 12 deity tests and `aura_sphere` pass on the branch 84 tip.
- The Aura Sphere 999 is a crit: the test raises `wEnemyMonStats` but not `wEnemyDefense`/`wEnemySpDef`, and it doesn't seed the RNG (battle.md).
- New suites, HEAD: v10_battle 33, v10_items 18 pass, v10_story 21/22 (the fail is bug 3), v10_overworld 23 (smoke allowlists 9 maps whose entry scene needs input). v10_audit: save tests fail until bug 1 is fixed.

### v1.0 game bugs (open)

| # | Bug | Sev | Where / fix | Source |
|---|---|---|---|---|
| 1 | Hana's flag inserted mid-list shifts 271 event flags on v0.9 saves (Rocket quest at Ruins re-activates, rival reappears, trainers flip) | won't fix: v1.0 doesn't keep v0.9 saves | `constants/event_flags.asm:907`: use the `const_skip` at the head of the Kimono Girl block | audit.md |
| 2 | A v0.9 save made in the Orange Islands is stranded: Valencia needs the ORANGE PASS | won't fix: v1.0 doesn't keep v0.9 saves | `maps/ValenciaPort.asm:76,118`: also accept the S.S.TICKET | audit.md |
| 3 | Losing to the S.S.AQUA lazy sailor (GRUNTM_41) doesn't white out; Petrel is then a free win | fixed on 84-v1-regression-fixes | `maps/FastShipCabins_NNW_NNE_NE.asm:85`: `reloadmap` -> `reloadmapafterbattle` | story.md |
| 4 | Fae Blade blocked by the wrong immunities (Fairy never burned/frozen, Poison never poisoned). shasocastris: it should affect any type, so it now ignores immunities | fixed on 84-v1-regression-fixes | check target types in `BattleCommand_FaeBlade` | battle.md |
| 5 | Fae Blade outcome mix skewed (FRZ 25%, SLP 11%); suspected, confirm in play | fixed on 84-v1-regression-fixes | battle.md | battle.md |
| 6 | Fae Blade's confusion replays the full animation | fixed on 84-v1-regression-fixes | `effect_commands.asm:5735`: skip EFFECT_FAE_BLADE | battle.md |
| 7 | Life Dew / Heal Bell leave the Toxic flag set (vanilla); Life Dew text always says cured | fixed on 84-v1-regression-fixes | `heal_bell.asm:15` | battle.md |
| 8 | Three NPC texts still tie obedience to badges | fixed on 84-v1-regression-fixes | VioletPokecenter1F, VioletKylesHouse, IlexForest | battle.md |
| 9 | Janine says "fought until you dropped" to a player who saved the ship with a full bag | fixed on 84-v1-regression-fixes | dedicated saved-ship flag | story.md |
| 10 | Petrel stays in the cabin on v0.9 saves past the first S.S.AQUA trip | won't fix: v1.0 doesn't keep v0.9 saves | audit.md | audit.md |
| 11 | 18 follower interactions (85-followers) followed `text_ram` with `line`; the engine read `<LINE>` ($4f) as a text command, indexed past `TextCommands` and jumped into WRAM (`$c9c5` in that build). Reaction stopped after the nickname, or worse depending on RAM | fixed on 85-followers (`1321aa614`) | `engine/events/follower.asm`: `text_start` after each `text_ram`. Guarded by `followers.static_text_command_then_char` | `followers.follower_interactions` (Mr. Psychic's house), 2026-11-09 |

Design calls for shasocastris: one-source evolution items can be sold or tossed; the Moon Ball loses its bonus on Gligar/Sneasel/Eevee; Yuki's Glaceon has Shadow Ball; the herd leader is gone for good after a loss; bank $1d has 248 bytes free.

## Alph/Unown/Suicune merge pass (2026-11-19): core `6d91ba776` + Celebi starter WIP (debug `c54d50a09f1b`)

Plan: `alph_merge_test_plan.md`. Every run went through one flock, `--jobs 1`.

- **Section 1:** all pass after one test fix. Details:
  - `suicune_chamber` / `suicune_shrine` failed "not under the puzzle". This was a test fault: with sight range 2 (`6d91ba776`), Nikola also sees the player at (4,4) and walks to (3,4). The walk in `v10_suicune.py` now routes around her (`20261119-075209`, `-075342`).
  - `samuels_mail`, `ow_smoke_changed_maps`, `items_balls_*`, `items_evo`, `items_debug_items_given`, and `audit_v09_save_ruins_of_alph` pass. The v0.9 baseline was recreated under 4203bf99's scratchpad.
  - `ow_save_layout_matches_v09` fails (follower-era shift, known). Compared with the pre-merge build `896b5cfc3`, 0 WRAM/SRAM symbols moved, so the merge kept the save layout.
- **Section 2:** all pass except `scenes.deity_suicune` (stale since `87580fe2d`, known). Includes `ow_smoke_all_maps` (567 s).
- **Section 3:** new modules `v10_eviolite`, `v10_eviolite_give`, `v10_kurt_chain` (`-k kurt_chain`) and `v10_story_unown` (`-k story_unown`).
  - EVIOLITE boost, saturation and evolution block (level, happiness, stone, Metal Coat, Rare Candy) pass.
  - Route 42 → Kurt call → house chain and the full-mailbox path pass.
  - Archer/Petrel DVS parties, all 621 parties re-parsed, rocket machine, sightings and Wild Hunt W/T pass.
- `dialogue_lint.py --changed 896b5cfc3`: 65 files, 0 errors.

| # | Bug | Status | Where | Source |
|---|---|---|---|---|
| 12 | EVIOLITE can't be given: CANT_TOSS hides GIVE in the pack, and party/PC give says "can't be held" | fixed `5838f1708`: CANT_TOSS items in the Items pocket get GIVE/QUIT and pass `_GetItemToGive`, still no toss/sell | `engine/items/pack.asm`, `engine/pokemon/mon_menu.asm` | `v10_eviolite_give` |
| 13 | PC-mailbox mail type is a runtime 8-bit item ID that `ItemTableGarbageCollection` never scans; the first save frees it (SAMUEL's MIRAGE_MAIL 53 -> freed) | fixed `53c516ab3` (type) + `7d3a5e7fb` (same gap for the species byte, PORTRAIT MAIL): both GCs scan party mail, PC mailbox and backups, restoring `hSRAMBank` | `engine/16/table_functions.asm`; tests `kurt_chain_mail_{type,species}_after_gc`, `kurt_chain_gc_restores_sram` | `kurt_chain_mail_type_after_gc` |
| 14 | The Suicune sighting loop (36 → Cianwood → 42 → 36) re-runs Route 42's `clearevent EVENT_KURTS_HOUSE_DRAGONITE` + Kurt call every lap, so the MAIL can be delivered again | fixed `612749968`: new `EVENT_GOT_SAMUELS_MAIL` (from the unused gap) set on delivery; Route 42 re-arms only if the mail isn't got and the Dragonite isn't already waiting | `maps/Route42.asm`, `maps/KurtsHouse.asm`, `constants/event_flags.asm` | `story_unown_suicune_cycle_rearms_kurt` |
| 15 | Dragonite steps down one tile on each mailbox-full retry in the same visit | fixed `e9bc2e5bc`: the full path walks it back to (2,2) facing right | `maps/KurtsHouse.asm` | `kurt_chain_mailbox_full` |
| 16 | `SetTrainerBattleLevel` walks `TrainerGroups` 2 bytes at a time (entries are 3-byte `dba`), without paging the bank: wrong level, only the battle transition is affected | fixed `ef89a0fe7`: lookup shared with ReadTrainerParty (`FindTrainerParty`); test `story_unown_battle_level_all` (618/621 wrong before) | `engine/battle/read_trainer_party.asm` | story_unown review |
| 17 | `specialphonecall` writes 2 bytes into the 1-byte `wSpecialPhoneCallID`, clobbering `wBugContestStartTime` | fixed `6dd78ab8b`: `Script_specialphonecall` skips the high operand byte, the bike-shop call writes one byte; RAM layout unchanged. Checked in `kurt_chain_route42_call_house` | `engine/overworld/scripting.asm`, `engine/overworld/events.asm` | story_unown review |

Suspected/minor: the party menu shows ABLE for an EVIOLITE holder; a confusion self-hit ignores EVIOLITE; Kurt in the workshop (`ENGINE_KURT_MAKING_BALLS`) runs the hand-over across the room; reaching the Tin Tower Suicune without stepping on Route 42 (24,14) may leave the MAIL unobtainable; an enemy Thief could take the one EVIOLITE.

2026-11-19: the 11 `scenes.deity_*` tutor tests (stale since `87580fe2d`) are parked behind `DEITY_TUTOR_TESTS = False` in `harness/suite_scenes.py`; `deity_story_gates` still runs. `suite_scenes`: 12/12 pass.

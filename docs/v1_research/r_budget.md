# Crystal Eclipse resource budget for branches 11/24/30/32/39/49 (base: core 01727c11f)

**The build artifacts are one commit out of date.** The .map, .sym and .gbc files (release and debug) were all built at 2026-10-23 20:51. The tip of core, 01727c11f (Fast Ball, 21:27), is newer. That commit changes only `engine/items/item_effects.asm` (+4/−35), `data/wild/flee_mons.asm` and `main.asm`. So the numbers below match 8569b7acd. After a rebuild, expect a few dozen bytes more free in the item-effects bank and in "Flee Mons" ($07). Nothing else changes.

## 1. ROM0
| build | Home section | free above Home |
|---|---|---|
| release | $0150-$3f20 | **$3f21-$3fff = 223 B** |
| debug | $0150-$3f3d | **$3f3e-$3fff = 194 B** |

The map's TOTAL EMPTY figures ($1ad / $190) include the 157 bytes at $0063-$00ff and the rst gaps, so they overstate what is usable. Debug runs out first.

## 2. ROMX free space (bytes, release / debug)
Totals: ROMX has 1,620,711 B used and 460,057 free across 127 banks. ROM0+ROMX together are **78.0% used** (1,636,666 / 2,097,152). The header is MBC3 at 2 MB with RAM size $03 (32 KB), so the ROM cannot grow any further.

| Bank | Contents relevant here | Free rel / dbg |
|---|---|---|
| $0d Effect Commands | `effect_commands.asm`, `DoMove`, **`BattleCommand_CheckObedience` (0d:43aa)**, TypeMatchups | **41 / 41** |
| $0f Battle Core | core.asm, `BattleCommandPointers` (0f:7ceb), LoadEnemyMon, StartBattle, HandleWeather | **435 / 435** |
| $09 bank9 | `data/moves/effects.asm` (MoveEffectsPointers 09:7267, MoveEffects) + "Moves Gen 2" | **2 / 2** |
| $07 | "Moves Gen 1" (846 B), Flee Mons | **3 / 3** |
| $10 | `Moves::` indirect table, Pokedex, evos/attacks ptrs | 530 / 530 |
| $72 Misc Text | MoveNames | 3770 / 3770 |
| $0b bankB | MoveDescriptions, AI_Redundant, ChooseMoveToLearn, several BattleAnimFunc | 791 / 881 |
| $01 | **"Battle Animation Data" (`BattleAnimations` ptr table, 3 B/move)**, StepHappiness, LearnMove | **6 / 1** |
| $0e | AI scoring/items + "Battle Animations Gen 1" | 3700 / 3700 |
| $11 | AIChooseMove, "Battle Animations Gen 2", pokedex_2 | 870 / 870 |
| $06 | "Battle Animations Gen Negatives", Overworld Weather | 2 / 3 |
| $33 Move Animations | anim engine, OAM data, object gfx table | 7591 / 7591 |
| $05 | anim framesets | 0 / 0 |
| $21 | gfx/battle_anims.asm | 6284 / 6284 |
| $03 bank3 | **SpecialsPointers (3 B/special)**, SafariZoneMoveTutorSpecial stub, FishFunction, InitRoamMonsSpecial, mobile5C (1086 B) | **0 / 3** |
| $3f bank3F | safari_move_tutor.asm (SafariZoneMoveTutor 3f:536a), tileset anims | 9873 / 9873 |
| $12 | MoveTutor (12:45a4), evos/attacks 2 | 7510 / 7510 |
| $25 | CountStep, CheckWildEncounterCooldown, events.asm | 6647 / 6647 |
| $20 | DoPlayerMovement | 237 / 210 |
| $24 | Fish | 1047 / 1053 |
| $0a | wildmons.asm (TryWildEncounter, roamers), Johto/Kanto/Swarm wild data | **7 / 8** |
| $75 | 16-bit ID stuff, Orange + Season wild data | 11798 / 11798 |
| $43 | BaseData, PokemonNames | 1064 / 1064 |
| $5f/$6e/$73/$74 | Pokédex entries | 4686 / 9509 / 9391 / 6924 |
| $13 | stats_screen.asm, CheckSave | 8944 / 8855 |
| $02 | Evolutions and Attacks 3 | 0 / 0 |

**The ten emptiest banks:** $47 Battle Tower 15373; $45 mobile45 15092; $78 Tileset Data 8 14997; $7a 14351; $7c BT trainer data 13864; $7d Mon Icons 3 13312; $46 mobile46 12785; $7b BT text 12542; $75 11798; $22 Crystal Features 2 10740.

**Hard blockers. These have to be relocated before branches 39 and 49 can start:**
- **New move data doesn't fit.** Each new move needs 6 B in Moves data ($07 or $09, which have 3 and 2 B free), 3 B in the anim pointer table ($01, 6 B free, so 2 moves in release and none in debug), and a new effect script in $09 (2 B free). Fix: give `Moves::` and `BattleAnimations::` a third `indirect_entries` segment in a roomy bank, or move whole sections. MoveEffects/MoveEffectsPointers are read with `BANK(...)`, so they can move freely.
- **Bank $0d (41 B) blocks new battle commands.** `DoMove` dispatches with `jp hl`, so every handler must live in $0d, or be a stub of about 4 B that farcalls out. Each command also costs 2 B in `BattleCommandPointers` ($0f).
- **Bank $03 has 0 B free, so no new specials.** Branches 30 and 39 likely need specials. Removing mobile5C (1086 B, also in $03) during branch 11 frees this room, so **do 11 first**.
- **The pseudo-ability hooks sit in full banks.** StepHappiness is in $01 (6 B) and the encounter roll is in $0a (7 B), so both must farcall out. The battle hooks go in $0f (435 B).

## 3. RAM, flags and ID spaces
**WRAM free:** WRAM0 10 B; WRAMX1 **118 B** (tail $df8a-$dfff, after the saved block); WRAMX2 584 B; WRAMX5 2530 B; WRAMX 3, 4, 6 and 7 none; HRAM 0. Debug is identical.

**Saved-block growth ceiling: 118 B.** Each saved byte costs one byte in each of three places: WRAMX1 (118 free), SRAM1 ($bd93-$bfff, 621 free) and SRAM0 backup ($bee8-$bfff, 280 free, where the debug-only `sDebugTimeCyclesSinceLastCall` floats). WRAMX1 is the smallest, so it sets the limit.

**M0 reserved bytes, still unused (grep finds no references):**
- `wOvercastReserved` (4 B, dbf5)
- `wReservedRegionMapData` (8 B)
- the `ds 4` after `wVisitedSpawns`
- the `ds 4` after `wPokedexCaught`
- the `ds 4` after `wPokedexSeen`

The reserved bytes now in use are `wSeason`, `wSeasonalFlags`, `wCurRegion`, `wOvercastRandomDay` and `wOvercastSeed` (renamed from wOvercastRandomMaps). The 8 B `wReservedSaveData` went to `wVariantCaught`/`wVariantBaseCaught`, sized for MAX_VARIANTS 32 with 25 used. Old padding at `ram/wram.asm:2888` (`ds 4`) and `:2903` (`ds 2`) is also still unclaimed.

**Per-mon spare space:** `rb_skip 4` after the EVs in both `party_struct` and `savemon_struct` (`constants/pokemon_data_constants.asm`). That is 4 free bytes per mon with no layout change. Check that they are zero in existing saves before using them.

**Event flags:** `NUM_EVENTS` = **2048**; the "; 800" comment at `constants/event_flags.asm:1659` is stale. `wEventFlags` is 256 B. 1528 are named, so **520 are free**: 33 `const_skip` plus gaps of 51 (249-299), 219 (381-599), 148 (852-999), 61 (1539-1599) and 8 (1903-1910). The last block (1911-2047, Kanto) is completely full. New flags must go inside a gap, before a `const_next`, and that placement does not shift any saved flag.

**Other counts:**
- **Engine flags:** 183. The ID is 16-bit (`dwb` address+bit), so there is no index limit. Each flag costs a saved bit.
- **Scene IDs:** 89 `w*SceneID` bytes and 83 `scene_var` rows; the only limit is saved bytes.
- **Specials:** 138. The `special` macro uses a `dw` index, so the real limit is bank $03 space (above).
- **Script commands:** up to $af, so about 80 free.

**Moves:** **NUM_ATTACKS = 263** (141 GEN1 + 122 GEN2; the comments in move_constants.asm are stale). The assert limit is $3fff, matching the 6-bit `MOVES_HIGH_MASK`. The 8-bit move table is `MOVE_TABLE_ENTRIES` 230 with 18 locked, 16 recent and $FF reserved. That caps distinct moves live at once, not the total.

**Effects:** **159 used** (NUM_MOVE_EFFECTS), stored as a `db` in the move struct and BATTLE_VARS_MOVE_EFFECT, so **97 left**.

**Battle commands:** $01-$b1 used (177; NUM_EFFECT_COMMANDS = $b1). They share one byte space with `endmove` $ff and `endturn` $fe, and DoMove treats anything ≥ $fe as a terminator. That leaves **$b2-$fd = 76 free**.

**Battle anims:**
- Animation IDs are the move constants (16-bit), plus 23 negative IDs ($ffe9-$ffff).
- Anim script opcodes run $d0-$ff; free opcodes are $ea-$ed and $f6-$f7 (6). `anim_wait` must stay below $d0.
- Objects: 189, `dw`.
- Funcs: 80 of 256 (`db`).
- Framesets: 186, `dw` in the object data.
- OAM sets: **217 of 252** (assert ≤ FIRST_OAM_CMD $fc).
- BG effects: 54 of 256.
- Anim gfx: 41 of 255.
- Active structs: 10.

## 4. Branch hygiene
`git branch --merged core`: 11, 20, 21, 24, 30, 32, 64, 65, 66, 67, 68, 69, 70, 71 and CSE-base. Not merged: 15, 39, 49 and gen3.

| branch | behind / ahead of core | status |
|---|---|---|
| 11-remove-time-capsule-link-capability | 699 / 0 | Stale name. Its tip is a *Revert* of the link removal. The work isn't in core: TimeCapsule (5b:66e7) and the mobile banks are live. |
| 24-reorder-moves | 618 / 0 | Stale name; the moves are still in gen order. |
| 30-make-events-to-max-DVs-and-EVs | 629 / 0 | Stale name; the work isn't done. |
| 32-add-obedience-checks | 626 / 0 | Stale name; CheckObedience still checks badges (`effect_commands.asm:645-663`). |
| 39-make-legendaries-move-tutors | 272 / **2** | WIP from 2026-05-24, "need to reduce BATTLE CORE". It changes 31 files: removes CONVERSION and BEAT_UP, adds SWITCH_HIT, and edits descriptions, animations, effects, AI and parties. It **conflicts head-on with 24**. |
| 49-introduce-pseudo-abilities | 309 / 1 | Its one commit is an unrelated PP_UP/Celadon mart change. Core already has PP_UP at `marts.asm:328`, so the branch is effectively empty. |
| 68-ow-weather | 1 / 0 | Merged. Core is *ahead* of it by Fast Ball; origin/68 is also in core. The "core is behind 68" memory is obsolete. |
| 69-dead-code | 69 / 0 | Merged. |
| 70-render-overworld | 27 / 0 | Merged. |
| 71-fast-ball-fix | 0 / 0 | Same as core. |
| 15-implement-followers | 627 / 1 | One small map-script commit (2 maps). |
| 20, 21 | 738 / 0 and 607 / 0 | Merged. |
| gen3 | 1010 / 552 | Divergent; ignore. |

Recommendation: cut the four stale branch names fresh from core, and rebase or rewrite 39 on top of 24.

**Optimizer baseline:** `python3 utils/optimize.py | wc -l` gives **608 lines** ("Found 161 instances"). The largest group is 33 `a == 1`. There are no jmp→jr warnings.

## 5. Save compatibility
Core **already breaks v0.7 saves**. The M0 reservation (8e193b313) and M1's variant arrays (7060f05ce, 2026-08-20) both landed after v0.7 (2026-07-14). `SAVE_CHECK_VALUE_1/2` are still 99/127, so old saves will load as garbage instead of being rejected.

| Branch | Layout / meaning change |
|---|---|
| **24** | **Breaks saves.** Box mons store 16-bit move indexes (`SAVEMON_MOVES_LOW/HIGH`), the party stores 8-bit IDs mapped through the saved `sMoveIndexTable`, and day-care and Battle Tower SRAM mons also store moves. Every saved move becomes the wrong move unless an old→new remap runs on load. |
| **39** | Is safe if the 10 species stay defined but unobtainable. **Breaks saves** if the species constants are deleted: species indexes shift in boxes, and `wPokedexCaught`/`wPokedexSeen` shrink and move every later offset. Leave `wRoamMon1-3` (saved) in place even if the beasts stop roaming. Redefining existing signature moves changes what saved mons' moves do. New moves appended at the end are safe. Pseudo-ability Pressure (49) lists 8 of the retired legendaries. |
| **11** | Breaks saves if done naively. `"Link Battle Data"` (SRAM1, $60 B) sits between Box Metadata and HoF/**Crystal Data**/Battle Tower in `layout.link`, so removing it shifts `sCrystalData`. `wMobileOrCable_LastSelection`, `wTimeCapsuleSceneID` and `wMobileTradeRoomSceneID` are inside the saved block. Deleted EVENT_* constants renumber later flags. Use `ds`/`const_skip` placeholders to keep compatibility. Side note: SRAM banks 4-7 don't exist on this 32 KB cart, so `s5_*` and Trainer Rankings mirror onto SRAM bank 1, over sSaveData. Their only users are stubbed, mobile, or unused BattleTowerAction_11/12. Branch 11 should delete them. |
| **30** | No layout change (DVs and EVs exist). **Caution:** CSE marks a mon shiny when all four DVs are ≥ 12 (`engine/gfx/color.asm:8`), so maxed DVs make every mon shiny. Atk/Spd DVs also set gender (`mon_stats.asm:133`), Unown letter and Hidden Power. Plan for this, e.g. store a "trained" flag in the spare per-mon bytes, or cap the DVs. |
| **32** | None; happiness is already stored. |
| **49** | None if every effect is stateless. "After X steps" curing would need per-mon counters: use the 4 spare per-mon bytes or a few of the 118 saved bytes. |

**Recommendation:** declare v1.0 a save break, since core already is one. Batch 24, a species-deleting 39 if wanted, a non-placeholder 11, and any 49 state into the same pre-1.0 window. Bump `SAVE_CHECK_VALUE_1/2` (`constants/misc_constants.asm:22-23`) once at the end so old saves are cleanly rejected. If placeholder-preserving 11 and keep-species 39 are chosen, 24 is the only unavoidable break. Doing it last before 1.0 avoids a migration routine.

**Suggested order:** 11 (frees bank $03), then the bank relocation pass ($09/$07/$01/$0d), then 24, then 39, then 32, 30 and 49.

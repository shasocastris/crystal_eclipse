# Battle fixture recipe (for the SameBoy harness)

Researched against `core` @ 9a507d462 with `crystal_eclipse_debug.sym`. Re-read addresses from the `.sym` on every build: they move.

Sym notation is `bank:addr`:
- For ROM, the bank is the ROM bank.
- For `c000-cfff`, `00` is WRAM0.
- For `d000-dfff`, the bank is the WRAMX bank (SVBK). Party and battle data are in bank 1, and the 16-bit index tables are in bank 2.
- `ff80+` is HRAM.

## 1. Starting a battle on demand

### Wild battle: inject a mem-script (pure RAM writes, no CPU hijack)

The overworld runs queued "mem-scripts" through `PlayerEvents` → `RunMemScript` (`engine/overworld/events.asm:1019`, `25:62a3`). That path does `EnableScriptMode` and `DoPlayerEvent` properly. Writing `wScriptRunning` directly would not, because `PlayerEvents` returns early when it is non-zero (`events.asm:226-229`).

Reuse the ROM's own `WildBattleScript` (`events.asm:1168`, **`25:637d`**: `randomwildmon / startbattle / reloadmapafterbattle / end`).

**Preconditions:** the overworld is idle (the player is standing, no text is open), `wScriptRunning` (`01:d43d`) = 0, and `wMapReentryScriptQueueFlag` (`01:d45a`) = 0.

Writes:

| Label | sym | Value |
|---|---|---|
| `wTempWildMonSpecies` | 01:d236 | species **runtime 8-bit ID** (§2) |
| `wCurPartyLevel` | 01:d154 | level |
| `wBattleType` | 01:d238 | `BATTLETYPE_NORMAL` = 0 (`constants/battle_constants.asm:145`) |
| `wOtherTrainerClass` | 01:d237 | 0 (wild) |
| `wMapReentryScriptBank` | 01:d45b | `$25` (BANK of WildBattleScript) |
| `wMapReentryScriptAddress` | 01:d45c (LE word) | `$637d` |
| `wMapReentryScriptQueueFlag` | 01:d45a | 1, **written last** |

Then `run_until StartBattle` (`engine/battle/core.asm:7599`, `0f:70a9`).

How the pieces connect:
- `randomwildmon` only clears `wBattleScriptFlags` (`scripting.asm:1065`).
- `LoadTrainerOrWildMonPic` copies `wTempWildMonSpecies` → `wTempEnemyMonSpecies` (`core.asm:7661-7670`).
- `InitEnemy` picks wild because `wOtherTrainerClass` is 0 (`core.asm:7672`). `InitEnemyWildmon` (`:7746`) sets `wBattleMode = WILD_BATTLE` and calls `LoadEnemyMon` (`:5409`).
- The held item is rolled with BattleRandom (`:5466-5484`) unless `wBattleType` is `BATTLETYPE_FORCEITEM`. Override it after the start (§3).

`StartBattle` returns at once if `wPartyCount` (`01:dc30`) = 0 (`core.asm:7603`).

### Trainer battle: same injection

`InitEnemy` branches on `wOtherTrainerClass` alone, so the same `WildBattleScript` injection gives a trainer battle when you also write:
- `wOtherTrainerClass` (`01:d237`) = the trainer class constant
- `wOtherTrainerID` (`01:d239`) = the party number (1-based)

`randomwildmon` sets the script flags to 0, so `reloadmapafterbattle` takes the "was_wild" path (`scripting.asm:1105-1127`). That's harmless: it only skips Mom's money-saving.

**Use `wBattleType = BATTLETYPE_CANLOSE` (1)** for trainer tests, so a loss doesn't white out. The proper script route is `Script_loadtrainer` (`scripting.asm:1088`, `25:5b55`), which needs script bytes in ROM; `StartBattleWithMapTrainerScript` (`engine/events/trainer_scripts.asm:18`) needs a talked-to object. Neither is needed here.

## 2. Setting up the player's party mon

### CSE runtime IDs (the gotcha)

Party species and moves are **8-bit runtime IDs**, not constants. A constant is converted through the WRAM bank-2 tables (`macros/wram_16bit.asm:1-49`, `ram/wram.asm:2979-2980`):

| Table | Base | Entries (ID n at `Entries + 2*(n-1)`, little-endian 16-bit index) | Size |
|---|---|---|---|
| `wPokemonIndexTable` | 02:d200 | `wPokemonIndexTableEntries` 02:d202 | 100 IDs (`MON_TABLE_ENTRIES`, `constants/16_bit_translation_constants.asm:16`) |
| `wMoveIndexTable` | 02:d300 | `wMoveIndexTableEntries` 02:d302 | 230 IDs (`MOVE_TABLE_ENTRIES`, `:22`) |

ID 0 is "none". IDs ≥ `MON_TABLE_MINIMUM_RESERVED_INDEX` (`$FD`) are reserved: `$FD` is EGG. A free slot's entry is 0. The read macro is at `engine/16/macros.asm:4-40`.

To get a runtime ID:
- **Read-only lookup (safe):** scan `Entries` for the 16-bit index. If it is found, `ID = slot + 1`.
- **Allocate (when not found):** call the home routine instead of writing the table. **`GetPokemonIDFromIndex`** (`00:3b38`) takes hl = index and returns a = ID; **`GetMoveIDFromIndex`** (`00:3b77`) works the same way. Both are home-bank, so call them directly (push a return address and set PC) with no farcall.
  - The store routine falls through into **garbage collection** (`engine/16/table_functions.asm:22-49`, `:58-86`), which frees any ID not referenced from party, OT party, battle mon, enemy mon, `wCurPlayerMove` and the like.
  - **Write each new ID into `wPartySpecies` / `wPartyMon1Species` / `wPartyMon1Moves` straight away**, before allocating the next one.
- **Index constants:** parse `constants/pokemon_constants.asm` (`const_def 1` at :31; `const_skip`/`const_next` exist) and `constants/move_constants.asm` (`const_def` at :7). Or read the existing runtime ID from party slot data written by the game.

### Party mon 1 fields (`PARTYMON_STRUCT_LENGTH` = `$30`; mon N = mon 1 + `$30`·(N−1))

| Field | sym | Notes |
|---|---|---|
| `wPartyCount` | 01:dc30 | |
| `wPartySpecies` | 01:dc31 | list of runtime IDs, then `$ff` |
| `wPartyMon1Species` | 01:dc38 | runtime ID |
| `wPartyMon1Moves` | 01:dc3a | 4 runtime move IDs |
| `wPartyMon1EVs` | 01:dc43 | 6 bytes: HP/Atk/Def/Spd/SAt/SDf |
| `wPartyMon1DVs` | 01:dc4d | 2 bytes: Atk·Def, Spd·Spc |
| `wPartyMon1PP` | 01:dc4f | 4 bytes (bits 6-7 = PP Ups) |
| `wPartyMon1Happiness` | 01:dc53 | |
| `wPartyMon1Level` | 01:dc57 | |
| `wPartyMon1Status` | 01:dc58 | |
| `wPartyMon1HP` / `MaxHP` | 01:dc5a / 01:dc5c | big-endian; stats follow MaxHP |

After changing species, level, DVs or EVs, **recompute the stats**. That's the same pair `PerfectMonApply` uses (`engine/events/perfect_mon.asm`):
1. Set `wCurPartyMon` (`01:d11a`) = slot (0-based) and `wCurPartySpecies` (`01:d119`).
2. Call `RareCandy_StatBooster_GetParameters` (`03:69d8`), then `UpdateStatsAfterItem` (`03:694e`, `engine/items/item_effects.asm:1300`). That ends in `CalcMonStats` (`03:5dab`).

These are in ROM bank 3, so call them through **`FarCall_hl`** (`00:2871`: a = bank, hl = address). Then set HP = MaxHP if you want full health.

The battle copies the party mon into `wBattleMon*` at send-out. **Changes after the battle starts must go to `wBattleMon*`** (§3).

## 3. Enemy mon and forcing its move

Sync point: the first `BattleMenu` entry (`0f:5dd3`, `core.asm:BattleMenu`). It is reached after `InitEnemy`, `LoadEnemyMon` and the send-outs.

| Label | sym |
|---|---|
| `wEnemyMonSpecies` | 01:d20e |
| `wEnemyMonItem` | 01:d20f (runtime **item** ID) |
| `wEnemyMonMoves` | 01:d210 (4 runtime move IDs) |
| `wEnemyMonDVs` | 01:d214 |
| `wEnemyMonPP` | 01:d216 |
| `wEnemyMonHappiness` / `Level` | 01:d21a / 01:d21b |
| `wEnemyMonStatus` | 01:d21c |
| `wEnemyMonHP` / `MaxHP` | 01:d21e / 01:d220 (big-endian) |
| `wEnemyMonStats` | 01:d222 (Atk, Def, Spd, SAt, SDf; 2 B each, BE) |
| `wEnemyMonType1` | 01:d22c |
| `wWildMonMoves` | 00:c731 (the wild copy used for catching) |

**Forcing the enemy's move:**
- **Simplest:** give it one move with PP. Set `wEnemyMonMoves` = [M, 0, 0, 0] and `wEnemyMonPP` = [pp, 0, 0, 0]. The wild picker (`ParseEnemyAction.loop2`, `core.asm:5310-5335`) can then only pick slot 0.
- **Exact, wild and trainer:** hook **`ParseEnemyAction.skip_load`** (`0f:63bf`, `core.asm:5340`). At that PC the choice is final but `UpdateMoveData` hasn't read it yet. Overwrite `wCurEnemyMove` (`00:c6e4`, runtime ID) and `wCurEnemyMoveNum` (`00:c6e8`).
  - Trainers choose in `AIChooseMove` (`11:413a`), which runs at the top of every `BattleTurn` before the menu (`core.asm:BattleTurn`). `ParseEnemyAction` then jumps straight to `.skip_load` because `wBattleMode` ≠ 1 (`:5306-5308`). That's why the hook works for both kinds of battle.

## 4. Battle menu input

The menu is a 2×2 static menu (`engine/battle/menu.asm:29-46`): **1 FIGHT, 2 PKMN** on the top row and **3 PACK, 4 RUN** on the bottom.

Its cursor comes from `wBattleMenuCursorPosition` (`01:d0e2`), copied in `LoadBattleMenu` (`09:4eec`, `menu.asm:1-16`). B snaps the cursor to RUN (`menu.asm:9-12`).

**Deterministic selection without D-pad navigation:**

1. `run_until LoadBattleMenu` (`09:4eec`).
2. Write `wBattleMenuCursorPosition` = 1 (FIGHT) or 4 (RUN).
3. `run_until InterpretBattleMenu` (`00:1bde`). The menu is drawn and polling.
4. Press A (hold 2-4 frames, release).
5. **FIGHT:** `ParsePlayerAction` (`0f:4392`) calls `MoveSelectionScreen` (`0f:6079`). `run_until MoveSelectionScreen`, then write **`wCurMoveNum` (`01:d0e5`) = slot (0-3)**. The cursor is `wCurMoveNum + 1` when `wMoveSelectionMenuType` (`01:d23d`) = 0 (`core.asm`, `MoveSelectionScreen .skip_inc`). Then `run_until MoveSelectionScreen.interpret_joypad` (`0f:6149`, which polls `ScrollingMenuJoypad` `00:17b6`) and press A.
6. **RUN:** `BattleMenu_Run` (`0f:6048`) → `TryToRunAwayFromBattle` (`0f:560d`, `core.asm:3384`). Its text needs A presses until the battle ends (§7).

"Waiting for input" labels: `InterpretBattleMenu` (00:1bde) for the main menu, and `MoveSelectionScreen.interpret_joypad` (0f:6149) for the move list. **Don't mash A after a decisive turn without checking**: an A pressed at `InterpretBattleMenu` picks FIGHT.

Options that speed up runs (`wOptions` `00:cfb5`, `ram/wram.asm:1365`): bit 7 `BATTLE_SCENE` set = animations off, bit 4 `NO_TEXT_SCROLL`, bit 6 `BATTLE_SHIFT` set = "set" style (no switch prompt). `constants/ram_constants.asm:42-47`.

## 5. Reading the outcome

| What | Label | sym | Notes |
|---|---|---|---|
| Weather | `wBattleWeather` | 00:c707 | 0 none, 1 rain, 2 sun, 3 sandstorm, 4 hail (`battle_constants.asm:311-315`) |
| Weather turns | `wWeatherCount` | 00:c708 | |
| Player stat stages | `wPlayerStatLevels` | 00:c6cc | Atk, Def, Spd, SAt, SDf, Acc, Eva; base 7, max 13 (`ram/wram.asm:436-443`) |
| Enemy stat stages | `wEnemyStatLevels` | 00:c6d4 | same order |
| Player battle mon | `wBattleMonSpecies` 00:c62c, `Item` c62d, `Moves` c62e, `DVs` c632, `PP` c634, `Happiness` c638, `Level` c639, `Status` c63a, `HP` c63c, `MaxHP` c63e, `Stats` c640, `Type1` c64a | | |
| Substatus | `wPlayerSubStatus1-5` 00:c668/c669/c66a/c66b/c66c; `wEnemySubStatus1-5` 00:c66d/c66e/c66f/c670/c671 | | bit names in `battle_constants.asm:254-298` |
| Hit/miss | `wAttackMissed` 00:c667, `wEffectFailed` 00:c70a, `wCriticalHit` 00:c666, `wTypeModifier` 00:c665, `wCurDamage` 01:d260 | | read at the hook below |
| Moves used | `wCurPlayerMove` 00:c6e3, `wCurEnemyMove` 00:c6e4, `wLastPlayerMove` 00:c718, `wLastEnemyMove` 00:c719 | | runtime IDs |
| Disobedience | `wAlreadyDisobeyed` | 00:c6f1 | reset each turn (`effect_commands.asm:124`) |
| Whose turn | `hBattleTurn` | 00:ffdf | 0 player, 1 enemy |
| Result | `wBattleResult` | 01:d0ff | low bits WIN 0, LOSE 1, DRAW 2; bit 6 caught Celebi, bit 7 box full (`battle_constants.asm:348-354`) |
| Ended | `wBattleEnded` | 00:c730 | |
| Mode | `wBattleMode` | 01:d235 | 1 wild, 2 trainer; 0 after cleanup |

**Turn-order hooks:** `DetermineMoveOrder` (`0f:42f3`) then calls exactly one of **`Battle_EnemyFirst` (`0f:453b`)** or **`Battle_PlayerFirst` (`0f:4597`)** (`core.asm:BattleTurn`). Whichever PC is hit first that turn is the order. The individual actions are `DoPlayerTurn` (`0d:4000`) and `DoEnemyTurn` (`0d:400a`), the effect-script entry points: log their order and `hBattleTurn`.

Obedience runs inside `DoPlayerTurn` (`BattleCommand_CheckObedience`). Read `wAlreadyDisobeyed` and `wBattleMonStatus` (nap) after `DoPlayerTurn` returns, or at the next `BattleMenu`.

## 6. Randomness

`Random` and `BattleRandom` are **one routine** (`home/random.asm:1-30`, `00:2aeb`). It mixes `rDIV` into `hRandomAdd` (`00:ffdc`) with `adc` and into `hRandomSub` (`00:ffdd`) with `sbc`, and returns `a = hRandomSub`. VBlank also stirs them.

**Writing `hRandom*` alone does not fix the result**, because `rDIV` and the carry flag are mixed in at call time.

Two deterministic options:
1. **Save-state replay.** SameBoy is deterministic, so the same state plus the same inputs on the same frames gives the same rolls. Save one state at the `BattleMenu` sync point and replay variants from it. This is best for A/B ROM comparisons, as long as both ROMs reach the same code with the same timing; differing code shifts `rDIV`, so compare outcomes statistically, not roll by roll.
2. **Force a roll.** Set an execution breakpoint on Random's `ret` at **`00:2afd`** (`c9`, verified in the ROM: the routine is 18 bytes from `00:2aeb`) and overwrite register A before it executes. Count the calls inside a move to pick the one to force, for example the obedience `rand1` loop or the secondary-effect chance.

## 7. Ending the battle and returning to the overworld

- The turn loop exits on `wBattleEnded` or `wForcedSwitch`. `StartBattle` then calls `ExitBattle` (`0f:7227`, `core.asm:7792`) → `CleanUpBattleRAM` (`0f:7242`), which zeroes `wBattleMode`, `wBattleType`, `wTempWildMonSpecies`, `wOtherTrainerClass` and more (`:7806-7822`).
- Then `Script_startbattle` copies the result to `wScriptVar`. `reloadmapafterbattle` (`scripting.asm:1105`) whites out on LOSE unless the battle type was CANLOSE, and otherwise reloads the map (`MAPSETUP_RELOADMAP`).
- **Detection:** `run_until CleanUpBattleRAM` means the battle is over; read `wBattleResult` there. Back in the overworld means `wBattleMode` = 0 **and** `wScriptRunning` (`01:d43d`) = 0, polled each frame. You can also hook `HandleMapTimeAndJoypad` (`25:500f`), which runs every overworld frame.
- Between the last move and `CleanUpBattleRAM`, text ("fainted", EXP, level-up, "learned a move") needs A presses. Press A only while PC is not at `InterpretBattleMenu` or `MoveSelectionScreen.interpret_joypad`. A level-up move prompt is a yes/no; answer B to skip learning.
- **Fleeing:** set `wBattleMenuCursorPosition` = 4 and press A. A wild flee can fail (`wFailedToFlee` 01:d271, `wNumFleeAttempts` 01:d272). A trainer battle refuses to flee.

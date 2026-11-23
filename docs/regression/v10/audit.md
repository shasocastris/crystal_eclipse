# v1.0 audit: static review, build health, save compatibility, data diff

HEAD `1fb549fdf` vs `v0.9` (`2f2a153e6`). Tests are in `docs/regression/harness/v10_audit.py` and the evidence is in `docs/regression/v10/audit/`.

## Tests

| Test | Checks | HEAD | v0.9 (control) | Intended? |
|---|---|---|---|---|
| `v10_audit.audit_v09_save_loads` | Makes a save on v0.9: debug party, SHIFT battle style, and 4 trainer/story flags set. Loads it on the ROM under test and continues. Map, party (species by index), bag (by index), key items, money, badges, wOptions and **every named event flag** must match. Then it walks 6 steps, re-saves, and reloads. | **FAIL**: 5 flags read wrong, and `EVENT_BEAT_KIMONO_GIRL_HANA` reads as set. Everything else carries over. The CONTINUE, walk, re-save and reload steps all work. | PASS | No (bug 1) |
| `v10_audit.audit_v09_save_ruins_of_alph` | Loads a plain v0.9 debug-party save and warps to the Ruins of Alph. The executives' hide flag must stay set and the Ruins quest must not be active. | **FAIL**: a Rocket executive stands outside the Ruins (`ruins_outside_head.png`). | PASS (`ruins_outside_control.png`) | No (bug 1) |

**2026-11-08 (`85-followers`, 545f73d97):** `audit_v09_save_loads` now fails earlier: the v0.9 save is rejected outright, and the main menu shows no CONTINUE. Expected under the 2026-11-05 fresh-save decision for v1.0. **Cause (confirmed):** follower phase A (`c450a9048`) raised `NUM_OBJECTS` 18→19, adding a 16-byte map object inside the saved data, so `wGameDataEnd`, `sChecksum` and `sCheckValue2` move by 17 bytes ($11; one byte not traced). The v0.9 save fails the check and gets no CONTINUE. Core `ba9240400` (the port's base) still continues the v0.9 save, with only the known Hana flag shift.

Both tests pass on the prototype fix ROM (`<scratch>/wt/audit-fix`, screenshots `*_audit-fix.png`).

## Game bugs

### 1. HIGH: v0.9 saves are not compatible. Inserting Kimono Girl Hana's flag renumbered 271 event flags
- **Root cause:** `constants/event_flags.asm:907` (commit 9282d730f) inserts `EVENT_BEAT_KIMONO_GIRL_HANA` mid-list, after `..._YUKI`. Every flag from `EVENT_BEAT_POKEMANIAC_LARRY` ($4F4) through `EVENT_ICE_PATH_1F_RIVAL` ($602) moves up by one. This covers all trainer-beaten flags for the classes after Kimono Girl, plus 5 story flags. Every other save-relevant symbol stayed put: no WRAM or SRAM symbol in wGameData or SRAM moved between the two `.sym` files.
- **What a v0.9 player sees on v1.0:**
  - Each flag in the shifted range reads the bit of the next flag in the v0.9 list. Beaten trainers there can show as unbeaten and battle again, and unbeaten ones can show as beaten. Hana reads Larry's bit.
  - `EVENT_RUINS_OF_ALPH_ROCKETS` reads the v0.9 executives' hide bit. That bit is set at new game, so the Ruins Rocket quest turns on for every upgraded save, at any point in the story.
  - `EVENT_RUINS_OF_ALPH_OUTSIDE_EXECUTIVES` reads 0, so the executives and the Suicune sprite appear outside the Ruins. This is confirmed on screen.
  - `EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS` reads 1, which hides the chamber grunts and affects the `RadioTower5F` check.
  - `EVENT_ICE_PATH_1F_RIVAL` reads 0, so the rival is visible on Ice Path 1F.
  - `EVENT_ANGELICA_GAVE_INTRO` reads Sage Koji's bit.
- **Fix (prototyped and verified):** put Hana in the unused slot that already sits at the head of the Kimono Girl block, and delete the line at 907:
  ```
  ; Kimono Girl
  -	const_skip ; unused
  +	const EVENT_BEAT_KIMONO_GIRL_HANA
  ```
  Nothing renumbers after this change. Both audit tests pass, and the debug build has 0 warnings.

### 2. HIGH (upgraders only): a v0.9 save made in the Orange Islands is stranded
- In v0.9 the Valencia express asked for the S.S.TICKET. Now `maps/ValenciaPort.asm:76` and `:118` ask for `ORANGE_PASS`, which only Oak's assistant in Pallet gives (`maps/OaksLab.asm:72`).
- Orange Islands Pokémon Centers are spawn points, so a whiteout or Teleport lands back in Orange. Cross-region Fly refuses the Orange page (`engine/pokegear/pokegear.asm:2172`).
- A v0.9 player who saved in Orange therefore has no way off the islands. I confirmed this from the code only; I did not run it in the harness.
- **Fix:** at Valencia, accept `ORANGE_PASS` **or** `S_S_TICKET`. The only way to reach Valencia is by ship, so dropping the check there entirely also works.

### 3. LOW (upgraders only): the Petrel "sailor" stays in the Captain's cabin forever on old saves
- `EVENT_FAST_SHIP_PETREL` was an unused slot in v0.9, so it reads 0. It is only set by `VermilionPortEndRaidScript`.
- A v0.9 save that already made the first S.S.AQUA trip never gets the raid. `EVENT_FAST_SHIP_FIRST_TIME` is already set, so the disguised Petrel (`FastShipCabins_SE_SSE_CaptainsCabin.asm:628`) stands there on every trip, and talking to him does nothing.
- These saves also never see the raid arc at all.
- **Fix:** have a later script (for example `VermilionPortLeaveShipScript.ShipHousekeeping`) set `EVENT_FAST_SHIP_PETREL` whenever `EVENT_FAST_SHIP_FIRST_TIME` is already set.

### Things that are fine for upgraders
- `wOptions` carries over unchanged. Nothing reads `BATTLE_SHIFT` any more, so a v0.9 SHIFT player simply gets SET.
- The other new flags take slots that were unused in v0.9, so they read 0 on an old save:
  - `ENGINE_CROSS_REGION_FLY`
  - `ENGINE_WEATHER_MAP` / `POKEGEAR_WEATHER_MAP_F`
  - `EVENT_SAFARI_ZONE_PROTECTOR`, `EVENT_POKEMON_MANSION_DUBIOUS_DISC` and the two Razor Claw item flags (the item balls simply appear)
  - `EVENT_SS_AQUA_RAID` and `EVENT_VERMILION_PORT_KOGA`
- `wSilverCaveRoom1SceneID` reuses the never-written `wGoldenrodPokecenter1FSceneID` byte, and a callback rewrites it anyway.
- `wRoute38EcruteakGateSceneID` takes a former `ds 1`. Scene 0 is the only scene, and the gate officer flag is recomputed by a callback.
- `sBattleTowerReward`: an old save's item ID is masked to `%11`, which still gives one of the four stat items.
- `wRepelType`: an old save's ID just makes the Repel wear off (by design, da77fc591).

## Build health
- **make warnings:** 0 on HEAD. v0.9 had 2 unique warnings, built twice: `jp can be jr` at `mobile/mobile_41.asm:264,269`.
- **optimize.py:** 155 on HEAD vs 156 on v0.9. With line numbers ignored, the only change is that the IcePathB3F "trailing string space" warning is gone. Nothing new.
- **farcheck.py:** output is identical to v0.9 (line numbers aside) for both builds. No new cross-bank `call`/`jp`.
- **ROM0:** unchanged. The debug build has 863 bytes ($35f) free above `Home` and the release build has 892 bytes. WRAM0 has 27 bytes free, down 1 for `wWaterWarpState`.
- **Banks to watch (debug build):**
  - **$1d "Map Scripts 8"** dropped from 2022 to **248** free. This bank holds VermilionPort, FastShip*, OlivinePort and SafariZone, i.e. the whole S.S.AQUA arc. More arc work will overflow it.
  - $45 dropped from 15116 to 398, because "Map Scripts 26" was placed there.
  - Already tight in v0.9: $20 (131), $44 (127), $3a (143), $1a (94), $48 (80) and $5b (70).
  - $01–$05 are at 0. Small floating sections fill those gaps, so this is harmless.
- `LoadWeatherGraphics` now uses `xcall`, which is resolved at link time, so the "Overworld Weather" section can float to bank 5 safely.

## Static review, other notes (no bugs confirmed)
These all checked out:
- `HandleEnemySwitch` / `EnemyPartyMonEntrance` after the Shift removal: the return value of `a` is unchanged.
- The `CheckPartyValueIsUnique` stack is balanced. Eggs now count by real species, which the commit intends.
- `GiveNicknameHappiness` in the party, box and Name Rater paths: same bank, and registers are preserved across `farcall`.
- `Buy_CapQuantityToMoney`: 24-bit compare.
- Heal machine palette copy: `wOBPals1` to `wOBPals2`.
- `GetLandmarkWeather` stack and register use.
- `CheckEvoLocation`.
- `IsInSilverCave` range asserts.
- No 8-bit species, item or move constants are used raw in the new engine code.
- No new or changed text line is over 18 characters (488 lines checked).

## Data diff, v0.9 vs HEAD
- **Trainers:**
  - New: GRUNTM 39–41 (S.S.AQUA, lv 56–58) and EXECUTIVEM 5 (Petrel, lv 59–61).
  - Changed: Kimono Girl Yuki's two Laprases became Glaceons.
  - Changed: Kimono Girl Hana went from an unused lv24 Eevee to Eevee/Leafeon/Leafeon at lv 49–51, with items and moves.
  - All parties are terminated and no level is 0.
  - Yuki's lv49 Glaceon knows SHADOW_BALL, which is not in Glaceon's TM list or learnset. It is legal only as an Eevee TM carried over, so probably fine.
  - Hana stands on Route 30 with no hide flag and range 0 (talk only), at lv 49–51. Please confirm that early-route placement is intended.
- **Evolutions:**
  - Gligar and Sneasel now use RAZOR_CLAW, where both used MOON_STONE.
  - Rhydon now uses PROTECTOR, where it used SUN_STONE.
  - Eevee: Leafeon (Ilex Forest) and Glaceon (Ice Path B3F) are now EVOLVE_LOCATION gates. Sylveon now evolves with SUN_STONE, where it used MOON_STONE, and the old LEAF_STONE and MIST_STONE entries were removed.
  - Evo moves were added for Leafeon, Glaceon and Sylveon.
- **Moves:** FAE_BLADE uses the new EFFECT_FAE_BLADE.
- **Unchanged:** wild data and base stats (the Celebi base-stat edit is uncommitted, so it is not part of this diff).
- **Pre-existing, harmless:** Leafeon and Glaceon list PROTECT twice in their tmhm lines.

## Not tested headlessly (for the hand playthrough)
- Load a **real** v0.9 mid-game save on v1.0 after fix 1. The debug party sets only a few trainer flags.
- Load a v0.9 save made in the Orange Islands (bug 2) and one made after the first S.S.AQUA trip (bug 3).
- The options screen layout after Battle Style was removed. Nothing reads the old bit.

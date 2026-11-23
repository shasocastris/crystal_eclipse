# Branch 11: remove the Time Capsule and link/serial support (research)

Base: `core` @ 01727c11f. Byte counts come from `crystal_eclipse.sym` label deltas and `.map` sections (my script: scratchpad/py/sz.py, lab.py). Anything marked **[inferred]** was not verified directly.

## 0. Branch state and lessons from the failed attempt

- The tip of `11-remove-time-capsule-link-capability` (102f4d1d8) **is the merge base**. It is an ancestor of core, and core is 699 commits ahead. The branch has nothing unique, so delete it and re-branch from core.
- The history is all in core already:
  - **7957acd8f** removed the Colosseum, TradeCenter and TimeCapsule maps and gutted Pokecenter2F. This stuck: core's `maps/Pokecenter2F.asm` is 38 lines with three receptionists that say "being adjusted".
  - **495a7f41b** deleted 9 files (`engine/link/*`, `home/serial.asm`, `engine/battle/link_result.asm`) "still need to purge link references". Then **5bdb8609c** dropped the INCLUDEs ("WIP"). Both were reverted.
- Why it failed **[inferred from the diffs]**: the files were deleted before anything was moved out of them. The deleted set held symbols that live code still needs:
  - `TradeAnimation`: `link.asm:2421` INCLUDEs `engine/movie/trade_animation.asm`, which NPC trades use.
  - `TryQuickSave`: Battle Tower and the Vermilion gift house.
  - `InitList`: intro_menu.
  - `PlaceWaitingText`: core.asm.
  - `LinkTransfer`, `LinkDataReceived`: core.asm.
  - The `ConvertMon_1to2` and `LinkTextboxAtHL` predefs.
  - The specials table.
  - **Lesson:** move what must stay, then cut the callers, then delete the files.
- Already gone in core: trade evolutions (`EVOLVE_TRADE` no longer exists), the IR Mystery Gift engine (1f3823c87), printing (cdf682ac8), `link_result.asm` (65b4abcfe), and the mobile ranking stub bodies (982661293).
- There have been no upstream (CSE/pret) merges since d06381d0f (2025-11-16), so modify/delete merge conflicts are a small risk.

## 1. Inventory (core)

**ROM0 (home)**
- `home.asm:15` `home/serial.asm`: `Serial` ISR plus exchange, timeout and transfer routines. **526 B**, $05df–$07ed.
- `home/header.asm:68-69`: vector `jmp Serial`.
- `constants/ram_constants.asm:486`: `IE_DEFAULT` includes `IE_SERIAL`.
- `home/init.asm:152`: writes `CONNECTION_NOT_ESTABLISHED` to `hSerialConnectionStatus`.
- `home/vblank.asm:53,277`: `VBlank_Serial` (15 B), `VBLANK_SERIAL` (`ram_constants.asm:473`). Nothing uses it.
- `home/battle.asm:170-188`: `MobileTextBorder` (17 B) and its call in `BattleTextbox`.
- `home/text.asm:325,457,477,486,520,529,788`: `wLinkMode` checks in PlaceEnemysName, Paragraph, _ContText, PromptText and TextCommand_PROMPT_BUTTON.
- `home/joypad.asm:359`: PromptButton `.link`.
- `home/gfx.asm:243-252`: Request2bpp `LINK_MOBILE` throttle.
- `home/random.asm:31-47`: `BattleRandom`, an 18 B bank-switch wrapper around `_BattleRandom`.
- `home.asm:59` `home/mobile.asm` (66 B): `MobileAPI` and `Function3eea` are still called from `mobile/mobile_46.asm` (Battle Tower).
- **HRAM** (`ram/hram.asm`):
  - Link only, link/core use them: `hSerialReceivedNewData`, `hSerialConnectionStatus`, `hSerialIgnoringInitialData`, `hSerialSend`, `hSerialReceive` (126-131).
  - Battle Tower and gfx use them: `hMobileReceive` (126), `hMobile` (171).
  - HRAM currently has **0 free bytes**.

**Banked engine**
- `engine/link/link.asm` (bank $5B, main.asm:536): about 4.9 KB of its own code. Specials CableClub*, TimeCapsule/TradeCenter/Colosseum, WaitForLinkedFriend and others, plus **`TryQuickSave`** (5b:6690, 21 B).
- `engine/link/link_trade.asm` ($5B, main.asm:535): 2,031 B.
- `link_2.asm` ($13, main.asm:209): 141 B.
- `time_capsule.asm` and `time_capsule_2.asm` ($3E, main.asm:471,475): 221 + 43 B.
- `place_waiting_text.asm` ($01, main.asm:3): 46 B. Bank 1 has **6 B free**.
- `init_list.asm` ($14, main.asm:238): 75 B. **Keep `InitList`**, intro_menu uses it.
- Battle Core ($0F), `engine/battle/core.asm`:
  - Link-only functions: `LinkBattleSendReceiveAction` (5906, 109 B), `ShowLinkBattleParticipantsAfterEnd` (28), `DisplayLinkBattleResult` (93), `_DisplayLinkRecord` (38), `ReadAndPrintLinkBattleRecord` (295), `AddLastLinkBattleToLinkRecord` (278), and the link RNG half of `_BattleRandom` (7051, 55 B).
  - 19 `wLinkMode` sites: 25, 95, 123, 540, 557, 2441, 2492, 2500, 2845, 3044, 3236, 3538, 3764, 3881, 4959, 5162, 5171, 5368, 5737, 6008, 7151, 7898, 8472.
  - **23 `hSerialConnectionStatus` reads**, for example 29, 98, 206, 322, 412, 476, 570, 627, 655, 829, 1269 and 1337. Each one picks a "player 2 / enemy first" duplicate path that is dead in single player, because the status is always $ff and only link.asm and serial.asm set it.
  - Stub `farcall`s: StubbedTrainerRankings_Colosseum*/LinkBattles.
- Effect Commands ($0D, **41 B free**):
  - `effect_commands.asm:13` (DoEnemyTurn), 622 (CheckObedience), 2130 (friendship endure), 6468 (time-based heal).
  - `move_effects/baton_pass.asm:70-110` (BatonPass_Link*, 68 B), `beat_up.asm:103`, `sketch.asm:4`, `thief.asm:24`.
- Other battle code:
  - `start_battle.asm:1,126` (ShowLinkBattleParticipants, 19 B, bank $0B).
  - `trainer_huds.asm:178,232` (LinkBattle_TrainerHuds 51 B, _ShowLinkBattleParticipants 53 B).
  - `ai/items.asm:8,694`, `ai/move.asm:10`, `type_completion_boosts.asm:7`, `read_trainer_party.asm:6,275`, `read_trainer_attributes.asm:24`.
- Overworld and menus:
  - `overworld/events.asm:415` (CheckTimeEvents), `:856` (CountStep).
  - `menus/start_menu.asm:304,324`, `pokemon/mon_submenu.asm:112,145`, `mon_menu.asm:529` (mail), `move_mon.asm:854`, `phone/phone.asm:297`.
  - `pokemon/evolve.asm:80,153,342`, `gfx/mon_icons.asm:505` (GetGFXUnlessMobile), `movie/trade_animation.asm:1131` (Time Capsule text branch).
  - Writers: `menus/intro_menu.asm:362`, `events/battle_tower/battle_tower.asm:67`.
- `engine/menus/save.asm:25,38` (SaveAfterLinkTrade/Link_SaveGame), 232/245 (EraseLinkBattleStats), 182/500/515 (GS Ball backup/restore; that lives in mobile_41 and must stay).
- Specials: `data/events/special_pointers.asm:13-29` (17 link specials, including TryQuickSave), `:99` (DisplayLinkRecord, which no map uses).
- Predefs: `data/predef_pointers.asm:23` (LinkTextboxAtHL), `:36` (TradeAnimationPlayer2), `:37` (TradeAnimation, **keep**).
- Constants: `constants/serial_constants.asm` (LINK_*, SERIAL_*), `ENGINE_TIME_CAPSULE` (`engine_flags.asm:102`, set at `maps/EcruteakPokecenter1F.asm:48`), `DAILYFLAGS1_TIME_CAPSULE_F` (`ram_constants.asm:372`).
- Maps:
  - `maps/Pokecenter2F.asm`: stub. About 70 warps point to `POKECENTER_2F`.
  - Link receptionist sprites in `GoldenrodPokecomCenter.asm` and `CeruleanAquarium.asm`.
  - `VermilionMysteryGiftHouse.asm`: a **custom daily item gift** (`MysteryGiftNPC`, bank $41, 34 B plus a 109 B table). It calls `special TryQuickSave` at line 27. It is a feature, not IR, so keep it.
- Mobile (`mobile/*.asm`; sections mobile45 $50c, mobile46 $e0f, mobile5F $12a6, mobile5C $43e, SDK stub):
  - Entangled with the **Battle Tower**: `_BattleTowerRoomMenu`, `CheckBTMonMovesForErrors`, `Clears5_a89a`, `CheckStringForErrors`, `Menu_ChallengeExplanationCancel` (BattleTower1F).
  - `mobile_41` holds the GS Ball flags and about 30 TrainerRankings stubs.
  - Music: mobileadapter/menu/center (`audio.asm:130,137,144`).
- WRAM (`ram/wram.asm`):
  - Plain bytes: `wLinkMode` 145, `wLinkOtherPlayerGender` 154, `wLinkBattleRNCount` 476.
  - Unions: `wPlayerPatchLists`/`wOTPatchLists` 606, `wMobileTransferData` 613, `wMobileMon` 646, `wLinkData`/`wLinkPlayerData`/`wTimeCapsule*`/link mail 936-1029.
  - Others: `wLinkTimeoutFrames` 1235, `wLinkBattleRNs` 2321, `wOTLinkBattleRNData` 2356, `wLinkBattleRecordBuffer` 1808.
  - **Save-block bytes:** `wTradeCenterSceneID`, `wColosseumSceneID`, `wTimeCapsuleSceneID` (2733-2735), `wMobileTradeRoomSceneID` (2809), `wMobileOrCable_LastSelection` (2887).
- SRAM (`ram/sram.asm`): "Link Battle Data" (127-139, $60 B at 1:$b0c4), "SRAM Trainer Rankings" (200-, bank 5 $a000, $ec B). No Mystery Gift SRAM is left.
- VC:
  - `vc/pokecrystal.patch.template` has about 30 Wireless_*/linkCable hooks. Their symbols are in link.asm, serial.asm and core.asm.
  - `make crystal_vc` is **already broken** (verified statically, not run): the Makefile rule (line 103) needs `vc/crystal_eclipse.patch.template`, but only `vc/pokecrystal.*` exists. On top of that, 6 hooks (Infrared_*, Forbid_printing_Unown) are already missing, and `tools/make_patch.c:84` exits on an unknown symbol.

## 2. What must be kept

- **The trade animation** (`engine/movie/trade_animation.asm`, 3,096 B in $5B) and `predef TradeAnimation`, used by `engine/events/npc_trade.asm:86`.
  - It references nothing in link.asm or link_trade.asm (verified), only WRAM `wLinkPlayer1/2Name`, `wLinkTradeSendmonSpecies`/`GetmonSpecies` (717-720) and `wPlayerTrademon`/`wOTTrademon`. Keep those variables (renaming is optional).
  - Move its INCLUDE out of link.asm. Delete the `LINK_TIMECAPSULE` branch at :1131.
  - `engine/gfx/trademon_frontpic.asm` (main.asm:214) is also used by the trade animation **[inferred]**.
- `TryQuickSave` (move it next to save.asm), `InitList`, `BackupGSBallFlag`/`RestoreGSBallFlag`/`ClearGSBallFlag`, the mobile code the Battle Tower uses, the `MysteryGiftNPC` gift house, and `SPRITE_LINK_RECEPTIONIST`.
- `BattleRandom` as a name: 70 callers. `Random` has the same contract (only af clobbered, `home/random.asm:1-28`), so `BattleRandom::` can become a second label on `Random`.
- **OT/traded concept:** NPC trades still create mons with a foreign OT, which matters for obedience and the traded-exp boost.
- **Save format:**
  - `wPlayerData` (2580-2957) is saved as one block. Removing any of the 5 save-block bytes above **shifts every later field and breaks existing saves**. Keep them as `ds 1`, or reuse them later; there is a precedent at 2810: `wValenciaPortSceneID` was formerly `wMobileBattleRoomSceneID`.
  - SRAM bank 1 sections float in `layout.link:397-402` order. Deleting "Link Battle Data" moves Hall of Fame, `sGSBallFlag`/`sCrystalData` and `sBattleTower*` down by $60, which corrupts those in old saves. The main save at $a000 is unaffected. Keep a `ds $60` placeholder there.
  - The same applies to Trainer Rankings in bank 5, which would shift `s5_*` (Battle Tower).
  - Engine-flag *table entries* (`ENGINE_TIME_CAPSULE`) can go: they map to WRAM bits and do not move them. The `wDailyFlags1` bit itself stays. **[inferred]**
- VC: drop the target or prune the template. It already does not build, so this is a cleanup, not a constraint.

## 3. Space freed

| Area | Freed | Value |
|---|---|---|
| **ROM0 Home** | serial 526 + VBlank_Serial 17 + MobileTextBorder 20 + BattleRandom 18 + text.asm checks ~60 + PromptButton ~10 + Request2bpp ~14 ≈ **650–700 B** (home/mobile.asm stays while the Battle Tower needs it) | **Highest.** Today the gap above Home is $df=223 B in release and **$c2=194 B in debug**, so this is about 3x the remaining headroom. |
| **HRAM** | 5 B (hSerial*); 7 B with hMobile* after Battle Tower de-mobilization | **High.** 0 free today. |
| **Battle Core $0F** | link functions 841 + _BattleRandom 55 + 19 wLinkMode sites ~150 + 23 hSerialConnectionStatus duplicate paths ~300–500 **[inferred]** + rankings farcalls ~36 ≈ **1.3–1.6 KB** | **High.** $1b3 = 435 B free today. |
| **Effect Commands $0D** | ~4 sites ×5 + BatonPass link 68 + Beat Up/Sketch/Thief sites ≈ **100–150 B** **[inferred]** | **High.** 41 B free today. |
| Bank $0B (start_battle/huds) | ~120 B | Medium |
| Bank $01 | PlaceWaitingText 46 B | Medium (6 B free) |
| Bank $3E | time capsule 264 B | Medium (~441 B free) |
| Bank $13 / $0E / $10 | 141 / ~30 / ~20 B | Low |
| Bank $5B | ~7.0 KB (link + link_trade), keeping the trade animation | Low: ROMX has 460 KB free in total |
| Bank $41 rankings stubs | up to ~2.8 KB (optional) | Low |
| WRAM | WRAM0 only ~3 bytes. wLinkData = wOverworldMapBlocks (1300) and wMobileTransferData = the 480 B Misc union, so removing them frees 0. WRAMX: tens of bytes **[inferred]** | Low |

## 4. Phased plan (build green at every step)

Before each phase, run `python utils/optimize.py > .opt.old`. After it, build with `make -j && make crystal_debug`, diff the optimizer output, and diff the `.map` and `.sym` against the previous baseline.

- **P0.** Re-create branch 11 from core. Save baseline `.map`/`.sym` copies outside the repo.
- **P1, relocate keepers, no behaviour change.**
  - Move the `INCLUDE trade_animation.asm` into main.asm (its own section, or bank5B).
  - Move `TryQuickSave` into `engine/menus/save.asm` or `engine/events`.
  - Leave `InitList` in place, or move it to `engine/pokemon`.
  - Risk: bank overflow when code moves. Check: TradeAnimation, TryQuickSave and InitList still appear in `.sym`.
- **P2, entry points.**
  - Drop the 17 link specials and DisplayLinkRecord, and remove `_DisplayLinkRecord` and the link-record functions.
  - Remove the `ENGINE_TIME_CAPSULE` table entry and the Ecruteak `setflag`.
  - Leave the Pokecenter2F receptionists for now (text only).
  - Risk: low. The `special` macro resolves by name.
- **P3, battle engine (largest gain, largest risk).**
  - Delete the `wLinkMode` branches and the **`USING_EXTERNAL_CLOCK`/`.player_2` branches only**. Keep each player-first path; the real speed-order `.enemy_first` labels such as DetermineMoveOrder must stay.
  - Delete LinkBattleSendReceiveAction and its callers (2445, 2850, 3892, 5166, 5744), DisplayLinkBattleResult and the record code, plus BatonPass_Link*, ShowLinkBattleParticipants and LinkBattle_TrainerHuds.
  - Alias BattleRandom to Random. Remove the Colosseum ranking farcalls.
  - `WildFled_EnemyFled_LinkBattleCanceled` (core.asm:117): keep the wild part.
  - Risk: turn order, between-turn effects, text and switching. Verification: read each diff hunk to confirm only branches already dead (`$ff` status, `wLinkMode`=0) were removed.
  - Play-test: wild and trainer battles, Baton Pass, Beat Up, Thief, Sketch, fleeing, switching, the Battle Tower, and a loss/whiteout.
- **P4, home, overworld and menus.**
  - Clean up text.asm, joypad, gfx, mon_icons, start_menu, mon_submenu/menu (mail), move_mon, phone, evolve, events.asm, the trade_animation :1131 branch, and save.asm `Link_SaveGame`/`SaveAfterLinkTrade`/`EraseLinkBattleStats`.
  - Check first: `mobile/mobile_5f.asm` references `SaveAfterLinkTrade`. Stub it or confirm it is unreachable **[inferred dead]**.
  - Play-test: an NPC trade, text prompts, the start menu, saving, the phone, mail.
- **P5, delete link files.**
  - Delete `engine/link/{link,link_trade,link_2,time_capsule,time_capsule_2,place_waiting_text}.asm` and `home/serial.asm`.
  - Change the vector to `reti`, drop `IE_SERIAL` from IE_DEFAULT, and remove the init.asm write, VBlank_Serial with its constant, the predefs LinkTextboxAtHL/TradeAnimationPlayer2/ConvertMon_1to2, and the hSerial* HRAM.
  - Check: no `LinkTransfer`/`Serial_` symbols remain in `.sym`, and ROM0 free goes up by about 600 B.
- **P6, RAM and constants.**
  - Remove `wLinkMode` (also the writes in intro_menu and battle_tower) and the link WRAM union members.
  - Remove `serial_constants.asm`. Keep `LINK_*` only if something still uses it.
  - Rename the save-block bytes to `ds 1`, and replace SRAM Link Battle Data with a `ds $60` placeholder.
  - **Verify the save layout:** diff `.sym` addresses from `wGameData` to `wGameDataEnd`, and every SRAM symbol (banks 00-07, $a000-$bfff), against the baseline. They must be identical.
- **P7, optional.**
  - Prune the VC template, or drop `crystal_vc`.
  - Remove the TrainerRankings stubs, keeping the GS Ball functions.
  - Decide what Pokecenter2F is for (it could host branch 30's NPC).
- **P8, separate project.** Battle Tower de-mobilization (mobile_45/46/5c/5f, home/mobile.asm, hMobile, mobile music). Large and risky; not needed for this goal.

## 5. Interactions with other branches

- **24, move renumbering:** link.asm hard-codes move-ID assumptions: `cp STRUGGLE + 1` "move too new" at 2483, `MOVE_TABLE_MINIMUM_RESERVED_INDEX` at 1447, and Time Capsule compatibility. Renumbering would silently break these, so **do branch 11 first.**
- **39, retire legendaries:** link.asm:2326-2333 hard-codes `MEW`/`CELEBI` and :2445 uses `JOHTO_POKEMON`. Removing those constants would break the link build, so doing 11 first removes the conflict. 39's new signature moves also need Effect Commands ($0D) and Battle Core space, which 11 frees.
- **32, happiness obedience:**
  - `BattleCommand_CheckObedience` (0d:43aa, 322 B) contains the `wLinkMode` guard (effect_commands.asm:622). Its "traded" test is OT-ID based (lines 629-638).
  - With link removed, foreign-OT mons come only from NPC trades, so 32 can simplify or drop the OT gate.
  - It works in bank $0D, which has 41 B free. Branch 11's ~100+ B there is the cushion.
- **49, pseudo-abilities:**
  - The hooks are TryToRunAwayFromBattle (link checks at core.asm 3764, 3881), battle start (DoBattle 25, 95, LoadEnemyMon 6008) and CountStep (events.asm:856).
  - All of them get simpler once link is gone. The battle-start abilities (Intimidate, Frisk, Pressure) need Battle Core bytes, and P3's ~1.3 KB is the main enabler.
  - ROM0 is not needed if the hooks stay banked.
- **30, DV/EV maxing NPC:** no code coupling. Link removal frees no WRAM it needs. The emptied Pokecenter2F, with its 3 receptionist slots, is a natural home for the NPC.

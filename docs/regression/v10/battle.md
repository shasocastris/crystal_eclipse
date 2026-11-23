# v1.0 regression: battle area

HEAD `1fb549fdf` vs v0.9 `2f2a153e6`, debug ROMs, SameBoy harness.
Tests: `docs/regression/harness/v10_battle.py` (suite `v10_battle`, 33 tests).
Evidence: `docs/regression/v10/battle/` (screenshots) and the run reports in `docs/regression/reports/`.

## Tests

| Test | Checks | HEAD | v0.9 | Diff intended? |
|---|---|---|---|---|
| battle_no_switch_prompt | Falkner's 3 mons KO'd with the options byte on Set and on the old Shift value. Watches for YesNoBox, PlaceYesNoBox and OfferSwitch. | pass: no prompt, each next mon sent out, battle ends | fail: Shift prompts on the 1st KO | yes (06e73d29e) |
| battle_options_menu | 7 rows, no BATTLE STYLE. Left/right on each row changes only that row's value line and byte. Cursor wraps after 7. Bit 6 (old BATTLE_SHIFT) is never touched, whichever value it starts at. | pass | fail: BATTLE STYLE listed | yes |
| battle_no_battletype_set_refs | Static scan of the tree and `.sym`: no BATTLETYPE_SET, Shift-mode routines or their text. BATTLE_SHIFT is only defined. No raw numeric battle types. Battle Tower leaves wOptions alone. | pass | fail (50 `loadvar` lines) | yes (21aade23d, d25e6cf57) |
| battle_fae_blade_effects_and_text | 240 seeded trials vs Sentret: outcome shares, the matching status text for each outcome, sleep counter range, statused target always confused, move-animation count | **fail** (2 findings below); texts all correct; statused target 20/20 confused | skip (was Tri Attack) | n/a |
| battle_fae_blade_type_immunity | 90 trials each vs Vulpix, Swinub, Ekans, Magnemite and Clefairy | **fail** (finding below) | skip | n/a |
| battle_life_dew_player | Full HP, user and party statuses cured, LifeDewText shown. Also checks the leftover Toxic flag. | **fail** on the Toxic flag only; everything else OK | fail (½ heal, old text) | yes, except the Toxic flag |
| battle_life_dew_enemy | A trainer's Life Dew heals and cures its own side and OT party, and leaves the player's party statuses alone | pass | fail (½ heal) | yes |
| battle_happiness_catch | Catch: nickname 110, decline 70, blank name 70, Friend Ball + nickname keeps 200, box nickname 110, box decline 70 | pass | fail (nick = 70) | yes (c10552542) |
| battle_happiness_givepoke | GivePoke with the prompt: party and box, nickname and decline | pass | fail | yes |
| battle_happiness_givepoke_scene | Real script: Game Corner Larvitar prize, nicknamed 110, declined 70 | pass | fail | yes |
| battle_happiness_contest | CheckPartyFullAfterContest: party and box, nickname and decline | pass | fail | yes |
| battle_happiness_name_rater | Real Name Rater: 70 becomes 110; 150 stays 150 | pass | fail | yes |
| battle_happiness_npc_trade | Tim's trade: the Voltorb arrives at 70 (no player nickname) | pass | pass | — |
| battle_stats_met_level | Orange page met level for each caught-time value (MORN, DAY, NITE) × level 25/63 | pass | fail: MORN/NITE show 89/127 | yes (a39192467) |
| battle_obedience_text | No text ties obedience to badges, levels or trades. Lines edited in 22d89f4be are ≤18 columns. | **fail** (finding below); edited lines all fit | fail | partly |
| battle_ab_* (16 scenarios) | v0.9 vs HEAD with a deterministic RNG; identical traces required (below) | all identical | — | — |
| battle_ab_determinism | Control: a HEAD trace does not depend on input timing | pass | — | — |
| battle_ab_shift_prompt_v09_control | Control: v0.9 with the Shift byte prompts; HEAD with the same byte does not | pass | — | — |

Eggs: there is no egg or hatch code in this tree, so there is no egg nickname path to test.

## A/B differential (v0.9 vs HEAD)

- **Method.** diff_battle's idea is reworked inside the file:
  - Each tree's debug ROM is copied with `Random` replaced by the seeded LCG, into `scratchpad/roms_det_battle/`.
  - Constants are resolved per tree.
  - Species, move and item runtime IDs are converted back to constants before comparing.
  - Battle text labels are added to each turn's trace.
- **Scenarios, all identical across 1 to 6 seeds:** damage/crit (Slash), speed tie, type matchup, para/sleep, burn/poison, confusion, Quick Claw, Leftovers + Berry, Heal Bell, Baton Pass, voluntary switch, trainer next mon, Falkner AI over 14 turns, trainer KO switch-in, run away, Tri Attack.
- **Conclusion.** No unintended change in ordinary battle mechanics. The trainer KO switch-in traces match too, because the old Set path is what HEAD now always takes.
- **Harness note.** With the LCG, `StartTrainerBattle_SpeckleToBlack` loops forever on HEAD (the LCG never reaches some tiles). The differential skips `DoBattleTransition` with an immediate `ret` in both builds. This is a test artefact, not a game bug.

## Game bugs / findings

1. **Fae Blade confusion replays the whole Fae Blade animation (low, cosmetic).**
   - **Repro:** Fae Blade rolls confusion, or hits a target that already has a status, with Battle Scene ON. Trace: `LoadMoveAnim` runs once more on CONF outcomes than on any other outcome.
   - **Root cause:** `engine/battle/effect_commands.asm:5735`. BattleCommand_FinishConfusingTarget does `cp EFFECT_SWAGGER / call nz, AnimateCurrentMove`, which only skips CONFUSE_HIT, SNORE and SWAGGER. EFFECT_FAE_BLADE falls through and replays the move animation before ANIM_CONFUSED.
   - **Fix:** add `cp EFFECT_FAE_BLADE / jr z, .got_effect` next to the other secondary-confusion effects.
2. **Fae Blade ignores type immunities, but in the wrong direction (low-medium, design).**
   - **Observed:** Fire-type Vulpix was burned (11/90), Ice-type Swinub got frostbite (13/90), Steel/Electric Magnemite was poisoned (16/90). Fairy-type Clefairy can never be burned or frozen (those rolls do nothing). Poison-type Ekans was never poisoned (correct).
   - **Root cause:** BurnTarget and FreezeTarget block on `CheckMoveTypeMatchesTarget` (`effect_commands.asm:3893`, `:3959`), which compares the target's types with the **move's** type (Fairy). It does not compare them with Fire or Ice. PoisonTarget only checks POISON, a vanilla quirk (see the wiki's Twineedle/Steel page).
   - **Fix:** in `BattleCommand_FaeBlade` (`engine/battle/move_effects/signature_moves.asm:86`), check the target's types directly before jumping: Fire → no BRN, Ice → no FRZ, Poison/Steel → no PSN. Either re-roll or fall back to confusion, whichever shasocastris prefers.
3. **Fae Blade's six outcomes are not 1/6 each (medium-low, suspected real).**
   - **Observed:** two runs, 480 seeded trials pooled: FRZ 120 (25%, about 4.9σ high), PSN 22%, CONF 16.9%, PAR 13%, BRN 12%, SLP 10.8%.
   - **Cause:** the first draw is uniform, because the test seeds `hRandomAdd` and `hRandomSub`. The skew comes from the reject loop at `signature_moves.asm:93-97` (`and %111 / cp 6 / jr nc, .loop`). A retry made a few cycles after a 6 or 7 is strongly correlated with it, because `Random` just adds rDIV again, so the rejected quarter of draws lands mostly on FRZ and PSN.
   - **Fix:** `ld a, 6 / call BattleRandomRange` (or the game's equivalent) instead of the mask-and-retry loop.
   - **Caveat:** under real input timing the bias may differ in size. A hand check is cheap: count about 60 Fae Blade outcomes.
4. **Life Dew (and Heal Bell) leave SUBSTATUS_TOXIC set (low, inherited from vanilla).**
   - **Repro:** user badly poisoned (toxic count 5), uses Life Dew; status is cleared but the Toxic bit and the count stay. A later plain Poison Powder then ticks 126/344 (Toxic-scaled, count 6) instead of 43 (1/8).
   - **Root cause:** `engine/battle/move_effects/heal_bell.asm:15` CureUserPartyStatus clears status and Nightmare only.
   - **Fix:** also `res SUBSTATUS_TOXIC` on BATTLE_VARS_SUBSTATUS5 and zero the toxic count, as UseHeldStatusHealingItem does (`core.asm:3950`).
   - **On the brief's question:** apart from this, Life Dew does what its text says. It cures every party status (6/6), heals to full, and a trainer's Life Dew cures only its own side. Text nit: "Its team's status was cured!" is printed even for a wild mon or a team with no status.
5. **Stale obedience text (low, text).** Three NPCs still say badges control obedience:
   - `maps/VioletPokecenter1F.asm:178-189`: "Without the right GYM BADGES, they will just do as they please."
   - `maps/VioletKylesHouse.asm:22-30`: traded mons "may disobey" without the right badge.
   - `maps/IlexForest.asm:789-792`: the apprentice says his boss's mon won't obey him "because I don't have a BADGE". This is arguably flavour, but it contradicts the rules.

   The gym leader and Dragon Shrine speeches edited in 22d89f4be are fine, and every edited line fits 18 columns.

## Aura Sphere 999 in battle_moves.aura_sphere (coordinator question): test artefact

- **Measured** (`scratchpad/dbg_aura2.py`):
  - On HEAD, Aura Sphere is a **critical hit** (`wCriticalHit=1`): damage 999 before STAB/type, 1998 after ×2 SE, 1825 after variation. The enemy is KO'd.
  - On the old-party build the same turn is not a crit (71 damage).
- **Why the crit gets through.** On a crit with equal stat stages, `CheckDamageStatsCritical` (`effect_commands.asm:2665`) returns nc. PlayerAttackDamage then reads the **stage-adjusted copies `wEnemySpDef` / `wEnemyDefense`**, which still hold Sentret's real 10/9. The test only tanks `wEnemyMonStats+2/+8`. Non-crits use those tanked values, which is why the test normally works.
- **Why only the new party crits.** The test doesn't seed the RNG for this case. The new debug party shifts frame timing (fixture state), so this one roll lands a crit. Held item, moves and stats are not involved.
- **The engine is vanilla-correct.** The 999 cap is applied before STAB and type, as in Gen 2.
- **Fix the test:** in `suite_battle_moves.battle()` also write `wEnemyDefense` and `wEnemySpDef` to 999, and use more HP than one capped crit can do. My `tank_enemy()` now does this after hitting the same crit KO, at Fae Blade trial 92.

## Harness notes (not game bugs)
- Trainer battles: `AIChooseMove` runs before the battle menu, so a trainer move must be overridden through `wCurEnemyMove`/`wCurEnemyMoveNum`, as `set_enemy_moves()` does. Setting only `wEnemyMonMoves` is ignored for that turn. `Battle.set_enemy` is wild-only, so it is unaffected.
- `sb_step` can service an interrupt instead of the breakpoint instruction, so a watched PC is hit twice for one call. Text tracing dedupes with `_fresh()`. Shared helpers that count hits should do the same.
- The in-battle yes/no box can need more than one press, so `Inputs` repeats B for "no". `PokeBallEffect` called directly needs a pushed window (`LoadStandardMenuHeader`), or it hits "No windows available for popping".
- v0.9's OfferSwitch uses PlaceYesNoBox, not YesNoBox; the prompt watch covers both.

## Not testable headlessly (for shasocastris's playthrough)
- With Battle Scene ON, Fae Blade's double animation on confusion (finding 1): confirm it looks wrong.
- Options menu look after the row shift: cursor arrow, frame number position, BATTLE SCENE/SOUND text alignment (screenshot `options_menu-head.png` looks right).
- Loading a real v0.9 save whose options had Shift selected. The byte is equivalent to the tested `wOptions` value, but loading a real save was not tested.
- Fae Blade outcome mix under real input timing (finding 3).
- Elm's Travel Tip 5 (ElmsLab.asm has uncommitted local edits in the main repo; the worktree HEAD was used).

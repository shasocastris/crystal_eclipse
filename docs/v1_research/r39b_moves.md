# Branch 39, part B: legendary signature moves, battle engine side

Base: `core` @ 01727c11f. Paths are relative to the repo root. **[inf]** = inferred, not verified.
The maps (crystal_eclipse.map / _debug.map, 20:51) are about 35 min older than HEAD (21:27, the Fast Ball commit), so they are close but not exact.

## 0. Headline findings

1. **The real bank wall is Effect Commands (bank $0d), not Battle Core.** $0d has **$29 = 41 bytes** free in both release and debug (map: "ROMX bank #13"). Battle Core ($0f) has $1b3 in both. Every `BattleCommand_*` must live in $0d, because `DoMove` does `jp hl` into the same bank (effect_commands.asm:95-107).
2. **There is about 390 B of free $0d to recover.** The BEAT_UP *move* was removed on core (6ab3e262a), but its engine code is still there: `BattleCommand_BeatUp`, `BeatUpFailText` and `GetBeatupMonLocation` span sym 0d:54db-564e (= $173 = 371 B), plus five `cp EFFECT_BEAT_UP` sites (effect_commands.asm:2097, 2464, 3614, 5247, 5326), the `BeatUp` script (effects.asm:2059) and its pointer (effects_pointers.asm:156). Delete these first. This is the prerequisite for everything else.
3. **M4 is on core.** `core...68-ow-weather` = 1/0, so the memory note "core 23 behind" is stale. Outdoor battles start with overworld weather for **255 turns** (core.asm:9346-9348, `GetAutomaticBattleWeather .overworld` core.asm:9378-9398).
4. **CONVERSION and CONVERSION2 are still on core** (moves.asm:161, 179). Porygon learns both at L1 (evos_attacks_johto.asm:1593/1595, kanto:2717/2719), and 5 trainer parties use CONVERSION2 (parties.asm:600, 1693, 1752, 3486, 3535). Their command code is another ~254 B of $0d (Conversion 0d:70bc-714a = $8e, Conversion2 0d:5a52-5ac2 = $70).
5. **There are no OHKO moves on core**, but `EFFECT_OHKO`, the `OHKOHit` script (effects.asm:924) and `BattleCommand_OHKO` (effect_commands.asm:5434) all survive. Sheer Cold can reuse them directly.
6. **`BattleCommand_RadiantStatsBoost` exists** (effect_commands.asm:4629; Radiant Orb, core.asm:471). It gives +6 to Atk/Def/SpA/SpD/Spe/Eva but not accuracy. It is also flawed for reuse: `RaiseStat` aborts once `wAttackMissed` is set (effect_commands.asm:4153), so one stat already at max blocks all later ones.

## 1. Per-move status today

The core `move` macro has **no name argument** (moves.asm:3-11). The name sits in the trailing comment. The spec's `EFFECT_FLINCH` is core's `EFFECT_FLINCH_HIT`. `EFFECT_ACC_DOWN_2_HIT` does not exist.

| Move | Constant on core | Current data | Learned by / used by |
|---|---|---|---|
| SHEER_COLD | **none** | — | — |
| INNER_LIGHT | **none** | — | — |
| SKY_ATTACK | $8f (move_constants.asm:132) | EFFECT_SKY_ATTACK (2-turn charge), 140 FLYING PHYS, 90%, 5 PP, 0% (moves.asm:149) | Hoothoot L47, Noctowl L58, Murkrow L51, Skarmory L53 (johto:351/373/996/1496), Moltres L73 (kanto:2887). Explicit parties: Falkner Pidgeot (parties.asm:54), Brock Aerodactyl (454), Lance Aerodactyl (1154), Dana Skarmory ×2 (2578/2591), Ryan Skarmory (2702), Battle Tower Moltres (battle_tower/parties.asm:3734). Auto-fill NORMAL parties **[inf: auto-fill uses the last 4 learnset moves at or below the level]**: Bird Keeper 8/11/15/16 Noctowl L64-72, BK 14 Skarmory L55, Biker 3/5/8/9 and GruntF 12 Murkrow L60-68 |
| ERUPTION | **none** | — | — |
| STORM_CALL | **none** | — | — |
| LIFE_DEW | **none** | — | — |
| AEROBLAST | $b1 (:158) | NORMAL_HIT 100 DRAGON SPEC 100% 5 PP (moves.asm:180); high crit (critical_hit_moves.asm:6) | Lugia L22 (johto:1865); AI encore list (encore_moves.asm:25) |
| SACRED_FIRE | $dd (:198) | EFFECT_SACRED_FIRE 100 FIRE PHYS 100% 5 PP 50% (moves.asm:220) | Entei L91 (johto:1784), Ho-Oh L22 (johto:1879); AI sunny_day_moves.asm:11 |
| AURA_SPHERE | $11f (:263) | ALWAYS_HIT 80 FIGHTING SPEC 100% 20 PP (moves.asm:285); anim is a ZapCannon placeholder (animations_gen2.asm:114) | **Only Blissey L63** (johto:1752). Auto-fill: Lass 11 Blissey L68 (parties.asm:2536), Teacher 1 Blissey L65 (4171) |
| FAE_BLADE | **none** | — | — |

None of these appear in the safari tutor table, TM/HM/MT, or egg moves. Egg moves were merged into learnsets (df24078dd).

**AURA_SPHERE recommendation:** redefine it in place rather than split. Only Blissey (plus 2 auto-fill trainers) is affected. Swap Blissey's L63 slot for something on-theme (DAZZLING_GLEAM, or drop it). A split would cost a new move slot: about 6 B data, ~12 name, ~37 description, 3 anim. It is only worth it if a common 80-BP never-miss Fighting move is wanted elsewhere later. Note the current description line "aura. Never misses." is 19 chars, over the limit (descriptions.asm:1327).

**SKY_ATTACK:** once it becomes the 100-acc, accuracy-drop signature, the 4 johto mons plus 6 explicit parties plus BT Moltres plus ~10 auto-fill parties all change. Pull SKY_ATTACK from those learnsets and parties (branch 61's party workflow), or accept a 140-BP no-charge move on Noctowl and friends. Also consider Entei's L91 SACRED_FIRE → ERUPTION (part A owns the learnsets).

## 2. Building blocks that exist

- **Weather:** `BattleCommand_StartRain`/`StartSun`/`StartSandstorm`/`StartHail` (move_effects/rain_dance.asm, sunny_day.asm, sandstorm.asm, hail.asm). Each one fails when the same weather is already up, sets a count of 5 (8 with the HELD_PROLONG_* item), calls `AnimateCurrentMove`, and prints. **None of them can be reused after a damaging hit**: they would re-animate, and print "But it failed" when the weather already matches.
- **Weather texts:** `DownpourText`, `SunGotBrightText`, `SandstormBrewedText`, `ItStartedToHailText` (data/text/battle.asm:1062/1067/1014/1108, bank $20).
- **Script ordering rules** (verified):
  - `failuretext` jumps to `EndMoveEffect` on a miss (effect_commands.asm FailureText, `jmp nz, EndMoveEffect`).
  - `checkfaint` ends the script if the target faints (its header comment).
  - So any after-hit side effect that must also fire on a KO has to sit **between `supereffectivetext` and `checkfaint`**, which is how `AllUpHit` places `allstatsup` (effects.asm:736).
- **Never-miss:** `cp EFFECT_ALWAYS_HIT / ret z` in CheckHit (effect_commands.asm:1576-1579). It runs after the Fly/Dig miss check, so Swift-style moves still miss a target in mid-Fly or underground. `EFFECT_ALWAYS_HIT` points to `NormalHit` (effects_pointers.asm).
- **Priority:** table `MoveEffectPriorities` (data/moves/effects_priorities.asm), read by `GetMovePriority` (core.asm:955, Battle Core). PRIORITY_HIT = 2, Protect/Endure = 3, BASE = 1 **[inf]**. `EFFECT_PRIORITY_HIT` also points to `NormalHit`.
- **Random status:** `BattleCommand_TriStatusChance` (effect_commands.asm:4746) calls EffectChance itself, then picks PAR/FRZ/BRN at 1/3 each. Note FRZ here deals residual damage (core.asm:1137), Frostbite-like **[inf]**.
- **OHKO:** `BattleCommand_OHKO` (5434). It adds 2×(level difference) to accuracy, fails if the user's level is lower or the type modifier is 0, and then sets the damage to $ffff.
- **Heal / Heal Bell:** `BattleCommand_Heal` (6045) restores 50% (full for REST) and prints "HP is full" plus a failed animation at full HP, but does **not** end the script. `BattleCommand_HealBell` (move_effects/heal_bell.asm) clears both party structs' status and nightmare, then recalculates stats.
- **Accuracy down:** `BattleCommand_AccuracyDown2` (4317) honors `wEffectFailed` and `wAttackMissed`. `CheckMist` only covers the effect ranges (4428-4447), so a new effect appended at the end would ignore Mist (a minor quirk).

## 3. Effect designs (default interpretation; open questions in §6)

Shared new command **`signatureweather`**, one command for 5 effects. Logic:
- Look up `BATTLE_VARS_MOVE_EFFECT` in a 5-row table (`IsInArray`, rows of effect, weather, text pointer).
- If `wBattleWeather` already equals the target weather, **`ret` silently**. This matters: re-setting would shrink an overworld 255-turn weather to 5.
- Otherwise set the weather, set the count to 5, and print the matching text via `StdBattleTextbox`.
- No animation and no wEffectFailed check, so Sacred Fire's 50% applies only to the burn.
- Cost: ~58 B in $0d, +~15 B for prolong-item support, +2 B pointer in Battle Core.
- Place it before `checkfaint`.

1. **AEROBLAST**: `EFFECT_FLINCH_HIT, 140, DRAGON, SPECIAL, 100, 10, 50`. Pure data. Keep the high-crit entry? (Default: keep.)
2. **FAE_BLADE**: default is `EFFECT_TRI_ATTACK` at 100%, with **no new effect** (or `EFFECT_FAE_BLADE` pointing to `TriAttack`, 2 B). A "true random" version (PSN/BRN/FRZ/PAR/SLP; maybe confuse) needs a new command, ~25-30 B in $0d.
3. **SKY_ATTACK**: new `EFFECT_ACCURACY_DOWN_2_HIT` → new script = a copy of `AccuracyDownHit` with `accuracydown2` (~22 B bank 9 + 2 B pointer). `EFFECT_SKY_ATTACK` is then orphaned. Optional cleanup:
   - its references: `.continuousmoves` (effect_commands.asm:1051), the charge check (1894), `.move_messages` SKY_ATTACK (5596), sleep_talk.asm:129, and the `SkyAttack` script (effects.asm:1077);
   - this frees ~10 B in $0d and ~24 B in bank 9;
   - keep the `charge` command, which Razor Wind, Skull Bash and SolarBeam still use.
4. **LIFE_DEW**: script `checkobedience, usedmovetext, doturn, heal, healbell, endmove`. **0 B new code**, ~6 B script + 2 B pointer. It shows two animations and, at full HP, prints "HP is full" before the bell. Polishing that needs a ~15 B wrapper command.
5. **AURA_SPHERE**: `EFFECT_AURA_SPHERE` → `NormalHit`. Add `cp EFFECT_AURA_SPHERE / ret z` next to effect_commands.asm:1578 (3 B $0d), and `db EFFECT_AURA_SPHERE, 2` in effects_priorities.asm (2 B $0f).
6. **SACRED_FIRE**: edit the existing `SacredFire` script (effects.asm:1693). Insert `signatureweather` after `defrost`, before `checkfaint` (+1 B), and change the data to 140 BP / 10 PP. The sun lands after the hit, so it boosts the *next* Fire move.
7. **ERUPTION**: `EFFECT_ERUPTION`, script = NormalHit plus `signatureweather` (~19 B + 2). Fixed 140 by default. HP scaling (power = max(1, 140·HP/MaxHP)) would need a pre-`damagecalc` command, ~35 B $0d. **Ground type**: Flying targets are immune, so they get no sandstorm.
8. **STORM_CALL**: same shape as Eruption with rain. Ground targets are immune, so no rain.
9. **SHEER_COLD**: `EFFECT_SHEER_COLD`, script = `OHKOHit` with `signatureweather` before `checkfaint` (~14 B + 2). A failed OHKO skips the hail, because failuretext ends the script. At 100% base accuracy, the OHKO lands on every target of equal or lower level that isn't immune: a once-per-battle guaranteed KO. **Use power 1, not 0**, as vanilla OHKO moves did. AI_Offensive and menus treat power 0 as a status move **[inf]**.
10. **INNER_LIGHT**: new command `innerlight`, ~60 B $0d:
    - get the user's `w{Player,Enemy}StatLevels` (7 = NUM_LEVEL_STATS bytes);
    - for each one not already at MAX_STAT_LEVEL (13), write 13 and count it;
    - if the count is 0, `AnimateFailedMove`/`PrintButItFailed`;
    - otherwise `AnimateCurrentMove`, `Calc{Player,Enemy}Stats` (the 999 cap is handled there **[inf]**), and print a new `InnerLightText` (~30 B in bank $20, which has $ed free).
    
    This is cheaper and more correct than chaining 21 `*Up2` calls the way RadiantStatsBoost does. Baton Pass will pass +6 in everything.

## 4. AI, animations, descriptions

**AI** (scoring in "Enemy Trainers" bank $0e, $e74 free; redundant.asm in bankB $0b):
- SHEER_COLD:
  - `db EFFECT_SHEER_COLD` in risky_effects.asm (1 B);
  - `dbw EFFECT_SHEER_COLD, AI_Smart_Ohko` (scoring.asm:309 table, 3 B). AI_Smart_Ohko is at scoring.asm:985.
- LIFE_DEW:
  - `dbw → AI_Smart_Heal` (3 B);
  - redundant.asm `dbw EFFECT_LIFE_DEW, .Heal` (3 B). AI_Smart_HealBell's logic is ignored.
- AURA_SPHERE: `dbw → AI_Smart_PriorityHit` (scoring.asm:1646, 3 B).
- INNER_LIGHT:
  - redundant entry: all 7 stat levels at 13 = redundant (~15 B $0b);
  - smart handler: encourage on turn 1 / at high HP (~10-15 B $0e). AI_Setup's range checks (scoring.asm:69+) won't see a new effect.
- Weather hitters need nothing. Optional: add STORM_CALL to rain_dance_moves.asm, and keep SACRED_FIRE in sunny_day_moves.asm.

**Animations:** `anim_ptr` is 3 B and cross-bank (animation_pointers.asm:1-9). The Gen2 table is in bank $11 ($366 free). Placeholders:

| Move | Placeholder |
|---|---|
| SHEER_COLD | BattleAnim_Blizzard (gen1) |
| INNER_LIGHT | BattleAnim_Flash or PsychUp |
| ERUPTION | BattleAnim_FireBlast or Magnitude |
| STORM_CALL | BattleAnim_Thunder |
| LIFE_DEW | BattleAnim_Moonlight or HealBell |
| FAE_BLADE | BattleAnim_PlayRough |
| AURA_SPHERE | keep ZapCannon (or Dazzling Gleam) |

Optional: play the weather anim inside `signatureweather` (~6 B).

**Descriptions** (bank $0b, $317 free release / $371 debug). Format is `db "line1"` / `line "line2@"` with **≤18 chars per line** (descriptions.asm:788-790). Drafts, all counted ≤18:

| Move | Line 1 | Line 2 |
|---|---|---|
| SHEER_COLD | "A one-hit KO that" | "brings hail." |
| INNER_LIGHT | "Raises all stats" | "to the maximum." |
| SKY_ATTACK | "Sharply cuts the" | "foe's accuracy." |
| ERUPTION | "A fiery quake that" | "whips up sand." |
| STORM_CALL | "Calls lightning" | "and summons rain." |
| LIFE_DEW | "Heals 1/2 HP and" | "cures the party." |
| AEROBLAST | "A vacuum blast" | "that may flinch." |
| SACRED_FIRE | "May burn the foe." | "Makes it sunny." |
| AURA_SPHERE | "Strikes first and" | "never misses." |
| FAE_BLADE | "A fey slash that" | "inflicts status." |

**Per new move data** (6 new: SHEER_COLD, INNER_LIGHT, ERUPTION, STORM_CALL, LIFE_DEW, FAE_BLADE):
- each one gets moves.asm 6 B ("Moves Gen 2", floating, currently in bank 9), a name ~12 B (bank $72, $eba free), a description pointer + text ~37 B, and an anim pointer 3 B;
- append them after HURRICANE ($128), keeping names, descriptions, animations_gen2 and moves in the same order;
- ~350 B total, none of it in $0d or $0f.

**Bank 9** (MoveEffects scripts in the fixed "bank9" section) shows 2 B free. The floating sections there ("Moves Gen 2" $2dc, "Battle Weather Images" $100, BattleAnimFunc_Egg/Shake) will be relocated by rgblink as "bank9" grows **[inf: layout.link pins only "bank9" itself, layout.link:60]**. New scripts total ~80 B.

## 5. Old WIP on `39-make-legendaries-move-tutors`

- `core...39` = 272/2, merge-base 166979472.
- **78fafd342** is fully superseded. It is on core as 630acea0b, which is identical plus HURRICANE (the `git diff 78fafd342 630acea0b` on moves and constants is only the HURRICANE lines). Drop it.
- **76938dda0** ("WIP; need to reduce BATTLE CORE"):
  - adds U_TURN/VOLT_SWITCH (EFFECT_SWITCH_HIT, `BattleCommand_SwitchOut` in a new move_effects/switch_hit.asm, 70 lines);
  - in core.asm, splits `PassedBattleMonEntrance` into `NewMonEntranceSetup` + `SwitchHitEntrance` + `NewMonSendOut`, and inlines `UpdateHPBarBattleHuds` and `LoadBattleMenu2` to save Battle Core bytes;
  - deletes CONVERSION, CONVERSION2 and BEAT_UP (constants, scripts, commands, AI, anims).
  - Conflicts: 19 of its 30 files changed on core since the merge-base (`git diff --stat` merge-base..core): learnsets johto/kanto 1146/1402 lines, trainer parties 438, animations_gen1/2 615/331, descriptions 336, moves/names/constants 77 each, core.asm 61, effect_commands.asm 12.
  - Its constant edits collide head-on: U_TURN takes $128 = HURRICANE, and BEAT_UP's constant is already gone on core. A rebase means resolving nearly every data file by hand.
- **Recommendation: rebuild branch 39 fresh from core; do not rebase or cherry-pick.**
  - Port by hand: switch_hit.asm (almost drop-in), the `SwitchHit` script, the core.asm entrance refactor, and the BeatUp/Conversion removal hunks of effect_commands.asm as a recipe.
  - Battle Core now has $1b3 free, so the old "3 B short" problem is gone **[inf: the refactor's net cost is a few dozen bytes]**.
  - Put U_TURN/VOLT_SWITCH and the CONVERSION removal on their **own branch**; they are not legendary signatures. Removing CONVERSION/2 needs Porygon learnset and party edits plus a decision from shasocastris.
  - Removing move constants shifts every later 16-bit index **[inf: harmless to saves, which store 8-bit runtime IDs plus index tables; verify]**.

## 6. Open questions (default in brackets)

1. SHEER_COLD: is it an OHKO plus hail, with hail only if the OHKO lands? [yes, yes; power 1] Is 100% accuracy intended, since the level bonus makes it near-certain? [ask; suggest 30-50% base] Are Ice-types immune? [no]
2. INNER_LIGHT: +6 to all 7 with no HP cost at 5 PP? [yes per spec] Is it Baton-Passable? [yes]
3. ERUPTION: fixed 140 or HP-scaled? [fixed] The 140 Ground/Electric types make weather fail on immune targets [accepted].
4. Weather timing: after damage, only on a hit, and even when the target faints? [yes / yes / yes] If the field already has the same weather (including 255-turn overworld weather), the move does nothing. A different weather replaces the overworld weather for 5 turns, and when it ends the field goes clear, not back to the overworld weather [accept; reverting would need a saved "base weather" byte and a HandleWeather change in $0f, ~20 B]. Do prolong items apply? [yes, if bytes allow]
5. LIFE_DEW: heal only the user (50%) or the whole party's HP? [user only; party status cure]
6. FAE_BLADE: the Tri Attack 3 statuses or a wider pool with sleep? [Tri Attack; no sleep on a 100% damaging move] Does "auto" also mean never-miss? [no]
7. AEROBLAST: keep the high-crit entry? [keep] Is 50% flinch at 140 BP OK? [spec]
8. AURA_SPHERE: priority 2 like ExtremeSpeed? [yes] Does it still miss Fly/Dig? [yes, like Swift]
9. Should Metronome, Sketch or Mimic be able to call or copy the signatures? [add INNER_LIGHT and SHEER_COLD to metronome_exception_moves.asm]
10. Should Sacred Fire keep thawing the user? [yes, `defrost` stays]

## 7. Implementation order (cheapest, most reuse first)

| # | Step | $0d | $0f | Other |
|---|---|---|---|---|
| 0 | Delete dead BeatUp code (prereq) | **−~390** | −2 (pointer) | −~30 bank 9 |
| 1 | AEROBLAST data and description | 0 | 0 | desc text |
| 2 | FAE_BLADE as EFFECT_TRI_ATTACK 100% | 0 | 0 | ~58 move data |
| 3 | SKY_ATTACK → ACCURACY_DOWN_2_HIT script (+ optional EFFECT_SKY_ATTACK cleanup) | 0 (−10) | 0 | +24 bank 9 |
| 4 | LIFE_DEW heal+healbell script, AI | 0 | 0 | ~8 bank 9, 6 AI |
| 5 | AURA_SPHERE never-miss + priority, Blissey swap | +3 | +2 | 3 AI |
| 6 | `signatureweather` command + SACRED_FIRE | +60-75 | +2 | +1 bank 9 |
| 7 | ERUPTION, STORM_CALL scripts | 0 | 0 | ~42 bank 9 |
| 8 | SHEER_COLD (OHKOHit + weather), AI | 0 | 0 | ~16 bank 9, 4 AI |
| 9 | INNER_LIGHT command, text, AI | +60 | +2 | 30 bank $20, ~28 AI |
| opt | Eruption HP scaling / 5-way Fae Blade | +35 / +30 | +2 each | — |

Net $0d after step 9: about +125 to +200 B of new code against ~430 B available (41 free plus the BeatUp removal). Battle Core: +6 to +10 B of $1b3. Run `utils/optimize.py` before and after; the new code should use `jr`/`jmp` per CLAUDE.md.

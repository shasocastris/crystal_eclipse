# Crystal Eclipse — v1.0 Roadmap

**Scope:** order and approach for branches 11, 24, 30, 32, 39 and 49, the last feature set before v1.0.
**Research:** written 2026-10-23 against `core` @ 01727c11f. The per-branch research reports, with full file:line inventories, are in `docs/v1_research/` (`r11_link.md`, `r24_reorder.md`, `r30_perfect.md`, `r32_obedience.md`, `r39a_legendaries.md`, `r49_abilities.md`, `r_budget.md`). The prototype scripts are there too (`regen_proto.py`, `dump_moves.py`, `happy_sim.py`). **Where this doc and a report disagree, the report was written against the files.**
**Build artifacts used** were from 8569b7acd, one commit behind HEAD (the Fast Ball commit touches only item effects and the flee lists), so bank numbers may be off by a few dozen bytes in banks $07 and $03. Rebuild before trusting a figure within ~50 B. **Optimizer baseline on core:** 161 instances, with no `jmp`→`jr` warnings.

---

## 1. Branch state — every branch gets re-created

| Branch | Commits ahead of core | Behind | Reality |
|---|---|---|---|
| 11-remove-time-capsule-link-capability | 0 | 699 | Placeholder. Its tip is a revert of a failed attempt (§3) |
| 24-reorder-moves | 0 | 618 | Placeholder |
| 30-make-events-to-max-DVs-and-EVs | 0 | 629 | Placeholder |
| 32-add-obedience-checks | 0 | 626 | Placeholder |
| 39-make-legendaries-move-tutors | 2 | 272 | `78fafd342`'s moves were re-landed on core as `630acea0b` and extended with HURRICANE. The only unique work is `76938dda0`: U_TURN/VOLT_SWITCH, `EFFECT_SWITCH_HIT`, and removal of CONVERSION/CONVERSION2 |
| 49-introduce-pseudo-abilities | 1 | 309 | Its one commit is already on core as `64da3b201` |

**Done 2026-10-24:** all six were deleted and re-created from `core` @ 01727c11f, with the same names. The old 39 WIP is kept as the local tag `archive/39-wip-switch-hit` (→ `76938dda0`); port from it with `git show`, not a rebase. `origin/11-…` still points at the old tip, which is an ancestor of core, so pushing the new 11 fast-forwards it.

Stale facts this research corrected:
- The memory note for branch 39 says Battle Core is 3 bytes short. That is no longer true: core's Battle Core has **$1b3 (435) B free**.
- There are **263 moves** (`NUM_ATTACKS = $107`). The hex comments in `constants/move_constants.asm` are stale vanilla IDs.

---

## 2. Order and why

| # | Branch | Why here |
|---|---|---|
| **V0** | **72 — fix found bugs** | **BUILT 2026-10-24 (`4d064f0f6`)**, not yet play-tested or merged. Fixes the friendship-endure thresholds, the hail AI list (`db`→`dw`), the Bad Egg's move byte, the dead battle-type check in `ChooseWildEncounter`, and the restaurant's stray `.BuffHappiness` |
| **V1** | **11 — remove link** | It frees the space everyone else needs: ROM0 +650–700 B (about 3× today's 223 B release / 194 B debug), Battle Core +1.3–1.6 KB, Effect Commands $0d +100–150 B (which has **41 B** today), and HRAM +5 B. It also deletes the only code that blocks the others: `link.asm:2326` names MEW/CELEBI (so 39 can't build until it's gone) and `link.asm:2483` checks `cp STRUGGLE + 1` (24 would break it silently). |
| **V2** | **39 — legendaries become tutors + signature moves** | It changes the move set (10 new or redefined moves, CONVERSION removed, U_TURN/VOLT_SWITCH) and decides which type each move sorts into. 24 must not run before the move list is final. |
| **V3** | **24 — reorder moves by type** | Fully scripted, and verified by a ROM dump diff. Running it on the final move list means it only runs once. This is the save break (§8). |
| **V4** | **49 — pseudo-abilities** | **SHELVED 2026-10-25** (shasocastris): scope undecided; branch deleted, `docs/pseudo_abilities.md` left as is. Was: needs the final species roster from 39 (Pressure loses 8 of its 9 members). The infrastructure costs 0 ROM0 and about 30 B of Battle Core. |
| **V5** | **32 — happiness obedience** | Lives in bank $0d, which only 11 makes comfortable. Lands after 39, because 39 may want $0d for `BattleCommand_SwitchOut`. |
| **V6** | **30 — perfect-mon NPC** | Independent and cheap (bank $3F has 9.8 KB free). It goes last because its happiness gate and given happiness depend on 32's thresholds. |

**Moving 30 and 32 earlier:** both are independent of the move work and could happen any time after 11, for example as a palate cleanser between 39A and 39B. The only hard constraints are **11 before 39, 39 before 24, and 39 before 49's Pressure list.**

### V1.5 — Move-data relocation pass (blocking for 39B) **[from `r_budget.md`]**

**DONE 2026-10-24 on `73-move-data-relocation` (`9837a916a`). No relocation was needed.**
- Move data, animation pointers and animation scripts all sit behind indirect tables that store a bank per segment, in floating sections. rgblink moves them when a bank fills.
- Stress test, both ROMs linked: +144 B move data, +800 B animations, +300 B effect scripts, +450 B Effect Commands, +200 B names, +600 B descriptions, +40 B command pointers, +100 B battle text. "Moves Gen 1" moved itself from $09 to $0a.
- The dead Beat Up engine was removed. Effect Commands went from 16205 to 15777 B, so **$0d now has ~607 B of headroom**. Move dump is identical apart from the effect-ID renumber.
- **New tight spot: bank $20.** Battle text shares it with the pinned "Enemy Trainer Parties 2" and has only **304 B free in release and 277 B in debug**. Keep 39B's new battle text small, or move text out.
Adding moves is blocked by full banks:
- A new move needs 6 B of move data in $09/$07 (2–3 B free) and 3 B of anim pointer in $01 (6 B release, **1 B debug**).
- An effect script needs room in $09 (2 B free).
- New specials need room in $03 (0 B; mobile5C frees about 1 KB there in V1).

Before 39B:
- First try just building. `layout.link:60` pins only the "bank9" section, so rgblink *may* push the floating "Moves Gen 2" ($2dc), "Battle Weather Images" and anim-function sections out of bank 9 on its own [inferred].
- If it can't, or $01's anim-pointer table overflows in debug, give `Moves::` and `BattleAnimations::` a third segment in a roomy bank ($47, $45, $78…).
- Move the effect scripts and their pointer table out of $09 if needed. They are read by bank reference.
- New battle commands dispatch via `jp hl` from $0d, so each handler is a ~4 B farcall stub there plus 2 B in `BattleCommandPointers` ($0f).

Verify with an empty `dump_moves.py` diff.

**Order disagreement, resolved:** the budget audit suggests running 24 before 39, and the reorder research says 39 first. **This doc keeps 39 → 24**: renumbering once, on the final move list, avoids a script re-run and the rebase conflicts the audit itself flags. The cost is nil, because the save break is declared anyway (§9).

**Merge discipline:** same as the M-series. Merge each branch to `core` before stacking the next, and never keep more than two unmerged. `68-ow-weather` and `69`–`71` are all merged into core (checked 2026-10-23). Old notes saying core is behind 68 are out of date. Only 15, 39, 49 and gen3 are unmerged, and gen3 is diverged and can be ignored.

---

## 3. V1 — Branch 11: remove link, Time Capsule, Mystery Gift and mobile

**Already gone:** the TradeCenter, Colosseum and TimeCapsule maps (`7957acd8f`; Pokecenter2F is a 38-line stub), trade evolutions, the infrared Mystery Gift engine, printing, and `link_result.asm`.

**Why the first attempt was reverted:** it deleted files before moving out the parts live code still needed:
- `trade_animation.asm`, included from `link.asm:2421` and used by the NPC trades
- `TryQuickSave`, used by the Battle Tower and the Vermilion gift house
- `InitList`, used by the intro menu
- `PlaceWaitingText`, `LinkTransfer` and `LinkDataReceived`, used by `core.asm`
- two predefs and the specials table

**The fix is ordering:** move the keepers, then cut the callers, then delete.

### Phases (keep the build green after each)
1. Re-create the branch. Snapshot `optimize.py` output, the `.sym` addresses for `wGameData`..`wGameDataEnd`, and every SRAM symbol.
2. **Relocate the keepers:**
   - `trade_animation.asm` (3,096 B, self-contained) gets its own include. Keep the `wLinkPlayer*` and trademon WRAM it uses.
   - Move `TryQuickSave`, `InitList`, and the GS Ball flag routines in `mobile_41`.
3. Remove the 17 link specials and the link-record code.
4. **Battle engine (biggest gain, biggest risk):**
   - Remove the 19 `wLinkMode` checks.
   - Remove the 23 `hSerialConnectionStatus` reads that choose a "player 2" path. That path is dead in single player, because the status is always $ff.
   - Delete the link-only routines (841 B).
   - **Keep the real speed-order paths.** Delete only the arm that is impossible.
5. Clean up home, overworld and menus:
   - `BattleRandom` becomes a second label on `Random`.
   - Remove the link checks in text, joypad and gfx.
6. Delete the link files and `home/serial.asm` (526 B of ROM0). Point the serial vector at `reti` and drop `IE_SERIAL` from `IE_DEFAULT`.
7. **RAM and constants — keep the save layout:**
   - The five link/mobile bytes inside saved player data (`ram/wram.asm` ~2733-2735, 2809, 2887) become `ds 1`, following the `wValenciaPortSceneID` precedent.
   - SRAM "Link Battle Data" ($60) becomes `ds $60`, so Hall of Fame, the GS Ball flag and Battle Tower data don't move.
8. Optional:
   - Remove the ranking stubs.
   - The VC patch is already broken (`vc/crystal_eclipse.patch.template` doesn't exist, and 6 of its hooks point at removed symbols). Prune it or note it.
   - Untangling the Battle Tower from `mobile/*` is a separate project. Don't start it here.

### Verify
- Both ROMs build, with no new `optimize.py` warnings. Expect to fold in new `jp`→`jr` warnings as code shrinks.
- `TradeAnimation`, `TryQuickSave` and `InitList` are still in the `.sym`.
- **The saved WRAM and SRAM symbol addresses match the snapshot exactly.**
- Play-test: an NPC trade, the Battle Tower, the gift house, save and load, and battles that use Baton Pass, Beat Up, Thief, Sketch, running, and switching.

---

## 4. V2 — Branch 39: legendaries become move tutors

Split into **39A (world and species)** and **39B (battle engine)** as sub-branches. 39B can land first: the moves exist before anyone teaches them, and the debug build can teach them.

### 4.1 39A — retire 10 deities, Mewtwo stays

**BUILT 2026-10-25 on `39-make-legendaries-move-tutors` (`378ce8d8d`, `a38f949df`). Not play-tested.** P1–P7 are done; P8 (trial battle) is not.
- `DeityTutorScript` (std) + `DeityMoveTutor` / `GetDeityMove` specials; table `data/events/deity_tutor_moves.asm`.
- Raikou (Burned Tower B1F) and Entei (Dark Cave Blackthorn entrance) are statics after the first E4 win (`f8b0dc565`). Mew is in Shamouti Cave (E4 rematch). The roam code and `RoamingBeastScript` hooks stay for later, but nothing calls `InitRoamMons`.
- `BeastsCheck` reads EVENT_FOUGHT_SUICUNE/RAIKOU/ENTEI; Tin Tower 1F uses checkevent on the latter two.
- Celebi changes nothing until it teaches; a failed try keeps the GS Ball.
- Left alone: the deities' own learnsets (unobtainable), BATTLETYPE_SUICUNE/CELEBI battle-side checks (dead but harmless).

**Decision: keep the species data and make them unobtainable. Do not delete them.** Deleting would:
- shift every species index after ARTICUNO ($90), which the save stores in `sPokemonIndexTable`
- shrink the saved Pokédex flag arrays
- touch about 20 parallel tables
- lose the front pics that `pokepic` needs and the overworld sprites that six of them use

No other legendaries or mythicals exist. None of the ten appears in any wild table (Johto, Kanto, Orange, seasonal, swarm, fish, headbutt, Bug Contest).

**Encounter pattern** (all existing commands):
1. object sprite and `cry`
2. `pokepic` / `closepokepic` (see `PokemonMansion.asm:35-39`)
3. optionally `special ShowPokedexEntry`, which marks it as seen
4. teach the move
5. on success only: `setevent EVENT_FOUGHT_X` and `disappear`

**Zero new event flags:** reuse each deity's FOUGHT and hide flags. The gym-rematch gates on those flags (Falkner, Misty, Morty) keep working.

**Tutor engine:** `MoveTutorNoCheck` (`engine/events/move_tutor.asm:91`) is already a special and is unused. It is a ready-made "pick a mon, teach the move loaded by `loadmoveindex`" flow. Copy only the Safari tutor's structure (the submenu render layer, the result codes). Its species tables don't apply.

**Must-fix inventory** (full list in `r39a_legendaries.md`):
- **`BeastsCheck`** (`engine/pokemon/search_owned.asm:1`) requires owning Raikou, Entei and Suicune for the Rainbow Wing. It is called from `TinTower1F.asm:41` and `CeladonPokecenter1F.asm:33`, and there are related `MonCheck`s at `TinTower1F.asm:56,65,94,107` and `CeladonPokecenter1F.asm:30`. **Without a fix, Ho-Oh becomes unreachable.** Rewrite it as "met all three": Suicune via `EVENT_FOUGHT_SUICUNE`, and Raikou/Entei via their roam data cleared after `EVENT_RELEASED_THE_BEASTS`.
- **Battle Tower:** 5 legendary entries (`data/battle_tower/parties.asm:2274,2412,2553,3085,3732`).
- **Type lists:** MOLTRES at `data/types/pokemon_type_lists.asm:275` would make Fire type completion impossible.
- **Diploma:** `CeladonMansion3F.asm:17` `ifless 3` becomes `ifless 11`, per r39a. Confirm what the 3 counts before changing it.
- **Celebi:** `CheckCaughtCelebi` gates Kurt's scene at `IlexForest.asm:491`. Show Kurt unconditionally and rewrite his "caught Celebi" text.
- **Roamers:** keep the roam system. In `RandomEncounter` (`engine/overworld/events.asm:1141-1161`), a roaming battle type runs a shared tutor script instead of `WildBattleScript`. On success it clears the roamer the way a catch does; on cancel the beast flees.
- **Mewtwo:** stays at `PokemonMansion.asm:42`. Its hide flag is temporary and resets when the map reloads, so move it to the vestigial `EVENT_TOHJO_FALLS_MEWTWO`.
- **Seasonal Pokémon plan:** it moves Mew to the Orange Islands on `EVENT_FOUGHT_MEW`. Keep the location, make it a tutor, and drop its "Mythical: Mew" catch line from `docs/seasonal_pokemon_implementation_context.md`.
- **Safe as they are:** the Suicune chase scenes and the Ruins of Alph Clear Bell scene are sprites and cries only. `HoOhChamber`'s wall special is never called.

**Phases:**

| Phase | Content |
|---|---|
| P0 | Branch from core, after V1 |
| P1 | Data cleanup: Battle Tower, type list, diploma |
| P2 | Tutor special |
| P3 | Five simple statics: the birds, Lugia, Mew |
| P4 | Tin Tower and the new `BeastsCheck` |
| P5 | Roamers |
| P6 | Celebi and Kurt |
| P7 | Text pass, 18-character lines |
| P8 | Optional "trial" battle with balls blocked. Keep its checks out of Battle Core |

**Verify:**
- Grep checks: none of the ten is still in a wild battle, a party or a type list.
- The event-flag count is unchanged.
- A Python model of the new `BeastsCheck`.
- shasocastris play-tests each scene.

### 4.2 39B — signature moves and the battle engine *(detail: `r39b_moves.md`)*

**BUILT 2026-10-24 on `39-make-legendaries-move-tutors` (`cee53beda`, `8a0e54fbc`). Not play-tested.**
- All ten moves match the spec. The new commands are `signatureweather`, `innerlight` and `lifedew`.
- SKY_ATTACK reuses the EFFECT_SKY_ATTACK slot as EFFECT_ACCURACY_DOWN_2_HIT, so Mist covers it. Its charge code is gone.
- Metronome and Sketch refuse all ten (`data/moves/signature_moves.asm`).
- Learnsets: Hoothoot and Noctowl get DRILL_PECK; Murkrow and Skarmory drop the slot; Blissey L63 gets DAZZLING_GLEAM. The six explicit SKY_ATTACK parties get DRILL_PECK (Ryan's Skarmory gets STEEL_WING).
- $0d is at 15941 B (~443 B headroom). Bank $20 has 256 B free in debug.
- Still open: real animations; the deity learnsets and Battle Tower Moltres (39A). LIFE_DEW at full HP still cures the party, but only prints "HP is full".

shasocastris's spec:

| Deity | Move | Effect | BP | Type | Category | Acc | PP | Chance | Note |
|---|---|---|---|---|---|---|---|---|---|
| Articuno | SHEER_COLD | new | — | ICE | SPECIAL | 100 | 1 | — | sets hail |
| Zapdos | INNER_LIGHT | new | — | ELECTRIC | STATUS | 100 | 5 | 100 | maxes Atk/Def/SpA/SpD/Spe/Acc/Eva |
| Moltres | SKY_ATTACK | ACC_DOWN_2_HIT | 140 | FLYING | PHYSICAL | 100 | 10 | 100 | redefines an existing move |
| Entei | ERUPTION | new | 140 | GROUND | PHYSICAL | 100 | 10 | — | sets sandstorm |
| Raikou | STORM_CALL | new | 140 | ELECTRIC | SPECIAL | 100 | 10 | — | sets rain |
| Suicune | LIFE_DEW | new | — | WATER | STATUS | 100 | 10 | — | heal 50% + party status cure |
| Lugia | AEROBLAST | FLINCH | 140 | DRAGON | SPECIAL | 100 | 10 | 50 | redefines an existing move |
| Ho-Oh | SACRED_FIRE | new | 140 | FIRE | PHYSICAL | 100 | 10 | 50 | sun + burn; redefines an existing move |
| Mew | AURA_SPHERE | new | 140 | FIGHTING | SPECIAL | 100 | 10 | — | never misses + priority |
| Celebi | FAE_BLADE | new | 140 | FAIRY | PHYSICAL | 100 | 10 | 100 | random status |

Notes on the spec:
- Core's `move` macro has **no name argument**; the name is the trailing comment.
- The spec's `EFFECT_FLINCH` is core's `EFFECT_FLINCH_HIT`.
- `EFFECT_ACC_DOWN_2_HIT` does not exist yet.

#### The wall is bank $0d, not Battle Core
- Every `BattleCommand_*` must live in Effect Commands $0d, because `DoMove` dispatches with `jp hl` into the same bank (`effect_commands.asm:95-107`). That bank has **41 B** free. A command in another bank needs a ~4 B farcall stub in $0d.
- **Step 0 of 39B: delete the dead Beat Up engine code.** The move went in `6ab3e262a`, but `BattleCommand_BeatUp`, `BeatUpFailText` and `GetBeatupMonLocation` are still there (sym `0d:54db-564e`, 371 B). So are five `cp EFFECT_BEAT_UP` checks (`effect_commands.asm:2097, 2464, 3614, 5247, 5326`), the `BeatUp` script (`effects.asm:2059`) and its pointer. That frees **about 390 B of $0d**.
- Removing CONVERSION/CONVERSION2 would free about 254 B more. Both are still on core: Porygon learns them at L1, and 5 trainer parties use CONVERSION2.
- Total new $0d code for all 10 moves is about 125–200 B, against about 430 B available once Beat Up is gone. Battle Core grows by only 6–10 B.

#### What already exists on core
| Move | On core now | Who uses it now |
|---|---|---|
| SKY_ATTACK | $8f, 2-turn charge, 140/90%/5 PP | Hoothoot L47, Noctowl L58, Murkrow L51, Skarmory L53, Moltres L73; 6 explicit parties (Falkner's Pidgeot, Brock's and Lance's Aerodactyl, Dana's and Ryan's Skarmory); Battle Tower Moltres; about 10 auto-filled parties |
| AEROBLAST | $b1, plain hit, 100 Dragon special, high crit | Lugia L22; AI encore list |
| SACRED_FIRE | $dd, EFFECT_SACRED_FIRE 100, 50% burn | Entei L91, Ho-Oh L22; AI sunny-day list |
| AURA_SPHERE | $11f, ALWAYS_HIT 80, 20 PP | **Only Blissey L63**, plus 2 auto-filled Blissey parties (Lass 11, Teacher 1) |
| SHEER_COLD, INNER_LIGHT, ERUPTION, STORM_CALL, LIFE_DEW, FAE_BLADE | none | — |

**AURA_SPHERE: redefine it in place, don't split it.** Only Blissey is affected; give it DAZZLING_GLEAM at L63. Its current description line "aura. Never misses." is 19 characters, already one over the limit.

**SKY_ATTACK:**
- Making it Moltres's signature hands a 140 BP no-charge move to the 4 Johto learners and every party above. The fix is to strip it from those learnsets and parties with the branch-61 party workflow.
- Once SKY_ATTACK stops using it, `EFFECT_SKY_ATTACK` becomes dead code. Removing it frees about 10 B of $0d. The references are at `effect_commands.asm:1051, 1894, 5596` and `sleep_talk.asm:129`, plus the `SkyAttack` script.
- Keep the `charge` command: Razor Wind, Skull Bash and Solar Beam still use it.

#### Building blocks
- **Weather:** `BattleCommand_StartRain`, `StartSun`, `StartSandstorm` and `StartHail` can't follow a damaging hit. They animate a second time and print "But it failed" when the weather matches.
- **New shared command `signatureweather`** (about 58 B in $0d, about 15 B more for prolong items):
  - It looks up the effect in a 5-row table of effect, weather and text.
  - If that weather is already up, it **returns silently**. Setting it again would cut the 255-turn overworld weather (core.asm:9346) down to 5 turns.
  - Otherwise it sets the weather for 5 turns and prints the existing text.
  - It plays no animation and ignores `wEffectFailed`.
- **Script rule:** `failuretext` ends the script on a miss, and `checkfaint` ends it on a KO. A side effect that must fire on a KO goes **between `supereffectivetext` and `checkfaint`**, as `AllUpHit` does at `effects.asm:736`.
- **Reusable as is:**
  - OHKO machinery: `EFFECT_OHKO`, `OHKOHit`, `BattleCommand_OHKO` at :5434. No OHKO move uses it today.
  - Never-miss check: `effect_commands.asm:1576-1579`.
  - Priority table: `data/moves/effects_priorities.asm`. PRIORITY_HIT is 2.
  - Tri-status: `BattleCommand_TriStatusChance` at :4746.
  - Heal at :6045, and `HealBell`.
  - `AccuracyDown2` at :4317.
- **Don't reuse `RadiantStatsBoost`:** it skips accuracy and aborts at the first stat already at max.

#### Per move (cheapest first)
| # | Move | Build | Cost |
|---|---|---|---|
| 0 | — | Delete dead Beat Up code | **−390 B $0d** |
| 1 | AEROBLAST | Data only: `EFFECT_FLINCH_HIT`, 140, 10 PP, 50%. Keep high crit | 0 |
| 2 | FAE_BLADE | `EFFECT_TRI_ATTACK` at 100% (paralysis, freeze or burn) | data only |
| 3 | SKY_ATTACK | New `EFFECT_ACCURACY_DOWN_2_HIT` script, copying `AccuracyDownHit` with `accuracydown2` | +24 B bank 9 |
| 4 | LIFE_DEW | Script `checkobedience, usedmovetext, doturn, heal, healbell, endmove` | ~8 B script. Plays two animations and prints "HP is full" before the bell; a 15 B wrapper fixes both |
| 5 | AURA_SPHERE | `EFFECT_AURA_SPHERE` → `NormalHit`, plus `cp EFFECT_AURA_SPHERE / ret z` next to :1578, plus a priority row (2) | +3 $0d, +2 $0f |
| 6 | SACRED_FIRE | Add `signatureweather` to the existing script after `defrost`; 140 power, 10 PP. Sun lands after the hit | +60–75 $0d |
| 7 | ERUPTION, STORM_CALL | NormalHit + `signatureweather`. A Flying target (Eruption) or Ground target (Storm Call) is immune, so no weather starts | ~42 B bank 9 |
| 8 | SHEER_COLD | `OHKOHit` + `signatureweather` before `checkfaint`. **Use power 1, not 0**, because 0 reads as a status move to the AI and menus | ~16 B bank 9 |
| 9 | INNER_LIGHT | New `innerlight` command: set each of the 7 stat levels below 13 to 13, fail if none changed, then `Calc*Stats` and `InnerLightText` | +60 $0d, ~30 B bank $20 |

Each new move also needs:
- **Data:** 6 B in "Moves Gen 2", a name in bank $72, a description in $0b, and a 3 B anim pointer.
- **Animation placeholder:** SHEER_COLD Blizzard, INNER_LIGHT Flash or Psych Up, ERUPTION Fire Blast, STORM_CALL Thunder, LIFE_DEW Moonlight, FAE_BLADE Play Rough.
- **AI:** SHEER_COLD gets risky-effects + `AI_Smart_Ohko`. LIFE_DEW gets `AI_Smart_Heal` + a redundant-check row. AURA_SPHERE gets `AI_Smart_PriorityHit`. INNER_LIGHT gets an "all at max" redundancy check + a turn-1 bonus.
- **Descriptions:** drafted at 18 characters or fewer in `r39b_moves.md` §4.
- **Metronome:** add INNER_LIGHT and SHEER_COLD to `metronome_exception_moves.asm`.

#### Decisions (shasocastris, 2026-10-24)
**The signature moves are deliberately overpowered, and each can be learned only once per save.** Their spec numbers are final: no nerfs, and no accuracy or PP tuning.

That settles:
1. **SHEER_COLD:** an OHKO that sets hail only if it lands. 100% accuracy stays, even though OHKO's level bonus makes it near-certain. Power is 1 in the data, for the AI and menus.
2. **INNER_LIGHT:** +6 to all 7 stats with no HP cost at 5 PP. Baton Pass can pass it.

These stand as the defaults unless shasocastris objects:

3. **ERUPTION:** fixed 140.
4. **Weather when it ends:** the field goes clear rather than back to the overworld weather.
5. **LIFE_DEW:** heals the user 50% and cures the party's status.
6. **FAE_BLADE:** Tri Attack's three statuses, and it can miss.
7. **AURA_SPHERE:** priority 2, and it misses a target that is mid-Fly or underground, like Swift.

What "once" means for the game:
- If the mon later forgets the move (Move Deleter, or overwriting it), it is gone for that save. The tutor text should warn about this.
- The Metronome exception list should include all ten signature moves, not just two. Otherwise Metronome becomes a back door to them.
- Mimic's copy lasts only for the battle, which is fine. Sketch's copy is permanent, which is a second back door: make Sketch fail on the ten [check during 39B whether Sketch is still obtainable].

#### Old 39 WIP: rebuild, don't rebase
- `78fafd342` is fully superseded by core's `630acea0b`.
- `76938dda0` conflicts in 19 of its 30 files (learnsets, parties, anims and descriptions all moved on), and U_TURN takes `$128`, which is HURRICANE on core.
- **Port it by hand onto its own branch** (call it 39C, or give it a new number): `move_effects/switch_hit.asm` (almost drop-in), the `SwitchHit` script, the `PassedBattleMonEntrance` split, and the Conversion removal as a recipe.
- shasocastris decides whether CONVERSION goes, which affects Porygon's learnset and 5 trainer parties. Its removal is a save break (§9), so land it in the same window as 24.

**Learners (decided):** **any species can learn it, if the chosen mon's happiness is exactly 255.** There is no type gate.
- A new wrapper special (call it `DeityMoveTutor`) runs the party pick. It then checks `MON_HAPPINESS` = 255 on the chosen mon and refuses with text if not. Only then does it hand off to the `MoveTutorNoCheck` teach path.
- Other results: refuse eggs, and refuse if the mon already knows the move.
- The deity's FOUGHT flag and `disappear` fire **only on a successful teach.** Not enough happiness, a cancel, or declining to forget a move all leave the deity in place, and a roamer flees to be met again.
- 255 happiness also clears branch 32's top obedience threshold (220), so a mon that earns a deity move always obeys.
- Reaching 255 is an end-game goal. Walking stops adding happiness at 200, so the last 55 come from level-ups, vitamins and the daily boosts (restaurant, photo, grooming, haircut), or start from a Friend Ball's 200. The 4th stats page shows the number, so players can track it.

---

## 5. V3 — Branch 24: reorder moves by type

**Mechanical, and safe for the bank layout.**

**MERGED to core 2026-10-25 (`840a21c70`, fast-forward).** `docs/v1_research/reorder_moves.py` (uncommitted helper; category then power within a type; writes `; TYPE` markers). The ROM dump diff against core is empty; Battle Core +1 B. Both pre-existing bugs were already fixed on core. Breaks saves.

Only five files are order-dependent:
- `constants/move_constants.asm`
- `data/moves/moves.asm`
- `names.asm`
- the description pointer list
- the `anim_ptr` lists in `animations_gen1.asm` (142 entries from NO_MOVE) and `animations_gen2.asm` (122)

Each animation pointer carries its own bank, so the animation bodies stay put. If the gen1/gen2 split stays at index 141, every section keeps its size; the split becomes just a split point.

Everything else references moves by name: crit list, Metronome exceptions, AI lists, TM/HM/tutor, field moves, trainer and Battle Tower parties, Safari tutor, learnsets. Nothing in `tools/` or `utils/` parses move constants.

**Order:**
- Types in `constants/type_constants.asm` order, with CURSE_TYPE (CURSE alone) between STEEL and FIRE.
- Within a type: category, then power. This is a script option; current order is the alternative.
- NO_MOVE stays 0. STRUGGLE goes last in NORMAL.
- Metronome picks from 1..`NUM_ATTACKS`, so the values must stay gap-free.

**Workflow:**
1. `dump_moves.py core.gbc core.sym > before.txt`. It prints one line per move, keyed by name (effect, BP, type, category, acc, PP, chance, anim label, description), plus the TM, crit, Metronome and AI sets.
2. `docs/v1_research/reorder_moves.py` (not committed) rewrites the five files in lockstep.
3. Build, dump to `after.txt`, and **`diff` must be empty.**
4. Section sizes are unchanged, except +1 B in Battle Core (`core.asm:743`, the KARATE_CHOP `HIGH()` block).
5. No new `optimize.py` warnings.
6. Grep for value-dependent code that the dump can't see: `cp <MOVE> + 1`, `HIGH(` blocks, and `db <MOVE>`.

**Fix in the same branch (pre-existing bugs found):**
- `engine/battle/ai/scoring.asm:2129` `.GoodHailMoves` is `db` but read as words, so it never matches and runs off its end. Make it `dw`.
- `data/pc/bad_egg.asm:5` uses `db KARATE_CHOP` where a runtime ID belongs. It should be NO_MOVE.

**Save impact:**
- Party moves are 8-bit IDs mapped through `sMoveIndexTable`, which saves 16-bit constants.
- Box mons store the constant split into low and high bytes.
- After a renumber, **every saved move silently becomes a different move.** There is no Bad Egg and nothing is detected. See §8.

---

## 6. V4 — Branch 49: pseudo-abilities

Spec: `docs/pseudo_abilities.md`. Stale points the research found:
- **Status never wears off in the overworld.** Early Bird, Limber, Water Veil and Flame Body become "on step tick T, cure status S across the party".
- The 256-step tick lives in `CountStep` (`engine/overworld/events.asm:871-876`, bank $25, 6.6 KB free), not in `StepHappiness` (bank $01, 6 B free).

**Infrastructure (recommended): one ability byte per species in the unused `BASE_FRONTPIC` word.**
- `dw NULL, NULL` sits unread in all 279 base-stats files, so this costs **0 B of ROM and 0 B of WRAM.**
- Every species and variant has its own file, so each new species is forced to choose.
- Read it with a ~20 B helper: `LoadIndirectPointer` on BaseData, then `GetFarByte`. **Not `GetBaseData`**, which overwrites `wCurBaseData` mid-battle.
- Helpers (~100 B, in one ROMX bank such as $22): `GetSpeciesAbility`, `LeadHasAbility`, `PartyHasAbility` and `BattleMonHasAbility`.
- **ROM0 cost: 0.** Battle Core cost is ~30 B total, as 4 B farcall stubs.

**Decision for shasocastris:**
- One byte allows one ability per species. 12 species sit on two or more spec lists (AIPOM on four). Suggested split: AIPOM=Run Away, AMBIPOM=Pickup, GRIMER/MUK=Stench, PONYTA=Run Away, RAPIDASH=Flame Body, LEDYBA line=Early Bird, MURKROW=Compound Eyes, HONCHKROW=Pickup.
- The alternative is a 2-byte bitfield, with the UI showing only the first ability.

**Roster updates:**
- Pressure is left with only Mewtwo after 39. Add AERODACTYL and WEAVILE.
- Canon additions the spec missed: Magmortar, Magby, Slugma and Magcargo (Flame Body); Pupitar (Shed Skin); Houndour line, Natu line, Sunkern line and Kangaskhan (Early Bird); Dunsparce, Caterpie, Weedle and Venonat (Run Away); Growlithe, Ekans line, Tauros, Stantler, Hitmontop and Wyrdeer (Intimidate).
- Variants are typed by their own form. Do not inherit through `GetVariantBase`, or Alolan Vulpix would get Flame Body.
- Full table in `r49_abilities.md` §3.

**Implementation order** (one at a time, per shasocastris's preference):

| # | Item | Hook | Note |
|---|---|---|---|
| 1 | Infrastructure + Orange-page display | Orange stats page, rows 16–17 are free at full width | "ABILITY/" + name; names ≤12 chars; ~220 B in $13 |
| 2 | Stench / Illuminate | `wildmons.asm:227`, `events.asm:1276` | Move `ApplyCleanseTagEffect` into the ability bank. This *frees* ~20 B in $0a, which has 7 B today |
| 3 | Suction Cups | `fish.asm:28-31` | |
| 4 | The five step cures | One table-driven `StepAbilityCures` after `events.asm:876` | Consider the 4-step tick for Flame Body |
| 5 | Pickup | Same tick | |
| 6 | Compound Eyes | `core.asm:6071-6083` | |
| 7 | Arena Trap | `core.asm:888` | |
| 8 | Run Away | After `core.asm:3770` | Copy the Smoke Ball text path; keep scripted no-escape battle types inescapable |
| 9 | Intimidate | Pre-battle filter in `RandomEncounter`, modelled on `CheckRepelEffect` | 0 B in $0f |
| 10 | Frisk | One shared `farcall BattleStartAbilities` at `core.asm:110` | |
| 11 | Pressure | Same | Highest risk (stat-down interacting with Mist and Substitute); last, after 39 |

New battle text should be `text_far` stubs; bank $20 has only 237 B (release) / 210 B (debug).

**Side bug:** in `wildmons.asm:340-344`, a chain of `cp` instructions has no branches between them, so only the last compare has any effect.

---

## 7. V5 — Branch 32: happiness obedience

**MERGED to core 2026-10-25 (`4748aec0e`, fast-forward), not play-tested.** shasocastris's calls: all mons, happiness only (no badges, no OT gate); his formula P(disobey) = (level - cap) / level; Kangaskhan arrives at 220; the Larvitar prize is L25 (happiness unchanged); Mewtwo unchanged. Effect Commands -31 B. Odds: `docs/v1_research/obey_model.py`.

**Spec (shasocastris):** obedience is checked by happiness instead of badges. Level 25 needs 110, level 40 needs 160, and level 55+ needs 220.

**Current routine:** `BattleCommand_CheckObedience` (`engine/battle/effect_commands.asm:603-882`, bank $0d, **41 B free**).
- Gates: enemy turn, charging, already disobeyed, link (:622), Battle Tower, and an OT-ID match (:632-641; the ID only, not the name).
- Then the badge cap (:643-668), followed by the roll: obey with chance cap/(cap+level).
- The outcomes stay as they are.

**Recommended design (defaults; confirm with shasocastris):**
- Applies to **all** player mons. The OT gate goes.
- Below level 25, always obey (**decided**, shasocastris 2026-10-24).
- A step function feeding the existing roll as an obedience cap: happiness ≥220 → no cap; ≥160 → 54; ≥110 → 39; otherwise 24.
- Keep the vanilla probabilistic disobedience below the threshold. It costs no bytes and degrades gently.
- No badge fallback, since traded mons arrive at 70 happiness anyway. Keep the link and Battle Tower skips.
- Remove the dead code at :617-618.
- **Net: about −20 B** in $0d.

**Economy risk (from `happy_sim.py`):**
- Starters only *just* make it: about 222 at level 55, so a few faints push them under.
- Steps cap at 200, so walking alone can never reach 220.
- Everything else starts at 70: a level-30 catch ends at about 112 by level 40 (needs 160) and about 157 by level 55 (needs 220). It needs the daily boosts (restaurant, photo, grooming, haircut) or a Friend Ball (catches at 200; ¥400 at the Azalea and Safari marts).

**Data fixes in this branch:**
- The level-60 Kangaskhan gift arrives at 70 happiness, about 29% obedient, even though the sage demands 220 happiness to hand it over.
- The level-40 Larvitar prize is about 38% obedient.
- The level-100 debug party: set 255, or skip the check under `_DEBUG`.
- Mewtwo (level 70 static) is about 26% obedient; shasocastris decides.
- Consider whether gifts in general should arrive at higher happiness.

**Also fix:**
- Friendship-endure at `effect_commands.asm:2137-2150` uses `jr z` (exact match) where it means `jr nc`. Every player mon gets a 12% endure.
- `OlivineRestaurant.asm:45-49` `.BuffHappiness` passes a RAM address to `GetPokemonIDFromIndex`. Trace this before fixing.

**Verify:** build both ROMs and check that $0d's free space grew by about 20 B. Then a Python model that mirrors the assembly, enumerates all 256 random values, sweeps level 1–100 against happiness 0–255, asserts the always-obey regions, and outputs the odds tables for shasocastris.

---

## 8. V6 — Branch 30: the perfect-mon NPC

**MERGED to core 2026-10-25 (`9a507d462`, fast-forward), not play-tested.** shasocastris's calls: max DVs keeping gender and shininess (non-shiny → Speed 11), 252 EVs in all six, Silver Cave Pokémon Center, one STAR PIECE (GOLD LEAF is unobtainable) once a day. Refuses eggs, Unown and already-perfect mons; no stats box afterwards. Model: `docs/v1_research/perfect_dvs_model.py`.

**Spec (shasocastris):** an NPC turns a Pokémon into a "perfect" Pokémon with max stats.

**Struct:**
- 6 EV bytes (`MAX_EV 252`, `MAX_TOTAL_EV 510`). The caps are enforced only where EVs are gained; `CalcMonStats` doesn't check them.
- 2 DV bytes: Atk|Def and Spd|Spc. The HP DV is derived from the low bits.
- There are no natures. `docs/newbox_format.md` is stale: it still describes stat exp.

**What max DVs (`$FF $FF`) would do here:**
- **Shiny:** `CheckShininess` (`engine/gfx/color.asm:8-38`) makes a mon shiny when all four DVs are 12 or higher. **Every perfected mon would be shiny.**
- **Gender** (Atk, Def and Spc low bits; `mon_stats.asm:124-243`): 50% and 75% female species become male; 12.5% and 25% female species, including the starters and Eevee, become female.
- **Unown:** the letter becomes Z.
- **Hidden Power:** the type becomes Dark (power is fixed at 70).

**Recommended recipe** (shasocastris to confirm):
- Keep gender: try `$FF $FF`, then `$FF $FE`, then `$FE $FF`, and use the first that preserves `GetGender`.
- Keep a non-shiny mon non-shiny by forcing Speed DV 11 (Speed affects neither gender nor Hidden Power, and an odd value keeps HP at 15). This costs about 8 Speed at level 100.
- Refuse Unown and eggs.
- EVs: 252 in all six if "max" is literal. `CalcMonStats` accepts that, and later gains clamp per stat. The alternative is leaving EVs alone.

**Flow:**
- Use the `HaircutOrGrooming` / `MoveDeletion` pattern (`SelectMonFromParty`, then a result in `wScriptVar`). The Safari submenu isn't needed, because nothing follows the selection.
- Two specials in bank $3F (9.8 KB free):
  - `PerfectMonSelect` returns 0 cancel, 1 egg, 2 already perfect, 3 ok.
  - `PerfectMonApply` writes the DVs/EVs, recalculates stats via `RareCandy_StatBooster_GetParameters` + `UpdateStatsAfterItem` (farcall or duplicate), and adds the max-HP difference to current HP only if HP > 0.
- Show the result with the Rare Candy stats box.
- Party only. Box stats are recalculated on withdraw anyway.

**Gating** (defaults):
- A post-game location. Top pick is **SilverCavePokecenter1F** (2 objects); alternatives are Route28SteelWingHouse and the emptied Pokecenter2F after V1.
- A cost (money, or GOLD_LEAF / STAR_PIECE / BIG_PEARL).
- Once per day via the free `ENGINE_UNUSED_FLAG_3..7` in `wDailyFlags3`.
- Optionally require 220 happiness, which ties into 32.
- **Zero new event flags.**

**Event flags are full only at the tail:** a Python count found several hundred unassigned bits in earlier `const_next` blocks (51 at 249-299, 219 at 381-599, 148 at 852-999, and so on). Confirm with a build before relying on it. This also helps 39 if a flag turns out to be needed.

---

## 9. Save compatibility — declare v1.0 a save break

| Branch | Effect on saves |
|---|---|
| 11 | None, **if** the placeholders in §3 phase 7 are kept |
| 39 | Removing CONVERSION/CONVERSION2 shifts move values, which is a break. Keeping the species avoids a species break |
| 24 | Every saved move remaps silently, which is a break |
| 49 | None (ROM data only) |
| 32, 30 | None |

**Core already breaks v0.7 saves.** The M0 reservation and the M1 variant-caught arrays both landed after v0.7 (2026-07-14). `SAVE_CHECK_VALUE_1/2` (`constants/misc_constants.asm:22-23`) is still 99/127, so old saves load as garbage instead of being rejected. **Bump both once, as the last commit before tagging v1.0.**

Also, SRAM banks 4–7 don't exist on this 32 KB cart. The `s5_*` data and Trainer Rankings alias onto SRAM bank 1, on top of the main save. Nothing reachable writes them today; V1 deletes them.

Spare per-mon space: there are 4 spare bytes after the EVs in both the party and box formats. Check that they are zero in existing saves before using them; they are a candidate for a "perfected" marker (30) if one is wanted.

**Recommendation:** v0.5 and v0.7 saves exist in the wild. Announce v1.0 as a fresh-save release and land 39's move removal and 24's renumber back to back. A Python save converter (rewrite `sMoveIndexTable`, its backup, and every newbox move, then recompute the newbox and main checksums) is possible, but only worth building if players ask.

---

## 10. Risk register

| Risk | Branch | Mitigation |
|---|---|---|
| Deleting link code that is still live (repeat of the revert) | 11 | Relocate the keepers first; check the `.sym` for TradeAnimation, TryQuickSave and InitList |
| Save layout shifts while removing link vars | 11 | `ds` placeholders; diff saved-symbol addresses against the snapshot |
| Deleting a real speed-order path along with the dead player-2 arm | 11 | Delete only the arm that is impossible; play-test the move list in §3 |
| Ho-Oh unreachable because of `BeastsCheck` | 39A | P4 rewrite + Python model |
| Fire type completion impossible | 39A | Remove MOLTRES from the type list |
| AURA_SPHERE / SKY_ATTACK redefinitions change existing learners | 39B | AURA_SPHERE: only Blissey, so swap it to DAZZLING_GLEAM. SKY_ATTACK: strip it from 4 learnsets and the listed parties |
| $0d has 41 B | 39B, 32 | Delete dead Beat Up code first (−390 B) |
| $0d contention between 39B and 32 | 39B, 32 | New effect code in $0e or ROMX; $0d gets stubs only |
| A value-dependent move check missed by the reorder | 24 | Run 11 first; grep for `cp`/`HIGH(`/`db`; empty dump diff |
| Silent move remap in old saves | 24 | Declared save break |
| A forgotten variant gets no ability | 49 | Per-file ability byte forces a choice |
| High-level gifts and catches are unusable | 32 | Gift happiness fixes; Friend Ball availability; odds table for shasocastris |
| Every perfected mon turns shiny or changes gender | 30 | Gender/shiny-preserving recipe |

---

## 11. Cadence

- **V1** is the riskiest change to the engine and the most valuable. Take the battle-engine phase slowly and play-test battles before merging.
- **V2** is the content-heavy milestone. Settle the 39B open questions with shasocastris before writing effect code; 39A's scenes are mostly scripting.
- **V3** is an afternoon once the script is promoted. The empty dump diff is the acceptance test.
- **V4** proceeds one ability at a time.
- **V5** and **V6** are each a session.

**Checkpoint before tagging v1.0:** a fresh save played to the Rainbow Wing, a beast tutor, a battle with a level-40 catch to feel the obedience curve, and one perfected mon.

## 12. v0.9 regression pass (2026-10-25/26)

Tagged `v0.9` at `2f2a153e6`, then tested headless on SameBoy. Results and the bugs found are in `docs/regression/results.md`.
- **Seven game bugs.** Four more came from shasocastris's play-test and are fixed in branch 76, merged to core: the bike after door warps, the swapped Fly/Dig moves, the auto-Repel freeze after a save, and Raikou/Entei's blinking sprites. See `docs/regression/results.md`.
  - Refusing Suicune soft-locked Tin Tower 1F. Branch 74 fixed it (`1f371a693`), and it is merged to core.
  - The Battle Tower rules check wrongly refuses some valid teams. The `.isegg` stub from `98812dc12` clobbered `a`. Branch 75 fixed it (`aa180f48e`), merged to core.
  - Completing a Battle Tower streak crashed when the prize was given (`checkmaplockeditems` clobbered the reward; inherited from CSE). Branch 75 fixed it (`d3f3b41da`), merged to core.
- **Passing:** obedience, signature moves, the coach, the deity scenes, NPC trade, the Mystery Gift house, saving and weather. The branch-11 link-removal comparison passes 27/27, and the moved battle animations match frame for frame.

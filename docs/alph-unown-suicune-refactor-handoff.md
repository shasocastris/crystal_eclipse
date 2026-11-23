# Handoff: Alph/Unown Rework and the Unown Reward

**Repo:** `shasocastris/crystal_eclipse` (the Claude Project sync tracks branch `core`; confirm the primary branch before branching — [VERIFY])
**Written:** 2026-11-18 · **Phase:** design settled in outline; the Suicune puzzle itself is NOT designed yet.
**Suggested branch:** `feature/alph-unown-suicune` (one commit per phase below, merge back promptly per the usual per-milestone flow).

## Tag legend

- **[STRUCTURAL]** — a constraint or decision that must hold. Don't re-litigate it.
- **[PLACEHOLDER]** — value, text or design that shasocastris hasn't decided. Stub it with a clearly marked `; TODO(shasocastris):` comment. Do not invent it.
- **[VERIFY]** — an assumption not yet confirmed in the repo. Check before relying on it, and report what you find.

---

## 1. Design summary (decisions shasocastris has made)

1. **Rockets already solved the Alph chamber puzzles.** They have real scientists, not a lone 10-year-old. Because of that, some Rocket members hold Unown.
2. **Unown appear in the story across Johto**, not just in the Ruins:
   - **Slowpoke Well:** Archer's ace (currently a Koffing) becomes Unown A. After beating Archer, the player gets a fight with Unown A and can catch it either way. Kurt remarks that it's a very strange Pokémon he's never seen and that he'll ask his old friend Samuel about it.
   - **Mahogany Rocket hideout:** executives and/or scientists hold more Unown. They can be caught after defeating specific people.
   - **Wild Hunt:** the player faces an Unown whose psychic energy was being used to spur the Tauros on to attack Ecruteak and possibly Olivine.
3. **Ruins of Alph finale** (this arc replaces the Johto Radio Tower plot): Rockets are trying to unlock one *final* puzzle, a new **5th "Suicune puzzle."** The player figures it out. Solving it activates the shrine. Rockets try to take it over, and the final fight happens alongside Suicune (the existing `ShrineFight` scene).
4. **Catching all 26 Unown no longer unlocks the shrine.** Instead, if all 26 are caught by the final fight, Suicune gives the player an **EVIOLITE** on top of the Clear Bell (decided 2026-11-18; replaces the earlier "Suicune joins as a gift" plan).
5. **Tin Tower is unchanged.** Suicune is never gifted, so it stays the only Suicune path and needs no owned-Suicune branch.

## 2. Scope

**In scope for this branch**
- Decouple the shrine/finale from the Unown count (new "puzzle solved" gate with a stub).
- EVIOLITE bonus at the Ruins finale (DONE, `d99103e96`).
- Reusable infrastructure for "Rocket-held Unown" encounters, plus ONE reference placement.
- Recoverability of missed Unown (no permanent missables).
- Dialogue pass on text that still says "catch all 26 to activate the shrine."

**Out of scope (do not do in this branch)**
- Designing or building the Suicune puzzle itself (Phase 6 is a deferred stub).
- Final letter-to-location allocation, prize tuning, Wild Hunt Unown specifics.
- Anything in `engine/battle/core.asm` Unown DV logic or the DV tables in `constants/battle_constants.asm`.
- Trainer rebalancing, stat exp work, seasons/weather/Orange Islands milestones.

## 3. Current state (verified from the synced repo)

**`maps/RuinsOfAlphOutside.asm`**
- `ShrineFight` is a `coord_event` at (7,26) on `SCENE_RUINSOFALPHOUTSIDE_ROCKET_BOSS`. It currently opens with `readvar VAR_UNOWNCOUNT` / `ifequal NUM_UNOWN, .FightExecutives`, else `end`. **This is the all-26 gate to replace.**
- `RuinsOfAlphOutsideShrineCallback` (`MAPCALLBACK_TILES`) does `ifless NUM_UNOWN` → `changeblock 6, 24, $9C`. That is the shrine's visual state, also keyed to the count.
- The finale runs the executive fight (`EXECUTIVEF_2`, `BATTLETYPE_SET`), then sets `EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS`, `EVENT_RUINS_OF_ALPH_RESEARCH_CENTER_ROCKET`, `EVENT_BEAT_ROCKET_EXECUTIVEF_2`, and `setmapscene ICE_PATH_1F, SCENE_ICEPATH1F_RIVAL`. Then Suicune approaches and `verbosegiveitem CLEAR_BELL`, followed by more Suicune movement (the tail of the script was truncated in my view — read it fully).
- A Suicune object already exists at (4,26), hidden via `EVENT_RUINS_OF_ALPH_OUTSIDE_EXECUTIVES`.
- Four scientist trainers outside (Werner, Enrico, Niels, Earnest) gate on `EVENT_MET_ELM_AT_RESEARCH_CENTER` + `EVENT_RUINS_OF_ALPH_ROCKETS`.

**Word rooms (the 26 wandering Unown)** — Kabuto A–K (11), Omanyte L–R (7), Aerodactyl S–W (5), Ho-Oh X–Z (3).
- Each Unown is a `SPRITEMOVEDATA_WANDER` object whose script does: `setevent EVENT_FOUGHT_UNOWN_x` → `loadvar VAR_BATTLETYPE, BATTLETYPE_UNOWN_x` → `loadwildmon UNOWN, 35` → `startbattle` → rock-smash movement → `disappear`.
- **Observed quirk [VERIFY]:** the FOUGHT flag is set *before* the battle and the sprite disappears regardless of outcome. A KO'd or fled Unown looks permanently lost today.

**Battle engine (`engine/battle/core.asm`, `constants/battle_constants.asm`)**
- `BATTLETYPE_UNOWN_A`…`_Z` force specific DVs (`ATKDEFDV_UNOWN_x` / `SPDSPCDV_UNOWN_x`), which deterministically yields the letter.
- After the DVs are set for a wild Unown, the code runs `GetUnownLetter` then `CheckUnownLetter` ("can't use any letters that haven't been unlocked"). On carry it jumps back to `.GenerateDVs` and rerolls. **[VERIFY] what "unlocked" means in this hack.** If it is the vanilla `wUnlockedUnowns` bits set by solving chamber puzzles, then a forced-letter encounter OUTSIDE the Ruins (Slowpoke Well, etc.) would silently reroll to a different letter. See Phase 3.

**Tin Tower / Ecruteak**
- Out of scope now that Suicune is not gifted. `TinTower1FSage6Text2` already says Unown "must be sharing a cooperative bond with SUICUNE"; it still fits the EVIOLITE reward, so keep it.
- **[VERIFY]** still open from the old plan: which event the Ruins finale sets in place of `EVENT_CLEARED_RADIO_TOWER` for `EcruteakTinTowerEntrance`'s Clear Bell gate.

**Other consumers of Alph flags** — do not change *when* these are set:
- `EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS`: hides the chamber Rockets (Kabuto: GruntM12, GruntF6, Erwin; Aerodactyl: GruntM22, GruntF9, Carl) and gates the Radio Tower 5F Director's Whirlpool gift.
- `EVENT_RUINS_OF_ALPH_RESEARCH_CENTER_ROCKET`, `EVENT_ELM_NOT_AT_RUINS_RESEARCH_CENTER`.

**Research Center (`maps/RuinsOfAlphResearchCenter.asm`)**
- Has "caught all the UNOWN" dialogue and the optional Unown Dex gift text. **[VERIFY]** what actually triggers the dex gift (first catch vs. all). Rocket-held Unown caught outside the Ruins must still trigger it correctly.

**Text that is now wrong and needs rewriting:** Elm's `…ElmText_Searching` (Research Center), `ScientistErwinAfterBattleText` (Kabuto chamber), `ScientistCarlAfterBattleText` (Aerodactyl chamber). All say catching all 26 activates the shrine. Boss F's seen-text may also need a light touch.

## 4. Guards against misreading this hack as vanilla

- **[STRUCTURAL] 16-bit species indexes.** Don't use raw species constants where the engine expects an ID. Mirror existing patterns (`loadmonindex` + reserved slots + `MonCheck`, `loadwildmon`).
- **[STRUCTURAL] 16-bit item IDs.** `verbosegiveitem CLEAR_BELL` already works; don't hand-roll item gives.
- **[STRUCTURAL] Event flags.** New flags go where the existing ones live (`constants/event_flags.asm`). Check flag-array capacity and the M0 save-block reservation notes before adding any. Default-hidden objects need an entry in `InitializeEventsScript` (`engine/events/std_scripts.asm`) like the others.
- **[STRUCTURAL] Don't touch the Unown DV tables or letter-forcing logic.** Reuse `BATTLETYPE_UNOWN_x` as-is. Those only apply to **wild** battles; a trainer-owned Unown uses trainer-party DVs, so a trainer's Unown can't be forced to a letter the same way (see Open Decision 6).
- **[STRUCTURAL] Preserve every existing flag's timing** listed in §3 "Other consumers."
- **Style:** match the existing script style (tabs, `opentext`/`writetext`/`waitbutton`/`closetext`, 18-char text lines with `para`/`line`/`cont`). Mark every changed line with an inline `; CHANGED:` comment.
- **Tooling:** RGBDS + `gawk`; the build must pass. If `.claude/agents/` has the script/flag consistency checker, dialogue linter or build automation, run them after each phase.

## 5. Work breakdown

### Phase 0 — Audit only (no edits)
- `grep -rn` for `EVENT_FOUGHT_SUICUNE`, `EVENT_CLEARED_RADIO_TOWER`, `EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS`, `VAR_UNOWNCOUNT`, `NUM_UNOWN`, `EVENT_FOUGHT_UNOWN_`, `MonCheck`, `BeastsCheck`, `CheckUnownLetter`, `wUnlockedUnowns`, `UnownDex`.
- Read the full `ShrineFight` script and the full `TinTower1FSuicuneBattleScript` (both truncated in my view).
- Resolve every [VERIFY] above and report: what sets `VAR_UNOWNCOUNT` (caught vs. seen), what "unlocked" means in `CheckUnownLetter`, the `loadmonindex` slot convention, and which event replaces `EVENT_CLEARED_RADIO_TOWER`.
- **Stop and report before Phase 1.**

### Phase 1 — Decouple the shrine from the Unown count
- **[STRUCTURAL]** Add one new event flag for "Suicune puzzle solved" (**[PLACEHOLDER]** name: e.g. `EVENT_SOLVED_SUICUNE_PUZZLE`).
- `ShrineFight`: replace the `VAR_UNOWNCOUNT == NUM_UNOWN` gate with the new flag. Leave the rest of the scene untouched.
- `RuinsOfAlphOutsideShrineCallback`: key the shrine tile state to the new flag instead of the count.
- **[PLACEHOLDER]** Add a clearly labelled temporary stub that sets the flag (e.g. a statue interaction in the Inner Chamber) so the game stays completable until the real puzzle lands. Mark it `; TEMP STUB — remove when Suicune puzzle is implemented`.

### Phase 2 — EVIOLITE bonus (DONE, `d99103e96`)
Replaces the Suicune gift and the Tin Tower owned-Suicune branch, which are dropped.
- New item `EVIOLITE` ($009A, end of the item pocket). +50% Def/Sp.Def when the holder's species still has an evolution entry (`EvioliteBoost`, both damage routines, before `TruncateHL_BC`). Held, it blocks all evolution in `EvolveAfterBattle`, stones included. A normal held item since 2026-11-23: price 4000, tossable and sellable.
- Ruins finale: after the Clear Bell text, `VAR_UNOWNCOUNT == NUM_UNOWN` → Suicune gives it. Bag full → hidden item ball (`EVENT_RUINS_OF_ALPH_OUTSIDE_EVIOLITE`) appears at (4,26).
- Not play-tested yet.

### Phase 3 — Rocket-held Unown infrastructure + one reference placement
- Build ONE reusable pattern for "post-trainer Unown encounter": after the relevant trainer is beaten, a scripted wild encounter with `BATTLETYPE_UNOWN_x`. Reuse the Ruins word-room script shape rather than inventing a new one.
- **Letter-unlock problem [VERIFY]:** if `CheckUnownLetter` rejects letters not yet "unlocked," a forced-letter encounter outside the Ruins will reroll to the wrong letter. Resolve in the least invasive way (e.g. pre-set the unlock bit for that letter when the Rocket encounter is triggered, consistent with "Rockets already solved the puzzles"). Don't edit the DV tables.
- **[PLACEHOLDER]** Encounter level per location. A level-35 Unown at Slowpoke Well is wrong for the early game; match the surrounding progression.
- Reference placement: **Slowpoke Well / Archer → Unown A**, plus Kurt's reaction line. **[VERIFY]** where Archer actually lives in this repo (only `SlowpokeWellB1F.asm` surfaced in my search; check `SlowpokeWellB2F.asm`) and how Kurt's existing post-Well scene in B1F (`KurtLeaveSlowpokeWellText`) interacts. Kurt's text: **[PLACEHOLDER]** — he mentions asking his old friend Samuel.
- **Do NOT place the other letters.** Mahogany, Wild Hunt and others wait on shasocastris's allocation (Open Decision 1). Leave a table of TODOs.

### Phase 4 — No permanent missables
- Today the chamber wanderers set `EVENT_FOUGHT_UNOWN_x` before the battle and vanish whatever the outcome.
- Goal: any letter the player has not actually caught must be obtainable later. **[PLACEHOLDER]** mechanism (Open Decision 2). Leading option: after the finale, chamber wanderers respawn for letters not in the player's Unown dex.
- **[VERIFY]** how to test "is letter X caught" (the Unown dex array vs. the count variable). If it needs a small new `special`/`callasm`, keep it minimal and mirror existing helpers.
- Rocket-held encounters must use the same per-letter flag so a letter isn't obtainable twice.

### Phase 5 — Dialogue pass
- Rewrite the lines listed in §3 so they say the Rockets already cracked the chamber puzzles and that the last one (the Suicune puzzle) is what's needed. **[PLACEHOLDER]** wording; draft with `; TODO(shasocastris): reword` and keep the 18-char line format. Elm should also hint that Suicune favours those who know every letter (foreshadowing the EVIOLITE).

### Phase 6 — Suicune puzzle (DEFERRED)
- Not implemented here. Leave the Phase 1 stub and a short note describing the hook (`EVENT_SOLVED_SUICUNE_PUZZLE`). Design is a separate brainstorming phase.

## 6. Open decisions for shasocastris

1. **Letter allocation.** Which letters go to which Rocket encounters (Slowpoke Well = A so far), how many stay as chamber wanderers, which letter the Wild Hunt Unown is.
2. **Missable policy.** Respawn mechanism and timing (immediately after the encounter, after the finale, or via Elm).
3. ~~**Prize spec.**~~ Decided: EVIOLITE from Suicune (Phase 2).
4. **Puzzle design.** Where it lives (Inner Chamber vs. a new 5th chamber), mechanic, and where its clues come from. If clues come from the Rocket encounters, they should come from *encountering/defeating* the holder, not from catching the Unown (catching stays the optional bonus).
5. **Shrine visual.** Whether the shrine tile change should happen on puzzle solve or at the finale.
6. **Archer's Unown.** A trainer-party Unown can't be forced to a letter the way wild ones can. Either give that party slot custom DVs, or have Archer not field it and trigger the scripted wild encounter after the battle. Which?
7. **Tin Tower sage text** acknowledging the Bell came from the Ruins (the owned-Suicune flyby is dropped).

## 7. Test matrix (BGB)

| # | Scenario | Expected |
|---|----------|----------|
| 1 | All 26 caught, solve puzzle, finale | Bell + EVIOLITE; shrine active |
| 2 | Same, item pocket full | EVIOLITE item ball appears at (4,26) and can be picked up |
| 3 | <26 caught, solve puzzle, finale | Bell only, no EVIOLITE, Suicune leaves |
| 4 | Any save → Tin Tower | Original Suicune battle at 50; all flags as before |
| 5 | Miss a letter, finish arc | Letter still obtainable afterward (Phase 4) |
| 6 | EVIOLITE held: level up, use a stone, battle | No evolution, stone not consumed; +50% Def/Sp.Def only on a mon that can still evolve |
| 7 | Eusine → Ho-Oh chain | Works once Raikou/Entei are caught and the E4 is beaten |
| 8 | `EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS` consumers | Chamber Rockets vanish; Radio Tower 5F Director still gives Whirlpool |
| 9 | Rocket-held Unown A at Slowpoke Well | Correct letter (not rerolled); Unown dex gift still triggers |

## 8. Kickoff prompt for Claude Code

> Read `alph-unown-suicune-refactor-handoff.md` fully. This repo is a heavily modified pokecrystal (Crystal Eclipse), NOT vanilla: it uses 16-bit species and item indexes, reserved-ID `loadmonindex`/`MonCheck` patterns, and custom Unown battle types. Don't assume vanilla behavior; verify in the repo.
> 1. Create branch `feature/alph-unown-suicune` off the primary branch.
> 2. Do **Phase 0 only** (read-only audit). Report findings for every [VERIFY], then stop and wait for my go-ahead.
> 3. After approval, implement one phase at a time, one commit per phase, running the build and any consistency/dialogue-lint agents each time. Mark edits with `; CHANGED:` comments.
> 4. Never invent [PLACEHOLDER] values. Stub with `; TODO(shasocastris):` and list them in your report.
> 5. Do not implement the Suicune puzzle, do not edit Unown DV tables, and do not change when existing Alph flags are set.

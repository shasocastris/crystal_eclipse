# Safari Zone Move Tutor — Design Context for Crystal Eclipse

This document summarizes design decisions made in a planning conversation for a new
feature: an evolution-line-gated move tutor that teaches the event-distribution movepool
(moves historically distributed on real-world Pokémon Center New York event
Pokémon — see [Bulbapedia's list](https://bulbapedia.bulbagarden.net/wiki/List_of_PCNY_event_Pok%C3%A9mon_distributions_in_Generation_II))
to the matching species in Crystal Eclipse.

Project background: Crystal Eclipse is a pokécrystal disassembly ROM hack, RGBDS-flavored
SM83 assembly, MBC3 mapper. See project knowledge for full project context (type
completion boosts, physical/special split, custom moves, etc.) — this doc covers only
the Safari Zone tutor feature.

---

## 1. Feature summary

A tutor NPC teaches a curated, **one-move-per-species** list of event-distribution moves.
A move for a given species is only offered once **every member of that species'
full evolutionary line** (including branches) has been marked caught in the Pokédex.

Example: to teach Petal Dance to a Pichu, the player must have Pichu, Pikachu, *and*
Raichu all caught — not just own a Pichu.

---

## 2. Reused existing infrastructure

No new low-level primitives are needed — this feature composes things that already
exist in the repo:

| Piece | Location | Role |
|---|---|---|
| `CheckPokedexCaughtFlag` | `engine/battle/type_completion_boosts.asm` | Input `hl` = species index, sets z/nz for caught/not-caught. Originally built for the type-completion damage-boost system; reused as-is here. |
| `ChooseMonToLearnTMHM` | stock pokécrystal (used by `move_tutor.asm`, `move_reminder.asm`) | Standard party/box mon picker. Reused unmodified for species-first flow. |
| `MoveTutor` special / `CheckCanLearnMoveTutorMove` | `engine/events/move_tutor.asm` | Stock teach-the-move flow. Reused for the actual teaching step once gating passes. |
| `ChooseMoveToLearn` / scrolling-menu move list builder | `engine/events/move_reminder.asm` | **Not needed anymore** — see §3, we moved away from a multi-move-per-species design, so no move-selection menu is required. |
| `evos_attacks_kanto.asm` / `evos_attacks_johto.asm` | `data/pokemon/` | Source of truth for evolution chains, used to hand-derive the `PokemonEvoLines` table (see §4). |

---

## 3. Control flow (finalized)

Order of operations, as decided: **talk to tutor → pick Pokémon → check eligibility → teach.**
This is species-first, not move-first, and there is no move-selection menu because each
species has exactly one candidate move.

```
SafariZoneMainOfficeMoveTutorScript:
    faceplayer
    opentext
    writetext SafariZoneMainOfficeMoveTutorIntroText
    yesorno
    iffalse .Refused

    farcall ChooseMonToLearnTMHM      ; standard party/box picker
    jr c, .Cancelled
    ; wCurPartySpecies now set

    callasm GetSafariZoneMoveTutorMove     ; table lookup by species -> move id in wScriptVar, or -1
    ld a, [wScriptVar]
    cp -1
    jr z, .NothingForThisMon          ; this species has no tutor move defined

    callasm CheckLineFullyCaught_ForCurSpecies   ; see §4/§5
    iffalse .LineIncomplete            ; "come back once you've caught the whole family" text

    loadmoveindex ...                  ; move id from the lookup above
    writetext SafariZoneMainOfficeMoveTutorMoveText
    special MoveTutor
    ifequal FALSE, .TeachMove
    sjump .Incompatible
```

Key point: a player with no tutor-eligible species in their party/boxes never sees any
move-related screen at all — `ChooseMonToLearnTMHM` runs first, so there's nothing to
build a list against until a specific mon is chosen.

---

## 4. Data layer

### 4a. `PokemonEvoLines` table — **already drafted**, provided as `evo_lines.asm`

A `LINE_*` → species-list lookup, formatted like the existing `PokemonTypeLists`
convention (`table_width 3`, `db LINE_id : dw pointer`, each pointer leading to a
`dw`-terminated `-1`-sentinel species list).

Scoped to only the ~85 evolutionary lines that actually contain a tutor-listed species
(not the full Pokédex) — see the file for the complete table and inline comments.

**Branching-line design decision (as specified):** branches require **every** branch
member caught, not just the ancestor chain to the target species. This affects:
- Oddish line (Oddish/Gloom/Vileplume **+ Bellossom**)
- Poliwag line (Poliwag/Poliwhirl/Poliwrath **+ Politoed**)
- Eevee line (all 6: Eevee/Vaporeon/Jolteon/Flareon/Espeon/Umbreon)
- Tyrogue line (all 3 evolved forms: Hitmonlee/Hitmonchan/Hitmontop)

**Verification TODO before compiling:**
- Cross-check `HO_OH`, `MEW`, and other Johto-range species constant spellings against
  the actual `constants/pokemon_constants.asm` (only confirmed up to the Chikorita
  range directly in this conversation; `MR__MIME` double-underscore was confirmed).
- Double-check evolution *trigger methods* aren't needed for this table (only species
  *membership* matters for line-completion), but a few third-stage evolutions
  (Machoke→Machamp, Weepinbell→Victreebel, Graveler→Golem, Seadra→Kingdra) were
  inferred as still-present rather than directly confirmed in the searched excerpts —
  low risk, but worth a glance at `evos_attacks_kanto.asm` directly.

### 4b. `SafariZoneMoveTutorMoves` table — **needs to be authored**, single-row-per-species

Originally scoped as multi-row (all Bulbapedia entries per species), but per the
finalized single-move-per-species design, this needs a **curation pass**: for any
species with more than one candidate move in the source list, only one is kept.

Species currently needing a pick (source options in parens):
- Pichu (Dizzy Punch / Petal Dance / Scary Face / Sing)
- Nidoran♀ (Lovely Kiss / Moonlight / Sweet Kiss)
- Nidoran♂ (Lovely Kiss / Morning Sun / Sweet Kiss)
- Poliwag (Growth / Lovely Kiss / Sweet Kiss)
- Snorlax (Lovely Kiss / Splash / Sweet Kiss)
- Cleffa (Petal Dance / Scary Face / Swift)
- Igglybuff (Mimic / Petal Dance / Scary Face)
- Marill (Dizzy Punch / Hydro Pump / Scary Face)
- Bellsprout (Lovely Kiss / Sweet Kiss)
- Yanma (Steel Wing / Sweet Kiss)
- Psyduck (Petal Dance / Tri Attack)
- Magikarp (Bubble / Reversal)
- Lapras (Bite / Future Sight)
- Delibird (Pay Day / Spikes)
- Remoraid (Amnesia / Mist)
- Smoochum (Metronome / Petal Dance)
- Elekid (Dizzy Punch / Pursuit)

Anthropic/Claude has not yet made these picks — this is an open decision for shasocastris,
or Claude Code can propose a shortlist (thematic fit / movepool usefulness) if asked.

Once curated, each row needs: `{species, move, LINE_*}` — the `LINE_*` should just be
the line containing that species, pulled from the table in §4a.

### 4c. Supporting routines — **need to be written**

- `GetSafariZoneMoveTutorMove`: linear scan of `SafariZoneMoveTutorMoves` for `wCurPartySpecies`,
  returns move id (or `-1`) via `wScriptVar`.
- `CheckLineFullyCaught` (or a per-call variant `CheckLineFullyCaught_ForCurSpecies`):
  walks a `PokemonEvoLines` species list through `CheckPokedexCaughtFlag`, sets
  `wScriptVar` TRUE only if every member is caught. Modeled on the existing
  `CheckAllTypeSpeciesCaught`-style routine in `type_completion_boosts.asm`.
  Integrate into scripts via `callasm` + `iffalse`, mirroring the existing
  `.CheckWhitedOut` idiom in `poisonstep.asm`.

---

## 5. NPC / location — **pending final confirmation**

Design goal: tutor character should read as "someone connected to Elm's lab"
(Elm specializes in evolution — thematically he/his team would care about a trainer
completing an evolution line), **without** adding more script weight to `ElmsLab.asm`,
which is already dense.

Precedent already in the repo: `ShowElmTogeticScript` → `ElmGiveMistStoneScript` in
`ElmsLab.asm` is an existing one-off "show Elm an evolved Pokémon, get a reward" beat
(Togepi→Togetic → Mist Stone). The tutor generalizes this same idea into a repeatable
feature, just relocated.

**Two candidate locations identified, low script density confirmed for both:**

- **Elm's House** (`ELMS_HOUSE`, separate map from `ELMS_LAB`, warped to from New Bark
  Town) — Elm's personal residence, distinct from his lab. Content not yet inspected;
  **flagged as the next thing to check** (`maps/ElmsHouse.asm`) before committing.
  Current lean: **preferred option** — ties directly to Elm without being the lab
  itself, and could reuse the existing `ELMSLAB_ELMS_AIDE` character concept
  (currently seen handing out a starting Potion inside the lab) repositioned here as
  "Elm sent his aide to track evolution-line completions."
- **Cherrygrove Pokémon Center 2F ("Communication Center")** — confirmed low NPC count
  in `CherrygrovePokecenter1F.asm` (nurse/fisher/gentleman/teacher only), and the 2F
  room is already narratively gated behind `EVENT_GAVE_MYSTERY_EGG_TO_ELM`, so it's
  already coded as Elm-storyline-adjacent. Alternative if Elm's House turns out to be
  more script-heavy than expected.

**Next step:** inspect `maps/ElmsHouse.asm` directly before finalizing placement.

---

## 6. Files referenced or needed from the repo

Already retrieved/confirmed in this conversation:
- `engine/battle/type_completion_boosts.asm` (`CheckPokedexCaughtFlag`, and the
  `CheckAllTypeSpeciesCaught`-style pattern to model the new line-check routine on)
- `engine/events/move_tutor.asm`, `engine/events/move_reminder.asm` (partial)
- `data/moves/tmhm_moves.asm`, `constants/item_constants.asm` (`add_mt` macro, stock
  tutor slot pattern — ultimately not used, since the final design bypasses the
  TM/HM-style compatibility bitfield entirely in favor of a custom species/move table)
- `maps/GoldenrodCity.asm`, `maps/KurtsHouse.asm` (stock tutor script examples)
- `data/pokemon/evos_attacks_kanto.asm`, `data/pokemon/evos_attacks_johto.asm`
  (evolution chain data, source for `PokemonEvoLines`)
- `data/pokemon/first_stages.asm` (`FirstEvoStages` — confirms base-species groupings)
- `constants/pokemon_constants.asm` (species constants, partial — Kanto range + start
  of Johto confirmed)
- `maps/ElmsLab.asm`, `maps/NewBarkTown.asm`, `maps/CherrygrovePokecenter1F.asm`,
  `maps/CherrygroveMart.asm` (location scouting)

Still needed:
- `maps/ElmsHouse.asm` — **not yet inspected**, needed to finalize NPC placement
- Full `constants/pokemon_constants.asm` — to verify all Johto-range species constant
  names used in `evo_lines.asm`
- `wram.asm` — full defs for `wCurPartySpecies`, `wScriptVar`, and whatever variable
  `ChooseMonToLearnTMHM` uses to communicate the chosen species back to the caller
- `constants/event_constants.asm` — to reserve a free `EVENT_*` flag if one is needed
  for gating tutor availability (e.g. post-game unlock condition, if any is desired
  beyond per-move line-completion)
- `std_scripts.asm` — check for an existing reusable NPC-interaction pattern before
  hand-writing `SafariZoneMainOfficeMoveTutorScript` from scratch

---

## 7. Explicit open decisions for shasocastris / Claude Code

1. Curate the single move per species for the ~17 species listed in §4b.
2. Confirm all species constant spellings used in `evo_lines.asm` against the actual
   `constants/pokemon_constants.asm`.
3. Inspect `maps/ElmsHouse.asm` and confirm/reject it as the tutor location (vs.
   Cherrygrove Communication Center as fallback).
4. Decide whether the tutor itself needs any additional unlock gate (e.g. story-flag
   gated, item-cost gated like Kurt's tutor) beyond per-move line-completion — not yet
   decided, current design assumes the tutor is simply available and each move's
   availability is governed purely by dex-completion state.
5. Write `GetSafariZoneMoveTutorMove` and `CheckLineFullyCaught` per the pseudocode in §3/§4c.
6. Write the actual NPC script (`SafariZoneMainOfficeMoveTutorScript` per §3) and its dialogue text,
   respecting the project's 18-character dialogue line limit convention.

---

*Companion file: `evo_lines.asm` — the full `PokemonEvoLines` data table referenced in
§4a, already drafted and ready to drop into `data/pokemon/`.*

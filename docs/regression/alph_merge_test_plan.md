# Test plan: after the Alph/Unown/Suicune merge (written 2026-11-18)

Context for a fresh session. Branch `95-alph-unown-suicune` was fast-forwarded into `core` on 2026-11-18. The merge is 28 commits (`896b5cfc3..6d91ba776`, 70 files). Nothing below has been run against `core` as a whole yet. Only the two Suicune tests and the Kurt test were run, on the branch, as each change landed.

## Ground rules

- Work on `core` (or a branch from it). shasocastris's uncommitted Celebi starter test lives in `data/pokemon/base_stats/celebi.asm`, `data/pokemon/evos_attacks_johto.asm` and `maps/ElmsLab.asm`: never stage or revert them. If they change test results (the starter is Celebi), say so rather than touching them.
- Build first: `make -j"$(nproc)" all`. Tests run on `crystal_eclipse_debug.gbc` by default.
- Run from `docs/regression/harness/`: `python3 -u runner.py <module> -k <name> --jobs 1`.
- **One suite at a time, always `--jobs 1`.** Parallel suites froze the machine on 2026-10-25. Use `timeout` on long runs.
- **Always pass `-k` for the v10 modules.** `v10_suicune` and `v10_kurt_mail` import `v10_overworld`, whose tests otherwise run too.
- Reports land in `docs/regression/reports/<time>-<rom id>/`. Record results in `docs/regression/results.md`.
- The harness is untracked; never commit it (see `docs/helper_scripts.md`).

## What the merge changed

- **Ruins of Alph:**
  - The four chambers are pre-solved at new game (`InitializeEventsScript`).
  - The shrine is gated on the Suicune puzzle flag, not the Unown count.
  - New Suicune puzzle chamber, item room (Sacred Ash, Amulet Coin, BrightPowder) and word room.
  - Gate and NPC dialogue edits; the scientists Nikola and Murray now see 2 tiles.
- **EVIOLITE:** a new item (`$009A`), Suicune's bonus at the shrine if all 26 Unown are caught. There's a fallback item ball if the bag is full. In battle it gives the holder +50% Def/Sp. Def if it can still evolve (`EvioliteBoost` in `effect_commands.asm`, on both sides). It also blocks all evolution, stones included (`evolve.asm`).
- **SAMUEL's MAIL:**
  - Kurt is a new special-call contact (`PHONE_KURT`), who calls after the Route 42 Suicune scene.
  - Oak's Dragonite (`SPRITE_DRAGONITE` $84) waits in Kurt's house.
  - The `GiveSamuelsMail` special writes the letter into the PC mailbox.
  - `KurtsHouse.asm` moved to the new "Map Scripts 32" section.
- **Unown in the story:**
  - In the Slowpoke Well, Archer leads with Unown A, which has its own DVs (new `TRAINERTYPE_DVS`).
  - In the Rocket hideout, the machine is Unown-powered, Lance's Unown F, M and Q count as fought, and Petrel's ace is Unown Z.
  - The Wild Hunt now has Unown W and T running with the herd.
  - The Unown that Suicune drives off at each sighting count as fought.
  - The Rocket executives' held items changed.
- **New event flags** (`EVENT_RUINS_OF_ALPH_OUTSIDE_EVIOLITE`, `EVENT_KURTS_HOUSE_DRAGONITE`, Suicune room flags) were taken from the unused gap, so the save layout shouldn't move.

## 1. Tests that cover the merge directly (run these first)

| Command | Covers |
|---|---|
| `runner.py v10_suicune -k suicune_chamber --jobs 1` | Tree seal, chamber trainers (with the new sight range), puzzle solve, item room, word room, pit |
| `runner.py v10_suicune -k suicune_shrine --jobs 1` | Shrine fight with 25 Unown, with 26, and with 26 and a full bag: Clear Bell, EVIOLITE, fallback ball |
| `runner.py v10_kurt_mail -k samuels_mail --jobs 1` | Dragonite only cries; Kurt from below and from his right; follower stow/return; mailbox contents |
| `runner.py v10_overworld -k ow_smoke_changed_maps --jobs 1` | Every map changed since v0.9 loads, walks and opens its menu (now includes all the Ruins maps and Kurt's house) |
| `runner.py v10_overworld -k ow_save_layout_matches_v09 --jobs 1` | The new flags, item and sprite didn't shift the save layout |
| `runner.py v10_items -k items_balls --jobs 1` | Item-ball flags, including the 16 pre-solved chamber balls, the Suicune item room and the EVIOLITE fallback ball |
| `runner.py v10_items -k items_evo --jobs 1` | Evolution-item paths still work with the EVIOLITE check added to `evolve.asm` |
| `runner.py v10_items -k items_debug_items_given --jobs 1` | The debug bag still builds with the new item constant |
| `runner.py v10_audit -k audit_v09_save_ruins_of_alph --jobs 1` | Ruins executives and Suicune stay hidden outside the Ruins. Note: v0.9 saves are rejected outright now, so this may skip or fail by design; check before calling it a bug |

## 2. Suites that pass through changed code (run after section 1)

| Command | Why |
|---|---|
| `runner.py suite_evolve_location --jobs 1` | `evolve.asm` gained the EVIOLITE check before every evolution |
| `runner.py suite_battle_moves -k smoke_damage --jobs 1` | `EvioliteBoost` runs inside both damage routines on every hit |
| `runner.py suite_scenes -k deity_suicune --jobs 1` | Tin Tower Suicune; the shrine gate and sighting flags changed |
| `runner.py v10_story -k hunt --jobs 1`, then `-k route39` | Wild Hunt with the new Unown W/T |
| `runner.py suite_followers -k cutscene_stow --jobs 1`, `-k unown_letters`, `-k route39` | Stow pattern used in Kurt's house; Unown followers; the Route 39 herd |
| `runner.py suite_save --jobs 1` | Save round-trip with the new flags and a mailbox letter |
| `runner.py v10_overworld -k ow_smoke_all_maps --jobs 1` | Slow; run last. Catches anything the map-script section move broke |

## 3. Not covered by any test yet (write these, or ask shasocastris to play-test)

- **EVIOLITE in battle:** damage against a holder that can still evolve vs. a fully evolved one, on both the player and enemy side. Also check that the `$ffff` saturation holds.
- **EVIOLITE blocks evolution:** by level-up, by stone and by trade. The stone case should fail cleanly with no item consumed; check what actually happens.
- **Kurt's call:** the Route 42 Suicune scene ends with `specialphonecall SPECIALCALL_KURT` and clears `EVENT_KURTS_HOUSE_DRAGONITE`. The call comes outside only (`SpecialCallOnlyWhenOutside`). Nothing drives the full chain: Route 42 scene → call → Kurt's house.
- **Kurt's house with the mailbox full:** the Dragonite waits and the follower comes back. This path was never run headless.
- **Slowpoke Well:** Archer's Unown A has fixed DVs and is left behind afterwards (`TRAINERTYPE_DVS`).
- **Rocket hideout:** the Unown machine, Lance's Unown F/M/Q flagged as fought, and Petrel's Unown Z.
- **Suicune sightings:** the driven-off Unown are marked as fought at each sighting.
- **Dialogue:** run `python3 utils/dialogue_lint.py --changed core`. It compares against `core`, which now contains the branch, so for this merge lint the files directly or diff against `896b5cfc3`.

## Known gotchas

- `g.read` on a ROMX symbol goes through the bus, so it's only correct when that bank is paged in. Compare against known bytes instead.
- The Kurt and shrine tests set event flags directly and warp. They don't prove the story route reaches those states (that's section 3).
- After a test fails, look at its screenshots in `docs/regression/v10/<suite>/` before suspecting the ROM. Most first-run failures so far were test faults.

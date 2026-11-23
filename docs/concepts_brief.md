# EVOLVE_LOCATION Gate: Leafeon in Ilex Forest, Glaceon on Ice Path B3F

**Author:** shasocastris
**Date:** 2026-11-05

## Overview

The plan adds a location gate to the evolution table format. It is modelled on the existing `EVOLVE_REGION` gate (`constants/pokemon_data_constants.asm:207-210`). An Eevee that levels up on `ILEX_FOREST` evolves into Leafeon. One that levels up on `ICE_PATH_B3F` evolves into Glaceon. Only those exact maps count. The Leaf Stone and Mist Stone entries for Eevee are removed (`data/pokemon/evos_attacks_kanto.asm:2641`, `:2643`).

Six reviewers looked at the concept: design, codebase details, zoom-out, comprehension, implementation readiness and structural. All of them read the cited code. All six agree the approach is sound and small. A gate fits the format better than a new method would. The work stays in banked code (bank 16 / `bank10` section, `main.asm:169-173`) and changes no save data.

Three problems need fixing before implementation:

1. The map values in the concept are wrong.
2. A missed byte-width site in any table walker corrupts data silently.
3. Players have no way to discover the rule.

## Analysis

### Correction: the map numbers in the concept are map sizes

`map_const` takes `NAME, width, height` (`constants/map_constants.asm:9-18`). "15, 27" and "10, 9" are therefore sizes in blocks, not group and number. Both maps are in group 3, `DUNGEONS` (`:66`):

- `MAP_ILEX_FOREST` is 52 (`:118`).
- `MAP_ICE_PATH_B3F` is 66, not the 65 the line comment says. The hand-written comments drift at `:123` ("; 56 - 2"). Line 67 is map 1, so line 132 is map 66.

"10, 9" is also the size of `ICE_PATH_B2F_MAHOGANY_SIDE`. Any hand-coded gate would point at the wrong map, and the build would not catch it.

**Resolution (all reviewers):** never write raw numbers. Emit the gate as `db EVOLVE_LOCATION` followed by the existing `map_id` macro (`macros/scripts/maps.asm:1-6`). That macro emits `db GROUP_\1, MAP_\1` and asserts the map exists.

### Readers of the evolution table (verified complete)

A search of the whole repo confirms the three walkers the concept names. No Python, C or shell tool parses the table. Breeding uses `data/pokemon/first_stages.asm`, which already maps Leafeon and Glaceon to Eevee (`:260`, `:269`).

| Walker | Location | Callers |
| --- | --- | --- |
| `EvolveAfterBattle` | `engine/pokemon/evolve.asm:9-329` (region gate `:66-77`, width logic `:316-329`) | after battle, `EvolvePokemon` (Rare Candy) |
| `SkipEvolutions` | `evolve.asm:605-626` | `LearnLevelMoves` (`:407`), `FillMoves` (`:489`, used by `givepoke` and wild mons), `FarSkipEvolutions` (`home/battle.asm:18-27`) used by `move_reminder.asm:207` |
| `DetermineEvolutionItemResults` | `evolve.asm:628-679` (region gate `:658-670`) | `party_menu.asm:368` (ABLE/NOT ABLE column), `item_effects.asm:1028` (`MoonBallMultiplier`, not the stone handler) |

Byte widths are decided in four places, not three: `evolve.asm:317-321`, `:617-621`, `:642-647` and `:667-670`. Each one tests only for LEVEL and HAPPINESS. Any other byte is treated as a 5-byte entry.

### Findings by severity

**Blocker: a missed width site misaligns silently.** If a walker does not recognise `EVOLVE_LOCATION`, it skips the 3-byte gate plus 2 bytes of the guarded entry, then reads the middle of that entry as a method byte. If `SkipEvolutions` is the one missed, Eevee's learnset pointer is wrong everywhere: level-up moves, `givepoke` starting moves (Bill's Eevee, `maps/BillsFamilysHouse.asm:27`) and the move reminder. Nothing fails at build time. (structural, codebase-details, design)

**Blocker: stage order.** If the Eevee data lands before all the walker changes, the misalignment above happens in a real build. Walker changes must come first, or ship in the same commit. (structural)

**Major: read both gate bytes before branching.** If a gate leaves as soon as the group fails to match, the map-number byte is never consumed. The gate must consume both bytes. On a miss it should then join the existing "read guarded method, `ret z`/MasterLoop on 0, skip by method" tail at `evolve.asm:73-77` and `:664-670`, rather than copying that tail. (design, codebase-details, zoom-out, implementation-readiness)

**Major: register contract in `DetermineEvolutionItemResults`.**
- `de` is the return value: zeroed at `:633` and returned at `:639` and `:666`.
- `MoonBallMultiplier` relies on `c` surviving the farcall (`item_effects.asm:1020`, `:1029-1030`).

The gate must use only `a` and `b`. If it uses `c`, Moon Ball corrupts `wCurItem`. If it uses `de`, a non-matching Eevee can show as ABLE. (implementation-readiness)

**Major: where the gate sits in `EvolveAfterBattle`.** The location check must come before the ITEM and `wForceEvolution` branches (`evolve.asm:80-86`), just as the region check does. Placed after them, a stone use sends the gate byte to `.dont_evolve_check` with the wrong width. (codebase-details, design)

**Major: stacking gates as well as nesting them.** Today "Gates do not nest" is only a comment (`pokemon_data_constants.asm:209`). With two gate types, writing `EVOLVE_REGION` followed by `EVOLVE_LOCATION` is an easy mistake. On the failure path the second gate is read as a method, and the walker misaligns. Reword the comment to say "a gate's guarded entry must be a method, never another gate; a location already implies a region, so never stack them". A build-time check would mean wrapping all ~250 entries in macros, which is out of scope. (structural, design, codebase-details)

**Major: the "cancel with B" risk is larger than stated.** `CancelEvolution` jumps to `EvolveAfterBattle_MasterLoop` (`evolve.asm:375-379`), which moves on to the next party member. A happy Eevee that levels in Ilex Forest is offered Leafeon and never Espeon or Umbreon on that level-up. Cancelling costs that level-up's evolution chance, and the prompt repeats on every level gained in Ilex. Ilex has wild encounters (`data/wild/johto_grass.asm:565`). The repo has no Everstone: nothing references `EVERSTONE`. (comprehension, design, codebase-details)

**Major: discoverability.** No Pokedex or stats-screen display shows how a mon evolves. Searches of `engine/pokedex/` and `stats_screen.asm` find nothing. Existing text points players to the wrong places:
- Kimono Girl Hana (Leafeon) stands on Route 30, and her lines suggest training there ("deep into the woods", "LEAFEON can rest in the sun", `maps/Route30.asm:396-416`).
- Bill says his Eevee came from "training in ICE PATH" (`maps/BillsFamilysHouse.asm:114-117`), which suggests any floor.
- An Icy Rock item ball sits on Ice Path 1F (`maps/IcePath1F.asm:121`).
- A hidden Mist Stone sits in Ilex Forest itself (`maps/IlexForest.asm:445`).
- Kimono Girl Yuki stands on B3F (`maps/IcePathB3F.asm:82`). Her opening line promises "we'd talk more" (`:35-38`), so she is a natural place for the hint.

Without a hint, the B3F-only rule works as a trap, not a secret. (comprehension, zoom-out)

**Major: stale format documentation.**
- The header at `data/pokemon/evos_attacks.asm:5-14` says `dbbw EVOLVE_ITEM`, but the data uses `dbww` (5 bytes), and the header does not mention gates.
- The constants comment says `dbb EVOLVE_REGION`. No `dbb` macro exists, and the data uses `db` (`evos_attacks_kanto.asm:638`, `:2911`).
- "First match wins" is not written down anywhere, though the Eevee ordering and the Pikachu/Dragonair fallbacks depend on it.

(structural, codebase-details, comprehension)

**Nit: `jr` range.** The `jr z, EvolveAfterBattle_MasterLoop` instructions at `evolve.asm:62` and `:76` already reach back about 90 bytes. A second gate block that copies the tail could push a `jr` past -128. Sharing the tail avoids this. `utils/optimize.py:420-423` flags the `jr cc, .a / jr .b / .a:` pattern, so lay out branches to avoid it. (design, codebase-details, implementation-readiness)

**Nit: size.**
- Eevee's table grows by net 4 bytes.
- Code in bank 16 grows by about 25-35 bytes with shared tails, or 60-90 if copied three times.
- `crystal_eclipse.map:211-215` shows $225 bytes free in bank 16, but the file may be stale. Re-check it after building.
- ROM0 is untouched, and `FarSkipEvolutions` does not change.

**Nit: level-100 Eevee.** With the stones removed, a level-100 Eevee can never become Leafeon or Glaceon: Rare Candy fails at `MAX_LEVEL` (`item_effects.asm:1408-1410`). This matches the official games. Record it as accepted.

**Nit: uncommitted work.** `data/pokemon/evos_attacks_kanto.asm` and `maps/ElmsLab.asm` have uncommitted edits in the working tree. Decide whether this work builds on them.

### Verified correct (no change needed)

- **Constant space.** `EVOLVE_LOCATION` would be 6 (`const_def 1`: LEVEL=1 … REGION=5). Every walker compares method bytes with a plain `cp`; none uses a range check or jumptable.
- **Level-1 semantics.** `GetEvoLevel` (`evolve.asm:700-705`) sets carry only when the level is below the parameter, so `EVOLVE_LEVEL, 1` means "any level-up". Rare Candy clears `wForceEvolution` (`item_effects.asm:1481-1483`), and so does the end of battle (`engine/battle/core.asm:7695-7697`), so both paths reach the gate.
- **Stones still work.** Stones set `wForceEvolution` (`item_effects.asm:1216-1218`). The guarded `EVOLVE_LEVEL` entry is skipped (`evolve.asm:84-86`), and later stone entries still match. A Thunderstone used in Ilex still gives Jolteon.
- **`wEvolvableFlags`.**
  - Flags are set only for mons that level in battle (`core.asm:6827-6831`, reset at `start_battle.asm:156`) or for the single Rare Candy target (`evolve.asm:1-8`).
  - Walking into Ilex without levelling does nothing.
  - Day Care level-ups never evolve.
  - Link battles give no experience, so the Cable Club point does not matter.
  - A lost battle returns before evolution runs (`core.asm:7691-7693`).
- **WRAM reads.** `wMapGroup` and `wMapNumber` (`ram/wram.asm:2825-2826`) share a WRAMX section with `wCurRegion`, which the region gate already reads directly. They are valid after battle, in the party menu and during Moon Ball. `GetFarByte` clobbers only `a` (`home/copy.asm:68-87`).
- **Save compatibility.** No SRAM, WRAM or flag changes. Existing saves load, and rollback is a revert.
- **Stones keep other users.** Leaf Stone: Vileplume, Victreebel, Exeggutor and others. Mist Stone: Alakazam, Machamp, Golem, Gengar. Neither item becomes unused, and their descriptions (`data/items/descriptions.asm:472-480`) stay accurate.

## Goals vs. Non-Goals

**Goals**
- Leafeon on any level-up while on `ILEX_FOREST`, by battle or Rare Candy.
- Glaceon on any level-up while on `ICE_PATH_B3F` only. Other Ice Path floors, `ILEX_FOREST_AZALEA_GATE` and Route 34 are excluded.
- Location entries take priority over Espeon/Umbreon. Stone evolutions are unaffected on these maps.
- A reusable 3-byte gate that any species' table can use.
- A hint from Kimono Girl Yuki (`maps/IcePathB3F.asm`) that names B3F as the place where Glaceon evolves.
- Format documentation corrected, and the gate rules written down.

**Non-Goals**
- An Everstone or other opt-out item. Cancelling with B is the only opt-out in v1 (author decision, 2026-11-05).
- Rewriting Hana's, Bill's or Elm's text. Only Yuki gets a hint in v1. Ilex Forest has no explicit hint, though Hana's "deep into the woods" line already points that way.
- A Pokedex or stats-screen "how it evolves" display.
- Build-time validation of gate nesting or stacking. That needs every entry wrapped in a macro.
- A general location-evolution framework, or work for Magnezone/Probopass. Magnezone uses a Thunderstone (`evos_attacks_kanto.asm:1714`), and Probopass is not in the game.
- Keeping Leaf Stone and Mist Stone as fallback routes for Eevee.
- Caching the location in WRAM the way `wCurRegion` is cached.

## Alternatives Weighed

| Alternative | Verdict | Reason |
| --- | --- | --- |
| 3-byte map gate, `db EVOLVE_LOCATION` + `map_id MAP` | **Chosen** | The only option that expresses "B3F only". `map_id` catches bad map names at build time. The extra byte per entry is negligible. |
| 1-byte landmark gate (2 bytes total) | Rejected unless the B3F-only rule is relaxed | `LANDMARK_ICE_PATH` covers five maps (`data/maps/maps.asm:142-146`). It would work for Ilex (`:132`). `GetPlayerLandmark` already exists in ROM0 (`home/region.asm:1-17`). If "anywhere in Ice Path" is acceptable, this gives the same 2-byte width as the region gate and a larger target for the player. |
| Reuse the `EVOLVE_REGION` parameter byte for special locations | Rejected | It overloads the meaning of `RegionCheck` (`engine/overworld/landmarks.asm:45-79`) and the cached `wCurRegion`. |
| 2-byte gate with an index into a small `EvoLocations` table | Deferred | Keeps every walker's skip at one `inc hl`, but adds a lookup and a table for two entries. Revisit only if several species need multi-map sets. |
| Length-prefixed generic gate header | Rejected | Costs a byte per gate, differs from `EVOLVE_REGION`, and only fixes skipping, not checking. |
| A new `EVOLVE_LOCATION_LEVEL` method | Rejected | It would need a new width class and would not combine with other methods. A gate does both. |
| Keep the stones as fallbacks | Rejected | It makes the gate pointless for Eevee. |
| Shared gate helper (`CheckEvoGate`/`SkipEvoGate`) | Recommended | Smallest code, and future gates do not drift. Note that `SkipEvolutions` reads with the bank in `b` via `GetFarByte`, not `hTemp`, so it needs separate handling, or it can share only the REGION `inc hl` path. |

## Key Decisions & Staging for Next Steps

**Decisions to confirm**
1. **Map identity:** always use `map_id` symbols and correct the numbers in the design text. Optionally fix the `map_constants.asm` comment drift from `:123` onward.
2. **Exact-map gate rather than landmark (decided):** the original request names Ice Path B3F, so the 3-byte map gate is used and Yuki's hint names that floor.
3. **Macro style:** either write `db EVOLVE_LOCATION` + `map_id` inline, or add `evo_location`/`evo_region` macros together and convert the two existing region gates (`evos_attacks_kanto.asm:638`, `:2911`). Do not wrap only one kind of gate.
4. **Gate failure path:** all gates join one shared "skip guarded entry" tail in each walker. Gates use only `a` and `b`.
5. **Priority and cancel cost (decided):** location entries come first. Cancelling with B is accepted for v1, even though it skips Espeon/Umbreon for that level-up and the prompt repeats on every level gained in Ilex.
6. **Hints (decided):** only Yuki gets a hint. Rewrite her post-battle text (`KimonoGirlYukiAfterBattleText`, `maps/IcePathB3F.asm`) to say Eevee becomes Glaceon on this floor. Keep every line to 18 characters or fewer. Reviewer example: "EEVEE grew into" / "GLACEON on this" / "very floor." Hana and Bill are left unchanged.
7. **Level-100 Eevee** cannot reach Leafeon or Glaceon. Accept.

**Staging**
1. **Constants and docs.** Add `EVOLVE_LOCATION` (6) under a `; gates` heading. Fix `dbb` to `db`. Write down the no-nest/no-stack rule and "first match wins". Update the `data/pokemon/evos_attacks.asm` header with every method's and gate's byte width. The build should be byte-identical apart from symbols.
2. **Walkers.** Update all four width sites in `evolve.asm`, with no data change yet. Check Pikachu and Dragonair region behaviour, and confirm `optimize.py` reports no new warnings.
3. **Data.** Put the two gated `EVOLVE_LEVEL, 1` entries at the top of `EeveeEvosAttacks` and remove the Leaf Stone and Mist Stone entries. This may share a commit with stage 2 but must never come before it.
4. **Text hint.** Yuki's post-battle text only.
5. **Tests.** Use the SameBoy harness in `docs/regression/`: `warp()`, `set_party_mon()`, direct `g.call`.
   - **Direct calls:**
     - `DetermineEvolutionItemResults` returns 0 for Eevee with Leaf Stone or Mist Stone on any map.
     - The other stones still return Jolteon, Vaporeon, Flareon and Sylveon.
     - `c` is preserved.
     - `FarSkipEvolutions` lands on Eevee's learnset label.
   - **Scenes:**
     - Rare Candy gives Leafeon in Ilex and Glaceon on B3F.
     - Nothing happens on B2F, B1F, the Azalea gate or Route 34.
     - A high-happiness Eevee in Ilex becomes Leafeon. Outside, it still becomes Espeon or Umbreon.
     - B-cancel leaves Eevee.
     - A post-battle level-up in Ilex evolves.
     - `givepoke` Eevee has the correct starting moves.
     - The move reminder list is intact.
     - The Moon Ball multiplier is unchanged.
   - **Build:** zero new warnings, and bank 16 free space re-checked in `crystal_eclipse.map`.

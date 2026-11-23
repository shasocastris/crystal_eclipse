# Branch 30: "Perfect Pokémon" NPC (max DVs and EVs), research on `core`

Everything here was checked against the source unless it is marked **(inferred)**. Line numbers are for `core` at 01727c11f.

## 1. Struct layout, the EV system and stat calc

**Party struct** (`constants/pokemon_data_constants.asm:74-112`):
- `MON_EVS` is 6 bytes in the order HP/Atk/Def/Spd/SAt/SDf (`:79-86`).
- `MON_DVS` is 2 bytes (`:88`). Byte 0 is `Atk<<4 | Def` and byte 1 is `Spd<<4 | Spc`. There are 4 DVs. The HP DV is derived, and SAt and SDf share the Special DV.
- `BOXMON_STRUCT_LENGTH` ends at `MON_LEVEL` (`:100`). `MON_MAXHP` and the stats come after it (`:103-111`).

**Save/box struct** (`:116-155`): `SAVEMON_EVS` is 6 bytes (`:125`) and `SAVEMON_DVS` is a word (`:134`). Box entries are checksummed: the checksum is spread across the MSBs of the nickname and OT bytes, and a bad checksum makes the mon a Bad Egg (`docs/newbox_format.md:109,134-160`). That doc is **stale on EVs**: it still lists 10 bytes of stat exp at 0x0B-0x14, but the constants hold 6 EV bytes.

**EV caps:**
- `MAX_EV EQU 252` and `MAX_TOTAL_EV EQU 510` (`pokemon_data_constants.asm:301-302`).
- Both caps are enforced only where EVs are gained:
  - Battle gain clamps each stat to 252 (`engine/battle/core.asm:7245-7262`) and uses `IsEvsGreaterThan510` (`:7663`).
  - Vitamins stop at 100 per stat (`engine/items/item_effects.asm:1266`, `cp 100`) and also check the 510 total (`:1216-1271`).
- **`CalcMonStats` does not check either cap.**

**Stat calc** (`engine/pokemon/move_mon.asm:922 CalcMonStats`, `:944 CalcMonStatC`):
- Formula: `((Base + DV)*2 + EV/4) * L/100 + 5`. HP uses `+ L + 10` instead of `+5`. Stats are capped at 999.
- The HP DV is `(Atk&1)<<3 | (Def&1)<<2 | (Spd&1)<<1 | (Spc&1)` (`:989`).
- At L100, DV 15 adds +30 over DV 0 and EV 252 adds +63.
- There are no natures (grep found none).

**How stats are recalculated:**
- `UpdateStatsAfterItem` (`item_effects.asm:1300`) loads `MON_MAXHP` into `de` and `MON_EVS-1` into `hl`, sets `b=TRUE`, and runs `predef_jump CalcMonStats`.
- It needs `wCurSpecies`, `GetBaseData` and `wCurPartyLevel` set first. `RareCandy_StatBooster_GetParameters` (`:1368`) does exactly that.
- Vitamins do **not** adjust current HP.
- Rare Candy adds the change in max HP to current HP (`:1414-1438`). Applied to a fainted mon, that adds HP to a 0-HP mon **(inferred)**.

**New DVs/EVs persist on their own.** These paths all recalculate from the stored DVs/EVs:
- level-up (`core.asm:7481-7485`)
- evolution (`engine/pokemon/evolve.asm:229`)
- box withdraw (`engine/pc/bills_pc.asm:1050-1061`)

## 2. What else the DVs drive

| Consumer | Rule | Effect of all-15 (`$FF $FF`) |
|---|---|---|
| **Shiny** `CheckShininess` (`engine/gfx/color.asm:8-38`) | Shiny if **all four DVs are 12 or higher**. The `SHINY_*_DV` constants at `:3-6` are dead vanilla leftovers. Forced-shiny battles use `$FF/$FF` (`constants/battle_constants.asm:81-82`). | **Every mon becomes shiny.** This is the opposite of vanilla. The natural shiny rate here is (4/16)^4 = 1/256 **(inferred, if wild DVs are uniform)**. |
| **Gender** `GetGender` (`engine/pokemon/mon_stats.asm:124-243`) | Gender comes from the **Atk, Def and Spc LSBs, not Speed**. The comment at `:133` is wrong. `b = (~Spc0)<<7 \| Def0<<6 \| (~Atk0)<<5`, and the mon is male if `b < ratio` (`:232`). Ratios use `percent = *$ff/100` (`macros/data.asm:23`): F12.5=31, F25=63, F50=127, F75=191, F100=254. | All-15 gives b=64. **Male** for F50/F75 species. **Female** for F12.5 species (starters, Eevee and the like) and F25 species. F0, F100 and genderless species are unchanged. |
| **Unown letter** `GetUnownLetter` (`engine/gfx/load_pics.asm:1-45`) | Uses the middle 2 bits of each DV. | Every Unown becomes **Z**, which is a form change. |
| **Hidden Power** (`engine/battle/hidden_power.asm:1,46`) | Type = `((Atk&3)<<2 \| (Def&3)) + 1`, skipping the unused type gap (9 to 19) (`constants/type_constants.asm`). Power is fixed at **70** (`data/moves/moves.asm:236`), not DV-based. | **Dark.** Fairy can never be rolled. Hidden Power is still live: TM10 (`constants/item_constants.asm:304`), sold in a mart (`data/items/marts.asm:308`), in learnsets, and its type is read out by the Poké Seer (`engine/events/poke_seer.asm:22`). |
| **Magikarp length** (`engine/events/magikarp.asm:27-44,105+`) | Built from the DVs XOR the OT ID. | The length becomes fixed, so it could be used to game the Lake of Rage record. Minor. |
| Attract / in-battle gender (`engine/battle/move_effects/attract.asm:46-55`) | Reads gender from the DVs. | Follows the gender change. |

Egg creation from the Day-Care does not appear to inherit DVs: there are no `wEggMonDVs` users, and only `RetrieveBreedmon`/`DepositBreedmon` remain **(inferred: breeding code removed or not DV-based)**.

**DV recipes** (byte 0 = Atk/Def, byte 1 = Spd/Spc):
- **A. Pure max:** `$FF $FF`. Shiny, Dark Hidden Power, gender forced as in the table above.
- **B. Keep gender.** Try these candidates in order and keep the first whose `GetGender` result matches the original:
  1. `$FF $FF`
  2. `$FF $FE` (Spc 14). Gives female for F50/F75 species. HP DV becomes 14.
  3. `$FE $FF` (Def 14). Gives male for F25/F12.5 species. HP DV becomes 11.

  These three cover every ratio (checked by hand). All three are still shiny.
- **C. Keep non-shiny.** Set **Speed to 11** (`$FF $BF`, or apply it on top of B). Speed is the only DV that affects neither gender nor Hidden Power type, and 11 is odd, so the HP DV stays 15. The cost is about 8 Speed at L100. Atk 11 would also leave HP type and gender alone (11&3 = 3), so it is an option for special attackers.
- **D. Keep Hidden Power type.** `Atk = 12 | (Atk&3)`, `Def = 12 | (Def&3)`, `Spc = 14 | (Spc&1)`, `Spd = 15`. This keeps gender as well, because it keeps the Atk and Def LSBs. Add `Spd = 11` to stay non-shiny.
- **Recommended default:** keep shininess *and* gender. Check `CheckShininess` on the original DVs. If the mon was shiny, use B. If not, use B with Speed forced to 11. Exclude Unown (or keep the middle bits, `DV = (orig & %0110) | %1001`).

**EV recipes:**
- **(i)** 252 in all six stats (1512 total). This ignores the 510 cap. `CalcMonStats` accepts it. Reading the battle gain loop, a later EV gain would wrap `e` in `.decrease_evs_gained` (`core.asm:7239-7244`) but still clamp each stat back to 252, so nothing breaks **(inferred, not tested)**. Vitamins would show "no effect".
- **(ii)** A legal 510 spread: 252/252 plus 6. This needs a stat-choice menu.
- **(iii)** Leave EVs alone and change DVs only.

## 3. Pattern to reuse

| Pattern | Flow | Fit |
|---|---|---|
| `HaircutOrGrooming` (`engine/events/haircut.asm:29-55`), and `MoveDeletion` (`engine/events/move_deleter.asm:1`) | `farcall SelectMonFromParty` (`engine/pokemon/party_menu.asm:1-11`, which ends in `ReturnToMapWithSpeechTextbox`), then a result in `wScriptVar`. The map script handles text, cost and the daily `ENGINE_` flag (`maps/GoldenrodUnderground.asm:317-330`). | **Best fit.** There is no follow-on UI, so a speech textbox is all it needs. |
| `SafariZoneMoveTutor` (`engine/events/safari_move_tutor.asm:23-114`) | `FadeToMenu` .. `CloseSubmenu` around a plain party menu. It returns one of 0-5 in `wScriptVar` (`maps/SafariZoneMainOffice.asm:13-19`). | Only needed because `LearnMove`'s forget-a-move UI has to render in the menu layer. It is heavier than this feature needs. Reuse its egg check: `IsAPokemon` on `wCurPartySpecies` (`:52-54`; `home/pokemon.asm:1`). |
| Rare Candy readout (`item_effects.asm:1442-1452`) | `CopyMonToTempMon`, then `Textbox`, then `PrintTempMonStats`. | Good for showing the new stats. Nothing on screen shows DVs or EVs: the 4 pages are Pink/Green/Blue/Orange (`engine/pokemon/stats_screen.asm:502-508`), and Orange holds met data and happiness (`:745`). |

**Recommendation: two specials in bank $3F.**
- `PerfectMonSelect` picks a mon with `SelectMonFromParty` and checks it. It returns one of: 0 = cancel, 1 = egg, 2 = already perfect, 3 = OK. It also copies the nickname for the text, the way `GetCurNickname` does in `haircut.asm:36`.
- The script then asks yes/no, takes the cost, and sets the flag.
- `PerfectMonApply` writes the DVs and EVs, then:
  1. Saves the old max HP.
  2. Runs `RareCandy_StatBooster_GetParameters` and `UpdateStatsAfterItem`, or a local copy (they live in `item_effects.asm`, which is in another bank, so use a farcall or duplicate them).
  3. Adds the change in max HP to current HP **only if HP is above 0**, so a fainted mon is not revived. Alternatively, fully heal.

`wCurPartyMon` stays set between the two specials.

**Box mons:** handle the party only. Box entries are checksummed and get their stats recalculated on withdraw anyway.

## 4. Open design questions (recommended default in **bold**)

1. Which DV recipe? **Keep shiny status and gender (B, plus C if the mon was not shiny)**, and say so in the NPC's text.
2. Which EV recipe? **(i) 252 in everything, if "max stats" is meant literally.** Otherwise (iii), which keeps EV training meaningful. (ii) costs a menu.
3. Eggs: **refuse** (`IsAPokemon` carry).
4. Already perfect (DVs and EVs equal the target): **refuse with a line of text and charge nothing.**
5. Unown: **refuse** (it would become Z) or keep its letter.
6. Nickname and OT: **leave untouched**. Nothing in the routine reads them. Traded mons keep their boosted EXP and their obedience status.
7. Gating:
   - **Post-game location** (gated by where the NPC stands, with no flag).
   - **Plus a cost**: money via `PlaceMoneyTopRight`/`checkmoney`, or an item (`GOLD_LEAF`, `STAR_PIECE` and `BIG_PEARL` exist, `constants/item_constants.asm:126-134`).
   - **Plus once per day.** Optional: require high happiness (`HAPPINESS_TO_EVOLVE` = 220), which ties in with branch 32.
8. Show the new stats afterwards? **Yes**, with the Rare Candy-style stats box.
9. Should the NPC also max PP Ups or happiness? **No**, keep the scope tight.

## 5. Placement, flags, space

- **Object slots:** `NUM_OBJECTS EQU 18` (`constants/map_object_constants.asm:98`), so there are up to 17 `object_event`s per map **(inferred: the player takes one slot)**.
- **Candidate locations:**
  - **SilverCavePokecenter1F**: 2 objects (nurse, granny). Effectively the last area in the game. **Top pick.**
  - **Route28SteelWingHouse**: 2 objects (Celebrity, Fearow). Post-game, and a celebrity "trainer coach" fits the theme.
  - **CeladonMansionRoofHouse**: 1 object (pharmacist). Kanto post-game. CinnabarPokecenter1F (3 objects) is an alternative.
- **Zero new event flags: yes.** The location gates by itself, and the daily lock can use the free `ENGINE_UNUSED_FLAG_3..7` (`constants/engine_flags.asm:120-124`). These sit in `wDailyFlags3`, which is cleared daily at `engine/overworld/time.asm:186` and is already in the table at `data/events/engine_flags.asm:130-134`.
- **"Event flags are full" is only true at the tail.** The last block (1911-2047) is full: appending fails with "const_next cannot go backwards" (`macros/const.asm:34-40`; `docs/orange_islands_implementation_context.md:409`). But counting `const`/`const_skip` per `const_next` block shows unassigned bits before each jump:
  - 51 at 249-299
  - 219 at 381-599
  - 148 at 852-999
  - 61 at 1539-1599
  - 8 at 1903-1910
  - plus 33 `const_skip` slots

  The "Unused: next N" comments are stale. **(Verified by a Python count of the file. Confirm with a build before relying on it.)**
- **Free space** (`crystal_eclipse.map`): bank $3F has **$2691** (about 9.8 KB) free in both the release and debug builds. That is where `SafariZoneMoveTutor` lives (`main.asm:489-494`, sym `3f:536a`). Bank $13 has $22F0. Bank $01 has only 6 bytes and bank $03 has 0, so don't add anything to the haircut bank or the `CalcMonStats` bank.
- **Specials:** append `add_special PerfectMonSelect` and `add_special PerfectMonApply` to `data/events/special_pointers.asm`, which has 139 entries now. The `special` macro emits a word index (`macros/scripts/events.asm:105-108`), so there is no 256 limit. Map text is limited to 18 characters per line.

## 6. Interactions with other branches

- **32 (happiness obedience):** obedience now applies only to traded mons and is capped by badges (`engine/battle/effect_commands.asm:603-690`). DVs and EVs don't touch it. If branch 32 applies obedience to every mon, a perfected mon is still governed by its happiness, so a happiness gate on the NPC (Q7) would line up with that. No code conflict.
- **39 (legendaries removed, their sites become tutors):** no code conflict. A freed legendary site could host this NPC instead. Avoid putting this NPC on a site branch 39 will claim, for example a Mt. Silver area tutor. Mewtwo is still perfectible.
- **24 (move renumbering):** the routine uses no move constants. Hidden Power type depends on the *type* order (`UNUSED_TYPES`), not move IDs. No conflict.
- **11 (link removal):** removes the only way to export perfected mons, which settles any "exploit" worry. `engine/link/link.asm` touches DVs but is independent. No conflict.
- **49 (pseudo-abilities):** these are keyed by species (`docs/pseudo_abilities.md:3`). Nothing reads DVs, gender or shininess. No conflict.

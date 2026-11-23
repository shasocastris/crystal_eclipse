# Branch 39, part A: legendaries become move tutors (species and world side)

Base: `core` @ 01727c11f. Research only; nothing in the repo was touched. "Verified" means I read it in source. **[inferred]** means I didn't trace it fully.

## 0. Headline findings

- **No other legendaries or mythicals exist.** The species past CELEBI ($fc–$114, `constants/pokemon_constants.asm:286-310`) are Electivire…Cursola: all cross-gen evolutions, none legendary. The variants are CORSOLA_KANTO, RAICHU_ORANGE and DRAGONITE_KANTO (`:343-347`). The reserved roster (`:349-385`) has **no Galarian birds**. The seasonal plan adds none either.
- **The old `39-make-legendaries-move-tutors` branch is stale.** It holds 2 WIP commits (78fafd342 and 76938dda0, "need to reduce BATTLE CORE"), it is 272 commits behind `core`, and its merge-base is 166979472. Start part A from `core`. Don't build on it.
- **The hardest blocker is the Rainbow Wing / Ho-Oh gate.** `special BeastsCheck` (`engine/pokemon/search_owned.asm:1-30`) requires that the player *owns* Raikou, Entei and Suicune with their own OT. It is called at `maps/TinTower1F.asm:41` (Wise Trio and the Rainbow Wing) and `maps/CeladonPokecenter1F.asm:33` (Eusine). If this isn't changed, Ho-Oh becomes unreachable.
- **Recommendation: option (b).** Keep the species data and make it unobtainable. The overworld sprites of the birds, Lugia, Ho-Oh and Mew are party icons (`SpriteMons`), and `pokepic` needs the front pics, so deleting the species would destroy the presentation the tutors need.

## 1. References, by subsystem

**Species tables (indexed by NUM_POKEMON_AND_VARIANTS; keep under option b)**
- Constants: `constants/pokemon_constants.asm:176-178` (birds), `:182-183` (Mewtwo, Mew), `:277-279` (beasts), `:283-285` (Lugia, Ho-Oh, Celebi).
- `data/pokemon/names.asm:150-157,249-257`; `base_stats.asm` plus `base_stats/{articuno…celebi}.asm`; `cries.asm:152-159,251-259`; `menu_icon_pals.asm:156-163,255-263`; `icon_pointers.asm`, `pic_pointers.asm`, `palettes.asm`, `first_stages.asm:147-154,246-254`; `gfx/pics.asm`, `gfx/icons.asm`, `gfx/pokemon/{anim,idle,bitmask,frame}_pointers.asm`, `anims/idles/bitmasks.asm`, `johto_frames.asm`, `kanto_frames.asm`.
- Learnsets: `evos_attacks_kanto.asm:2834,2853,2872,2951,2966` and `evos_attacks_johto.asm:1757,1772,1787,1861,1875,1889`. Nothing evolves *into* them (verified, no EVOLVE target). No egg-move source exists in this tree **[inferred]**: `EggMovePointers` has no .asm hits.
- Dex (tables sized NUM_POKEMON): `dex_entry_pointers.asm`, `dex_entries/*.asm`, `dex_order_new.asm:264-269,276-280` (the end of the new dex, interleaved with the Dratini and Larvitar lines), `dex_order_alpha.asm:15,26,63,97,128,149,150,154,199,237,279`, `gfx/footprints.asm`.
- Time Capsule / gen 1: `gen1_order.asm:23,54,75-77,133,174-186`, `gen1_base_special.asm`, `engine/link/link.asm:2321-2333` (Mew/Celebi trade text). `mobile/mobile_46.asm:615-619` is dead mobile code.

**Overworld sprites and cutscene art**
- `SpriteMons` (party icon used as the overworld sprite): `data/sprites/sprite_mons.asm:40-42` (Lugia, Ho-Oh, Mew) and `:60-62` (Moltres, Zapdos, Articuno). Constants are at `constants/sprite_constants.asm:176-178,196-198`.
- Dedicated sprites: SPRITE_SUICUNE/ENTEI/RAIKOU at `sprite_constants.asm:103-105`, `data/sprites/sprites.asm:111-113`, `gfx/sprites.asm:104-106`.
- Celebi uses its own sprite-anim GFX: `engine/events/celebi.asm:2-100` (`gfx/overworld/celebi.2bpp`).
- Mewtwo uses the generic SPRITE_MONSTER (`maps/PokemonMansion.asm:71`).
- Title and intro Suicune are graphics only (`engine/movie/title.asm:24-345`, `engine/movie/intro.asm`, `engine/menus/intro_menu.asm:925`). Nothing there to change.

**Static encounters (all use `loadwildmon` and `BATTLETYPE_FORCEITEM` unless noted)**

| Mon | Map:line | Appears when | "Met" flag (set before battle) | Object hide flag |
|---|---|---|---|---|
| Articuno L70 | `SeafoamCaves.asm:10-37,55` | EVENT_BEAT_BLAINE | EVENT_FOUGHT_ARTICUNO (`event_flags.asm:546`) | EVENT_SEAFOAM_CAVES_ARTICUNO |
| Zapdos L70 | `RockTunnelB1F.asm:13-40,77` | EVENT_RESTORED_POWER_TO_KANTO | EVENT_FOUGHT_ZAPDOS (`:547`) | EVENT_ROCK_TUNNEL_ZAPDOS |
| Moltres L70 | `VictoryRoad.asm:103-127,543` | EVENT_BEAT_ELITE_FOUR | EVENT_FOUGHT_MOLTRES (`:548`) | EVENT_VICTORY_ROAD_MOLTRES |
| Mew L30 | `DarkCaveBlackthornEntrance.asm:15-42,203` | EVENT_BEAT_ELITE_FOUR_REMATCH | EVENT_FOUGHT_MEW (`:544`) | EVENT_DARK_CAVE_MEW |
| Lugia L60 | `WhirlIslandLugiaChamber.asm:10-37,55` | has SILVER_WING (from `PewterCity.asm:44-49`) | EVENT_FOUGHT_LUGIA (`:543`) | EVENT_WHIRL_ISLAND_LUGIA_CHAMBER_LUGIA |
| Ho-Oh L60 | `TinTowerRoof.asm:10-38,56` | has RAINBOW_WING | EVENT_FOUGHT_HO_OH (`:542`); also sets EVENT_SET_WHEN_FOUGHT_HO_OH (hides Celadon Eusine, `CeladonPokecenter1F.asm:163`) | EVENT_TIN_TOWER_ROOF_HO_OH |
| Suicune L50 | `TinTower1F.asm:89-140` (scene SCENE_TINTOWER1F_SUICUNE_BATTLE; BATTLETYPE_SUICUNE) | entering with Clear Bell / Koji | EVENT_FOUGHT_SUICUNE (`:575`) | object TINTOWER1F_SUICUNE |
| Celebi L30 | `IlexForest.asm:450-502` (BATTLETYPE_CELEBI via `celebi.asm:261`) | GS_BALL in bag plus EVENT_FOREST_IS_RESTLESS | none; the GS Ball is consumed (`:470`), which makes it one-shot | none |
| Mewtwo L70 (stays) | `PokemonMansion.asm:12-45,71` (Cinnabar), all NUM_BADGES | | EVENT_FOUGHT_MEWTWO (`:545`) | **bug**: the flag column is `POKEMONMANSION_MEWTWO` (=6, which is EVENT_TEMPORARY_UNTIL_MAP_RELOAD_7). The callback masks it. |

All the hide flags are pre-set in `engine/events/std_scripts.asm:533-539`. `EVENT_TOHJO_FALLS_MEWTWO` (`event_flags.asm:1462`) is only ever set there and is otherwise vestigial. It is a free flag to fix Mewtwo's hide-flag bug or to reclaim.

**The roaming system (Raikou and Entei)**
- Release happens at `maps/BurnedTowerB1F.asm:33-96`: cries and sprite run-offs, `setevent EVENT_RELEASED_THE_BEASTS` (`:83`), `special InitRoamMons` (`:84`).
- `InitRoamMons` (`engine/overworld/wildmons.asm:591-629`) puts Raikou in roam slot 1 and Entei in slot 2, both L50. It calls **SetSeenMon on all three beasts**: this is the "auto-registered in dex" logic (`:598,602,605`). Slot 3 is unused.
- Encounters go through `CheckEncounterRoamMon` (`:631-676`), called from `ChooseWildEncounter` (`:287`). It sets BATTLETYPE_ROAMING. Roamers move via `UpdateRoamMons` / `JumpRoamMons` (`:678+`, `data/maps/setup_scripts.asm:31,110,143`, `data/wild/roammon_maps.asm`), and the dex nest display reads them at `:70-104`.
- After a battle, `BattleEnd_HandleRoamMons` (`engine/battle/core.asm:8757-8786`) clears the struct (species 0, map GROUP_N_A) on a **win or a catch**.
- Other roamer references: `core.asm:6129-6140,6528-6548` (HP), `wram.asm:3082-3089`, `intro_menu.asm:149-160` (structs start at species 0 / map -1), `engine/16/table_functions.asm:39` (roam species keep their ID slots locked), and `data/wild/flee_mons.asm:251-252`.

**Beast-ownership checks (must be replaced)**
- `BeastsCheck` callers: `TinTower1F.asm:41`, `CeladonPokecenter1F.asm:33`.
- `MonCheck` on beasts: `TinTower1F.asm:56,65` (callback) and `:94,107` (cutscene; Raikou/Entei appear only if not owned), `CeladonPokecenter1F.asm:30` (Suicune).
- Locked IDs: `TinTower1F.asm:30-34`.

**Story scenes that use sprites and cries only (no battle; keep as they are)**
- Suicune chase: `Route36.asm:26-46`, `Route42.asm:26-42`, `CianwoodCity.asm:44-70`, plus the init flags at `std_scripts.asm:588-590`.
- Ruins of Alph: Suicune routs Rocket, then gives you the **Clear Bell** (`RuinsOfAlphOutside.asm:165-200,555-625`). This is custom.
- Elm's phone call: `CianwoodGym.asm:59`, `engine/phone/scripts/elm.asm:70,100`.
- Dialogue mentions only: WiseTriosRoom, BurnedTower1F, DanceTheater:287, IcePath1F:134, Route44:330, VioletGym:274, CeruleanGym:225-330, Cianwood and Ecruteak LugiaSpeechHouse, SeafoamGym and CeruleanBase3 (Mewtwo).

**Gameplay gates on the "fought" flags (these keep working if the flags are reused)**
- Falkner rematch needs all three birds: `VioletGym.asm:72-76`.
- Misty rematch needs Lugia: `CeruleanGym.asm:157`.
- Morty rematch needs Ho-Oh: `EcruteakGym.asm:87`.
- Blaine rematch needs Mewtwo: `SeafoamGym.asm:52`.
- Tin Tower sages and Karen read FOUGHT_HO_OH: `TinTower1F.asm:46,187-227`.
- Wise Trio and the tower entrance read FOUGHT_SUICUNE: `WiseTriosRoom.asm:24`, `EcruteakTinTowerEntrance.asm:22`.

**Celebi / GS Ball chain**
- Oak gives the GS Ball (`OaksLab.asm:22-30`), then Kurt (`KurtsHouse.asm:284-334`), then the Azalea scene gives it back (`AzaleaTown.asm:153-170`), then the shrine (`IlexForest.asm:450`).
- After the battle, `special CheckCaughtCelebi` (`celebi.asm:265`, which reads `BATTLERESULT_CAUGHT_CELEBI` set at `item_effects.asm:626-632`) decides whether Kurt appears (`IlexForest.asm:491-500`).
- Battle-side code: `core.asm:3755,9265`, `effect_commands.asm:4983`, `teleport.asm:7`, `data/text/battle.asm:31`.

**Trainers and Battle Tower**
- Battle Tower: `data/battle_tower/parties.asm:2274,2553,3085` (Zapdos), `:2412` (Articuno), `:3732` (Moltres). These must be replaced.
- Archer has Mewtwo L80 (`data/trainers/parties.asm:6272`). That's fine, since Mewtwo stays.

**Type completion, tutor and dex counts**
- `data/types/pokemon_type_lists.asm:275` lists **MOLTRES** in FireTypeSpecies. No other legendary appears in any type list. Mewtwo isn't in PsychicTypeSpecies, though it's catchable (an existing gap; shasocastris should decide). If Moltres stays listed, Fire completion becomes impossible.
- `data/pokemon/evo_lines.asm:12` and `safari_move_tutor_moves.asm` already leave legendaries out.
- Diploma: `CeladonMansion3F.asm:16-17` reads `VAR_DEXUNCAUGHT`, `ifless 3 ; ignore Mew and Celebi`. With ten mons uncatchable it must become `ifless 11`. The count comes from `engine/overworld/variables.asm:88-100`.
- Oak's ratings (`data/events/pokedex_ratings.asm`) cap at 248, and 266 mons stay catchable, so no change. Blue's `ifless 151` (`ViridianGym.asm:46`) is still reachable.
- The radio Pokédex show uses caught mons only (`radio.asm:610-633`), so no change.

**Other**
- `engine/events/unown_walls.asm:1-23` (`HoOhChamber`, Ho-Oh leading the party) is registered (`special_pointers.asm:136`) but **nothing calls it**, so it's effectively dead.
- No legendaries in any wild table: grass/water/Kanto/Orange/season/swarm/fish/tree/contest were all grepped. Those `WHIRL_ISLAND_LUGIA_CHAMBER` hits are map names.
- No legendaries in NPC trades, odd eggs or Mystery Gift.
- The debug start party has `givepoke MEWTWO`/`MEW` inside `IF DEF(_DEBUG)` (`PlayersHouse2F.asm:50-239`).
- Seasonal plan conflict: `docs/seasonal_pokemon_implementation_context.md:387,423,497` (D8) moves the **Mew static to the Orange Islands, reusing EVENT_FOUGHT_MEW**. That works the same way for a Mew tutor. Only the "Mythical: Mew" catch line needs dropping.

## 2. Delete or keep?

**(a) Full delete: not recommended.**
- Removing ARTICUNO ($90) renumbers every later species index.
- The save stores 16-bit indexes in `sPokemonIndexTable` (`ram/sram.asm:68,99`), so every existing save would map its IDs to the wrong species.
- `wPokedexCaught`/`wPokedexSeen` (`wram.asm:3022,3035`, flag_array NUM_POKEMON) and `wPokedexOrder` (`:3352`) shrink, which shifts the save block.
- `NUM_KANTO`/`NUM_JOHTO_POKEMON` split `evos_attacks.asm:18-19`.
- About 20 parallel tables and the gen1_order rows would need editing.
- The overworld sprites of six of the deities, the `pokepic` front pics and the cries would be gone. Cutscenes would need new art.

**(b) Keep the data, make them unobtainable: recommended.** The species stay in the dex as "seen-only" lore entries. The deity is never put into a wild battle that lets you catch it. Work per encounter:
1. **Presentation**, built from commands that already exist:
   - The existing object sprite.
   - `cry X`.
   - `refreshscreen` + `pokepic X` + `waitbutton` + `closepokepic`; `PokemonMansion.asm:35-39` already does this.
   - Optionally `loadmonindex 0, X` + `special ShowPokedexEntry` (`specials.asm:29-37`, used at `CeladonCity.asm:31`). This registers the deity as *seen* and splashes its dex page (the Gen-I splash tutorial). It replaces the seen-registration a battle would have done.
2. **Teach** (section 3).
3. **Depart**: `setevent EVENT_FOUGHT_X`, then `disappear`. Do this only on a successful teach.

**No new flags are needed.**
- Birds, Mew, Lugia, Ho-Oh and Suicune reuse their FOUGHT flags and hide flags. Every rematch and story gate above keeps working unchanged.
- Celebi stays one-shot through GS Ball consumption.
- Raikou and Entei use their saved roam struct (`species=0`, `map=GROUP_N_A`) plus EVENT_RELEASED_THE_BEASTS as the "met" state.

**Optional "trial" battle** (a later phase, not v1):
- Add a `BATTLETYPE_DEITY` whose ball throw is blocked. Put the check in `PokeBallEffect` near `item_effects.asm:292-310`, reusing `BallBlockedText` (`:2948`).
- It should also be treated as can-lose.
- Every new battle-type check in `engine/battle/core.asm` costs Battle Core bytes, and that bank was full on the old branch (memory). Keep any such checks in `item_effects` and the overworld scripts.

## 3. The tutor mechanic

**What already exists:**
- `MoveTutor` / `CheckCanLearnMoveTutorMove` (`engine/events/move_tutor.asm:1-89`) checks compatibility through `CanLearnTMHMMove`.
- **`MoveTutorNoCheck`** (`:91-140`) teaches to any chosen mon and returns 0 for taught or -1 for cancelled. It's registered (`special_pointers.asm:130`) but **unused**, and it is the ready-made "pick a mon, teach X" flow.
- Scripts load the move with `loadmoveindex MOVE`, which converts it to the 8-bit ID in wScriptVar (`GoldenrodCity.asm:63-66`).
- `SafariZoneMoveTutor` (`engine/events/safari_move_tutor.asm`) is species-table and evo-line gated. Reuse only its shape: one menu submenu (FadeToMenu…CloseSubmenu) and result codes in wScriptVar. Its tables don't fit, because the gate here is the deity, not the species.

**Compatibility options:**
1. **Any mon**: plain `MoveTutorNoCheck`. Zero data, but OHKO Sheer Cold on anything.
2. **Type-match (default recommendation)**: the mon must share the move's type. That's about 20 lines: read the move type from `Moves`, compare it with the BaseData types, and use the result codes in the Safari style ("can't sense the power"). Thematic and cheap. It depends on part B's final types, for example Inner Light and Fae Blade.
3. **A compatibility bitmask via `add_mt`**: today there are 50 TMs + 8 HMs + 17 tutors = 75 bits, held in 10 bytes (`constants/item_constants.asm:371-400`, `pokemon_data_constants.asm:31`). Ten more makes 85 bits, so BASE_TMHM grows to 11 bytes. That adds +1 byte to every one of about 279 BaseData rows and needs hand-edited tmhm lines. Avoid it.

**Open question for shasocastris:** any mon, type-match, or a curated list?

**One-shot or repeatable:**
- Default: **one teach per deity**. The deity leaves only after `wScriptVar == 0`. If the player cancels, it stays, nothing is set, and it can be re-tried.
- A repeatable variant costs no flags for statics: set FOUGHT as "met" but never `disappear`.
- Since Celebi's GS Ball is consumed, Celebi can only be repeatable if the GS Ball isn't taken. Keep it one-shot.

**Roaming beasts as tutors:**
- Keep the roam system as it is: movement, nests in the dex, and SetSeenMon on release.
- In `RandomEncounter` (`engine/overworld/events.asm:1141-1161`), after `TryWildEncounter`, check `wBattleType == BATTLETYPE_ROAMING`. If it is, call a common `RoamDeityTutorScript` instead of `WildBattleScript` (`:1171`).
- That script does the cry, pokepic and teach. On success it calls a callasm that clears the roam struct, mirroring `core.asm:8768-8777`. On cancel the beast runs off: call `UpdateRoamMons` / `JumpRoamMon`.
- The move is picked from the staged `wTempWildMonSpecies`.
- Because a roamer encounter is a random ~29% roll on its map (`wildmons.asm:638-644`), the player meets it by chance, the same way the roamers work now. The struct state is saved, so no flag is needed.

## 4. Story risks

1. **Rainbow Wing.** Change `BeastsCheck` to "met all three": EVENT_FOUGHT_SUICUNE + EVENT_RELEASED_THE_BEASTS + roam slots 1 and 2 cleared. Otherwise Ho-Oh is unreachable. Celadon Eusine uses the same special and gets fixed with it.
2. **The Tin Tower 1F cutscene** (`:89-112`) and its callback (`:53-75`) use `MonCheck` ("caught it, so it doesn't appear"). Change them to the roam-struct state. Swap the Suicune `loadwildmon`/`startbattle` (`:124-128`) for the tutor scene. Everything after it (flags at `:131-139`, Karen, sages) stays.
3. **Roamer defeat path.** Today, defeating Raikou or Entei clears it forever. With BeastsCheck as written, that already soft-locks the Rainbow Wing in a vanilla-like way. Under the new design no battle happens, so the soft-lock goes away. A save mid-game that already defeated one also counts as "met" **[inferred: desired]**.
4. **Lugia, Silver Wing, Misty.** No catch dependency, so it's safe.
5. **Celebi and Kurt.** `CheckCaughtCelebi` controls Kurt's scene. Replace the battle with the tutor, then show Kurt unconditionally and rewrite `Text_KurtCaughtCelebi` (`IlexForest.asm:912`). BATTLETYPE_CELEBI and `BATTLERESULT_CAUGHT_CELEBI` become dead code but can stay.
6. **Mewtwo** stays a catchable Pokemon Mansion static. Fix its hide-flag bug with EVENT_TOHJO_FALLS_MEWTWO while you're there (optional). Archer keeps his Mewtwo.
7. **Red Gyarados** (`LakeOfRage.asm:74-80`, FORCESHINY) is unrelated and stays.
8. **Kimono Girls / Clear Bell.** In this hack Suicune hands over the Clear Bell (`RuinsOfAlphOutside.asm:620`), and that's a cutscene, not a capture, so nothing breaks.
9. **Link / Time Capsule.** Traded legendaries can still arrive. That's acceptable; just document it.

## 5. Phased plan (build green after each step)

- **P0.** Branch fresh from `core`, then take the optimize.py snapshot. Part B delivers the move constants first. Until it lands, use placeholder existing moves (SKY_ATTACK, AEROBLAST, SACRED_FIRE and AURA_SPHERE already exist: `move_constants.asm:132,158,198,263`).
- **P1, data hygiene:**
  - Replace the 5 Battle Tower species.
  - Remove MOLTRES from `pokemon_type_lists.asm:275`.
  - Change the diploma to `ifless 11`.
  - Update the seasonal doc's Mew line.
- **P2, tutor core:**
  - Add a `DeityMoveTutor` special that wraps `MoveTutorNoCheck`, plus the optional type gate and result codes.
  - Add one shared script macro or std script: cry, pokepic, ShowPokedexEntry, teach, then branch on the result.
- **P3, the five simple statics** (the birds, Mew and Lugia): swap the `loadwildmon`/`startbattle` blocks for the tutor. Keep the flags.
- **P4, Ho-Oh and Suicune** (Tin Tower 1F and the roof), plus the new BeastsCheck logic and the MonCheck replacements. That covers TinTower1F and CeladonPokecenter1F.
- **P5, roamers:** the `RandomEncounter` branch, `RoamDeityTutorScript`, and the struct clear.
- **P6, Celebi:** the shrine tutor and the Kurt rewrite.
- **P7, text pass** (18-character limit): Misty, Wise Trio, Eusine, the sages, Karen and others where "caught" or "battle" wording appears.
- **P8 (optional):** the BATTLETYPE_DEITY trial battle.

## 6. Verification without an emulator

- After each phase, run `make -j` and `make crystal_debug`, then diff `optimize.py`. Also check the bank-free output from the `.map`, especially the banks of `RandomEncounter` and `move_tutor`.
- Source asserts by grep:
  - No `loadwildmon` of any of the ten remains (Mewtwo is allowed).
  - No `BeastsCheck`/`MonCheck` on beasts remains.
  - None of the ten appears in `data/battle_tower`, `data/trainers` or `pokemon_type_lists`.
  - The `const EVENT_` count and NUM_EVENTS are unchanged, which proves no new flags.
- Static flow check: for each map, list every flag set or checked and confirm the gate chain still works. Example: FOUGHT_SUICUNE leads to E4, then new BeastsCheck, then Rainbow Wing, then the roof callback, then FOUGHT_HO_OH, then Morty.
- Per memory guidance, a small Python model of `BeastsCheck` and the roam-struct state is worth having, run over the cases: pre-release, one met, both met, legacy "defeated".
- shasocastris play-test list (I can't check these): each deity scene, the roamer tutor trigger, the Tin Tower sequence, Celebi and Kurt, and the dex seen pages.

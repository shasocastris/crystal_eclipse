# Branch 49: pseudo-abilities research (against core 01727c11f)

## 0. Branch status
- `49-introduce-pseudo-abilities` = core@b77e76998 (May 5) + afa3df7b5. That commit's diff is identical to core's 64da3b201 (same 5 files, same message), and 64da3b201 is an ancestor of core. **The branch has nothing core lacks. It is 309 commits behind.** Recreate it from core rather than rebasing.
- Branches 11, 24, 30 and 32 have **no commits** past their merge-base with core. They are placeholders 600-700 behind. Branch 39 has 2 WIP commits and is 272 behind. So the "interactions" below are with planned work, not with existing code.

## 1. Hook re-verification (spec is stale in several places)

| Spec hook | Current location | Notes |
|---|---|---|
| "StepHappiness / 256-step tick in engine/overworld/events.asm" | **Stale.** `CountStep` events.asm:854 (bank $25, 6647 B free). 256-tick at events.asm:871-876 (`inc [wStepCount]`, `jr nz`). `StepHappiness` itself is in engine/events/happiness_egg.asm:81, **bank $01, 6 B free** | Hook in CountStep after :876, not inside StepHappiness. Poison 4-step tick: events.asm:886-894 → `DoPoisonStep` engine/events/poisonstep.asm:1 (bank $14, 772 B free). CountStep exits early on `wLinkMode` (:856), which branch 11 will remove. |
| Early Bird / Limber / Water Veil / Flame Body "recover after X steps" | **No overworld status decay exists.** Only poison has step logic | Each one has to be defined as "on tick T, cure status S in party". Early Bird's "fewer steps" has nothing to shorten. |
| Encounter rate | `TryWildEncounter.EncounterRate` wildmons.asm:224-230: `GetMapEncounterRate` → `ApplyMusicEffect…` (:245) → `ApplyCleanseTagEffect…` (:262) → `Random`/`cp b`. Bug Contest copy at events.asm:1267-1283 | **Bank $0a has 7 B free (8 debug).** Seasons only swap *tables* (`_SeasonGrassWildmonCheck` wildmons.asm:443/457). The rate is one byte fanned across 4 slots (:1-25). **Weather never touches encounter rate** (no weather refs in wildmons.asm). Sweet Scent (sweet_scent.asm:38) reads only GetMapEncounterRate, so Stench and Illuminate won't affect it. |
| Fish "50%→80%, top of .Fish" | fish.asm:28-31 `call Random / cp [hl]`. Threshold is **per FishGroup** (data/wild/fish.asm:12-25, all `50 percent + 1`) | Bank $24, 1047 B free. Spec is otherwise correct. |
| Compound Eyes "encounter setup" | `LoadEnemyMon` core.asm:6071-6088 (`cp 75 percent + 1`, `cp 8 percent`). WILD_HUNT/FORCEITEM bypass at :6045-6063 | Battle Core $0f. |
| Run Away "flee logic" | `TryToRunAwayFromBattle` core.asm:3746. Scripted no-escape battletypes :3748-3762. Link :3764. Trainer :3768. `SUBSTATUS_CANT_RUN` :3772. Wrap :3776. Smoke Ball path (with text) :3780-3796 | Insert after :3770. That bypasses Mean Look, Wrap and the speed roll, but **not** the TRAP/SUICUNE/CELEBI/WILD_HUNT battle types (recommended). Reuse the Smoke Ball text pattern. |
| Arena Trap "wild flee" | `TryEnemyFlee` core.asm:883 (callers :1002, :1064). Already uses `IsInFarWordArray` on Flee Mons lists (:900-930) | Add a check on `wBattleMonSpecies` beside :888. No text is needed. |
| Intimidate/Frisk/Pressure "battle start" | `DoBattle` core.asm:85-111. The player mon is out after `SendOutPlayerMon` (:90). `StartAutomaticBattleWeather` (:111, defined :9325) is the natural start-of-battle slot. `BattleStartMessage` (:9203) runs **before** the player mon is out, so it is wrong for these. Every switch-in goes through `SendOutPlayerMon` :4077 (callers :90, 2890, 2911, 4069, 5234, 5258). Trainer switch-in: `EnemySwitch` :3195 | Template: `HandleUnownAuraStatBoost` core.asm:475-537 (anim + text + `farcall BattleCommand_UnownAuraStatsBoost` effect_commands.asm:4662). |
| PP deduction (canon Pressure) | `BattleCommand_DoTurn.consume_pp` effect_commands.asm:992-1008 (single `dec [hl]`). Wild PP path :1010-1028 | **Bank $0d has 41 B free.** The spec's Pressure is *not* PP-based (see §4). |
| Stats display | engine/pokemon/stats_screen.asm, bank $13 (8944 B free) | See §5. |

Side note (unrelated): wildmons.asm:340-344 is a chain of `cp`s with no branches between them, so only `cp BATTLETYPE_FORCEITEM` takes effect.

## 2. Shared infrastructure

**Existing ROM0 helpers that cover everything (0 new ROM0 bytes):** `IsInFarWordArray` home/array.asm:42 (a=bank, bc=16-bit species, de=2, hl=list; already used for the flee lists), `LoadIndirectPointer` home/indirection.asm:1, `GetFarByte` home/copy.asm:68, `GetPokemonIndexFromID`, and `farcall` (4 bytes: `rst FarCall` + `dbw`, macros/farcall.asm:3). **ROM0 cost is zero.** All new code and data can go in one floating ROMX section, e.g. bank $22 (10740 B free), $12 (7510) or $75 (11798). Free space is the same in release and debug.

**Spec conflict that drives the format:** 12 species sit on more than one list. AIPOM is on 4 (Pickup, Suction Cups, Limber, Run Away). TEDDIURSA, MURKROW, GRIMER, MUK, LEDYBA, LEDIAN, ARCANINE, PONYTA, RAPIDASH, DODUO and DODRIO are on 2 each. The spec has 115 entries in total; Mr. Mime's constant is `MR__MIME`.

Options:

A. **Per-ability `dw SPECIES … dw -1` lists** (the Flee Mons pattern, main.asm:482). Multiple membership is free.
   - Cost: about 145 entries after the §3 additions, plus 15 terminators, ≈ **320 B** of ROMX.
   - Lookup: `IsInFarWordArray`. Linear scan, cheap at these sizes.
   - Drawback: variants are separate 16-bit indexes (CORSOLA_KANTO, RAICHU_ORANGE, DRAGONITE_KANTO, and 22 more reserved at constants/pokemon_constants.asm:322-360). Each must be added by hand, and if one is forgotten nothing fails. Do **not** resolve through GetVariantBase: that would give Alolan Vulpix Flame Body.

B. **Repurpose the unused base-stats words.** `BASE_FRONTPIC`/`BASE_BACKPIC` (constants/pokemon_data_constants.asm:28-29) are "unused" in all 279 files (`dw NULL, NULL`) and nothing reads them (grep finds only the wram.asm:2417 labels).
   - Cost: **0 B of ROM and 0 B of WRAM.** The 4 bytes allow up to 4 ability IDs per species, or a 32-bit flag set.
   - Every species and variant has its own file, so each new variant is forced to make a choice. Gen 4 evos already have files.
   - Cost: one mechanical edit across 279 files (an `abilities` macro).
   - Read it with a direct helper of ≈20 B: index → `LoadIndirectPointer` on BaseData (bank $43) → `+BASE_FRONTPIC` → `GetFarByte`. Use this rather than `GetBaseData`, which overwrites wCurBaseData. That matters mid-battle and on the stats screen.

C. Add a new ability byte to base stats: +279 B in bank $43 (1064 free) and +1 B of wBaseData. B makes this pointless.

**Recommendation: B, with a single ability byte per species** (the low byte of BASE_FRONTPIC; reserve the rest). It is free, keyed per species index (variants included), and one ability per mon is what a display can show. That means resolving the 12 conflicts in the spec, e.g. AIPOM=Run Away, AMBIPOM=Pickup, GRIMER/MUK=Stench, PONYTA=Run Away/RAPIDASH=Flame Body, LEDYBA line=Early Bird, MURKROW=Compound Eyes→HONCHKROW=Pickup… This is a design decision for shasocastris. If he wants the multi-ability lists kept as written, use B with a bitfield (2 bytes = 16 flags is enough for 15 abilities), and the UI shows the first one only.

Helpers, ≈100 B total in the ability bank:
- `GetSpeciesAbility` (a=ID → a=ability)
- `LeadHasAbility` (wPartySpecies[0], counts fainted mons per spec)
- `PartyHasAbility` (loop over the party; fainted mons are an open question)
- `BattleMonHasAbility` (wBattleMonSpecies)

Each Battle Core hook is a 4 B `farcall` plus a 2 B `jr`.

## 3. Species list audit

**Retiring in branch 39** (all still `const` on core: constants/pokemon_constants.asm:176-183, 277-285): the only affected list is **Pressure**, which loses 8 of 9 and leaves Mewtwo alone. Suggested replacements, canon Pressure holders in the dex: **AERODACTYL, WEAVILE** (and optionally Sneasel, thematic only). No other list contains a legendary.

**Additions for consistency** (c = canon Gen 3-4 ability, t = thematic, extends the spec's line):
- Pickup: AMBIPOM (c). Swinub and Murkrow are not canon Pickup; MAMOSWINE/HONCHKROW only if lines are kept whole.
- Suction Cups: AMBIPOM (t), TANGROWTH (t). GRIMER_ORANGE/MUK_ORANGE when they land.
- Compound Eyes: YANMEGA (t; Yanma is c), TOGEKISS (t), HONCHKROW (t).
- Flame Body: **MAGMORTAR, MAGBY, SLUGMA, MAGCARGO (all c, missing from spec)**. Variants: GROWLITHE/ARCANINE_ORANGE yes (Fire/Rock). VULPIX/NINETALES_ORANGE no (Ice). PONYTA/RAPIDASH_KANTO no (Psychic).
- Shed Skin: **PUPITAR (c)**.
- Early Bird: HOUNDOUR/HOUNDOOM, NATU/XATU, SUNKERN/SUNFLORA, KANGASKHAN (all c). FARIGIRAF (t, from Girafarig).
- Limber: DITTO (c, conflicts with its Suction Cups entry), AMBIPOM (t).
- Water Veil: MANTINE (c, hidden ability) optional.
- Stench: WEEZING_KANTO (t) when it lands.
- Run Away: DUNSPARCE, DUDUNSPARCE, CATERPIE, WEEDLE, VENONAT (c). PONYTA/RAPIDASH_KANTO (c). Magikarp is t.
- Intimidate: GROWLITHE, EKANS, ARBOK, TAUROS, STANTLER, HITMONTOP, WYRDEER (all c). GROWLITHE/ARCANINE_ORANGE (c). Tyranitar is t.
- Frisk: MISMAGIUS (t).
- New Gen 4 evos with no natural slot: Electivire, Leafeon, Glaceon, Sylveon, Gliscor, Magnezone, Porygon-Z, Rhyperior, Lickilicky, Weavile, Annihilape, Sirfetch'd, Ursaluna, Cursola. CORSOLA_KANTO, RAICHU_ORANGE and DRAGONITE_KANTO: none.

## 4. Per-ability analysis

Battle Core $0f has $1b3 (435) B free and Effect Commands $0d has 41 B. Battle text bank $20 has $ed (237) B free in release and $d2 (210) in debug. Keep `BattleText_*` as 5 B `text_far` stubs and put the strings in $6f-$71 (≈9 KB free each).

| # | Ability | Hook / bank | Cost | Text | Notes |
|---|---|---|---|---|---|
| 1 | Stench / Illuminate | Move `ApplyCleanseTagEffectOnEncounterRate` (≈26 B) out of $0a into the ability bank as `ApplyPartyEncounterRateMods`, and farcall it from wildmons.asm:227 and events.asm:1276 | Net **frees** ≈20 B in $0a | none | Halve or double `b`, like Cleanse Tag. `farcall` keeps `b` (proven by events.asm:1275). Trivial. |
| 2 | Suction Cups | fish.asm:28-31, $24 | ≈12 B | none | `cp 80 percent+1` when the lead has it. Trivial. |
| 3-7 | Flame Body (FRZ), Water Veil (BRN), Limber (PAR), Early Bird (SLP), Shed Skin (PSN, 1/3) | One table-driven `StepAbilityCures` farcalled from CountStep after events.asm:876 (bank $25) | ≈60 B + 5×3 B table | optional (silent + SFX is cheapest; a message needs the `.doscript` return path, as DoPoisonStep does) | Low risk. The 256-step tick is slow for a frozen mon, so consider running Flame Body on the 4-step poison tick. |
| 8 | Pickup | Same tick. If the holder's MON_ITEM is empty, roll and store an item via `GetItemIDFromIndex` (no bag-full problem) | ≈40 B + item table | none (Gen 3 style) | Crystal Clear's exact behaviour is not checked (inferred). |
| 9 | Compound Eyes | core.asm:6071-6083: farcall a helper that returns the two thresholds | ≈10 B in $0f | none | Low risk. |
| 10 | Run Away | core.asm:3770/3772 | ≈8 B in $0f | 1 msg ("…fled using RUN AWAY") | Mirror the Smoke Ball path :3792-3796. Low risk. |
| 11 | Arena Trap / Shadow Tag | core.asm:888 | ≈6 B in $0f | none | Wild-flee only, as specced. Low risk. |
| 12 | Intimidate (spec: weak wild mons flee) | **Recommended:** a pre-battle filter in `RandomEncounter` after events.asm:1141 (bank $25), on the `CheckRepelEffect` model (wildmons.asm:401) | **0 B in $0f** | none | In battle instead, it would cost text plus the `WildFled_…` path (core.asm:117). The canon Atk -1 version suits branch 39's stat work better, but needs a switch-in hook and text. |
| 13 | Frisk | One `farcall BattleStartAbilities` at core.asm:110 (4 B, shared with 12/14). Read `wEnemyMonItem` (set at :6092) → `GetItemName` → text | ≈4 B in $0f, ≈40 B elsewhere | 1 msg | Wild only first. Trainers would need `EnemySwitch` (:3195). |
| 14 | Pressure (spec: all 7 enemy stats -1) | Same battle-start farcall. 7 × `farcall BattleCommand_*Down` (effect_commands.asm:4269-4293) from the ability bank, under player turn, with wAttackMissed/wEffectFailed cleared (StatDown fails on these, :4355-4361) | 0 B in $0d, ≈40 B elsewhere | 1 msg | Highest risk: Mist, Substitute and the stat recalculation all interact with it. A canon PP version would sit in $0d (:1006, ≈10 of 41 B) and compete with branch 32. **The list must be rebuilt after branch 39.** |

**Total in Battle Core: about 30 B of 435. Effect Commands: 0. ROM0: 0.**

Cross-branch notes:
- **39** rebases onto Battle Core, which it previously overflowed by 3 B. So keep ability logic out of $0f and use only farcall stubs. Pressure (stat version) is independent of the new weather-setting moves. A PP version would charge extra PP on them, and that is fine. Intimidate as an Atk drop goes through the same StatDown path as the new moves.
- **24** (moves renumbered by type): no impact as long as nothing hard-codes move IDs. The lists are keyed by species.
- **11** (link removal): `wLinkMode` branches sit next to hooks at events.asm:856, core.asm:25/95/540/3764. Abilities that apply to only one side would desync a link battle, so either do 11 first or guard the battle hooks with `wLinkMode`.
- **32** (happiness obedience): probably `BattleCommand_CheckObedience` effect_commands.asm:603 in $0d (inferred), which is another reason to keep Pressure out of $0d. It shares the 256-step tick with StepHappiness but there is no logic conflict. The Orange stats page shows happiness and may also host the ability line.
- **30** (perfect-mon NPC): no interaction while abilities are per species. If a DV-selected second ability is added later, its perfect mons would fix the choice.

**Recommended order:**
1. Infrastructure plus stats-page display.
2. Stench/Illuminate (this also frees $0a).
3. Suction Cups.
4. The five step cures.
5. Pickup.
6. Compound Eyes.
7. Arena Trap.
8. Run Away.
9. Intimidate (overworld version).
10. Frisk.
11. Pressure, after branch 39 settles the legendaries.

## 5. How the player learns a mon's ability (open question)

Stats screen layout (stats_screen.asm):
- **Pink** (:510): the left column is only 9 wide. Rows 10-11 are free but too narrow.
- **Green** (:651): full (item plus 4 moves and PP).
- **Blue** (:691): the left column (cols 0-9) rows 15-17 are free, but only 9 chars wide. "SUCTION CUPS" and "COMPOUNDEYES" are 12 chars.
- **Orange** (:745): no divider. MET AT/location/time on rows 9-11, MET LEVEL 12-13, HAPPINESS 14-15. **Rows 16-17 are free at full width** (ClearBox covers rows 8-17, :481).

Options:
1. **Orange page, "ABILITY/" at (1,16) and the name at (2,17).** This is the best fit. Names are ≤12 chars, so a name table is ≈16×13 ≈ 200 B in $13, plus ≈20 B of code. It works for enemy and box mons too because it reads the species.
2. Blue page lower-left, with names truncated to 9 chars.
3. A Pokédex line. Not examined; inferred to need space on the entry page.
4. NPC or tutorial only (no UI). This is the cheapest option, but players can't see a mon's ability in game.
5. A one-line description on SELECT in the Orange page (≈300 B of text): an optional extra.

A one-ability-per-species model (§2-B) makes option 1 clean. A bitfield would need "first of N" display or paging.

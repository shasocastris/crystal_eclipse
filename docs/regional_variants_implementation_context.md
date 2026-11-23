# Crystal Eclipse — The Variant System (M1, as built)

> **STATUS: M1 IS COMPLETE AND MERGED TO `core`.** This is no longer a plan; it is the
> reference for how variants work and what it costs to add one. Read §4 (layers), the
> roster in §5, and the traps flagged `[STRUCTURAL]` — those are what bite.
>
> **To add a variant**, the short version: promote its name from the reserved roster in
> `constants/pokemon_constants.asm` to a real `const`, then give it a row in all
> thirteen `NUM_POKEMON_AND_VARIANTS` tables, `VariantBaseSpecies`,
> `VariantPokedexEntries`, base stats, a dex entry, a learnset, and its own type-list
> entries. **Its icon must be a fresh copy appended to the end of `gfx/icons.asm`** —
> it cannot reuse its base's. The build will tell you what you missed; every one of
> those tables is length-asserted.

**Branch:** `65-regional-variants`, merged. Cut from `core` after the M0 save-reservation work
**Target:** pokecrystal disassembly, RGBDS, SM83, MBC3
**Roadmap:** `major_systems_roadmap.md` §4. This doc is the implementation spec; the roadmap is the sequencing rationale.

**Status of the design:** the roadmap's §4.1 Phase 0 questions were answered during M0 against the real files, and the §4.3 decisions are settled. **This doc carries those results so M1 does not re-derive them.** Where it contradicts an older draft of the roadmap, this doc is right.

---

## Legend

- **[STRUCTURAL]** — the reasoning is load-bearing. Read the "Why" note before changing it.
- **[PLACEHOLDER]** — plausible example content. Implement as written so there's something to look at; the specifics are shasocastris's to revise.
- **[VERIFY]** — an assumption not yet checked against the files. Confirm before building on it.
- **[VERIFIED]** — checked during M0 against the actual source, with line references.

---

## 1. What M1 is

A **variant species** is a real species — its own base stats, types, sprite, palette and learnset — that does **not** occupy a Pokédex slot. Catching one marks its *base* species as seen/caught, so the dex, the type-completion system and the move-tutor gates all behave as though the player caught the base.

The mechanism is a redirect at `SetSeenMon` / `SetCaughtMon`, plus a constant block appended past `NUM_POKEMON` so that no table indexed by `NUM_POKEMON` is disturbed.

M1 exists first in the roadmap because **M2 and M3 author bulk wild data against the species ID space.** Landing variants after either means revisiting every `dbw level, SPECIES` entry to decide, per entry, whether it should be a base or a variant.

### Test case for this branch

**Corsola.** Johto Corsola is the standard Water/Rock form, unchanged. Kanto Corsola is the Galarian form — called the **Kanto form** in this hack — a pure Ghost-type.

Chosen because Corsola neither evolves nor is evolved into (`db 0 ; no more evolutions` in `data/pokemon/evos_attacks_johto.asm`), which keeps Layer 5's evolution-move risk out of the vertical slice per roadmap §4.3 decision 6.

---

## 2. Verified findings carried in from M0

Do not re-investigate these. Line references are to the tree as of the M0 merge.

### 2.1 The 16-bit species system accepts variant indexes **[VERIFIED]**

`___conversion_table_store` (`engine/16/macros.asm:42-211`, the body of `_GetPokemonIDFromIndex`) is a dynamic slot allocator, **entirely agnostic to the value of the index**. It range-tests exactly twice: the `EGG` case (high byte `$FF`, low byte ≥ `$FD` — `:48-53`, which is what `MON_TABLE_MINIMUM_RESERVED_INDEX EQU $FD` exists for, `EGG EQU -3` = `$FFFD`) and zero (`:55-56`). No comparison against `NUM_POKEMON` appears anywhere in the macro, and `___conversion_table_load` keys on the 8-bit slot number, not the species value.

`NUM_POKEMON` is already `$113` (275), so indexes past 255 are in daily use.

> **[STRUCTURAL] The only constraint on a variant index: non-zero, and outside `$FFFD`–`$FFFF`.** Appending after `NUM_POKEMON` satisfies both. Do not place variants at negative constants alongside `EGG`.

### 2.2 `ValidateTempWildMonSpecies` rejects them — the one real blocker **[VERIFIED]**

`engine/overworld/wildmons.asm:805-821`. `LOW(NUM_POKEMON)` is `$13`, so the `else` arm assembles and the routine returns carry — invalid — for any index `> $113`. The caller acts on it immediately:

```
	call ValidateTempWildMonSpecies
	jr c, .nowildbattle          ; wildmons.asm:351-352
```

> ⚠️ **[STRUCTURAL] A variant in a grass or water table is silently discarded.** No crash, no assembler error — the player walks through grass or surfs and nothing happens, at whatever rate that slot occupies. **Fix this in Phase 1, before any variant reaches a wild table.**

### 2.3 The fishing path has no such gate **[VERIFIED]**

`engine/events/fish.asm` calls `GetPokemonIDFromIndex` at `:65` with **no `NUM_POKEMON` bound check anywhere in the file**. Fishing would accept a variant index today, without the Phase 1 fix.

This is a trap rather than a convenience: it means a fishing-only test would pass while leaving the grass/water blocker undetected, and M2/M3 author their bulk data against the grass/water path. **The vertical slice must use a water table, not a fish group** — see §4.

### 2.4 Locked-ID pool: no new requirement **[VERIFIED]**

The pool is a script-level opt-in. `ResetMapLockedIDs` (`engine/overworld/warp_connection.asm:17-36`) *clears* all eight `LOCKED_MON_ID_MAP_*` slots on every map load, and only the `loadmonindex` script command (`engine/overworld/scripting.asm:2251-2266`) fills them.

A wild variant needs nothing: the allocation is protected by the 8-entry recent-allocation ring, and by battle start the value lives in `wBattleMonSpecies` / `wEnemyMonSpecies`, both scanned by the garbage collector (`engine/16/table_functions.asm:41-42`). A variant referenced by a *map script* needs a lock for exactly the same reason a base species would.

### 2.5 Type-completion GC churn — pre-existing, not M1's problem **[VERIFIED]**

`engine/battle/type_completion_boosts.asm:152-153` round-trips every species in a type list through `GetPokemonIDFromIndex` / `GetPokemonIndexFromID`. The round trip is a **no-op on the value**, but the first leg allocates a table slot per species. Water's list is 50 entries against `MON_TABLE_ENTRIES EQU 100`, so two consecutive different-type damage calculations force a full garbage collection *inside the damage formula*.

Locked entries and the recent-allocation ring survive collection by design (`___conversion_bitmap_initialize`, `engine/16/macros.asm:274-297`). Unprotected: any 8-bit mon ID in a variable outside the collector's fixed list — `wCurPartySpecies` most obviously.

> **M1 does not worsen this**, because variants never enter the type lists (§3, Layer 3). Do not fold a fix into this branch; it deserves its own pass.

---

## 3. Decisions — settled, do not re-open

Recorded in roadmap §4.3 with full reasoning. Summary:

| # | Decision | Answer |
|---|---|---|
| 1 | Variants count toward type completion? | **Yes** — via the Layer 4 redirect, no extra code |
| 2 | Safari tutor line gate includes variants? | ~~**No**~~ **AMENDED: yes, per form** — see §4 Layer 4 |
| 3 | Variant occupies a Pokédex slot? | **No** |
| 4 | Sabrina rematch trigger | Not a separate decision — it *is* decision 1 |
| 5 | Nickname default | **Base species name** — `CORSOLA_KANTO` displays as "CORSOLA" |
| 6 | First variant part of an evolution line? | **No** — standalone, non-evolving |

### 3.1 What decision 1 means concretely for Corsola **[STRUCTURAL — read this]**

The Kanto form is pure **Ghost**. Under the Layer 4 redirect, catching it marks **`CORSOLA`** caught — and `CORSOLA` sits in `WaterTypeSpecies` and `RockTypeSpecies`, not `GhostTypeSpecies`.

So catching a Ghost-type Pokémon ticks the player's **Water and Rock** completion progress, and does nothing for Ghost. `GhostTypeSpecies` is 6 entries and stays exactly as it is.

That is the correct behaviour under the recorded decision, and it is also slightly strange to a player who thinks about it. It is listed as open question #1 in §9 — not because the implementation is in doubt, but because it is the first concrete instance of a rule that will recur for every future variant whose typing differs from its base.

---

## 4. Layer-by-layer specification

The roadmap's seven layers, made concrete. Layers are ordered by dependency, not by phase; §5 maps them onto commits.

### Layer 1 — Constant block **[STRUCTURAL]**

In `constants/pokemon_constants.asm`, **after `DEF NUM_POKEMON EQU const_value - 1` and its `if NUM_POKEMON > 999` guard, and before the `; Unown forms` block.**

> ⚠️ **The roadmap says "at the end of the file, after `EGG`". That is wrong.** The Unown block opens with its own `const_def 1`, which resets `const_value` to 1. Anything placed after it gets Unown's numbering, not the species numbering. Placement is between `DEF EGG EQU -3` and `; Unown forms`.

```
; --- VARIANT SPECIES (no Pokédex entries) ---
; Real species with their own stats, sprites and learnsets, appended past
; NUM_POKEMON so that every table indexed by NUM_POKEMON is unaffected.
; They redirect to their base species for all Pokédex purposes — see
; GetVariantBase. NOT dex entries; do NOT add them to any dex-ordered table.
DEF VARIANTS_START EQU const_value

	const CORSOLA_KANTO ; Galarian Corsola; Kanto coastal waters

DEF NUM_VARIANTS EQU const_value - VARIANTS_START
DEF NUM_POKEMON_AND_VARIANTS EQU const_value - 1
```

With one variant: `VARIANTS_START` = 276 (`$114`), `CORSOLA_KANTO` = 276, `NUM_VARIANTS` = 1, `NUM_POKEMON_AND_VARIANTS` = 276.

**Naming.** `MR__MIME` uses a double underscore because its display name contains a period; that is not a general variant convention. `CORSOLA_KANTO` — base species, then region suffix — is the pattern to follow.

### Layer 2 — `VariantBaseSpecies` lookup **[STRUCTURAL — BUILT, differs from the original sketch]**

`data/pokemon/variant_bases.asm`, **indexed directly** by `species index - VARIANTS_START`:

```
VariantBaseSpecies:
	table_width 2
	dw CORSOLA ; CORSOLA_KANTO
	assert_table_length NUM_VARIANTS
```

`GetVariantBase` lives in **`home/pokedex_flags.asm` (ROM0)**, not a banked engine file. In: `de` = 16-bit species index. Out: `de` = base index, or unchanged. Preserves `bc` and `hl`; clobbers `a`. 24 bytes.

Three deviations from the original sketch, all deliberate:

- **Direct index, not a `-1`-terminated search.** Constant time, and 2 bytes per entry instead of 4. The cost is that variants must stay contiguous and in the same order as the const block; `assert_table_length NUM_VARIANTS` catches a count mismatch but **cannot catch a reordering** — keep the two lists in step by hand.
- **ROM0, not banked.** The call site is ROM0 and the Pokédex list builders call it in a loop over every species, so a `farcall` per check wasn't worth it. ROM0 had 338 bytes free after the change.
- **`de`, not `hl`.** At the call site `hl` already holds the flag array pointer.

> ⚠️ **[STRUCTURAL] The position arithmetic is an 8-bit subtract**, which only works while every variant shares a high byte with `VARIANTS_START`. Guarded by
> `assert HIGH(VARIANTS_START) == HIGH(NUM_POKEMON_AND_VARIANTS)`.
> That allows variant indexes up to `$01FF` — 236 of them at present numbering. Past that the assert fires and the routine needs a real 16-bit subtract.

### Layer 3 — Tables that grow **[STRUCTURAL]**

Change each `assert_table_length NUM_POKEMON` (or `+ 1`) to `NUM_POKEMON_AND_VARIANTS` and append one entry.

| Table | File | Corsola-Kanto entry |
|---|---|---|
| `PokemonNames` | `data/pokemon/names.asm` | `"CORSOLA"` — base name, per decision 5 |
| `BaseData` | `data/pokemon/base_stats.asm` | new `base_stats/corsola_kanto.asm` + `INCLUDE` |
| `EvosAttacksPointers` | `data/pokemon/evos_attacks.asm` | `dw CorsolaKantoEvosAttacks` |
| `PokemonCries` | `data/pokemon/cries.asm` | reuse an existing `CRY_*` at a new pitch/length — no new cry data |
| `IconPointers` | `data/pokemon/icon_pointers.asm` | needs its **own** icon in "Mon Icons 3" — see the bank trap below |
| `MonMenuIconPals` | `data/pokemon/menu_icon_pals.asm` | new `icon_pals` pair; base is `PINK, TEAL` |
| `PokemonPicPointers` | `data/pokemon/pic_pointers.asm` | front + back, new pics |
| `PokemonPalettes` | `data/pokemon/palettes.asm` | normal + shiny |
| `AnimationPointers` | `gfx/pokemon/anim_pointers.asm` | new or reused animation |
| `AnimationIdlePointers` | `gfx/pokemon/idle_pointers.asm` | ditto |
| `BitmasksPointers` | `gfx/pokemon/bitmask_pointers.asm` | ditto |
| `FramesPointers` | `gfx/pokemon/frame_pointers.asm` | ditto |
| `FirstEvoStages` | `data/pokemon/first_stages.asm` | `dw CORSOLA_KANTO` — itself, since it doesn't evolve **[VERIFY]** against `engine/pokemon/evolve.asm:605-608` |

**Tables that must NOT grow.** `PokedexDataPointerTable`, `wPokedexCaught` / `wPokedexSeen`, `wPokedexOrder`, `AlphabeticalPokedexOrder`, `NewPokedexOrder`, `PokemonTypeLists` and its 18 species lists, `PokemonEvoLines` and its `*Line` lists, `Pokered_MonIndices`, `KantoMonSpecials`, `Footprints`.

> **Because every one of those asserts against `NUM_POKEMON`, and Layer 1 leaves `NUM_POKEMON` unchanged, the don't-grow set needs no edit at all.** The asserts stay green on their own. That is the whole point of appending past `NUM_POKEMON` rather than raising it.

> ⚠️ **The header comment at the top of `constants/pokemon_constants.asm` is stale — do not use it as the checklist.** It names `EggMovePointers` and `data/pokemon/egg_move_pointers.asm`, which **do not exist** (egg moves were removed; the comment is the only surviving reference). It gives the wrong path for `EvosAttacksPointers`. And it **omits `MonMenuIconPals` and `FirstEvoStages` entirely** — both species-indexed, both in the grow list above. Fixing that comment is part of this branch.

> ⚠️ **[STRUCTURAL] A variant cannot reuse its base species' icon by pointer.**
> `GetIconBank` (`engine/gfx/mon_icons.asm`) derives the icon's ROM bank from the
> **species index**, not from where the data is:
>
> ```
> 	cp HIGH(HONCHKROW) ; first species in "Mon Icons 3"
> ```
>
> Every variant index is past `HONCHKROW`, so a variant's icon is always fetched from
> **"Mon Icons 3"**. Pointing `IconPointers` at a base icon in another bank gives the
> right offset in the wrong bank and draws garbage — `DRAGONITE_KANTO` read
> `$7d:4a01`, one byte into `CursolaIcon`. Append every variant icon to the end of
> `gfx/icons.asm`. The first three variants only worked because their placeholder
> icons landed there anyway.
>
> **Icons are the only table with this trap.** `PokemonPicPointers` and
> `FramesPointers` use `dba` and carry their own bank; the animation, idle and bitmask
> pointer tables each share one bank with their data.

> ⚠️ **[STRUCTURAL] Icon colour is nearly fixed.** All eight entries in
> `gfx/stats/party_menu_ob.pal` share the same second colour, `RGB 31,19,10`, and
> `GetMonPalInBCDE` returns that plus the chosen accent — so an icon always shows that
> orange plus one `PAL_ICON_*` accent, and the nibble in `MonMenuIconPals` is a
> **hardware OBJ palette index**, so a ninth palette cannot be added. To recolour a
> variant's icon, redraw it so the body pixels use the accent index instead of the
> shared one. `gfx/icons/dragonite_kanto.png` is Dragonite's icon with exactly that
> change: its 86 shared-orange pixels folded into the accent, silhouette untouched.

**Bank headroom.** `BaseData` uses a single `indirect_entries NUM_POKEMON, BaseData1` group, unlike `EvosAttacksPointers`' three. Adding entries may overflow its bank; the assembler will say so. If it does, split it the way `evos_attacks.asm` is split rather than shuffling unrelated data.

### Layer 4 — Dex redirect **[STRUCTURAL — BUILT]**

**This is the entire mechanism** by which variants count toward the base species — the dex, the type-completion boost, the Sabrina rematch and Prof. Oak's rating all read the same flag arrays.

Hooked at **`FlagActionBaseOne`** in `home/pokedex_flags.asm`, which is the single point all eight entry points funnel through: `SetSeenAndCaughtMon`, `SetSeenMon`, `SetCaughtMonIndex`, `SetSeenMonIndex` and the four `Check*` equivalents. One `call GetVariantBase` covers every path.

> **[STRUCTURAL] Redirecting the `Check*` paths is required, not a bonus.** Without it a variant would set the base species' bit and then read back its own, reporting not-caught for a mon sitting in the player's party.
>
> It is also a **bounds fix**. `wPokedexSeen` / `wPokedexCaught` are `flag_array NUM_POKEMON`, and the last byte has unused tail bits. An unredirected variant index sets one of those, and `CountSetBits16` runs over the whole byte range — so the dex count silently gains a phantom mon. This is why no code path may write a raw variant index into the flag arrays.

**There was one deliberate bypass, and it became a bug. [AMENDED]** `CheckLineCaughtFlag` in `engine/events/safari_move_tutor.asm` was a local copy of the caught-flag logic that read `wPokedexCaught` directly, on the reasoning that `*Line` lists hold base species only, so no redirect was needed — and that per decision 2 variants would never become line members.

Decision 2 has since been reversed, the same way decision 1 was: **a variant may appear in a `*Line` list, and means that form specifically.** The bypass then fails silently — a variant index tests a bit in the unused tail of `flag_array NUM_POKEMON`, a real bit that nothing ever sets, so the line reports incomplete forever with no error and no crash.

It now calls **`CheckCaughtFormIndex`**, and the local copy is deleted. That routine answers all three cases: a variant reads `wVariantCaught`, a base species that *has* a variant reads `wVariantBaseCaught`, and an ordinary species falls through to the shared Pokédex bit. It is in ROM0, so the tutor stays bank-independent as its header comment intended.

> ⚠️ **[STRUCTURAL] Listing a species that has a variant now means that form specifically.** `RAICHU` in `PichuLine` means the *Kanto* Raichu, not "either Raichu". With `RAICHU_ORANGE` listed as well, the line requires **both** forms. Adding a variant to an existing line therefore hardens that line's gate mid-playthrough — the retroactive-hardening problem decision 2 originally existed to prevent, now accepted knowingly.
>
> **Any other code that reads `wPokedexCaught` or `wPokedexSeen` directly is this bug waiting to happen.** There are no remaining direct readers outside `home/pokedex_flags.asm`; check before adding one.

### Layer 5 — Learnset

One `evos_attacks` block per variant. For Corsola-Kanto:

```
CorsolaKantoEvosAttacks:
	db 0 ; no more evolutions
	; ... level-up moves
```

**Not exercised by this branch**, per decision 6. When a future variant does evolve, verify the evolution-move system (`wEvolutionOldSpecies` as the evolution-vs-level-up discriminator) across all three paths: evolution, Rare Candy, battle level-up.

### Layer 6 — Wild encounter injection **[STRUCTURAL]**

**The region split is pure data. Do not write a runtime region check.**

`_JohtoWildmonCheck` already dispatches between `JohtoWaterWildMons` and `KantoWaterWildMons` by map. Putting the base in one table and the variant in the other *is* the Johto/Kanto split, with zero engine code.

> ⚠️ **[STRUCTURAL] Fish groups cannot do this.** `FISHGROUP_*` is a per-map field in `data/maps/maps.asm`, and the groups are **not region-partitioned** — `FISHGROUP_SHORE` covers Olivine and Route 19; `FISHGROUP_OCEAN` covers New Bark, Olivine, Routes 26/27/41 *and* Cinnabar, Pallet, Vermilion, Routes 20/21. A fishing-based split would require new `FISHGROUP_*` constants and reassigning Kanto coastal maps. It would also skip the §2.2 blocker entirely (§2.3), which is the opposite of what the slice needs to prove.

**Current Corsola availability, unchanged by this branch:** fishing only, via `FISHGROUP_SHORE` → `TimeFishGroups` entries 0 and 1 (`data/wild/fish.asm:212-213`), day slot. Nite is Staryu. Johto Corsola is not a surf encounter today and stays that way.

**Placement for the Kanto form [PLACEHOLDER]:** one slot in a `KantoWaterWildMons` coastal entry. `ROUTE_19` (`data/wild/kanto_water.asm:68-73`) is the natural home — it currently runs `TENTACOOL / TENTACOOL / OCTILLERY` at 6%. `NUM_WATERMON` is 3, so this replaces a slot rather than adding one:

```
	def_water_wildmons ROUTE_19
	db 6 percent ; encounter rate
	dbw 35, TENTACOOL
	dbw 30, TENTACOOL
	dbw 35, CORSOLA_KANTO
	end_water_wildmons
```

### Layer 7 — Battle display

No special-casing. Variants have real entries in every table the battle engine reads.

---

## 5. Phases

Each phase is a commit. Prefix `variants:` per roadmap §2.

### Phase 1 — Unblock the wild path **[DONE]**

Fix `ValidateTempWildMonSpecies` to bound against `NUM_POKEMON_AND_VARIANTS`. Requires Layer 1 to exist, so the constant block lands here too.

> **[STRUCTURAL]** The routine's `if LOW(NUM_POKEMON) == $FF` branch is resolved **at assembly time**, so the replacement constant's low byte decides which arm assembles. `NUM_POKEMON_AND_VARIANTS` = 276, `LOW` = `$14`, so the `else` arm still assembles and the shape is unchanged. **If a future variant count pushes the low byte to `$FF`, the other arm takes over** — re-read the routine then rather than assuming.

**Acceptance:** builds clean; no new `optimize.py` warnings; `VARIANTS_START` and `NUM_POKEMON_AND_VARIANTS` resolve to 276.

### Phase 2 — Table extension **[DONE]**

Layer 3, all thirteen tables, plus the stale header comment. No graphics yet — point the new pic/palette/animation entries at Corsola's existing assets so the branch stays buildable.

**Acceptance:** builds clean. Every `assert_table_length` green. A debug poke of `CORSOLA_KANTO` into `wBattleMonSpecies` shows base Corsola's sprite and the new stats.

### Phase 3 — `GetVariantBase` and the dex redirect **[DONE — code complete, untested on hardware]**

Layers 2 and 4.

**Acceptance:** catching `CORSOLA_KANTO` sets the **`CORSOLA`** seen and caught bits, and no others. Dex count increments by exactly one. Dex entry shows base Corsola.

### Phase 4 — Graphics

Real sprites, palettes and animation for the Kanto form. `gfx/pokemon/corsola_kanto/` mirroring `gfx/pokemon/corsola/`: `front.png`, `back.png`, `front.dimensions`, `normal.gbcpal`/`shiny.pal`, `anim.asm`, `anim_idle.asm`, `bitmask.asm`, `frames.asm`, plus `INCBIN`s in `gfx/pics.asm`.

**Acceptance:** correct sprite and colours in battle, party menu and PC, normal and shiny.

### Phase 5 — Wild injection **[BUILT, NEVER CLEANLY VERIFIED — see §10]**

Layer 6. `CORSOLA_KANTO` into `KantoWaterWildMons`.

**Acceptance — this is the vertical slice:**
- Surfing on Route 19 yields Kanto Corsola at the expected rate.
- Surfing anywhere in **Johto** never yields it.
- Fishing in Johto still yields **base** Corsola, day only, unchanged.
- Catching it registers **`CORSOLA`** in the dex.

**Do not proceed past this point until all four hold.** This is what proves the Phase 1 fix and the whole design.

### Phase 6 — Learnset and polish **[DONE]**

Layer 5 landed: `CorsolaKantoEvosAttacks` plus its own TM list. `flee_mons.asm` now lists `CORSOLA_KANTO` alongside base Corsola (`df3ae43d2`, which also moved the tables out of Battle Core behind a bank switch — still the branch's biggest untested regression risk). The §7 sweep is 9 of 14 verified.

### Phase 7 — Pokédex form view **[BUILT — behaviour below is what shipped, not a plan]**

START on a dex entry swaps between a species' forms. Requested by shasocastris; **not** part of the roadmap's M1 acceptance.

**Decisions [ANSWERED — shasocastris]**

| Decision | Answer |
|---|---|
| Control | **START**, independent of SELECT/shiny, so a shiny variant is viewable |
| Gate | **None.** The indicator shows for any species that has a variant |
| Indicator | `START ▸ FORM` to the **right** of `SELECT ▸ SHINY` |

#### No per-form state, and why **[STRUCTURAL — do not re-add without reading this]**

An earlier build tracked seen and caught per form, in four saved flag arrays, so the dex could hide a variant until met and open on whichever form the player had actually seen. **That was removed deliberately.**

- It cost the **entire M0 dex reservation**, capping the project at 8 variants before a save-format break, to conceal something the dex leaks cheaply anyway.
- It was **not** where the difficulty came from. Of the four bugs this screen produced, three were inherent to having a form view at all — the freeze came from `Pokedex_GetSelectedMon`'s side effects behind the indicator check, and the type and sprite lags came from `Init` and `Reinit` disagreeing about when `wTempSpecies` and the mon tiles are settled.

**Two bits survive**, and they are display truth rather than concealment: `wVariantCaught` and `wVariantBaseCaught` back the per-form caught markers. The shared Pokédex bit is set by *either* form — that is decision 1 working, and it keeps the dex count and type-completion gates correct — so it cannot say which form was actually caught. `CheckCaughtForm` asks these instead.

The dex therefore always opens on the base form, and `wPokedexVariantToggle` (`$c68d`, WRAM0, session state) is cleared on entering an entry, on the post-catch screen, and on backing out to the listing.

The redirect still means catching a variant marks the **base** species seen and caught — that is Layer 4 working, and it is why the dex count and type-completion gates are unaffected.

#### Routines

| Routine | Where | Notes |
|---|---|---|
| `GetSpeciesVariant` | `home/pokedex_flags.asm` | base index → variant index; `VariantBaseSpecies` only maps the other way |
| `Pokedex_GetDisplayedMon` | `engine/pokedex/pokedex.asm` | wraps `Pokedex_GetSelectedMon`, yields the variant when toggled |
| `Pokedex_SelectedMonHasVariant` | ditto | carry set when the species has a variant; now just wraps `GetSpeciesVariant` |
| `Pokedex_DrawFormIndicator` | ditto | separate from the BG draw on purpose, see below |
| `CheckCaughtForm` | `home/pokedex_flags.asm` | "was *this form* caught?" — backs the Pokédex ball and the battle HUD's owned marker |
| `SetVariantCaught` | ditto | hooked at `SetCaughtMonIndex`; sets the variant's bit or the base's, whichever was caught |

#### Hard-won facts — read before touching this screen again

Each of these cost a test cycle.

- **`Pokedex_GetSelectedMon` is NOT a pure read.** It writes `wTempSpecies`, locks `LOCKED_MON_ID_DEX_SELECTED`, and indexes `wPokedexOrder` by the listing cursor — which is meaningless on any screen not reached through the list. Calling it from the entry screen's BG draw **froze the game** on every first catch: garbage index into the 16-bit allocator, whose `.no_room` path is documented as not exiting until slots are freed. Use `wTempSpecies` for detection instead.
- **`Pokedex_DrawDexEntryScreenBG` farcalls `DisplayDexMonType`** (`pokedex.asm:1341`), which reads `wTempSpecies`. Every path must settle the displayed form *before* the BG draw or the types render one form behind.
- **`Pokedex_InitDexEntryScreen` does not load the mon sprite.** Reinit and the toggle handler call `Pokedex_LoadSelectedMonTiles`; Init inherits whatever the listing left in VRAM. Since the listing loads through the same form-aware routine, the sprite on entry was chosen by the *previous* entry's toggle — which looks exactly like an inverted flag and is not.
- **`wNamedObjectIndex` aliases `wTempSpecies`** (`ram/wram.asm:2420-2426`). That is why pointing AREA at `Pokedex_GetDisplayedMon` works: `FindNest` reads `wNamedObjectIndex`.
- **`Pokedex_ReinitDexEntryScreen` draws the BG before `Pokedex_LoadCurrentFootprint` updates `wTempSpecies`.** Anything species-dependent in the BG draw must therefore be sequenced explicitly, not assumed.
- **`FlagAction` answers in `c`.** Read it *before* any `pop bc` restores the caller's value. Getting this wrong made `CheckVariantCaught` return whatever the caller happened to have in `c` — non-deterministic, and it presented as a design problem rather than a bug. The same slip was in the removed per-form gating, so that gating was very likely never working; the "both entries show with only one form caught" report that prompted removing it was probably this. Pops do not disturb the flags, so `ld a, c` early and `and a` after the pops is the safe shape.
- **`GetDexEntryPointer` branches on whether the species IS a variant**, not on the toggle. The post-catch screen shows a caught variant without the toggle ever being set.

#### Sites deliberately NOT form-aware

`Pokedex_GetSelectedMon` is still used by the listing, its seen-checks, and `Pokedex_LoadCurrentFootprint`. `Footprints` is sized `NUM_POKEMON`, and the listing must never navigate variant indexes.

#### Tiles

`START` is `$41`–`$43` (pre-existing, from `String_START_SEARCH`). `FORM` is `$62`–`$64`, drawn by shasocastris. Those four tiles used to be the footprint scratch buffer; the footprint moved to `FOOTPRINT_TILE EQU $71`. **Every blank tile in `pokedex.png` is spoken for** — `$31`/`$32` are referenced by `pokedex_3.asm`, and the rest was scratch. `$75`–`$7e` are free but outside the `pokedex.png` block, so they need their own load.

#### Kanto Corsola's entry

`data/pokemon/dex_entries/corsola_kanto.asm` — classification `CORAL`, height `200` (2'00"), weight `1`. **Weight is whole pounds in this hack** (Corsola 11, Onix 463, Snorlax 1014), not the tenths vanilla uses.

### Phase 8 — A variant that evolves **[DONE]**

Target: `CORSOLA_KANTO` evolves into `CURSOLA` at level 38.

Phases 1–7 deliberately used a **standalone, non-evolving** variant (§3 decision 6) to keep evolution out of the vertical slice. This is where that debt is paid.

`CURSOLA` is a real species at index 276, and `CORSOLA_KANTO` moved to 277. Adding it cost five tables that had never had to grow — both dex orderings, `PokedexDataPointerTable`, `Footprints` and `Pokered_MonIndices` — and nothing in the save block, since `flag_array 275` is 35 bytes and 35 bytes hold 280 bits. Species 281 is the next one that costs anything.

Its sprites were already in `gfx/pokemon/cursola/`, drawn and unreferenced. **Look for pre-drawn art before making a placeholder** — `gfx/pokemon/raichu_orange/` and `gfx/pokemon/pikachu_surf/` were found the same way, by listing `gfx/pokemon/*/` and grepping each name for a reference. The icon and footprint are still placeholder copies of Corsola's.

**What the evolution walker already does.** Evolution entries are variable width, and `SkipEvolutions` (`engine/pokemon/evolve.asm`) decodes the width from the *method byte*:

| Method | Macro | Bytes |
|---|---|---|
| `EVOLVE_LEVEL`, `EVOLVE_HAPPINESS` | `dbbw` | 4 |
| `EVOLVE_ITEM` | `dbww` | 5 |
| `EVOLVE_STAT` | `dbbbw` | 5 |

Everything that walks an `EvosAttacks` block relies on that classification. **Any new method must fit it or teach every walker its width** — that is the main structural constraint on Phase 10.

**Acceptance:** a Kanto Corsola reaches 38 and becomes Cursola, by level-up in battle *and* by Rare Candy. The Pokédex, the form view, the caught markers and type completion all behave sensibly for both members of the line.

### Phase 9 — Evolution moves for a variant line **[DONE]**

Target: `CURSOLA` always learns `HYPNOSIS` on evolving.

The mechanism exists: `LEARN_EVO_MOVE` in an `EvosAttacks` learnset, discriminated at runtime by `wEvolutionOldSpecies` (`engine/pokemon/evolve.asm:411`, `:503`, `:542`, `:564`). Roadmap §4.2 Layer 5 flags this as needing verification across **all three paths** — evolution, Rare Candy, and battle level-up — because they set `wEvolutionOldSpecies` from different places (`evolve.asm:32`, `:253`, `item_effects.asm:1481`, `battle/core.asm:7587`).

**Result.** `dbw LEARN_EVO_MOVE, HYPNOSIS` at the head of `CursolaEvosAttacks`, per the convention the other 55 evolution moves follow (first in the learnset, not last).

All three paths were traced against the source and behave correctly:

| Path | Sets `wEvolutionOldSpecies` | Compares | Effect |
|---|---|---|---|
| Evolution | `evolve.asm:32`, cleared at `:253` *after* `LearnLevelMoves` | old ≠ new | learned unconditionally |
| Rare Candy | `item_effects.asm:1478-1481`, same value as `wTempSpecies` | equal | falls to the level test against 101, skipped |
| Battle level-up | `core.asm:7573-7587`, both from `wCurSpecies` | equal | skipped at every level |

> **[STRUCTURAL] The shape depends on `GetNextEvoAttackByte` preserving flags** across the two move-index reads — `cp b` sets the flags, then two far reads happen before `jr nz`. It does: `GetFarByte` brackets itself with `push af` / `pop af`, and `Bankswitch` is `ldh` / `ld` / `ret`, which touch no flags. Do not "optimise" either routine without re-reading this.

Still wants shasocastris's eyes in BGB: that Cursola actually knows Hypnosis after evolving, by both battle level-up and Rare Candy, and does not relearn it at 39.

### Phase 10 — `EVOLVE_REGION` **[DONE]**

Pikachu takes a **Thunder Stone in both regions**; the gate picks which Raichu it
becomes. The gate **composes with every method**, which is why it is a gate and not a
fifth method — that is a property of the mechanism, not something the shipping data
exercises. See the warning below.

`RegionCheck` (`engine/overworld/landmarks.asm`) returns `e` = 0 Johto, 1 Kanto, from
`wMapGroup` / `wMapNumber` via the landmark. It is now exported (`RegionCheck::`),
because `home/map.asm` is a different object file.

#### Encoding **[STRUCTURAL]**

```
	db   EVOLVE_REGION, JOHTO_REGION
	dbww EVOLVE_ITEM, THUNDERSTONE, RAICHU_ORANGE
	db   EVOLVE_REGION, KANTO_REGION
	dbww EVOLVE_ITEM, THUNDERSTONE, RAICHU
	db 0 ; no more evolutions
```

Two bytes, guarding the **single entry that follows**, whatever method that entry
uses. Plain `db` — there is no `dbb` macro in this tree, and one is not worth adding.

- **Gates do not nest.** A gate guarding a gate is not handled by any walker.
- **The region is a whole byte.** M3's third region needs no re-encoding; only
  `NUM_REGIONS` moves. This is the trap §5 warned about, avoided.
- Rejected: a flag bit in the method byte (every `cp EVOLVE_*` across four sites
  becomes a masked compare) and a region field on every entry (a byte on each of
  ~250 existing evolutions, and every `evos_attacks` file rewritten).

#### The three walkers

Every walker that decodes entry width from the method byte had to learn a 2-byte
entry that does not terminate the block:

| Walker | Where | Change |
|---|---|---|
| `SkipEvolutions` | `evolve.asm` | `inc hl` once and loop |
| `EvolveAfterBattle` | `evolve.asm` `.loop` | evaluate or skip the guarded entry |
| `DetermineEvolutionItemResults` | `evolve.asm` | honours the gate; see below |

It was **four** until the Move Reminder stopped carrying its own inlined copy — see
§10. Check for a fourth again before adding a sixth opcode.

> ⚠️ **[STRUCTURAL] In `EvolveAfterBattle` the gate is handled *before* the
> `wLinkMode` check.** That path skips entries through `.dont_evolve_check`, which
> decodes width from `b` — and would read a gate as a 4-byte entry and desynchronise
> the rest of the walk. Anything else that jumps into that chain must intercept the
> gate first too.

`DetermineEvolutionItemResults` **honours** the gate rather than stepping over it, so
the party menu's ABLE / NOT ABLE column and the Moon Ball multiplier are truthful by
region. Out of region it skips the guarded entry *without matching the item*, which is
why it cannot simply re-enter the normal dispatch.

#### `wCurRegion`

The M0 byte reserved for a cached `RegionCheck` is now live. Refreshed by
`UpdateCurRegion` (ROM0, `home/map.asm`) from `CopyMapPartialAndAttributes` — the one
point `LoadMapAttributes` and `LoadMapAttributes_SkipObjects` share, and after
`wMapGroup` / `wMapNumber` are set for the map being loaded. Cached rather than asked
because the party menu needs it once per party member.

It is a *saved* byte, so after a Continue it holds the previous session's value until
the first map load — which happens during the continue sequence, before the player can
reach a menu. A new game zeroes it, which is `JOHTO_REGION`, which is where the player
starts.

#### Which region an off-overworld evolution belongs to

Settled, and there was nothing to decide: **link mode cannot evolve at all**
(`evolve.asm:63-65` jumps straight to `.dont_evolve_check` when `wLinkMode` is
non-zero), so trades never reach a region test. Rare Candy and post-battle level-up
both run with a live `wMapGroup`. `RegionCheck` already handles the two awkward maps
itself: S.S. Aqua is forced Johto, and `LANDMARK_SPECIAL` maps fall back to
`wBackupMapGroup`.

#### Verified from the ROM

The emitted `SkipEvolutions` branches on `cp $05` and advances two bytes before
looping. Pikachu's block encodes as `05 00 | 02 36 00 16 01 | 05 01 | 02 36 00 1a 00 |
00`, learnset at +15. Walking those bytes: a Thunder Stone yields species 278 in Johto
and 26 in Kanto, the party menu reads ABLE in both, and no level-up evolves Pikachu at
any level.

**Needs shasocastris in BGB**: that a Thunder Stone on a Johto Pikachu gives the Orange Raichu
and on a Kanto one the ordinary Raichu, and that no ordinary evolution regressed —
Caterpie at 7 is the cheapest check, since it is the plain `EVOLVE_LEVEL` case the
walkers now branch past.

#### The second gate: a level evolution

`DRAGONITE_KANTO` covers the other half. Dragonair levels to 55 and becomes the Kanto
form in Kanto, the ordinary Dragonite anywhere else:

```
	db   EVOLVE_REGION, KANTO_REGION
	dbbw EVOLVE_LEVEL, 55, DRAGONITE_KANTO
	dbbw EVOLVE_LEVEL, 55, DRAGONITE ; ungated fallback: every other region
	db 0 ; no more evolutions
```

> **[STRUCTURAL] Prefer a gate plus an ungated fallback over one gate per region.** The
> walker returns on the first match, so the guarded entry wins where it applies and
> everything else falls through. **This is what makes the data survive M3**: a
> two-gate form would leave a Dragonair in the third region unable to evolve at all.
> Verified by walking the bytes with region id 2 — it yields the ordinary Dragonite.

Between them, Pikachu and Dragonair now exercise a gate in front of both
`EVOLVE_ITEM` and `EVOLVE_LEVEL`. `EVOLVE_HAPPINESS` and `EVOLVE_STAT` still have no
gated data; they share the 4- and 5-byte widths already covered, so the risk is small,
but nothing has proved them.

## 9a. Questions for Phases 8–10 — **ALL ANSWERED**

Kept as a record of what was decided and why, not as work.

1. **Is `CURSOLA` a real species or a variant?** — **A real species** (shasocastris). Dex
   slot, dex entry, its own `GhostTypeSpecies` line, `NUM_POKEMON` = 276. Free in the
   save block.
2. **What does a variant evolving into a real species do to `FirstEvoStages`?** —
   **Nothing.** `GetLowestEvolutionStage` (`evolve.asm:600`) has **zero callers**
   anywhere in the tree, including `data/predef_pointers.asm`. The table is read only
   by dead code, so `dw CORSOLA_KANTO` as Cursola's lowest stage is inert but honest.
   Worth deleting the routine in a cleanup pass; not this branch.
3. **Does the Corsola line get a `LINE_*` entry?** — **No, and there is nothing to
   decide.** Corsola has no row in `data/pokemon/safari_move_tutor_moves.asm`, and
   `evo_lines.asm`'s own header says only lines with a tutor row are listed. Decision 2
   is untouched. This reopens only if the line is later given a tutor move.
4. **Type completion for the line.** — **Cursola joins `GhostTypeSpecies`** (shasocastris).
   GHOST completion now requires evolving a Kanto Corsola to 38.
   **`RAICHU_ORANGE` is Electric/Psychic and joins both `ElectricTypeSpecies` and
   `PsychicTypeSpecies`** (shasocastris, confirmed explicitly). A dual-typed variant belongs
   in *both* its lists, exactly as dual-typed species already do. The Psychic
   membership **hardens Sabrina's rematch gate** — the first time a variant has made a
   shipped gate stricter rather than looser. Accepted, not an oversight.
5. **Which region does an off-overworld evolution belong to?** — Answered in Phase 10
   above. Nothing to decide.
6. **Does `EVOLVE_REGION` gate the entry after it, or modify the method byte?** —
   **Gates the entry after it** (shasocastris). Encoding and rationale in Phase 10.
7. **Do variants of an evolved form need their own `_JOHTO` convention?** —
   **`BASE_REGION`, as sketched** (shasocastris). `RAICHU_ORANGE` beside `CORSOLA_KANTO`:
   suffix names *where the variant is found*, matching this hack calling Galarian
   Corsola the Kanto form. Not the real-world form name.

### Variant roster — **FINAL LIST RECEIVED: 25 of 32**

shasocastris's final roster, superseding everything earlier. Recorded as a comment block
beside the const block in `constants/pokemon_constants.asm`; **that file is the
authority**, this is the rationale.

| Orange Islands (M3) — 17 | Kanto — 8 |
|---|---|
| RAICHU **[done]**, SANDSHREW, SANDSLASH, VULPIX, NINETALES, GROWLITHE, ARCANINE, GEODUDE, GRAVELER, GOLEM, GRIMER, MUK, EXEGGUTOR, MAROWAK, VOLTORB, ELECTRODE, DRAGONITE | PONYTA, RAPIDASH, SLOWPOKE, SLOWBRO, SLOWKING, WEEZING, CORSOLA **[done]**, DRAGONITE **[done]** |

> **A variant cannot be reserved as a bare `const`.** Adding one fails ~15
> `assert_table_length` checks, because every species-indexed table is direct-indexed
> and a gap would read whatever follows. Verified by trying it. Names stay in the
> comment block until their rows exist.
>
> Nothing is lost by reserving on paper: the saved arrays are sized `MAX_VARIANTS`, so
> all 32 slots are paid for and promoting a name shifts nothing in the save block.

> ⚠️ **`DRAGONITE` is the only base with two variants.** `GetSpeciesVariant` returns
> the **first** match and stops, so the Pokédex form toggle can only reach one of them.
> Catching, stats, typing, type lists and the caught markers are unaffected — because
> `SetVariantCaught` and `CheckCaughtFormIndex` both take that same first match and so
> stay consistent with each other. Only the dex view is limited. Cycling needs a "next
> variant after this one" helper; write it when `DRAGONITE_ORANGE` lands, not before.

> **A constant name may reference a region that does not exist yet** — it is just an
> identifier. Only the `EVOLVE_REGION` gate operand, `RegionCheck` and `wCurRegion`
> need a real region constant, and `ORANGE_REGION` arrives with M3. Until then an
> `_ORANGE` form can be fully defined but not region-gated, and has no way to be
> obtained. `RAICHU_ORANGE` is the live exception: it is deliberately gated on
> `JOHTO_REGION` for now, marked `TODO(M3)` in `PikachuEvosAttacks`, so that a gate in
> front of an `EVOLVE_ITEM` entry keeps shipping data behind it.

### How the budget was settled — **17–32, arrays relocated**

shasocastris's answer: **17–32 variants**. `wVariantCaught` and `wVariantBaseCaught` moved
out of the M0 dex reservation into the former `wReservedSaveData`, and are sized
`flag_array MAX_VARIANTS` with `MAX_VARIANTS EQU 32` rather than `NUM_VARIANTS`, so
their offsets are fixed and the roster can grow to 32 with no further save-format
break. `constants/pokemon_constants.asm` fails the build past 32.

Consequences to carry forward:

- **The unassigned 8-byte reserve is spent.** M2 seasons and M4 weather have their own
  named bytes, but the *next unplanned* saved byte has nowhere to come from. The dex
  reservation still holds 4 bytes and must stay adjacent to `wPokedexCaught`, so it
  cannot serve as general reserve.
- The save block is byte-identical in size across the move — `wPlayerDataEnd` is still
  `$dc01` and `wPokedexSeen` still `$de0f`. Only the meaning of those bytes changed.
- **The variant const block is append-only.** `VariantBaseSpecies` is indexed by
  position and `assert_table_length` cannot catch a reordering. Noted in the header
  comment now.

---

## 6. Files touched

| File | Change |
|---|---|
| `constants/pokemon_constants.asm` | variant const block, `MAX_VARIANTS`, `CURSOLA`; header comment corrections |
| `constants/pokemon_data_constants.asm` | `EVOLVE_REGION` |
| `ram/wram.asm` | per-form caught arrays relocated into `wPlayerData`, sized for 32 |
| `engine/overworld/wildmons.asm` | `ValidateTempWildMonSpecies` bound |
| `data/pokemon/variant_bases.asm` | new — Layer 2 table |
| `data/pokemon/variant_dex_entry_pointers.asm` | new — variant dex entries |
| `home/pokedex_flags.asm` | Layer 4 redirect, `GetVariantBase`, `CheckCaughtForm` |
| `home/map.asm` | `UpdateCurRegion`, called from `CopyMapPartialAndAttributes` |
| `engine/overworld/landmarks.asm` | `RegionCheck` exported |
| `engine/pokemon/evolve.asm` | `EVOLVE_REGION` in all three block walkers |
| `engine/events/move_reminder.asm` | inlined walker replaced by `FarSkipEvolutions` |
| `engine/battle/core.asm` | comment only |
| 13 table files (§4 Layer 3) | one entry per variant *and* per new species |
| 5 more table files | `NUM_POKEMON` grew for `CURSOLA`: both dex orders, `PokedexDataPointerTable`, `Footprints`, `Pokered_MonIndices` |
| `data/pokemon/base_stats/{corsola_kanto,cursola,raichu_orange}.asm` | new |
| `data/pokemon/dex_entries/{corsola_kanto,cursola,raichu_orange}.asm` | new |
| `data/pokemon/evos_attacks_extra.asm` | three new blocks; Kanto Corsola's evolution |
| `data/pokemon/evos_attacks_kanto.asm` | Pikachu's region gates |
| `data/types/pokemon_type_lists.asm` | Ghost, Electric, Psychic |
| `gfx/pokemon/{corsola_kanto,cursola,raichu_orange}/*` | sprites (Cursola's and Orange Raichu's were already drawn) |
| `gfx/pics.asm`, `gfx/icons.asm`, `gfx/footprints.asm` | `INCBIN`s |
| `data/wild/kanto_water.asm`, `data/wild/flee_mons.asm` | Route 19 slot; flee list |

---

## 7. Do-not-break checklist (run before merge)

`[x]` = verified statically or in play. `[ ]` = still needs shasocastris in BGB.

- [x] Dex count after catching a variant increases by exactly one, and only the base species' bits change — confirmed in play
- [x] `CORSOLA` seen **and** caught both redirect — not just caught
- [x] Johto surf never yields the Kanto form; Kanto surf never yields the Johto form — `CORSOLA_KANTO` appears in exactly one wild table, `data/wild/kanto_water.asm` Route 19, and in `flee_mons.asm`. Nothing in any Johto table or in `fish.asm`
- [x] Johto Corsola still fishable, day only, via `FISHGROUP_SHORE` — `fish.asm:212-213` unchanged
- [x] Trainer card dex count unchanged — catching a variant and its base does not inflate it
- [x] Prof. Oak's rating unchanged for a save with no variants — confirmed in play
- [x] Safari tutor line gates — **deliberately no longer identical**, and confirmed in play. `PichuLine` lists `RAICHU_ORANGE`, and `RAICHU` in it means the Kanto form, so the line wants both. Every other line is untouched, since no other line member has a variant
- [x] Type-completion boost fires for **Ghost** after catching the Kanto form, per the *amended* decision 1 — confirmed empirically
- [x] Sabrina rematch gate — **deliberately stricter** by one (Orange Raichu), as is DRAGON (Kanto Dragonite). The completion machinery is confirmed working empirically
- [ ] **New:** Heavy Ball brackets behave sensibly after the weight-unit fix — one heavy catch, one light
- [x] Bug Contest unaffected — **played, with a variant in the lineup.** `CORSOLA_KANTO` was added to the contest mons, encountered, caught, and the contest ended cleanly. That also proves a variant survives the contest's own party swap and scoring, which nothing else exercised. Swarms and roaming mons share the same wild-encounter path and the only change to it widened `ValidateTempWildMonSpecies`' bound, so nothing previously valid became invalid
- [x] Existing saves invalidated only by M0, not additionally by M1 — the flag-array relocation kept the block byte-identical in size
- [x] No new `optimize.py` warnings; all `jmp`→`jr` resolved — 161, one fewer than the branch started with
- [x] Header comment in `pokemon_constants.asm` matches reality — also corrected this session, it still said variants must stay out of the type lists
- [x] **New:** ordinary evolutions unaffected by the `EVOLVE_REGION` walkers — Kanto Corsola → Cursola at 38 is a plain `EVOLVE_LEVEL` in a block with no gate, and works in play
- [x] **New:** the Move Reminder works. Two pre-existing bugs fixed: the learnset walker's `EVOLVE_LEVEL` width, and `IsAPokemon` being asked about an unloaded register
- [x] **New:** Route 19 yields Kanto Corsola at a sane rate with the shipping data

---

## 8. Commit sequence

```
1  variants: add VARIANTS_START constant block                            [done]
2  variants: bound ValidateTempWildMonSpecies by NUM_POKEMON_AND_VARIANTS [done]
3  variants: extend species-indexed tables to NUM_POKEMON_AND_VARIANTS    [done]
4  variants: correct the stale table index list in pokemon_constants.asm  [done]
5  variants: redirect Pokedex seen/caught through GetVariantBase          [done]
6  variants: add Kanto Corsola graphics and palettes                      [done]
7  variants: add Kanto Corsola to Route 19 water encounters               [done]
8  variants: add Kanto Corsola learnset                                   [done]
...
   variants: reserve the per-form caught bits for a roster of 32          [done]
   move reminder: fix the learnset offset for level-evolving species      [done]
   variants: add CURSOLA and evolve Kanto Corsola into it at 38           [done]
   variants: Cursola always learns HYPNOSIS on evolving                   [done]
   variants: add RAICHU_JOHTO, the second variant                         [done]
   variants: record the final roster, rename it to RAICHU_ORANGE          [done]
   variants: EVOLVE_REGION, a gate rather than a fifth method             [done]
```

Commits 5 and 6 of the original plan landed as one: `GetVariantBase` without its
call site is dead code, and the call site without the routine does not build.

---

## 9. Open questions for shasocastris

Sensible defaults assumed throughout; none block implementation.

0. **Pikachu's evolution method.** ~~Level 22 in Johto versus a stone in Kanto.~~
   **Answered: Thunder Stone in both regions**, so the player keeps the timing choice;
   the gate only picks which Raichu.
1. **Cross-type completion credit.** ~~Catching Ghost-type Kanto Corsola advances Water and Rock.~~ **Resolved by amending decision 1** — type lists name a *form*, so the Kanto form advances GHOST. See §9a item 4 for what that now costs at Sabrina.
2. **Route 19 slot.** The placement replaces `OCTILLERY` in the third water slot. Different route, slot or rate all free to change. *Default: as written.*
3. **Kanto Corsola stat spread.** *Default: gen 8's shape, re-tuned defensively.* Cursola follows the same re-tune; Orange Raichu does not (straight from gen 7). Both open.
4. ~~**Does it get a Cursola line later?**~~ **Answered: yes**, and it landed — Phase 8.
5. **Fishing parity.** Should the Kanto form also be fishable in Kanto, mirroring how the base form is obtained? Needs new `FISHGROUP_*` constants and Kanto map reassignment (§4 Layer 6). *Default: defer to a follow-up commit.*
6. ~~**Second variant.**~~ **Answered: yes** — `RAICHU_ORANGE` landed in Phase 10's run-up, and the pattern generalised without surprises.
7. **`pikachu_surf`.** Drawn, unreferenced, unclaimed. A surfing-Pikachu variant needs a base, an acquisition route and a reason to exist. Nothing is blocked on it.

---

## 10. State at handoff — 2026-08-20 (end of M1 phases 1–10)

**Branch:** `65-regional-variants`, 36 commits ahead of `core`. Builds clean; one
*fewer* `optimize.py` warning than the branch started with (161, was 162).

### Done

Phases 1–10 are all built. Three variants ship (`CORSOLA_KANTO`, `RAICHU_ORANGE`,
`DRAGONITE_KANTO`) of a final roster of 25, one
new real species (`CURSOLA`), a variant that evolves, an evolution move on a variant
line, and `EVOLVE_REGION`.

The wild-data test scaffolding is **already reverted** — Route 19 carries one
`CORSOLA_KANTO` in the third water slot, Olivine is back to `REMORAID`.

### Confirmed in play — shasocastris, 2026-08-20

Phases 8–10 are **play-tested and working**:

- Pikachu evolves by Thunder Stone in both regions, to the right Raichu each time.
- **Dragonair at 55 gives the Kanto Dragonite in Kanto and the ordinary one in
  Johto** — the level-gated path, and the ungated fallback behind it.
- Kanto Corsola evolves into Cursola. That block carries no gate at all, so it also
  covers "ordinary evolutions still work" for the rewritten walkers.
- Evolution moves fire on every line, and ordinary level-up moves still do.
- **The Safari tutor's Pichu line** opens once both Raichu forms are caught, and every
  other line is unchanged.
- The Pokédex caught-ball works, including the per-form marker, and the dex count
  increments by exactly one when a variant is caught.
- Kanto Dragonite's icon draws correctly out of "Mon Icons 3".

That retires the `EVOLVE_REGION` walkers and the per-form line gate, which were the
two largest unknowns.

### Still needs shasocastris in BGB

Effectively nothing is unverified. The one item never *observed* is closed by static
evidence instead:

**Wild flee, Kanto Corsola** (`df3ae43d2`). Not seen fleeing, and that is expected
rather than suspicious:

- Both forms are in `SometimesFleeMons` and in neither of the other two lists —
  read back from the ROM by index: `CORSOLA` (222) and `CORSOLA_KANTO` (277).
- `SometimesFleeMons` is **12/256 = 4.7% per enemy turn**, and only in a wild battle
  with the enemy awake, not wrapped, and the player not `CANT_RUN`. Roughly 40 enemy
  turns for an even chance of seeing one.
- The lookup is **variant-safe by construction**: `TryEnemyFlee` calls
  `GetPokemonIndexFromID` and searches with `IsInFarWordArray`, so it compares
  **16-bit indexes**, never a flag array. That is why this never had the bug the type
  lists and `*Line` lists did.
- The bank switch that `df3ae43d2` introduced is exercised on every one of those
  lookups, and other species flee correctly in play — so the shared path is proven.
  Both Corsola forms differ from them only by index, and the index is confirmed
  present.

Nothing form-specific remains that could fail. Treat it as verified unless a Kanto
Corsola is ever seen *failing* to flee over a long battle.

### Outstanding

Nothing blocking. M1 phases 1-10 are complete and play-tested.

- **Test scaffolding is all reverted** — the working tree has no tracked changes. The
  Route 19 slots, the debug Dratini and the Bug Contest entry are gone.
- **Art, deferred by shasocastris**: placeholder icons for `corsola_kanto` and
  `raichu_orange`, and Cursola's footprint. Kanto Dragonite's icon is real, if
  flat-shaded. `gfx/pokemon/pikachu_surf/` is drawn, unreferenced and unclaimed.
- **Base stats are accepted as they stand** (shasocastris) — Cursola re-tuned toward defence
  like its pre-evolution, Orange Raichu and Kanto Dragonite straight from their
  originals.
- **`MoveNames` hex comments in `constants/move_constants.asm` are stale**, the same
  way `pokemon_constants.asm`'s header was. `HYPNOSIS` is commented `; 5f` and is
  actually `$53`. Count the consts; do not trust the comments.
- **`GetLowestEvolutionStage` is dead code** (§9a item 2). Deleting it and
  `FirstEvoStages` is a real saving, in its own pass.
- **Type icon assets are orphaned** — `TypeLightIconGFX` / `TypeDarkIconGFX` and
  `TypeIconPals` are INCBIN'd but referenced by nothing. shasocastris's parked work.
- **The Move Reminder had two independent pre-existing bugs**, both fixed here. It had
  clearly never been exercised; anything else in that feature is equally unproven.
- **Heavy Ball fixed** (pre-existing, unrelated to variants, found while auditing
  variant-safety). `HeavyBallMultiplier` converts the dex weight to tenths of a kg as
  `29w/64` and compares the **high byte** against `HIGH(1024)`, needing a field of
  2260+. That is vanilla's tenths-of-a-pound; this hack stores **whole pounds**, so
  every value was 10x too small and even Snorlax (1014) yielded 459 — high byte 1,
  under the `cp 4`. Every species took `.lightmon` for a flat -20 and the
  `.WeightsTable` brackets were unreachable. Now scaled by 10 at the point of load,
  inside that routine only; the dex still stores and displays whole pounds. Brackets
  across all 279 species: 240 light, 26 at +0, 11 at +20, Steelix +30, Snorlax +40 —
  matching gen 2.
  > **Needs shasocastris in BGB**: Heavy Ball now behaves differently on every throw. Worth
  > one catch on something heavy (Onix, Snorlax) and one on something light.

### Testing notes

No emulator on the dev box — every visual or behavioural claim needs shasocastris in BGB.

```
WRAM bank 1 (rSVBK = 1)
  DBF2  wCurRegion            0 = Johto, 1 = Kanto
  DBF9  wVariantCaught        caught this variant      (4 bytes, 32 variants)
  DBFD  wVariantBaseCaught    caught the base form     (4 bytes)
WRAM0 (always mapped)
  C68D  wPokedexVariantToggle nonzero = the dex is showing the variant
```

> ⚠️ **These addresses moved this session.** `wVariantCaught` was `DE0B` and
> `wVariantBaseCaught` was `DE0C`; both are now in `wPlayerData`, four bytes each.

BGB's memory viewer shows **little-endian words**: `DBF9 0100` means `DBF9 = 00`,
`DBFA = 01`.

Debug ROM: hold A+B to walk through walls (`engine/overworld/player_movement.asm:37`),
hold B to skip trainers (`home/trainers.asm:93`). Kanto fly points are enabled in the
debug build (`maps/PlayersHouse2F.asm`). There is no debug room or warp menu.

### Working agreements

- Say plainly which claims are statically verified and which need shasocastris's eyes.
- **Verify table wiring by reading the assembled ROM by index, not by grepping
  source.** Grep once said the graphics wiring was fine while base Corsola and the
  variant had swapped sprites. The decoders in this branch's commit messages were all
  read back out of the ROM.
- **Anchor bulk edits on a two-line context and assert the anchor appears exactly
  once.** `SLOWKING`, `MAGNEZONE` and `FARIGIRAF` each appear in two type lists; a
  first-occurrence replace hits the wrong one silently.
- **Check whether a file or directory already exists before creating it.** `mkdir -p`
  and `cp` both succeed silently over shasocastris's pre-drawn art.
- **`git add -A` is wrong in this repo.** `docs/`, `.idea/`, `.claude/` and
  `rgbds-1.0.0/` are all untracked on purpose.
- Keep source comments short; rationale goes in commit messages.
- Design docs in `docs/` are deliberately **untracked**. Update them, do not commit.
- Map text is 18 characters per line; `#MON` counts as 7.

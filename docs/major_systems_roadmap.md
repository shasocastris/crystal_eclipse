# Crystal Eclipse — Major Systems Roadmap

**Scope:** sequencing and branch strategy for four large features — regional variants, seasons, a third region, and overworld weather — plus a preparatory milestone.

**Companion documents:**
- `seasons_implementation_context.md` — full implementation spec for M2. This roadmap does not duplicate it.
- `weather-particles-guide.md` — full reference and port guide for M4, describing the Polished Crystal implementation being ported. This roadmap does not duplicate it. (Earlier drafts of this roadmap referred to it as `overworld_weather_port_guide.md`; that filename does not exist.)
- `regional_variants_implementation_context.md` — full implementation spec for M1, including the verified Phase 0 findings and the Corsola test case. **Where it and §4 of this roadmap disagree, that doc is right** — it was written against the files.
- `HANDOFF_variant_evolution.md` — temporary. Session-start doc for M1 phases 8–10 (evolving variants, evolution moves, `EVOLVE_REGION`). Delete once that work lands.
- M3 is specced at phase level here and should get its own detailed context doc before implementation, following the seasons doc's format. M1's now exists (above).

---

## 1. Milestone order and why

| # | Milestone | Branch                 | Depends on |
|---|---|------------------------|---|
| **M0** | Save-block reservation | `64-save-reservation`  | — |
| **M1** | Regional variants | `65-regional-variants` | M0 |
| **M2** | Seasons | `66-seasons`           | M1 |
| **M3** | Third region (Orange Islands) | `67-orange-islands`    | M2 |
| **M4** | Overworld weather particles | `68-ow-weather`        | M3 (soft) |

### The ordering constraint

**Variants change the species ID space, and both other projects author bulk wild data against that space.**

Seasons generates ~36 new `def_grass_wildmons` blocks. The Orange Islands will generate far more. Every entry is `dbw level, SPECIES`. If variants land *after* either, you revisit all of it to decide, per entry, whether it should be the base species or a variant — exactly the kind of judgement that doesn't survive being made in bulk under time pressure at the end.

The dependency is one-directional. `VariantBaseSpecies` is a redirect at `SetSeenMon` / `SetCaughtMon`; it does not touch the wild lookup *chain* at all. So variants slot in ahead of the others without disturbing them.

### Cross-milestone impact matrix

| | affects M1 | affects M2 | affects M3 | affects M4 |
|---|---|---|---|---|
| **M0** | dex flag headroom | `wSeason`, `wSeasonalFlags` | region byte, spawn/landmark state | overcast roll bytes |
| **M1** | — | changes seasonal table *contents* | changes new region's table *contents* | none |
| **M2** | none | — | near-zero (see below) | **enables seasonal weather selection**; palette-axis decision |
| **M1 (late)** | — | none | **`EVOLVE_REGION` must survive `RegionCheck` going three-way** | none |
| **M3** | none | design question only | — | **map-attributes weather byte must be added during M3** |
| **M4** | none | none | none | — |

**Seasons and the third region genuinely don't fight.** `_SeasonWildmonCheck` keys on map group + map number, which is globally unique, and it sits *upstream* of the Johto/Kanto dispatch that M3 rewrites. That's a happy consequence of the hook placement already specced in the seasons doc. M2 and M3 could in principle swap order; M1 could not move.

### Why M4 goes last

Weather is close to orthogonal to everything else — it touches OAM, VRAM, and OB palettes, not species IDs or wild data. Nothing in M1–M3 blocks it, and it blocks nothing.

It goes last for two reasons, both about getting more for free:

1. **M2 makes it better.** `SetCurrentWeather` currently branches on map id. With seasons available it can branch on `wSeason` — snow across outdoor Johto in winter rather than only Silver Cave, cherry blossoms as a spring-wide effect rather than a Cherrygrove special case. That is the cheapest content in the whole roadmap: no maps, no species, one selection function.
2. **M3 authoring.** The weather selection should be a map-attributes field, not a hardcoded id chain (port guide §10 step 9). Adding the field *during* M3 means Orange Islands maps get it at authoring time; adding it after means retrofitting maps across three regions.

**But two pieces must be pulled forward.** See M0 (§3) and M3 (§6.2). Both are cheap now and expensive later.

### Why M0 exists

Four milestones grow the saved data region. Done in sequence that is **four separate save-format breaks** across a year of development — four times you invalidate your own test saves and any playtester's progress.

M0 reserves the full footprint for all four in one commit, before variants. Each feature then *fills in* reserved space rather than growing the block. One save break instead of four, for roughly an afternoon of careful reading.

---

## 2. Branch strategy

### Topology

Each milestone branches from the previous, so later work is built on top of earlier work rather than merged with it. **The default branch in this repo is `core`, not `main`**, and branches follow the numbered convention already in use (`57-remove-unused-blocks-and-other-code`, `49-introduce-pseudo-abilities`, …):

```
core
 └── 64-save-reservation          (M0)
      └── 65-regional-variants    (M1)
           └── 66-seasons         (M2)
                └── 67-orange-islands  (M3)
                     └── 68-ow-weather (M4)
```

### Merge-down discipline **[IMPORTANT]**

Stacked branches are correct for the *dependency* structure but dangerous if all four stay open simultaneously — a fix in M0 forces a rebase cascade through three branches, and conflict resolution in assembly data files is miserable.

**Rule: merge each milestone into `core` as soon as it builds clean and passes its acceptance checklist. Do not wait for the milestone above it.**

The intended lifecycle:

1. Cut `64-save-reservation` from `core`. Complete, verify, **merge to `core`**.
2. Cut `65-regional-variants` from the updated `core`. Complete, verify, **merge to `core`**.
3. Cut `66-seasons` from the updated `core`. And so on.

In practice you'll want to start M1 before M0 is merged. That's fine — branch M1 off M0 as drawn, then rebase M1 onto `core` once M0 lands. Just avoid having three unmerged milestones stacked at once.

### Sub-branches within a milestone

Each milestone has phases (M2 has six). For milestones expected to take more than a couple of weeks — M1 and M3 certainly — cut short-lived phase branches off the milestone branch and merge them back:

```
65-regional-variants
 ├── variants/01-constants-and-lookup
 ├── variants/02-table-extension
 ├── variants/03-dex-redirect
 └── variants/04-first-variant-end-to-end
```

Phase branches should live days, not weeks. Their purpose is reviewable, revertable units — not parallel work.

### Commit conventions

Prefix commits with the milestone shorthand so `git log --oneline` stays readable across a year:

```
save: reserve seasonal flag bytes in saved WRAM block
variants: add VARIANTS_START constant block
seasons: add checkseason script command
region: rewrite RegionCheck for three-way dispatch
weather: port DoOverworldWeather particle engine
```

### Working practices **[LEARNED THE HARD WAY DURING M1 — carry these forward]**

- **No emulator on the dev box.** Every visual or behavioural claim needs shasocastris in
  BGB. Say plainly which claims are statically verified and which need his eyes.
- **Verify table wiring by reading the assembled ROM by index, not by grepping
  source.** Grep once said the graphics wiring was fine while two species had swapped
  sprites. The `.sym` file makes offset lookups easy; disassembling the built routine
  settles arguments that source reading cannot.
- **Check `make`'s exit status, not its output.** Grepping for `error|warn|fail` misses
  `No rule to make target ... Stop.`, which cost a false "build ok" during M1.
- **Anchor bulk edits on two lines of context and assert the anchor matches exactly
  once.** `SLOWKING`, `MAGNEZONE` and `FARIGIRAF` each appear in two type lists; a
  first-occurrence replace silently hits the wrong one.
- **Check whether a file or directory already exists before creating it.** `mkdir -p`
  and `cp` both succeed silently over pre-drawn art. shasocastris draws sprites ahead of the
  code and leaves them unreferenced — sweep `gfx/pokemon/*/` for directories nothing
  mentions before making a placeholder.
- **`git add -A` is wrong in this repo.** `docs/`, `.idea/`, `.claude/` and
  `rgbds-1.0.0/` are all untracked on purpose. Stage by name.
- **Run `utils/check_season_comments.py`** after touching any base wild table
  (`johto_grass.asm`, `kanto_grass.asm`, `johto_water.asm`, `kanto_water.asm`). The
  seasonal column files carry `; level, SPECIES` comments recording what a SUMMER
  sentinel column falls through to; editing a base table silently invalidates them.
  Exits non-zero on a mismatch.
- **Run `utils/farcheck.py <rom>.sym` after adding any call between files.** RGBDS does
  **not** error on a near `call` to a label in another bank: it links cleanly and jumps
  into garbage at runtime. M2's `ee4feb1` shipped one (bank `24` → bank `05`) and it
  survived a day because no play-tested path reached it — it only surfaced when shasocastris
  started a new game. Filter with `grep -v "in bank 00"`; the home-bank hits are
  legitimate. **A routine that moves to a different file has very likely changed bank.**
- **Run `utils/optimize.py` before and after** and diff, ignoring line numbers. A PR
  must add no new warnings. **Invoke it as `python3`, not `python`** — `python` is not
  on PATH on this box, and `AGENTS.md` is wrong about that. The failure is exit 127
  with an empty output file, which reads exactly like "no warnings".
- **A cache is not a test hook for the thing that fills it.** [M2, 2026-08-22 — one
  session lost] Poking `wSeason` forces every season *consumer*, because they all read
  the cache. But `GetSeason` is its only writer, so any day rollover overwrites the
  poke — making the calendar itself untestable that way, and producing a phantom
  "season skip" that reads exactly like an engine bug. Test the *source*
  (`wStartDay`), not the cache. **Before trusting any poke, ask who writes this
  address**: `grep -rn "\[wThing\], a"` answers it in seconds. M4's weather state will
  have the identical shape.
- **Establish the byte order of shasocastris's memory view before reasoning about its
  numbers.** [M2, 2026-08-22] It is **16-bit little-endian** — a displayed `FF07` at
  `$d4c4` means `$d4c4` = `$07`. Reading it as bytes-in-address-order made a correct
  value look impossible and cost three rounds chasing a nonexistent byte wrap. Nearly
  every symbol in these features is a `db`: **split the word, take the low half.** When
  a reading looks impossible, suspect the transcription before the engine.
- **Keep a byte whose value you can predict independently**, to check a reading against.
  `wCurRegion` must be `$00` in Johto; that settled the above in one step. Invariants
  (`wCurDay - wStartDay ∈ [0, 140)`) serve the same purpose. Use them to test a
  *reading*, not to condemn it. `$D000-$DFFF` is also banked, so `$FF70` = 1 is worth
  confirming — though that has not actually bitten yet.
- **Keep source comments short.** Rationale belongs in the commit message; shasocastris
  strips verbose comment blocks.
- **Design docs in `docs/` are deliberately untracked.** Update them, never commit
  them.
- **Map text is 18 characters per line**; `#MON` counts as 7.

### Tagging

**Do not tag milestones. [CORRECTED — shasocastris]** The only tags in this repo are actual
release version tags. An earlier draft of this section proposed `m0-save-reservation`,
`m1-variants` and so on; those were never created and should not be. When a
save-format or species-ID question surfaces later, the reference point is the merge
commit on `core` and its message, which is why the commit messages carry the detail.

---

## 3. M0 — Save-block reservation

**Branch:** `64-save-reservation` (cut from `core`)
**Size:** one sitting
**Risk:** low, but mistakes here are expensive to correct later

### Purpose

Reserve WRAM and SRAM footprint for M1–M4 in a single save-format change.

### Phase 0 — Read before changing anything

- `wram.asm` — exact boundaries of the saved block; existing padding or unused bytes
- `sram.asm` — `sGameData` layout, checksum region boundaries
- `constants/16_bit_translation_constants.asm` — already read: `MON_TABLE_ENTRIES EQU 100`, `MON_TABLE_LOCKED_ENTRIES EQU 30`, `MON_TABLE_MINIMUM_RESERVED_INDEX EQU $FD`
- `macros/wram_16bit.asm` — conversion table layout and its alignment assertions

#### Phase 0 findings **[DONE — measured against the real files, keep for M1–M4]**

**Saved block boundaries.** Three ranges, all in WRAMX bank 1: `wPlayerData`–`wPlayerDataEnd`, `wCurMapData`–`wCurMapDataEnd` (both inside `SECTION "Enemy Party"`, *not* `"More WRAM 1"` — the section starts at `ram/wram.asm:2444`, well above `wGameData`), and `wPokemonData`–`wPokemonDataEnd` (`SECTION "Party"`). `wGameData`/`wGameDataEnd` bracket all three but are **not contiguous** — `layout.link` places `"Enemy Party"`'s non-saved head between them. Only the new-game clear at `engine/menus/intro_menu.asm:102-105` uses that span.

Saved but **outside** the checksum: `wOptions` → `sOptions`, `wCrystalData` → `sCrystalData`.

**Checksum coverage.** `SaveChecksum` / `VerifyChecksum` (`engine/menus/save.asm:389`, `:699`) run over `sSaveData` → `sSaveDataEnd`, which is `sPlayerData` + `sCurMapData` + `sPokemonData` + `sPokemonIndexTable` + `sConversionTableChecksum`. All twelve save/load/backup copies are sized symbolically (`wPlayerDataEnd - wPlayerData` etc.), so **anything added inside the three blocks is saved, restored, backed up and checksummed with no code change.** The separate `sConversionTableChecksum` covers only `sMoveIndexTable`; the item table is not checksummed at all.

**Existing padding already in the saved block.** Only 6 usable bytes: `ram/wram.asm` `ds 4` after `wMobileOrCable_LastSelection` and `ds 2` after `wPlayerMonSelection`. The `ds 1` after `wBikeFlags` is *not* usable — `ResetBikeFlags` clears it. `wUnusedTwoDayTimer*` look free but are live (`engine/overworld/time.asm:7, 207, 210`). M0 left all of these alone, to keep the reservation in contiguous readable runs.

**Conversion tables.** `SECTION "16-bit WRAM tables"` sits in **WRAMX bank 2** (`layout.link`, `align 8`), a different bank from the saved block — not inside it, not adjacent. The `$100` assertions in `macros/wram_16bit.asm:8-22` constrain only the `*_TABLE_*` constants, never the section's position; the `align 8` is what the low-byte pointer arithmetic in `engine/16/macros.asm` actually depends on. **M0 imposes no constraint on them and they impose none on M0.** In SRAM, `sPokemonIndexTable` is copied by plain `CopyBytes` with no alignment requirement, so shifting it is harmless.

**Capacity (measured from a clean build).** Free space before M0: WRAMX bank 1 tail **171 bytes**, SRAM bank 1 **658**, SRAM bank 0 **317**. Each saved byte costs one of each, so **171 was the ceiling**. M0 spent 37, leaving 134 / 621 / 280. Capacity was never tight; nothing was cut.

### What to reserve

| Reservation | Size | For | Notes |
|---|---|---|---|
| `wSeason` | 1 byte | M2 | Season index 0–3. Must be *saved* — needed to detect season change across a reload. |
| `wSeasonalFlags` | 1 byte | M2 | Cleared on season change. |
| `wCurRegion` or equivalent | 1 byte | M3 | Only if profiling shows `RegionCheck` is called often enough to warrant caching. Reserve regardless; unused bytes are cheap, a second save break is not. |
| Dex-flag headroom | TBD | M1 | **Only if** variants get their own seen/caught bits. Under the recommended design they do not — see §4.2. Reserve a small margin anyway. |
| Orange Islands spawn / landmark state | TBD | M3 | Depends on how many spawn points and visited-map flags the region needs. Estimate high. |
| `wOvercastRandomDay`, `wOvercastRandomMaps` | 2 bytes min | **M4** | **Pulled forward — see below.** The weekly overcast roll must survive a save. |
| Overcast headroom | 2–4 bytes | M4 | Per-map or story-gated overcast state, if you want it. Estimate high; these are the cheapest bytes in the table. |
| General reserve | 4–8 bytes | future | Named `wReservedSaveData` with a comment explaining its purpose, so it isn't "reclaimed" by a future you. |

#### What was actually reserved **[SHIPPED]**

37 bytes total, all inside the checksummed range. Every one carries a comment naming its milestone and stating that it is intentionally unused.

| Symbol | Bytes | Block | For |
|---|---|---|---|
| `wSeason` | 1 | `wPlayerData` | M2 |
| `wSeasonalFlags` | 1 | `wPlayerData` | M2 |
| `wCurRegion` | 1 | `wPlayerData` | M3 |
| `wOvercastRandomDay` | 1 | `wPlayerData` | M4 |
| `wOvercastRandomMaps` | 1 | `wPlayerData` | M4 |
| `wOvercastReserved` | 4 | `wPlayerData` | M4 |
| `wReservedSaveData` | 8 | `wPlayerData` | future |
| *(anonymous)* after `wVisitedSpawns` | 4 | `wCurMapData` | M3 — ~32 more `SPAWN_*` |
| `wReservedRegionMapData` | 8 | `wCurMapData` | M3 — visited-landmark state |
| *(anonymous)* after `wEndPokedexCaught` | 4 | `wPokemonData` | M1 — ~32 more dex entries |
| *(anonymous)* after `wEndPokedexSeen` | 4 | `wPokemonData` | M1 — ditto |

> **Three of these are position-dependent.** The spawn padding must stay adjacent to `wVisitedSpawns`, and the two dex paddings adjacent to their `flag_array`s. They work by being *deleted* one-for-one as the array in front of them grows, which is what keeps every later offset stable. Move them and the mechanism silently stops working.

### ⚠️ Why the weather bytes are here and not in M4

The particle engine itself needs **no saved state** — `wCurWeather`, `wPrevWeather`, `wWeatherFlags`, and the timers are all recomputed by `SetCurrentWeather` on every map load.

The **overcast system underneath it is different.** `GetOvercastIndex` performs a weekly roll stored in `wOvercastRandomDay` / `wOvercastRandomMaps`, and that must persist — otherwise the weather re-rolls every time the player reloads.

Two bytes. If they are not reserved now, M4 forces a fourth save break for them, which is precisely what this milestone exists to prevent. Reserve generously: the overcast system also carries story gating and per-region special cases, and unused reserved bytes cost nothing.

### Critical checks

> ⚠️ **The 16-bit conversion tables have alignment assertions.** `___wram_conversion_table` asserts the total is padded to a `$100` multiple and that the cache does not straddle a `$100` boundary. **Do not place reservations inside or adjacent to a conversion table without re-running the build** — a violation is a hard assembler failure, which is at least loud.

> ⚠️ **Verify the checksum region covers the new bytes.** Reserved-but-unchecksummed bytes will appear to work until they silently fail to persist.

**Both checks came back clean.** The conversion tables are in a different WRAM bank and were never at risk; all 37 reserved bytes map into `sSaveData`–`sSaveDataEnd` and were confirmed there by arithmetic against the linker symbol table.

### ⚠️ Bug folded into M0 — item index table saved to the wrong SRAM bank

Found while auditing the save path, fixed on this branch because M0 is the save-format commit.

`SaveIndexTables` and `LoadIndexTables` (`engine/menus/save.asm`) opened `BANK(sPokemonIndexTable)` (SRAM bank 1) and then copied the **item** table to/from `sItemIndexTable`, which is a **bank 0** symbol, without reopening SRAM. With bank 1 selected the access landed at `01:b100` — inside `sHallOfFame` — so every save silently corrupted the first two-and-a-bit Hall of Fame entries, while `sItemIndexTable` in bank 0 was never written. Because save and load made the identical mistake the item table itself round-tripped correctly, which is why this went unnoticed. The backup path (`SaveBackupIndexTables`) was already correct, since both its symbols are in bank 0.

Fix: one `OpenSRAM` before each item-table copy. **This changes where the item table lives in SRAM, so it is itself a save-format change** — harmless here only because M0 already breaks the format.

### Acceptance

- Builds clean.
- New game → save → reload preserves the reserved bytes when written by a debug poke.
- Save-format change noted in the commit message. (No milestone tag — see §2 Tagging.)

---

## 4. M1 — Regional variants **[COMPLETE — merged to `core`]**

**Status:** all ten phases built, play-tested and merged. The implementation reference
is `regional_variants_implementation_context.md`; everything below is the original
plan, kept for its reasoning. Where the two differ, **the context doc is right** — two
of the §4.3 decisions were amended during implementation.

**What shipped:** three variants (`CORSOLA_KANTO`, `RAICHU_ORANGE`, `DRAGONITE_KANTO`)
of a final roster of 25, one new real species (`CURSOLA`), `EVOLVE_REGION` as a gate
opcode, per-form caught tracking, a Pokédex form view, and a live `wCurRegion`.

**Amended decisions — read these before trusting §4.3 below:**
- **Decision 1** — type lists name a *form*, not a species. A variant advances **its
  own** type, not its base's.
- **Decision 2** — variants **may** appear in `*Line` lists, per form. That hardens
  the affected gate deliberately.

**Bugs found and fixed along the way, all pre-existing on `core` and unrelated to
variants:** the Move Reminder's learnset walker mis-sized `EVOLVE_LEVEL`; the Move
Reminder asked `IsAPokemon` about an unloaded register; Heavy Ball was a flat -20 for
every species because the hack stores whole pounds where the maths expects tenths.

**Branch:** `65-regional-variants`
**Basis:** the seven-layer design from the "Creating a third Pokémon region" chat (18 Aug), corrected below.

### 4.1 ⚠️ Blocking correction to the original design

The original variants breakdown assumed one-byte species IDs, stating: *"since your species IDs are likely all 8-bit in game RAM (vanilla Crystal uses 1-byte species)."*

**That is not true of this codebase.** Crystal Eclipse has a **16-bit species index system with a runtime conversion table**, architecturally parallel to the 16-bit item ID system:

- `constants/16_bit_translation_constants.asm`: `MON_TABLE_ENTRIES EQU 100`, `MON_TABLE_LOCKED_ENTRIES EQU 30`, `MON_TABLE_CACHE_SIZE EQU 16`, `MON_TABLE_MINIMUM_RESERVED_INDEX EQU $FD`
- Wild tables store **16-bit indexes** (`dbw level, SPECIES`) and call `GetPokemonIDFromIndex` at encounter time
- `constants/16_bit_locking_constants.asm` defines `LOCKED_MON_ID_MAP_1`–`_8`, `LOCKED_MON_ID_DEX_SELECTED`, `LOCKED_MON_ID_TRADE_SEND/RECEIVE`, `LOCKED_MON_ID_BATTLE_TOWER_1`–`3`, `LOCKED_MON_ID_CURRENT_MENU`
- At most **100 species hold live 8-bit IDs simultaneously**, allocated dynamically with garbage collection and eviction protection

**Phase 0 of M1 must answer these before any code is written:**

1. Does a species index past `NUM_POKEMON` convert cleanly through `GetPokemonIDFromIndex` / `GetPokemonIndexFromID`, or does the table assume indexes ≤ `NUM_POKEMON`?
2. `engine/battle/type_completion_boosts.asm` performs a **round trip** — `GetPokemonIDFromIndex` then `GetPokemonIndexFromID` — per species checked. Does `CheckAllTypeSpeciesCaught` iterating a full type list churn the 100-entry allocation table or trigger eviction of locked IDs? This is a pre-existing question that variants make sharper.
3. Do variants need entries in the locked-ID pool (`LOCKED_MON_ID_MAP_*`) when present on a map?
4. Does `ValidateTempWildMonSpecies` (called in `ChooseWildEncounter`) reject indexes above `NUM_POKEMON`?

**If any answer is unfavourable, stop and re-plan.** This is precisely why variants goes first: discovering this constraint while authoring a region's worth of wild data would be considerably worse.

#### Answers **[VERIFIED during M0 — three clean, one blocker]**

**1. Does an index past `NUM_POKEMON` convert cleanly? — Yes.** The conversion table is a dynamic slot allocator, entirely agnostic to the value of the index. `___conversion_table_store` (`engine/16/macros.asm:42-211`) range-tests the incoming index exactly twice: for the `EGG` case (high byte `$FF`, low byte ≥ `$FD` — `engine/16/macros.asm:48-53`, which is what `MON_TABLE_MINIMUM_RESERVED_INDEX` exists for, `EGG EQU -3` = `$FFFD`) and for zero (`:55-56`). There is no comparison against `NUM_POKEMON` anywhere in the macro, and `___conversion_table_load` is keyed on the 8-bit slot number, not the species value. `NUM_POKEMON` is already `$113` (275), so indexes past 255 are in daily use. **Constraint: a variant index must be non-zero and outside `$FFFD`–`$FFFF`.** Appending after `NUM_POKEMON` satisfies both.

**2. Does the type-completion round trip churn the table or evict locked IDs? — It churns heavily; locked IDs are safe.** The round trip at `engine/battle/type_completion_boosts.asm:152-153` is a **no-op on the value**, but the first leg *allocates a slot* per species. `DoTypeCompletionBoosts` walks up to 50 species (Water) per damage calculation against `MON_TABLE_ENTRIES EQU 100`; two consecutive different-type calculations hit `.no_room` and run a **full garbage collection inside the damage formula**. `CountCompletedTypes` walks all 18 lists — 406 lookups — and forces several GC passes per call. Locked entries and the 8-entry recent-allocation ring survive collection: `___conversion_bitmap_initialize` (`engine/16/macros.asm:274-297`) seeds the bitmap from `LockedEntries` and runs `inc e / jr nz` to the end of the `$100` page, which for `MON_TABLE` covers all 30 locked slots plus all 8 recent ones exactly. **What is not protected** is any 8-bit mon ID in a variable outside the collector's fixed list — `wCurPartySpecies` is the obvious one. **Pre-existing; variants do not worsen it**, since variants never enter the type lists. Worth its own cleanup pass, unrelated to M1.

**3. Do variants need locked-ID pool entries on a map? — No new requirement.** The pool is a script-level opt-in, not something the map system fills: `ResetMapLockedIDs` (`engine/overworld/warp_connection.asm:17-36`) *clears* all eight slots per map, and only `loadmonindex` (`engine/overworld/scripting.asm:2251-2266`) populates them. A wild variant needs nothing — the allocation is covered by the recent-allocation ring, and by battle start the value lives in `wBattleMonSpecies` / `wEnemyMonSpecies`, both scanned by the collector. A variant referenced by a *script* needs a lock for exactly the same reason a base species would.

**4. Does `ValidateTempWildMonSpecies` reject indexes above `NUM_POKEMON`? — YES. This blocks Layer 6 as written.**

`engine/overworld/wildmons.asm:805-821`. `NUM_POKEMON` = `$113`, so `LOW(NUM_POKEMON)` is `$13` and the `else` branch assembles; the routine returns carry — invalid — for any index `> $113`. The caller acts immediately:

```
	call ValidateTempWildMonSpecies
	jr c, .nowildbattle          ; wildmons.asm:351-352
```

> ⚠️ **A variant index placed in a wild table is silently discarded.** The player walks through grass and nothing happens, at whatever rate that slot occupies — no crash, no assembler error, no log. This is exactly the failure mode §8 row 1 warns about, and it is why Phase 0 was made blocking.
>
> **Fix required in M1 before any variant enters a wild table:** widen the bound in `ValidateTempWildMonSpecies` to `NUM_POKEMON_AND_VARIANTS`. Small and localised — note that the `if LOW(NUM_POKEMON) == $FF` branch selection is computed at assembly time, so the replacement constant's low byte decides which arm assembles. Add a wild-encounter test for a variant to the M1 acceptance list.

### 4.2 The design (layers, corrected)

**Layer 1 — Constant block.** At the end of `constants/pokemon_constants.asm`, after `EGG`:

```
; --- VARIANT SPECIES (no Pokédex entries) ---
DEF VARIANTS_START EQU const_value

	const PIKACHU_FLYING   ; Yellow Forest
	const RAICHU_ALOLAN    ; Orange Islands

DEF NUM_VARIANTS EQU const_value - VARIANTS_START
DEF NUM_POKEMON_AND_VARIANTS EQU const_value - 1
```

`NUM_POKEMON` is unchanged, so every table indexed by it is unaffected.

> Note the existing convention: `MR__MIME` uses a **double underscore** in this codebase. Follow local naming precedent for variant constants.

**Layer 2 — `VariantBaseSpecies` lookup.** `data/pokemon/variant_bases.asm`, entries as **16-bit index pairs** (not `db` pairs as originally sketched):

```
VariantBaseSpecies:
	dw PIKACHU_FLYING, PIKACHU
	dw RAICHU_ALOLAN,  RAICHU
	dw -1
```

Helper `GetVariantBase` in `engine/pokemon/variants.asm`. Follow the `cphl16` comparison idiom already used for 16-bit item comparisons in `ApplyCleanseTagEffectOnEncounterRate`.

**Layer 3 — Tables that grow to `NUM_POKEMON_AND_VARIANTS`. [CLASSIFIED EXHAUSTIVELY during M0 — this list supersedes the earlier sketch.]**

| Table | File | Why it grows |
|---|---|---|
| `PokemonNames` | `data/pokemon/names.asm` | name shown in battle, party, everywhere |
| `BaseData` | `data/pokemon/base_stats.asm` | different stats/types is the point of a variant |
| `EvosAttacksPointers` | `data/pokemon/evos_attacks.asm` | own learnset (Layer 5) |
| `PokemonCries` | `data/pokemon/cries.asm` | cry plays on send-out |
| `IconPointers` | `data/pokemon/icon_pointers.asm` | party-menu icon |
| `MonMenuIconPals` | `data/pokemon/menu_icon_pals.asm` | icon colour, read alongside `IconPointers` |
| `PokemonPicPointers` | `data/pokemon/pic_pointers.asm` | front/back sprite |
| `PokemonPalettes` | `data/pokemon/palettes.asm` | sprite colours |
| `AnimationPointers` | `gfx/pokemon/anim_pointers.asm` | sprite animation |
| `AnimationIdlePointers` | `gfx/pokemon/idle_pointers.asm` | ditto |
| `BitmasksPointers` | `gfx/pokemon/bitmask_pointers.asm` | ditto |
| `FramesPointers` | `gfx/pokemon/frame_pointers.asm` | ditto |
| `FirstEvoStages` | `data/pokemon/first_stages.asm` | species-indexed, read by `engine/pokemon/evolve.asm:605-608` |

**Tables that must NOT grow** (stay at `NUM_POKEMON`):

| Table | File | Why it doesn't |
|---|---|---|
| `PokedexDataPointerTable` | `data/pokemon/dex_entry_pointers.asm` | variants have no dex entry (§4.3 decision 3) |
| `AlphabeticalPokedexOrder` | `data/pokemon/dex_order_alpha.asm` | dex listing order |
| `NewPokedexOrder` | `data/pokemon/dex_order_new.asm` | ditto |
| `wPokedexCaught` / `wPokedexSeen` | `ram/wram.asm` | the Layer 4 redirect is what makes this correct |
| `wPokedexOrder` | `ram/wram.asm` | derived from the flag arrays |
| `PokemonTypeLists` + the 18 species lists | `data/types/pokemon_type_lists.asm` | keyed by type; adding variants silently hardens every completion gate (§4.3 decision 1) |
| `PokemonEvoLines` + the `*Line` lists | `data/pokemon/evo_lines.asm` | keyed by `LINE_*`. **This is the PCNY gate of §4.3 decision 2 — leaving it alone *is* the "variants don't count" answer** |
| `Pokered_MonIndices` | `data/pokemon/gen1_order.asm` | despite its `NUM_POKEMON + 1` assert it is indexed by *gen-1* index or searched linearly, never by species |
| `KantoMonSpecials` | `data/pokemon/gen1_base_special.asm` | gen-1 compatibility only |
| `Footprints` | `gfx/footprints.asm` | read only by `engine/pokedex/pokedex.asm:2705`; no dex entry means it is never reached for a variant |

Because every don't-grow table asserts against `NUM_POKEMON`, and Layer 1 leaves `NUM_POKEMON` unchanged, **the entire don't-grow set needs no edit at all** — the asserts stay green on their own.

> ⚠️ **The header comment in `constants/pokemon_constants.asm` is stale — do not use it as the checklist.** `EggMovePointers` and `data/pokemon/egg_move_pointers.asm` **do not exist**; egg moves have been removed from this codebase and the comment is the only surviving reference. `EvosAttacksPointers` is in `evos_attacks.asm`, not `evos_attacks_pointers.asm`, and is an `indirect_entries` table split three ways. And two species-indexed tables are **absent from the list entirely** — `MonMenuIconPals` and `FirstEvoStages` — both of which would have been missed by working the comment alone. Fixing that comment is M1 work.
>
> `EZChat_SortedPokemon`, named in earlier drafts of this section, **does not exist in this repo** either; the only trace is a length constant comment in `constants/mobile_constants.asm`.

**Two flagged rather than guessed:** `Footprints` is classified don't-grow on the strength of its single call site, and flips the moment a variant appears in any dex-like UI — it is 8 bytes an entry, so growing it is cheap insurance. `Pokered_MonIndices` operates on 8-bit `wTempSpecies` values, which in this codebase are dynamic table slots rather than species numbers, so the Time Capsule path may already be non-functional; worth a separate look, unrelated to M1.

**Layer 4 — Dex redirect.** Call `GetVariantBase` before `SetSeenMon` / `SetCaughtMon`. This is the entire mechanism by which variants count toward the base species.

**Layer 5 — Learnsets.** One `evos_attacks` file per variant. Note the project's **evolution-move system** (`wEvolutionOldSpecies` as the evolution-vs-level-up discriminator): if a variant evolves, or a base evolves into a variant, verify the evolution move logic still fires correctly across all three paths (evolution, Rare Candy, battle level-up).

**Layer 6 — Wild encounter injection.** Variant index placed directly in wild tables. **This is the layer M2 and M3 depend on**, and the reason M1 goes first. ⚠️ **Blocked until `ValidateTempWildMonSpecies` is widened — see §4.1 answer 4.** Nothing else in the layer stack is affected.

**Layer 7 — Battle display.** No special-casing needed; variants have real table entries.

### 4.3 Decisions M1 forces **[ANSWERED — shasocastris, this session. These are now settled; do not re-open them mid-implementation.]**

These are not implementation details — they change what shipped systems mean.

**Summary of answers**

| # | Decision | Answer |
|---|---|---|
| 1 | Variants count toward type completion? | **Yes** — let the Layer 4 redirect apply |
| 2 | PCNY tutor gate includes variants? | **No** — settled by `PokemonEvoLines` staying keyed by `LINE_*` |
| 3 | Variant occupies a Pokédex slot? | **No** |
| 4 | Sabrina rematch trigger | Not a separate decision — see below |
| 5 | Nickname default | **Base species name** |
| — | First variant is part of an evolution line? | **No** — standalone, non-evolving, to keep Layer 5 out of the vertical slice |

1. **Does catching a variant count toward the type completion boost? — ~~YES, via the redirect~~ AMENDED: it counts toward its OWN type.**

> **[AMENDED during M1]** Implemented as recorded, then changed. Type lists name a *form*, so they now ask which form was caught (`CheckCaughtForm`). Kanto Corsola advances GHOST; `CORSOLA` in WATER and ROCK means the base form specifically. A no-op for every species without a variant. See the M1 context doc, Phase 7 and §9a item 4. Original reasoning follows.
 Under Layer 4 the base species is marked caught, so this needs no extra code. Consequences to accept knowingly: a player who catches a psychic variant satisfies `PSYCHIC` completion without ever catching the base species, which unlocks **both** the damage boost *and* the Sabrina rematch (`maps/SaffronGym.asm:53`). This **loosens** two shipped gates — it never hardens them, since the type lists stay at `NUM_POKEMON`. The alternative (suppressing variant-derived catches for completion checks) was rejected: it needs a "caught the real thing" distinction separate from the dex bit, which means a second flag array that M0 did not reserve.
2. **Does the PCNY move tutor's line-completion gate include variants? — NO.** The gate requires all members of an evolutionary line including branches (Eevee's five, Tyrogue's three); if variants counted, every existing gate would get harder retroactively, mid-playthrough. **This is already enforced structurally:** `PokemonEvoLines` and its `*Line` lists are keyed by `LINE_*`, not by species, and are classified don't-grow in §4.2 Layer 3. Leaving them untouched *is* the "no" answer — no code required, but do not add variants to a `*Line` list later without re-reading this.
3. **Does a variant occupy a Pokédex slot? — NO.** Follows the Unown form precedent. `PokedexDataPointerTable`, the seen/caught flag arrays and both dex orderings all stay at `NUM_POKEMON` (§4.2 Layer 3). Recorded as a decision, not as an accident of the redirect.
4. ~~**Sabrina rematch trigger.**~~ **[CORRECTED — not an independent decision.]** This entry assumed a "catch all 26 Unown" trigger. That trigger does not exist in the code. `maps/SaffronGym.asm:17-18` gates the rematch on `VAR_BADGES == NUM_BADGES`, then `:53` calls `.CheckPsychicTypeCompletion`, which is `farcall CheckAllTypeSpeciesCaught` on `PSYCHIC_TYPE` (`:77-85`). The trigger was already reworked onto the type-completion system at some earlier point. Variants therefore reach it only through **decision 1**, and through the same mechanism: `PsychicTypeSpecies` is don't-grow (§4.2 Layer 3), so no variant is ever *added* to the requirement — but under the Layer 4 redirect, catching a psychic variant marks its base species caught and so *loosens* the gate. Decide it once, in decision 1; there is nothing separate to resolve here.
5. **Nickname default. — BASE SPECIES NAME.** A caught `RAICHU_ALOLAN` displays as "RAICHU", matching the mainline convention where a regional form shares its species name. `PokemonNames` still *grows* — it is species-indexed, so a variant must have an entry — but the entry holds the base species' string. The player distinguishes a variant by sprite and stats, not by name, which is deliberately subtle in the PC list.

6. **Is the first variant part of an evolution line? — NO, standalone and non-evolving.** Keeps Layer 5 out of the vertical slice. The evolution-move system (`wEvolutionOldSpecies` as the evolution-vs-level-up discriminator) has three paths to verify — evolution, Rare Candy, battle level-up — and entangling them with the first end-to-end test would make any failure ambiguous between the table extension and the evolution logic. Evolving variants come after the slice is green.

### 4.4 Acceptance

- One variant obtainable end-to-end: appears in a wild table, battles with its own sprite / stats / learnset, and registers as its **base species** in the dex.
- Type completion boost for the relevant type unaffected in either direction beyond the decision recorded in §4.3.
- PCNY tutor gate behaves per the recorded decision.
- Existing saves invalidated only by M0, not additionally by M1.

---

## 5. M2 — Seasons **[MERGED to `core` 2026-08-22 — Phases 1-5 only]**

**Branch:** `66-seasons` (merged, fast-forward; `core` == `origin/core` at `b23c590`)
**Full spec:** `seasons_implementation_context.md` — six phases, acceptance criteria, do-not-break checklist.
**Current state:** `seasons_status.md` — read that first; it supersedes the spec.

> ### ✅ M2 Phase 6 — winter tiles — BUILT 2026-10-14/15 on `68-ow-weather` (was deferred 2026-08-22)
>
> **M2 merged with five of its six phases.** Phase 6 is not started, not abandoned:
> it is deferred until shasocastris has art time. Nothing in `core` depends on it, and no
> merged commit assumes it exists.
>
> **When it is picked up, read `seasons_status.md` §6 first.** The design was reframed
> away from a whole `TILESET_JOHTO_WINTER` into a `LoadMapGroupRoof`-style tile patch
> keyed on `wSeason` — about a tenth of the art.
>
> Two things carried forward:
> - **One engine fix is needed and is art-independent:** `DeferredLoadMapGraphics`
>   skips the reload when `TilesetUnchanged` returns z, so a season change across a map
>   *connection* would not re-patch. Cache `wOldSeason` beside `wOldTileset` and compare
>   both — ~10 bytes and one unsaved WRAM byte. Deliberately **not** done during M2: it
>   is dead code until tiles exist and it touches map loading.
> - **Winter's palette is currently doing work the tiles should do.** shasocastris kept
>   Christmas's saturated values, which read as icy only because that hack redraws its
>   tiles as snow. A retune was tried (`21a70a1`) and reverted (`12940a1`);
>   `git revert 12940a1` restores it, and it is worth re-evaluating once tiles land.
>
> Scope when it happens: 79 outdoor maps across 8 tilesets, but `TILESET_KANTO` (38),
> `TILESET_JOHTO` (30) and `TILESET_JOHTO_MODERN` (4) cover 72 of them.

### What changed now that M1 has landed **[CONFIRMED against the merged tree]**

- **Wild tables accept variant indexes.** `ValidateTempWildMonSpecies` is bounded by
  `NUM_POKEMON_AND_VARIANTS`, so §5.4/§5.5 example data *may* reference variants.
  Winter is the natural home for a variant coat — but see the caution below.
- **Nothing structural changes.** `_SeasonWildmonCheck` is unaffected by the variant
  system; wild data is still `dbw level, SPECIES` and still 16-bit indexes.
- ⚠️ **`wReservedSaveData` no longer exists.** M1 spent all 8 bytes on the per-form
  caught arrays. `wSeason` and `wSeasonalFlags` are still reserved and untouched, so
  M2 as specified needs no save break — but there is **no general-purpose reserve left**
  if M2 discovers it needs a byte the spec did not anticipate. Find that out early.
- **`wCurRegion` is live** at `$dbf2`, refreshed by `UpdateCurRegion` from
  `CopyMapPartialAndAttributes` on every map load. If seasons ever want to vary by
  region, the cached value is already there and correct.

### Open question #2 from the seasons doc, revisited

The seasons doc asks whether seasonal encounters should use variants, with a default of **no**. With M1 complete, that becomes viable rather than speculative.

Recommendation stands at **no for the first pass.** Coupling seasons to variants on their first outing together means any bug is ambiguous between two new systems. Land seasons with vanilla species, confirm it works, then introduce variants as a follow-up commit *on the same branch* where the interaction can be isolated.

### Reserved space

`wSeason` and `wSeasonalFlags` are already reserved by M0. **Phase 1 of the seasons doc should be amended to fill reserved bytes rather than add new ones** — no save break at M2.

### ⚠️ Decision M2 forces on behalf of M4

Seasons Phase 4 adds a **season axis** to the OW sprite palettes below `NUM_OW_TIME_OF_DAY_PALS`. M4 will add `rain` and `sand` rows to each time-of-day block of the same file.

Multiply those and you get 4 seasons × 4 times of day of weather palette rows.

**Decide during M2 whether weather palettes are exempt from the season axis.** Recommendation: **exempt them.** Rain looks like rain in July. Structure the palette tables during M2 so the weather rows sit outside the seasonal block, and M4 adds two rows per time-of-day rather than eight per weather type.

Getting this wrong means reshaping the palette table twice. Record the decision in the M2 branch, not in the M4 branch.

> **[DECIDED — shasocastris, 2026-08-20, on the `66-seasons` branch. The recommendation above
> was NOT taken.]** Weather palettes **are seasonal**. The table shape is
> `[season][weather][time-of-day]`, so M4 adds **32 rows** for rain + sand, not 8.
> Two corrections to the arithmetic above: this hack has `NUM_DAYTIMES == 4` (EVE
> exists), and the weather palettes are **OB** palettes loaded by `LoadWeatherPal`,
> a different table from the BG work in seasons doc §6 — M2 fixes the shape, M4 builds
> it. §7.1's prerequisite row is inverted accordingly. See
> `seasons_implementation_context.md` §9.

---

## 6. M3 — Third region (Orange Islands)

**Branch:** `67-orange-islands`
**Basis:** the five-layer breakdown from the same 18 Aug chat.
**Size:** by far the largest of the three. Expect it to dwarf M1 and M2 combined.

### 6.1 The five layers

**Layer 1 — Landmarks.** The region system is **landmark-based**, not map-group-based. `RegionCheck` reads the landmark ID from `GetWorldMapLocation`. In `constants/landmark_constants.asm`, add a landmark block wrapped in boundary markers following the existing Johto/Kanto pattern:

```
DEF ORANGE_LANDMARK EQU const_value
	const LANDMARK_MIKAN_ISLAND
	const LANDMARK_NAVEL_ISLAND
	; ...
DEF ORANGE_LANDMARK_LAST EQU const_value - 1

	const ORANGE_REGION
DEF NUM_REGIONS EQU const_value
```

The boundary-marker idiom is the key trick — it lets `RegionCheck` use simple `cp` range checks with **zero added code per new landmark**. Then add coordinate/name entries to `data/maps/landmarks.asm`.

**Layer 2 — `RegionCheck` rewrite.** `engine/overworld/landmarks.asm`. Currently a two-way compare with a `LANDMARK_VICTORY_ROAD` edge case and `LANDMARK_FAST_SHIP` / `LANDMARK_SPECIAL` handling via `wBackupMapGroup` / `wBackupMapNumber`. Becomes three-way. **Preserve the existing edge cases** — they are load-bearing and easy to lose in a rewrite.

**Layer 3 — Battle music.** `PlayBattleMusic` in `engine/battle/start_battle.asm` currently branches on `e == 0` vs non-zero. Becomes a three-way branch on both the wild and trainer paths. Note the existing night-variant check on the Johto wild branch.

**Layer 4 — Map groups and maps.** `newgroup` blocks in `constants/map_constants.asm`, pointers in `data/maps/maps.asm`, plus per map: an `attributes.asm` entry, a `.blk` file, and a script/events file. **`MAP_LOCATION` in the attributes struct is the link between a map and the region system** — get it wrong and the map silently belongs to Johto.

**Layer 5 — Spawn points.** `SPAWN_*` constants in `constants/map_data_constants.asm` (which already has commented `; kanto` / `; johto` section markers — follow the convention), plus entries in `data/maps/spawn_points.asm`.

### 6.2 Additional work the original breakdown didn't cover

Surfaced by the seasons investigation:

- **`_JohtoWildmonCheck`** in `engine/overworld/wildmons.asm` is a boolean (`IsInJohto` → `hl` or `de`). Becomes a three-way dispatch. The seasonal hook sits **upstream** of it and is unaffected.
- **`FindNest`** takes `e: 0 = Johto, 1 = Kanto` — a boolean that must become a three-value index. The Town Map is also currently two pages.
- **`LookUpGrassJohtoWildmons`** (used by `RandomPhoneWildMon`) is hardcoded to the Johto table.
- **New wild data files** — `orange_grass.asm`, `orange_water.asm` — and their bank placement.
- **Fish groups** for island waters (`data/wild/fish.asm`).
- **Seasonal coverage decision:** ~~do the Orange Islands have seasons?~~ **DECIDED — shasocastris, 2026-08-22: NO.** The Orange Islands are tropical and do not get seasons. Implementation is to simply omit their maps from `season_grass_data.asm` / `season_water_data.asm`; a map absent from a season's table falls through to its base entry, which is exactly the desired behaviour and costs nothing. **Consequence:** `orange_grass.asm` / `orange_water.asm` need only one roster each, and M2's `_SeasonGrassWildmonCheck` hook needs no change — it already sits upstream of the region dispatch.

### 6.2a ✅ Pulled forward from M4 — the map weather field **[DONE 2026-08-26, `75f908885`]**

> Landed **after** the M3 merge rather than during M3, as a standalone commit on `core`.
> `constants/weather_constants.asm` holds the `OW_WEATHER_*` block; the `map_attributes`
> macro takes an optional 5th argument defaulting to `OW_WEATHER_NONE`, so all 423 maps
> carry a byte without 423 edits. Every map is currently NONE — **per-map values for the
> islands are still shasocastris's design call**, and are now a one-argument edit.
>
> ⚠️ The runtime byte is `wMapWeather` in **WRAM0**, not a wider `wMapAttributes`.
> That struct sits below the saved block in an unpinned section; growing it shifts
> `wEventFlags`/`wSeason`/`wVisitedSpawns`/`wDigWarpNumber` and breaks every save.
> `CopyMapAttributes` consumes the byte **after** its loop, because `GetMapConnections`
> reads connection structs straight from `hl` afterwards.


**Add a weather byte to the map attributes struct during M3, even though nothing reads it yet.**

Port guide §10 step 9 makes the case: `SetCurrentWeather` in the source project is a hardcoded chain of map-id compares, and the right design for a fresh port is a map-attributes field, with only genuinely conditional cases (overcast rain, story-gated blossoms) left in code.

That is an attributes-struct change. Do it after M3 and you retrofit every map across three regions. Do it during M3 and the Orange Islands maps get it at authoring time for free.

Scope for M3:

- Add the field to the attributes struct in `data/maps/attributes.asm` and its macro
- Every existing map writes `OW_WEATHER_NONE`
- Nothing reads it — `SetCurrentWeather` does not exist yet
- Orange Islands maps get real values as they're authored

~~Also decide during M3: **do the Orange Islands get weather?**~~ **DECIDED — shasocastris, 2026-08-22: YES.** The islands get weather, so the map-attributes field is useful immediately rather than speculative. Note this pairs with the no-seasons decision above: the islands vary by *weather*, not by season, which is a cleaner thematic split than having both.

> Note this creates a dependency on `constants/weather_constants.asm` existing. Add just the `OW_WEATHER_*` const block during M3 — a dozen lines, no engine code.

### 6.3 Acceptance

- `RegionCheck` returns the correct region for every map in all three regions, including the `FAST_SHIP` / `SPECIAL` / `VICTORY_ROAD` edge cases.
- Battle music correct in all three regions, wild and trainer, day and night.
- Blackout from an Orange Islands map spawns correctly.
- Town Map handles three regions.
- Johto and Kanto behaviour unchanged in every respect.

---

## 7. M4 — Overworld weather particles **[BUILT on `68-ow-weather`, pushed 2026-10-15; `core` is 20 commits behind — merge after play-test]**

**Branch:** `68-ow-weather`
**Full spec:** `overworld_weather_port_guide.md` — architecture, per-file breakdown, integration table, porting checklist, tuning reference.
**Nature:** a **port**, not a design. The engine is written; the work is fitting it to this codebase.

### 7.1 Prerequisites carried by earlier milestones

| Item | Milestone | Status check before starting M4 |
|---|---|---|
| `wOvercastRandomDay` / `wOvercastRandomMaps` reserved | M0 | Confirm the bytes exist and are checksummed |
| ~~Weather palettes exempt from the season axis~~ **Weather palettes ARE seasonal** | M2 | **Decided against exemption — see §5.** Confirm the OB weather palette table is shaped `[season][weather][time-of-day]`: 32 rows for rain + sand |
| `OW_WEATHER_*` constants exist | M3 | Added as part of the attributes field |
| Map attributes weather byte | M3 | Every map carries a value, even if `OW_WEATHER_NONE` |

If any is missing, **add it on its own commit before starting the port** rather than folding it into M4 — particularly the M0 item, which is a save-format change.

### 7.2 Phase 0 — Verification (read and report, write no code)

The port guide's §10 checklist assumes a generic pokecrystal base. These are the Crystal Eclipse specifics to confirm first.

**A. VRAM — the tightest constraint.** The guide reserves `vTiles0 $6d`–`$6e`, between the headbutt-tree tiles and `OverworldEffectGFX`. **Audit everything this project loads into `vTiles0 $60`–`$7f`.** Crystal Eclipse has custom overworld features (surf-preserving warps, the MACHETE key item replacing CUT, overworld Pokémon sprites among the ~30 hidden locations) that may have claimed that space. Report the actual free gaps.

**B. OB palette slot.** `PAL_OW_WEATHER EQU 6` is a **hardware OB palette slot** — a different numbering space from this project's `PAL_OW_RED`…`PAL_OW_TREE` `MapObjectPals` indexes. Do not conflate them. This project has a dynamic OB palette allocator (`ClearSavedObjPals`, `CheckForUsedObjPals`, `NO_DYN_PAL_APPLY_F`), so the port needs a hardware slot the allocator will never hand out. Confirm one is available and identify it.

**C. `wPlayerStepVectorX/Y`.** Port guide §10 step 7: without these, particles slide across the screen instead of through the world. Determine whether this project has them, and if not, where the signed camera delta accumulates.

**D. Collision constant collision.** `SpawnCherryBlossom` reads `COLL_CHERRY_LEAVES` ($d0). This project has **custom collision constants** — `COLL_WARP_SURF_DOWN/UP/LEFT/RIGHT` using WATER_TILE permissions. Confirm $d0 is free.

> ⚠️ **Prior finding, directly relevant:** duplicate `tilecoll` entries cause wrong collision assignment, because the assembler matches on the first entry. If a cherry-leaf collision is added, verify no duplicate entry silently shadows it.

**E. OAM headroom.** The engine claims OAM slots from the front while map objects occupy the tail. Confirm nothing in this project already writes to the front of `wShadowOAM` outside the map-object system.

### 7.3 Phases

| Phase | Content | Gate |
|---|---|---|
| 1 | Constants, RAM, VRAM tiles, graphics, palettes | Builds; tiles visible in BGB VRAM viewer |
| 2 | Port `engine/overworld/weather.asm`; hook `DoOverworldWeather` into the overworld frame only | **Rain falls on one hardcoded map.** Vertical slice gate. |
| 3 | Remaining hooks per port guide §9 — textbox freeze, battle save/restore, menu restore, Fly, ledge hops, lightning suppression | No visual glitch on any transition |
| 4 | `SetCurrentWeather` reading the M3 attributes field, plus `mapsetup` wiring | Weather changes correctly on warp and connection |
| 5 | `GetOvercastIndex` — the weekly roll, filling M0's reserved bytes | Overcast persists across save/reload |
| 6 | **Seasonal weather integration** — see §7.5 | Snow in winter, blossoms in spring |

Phase 2 is the gate. Do not proceed until rain falls correctly on a single map.

### 7.4 Two bugs in the source — fix, don't reproduce

Both are flagged in port guide §11. Neither should be carried across.

1. **`sand.png` is 8×16 but `weather_gfx SandGFX, 1` loads one tile.** Decide which is right and make the PNG and the count agree.
2. **`LoadWeatherPal.snow` writes `wLoadedObjPal7` while `PAL_OW_WEATHER` is 6.** Snow looks correct but the "already loaded" marker lands in the wrong slot, so `DoOverworldSnow` re-`farcall`s `LoadWeatherPal` **every weather frame**. This matters more here than in the source: with a dynamic allocator present and seasonal palette work on the same frame budget, fix it at port time.

### 7.5 Seasonal weather — the payoff **[BUILT — `db7272dab`, `809574b0b`]**

The reason M4 sits after M2. What landed, against the original sketch:

- **Winter** — ✅ snow across outdoor Johto, and **unconditional**: every outdoor Johto map, every day of winter. See the open question below.
- **Spring** — ⚠️ **not** region-wide. Cherrygrove keeps it as a special case, now gated to spring with `OW_WEATHER_CHERRY_BLOSSOMS | OW_WEATHER_SPRING`. Going region-wide was blocked on `COLL_CHERRY_LEAVES` existing on real tiles, which it now does — so this is reconsiderable, but blossoms on every Johto route every spring is a lot of screen noise.
- **Autumn** — ✅ raised overcast weighting, via the same `.SeasonWetness` threshold the roll uses (35% against spring's 20%). Falling leaves as a fifth weather type: **not built**, needs art.
- **Summer** — ✅ clear-weather bias, 10%.

> ⚠️ **The timing-collision warning below is STALE. Do not act on it.** It argues for a midweek `add 3` offset in `GetSeason`. That was put to shasocastris at M2 kickoff and answered **no**, deliberately — one weekly "the world changed" beat rather than two — with *"do not revisit later, changing it shifts every existing player's season phase"* (`docs/seasons_implementation_context.md:1458`). It is also moot: the overcast roll as built is per-map hashed and re-seeded daily, not weekday-keyed, so it has no weekly cycle to phase-lock against the season in the first place.

#### Open, deferred with the winter tiles — **ALL DECIDED AND BUILT 2026-10-14/15**

> Superseded: winter snow is a 40% per-map daily roll; Kanto gets full winter (tiles, roofs,
> weather), the Orange Islands none and summer palettes; cherry trees get a winter canopy with a
> brown trunk. M2 Phase 6 (winter tiles) is done for Johto, modern, Battle Tower, the park and
> Kanto. Also added: sunny days (spring 15% / summer 30%, daytime only, sun in battle), battle
> weather following the overworld outdoors, icy recoloured roofs. See
> `docs/seasonal_cluster_handoff.md`'s top update block. The text below is history.

Three seasonal-presentation items, all judged in play and left alone deliberately. They are grouped because two of them want the **same** machinery — seasonal tile patching, `LoadMapGroupRoof`-style, which is what seasons doc §6 already proposes for the winter tileset.

1. **Winter snow never lets up.** Unconditional means a quarter of the year has no weather variety at all, and the roll, the seed and `.SeasonWetness`'s winter row are all dead code in Johto winter. The middle option is to let winter go through the roll at a high threshold (~70%), so it snows most days and the occasional clear one feels like a break. Deliberately kept for now: snow is standing in for the absent winter tileset, and an intermittent stand-in is a weak one.
2. **Kanto gets no winter snow.** Only Johto is gated in, so crossing the border in January goes from blizzard to drizzle. The Orange Islands being excluded is clearly right; Kanto was excluded only because this section said "outdoor Johto".
3. **Cherry trees stay pink all year.** Block `$ac`'s canopy uses `PAL_BG_RED`, and the season axis in `.OutdoorColors` varies **only** the GREEN slot — every other slot is the summer value in all four seasons, so only the block's four corner tiles follow the season. Giving RED a season axis would recolour everything else using it across Johto, and there is no spare BG slot. Seasonal tile patching is the answer, and it needs four canopy variants drawn.

**Item 1 and 2 are design calls needing no art. Item 3 needs art and shares its machinery with the winter tiles.**

### 7.6 Acceptance

- Each weather type renders correctly on a map configured for it.
- Map objects remain visible in the heaviest weather (the reverse-iteration sprite limiter works).
- No visual glitch entering or leaving: battles, menus, textboxes, Fly, ledge hops, map connections.
- Weather drains smoothly on a weather change rather than popping.
- Overcast state survives save and reload.
- Lightning does not fire during a map-name sign, a headbutt shake, or a Fly.
- Frame rate holds on the busiest overworld map with maximum particle density.

---

## 8. Risk register

| Risk | Milestone | Mitigation |
|---|---|---|
| ~~16-bit conversion table rejects variant indexes~~ | M1 | **Retired.** The table is index-agnostic — §4.1 answer 1 |
| `ValidateTempWildMonSpecies` silently discards variant encounters | M1 | **Confirmed live.** Widen the bound before any variant enters a wild table — §4.1 answer 4 |
| Type-completion GC churn repoints IDs held outside the collector's scan list | pre-existing | Not caused by variants; own cleanup pass — §4.1 answer 2 |
| Type completion / PCNY gates change meaning silently | M1 | Decisions recorded explicitly in §4.3 before coding |
| Missed table in the `NUM_POKEMON` grow/don't-grow split | M1 | **Done — §4.2 Layer 3 carries the full classification.** Do not re-derive it from the stale header comment |
| ~~Four separate save breaks~~ | all | **Retired.** M0 shipped 37 reserved bytes including the M4 overcast bytes |
| Rebase cascade across stacked branches | all | Merge each milestone to `core` promptly; never keep three unmerged |
| Season-gated content blocks progression | M2 | Rule stated in seasons doc §7.3; PR must state which side each gate falls on |
| Weather palette table reshaped twice | M2 | Season-axis exemption decided during M2 — see §5 |
| `RegionCheck` rewrite drops an edge case | M3 | Explicit acceptance test per edge case |
| M3 scope creep | M3 | Split into sub-branches per layer; layers 1–3 are shippable without any maps existing |
| ~~Attributes field retrofitted across three regions~~ | M3 | **Retired.** Weather byte added 2026-08-26 (`75f908885`), just after the M3 merge — see §6.2a |
| No free `vTiles0` gap for the weather tiles | M4 | Phase 0 audit is blocking — see §7.2A |
| OB palette slot claimed by the dynamic allocator | M4 | Phase 0 verification — see §7.2B |
| Sprite limiter culls map objects instead of particles | M4 | Covered by §7.6 acceptance; the reverse-iteration order is the mechanism |

---

## 9. Suggested cadence

M0 is an afternoon. M1 is the one to take slowly — its Phase 0 determines whether the design survives contact with the 16-bit species system, and its §4.3 decisions have retroactive reach into shipped systems. M2 is fully specced and should move quickly. M3 is a project in its own right; treat layers 1–3 (landmarks, `RegionCheck`, music) as a shippable first slice that can land before a single Orange Islands map exists. M4 is a port rather than a design, so its duration is dominated by Phase 0 — if VRAM and the palette slot come back clean it moves fast, and if they don't, resolving that is the milestone.

A useful checkpoint: after M1 merges, play an existing save for half an hour. Variants touch the species system that everything else in the game reads from, and the failure mode is subtle — wrong sprite, wrong stats, a dex entry that doesn't tick — rather than a crash.

A second checkpoint after M4: weather runs on every overworld frame and competes for OAM with map objects. Walk a crowded map — Goldenrod, a route with several trainers and overworld Pokémon — in heavy rain and confirm nothing disappears.

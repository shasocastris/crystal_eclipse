# M2 Seasons — Status Reference

**Branch:** `66-seasons` (tracks `origin/66-seasons`)
**As of:** 2026-08-22, through commit `b23c590`
⚠️ `origin/66-seasons` is still at `ee4feb1` — the last **seven** commits are unpushed.
M2 is **ready to merge to `core`** (roadmap §2); shasocastris is doing the merge.
**Full spec:** `seasons_implementation_context.md`. **Where this file and that one
disagree, this one is right** — the spec was written before the code existed and
several of its assumptions were corrected against the real files.

---

## 1. What is built

| Phase | State |
|---|---|
| 1 — constants, `GetSeason`, change detection | **DONE**, play-tested |
| 2 — `checkseason` opcode + vertical slice NPC | **DONE**, play-tested |
| 3 — seasonal wild encounters, grass and water | **DONE**, play-tested |
| 4 — seasonal palettes | **DONE**, play-tested |
| *(extra)* seasonal time-of-day schedule | **DONE**, play-tested |
| *(extra)* Pokégear clock shows season + TOD | **DONE**, play-tested |
| *(extra)* encounter data format overhaul | **DONE**, byte-verified |
| 5 — seasonal NPCs and events | **DONE**, all three parts play-tested |
| 6 — winter tiles | **NOT STARTED** (reframed, see §6) |

### Commits, oldest first

```
28c2dd9  seasons: add SEASON_* constants, GetSeason, and season change detection
9f6121a  seasons: add the checkseason script command and a Route 30 vertical slice
aa2c84d  seasons: force a season by poking wSeason, not a debug override byte
f543d2a  seasons: seasonal wild encounters for grass and water
55d8713  wild: one encounter rate per grass map instead of one per time of day
e5953a3  wild: write seasonal encounter data as columns, one per season
99c6ea3  wild: summer is the base game, so its column becomes a sentinel
8b011fb  seasons: seasonal roof palettes
0776a3b  seasons: seasonal foliage palettes
d6d275c  seasons: fruit trees follow the seasonal foliage palette
21a70a1  seasons: retune winter away from the Christmas reference
12940a1  Revert "seasons: retune winter away from the Christmas reference"
ee4feb1  seasons: the time-of-day schedule shifts with the season
7ac6674  seasons: show the season and time of day on the Pokégear clock
2b5a356  seasons: the Bulletin Board reports the current season
97bd03d  seasons: season-gate object events, and register wSeasonalFlags
38c0f5f  Shift season and time one space to the left        (shasocastris, pokegear.asm)
e6baaa3  rtc: fix the blank clock box on the new-game and Continue screens
a0d03a6  wild: seasonal encounters for Route 35
b23c590  battle: store a bank per battle animation pointer
```

`f00fdf5` ("Actually add the code to make the forge work") is shasocastris's, unrelated.

`e6baaa3` fixes two bugs `ee4feb1` introduced in `GetTimeOfDayString` — a clobbered `hl`
and a near `call` across banks — which together blanked the clock box on the new-game
"What time is it?" screen, Oak's time confirmation, and the **main menu's Continue
screen**. Play-tested. See §10.

---

## 2. How to test anything

**There are two pokes, doing two different jobs. Mixing them is what makes seasons look
broken.** [cost a full debugging session, 2026-08-22]

| Poke | Address | Tests | Survives a day rollover? |
|---|---|---|---|
| `wSeason` | `$dbf0` | **consumers** — palettes, encounters, NPC gating, Pokégear, Bulletin Board | **No.** Overwritten. |
| `wStartDay` | `$d4b5` | **the calendar** — rollovers, transitions, `wSeasonalFlags` | Yes. It is the real anchor. |

`wSeason` holds an **INDEX**, not a mask: `00` spring, `01` summer, `02` autumn,
`03` winter. Works in both ROMs.

> ⚠️ **`$dbf0` is a cache with exactly one writer** — `GetSeason`
> (`engine/overworld/time.asm:37`). Every other site only reads it. Poking it does not
> move the calendar; it lies to the consumers until the next rollover recomputes the
> truth from `wCurDay` and overwrites it.
>
> **Never poke `$dbf0` in a test where a day passes.** Doing so produces a phantom
> "season skip" — poke winter, cross midnight, land in summer — that looks exactly like
> an engine bug and is not one. This is what §5.3 used to recommend; it no longer does.

**To move the calendar, poke `wStartDay` at `$d4b5`.** `wCurDay = wStartDay + hRTCDayLo`
(`FixTime`, `home/time.asm:155-161`), so **+7 advances the season index by exactly one**
and preserves the weekday. Take a step afterwards — `UpdateTime` runs every overworld
frame, but the reset needs `CheckTimeEvents` to come round.
**Play-tested (shasocastris, 2026-08-22): +7 rolls the season as expected.**

> ⚠️ **On a fresh save, poke only AFTER the Mom/Pokégear scene.** `special SetDayOfWeek`
> calls `InitDayOfWeek` → `AlignStartDayToSpring`, which recomputes `wSeason` back to
> spring. Anything poked before that is wiped. This cost two debugging rounds.

> ⚠️ **Palettes only reload on a map load**, and **seasonal palettes only apply to TOWN
> and ROUTE**. Testing inside a building shows nothing — that is correct behaviour, not
> a bug. Walk outdoors, then through a map transition.

### Reading these addresses without fooling yourself

- ⚠️ **shasocastris's BGB view shows 16-bit LITTLE-ENDIAN words, not bytes in address order.**
  A displayed `FF07` at `$d4c4` means `$d4c4` = **`$07`** and `$d4c5` = `$FF`. **The low
  byte is the lower address.** Getting this backwards on 2026-08-22 turned a perfectly
  good reading into a phantom bug hunt. Every symbol in this feature is a `db`, so
  always split the word and take the **low** half.
- **`wCurDay` is one byte** (`ram/wram.asm:2593`). Its neighbour `$d4c5` is
  `wObjectFollow_Leader`, which sits at `$FF` whenever nothing is following you — so a
  word read of `wCurDay` almost always shows a leading `FF` that means nothing.
  Likewise `$dbf2` (`wCurRegion`) rides along with `wSeasonalFlags`.
- **`wCurRegion` `$dbf2` is a free byte-order check**: `JOHTO_REGION` = 0,
  `KANTO_REGION` = 1 (`engine/overworld/landmarks.asm:44-47`), so in Johto it must read
  `$00`. If your split puts `$01` there, the split is backwards.
- **Invariant:** `wCurDay - wStartDay` must be in `[0, 140)`. `FixDays` caps
  `hRTCDayLo` below 140 before `FixTime` runs, and the hour carry adds at most 1. Use it
  to check a *split*, not to condemn a read.
- **`$D000-$DFFF` is the banked WRAM window**, so in principle confirm `$FF70` = 1
  before trusting `$d4c4`/`$d4b5`/`$dbf0`. (`wBGPals1` lives in bank 5, so the game does
  switch.) This has **not** actually bitten yet — it was a wrong guess at the 2026-08-22
  symptom, kept only because it remains a real hazard.
- **HRAM is unbanked**, so `hRTCDayLo` `$FF8E` / `hRTCHours` `$FF8F` / `hHours` `$FF94`
  are always safe to read and settle any dispute about the derived values.
- **The Pokégear is a reliable oracle.** Weekday and season both derive from `wCurDay`,
  so if it reads Sunday + Summer, then `wCurDay ≡ 7 (mod 28)` with no memory read at
  all. On 2026-08-22 it pinned `wCurDay` = 7, which is exactly what the raw read had
  been saying once the byte order was read correctly.

### Useful addresses

| Symbol | Address | Note |
|---|---|---|
| `wSeason` | `$dbf0` | index 0-3, **saved**. Cache — see the warning above. |
| `wSeasonalFlags` | `$dbf1` | **saved**, cleared on season change. Bit 0 = `ENGINE_ROUTE_30_SEASON_WATCHER`. |
| `wCurDay` | `$d4c4` | one byte; `mod 28` gives the true season, `mod 7` the weekday |
| `wStartDay` | `$d4b5` | the calendar anchor — poke this, not `$dbf0` |
| `wStartHour` | `$d4b6` | in-game hour = `wStartHour + hRTCHours`, so midnight sits at RTC hour `24 - wStartHour` |
| `wTimeOfDay` | `$d27f` | |
| `wBGPals1` | **`05`**`:d000` | ⚠️ **WRAM bank 5**, not 1. `PAL_BG_ROOF` colours 1-2 are at `WRA5:D032`; `PAL_BG_GREEN` is palette 2. BGB's VRAM viewer palette tab is easier. |

---

## 3. Corrections to the spec **[do not re-derive these]**

1. **`wCurDay` is NOT 0-139.** `FixDays` mods `hRTCDayLo` by 140, then `FixTime` adds
   `wStartDay` *without re-modding*, so it runs over `[wStartDay, wStartDay+139]`. What
   makes the season cycle continuous is the **period** being 140 (a multiple of 28), not
   the range.
2. **A new game does not naturally start in spring.** `_InitTime` leaves `wCurDay` on a
   multiple of 7 — a season boundary, but not necessarily boundary zero.
   `AlignStartDayToSpring` fixes this by adding whole weeks to `wStartDay`, which
   preserves the day of week and costs no saved byte.
3. **There are TWO calendar anchors at new game**, not one: `InitTimeOfDay` (Oak's clock)
   and `InitDayOfWeek` (Mom's weekday question). Both call `AlignStartDayToSpring`.
4. **`object_event` argument `\7` is never emitted.** The macro emits `db \9, \8` and
   drops `h1`; `\8` alone lands at `MAPOBJECT_TIMEOFDAY` and is always a TOD mask.
   `CheckObjectTime` ignores its high nibble. **See §5 for the trap this creates.**
5. **`NUM_DAYTIMES` is 4** — this hack has EVE.
6. **`wTimeOfDayPalset` cannot carry the season.** It is four 2-bit fields;
   `wTimeOfDayPal` is 2 bits wide.
7. **Two guards §6.2 asks for are unnecessary.** All 19 `IN_DARKNESS` maps are CAVE or
   INDOOR, so the TOWN/ROUTE restriction already covers darkness. `FORCED_PALSET_F` is
   tested once and **set nowhere** in the codebase.
8. **Script opcode comments have drifted.** `checkseason` is **`$ad`**, not the `$b0` the
   neighbouring comments imply. `loadmoveindex` is commented `$af` but sits at `$ac`.
   Only `assert_table_length` keeps the lists honest, and it checks *length*, not values.
   **Read the built ROM, not the comments.**

---

## 4. Architecture as built

### Season state

`wSeason` / `wSeasonalFlags` fill bytes M0 reserved. **No save-format change.**
`GetSeason` computes `(wCurDay / 7) % 4` by repeated subtraction and caches to `wSeason`.
It runs **only** on a day rollover (`CheckDailyResetTimer`) and at new game.

> **Every consumer reads the `wSeason` cache; nothing recomputes.** That is what makes
> poking `$dbf0` work as a hook for testing *consumers*. A first attempt at a separate
> `wDebugSeasonOverride` byte failed precisely because it was applied at compute time.
> **Any new season consumer must read `wSeason`.**
>
> The flip side, learned 2026-08-22: because `GetSeason` is the cache's **only writer**,
> any rollover discards the poke. `$dbf0` is useless for testing the calendar itself.
> See §2.

### The season and the weekday share a modulus **[derived, and play-test confirmed]**

`GetWeekday` is `wCurDay mod 7` (`home/pokedex_flags.asm:66-72`) with `SUNDAY = 0`;
`GetSeason` is `(wCurDay mod 28) / 7`. The season index therefore increments exactly
when `wCurDay mod 7` wraps 6 → 0.

**Every season begins on a Sunday and ends on a Saturday, and every Sunday is a season
change.** This is structural, not an artifact of the start alignment — which is why
`AlignStartDayToSpring` insists on adding *whole* weeks (its comment at
`engine/overworld/time.asm:54-58` is guarding this coupling).

Confirmed in BGB 2026-08-22: the Pokégear read **Sunday, Summer, 12:17 AM** — i.e.
`wCurDay ≡ 7 (mod 28)`, the first day of summer, 17 minutes after the transition fired.

Two consequences worth knowing:

- **Sunny of Sunday (Route 37) shares the boundary.** If she is out and the season did
  not just turn, the alignment is broken. Free cross-check, no memory reads.
- **The first season of a new save is short.** `AlignStartDayToSpring` preserves the
  weekday the player gives Mom while forcing spring, which leaves `wCurDay mod 28`
  *equal to that weekday* (0-6). Spring therefore starts mid-week and ends on the first
  Saturday. **Tell Mom it is Saturday and you get exactly one day of spring.** Not a bug
  — it falls out of honouring the weekday choice, and the alternative resets the weekday,
  which `engine/overworld/time.asm:54-58` explicitly rejects. Still the sharpest edge in
  the feature and worth seeing once. **Not yet play-tested.**

### The pointer-table pattern

Used identically in three places. To make anything seasonal, copy it:

```
	ld a, [wSeason]
	maskbits NUM_SEASONS   ; poked by hand in testing; never index off the end
	add a
	ld hl, SeasonSomethingTable
	...deref...
```

| Table | Seasons that differ |
|---|---|
| `SeasonGrassTables` / `SeasonWaterTables` (`wildmons.asm`) | all four; summer is an empty table |
| `SeasonRoofPals` (`color.asm`) | winter only — spring/summer/autumn share `RoofPals` |
| `SeasonTimesOfDay` (`rtc.asm`) | all four |

**Seasons that don't differ point at the same table.** No duplication, no placeholders.

### Encounters

`_SeasonGrassWildmonCheck` / `_SeasonWaterWildmonCheck` sit **after** the swarm check and
**before** the Johto/Kanto lookup, so swarms still win. A map absent from a season's
table falls through to the base table — which is how all 54 cave/dungeon/indoor grass
maps are handled.

**Coverage so far: 3 grass maps** (Route 30, **Route 35**, Route 45) and 2 water maps
(Lake of Rage, Route 41). Route 35 exists to test the Yanma swarm — see §11.

**Data lives in `data/wild/season_{grass,water}_data.asm`**, written once with one column
per season, `INCLUDE`d four times with `SEASON_COLUMN` selecting the column:

```
	def_season_grass ROUTE_30, ANYSEASON & ~SUMMER
	;          SPRING        SUMMER  AUTUMN        WINTER        ; SUMMER = base
	seasonrate 10,           -,      10,           6             ; 10
	; morn
	seasonmon  3, HOPPIP,    -, -,   5, SENTRET,   4, RATTATA    ; 3, LEDYBA
```

- **`SUMMER` is the base game.** Its column is the sentinel `-, -` and the map is omitted
  from `SummerGrassWildMons` (measured empty in the ROM).
- **The sentinel must occupy both argument slots** — the macros index positionally.
- **The trailing comment is a fifth column** showing what the sentinel resolves to.
  ⚠️ **Those comments drift. `utils/check_season_comments.py` verifies them** and exits
  non-zero on a mismatch. Run it after editing any base wild table.
- Grass entries are **66 bytes** — one encounter rate per map, not one per time of day.

### Palettes

`LoadMapPals` is a two-stage indirection: `EnvironmentColorsPointers` yields a table of
one-byte **indexes** into `TilesetBGPalette`, refined by time of day. The season axis is
`season * 32` added before the TOD offset, **only for TOWN and ROUTE**.

Only **`PAL_BG_GREEN`** varies — 12 new palettes at `$2c`-`$37`. `PAL_BG_BROWN` and
`PAL_BG_YELLOW` measured identical to vanilla in both reference hacks; `PAL_BG_ROOF` is
handled by `RoofPals`.

⚠️ **`PAL_OW_TREE` duplicates vanilla BG green byte-for-byte.** Anything using it strands
in summer. `FruitTreeSpriteGFX` was repointed to `PAL_OW_COPY_BG_GREEN`, which reads
`wBGPals1` and inherits the season for free. **Check for other duplicates before making
another BG palette seasonal.**

### Time of day

`GetTimeOfDayForHour` is the single classifier; `GetTimeOfDay` and `GetTimeOfDayString`
both call it, so the Pokégear clock cannot disagree with the world.

```
          morn     day      eve      nite     daylight
  spring  05-10    10-17    17-20    20-05      15h
  summer  04-10    10-18    18-21    21-04      17h
  autumn  05-10    10-16    16-20    20-05      15h
  winter  06-11    11-16    16-18    18-06      12h
```

Deliberately **not** seasonal: `BuenasPasswordCheckTime` and the Radio Tower gate (a
schedule, not a description), and Oak's one-off clock-setting line.
`MORN_HOUR`/`DAY_HOUR`/`EVE_HOUR`/`NITE_HOUR` survive only for those three sites.

---

## 5. Phase 5 — all three parts built

1. ~~**Bulletin Board season panel** (Goldenrod PokéCom).~~ **BUILT and play-tested.**
   Four `checkseason` branches at the top of `BulletinBoardScript`
   (`maps/GoldenrodPokecomCenter.asm`), before the swarm panel, each falling into a
   shared `BulletinSeasonCycleText` that states the weekly cycle. **Winter is the
   fall-through**, so a corrupt `wSeason` shows winter rather than nothing.
   Every claim the panel makes was checked against the shipped tables: daylight spans
   against `SeasonTimesOfDay`, roster/rate claims against `season_grass_data.asm`.
   ⚠️ The winter line "fewer #MON are out" is true of the **two** maps with seasonal
   rate drops (Route 30 10→6, Route 45 15→9); it reads as a world-wide claim, which
   becomes true as encounter coverage grows.
2. ~~**Season-gated NPCs**~~ **BUILT** (`97bd03d`), not play-tested. `object_event` takes
   an **optional 14th argument**, a season mask packed into the high nibble of the TOD
   byte. Zero extra bytes of map data.

   ```
   object_event 13, 43, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_DOWN, 0, 0,
       -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, Route30ForagerScript, -1,
       SPRING | AUTUMN
   ```

   > ⚠️ **The trap, and how it was defused.** 1748 objects pass `-1` (`$FF`, safe under
   > `CheckObjectTime`'s `cp -1`), but **12 pass a bare `DAY`/`NITE`/`MORN`/`EVE`** —
   > four of them **Mom, in the player's own house**. A `$0` default would make those 12
   > invisible in every season, silently and with no build error. The macro defaults the
   > nibble to `ANYSEASON`, fixing all 12 without touching a map file.
   > **Measured, not assumed:** all 1760 objects decoded out of the ROM give
   > `$ff`×1739, `$f1`×3, `$f2`×5, `$f4`×3, `$f8`×1, `$5f`×1 — **zero** empty season
   > nibbles. `PlayerObjectTemplate` (macro used without `def_object_events`) still `$ff`.

   Masks are evaluated in `LoadObjectMasks`, called **only** from `map_setup.asm` on map
   load. A gated NPC therefore never spawns rather than being made to appear, so §7.1's
   sprite-viewport limit does not apply — and a season change mid-map does not take
   effect until you re-enter, exactly as TOD gating already behaves.
3. ~~**`wSeasonalFlags`**~~ **BUILT** (`97bd03d`). All 8 bits registered, appended at the
   **end** of both `constants/engine_flags.asm` and `data/events/engine_flags.asm` —
   those constants index `EngineFlags`, so inserting mid-list renumbers everything after.
   ROM rows 173-180 read back as `$dbf1` bits `$01`-`$80`, row 172 unchanged.
   Only consumer so far: `ENGINE_ROUTE_30_SEASON_WATCHER`.

   ⚠️ **Testing the once-per-season clear needs a real day rollover**, not just a poke.
   `CheckDailyResetTimer` clears `wSeasonalFlags` only when `GetSeason` disagrees with
   `wSeason` on a rollover.

   > **[CORRECTED 2026-08-22 — the previous recipe here was actively misleading.]**
   > This section used to say "poke `$dbf0` to a *wrong* season, then advance the day".
   > That does fire the clear, but it also manufactures a phantom season jump (poke
   > winter, cross midnight, land in summer) that reads as an engine bug and cost a full
   > session to run down. **Do not do it.**
   >
   > **Correct recipe:** leave `$dbf0` alone entirely. Poke `wStartDay` `$d4b5` **+7**
   > and take a step. That is a genuine season change, so it exercises the real `cp b`
   > comparison rather than a manufactured disagreement. `$dbf0` advances by one and
   > `$dbf1` clears to `$00`.
   >
   > **Also test the negative case**, which is the half that breaks if the season
   > comparison is ever dropped: poke `$d4b5` **+1** instead. The day rolls over, the
   > season does not change, and `$dbf1` must **survive**.

**Rule (§7.3): no required progression may be gated behind a season.** A player hitting a
winter-only gate in spring waits up to three real weeks. Both slice NPCs are pure flavour,
so this holds.

### Where the vertical slices are

Both on **Route 30**, side by side at the south end, so one visit tests everything:

| Tile | Who | Tests |
|---|---|---|
| (12,43) | season watcher (`SPRITE_GRAMPS`, always present) | control + `wSeasonalFlags` |
| (13,43) | forager (`SPRITE_POKEFAN_M`, `SPRING \| AUTUMN`) | the season mask |

Expected: spring/autumn both present; summer/winter watcher only. The forager's dialogue
states his own gate, so no notes are needed while testing.

**Tile walkability was derived, not guessed** — `Route30.ablk` decoded against
`johto_collision.asm` and `CollisionPermissionTable`. The same decoder reproduces all 13
live Route 30 objects as `LAND_TILE` and the 3 dead fruit trees as out of bounds, which
is what makes it trustworthy. Route 30 is now at **17 objects**; four maps already carry
17 against `NUM_OBJECTS` 18.

---

## 6. Phase 6 — winter tiles, reframed

> **M4 added two more items that want this same machinery.** Cherry tree canopies stay pink
> all year (`PAL_BG_RED` is season-invariant), and any other tile whose seasonal look cannot
> be expressed through the GREEN slot has the same problem. See
> `docs/major_systems_roadmap.md` §7.5, "Open, deferred with the winter tiles" — whoever
> builds the tile patch should read those three items first and size the work for all of them.

§8 proposes a whole `TILESET_JOHTO_WINTER`. **There is a much cheaper mechanism already
shipped:** `LoadMapGroupRoof` (`engine/tilesets/mapgroup_roofs.asm`) runs from
`_LoadTilesetGFX2` after the tileset decompresses, reads `wMapGroup`, and copies **9
tiles** into `vTiles2 tile $0a`. That is how Goldenrod and New Bark share one tileset
with different roofs.

**A seasonal tile patch is that routine keyed on `wSeason`.**

| | tile patch | full tileset variant |
|---|---|---|
| New blocks / `.ablk` / `Meta` / `Coll` / `Attr` | none | none |
| Data | ~16 bytes × tiles changed (~30 = 480 B) | 2,230 B (johto, compressed) |
| **Art** | **only the tiles you change** | a whole 128×96 sheet |

Constraints: patched tiles want to be **contiguous**; it **replaces** tiles and cannot add
them (`johto.png` is exactly 192 and VRAM holds exactly 192); a tile used twice changes in
both places.

⚠️ **One fix needed:** `DeferredLoadMapGraphics` skips the reload when `TilesetUnchanged`
returns z, so a season change while crossing a map *connection* would not re-patch. Store
`wOldSeason` beside `wOldTileset` and compare both — ~10 bytes and one unsaved WRAM byte.

**Why this matters:** winter's palette is doing work the tiles should do. Christmas's
values (which shasocastris kept) read as icy because that hack redraws its tiles as snow. A
hand-authored retune was tried (`21a70a1`) and reverted (`12940a1`) — shasocastris preferred the
saturated version. `git revert 12940a1` restores it if tiles later change the calculus.

**Scope:** 79 outdoor maps across 8 tilesets, but three cover 72 — `TILESET_KANTO` (38),
`TILESET_JOHTO` (30), `TILESET_JOHTO_MODERN` (4).

---

## 7. Deferred: encounter authoring at scale

> ⚠️ **[CORRECTED 2026-08-22 during M3 Phase 0 — the figure below was wrong.]**
> **Bank `$0a` has 75 bytes free**, not ~6,500. That is rgblink's own number from
> `crystal_eclipse.map` (`TOTAL EMPTY: $004b`), measured after M2 merged. The bank holds
> the base wild tables, the seasonal tables, `BattleAnimationsGen2` and the
> `BattleAnimFunc_*` sections. **The bank-independence fix below is therefore mandatory
> for any further wild data at all — not "when needed".** There is no shortage of ROM
> overall: 467 KB free across ROMX, with banks `$47`, `$45` and `$78` each holding
> 15 KB.

~~**Bank `$0a` has ~6,500 bytes of headroom.**~~ Full outdoor coverage — 44 grass maps and
47 water maps at three authored seasons — needs **10,404**.

The season data **cannot** simply move to another bank: `ChooseWildEncounter` reads
`GrassMonProbTable` (in `$0a`) through `hl` in the same breath as the wild data, and
`LookUpWildmonsForMapDE` is itself in `$0a`, so the lookup cannot run under a bankswitch.

**Fix when needed:** have the season lookup farcall a routine living *in* the season bank
which copies the matched entry into a WRAM buffer, returning a bank-independent pointer.
~68 bytes of unsaved WRAM, ~40 bytes of code. Performance is a non-issue —
`TryWildEncounter` gates on `.EncounterRate` first, so this runs per *encounter*, not per
step.

Note `Map Attributes` was already floated out of `$0a` (`layout.link`) to make room for
Phase 3. `Trainer Backpics` (382 bytes) is the next portable section there.

---

## 8. Pre-PR checklist — 1 item still unverified (optional)

### Verified in BGB 2026-08-22 (shasocastris)

- [x] **A genuine midnight rollover advances the season**, on the correct weekday.
      Pokégear read Sunday, Summer, 12:17 AM — `wCurDay ≡ 7 (mod 28)`, 17 minutes past
      the transition.
- [x] **`wStartDay` `$d4b5` +7 rolls the season as expected**, and is now the documented
      way to move the calendar (§2).
- [x] **`wSeasonalFlags` clears on a season change and the watcher's "Season's turned"
      line fires.** `$dbf1` read `$01` after talking, so `setflag
      ENGINE_ROUTE_30_SEASON_WATCHER` sets the right bit at the right address —
      corroborating the ROM check of `EngineFlags` row 173 (`$dbf1`, mask `$01`).

### Still unverified — cannot be done without BGB

- [x] **Indoor and cave palettes identical in all four seasons** — the TOWN/ROUTE guard
      holds. Confirmed 2026-08-22.
- [x] **Flash works identically in all four seasons.** Confirmed 2026-08-22.
- [x] **Yanma swarm still overrides seasonal encounters.** Confirmed 2026-08-22 on
      Route 35 (swarm verified via Arnie and the PokeCom alerts): encounters were
      NIDORAN_M / NIDORAN_F / YANMA / PIDGEY / DITTO — the swarm roster — **in SPRING,
      where Route 35's seasonal table is live**, so this tests swarm-over-seasonal and
      not merely swarm-over-base. DITTO, NIDORAN and PIDGEY appear in neither the base
      table nor any seasonal column (verified: 0 occurrences in both), so three
      independent species confirm the swarm table was the one in use. `_SeasonGrassWildmonCheck` sits after the
      swarm check, as designed. Dunsparce not separately tested; same code path.
- [ ] Day 139 → 0 wrap produces no season skip *(proven arithmetically over three RTC
      cycles; worth one real look)*
- [x] **Summer shows base rosters on Route 30/45.** Confirmed 2026-08-22 — the
      `99c6ea3` sentinel resolves correctly.
- [x] **Mom is still in the house in all four seasons.** Confirmed 2026-08-22 — the
      `97bd03d` regression check, and the one that would have hurt most. The macro's
      `ANYSEASON` default correctly covers all 12 bare-TOD objects.
- [x] **Route 30 forager present in spring/autumn, absent in summer/winter.** Confirmed
      2026-08-22 — object season-gating works. This is the last of Phase 5's three parts.
- [x] **Season watcher's extra line fires once per season, then stops.** Both halves
      confirmed 2026-08-22: it fired after a season change, and a second talk in the same
      season gave the seasonal line only.
- [x] **`wSeasonalFlags` survives an ordinary day rollover.** Confirmed 2026-08-22 —
      the negative case for the `cp b` in `CheckDailyResetTimer`. Both directions of that
      branch are now exercised.
- [x] **New game telling Mom it is Saturday yields exactly one day of spring.**
      Confirmed 2026-08-22 — the short-first-season edge in §4 behaves as derived.

Already satisfied: Bug Contest uses a separate path; opcodes appended at the end
(`$ad`, verified in ROM); all dialogue within 18 chars; no save-format change (M0 reserved
the bytes).

---

## 9. Working practices that earned their place here

- **No emulator on the dev box.** Say plainly which claims are static and which need
  shasocastris's eyes.
- **A cache is not a test hook for the thing that fills it.** `$dbf0` tests season
  *consumers*; `$d4b5` tests the *calendar*. Poking a cache in a test where the thing
  that writes it runs will look exactly like a bug in that thing. One session lost;
  see §2. Before trusting any poke, ask **who writes this address** —
  `grep -rn "\[wThing\], a"` answered it in seconds here (one writer, `GetSeason`).
- **Establish the byte order of a memory view before reasoning about its numbers.**
  shasocastris's BGB view is 16-bit little-endian; reading it as bytes-in-address-order made a
  correct `wCurDay` = 7 look like `$FF` and sent this branch chasing a nonexistent
  256-byte wrap for three rounds. **Every symbol here is a `db` — split the word, take
  the low half.** When a reading looks impossible, suspect the transcription before the
  engine.
- **Keep a byte whose value you can predict independently.** `wCurRegion` `$dbf2` must
  be `$00` in Johto, which settled the byte order in one step. An invariant like
  `wCurDay - wStartDay ∈ [0, 140)` does the same job — but use these to test a *reading*,
  not to declare the read broken.
- **Verify table wiring by reading the assembled ROM by index**, not by grepping source.
  Used throughout; caught the `$ad` opcode drift and confirmed every pointer table.
- **Check `make`'s exit status**, not its output.
- **Run `python3 utils/optimize.py`** before and after and diff. `python` is not on PATH.
- **Run `python3 utils/check_season_comments.py`** after touching a base wild table.
- **Run `python3 utils/farcheck.py crystal_eclipse.sym`** after adding any call between
  files. RGBDS does **not** error on a near `call` to a label in another bank — it
  links fine and jumps into garbage at runtime. `ee4feb1` shipped exactly that
  (`GetTimeOfDayString` in bank `24` calling `GetTimeOfDayForHour` in bank `05`) and it
  went unnoticed for a day because no play-tested path reached it. Filter the noise with
  `grep -v "in bank 00"` — the home-bank hits are legitimate.
- **`git add -A` is wrong here.** `docs/`, `.idea/`, `.claude/`, `rgbds-1.0.0/` are
  untracked on purpose. Stage by name.
- **Docs in `docs/` are deliberately untracked.** Update them, never commit them.
- **Watch `jr` range.** Inserting code stretched an existing `jr` past 128 bytes **three
  times** this branch (`wildmons.asm`, `rtc.asm` twice). Prefer moving new code to the end
  of a file over converting an existing `jr` to `jmp`.
- **Map text is 18 characters per line**; `#MON` counts as 7.

---

## 10. Bug found 2026-08-22 — blank clock box (fixed, `e6baaa3`)

**Symptom (shasocastris, BGB):** starting a new game, the box above "What time is it?" is blank.

**Two independent bugs, both introduced by `ee4feb1`**, both in `GetTimeOfDayString`
(`engine/rtc/timeset.asm`). The old routine was four `cp`/`jr` pairs that set **only
`de`**; the rewrite made it a seasonal table lookup, and broke two contracts at once.

**1. `hl` was clobbered.** `PrintHour` keeps the **screen coordinate** in `hl` across the
call:

```
PrintHour:
	ld l, e
	ld h, d          ; hl = screen coord
	push bc
	call GetTimeOfDayString   ; left hl pointing at the string
	rst PlaceString           ; wrote to hl -- a ROM address
```

`PlaceString` then wrote into ROM and returned `bc` = that ROM address + length, which
`PrintHour` used for the digits. **Both halves of the line went nowhere.**

**2. A near `call` across banks.** `GetTimeOfDayString` is in bank `24`;
`GetTimeOfDayForHour` is in bank `05` (it sits at the end of `rtc.asm`, moved there to
avoid stretching a `jr`). RGBDS links a near `call` to an out-of-bank label without any
error, so it jumped into whatever is at `$40f0` in bank `24`.

**Fix:** `push hl` / `pop hl` around the body, `ld d, [hl]` / `ld e, a` instead of
round-tripping through `hl`, and `farcall GetTimeOfDayForHour`. `farcall` passes `a` in
and returns the callee's `a` (`ReturnFarCall`, `home/farcall.asm`), preserving
`bc`/`de`/`hl`/flags — so it is a drop-in.

**Blast radius — all three `PrintHour` callers**, none of which had been play-tested:

| Site | What was blank |
|---|---|
| `timeset.asm` `DisplayHourOClock` | the hour box on "What time is it?" |
| `timeset.asm` `OakText_ResponseToSetTime` | Oak's "so it's X:YY" confirmation |
| `main_menu.asm:180` | **the main menu's Continue clock** |

**Why it stayed hidden:** the Pokégear clock (`7ac6674`, play-tested) uses
`PrintHoursMins`, a different routine. Only new-game and main-menu paths reach
`PrintHour`, and neither had been walked since `ee4feb1`.

**Verified statically:** both ROMs build (exit 0), no new `optimize.py` warnings,
`farcheck.py` clean for this site, and the assembled routine decodes as
`e5 79 cf 05 f0 40 …` — `push hl`, then `rst FarCall` with `dbw $05, $40f0` — with the
`.strings` table still resolving 4/4 to MORN/DAY/NITE/EVE for `MORN_F`/`DAY_F`/`NITE_F`/
`EVE_F` = 0/1/2/3.

**PLAY-TESTED (shasocastris, 2026-08-22): the new-game clock screen renders again.** The other
two sites share the single `PrintHour` path, so they follow, but neither was walked.

**Lesson, now in §9 and the roadmap:** run `farcheck.py` after any call between files.
A routine that moves to a different file has very likely changed bank.

---

## 11. Route 35 seasonal encounters — for the swarm test (`a0d03a6`)

Added 2026-08-22 so the **Yanma swarm** check in §8 has something to override. All three
tables agree on map id `(10, 2)`: `JohtoGrassWildMons`, `SwarmGrassWildMons`'s Yanma
entry, and the new seasonal entries.

**The design makes the test unambiguous: winter has no YANMA at all.** Bugs overwinter,
so a wild Yanma on Route 35 in winter can *only* have come from the swarm. Spring and
autumn keep Yanma, at shifted levels.

| | rate | flavour |
|---|---|---|
| spring | 10% | bugs and grass emerging — HOPPIP, LEDYBA, SKIPLOOM, SPINARAK; levels 1-2 below base |
| summer | — | sentinel; base game |
| autumn | 10% | mature forms — SNUBBULL, NOCTOWL, GROWLITHE; levels 1-2 above base |
| winter | **6%** | hardy only — MAGNEMITE, VULPIX, GROWLITHE, HOUNDOUR, HOOTHOOT. **No YANMA.** |

The other tell is the swarm's own roster: NIDORAN_M / NIDORAN_F / DITTO appear in
**neither** the base nor any seasonal column, so seeing one proves the swarm won.

**How to run the check:** stand on Route 35 in **winter** (`$dbf0` = `03`, or poke
`$d4b5` +7 until the season lands there — see §2). With the swarm inactive you should see
no Yanma at all and a noticeably lower encounter rate. With the Yanma swarm active you
should see Yanma, Nidoran and Ditto at levels 10-14.

**Verified statically:** builds clean, `check_season_comments.py` passes, no new
`optimize.py` warnings, and all 21 rows × 3 seasons were decoded out of the ROM and match
the source. `SummerGrassWildMons` measured **empty** (`$6401` → `$6402`, one byte:
just its terminator), so summer still falls through to the base table.

**PLAY-TESTED (shasocastris, 2026-08-22): the swarm overrides the seasonal table.** See §8.


---

## 12. Poison Jab hang — a pre-existing bug this branch exposed (fixed, `b23c590`)

**Symptom (shasocastris, BGB):** using Poison Jab hung the game, in wild *and* trainer battles.
Hurricane and Rain Dance were fine.

**Not caused by seasons — but exposed by it.** All 15 offending pointers exist on `core`.

`LoadDoubleIndirectPointer` returned the bank of the **pointer table**, not of the target:

```
	call LoadIndirectPointer   ; b = sub-table's bank
	call nz, GetFarWord        ; hl = pointer read from it
	ld a, b                    ; <- table's bank, not the target's
```

`GetBattleAnimPointer` stored that in `wBattleAnimBank` and `GetBattleAnimByte`
bankswitched to it. So an unwritten invariant held: **an animation must live in the same
bank as the table referencing it.** 15 gen2 moves broke it by reusing gen1 animations:

```
AIR_SLASH  BRAVE_BIRD  ROCK_BLAST  ICE_SHARD  SCALD  AQUA_JET  AQUA_TAIL
WATER_PULSE  POWER_WHIP  X_SCISSOR  NIGHT_SLASH  DISARM_VOICE
ZEN_HEADBUTT  POISON_JAB  HYPER_VOICE
```

⚠️ **Why it surfaced now.** `BattleAnimationsGen2` is bank `0a` — *the same bank as the
seasonal wild data*. Poison Jab's pointer `$628d` was executed as `0a:628d`, which landed
4 bytes inside **`_SeasonGrassWildmonCheck`**, a routine this branch added. The engine ran
encounter-lookup code as animation commands. Before the branch, that address held
something that happened not to hang. **Authoring more seasonal encounters shifts bank `0a`
again** — so this class of latent bug can change symptom without changing cause.

**Fix:** the table now stores a bank per entry. `indirect_table 2, 0` -> `3, 0`, a new
`anim_ptr` macro emits `db BANK(x)` + `dw x` with a ROMX assert, and a new
`LoadFarIndirectPointer` (`home/indirection.asm`) returns the pointer's own bank.
`LoadDoubleIndirectPointer` is untouched, so its 9 other callers are unaffected.
Cost ~287 bytes of table plus 20 bytes of home.

A `BANK(\1) == BANK(@)` assert was considered and **rejected**: it enforces the invariant
the fix removes, and would fail the build on 15 legitimate pointers.

**Verified statically:** both ROMs build, no new `optimize.py` warnings, all 264 entries
decoded out of the ROM resolve to real `BattleAnim*` labels, POISON_JAB now reads
`0e:631b` = `BattleAnim_Acid`, and a sweep of the other **26** indirect sub-tables
(968 pointers) found **zero** cross-bank pointers, so nothing else needs this treatment.

**PLAY-TESTED (shasocastris, 2026-08-22):** POISON_JAB and HYPER_VOICE — both previously
cross-bank and hanging — now work in battle, and HURRICANE (the in-bank control) still
works. The other 13 share the identical mechanism and were verified out of the ROM, so
they are static-verified rather than played.

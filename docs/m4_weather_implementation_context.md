# M4 — Overworld weather particles: implementation context

**Branch:** `68-ow-weather`, cut from `core` at `00be08c06`.
**State:** All phases 1-6 committed. Phases 1-4 are play-tested. **Phases 5 and 6 are
built but NOT yet play-tested.**
**Nature:** a **port**, not a design. The engine is written; the work is fitting it here.

> **The source is on this box.** `~/polishedcrystal/` —
> `engine/overworld/weather.asm` (1306 lines), `engine/gfx/sprite_palettes.asm`,
> `engine/events/{weather,overcast}.asm`. Diff against it rather than working from the
> guide's prose; the guide paraphrases and is wrong in places.

**Read in this order:** this file → `docs/m4_phase0_audit.md` (what is different about this
codebase) → `docs/weather-particles-guide.md` (the engine itself, §7 flow, §9 hooks,
§10 checklist) → `docs/major_systems_roadmap.md` §7 (phases and acceptance).

---

## 1. Where the work stands

| Phase | Content | State |
|---|---|---|
| 0 | Verification audit | ✅ `docs/m4_phase0_audit.md` |
| 1 | Constants, RAM, VRAM tiles, graphics, palettes | ✅ `a4b9fa2bf` — gate passed |
| 2 | Port the engine; hook `DoOverworldWeather` into the overworld frame | ✅ `6072b4559` `9d202bea2` `6a053e8da` `aaddaad02` — gate passed |
| 3a–3f | Particles animate under, and are clipped off, textboxes and menus | ✅ `e9b03c126` `b15a984db` `72f5e1f39` `5cf3172f9` `d76ce94d9` `49ce7bb37` |
| 3g | Battle save/restore, Fly, ledge hops | ✅ `b6606df23` — play-tested |
| 3h | Lightning, and a reentrancy guard for it | ✅ `deeafceb6` `12893704b` `a48826122` — play-tested |
| 4 | `SetCurrentWeather` from the map attributes byte + `mapsetup` wiring | ✅ `f75e7d2ec` `da54fc860` — play-tested |
| 5 | Daily overcast roll, filling M0's reserved bytes | ✅ `db7272dab` — **untested** |
| 6 | Seasonal weather (roadmap §7.5) | ✅ `db7272dab` — **untested** |
| 7 | Overcast palettes — darken the world while weather runs | ✅ `801153378` `514facefc` `363148a97` — play-tested |

### Verification baselines (all currently met)

- `optimize.py` **608** — this is the number to stay at or below.
- `farcheck.py crystal_eclipse.sym` → **82** findings (56 cross-bank + 26 `rst`).
  ⚠️ **It needs the `.sym` argument.** Run bare it prints usage and exits 0, which looks
  like a pass. This cost a wrong number in the last doc.
- Save canaries unmoved: `wEventFlags $da66`, `wSeason $dbf0`, `wVisitedSpawns $dc01`,
  `wDigWarpNumber $dc09`. **Check these after every WRAM change.**
- ROM free 22.45% / 22.46% (release / debug).

---

## 2. What Phase 1 built

| File | What |
|---|---|
| `constants/weather_constants.asm` | `OW_WEATHER_*`, `NUM_OW_WEATHERS` (= 5, real weathers only), `wWeatherFlags` bits |
| `constants/sprite_data_constants.asm` | `PAL_OW_RAIN`, `PAL_OW_SAND`, and `PAL_OW_WEATHER EQU 6` |
| `gfx/overworld/{rain_splash,snow,sand,cherry_blossom}.png` | **placeholder art, wants redrawing** |
| `gfx/misc.asm` | `SECTION "Overworld Weather Graphics"` |
| `data/sprites/weather.asm` | `WeatherGraphics` table |
| `engine/overworld/weather.asm` | tile `EQU`s + `LoadWeatherGraphics` |
| `ram/wram.asm` | state (bank 1) + `wWeatherScratch` |
| `engine/overworld/overworld.asm` | one `jmp LoadWeatherGraphics` at the end of `LoadMiscTiles` |

### Addresses you will need in BGB

```
wCurWeather               $df7a   (bank 1)
wPrevWeather              $df7b
wWeatherFlags             $df7c
wOverworldWeatherTimer    $df7d
wOverworldWeatherCooldown $df7e
wLastWeatherVBlank        $df7f   (frame guard; was wSpriteOverlapCount)
wWeatherRunning           $df80   (reentrancy guard)
wWeatherMenuClip{L,T,R,B}         (menu box rectangle, OAM coords)
wWeatherTextboxClip               (nonzero while a textbox is open)
wWeatherClip{L,T,R,B}             (the rectangle being swept; scratch)
wWeatherScratch           bank 2
```

Re-read the addresses from `crystal_eclipse.sym` after any WRAM change — the block has
grown since Phase 1 and only the first five are still where that list put them.

VRAM: `WEATHER_TILE_1 = $60`, `WEATHER_TILE_2 = $61`, **VRAM bank 0**.

---

## 3. Five ways this codebase differs from the port guide

These are the whole reason Phase 0 existed. Do not port §10 literally.

1. **VRAM `$6d`–`$6e` does not exist here.** `FIELDMOVE_TREE` is `$84`.
   `GetSpriteVTile` (`home/map_objects.asm:14`) allocates **12 tiles per object struct**, so
   structs 0–7 fill exactly `$00`–`$5f` of VRAM bank 0. `WEATHER_TILE_1` is therefore
   `FIRST_VRAM1_OBJECT_STRUCT * 12` — an expression, not a literal, so it tracks the split.

2. **OAM is inverted — but weather still claims the front, as the source does.** Here
   `_UpdateSprites` starts at index 0 and grows **upward**, so the tail is what is free.
   Phase 2 tried the tail (via the dormant `LAST_12_SPRITE_OAM_STRUCTS_RESERVED_F`) and it
   worked, but **rain drew behind the player**: OAM index is OBJ-to-OBJ draw priority on
   CGB, and there is no per-sprite OBJ-over-OBJ bit — `OAM_PRIO` is BG-over-OBJ, and `rOPRI`
   coordinate mode would upend every sprite in the game. So weather owns structs 0–11 and
   `_UpdateSprites` starts map objects at struct 12, under a new
   `FIRST_12_SPRITE_OAM_STRUCTS_RESERVED_F`. Map objects keep 28 structs either way.
   Do **not** reuse `LAST_12_...` for this: its name means the opposite and `mobile_46` uses
   it. Claiming the front is also the *smaller* change — map objects grow away from the
   window, so `.fill`'s default bound is already correct and the sprite writer needs no
   limit at all.

3. **HRAM is full (127/127).** `hUsedWeatherSpriteIndex` is in WRAM instead. Anywhere the
   guide says `ldh`, use `ld`.

4. **No hardware OB slot is free.** `CheckForUsedObjPals` (`engine/gfx/dynamic_pals.asm:146`)
   scans all 8 bits of `wUsedObjectPals` and evicts slot 7 when full. We kept
   `PAL_OW_WEATHER EQU 6` and rely on the guide's own §6 design: each weather frame
   re-checks `wLoadedObjPal6` and reclaims the slot. **If that thrashes visibly in Phase 2**,
   the fallback is to pre-mark bit 6 in `wUsedObjectPals` after every `ClearSavedObjPals`,
   which costs map objects one palette everywhere.

5. **No season axis on OW palettes.** `MapObjectPals` is
   `NUM_OW_TIME_OF_DAY_PALS × NUM_DAYTIMES` (now 19 × 4 = 76 rows). The roadmap §7.1
   expectation of a `[season][weather][time-of-day]` table with 32 rain+sand rows is wrong
   for this codebase. Weather palettes are time-of-day only, like every other OW palette.
   Adding a time-of-day pal means **three** edits: the const list (before
   `NUM_OW_TIME_OF_DAY_PALS`), 1 row per block in `npc_sprites.pal`, **and** 1 row in
   `npc_sprites_darkness.pal`.

### Guide bugs

- **#1 `sand.png` size vs tile count — fixed in Phase 1.** Our PNG is 8×8 and the count is 1.
- **#2 `LoadWeatherPal.snow` writes `wLoadedObjPal7` while `PAL_OW_WEATHER` is 6 — fixed in
  Phase 2a.** Left uncorrected it re-`farcall`s `LoadWeatherPal` every weather frame.
- **#3 the four `Do*Fall` loops read `[$0000]` — fixed in Phase 2a.** `ld hl, OAMA_Y` with no
  `add hl, de`, so the hidden-slot test reads a ROM byte. It does not hang (that byte is
  `$f3`), but a hidden rain splash keeps its tile and palette, so the loop treats it as live
  and can walk it back on screen.

---

### Found during Phase 2, not in the audit

- **Setting `LAST_12_...RESERVED_F` was not sufficient.** It is only read by
  `_UpdateSprites.fill`, the pass that *hides* slots. The pass that *writes* them
  (`map_objects.asm:2865`) bounded against `LOW(wShadowOAMEnd)` unconditionally, so map
  objects could still land in structs 28–39 — and with `.fill` now stopping at struct 28,
  an object leaving the screen stranded a sprite there forever. The writer takes the same
  limit now (borrowing `e`, dead between the coordinate math and `.addsprite`).
- **The flag is set in one place already** — `mobile/mobile_46.asm:111`, not "nowhere".
  Harmless; mobile never runs the overworld frame.
- **`bank5` had `$97` bytes free** and the engine is `$05a8`, so weather moved to its own
  `SECTION "Overworld Weather"` (landed in bank 6) and `LoadMiscTiles`' tail call became a
  `farjp`.
- **The software sprite limiter was dropped**, deliberately. It exists in the source only
  because weather sits at the *front* of OAM there, where the hardware's 10-per-scanline
  rule would cull map objects instead of particles. With weather in the tail the hardware
  culls particles first already. Porting it verbatim would have been actively wrong — it
  iterates backwards, so here it would cull map objects. This also spares `wWeatherScratch`
  an `ALIGN[8]` that `SpriteLimitExceeded`'s `ld h, HIGH(...)` / `ld l, a` would demand
  (it currently sits unaligned at `$dd97`). Revisit only if particles visibly hide NPCs.
- **Guide bug #3, fixed:** all four `Do*Fall` loops in the source do `ld hl, OAMA_Y` with no
  `add hl, de`, so the hidden-slot test reads `[$0000]`. It does not hang (that byte is
  `$f3`, not 160), but a hidden rain splash keeps its tile and palette, so the loop treats
  it as live and can walk it back on screen.
- **`Lightning` is deferred to Phase 3.** CE has no `wPalWhiteState`,
  `NO_DYN_PAL_APPLY_UNTIL_RESET_F`, `OWFadePalettesInit` or `SFX_THUNDER_OW`. It has
  `SetWhitePals`, `ApplyPals`, `LoadMapPals`, `FadeInPalettes_EnableDynNoApply` and
  `SFX_THUNDER` to build it from.
- **`StackJumpTable` does not exist** here; `ld hl, .Jumptable` / `jmp JumpTable` replaces it.
  `NO_PAL_LOADED` does not exist either — it is a literal `-1`.
- **`rSVBK` and `rWBK` are the same register** (`hardware.inc:688`, `:1108`). Either spelling
  assembles; the tree uses both.
- **`ClearSprites` zeroes shadow OAM** — it byte-fills `$00`, *not* `OAM_YCOORD_HIDDEN`
  (`home/clear_sprites.asm:1`; `HideSprites` just below it is the one that writes 160).
  Every map load runs it via `ReloadTilesetAndPalettes`, so the reserved window comes back
  with `y = 0`, and `_UpdateSprites.fill` cannot repair it while the reservation is held.
  `ScanForEmptyOAM` therefore treats a slot as free when it is hidden **or** when its
  attribute byte is not `PAL_OW_WEATHER`; the window is self-healing rather than depending
  on a map-load hook that does not exist until Phase 4. Cost this a debugging round —
  weather ran until the first warp and then stopped for good (`6a053e8da`).

### Phase 3 — three separate reasons particles freeze

Each was found only by play-testing, and each has a different cause. Anywhere weather
looks frozen, work down this list before suspecting the engine.

1. **The loop never calls the engine.** `DoOverworldWeather` now hangs off `DelayFrame`
   (`home/delay.asm`), gated on `hMapAnims` — the same gate `AnimateTileset` uses from
   VBlank, which is why animated flowers never stop. That covers the overworld,
   `Script_pause` and Fly in one hook instead of the guide's four.
2. **The loop spins instead of sleeping**, so it never reaches `DelayFrame`. Two do:
   `PrintLetterDelay` while text types, and `Do2DMenuRTCJoypad` while a yes/no box waits.
   Both call the engine themselves. `DoOverworldWeather` is idempotent per frame — it
   records `hVBlankCounter` in `wLastWeatherVBlank` — so calling it from a spin is safe.
3. **OAM stops being transferred.** VBlank only calls `hTransferShadowOAM` when
   `hOAMUpdate` is zero, and several wait loops park it at 1 to buy VBlank time. Weather
   clears it whenever it is live. Symptom: the engine runs perfectly, the screen does not
   move.

### Phase 3 — the clip

Sprites always beat the background, so keeping particles off a box is not an OAM question.
The BG attribute priority bit cannot do it alone either: it only wins on colours 1–3, and
the box interior is colour 0 in `bg_text.pal`. **Tried and reverted** — rain fell through
the white middle while being clipped by the border and letters.

Instead `ClipWeatherSprites` sweeps the OAM window after the particles move and hides any
inside a UI rectangle. Two rectangles are tracked, because a yes/no box and the textbox it
covers are on screen together. The menu one is set in **`MenuBox`**, which every menu box
in the game is drawn through, and read back from `wMenuBorder*` rather than a menu header
because `DrawVariableLengthMenuBox` sizes boxes to their item count.

### Phases 5 and 6 — what was built, and what was not

**Precedence in `SetCurrentWeather`: an authored map byte always wins**, then the season
and the daily roll for maps that name nothing. The reverse would read more like the
roadmap's "snow across outdoor Johto in winter", but would bury Route 45's sandstorm,
Silver Cave's snow and Lake of Rage's storm under snow for a quarter of the year.

**The overcast roll is not the source's design, and cannot be.** The source stores four
`(intensity, group, map)` triples plus a day and an intensity — 14 saved bytes against M0's
6, and growing the reservation shifts `wVariantCaught`, `wPlayerDataEnd` and both save
canaries. `GetOvercastWeather` stores a one-byte daily seed and hashes it against each
map's id instead: stable all day, identical after a reload, independent between maps, and
no per-map table. **Two of the six reserved bytes are used; `wOvercastReserved`'s four are
still free.**

**`OVERCAST_INTENSITY_OVERCAST` was dropped deliberately.** In the source it means "dark
sky, no particles", and drives `npc_sprites_overcast.pal`, an overcast tileset, roof tables,
palette swaps and a music branch — **none of which exist in CE**. That state would be
pixel-identical to clear weather here. If overcast presentation is ever built, the third
intensity comes back with it.

**⚠️ The roadmap §7.5 `add 3` season offset is STALE — do not implement it.** It was put to
shasocastris at M2 kickoff and answered **no**, deliberately: one weekly "the world changed" beat
rather than two, and *"do not revisit later — changing it shifts every existing player's
season phase"* (`docs/seasons_implementation_context.md:1458`). The overcast roll is per-map
hashed rather than weekday-keyed, so it is decorrelated from the season turnover anyway.

**Also fixed here:** `MapSetupScript_Continue` never re-selected weather, and `wCurWeather`
sits past `wPlayerDataEnd` so it is not saved — a loaded game had no weather until its first
warp. A phase 4 gap, invisible while only four maps carried weather.

**Still deferred, both blocked on things that do not exist:**
- **Spring blossoms region-wide.** No tileset assigns `COLL_CHERRY_LEAVES`, so
  `SpawnCherryBlossom`'s tile scan finds nothing and only its 30% edge path fires. Going
  region-wide first would be pink confetti blowing in from offscreen on every route. Tag
  tree-canopy tiles in `data/tilesets/*_collision.asm` first, verify in Cherrygrove, then
  reconsider.
- **Autumn falling leaves.** A fifth weather type is cheap in code if it reuses a tile slot
  and an existing palette (`PAL_OW_ORANGE`), but it needs art, and all four existing
  particle PNGs are still placeholders.

### Phase 7 — overcast as a palette transform

Not in the roadmap; added because rain through a bright noon sky read wrong. The source
does this with a parallel set of hand-tuned overcast palettes, an overcast tileset, a roof
table and darker sprite palettes — **none of which exist here**. `DimWeatherPals` needs none
of it: it transforms whatever `LoadMapPals` just produced, so it follows the season, the
time of day and any special map palette for free.

**A pure multiply is not enough, and this is the reusable lesson.** Scaling every channel by
one factor preserves their ratios exactly, so hue and saturation come out untouched and the
map reads as the same sunny scene with the brightness down. Verified from a screenshot: the
spring green `$2c` (28,31,16) landed on exactly (21,23,12), 6/8 of itself, and still looked
sunny. Overcast light is diffuse — it **desaturates, cools, and lifts the blacks**.
Interpolating each channel toward a target colour does all three; `rgbasm` folds the target
into a per-channel lift so the inner loop stays a multiply and an add.

Measured on the Lake of Rage / Route 43 pair, autumn, same tileset:

| clear | sat | thunderstorm | sat |
|---|---|---|---|
| `31,22,10` ground | 0.68 | `19,16,12` | 0.37 |
| `23,9,2` tree | 0.91 | `15,9,8` | 0.47 |
| `7,7,7` neutral | 0.00 | `7,8,10` | 0.30 — neutrals pick up the sky |
| `31,7,1` player's cap | 0.97 | `19,8,7` | 0.63 |
| `0,0,0` outline | — | `4,5,7` | blacks lifted |
| rain particles | — | `21,21,31` **unchanged** | exempt |

**Two hooks, two dials.** `_CGB_MapPals` (not inside `LoadMapPals` — hooking the caller
covers both its exits and lands after the roof palettes it copies last) and `CopySpritePal`
for map objects. Lightning re-dims between its `LoadMapPals` and its fade-back, or every
strike would leave the storm bright until the next map load. The weather's own OB slot is
exempt by address, so particles stay bright; snow never reaches that path since
`LoadWeatherPal` byte-fills it white.

Per weather, `WeatherDimming` carries a brightness in eighths and a target colour — how
dark, and how grey and how cool. Those are the only things to touch when tuning.

### ⚠️ ROM0 is the project's real ceiling

Weather work drove the debug build's `Home` section to **one free byte**, which forced two
hooks into worse homes than they deserve. `df6ecc40f` + `a6be09117` removed 201 bytes of
dead ROM0 code to fix that. Two things to know:

- **The 157 bytes at `$0063`–`$00ff` are useless to `Home`** — they sit below the cartridge
  header. Only the gap above `Home` counts. Check
  `awk '/^ROM0 bank #0:/,/^ROMX/' crystal_eclipse_debug.map | grep Home`.
- **The debug build runs out first**, and `unreferenced.py` needs the `.sym` argument.
  Seven of its 21 ROM0 hits were unreferenced *labels fronting live code* reached by
  fallthrough; deleting those builds fine and breaks at runtime. Check the instruction
  before each label for an unconditional flow break.

## 4. Phase 2 shape

Port `engine/overworld/weather.asm` wholesale (guide §7 for flow, §10 step 6 for the
dependency list: `Random`, `RandomRange`, `ByteFill`, `JumpTable`/`StackJumpTable`,
`wShadowOAM`, `wPlayerStepVector{X,Y}`, `GetCoordTileCollision`, and the fade helpers for
`Lightning`). Then **one** hook — `DoOverworldWeather` in the overworld frame
(`engine/overworld/events.asm`) — and stop.

Watch for:

- **Bank discipline.** Anything that pages a bank into `$4000`–`$7fff` must live in ROM0, or
  it swaps out its own code. This has bitten this project before (`GetWildMonByte`).
- **`rWBK` around every `wWeatherScratch` use** — it is in bank 2, and the caller runs with
  bank 1 selected. The six state bytes are in bank 1 precisely so they need no switching.
- `wPlayerStepVectorX/Y` exist (`ram/wram.asm:2123`); guide §10 step 7 is a no-op here.
- Collision `$d0` is free for `COLL_CHERRY_LEAVES` (Phase 6), permission already `LAND_TILE`.
  Verify no duplicate `tilecoll` entry shadows it — the assembler matches the first entry.

---

## 5. BGB gate results

**Phase 1 — passed.** Both raindrop tiles load at `vTiles0 $60`–`$61`, VRAM bank 0.

**Phase 2 — passed, 2026-08-27.** Rain falls on a hand-poked map and continues smoothly
across a building entrance and exit and across a map connection.

**Phase 3 textbox/menu work — passed, 2026-08-28.** Particles keep animating under
textboxes, the start menu and yes/no boxes, and stay off all three. Battles are clean and
weather resumes afterwards.

**Phases 3g/3h/4 — passed, 2026-08-29.** Weather selects and renders from the map
attributes byte; ledge hops leave the particles alone; Fly arrives with the destination
already full; the transition drain works between maps with different weather; palettes
restore after a battle; lightning fires. **Phases 1 through 4 are now fully play-tested.**

Lightning took three passes. It was suppressed by nothing — `wCurWeather` read 3 and
`wWeatherFlags` read 0 — the flash simply never reached the hardware, because `ApplyPals`
only stages `wBGPals1` into `wBGPals2` and `hCGBPalUpdate` is what makes VBlank upload it.
It then read as a distracting strobe, so both directions now ramp through `FadePalettes`.

### Art verdict, 2026-08-29

| Weather | shasocastris's call |
|---|---|
| Rain / splashes | Good, renders as designed |
| Snow | **Excellent** — leave it alone |
| Sandstorm | ⚠️ **Not liked; wants a redraw pass.** `gfx/overworld/sand.png`, one 8×8 tile |
| Cherry blossom | Assigned to Cherrygrove City, but **edge-spawn only** until a tileset uses `COLL_CHERRY_LEAVES` |

Sand is the only art item outstanding. The engine side of it is finished and correct.

### Maps carrying weather

Route 45 sandstorm, Silver Cave Room 3 snow, Lake of Rage thunderstorm, Cherrygrove City
cherry blossoms — all four copying the source's choices, all four placeholders for shasocastris's
own design. Each is one optional argument in `data/maps/attributes.asm`; the other 419 maps
default to `OW_WEATHER_NONE`.

**Blossoms fall only from the screen edges** until some tileset assigns
`COLL_CHERRY_LEAVES` ($d0). `SpawnCherryBlossom` spends 70% of its attempts scanning for
that collision and giving up, so only its 30% edge path produces petals. That collision is
`LAND_TILE`, so it belongs on walkable ground under the trees, not on the trees — a map
design call, and the audit's warning about duplicate `tilecoll` entries applies when it is
made.

**Resolved: weather now owns the front of OAM** (`aaddaad02`). Play-testing confirmed rain
passing behind the player under the tail claim; OAM index *is* OBJ-to-OBJ priority on CGB,
so the front is the only way to draw over map objects. Structs 0–11 are weather's,
`_UpdateSprites` starts map objects at struct 12 under a new
`FIRST_12_SPRITE_OAM_STRUCTS_RESERVED_F`. **Not yet re-tested in BGB.**

### Procedure, for re-running

Nothing sets `wCurWeather` yet — that is Phase 4 — so the weather is still poked by hand.

1. Set **`$df7a` = 1** (bank 1), and leave **`$df7b`–`$df80` at zero**. A nonzero
   `wOverworldWeatherCooldown` with a garbage `wPrevWeather` jumps through an unbounded
   jumptable. `ClearWRAM` zeroes WRAMX 1–7 at boot, so a fresh boot is already safe.
2. Re-enter a map so `LoadMiscTiles` loads the tiles.
3. Rain should start falling within a second or two.

What to check, in order of what would falsify the port:

- **Particles fall diagonally down-left and drift with the player**, not sliding with the
  screen. Sliding means `wPlayerStepVectorX/Y` is being read at the wrong point.
- **Rain draws *behind* the player and NPCs.** Expected — see §3 item 2. Say so if it
  looks wrong; the fix is to claim the front of OAM instead, which is a contained change.
- **NPCs do not flicker into rain colours.** If they do, the dynamic allocator is handing
  OB slot 6 out and the audit's fallback (pre-mark bit 6 in `wUsedObjectPals`) is needed.
- **No stuck sprites** at the bottom-right after an NPC walks offscreen, and none left
  behind after setting `$df7a` back to 0.
- Splashes appear and clear roughly four times a second.
- Values 2–5 give snow, thunderstorm (renders as plain rain until phase 3), sandstorm,
  cherry blossom. Cherry blossoms only edge-spawn — no tile has `COLL_CHERRY_LEAVES` yet.

Known and expected at this phase: **particles keep animating and stay on screen during
textboxes and menus**, and battles will scribble over the tiles. Those are phase 3 hooks.

> shasocastris's BGB memory view is 16-bit little-endian — the low byte is the lower address.

---

## 6. Standing constraints

- **Never `git add -A`.** `docs/`, `.idea/`, `.claude/`, `rgbds-1.0.0/` are untracked
  deliberately. Docs in `docs/` are maintained but never committed.
- `maps/PlayersHouse2F.asm` carries shasocastris's own debug edits — do not commit it.
- No emulator on this box: verify statically, then say plainly what needs play-testing.
- Map text is **18 characters** per `text`/`line`/`cont`/`para`.
- Commit after every verified batch, so a bad batch costs one `git checkout`.

---

## 7. Elsewhere in the project

**The full cross-milestone list now lives in `docs/m0_m4_loose_ends.md`.** In brief:

- **ROM0 and WRAM0 are the real ceilings**, not ROM size. Debug `Home` has 186 bytes free
  after last session's cleanup; WRAM0 has 11.
- Deferred: M2 phase 6 winter tiles (on art) with a `wOldSeason` prerequisite and a reverted
  palette retune; M3 placeholders; M4's three seasonal-presentation items.
- ~~Safari Zone move tutor~~ — **merged**, in `core` at `4f534727f`. This note was stale.
- ~~`core` ahead of `origin/core`~~ — **level**. Also stale.

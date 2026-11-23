# Overworld Weather Particles — Reference & Port Guide

How Polished Crystal draws rain, snow, sandstorm, and cherry blossoms as free-floating
OAM particles over the overworld, and what you need to bring the system into another
pokecrystal-based project.

---

## 1. What the feature is

A per-frame particle simulator that runs on the overworld map loop. It borrows
**shadow-OAM slots that map objects aren't using**, stamps them with one of two
weather tiles, and moves them every other frame. Particles inherit the player's
walking motion so they look like they're falling through the world rather than
sliding across the screen.

Total cost: **2 VRAM tiles**, **1 OB palette slot**, **7 bytes of WRAM0**, **1 HRAM
byte**, and 144 bytes of scratch in WRAMX.

---

## 2. Files involved

| File | Role |
|---|---|
| `constants/weather_constants.asm` | `OW_WEATHER_*` ids, `wWeatherFlags` bits, overcast intensities |
| `gfx/misc.asm` | `SECTION "Overworld Weather Graphics"` — the four `INCBIN`s |
| `gfx/overworld/rain_splash.png` | 16×8 — 2 tiles: raindrop, splash |
| `gfx/overworld/snow.png` | 8×8 — 1 tile |
| `gfx/overworld/sand.png` | 8×16 — 2 tiles (only the first is loaded, see §9) |
| `gfx/overworld/cherry_blossom.png` | 8×8 — 1 tile |
| `data/sprites/weather.asm` | `WeatherGraphics` table + `weather_gfx` macro |
| `engine/overworld/weather.asm` | The whole engine: dispatch, spawners, fall physics, OAM cleanup, sprite-limit enforcement, lightning |
| `engine/events/weather.asm` | `SetCurrentWeather` — picks the weather for the current map |
| `engine/events/overcast.asm` | `GetOvercastIndex` — decides *whether it is raining* on rain-capable maps |
| `engine/gfx/sprite_palettes.asm` | `LoadWeatherPal` / `LoadWeatherPalNoApply` |
| `gfx/overworld/npc_sprites.pal` | `rain` and `sand` palette rows (per time-of-day) |
| `ram/wram0.asm`, `ram/wramx.asm`, `ram/hram.asm` | State variables |

---

## 3. Graphics pipeline

### The section

```asm
SECTION "Overworld Weather Graphics", ROMX

RainGFX::          INCBIN "gfx/overworld/rain_splash.2bpp"
SnowGFX::          INCBIN "gfx/overworld/snow.2bpp"
SandGFX::          INCBIN "gfx/overworld/sand.2bpp"
CherryBlossomGFX:: INCBIN "gfx/overworld/cherry_blossom.2bpp"
```

Uncompressed 2bpp, because the loader is a plain `Get2bpp` copy — small enough that
LZ decompression would cost more than it saves, and it has to run mid-map without a
decompression buffer.

### The lookup table (`data/sprites/weather.asm`)

```asm
MACRO weather_gfx
	fardw \1 ; gfx pointer
	db \2 ; tile count
ENDM

WeatherGraphics:
	table_width 3
	farbank "Overworld Weather Graphics"
	weather_gfx RainGFX, 2          ; OW_WEATHER_RAIN
	weather_gfx SnowGFX, 1          ; OW_WEATHER_SNOW
	weather_gfx RainGFX, 2          ; OW_WEATHER_THUNDERSTORM (shares rain gfx)
	weather_gfx SandGFX, 1          ; OW_WEATHER_SANDSTORM
	weather_gfx CherryBlossomGFX, 1 ; OW_WEATHER_CHERRY_BLOSSOMS
	assert_table_length NUM_OW_WEATHERS
```

Three bytes per entry, indexed by `wCurWeather - 1`. `farbank` emits the bank byte
once for the whole section rather than per-entry.

### The loader (`LoadWeatherGraphics`, end of `engine/overworld/weather.asm`)

```asm
LoadWeatherGraphics:
	ld a, [wCurWeather]
	assert OW_WEATHER_NONE == 0
	and a
	ret z                 ; no weather → nothing to load
	ld hl, WeatherGraphics - 3
	ld d, 0
	ld e, a
	add hl, de
	add hl, de
	add hl, de            ; hl = WeatherGraphics + 3*(wCurWeather-1)
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a               ; de = gfx pointer
	ld b, BANK("Overworld Weather Graphics")
	ld c, [hl]            ; c = tile count
	ld hl, vTiles0 tile WEATHER_TILE_1
	jmp Get2bpp
```

`Get2bpp` routes to `Request2bpp` (VBlank-deferred) if the LCD is on, so this is safe
to call mid-map.

### VRAM budget

```
vTiles0 $61–$6c   HeadbuttTreeGFX / HeadbuttTree2GFX (12 tiles)
vTiles0 $6d       WEATHER_TILE_1  ← raindrop / snowflake / sand / petal
vTiles0 $6e       WEATHER_TILE_2  ← rain splash
vTiles0 $6f–$7f   OverworldEffectGFX (17 tiles)
```

Two tiles wedged between two existing blocks. **This is the tightest constraint in the
port** — if your target has nothing free at `$6d`, you must find another 2-tile gap in
`vTiles0` and change the two `EQU`s at the top of `engine/overworld/weather.asm`:

```asm
DEF WEATHER_TILE_1  EQU $6d
DEF WEATHER_TILE_2  EQU $6e
DEF RAINDROP_TILE   EQU WEATHER_TILE_1
DEF RAINSPLASH_TILE EQU WEATHER_TILE_2
DEF SNOWFLAKE_TILE  EQU WEATHER_TILE_1
DEF SANDSTORM_TILE  EQU WEATHER_TILE_1
DEF CHERRYLEAF_TILE EQU WEATHER_TILE_1
```

`RAINDROP_TILE + 1 == RAINSPLASH_TILE` is `assert`ed in `SpawnRandomWeatherCoords.rain`,
which computes the tile id branchlessly (`ccf` / `sbc a` / `add`). Keep them adjacent.

---

## 4. Constants

```asm
; constants/weather_constants.asm
	const_def
	const OW_WEATHER_NONE            ; 0
	const OW_WEATHER_RAIN            ; 1
	const OW_WEATHER_SNOW            ; 2
	const OW_WEATHER_THUNDERSTORM    ; 3
	const OW_WEATHER_SANDSTORM       ; 4
	const OW_WEATHER_CHERRY_BLOSSOMS ; 5
DEF NUM_OW_WEATHERS EQU const_value - 1

; wWeatherFlags
	const_def
	const OW_WEATHER_DO_FLY_F             ; 0 — a Fly animation is in progress
	const OW_WEATHER_DISABLED_F           ; 1 — a textbox is open
	const OW_WEATHER_LIGHTNING_DISABLED_F ; 2 — suppress the thunderstorm flash
	const OW_WEATHER_IGNORE_PLAYER_Y      ; 3 — ignore player Y motion (ledge hops)
```

`OW_WEATHER_NONE == 0` is load-bearing: every entry point does `and a / ret z` and every
jumptable index is `wCurWeather - 1`.

---

## 5. State

| Symbol | Where | Meaning |
|---|---|---|
| `wCurWeather` | wram0 | Active `OW_WEATHER_*` |
| `wPrevWeather` | wram0 | Weather being drained during a transition |
| `wWeatherFlags` | wram0 | Bitfield above |
| `wOverworldWeatherTimer` | wram0 | Free-running 0→255 counter; drives the 30 Hz gate and splash lifetime |
| `wOverworldWeatherCooldown` | wram0 | Frames left draining the old weather (set to 32) |
| `wSpriteOverlapCount` | wram0 | Working count inside `SpriteLimitExceeded` |
| `hUsedWeatherSpriteIndex` | hram | High-water mark (byte offset into shadow OAM) of the last weather-owned slot |
| `wWeatherScratch` | wramx, `ds SCREEN_HEIGHT_PX` | Per-scanline sprite counter; reused as the cherry-leaf candidate buffer |

`wWeatherScratch` is double-purposed — 144 bytes, banked. `WeatherSpriteLimitCheck` uses
it as a per-scanline countdown; `SpawnCherryBlossom` uses byte 0 as a count and bytes
1..143 as packed screen coordinates. They never run in the same call, but the bank must
be saved/restored around every use (`rWBK` push/pop), because the caller is running with
`BANK(wXCoord)` selected.

---

## 6. Palettes

Weather always draws in **OB palette slot 6** (`DEF PAL_OW_WEATHER EQU 6` in
`constants/sprite_data_constants.asm`), so every OAM entry the engine writes uses
attribute byte `PAL_OW_WEATHER`. That palette index is also the *tag* the cleanup and
per-weather loops use to tell "my sprite" apart from a map object that happens to sit on
tile `$6d`.

`LoadWeatherPal` (`engine/gfx/sprite_palettes.asm`) fills it:

| Weather | Palette |
|---|---|
| Rain, Thunderstorm | `PAL_OW_RAIN` (row `rain` in `gfx/overworld/npc_sprites.pal`) |
| Sandstorm | `PAL_OW_SAND` (row `sand`) |
| Cherry blossoms | `PAL_OW_PINK` (row `pink`) |
| Snow | *no palette index* — the four colors are byte-filled to `$ff` (white); the slot is marked `NO_PAL_LOADED` so the dynamic-palette allocator doesn't associate it with a sprite |

Palette rows exist once per time-of-day block (morn / day / nite / eve), e.g.

```
	RGB 27,31,27, 21,21,31, 16,22,31, 00,00,00 ; rain   (day)
	RGB 27,31,27, 22,19,09, 11,05,00, 15,09,02 ; sand   (day)
```

`LoadWeatherPalNoApply` is the same thing with `NO_DYN_PAL_APPLY_ONCE_F` set — used when
returning from a menu, where the palette must be staged but not pushed to the CGB
registers until the fade-in runs.

Each per-weather handler re-checks the slot before doing work:

```asm
DoOverworldRain:
	ld a, [wLoadedObjPal{d:PAL_OW_WEATHER}]
	cp PAL_OW_RAIN
	jr z, .continue
	farcall LoadWeatherPal
.continue
```

So if the dynamic palette allocator hands slot 6 to an NPC, the next weather frame
reclaims it.

---

## 7. Runtime flow

### Entry point

`DoOverworldWeather` is `farcall`ed from four places:

- `engine/overworld/events.asm:102` — the normal overworld frame, after `CheckPlayerState`
- `engine/overworld/scripting.asm` — inside `Script_pause`, so weather keeps animating during scripted waits
- `engine/events/field_moves.asm` (×3) — inside the Fly-to / Fly-from animation loops

### The frame

```
DoOverworldWeather
├─ bit OW_WEATHER_DISABLED_F, [wWeatherFlags] → bail if a textbox is open
├─ wOverworldWeatherTimer & 1 → bail on even frames (particles run at 30 Hz)
├─ decrement wOverworldWeatherCooldown if non-zero
├─ clamp hUsedWeatherSpriteIndex below the first map-object OAM slot
├─ if cooldown != 0:
│     dispatch wPrevWeather through .DoWeather_Jumptable  (fall-only, no spawning)
│     on the last cooldown frame: ClearWeather + LoadWeatherGraphics
│  else:
│     dispatch wCurWeather through .DoOverworldWeather_Jumptable  (spawn + fall)
├─ inc wOverworldWeatherTimer
└─ WeatherSpriteLimitCheck
```

Two jumptables, both `NUM_OW_WEATHERS + 1` long (index 0 = `DoNothing`):

```asm
.DoOverworldWeather_Jumptable:      .DoWeather_Jumptable:
	dw DoNothing                        dw DoNothing
	dw DoOverworldRain                  dw DoRainFall
	dw DoOverworldSnow                  dw DoSnowFall
	dw DoOverworldRain                  dw DoRainFall
	dw DoOverworldSandstorm             dw DoSandFall
	dw DoOverworldCherryBlossoms        dw DoCherryBlossomFall
```

Each `DoOverworld*` routine spawns, then **falls through** into its matching `Do*Fall`
routine. The right-hand table is the same code entered one label later, so the transition
path reuses the physics without spawning anything new — that's what makes a weather change
drain smoothly instead of popping.

### OAM arbitration

Map objects and sprite animations occupy the **tail** of shadow OAM; `hUsedOAMIndex`
counts the bytes they hold. Weather claims slots from the **front**:

```asm
ScanForEmptyOAM:
; return empty OAM slot in de, or carry set if none
	ld de, wShadowOAM
	ld h, d
	ld l, e
	ldh a, [hUsedOAMIndex]
	cpl
	add OAM_SIZE + 1    ; a = OAM_SIZE - hUsedOAMIndex  (bytes available)
	rrca
	rrca                ; a /= 4 → slot count
	ld b, a
```

A slot is "empty" when its Y coordinate is `OAM_YCOORD_HIDDEN` (160). `hUsedWeatherSpriteIndex`
tracks the furthest slot weather has ever touched, so `ClearWeather` only has to sweep that
far. At the top of every frame it's re-clamped downward in case map objects grew into the
weather's range.

### Per-particle update, common shape

Every `Do*Fall` walks all 40 shadow-OAM entries and applies the same guard chain:

1. Y == `OAM_YCOORD_HIDDEN` → skip (empty slot)
2. tile id != this weather's tile → skip (someone else's sprite)
3. attribute != `PAL_OW_WEATHER` → skip (a map object on the same tile)
4. random despawn roll
5. subtract the player's step vector (scaled), add the per-weather drift, write back
6. underflow/overflow on X or Y → despawn (write `OAM_YCOORD_HIDDEN` + zero the entry)

Step 5 is the trick that sells the effect. `wPlayerStepVectorX/Y`
(`engine/overworld/map_objects.asm`) is the signed sub-pixel scroll the camera applied
this frame. Weather *subtracts* a multiple of it, so particles stay anchored to world
space while the map scrolls under them:

| Weather | Step-vector scale | Base motion | Extra |
|---|---|---|---|
| Rain | ×4 | +8 Y, −4 X, +2 more per even slot | 5% chance/frame to become a splash |
| Snow | ×2 | +2 Y, −0/−1 X random wiggle, +1 more Y per even slot | 1% × 10% = 0.1% despawn |
| Sand | ×4 | −4 Y (rises), −12 X, ±2 per even slot | 5% despawn |
| Cherry | ×2 | +2 Y, −0/−1 X wiggle, +1 more Y per even slot | 1% despawn |

`IsEvenSpriteIndex` returns `(slot_index / 4) & 1`, giving two speed classes for free
parallax without storing any per-particle state.

`OW_WEATHER_IGNORE_PLAYER_Y` skips the Y compensation. It's set by the ledge-hop object
routine in `engine/overworld/map_objects.asm`, because during a hop the camera Y vector is
being faked and compensating for it would make the particles jump.

### Spawners

- **`SpawnRainDrop`** — 50/50 top edge vs. right edge. Top: `(y=0, x=RandomRange(167)+8)`. Right: `(y=RandomRange(160), x=168)`.
- **`SpawnSnowFlake`** — 40% chance to spawn at all; then 25% right edge, 75% top edge.
- **`SpawnSandDrop`** — spawns at the **bottom** (`y = SCREEN_HEIGHT_PX + TILE_WIDTH`) or right edge, because sand rises.
- **`SpawnCherryBlossom`** — 10% chance to spawn; then 30% edge-spawn like snow, 70% *from a cherry-leaf tile*.

The cherry-blossom tile scan is the only spawner that reads the map. It walks the
10×9 grid of on-screen collision cells via `GetCoordTileCollision`, collects every cell
whose collision is `COLL_CHERRY_LEAVES` ($d0) into `wWeatherScratch` as packed
`(X<<4)|Y` nibbles, picks one at random, and converts it to pixel coords (`<<4`, `+16`).
Petals therefore drift out of the trees they belong to. It bank-switches between
`BANK(wXCoord)` and `BANK(wWeatherScratch)` repeatedly and restores `rWBK` on every exit
path — including the `.no_spawn` early-out.

### Rain splashes

A falling raindrop has a 5% chance per frame of converting in place to `RAINSPLASH_TILE`.
Splashes don't fall; they only track the player's step vector (×2), and the whole set is
wiped every 8 weather frames:

```asm
	ld a, [wOverworldWeatherTimer]
	and %1110      ; LSB ignored — weather only runs on odd frames
	ret nz
```

That's ~3.75 Hz, i.e. a splash lives at most ~a quarter second.

### Lightning

`DoOverworldRain` rolls 1% × 50% ≈ 0.5% per weather frame when `wCurWeather ==
OW_WEATHER_THUNDERSTORM`. `Lightning` whites out all palettes, plays `SFX_THUNDER_OW`,
waits a frame, reloads map pals, and re-runs the OW fade. It bails on
`OW_WEATHER_DO_FLY_F` (mid-Fly) and `OW_WEATHER_LIGHTNING_DISABLED_F`, which is set
around headbutt-tree shakes, map-name signs, and several `engine/events/overworld.asm`
sequences that manage palettes themselves.

### Hardware sprite limit

The Game Boy draws at most 10 sprites per scanline. Weather particles can easily blow
past that and start hiding *map objects* (which are earlier in OAM priority order). Two
routines prevent it, running every frame regardless of whether weather is active:

- **`WeatherSpriteLimitCheck`** — fills `wWeatherScratch` with 11 (limit + 1), then for
  each OAM entry decrements the 8 bytes covering its scanline span. Any byte hitting zero
  means an 11th sprite touched that line → call `SpriteLimitExceeded`.
- **`SpriteLimitExceeded`** — walks OAM *backwards* (lowest priority first) counting
  sprites overlapping that scanline, and hides everything past the 10th, decrementing the
  scratch counters back as it goes.

Because it scans in reverse, the sprites sacrificed are the lowest-priority ones — and
weather always lives at the front of OAM, i.e. **highest** priority. Reverse iteration is
what keeps map objects visible in a downpour.

Note this runs at `.done`, outside the `wCurWeather` check, so it also polices ordinary
overworld object crowding.

### Cleanup

`ClearWeather` hides every weather-owned OAM entry (matching tile `$6d`/`$6e` *and*
`PAL_OW_WEATHER`) up to `hUsedWeatherSpriteIndex`, then zeroes that index. It is exposed
as map-setup script command `$33` and is called before every battle
(`engine/battle/core.asm`), with `LoadWeatherGraphics` + `LoadWeatherPal` after.

---

## 8. Choosing the weather

### `SetCurrentWeather` (`engine/events/weather.asm`)

Map-setup command `$34`. Runs on warp, connection, fall, door, and train transitions —
always immediately after `ClearWeather` (except on connections, where the particles
should carry across the seam).

```
GetOvercastIndex != NOT_OVERCAST  and  wOvercastCurIntensity != OVERCAST_INTENSITY_OVERCAST
  → OVERCAST_INTENSITY_RAIN         → OW_WEATHER_RAIN
  → OVERCAST_INTENSITY_THUNDERSTORM → OW_WEATHER_THUNDERSTORM
else, by map:
  Silver Cave Room 3 → OW_WEATHER_SNOW
  Route 45                           → OW_WEATHER_SANDSTORM
  Cherrygrove City   → OW_WEATHER_CHERRY_BLOSSOMS (guaranteed until the Mystery Egg
                       is delivered to Elm, then 10%)
  Route 29 / 30    → 10% OW_WEATHER_CHERRY_BLOSSOMS
  otherwise          → OW_WEATHER_NONE
```

**This function is the hardcoded, project-specific part.** Everything upstream of it is
generic; everything in it is Polished Crystal map ids. In a port, this is the piece you
rewrite (or replace with a map-header field — see §10).

### The transition

If the new weather differs from the old *and* weather was already running *and* this
isn't a Fly, it defers: stash the old weather in `wPrevWeather`, set the new one in
`wCurWeather`, and set `wOverworldWeatherCooldown = 32`. For 32 weather frames the engine
runs the *old* weather's fall physics with no spawning, then swaps graphics. Rain↔thunderstorm
is explicitly exempt (same tiles, same palette — no reason to drain).

### `GetOvercastIndex` (`engine/events/overcast.asm`)

Decides whether rain-capable maps are overcast today. Gated behind
`EVENT_AZALEA_TOWN_SLOWPOKES`, then a generic weekly roll (`CheckGenericOvercast`,
`wOvercastRandomDay` / `wOvercastRandomMaps`) plus per-region special cases: Azalea
Town / Route 33 (rain on Sun/Tue/Thu/Sat), Lake of Rage / Route 43 (thunderstorm
Mon/Wed/Fri, always until Rocket is beaten), Stormy Beach / Goldenrod, Route 10 North.
It also drives overcast BG palettes (`gfx/overworld/npc_sprites_overcast.pal`) and music
independently of the particles.

---

## 9. Integration points

Every call site outside `engine/overworld/weather.asm`:

| Call site | Call | Why |
|---|---|---|
| `engine/overworld/events.asm:102` | `DoOverworldWeather` | The main overworld frame |
| `engine/overworld/scripting.asm:2354` | `DoOverworldWeather` | Keep weather alive during `Script_pause` |
| `engine/events/field_moves.asm` ×3 | `DoOverworldWeather` | Fly animation loops |
| `engine/events/field_moves.asm:431-433` | `LoadWeatherGraphics`, `LoadWeatherPal`, `SpawnRandomWeatherFullScreen` | Fly-to arrival: prefill the screen so it isn't empty for the first second |
| `home/window.asm:35 / :59` | `res/set OW_WEATHER_DISABLED_F` | Freeze particles while a textbox is open |
| `home/sprite_updates.asm:41-42` | `LoadWeatherPalNoApply`, `LoadWeatherGraphics` | Restore weather VRAM/pal after closing a menu |
| `engine/menus/start_menu.asm:46` | `LoadWeatherPal` | Same, for the start menu |
| `engine/battle/core.asm:7932, 7936-7937` | `ClearWeather` → battle → `LoadWeatherGraphics` + `LoadWeatherPal` | Battles reuse the tiles and palette slot |
| `engine/events/overworld.asm:771, 798, 803` | `LoadWeatherPal`, set/res `OW_WEATHER_DO_FLY_F` | Fly bookkeeping |
| `engine/events/map_name_sign.asm:212, 217` | `res/set OW_WEATHER_LIGHTNING_DISABLED_F` | Don't flash while the sign animates |
| `engine/overworld/map_objects.asm:1742, 1772` | `set/res OW_WEATHER_IGNORE_PLAYER_Y` | Ledge hops |
| `data/maps/setup_scripts.asm` | `mapsetup ClearWeather` / `mapsetup SetCurrentWeather` | Map transitions |

`SpawnRandomWeatherFullScreen` / `SpawnRandomWeatherCoords` fill the screen with particles
at random positions instead of waiting for them to drift in from the edges. Note the
jumptable there is only `NUM_OW_WEATHERS` long (no index-0 entry) — it does its own
`and a / ret z` and `dec a` first. Cherry blossoms map to `DoNothing`, since their
positions come from map tiles rather than randomness.

---

## 10. Porting checklist

1. **Constants** — copy `constants/weather_constants.asm`; add `DEF PAL_OW_WEATHER EQU 6`
   (or whichever OB slot your project can spare) to your sprite-data constants.
2. **RAM** — add the six wram0 bytes, `hUsedWeatherSpriteIndex` in HRAM, and
   `wWeatherScratch:: ds SCREEN_HEIGHT_PX` in a WRAMX bank.
3. **VRAM** — find two free consecutive tiles in `vTiles0` and set `WEATHER_TILE_1/2`.
   This is usually the hardest part; audit whatever your project loads into `vTiles0`
   `$60`–`$7f`.
4. **Graphics** — copy the four PNGs and the `SECTION "Overworld Weather Graphics"` block,
   plus `data/sprites/weather.asm`.
5. **Palettes** — add `rain`, `sand` rows to each time-of-day block of your OW sprite
   palette file, and the matching `PAL_OW_*` constants. Port `LoadWeatherPal` /
   `LoadWeatherPalNoApply`; if your project has no dynamic OB palette allocator, the
   `wLoadedObjPal*` / `wNeededPalIndex` bookkeeping simplifies to a direct
   `wOBPals1 palette PAL_OW_WEATHER` copy.
6. **Engine** — copy `engine/overworld/weather.asm` wholesale. Its only external
   dependencies are `Random`, `RandomRange`, `ByteFill`, `JumpTable`/`StackJumpTable`,
   `wShadowOAM`, `hUsedOAMIndex`, `wPlayerStepVector{X,Y}`, `GetCoordTileCollision`,
   and the palette/fade helpers used by `Lightning`.
7. **Step vectors** — if your base lacks `wPlayerStepVectorX/Y`, add them: accumulate the
   signed camera delta in `ApplyPlayerStep` and clear them once per overworld frame.
   Without this, particles slide across the screen instead of through the world.
8. **Hooks** — wire up the table in §9. The minimum viable set is `DoOverworldWeather` in
   the overworld frame, `OW_WEATHER_DISABLED_F` around `OpenText`/`CloseText`, and the
   battle save/restore.
9. **Selection** — rewrite `SetCurrentWeather` for your maps, or replace it with data.
   A cleaner design for a fresh port: add a weather byte to the map header/attributes and
   have `SetCurrentWeather` read it, keeping only the genuinely conditional cases (rain
   via overcast, story-gated cherry blossoms) in code.
10. **Map setup** — insert `mapsetup ClearWeather` + `mapsetup SetCurrentWeather` into
    the warp/fall/door/train scripts, and `mapsetup SetCurrentWeather` alone into the
    connection script.

### Adding a fifth weather type

1. `const OW_WEATHER_FOO` before the `NUM_OW_WEATHERS` line.
2. `INCBIN` the tiles into the weather section; add `weather_gfx FooGFX, n`.
3. Add rows to *all three* jumptables (`.DoOverworldWeather_Jumptable`,
   `.DoWeather_Jumptable`, `SpawnRandomWeatherCoords.Jumptable`) and to
   `LoadWeatherPal.Jumptable`. The `assert_table_length` directives will catch a miss.
4. Write `DoOverworldFoo` (palette check + `rept n` spawn) falling through into
   `DoFooFall` (the six-step guard chain), plus a `SpawnFooDrop`.
5. Add a branch to `SetCurrentWeather`.

If your new type needs more than one tile *distinct from* rain's two, you must widen the
`$6d`/`$6e` window and extend `ClearWeather.HideWeatherSprites`, which hardcodes a check
against exactly `WEATHER_TILE_1` and `WEATHER_TILE_2`.

---

## 11. Observations worth checking during a port

Two things in the current code that a port shouldn't blindly reproduce:

- **`sand.png` is 8×16 (two tiles) but `weather_gfx SandGFX, 1` loads only one.** The
  second tile never reaches VRAM and `SANDSTORM_TILE` only ever references the first.
  Either the tile count is meant to be 2 and sand is missing a second frame, or the PNG
  should be trimmed to 8×8.

- **`LoadWeatherPal.snow` writes `wLoadedObjPal7`, but `PAL_OW_WEATHER` is 6** and
  `DoOverworldSnow` reads `wLoadedObjPal{d:PAL_OW_WEATHER}` (slot 6). The white byte-fill
  still lands in `wOBPals1 palette PAL_OW_WEATHER` correctly, so snow *looks* right, but
  the "already loaded" marker goes to the wrong slot — so unless something else has left
  slot 6 as `NO_PAL_LOADED`, `DoOverworldSnow` re-`farcall`s `LoadWeatherPal` every
  weather frame. Looks like a leftover from when the weather slot was 7. Harmless
  visually, wasteful per-frame.

---

## 12. Tuning quick-reference

| Want | Change |
|---|---|
| Denser precipitation | The `rept N` count in `DoOverworldRain` (3) / `DoOverworldSnow` (2) / `DoOverworldSandstorm` (3) |
| Rarer particles | The `cp N percent` early-return in the `Spawn*` routine |
| Faster fall | The `add 8` / `add 2` "minimum fall speed" line in the `Do*Fall` loop |
| More wind shear | The `sub 4` / `sub 12` "minimum horizontal movement" line |
| Stronger parallax | The `add a` count applied to `wPlayerStepVector*` (×2 vs ×4) |
| Longer splashes | The `and %1110` mask in `DoRainFall` (→ `%11110` doubles the lifetime) |
| More/less lightning | The two `cp N percent` rolls in `DoOverworldRain` |
| Longer weather transition | `ld a, 32` in `SetCurrentWeather.do_cooldown` |
| Particles run at 60 Hz | The `and %1` gate at the top of `DoOverworldWeather` — expect the sprite limiter to start culling |

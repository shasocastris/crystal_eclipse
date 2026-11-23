# Weather & seasons — finalization context

**Written 2026-10-23** to park this work and resume it later. Condenses
`major_systems_roadmap.md`, `m4_weather_handoff.md`, `seasonal_cluster_handoff.md` and
`m0_m4_loose_ends.md` into what is still true. Where this file and those disagree, this one is
newer. They remain the deep references (§8).

---

## 1. Where things stand

| Milestone | State |
|---|---|
| M0 save reservation | Done, on `core` |
| M1 regional variants | Done, on `core` |
| M2 seasons | Phases 1–5 on `core`. Phase 6 (winter tiles) **built, branch only** |
| M3 Orange Islands | Done, on `core`; content placeholders remain (§5.4) |
| **M4 overworld weather** | **Built, branch only.** Acceptance not all play-tested |

**Branch:** `68-ow-weather`, pushed at `8569b7acd`. `core` is **23 commits behind, 0 ahead**:
a clean fast-forward. Re-check before acting:
`git rev-list --left-right --count core...68-ow-weather`.

**Nothing is half-built.** What remains is play-testing, the merge, a handful of design calls,
and art.

---

## 2. What is built (on the branch)

**Weather engine** (Polished Crystal port): rain, snow, thunderstorm, sandstorm, cherry
blossoms, sun. `SetCurrentWeather` runs as map-setup command `$34`: an authored map byte wins,
otherwise the daily roll decides. `DoOverworldWeather` runs every frame off `DelayFrame` (gated
on `hMapAnims`), owns shadow OAM 0–11, and animates under textboxes, menus, battles, Fly and
ledge hops. The overcast palette transform interpolates toward a per-weather colour.

**Daily roll** (`engine/events/overcast.asm`), reseeded once per day and hashed per map, so
each map's weather stays the same all day and after a reload. Gated behind
`EVENT_AZALEA_TOWN_SLOWPOKES`. Outdoor (TOWN/ROUTE) only.

| | Johto + Kanto | Orange Islands |
|---|---|---|
| Spring | 20% wet, 15% sun | 15% wet, 20% sun |
| Summer | 10% wet, 30% sun | 25% wet, 10% sun |
| Autumn | 35% wet | 30% wet, 5% sun |
| Winter | **snow on 40% of maps** | 10% wet, 25% sun, never snow |

Sun is daytime only and carries into battle. Outdoor battles take the overworld weather
(`OverworldBattleWeather`).

**Authored map weather** (`data/maps/attributes.asm`, 5th arg of `map_attributes`). These are all
placeholders awaiting shasocastris's design:
Cherrygrove (blossoms, spring), Lake of Rage (thunderstorm, spring–autumn), Route 45
(sandstorm, spring–autumn), Silver Cave Room 3 (snow). Every other map is `OW_WEATHER_NONE` and
uses the roll.

**Seasonal presentation.** In winter, Johto, Kanto, Johto modern, Battle Tower Outside and
National Park get tiles patched to snow, block swaps (flowers, dead grass), icy recoloured
roofs, and cherry trees with a snowy canopy and brown trunk. The Orange Islands use summer
palettes all year and get no winter tiles.

**Seasonal wild encounters.** Johto (Routes 30, 35, 45; Lake of Rage, Route 41 water) and,
as of `8569b7acd`, Kanto (Routes 2, 14, 25, 28; Routes 20, 25 water). Summer = the base table.
The seasonal tables live in bank $75 and are read through `wWildMonBank`.

---

## 3. Finalize — the path to merging

All of this needs shasocastris in BGB; nothing is code work unless a test fails.

**A. Unverified changes from 2026-10-23** (`7528bcc7a`, `8569b7acd`):
- [ ] A wild encounter on a Kanto seasonal route in spring, autumn or winter
- [ ] One battle animation from the set the bank repack moved (Bite, Leech Seed, Petal Dance)
- [ ] Weather renders on an outdoor map (its graphics changed bank)
- [ ] OlivineRestaurant: no snow inside, looks like the other houses

**B. M4 acceptance** (roadmap §7.6), not all confirmed in play:
- [ ] Frame rate holds on the busiest map at max particle density
- [ ] **Goldenrod in heavy rain: no NPC or overworld Pokémon disappears** (roadmap §9 checkpoint)
- [ ] Lightning stays off during a map-name sign, a headbutt shake and Fly
- [ ] Overcast survives save and reload (same weather on the same map after reload)
- [ ] No glitch entering or leaving battles, menus, textboxes, Fly, ledge hops, connections
- [ ] Weather drains smoothly on a change rather than popping

**C. Two old M3 checks never watched:**
- [ ] Whiteout on an Orange map: where does the player wake?
- [ ] Day 139 → 0 wrap keeps the season sequence continuous (proven arithmetically only)

**D. Merge:** `git checkout core && git merge --ff-only 68-ow-weather`, then push. Then
correct the merge-status lines in the docs and memory, which have gone stale twice.

---

## 4. Final touches — decisions (no art)

Propose these; don't change them unprompted.

1. **Winter palette retune.** `git revert 12940a1` restores a hand-authored winter palette that
   was rejected while winter had no tiles. Now that the tiles carry the snow, the saturated ramp
   may read as cyan paint. Judge both on screen.
2. **Per-map authored weather.** The four placeholders in §2 are stand-ins. Decide which maps
   get fixed weather (especially Orange Islands maps; they were meant to vary by weather, not
   season).
3. **Spring blossoms region-wide?** Unblocked (`COLL_CHERRY_LEAVES` exists on real tiles), but
   it would add a lot of visual noise. Leaning no.
4. **More seasonal Kanto encounters?** Only 4 grass + 2 water maps so far; Johto has 3 + 2.

---

## 5. Final touches — art and content

### 5.1 Weather art
- **Sandstorm** wants a redraw (currently the source's tile).
- **Cherry blossom particles** have never been seen in game. Look at them in Cherrygrove in spring.
- **Autumn falling leaves**, a fifth weather type. Cheap in code: reuse a tile slot and
  `PAL_OW_ORANGE`. Five tables each need a row, and every one has an `assert_table_length`.

### 5.2 Seasonal tile art
- Winter versions of any further flower blocks.
- Cherry canopy for autumn, if wanted (pink outside winter today; `PAL_BG_RED` can't take a
  season axis because it also carries Goldenrod pavement, Johto roads and brick).

### 5.3 shasocastris draws his own art
Don't offer to redraw; sweep `gfx/` for pre-drawn unreferenced sheets before making a
placeholder.

### 5.4 M3 content placeholders
`MUSIC_ORANGE_*` aliases (3), radio programming, landmark coordinates, island species, Town
Map page art (`docs/townmap/`).

---

## 6. Verify every batch

- Both ROMs: `make -j"$(nproc)" all`. **Check the exit status**, not the output.
- `python3 utils/optimize.py | wc -l` → **608** (use `python3`; bare `python` exits 127 with
  empty output, which looks like a pass)
- `python3 utils/farcheck.py crystal_eclipse.sym | wc -l` → **82** (needs the `.sym` arg)
- `python3 utils/check_season_comments.py` after touching any base wild table
- Save canaries: `wEventFlags $da66`, `wSeason $dbf0`, `wVisitedSpawns $dc01`,
  `wDigWarpNumber $dc09`
- Count matches aren't proof. For anything that moves sections, diff the `.map` section list
  and the sorted farcheck/optimize output against a HEAD build in a scratch worktree.

**Ceilings (2026-10-23):** ROM0 debug `Home` **194 B** (the binding one; only the gap above
`Home` counts), release 223 B. WRAM0 10 B. Bank $75 has ~11.8 KB free. `wOvercastReserved`
`$dbf5-$dbf8` has 4 unused bytes inside the save block.

---

## 7. Hazards that have cost time

- **New unsaved bytes go in WRAM0.** A byte added to a floating WRAMX bank 1 section shifts
  the saved block and breaks every save.
- **To test seasons, poke `wStartDay` (`$d4b5`) `+7`**, never `wSeason` (`$dbf0`): it is a cache
  with one writer, and a day rollover overwrites the poke, faking a season skip. Weather only
  re-selects on a map transition: take a step, then warp.
- **The environment field does many jobs:** Dig/Escape Rope (CAVE/DUNGEON), seasonal palettes,
  roofs, winter tiles, weather, Fly/Teleport, bike, outdoor phone calls. Silver Cave is INDOOR
  on purpose. Never change it to fix a palette.
- **Weather owns OAM 0–11.** Reserving slots without drawing in them freezes ghost sprites;
  particle-less weathers (sun) must not reserve.
- **Bank-paging routines must live in ROM0** (`GetWildMonByte`). RGBDS links a near `call`
  across banks silently; run farcheck.
- **Repacking bank $0a is safe as of 2026-10-23.** Moving the seasonal tables out reshuffled
  `BattleAnimFunc_*` sections and the weather graphics between $0a and $0b; both are
  bank-independent. The old "repack corrupts map loads" warning is retired, but diff the
  section map whenever $0a changes size.
- **`unreferenced.py` lies about labels fronting fallthrough code**; check the instruction
  before each label.
- **BGB memory view is 16-bit little-endian**: the low byte is the lower address.
- **mtPaint "save layers" writes a text stub, not a PNG.** Export instead.
- **Diff against `~/polishedcrystal/`**, not
  `weather-particles-guide.md`, which paraphrases.
- **Never `git add -A`**: `docs/`, `.idea/`, `.claude/`, `rgbds-1.0.0/` are untracked on purpose.
  Docs are updated, never committed.

---

## 8. Where things live

| For | Look at |
|---|---|
| Weather engine, sun palette | `engine/overworld/weather.asm` (`SunPals`) |
| Weather OB palettes | `LoadWeatherPal`, `engine/gfx/sprite_palettes.asm` |
| Daily roll and odds | `engine/events/overcast.asm` |
| Battle weather mapping | `OverworldBattleWeather`, `data/battle/automatic_weather.asm` |
| Weather constants | `constants/weather_constants.asm` |
| Winter tiles, block swaps, roof recolours | `data/tilesets/winter_tiles.asm`, `engine/tilesets/mapgroup_roofs.asm` |
| Winter art | `gfx/tilesets/seasonal/*.png` |
| Seasonal palettes | `LoadMapPals` in `engine/gfx/color.asm`, `GetPaletteSeason` |
| Seasonal encounters | `data/wild/season_{grass,water}_data.asm` |
| Preview renderers | `docs/winter_previews/`, `docs/sun_previews/` |
| How M4 works in depth | `docs/m4_weather_implementation_context.md` |
| Seasons as built | `docs/seasons_status.md` |
| Measured tile and palette data | `docs/seasonal_cluster_handoff.md` §9 |

Useful addresses: `wStartDay $d4b5`, `wCurDay $d4c4`, `wSeason $dbf0`, `wCurRegion $dbf2`
(`$00` in Johto), `wMapWeather $cfdd`, `wOldSeason $cfde`, `EVENT_AZALEA_TOWN_SLOWPOKES` =
`$DB09` bit 1.

---

## Resume prompt

```
Picking up weather & seasons on Crystal Eclipse to finalize it. Read
docs/weather_seasons_finalization.md first; it supersedes the older handoffs. Check merge
state with `git rev-list --left-right --count core...68-ow-weather`. I've play-tested
[ which §3 items, and results ]. Next: [ merge / §4 decision / §5 art ].
```

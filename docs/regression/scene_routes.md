# Scene routes for the SameBoy regression harness

How to drop the player next to an NPC or object in the debug ROM, set the right
flags, and press A. All addresses come from `crystal_eclipse_debug.sym` and the
debug ROM as of `2f2a153e6`. **Re-resolve them after any WRAM change.** Constants
were resolved with `rgbasm -P includes.asm` on a file of `PRINTLN "{d:X}"` lines.

## 1. Warp from RAM

This copies `Script_warp`. Run until PC = `OverworldLoop.loop` (`25:4f19`), then write:

| What | Address | Value |
|---|---|---|
| wMapGroup | `wMapGroup` | group |
| wMapNumber | `wMapNumber` | map |
| wXCoord / wYCoord | `wXCoord`, `wYCoord` | stand tile |
| wDefaultSpawnpoint | `wDefaultSpawnpoint` | `$ff` (SPAWN_N_A) |
| hMapEntryMethod | `hMapEntryMethod` | `$f1` (MAPSETUP_WARP) |
| wMapStatus | `wMapStatus` | `1` (MAPSTATUS_ENTER), **written last** |

The loop then dispatches EnterMap itself. Look the four symbols up by name in the
.sym; they are not reproduced here.

**Ready signal:** `wMapStatus == 2` (HANDLE), `wScriptRunning == 0`, and PC passing
`HandleMap` (`25:4fa1`). Give it about 10 extra frames for the fade.
MapSetupScript_Warp ends in SpawnInFacingDown, so the player always arrives facing
**down**.

**Map callbacks run on entry.** Set every flag in §2 *before* writing
wMapStatus, so the object visibility and callbacks (Tin Tower NPCs, the Mewtwo
badge check) see the final state.

## 2. Flags and facing

- **Event flag n:** byte `$da5a + (n >> 3)` (wEventFlags), bit `n & 7`. The bit
  for each flag used below is listed under the scene.
- **Engine flag:** look it up in the ROM table `EngineFlags` (`20:459e`). Each entry
  is 3 bytes (`dw addr, db mask`), indexed by the ENGINE_* value. Resolved:
  - ENGINE_PERFECT_MON_COACH (100) → `$db87` mask `$08`
  - ENGINE_DAILY_MYSTERY_GIFT (97) → `$db87` mask `$01`
  - ENGINE_FOREST_IS_RESTLESS (111) → `$db5b` (wCelebiEvent) mask `$04`
  - ENGINE_POKEDEX (11) → `$d835` mask `$01`
- **Facing:** write `wPlayerDirection` (`01:d4ca`) after the ready signal and before
  pressing A. Values: DOWN `$00`, UP `$04`, LEFT `$08`, RIGHT `$0c`. The interaction
  code reads `[wPlayerDirection] & %1100`. An alternative is to tap the direction
  for one frame, which turns the player without moving them when the tile is blocked.
- **Scene var:** Tin Tower 1F uses `wTinTower1FSceneID` (`01:da36`):
  0 = SUICUNE_BATTLE, 1 = NOOP.

## 3. Giving things through RAM

CSE stores 16-bit item indexes directly in the bag, so no conversion table is
involved.

| Pocket | Count | List | Entry format | Cap |
|---|---|---|---|---|
| Items | `wNumItems` d87c | `wItems` d87d | `[idx HI, idx LO, qty]`, `$ff` terminator | 40 |
| Key items | `wNumKeyItems` d8f6 | `wKeyItems` d8f7 | `[idx LO]`, `$ff` terminator | 25 |
| Balls | `wNumBalls` | `wBalls` d912 | `[idx LO, qty]` | |
| Berries | `wNumBerries` d92b | `wBerries` d92c | `[idx LO, qty]` | |

To add an item, append the entry, increment the count and rewrite `$ff` after it.
You can also set `wCurItem` (`01:d117`) and `wItemQuantityChange` and call
`ReceiveItem` (`00:2aa6`), but injecting a call is more work than writing the bytes.

Item indexes: STAR_PIECE `$006b` (item pocket), KINGS_ROCK `$0051`,
COIN_CASE `$101`, SILVER_WING `$10b`, GS_BALL `$10c`, RAINBOW_WING `$115`.
Key items store only the low byte (`$01`, `$0b`, `$0c`, `$15`).

Other values:
- Coins: `wCoins` d83e, 2 bytes, big-endian.
- Money: `wMoney` d837, 3 bytes, big-endian.
- Badges: `wJohtoBadges` d840, `wKantoBadges` d841 (`$ff` each = all 16).
- Pokédex: `wPokedexCaught` dddc and `wPokedexSeen` de03 are bit arrays indexed by
  species-1. No scene below needs them except the optional dex splash at the
  Larvitar prize.
- Party: `wPartyCount` dc30, `wPartySpecies` dc31, `wPartyMon1` dc38,
  `wPartyMon1Happiness` dc53. Party slots hold *dynamic 8-bit IDs*. Never write a
  species constant there; the debug party already has what these scenes need.

**Debug-start state.** Taking the debug radio in PlayersHouse2F (24/7) gives
COIN_CASE, 9999 coins, KINGS_ROCK, many items, all 16 badges, EVENT_BEAT_BLAINE,
EVENT_BEAT_ELITE_FOUR and a party: Mewtwo/Mew/Lanturn at L100 with 255
happiness, plus L50 test mons at 70 happiness. Most gates below are already open
from there. **Battle detection:** `wBattleMode` (d235) goes non-zero, and
`wEnemyMonSpecies` (d20e) holds the dynamic ID. Convert it with
GetPokemonIndexFromID logic, or compare against a known-good run.

## 4. Scenes

Coordinates are map tiles (the warp X/Y). The stand tiles were checked against
collision with `tile_probe.py` (§5).

### Deity tutor scenes (10)

| # | Map (group/map) | Object at | Stand → face | Gate (must hold) | Hide flag (clear to show) | Success sets |
|---|---|---|---|---|---|---|
| 1 | Articuno — SeafoamCaves (3/96) | 10,6 | 10,7 → UP | !FOUGHT_ARTICUNO, BEAT_BLAINE | SEAFOAM_CAVES_ARTICUNO 1856 ($db42.0) | FOUGHT_ARTICUNO 790 ($dabc.6) |
| 2 | Zapdos — RockTunnelB1F (3/92) | 12,12 | 12,11 → DOWN | RESTORED_POWER_TO_KANTO 305 ($da80.1) | ROCK_TUNNEL_ZAPDOS 1857 ($db42.1) | FOUGHT_ZAPDOS 791 ($dabc.7) |
| 3 | Moltres — VictoryRoad (3/95) | 10,50 | 11,50 → LEFT (only land neighbour) | BEAT_ELITE_FOUR 65 ($da62.1) | VICTORY_ROAD_MOLTRES 1858 ($db42.2) | FOUGHT_MOLTRES 792 ($dabd.0) |
| 4 | Lugia — WhirlIslandLugiaChamber (3/74) | 9,5 | 9,4 → DOWN, **on water** | SILVER_WING key item | WHIRL_ISLAND_LUGIA_CHAMBER_LUGIA 1853 ($db41.5) | FOUGHT_LUGIA 787 ($dabc.3) |
| 5 | Ho-Oh — TinTowerRoof (15/12) | 9,5 | 9,6 → UP | RAINBOW_WING key item | TIN_TOWER_ROOF_HO_OH 1852 ($db41.4) | FOUGHT_HO_OH 786 ($dabc.2) + SET_WHEN_FOUGHT_HO_OH 2006 ($db54.6) |
| 6 | Mew — ShamoutiCave (27/5) | 8,3 | 8,2 → DOWN | BEAT_ELITE_FOUR_REMATCH 66 ($da62.2) | SHAMOUTI_CAVE_MEW 1854 ($db41.6) | FOUGHT_MEW 788 ($dabc.4) |
| 7 | Entei — DarkCaveBlackthornEntrance (3/80) | 15,10 | 15,9 → DOWN | BEAT_ELITE_FOUR | DARK_CAVE_ENTEI 620 ($daa7.4) | FOUGHT_ENTEI 610 ($daa6.2) |
| 8 | Raikou — BurnedTowerB1F (3/14) | 7,3 (last object_event) | 7,2 → DOWN | BEAT_ELITE_FOUR | BURNED_TOWER_B1F_RAIKOU 622 ($daa7.6) | FOUGHT_RAIKOU 612 ($daa6.4) |
| 9 | Suicune — TinTower1F (3/4) | scene, Suicune obj 9,9 | warp to 9,15 (door); no A press needed | wTinTower1FSceneID = 0, !FOUGHT_SUICUNE | TIN_TOWER_1F_SUICUNE 2001 ($db54.1) | FOUGHT_SUICUNE 818 ($dac0.2), scene → 1, clears SET_WHEN_FOUGHT_HO_OH |
| 10 | Celebi — IlexForest (3/52) | shrine bg_event 8,22 (BGEVENT_UP) | 8,23 → UP | EVENT_FOREST_IS_RESTLESS 197 ($da72.5) + GS_BALL key item | — | takes GS_BALL, clears FOREST_IS_RESTLESS, sets AZALEA_TOWN_KURT 1986 ($db52.2); Kurt scene (ILEX_FOREST_KURT 1987) |

Notes:
- All of these go through `DeityTutorScript` after the opening text and a yes/no
  prompt. Drive the text with A and answer YES with A.
- **Lugia:** every neighbour is water. Either set `wPlayerState` (d9fa) to
  PLAYER_SURF (4) before the warp's ready signal, or warp onto 9,4 directly. A warp
  onto water with PLAYER_NORMAL is **unverified** for the A press, so prefer surf.
- **Zapdos alt:** 13,12 → LEFT. **Raikou alt:** 7,4 → UP. **Ho-Oh alt:**
  8,5 → RIGHT. **Articuno alt:** 10,5 → DOWN.
- **Burned Tower:** the other beast objects there use EVENT_BURNED_TOWER_B1F_BEASTS_1/2
  and are cutscene sprites. Don't confuse them with the Raikou static.
- **Suicune pitfall:** if the harness fakes FOUGHT_SUICUNE for another test (Eusine,
  Rainbow Wing), **also set wTinTower1FSceneID = 1**, or the cutscene runs on entry
  anyway. The battle path runs the sdefer on map entry, sets the SAW_SUICUNE_*
  events, then plays Karen and the sages.
- **Celebi failure path** (lose or run): ENGINE_FOREST_IS_RESTLESS is re-set,
  "took back the GS BALL" prints, and GS_BALL stays in the key pocket. Assert both.

### Eusine and the Rainbow Wing path

**Eusine:** CeladonPokecenter1F (21/17). Object at 4,3 is visible while
EVENT_SET_WHEN_FOUGHT_HO_OH is **clear**. Stand at 4,4 facing UP.

| State | Expected |
|---|---|
| !FOUGHT_SUICUNE | Greeting only |
| FOUGHT_SUICUNE, but not all three beasts | NoBeastsText |
| FOUGHT_SUICUNE + RAIKOU + ENTEI | EusineLeavesCeladonText, he walks out, hide flag set (2006 $db54.6) |

**Rainbow Wing:** TinTower1F (3/4). Set wTinTower1FSceneID = 1 first.
`TinTower1FNPCsCallback` runs only if !EVENT_GOT_RAINBOW_WING (819, $dac0.3),
BEAT_ELITE_FOUR is set and BeastsCheck passes (FOUGHT_RAIKOU, FOUGHT_ENTEI and
FOUGHT_SUICUNE all set). It then clears TIN_TOWER_1F_WISE_TRIO_2 (2023 $db56.7)
and sets _1 (2005 $db54.5). Talk to Sage5 at 9,1 from 9,2 facing UP.
Expected: RAINBOW_WING ($15) lands in the key pocket, EVENT_GOT_RAINBOW_WING is
set, and changeblock 10,2 → `$20` opens the stairs.
Negative: with one beast flag clear, the trio stays hidden and there is no wing.

### Mewtwo

PokemonMansion (3/102). Object at 4,13 (SPINRANDOM), hide flag
EVENT_TOHJO_FALLS_MEWTWO 1855 ($db41.7). It appears only if !FOUGHT_MEWTWO
(789 $dabc.5) **and** all 16 badges are set. Stand at 4,12 facing DOWN; it spins, so
facing matters, not its direction.
Expected: FOUGHT_MEWTWO is set, BATTLETYPE_FORCEITEM, wild Mewtwo L70. After the
battle the object disappears (hide flag set) and the map reloads.
Negative: clear one badge bit and the object is absent.

### Silver Cave coach (perfect mon)

SilverCavePokecenter1F (19/3). Object at 7,2. Stand at 7,3 facing UP (alt 7,1 DOWN).
Gate: ENGINE_PERFECT_MON_COACH clear (`$db87` & `$08` = 0) and STAR_PIECE (`$00 $6b qty`)
in the item pocket.
Flow: intro → YES → party menu (A on slot) → confirm YES. Then: takeitem, PerfectMonApply,
flag set.
Expected for the chosen slot: DVs = `$ff $ff` (shiny) or `$ff $bf`, adjusted
down by one point for gender (Special to 14, then Defense to 14).
All six EVs = MAX_EV, HP lost is preserved (a fainted mon stays at 0), and one
STAR_PIECE is gone.
`wScriptVar` carries a PERFECTMON_* result for the CANCEL, EGG, UNOWN and ALREADY
branches. Unown is refused because its letter depends on its DVs.

### Fuchsia sage — Kangaskhan

FuchsiaPokemonGiver (17/14). Object at 2,3. Stand at 2,4 facing UP.
Gate: the first party mon's happiness ≥ 220 (debug Mewtwo has 255), party < 6,
!EVENT_GOT_KANGASKHAN_FROM_SAGE (327 $da82.7).
Expected: KANGASKHAN L60 holding KINGS_ROCK, moves BODY_SLAM / EARTHQUAKE /
SHADOW_BALL / ROCK_SLIDE, happiness 220, flag set.
`givepoke` asks to nickname it; answer NO (B or DOWN+A).
Negative: give the lead mon happiness 219 and it must refuse.

### Celadon prize — Larvitar

CeladonGameCornerPrizeRoom (21/20). bg_event at 4,1 (BGEVENT_READ). Stand at 4,2
facing UP. Gate: COIN_CASE, coins ≥ 8888, party < 6.
Menu: PIKACHU / PORYGON / LARVITAR / CANCEL → DOWN, DOWN, A, then YES.
GameCornerPrizeMonCheckDex may splash the dex entry; press A or B through it.
Expected: LARVITAR L25 is added, coins drop by 8888 (9999 → 1111), and you get
the nickname prompt.

### NPC trade — Tim

OlivineTimsHouse (1/3). Tim at 2,3 (SPINRANDOM_SLOW). Stand at 2,4 facing UP.
NPC_TRADE_TIM: give KRABBY, receive VOLTORB "VOLTY" (OT TIM, ID 29189).
The trade bit is in `wTradeFlags` (d9fc) through TradeFlagAction.
**The party needs a Krabby**, which the debug party lacks. Either catch one or
build a fixture through the battle_fixture route. Writing a species ID by hand
is unsafe (§3).
Alternatives: Kyle in VioletKylesHouse walks up and down, which makes facing
unreliable. Mike in GoldenrodDeptStore5F (6,3) spins.

### Vermilion gift house + Battle Tower (TryQuickSave)

`TryQuickSave` (`engine/events/quick_save.asm`) is `farcall Link_SaveGame`. It
writes TRUE to wScriptVar on success.

**Gift house:** VermilionMysteryGiftHouse (12/15). Carrie at 5,4. Stand at 5,5
facing UP. Gate: ENGINE_DAILY_MYSTERY_GIFT clear (`$db87` & `$01` = 0), item pocket
≤ 36 entries, ball pocket ≤ 8. **The debug start's large bag may trip "nearly
full".** Trim wNumItems or assert that branch on purpose.
Flow: YES → save YES → TryQuickSave → 3 items.
Expected: the items are added, the engine flag is set, and SRAM is written (the
save checksum/bank changed).

**Battle Tower:** BattleTower1F (22/11). Receptionist at 7,6. Stand at 7,7 facing UP.
Flow: welcome → (first visit: intro YES/NO) → menu Challenge → CheckForBattleTowerRules
→ save YES → setscene CHECKSTATE → TryQuickSave → BattleTowerRoomMenu.
The debug party has L100 mons and legendaries, so CheckForBattleTowerRules will
**probably** refuse it (unverified; check the rules routine). To reach the save,
use a fixture party that clearly meets the rules.

## 5. tile_probe.py

`docs/regression/tile_probe.py` (helper, untracked, not committed) reads the built
debug ROM. For a given map and tile, it reports the four neighbours as
LAND/WATER/WALL, the facing needed from each, and any object standing there.

```
python3 docs/regression/tile_probe.py SeafoamCaves 10 6
```

It parses `<Map>_Blocks`, the map width from map_constants, `Tileset<Camel>Coll`
(4 bytes per metatile) and CollisionPermissionTable. Ledges count as land.

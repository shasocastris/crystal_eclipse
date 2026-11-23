# v1.0 regression: overworld, travel, time

HEAD `1fb549fdf` vs `v0.9` (`2f2a153e6`), debug ROMs. Tests: `docs/regression/harness/v10_overworld.py` (23 tests, prefix `ow_`). Evidence: `docs/regression/v10/overworld/`.
Final reports: HEAD `reports/20261105-191521-de6bac77d41e`, v0.9 `reports/20261105-193132-ffdb7206c8d6`.

**Bottom line: no new game bugs found in this area.** Every targeted check passes on HEAD. Each v0.9 failure is a bug that HEAD fixes, and the tests reproduce those bugs on v0.9.

## Tests

| Test | Checks | HEAD | v0.9 | Intended? |
|---|---|---|---|---|
| `ow_silver_cave_gate_every_map` | `IsInSilverCave` called for all 420 maps. It must return carry for exactly Room 1/2/3, Item Rooms and Underbelly, and not for Outside or the Pokecenter. | PASS | skip (no routine) | new |
| `ow_silver_cave_no_rope_no_dig` | In each of the 5 maps, with the dig warp primed to Outside, Dig and the Escape Rope (`EscapeRopeEffect`) fail. They queue no script, the rope is not used up, the player keeps position and control, and "There are no paths out…" shows. Dig does not leave `wUsingHMItem` set. | PASS | PASS (INDOOR blocks it already; only the text differs) | yes |
| `ow_other_caves_rope_and_dig_work` | Control: Union Cave 1F, Ice Path 1F and Diglett's Cave. Rope and Dig both work, the rope is consumed, and the player lands at the dig destination. | PASS | PASS | — |
| `ow_silver_cave_repel` | In each of the 5 maps, `CheckRepelEffect` lets a level-2 encounter through, `DoRepelStep` ×5 leaves the count alone, and using a Repel prints "no effect here" and keeps it. Union Cave and Silver Cave Outside behave normally (blocked, the count goes 20→15). | PASS | skip | new |
| `ow_silver_cave_room1_repel_warning` | Walking Outside→Room 1 with a Repel shows the warning once and resets the scene byte. Without a Repel, no text. | PASS | skip | new |
| `ow_silver_cave_radio` | Real Pokegear radio tuned to the #MON Music frequency. In all 5 maps it says "You're out of the broadcast area." After walking out of Room 1 to Outside, and in Goldenrod, it plays #MON Music. | PASS | PASS (no gate; only Outside and Goldenrod are checked) | new |
| `ow_red_rematch_after_whiteout` | Lose to Red: whiteout, party healed, money halved, respawn in Room 3 at (9,10) facing Red, respawn already reset to Silver Cave Outside, scene back to 0, Red still present. Rematch starts with A. Win: credits roll, `EVENT_RED_IN_MT_SILVER` set, respawn Outside. | PASS | old behaviour: whites out to the previous spawn (the player's house in the fixture) | new |
| `ow_fly_every_point` | Real `FlyFunction` and Fly map from a town in each region, cursor moved with UP to each of the 27 flypoints, A. Each landing is on the spawn, on a land tile, not on a warp collision or warp_event, and the player is in control. | PASS (all 27) | PASS | — |
| `ow_indigo_fly_point` | f2e01e5ce: the Indigo spawn is Route 23 (10,6), walkable and not a warp. UP enters Indigo Plateau Pokecenter 1F. | PASS | PASS (old spot (9,6) also works) | yes |
| `ow_fly_cross_region` | Locked: LEFT/RIGHT do nothing. Unlocked: RIGHT goes to the Kanto page on Pallet. The BG tilemap rows 2-17 and BG palettes equal the native Kanto Fly map. UP stays in Kanto, LEFT returns to Johto with the same tilemap, and RIGHT+A lands in Pallet. The Orange map never switches. With no Kanto flypoint visited, RIGHT does nothing. Cancel returns control. | PASS | skip | new |
| `ow_fly_denied` | Fly fails, with no map and no warp, inside Cherrygrove PC, inside Silver Cave Room 2, and without the STORMBADGE. | PASS | PASS | — |
| `ow_weather_map_every_landmark` | Weather-map upgrade on. The Pokegear map opened in Goldenrod, Saffron and Valencia, with UP through all 100 landmarks. Every label is one of the 9 names. Each of the 19 landmarks reachable by warp shows the label equal to the weather on arrival at its first outdoor map. Exits cleanly. | PASS | skip | new |
| `ow_overcast_palette_only` | Goldenrod forced to `OW_WEATHER_OVERCAST`: BG palettes are dimmed, there is no OAM reservation, no particles, and `GetAutomaticBattleWeather` returns 0. | PASS | skip | new |
| `ow_orange_pass` | Oak's aide gives the pass. With it, on a Monday, Vermilion Port→Valencia Port and back by the express both work. Without it, the player is turned away at both ports. | PASS | skip | new |
| `ow_clock_reset_keeps_season` | `InitTime` for 4 seasons × 7 weekdays × RTC days 0/10/50/139 (112 cases). `wSeason` and the calendar season keep the pre-reset season, and `wCurDay mod 7` is the chosen weekday. | PASS 112/112 | **FAIL 84/112** (the season jumps while `wSeason` stays stale) | yes: 83c1890e5 fix confirmed |
| `ow_warps_keep_player_state` | Door, stairs, cave entrance and water warp, each (a) after a real wild battle and (b) with the trainer-battle/Good Rod scratch leftovers poked in. Walking arrives NORMAL, surfing arrives SURF, and `wWaterWarpState` ends at 0. | PASS 8/8 | **FAIL**: door, stairs and cave with leftovers arrive on the BIKE. Water after a real wild battle arrives **not surfing**. Water with leftovers arrives on the BIKE. | yes: cd89b9f5d fix confirmed, and it also fixes surf lost after a battle |
| `ow_heal_machine_keeps_npc_palettes` | Azalea PC, entered through the door. rOBP1 forced to `$ff` (the commit's precondition), then heal at the nurse. NPC object palette slots (`wUsedObjectPals` 0-6) must be unchanged in `wOBPals2`. | PASS | **FAIL**: slot 1 goes from `fb6f7f2a2a7d0000` to all zero (black NPCs) | yes: 91f7ab4b7 fix confirmed |
| `ow_visual_caves_and_museum` | Screenshots of Ice Path (5 maps), Seafoam Caves and Pewter Museum 1F/2F at fixed spots, hour 12. | saved | saved | see Visual diffs |
| `ow_save_layout_matches_v09` | Every WRAM label in `wGameData..wGameDataEnd` has the same address on both builds, and the size is unchanged (2776). `wVisitedSpawns` `$dbf5` and `wDigWarpNumber` `$dbfd` are identical. `GiveNicknameHappiness` is in `PokeBallEffect`'s bank (00bca0e35 near call is safe). | PASS (0 moved; renames only: `wGoldenrodPokecenter1FSceneID`→`wSilverCaveRoom1SceneID`, plus the Route 38 gate scene in a former `ds`) | PASS | yes (8c86d4b2f) |
| `ow_smoke_changed_maps` | The 59 maps whose files changed since v0.9. For each: land on the first warp_event, win any battle, walk 4 ways, open and close START, and get back to PlayerEvents with no crash. | PASS (after the allowlist below) | v0.9 also stalls in Tin Tower 1F (the Suicune soft-lock, fixed in 1f371a693) | — |
| `ow_smoke_all_maps` | All 420 maps: land, take one step, regain control. A crash is PC at `$38`, in VRAM/SRAM or in echo RAM. | PASS (after the allowlist) | Tin Tower 1F also stalls | — |

**Smoke allowlist (`SCRIPTED_ENTRY`):** Dragon Shrine, Mt. Moon, Cerulean Base 3, Hall of Fame, Battle Tower battle room and elevator, Mr. Pokémon's house. (The Goldenrod and Celadon Dept Store elevators were taken off on 2026-11-08: `_smoke_one` now sets `wBackupWarp*` before a raw warp onto a `-1` warp, as the game does on arrival, so both step out to 1F. Before that, the raw warp left the way back unset and they crashed via map 0,0.) These are test limits, not bugs:
- Their entry scene needs a real answer (a quiz, an elevator floor, the Hall of Fame sequence, Mewtwo's static battle). The blind A/B masher cannot give it.
- The same set fails on v0.9.
- The screenshots show menus or battles, not crashes.
- No map anywhere showed a crash signature.

## Game bugs found
None in this area. Cross-reference: `audit.md` bug 2. The Valencia express now needs the ORANGE PASS, so a v0.9 save made in the Orange Islands is stranded. I did not repeat that check. `ow_orange_pass` confirms that the Valencia sailor refuses a player without the pass on HEAD, which is the same mechanism.

## Visual diffs for shasocastris to judge
Side-by-side sheet: `v10/overworld/visual_compare_head_left_v09_right.png` (HEAD left, v0.9 right).
- **Ice Path 1F/B1F/B2F×2/B3F and Seafoam Caves (e03df73c5):**
  - The only pixels that differ are on sprites: the player, boulders and item balls. They are lighter (day sprite palette) on HEAD and darker (night) on v0.9.
  - The BG is identical.
- **Pewter Museum 1F/2F (f136b583a, 34fecc68b):**
  - Pixel diffs fall where the wandering NPCs and the player stand. I saw no BG difference at the 7 spots captured.
  - The changed blocks may lie outside these views. Please confirm on the full museum in play.
- Other screenshots are there for eyeballing, not for a verdict:
  - `fly_*.png`: cross-region pages.
  - `weathermap_*.png`: weather labels CLEAR, SUNNY and CLOUD in each corner.
  - `overcast_goldenrod_{none,overcast}.png`
  - `radio_*.png`
  - `red_after_whiteout_head.png`
  - `heal_{before,after}_{head,v09}.png`

## Suspicious, not confirmed
- **Fly map bubble garbled:** when `FlyFunction` is called straight from the overworld, as the harness does, the "Where? / town" bubble draws as garbage tiles. The tilemap holds the right text.
  - This is identical on v0.9 and HEAD.
  - The harness skips the party menu, which normally has the font loaded, so this is almost certainly a harness artifact.
  - Worth one glance in play after a cross-region switch.
- **Cross-region Fly vs the Indigo gate:** the native Kanto Fly page needs `SPAWN_INDIGO` visited. Cross-region RIGHT needs only *any* visited Kanto flypoint (`engine/pokegear/pokegear.asm` `_FlyMap.SwitchRegion`).
  - This is harmless in practice, since the unlock is at Mt. Silver after the League.
  - It is a design inconsistency to note.
- **Respawn after Red:** the respawn resets to Silver Cave Outside even if the player's previous respawn was elsewhere. This is documented as intended in memory: whiteout is "the only way out" by design.
- **Battle Tower elevator on v0.9:** the stall there had PC=`$de01`, which is WRAM. HEAD stalls at `$03fc`, a normal wait loop. This is pre-existing, v0.9 only, and not investigated.

## Harness notes (not game bugs)
- Text boxes: advance with **A**, not B, when a yes/no may follow. A B held into `YesNoBox` answers "no". `overworld.wait_for` and `finish` use B, which declined the express and the heal until `_run_dialogue` switched to A.
- Beating Red rolls the credits, not `CleanUpBattleRAM`. Losing ends at `HalveMoney`, the whiteout script. Battle drivers need these end markers.
- `FlyFunction`'s escape/fly scripts go to `wQueuedScriptBank`, and only the start-menu callback runs them. `run_queued()` re-queues them as the map reentry script.
- `POKEGEARCARD_*` constants live in `engine/pokegear/pokegear.asm`, so `consts.resolve` can't see them. The radio knob steps by 2.
- `battle.fast_options` still sets `BATTLE_SHIFT`. The constant is kept as "unused" on HEAD, so this is harmless.
- `pgrep -f` waits matched their own shell. Use the PID.

## Not testable headlessly (hand playthrough)
- The feel and timing of the Red rematch scene (turns, music) and the ominous texts.
- That the radio static and music really stop in the cave, as audio.
- Whether the Fly map bubble is correct after LEFT/RIGHT when entered from the party menu, as above.
- The museum's full layout. Whether the Ice Path day sprite palette looks right at night, i.e. with the player's real RTC hour.
- Getting the ORANGE PASS from the real giver flow (Oak's aide is a placeholder), and S.S.TICKET + pass on a Wednesday or Sunday (the destination menu). Neither is covered.

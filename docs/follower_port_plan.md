# Follower Pokémon — Port Plan

Status: Phase A committed on branch `85-followers` (`c450a9048`, 2026-11-06). Phase B committed (`7e0d234fd`, 2026-11-06). Phase C committed (`f8e911dab`, 2026-11-06). Phase D committed (`319133633`, 2026-11-06). Phases E–G committed together (`8c5dc96ef`, 2026-11-07); see the outcomes below. After G: SELECT choice (`91feb141d`), boxed F (`1f4bc7d23`), double happiness (`b530d630a`) and art for seven borrowed sprites (`545f73d97`, 2026-11-08). Full regression clean on 2026-11-08 (see Phase G). Interaction text fix (`1321aa614`, 2026-11-09). Still open: the weather OAM check (§4.2) and the by-eye palette pass.

## Phase E outcome (sprites)

- **Source:** MysticCrystal's `gfx/following/` sheets (16×96, already in frame order: front, back, side, then the step frames). They're converted to 4-level greys by luminance rank, because 26 of Mystic's sheets are tinted RGB rather than grey. Colours still come from the palette table.
- **Importer:** `docs/followers/import_follower_sprites.py` (untracked). It writes `gfx/following/*.png`, `gfx/following_sprites.asm` and `gfx/following_sprite_pointers.asm`. Rerun it after adding a sheet or a species.
- **Layout:** one floating `SECTION` per sprite (384 B). Free ROM is fragmented, and pinned sections are placed first, so these only fill the leftover gaps. 297 sheets ≈ 112 KB; 325 KB of ROM is still free.
- **Name mapping:** MR__MIME→`mr_mime`, PORYGON_Z→`porygonz`, DUDUNSPARC→`dudunspars`, RAICHU_ORANGE→`raichu_alolan`.
- **Unown** has a sheet per letter (`UnownFollowingSpritePointers`), chosen from the DVs with `GetUnownLetter` (Mystic `2d1a23c84`).
- **Borrowed sprites → Eclipse art (`545f73d97`, 2026-11-08):** the eight species with no Mystic sheet used to borrow one. Seven now have their own sheet in `gfx/following/`, listed in the importer's `ECLIPSE_ART` set so a rerun keeps them instead of pulling from Mystic:

  | Species | Was | Art |
  |---|---|---|
  | Annihilape | Primeape | drawn from the Pokédex pic |
  | Sirfetch'd | Farfetch'd | drawn from the Pokédex pic |
  | Wyrdeer | Stantler | drawn from the Pokédex pic |
  | Farigiraf | Girafarig | drawn from the Pokédex pic |
  | Ursaluna | Ursaring | `../crystal-inheritance/.../ursaluna_wilds.png`, reordered into follower frame order |
  | Cursola | Corsola | drawn from the Pokédex pic |
  | Corsola (Kanto) | Corsola | drawn from the Pokédex pic |

  **Dragonite (Kanto)** still borrows Dragonite's sheet (the only `BORROW` entry left): its Pokédex pic is Dragonite's, only the palette differs, and the follower already gets its own BLUE. Walk frames for the new sheets are the base frame one pixel lower, with no separate leg poses.
- **Light shade is skin tone:** in every overworld hue except WHITE, colour 1 is the shared peach skin tone, so mostly-light art turns peach. Annihilape, Cursola and Corsola (Kanto) therefore use WHITE (normal); shiny Cursola and Corsola (Kanto) use `WHITE_PURPLE` (grey light shade, purple dark). They're the first users of WHITE and of a two-hue name.

- **Palettes (2026-11-07, shasocastris's call):** every follower now uses its party icon colours, copied row for row from `data/pokemon/menu_icon_pals.asm` (normal and shiny). The icon and overworld palettes share the same RGB values, so a follower matches its icon. Mystic's two-tone picks are gone from the table; the pair-palette code (`FIRST_FOLLOWER_PAIR_PAL`, `CopySpritePal`) stays in case a two-hue name is wanted again.
- **Contact sheets:** `docs/followers/follower_sheet_day.png` and `_nite.png`, every species normal and shiny. Regenerate them with `docs/followers/render_follower_sheet.py [morn|day|nite|eve]`.

## Phase F outcome (movement)

- Already in from Phase A: ledge sound, running and ledge speed (`eaf6d1baf`, `7d9f8540d`), the FOLLOWEROBJ template (`0863ecdb3`), and the talk glitch fix (`7c5e936fd`). Eclipse never had `HideFollowerIfNPCBump` (`6c445f03a`).
- **Bike:** getting on the Bike stows the follower (with the ball). Any player step taken on a bike also stows it, which covers forced cycling and warping in on a bike. Getting off brings it out one step later.
- **No-whiteout loss** (Mystic's open TODO `ef515cf39`): with every mon fainted, `GetFirstAliveMon` falls back to the first non-egg mon, instead of entry 0 (which showed Bulbasaur).
- **Lead changes in scripts** (the proper fix for Mystic's "bad Day-Care hack" `75cd41d39`): when a script ends (`end`/`endall` with no parent), `RefreshFollowerIfLeadChanged` compares the lead's species and party slot with the follower's, and reloads the sprites if they differ. This covers the Day-Care, trades, gifts, the PC and overworld poison faints.
- **Skating:** `PLAYER_SKATE` is never set anywhere in Eclipse (vanilla's unused skateboard), so there's nothing to test.
- **Headless tests** (`docs/regression/harness/suite_followers.py`, all passing):
  - bike on/off, including a warp while riding;
  - ice slides (Ice Path 1F, Mahogany Gym);
  - Escape Rope and Dig;
  - Fly;
  - all-fainted lead;
  - Unown letters;
  - lead changed by a script.
- **Covered by the existing suites:** Fly to every point, cross-region Fly, the Orange Pass, warps keeping the player state, Silver Cave whiteouts (`v10_overworld`), and S.S. Aqua boarding (`v10_story`).
- **Not tested headless:** Waterfall and Whirlpool. The follower is in its ball while surfing, so they only move the player.

## Follower choice (SELECT in the party menu, after G)

Modelled on Crystal Clear. **shasocastris's calls:** a fainted follower is put away and comes back once healed (the F stays); the starter follows on a new game; SELECT works only in the start menu's POKéMON screen.
- **State:** `wFollowerSlot` (saved, in the old `ds 4` after `wFollowerFlags`): a party index, or `FOLLOWER_NONE` ($ff). Zero on a new game, so the starter follows; old saves start with mon 1.
- **Who follows:** `GetFollowerMon` (was `GetFirstAliveMon`) returns the chosen mon, or none if it's an egg, fainted or past the end of the party (Bug-Catching Contest: only the lead is kept).
- **Showing / hiding:** `CheckObjectFlag` masks the follower on map load, `CopyFollowerStruct` won't build it, and `RefreshFollowerIfLeadChanged` (script `end`, start menu close) adds it (out of its ball on the next step) or deletes it.
- **Party changes:** `FollowerSlotRemoved` (RemoveMonFromParty: Day-Care, Shuckle, NPC trades, mail; and the PC's party removal) and `FollowerSlotSwapped` (party menu SWITCH, the PC's `SwapPartyMons`). Removing a mon above the follower moves the slot up; removing the follower leaves the slot to the mon that moves in, or the one above if it was last.
- **Menu:** `PartyMenuSelect` handles SELECT (only the start menu adds it to `wMenuJoypadFilter`); `PlacePartyFollowerMarks` draws the boxed F (`gfx/stats/follower.png`, Crystal Clear's tile: black outline, blue F from party BG palette 0) at column 4 of the mon's second row, right of the held-item icon. `LoadPartyMenuGFX` loads it over the unused `<DO>` tile, `FOLLOWER_MARK_TILE` = $70. Eggs and CANCEL get `SFX_WRONG`.
- **Tests:** `follower_select_choice`, `follower_fainted_comes_back`, `follower_slot_on_removal`; `follower_all_fainted` now expects no follower.
- **Smoke test:** the Celadon elevator now also trips the `-1`-warp artefact (see the Phase G note); walked in from 1F, both elevators work. Harness fixed 2026-11-08, see there.

## Phase G outcome (map scripts)

- **Method:** `docs/regression/harness/follower_sweep.py` (untracked) triggers every coord-event, map-entry (`sdefer`) and talk-triggered cutscene with a follower out. `follower_watch.py` reports every frame where a visible NPC or the player shares the follower's tile. Baseline runs on the pre-fix ROM covered 110 coord scripts, 61 entry scenes and the talk scripts. Fixes were rechecked with `--all-dirs`, since a single approach direction missed half the cases.
- **Fix pattern:** `stowfollower` before the first NPC walks toward the player, and `appearfolloweronestep` before `end`. On a follower that's already hidden (just warped in), `stowfollower` is silent. `appearfolloweronestep` does nothing if the follower is still out, so it's safe on shared exits. There's also a new macro, `stowfollowerif DIR`, for scenes where only one approach collides. Scenes that end in a warp need no appear.
- **Patched** (all overlapped in the sweep unless noted):
  - Cherrygrove rival; New Bark teacher (both) and rival; Route 32 cooltrainer; Elm's aide (4 scripts); Mr. Pokémon (Oak's exit, then back after the heal); Route 27 first step into Kanto (`stowfollowerif RIGHT`).
  - Olivine rival (top/bottom), Olivine Port and Vermilion Port leaving the ship (incl. the express), Fast Ship boarding (an extra `step DOWN`) and the worried grandpa; Goldenrod/Saffron Magnet Train arrivals; Cianwood Karen/Suicune.
  - Ecruteak Pokémon Center Bill; Ecruteak Gym and Route 34 gate escorts; Ruins research centre (closed escort; Elm's scene); Mahogany escort; Wise Trio's room.
  - Rocket Base B1F cameras (all 8), B2F Ariana/Lance, B3F Archer-boss and rival; Victory Road rival.
  - Elite Four rooms (a 5th `step UP` so the follower clears the closing door), Lance's room (Mary/Oak and the rematch).
- **Engine fix found by the sweep:** a stowed follower came back out whenever it stepped from a non-land tile onto land, through the "comes back on land" half of the water rule. New flag `FOLLOWER_ON_WATER_F`: only a follower the water put away comes back on land. A stowed follower stepping onto water no longer plays a second ball animation either.
- **Not patched, on purpose:**
  - Cerulean Base 3 Archer: a sweep artefact. The fixture lacked `EVENT_DISCOVERED_CERULEAN_CAVE`, so Lance and the ranger stood in the room from the start; with the story flag it's clean.
  - Sweep errors that are harness limits: naming screen (Elm's cop), Mom's Pokégear, the starter nickname, the Hall of Fame and Lance rematch continuations, the Cerulean Base 2 rival, and the Dragon Shrine quiz.
- **Pre-existing, not follower-related:** entering the Ruins research centre by the right-hand door (3,7) during Elm's scene walks the player into Elm's tile.
- **Tests added:** `follower_cutscene_stow` (New Bark teacher with the follower on her side: nobody shares its tile, it's back one step after) and `follower_surf_to_land`.
- **Final regression run (all E–G changes):** `suite_followers`, `v10_story` and `suite_scenes` pass. Battle Tower first failed on every post-G ROM: the harness only pressed A, so a status move in slot 1 ran out of PP by the 5th opponent, depending on RNG/layout. `_tower_battle` now gives the battle mon Strength with PP each turn; all four tower tests pass on the baseline and the final ROM. `v10_overworld` fails only `ow_smoke_all_maps` on GOLDENROD_DEPT_STORE_ELEVATOR. That's a harness artefact: the smoke test raw-warps into a map whose only exits are `-1` warps, so stepping out goes to an unset "last map". Raw-warped, both the pre-G baseline and the final ROM step into map (0,0). The baseline hangs at `d6ec`, which the smoke test tolerates for scripted-entry maps; the final ROM's different layout happens to fall into `rst $38`, which counts as a crash. Walked in from 1F for real, the elevator exits cleanly on both ROMs. **Fixed in the harness (2026-11-08):** in game, arriving on a `-1` warp saves the way back (`GetWarpDestCoords.backup`) and the elevator menu overwrites it, so the player never meets an unset backup. `_smoke_one` now does the same before a raw warp onto a `-1` warp: `_backup_warp_for` points `wBackupWarp*` at the map the warp names, at its warp that leads back. Pokécenter 2F names itself, so it's left alone. Both elevators are off `SCRIPTED_ENTRY`; spot-checked, each steps out to its 1F elevator door. Full `v10_overworld` rerun on the 545f73d97 debug ROM: 21/21 pass, `ow_smoke_all_maps` included.
- **Save roundtrip (2026-11-08, harness-only):** `save.save_and_continue_roundtrip` (also pulled in by `suite_weather`) failed on `wObject1StepType 1->0`, its first run since the port (last pass 2026-11-05). Slot 1 is now the follower, and every reloaded object is `STEP_TYPE_RESET` until its first frame; the test read WRAM on the exact frame control returned. All other follower fields, `wFollowerFlags` and `wFollowerSlot` round-trip. The test now runs 2 frames after CONTINUE before comparing; passes.
- **Full regression queue (2026-11-08, debug ROM of 545f73d97 plus the working tree's uncommitted Celebi/Johto-evos/Elm's Lab edits), one suite at a time:**

  | Suite | Result | Notes |
  |---|---|---|
  | `suite_followers` | 35/35 | includes all 21 `v10_overworld` tests, smoke-all-maps too |
  | `suite_followers` (rerun 2026-11-09, `1321aa614`) | 37/37 | adds `follower_interactions` and `static_text_command_then_char`; report `20261109-003329-5b723555df3a` |
  | `suite_scenes` | 23/23 | |
  | `v10_story` | 22/22 | |
  | `suite_weather` | 8 pass, 1 fail, 1 skip | fail = the save roundtrip above (fixed; passes on rerun); skip = `bank_moved_battle_anims_match` needs the v09/pre11/post11 baseline ROMs |
  | `suite_battle_moves` | 15/15 | |
  | `suite_obedience` | 8/8 | |
  | `suite_direct` | 5/5 | |
  | `suite_evolve_location` | 9/9 | |
  | `suite_repro` | 6 pass, 1 skip | `repel_shasocastris_bt_save`: shasocastris's save copy not present |
  | `suite_save` | 3/3 | with the roundtrip fix |
  | `v10_battle` | 33/33 | the 18 `battle_ab_*` first errored (environment, below); 18/18 on rerun |
  | `v10_items` | 18/18 | `items_balls_flags` first errored (environment); passes on rerun |
  | `v10_audit` | 4 pass, 1 fail | `audit_v09_save_loads` first errored (environment); on rerun fails by design: v0.9 save gets no CONTINUE, since phase A `c450a9048` (NUM_OBJECTS 18→19 shifts the save checksum by 17 bytes; core `ba9240400` still continues it). Fresh-save v1.0, see `docs/regression/v10/audit.md` |

  The 20 errors are all `FileNotFoundError`: the v0.9 and head comparison tests read source trees from session `4203bf99`'s scratchpad (`wt/v09` = tag v0.9 `2f2a153e6`, `wt/head` = `1fb549fdf`). Their ROMs in `roms/` survive but the worktrees are gone. Paths are hard-coded in `v10_battle.py` (`SCR`), `v10_audit.py` (`SCRATCH`, or `AUDIT_SRC_REPO`) and `v10_items.py` (`V09_REPO`). Recreated with `git worktree add --detach` at those paths for the rerun (no build needed), then removed again. `suite_linkdiff` wasn't run (A/B only, needs the pre11/post11 ROMs).

## Phase D outcome

- **shasocastris's call:** Mystic's two-tone follower palettes, built from Eclipse's own hues for all four times of day. Party icons are unchanged.
- **Table:** `data/pokemon/follower_pals.asm` (normal, shiny), 2 bytes × `NUM_POKEMON_AND_VARIANTS`. It's generated from Mystic's `data/pokemon/menu_mon_pals.asm` by a scratch script, in Eclipse species order. DUDUNSPARC takes Mystic's DUDUNSPARS row.
- **No Mystic pick (icon colours for now, review in Phase E):** ANNIHILAPE, SIRFETCH_D, WYRDEER, FARIGIRAF, URSALUNA, CURSOLA, CORSOLA_KANTO, RAICHU_ORANGE, DRAGONITE_KANTO. (2026-11-08: ANNIHILAPE, CURSOLA and CORSOLA_KANTO moved to WHITE; see Phase E.)
- **Pair palettes** have no stored colours. The index is `FIRST_FOLLOWER_PAIR_PAL` ($30) + hue1 × 16 + hue2, where both hues are ≤ BLACK ($0c), so the maximum is $fc and $ff stays free. `CopySpritePal` loads hue1's palette, moves its colour 2 into colour 1, then puts hue2's colour 2 in colour 2. Each hue goes through the normal darkness / time-of-day lookup (now `GetSpritePalSource`), and the weather dim applies afterwards. Pairs share the normal OB slot allocation.
- **Shiny** uses `CheckShininess` (all DVs ≥ 12).
- **Verified headless:** 8 species, normal and shiny, by day and at night. In a dark cave, the follower's loaded OB palette equals [hue1 c0, hue1 c2, hue2 c2, hue1 c3] read back under the same conditions. Every species still shows the placeholder sprite, so judging the colours by eye waits for Phase E.
- No new optimizer warnings; no ROM0 cost.

## Phase C outcome

- **Art:** Mystic's `anim_pokeball.png` (three 16×16 frames: open, opening, closed), now `gfx/emotes/poke_ball.png`. It's loaded as `EMOTE_POKE_BALL` on every map load, in `LoadMiscTiles`.
- **VRAM:** the ball's 12 tiles go at VRAM0 `$64`–`$6f` (`FOLLOWER_POKE_BALL_TILE`). Mystic used `$f0`, but in Eclipse that's the map-name popup. `$62`–`$7b` was free: weather uses `$60`–`$61` and the heal machine `$7c`.
- **Palette:** Eclipse already had `PAL_OW_POKE_BALL`, so Mystic's palette fixes (`47421bf12`) weren't needed. `2e37d522b` is a battle catch-animation fix and isn't a follower change; skipped. `913ec07c6` (cosmetic) skipped.
- **The ball** is a temp object (`SPRITEMOVEDATA_POKEBALL_OPENING`/`_CLOSING`) that tracks the follower's sprite position, showing each frame for 4 frames. Opening shows the follower at the end, unless a script stowed it again meanwhile. If no object struct is free, the follower just appears.
- **No entering/exiting flags.** Mystic sets "entering ball"/"exiting ball" flags so it can restart an animation that a battle or map reload cut off. Here `wFollowerFlags` get the *final* state the moment an animation starts, so a reload just lands on it. Only `FOLLOWER_IN_POKEBALL_F` (3) was added: "come out of a ball next time you appear".
- **When the ball plays:**
  - water: closes as the follower steps onto it; land: opens as it steps back
  - `stowfollower` (closes; the script waits 13 frames)
  - `appearfollower` (opens; waits 13 frames)
  - `appearfolloweronestep` (opens on the player's next step, so Elm's Lab's starter pops out of a ball)
  - `silentstowfollower` hides it without a ball, but the next appearance uses one.
- **No ball after warps, Fly, Dig or falls:** the follower just appears on the first step, as in Mystic. Adding one there is a Phase F decision.
- **Verified headless** (filmed frame by frame): stow, appear, appear-one-step, surf off (closes), landing (opens).
- No new optimizer warnings; no ROM0 cost.

## Phase B outcome

- **Script commands** `$b2`–`$b6`: `stowfollower`, `silentstowfollower`, `appearfollower`, `appearfolloweronestep`, `savefollowercoords`. The code is in `player_object.asm` (`_StowFollower` etc.).
  - `stowfollower` and `silentstowfollower` both just hide the follower for now; Phase C gives `stowfollower` the Poké Ball and a script wait.
  - A stowed follower keeps trailing, invisible, and stays hidden until `appearfollower` or a warp plus a step. (A water→land step used to reveal it too; Phase G limited that to water hides.)
  - `appearfollower` rebuilds the follower's struct at its map object's coords (set those with `moveobject` or `savefollowercoords`). Rebuilding reloads the lead mon's sprite and palette, so it also covers a changed lead.
  - `appearfolloweronestep` puts it hidden under the player; it appears behind them after their next step. Elm's Lab uses it at the top of `ElmDirectionsScript`.
- **The follower template is now `SPRITEMOVEDATA_FOLLOWEROBJ`** (Mystic `0863ecdb3`), so an `applymovement FOLLOWER` resets it to follower movement rather than plain follow.
- **`jump_in_place`** is movement `$5e` with step type `STEP_TYPE_NPC_JUMP_IN_PLACE`. It uses a jump height step of 8, not the reference's 4, so the hop comes back down instead of snapping from the top.
- **Interaction table** (`engine/events/follower.asm`): Mystic's 16-bit species matcher, rewritten. Changes from both sources:
  - Every script now ends with `waitbutton`/`closetext` (in `FollowerScript`); the sources closed the box without waiting, and Paralyze never opened one.
  - Rows match the map by group *and* number (the sources compared the map number alone).
  - A time-of-day mask column and an `OW_WEATHER_*` column. No time rows yet.
  - New rows: Silver Cave, Shamouti (Lugia and the birds), sea breeze on Valencia/Shamouti, and weather (snow, rain, thunderstorm, sun, sandstorm, cherry blossoms).
  - Fixed: the Power Plant rows used `LANDMARK_ROUTE_2`; the Ditto text printed a stray `@`; "emmited"; "it's body". Slowking joins the Slowpoke Well rows.
  - Dropped: the default interaction's 1-in-50 Nugget (farmable by talking repeatedly). The default now hops twice and picks one of three lines.
  - Talking to a hidden follower does nothing.
- **Phase A bug fixed:** `CopySpriteMovementData` checked the struct's *old* sprite to decide whether to hide the follower. It only worked after warps because struct 1 still held `SPRITE_FOLLOWER`. It now reads `wTempObjectCopySprite`, which also saves 4 B of ROM0 (debug ROM0 now 824 B free).
- **Verified headless** (now a regression test: `followers.follower_interactions`, see §4.6): talk (hop + text), poison (emote + text), snow row, Sudowoodo on Route 36, stow (hidden, can't be talked to), save coords + appear, appear-one-step, and the empty-party → first-mon case.

## Phase A outcome

What changed from the plan below:
- **Mystic is closer to Eclipse than the reference.** It sits on pokecrystal16, the base CSE grew from (`jmp`, `NormalStep` taking `d`, the same STEP_RUN/STEP_BIKE vectors). Its versions of the engine hunks were used wherever they matched Eclipse better. The reference was the guide for *which* hunks to take.
- **Still 13 object structs, not 14.** The VRAM tile slots are full: structs 0–7 use VRAM0 `$00-$5f`, with walking frames at `$80-$df`; structs 8–12 use VRAM1 `$00-$3b` and `$40-$7b`. A 14th struct would overlap struct 8's walking frames, and the free VRAM0 space is taken by the map-name popup (`$e0+`), weather (`$60`) and the heal machine (`$7c`). The follower takes struct 1, so NPCs get 11 structs instead of 12. Check crowded maps in Phase G.
- **`NUM_OBJECTS` went from 18 to 19.** Map object 1 is the follower and map events start at 2. Map object constants already started at 2 (`object_const_def`), so `GetScriptObject` (the `dec a`) was deleted, along with its 14 call sites.
- **Palettes come from `MonMenuIconPals`** (normal and shiny), mapped from PAL_ICON_* to PAL_OW_*. This is what the reference ended up doing ("use party pals"), so **most of Phase D is done**. `RefreshFollowerPalette` runs from `RefreshSprites`, so a changed lead mon gets its new colours.
- **Sprites are uncompressed** (384 B each). That means no `wDecompressScratch` and no SVBK juggling in `GetUsedSprite`; the full set costs about 170 KB of the 447 KB free. The table is indexed by species index − 1 over `NUM_POKEMON_AND_VARIANTS`, and every entry currently points to `gfx/following/placeholder.png` (Mystic's Pikachu).
- **Mystic art needs no conversion.** It has the same 16×96 frame order and left-facing side frames as Eclipse NPCs. Only its RGB greys need snapping to 0/85/170/255.
- **Left out:**
  - the party menu icon swap
  - `wFollowerState`, `VAR_FOLLOWERSTATE`, `wScriptVar2`, `text_endasm` (write-only or unused in both sources)
  - the Fly `SetFirstOBJPalette` call (it belongs to the icon swap)
  - `HideFollowerIfNPCBump` (Mystic removed it in `6c445f03a`)
  - the reference's "very fast" step vectors (Mystic's STEP_RUN/STEP_BIKE ledge jump replaces them)
- **Added beyond the plan:**
  - Ledge SFX and running support in the jump (from Mystic, Phase F).
  - Eggs never follow.
  - Trainer sight blocking is a ROMX `CheckFollowerBlocksSight`; it ignores a hidden follower.
  - New `.CheckBackedInto`: when a cutscene backs the player up (`fix_facing`) onto the follower, the follower is pushed back instead of swapping in front. Without it, the Tin Tower Suicune scene parked the follower on Suicune's tile and `scenes.deity_suicune_retry` failed.
- **Saves:** `wFollowerFlags` uses existing padding in the saved block. The extra map object makes `wPlayerData` 16 B longer, which is a save break (already accepted for v1.0).
- **Cost:** debug ROM0 went from 863 to 820 B free. No new `optimize.py` warnings.
- **Verified headless (SameBoy):**
  - Warp (hidden until the first step), walking, running.
  - Talking ("<NICK> is happy to be out!" plus a cry).
  - Surf: hidden on water, back on land.
  - Route 29 ledge hop.
  - The Route 29 → New Bark connection.
  - `suite_scenes` 23/23 and `v10_story` 22/22.
- **Not yet checked:**
  - continue from a save
  - bike
  - ice
  - trainer sight blocking in a real encounter
  - a lead change from the party menu
- **Phase G already has one finding:** New Bark's "Wait, <PLAYER>!" teacher scene, with the follower out.
- **With an empty party the follower is masked** (`CheckObjectFlag`). After the first mon is received it stays hidden until the next map load; the Elm's Lab `appearfollower` belongs to Phase B/G.

---

Original plan (2026-11-06):

## 0. Sources and the old branch

| Source | Path | Role |
|---|---|---|
| fellowship-of-the-roms `follow-mons` (Vulcandth) | `../follow_mons_pokecrystal` | **Primary.** The cleanest version: 24 commits on pret, base `86a87a355`, tip `c22a36d29`. Port the engine and scripts from here. |
| MysticCrystal | `../MysticCrystal` | **Gap filler.** It built on the same code and added 1.5 years of fixes (running, ledges, bike, palettes, rival shove, Falkner guide) and 446 follower sprites (Gen 1–4 plus regional forms). |
| Branch `15-implement-followers-from-MysticCrystal` | — | **Abandon.** It is 627 behind `core`, and its one commit (`7cb4f3f22`) only gives the Blackthorn Dratini its own sprite and makes the Goldenrod Growlithe show its dex entry. Cut a fresh branch from `core`. Cherry-pick `7cb4f3f22` only if those two map tweaks are still wanted. |

Read the reference with `git -C ../follow_mons_pokecrystal show <hash>`. It is pret-style (raw `jp`), not CSE, so every hunk gets rewritten by hand rather than applied as a patch.

## 1. What CSE already has (skip these)

| Reference commit | Why it's skipped |
|---|---|
| `fb4a2b900` Port FIQ's GDMA transfer routine | Already in CSE (`home/gfx.asm:36`, `CheckGDMA`). |
| `7607fa0ec` Dynamic Sprite Reload | Already in CSE (`data/maps/outdoor_sprites.asm` is gone, and `ReloadSpriteIndex` is in `engine/overworld/overworld.asm:83`). Check that the follower's sprite slot fits the CSE version of `wUsedSprites` handling. |
| `7708ffd23` Debug Tools | Unrelated. |

Stale `gfx/following_sprites*.o` files in `gfx/` are left over from an older attempt. They are git-ignored; run `make tidy` before starting.

## 2. Port order (reference commit → Eclipse step)

Each phase builds and runs before the next one starts. Run the optimizer baseline (`.opt.old`) before phase A.

### Phase A — Engine core (`1f8500488` "Follow Mons Base Commit", `71b4edf42`)
The big one: 336 files, most of them sprite PNGs. The code parts:

- **Constants:**
  - `map_object_constants.asm`: `SPRITEMOVEDATA_FOLLOWEROBJ`, `SPRITEMOVEFN_FOLLOWER_OBJ`, `FOLLOWERMOVE_*`
  - `wram_constants.asm`: `wFollowerFlags` bits (INVISIBLE, INVISIBLE_ONE_STEP, FROZEN, IN_POKEBALL, ENTERING_BALL, EXITING_BALL)
  - `sprite_constants.asm`: `SPRITE_FOLLOWER`
  - `sprite_data_constants.asm`
  - `script_constants.asm`
  - `menu_constants.asm`
  - `sprite_anim_constants.asm`
- **WRAM:** `wFollowerSpriteID`, `wFollowerPartyNum`, `wFollowerNextMovement`, `wFollowerFlags`, `wFollowerMovementQueueLength`, `wFollowMovementQueue` (5 bytes), `wFollowerState`. Mystic's layout is `ram/wram.asm:135,136,2923,2941,2945,2946,3044`. Keep all of them out of the saved block if possible. If a byte has to persist (in-ball state across save/load), the v1.0 save break covers it.
- **Engine:**
  - `engine/events/follower.asm` (new; interaction table, emotes, `FollowerScript`)
  - `engine/overworld/map_objects.asm` (the follower movement function and step queue)
  - `player_object.asm` (`FollowObjTemplate`, spawning, `CopyDECoordsToMapObject`)
  - `overworld.asm`
  - `events.asm`
  - `scripting.asm`
  - `movement.asm`
  - `npc_movement.asm`
  - `player_movement.asm`
  - `map_objects_2.asm`
  - `map_setup.asm`
  - `data/maps/setup_scripts.asm` and `setup_script_pointers.asm` (new map-setup commands)
- **Home (ROM0):**
  - `home/map_objects.asm` +33
  - `home/map.asm`
  - `home/menu.asm`
  - `home/trainers.asm` (the follower steps aside for trainer approach)
  - the `"Follower Script Home"` section (the `_FollowerScript: farjump FollowerScript` trampoline)
  
  See §4.1. All of this must be squeezed or moved to ROMX.
- **Script macros:** the `macros/scripts/events.asm` additions and `macros/scripts/text.asm`.
- **Build:** `main.asm` includes, a `layout.link` section, the Makefile object `gfx/following_sprites.o`, and `gfx/lz.mk` rules.
- Use a **single placeholder sprite** for every species at first (see Phase E).

**Do not port** the parts of the base commit that replace the party menu icons:
- `engine/gfx/mon_icons.asm`
- `data/pokemon/menu_icons.asm`
- `data/icon_pointers.asm`
- `constants/icon_constants.asm`
- `gfx/icons.asm`
- `data/pokemon/menu_mon_pals.asm`
- `gfx/stats/party_menu_ob.pal`
- `engine/menus/naming_screen.asm`

Eclipse keeps its own 560-file `gfx/icons/` set. Also skip `7f839a4a9` (party-screen X_FLIP) for the same reason. The one exception: if `follower.asm` reads a palette from `menu_mon_pals`, point it at the follower palette table from Phase D.

The reference also removed unreferenced ROM0 routines (`PlaceBCDNumberSprite`, `Function3ed7`, `Function3efd`) to make room. Eclipse's dead-code pass may already have removed them; check before relying on the space.

### Phase B — Interactions and script commands
- `7818c6e3d` More Follower Interactions: the interaction table and its scripts.
- `8f547e405` Fix follower event script nick.
- `c5cdf9a2f` The `Script_appearfollower` bank fix. **Must be included**: without it, `appearfollower` never worked.
- `ec6c3afd6` `jump_in_place` movement, used by the emotes.

The new script commands are `freezefollower`, `unfreezefollower`, `getfollowerdirection`, `appearfollower`, `stowfollower`, `silentstowfollower` and `savefollowercoords`. The script-command table has a fixed index space, so check that the CSE table has room for them.

**Rewrite the interaction table for Eclipse** (see §4.6). Don't copy Mystic's table, which keys on Mystic's landmarks and events.

### Phase C — Poké Ball in/out
- `482f93aae` AddPokeballSprite
- `d8d0645c3` OW Pokeball close animation
- `56d13f7d4` Follower Pokeball is Emote
- `b48a2e016` Speed up pokeball animation
- `11e497523` PokeBallEmote
- `534b320d6` CheckActiveBall, NewballAnim, GetFirstAlive off-by-one fix

These touch `data/sprite_anims/oam.asm`, `framesets.asm` and `engine/sprite_anims/core.asm`. Fill from Mystic:
- `47421bf12`: the stowed follower used the wrong Poké Ball palette.
- `2e37d522b`: the Poké Ball palette changed to the mon's palette after a successful catch.
- `913ec07c6` (RED balls in the trainer HUD): optional, cosmetic.

### Phase D — Palettes and shiny
- `8edea4400` Shiny OW Mons & use party pals; `gfx/following_palettes.asm`.
- `d3de1f655` Poliwag RED→BLUE.
- From Mystic, `e2fe2ad26` and `3b45b22d0` (normal and shiny following palettes). Take only the follower half, not the MenuMon half.

Eclipse's shiny check is "all DVs ≥ 12" (`engine/gfx/color.asm:8`). The follower shiny palette must use the same routine.

### Phase E — Sprites
See §3.

### Phase F — Movement gaps (Mystic only)
The reference doesn't handle these; Eclipse needs all of them:

| Mystic commit | Fixes |
|---|---|
| `eaf6d1baf` | Follower ledge sound and **running support**. Eclipse has B-button running (`player_movement.asm:322`). |
| `7d9f8540d` | Follower ledge speed. |
| `0863ecdb3` | Follower `jump_in_place` plus ledges. |
| `c91aeff9a` | **Stow the follower on the bike.** |
| `6c445f03a` | Don't make the follower invisible when an NPC bumps it. |
| `7c5e936fd` | Talking to the follower glitched it. |
| `2d1a23c84` | The follower Unown (form lookup). |
| `ef515cf39` | TODO note: the wrong follower shows after a no-whiteout loss (the rival or Red). **Unfixed in Mystic too.** Resolve it here by refreshing the follower from `GetFirstAlive` after the battle. |
| `26b5e9734`, `54c116ef0` | "More follower fixes" / "OW following mon fixes". Read the diffs and take only the follower hunks; these commits mix in species work. |

Eclipse-only movement that neither source handles, so each needs its own test:
- ice sliding (`STEP_ICE`)
- skating (`PLAYER_SKATE`)
- Surf/Whirlpool/Waterfall entry and exit
- Fly, Dig, Escape Rope and Teleport
- the travel-unlock warps (ORANGE PASS, cross-region Fly)
- S.S. AQUA boarding
- the Silver Cave respawn reset

### Phase G — Map scripts
- Reference: `1e0f965fd` Cherrygrove, `e4b148cca` Elm's Lab, `6c2597308` additional, `85b45f1df` finish (25 maps), `a6330530e` Pokémon Center and Mr. Pokémon. In the base commit: BlackthornGym2F, BrunosRoom, BurnedTowerB1F, IcePathB1F, LakeOfRage, Route34.
- Mystic: `d8fa23244` Port Follower Map Script Updates, `9bef7e881` (the rival shoves you through your follower in New Bark), `7b0258d63` (the Falkner Gym guide pushes you out), `b83ec03c5` (stop Red's follower before emotes), `fa08d5103` (Burned Tower ghosts use following sprites; optional).
- `75cd41d39` "Bad Daycare hack": **don't port it as-is.** Find the bug it works around (the follower's party slot was deposited) and fix it properly by refreshing from `GetFirstAlive` on party change.

Then the **Eclipse audit** (§4.5).

## 3. Sprites

Format: 16×96 PNG with six 16×16 frames, converted to `.2bpp.lz`. Mystic's `gfx/following/*.py` reorders frames (`frame_order = [4, 3, 1, 5, 2, 0]`); use it if a sheet comes from another source. About 384 B raw per sprite; the full set is well under 170 KB, and the ROM has about 449 KB free.

- Copy from `../MysticCrystal/gfx/following/` (446 PNGs). After normalizing names, it covers about 268 of Eclipse's ~310 `gfx/pokemon/` species. Name mismatches to map: `mr__mime`, `porygon_z`, `sirfetch_d`, and Unown, which is one file per letter in Eclipse.
- **Missing, needs art:** (outcome: see Phase E. Seven drawn 2026-11-08; Dragonite (Kanto) keeps Dragonite's sheet; Raichu (Orange) and Dudunsparce came from Mystic.)
  - Annihilape
  - Cursola
  - Corsola (Kanto)
  - Dragonite (Kanto)
  - Farigiraf
  - Ursaluna
  - Wyrdeer
  - Raichu (Orange)
  - Surfing Pikachu
  - Dudunsparce (check Mystic's "Tropius and Dudunspars" commit first)
  - any seasonal forms that land later
  
  Sweep `gfx/pokemon/*/` and `docs/assets` for pre-drawn art before making placeholders.
- Mystic fixed some broken sheets: `8d1e6f7af` frame order, `40851ea9d` Lucario/Munchlax/Pikachu, `9c1892b80` Marshtomp, `3b169050e` Infernape. Take the PNGs from Mystic's tip so these are already included.
- The pointer table is indexed by **species index including variants** (`NUM_POKEMON_AND_VARIANTS`) and looked up with `GetPokemonIndexFromID`, never the runtime ID. The reference indexes by 8-bit species, so this is a rewrite.

## 4. Eclipse-specific constraints

### 4.1 ROM0
ROM0 is the ceiling: only the gap above `Home` counts, and the debug build runs out first (memory: `reference_rom0_is_the_ceiling`). Budget for the follower's home code:
- Keep only what must be in ROM0 (the `_FollowerScript` trampoline and anything called with a different ROMX bank paged in).
- Move the rest of the `home/map_objects.asm` / `home/map.asm` / `home/trainers.asm` additions into ROMX behind `farcall`.
- Measure the release **and** debug builds after Phase A.

Branch 11 (link removal) frees about 650–700 B of ROM0. If it lands first, this gets much easier.

### 4.2 OAM and the 10-sprites-per-line limit
Weather owns OAM 0–11 (`reference_weather_oam_reservation`). The follower adds four more 8×16 objects on the player's rows. Test snow and sandstorm with the player and follower side by side next to an NPC, and accept or reduce particle density.

### 4.3 Object structs and VRAM sprite slots
- The follower permanently takes one of the 13 object structs (`NUM_OBJECT_STRUCTS`) and one VRAM sprite slot.
- Check crowded maps for overflow: Orange Islands, Battle Tower, Goldenrod Dept. Store, and the planned expanded Johto maps.
- Vanilla escort scenes (`follow` / `stopfollow`) appear in 21 maps, among them New Bark, Cherrygrove, Violet, Route 32, Mahogany, the Rocket Base, Lance's room, Hall of Fame, Battle Tower and Cerulean Base 3. Each one should `stowfollower` / `appearfollower` around the escort.

### 4.4 16-bit indexes and variants
All species checks (interaction table, sprite and palette lookup) go through `GetPokemonIndexFromID` (memory: `reference_16bit_id_index_system`). The table's `dw species` field holds the **index** constant.

### 4.5 Map audit
60 Eclipse maps have 126 `applymovement PLAYER` cutscenes. Not all of them need edits. The follower trails automatically, but these do:
- Scenes where an NPC walks into the tile behind the player: `freezefollower` plus a reposition, or `stowfollower`.
- Scenes where the player is pushed or warped by a script.
- Eclipse-only maps and scenes: Orange Islands (M3), the S.S. AQUA Rocket arc (branch 79), the Silver Cave Red rematch, the Safari tutor office, Valencia, and the travel-unlock gates.

Method: grep every `applymovement PLAYER` / `follow` / `warpfacing` / `teleport`-style script, then play-test each through the SameBoy regression harness (`docs/regression/`).

### 4.6 Interaction table
Copy the **format** from the reference (the `interaction` macro: species / type-in / type-out / landmark / map / time / status / event / script). Fill it with Eclipse content:
- Keep the status rows (sleep, poison, burn, freeze, paralysis).
- Use Johto/Kanto rows where the landmark still exists in Eclipse.
- Add new rows for Orange Islands landmarks, seasonal weather (snow/sun), and Silver Cave.
- Event flags are full (M3 memory), so the interactions can only *read* existing events, never add new ones.
- Map text keeps the 18-character line limit.

**Outcome:** done in Phase B (`7e0d234fd`); checked against the points above on 2026-11-09 (status rows, Orange Islands, Silver Cave and all six weathers, only `EVENT_CLEARED_SLOWPOKE_WELL` read, every line within 18 characters). No time-of-day rows yet. Tested by `followers.follower_interactions`: 13 cases (default, poison, poison beating a species row, species/type with landmark or map, event set and clear, Shamouti, Silver Cave, snow/rain rows), with expected text read from the asm. The test found 18 reactions with `text_ram` followed by `line`, which jumped into WRAM; fixed in `1321aa614`, and `followers.static_text_command_then_char` now guards the whole codebase.

### 4.7 Saves
v1.0 is already a fresh-save release, so any saved follower state is fine. Bump `SAVE_CHECK_VALUE_1/2` once, at the very end of the v1.0 save-break window (`docs/v1_roadmap.md`), not here.

## 5. Acceptance checklist
- [ ] Release and debug builds pass; no new `optimize.py` warnings; ROM0 measured for both builds.
- [ ] The follower is the first non-fainted party mon. It refreshes after: a party reorder, a faint, a no-whiteout loss, a day-care deposit, a PC deposit and a trade.
- [ ] Walk, run, bike (stowed), surf (stowed), ledge hops, ice, skating, warps, doors, connections, Fly, Dig, Escape Rope, Teleport, Whirlpool and Waterfall all work.
- [ ] Trainer approach, escort `follow` scenes and every audited cutscene behave.
- [x] Talk to the follower: the status interactions, location interactions and the generic fallback all work. (`followers.follower_interactions`, 13/13 after `1321aa614`.)
- [ ] Poké Ball in/out animations use the right ball palette. Shiny followers show the shiny palette. (Phase D: palette data verified; needs a by-eye pass with real sprites.)
- [ ] Weather with a follower shows acceptable flicker.
- [ ] Unown, the regional variants and the Eclipse-only species show the right sprites.

## Double happiness

The active follower (`GetFollowerMon`: chosen, not an egg, not fainted) gains double happiness. Done in `ChangeHappiness`, so it covers levels, vitamins, steps, haircuts, grooming, photos, the restaurant and the tutors; losses are unchanged and the gain still caps at 255. The nickname bonus and the Friend Ball set fixed values, not gains, so they are untouched. Test: `follower_double_happiness`.

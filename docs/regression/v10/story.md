# v1.0 regression: story events (S.S.AQUA arc, Wild Hunt, Route 30)

HEAD `1fb549fdf` vs `v0.9` (`2f2a153e6`). Tests: `docs/regression/harness/v10_story.py`
(fixtures `story_raid` = debug party + the first Olivine boarding, `story_arc_done` = that + Petrel beaten + docked).
Evidence: `docs/regression/v10/story/` (screenshots, plus the static scripts `textlen.py`, `static.py`, `bfs.py`).

## Game bugs

### 1. Losing to the lazy sailor leaves a fainted party and auto-wins the rest of the raid (medium)
- **Repro:** on the raid voyage, talk to the lazy sailor (GRUNTM_41, NNW/NNE/NE cabins) and lose.
- **HEAD:** there is no whiteout. The party stays at 0 HP, the sailor counts as beaten (`EVENT_FAST_SHIP_LAZY_SAILOR` is set and the B1F blocker opens), and the raid goes on with the bed refusing to heal. The next trainer battle, Petrel, ends at once with `wBattleResult` = 0 (win) while our HP is 0. The player then gets Petrel's escape, the reunion and the Metal Coat without fighting. Screenshots: `lazy_sailor_loss.png`, `lazy_loss_then_petrel_autowin.png`.
- **Root cause:** `maps/FastShipCabins_NNW_NNE_NE.asm:85` uses `reloadmap`, not `reloadmapafterbattle`. Only `reloadmapafterbattle` checks for LOSE and jumps to `Script_BattleWhiteout`. Vanilla and v0.9 hid this with `special HealParty` on the next line, which 20adb94b6 removed ("no healing on the raid").
- **Fix (verified):** change line 85 to `reloadmapafterbattle`. Built in `scratchpad/wt/story-fix`: a loss now whites out to the Vermilion pier, Koga's blackout scene closes the raid, and the win path is unchanged (`story_lazy_sailor_grunt_*` both pass).

### 2. Janine's nod misreads a full bag as a whiteout (low)
`maps/FuchsiaGym.asm` (after `.AfterTM`) uses `EVENT_GOT_METAL_COAT_FROM_GRANDPA_ON_SS_AQUA` to mean "saved the ship". The Metal Coat is not given if the bag is full (`SSAquaMetalCoatAndDocking` → `.NoRoom`), and the grandpa is hidden at docking. A player who saved the ship with a full bag therefore hears "fought until you dropped" and loses the Metal Coat for good. Losing the coat is vanilla; the wrong line is new.
**Fix:** set a dedicated "saved the ship" flag in the Petrel win path (a free `const_skip` slot in the phone block) and check that flag instead.

## Tests (HEAD / v0.9)

Final full HEAD run: 21 pass, 1 fail (bug 1), report `reports/20261105-144821-de6bac77d41e`. On the fixed ROM (`scratchpad/wt/story-fix`) both lazy-sailor tests pass.

| Test | Checks | HEAD | v0.9 |
|---|---|---|---|
| story_raid_starts_on_first_olivine_run | first Olivine boarding sets RAID, port scene 3, blackout → VERMILION_PORT, Petrel shown | pass | n/a (no raid) |
| story_petrel_walks_up_from_each_column | row 29 at x=0/5/9: Petrel walks over, EXECUTIVEM_5, Smoke Ball, reunion at (2,19), Metal Coat, no re-trigger | pass | n/a |
| story_arc_win_closes_out / _texts | after docking: Koga raid-over text, every close-out flag, port scene 0, B1F NOOP, blackout VERMILION_CITY, Koga gone on reload | pass | n/a |
| story_petrel_loss_whiteout | loss → Vermilion pier, Koga "took the ship", raid closed, no Metal Coat, party healed | pass | n/a |
| story_hold_grunts_fight_once | GRUNTM_39/40 fight once each (reused Jeff/Fritz flags), then text only | pass | n/a |
| story_hold_grunt_loss_whiteout | grunt 1 spots you from 3 tiles; loss → pier, raid closed | pass | n/a |
| story_lazy_sailor_grunt_win | GRUNTM_41: no heal, leaves, B1F opens | pass | n/a |
| story_lazy_sailor_grunt_loss | a loss must white out | **FAIL (bug 1)** | heals (code) |
| story_raid_bed_refuses | bed refuses during the raid | pass | n/a |
| story_reboard_after_arc | Vermilion (Wed) → Olivine and Olivine (Mon) → Vermilion: no raid, Petrel and grunts gone, row 29 quiet, bed heals and docks | pass | n/a |
| story_janine_nod_after_save | praise line with the Metal Coat, fall line without it | pass | n/a |
| story_vermilion_checkin_matrix | 17 paths: first-run refusal, Mon/Fri refusals, Wed yes/no/no ticket, OLIVINE/VALENCIA/CANCEL/B menu, Orange Pass yes/no, pass before the first run, pass with no ticket; walk-up and talking to the sailor; re-trigger after each refusal | pass | n/a (old flow) |
| story_olivine_needs_league | pre-HOF sailor blocks the gangway; no raid | pass | error (no RAID flag) |
| story_saffron_foreshadowing | 3 NPCs switch lines on EXECUTIVEM_3 | pass | fail (intended: new lines) |
| story_gate_visibility_by_hunt_state | gate in each state (below), and the mid-hunt usher to Route 38 (35,8) | pass | error (flag renamed) |
| story_gate_morty_starts_hunt | NO loops back, YES starts the hunt and warps to Route 38 | pass | pass |
| story_route39_scene_by_hunt_state | hunt scene only while ENGINE_WILD_HUNT and leader unfought | pass | fail: scene 0 (hunt) with no hunt, which is the bug b0d6082cc fixed |
| story_dance_theater_by_hunt_state | girls hidden only during the hunt; gentleman/granny hunt lines | pass | fail (intended: new lines) |
| story_route30_hana_once | KIMONO_GIRL HANA fights once, then text | pass | n/a |
| story_icepath_yuki_once | Yuki fights once, then text | pass | pass |
| story_route30_youngster_season | directions before the egg, season line after | pass | fail (intended) |

Gate states (from flags after the map callbacks ran, plus a walk from x=8 to x=1):

| State | Rangers | Morty + girls | Officer | Passable |
|---|---|---|---|---|
| before Pryce | shown | hidden | hidden | no (rangers) |
| Pryce beaten, hunt not started | hidden | shown | hidden | no (Morty must be talked to) |
| during the hunt | n/a | n/a | n/a | Morty ushers you back to Route 38 on entry |
| after the hunt | hidden | hidden | shown | yes |

## Static checks (all maps changed since v0.9)
- **Text width** (`textlen.py`; `<PLAYER>`/`<RIVAL>`/`<PLAY_G>` count as 7, `#` as 4): no new or changed string is over 18 characters. Six older over-length strings remain in changed files, all present in v0.9: `FuchsiaGym.asm:396` "the shadows' secrets." (21), `BlackthornGym1F.asm:343`, `CeruleanGym.asm:309`, `OaksLab.asm:177`, `VermilionGym.asm:232`, `ViridianGym.asm:227` (19 each). The `text_ram` concatenations in SilverCavePokecenter1F (name + " is") fit.
- **Jump targets:** the HEAD build links, so every `sjump`/`scall`/`jumptext` target exists.
- **Flags** (`static.py`): every flag that is set or cleared is also read, except vanilla item-ball flags and set-only "beat" flags (`EVENT_BEAT_SAILOR_STANLY` is now set and never read). `Route30.asm` has 14 object consts for 16 objects. `ROUTE30_POKE_BALL3` labels a fruit tree, which is harmless because no script uses it.
- **Parties:** Hana (Eevee 49, Leafeon 49/51) and Yuki (Glaceon 49/51) moves are all legal from the level-up list, TM/MT, or Eevee's TM Shadow Ball. GRUNTM_39-41 and EXECUTIVEM_5 are TRAINERTYPE_NORMAL, so their moves come from the learnsets.
- **Hana** at (22,42) can be reached only with Surf (BFS over collision).

## Suspicious, not confirmed as bugs
- **Pre-Pryce gate:** before Pryce the Route 38 gate cannot be crossed at all, because the rangers block both rows. v0.9 does the same, so it is presumably design (Olivine reached another way). Worth a sentence to confirm.
- **Row 29 triggers:** the ten always-on row-29 coord events run a script on every later voyage. The script just ends, but the player stops for a moment on each crossing. Cosmetic.
- **Herd leader:** `EVENT_FOUGHT_WILD_HUNT_TAUROS_17` is set before the battle. Losing to or running from the herd leader removes him for good. The hunt can still be finished at the barn, so this is not a soft-lock.
- **Save layout:** the HANA flag shift is covered in `audit.md`. Separately, the gate scene var uses the spare link-room byte (`wRoute38EcruteakGateSceneID`). A nonzero leftover value there is harmless because RunSceneScript ignores out-of-range scene ids.

## Not testable headlessly (for shasocastris's playthrough)
- Petrel's walk along row 28: whether he clips the captain or girl sprites or walks through walls, the fade to black for the Smoke Ball, and the music swap.
- The look of Koga's walk down and back, the ranger's brown palette, and whether the check-in menu box (9,4)-(19,TEXTBOX_Y-1) overlaps the text box.
- Real battle difficulty of Petrel L59-61, the grunts L56-58 and Hana with no healing on board. The harness forced wins and losses.
- The full Wild Hunt loop (Tauros 1-16, whiteouts mid-hunt and walking back in from Olivine). Only the scene and visibility states were tested.
- Reaching Hana by Surf in real play, and her line art and text in the box.

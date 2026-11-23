# Suicune chamber session → Alph/Unown/Suicune session

Written 2026-11-18 by the session that built the Suicune puzzle chamber, for the
session that owns `feature/alph-unown-suicune` (docs/alph-unown-suicune-refactor-handoff.md).
Both sessions have been committing to the same branch in the same working tree.
**From here on, the Alph session owns all of it; this session stops editing the branch.**

## What went wrong

`7c1c1e886` (Kurt / SAMUEL's MAIL) staged all of `constants/event_flags.asm`,
which picked up this session's uncommitted rename of three Suicune item-room
flags. The map that uses them was still on the old names, so `7c1c1e886` alone
doesn't build; `7eef5f50a` fixed it. There was no lost work, only one broken
commit in history.

Cause: two sessions, one working tree, whole-file staging of a shared file.

## Rules for a shared working tree (if it ever happens again)

1. Before every commit, run `git status` and `git diff` on every file you stage.
   For hot shared files (below), stage hunks (`git add -p`) or check
   `git diff --cached` contains only your hunks.
2. Re-check `git log -1` right before committing; HEAD moves under you.
3. Build at the exact tree you commit (`make` after staging, with unrelated WIP
   stashed in a scratchpad worktree, not `git stash`; shasocastris commits from his IDE).
4. Never stage shasocastris's WIP: `data/pokemon/base_stats/celebi.asm`,
   `data/pokemon/evos_attacks_johto.asm`, `maps/ElmsLab.asm`.

Hot shared files on this branch: `constants/event_flags.asm`,
`constants/trainer_constants.asm`, `data/trainers/parties.asm`,
`maps/RuinsOfAlphOutside.asm`, `constants/map_constants.asm`,
`data/maps/{maps,attributes,blocks,scripts}.asm`, `main.asm`.

## What this session built (all committed)

| Commit | What |
|---|---|
| `aafbea13e`, `f7647984c` | `gfx/unown_puzzle/suicune.png` (right frame of the intro jump, light margin + corner blocks) |
| `4e690ffbb` | `engine/games/unown_puzzle.asm`: fifth puzzle pointer + INCBIN |
| `0c7c33d25` | `UNOWNPUZZLE_SUICUNE` (= 4) in `constants/script_constants.asm` |
| `865f7783e` | `RUINS_OF_ALPH_SUICUNE_CHAMBER` + `_ITEM_ROOM` (DUNGEONS 105/106), Outside warp 12 at (2,9), Scientist MAX at (2,10), trainers GRUNTM_42 / SCIENTIST NIKOLA / MURRAY, floating sections "Map Scripts 31" and "Enemy Trainer Parties 4" |
| `8e3885979`, `ccb6815b8` | `RUINS_OF_ALPH_SUICUNE_WORD_ROOM` (DUNGEONS 107), `TILESET_SUICUNE_WORD_ROOM` (26, metatiles/attrs in Tileset Data 8), own `.ablk`; pit → Inner Chamber warp 6 at (2,22) |
| `7eef5f50a` | Item room balls: MYSTIC_DEW, SACRED_ASH, AMULET_COIN, BRIGHTPOWDER (flags `EVENT_PICKED_UP_<ITEM>_FROM_SUICUNE_ITEM_ROOM`) |

Your commits `69cc63964` (scientist-based tree seal) and `d99103e96` (Eviolite)
sit on top of this and were play-tested together with it (below).

Flow: Outside tree at block (1,5) is `$62` until Erwin/JayJay/Carl/Kip are beaten
→ MAX → chamber (grunt, Nikola, Murray; hidden by
`EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS`) → puzzle sets `EVENT_SOLVED_SUICUNE_PUZZLE`
→ item room → word room ("IN OUR ABSENCE / THE NORTH WIND / SHALL GUARD THEM /
WHEN THE BELL / RINGS CLEAR WE / SHALL RETURN") → Inner Chamber → shrine fight.

## Uncommitted, needs a decision

- `maps/PlayersHouse2F.asm`: debug-only stair warp to the Suicune chamber
  (`IF DEF(_DEBUG)`, marked `TODO(shasocastris): TEMP`). shasocastris is using it to test.
  **Do not commit; revert when shasocastris says he's done** (`git checkout maps/PlayersHouse2F.asm`).

## Tests and helpers (untracked, listed in docs/helper_scripts.md)

- `docs/regression/harness/v10_suicune.py`
  - `-k suicune_chamber`: seal → MAX → chamber trainers → real puzzle solve →
    four balls → word room → pit to (2,22). PASSES on `7eef5f50a`-equivalent tree.
  - `-k suicune_shrine`: from that solve, the shrine fight with 25 Unown,
    26 Unown, and 26 + full bag (Eviolite ball fallback, then pickup). PASSES on `d99103e96`.
  - Always pass `-k` (it imports `v10_overworld`, whose suite runs otherwise) and `--jobs 1`.
  - It has its own `fight()`: `v10_overworld._battle` misses the end of
    script-started battles, and the debug lead runs out of PP after 4 fights.
  - `SCENE_*` constants don't resolve through `consts.py`; compare scene indexes.
- `docs/word_room/make_word_room.py`: regenerates the word room metatiles/attrs/ablk from text.

Run `-k suicune_chamber` and `-k suicune_shrine` after any change to the Ruins
Outside callback, the event flag layout around 355-365, or the shrine script.

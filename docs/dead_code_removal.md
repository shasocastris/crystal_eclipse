# Dead code removal — branch `69-dead-code`

**Branch:** `69-dead-code`, cut from `core` at `75f908885`.
**Nature:** pure size and noise reduction. **No behaviour change is intended anywhere.**

Six commits. `utils/unreferenced.py` went from **215 unreferenced symbols to 65**;
**1,517 lines** removed across 65 files. ROM free space rose to 471,255 bytes (22.47%).

---

## 1. What was removed

| Commit | What | Count |
|---|---|---|
| `65b4abcfe` | Four wholly-unreferenced files | 4 files |
| `7796979cc` | Descriptions + battle animations for **removed moves** | 64 blocks / 524 lines |
| `4ee3e327a` | Unreferenced text (egg/breeding, carpet/poster) | 24 blocks |
| `b7570ca54` | Map scripts and text (signs, removed NPCs, 2 Swimmers) | 36 blocks / 26 maps |
| `982661293` | Second-order items in maps, mobile, gfx, audio | 7 blocks |
| `ae7641bfc` | Engine routines | 34 blocks |

**The move data is the interesting one.** 33 descriptions and 31 animations belonged to
moves this hack no longer has — `POUND`, `DOUBLESLAP` and `VICEGRIP` are not move
constants any more, leftovers from the branch-39 rework. They *look* like false positives,
because descriptions and animations are reached through indirect tables the tool cannot
follow; they are not, because those tables list only surviving moves.

---

## 2. What is deliberately NOT removed

**65 symbols remain, and most are not deletable.** The largest group is symbols that are
unreferenced *by name* but reached by **falling through** from the block above. Deleting
those breaks their neighbour.

The clearest example, from `engine/tilesets/tileset_anims.asm`:

```asm
ScrollTileRightLeft:
	...
	and %1000
	jr z, ScrollTileRight
; fallthrough
ScrollTileLeft:          ; <- "unreferenced", but this is the fallthrough target
```

Roughly 55 of the 65 are this shape. The rest are in `home/` (see below).

### `home/` — 21 symbols, attempted and reverted

The home-bank pass **fails to build** and was reverted:

```
error: Undefined symbol `WriteVCopyRegistersToHRAM.outerLoop2`
```

Home routines share local labels across block boundaries — one block's `.loop` is
referenced from another. Any home cleanup has to be done **per symbol, by hand**, checking
local-label usage first. It is also the most valuable area (ROM0 is the scarcest space in
the project, currently `$00ef` free), so it is worth doing carefully rather than not at all.

---

## 3. ⚠️ Five hazards this pass hit, all of which built or looked fine at first

Anyone continuing this work should read these; each cost a failed build or worse.

1. **A block does not end at the next label.** Deleting label-to-next-label swallowed a
   `SECTION "Copyright", ROMX` directive and a `DEF HALF_HEIGHT EQU ...`, both of which sat
   between two labels. A block ends at the next **column-0 directive** — label, `SECTION`,
   `DEF`, `INCLUDE`, `MACRO`.
2. **Local labels are column-0 too.** `.loop` starts in column 0, so the rule above must
   *exclude* lines starting with `.` or the locals get orphaned onto the previous parent
   and collide (`PlaceVWFString.loop already defined`).
3. **`jr z, Label` is not a terminator.** A fallthrough guard that treats any `jr`/`jp` as
   unconditional will happily delete a fallthrough target. Check for a condition code, and
   honour `; fallthrough` comments.
4. **Deleting leaves jumps pointing at the next line.** Every pass added new
   "Pointless jumps" warnings from `jr X` immediately above `X:`. These must be removed
   (or turned into a conditional return) to keep `optimize.py` at baseline.
5. **A verification tool that "passes" may not have run.** `farcheck.py` takes the `.sym`
   as an argument; invoked bare it prints a usage line and exits **0**. Piped through
   `wc -l` that reads as a near-clean result. Any check whose failure mode is "no output"
   should be confirmed to have actually looked at something.

Freeing this much space also **re-packed 73 sections**, so the Correction 9 audit applies.

---

## 4. Verification already done

- Both ROMs build clean.
- `optimize.py` **608**, below the 612 baseline. The only category difference is one
  *fewer* `a == 1` warning; no new warnings of any kind.
- `farcheck.py` **82 findings — 56 cross-bank references and 26 `rst` suggestions.**
  Verified unchanged by building `core` at `75f908885` in a scratch worktree and diffing:
  once line numbers and output order are normalised, the finding *set* is identical.
  (Note `farcheck.py` **requires** the `.sym` as an argument — run bare it just prints its
  usage line and exits 0, which is easy to mistake for a clean result. An earlier draft of
  this doc claimed "27 cross-bank references" for exactly that reason.)
- `check_season_comments.py` clean.
- Save canaries unmoved: `wEventFlags $da66`, `wSeason $dbf0`, `wVisitedSpawns $dc01`,
  `wDigWarpNumber $dc09`.
- Re-pack audit after the 73-section move: **80** battle-anim jumptable entries, **846**
  map attribute/blocks/scripts pointers, and the `Moves` / `BattleAnimations` /
  `MoveDescriptions` indirect tables all still resolve.
- Every symbol cross-checked with an independent `grep` before deletion — the tool reads
  the `.sym` and cannot see indirect references, so it is evidence, not proof.

---

## 5. ⚠️ What needs testing in BGB

Nothing here should change behaviour, so **this is a hunt for things that silently broke**.
Static checks cannot catch a routine that is reached in a way the tool could not see.

**Play-tested 2026-08-26 (shasocastris) — no errors found:**

- [x] **Tile animations** — water/flower/whirlpool. The highest-risk item, since
      `tileset_anims.asm` lost `ScrollTileUp` and its neighbours are fallthrough-linked.
- [x] **Bill's PC**, including releasing.
- [x] **Battle animations** across a spread of moves — 31 were deleted.
- [x] **Time-of-day changes** — `time.asm` lost a block beside `UpdateTimeRemaining`.
- [x] **Menu screens** — covers the `dma_transfer.asm` removals in practice.
- [x] **Move descriptions**, **Pokédex**, and several of the 26 edited maps.

That clears every area where *code* rather than data was removed, which is where a silent
break would have shown up. Treat the pass as verified.

**Still unexercised, all low risk:**

- Trade animation, if it is reachable at all in this hack.
- The remaining edited maps — the signs removed were already absent from their event
  tables, so this is confirmation rather than risk.
- Mobile / trainer rankings — stubs behind an unconditional `ret`, inert by construction.

---

## 6. If continuing

Order by value:

1. **`home/` (21)** — most valuable, needs per-symbol hand work; ROM0 is the scarcest space.
2. **The ~30 engine leftovers** — mostly fallthrough targets; verify individually.
3. Re-run `python3 utils/unreferenced.py crystal_eclipse.sym` after any pass; removals
   expose second-order dead code, so it converges over several rounds.

Commit after **every** successful batch. A failed batch then costs one `git checkout`
rather than the whole pass — this was learned the hard way here.

# Branch 24 `24-reorder-moves`: research report

Base: `core` @ 01727c11f. Branch `24-reorder-moves` has no commits of its own: 0 ahead of core, 618 behind (merge-base b427df18d). Everything here is read from core. [V] = verified by reading code or running scripts. [I] = inferred.

## 0. Current state [V]

- The move constants have **no value gaps.** `constants/move_constants.asm` uses plain `const` with no `const_skip`. The hex comments are stale vanilla IDs. Real values: `NUM_ATTACKS = 263 ($107)`, `GEN1_MOVES = 141 ($8d)` (= STRUGGLE), and the last 8 moves are ≥ $100.
- Per-type counts (type, then P/S/St = Physical/Special/Status), 263 total:

| Type | Count | P/S/St |
|---|---|---|
| NORMAL | 78 | 25/6/47 |
| FIGHTING | 18 | 15/2/1 |
| FLYING | 12 | 7/4/1 |
| POISON | 8 | 3/3/2 |
| GROUND | 9 | 6/2/1 |
| ROCK | 8 | 5/2/1 |
| BUG | 10 | 8/1/1 |
| GHOST | 9 | 2/3/4 |
| STEEL | 10 | 9/1/0 |
| CURSE_TYPE | 1 | 0/0/1 (CURSE) |
| FIRE | 9 | 3/4/2 |
| WATER | 14 | 4/9/1 |
| GRASS | 16 | 5/6/5 |
| ELECTRIC | 8 | 3/4/1 |
| PSYCHIC | 17 | 1/7/9 |
| ICE | 12 | 3/5/4 |
| DRAGON | 7 | 2/5/0 |
| DARK | 7 | 6/1/0 |
| FAIRY | 10 | 3/4/3 |

## 1. What depends on move ORDER/VALUE

### A. Positional tables: must be permuted in lockstep [V]

| File | Form | Notes |
|---|---|---|
| `constants/move_constants.asm:8-272` | `const` list | `GEN1_MOVES` at :150, `GEN2_MOVES` :273, `NUM_ATTACKS` :275 |
| `data/moves/moves.asm:15-19, 25…, 170` | `indirect_table` split by `GEN1_MOVES` into SECTIONs "Moves Gen 1"/"Moves Gen 2" | Each `move` line carries a `;NAME` comment, and all 263 match the constants |
| `data/moves/names.asm:2-266` | `list_start`/`li`, `assert_list_length NUM_ATTACKS` | No per-line name comment, so it is positional only |
| `data/moves/descriptions.asm:1-5` | `indirect_table`, two pointer lists `MoveDescriptionsGen1/2` | No duplicate description pointers. Text bodies are label-referenced, so their order does not matter |
| `data/moves/animation_pointers.asm:11-18` | `indirect_table 3, 0` (starts at index 0) | Uses `BattleAnimationsGen1` (`animations_gen1.asm:1`, 142 `anim_ptr` including `BattleAnim_Dummy` for NO_MOVE) and `BattleAnimationsGen2` (`animations_gen2.asm:1`, 122) |

- `anim_ptr` stores a bank per entry (`animation_pointers.asm:1-9`). An entry can therefore point into either gen file, and the animation **bodies need not move**. Only the pointer lines move.
- If the split index stays at 141, every table's Gen1/Gen2 byte size stays the same, so there is **no bank-layout churn**. Gen1 is "Moves Gen 1" $34e = 141×6; "Moves Gen 2" is $2dc = 122×6.

### B. Code that depends on values

- **`engine/link/link.asm:2483` `cp STRUGGLE + 1 / jr nc, .move_too_new`** [V]. This is the Time Capsule "is it a Gen 1 move" check. It assumes indexes 1..STRUGGLE are exactly the Gen 1 moves. After a type sort, STRUGGLE would be about $4e and the check would be wrong. It is already semantically broken anyway: `link.asm:835-850` sends the low byte of the CSE index, and KARATE_CHOP=1 here is not vanilla's 2. So it is already incompatible with real RBY. Delete it (branch 11), or replace it with an explicit list.
- **`engine/battle/move_effects/metronome.asm:38-66`** picks a random value in 1..NUM_ATTACKS. Contiguity is preserved, so it is safe [V].
- **`if HIGH(MOVE)` codegen sites.** Equality-only, but code size changes if a move crosses $100. Sites: core.asm:739-748 (KARATE_CHOP), :756/:5921 (STRUGGLE), :963 (VITAL_THROW), :1529 (SKETCH), :4421 (RECOVER); item_effects.asm:2434 (SKETCH); effect_commands.asm:5524 (`if HIGH(FLY) != HIGH(DIG)`); ai/scoring.asm:1215 (ICY_WIND), :2299 (DIG), :2662 (FLY); battle_anims/bg_effects.asm:1499 and anim_commands.asm:114 (ROLLOUT).
  - In the prototype sort none of these crosses $100. Only `core.asm:743` changes: today `LOW(KARATE_CHOP)==HIGH+1` gives `inc a`; with KARATE_CHOP=$4f it becomes `ld a,$4f`, costing **+1 byte in Battle Core**. Battle Core has $1b3 free on core, per `crystal_eclipse.map:206-208` [V].
- **8-bit `db` of a move constant.** With `-Wtruncation=1` (Makefile:43) these only warn when a value is ≥$100:
  - `data/pc/bad_egg.asm:5` `db KARATE_CHOP` is copied into `wBufferMon`, a party struct that holds 8-bit runtime IDs (`bills_pc.asm:1041`). This is **already wrong**: it puts an index where an ID belongs. It becomes $4f after the sort, still < $100. Suggest `NO_MOVE`.
  - `engine/battle/ai/scoring.asm:2128-2130` `.GoodHailMoves: db BLIZZARD / db -1` is read by `AIHasMoveInArray` → `IsInWordArray` with de=2 (:2918-2940). This is a **pre-existing bug**: a byte list scanned as a word list never matches and over-reads until it hits $FFFF. Fix it to `dw` regardless of the reorder.
- I swept every `cp`/`ld`/`sub`/`and` that uses a move constant without HIGH/LOW: the only hit was link.asm:2483. Every `LOW(MOVE)` use has matching HIGH handling [V].

### C. Order-independent, symbolic only [V]

- critical_hit_moves.asm, metronome_exception_moves.asm, `data/battle/ai/*_moves.asm` (all `dw` lists terminated by -1)
- tmhm_moves.asm (`TMxx_MOVE` aliases from `add_tm`/`add_hm`/`add_mt` in item_constants.asm:281-392). TM learn bits key off `*_TMNUM`, not the move value.
- mon_menu.asm `dbbw`, overworld.asm field-move `ld hl, SURF` etc.
- trainer and Battle Tower parties (`dw` symbolic), safari_move_tutor_moves.asm, learnsets/egg moves, event macros `givepokemove`/`loadmoveindex` (`dw`, macros/scripts/events.asm:1081-1093)
- VC patch: `vc/pokecrystal.constants.asm` EXPORTs plus `{dws_ X}` in the template, regenerated from the .sym file.
- **16-bit system** (`constants/16_bit_translation_constants.asm:22-26`): ENTRIES=230, LOCKED=18, MINIMUM_RESERVED_INDEX=$FF. These are runtime ID-slot parameters. Nothing is preallocated per move, so they are order-independent. `MOVES_HIGH_MASK %00111111` caps indexes at $3fff, which is fine.
- Negative `ANIM_*` constants (move_constants.asm:286-312) are independent. `ANIM_SWEET_SCENT_2` (=NUM_ATTACKS+1, :284) falls in the null range of the anim table and is referenced nowhere.
- **tools/ and utils/**: nothing parses move constants or move tables (grep found nothing) [V].
- No numeric-literal move values were found in data, parties, scripts, mon_menu or field moves (regex sweeps) [V].

## 2. Save compatibility: renumbering BREAKS saves [V]

- **Party, day-care and contest mons**: `MON_MOVES` holds 8-bit runtime IDs (`pokemon_data_constants.asm:76`). The ID→index map `wMoveIndexTable` is saved to `sMoveIndexTable`/`sBackupMoveIndexTable` (`ram/sram.asm:49-50`, `engine/menus/save.asm:355-370`) as 16-bit **indexes**. This covers wPartyMons, wDayCareMon1/2, wEggMon (box_struct) and wContestMon in wPokemonData (`ram/wram.asm:427-497`).
- **Box mons (newbox)**: savemon stores the index split into `SAVEMON_MOVES_LOW` (:118) and `SAVEMON_MOVES_HIGH & MOVES_HIGH_MASK` (:136, :167), in `sNewBoxMons1/2` (sram.asm). docs/newbox_format.md bytes 0x02-0x05 hold the moves. The checksum lives in the MSBs of the nickname/OT and covers the entry data [I: inferred from the doc text].
- **Effect of the reorder**: every stored move silently becomes whichever move now owns its old index. Its PP and PP-ups are left over from the old move, and the stored PP can exceed the new move's max. No crash, no Bad Egg, so the corruption is not detected. Hall of Fame, mail, link records and Battle Tower SRAM hold no moves.
- **Mitigation options**:
  - (a) Accept a save wipe. Recommended while in development.
  - (b) Offline Python converter: apply the old→new permutation to both move index tables and to every pokedb entry's low+high move bytes, then recompute the newbox per-entry checksum and the main/backup checksums.
  - (c) In-ROM migration behind a save-version byte. Costs ROM0/bank space and is not worth it [I].

## 3. Hardcoded numeric moves

None found, apart from the 8-bit `db` items in 1B. Stale hex comments live in move_constants.asm and in docs/memory (for example project_branch39_moves.md lists IDs $101-$129). The regenerator should rewrite the constants comments with real values.

## 4. Type order and special cases

- **Order**: follow `constants/type_constants.asm`: NORMAL…STEEL, CURSE_TYPE, FIRE…FAIRY. That matches TypeNames and TypeMatchups, so a move's position mirrors its type value. CURSE_TYPE then sits as a 1-move group between STEEL and FIRE.
- **Within a type**: a stable sort (current relative order) is the least surprising. For "examine in aggregate", sorting by category (P/S/St), then power descending, is better. Make the key a script flag.
- **NO_MOVE**: stays 0. The anim table starts at index 0 with `BattleAnim_Dummy`, the other tables at 1.
- **STRUGGLE**: is NORMAL typed. Place it last in the NORMAL group (prototype gives $4e) or at the very end. Nothing depends on its value except link.asm:2483.
- **Gen split**: "Gen1/Gen2" stops meaning anything. Keep `GEN1_MOVES` as a **split index left at 141** (or rename it `MOVES_SPLIT`), so every SECTION size is byte-identical. The prototype's slot substitution does exactly this. Animation bodies stay in their current files. With per-entry banks, a gen1 slot can point at a gen2 body and vice versa.
- **Prototype stable sort, starting IDs**: NORMAL $01, FIGHTING $4f, FLYING $61, POISON $6d, GROUND $75, ROCK $7e, BUG $86, GHOST $90, STEEL $99, CURSE $a3, FIRE $a4, WATER $ad, GRASS $bb, ELECTRIC $cb, PSYCHIC $d3, ICE $e4, DRAGON $f0, DARK $f7, FAIRY $fe. The ≥$100 moves are SWEET_KISS, CHARM, MOONLIGHT, MOONBLAST, PLAY_ROUGH, DAZZLING_GLEAM, DISARM_VOICE and DRAIN_KISS, all FAIRY.

## 5. Mechanical approach (prototyped)

**Regenerator**: `scratchpad/regen_proto.py`. It reads only and writes to `scratchpad/out/`.

1. Parse the `const` slots of move_constants.asm (up to `GEN2_MOVES`).
2. Collect the entry lines of each positional table by regex. The slot counts were checked against the constants: 263, 263, 263, 142+122 = N+1.
3. Bind lines to move names by position, read each move's type from field 3 of its `move` line, and build the new order.
4. **Slot substitution**: write the new move's line into the k-th slot of each file. Headers, SECTION lines, `.IndirectEnd::` and the `GEN1_MOVES` line stay in place, so the split index and section sizes do not change.
5. Rewrite the constants comments with real hex values.

Confirmed: the output names list is an exact permutation of the input. Remaining TODO:
- link.asm:2483 (manual)
- `db BLIZZARD` → `dw` and bad_egg (manual)
- optionally regroup the description and animation **bodies** for readability (cosmetic only; changes bank fill)
- refresh the move_constants header comment, which still points at a nonexistent `animations.asm`

Keep the script in `utils/` so it can be re-run after every move addition [I: recommended].

**Verification without an emulator**: `scratchpad/dump_moves.py ROM SYM`. It works today on the core ROM.
- Walks the `Moves`, `MoveDescriptions` and `BattleAnimations` indirect tables and the `MoveNames` list via .sym addresses, and decodes text with constants/charmap.asm.
- Emits one line per move keyed by **NAME**: effect, power, type, category, accuracy, PP, chance, anim label (bank:addr resolved via the sym file), description text.
- Also dumps TMHMMoves (ordered), plus CriticalHitMoves, MetronomeExcepts and every `dw`-style AI list as **name sets**.
- On current core: 263 MOVE lines, no unresolved indexes.

Procedure:
1. Dump core, apply the reorder, build, dump again, `diff`. The diff must be empty.
2. Also check: the `.map` section sizes are identical, except for the +1 byte in Battle Core from core.asm:743. `rgbasm` prints no new truncation warnings. optimize.py shows no new warnings.
3. Optional additions: decode learnsets (EvosAttacks), egg moves, trainer and Battle Tower parties and the safari tutor table into names the same way. These are symbolic, so they cannot drift, but dumping them guards against hidden literals.
4. The dumper does not cover code-path behaviour (link.asm:2483). Grep-audit that separately.

## 6. Interactions with other branches

| Branch | State vs core | Move-order relevance |
|---|---|---|
| 39 `make-legendaries-move-tutors` | 2 ahead, 272 behind | High. Its own diff (`core...39`): removes CONVERSION, CONVERSION2 and BEAT_UP. Adds 37 moves that **core already has**, plus U_TURN and VOLT_SWITCH with EFFECT_SWITCH_HIT. Also touches AI lists, parties and learnsets. BEAT_UP is already gone from core. Its WIP state is Battle Core over by about 3 bytes, in an older bank layout. The planned signature moves and the AEROBLAST/SACRED_FIRE/SKY_ATTACK/AURA_SPHERE redefinitions (type changes would move these between groups) are not on the branch yet. |
| 49 pseudo-abilities | 1 ahead (Celadon map/mart edit) | None. docs/pseudo_abilities.md effects are keyed by species and field logic. |
| 32 obedience | 0 ahead | None [I]. |
| 30 DV/EV NPC | 0 ahead | None [I]. |
| 11 remove link | 0 ahead | Removes link.asm:2483 and the link transfer paths (:835, :1115, :1162, :1440, which send indexes). Builds with different numbering cannot trade or battle. Doing 11 first deletes the only order-dependent code. |

**Recommendation: do the reorder AFTER the move set is final for this cycle, i.e. 11 → 39 → 24.**

1. **Saves.** Appending moves at the end never breaks saves. Removals (CONVERSION/2) and the reorder both do, so batch them into one break.
2. **Conflicts.** 39 edits the very positional tables that 24 permutes. Any reorder first turns 39's rebase into hundreds of conflicting lines. 39 already needs a manual rebase onto core, since most of its content landed separately.
3. **Type changes.** 39's type redefinitions decide group membership, so sorting first sorts by stale data.
4. **11 first.** It removes the STRUGGLE+1 check, so 24 has zero hand-edited code paths.

Counterpoint: with the script, re-sorting is cheap. But every re-sort is a save break and churns BGB-visible IDs. So run it once per batch of move changes, and treat the order as frozen near release. If 39 has to slip, run 24 now with the script and then have 39 insert new moves via the script (append to the constants, then re-run). That works too; the cost is one extra save break.

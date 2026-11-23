# Mass Compression Prep: Crystal Eclipse

Context document for planning ROM-space savings across the repo (`shasocastris/crystal_eclipse`, branch `core`).
Source: a Discord thread between Sylvie (Rangi42, Polished Crystal maintainer), Aaron, Drush and others, plus Eclipse project notes.
Anything marked **[Proposed]** is my suggestion and is not from the thread.
Anything marked **[Checked]** was verified against the `core` tree on 2026-11-16.

---

## 0. Status as of 2026-11-16 **[Checked]**

**Already done:**

- `gfx/lz.mk` is deleted. The Makefile has only the plain `%.lz` rule (step 2).
- Tileset metatiles are compressed. Tilesets include `*_metatiles.bin.lz`, and `wDecompressedMetatiles` / `wDecompressedAttributes` exist in WRAM (section 5).
- The code half of step 1 is done. Branch `69-dead-code` is merged into `core`; see `docs/dead_code_removal.md`. 65 unreferenced symbols remain, mostly fallthrough labels that cannot be deleted.
- Orange Islands (M3) is merged, so advice about reserving space "before M3" no longer applies.

**Baseline (release ROM, from `crystal_eclipse.map`):**

| Region | Free |
|---|---|
| ROMX | 328,395 bytes |
| Whole ROM | 313,072 bytes (14.93%) |
| ROM0 | 1,061 bytes |
| WRAM0 | 27 bytes |
| WRAMX | 3,227 bytes |

Total ROM space is not the constraint. ROM0, WRAM0 and individual pinned banks are.
52 banks show under 256 bytes free, but that count does not separate banks pinned in `layout.link` from banks the linker simply packed full. Splitting those is the first job (section 10).

**Done on branch `92-compression` (2026-11-17, uncommitted at time of writing):**

| Step | ROMX freed | ROM0 freed | How it was checked |
|---|---|---|---|
| Map block compression | 11,777 B | 267 B | `wOverworldMapBlocks` byte-identical on old and new ROM for all 426 maps, connection strips included |
| Music subroutine factoring | 2,416 B | 0 | Executed bytecode identical for all 364 channels on both builds (19.8 million commands) |

Free space after both: **328,126 bytes (15.65%)** release. ROM0 has 1,329 bytes free, of which 1,121 (release) / 1,092 (debug) sit above `Home`. `utils/optimize.py` reports no new warnings.

How the map change works:
- `data/maps/blocks.asm` includes `maps/*.ablk.lz`. The `.ablk` files stay the editable source; the Makefile's `%.lz` rule builds the rest.
- `ChangeMap` (home) decompresses the map into `wDecompressScratch` and far-jumps to `_ChangeMap`, which copies the rows.
- `FillMapConnections` and the strip fillers moved to `engine/overworld/load_map_blocks.asm` (ROMX). They call `DecompressAnyMapBlocks` (home) for each neighbour, so entering a map decompresses up to five maps. **Play-test a connection crossing for a hitch.**
- The `connection` macro now points strips at `wDecompressScratch`, not at the neighbour's ROM data.

How the music change works:
- `utils/music_optimize.py` was written for Eclipse. Polished Crystal's script was not ported, because it scores by source-text size and resolves local labels per file, while Eclipse's songs call each other's subroutines across files.
- It factors repeated command runs into `sound_call` subroutines named `<Song>_DittyN`, appended to the same file, and never inside code that is itself called (the engine keeps one return address).
- It refuses to write unless every channel plays the same command stream before and after. Re-run it after adding or editing songs.

**Dead code removed on the same branch (2026-11-17):** 7,603 B of ROMX, no ROM0. Free space after everything: **335,729 bytes (16.01%)** release.

| What | Notes |
|---|---|
| Trainer Rankings | Every `StubbedTrainerRankings_*` routine began with `ret`. The routines, their 28 `farcall`/`farjp` sites, the `special` and its 10 script uses are gone. The SRAM layout is untouched. |
| Foreign mail fonts | `ParseMailLanguage`, the French/German and Spanish/Italian fonts and the four converters. Nothing writes a mail nationality, so mail was always English. |
| Five unused songs | GS opening 1 and 2, Mobile Adapter, Mobile Adapter Menu, Mobile Center. The `MUSIC_*` constants stay and point at `Music_Nothing`, so music IDs do not shift. |
| Two unreachable houses | `OlivineHouseBeta` and `GoldenrodPPSpeechHouse` are stubs with warps only. The maps and the ten empty `*_POKECENTER_2F_BETA` maps keep their IDs; deleting them outright would renumber maps and break existing saves for under 300 B. |
| Unreferenced blocks | Link text, Swimmer Walter/Rick text, mobile CGB layouts, `AddMobileMonToParty`, and other blocks that `utils/unreferenced.py` lists and nothing falls into. |

Left in place on purpose: unreferenced labels that code falls into (`OpenCarpet`, `CheckPartyMove`, `_ResetWRAM`, `ScrollTileLeft` and others), `PrintDiplomaPage2`, `GuideGentPlayerMovement`, and `FirstEvoStages` (a 282-line table nothing reads yet).

Headroom gained in the tight code banks is small: `$04` 32 → 71 B, `$03` 88 → 143 B, `$0d` 117 → 125 B, `$20` unchanged.

**Super Game Boy support removed (2026-11-17):** 4,904 B of ROMX and 10 B of ROM0. Free space: **340,386 bytes (16.23%)** release.

- Gone: `engine/gfx/sgb_layouts.asm`, the border graphics and tilemap, the packet-push code, the control and block packets, the SGB Pokédex tiles, the SGB exp-bar tile, and every `hSGB` check (each collapsed to its GBC path).
- `GetSGBLayout` and `LoadSGBLayout` keep their names (about 90 call sites) but only apply CGB layouts. `GetSGBLayout` returns at once on a DMG.
- The `PalPacket_*` entries the CGB layouts still read stay in `gfx/sgb/pal_packets.asm`.
- The `hSGB` byte in HRAM is now padding, so no HRAM address moved.
- Checked: all 32 `SCGB_*` layouts give identical palettes and attrmap on old and new ROM. **Not checked:** booting on a real DMG or SGB. Both should now reach the "GBC only" screen the same way, the SGB without a border.
- The source art (`gfx/sgb/sgb_border.*`, `gfx/pokedex/pokedex_sgb.png`, `gfx/battle/expbarend_sgb.png`) is still in the tree, unused.

**Battle Tower level menu rewritten, mobile code removed (2026-11-17):** 9,057 B freed, 64 B of it ROM0. Free space: **349,443 bytes (16.66%)** release. ROM0: 1,403 free release, 1,374 debug.

- New `engine/events/battle_tower/room_menu.asm` (floating section, about 380 B) replaces `mobile/mobile_46.asm`. It uses `PrintText`, a plain menu box and `YesNoBox`. Same box, same level list, same refusals, same `wScriptVar` and `wBTChoiceOfLvlGroup` results.
- Deleted with it: `mobile/mobile_45_sprite_engine.asm`, `home/mobile.asm` (`MobileAPI`), `lib/mobile/`, the Pokémon News block in `mobile/mobile_5f.asm` (about 2,000 lines that only referenced each other), the dialing graphics loader, and seven routines only that code called (`SaveAfterLinkTrade`, `LoadStandingSpritesGFX`, `LoadWalkingSpritesGFX`, three palette loaders, `InitBattleTowerChallengeRAM`).
- Banks `$45` and `$46` are no longer pinned in `layout.link`.
- **Bug fixed on the way:** the old cancel prompt drew no YES/NO box, and A or B on it ended in "No windows available for popping." The new one is a normal YES/NO.
- The map is no longer reloaded after the menu (the old code needed that to restore tiles it overwrote).
- Checked with `docs/compression/ab_tower_menu.py`: opening screen, scrolling, and 50 level/party combinations (with and without an uber) match the old ROM; only the cancel steps differ, as above. The four Battle Tower scene tests pass.
- Regression harness: `mapblocks.py` added, because `follower_sweep.py` and `v10_items.py` read raw map blocks from the ROM and those are compressed now. This engine's LZ counts repeat from 2 and alternate from 3. `lz_decompress` in `utils/render_overworld.py` assumed 1; it now reads the minimums from the repo's `tools/lz/util.c`, so it works for both this engine and pret-style hacks.

**Looked at and left alone:**

| Data | Raw | Possible saving | Why not done |
|---|---|---|---|
| Follower sprites (`gfx/following`) | 117 KB | ~48 KB | Loaded straight from ROM to VRAM in slices; needs a new sprite-loading path and costs load time when the follower changes |
| Overworld sprites (`gfx/sprites`) | 44 KB | ~21 KB | Same loader, same cost on every map load |
| Party icons (`gfx/icons`) | 36 KB | ~11 KB | Loaded per icon with animation frames |
| Winter tiles, pack, credits, trainer card | 21 KB | ~11 KB | Each loader reads sub-ranges (per pocket, per tile, per frame), so each needs its own rewrite |
| Footprints | 9 KB | ~3.5 KB | 32 bytes each; per-file LZ overhead eats most of it |

The sprite numbers are the only large win left. That is an engine project with a visible speed cost, so it needs a decision, not a blind pass.

**Expected size of the remaining wins** (estimates made before the work above):

| Step | Estimate |
|---|---|
| Mobile leftovers | up to ~10.7 KB, if all four sections can go |
| Map block compression | ~12 KB |
| Assembly optimization | a few hundred bytes at most |
| Music optimization | "thousands of bytes" per the thread; not measured here |
| Text n-grams | not measured |

---

## 1. Goal and constraints

- Free ROM space on the MBC3 build without switching mappers.
- The thread covered mapper alternatives (MBC30, MBC5, TPP1). They are **out of scope**, because Eclipse targets MBC3 and compatibility matters.
  - MBC30 is easy but causes emulation compatibility issues.
  - MBC5 is better supported but loses the RTC. Eclipse uses the RTC for seasons and Wonder Trade day rotation, so this is not an option.
  - TPP1 allows 1 GB ROMs and is supported by SameBoy and BGB, but it is a different mapper entirely.
- Reference point: Polished Crystal has hovered around 1% free space for a long time and keeps finding new savings when it runs low. Expect compression work to be iterative, not one-and-done.

## 2. Ordered plan (Sylvie's priority order)

Do these in order. Each step assumes the previous ones are finished.

1. **Remove significant unused content first.** This means unused maps, tileset tiles/blocks, JP mobile leftovers and so on. **Partly done**, see below.
2. ~~**Delete `gfx/lz.mk`.**~~ **Done.** See section 3.
3. **Compress more things.** This is the main lever (sections 4 and 5). Metatiles are done; maps are not.
4. **Optimize assembly patterns** (section 6).
5. **Optimize music** (section 7).
6. **Add text n-gram characters** (section 8).
7. **Improve the LZ format itself** (section 9). This is the most advanced step and optional.

**[Checked] What is left of step 1:**

- The mobile sections still take about 10.7 KB: `mobile5F` (4,774), `mobile46` (3,599), `mobile45` (1,268), `mobile5C` (1,031). How much of that is reachable has not been audited.
- Unused maps and unused tileset tiles/blocks have not been audited. `docs/tileset_survey.md` is the starting point.
- `utils/unreferenced.py` fails when run with no arguments, because it looks for `pokecrystal.sym`. Fix or parameterise that before relying on it again.

## 3. Matching vs. non-matching LZ (read before touching `lz.mk`)

- The `lz.mk` file has a comment: *"Delete these rules if you don't care about matching."*
- **"Matching" means producing byte-identical output to the original Pokémon Crystal ROM.** The rules force `lzcompress` to emit the original, larger .lz bytes for specific vanilla assets.
- Deleting `gfx/lz.mk` makes `lzcompress` emit smaller .lz files that decompress to the same data. For a hack like Eclipse, matching has no value, so delete it.
- **Caveat from the thread (unverified):** Th3Element05's players reported random garbled trainer-pic tiles in BGB, and it was never reproduced. One hypothesis was a decompression issue. Grate Oracle Lewot removed the matching rules in their own hack and has not seen the issue. This is not proven to be the cause, but **trainer pics and Pokémon pics should be on the regression checklist** after any compression change.
- **[Checked]** `gfx/lz.mk` is not present in `core`, so Eclipse already builds non-matching. Eclipse has shipped this way, which makes its own play history the available evidence on the garbled-pic report.

## 4. Compress maps (highest expected savings)

Sylvie says compressing maps will probably save much more space than compressing menu data.

- Aaron's concern: it needs an engine buffer to decompress into.
- Sylvie's answer: **the `wOverworldMapBlocks` buffer already exists**, so maps can decompress into it.
- Reference commit (Polished Crystal, with its engine customizations, but mostly relevant to pokecrystal):
  `https://github.com/Rangi42/polishedcrystal/commit/ad7ccaeda1243c13b14f6823294f23f48fc81372`

**[Checked] Findings:**
- **Size of the win.** `data/maps/blocks.asm` references 292 `.ablk` files in three sections ("Map Blocks 1" to "3"), 38,364 bytes raw. Run through the current `tools/lzcomp` one file at a time, they total about 26,266 bytes, so this saves roughly 12 KB.
- **The buffer is big enough.** `wOverworldMapBlocks` is 1,300 bytes. The largest map, Route 41, needs 1,023 including its border.
- **The copy is not a straight decompress.** `ChangeMap` in `home/map.asm` copies the blocks row by row into the interior of the buffer, leaving a 3-block border. A contiguous decompress therefore needs either a scratch area, or a decompress-then-spread pass inside the buffer.
- **Room for new code and buffers is tight.** ROM0 has 1,061 bytes free and WRAM0 has 27. A scratch buffer would have to live in WRAMX (3,227 free).

**Still to check before starting:**
- Read the Polished Crystal commit first, and follow its design unless Eclipse's engine forces a difference.
- Open `FillMapConnections`. If connection strips are read from the neighbouring map's ROM data as in vanilla, those neighbours would also need decompressing. This was not confirmed.
- Check every script path that reloads block data, plus the custom warp paths (surf-preserving warps, `Script_warpmod`, the planned fortress travel system).
- The repo's Project sync **excludes `/data/maps/` and `/data/tilesets/`**, so those files have to be pulled in manually when working on this step.

## 5. Compress tileset metatiles (second tier)

**[Checked] Done.** Metatiles are already compressed and the WRAM buffers exist (section 0). The notes below are kept for reference. Menu data remains an untried, lower-value target.

- Sylvie notes compressing tilesets needs **its own buffer** for the decompressed `*_metatiles.bin` data (maps can reuse an existing one, tilesets cannot).
- Reference commit: `https://github.com/Rangi42/polishedcrystal/commit/4c022f208453394691b3cab2d255d227e5b639b0`
- **[Proposed]** Decide where in WRAM the buffer lives. The M0 save-block and WRAM reservation work already in the roadmap is the right place to reserve it, before M3 (Orange Islands) adds a new full tileset.
- Aaron separately suggested **menu data** as an easier target. It is lower savings, but needs less engine work.

## 6. Assembly optimization

- Script: `https://github.com/Rangi42/polishedcrystal/blob/master/utils/optimize.py`
- It finds many suboptimal patterns described at `https://github.com/pret/pokecrystal/wiki/Optimizing-assembly-code`.
- **It only reports; you apply fixes by hand.** Sylvie's warning: check each hit. The "optimized" pattern can break code through side effects (for example flags that a later instruction reads).
- **[Checked]** Eclipse already has the script at `utils/optimize.py`. It currently reports 155 instances on `core`. At a byte or two each, expect a few hundred bytes at most.
- **[Proposed]** Eclipse has a lot of custom assembly (16-bit species and item systems, type completion boost, evolution move gating). Review hits in those files with extra care, and rebuild and test after each batch rather than applying everything at once.

### Chunk-sized example
A classic pattern the wiki covers: loading zero into `a`.
```
ld a, 0     ; 2 bytes, 2 cycles, leaves flags alone
xor a       ; 1 byte, 1 cycle, BUT sets Z and clears carry
```
Saves a byte, but is only safe if nothing afterward depends on the old flags. This is exactly the kind of side effect Sylvie warned about.

## 7. Music optimization

- Run `utils/music_optimize.py` on the music files.
- Reference: `https://github.com/Rangi42/polishedcrystal/pull/1678`
- Sylvie says it saves **thousands of bytes**. Likely the cheapest large win after the LZ change.
- **[Checked]** `utils/music_optimize.py` is **not in this repo**. It has to be ported from the Polished Crystal PR and checked against CSE's audio macros before it can run. The audio sections total about 75 KB.
- **[Proposed]** Run it on a branch and listen-test a handful of tracks in BGB, since it rewrites music data.

## 8. Text n-gram characters

- Idea: define single-byte charmap entries that expand to common multi-letter strings. These are the "n-gram" characters.
- Existing example: in `home/text.asm`, the single-byte `#` renders as the four characters **P O K é**.
- Candidates from the thread: "the", "as", "ing", etc.
- Aaron said he had spare character slots available but did not use them. He noted diminishing returns, but it could still be worth it.
- **[Proposed]** Count n-gram frequencies in the dialogue text first and rank by (occurrences × bytes saved), so slots go to the best candidates.
- **Eclipse-specific:** the 18-character dialogue line limit is a hard constraint, and `#MON` already counts as 7 characters. Any new n-gram must be accounted for in the dialogue linter, or lines will overflow on screen.
- **[Checked]** No dialogue linter was found in `utils/` or `docs/helper_scripts.md`. One has to be written before n-grams go in, or the 18-character limit cannot be enforced.
- **[Checked]** 32 byte values have no entry in `constants/charmap.asm`: `$01-$04`, `$17`, `$20`, `$21`, `$4d`, `$60-$6d`, `$6f`, `$76-$7e`. These are candidates only. Each must be checked against the text engine in `home/text.asm`, since a value can be unmapped in the charmap and still be handled as a control code.

## 9. Improving the LZ format (advanced, optional)

- Polished Crystal's compressor adds commands for special cases, for example runs of bytes all in `$00-$0F`. Drush's comments in the compressor source explain them:
  `https://github.com/Rangi42/polishedcrystal/blob/master/tools/lzpcompress.cpp`
- Drush's own notes on the current state (from the thread):
  - The `lzpack16` variant may not provide much beyond the other two lzpack variants, and he wants to rename it.
  - `lzalternate` may not be earning its keep. Changing the `LZ_LONG` format might help.
  - His main obstacle is analyzing the bytes inside the commands.
  - Treat these as **work in progress**, not settled tooling.
- **[Proposed]** Defer this step. Adopting a new LZ format means changing both the compressor and the decompressor and re-verifying every compressed asset.

## 10. Preparation checklist **[Proposed]**

Before any compression work:

- [ ] **Decide the target.** Work out which pinned banks are blocking planned work, by separating banks pinned in `layout.link` from banks the linker packed full. Without this, savings land in banks that already have room.
- [x] Record a whole-ROM baseline (section 0).
- [ ] Record **free bytes per bank** on the working branch, so each step can be measured on its own.
- [ ] Cut a dedicated branch off `core`, consistent with the per-milestone branch approach.
- [ ] Finish step 1: audit the mobile sections, unused maps and unused tileset tiles/blocks. Commit separately so the savings can be measured on their own. (Dead code is already done.)
- [x] Delete `gfx/lz.mk`.
- [x] Metatile buffer in WRAM.
- [ ] Decide where a map-decompression scratch buffer lives, if the design needs one. WRAM0 has 27 bytes free, so it would go in WRAMX.
- [ ] Write the dialogue line-length linter before any n-gram work.
- [ ] Define a regression test list: trainer pics, Pokémon pics (front/back), overworld load in several tilesets, map connections, menus, and a battle on each map group. The SameBoy harness in `docs/regression/` covers the scripted part; music needs a listen-test.
- [ ] Measure after each step, so you can tell what each change earned.

## 11. Open questions

1. Does Eclipse's map-loading path (custom warps, fortress travel) conflict with a decompress-into-`wOverworldMapBlocks` design?
   **Still open.** The row-by-row copy in `ChangeMap` and the unconfirmed connection-strip question are the known complications (section 4).
2. Will the largest planned maps fit that buffer once decompressed?
   **Answered: yes** for every map in `core`. Route 41 is the largest at 1,023 of 1,300 bytes. Any new map must stay under the same limit.
3. Is the garbled trainer-pic report actually LZ-related? It could be a separate graphics-loading bug.
   **Cannot be settled here.** Eclipse already builds without the matching rules, so its own play history is the evidence.
4. Which banks are currently full? Savings in a bank with spare room are wasted.
   **Partly answered.** The ROM has 313,072 bytes free overall and 52 banks under 256 bytes free. Which of those are pinned and actually blocking work is not yet known.
5. How many spare charmap slots exist for n-grams after Eclipse's own additions?
   **Partly answered.** 32 candidate byte values, pending the text-engine check in section 8.

## 12. Link index

| Topic | Link |
|---|---|
| Compressed maps commit | https://github.com/Rangi42/polishedcrystal/commit/ad7ccaeda1243c13b14f6823294f23f48fc81372 |
| Compressed metatiles commit | https://github.com/Rangi42/polishedcrystal/commit/4c022f208453394691b3cab2d255d227e5b639b0 |
| `optimize.py` | https://github.com/Rangi42/polishedcrystal/blob/master/utils/optimize.py |
| Asm optimization wiki | https://github.com/pret/pokecrystal/wiki/Optimizing-assembly-code |
| Music optimizer PR | https://github.com/Rangi42/polishedcrystal/pull/1678 |
| LZ compressor (special cases) | https://github.com/Rangi42/polishedcrystal/blob/master/tools/lzpcompress.cpp |
| TPP1 mapper (reference only) | https://github.com/aaaaaa123456789/tpp1 |

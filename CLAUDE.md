# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Crystal Eclipse** is a Pokemon Crystal ROM hack built on top of **CrystalShireEngine (CSE)** — an enhanced engine for pokecrystal romhacking. The codebase is a fork of [pret/pokecrystal](https://github.com/pret/pokecrystal) written entirely in **RGBDS assembly** (Game Boy/GBC assembly), with custom tooling in C and Python.

- **upstream** remote: `fellowship-of-the-roms/CrystalShireEngine`
- **origin** remote: `shasocastris/crystal_eclipse`
- Default branch: `core`

## Build Commands

```bash
# Build release ROM (crystal_eclipse.gbc)
make

# Build debug ROM (crystal_eclipse_debug.gbc) — enables _DEBUG define
make crystal_debug

# Build both
make all

# Build VC patch
make crystal_vc

# Build C tools only
make tools

# Remove .o files, .sym, .map, ROMs (keep generated graphics)
make tidy

# Full clean (also removes generated .2bpp, .lz, .gbcpal, etc.)
make clean
```

The build requires **rgbds 1.0.0** (`rgbasm`, `rgblink`, `rgbfix`, `rgbgfx`). To use a local rgbds version: `make RGBDS=rgbds-1.0.0/`

## Optimizer / Pre-PR Workflow

Per `AGENTS.md`, before making changes and before submitting a PR:

```bash
# Snapshot current warnings (never commit this file)
python utils/optimize.py > .opt.old || true

# Make changes, then build
make -j"$(nproc)"

# Check for new warnings introduced by your changes
python utils/optimize.py > .opt.new
diff -u .opt.old .opt.new && echo "OK"

# Delete temp files before committing
rm -f .opt.old .opt.new
```

PRs must not introduce new `optimize.py` warnings. All `jmp`→`jr` warnings must be resolved.

## Code Architecture

### Entry Points / ROM Structure

The ROM is assembled from four top-level `.asm` files, each compiled to a `.o` object:

- **`home.asm`** — ROM bank 0 (always-accessible): interrupt handlers, vblank, joypad, text engine, farcall, palettes, map/movement primitives
- **`main.asm`** — ROM banks 1–N: all banked code (battle, overworld events, menus, items, Pokemon systems, etc.)
- **`audio.asm`** — Audio banks: music and sound engine
- **`ram.asm`** — WRAM/SRAM definitions (no code, only memory layout)

`includes.asm` is pre-included into every assembled file (via `-P` flag) and pulls in all constants, macros, and charmap definitions.

`layout.link` controls bank layout for `rgblink`.

### 16-Bit Index System

CSE uses extended 16-bit indexes for Pokemon, Moves, and Items (beyond the 8-bit limit of vanilla). Always use the provided helpers — never access conversion tables directly:

| Helper | Input | Output | Clobbers |
|--------|-------|--------|----------|
| `GetPokemonIndexFromID` | `a` | `hl` | `a` |
| `GetPokemonIDFromIndex` | `hl` | `a` | `hl` |
| `GetMoveIndexFromID` | `a` | `hl` | `a` |
| `GetMoveIDFromIndex` | `hl` | `a` | `hl` |
| `GetItemIndexFromID` | `a` | `hl` | `a` |
| `GetItemIDFromIndex` | `hl` | `a` | `hl` |

### Debug Build

The debug ROM (`crystal_eclipse_debug.gbc`) is assembled with `-D _DEBUG`. Use `IF DEF(_DEBUG)` / `ENDC` guards for debug-only code.

## Style

- **Tabs for indentation, spaces for alignment** (unless existing code uses different style)
- Follow [pret/pokecrystal STYLE.md](https://github.com/pret/pokecrystal/blob/master/STYLE.md)
- Use `jmp` macro (not raw `jp`); replace with `jr` when target is within ±128 bytes (the optimizer flags these)
- Scripting macros are defined in `macros/scripts/` — use these for map events, text, movement, battle animations, etc.
- **Map text line limit: 18 characters maximum** per `text`/`line`/`cont`/`para` string. Always count every character (including spaces and punctuation) before writing or editing NPC/sign/item text. After editing dialogue, run `python3 utils/dialogue_lint.py --changed core` and fix any errors it reports.

## External References

The pret/pokecrystal wiki tutorial index lives in the `pokecrystal-wiki` skill (`.claude/skills/pokecrystal-wiki/SKILL.md`). Use it when implementing a feature a wiki tutorial may cover.

## Key Generated Files (do not commit)

- `*.o`, `*_debug.o`, `*_vc.o` — compiled object files
- `*.gbc`, `*.sym`, `*.map` — ROM output files
- `gfx/**/*.2bpp`, `*.lz`, `*.gbcpal` — generated graphics binaries
- `.opt.old`, `.opt.new` — temporary optimizer snapshots

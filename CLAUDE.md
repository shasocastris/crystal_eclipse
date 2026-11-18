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

### Directory Structure

| Directory | Contents |
|-----------|----------|
| `home/` | ROM0 subroutines (one file per subsystem: vblank, farcall, palettes, etc.) |
| `engine/` | Banked game logic — battle, overworld, menus, items, pokemon, math, etc. |
| `data/` | Game data tables — maps, pokemon stats, moves, items, text |
| `maps/` | ~670 individual map scripts (`.asm`) and block layouts (`.ablk`) |
| `constants/` | All constants and enums (`INCLUDE`d via `includes.asm`) |
| `macros/` | RGBDS macros — `scripts/` subdirectory has domain-specific scripting macros |
| `gfx/` | Source graphics (`.png`) and generated binary graphics (`.2bpp`, `.lz`, etc.) |
| `audio/` | Music and drumkit definitions |
| `ram/` | WRAM struct definitions |
| `tools/` | C build tools: `lzcomp`, `gfx`, `gbcpal`, `bankends`, `scan_includes`, `pokemon_animation`, etc. |
| `utils/` | Python utilities: `optimize.py`, `farcheck.py`, `grayscale.py`, `unreferenced.py` |
| `docs/` | Documentation for scripting commands (event, movement, text, battle anim, etc.) |
| `vc/` | Virtual Console patch support |

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
- **Map text line limit: 18 characters maximum** per `text`/`line`/`cont`/`para` string. Always count every character (including spaces and punctuation) before writing or editing NPC/sign/item text.

## External References

Use `WebFetch` to retrieve any of these pages when working on related features.

### General Reference
- https://github.com/pret/pokecrystal/wiki/Hard-coded-logic — Hard-coded logic
- https://github.com/pret/pokecrystal/wiki/Code-cleanup — Code cleanup

### Tutorials — Miscellaneous
- https://github.com/pret/pokecrystal/wiki/Tips-and-tricks — Tips and tricks
- https://github.com/pret/pokecrystal/wiki/Useful-unused-data-and-routines — Useful unused data and routines
- https://github.com/pret/pokecrystal/wiki/Discovering-GameShark-cheat-codes — Discovering GameShark cheat codes
- https://github.com/pret/pokecrystal/wiki/Simplify-the-Clock-Reset-Procedure — Simplify the Clock Reset Procedure
- https://github.com/pret/pokecrystal/wiki/Set-DVs-to-0-for-all-your-Pokemon — Set DVs to 0 for all your Pokémon
- https://github.com/pret/pokecrystal/wiki/How-to-find-ROM-offsets — How to find ROM offsets
- https://github.com/pret/pokecrystal/wiki/Show-Metrics-Units — Show metric units

### Tutorials — How to Add a New…
- https://github.com/pret/pokecrystal/wiki/Add-a-new-map-and-landmark — Map and landmark
- https://github.com/pret/pokecrystal/wiki/Add-a-new-tileset — Tileset (with custom palette)
- https://github.com/pret/pokecrystal/wiki/Add-a-new-Pokémon — Pokémon species (up to 253)
- https://github.com/pret/pokecrystal/wiki/Add-a-new-trainer-class — Trainer class
- https://github.com/pret/pokecrystal/wiki/Add-a-new-type — Type (Fairy)
- https://github.com/pret/pokecrystal/wiki/Add-a-new-move — Move (up to 255)
- https://github.com/pret/pokecrystal/wiki/Add-a-new-move-effect — Move effect
- https://github.com/pret/pokecrystal/wiki/Add-a-new-field-move-effect — Field move effect
- https://github.com/pret/pokecrystal/wiki/Add-a-new-item — Item (up to 254, with various effects)
- https://github.com/pret/pokecrystal/wiki/Add-a-new-TM-or-HM — TM or HM (up to 120)
- https://github.com/pret/pokecrystal/wiki/Add-a-new-party-menu-icon — Party menu icon (up to 254)
- https://github.com/pret/pokecrystal/wiki/Add-a-new-overworld-sprite — Overworld sprite
- https://github.com/pret/pokecrystal/wiki/Add-a-new-map-object-movement-behavior — Map object movement behavior
- https://github.com/pret/pokecrystal/wiki/Add-a-new-player-gender — Player gender
- https://github.com/pret/pokecrystal/wiki/Add-a-new-Mart — Mart (with new dialog and more items)
- https://github.com/pret/pokecrystal/wiki/Add-a-new-music-song — Music song
- https://github.com/pret/pokecrystal/wiki/Add-a-fourth-stats-page — Pokémon stats page
- https://github.com/pret/pokecrystal/wiki/Add-a-new-Pack-pocket — Pack pocket
- https://github.com/pret/pokecrystal/wiki/Add-a-new-radio-channel — Radio channel
- https://github.com/pret/pokecrystal/wiki/Add-a-new-wild-Pokémon-slot — Wild Pokémon slot
- https://github.com/pret/pokecrystal/wiki/Wild-Pokemon-Encounter-Data — Wild Pokemon Encounter Data
- https://github.com/pret/pokecrystal/wiki/Add-a-new-Unown-form — Unown form
- https://github.com/pret/pokecrystal/wiki/Add-a-new-Unown-puzzle-chamber — Unown puzzle chamber
- https://github.com/pret/pokecrystal/wiki/Add-a-new-fishing-rod — Fishing rod
- https://github.com/pret/pokecrystal/wiki/Add-a-new-battle-transition — Battle transition
- https://github.com/pret/pokecrystal/wiki/Add-a-new-spawn-point — Spawn point (for Fly or Teleport)
- https://github.com/pret/pokecrystal/wiki/Add-a-new-text-scrolling-speed — Text scrolling speed
- https://github.com/pret/pokecrystal/wiki/Add-a-new-scene-script — Scene script
- https://github.com/pret/pokecrystal/wiki/Move-Tutor-and-Tutor-Moves — Move Tutor and new tutor moves
- https://github.com/pret/pokecrystal/wiki/Add-a-new-phone-contact — Phone contact
- https://github.com/pret/pokecrystal/wiki/Adding-an-NPC-that-gives-you-an-item — NPC that gives you an item
- https://github.com/pret/pokecrystal/wiki/Adding-an-NPC-that-gives-you-a-Pokémon — NPC that gives you a Pokémon
- https://github.com/pret/pokecrystal/wiki/Add-an-About-Page-to-the-Intro-Menu — About page to the Main Menu
- https://github.com/pret/pokecrystal/wiki/Add-a-new-AI-layer — Enemy trainer AI layer

### Tutorials — How to Edit the…
- https://github.com/pret/pokecrystal/wiki/Edit-the-Town-Map — Town Map
- https://github.com/pret/pokecrystal/wiki/Edit-the-battle-HUD — Battle HUD
- https://github.com/pret/pokecrystal/wiki/Edit-the-male-and-female-player-colors — Male and female player colors
- https://github.com/pret/pokecrystal/wiki/Change-the-default-Player-and-Rival-names — Default Player and Rival names

### Tutorials — Upgrades to Existing Features
- https://github.com/pret/pokecrystal/wiki/Expand-tilesets-from-192-to-255-tiles — Expand tilesets from 192 to 255 tiles
- https://github.com/pret/pokecrystal/wiki/Allow-map-tiles-to-appear-above-sprites-(so-NPCs-can-walk-behind-tiles)-with-PRIORITY-colors — Allow map tiles to appear above sprites
- https://github.com/pret/pokecrystal/wiki/Allow-tiles-to-have-different-attributes-in-different-blocks-(including-X-and-Y-flip) — Allow tiles to have different attributes in different blocks
- https://github.com/pret/pokecrystal/wiki/Allow-more-than-15-object_events-per-map — Allow more than 15 object_events per map
- https://github.com/pret/pokecrystal/wiki/Improve-the-outdoor-sprite-system — Improve the outdoor sprite system
- https://github.com/pret/pokecrystal/wiki/Improve-the-event-initialization-system — Improve the event initialization system
- https://github.com/pret/pokecrystal/wiki/Expand-the-Town-Map-tileset — Expand the Town Map tileset
- https://github.com/pret/pokecrystal/wiki/Expand-the-Town-Map-tileset-Alternate — Expand the Town Map tileset (Alternate)
- https://github.com/pret/pokecrystal/wiki/Increase-Pokémon-sprite-animation-size — Increase Pokémon sprite animation size
- https://github.com/pret/pokecrystal/wiki/Color-party-menu-icons-by-species — Color party menu icons by species
- https://github.com/pret/pokecrystal/wiki/Color-Pokémon-pictures-shown-in-overworld — Color Pokémon pictures shown in the overworld
- https://github.com/pret/pokecrystal/wiki/Allow-more-trainer-parties,-with-individual-DVs,-stat-experience,-nicknames,-variable-teams,-etc — Allow more trainer parties with individual DVs, stat exp, nicknames, variable teams
- https://github.com/pret/pokecrystal/wiki/Colored-trainer-card-badges — Colored trainer card badges
- https://github.com/pret/pokecrystal/wiki/Show-the-tops-of-leaders-heads-on-the-trainer-card — Show the tops of leaders' heads on the trainer card
- https://github.com/pret/pokecrystal/wiki/Add-a-third-trainer-card-page-for-Kanto-badges — Add a third trainer card page for Kanto badges
- https://github.com/pret/pokecrystal/wiki/Print-text-when-you-lose-a-trainer-battle — Print text when you lose a trainer battle
- https://github.com/pret/pokecrystal/wiki/Correct-grammar-for-plural-trainers-like-Twins — Correct grammar for plural trainers like Twins
- https://github.com/pret/pokecrystal/wiki/Make-evening-the-fourth-time-of-day — Make evening the fourth time of day
- https://github.com/pret/pokecrystal/wiki/Custom-order-for-the-Old-Pokédex-mode — Custom order for the Old Pokédex mode
- https://github.com/pret/pokecrystal/wiki/Short-beeping-noise-for-low-HP — Short beeping noise for low HP
- https://github.com/pret/pokecrystal/wiki/Remove-the-artificial-save-delay — Remove the artificial save delay
- https://github.com/pret/pokecrystal/wiki/Option-to-show-shiny-colors-in-Pokédex — Option to show shiny colors in Pokédex
- https://github.com/pret/pokecrystal/wiki/Restore-the-GS-Ball-Celebi-Event — Restore the GS Ball Celebi Event
- https://github.com/pret/pokecrystal/wiki/Restore-the-Unused-Memory-Game — Restore the Unused Memory Game
- https://github.com/pret/pokecrystal/wiki/Improve-the-trainer-rematch-system — Improve the trainer rematch system
- https://github.com/pret/pokecrystal/wiki/Make-wild-Pokémon-encounter-levels-vary — Make wild encounter levels vary
- https://github.com/pret/pokecrystal/wiki/Make-the-Lottery-Corner-generate-a-lucky-number-daily-instead-of-weekly — Make the Lottery Corner generate a lucky number daily
- https://github.com/pret/pokecrystal/wiki/Modify-existing-gender-formula — Modify existing gender formula
- https://github.com/pret/pokecrystal/wiki/Force-Set-battle-style-or-forbid-item-usage-in-battle — Force Set battle style or forbid item usage in battle
- https://github.com/pret/pokecrystal/wiki/Make-new-battle-text-to-distinguish-status-move-misses-and-fails — Make new battle text to distinguish status move misses and fails
- https://github.com/pret/pokecrystal/wiki/Restore-and-localize-the-Japanese-move-grammar-table — Restore and localize the Japanese move grammar table
- https://github.com/pret/pokecrystal/wiki/Kurt-Makes-Pokeballs-Instantly — Kurt finishes Apricorn Poké Balls instantly
- https://github.com/pret/pokecrystal/wiki/Harvest-multiple-items-from-fruit-trees — Harvest multiple items from fruit trees
- https://github.com/pret/pokecrystal/wiki/Make-the-field-move-Headbutt-work-with-Kanto-trees — Make the field move Headbutt work with Kanto trees
- https://github.com/pret/pokecrystal/wiki/Prevent-Steel‐types-from-being-poisoned-by-Twineedle — Prevent Steel types from being poisoned by Twineedle
- https://github.com/pret/pokecrystal/wiki/Evolve-while-holding-an-item — Evolve while holding an item
- https://github.com/pret/pokecrystal/wiki/Display-more-information-on-the-move-screen — Display more information on the move screen
- https://github.com/pret/pokecrystal/wiki/Improve-the-enemy-trainer-AI — Improve the enemy trainer AI
- https://github.com/pret/pokecrystal/wiki/Trainers-switch-their-Pokemon-out-in-a-consecutive-order-instead-of-AI-determining-it — Trainers switch their Pokémon out in a consecutive order
- https://github.com/pret/pokecrystal/wiki/Speed-up-Pokémon-Center-Healing — Speed up Pokémon Center healing
- https://github.com/pret/pokecrystal/wiki/Increase-the-shiny-odds-of-wild-or-static-encounters-while-also-giving-red-gyarados-more-random-DV-spreads. — Increase shiny odds of wild or static encounters

### Tutorials — Removing Features
- https://github.com/pret/pokecrystal/wiki/Remove-Pokémon-sprite-animations — Remove Pokémon sprite animations
- https://github.com/pret/pokecrystal/wiki/Remove-the-25%25-failure-chance-for-AI-status-moves — Remove the 25% failure chance for AI status moves
- https://github.com/pret/pokecrystal/wiki/Remove-the-redundant-move-grammar-table — Remove the redundant move grammar table
- https://github.com/pret/pokecrystal/wiki/Removing-the-intro — Remove the opening intro
- https://github.com/pret/pokecrystal/wiki/Remove-stat-experience — Remove stat experience
- https://github.com/pret/pokecrystal/wiki/Reduce-the-command-queue-system-to-just-stone-tables — Reduce the command queue system to just stone tables
- https://github.com/pret/pokecrystal/wiki/Remove-the-gym-badges-boosts — Remove the gym badges boosts

### Tutorials — Features from Different Generations
- https://github.com/pret/pokecrystal/wiki/Physical-Special-split — Physical/Special split
- https://github.com/pret/pokecrystal/wiki/Replace-stat-experience-with-EVs — Replace stat experience with EVs
- https://github.com/pret/pokecrystal/wiki/Generation-6-Experience-System — Generation 6 Experience System
- https://github.com/pret/pokecrystal/wiki/Don't-gain-experience-at-level-100 — Don't gain experience at level 100
- https://github.com/pret/pokecrystal/wiki/Erratic-and-Fluctuating-experience-growth-rates — Erratic and Fluctuating experience growth rates
- https://github.com/pret/pokecrystal/wiki/Gain-experience-from-catching-Pokémon — Gain experience from catching Pokémon
- https://github.com/pret/pokecrystal/wiki/Lose-money-proportional-to-badges-and-level — Lose money proportional to badges and level
- https://github.com/pret/pokecrystal/wiki/Survive-poisoning-with-1-HP — Survive poisoning with 1 HP
- https://github.com/pret/pokecrystal/wiki/Don't-lose-HP-from-poisoning-in-the-overworld — Don't lose HP from poisoning in the overworld
- https://github.com/pret/pokecrystal/wiki/Show-move-names-for-TMs-and-HMs-when-receiving-or-buying — Show move names for TMs and HMs when receiving or buying
- https://github.com/pret/pokecrystal/wiki/Infinitely-reusable-TMs — Infinitely reusable TMs
- https://github.com/pret/pokecrystal/wiki/Automatically-reuse-Repel — Automatically reuse Repel
- https://github.com/pret/pokecrystal/wiki/Evolution-moves — Evolution moves
- https://github.com/pret/pokecrystal/wiki/Running-Shoes — Running Shoes
- https://github.com/pret/pokecrystal/wiki/Rock-Climb — Rock Climb
- https://github.com/pret/pokecrystal/wiki/Dive — Dive
- https://github.com/pret/pokecrystal/wiki/Automatic-battle-weather-on-certain-maps — Automatic battle weather on certain maps
- https://github.com/pret/pokecrystal/wiki/Make-Sandstorm-raise-the-Special-Defense-of-Rock-type-Pokémon-by-50%25 — Make Sandstorm raise the Special Defense of Rock-type Pokémon
- https://github.com/pret/pokecrystal/wiki/Show-an-icon-for-the-current-weather — Show an icon for the current weather
- https://github.com/pret/pokecrystal/wiki/Show-an-icon-for-the-current-Time-of-Day — Show an icon for the current Time of Day
- https://github.com/pret/pokecrystal/wiki/Puddles-that-splash-when-you-walk — Puddles that splash when you walk
- https://github.com/pret/pokecrystal/wiki/Use-GS-SGB-palettes-for-maps — Use G/S SGB palettes for maps
- https://github.com/pret/pokecrystal/wiki/Use-unique-colors-for-each-thrown-Pokémon-Ball — Use unique colors for each thrown Poké Ball
- https://github.com/pret/pokecrystal/wiki/Smashing-rocks-has-a-chance-to-contain-items — Smashing rocks has a chance to contain items
- https://github.com/pret/pokecrystal/wiki/How-To-Add-a-Pocket-PC — How To Add a Pocket PC
- https://github.com/pret/pokecrystal/wiki/Add-spinner-tiles-from-Generation-I-Rocket-Hideout — Add spinner tiles from Generation I Rocket Hideout
- https://github.com/pret/pokecrystal/wiki/Grant-Grass-type-Pokémon-immunity-to-Powder-Spore-based-moves — Grant Grass-type Pokémon immunity to Powder/Spore-based moves
- https://github.com/pret/pokecrystal/wiki/Add-Hail-as-a-new-weather-condition — Add Hail as a new weather condition
- https://github.com/pret/pokecrystal/wiki/Allow-tall-grass-in-forests — Allow tall grass in forests
- https://github.com/pret/pokecrystal/wiki/Battle-Autoprompts — Battle Autoprompts
- https://github.com/pret/pokecrystal/wiki/SWSH-Friendship-Endure — SWSH Friendship Endure
- https://github.com/pret/pokecrystal/wiki/Replace-the-Freeze-status-with-Frostbite — Replace the Freeze status with Frostbite
- https://github.com/pret/pokecrystal/wiki/Regional-forms — Regional forms
- https://github.com/pret/pokecrystal/wiki/Name-the-rival-during-the-intro — Name the rival during the intro
- https://github.com/pret/pokecrystal/wiki/Trashcan-puzzle-in-Vermilion-Gym — Trashcan puzzle in Vermilion Gym
- https://github.com/pret/pokecrystal/wiki/Splash-a-Pokédex-Entry-from-an-Overworld-Event-(Generation-I) — Splash a Pokédex Entry from an Overworld Event (Generation I)
- https://github.com/pret/pokecrystal/wiki/Reviving-Pokémon-from-Fossils-(Gen-I) — Reviving Pokémon from Fossils (Gen I)
- https://github.com/pret/pokecrystal/wiki/Inverse-Battles — Inverse Battles
- https://github.com/pret/pokecrystal/wiki/Add-a-Move-Relearner — Move Relearner/Reminder (Variant 1)
- https://github.com/pret/pokecrystal/wiki/Add-a-Move-Reminder — Move Reminder (Variant 2)
- https://github.com/pret/pokecrystal/wiki/Allow-fishing-while-surfing — Allow fishing while surfing
- https://github.com/pret/pokecrystal/wiki/Update-thaw-chances-and-sleep-turns-to-generation-7 — Update defrost chances and sleep turns
- https://github.com/pret/pokecrystal/wiki/How-to-add-a-Pocket-Move-Reminder-and-Pocket-Move-Deleter — Adding a Pocket Move Reminder and Pocket Move Deleter

### Tutorials — Custom Features
- https://github.com/pret/pokecrystal/wiki/Adding-a-Tradeback-NPC — Adding a 'Tradeback' NPC
- https://github.com/pret/pokecrystal/wiki/Adding-items-that-act-like-HMs — Items that act like HM field moves
- https://github.com/pret/pokecrystal/wiki/Level-cap — Level cap
- https://github.com/pret/pokecrystal/wiki/Customizable-Pokédex-Color — Customizable Pokédex Color
- https://github.com/pret/pokecrystal/wiki/Wall-to-wall-carpeting-in-your-room — Wall-to-wall carpeting in your room
- https://github.com/pret/pokecrystal/wiki/Disable-jumping-over-ledges-onto-obstacle-tiles-or-NPCs — Disable jumping over ledges onto obstacle tiles or NPCs
- https://github.com/pret/pokecrystal/wiki/Add-more-music-that-changes-at-night — Add more music that changes at night
- https://github.com/pret/pokecrystal/wiki/Fix-ReadNoiseSample-'inc-a'-distorting-channel-4-percussion — Tweak ReadNoiseSample
- https://github.com/pret/pokecrystal/wiki/Create-Battle-Palettes-for-Different-Times-of-Day-and-Environments — Create Battle Palettes for Different Times of Day
- https://github.com/pret/pokecrystal/wiki/Improving-the-Swarm-System — Improving the Swarm System
- https://github.com/pret/pokecrystal/wiki/Allow-using-a-field-move-if-the-Pokemon-can-learn-it — Allow using a field move if the Pokémon can learn it
- https://github.com/pret/pokecrystal/wiki/Togglable-Infinite-Repel — Togglable Infinite Repel
- https://github.com/pret/pokecrystal/wiki/Password-system — Password system
- https://github.com/pret/pokecrystal/wiki/Replace-Menu-Account-with-a-small-clock-in-the-corner-of-the-screen — Replace Menu Account with a small clock
- https://github.com/pret/pokecrystal/wiki/Fight-a-copy-of-your-own-party-in-the-Trainer-House — Fight a copy of your own party in the Trainer House
- https://github.com/pret/pokecrystal/wiki/Badge-Level-Caps — Badge-dependent Level Caps
- https://github.com/pret/pokecrystal/wiki/Scale-Gym-Leader-Teams-Based-on-Number-of-Badges — Scale Gym Leader Teams Based on Number of Badges

### Tutorials — Debug Features
- https://github.com/pret/pokecrystal/wiki/Essential-Debug-Tools — Essential Debug Tools
- https://github.com/pret/pokecrystal/wiki/Choosing-RUN-in-a-trainer-battle-makes-you-win-on-DEBUG-mode — Choosing RUN in a trainer battle makes you win on DEBUG mode
- https://github.com/pret/pokecrystal/wiki/Wild-Pokémon-Catch-Cheat-in-DEBUG-mode — Wild Pokémon Catch Cheat in DEBUG mode
- https://github.com/pret/pokecrystal/wiki/Make-Debug-Room-accessible-without-button-combination — Make Debug Room accessible without button combination
- https://github.com/pret/pokecrystal/wiki/Count-all-Pokemon-as-seen-and-caught — Count all Pokémon as seen and caught

### Tutorials — Legacy Compatibility
- https://github.com/pret/pokecrystal/wiki/Add-macros-to-support-modern-audio-files-in-legacy-pokecrystal — Add macros to support modern audio files in legacy pokecrystal

### Tutorials — Assembly Programming
- https://github.com/pret/pokecrystal/wiki/Optimizing-assembly-code — Optimizing assembly code
- https://github.com/pret/pokecrystal/wiki/Assembly-programming — Assembly programming relevant links

## Key Generated Files (do not commit)

- `*.o`, `*_debug.o`, `*_vc.o` — compiled object files
- `*.gbc`, `*.sym`, `*.map` — ROM output files
- `gfx/**/*.2bpp`, `*.lz`, `*.gbcpal` — generated graphics binaries
- `.opt.old`, `.opt.new` — temporary optimizer snapshots

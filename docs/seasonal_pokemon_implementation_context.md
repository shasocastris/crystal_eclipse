# Seasonal Pokémon — Implementation Context

**Written:** 2026-10-23, against `68-ow-weather` at `8569b7acd`.
**Status:** PLAN ONLY. Nothing here is built. D1–D4 and D8 were settled by shasocastris on
2026-10-23; the rest of §9 is open, each with a
default so work can start without blocking on them.

**Goal.** Each season's wild Pokémon draw on a source hack:

| Season | Source | Role |
|---|---|---|
| Spring | Polished Coral | most new species |
| Summer | Crystal | the base tables, unchanged |
| Autumn | Spirits and Legends | ghosts, dark and dusk |
| Winter | Pokémon Christmas | ice and festive |

Separately, the **Orange Islands** are re-themed onto the **Southern Islands TCG set** plus
its evolution families.

---

## 1. What exists today [CONFIRMED against the tree]

### Seasonal encounter engine (M2, play-tested)
- `data/wild/season_grass_data.asm` / `season_water_data.asm` — one column per season,
  `seasonmon lvl, SPECIES` per slot. SUMMER is the sentinel `-, -`; the lookup misses and
  falls through to the base Johto/Kanto table. Trailing `; lvl, SPECIES` comments record the
  base table and are checked by `utils/check_season_comments.py`.
- A map **absent** from those files uses its base table all year. That is how every cave and
  indoor map behaves now, and §5 leans on it for year-round fallbacks.
- Lookup is by map ID (`_SeasonWildmonCheck`, `engine/overworld/wildmons.asm:1098`), so
  **any** map can get seasonal columns, including Orange maps and indoor maps such as Burned Tower.
- Seasons are 7 real days (`SEASON_CYCLE_DAYS`), so the full cycle is 28 days.
- **Fishing and headbutt trees are not seasonal.** Old/Good/Super Rod and `TreeMons` are
  the same all year.

**Seasonal maps so far.** Each now has spring, autumn and winter columns, all built from
existing species:

| Type | Maps |
|---|---|
| Grass, Johto | Routes 30, 35, 45 |
| Grass, Kanto | Routes 2, 14, 25, 28 |
| Water | Lake of Rage, Routes 41, 20, 25 |

### Budget
- Seasonal data lives in `SECTION "Season Wild Data"` in bank `$75`. It is `$0602` bytes
  now, and `$2e16` (≈11.8 KB) is free. Each seasonal grass map costs ≈197 bytes (three
  non-summer tables) and each water map ≈40. §6 covers ~40 more grass maps, ~25 water maps
  and the Orange maps, ≈9.3 KB, which fits with ~2.5 KB to spare. Bank `$74` has `$1b0c`
  free if it spills. **Never free space in bank `$0a`** (M3 constraint).
- ROM overall: ≈52 banks free (`tools/bankends`).

### Species
- `NUM_POKEMON` = 276 (last real species `CURSOLA` = `$114`). Variants (`CORSOLA_KANTO`,
  `RAICHU_ORANGE`, `DRAGONITE_KANTO`, Unown forms) are numbered after it.
- **All 36 Southern Islands species are already in the dex.** The Orange rework needs no
  new species.
- Already present from the requested lists: Glaceon, Leafeon, Weavile, Mamoswine,
  Honchkrow, Mismagius. Coral's own Gen 4+ evolutions are also present: Magnezone,
  Electivire, Magmortar, Togekiss, Gliscor, Porygon-Z, Sylveon, Cursola, Wyrdeer, Farigiraf.
  Today they sit mostly in Cerulean Cave, Silver Cave and Route 28.
- **Evolution methods available:** `EVOLVE_LEVEL`, `EVOLVE_ITEM`, `EVOLVE_HAPPINESS`,
  `EVOLVE_STAT`, plus the `EVOLVE_REGION` gate.
  - No trade evolutions: Kadabra and Haunter use the **Mist Stone**.
  - No Dusk, Dawn or Shiny Stone. Dusk-style evolutions use the **Moon Stone** (Honchkrow,
    Mismagius, Weavile), and Togekiss uses the **Sun Stone**.
  - **No gender-gated evolution method.**

---

## 2. The new species — 71 of them

Union of the three lists minus what Eclipse has, minus the type-coverage cut below:
**60 from Coral, 11 more from Christmas or S&L.** `NUM_POKEMON` goes from 276 to **347**.

| Source | New to Eclipse |
|---|---|
| Christmas | Zigzagoon, Linoone, Snorunt, Glalie, Froslass, Snover, Abomasnow, Ralts, Kirlia, Gardevoir, Gallade, Rotom, Relicanth, Luvdisc |
| Spirits & Legends | Rotom, Litwick, Lampent, Chandelure |
| Coral | everything else in §4 (plus Snorunt/Glalie/Froslass, Snover/Abomasnow, Litwick line, which overlap) |

### Type-coverage cut (settled 2026-10-23)
The new species are meant to broaden the dex's type coverage. Eclipse's 280 species and
variants cover 75 type combinations. Of the 87 candidates, 40 bring a new combination; the
other 47 repeat one.

**Cut** (Tier 1: whole family repeats a crowded combination), 16 species, all spring:

| Family | Combination | Existing species with it |
|---|---|---|
| Pikipek, Trumbeak, Toucannon | Normal/Flying | 10 |
| Buneary, Lopunny | Normal | 11 |
| Minccino, Cinccino | Normal | 11 |
| Mienfoo, Mienshao | Fighting | 10 |
| Buizel, Floatzel | Water | 15+ |
| Venipede, Whirlipede, Scolipede | Bug/Poison | 4 |
| Maractus | Grass | 8 |
| Comfey | Fairy | 7 |

**Kept despite repeating:**
- Cherubi/Cherrim (Grass): the spring mascot, kept by shasocastris from Tier 1.
- Cottonee/Whimsicott (Grass/Fairy, shared only with Bellossom): shasocastris's pick.
- The Tier 2 repeats, whose combinations only 1–5 existing species share. These stay for
  now, and are the next place to look if more cuts are wanted:
  - Swablu/Altaria, Noibat/Noivern, Wingull/Pelipper, Mareanie/Toxapex
  - Cacnea/Cacturne, Drilbur/Excadrill, Dwebble/Crustle
  - Archen/Archeops, Tirtouga/Carracosta
  - Clodsire, Munchlax, Spiritomb
  - Zigzagoon/Linoone, Luvdisc, Relicanth, Snorunt/Glalie

When adding more species later, check the type combination first: one that already exists
is the first candidate to drop.

### Overlap rule
A species named by a later season's hack takes that season. So:
- The Litwick line is autumn (Coral and S&L).
- Snorunt and Snover lines are winter (Coral and Christmas).
- Rotom is autumn **and** winter (S&L and Christmas).
- Weavile and Leafeon are autumn and winter. Glaceon and Mamoswine are winter.

---

## 3. Costs of adding species [CONFIRMED where marked]

**Files per species.** The Sylveon commit `4891d191b` is the template:
- **Constants:** `constants/pokemon_constants.asm`
- **Base stats:** `data/pokemon/base_stats.asm` and `data/pokemon/base_stats/<mon>.asm`
- **Cries:** `data/pokemon/cries.asm`
- **Dex:** `dex_entries.asm`, `dex_entries/<mon>.asm`, `dex_entry_pointers.asm`,
  `dex_order_alpha.asm`, `dex_order_new.asm`, `gen1_order.asm`
- **Learnsets and evolutions:** `evos_attacks_extra.asm` and the
  `evos_attacks_*` pointers, `first_stages.asm`
- **Names, icons, palettes, pics:** `names.asm`, `icon_pointers.asm`, `menu_icon_pals.asm`,
  `palettes.asm`, `pic_pointers.asm`, `gfx/icons.asm`, `gfx/pics.asm`
- **Types:** `data/types/pokemon_type_lists.asm`
- **Footprints:** `gfx/footprints.asm` and `gfx/footprints/<mon>.png`
- **Animation tables:** `gfx/pokemon/{anim,bitmask,frame,idle}_pointers.asm`,
  `anims.asm`, `bitmasks.asm`, `idles.asm`, `johto_frames.asm`
- **Sprite folder:** `gfx/pokemon/<mon>/`

The Cursola work also found tables that had never needed to grow: both dex orderings,
`PokedexDataPointerTable`, `Footprints` and `Pokered_MonIndices`.

**Save and WRAM:**
- `wPokedexCaught` and `wPokedexSeen` are `flag_array NUM_POKEMON`, 35 bytes each today.
  At 347 they are 44 bytes each, **+18 bytes** in a WRAMX bank 1 save block that has
  `$76` (118) bytes free. Species 281 is the first that costs anything. Check the save
  canaries after the first batch.
- `wPokedexOrder` grows 2 bytes per species (+142). It is in WRAMX bank 5 with `$09e2` free, so that's fine.

**Renumbering.** Variants and Unown forms shift up by 71. Old saves holding a variant will
break. That's acceptable during development, but say so in the commit.

**Learnsets.** These have to be written in Eclipse's move list; the branch 60 learnset
overhaul set the conventions. Coral's `data/pokemon/evos_attacks.asm` is a reference, not
a drop-in, because its move constants and TM list differ. Coral's base stats carry
abilities and natures that Eclipse doesn't use; take the six stats, types, catch rate,
EXP, egg groups and growth rate.

### Sprite sources (checked across `~/Documents/Romhacks/*/gfx/pokemon/`)

Eclipse uses the pokecrystal animated front strip: `front.png` frames stacked vertically,
with `anim.asm` and `anim_idle.asm`.

**Tier A — 43 species with a drop-in strip in another local hack.** Credit the source in
the commit, as Sylveon credited Johto Legends.

| Source | Species |
|---|---|
| JohtoLegends | Aggron, Altaria, Aron, Cacnea, Cacturne, Croagunk, Froslass, Gallade, Gardevoir, Glalie, Kirlia, Lairon, Munchlax, Ralts, Snorunt, Swablu, Toxicroak |
| chattycrystal | Chandelure, Drilbur, Excadrill, Lampent, Linoone, Litwick, Pelipper, Wingull, Zigzagoon |
| MysticCrystal | Breloom, Camerupt, Carvanha, Medicham, Meditite, Numel, Sharpedo, Shroomish |
| crystal-inheritance | Abomasnow, Drifblim, Drifloon, Rotom, Snover, Spiritomb |
| GrateCrystal | Cottonee, Whimsicott |
| polishedcrystal | Clodsire |

**Tier B — 26 species animated only in Polished Coral:** Archen, Archeops, Carracosta,
Cherrim, Cherubi, Crustle, Dragapult, Drakloak, Dreepy, Dwebble, Espathra, Flittle,
Galvantula, Joltik, Larvesta, Mareanie, Mimikyu, Noibat, Noivern, Phantump, Scrafty,
Scraggy, Tirtouga, Toxapex, Trevenant, Volcarona.

- Coral ships `front.2bpp(.lz)` plus `frames.asm` and `anim0/anim1.asm`, with **no PNGs**.
- Converting needs one script: LZ-decompress, rebuild the vertical strip from `frames.asm`,
  and translate `anim0/anim1` into `anim.asm/anim_idle.asm`.
- Fallback: static 1-frame PNGs from `pokecrystal16` (DanielOlivaw), which has 914 species.

**Tier C — 2 species with static art only:** Luvdisc, Relicanth (`pokecrystal16`,
`relicanth_m`). Use a 1-frame animation, or draw frames.

Per the Pre-drawn Art rule, check `gfx/pokemon/*/` for shasocastris's own art before importing.
As of today there is none for these species.

---

## 4. Species → season → home

**Notation:**
- "Home" means where it is common. "Late" means where its evolved forms appear wild.
- **YR** marks a year-round source: a cave or indoor map left on its base table, or a
  headbutt tree (§5).
- Evolution levels are the mainline ones. Methods marked ⚑ have no direct equivalent in
  Eclipse; see D3.

### Spring — Polished Coral (45 species, after D1 and the type cut)

| Family | Evolution | Home (levels) | Late |
|---|---|---|---|
| Cherubi → Cherrim | 25 | R29, R31, National Park, R22, R24 | Cherrim R38/39 |
| Cottonee → Whimsicott | Sun Stone | R30, R32, National Park, R24/25, R13–15 | Whimsicott R28 |
| Shroomish → Breloom | 23 | R31–33, Ilex, R11 | Breloom R38/39 |
| Wingull → Pelipper | 25 | R32 grass; surf R34/40/41, Olivine, Cianwood, Vermilion, R12/13, R21 | Pelipper surf R41, R20 |
| Croagunk → Toxicroak | 37 | R32/33 (marsh), R11, R13–15 | Toxicroak R28 |
| Flittle → Espathra | 35 | R34, Ruins of Alph outside, R5/6, R24/25 | Espathra R28 |
| Swablu → Altaria | 35 | R35–37, R43, R13–15 | Altaria R28 |
| Joltik → Galvantula | 36 | National Park, R9, R10 North (Power Plant) | Galvantula Silver Cave outside |
| Meditite → Medicham | 37 | R42/43, R26/27; **YR** Mt Mortar | Medicham R26/27 |
| Scraggy → Scrafty | 39 | R7, R16–18 (Cycling Road gangs) | Scrafty R16–18 high slots |
| Carvanha → Sharpedo | 30 | surf R40/41, R19–21 | Sharpedo surf R41, R26/27 |
| Mareanie → Toxapex | 38 | surf Olivine, Cianwood, R40, R19–21, Cinnabar | Toxapex surf R20/21 |
| Numel → Camerupt | 33 | R45/46, R3/4, R16–18 | Camerupt R45 |
| Cacnea → Cacturne | 32 | R45/46, R3/4 | Cacturne R45 night |
| Larvesta → Volcarona | 59 | rare R45 day | Volcarona **YR** Silver Cave Underbelly |
| Aron → Lairon → Aggron | 32 / 42 | **YR** Union Cave, Dark Cave, Mt Moon | Lairon Rock Tunnel; Aggron Victory Road |
| Drilbur → Excadrill | 31 | **YR** Union Cave, Diglett's Cave, Rock Tunnel | Excadrill Victory Road |
| Noibat → Noivern | 48 | **YR** Union Cave night, Dark Cave, Rock Tunnel | Noivern Silver Cave, Cerulean Cave |
| Dwebble → Crustle | 34 | **YR** Whirl Islands | Crustle Whirl Islands B2F |
| Tirtouga → Carracosta | 37 | **YR** Mt Moon, rare, beside Kabuto/Omanyte (D5) | — |
| Archen → Archeops | 37 | **YR** Mt Moon, rare (D5) | — |
| Munchlax → Snorlax | happiness | **YR** rare headbutt (Route/Forest/Kanto sets) | — |
| Clodsire | ⚑ from Wooper (D4) | R32, Ruins of Alph (via Wooper) | — |

### Autumn — Spirits and Legends (12 new species with D1, plus 6 existing headliners)

| Family | Evolution | Home (levels) | Late |
|---|---|---|---|
| Litwick → Lampent → Chandelure | 41 / ⚑ Mist Stone (Dusk) | night: R29, R31, R36, National Park, R2, R7/8, R10 N; **Burned Tower** autumn column | Lampent R43 night, R16–18; Chandelure R28, Silver Cave outside |
| Rotom | — | rare night: R10 North (Power Plant), R35 (Goldenrod side) | — |
| Drifloon → Drifblim | 28 | R33, R34–37, R11, R3/4, R5/6, R13–15, R24/25 | Drifblim R28 |
| Phantump → Trevenant (D1) | ⚑ Mist Stone (trade) | R30/31, Ilex, National Park, R2, R13–15, R24/25 | Trevenant R28, Silver Cave outside |
| Mimikyu (D1) | — | rare night: R7/8 (Lavender), R37, Burned Tower | — |
| Spiritomb (D1) | — | rare night: Ruins of Alph outside | — |
| Dreepy → Drakloak → Dragapult (D1) | 50 / 60 | rare night: R45, R26/27 | Drakloak/Dragapult Silver Cave outside |
| *existing* Murkrow → Honchkrow | Moon Stone | night: R29, R1, R22, R32, R37, R43, R16–18 | Honchkrow R28, Silver Cave outside |
| *existing* Misdreavus → Mismagius | Moon Stone | night: R32, R35, R42/43, Ruins | Mismagius R28, Silver Cave outside |
| *existing* Sneasel → Weavile | Moon Stone | R42, R45 night | Weavile R28 (also winter) |
| *existing* Eevee → Leafeon | Leaf Stone | rare: R38/39 | Leafeon R28 (also winter, rare) |

Supporting cast from existing species: Houndour, Stantler, Teddiursa, Gastly/Haunter, Hoothoot/Noctowl.

### Winter — Pokémon Christmas (14 new species, plus existing headliners)

| Family | Evolution | Home (levels) | Late |
|---|---|---|---|
| Zigzagoon → Linoone | 20 | R29–33, R36, R46, Ilex, R1, R2, R3/4, R11, R22, R24/25 (replaces Sentret/Rattata) | Linoone R34–39, R5–8, R13–15, R28 |
| Ralts → Kirlia → Gardevoir / Gallade | 20 / 30 / ⚑ Kirlia + Mist Stone, any gender | R34/35, National Park, Ruins of Alph outside, R5/6 (Saffron), R24/25 | Kirlia R37–39, R7/8, R13–15; Gardevoir/Gallade rare R28 |
| Snorunt → Glalie / Froslass | 42 / ⚑ Mist Stone, any gender | R42/43, R44–45, R16–18; **YR** Ice Path | Glalie/Froslass R26/27, Silver Cave outside; **YR** Silver Cave Room 3 |
| Snover → Abomasnow | 40 | R29–33, R36–39, R42/43, R45/46, R3/4, R9/10, R13–15; **YR** Ice Path (rare) | Abomasnow R26/27, R28, Silver Cave outside |
| Rotom | — | rare night: R10 North (shared with autumn) | — |
| Relicanth | — | rare surf: R41, R20/21; **YR** Whirl Islands water | — |
| Luvdisc | — | surf: R34, R40, Cherrygrove, Olivine, R19–21, Vermilion, Pallet | — |
| *existing* Swinub → Piloswine → Mamoswine | 33 / Water Stone | R44–46, R16–18, R42/43 | Mamoswine R28 (already), Silver Cave outside |
| *existing* Eevee → Glaceon | Mist Stone | rare: R38/39 | Glaceon R28, Silver Cave outside |
| *existing* Sneasel → Weavile | Moon Stone | R42/43, R45, R16–18 | Weavile R28 (already) |
| *existing* Delibird, Smoochum/Jynx, Stantler | — | R37–39, R42–45, R16–18 | — |
| *existing* Seel/Dewgong, Shellder/Cloyster | — | surf: winter coast and lakes (Lake of Rage, R41, R20 already) | — |

The extracted Christmas wild data (Gold-based ROM, decoded from
`~/Documents/Romhacks/PokemonChristmas/christmas-v2014.gbc`) leans on Swinub/Piloswine,
Sneasel, Delibird, Jynx, Seel, Shellder, Stantler, Smeargle, Larvitar and Misdreavus. Use
that as the winter supporting cast.

---

## 5. Year-round fallbacks

With a 28-day cycle, most players pass a route in a single season. Two mechanisms give
season-exclusive species a way in without new code:

1. **Caves and indoor maps stay on their base tables** (they are never in
   `season_*_data.asm`). New species added to a cave's base table are catchable all
   year. Planned:

   | Map | Additions |
   |---|---|
   | Union Cave | Aron, Drilbur, Noibat |
   | Dark Cave | Aron, Noibat |
   | Mt Mortar | Meditite |
   | Ice Path | Snorunt, Snover |
   | Whirl Islands | Dwebble; Relicanth in water |
   | Mt Moon | Tirtouga, Archen, Aron |
   | Rock Tunnel | Drilbur, Noibat, Lairon |
   | Diglett's Cave | Drilbur |
   | Victory Road | Aggron, Excadrill |
   | Silver Cave | Noivern; Volcarona in Underbelly; Glalie/Froslass in Room 3 |
   | Cerulean Cave | Noivern, Excadrill |

   These are base-table edits. They change summer too, which is intended.
2. **Headbutt trees** aren't seasonal: Munchlax goes there.

Everything else is season-exclusive in the wild and reachable off-season only by breeding
or trade. That's deliberate: seasonal species are the reason to come back.

---

## 6. Map-by-map sketch — headliners only

Summer is the base table, unchanged. Each cell lists the 2–4 species that define the
season; when a table is written, fill the remaining slots with the base table's species
at matching levels. ✓ marks a map that already has seasonal columns; for those, the
additions merge into what's there. Night-only entries are marked *(n)*.

### Johto grass

| Map (base Lv) | Spring | Autumn | Winter |
|---|---|---|---|
| R29 (2–3) | Cherubi, Cottonee | Litwick (n), Murkrow (n) | Zigzagoon, Snover |
| R30 ✓ (3–4) | + Cottonee, Cherubi | + Phantump | + Zigzagoon, Snover (replace Rattata/Sentret) |
| R31 (5–6) | Shroomish, Cherubi | Litwick (n), Phantump | Zigzagoon, Snover |
| R32 (6–8) | Wingull, Croagunk, Cottonee, Shroomish | Misdreavus (n), Murkrow (n) | Zigzagoon, Snover, Swinub |
| R33 (9–10) | Shroomish, Croagunk | Drifloon, Phantump | Zigzagoon, Snover, Sneasel |
| Ilex Forest (11–13) | Shroomish, Cherubi, Joltik | Phantump, Litwick (n) | Zigzagoon, Snover |
| R34 (12–14) | Flittle, Swablu | Drifloon, Murkrow (n) | Ralts, Zigzagoon |
| R35 ✓ (14–18) | + Swablu, Flittle | + Drifloon, Misdreavus, Rotom (rare n) | + Ralts, Snover |
| National Park (10–15) | Cottonee, Cherubi, Joltik | Phantump, Litwick (n) | Ralts, Zigzagoon, Delibird |
| Ruins of Alph outside (18–24) | Flittle, Meditite | Spiritomb (rare n), Misdreavus | Ralts, Kirlia |
| R36 (4–6) | Swablu, Cherubi | Litwick (n), Drifloon | Zigzagoon, Snover |
| Burned Tower 1F/B1F (22–26) | — | Litwick, Mimikyu (n) | — |
| R37 (20–23) | Swablu, Joltik, Croagunk | Drifloon, Mimikyu (n), Murkrow | Linoone, Snover, Kirlia, Stantler |
| R38 / R39 (27–35) | Breloom, Cherrim, Swablu | Drifloon, Phantump, Murkrow (n), Leafeon (rare) | Linoone, Snover, Kirlia, Glaceon (rare) |
| R42 (21–26) | Meditite, Scraggy | Drifloon, Misdreavus, Sneasel | Snorunt, Snover, Linoone |
| R43 (25–27) | Meditite, Swablu | Misdreavus, Murkrow, Lampent (n), Houndour | Snorunt, Snover, Sneasel |
| R45 ✓ (31–43) | + Numel, Cacnea, Larvesta (rare) | + Dreepy (rare n), Sneasel (n) | + Snover, Snorunt (Swinub already) |
| R46 (2–3) | Cacnea, Numel | Murkrow (n) | Zigzagoon, Swinub |
| Silver Cave outside (70–74) | Galvantula, Medicham, Altaria | Chandelure, Drakloak, Trevenant, Mismagius, Honchkrow | Abomasnow, Glalie, Froslass, Weavile, Mamoswine, Glaceon |

Route 44 (the baby/nursery table) stays as it is.

### Kanto grass

| Map (base Lv) | Spring | Autumn | Winter |
|---|---|---|---|
| R1 (2–6) | Cherubi | Murkrow (n) | Zigzagoon |
| R2 ✓ (3–7) | + Cherubi, Shroomish | + Phantump, Litwick (n) | + Zigzagoon, Snover |
| R22 (3–7) | Cherubi, Cottonee | Murkrow (n) | Zigzagoon |
| R3 / R4 (5–10) | Numel, Cacnea | Drifloon | Snover, Zigzagoon |
| R5 / R6 (12–15) | Flittle, Swablu | Drifloon | Ralts, Zigzagoon |
| R7 / R8 (16–20) | Scraggy, Flittle | Litwick (n), Mimikyu (n), Drifloon | Ralts, Kirlia, Linoone |
| R9 / R10 North (15–18) | Joltik, Wingull (surf) | Rotom (rare n, R10 N), Litwick (n) | Rotom (rare n, R10 N), Snover |
| R11 (13–16) | Croagunk, Shroomish | Drifloon | Zigzagoon, Linoone |
| R13 / R14 ✓ / R15 (23–30) | Swablu, Cottonee, Croagunk | Phantump, Drifloon | Snover, Linoone, Kirlia |
| R16 / R17 / R18 (26–33) | Scraggy, Croagunk, Numel | Murkrow (n), Lampent (n) | Snorunt, Sneasel, Delibird, Swinub |
| R21 (20–35) | Wingull | — | Luvdisc (surf) |
| R24 / R25 ✓ (8–14) | Cottonee, Flittle, Cherubi | Phantump, Drifloon | Zigzagoon, Ralts |
| R26 / R27 | Meditite, Medicham, Scrafty | Dreepy (rare n), Honchkrow | Snover, Abomasnow, Glalie |
| R28 ✓ (69–73) | + Altaria, Whimsicott, Espathra, Toxicroak, Breloom, Scrafty | + Drifblim, Trevenant, Chandelure, Honchkrow, Mismagius, Leafeon | + Abomasnow, Gardevoir/Gallade, Glaceon, Linoone (Weavile/Mamoswine/Delibird/Jynx already) |
| Safari Zone (45) | D7 | D7 | D7 |

### Water (surf) — seasonal columns to add

| Season | Maps and species |
|---|---|
| **Spring** | Freshwater routes (R30–32, R35, R42, R4, R9/10, R24/25) have no new species since the Buizel cut; use Coral-dex Marill, Poliwag and Wooper. Wingull/Pelipper: R34, R40/41, Olivine, Cianwood, Cherrygrove, Vermilion, R12/13. Carvanha/Sharpedo: R40/41, R19–21, R26/27. Mareanie/Toxapex: Olivine, Cianwood, R40, R19–21, Cinnabar. |
| **Autumn** | Existing species only, night-heavy: Chinchou/Lanturn, Tentacruel, Gyarados at Lake of Rage (already). |
| **Winter** | Luvdisc: R34, R40, Cherrygrove, Olivine, R19–21, Vermilion, Pallet. Relicanth: rare R41, R20/21. Seel/Dewgong and Shellder/Cloyster: coasts. |

---

## 7. Orange Islands — Southern Islands set

### The set (36) and the families pulled in with it
- **Kanto starters:** Ivysaur (Bulbasaur, Venusaur), Wartortle (Squirtle, Blastoise),
  Charizard (Charmander, Charmeleon).
- **Bugs:** Caterpie/Metapod/Butterfree, Ledyba/Ledian, Paras/Parasect, Venonat/Venomoth.
- **Grass:** Oddish/Gloom/Vileplume/Bellossom, Bellsprout (Weepinbell, Victreebel),
  Exeggcute/Exeggutor.
- **Normal and fighting:** Pidgeot (Pidgey, Pidgeotto), Raticate (Rattata), Meowth (Persian),
  Jigglypuff (Igglybuff, Wigglytuff), Primeape (Mankey, Annihilape), Aipom (Ambipom),
  Lickitung (Lickilicky), Togepi (Togetic, Togekiss).
- **Electric:** Pikachu (Pichu, Raichu, and **`RAICHU_ORANGE`**, Thunder Stone in Orange,
  already wired).
- **Water:** Goldeen (Seaking), Horsea (Seadra, Kingdra), Krabby (Kingler), Lapras,
  Magikarp (Gyarados), Marill (Azurill isn't in the dex; Azumarill), Poliwag (Poliwhirl,
  Poliwrath, Politoed), Psyduck (Golduck), Seel (Dewgong), Slowking (Slowpoke, Slowbro),
  Tentacruel (Tentacool).
- **Rock:** Onix (Steelix).
- **Mythical:** Mew, as a move tutor only (branch 39 makes it uncatchable).

### Today's Orange data, and what changes

`data/wild/orange_grass.asm`, `orange_water.asm`, `fish.asm` (`.Orange_*`) and
`treemons.asm` (`TreeMonSet_Orange`).

Species there now that are **not** in the set and get replaced (D6):
- Grass: Spearow, Tangela, Zubat, Geodude, Machop.
- Water: Chinchou, Lanturn, Staryu, Corsola.
- Headbutt: Pineco, Heracross.
- Fishing: `TimeFishGroups` entry 0 (Corsola/Staryu).

| Source | Base (summer) | Seasonal Pokémon (D2) |
|---|---|---|
| **Shamouti Island grass** (22–28) | Oddish/Gloom, Bellsprout/Weepinbell, Exeggcute, Pikachu, Pidgeotto, Meowth, Raticate (n), Venonat (n) | Spring: Vileplume/Bellossom, Butterfree, Ledyba/Ledian, Jigglypuff. Autumn: Venomoth (n), Primeape, Persian, Lickitung (rare). Winter: Pidgeot (rare), Exeggutor, Wigglytuff, Togepi (rare) |
| **Shamouti Cave grass** (28–34) | Onix, Paras/Parasect, Mankey/Primeape, Psyduck, Marill, Slowpoke | stays year-round: it's a cave, and the fallback for the island's set |
| **Valencia Port surf** | Tentacool, Tentacruel, Krabby | — |
| **Valencia Island surf** | Psyduck, Poliwag, Marill | Spring: Golduck, Azumarill |
| **Shamouti Passage surf** | Tentacruel, Horsea, Seel | Winter: Lapras (rare), Dewgong |
| **Shamouti Island surf** | Goldeen, Seel, Slowpoke | Autumn: Seaking, Slowbro |
| **Shamouti Cave surf** | Psyduck, Slowpoke, Marill | year-round |
| **Fishing `.Orange_*`** | Old: Magikarp, Goldeen, Krabby. Good: Goldeen, Krabby, Horsea, Poliwag. Super: Gyarados, Seaking, Kingler, Seadra | not seasonal |
| **Headbutt `TreeMonSet_Orange`** | common: Exeggcute, Aipom, Pikachu, Ledyba. rare: Metapod, Butterfree | not seasonal |

Valencia Island has no grass table today. Check its `.ablk` for grass before planning
one.

### Statics and gifts (D8)

| Species | Proposal |
|---|---|
| Slowking | Static or gift at Shamouti: the Movie 2000 shrine keeper |
| Lapras | Static in Shamouti Passage; Union Cave already has one |
| Charizard, Wartortle, Ivysaur | NPC gifts or trades on Valencia/Shamouti |
| Togepi | Egg gift |
| Mew | **Moves to the Orange Islands** (D8). Today it is the Dark Cave Blackthorn Entrance static. Move the encounter rather than duplicating it, so `EVENT_FOUGHT_MEW` comes along and no new flag is needed. Since branch 39 it is a tutor scene (AURA_SPHERE), not a battle. It is now in Shamouti Cave, after the Elite Four rematch |

**The event-flag list is full at 2048.** Every new static or gift must claim a
`const_skip ; unused in Crystal` slot, not grow `wEventFlags` (M3 constraint).

### Notes for Orange seasonal tables
- Orange seasons change **Pokémon only**. The Orange weather rows in
  `engine/events/overcast.asm` (`49a79f72b`) and the no-snow, summer-palette-all-year
  behaviour stay exactly as they are. Don't theme the encounter columns on wet/dry.
- This reverses the M3 "tropical, no seasonal variants" call for encounters only. Update the
  header comments in `orange_*.asm` to say so.
- `check_season_comments.py` only reads the Johto and Kanto base tables. Extend it to
  `orange_grass.asm` / `orange_water.asm` before adding Orange rows, or their
  `; SUMMER = base` comments go unchecked.

---

## 8. Phases

Each phase builds, passes the `optimize.py` diff and `farcheck`, and is play-testable alone.

**Phase 0 — decisions and audit.** Settle §9 (defaults are fine). Re-measure bank `$75`
and the WRAMX bank 1 slack on the current tree.

**Phase 1 — existing species only, no dex change.**
1. **Orange rework (§7):** base tables, fishing, headbutt, then the Orange seasonal
   columns. Statics and gifts last; they need event flags. Moving Mew reuses its own flag.
2. **Existing-species seasonal headliners:**
   - Autumn: Murkrow/Honchkrow, Misdreavus/Mismagius, Sneasel/Weavile, Leafeon.
   - Winter: Swinub line, Glaceon, Delibird, Jynx, Seel, Stantler.
3. **Extend seasonal coverage** to every map in §6 using existing species only. New
   species slot into existing columns later; nothing needs restructuring.

At the end of Phase 1 the whole seasonal map is play-testable before any species work.

**Phase 2 — species plumbing.** Add the first new species end to end, as a vertical slice:
Zigzagoon, which is Tier A and needs only a level evolution. Confirm:
- Every table in §3 grows.
- Variants renumber cleanly.
- The save block still fits and the canaries hold.
- The dex and the type-completion boost count it.

**Phase 3 — species batches.** Each batch is one branch: species data, then sprites, then
encounter rows.

| Batch | Species | Sprites |
|---|---|---|
| **W — Christmas** (14) | Zigzagoon, Linoone, Ralts, Kirlia, Gardevoir, Gallade, Snorunt, Glalie, Froslass, Snover, Abomasnow, Rotom, Relicanth, Luvdisc | all Tier A except Relicanth and Luvdisc (Tier C) |
| **A — Spirits and Legends** (12) | Litwick, Lampent, Chandelure, Drifloon, Drifblim, Phantump, Trevenant, Mimikyu, Spiritomb, Dreepy, Drakloak, Dragapult | mixed; the Coral converter is needed for Phantump, Mimikyu and the Dreepy line |
| **S1 — Coral, Tier A** (25) | Wingull, Pelipper, Shroomish, Breloom, Aron, Lairon, Aggron, Meditite, Medicham, Carvanha, Sharpedo, Numel, Camerupt, Cacnea, Cacturne, Swablu, Altaria, Munchlax, Croagunk, Toxicroak, Drilbur, Excadrill, Cottonee, Whimsicott, Clodsire | ready |
| **S2 — Coral, Tier B** (20) | Cherubi, Cherrim, Joltik, Galvantula, Larvesta, Volcarona, Scraggy, Scrafty, Flittle, Espathra, Mareanie, Toxapex, Dwebble, Crustle, Noibat, Noivern, Tirtouga, Carracosta, Archen, Archeops | needs the Coral sprite converter, written once |

Batch W comes first: it is small, almost all Tier A, and it lights up winter, the season
with the most visual work behind it already.

**Phase 4 — polish.**
- Trainer parties using the new species (follow branch 61's format).
- Bug Catching Contest additions (D7).
- Dex entries and Pokégear AREA checks.
- Credits for imported art.

---

## 9. Decisions (settled ones marked ✅; open ones show their default in **bold**)

| # | Question | Default |
|---|---|---|
| D1 ✅ | Coral's ghosts and the Dreepy line read as autumn, not spring. Move Drifloon, Phantump, Mimikyu, Spiritomb and Dreepy (and their evolutions) to autumn? | **Yes** (settled). Noibat stays spring/YR (caves). |
| D2 ✅ | Give the Orange Islands seasonal columns? | **Yes, Pokémon only** (settled). Seasons change which species appear; Orange weather stays as built. Grass and two surf maps; caves, fishing and headbutt stay year-round. |
| D3 ✅ | Evolution methods with no Eclipse equivalent | **Mist Stone for Dusk, Shiny, Dawn/gender and trade** (settled): Chandelure, Trevenant, Gallade (Kirlia + Mist Stone, any gender) and Froslass (Snorunt + Mist Stone, any gender). Whimsicott keeps its canonical Sun Stone. No gender gate. **Existing species switch too** (settled): Honchkrow, Mismagius and Weavile go from Moon Stone, and Togekiss from Sun Stone, to Mist Stone. That's a data-only change in `evos_attacks_johto.asm`. |
| D4 ✅ | How does Clodsire exist? Coral used a Paldean Wooper. | **`EVOLVE_REGION` gate:** Wooper caught and raised in Kanto evolves into Clodsire at 20; in Johto, Quagsire (settled). |
| D5 | Tirtouga/Archen: wild in Mt Moon (as Kabuto/Omanyte are) or fossil revival? | **Wild, rare, Mt Moon.** |
| D6 | Orange strictness: only the set plus its families, or keep filler (Zubat/Geodude in the cave)? | **Strict.** Onix, Paras and Mankey fill the cave. |
| D7 | Safari Zone and Bug Contest: seasonal? | **Safari stays as it is for now.** The Bug Contest gets Joltik in spring only if contest tables become seasonal; until then it's untouched. |
| D8 | Orange statics: Mew and the starter middle stages | ✅ **Mew moves to the Orange Islands** (settled); reuse `EVENT_FOUGHT_MEW`. Open: Slowking and Lapras statics; Charizard, Wartortle and Ivysaur as NPC trades. Each of those needs a reclaimed event flag. |
| D9 | Spring tables: should they use **only** species in Coral's dex (Coral has no Hoppip, Sentret, Hoothoot, Spinarak, Caterpie, Weedle…)? | **Soft rule:** prefer Coral-dex species and keep the existing spring Hoppip columns. |
| D11 | Location evolutions for Leafeon and Glaceon (proposed, shasocastris interested) | **New `EVOLVE_LANDMARK` gate** modelled on `EVOLVE_REGION`: `db EVOLVE_LANDMARK, LANDMARK_X` guards the next entry, and `dbbw EVOLVE_LEVEL, 1, LEAFEON` under it means "levels up while there". Leafeon: Ilex Forest (Moss Rock). Glaceon: Ice Path (Ice Rock). See §11. |
| D10 | Where do the 71 sit in the regional dex (`dex_order_new.asm`)? | **Your call.** Numbering is fixed (after Cursola); display order is free. |

---

## 10. Gotchas carried over

- **16-bit IDs.** Runtime 8-bit IDs are dynamic slots, not species constants. Wild tables
  use `dbw lvl, SPECIES` with 16-bit indexes; code must convert with
  `GetPokemonIndexFromID`/`GetPokemonIDFromIndex`.
- **Never poke `wSeason` (`$dbf0`) in a test where a day passes.** Poke `wStartDay`
  (`$d4b5`) to move the calendar (seasons_status.md §2).
- **Re-run `utils/check_season_comments.py`** after every base-table edit, especially the
  §5 cave additions, which change summer.
- **No emulator on this box.** Table contents can be verified statically by decoding the
  built ROM, as the Kanto seasonal commit did; encounters themselves need shasocastris to play-test.
- **18-character text lines** for any new NPC or dex text.

---

## 11. Location evolution — `EVOLVE_LANDMARK` (proposed) [CONFIRMED against the tree]

No location method exists. The `EVOLVE_REGION` gate (`constants/pokemon_data_constants.asm`,
used today by `RAICHU_ORANGE` and Dragonair → `DRAGONITE_KANTO`; planned for Clodsire, D4) is the template: a 2-byte gate that
guards the single entry after it.

**Data.** Put the gated entries *before* Eevee's happiness entries. Otherwise a happy Eevee
levelling in Ilex Forest becomes Espeon or Umbreon first, since the first matching entry wins.

```
	db   EVOLVE_LANDMARK, LANDMARK_ILEX_FOREST
	dbbw EVOLVE_LEVEL, 1, LEAFEON
	db   EVOLVE_LANDMARK, LANDMARK_ICE_PATH
	dbbw EVOLVE_LEVEL, 1, GLACEON
```

Drop the `LEAF_STONE` / `MIST_STONE` entries for those two.

**Code: four parse sites, all in `engine/pokemon/evolve.asm`.**
- `EvolveAfterBattle` `.loop`: the gate check, beside `EVOLVE_REGION`.
- `SkipEvolutions`: a 2-byte skip, beside `EVOLVE_REGION`. This also covers the move reminder
  through `FarSkipEvolutions`.
- `DetermineEvolutionItemResults` `.region`: the item-use and party-menu "ABLE" path.
- The `.dont_evolve_check` sizes, if the gate is routed through it.

`EVOLVE_REGION` and `EVOLVE_LANDMARK` can share one gate path that differs only in what is
compared.

**Comparison.** Use `GetPlayerLandmark` (`home/region.asm`), not `wCurLandmark`. That's only
written by the map-name sign. A landmark covers every floor of Ice Path and both halves
of Ilex Forest; an indoor map with `LANDMARK_SPECIAL` reports the map that led into it.

**Behaviour.**
- Evolution runs after the battle on the current map, and when a Rare Candy is used, so
  both work at the spot.
- Gates don't nest, so a gate can't be combined with a region gate.
- Wild Leafeon (R28, Cerulean Cave) and wild Glaceon (R28, Silver Cave Room 3) stay as
  they are.


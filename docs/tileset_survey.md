# Tileset survey: Eclipse vs Polished Crystal, Polished Coral, JohtoLegends

Surveyed 2026-11-11. How full each tileset and blockset is, which maps use which
tileset, and what the overworld graphics cost in ROM space. Meant to inform
future graphics work for Eclipse.

| Repo | Commit | Tilesets | Maps | Tile capacity | Tilesets using GFX2 | Tilesets at 256 blocks |
|---|---|---|---|---|---|---|
| Polished Crystal | `b3dc0406c` (2026-08-19) | 52 | 608 | 384 | 6 | 1 |
| Crystal Eclipse | `d158bfd54` (`core`, 2026-11-11) | 37 | 426 | 384 | 0 | 0 |
| Polished Coral | `8c7829f1` (2025-12-15) | 43 | 403 | 384 | 30 | 18 |
| JohtoLegends | `9a970df7` (2024-12-09) | 44 | 446 | 255 | n/a | 0 |

## How to read the tables

- **GFX0 / GFX1 / GFX2** are the three 128-tile VRAM slots: bank 0 `$00-$7f`,
  bank 1 `$00-$7f`, bank 1 `$80-$ff`. In Eclipse these are `vTiles2`,
  `vTiles5`, `vTiles4`. Only 127 tiles of GFX0 are loaded (`$7f` is skipped).
  JohtoLegends has one 255-tile file and no third slot.
- **Drawn** counts non-blank tiles in the source PNG.
- **Used** counts distinct tiles the blocks reference. It includes the blank
  tile, so it can exceed Drawn by one. A low Used against Drawn usually means
  the art is shared with a sibling tileset.
- **Blocks** is the blockset size; the cap is 256.
- Roof tilesets have tiles `$0a-$12` of GFX0 overwritten by the 9 map-group
  roof tiles.

## What this means for Eclipse

- **Headroom is large.** No Eclipse tileset draws into the third slot, and most
  interiors are still at the vanilla 64 blocks. Kanto serves 38 maps with 110
  tiles and 132 blocks (about 270 tile slots and 124 blocks free); Johto has
  about 155 tile slots and 75 blocks free.
- **Johto is the most loaded tileset.** It carries 34 maps including Valencia
  Island, Shamouti Island and Shamouti Passage. Polished Crystal spreads the
  same ground over nine outdoor tilesets (six Johto variants, Shamouti,
  Valencia, Snowtop).
- **Kanto is the least differentiated.** Polished Crystal splits it into Kanto,
  Kanto North, Kanto Urban and Indigo Plateau. JohtoLegends has 80 more Kanto
  tiles and 85 more blocks than Eclipse for the same 38 maps.
- **Caves are thin.** Cave and Dark Cave draw 67 and 64 tiles. Polished
  Crystal's Cave has 177 tiles and 242 blocks, plus separate Quiet Cave, Tunnel
  and Peaks sets.
- **Regional splits are cheap if the base is shared.** Seven Polished Crystal
  Johto tilesets share one GFX0 file (`johto_common`) and four Kanto tilesets
  share another (`kanto_common`); each variant only adds its own GFX1 art and
  blocks. Johto Sacred also reuses Johto Traditional's GFX1/GFX2, and Johto
  Coast reuses Johto Modern's.
- **Block count tracks map variety, not map count.** Polished Crystal's Johto
  Traditional fills all 256 blocks with 21 maps, while Cave covers 50 maps in
  242.
- **Coral shows the ceiling.** 18 of its tilesets sit at exactly 256 blocks and
  several draw 360-380 of 384 tiles. Some of the 256s may be padding (Train
  references only 39 tiles); duplicate blocks were not checked there.

## ROM space

Overworld graphics are a small slice of every ROM and do not drive ROM size.

| Repo | ROM size | ROM used / free | Tile graphics | Blocks + attributes + collision | Tileset total | Share of ROM | Map layouts |
|---|---|---|---|---|---|---|---|
| Polished Crystal 3.2.3 | 2 MB | 2,078 KB / 2.4 KB | 85.2 KB | 79.0 KB | 164.2 KB | 7.8% | 44.9 KB |
| Crystal Eclipse | 2 MB | 1,767 KB / 330 KB | 50.3 KB | 34.1 KB | 84.3 KB | 4.0% | 38.4 KB |
| Polished Coral | 4 MB | 2,367 KB / 1,827 KB | 126.5 KB | 118.5 KB | 245.0 KB | 5.8% | 37.7 KB |
| JohtoLegends | 4 MB | not reported | 62.5 KB | 149.0 KB | 211.5 KB | 5.0% | 45.4 KB |

Sizes are of the files each ROM includes, shared files counted once. Used/free
comes from each repo's linker map. Overworld sprites, roofs and tile animations
are not included.

- Per tileset: Eclipse about 2.3 KB, Polished Crystal 3.2 KB, JohtoLegends
  4.8 KB, Coral 5.7 KB.
- A maxed tileset (384 tiles, 256 blocks) is about 15 KB raw and likely
  6-8 KB compressed, going by Coral's fullest sets. Eclipse's free space would
  hold roughly 40 of those.
- The real constraint in Eclipse is bank placement. The `tileset` macro stores
  one bank byte for all three graphics slots, so a tileset's graphics must sit
  together in one 16 KB bank.

### Compression vs sharing

Two separate savings. Compression is LZ on each file, unpacked at map load.
Sharing is several tilesets pointing at the same file, stored once.

| Repo | Graphics | Blocks | Attributes | Collision |
|---|---|---|---|---|
| Polished Crystal | compressed | compressed | compressed | compressed |
| Crystal Eclipse | compressed | compressed | compressed | raw |
| Polished Coral | compressed | compressed | compressed | raw |
| JohtoLegends | compressed | raw | raw | raw |

Example, Polished Crystal's Johto Traditional: graphics 2,048 to 1,471 bytes,
blocks 4,096 to 1,763, attributes 4,096 to 939, collision 1,024 to 370.
Compressing Eclipse's collision would save little; it is 9.7 KB raw in total.

## Crystal Eclipse

| Tileset | GFX0 | GFX1 | GFX2 | Drawn | Used | Blocks | Maps | Graphics file |
|---|---|---|---|---|---|---|---|---|
| Johto | 125 | 103 | – | 228 | 193 | 181 | 34 | johto |
| Johto Modern | 95 | 96 | – | 191 | 116 | 132 | 4 | johto_modern |
| Kanto | 110 | – | – | 110 | 102 | 132 | 38 | kanto |
| Battle Tower Outside | 95 | 96 | – | 191 | 124 | 128 | 1 | johto_modern |
| House | 96 | – | – | 96 | 96 | 64 | 62 | house |
| Players House | 94 | – | – | 94 | 90 | 64 | 7 | players_house |
| Pokecenter | 115 | 6 | – | 121 | 115 | 64 | 32 | pokecenter |
| Gate | 101 | 6 | – | 107 | 101 | 64 | 32 | gate |
| Port | 94 | – | – | 94 | 95 | 64 | 4 | port |
| Lab | 95 | 90 | – | 185 | 187 | 64 | 6 | lab |
| Facility | 106 | 6 | – | 112 | 108 | 88 | 10 | facility |
| Mart | 99 | 83 | – | 182 | 178 | 65 | 28 | mart |
| Mansion | 106 | 95 | – | 201 | 189 | 76 | 5 | mansion |
| Game Corner | 95 | 79 | – | 174 | 167 | 64 | 7 | game_corner |
| Elite Four Room | 96 | – | – | 96 | 92 | 64 | 13 | elite_four_room |
| Traditional House | 120 | – | – | 120 | 117 | 76 | 14 | traditional_house |
| Train Station | 93 | 4 | – | 97 | 94 | 64 | 5 | train_station |
| Champions Room | 95 | 94 | – | 189 | 179 | 64 | 3 | champions_room |
| Lighthouse | 92 | 7 | – | 99 | 102 | 64 | 11 | lighthouse |
| Players Room | 96 | – | – | 96 | 96 | 64 | 1 | players_room |
| Pokecom Center | 101 | 96 | – | 197 | 185 | 66 | 2 | pokecom_center |
| Battle Tower Inside | 95 | 1 | – | 96 | 94 | 64 | 4 | battle_tower_inside |
| Tower | 95 | 32 | – | 127 | 94 | 64 | 18 | tower |
| Cave | 67 | – | – | 67 | 47 | 74 | 18 | cave |
| Park | 95 | 5 | – | 100 | 97 | 72 | 3 | park |
| Ruins Of Alph | 99 | 96 | – | 195 | 78 | 64 | 9 | ruins_of_alph |
| Radio Tower | 95 | 31 | – | 126 | 124 | 66 | 10 | radio_tower |
| Underground | 95 | – | – | 95 | 74 | 64 | 9 | underground |
| Ice Path | 98 | 86 | – | 184 | 161 | 88 | 10 | ice_path |
| Dark Cave | 64 | – | – | 64 | 47 | 74 | 19 | dark_cave |
| Forest | 66 | 94 | – | 160 | 59 | 40 | 1 | forest |
| Beta Word Room | 99 | 96 | – | 195 | 111 | 64 | 0 | ruins_of_alph |
| Ho Oh Word Room | 99 | 96 | – | 195 | 102 | 64 | 1 | ruins_of_alph |
| Kabuto Word Room | 99 | 96 | – | 195 | 94 | 64 | 1 | ruins_of_alph |
| Omanyte Word Room | 99 | 96 | – | 195 | 98 | 64 | 1 | ruins_of_alph |
| Aerodactyl Word Room | 99 | 96 | – | 195 | 98 | 64 | 1 | ruins_of_alph |
| Museum | 94 | – | – | 94 | 78 | 38 | 2 | museum |

- **Johto (34):** every Johto town and route except Azalea, Goldenrod and
  Routes 33/34, plus Ruins of Alph Outside, Dragon's Den B1F, Blackthorn Pass,
  Mount Moon Square, Valencia Island, Shamouti Island, Shamouti Passage.
- **Johto Modern (4):** Azalea, Goldenrod, Routes 33 and 34.
- **Kanto (38):** all of Kanto outdoors, plus Route 28 and Silver Cave Outside.
- **Cave (18):** Union Cave, Slowpoke Well, Mt. Moon, Victory Road, Diglett's
  Cave, Dragon's Den 1F, Burned Tower B1F, Seafoam Gym, Shamouti Cave, parts of
  Silver Cave.
- **Dark Cave (19):** Mt. Mortar, Whirl Islands, Dark Cave, Tohjo Falls, Rock
  Tunnel, Cerulean Cave, Silver Cave Room 1.
- **Ice Path (10):** Ice Path, Ice Path Hollow 1F/2F, Seafoam Caves, Silver
  Cave Room 3, Hall of Fame.
- **Tower (18):** Sprout/Tin/Burned Tower, plus Ecruteak, Pewter and Cianwood
  gyms.

Full lists: [maps_crystal_eclipse.md](tileset_survey/maps_crystal_eclipse.md).

## Polished Crystal

| Tileset | GFX0 | GFX1 | GFX2 | Drawn | Used | Blocks | Maps | Graphics file |
|---|---|---|---|---|---|---|---|---|
| Johto Traditional | 126 | 127 | 39 | 292 | 264 | 256 | 21 | johto_common |
| Johto Modern | 126 | 127 | 64 | 317 | 205 | 183 | 5 | johto_common |
| Johto Coast | 126 | 127 | 64 | 317 | 252 | 240 | 10 | johto_common |
| Johto Outlands | 126 | 98 | – | 224 | 221 | 239 | 12 | johto_common |
| Johto Ancient | 126 | 88 | – | 214 | 157 | 153 | 2 | johto_common |
| Johto Sacred | 126 | 127 | 39 | 292 | 184 | 134 | 5 | johto_common |
| Battle Tower Outside | 126 | 75 | – | 201 | 117 | 42 | 1 | johto_common |
| Snowtop Mountain | 127 | 90 | – | 217 | 196 | 140 | 1 | snowtop_mountain |
| Kanto | 126 | 47 | – | 173 | 167 | 216 | 23 | kanto_common |
| Kanto North | 126 | 49 | – | 175 | 162 | 192 | 8 | kanto_common |
| Kanto Urban | 126 | 88 | – | 214 | 203 | 248 | 7 | kanto_common |
| Indigo Plateau | 126 | 73 | – | 199 | 158 | 252 | 13 | kanto_common |
| Shamouti Island | 125 | 94 | – | 219 | 214 | 219 | 11 | shamouti_island |
| Valencia Island | 74 | – | – | 74 | 74 | 42 | 2 | valencia_island |
| Faraway Island | 121 | – | – | 121 | 122 | 120 | 2 | faraway_island |
| Johto House | 126 | 90 | – | 216 | 217 | 157 | 46 | johto_house |
| Kanto House | 126 | 109 | – | 235 | 234 | 148 | 51 | kanto_house |
| Traditional House | 127 | 9 | – | 136 | 127 | 78 | 16 | traditional_house |
| Poke Center | 126 | 17 | – | 143 | 144 | 73 | 25 | pokecenter |
| Poke Com Center | 126 | 98 | – | 224 | 219 | 92 | 2 | pokecom_center |
| Mart | 127 | 59 | – | 186 | 186 | 99 | 28 | mart |
| Gate | 126 | 8 | – | 134 | 135 | 149 | 46 | gate |
| Gym | 126 | 127 | 7 | 260 | 249 | 246 | 12 | gym |
| Magnet Train | 72 | – | – | 72 | 54 | 24 | 2 | magnet_train |
| Champions Room | 126 | 19 | – | 145 | 144 | 44 | 3 | champions_room |
| Port | 125 | 21 | – | 146 | 147 | 60 | 6 | port |
| Lab | 126 | 45 | – | 171 | 172 | 53 | 5 | lab |
| Facility | 126 | – | – | 126 | 126 | 98 | 11 | facility |
| Mansion | 118 | – | – | 118 | 117 | 60 | 4 | celadon_mansion |
| Game Corner | 126 | – | – | 126 | 126 | 49 | 5 | game_corner |
| Decor | 98 | – | – | 98 | 99 | 57 | 4 | home_decor_store |
| Museum | 126 | 70 | – | 196 | 197 | 120 | 19 | museum |
| Hotel | 115 | – | – | 115 | 116 | 77 | 13 | hotel |
| Tower | 127 | 127 | – | 254 | 189 | 170 | 20 | sprout_tower |
| Battle Tower Inside | 111 | – | – | 111 | 110 | 55 | 5 | battle_tower_inside |
| Radio Tower | 126 | 26 | – | 152 | 152 | 117 | 15 | radio_tower |
| Lighthouse | 106 | – | – | 106 | 107 | 109 | 14 | lighthouse |
| Underground | 80 | – | – | 80 | 75 | 111 | 4 | underground |
| Cave | 126 | 51 | – | 177 | 177 | 242 | 50 | cave |
| Quiet Cave | 60 | – | – | 60 | 52 | 72 | 5 | quiet_cave |
| Ice Path | 127 | 31 | – | 158 | 158 | 82 | 11 | ice_path |
| Tunnel | 126 | 40 | – | 166 | 159 | 113 | 6 | tunnel |
| Forest | 126 | 80 | – | 206 | 199 | 188 | 4 | forest |
| Park | 104 | – | – | 104 | 104 | 71 | 2 | park |
| Safari Zone | 90 | – | – | 90 | 90 | 76 | 4 | safari_zone |
| Ruins Of Alph | 85 | 116 | – | 201 | 165 | 182 | 15 | ruins_of_alph |
| Pokemon Mansion | 126 | 36 | – | 162 | 162 | 116 | 3 | pokemon_mansion |
| Battle Factory | 126 | 62 | – | 188 | 183 | 79 | 3 | battle_factory |
| Hidden Grotto | 36 | – | – | 36 | 36 | 38 | 2 | hidden_grotto |
| Peaks | 108 | – | – | 108 | 107 | 140 | 6 | peaks |
| Hideout | 126 | 26 | – | 152 | 151 | 152 | 8 | hideout |
| Kanto Gym | 126 | 61 | – | 187 | 188 | 200 | 10 | kanto_gym |

Outdoor split:

| Tileset | Maps |
|---|---|
| Johto Traditional (21) | New Bark, Cherrygrove, Violet, Ecruteak, Mahogany; Routes 26, 27, 29-32, 35-37, 42, 44; Violet Outskirts, Cherrygrove Bay, Magnet Tunnel East |
| Johto Modern (5) | Goldenrod, Route 34, Route 34 Coast, Stormy Beach, Magnet Tunnel West |
| Johto Coast (10) | Olivine, Cianwood, Routes 38-41, Route 35 Coast, Goldenrod Harbor |
| Johto Outlands (12) | Azalea, Blackthorn, Lake of Rage, Routes 33, 43, 45-48, Rugged Road, Snowtop Mountain Inside |
| Johto Ancient (2) | Ruins of Alph Outside, Sinjoh Ruins |
| Johto Sacred (5) | Route 28, Silver Cave Outside, Bellchime Trail, Ecruteak Shrine Outside, Dragon's Den B1F |
| Kanto (23) | Pallet, Viridian, Pewter, Lavender, Fuchsia, Cinnabar; Routes 1-3, 8, 10 South, 12 North, 16 West/North, 18 East, 19-22; Mt. Moon Square, Uraga Channel West |
| Kanto North (8) | Cerulean, Routes 4, 5, 9, 10 North, 24, 25, Cerulean Cape |
| Kanto Urban (7) | Vermilion, Celadon, Saffron, Routes 6, 7, 11, 16 East |
| Indigo Plateau (13) | Indigo Plateau, Routes 12 South, 13-15, 17, 18 West, 23, Lucky Island, Uraga Channel East |
| Shamouti Island (11) | Shamouti and its beaches/coast, Noisy Forest, Navel Rock Outside, bird-island roofs, Shrine Ruins |
| Valencia Island (2) | Valencia Island, Route 49 |
| Faraway Island (2) | Faraway Island, Faraway Jungle |

Full lists: [maps_polishedcrystal.md](tileset_survey/maps_polishedcrystal.md).

## Polished Coral

| Tileset | GFX0 | GFX1 | GFX2 | Drawn | Used | Blocks | Maps | Graphics file |
|---|---|---|---|---|---|---|---|---|
| Player Room | 126 | – | – | 126 | 112 | 64 | 1 | player_room |
| Player House | 126 | 41 | – | 167 | 157 | 128 | 15 | playerhouse |
| Sunset | 126 | 128 | 64 | 318 | 248 | 256 | 13 | sunset |
| Glint | 126 | 128 | – | 254 | 198 | 256 | 9 | glint |
| Starglow | 126 | 128 | 65 | 319 | 254 | 256 | 11 | glint |
| House 1 | 126 | 128 | 107 | 361 | 344 | 247 | 54 | house1 |
| House 2 | 123 | 128 | 111 | 362 | 303 | 219 | 17 | house2 |
| Pokecenter | 124 | 54 | – | 178 | 129 | 64 | 18 | pokecenter |
| Mart | 124 | 50 | – | 174 | 150 | 75 | 16 | mart |
| Lighthouse | 126 | 95 | – | 221 | 205 | 145 | 6 | lighthouse |
| Gate | 123 | 123 | 41 | 287 | 259 | 169 | 17 | gate |
| Lab | 126 | 126 | 120 | 372 | 341 | 203 | 15 | lab |
| Cave | 106 | 56 | – | 162 | 139 | 256 | 18 | cave |
| Starglow Cavern | 106 | 56 | – | 162 | 102 | 256 | 5 | cave |
| Grove | 126 | 64 | – | 190 | 183 | 174 | 5 | grove |
| Mountain | 122 | 126 | 11 | 259 | 155 | 168 | 4 | mountain |
| Jungle | 125 | 108 | 23 | 256 | 144 | 156 | 2 | jungle |
| Spooky | 106 | 72 | – | 178 | 119 | 161 | 13 | spooky |
| Haunted | 116 | 99 | 18 | 233 | 224 | 151 | 9 | haunted |
| Haunted Tv | 116 | 99 | 18 | 233 | 224 | 151 | 1 | haunted |
| Ranch | 126 | 127 | 86 | 339 | 292 | 256 | 7 | ranch |
| Luster | 124 | 120 | 128 | 372 | 317 | 256 | 3 | luster |
| Snow | 122 | 121 | – | 243 | 183 | 202 | 4 | snow |
| Park | 120 | 124 | 84 | 328 | 269 | 256 | 2 | park |
| Mall 1 | 126 | 124 | 127 | 377 | 360 | 128 | 1 | mall1 |
| Mall 2 | 126 | 124 | 123 | 373 | 324 | 218 | 11 | mall2 |
| Sewer | 114 | 5 | – | 119 | 110 | 158 | 5 | sewer |
| Train | 71 | 17 | – | 88 | 39 | 256 | 5 | train |
| Ice Cave | 127 | 128 | 64 | 319 | 246 | 256 | 9 | ice_temple |
| Nett Building | 127 | 128 | 39 | 294 | 258 | 189 | 22 | nett_building |
| Shimmer | 122 | 126 | 120 | 368 | 287 | 256 | 6 | shimmer |
| Desert | 126 | 128 | 112 | 366 | 304 | 256 | 22 | desert |
| Airport | 126 | 127 | 112 | 365 | 306 | 256 | 2 | airport |
| Orphanage | 126 | 126 | 79 | 331 | 237 | 159 | 4 | orphanage |
| Highway | 126 | 126 | 128 | 380 | 326 | 256 | 4 | highway |
| Highway 2 | 126 | 128 | 128 | 382 | 284 | 256 | 6 | highway2 |
| Dive | 125 | 113 | 35 | 273 | 160 | 216 | 6 | dive |
| Bar | 120 | – | – | 120 | 76 | 32 | 1 | bar |
| Autumn | 126 | 127 | 9 | 262 | 230 | 256 | 12 | autumn |
| South Towns | 116 | 119 | – | 235 | 176 | 256 | 4 | south_towns |
| Green Cave | 125 | 50 | – | 175 | 129 | 166 | 5 | green_cave |
| South Buildings | 125 | 126 | 103 | 354 | 317 | 175 | 10 | south_buildings |
| Lava Cave | 106 | 56 | – | 162 | 129 | 256 | 3 | cave |

Outdoor tilesets are per-area, usually one town plus its neighbouring routes
(Sunset 13, Glint 9, Starglow 11, Desert 22, Autumn 12, Spooky 13, and small
sets of 2-7 maps such as Luster, Airport, Snow, Highway). Starglow is Glint's
art plus a GFX2 file; Starglow Cavern and Lava Cave reuse Cave's art.

Full lists: [maps_polishedcoral.md](tileset_survey/maps_polishedcoral.md).

## JohtoLegends

| Tileset | GFX0 | GFX1 | GFX2 | Drawn | Used | Blocks | Maps | Graphics file |
|---|---|---|---|---|---|---|---|---|
| Johto | 118 | 120 | – | 238 | 224 | 206 | 33 | johto |
| Johto Modern | 95 | 114 | – | 209 | 131 | 145 | 4 | johto_modern |
| Kanto | 121 | 69 | – | 190 | 191 | 217 | 38 | kanto |
| Battle Tower Outside | 95 | 114 | – | 209 | 124 | 128 | 1 | johto_modern |
| House | 110 | 2 | – | 112 | 101 | 64 | 58 | house |
| Players House | 98 | – | – | 98 | 94 | 64 | 7 | players_house |
| Pokecenter | 99 | 4 | – | 103 | 104 | 64 | 25 | pokecenter |
| Gate | 95 | – | – | 95 | 89 | 64 | 30 | gate |
| Port | 95 | – | – | 95 | 96 | 64 | 3 | port |
| Lab | 120 | 93 | – | 213 | 213 | 64 | 7 | lab |
| Facility | 123 | 49 | – | 172 | 168 | 135 | 13 | facility |
| Mart | 107 | 83 | – | 190 | 186 | 76 | 33 | mart |
| Mansion | 95 | 95 | – | 190 | 176 | 64 | 4 | mansion |
| Game Corner | 95 | 58 | – | 153 | 153 | 64 | 7 | game_corner |
| Elite Four Room | 118 | 4 | – | 122 | 115 | 127 | 10 | elite_four_room |
| Traditional House | 97 | 10 | – | 107 | 102 | 68 | 13 | traditional_house |
| Train Station | 117 | 61 | – | 178 | 147 | 88 | 6 | train_station |
| Champions Room | 102 | 94 | – | 196 | 186 | 84 | 4 | champions_room |
| Lighthouse | 96 | 7 | – | 103 | 106 | 67 | 11 | lighthouse |
| Players Room | 107 | – | – | 107 | 92 | 64 | 2 | players_room |
| Pokecom Center | 95 | 96 | – | 191 | 179 | 64 | 1 | pokecom_center |
| Battle Tower | 95 | 1 | – | 96 | 92 | 64 | 4 | battle_tower |
| Tower | 115 | 68 | – | 183 | 153 | 111 | 25 | tower |
| Cave | 87 | – | – | 87 | 68 | 141 | 26 | cave |
| Park | 95 | 5 | – | 100 | 97 | 64 | 3 | park |
| Ruins Of Alph | 99 | 96 | – | 195 | 129 | 76 | 11 | ruins_of_alph |
| Radio Tower | 109 | 31 | – | 140 | 96 | 64 | 1 | radio_tower |
| Underground | 125 | 34 | – | 159 | 138 | 171 | 12 | underground |
| Ice Path | 96 | 87 | – | 183 | 157 | 86 | 11 | ice_path |
| Dark Cave | 66 | – | – | 66 | 68 | 141 | 19 | dark_cave |
| Forest | 75 | 94 | – | 169 | 68 | 54 | 2 | forest |
| Beta Word Room | 99 | 96 | – | 195 | 111 | 64 | 0 | ruins_of_alph |
| Ho Oh Word Room | 99 | 96 | – | 195 | 102 | 64 | 1 | ruins_of_alph |
| Kabuto Word Room | 99 | 96 | – | 195 | 94 | 64 | 1 | ruins_of_alph |
| Omanyte Word Room | 99 | 96 | – | 195 | 98 | 64 | 1 | ruins_of_alph |
| Aerodactyl Word Room | 99 | 96 | – | 195 | 114 | 64 | 1 | ruins_of_alph |
| Route 47 | 123 | 71 | – | 194 | 87 | 177 | 4 | route_47 |
| Johto 3 | 126 | 84 | – | 210 | 78 | 102 | 3 | johto_3 |
| Pokemon Mansion | 125 | 55 | – | 180 | 125 | 137 | 4 | pokemon_mansion |
| Kanto 2 | 121 | 47 | – | 168 | 103 | 174 | 0 | kanto_2 |
| Fed Hideout | 125 | 28 | – | 153 | 115 | 163 | 5 | fed_hideout |
| Summit | 106 | 23 | – | 129 | 107 | 64 | 1 | summit |
| Tower Roof | 115 | 80 | – | 195 | 150 | 111 | 0 | tower_roof |
| Draco Scene | 86 | 118 | – | 204 | 198 | 36 | 1 | draco_scene |

Outdoor split is the same as Eclipse (Johto 33, Johto Modern 4, Kanto 38).
Additions: Johto 3 (Routes 47/48, Wild Area Outside), Route 47 (four Wild Area
maps), Summit (Mt. Silver Summit). Kanto 2 and Tower Roof are unused.

Full lists: [maps_JohtoLegends.md](tileset_survey/maps_JohtoLegends.md).

## Regenerating

Scripts are in `docs/tileset_survey/` and expect the sibling repos at
`~/` with built assets (`.2bpp`, `.lz`, `.lzp`).

- `tilesets_any.py <repo>`: tile/block table and per-tileset map lists for
  `crystal_eclipse`, `polishedcoral` or `JohtoLegends`.
- `pc_tilesets.py`, `pc_maps_by_tileset.py`: the same for Polished Crystal,
  whose layout differs.
- `sizes.py`: ROM bytes for tileset files and map layouts in all four repos.

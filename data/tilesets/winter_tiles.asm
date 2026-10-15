MACRO winter_tiles
; vTiles2 tile, WinterTilesGFX tile, count
	db \3
	dw (WinterTilesGFX) tile (\2 - WINTER_TILES_FIRST)
	dw (vTiles2) tile \1
ENDM

MACRO winter_tiles_vram1
; vTiles5 tile, WinterCherryGFX tile, count
	db \3
	dw (WinterCherryGFX) tile \2
	dw (vTiles5) tile \1
ENDM

; WinterTilesGFX mirrors johto.png rows $0x-$5x, so a tile's art sits at its
; own index. Modern's tree middles $13/$15 use slots johto doesn't patch.
DEF WINTER_TILES_FIRST EQU $00

WinterTilesJohto:
	winter_tiles $04, $04, 2 ; tall grass, grass
	winter_tiles $1e, $1e, 2 ; tree top
	winter_tiles $20, $20, 2 ; traditional roof top and ridge, winter blocks only
	winter_tiles $2b, $2b, 5 ; cliff top, tree middle
	winter_tiles $30, $30, 7 ; traditional roof, flat roof
	winter_tiles $3b, $3b, 5 ; cliff, ground, tree bottom
	winter_tiles $41, $41, 4 ; traditional roof
	winter_tiles $46, $46, 3 ; cave mouth, flat roof
	winter_tiles $4b, $4b, 3 ; cliff bottom
	winter_tiles $51, $51, 4 ; traditional roof
	winter_tiles $56, $56, 2 ; cave mouth
	winter_tiles $5c, $5c, 1 ; rock
	db 0

; The cherry tree, block $ac. The trunk, $71-$72, keeps its brown.
WinterTilesJohtoVRAM1:
	winter_tiles_vram1 $40,  0, 4
	winter_tiles_vram1 $50,  4, 4
	winter_tiles_vram1 $60,  8, 4
	winter_tiles_vram1 $70, 12, 1
	winter_tiles_vram1 $73, 15, 1
	db 0

; Only tiles whose art matches johto's, plus modern's own tree middles. Its
; flat roof top sits at $32 and $46.
WinterTilesJohtoModern:
	winter_tiles $04, $04, 2 ; tall grass, grass
	winter_tiles $13, $13, 1 ; tree middle
	winter_tiles $15, $15, 1 ; tree middle
	winter_tiles $1e, $1e, 2 ; tree top
	winter_tiles $2b, $2b, 3 ; cliff top
	winter_tiles $31, $31, 1
	winter_tiles $32, $36, 1
	winter_tiles $34, $34, 1
	winter_tiles $3b, $3b, 5 ; cliff, ground, tree bottom
	winter_tiles $41, $41, 1
	winter_tiles $44, $44, 1
	winter_tiles $46, $48, 1
	winter_tiles $4b, $4b, 3 ; cliff bottom
	winter_tiles $51, $51, 2
	winter_tiles $54, $54, 1
	winter_tiles $5c, $5c, 1 ; rock
	db 0

MACRO winter_park_tiles
; vTiles2 tile, WinterParkGFX tile, count
	db \3
	dw (WinterParkGFX) tile \2
	dw (vTiles2) tile \1
ENDM

; WinterParkGFX mirrors park.png rows $0x-$4x. The tree trunk ($2d $2e
; $3d $3e) keeps its brown; the roof is roofs/snow.png, ridge to eave.
WinterTilesPark:
	winter_park_tiles $01, $01, 1 ; grass
	winter_park_tiles $04, $04, 1 ; tall grass
	winter_park_tiles $0c, $0c, 4 ; tree
	winter_park_tiles $10, $10, 3 ; roof
	winter_park_tiles $1c, $1c, 4 ; tree
	winter_park_tiles $20, $20, 3 ; roof
	winter_park_tiles $2c, $2c, 1 ; tree
	winter_park_tiles $2f, $2f, 1 ; tree
	winter_park_tiles $30, $30, 3 ; roof
	winter_park_tiles $3a, $3a, 2 ; tall grass
	winter_park_tiles $3c, $3c, 1 ; tree
	winter_park_tiles $3f, $3f, 1 ; tree
	winter_park_tiles $4a, $4a, 2 ; tall grass
	db 0

MACRO winter_kanto_tiles
; vTiles2 tile, WinterKantoGFX tile, count
	db \3
	dw (WinterKantoGFX) tile \2
	dw (vTiles2) tile \1
ENDM

; WinterKantoGFX mirrors kanto.png. The multi-palette door and window
; frames $0a-$0c and the animated $03 and $14 are left alone.
WinterTilesKanto:
	winter_kanto_tiles $01, $01, 2 ; mountain edge, cliff
	winter_kanto_tiles $04, $04, 6 ; ledge, roof
	winter_kanto_tiles $11, $11, 3 ; mountain ground, roof, cliff
	winter_kanto_tiles $15, $15, 5 ; roof
	winter_kanto_tiles $1e, $1e, 1 ; cliff
	winter_kanto_tiles $24, $24, 2 ; cliff, roof
	winter_kanto_tiles $27, $27, 1 ; cliff
	winter_kanto_tiles $29, $29, 1 ; roof
	winter_kanto_tiles $2c, $2c, 3 ; grass, small tree
	winter_kanto_tiles $30, $30, 1 ; sand
	winter_kanto_tiles $33, $33, 6 ; shore, cliffs, roof
	winter_kanto_tiles $3d, $3d, 2 ; small tree
	winter_kanto_tiles $40, $40, 2 ; tree
	winter_kanto_tiles $48, $48, 2 ; cave mouth
	winter_kanto_tiles $4c, $4c, 3 ; flat roof
	winter_kanto_tiles $50, $50, 5 ; tree, tall grass, roof, shore
	winter_kanto_tiles $58, $58, 2 ; cave mouth
	winter_kanto_tiles $5c, $5c, 4 ; flat roof
	winter_kanto_tiles $76, $76, 1 ; stalks in the winter flower block
	db 0

; Per tileset: blocks replaced in winter by a block drawn for them, and roof
; cells moved to PAL_BG_GREEN so every winter roof is the same icy white/blue.
WinterBlockPatches:
	db TILESET_JOHTO
	dw WinterBlockSwapsJohto, WinterRecolorJohto
	db TILESET_JOHTO_MODERN
	dw 0, WinterRecolorJohtoModern
	db TILESET_BATTLE_TOWER_OUTSIDE
	dw 0, WinterRecolorJohtoModern
	db TILESET_PARK
	dw WinterBlockSwapsPark, WinterRecolorPark
	db TILESET_KANTO
	dw WinterBlockSwapsKanto, WinterRecolorKanto
	db -1

; block, winter block
WinterBlockSwapsJohto:
	db $04, $ae ; flowers
	db $2c, $b0 ; traditional roofs: top and ridge rows
	db $2d, $b1
	db $2a, $b2
	db $96, $b3
	db $97, $b4
	db -1

WinterBlockSwapsKanto:
	db $74, $83 ; flowers
	db -1

WinterBlockSwapsPark:
	db $3c, $44 ; flower beds
	db $3d, $45
	db $3e, $46
	db -1

MACRO winter_recolor_table
; Arguments: (palette, first tile, end tile) triples, end exclusive. Emits a
; 128-byte table: the palette a bank 0 tile must be drawn with to move to
; PAL_BG_GREEN, or -1.
	FOR _T, 128
		DEF _P = -1
		FOR _I, 1, _NARG + 1, 3
			DEF _F = _I + 1
			DEF _E = _I + 2
			IF _T >= \<_F> && _T < \<_E>
				DEF _P = \<_I>
			ENDC
		ENDR
		db _P
	ENDR
ENDM

WinterRecolorJohto:
	winter_recolor_table \
		PAL_BG_ROOF,  $0a, $13, \ ; snow roofs, which walls share in some towns
		PAL_BG_BROWN, $20, $22, \ ; traditional roofs
		PAL_BG_BROWN, $30, $37, \ ; and flat roofs
		PAL_BG_BROWN, $41, $45, \
		PAL_BG_BROWN, $48, $49, \
		PAL_BG_BROWN, $51, $55

; Modern's flat roof top sits at $32 and $46; its $33, $42, $43, $53 and $48
; are other things.
WinterRecolorJohtoModern:
	winter_recolor_table \
		PAL_BG_ROOF,  $0a, $13, \
		PAL_BG_BROWN, $31, $33, \
		PAL_BG_BROWN, $34, $35, \
		PAL_BG_BROWN, $41, $42, \
		PAL_BG_BROWN, $44, $45, \
		PAL_BG_BROWN, $46, $47, \
		PAL_BG_BROWN, $51, $53, \
		PAL_BG_BROWN, $54, $55

WinterRecolorPark:
	winter_recolor_table PAL_BG_RED, $10, $33 ; gate roof, which shares RED with its walls

WinterRecolorKanto:
	winter_recolor_table \
		PAL_BG_GRAY, $4c, $4f, \ ; flat roofs
		PAL_BG_GRAY, $5a, $5b, \
		PAL_BG_GRAY, $5c, $60

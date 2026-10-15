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
	winter_tiles $2b, $2b, 5 ; cliff top, tree middle
	winter_tiles $31, $31, 4 ; traditional roof
	winter_tiles $36, $36, 1 ; flat roof
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

; Blocks replaced in winter by a block drawn for it: block, winter block.
WinterBlockSwapsJohto:
	db $04, $ae ; flowers
	db -1

WinterBlockSwapsPark:
	db $3c, $44 ; flower beds
	db $3d, $45
	db $3e, $46
	db -1

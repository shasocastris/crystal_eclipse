MACRO winter_tiles
; vTiles2 tile, WinterTilesGFX tile, count
	db \3
	dw (WinterTilesGFX) tile \2
	dw (vTiles2) tile \1
ENDM

; Traditional roofs and the raised platforms that share their rim.
WinterTilesJohto:
	winter_tiles $31,  0, 4
	winter_tiles $36,  4, 1
	winter_tiles $41,  5, 4
	winter_tiles $48,  9, 1
	winter_tiles $51, 10, 4
	db 0

; Same art where modern's tiles match johto's; its $33, $42, $43 and $53
; are other things, and its platform top sits at $32 and $46.
WinterTilesJohtoModern:
	winter_tiles $31,  0, 1
	winter_tiles $32,  4, 1
	winter_tiles $34,  3, 1
	winter_tiles $41,  5, 1
	winter_tiles $44,  8, 1
	winter_tiles $46,  9, 1
	winter_tiles $51, 10, 2
	winter_tiles $54, 13, 1
	db 0

WinterTilesGFX:
INCBIN "gfx/tilesets/seasonal/johto_winter.2bpp"

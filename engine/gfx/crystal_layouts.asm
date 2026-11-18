

LoadOW_BGPal7::
	ld hl, Palette_TextBG7
	ld de, wBGPals1 palette PAL_BG_TEXT
	ld bc, 1 palettes
	ld a, BANK(wBGPals1)
	jmp FarCopyWRAM

Palette_TextBG7:
INCLUDE "gfx/font/bg_text.pal"


INCLUDE "engine/tilesets/tileset_palettes.asm"


TradeRoomPalette:
INCLUDE "gfx/trade/border.pal"


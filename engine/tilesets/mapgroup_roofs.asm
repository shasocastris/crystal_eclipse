LoadMapGroupRoof::
	call LoadWinterTiles
	; These tilesets support dynamic per-mapgroup roof tiles.
	ld a, [wMapTileset]
	cp TILESET_JOHTO
	jr z, .load_roof
	cp TILESET_JOHTO_MODERN
	jr z, .load_roof
	cp TILESET_BATTLE_TOWER_OUTSIDE
	ret nz
.load_roof
	ld a, [wMapGroup]
	ld e, a
	ld d, 0
	ld hl, MapGroupRoofs
	add hl, de
	ld b, [hl]
	; Winter snows the tileset's own roof too, e.g. the Ruins of Alph lab.
	call IsOutdoorWinter
	ld a, ROOF_SNOW
	jr z, .got_roof
	ld a, b
	cp -1
	ret z
.got_roof
	ld hl, Roofs
	ld bc, ROOF_LENGTH tiles
	rst AddNTimes

	ld d, h
	ld e, l
	lb bc, BANK(Roofs), ROOF_LENGTH
	ld hl, vTiles2 tile $0a
	jmp Get2bpp

IsOutdoorWinter:
; Returns z if so. Not the Orange Islands -- they are tropical.
	ld a, [wEnvironment]
	cp TOWN
	jr z, .outdoor
	cp ROUTE
	ret nz
.outdoor
	ld a, [wCurRegion]
	cp ORANGE_REGION
	jr z, .tropical
	ld a, [wSeason]
	maskbits NUM_SEASONS
	cp WINTER_F
	ret

.tropical
	or 1 ; nz
	ret

LoadWinterTiles:
	call IsOutdoorWinter
	ret nz
	ld a, [wMapTileset]
	cp TILESET_JOHTO
	jr z, .johto
	ld hl, WinterTilesPark
	cp TILESET_PARK
	jr z, .CopyRuns
	ld hl, WinterTilesKanto
	cp TILESET_KANTO
	jr z, .CopyRuns
	; Battle Tower Outside loads johto_modern's graphics.
	cp TILESET_BATTLE_TOWER_OUTSIDE
	jr z, .modern
	cp TILESET_JOHTO_MODERN
	ret nz
.modern
	ld hl, WinterTilesJohtoModern
	jr .CopyRuns

.johto
	ld hl, WinterTilesJohto
	call .CopyRuns
	ldh a, [rVBK]
	push af
	ld a, BANK(vTiles5)
	ldh [rVBK], a
	ld hl, WinterTilesJohtoVRAM1
	call .CopyRuns
	pop af
	ldh [rVBK], a
	ret

.CopyRuns:
	ld a, [hli]
	and a
	ret z
	ld c, a
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	push hl
	ld h, [hl]
	ld l, a
	ld b, BANK(WinterTilesGFX)
	call Get2bpp
	pop hl
	inc hl
	jr .CopyRuns

; Which WinterBlockPatches row the decompressed blocks carry, 0 for none. No
; tileset reaches block $ff, so its last byte is free.
DEF wWinterBlocksState EQUS "(wDecompressedMetatiles + 256 * 16 - 1)"

DEF WINTER_PATCH_LENGTH EQU 5 ; db tileset, dw swaps, dw recolors

GetWinterBlocksState:
; Returns a = 1-based row, 0 if none; hl = the row.
	call IsOutdoorWinter
	jr nz, .none
	ld a, [wMapTileset]
	ld c, a
	ld hl, WinterBlockPatches
	ld b, 1
.find
	ld a, [hl]
	cp -1
	jr z, .none
	cp c
	ld a, b
	ret z
	ld de, WINTER_PATCH_LENGTH
	add hl, de
	inc b
	jr .find
.none
	xor a
	ret

CheckWinterBlocks::
; Returns z if the decompressed blocks already suit this map.
	call GetWinterBlocksState
	ld c, a
	ldh a, [rSVBK]
	push af
	ld a, BANK(wDecompressedMetatiles)
	ldh [rSVBK], a
	ld a, [wWinterBlocksState]
	ld b, a
	pop af
	ldh [rSVBK], a
	ld a, b
	cp c
	ret

ApplyWinterBlocks::
	call GetWinterBlocksState
	ld c, a
	ldh a, [rSVBK]
	push af
	ld a, BANK(wDecompressedMetatiles)
	ldh [rSVBK], a
	ld a, c
	ld [wWinterBlocksState], a
	and a
	jr z, .done
	inc hl
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	ld h, d
	ld l, e
	ld a, h
	or l
	call nz, .SwapBlocks
	pop hl
	ld a, h
	or l
	call nz, .Recolor
.done
	pop af
	ldh [rSVBK], a
	ret

.SwapBlocks:
; hl = list of (block, winter block) pairs ending in -1
	push bc
.swap_loop
	ld a, [hli]
	cp -1
	jr z, .swapped
	ld e, a
	ld a, [hli]
	ld d, a
	push hl
	ld a, BANK(wDecompressedMetatiles)
	call .CopyBlock
	ld a, BANK(wDecompressedAttributes)
	call .CopyBlock
	pop hl
	jr .swap_loop
.swapped
	pop bc
	ret

.CopyBlock:
; Copy block d over block e in WRAM bank a.
	assert wDecompressedMetatiles == wDecompressedAttributes
	ldh [rSVBK], a
	push de
	ld l, d
	call .BlockAddress
	push hl
	ld l, e
	call .BlockAddress
	ld d, h
	ld e, l
	pop hl
	ld bc, 16
	rst CopyBytes
	pop de
	ret

.BlockAddress:
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, wDecompressedMetatiles
	add hl, bc
	ret

.Recolor:
; hl = a WinterRecolor table. Matching cells move to PAL_BG_GREEN, whose winter
; ramp is the icy one.
	ld b, h
	ld c, l
	ld de, wDecompressedMetatiles
	ld a, BANK(wDecompressedMetatiles)
	ldh [rSVBK], a
.cell
	ld a, [de]
	cp $80
	jr nc, .next_cell
	ld l, a
	ld h, 0
	add hl, bc
	ld a, [hl]
	inc a
	jr z, .next_cell
	dec a
	ld h, a
	ld a, BANK(wDecompressedAttributes)
	ldh [rSVBK], a
	ld a, [de]
	and $0f ; VRAM bank 0 and the palette
	cp h
	jr nz, .restore_bank
	ld a, [de]
	and ~7
	or PAL_BG_GREEN
	ld [de], a
.restore_bank
	ld a, BANK(wDecompressedMetatiles)
	ldh [rSVBK], a
.next_cell
	inc de
	ld a, d
	cp HIGH(wDecompressedMetatiles + 256 * 16)
	jr nz, .cell
	ret

INCLUDE "data/maps/roofs.asm"
INCLUDE "data/tilesets/winter_tiles.asm"

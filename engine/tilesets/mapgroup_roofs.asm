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
	call IsOutdoorJohtoWinter
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

IsOutdoorJohtoWinter:
; Returns z if so. Johto only -- the Orange Islands are tropical.
	ld a, [wEnvironment]
	cp TOWN
	jr z, .outdoor
	cp ROUTE
	ret nz
.outdoor
	ld a, [wCurRegion]
	cp JOHTO_REGION
	ret nz
	ld a, [wSeason]
	maskbits NUM_SEASONS
	cp WINTER_F
	ret

LoadWinterTiles:
	call IsOutdoorJohtoWinter
	ret nz
	ld a, [wMapTileset]
	cp TILESET_JOHTO
	jr z, .johto
	ld hl, WinterTilesPark
	cp TILESET_PARK
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

; Which winter patch the decompressed blocks carry. No tileset reaches block
; $ff, so its last byte is free.
DEF wWinterBlocksState EQUS "(wDecompressedMetatiles + 256 * 16 - 1)"
	const_def
	const WINTER_BLOCKS_NONE
	const WINTER_BLOCKS_JOHTO
	const WINTER_BLOCKS_PARK

GetWinterBlocksState:
	call IsOutdoorJohtoWinter
	jr nz, .none
	ld a, [wMapTileset]
	cp TILESET_JOHTO
	ld a, WINTER_BLOCKS_JOHTO
	ret z
	ld a, [wMapTileset]
	cp TILESET_PARK
	ld a, WINTER_BLOCKS_PARK
	ret z
.none
	xor a ; WINTER_BLOCKS_NONE
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
	ld hl, WinterBlockSwapsJohto
	cp WINTER_BLOCKS_JOHTO
	call z, .SwapBlocks
	ld a, c
	cp WINTER_BLOCKS_PARK
	jr nz, .done
	ld hl, WinterBlockSwapsPark
	call .SwapBlocks
	call .ParkRoofs
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

.ParkRoofs:
; Roof tiles $10-$12, $20-$22 and $30-$32 drawn on RED move to GREEN.
	ld hl, wDecompressedMetatiles
.loop
	ld a, BANK(wDecompressedMetatiles)
	ldh [rSVBK], a
	ld a, [hl]
	ld b, a
	and $0f
	cp 3
	jr nc, .next
	ld a, b
	and $f0
	jr z, .next
	cp $40
	jr nc, .next
	ld a, BANK(wDecompressedAttributes)
	ldh [rSVBK], a
	ld a, [hl]
	ld b, a
	and $0f ; VRAM bank 0 and PAL_BG_RED
	cp PAL_BG_RED
	jr nz, .next
	ld a, b
	and ~7
	or PAL_BG_GREEN
	ld [hl], a
.next
	inc hl
	ld a, h
	cp HIGH(wDecompressedMetatiles + $80 * 16)
	jr nz, .loop
	ret

INCLUDE "data/maps/roofs.asm"
INCLUDE "data/tilesets/winter_tiles.asm"

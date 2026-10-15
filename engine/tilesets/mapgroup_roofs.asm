LoadMapGroupRoof::
	call LoadWinterTiles
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

DEF FLOWER_BLOCK        EQU $04
DEF WINTER_FLOWER_BLOCK EQU $ae

CheckWinterBlocks::
; Returns z if the decompressed blocks already suit this map.
	ld a, [wMapTileset]
	cp TILESET_JOHTO
	jr nz, .no_work
	call IsOutdoorJohtoWinter
	ld c, FALSE
	jr nz, .compare
	inc c
.compare
	ldh a, [rSVBK]
	push af
	ld a, BANK(wDecompressedMetatiles)
	ldh [rSVBK], a
	ld hl, wDecompressedMetatiles + FLOWER_BLOCK * 16
	ld de, wDecompressedMetatiles + WINTER_FLOWER_BLOCK * 16
	ld b, 16
.loop
	ld a, [de]
	cp [hl]
	jr nz, .differ
	inc de
	inc hl
	dec b
	jr nz, .loop
.differ
	; b is 0 only if every byte matched, i.e. the swap is in place.
	pop af
	ldh [rSVBK], a
	ld a, b
	and a
	ld a, TRUE
	jr z, .got_state
	xor a ; FALSE
.got_state
	cp c
	ret

.no_work
	xor a
	ret

ApplyWinterBlocks::
	ld a, [wMapTileset]
	cp TILESET_JOHTO
	ret nz
	call IsOutdoorJohtoWinter
	ret nz
	ldh a, [rSVBK]
	push af
	ld a, BANK(wDecompressedMetatiles)
	ld hl, wDecompressedMetatiles
	call .copy
	ld a, BANK(wDecompressedAttributes)
	ld hl, wDecompressedAttributes
	call .copy
	pop af
	ldh [rSVBK], a
	ret

.copy
	ldh [rSVBK], a
	push hl
	ld bc, FLOWER_BLOCK * 16
	add hl, bc
	ld d, h
	ld e, l
	pop hl
	ld bc, WINTER_FLOWER_BLOCK * 16
	add hl, bc
	ld bc, 16
	rst CopyBytes
	ret

INCLUDE "data/maps/roofs.asm"
INCLUDE "data/tilesets/winter_tiles.asm"

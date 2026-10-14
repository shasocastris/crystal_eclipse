LoadMapGroupRoof::
	call LoadWinterTiles
	ld a, [wMapGroup]
	ld e, a
	ld d, 0
	ld hl, MapGroupRoofs
	add hl, de
	ld a, [hl]
	cp -1
	ret z
	ld b, a
	call IsOutdoorJohtoWinter
	jr nz, .got_roof
	ld b, ROOF_SNOW
.got_roof
	ld a, b
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
	ld hl, WinterTilesJohto
	cp TILESET_JOHTO
	jr z, .loop
	ld hl, WinterTilesJohtoModern
	cp TILESET_JOHTO_MODERN
	ret nz
.loop
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
	jr .loop

INCLUDE "data/maps/roofs.asm"
INCLUDE "data/tilesets/winter_tiles.asm"

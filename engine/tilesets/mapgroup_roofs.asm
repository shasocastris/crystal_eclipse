LoadMapGroupRoof::
	ld a, [wMapGroup]
	ld e, a
	ld d, 0
	ld hl, MapGroupRoofs
	add hl, de
	ld a, [hl]
	cp -1
	ret z
	ld b, a
	; Johto only -- the Orange Islands are tropical.
	ld a, [wCurRegion]
	cp JOHTO_REGION
	jr nz, .got_roof
	ld a, [wSeason]
	maskbits NUM_SEASONS
	cp WINTER_F
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

INCLUDE "data/maps/roofs.asm"

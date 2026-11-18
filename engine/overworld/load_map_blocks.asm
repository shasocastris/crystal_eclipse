; Map blocks are stored compressed. The home routines decompress a map to
; wDecompressScratch; these copy from there into wOverworldMapBlocks.

_ChangeMap::
; Copy the current map's blocks inside the 3-block border.
	ld hl, wOverworldMapBlocks
	ld a, [wMapHeight]
	ld b, a
	ld a, [wMapWidth]
	ldh [hConnectedMapWidth], a
	add 6
	ldh [hConnectionStripLength], a
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	add hl, de
	ld e, 3
	add hl, de
	ld de, wDecompressScratch

	ldh a, [rWBK]
	push af
	ld a, BANK(wDecompressScratch)
	ldh [rWBK], a
.row
	push hl
	ldh a, [hConnectedMapWidth]
	ld c, a
.col
	ld a, [de]
	inc de
	ld [hli], a
	dec c
	jr nz, .col
	pop hl
	ldh a, [hConnectionStripLength]
	add l
	ld l, a
	adc h
	sub l
	ld h, a
	dec b
	jr nz, .row
	pop af
	ldh [rWBK], a
	ret

FillMapConnections::
; North
	ld a, [wNorthConnectedMapGroup]
	cp $ff
	jr z, .South
	ld b, a
	ld a, [wNorthConnectedMapNumber]
	ld c, a
	call DecompressAnyMapBlocks

	ld hl, wNorthConnectionStripPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wNorthConnectionStripLocation]
	ld e, a
	ld a, [wNorthConnectionStripLocation + 1]
	ld d, a
	ld a, [wNorthConnectionStripLength]
	ldh [hConnectionStripLength], a
	ld a, [wNorthConnectedMapWidth]
	ldh [hConnectedMapWidth], a
	call FillNorthConnectionStrip

.South:
	ld a, [wSouthConnectedMapGroup]
	cp $ff
	jr z, .West
	ld b, a
	ld a, [wSouthConnectedMapNumber]
	ld c, a
	call DecompressAnyMapBlocks

	ld hl, wSouthConnectionStripPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wSouthConnectionStripLocation]
	ld e, a
	ld a, [wSouthConnectionStripLocation + 1]
	ld d, a
	ld a, [wSouthConnectionStripLength]
	ldh [hConnectionStripLength], a
	ld a, [wSouthConnectedMapWidth]
	ldh [hConnectedMapWidth], a
	call FillSouthConnectionStrip

.West:
	ld a, [wWestConnectedMapGroup]
	cp $ff
	jr z, .East
	ld b, a
	ld a, [wWestConnectedMapNumber]
	ld c, a
	call DecompressAnyMapBlocks

	ld hl, wWestConnectionStripPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wWestConnectionStripLocation]
	ld e, a
	ld a, [wWestConnectionStripLocation + 1]
	ld d, a
	ld a, [wWestConnectionStripLength]
	ld b, a
	ld a, [wWestConnectedMapWidth]
	ldh [hConnectionStripLength], a
	call FillWestConnectionStrip

.East:
	ld a, [wEastConnectedMapGroup]
	cp $ff
	ret z
	ld b, a
	ld a, [wEastConnectedMapNumber]
	ld c, a
	call DecompressAnyMapBlocks

	ld hl, wEastConnectionStripPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wEastConnectionStripLocation]
	ld e, a
	ld a, [wEastConnectionStripLocation + 1]
	ld d, a
	ld a, [wEastConnectionStripLength]
	ld b, a
	ld a, [wEastConnectedMapWidth]
	ldh [hConnectionStripLength], a
	; fallthrough

FillWestConnectionStrip:
; Copy b rows of 3 blocks from hl (in wDecompressScratch) to de.
	ld a, [wMapWidth]
	add 6
	ldh [hConnectedMapWidth], a

	ldh a, [rWBK]
	push af
	ld a, BANK(wDecompressScratch)
	ldh [rWBK], a
.loop
	push de

	push hl
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	pop hl

	ldh a, [hConnectionStripLength]
	ld e, a
	ld d, 0
	add hl, de
	pop de

	ldh a, [hConnectedMapWidth]
	add e
	ld e, a
	adc d
	sub e
	ld d, a
	dec b
	jr nz, .loop
	pop af
	ldh [rWBK], a
	ret

FillNorthConnectionStrip:
FillSouthConnectionStrip:
; Copy 3 rows of hConnectionStripLength blocks from hl (in wDecompressScratch) to de.
	ld a, [wMapWidth]
	add 6
	ld c, a

	ldh a, [rWBK]
	push af
	ld a, BANK(wDecompressScratch)
	ldh [rWBK], a
	call .row
	call .row
	call .row
	pop af
	ldh [rWBK], a
	ret

.row
	push de

	push hl
	ldh a, [hConnectionStripLength]
	ld b, a
.x
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .x
	pop hl

	ldh a, [hConnectedMapWidth]
	ld e, a
	ld d, 0
	add hl, de
	pop de

	ld a, c
	add e
	ld e, a
	adc d
	sub e
	ld d, a
	ret

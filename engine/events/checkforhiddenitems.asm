CheckForHiddenItems:
; Checks to see if there are hidden items on the screen that have not yet been found.  If it finds one, returns carry.
	call GetMapScriptsBank
	ld [wCurMapScriptBank], a
; Get the coordinate of the bottom right corner of the screen, and load it in wBottomRightYCoord/wBottomRightXCoord.
	ld a, [wXCoord]
	add SCREEN_WIDTH / 4
	ld [wBottomRightXCoord], a
	ld a, [wYCoord]
	add SCREEN_HEIGHT / 4
	ld [wBottomRightYCoord], a
; Get the pointer for the first bg_event in the map...
	ld hl, wCurMapBGEventsPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
; ... before even checking to see if there are any BG events on this map.
	ld a, [wCurMapBGEventCount]
	and a
	jr z, .nobgeventitems
; For i = 1:wCurMapBGEventCount...
.loop
; Store the counter in wRemainingBGEventCount, and store the bg_event pointer in the stack.
	ld [wRemainingBGEventCount], a
	push hl
; Get the Y coordinate of the BG event.
	call .GetFarByte
	ld e, a
; Is the Y coordinate of the BG event on the screen?  If not, go to the next BG event.
	ld a, [wBottomRightYCoord]
	sub e
	jr c, .next
	cp SCREEN_HEIGHT / 2
	jr nc, .next
; Is the X coordinate of the BG event on the screen?  If not, go to the next BG event.
	call .GetFarByte
	ld d, a
	ld a, [wBottomRightXCoord]
	sub d
	jr c, .next
	cp SCREEN_WIDTH / 2
	jr nc, .next
; Is this BG event a hidden item?  If not, go to the next BG event.
	call .GetFarByte
	cp BGEVENT_ITEM
	jr nz, .next
; Has this item already been found?  If not, set off the Itemfinder.
	ld a, [wCurMapScriptBank]
	call GetFarWord
	ld a, [wCurMapScriptBank]
	call GetFarWord
	ld d, h
	ld e, l
	ld b, CHECK_FLAG
	call EventFlagAction
	ld a, c
	and a
	jr z, .itemnearby

.next
; Restore the bg_event pointer and increment it by the length of a bg_event.
	pop hl
	ld bc, BG_EVENT_SIZE
	add hl, bc
; Restore the BG event counter and decrement it.  If it hits zero, there are no hidden items in range.
	ld a, [wRemainingBGEventCount]
	dec a
	jr nz, .loop

.nobgeventitems
	xor a
	ret

.itemnearby
	pop hl
	scf
	ret

.GetFarByte:
	ld a, [wCurMapScriptBank]
	call GetFarByte
	inc hl
	ret

RockItemEncounter:
	ld hl, .RockItems
.loop
	ld a, [hl]
	inc a
	jr z, .end_of_table
	call Random
	sub [hl]
	jr c, .got_item
	inc hl
	inc hl
	inc hl
	jr .loop
.got_item
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
.done
	call GetItemIDFromIndex
	ld [wScriptVar], a
	ret
.end_of_table
	ld hl, BRICK_PIECE
	jr .done

.RockItems
	dbw 1, MIST_STONE
	dbw 1, MOON_STONE
	dbw 1, FIRE_STONE
	dbw 1, NUGGET
	dbw 1, IRON
	dbw 1, CALCIUM
	dbw 1, ZINC
	dbw 2, HARD_STONE
	dbw 2, METAL_COAT
	dbw 2, SOFT_SAND
	dbw 2, BRIGHTPOWDER
	dbw 2, KINGS_ROCK
	dbw 2, THICK_CLUB
	dbw 2, METAL_POWDER
	dbw 2, IRON_PLATE
	db -1

TreeItemEncounter:
	ld hl, .TreeItems
.loop
	ld a, [hl]
	inc a
	jr z, .end_of_table
	call Random
	sub [hl]
	jr c, .got_item
	inc hl
	inc hl
	inc hl
	jr .loop
.got_item
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
.done
	call GetItemIDFromIndex
	ld [wScriptVar], a
	ret
.end_of_table
	ld hl, NO_ITEM
	jr .done

.TreeItems
	dbw 1, LEAF_STONE
	dbw 1, SUN_STONE
	dbw 1, BIG_MUSHROOM
	dbw 1, PROTEIN
	dbw 1, LUCKY_EGG
	dbw 2, MIRACLE_SEED
	dbw 2, SILVERPOWDER
	dbw 2, POISON_BARB
	dbw 2, CHARCOAL
	dbw 2, STICK
	dbw 2, MIRACLEBERRY
	dbw 2, TINYMUSHROOM
	dbw 2, GOLD_LEAF
	dbw 4, SILVER_LEAF
	db -1

FishItemEncounter:
	ld hl, .FishItems
.loop
	ld a, [hl]
	inc a
	jr z, .end_of_table
	call Random
	sub [hl]
	jr c, .got_item
	inc hl
	inc hl
	inc hl
	jr .loop
.got_item
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
.done
	call GetItemIDFromIndex
	ld [wScriptVar], a
	farcall LoadFonts_NoOAMUpdate
	ret
.end_of_table
	ld hl, NO_ITEM
	jr .done

.FishItems:
	dbw 1, WATER_STONE
	dbw 1, THUNDERSTONE
	dbw 1, DRAGON_SCALE
	dbw 1, BIG_PEARL
	dbw 1, STAR_PIECE
	dbw 1, CARBOS
	dbw 2, MYSTIC_WATER
	dbw 2, DRAGON_FANG
	dbw 2, MAGNET
	dbw 2, NEVERMELTICE
	dbw 2, ULTRA_BALL
	dbw 2, SLOWPOKETAIL
	dbw 2, STARDUST
	dbw 2, PEARL
	db -1
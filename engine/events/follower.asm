FollowerScript::
	faceplayer
	callasm StoreFollowerNickInBuffer
	opentext
	followcry
	writetext FollowerHappyText
	waitbutton
	closetext
	end

FollowerHappyText:
	text_ram wStringBuffer1
	text " is"
	line "happy to be out!"
	done

StoreFollowerNickInBuffer:
	ld a, [wFollowerPartyNum]
	ld hl, wPartyMonNicknames
	call SkipNames
	ld de, wStringBuffer1
	ld bc, MON_NAME_LENGTH
	jmp CopyBytes

GetFirstAliveMon::
; Return the species of the first party mon that has HP and isn't an egg
; in a with nz, and its party index in e. Return z and a = 0 if none.
	ld hl, wPartySpecies
	ld bc, wPartyMon1HP
	ld e, 0
.loop
	ld a, [hli]
	cp -1
	jr z, .none
	ld d, a
	cp EGG
	jr z, .next
	ld a, [bc]
	inc bc
	push hl
	ld h, a
	ld a, [bc]
	or h
	pop hl
	dec bc
	jr z, .next
	ld a, d
	and a
	ret

.next
	inc e
	push hl
	ld hl, PARTYMON_STRUCT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	pop hl
	jr .loop

.none
	xor a
	ret

GetFollowerSpriteData::
; GetSprite for SPRITE_FOLLOWER: return the lead mon's walking sprite
; at b:de, its length in c, and WALKING_SPRITE in l, with carry.
	call GetFirstAliveMon
	ld [wFollowerSpriteID], a
	ld a, e
	ld [wFollowerPartyNum], a
	ld a, [wFollowerSpriteID]
	ld bc, 0
	and a
	jr z, .got_index
	call GetPokemonIndexFromID
	dec hl
	ld a, l
	sub LOW(NUM_POKEMON_AND_VARIANTS)
	ld a, h
	sbc HIGH(NUM_POKEMON_AND_VARIANTS)
	jr nc, .got_index
	ld b, h
	ld c, l
.got_index
	ld hl, FollowingSpritePointers
	add hl, bc
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld e, a
	ld d, [hl]
	ld c, 12
	ld h, b
	ld l, WALKING_SPRITE
	scf
	ret

GetFollowerPalette::
; Return the lead mon's overworld palette (PAL_OW_*) in c.
; Uses its party menu icon colours, shiny included.
	call GetFirstAliveMon
	ld c, PAL_OW_RED
	ret z
	ld b, a
	ld a, [wCurPartySpecies]
	push af
	ld a, b
	ld [wCurPartySpecies], a
	ld a, e
	ld hl, wPartyMon1DVs
	ld bc, PARTYMON_STRUCT_LENGTH
	rst AddNTimes
	farcall GetMenuMonIconPalette
	ld e, a
	ld d, 0
	ld hl, .IconToOWPals
	add hl, de
	ld c, [hl]
	pop af
	ld [wCurPartySpecies], a
	ret

.IconToOWPals:
; entries correspond to PAL_ICON_* constants
	db PAL_OW_RED
	db PAL_OW_BLUE
	db PAL_OW_GREEN
	db PAL_OW_BROWN
	db PAL_OW_PINK
	db PAL_OW_GRAY
	db PAL_OW_TEAL
	db PAL_OW_PURPLE
	assert @ - .IconToOWPals == PAL_ICON_PURPLE + 1

RefreshFollowerPalette::
; The lead mon can change in a menu; give the follower its new colours.
	ld a, [wObject1Sprite]
	cp SPRITE_FOLLOWER
	ret nz
	call GetFollowerPalette
	ld hl, wObject1PalIndex
	ld a, [hl]
	cp c
	ret z
	ld [hl], c
	farjp CheckForUsedObjPals

INCLUDE "gfx/following_sprite_pointers.asm"

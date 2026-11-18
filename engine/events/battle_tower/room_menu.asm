BattleTowerRoomMenu:
; special: pick a level group.
; wScriptVar = 0 with wBTChoiceOfLvlGroup set, or $a if the player backed out.
	xor a
	ld [wBattleTowerBattleEnded], a
	ld [wNrOfBeatenBattleTowerTrainers], a
	ld [wcf65], a
	ld [wcf66], a
.restart
	ld hl, .WhatLevelText
	call PrintText
	ld hl, .MenuHeader
	call LoadMenuHeader
	call MenuBox
	ld a, '▼'
	hlcoord 16, 8
	ld [hl], a
	hlcoord 16, 10
	ld [hl], a
	hlcoord 16, 8, wAttrmap
	set B_BG_YFLIP, [hl]
	ld a, [wStatusFlags]
	bit STATUSFLAGS_HALL_OF_FAME_F, a
	ld a, 4 + 1
	jr z, .got_count
	ld a, 10 + 1
.got_count
	ld [wcd4a], a ; options, CANCEL last
	ld a, 1
	ld [wcd4f], a ; cursor
	call .PlaceLevel
	call WaitBGMap2
.loop
	call DelayFrame
	call JoyTextDelay
	ld hl, wcd4f
	ld a, [wcd4a]
	ld c, a
	ldh a, [hJoyPressed]
	bit B_PAD_B, a
	jr nz, .b_button
	bit B_PAD_A, a
	jr nz, .a_button
	bit B_PAD_DOWN, a
	jr nz, .down
	bit B_PAD_UP, a
	jr z, .loop
; up
	ld a, [hl]
	inc [hl]
	cp c
	jr c, .moved
	ld [hl], 1
	jr .moved

.down
	dec [hl]
	jr nz, .moved
	ld [hl], c
.moved
	call .PlaceLevel
	jr .loop

.a_button
	call PlayClickSFX
	ld hl, wcd4a
	ld a, [wcd4f]
	cp [hl]
	jr z, .cancel
	call CloseWindow
	call .CheckParty
	jr c, .refused
	ldh a, [rWBK]
	push af
	ld a, BANK(wBTChoiceOfLvlGroup)
	ldh [rWBK], a
	ld a, [wcd4f]
	ld [wBTChoiceOfLvlGroup], a
	pop af
	ldh [rWBK], a
	xor a
	ld [wScriptVar], a
	ret

.refused
	call PrintText
	ld c, 128
	call DelayFrames
	jmp .restart

.b_button
	call PlayClickSFX
.cancel
	call CloseWindow
	ld hl, .CancelText
	call PrintText
	call YesNoBox
	jmp c, .restart
	ld a, $a
	ld [wScriptVar], a
	ret

.PlaceLevel:
	ld a, [wcd4a]
	ld c, a
	ld a, [wcd4f]
	ld de, .Cancel
	cp c
	jr z, .place
	dec a
	add a
	add a
	add a
	ld e, a
	ld d, 0
	ld hl, .Levels
	add hl, de
	ld d, h
	ld e, l
.place
	hlcoord 13, 9
	rst PlaceString
	ret

.CheckParty:
; Return carry and a refusal text in hl if the party can't enter this level group.
	ld a, [wcd4f]
	ld c, 10
	call SimpleMultiply
	ld b, a
	ld hl, wPartyMon1Level
	ld de, PARTYMON_STRUCT_LENGTH
	ld a, [wPartyCount]
	ld c, a
.level_loop
	ld a, b
	cp [hl]
	jr c, .tops_level
	add hl, de
	dec c
	jr nz, .level_loop
; Past the level check every mon is under 70 in a room under 70,
; so any uber here is one that may not enter.
	ld a, b
	cp 70
	ret nc
	ld hl, wPartySpecies
.uber_loop
	ld a, [hli]
	cp -1
	ret z ; nc
	push hl
	ld [wNamedObjectIndex], a
	call GetPokemonIndexFromID
	ld b, h
	ld c, l
	ld hl, .Ubers
	ld de, 2
	call IsInWordArray
	pop hl
	jr nc, .uber_loop
	call GetPokemonName
	ld hl, .UberText
	scf
	ret

.tops_level
	ld hl, .TopsLevelText
	ret

.Ubers:
	dw MEWTWO
	dw MEW
	dw LUGIA
	dw HO_OH
	dw CELEBI
	dw -1

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 12, 7, SCREEN_WIDTH - 1, TEXTBOX_Y - 1
	dw NULL
	db 0 ; default option

.Levels:
	db " L:10 @@"
	db " L:20 @@"
	db " L:30 @@"
	db " L:40 @@"
	db " L:50 @@"
	db " L:60 @@"
	db " L:70 @@"
	db " L:80 @@"
	db " L:90 @@"
	db " L:100@@"
.Cancel:
	db "CANCEL@"

.WhatLevelText:
	text "What level do you"
	line "want to challenge?"
	done

.CancelText:
	text "Cancel your BATTLE"
	line "ROOM challenge?"
	done

.TopsLevelText:
	text "A party #MON"
	line "tops this level."
	done

.UberText:
	text_ram wStringBuffer1
	text " may go"
	line "only to BATTLE"

	para "ROOMS that are"
	line "Lv.70 or higher."
	done

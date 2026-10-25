MoveTutor:
	call FadeToMenu
	call ClearBGPalettes
	call ClearScreen
	call DelayFrame
	ld b, SCGB_PACKPALS
	call GetSGBLayout
	xor a
	ld [wItemAttributeValue], a
	call .GetMoveTutorMove
	ld [wNamedObjectIndex], a
	ld [wPutativeTMHMMove], a
	call GetMoveName
	call CopyName1
	farcall ChooseMonToLearnTMHM
	jr c, .cancel
	jr .enter_loop

.loop
	farcall ChooseMonToLearnTMHM_NoRefresh
	jr c, .cancel
.enter_loop
	call CheckCanLearnMoveTutorMove
	jr nc, .loop
	xor a ; FALSE
	ld [wScriptVar], a
	jr .quit

.cancel
	ld a, -1
	ld [wScriptVar], a
.quit
	jmp CloseSubmenu

.GetMoveTutorMove:
	ld a, [wScriptVar]
	ret

CheckCanLearnMoveTutorMove:
	ld hl, .MenuHeader
	call LoadMenuHeader

	predef CanLearnTMHMMove

	push bc
	ld a, [wCurPartyMon]
	ld hl, wPartyMonNicknames
	call GetNickname
	pop bc

	ld a, c
	and a
	jr nz, .can_learn
	push de
	ld de, SFX_WRONG
	call PlaySFX
	pop de
	ld a, BANK(TMHMNotCompatibleText)
	ld hl, TMHMNotCompatibleText
	call FarPrintText
	jr .didnt_learn

.can_learn
	farcall KnowsMove
	jr c, .didnt_learn

	predef LearnMove
	ld a, b
	and a
	jr z, .didnt_learn

	ld c, HAPPINESS_LEARNMOVE
	farcall ChangeHappiness
	jr .learned

.didnt_learn
	call ExitMenu
	and a
	ret

.learned
	call ExitMenu
	scf
	ret

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 12, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1


DeityMoveTutor:
; Teach the move in wScriptVar to a party mon with max happiness.
; Returns a DEITYTUTOR_* code in wScriptVar.
	call FadeToMenu
	call ClearBGPalettes
	call ClearScreen
	call DelayFrame
	ld b, SCGB_PACKPALS
	call GetSGBLayout
	farcall LoadPartyMenuGFX
	farcall InitPartyMenuWithCancel
	farcall InitPartyMenuGFX
	ld a, PARTYMENUACTION_CHOOSE_POKEMON
	ld [wPartyMenuActionText], a
	farcall WritePartyMenuTilemap
	farcall PlacePartyMenuText
	call WaitBGMap
	call SetDefaultBGPAndOBP
	call DelayFrame
	farcall PartyMenuSelect
	ld a, DEITYTUTOR_CANCEL
	jr c, .done

	ld a, [wCurPartySpecies]
	call IsAPokemon
	ld a, DEITYTUTOR_EGG
	jr c, .done

	ld a, MON_HAPPINESS
	call GetPartyParamLocation
	ld a, [hl]
	inc a
	ld a, DEITYTUTOR_NOT_HAPPY
	jr nz, .done

	ld a, [wScriptVar]
	ld [wNamedObjectIndex], a
	ld [wPutativeTMHMMove], a
	call GetMoveName
	call CopyName1
	ld a, [wCurPartyMon]
	ld hl, wPartyMonNicknames
	call GetNickname
	farcall KnowsMove
	ld a, DEITYTUTOR_KNOWS
	jr c, .done

	predef LearnMove
	ld a, b
	and a
	ld a, DEITYTUTOR_DECLINED
	jr z, .done
	assert DEITYTUTOR_TAUGHT == 0
	xor a
.done
	ld [wScriptVar], a
	jmp CloseSubmenu

GetDeityMove:
; wScriptVar: a deity's species. Marks it seen, then returns its move in
; wScriptVar, named in wStringBuffer3.
	ld a, [wScriptVar]
	push af
	call SetSeenMon
	pop af
	call GetPokemonIndexFromID
	ld b, h
	ld c, l
	ld hl, DeityTutorMoves
	ld de, 4
	call IsInWordArray
	ret nc
	inc hl
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call GetMoveIDFromIndex
	ld [wScriptVar], a
	ld [wNamedObjectIndex], a
	call GetMoveName
	ld h, d
	ld l, e
	ld de, wStringBuffer3
	ld bc, MOVE_NAME_LENGTH
	rst CopyBytes
	ret

INCLUDE "data/events/deity_tutor_moves.asm"

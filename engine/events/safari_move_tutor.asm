; engine/events/safari_move_tutor.asm
;
; The Safari Zone Move Tutor: an evolution-line-gated tutor. The player picks a
; Pokemon; if that species has a tutor move (see SafariZoneMoveTutorMoves) AND every member
; of its evolutionary line has been caught (see PokemonEvoLines), the move is
; taught for free. Composes existing party-menu / teach-move infrastructure.
;
; SafariZoneMoveTutor returns a result code in wScriptVar for the calling script:
;   0 (FALSE) taught the move
;   1         chosen species has no tutor move
;   2         evolutionary line not fully caught yet
;   3         the mon already knows the move
;   4         couldn't learn it (no room / declined)
;   5         player cancelled the selection

DEF SAFARI_TUTOR_TAUGHT          EQU 0
DEF SAFARI_TUTOR_NO_MOVE         EQU 1
DEF SAFARI_TUTOR_LINE_INCOMPLETE EQU 2
DEF SAFARI_TUTOR_ALREADY_KNOWS   EQU 3
DEF SAFARI_TUTOR_NO_ROOM         EQU 4
DEF SAFARI_TUTOR_CANCEL          EQU 5

OutrageMoveTutor:
; Same flow and result codes, but teaches OUTRAGE to the species in
; OutrageTutorSpecies with no evolution-line gate.
	ld a, TRUE
	jr SafariZoneMoveTutor.start

SafariZoneMoveTutor:
	xor a
.start
	push af ; which tutor
	; Run everything in one menu submenu (FadeToMenu..CloseSubmenu) so the party
	; picker and LearnMove's move-forget UI render in the menu layer instead of
	; under the overworld map/sprites.
	call FadeToMenu
	call ClearBGPalettes
	call ClearScreen
	call DelayFrame
	ld b, SCGB_PACKPALS
	call GetSGBLayout

	; Plain party menu (PARTYMENUACTION_CHOOSE_POKEMON) — no ABLE/NOT ABLE
	; column, unlike the TMHM teach menu. Mirrors ChooseMonToLearnTMHM but with
	; the neutral action. PartyMenuSelect sets wCurPartyMon + wCurPartySpecies
	; and returns carry on cancel.
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
	pop bc ; b = which tutor; flags kept
	jr c, .cancel

	; Reject eggs / non-Pokemon selections.
	ld a, [wCurPartySpecies]
	call IsAPokemon
	jr c, .no_move

	ld a, b
	and a
	jr z, .safari
	call CheckOutrageTutorSpecies
	jr nc, .no_move
	ld de, OUTRAGE
	jr .teach

.safari

	call GetSafariZoneMoveTutorMove ; carry = found; de = move index; b = LINE_* id
	jr nc, .no_move

	push de ; save move index
	; b = LINE_* id
	call CheckLineFullyCaught ; carry set if every line member is caught
	jr c, .line_complete
	pop de
	jr .line_incomplete

.line_complete:
	pop de ; de = move index
.teach
	; Convert the 16-bit move index to the dynamic 8-bit runtime ID.
	ld h, d
	ld l, e
	call GetMoveIDFromIndex ; a = 8-bit move ID
	ld [wNamedObjectIndex], a
	ld [wPutativeTMHMMove], a
	call GetMoveName
	call CopyName1

	ld a, [wCurPartyMon]
	ld hl, wPartyMonNicknames
	call GetNickname

	farcall KnowsMove
	jr c, .already_knows

	predef LearnMove
	ld a, b
	and a
	jr z, .no_room

	ld c, HAPPINESS_LEARNMOVE
	farcall ChangeHappiness
	ld a, SAFARI_TUTOR_TAUGHT
	jr .done

.already_knows:
	ld a, SAFARI_TUTOR_ALREADY_KNOWS
	jr .done

.no_room:
	ld a, SAFARI_TUTOR_NO_ROOM
	jr .done

.no_move:
	ld a, SAFARI_TUTOR_NO_MOVE
	jr .done

.line_incomplete:
	ld a, SAFARI_TUTOR_LINE_INCOMPLETE
	jr .done

.cancel:
	ld a, SAFARI_TUTOR_CANCEL
.done:
	ld [wScriptVar], a
	jmp CloseSubmenu

; Look up the chosen mon's species in SafariZoneMoveTutorMoves.
; wCurPartySpecies holds an 8-bit runtime ID; the table is keyed by 16-bit
; species index, so convert first, then match.
; Row format: dw species index, dw move index, db LINE_* id (5 bytes).
; Output: carry set if found -> de = move index, b = LINE_* id.
;         carry clear if the species has no tutor move.
GetSafariZoneMoveTutorMove:
	ld a, [wCurPartySpecies]
	call GetPokemonIndexFromID ; hl = 16-bit species index
	ld d, h
	ld e, l ; de = target species index
	ld hl, SafariZoneMoveTutorMoves
.loop:
	ld a, [hli]
	ld c, a ; row species low
	ld a, [hli]
	ld b, a ; row species high

	; Terminator is species index $ffff.
	cp $ff
	jr nz, .compare
	ld a, c
	cp $ff
	jr z, .not_found

.compare:
	ld a, c
	cp e
	jr nz, .next
	ld a, b
	cp d
	jr nz, .next

	; Match: hl points at the move index.
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a ; de = move index
	ld b, [hl] ; LINE_* id
	scf
	ret

.next:
	inc hl ; skip move low
	inc hl ; skip move high
	inc hl ; skip LINE_* id
	jr .loop

.not_found:
	and a ; carry clear
	ret

; Output: carry set if wCurPartySpecies is in OutrageTutorSpecies.
CheckOutrageTutorSpecies:
	ld a, [wCurPartySpecies]
	call GetPokemonIndexFromID
	ld d, h
	ld e, l
	ld hl, OutrageTutorSpecies
.loop
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	and c
	inc a
	ret z ; $ffff terminator; carry is clear
	ld a, c
	cp e
	jr nz, .loop
	ld a, b
	cp d
	jr nz, .loop
	scf
	ret

OutrageTutorSpecies:
	dw CHARMANDER
	dw CHARMELEON
	dw CHARIZARD
	dw GROWLITHE
	dw ARCANINE
	dw GYARADOS
	dw AERODACTYL
	dw DRATINI
	dw DRAGONAIR
	dw DRAGONITE
	dw DRAGONITE_KANTO
	dw HORSEA
	dw SEADRA
	dw KINGDRA
	dw LARVITAR
	dw PUPITAR
	dw TYRANITAR
	dw -1

; Check that every species in a given evolutionary line has been caught.
; Input: b = LINE_* id
; Output: carry set if all caught, carry clear otherwise.
; Destroys: af, bc, de, hl
CheckLineFullyCaught:
	; Find LINE_* id b in the PokemonEvoLines pointer table:
	; dbw LINE_id, SpeciesListPointer, ..., db -1
	ld hl, PokemonEvoLines
.find_line:
	ld a, [hl]
	cp -1
	jr z, .not_found
	cp b
	jr z, .found_line
	inc hl ; line id
	inc hl ; pointer low
	inc hl ; pointer high
	jr .find_line

.found_line:
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a ; hl = species list pointer

.check_loop:
	; Read next species (16-bit) from the list.
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a

	; Terminator is -1 ($ffff).
	ld a, e
	cp $ff
	jr nz, .not_terminator
	ld a, d
	cp $ff
	jr z, .all_caught

.not_terminator:
	push hl
	push de
	call CheckCaughtFormIndex ; z = not caught, nz = caught
	pop de
	pop hl
	jr z, .missing
	jr .check_loop

.all_caught:
	scf
	ret

.missing:
.not_found:
	and a
	ret

INCLUDE "data/pokemon/evo_lines.asm"
INCLUDE "data/pokemon/safari_move_tutor_moves.asm"

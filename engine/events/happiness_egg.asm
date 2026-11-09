GetFirstPokemonHappiness:
	ld a, [wPartySpecies]
	ld [wNamedObjectIndex], a
	ld a, [wPartyMon1Happiness]
	ld [wScriptVar], a
	call GetPokemonName
	jmp CopyPokemonName_Buffer1_Buffer3

CheckFirstMonIsEgg:
	ld a, [wPartySpecies]
	ld [wNamedObjectIndex], a
	xor a
	ld [wScriptVar], a
	call GetPokemonName
	jmp CopyPokemonName_Buffer1_Buffer3

ChangeHappiness:
; Perform happiness action c on wCurPartyMon

	push bc
	ld hl, wPartyMon1Happiness
	ld bc, PARTYMON_STRUCT_LENGTH
	ld a, [wCurPartyMon]
	rst AddNTimes
	pop bc

	ld d, h
	ld e, l

	push de
	ld a, [de]
	cp HAPPINESS_THRESHOLD_1
	ld e, 0
	jr c, .ok
	inc e
	cp HAPPINESS_THRESHOLD_2
	jr c, .ok
	inc e

.ok
	dec c
	ld b, 0
	ld hl, HappinessChanges
	add hl, bc
	add hl, bc
	add hl, bc
	ld d, 0
	add hl, de
	ld b, [hl]
	pop de
	ld a, b
	cp $64 ; why not $80?
	jr nc, .negative
	push de
	push bc
	farcall GetFollowerMon
	ld a, e
	pop bc
	pop de
	jr z, .gain
	ld hl, wCurPartyMon
	cp [hl]
	jr nz, .gain
	sla b ; the follower gains double
.gain
	ld a, [de]
	add b
	jr nc, .done
	ld a, -1
	jr .done

.negative
	ld a, [de]
	add b
	jr c, .done
	xor a

.done
	ld [de], a
	ld a, [wBattleMode]
	and a
	ret z
	ld a, [wCurPartyMon]
	ld b, a
	ld a, [wPartyMenuCursor]
	cp b
	ret nz
	ld a, [de]
	ld [wBattleMonHappiness], a
	ret

INCLUDE "data/events/happiness_changes.asm"

StepHappiness::
; Raise the party's happiness by HAPPINESS_STEP point every other step cycle.
	ld a, [wPartyCount]
.loop
	and a
	ret z
	dec a
	ld [wCurPartyMon], a
	ld c, HAPPINESS_STEP
	call ChangeHappiness
	ld a, [wCurPartyMon]
	jr .loop

DayCareStep::
; Raise the experience of Day-Care Pokémon every step cycle.

	ld a, [wDayCareMan]
	bit DAYCAREMAN_HAS_MON_F, a
	jr z, .day_care_lady

	ld a, [wDayCareMon1Level] ; level
	cp MAX_LEVEL
	jr nc, .day_care_lady
	ld hl, wDayCareMon1Exp + 2 ; exp
	inc [hl]
	jr nz, .day_care_lady
	dec hl
	inc [hl]
	jr nz, .day_care_lady
	dec hl
	inc [hl]
	ld a, [hl]
	cp HIGH(MAX_DAY_CARE_EXP >> 8)
	jr c, .day_care_lady
	ld [hl], HIGH(MAX_DAY_CARE_EXP >> 8)

.day_care_lady
	ld a, [wDayCareLady]
	bit DAYCARELADY_HAS_MON_F, a
	jr z, .done

	ld a, [wDayCareMon2Level] ; level
	cp MAX_LEVEL
	jr nc, .done
	ld hl, wDayCareMon2Exp + 2 ; exp
	inc [hl]
	jr nz, .done
	dec hl
	inc [hl]
	jr nz, .done
	dec hl
	inc [hl]
	ld a, [hl]
	cp HIGH(MAX_DAY_CARE_EXP >> 8)
	jr c, .done
	ld [hl], HIGH(MAX_DAY_CARE_EXP >> 8)

.done
	ret

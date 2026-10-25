PerfectMonSelect:
; Pick a party mon for the Silver Cave coach.
; Return a PERFECTMON_* value in wScriptVar and its nickname in wStringBuffer3.
	farcall SelectMonFromParty
	ld a, PERFECTMON_CANCEL
	jr c, .done

	ld a, [wCurPartySpecies]
	call IsAPokemon
	ld a, PERFECTMON_EGG
	jr c, .done

	; its letter is made from the DVs
	ld a, [wCurPartySpecies]
	call GetPokemonIndexFromID
	ld a, l
	cp LOW(UNOWN)
	jr nz, .not_unown
	ld a, h
	cp HIGH(UNOWN)
	ld a, PERFECTMON_UNOWN
	jr z, .done
.not_unown

	call GetCurNickname
	ld hl, wStringBuffer1
	ld de, wStringBuffer3
	ld bc, MON_NAME_LENGTH
	call CopyBytes

	call GetPerfectDVs
	ld a, MON_DVS
	call GetPartyParamLocation
	ld a, [hli]
	cp b
	jr nz, .ok
	ld a, [hl]
	cp c
	jr nz, .ok
	ld a, MON_EVS
	call GetPartyParamLocation
	ld b, NUM_STATS
.ev_loop
	ld a, [hli]
	cp MAX_EV
	jr nz, .ok
	dec b
	jr nz, .ev_loop
	ld a, PERFECTMON_ALREADY
	jr .done

.ok
	ld a, PERFECTMON_OK
.done
	ld [wScriptVar], a
	ret

PerfectMonApply:
; Give the selected party mon its perfect DVs and max EVs, then recalculate its stats.
	ld a, [wCurPartyMon]
	ld c, a
	ld b, 0
	ld hl, wPartySpecies
	add hl, bc
	ld a, [hl]
	ld [wCurPartySpecies], a

	call GetPerfectDVs
	ld a, MON_DVS
	call GetPartyParamLocation
	ld a, b
	ld [hli], a
	ld [hl], c

	ld a, MON_EVS
	call GetPartyParamLocation
	ld bc, NUM_STATS
	ld a, MAX_EV
	call ByteFill

	; bc = HP lost, which the mon keeps
	ld a, MON_MAXHP + 1
	call GetPartyParamLocation
	ld a, [hld]
	ld c, a
	ld a, [hld]
	ld b, a
	ld a, c
	sub [hl]
	ld c, a
	dec hl
	ld a, b
	sbc [hl]
	ld b, a

	push bc
	farcall RareCandy_StatBooster_GetParameters
	farcall UpdateStatsAfterItem
	pop bc

	; a fainted mon stays fainted
	ld a, MON_HP
	call GetPartyParamLocation
	ld a, [hli]
	or [hl]
	ret z

	; HP = new max HP - HP lost, at least 1
	inc hl
	ld a, [hli]
	ld d, a
	ld a, [hl]
	sub c
	ld e, a
	ld a, d
	sbc b
	ld d, a
	jr c, .one
	or e
	jr nz, .set_hp
.one
	ld de, 1
.set_hp
	ld a, MON_HP
	call GetPartyParamLocation
	ld a, d
	ld [hli], a
	ld [hl], e
	ret

GetPerfectDVs:
; Return in bc the highest DVs that keep the mon's gender and shininess:
; all 15, then Special 14, then Defense 14.
; A mon that isn't shiny gets Speed 11, which keeps it that way.
	xor a ; PARTYMON
	ld [wMonType], a
	ld a, MON_DVS
	call GetPartyParamLocation
	ld a, [hli]
	ld d, a
	ld e, [hl]
	push de
	ld b, h
	ld c, l
	dec bc
	farcall CheckShininess
	ld c, $ff
	jr c, .shiny
	ld c, $bf
.shiny
	ld b, $ff

	; the DVs are still the original ones here
	push bc
	farcall GetGender
	pop bc
	jr c, .done ; genderless
	ld d, a
	call .TryDVs
	jr z, .done
	dec c
	call .TryDVs
	jr z, .done
	; one of the three always matches
	inc c
	dec b

.done
	pop de
	ld a, MON_DVS
	call GetPartyParamLocation
	ld a, d
	ld [hli], a
	ld [hl], e
	ret

.TryDVs:
; Return z if DVs bc give gender d.
	push bc
	push de
	ld a, MON_DVS
	call GetPartyParamLocation
	ld a, b
	ld [hli], a
	ld [hl], c
	farcall GetGender
	pop de
	pop bc
	cp d
	ret

BattleCommand_HealBell:
	call CureUserPartyStatus
	call AnimateCurrentMove

	ld hl, BellChimedText
	call StdBattleTextbox
	; fallthrough

RecalcUserStats:
	ldh a, [hBattleTurn]
	and a
	jmp z, CalcPlayerStats
	jmp CalcEnemyStats

CureUserPartyStatus:
; Returns nz if any status was cured.
	ld a, BATTLE_VARS_SUBSTATUS1
	call GetBattleVarAddr
	res SUBSTATUS_NIGHTMARE, [hl]
	ld a, BATTLE_VARS_SUBSTATUS5
	call GetBattleVarAddr
	res SUBSTATUS_TOXIC, [hl]
	ld de, wPartyMon1Status
	ld a, [wPartyCount]
	ld b, a
	ldh a, [hBattleTurn]
	and a
	jr z, .got_party
	ld de, wOTPartyMon1Status
	ld a, [wOTPartyCount]
	ld b, a
	ld a, [wBattleMode]
	cp WILD_BATTLE
	jr nz, .got_party
	ld b, 0 ; a wild mon has no team
.got_party
	ld a, BATTLE_VARS_STATUS
	call GetBattleVarAddr
	ld a, [hl]
	ld [hl], 0
	ld h, d
	ld l, e
	ld de, PARTYMON_STRUCT_LENGTH
	inc b
	jr .next
.loop
	or [hl]
	ld [hl], 0
	add hl, de
.next
	dec b
	jr nz, .loop
	and a
	ret

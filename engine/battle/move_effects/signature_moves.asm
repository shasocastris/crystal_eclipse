BattleCommand_SignatureWeather:
; signatureweather
; Silent when the weather is already up, so overworld weather keeps its 255 turns.
	ld a, BATTLE_VARS_MOVE_EFFECT
	call GetBattleVar
	ld hl, SignatureWeathers
	ld de, 5
	call IsInArray
	ret nc
	inc hl
	ld a, [wBattleWeather]
	cp [hl]
	ret z
	ld a, [hli]
	ld [wBattleWeather], a
	push hl
	call GetUserItem
	pop hl
	ld a, [hli]
	cp b
	ld a, 5
	jr nz, .got_count
	ld a, 8
.got_count
	ld [wWeatherCount], a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jmp StdBattleTextbox

SignatureWeathers:
	db EFFECT_SACRED_FIRE, WEATHER_SUN,       HELD_PROLONG_SUN
	dw SunGotBrightText
	db EFFECT_ERUPTION,    WEATHER_SANDSTORM, HELD_PROLONG_SAND
	dw SandstormBrewedText
	db EFFECT_STORM_CALL,  WEATHER_RAIN,      HELD_PROLONG_RAIN
	dw DownpourText
	db EFFECT_SHEER_COLD,  WEATHER_HAIL,      HELD_PROLONG_HAIL
	dw ItStartedToHailText
	db -1

BattleCommand_InnerLight:
; innerlight
	ld hl, wPlayerStatLevels
	ldh a, [hBattleTurn]
	and a
	jr z, .got_levels
	ld hl, wEnemyStatLevels
.got_levels
	lb bc, NUM_LEVEL_STATS, 0
.loop
	ld a, [hl]
	cp MAX_STAT_LEVEL
	jr nc, .next
	ld [hl], MAX_STAT_LEVEL
	inc c
.next
	inc hl
	dec b
	jr nz, .loop
	ld a, c
	and a
	jmp z, BattleEffect_ButItFailed
	call RecalcUserStats
	call AnimateCurrentMove
	ld hl, InnerLightText
	jmp StdBattleTextbox

BattleCommand_LifeDew:
; lifedew
	call CureUserPartyStatus
	call RecalcUserStats
	call LifeDewRefillPP
	ld hl, GetMaxHP
	call CallBattleCore
	call AnimateCurrentMove
	call BattleCommand_SwitchTurn
	ld hl, RestoreHP
	call CallBattleCore
	call BattleCommand_SwitchTurn
	call UpdateUserInParty
	call RefreshBattleHuds
	ld hl, LifeDewText
	jmp StdBattleTextbox

BattleCommand_FaeBlade:
; faeblade
; PAR, FRZ, BRN, PSN, SLP or confusion, 1/6 each; confusion if the target has a status.
	call BattleCommand_EffectChance
	ld a, BATTLE_VARS_STATUS_OPP
	call GetBattleVar
	and a
	jmp nz, BattleCommand_ConfuseTarget
.loop
	call BattleRandom
	and %111
	cp 6
	jr nc, .loop
	ld hl, .StatusCommands
	jmp JumpTable

.StatusCommands:
	dw BattleCommand_ParalyzeTarget
	dw BattleCommand_FreezeTarget
	dw BattleCommand_BurnTarget
	dw BattleCommand_PoisonTarget
	dw FaeBladeSleepTarget
	dw BattleCommand_ConfuseTarget

FaeBladeSleepTarget:
; A secondary sleep: silent when it can't land, like the other *Target commands.
	call CheckSubstituteOpp
	ret nz
	call GetOpponentItem
	ld a, b
	cp HELD_PREVENT_SLEEP
	ret z
	ld a, [wEffectFailed]
	and a
	ret nz
	call SafeCheckSafeguard
	ret nz
	ld a, BATTLE_VARS_STATUS_OPP
	call GetBattleVarAddr
	ld a, [hl]
	and a
	ret nz
	ld d, h
	ld e, l
	ld b, SLP_MASK
	ld a, [wInBattleTowerBattle]
	and a
	jr z, .random_loop
	ld b, %011
.random_loop
	call BattleRandom
	and b
	jr z, .random_loop
	cp SLP_MASK
	jr z, .random_loop
	inc a
	ld [de], a
	ld de, ANIM_SLP
	call PlayOpponentBattleAnim
	call UpdateOpponentInParty
	call RefreshBattleHuds
	ld hl, FellAsleepText
	call StdBattleTextbox
	farcall UseHeldStatusHealingItem
	jmp z, OpponentCantMove
	ret

LifeDewRefillPP:
; Refill the user's PP; the party copy too, as BattleCommand_DoTurn spends it.
	ld hl, wBattleMonMoves
	ld de, wBattleMonPP
	ldh a, [hBattleTurn]
	and a
	jr z, .got_battle_mon
	ld hl, wEnemyMonMoves
	ld de, wEnemyMonPP
.got_battle_mon
	call .Refill
	ld a, BATTLE_VARS_SUBSTATUS5
	call GetBattleVar
	bit SUBSTATUS_TRANSFORMED, a
	ret nz
	ldh a, [hBattleTurn]
	and a
	ld hl, wPartyMon1Moves
	ld a, [wCurBattleMon]
	jr z, .got_party_mon
	ld a, [wBattleMode]
	dec a
	ret z ; wild
	ld hl, wOTPartyMon1Moves
	ld a, [wCurOTMon]
.got_party_mon
	call GetPartyLocation
	push hl
	ld bc, MON_PP - MON_MOVES
	add hl, bc
	ld d, h
	ld e, l
	pop hl
	; fallthrough

.Refill:
; hl = moves, de = PP. Each PP Up adds base / 5, at most 7, as in ComputeMaxPP.
	ld b, NUM_MOVES
.loop
	ld a, [hli]
	and a
	ret z
	push hl
	push bc
	push de
	ld l, a
	ld a, MOVE_PP
	call GetMoveAttribute
	pop de
	ld b, a
	ld c, -1
.divide
	inc c
	sub 5
	jr nc, .divide
	ld a, c
	cp 8
	jr c, .got_bonus
	ld a, 7
.got_bonus
	ld c, a
	ld a, [de]
	and PP_UP_MASK
	ld h, a
	rlca
	rlca
	and a
	jr z, .got_max
.add_bonus
	push af
	ld a, b
	add c
	ld b, a
	pop af
	dec a
	jr nz, .add_bonus
.got_max
	ld a, h
	or b
	ld [de], a
	inc de
	pop bc
	pop hl
	dec b
	jr nz, .loop
	ret

INCLUDE "data/moves/signature_moves.asm"

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
	jmp BattleCommand_Heal

INCLUDE "data/moves/signature_moves.asm"

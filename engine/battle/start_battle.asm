FindFirstAliveMonAndStartBattle:
	xor a
	ldh [hMapAnims], a
	call DelayFrame
	predef DoBattleTransition
	farcall _LoadBattleFontsHPBar
	ld a, 1
	ldh [hBGMapMode], a
	call ClearSprites
	call ClearTilemap
	xor a
	ldh [hBGMapMode], a
	ldh [hWY], a
	ldh [rWY], a
	ldh [hMapAnims], a
	ret

PlayBattleMusic:
	push hl
	push de
	push bc

	xor a
	ld [wMusicFade], a
	ld de, MUSIC_NONE
	call PlayMusic
	call DelayFrame
	call MaxVolume

	ld a, [wBattleType]
	cp BATTLETYPE_SUICUNE
	ld de, MUSIC_SUICUNE_BATTLE
	jmp z, .done
	cp BATTLETYPE_ROAMING
	jmp z, .done

	; Are we fighting a trainer?
	ld a, [wOtherTrainerClass]
	and a
	jr nz, .trainermusic

	farcall RegionCheck
	ld a, e
	cp KANTO_REGION
	jr z, .kantowild
	and a
	jr nz, .orangewild

	ld de, MUSIC_JOHTO_WILD_BATTLE
	ld a, [wTimeOfDay]
	cp NITE_F
	jmp c, .done ; not NITE_F or EVE_F -- out of jr reach now
	ld de, MUSIC_JOHTO_WILD_BATTLE_NIGHT
	jr .done

.orangewild
; The islands get a night variant like Johto's. Since M2 made NUM_DAYTIMES 4,
; `cp NITE_F` covers evening as well as night.
	ld de, MUSIC_ORANGE_WILD_BATTLE
	ld a, [wTimeOfDay]
	cp NITE_F
	jr c, .done ; not NITE_F or EVE_F
	ld de, MUSIC_ORANGE_WILD_BATTLE_NIGHT
	jr .done

.kantowild
	ld de, MUSIC_KANTO_WILD_BATTLE
	jr .done

.trainermusic
	ld de, MUSIC_CHAMPION_BATTLE
	cp CHAMPION
	jr z, .done
	cp RED
	jr z, .done

	ld de, MUSIC_ROCKET_BATTLE
	cp GRUNTM
	jr z, .done
	cp GRUNTF
	jr z, .done
	cp EXECUTIVEM
	jr z, .done
	cp EXECUTIVEF
	jr z, .done
	cp SCIENTIST
	jr z, .done

	ld de, MUSIC_KANTO_GYM_LEADER_BATTLE
	farcall IsKantoGymLeader
	jr c, .done

	; IsGymLeader also counts CHAMPION, RED, and the Kanto gym leaders
	; but they have been taken care of before this
	ld de, MUSIC_JOHTO_GYM_LEADER_BATTLE
	farcall IsGymLeader
	jr c, .done

	ld de, MUSIC_RIVAL_BATTLE
	ld a, [wOtherTrainerClass]
	cp RIVAL1
	jr z, .done
	cp RIVAL2
	jr nz, .othertrainer

	ld a, [wOtherTrainerID]
	cp RIVAL2_2_CHIKORITA ; Rival in Indigo Plateau
	jr c, .done
	ld de, MUSIC_CHAMPION_BATTLE
	jr .done

.othertrainer
	farcall RegionCheck
	ld a, e
	cp KANTO_REGION
	jr z, .kantotrainer
	and a
	jr nz, .orangetrainer

.johtotrainer
	ld de, MUSIC_JOHTO_TRAINER_BATTLE
	jr .done

.orangetrainer
	ld de, MUSIC_ORANGE_TRAINER_BATTLE
	jr .done

.kantotrainer
	ld de, MUSIC_KANTO_TRAINER_BATTLE

.done
	call PlayMusic

	jmp PopBCDEHL

ClearBattleRAM:
	xor a
	ld [wBattlePlayerAction], a
	ld [wBattleResult], a

	ld hl, wPartyMenuCursor
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a

	ld [wMenuScrollPosition], a
	ld [wCriticalHit], a
	ld [wBattleMonSpecies], a
	ld [wBattleParticipantsNotFainted], a
	ld [wCurBattleMon], a
	ld [wForcedSwitch], a
	ld [wTimeOfDayPal], a
	ld [wPlayerTurnsTaken], a
	ld [wEnemyTurnsTaken], a
	ld [wEvolvableFlags], a

	ld hl, wPlayerHPPal
	ld [hli], a
	ld [hl], a

	ld hl, wBattleMonDVs
	ld [hli], a
	ld [hl], a

	ld hl, wEnemyMonDVs
	ld [hli], a
	ld [hl], a

; Clear the entire BattleMons area
	ld hl, wBattle
	ld bc, wBattleEnd - wBattle
	xor a
	rst ByteFill

	farcall ResetEnemyStatLevels

	call ClearWindowData

	ld hl, hBGMapAddress
	xor a ; LOW(vBGMap0)
	ld [hli], a
	ld [hl], HIGH(vBGMap0)
	ret

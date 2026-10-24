LoadWildMonData:
; Grass data carries one encounter rate, but GetMapEncounterRate still indexes
; wMornEncounterRate by wTimeOfDay, so fan the single byte across all four slots
; and leave the selection logic alone.
	call _GrassWildmonLookup
	ld a, 0 ; no-optimize a = 0
	jr nc, .got_rate
	inc hl
	inc hl
	call GetWildMonByte
.got_rate
	ld hl, wMornEncounterRate
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	call _WaterWildmonLookup
	ld a, 0 ; no-optimize a = 0
	jr nc, .no_copy
	inc hl
	inc hl
	call GetWildMonByte
.no_copy
	ld [wWaterEncounterRate], a
	ret

GetTimeOfDayNotEve:
	ld a, [wTimeOfDay]
	cp EVE_F
	ret nz
	ld a, NITE_F ; ld a, DAY_F to make evening use day encounters
	ret

FindNest:
; Parameters:
; e: JOHTO_REGION, KANTO_REGION or ORANGE_REGION
; wNamedObjectIndex: species
	ld a, e
	ld [wNestRegion], a ; stash it: the decoord below overwrites e
	hlcoord 0, 0
	ld bc, SCREEN_AREA
	xor a
	rst ByteFill
	ld a, [wNamedObjectIndex]
	call GetPokemonIndexFromID
	ld b, h
	ld c, l
	decoord 0, 0
; The Orange tables are not in this bank, so the scan reads every table byte
; through GetWildMonByte rather than directly. Slower, but this runs once when
; the AREA screen opens, not per frame.
	push de
	push bc
	ld a, [wNestRegion]
	ld hl, GrassWildmonTables
	call _WildmonTableForRegion
	pop bc
	pop de
	call _FindNestGrass
	push de
	push bc
	ld a, [wNestRegion]
	ld hl, WaterWildmonTables
	call _WildmonTableForRegion
	pop bc
	pop de
	call _FindNestWater
	ld a, [wNestRegion]
	and a
	ret nz ; roamers are Johto-only
	call .RoamMon1
	jr .RoamMon2

.RoamMon1:
	ld a, [wRoamMon1Species]
	ld b, a
	ld a, [wNamedObjectIndex]
	cp b
	ret nz
	ld a, [wRoamMon1MapGroup]
	ld b, a
	ld a, [wRoamMon1MapNumber]
	ld c, a
	call AppendNest
	ret nc
	ld [de], a
	inc de
	ret

.RoamMon2:
	ld a, [wRoamMon2Species]
	ld b, a
	ld a, [wNamedObjectIndex]
	cp b
	ret nz
	ld a, [wRoamMon2MapGroup]
	ld b, a
	ld a, [wRoamMon2MapNumber]
	ld c, a
	call AppendNest
	ret nc
	ld [de], a
	inc de
	ret

_FindNestGrass:
; hl: a grass table in the bank named by wWildMonBank; de: output; bc: species
	ld a, NUM_GRASSMON * 3
	ld [wNestScanCount], a
	ld a, GRASS_WILDDATA_LENGTH
	jr _FindNestInTable

_FindNestWater:
	ld a, NUM_WATERMON
	ld [wNestScanCount], a
	ld a, WATER_WILDDATA_LENGTH
_FindNestInTable:
; One loop for both, parameterised by mons-per-entry and entry stride. They were
; two near-identical copies; merging them pays for the far reads below.
	ld [wNestScanStride], a
.loop
	call GetWildMonByte
	cp -1
	ret z
	push bc
	push hl
	; use the math buffers as storage, since we're not doing any math
	call GetWildMonByte
	ldh [hMathBuffer], a
	inc hl
	call GetWildMonByte
	ldh [hMathBuffer + 1], a
	inc hl
	inc hl ; skip the encounter rate
	ld a, [wNestScanCount]
	call .SearchMapForMon
	jr nc, .next
	ld [de], a
	inc de

.next
	pop hl
	ld a, [wNestScanStride]
	ld c, a
	ld b, 0
	add hl, bc
	pop bc
	jr .loop

.SearchMapForMon:
	inc hl
.ScanMapLoop:
; The original compared the low byte and read the high one before branching,
; because `ld a, [hli]` leaves flags alone. GetWildMonByte does not, so the
; low-byte result has to be acted on before the second read.
	push af
	call GetWildMonByte
	inc hl
	cp c
	jr nz, .next_mon
	call GetWildMonByte
	cp b
	jr z, .found
.next_mon
	inc hl ; past the species high byte
	inc hl ; past the next level byte
	pop af
	dec a
	jr nz, .ScanMapLoop
	and a
	ret

.found
	pop af
	ldh a, [hMathBuffer]
	ld b, a
	ldh a, [hMathBuffer + 1]
	ld c, a

AppendNest:
; b, c: map group and number. Appends its landmark unless already present.
	push de
	call GetWorldMapLocation
	ld c, a
	hlcoord 0, 0
	ld de, SCREEN_AREA
.AppendNestLoop:
	ld a, [hli]
	cp c
	jr z, .found_nest
	dec de
	ld a, e
	or d
	jr nz, .AppendNestLoop
	ld a, c
	pop de
	scf
	ret

.found_nest
	pop de
	and a
	ret

TryWildEncounter::
; Try to trigger a wild encounter.
	call .EncounterRate
	jr nc, .no_battle
	call ChooseWildEncounter
	jr nz, .no_battle
	call CheckRepelEffect
	jr nc, .no_battle
	xor a
	ret

.no_battle
	xor a ; BATTLETYPE_NORMAL
	ld [wTempWildMonSpecies], a
	ld [wBattleType], a
	ld a, 1
	and a
	ret

.EncounterRate:
	call GetMapEncounterRate
	call ApplyMusicEffectOnEncounterRate
	call ApplyCleanseTagEffectOnEncounterRate
	call Random
	cp b
	ret

GetMapEncounterRate:
	ld hl, wMornEncounterRate
	call CheckOnWater
	ld a, wWaterEncounterRate - wMornEncounterRate
	jr z, .ok
	ld a, [wTimeOfDay]
.ok
	ld c, a
	ld b, 0
	add hl, bc
	ld b, [hl]
	ret

ApplyMusicEffectOnEncounterRate::
; Pokemon March and Ruins of Alph signal double encounter rate.
; Pokemon Lullaby halves encounter rate.
	ld a, [wMapMusic]
	cp MUSIC_POKEMON_MARCH
	jr z, .double
	cp MUSIC_RUINS_OF_ALPH_RADIO
	jr z, .double
	cp MUSIC_POKEMON_LULLABY
	ret nz
	srl b
	ret

.double
	sla b
	ret

ApplyCleanseTagEffectOnEncounterRate::
; Cleanse Tag halves encounter rate.
	ld hl, wPartyMon1Item
	ld de, PARTYMON_STRUCT_LENGTH
	ld a, [wPartyCount]
	ld c, a
.loop
	ld a, [hl]
	push hl
	call GetItemIndexFromID
	cphl16 CLEANSE_TAG
	pop hl
	jr z, .cleansetag
	add hl, de
	dec c
	jr nz, .loop
	ret

.cleansetag
	srl b
	ret

ChooseWildEncounter:
	call LoadWildMonDataPointer
	jr nc, .nowildbattle
	call CheckEncounterRoamMon
	jr c, .startwildbattle

	inc hl
	inc hl
	inc hl ; skip the map id and the encounter rate -- same width for grass and water now
	call CheckOnWater
	ld de, WaterMonProbTable
	jr z, .watermon
	call GetTimeOfDayNotEve
	ld bc, NUM_GRASSMON * 3
	rst AddNTimes
	ld de, GrassMonProbTable

.watermon
; hl contains the pointer to the wild mon data, let's save that to the stack
	push hl
.randomloop
	call Random
	cp 100
	jr nc, .randomloop
	inc a ; 1 <= a <= 100
	ld b, a
	ld h, d
	ld l, e
; This next loop chooses which mon to load up.
.prob_bracket_loop
	ld a, [hli]
	cp b
	jr nc, .got_it
	inc hl
	jr .prob_bracket_loop

.got_it
	ld c, [hl]
	ld b, 0
	pop hl
	add hl, bc ; this selects our mon
; The prob table above lives in this bank; the entry may not. Everything the
; entry is read for is the three bytes below, so switch only around them.
; Read all three bytes up front through GetWildMonByte. The old code paged the
; data bank in and held it across everything below -- which only worked while
; every table shared this bank, because paging in another one swaps out this
; very code.
	call GetWildMonByte
	ld b, a
	inc hl
	call GetWildMonByte
	ld c, a
	inc hl
	call GetWildMonByte
	push af
; Check if we buff the wild mon, and by how much.
	call Random
	cp 35 percent
	jr c, .ok
	inc b
	cp 65 percent
	jr c, .ok
	inc b
	cp 85 percent
	jr c, .ok
	inc b
; Store the level
.ok
	ld a, b
	ld [wCurPartyLevel], a

	pop af
	ld h, a ; species index high byte
	ld l, c
	call ValidateTempWildMonSpecies
	jr c, .nowildbattle

	ld a, l
	sub LOW(UNOWN)
	jr nz, .done
	if HIGH(UNOWN) > 1
		ld a, h
		cp HIGH(UNOWN)
	elif HIGH(UNOWN) == 1
		ld a, h
		dec a
	else
		or h
	endc
	jr nz, .done

	ld a, [wUnlockedUnowns]
	and a
	jr z, .nowildbattle

.done
	call GetPokemonIDFromIndex
	ld [wTempWildMonSpecies], a

.startwildbattle
	xor a
	ret

.nowildbattle
	ld a, 1
	and a
	ret

INCLUDE "data/wild/probabilities.asm"

CheckRepelEffect::
; If there is no active Repel, there's no need to be here.
	ld a, [wRepelEffect]
	and a
	jr z, .encounter
; Get the first Pokemon in your party that isn't fainted.
	ld hl, wPartyMon1HP
	ld bc, PARTYMON_STRUCT_LENGTH - 1
.loop
	ld a, [hli]
	or [hl]
	jr nz, .ok
	add hl, bc
	jr .loop

.ok
; to PartyMonLevel
rept 4
	dec hl
endr

	ld a, [wCurPartyLevel]
	cp [hl]
	jr nc, .encounter
	and a
	ret

.encounter
	scf
	ret

LoadWildMonDataPointer:
	call CheckOnWater
	jr z, _WaterWildmonLookup

_GrassWildmonLookup:
	ld hl, SwarmGrassWildMons
	ld a, BANK(SwarmGrassWildMons)
	ld [wWildMonBank], a
	ld bc, GRASS_WILDDATA_LENGTH
	call _SwarmWildmonCheck
	ret c
	call _SeasonGrassWildmonCheck
	ret c
	ld hl, GrassWildmonTables
	call _RegionWildmonTable
	ld bc, GRASS_WILDDATA_LENGTH
	jmp _NormalWildmonOK ; out of jr reach

_WaterWildmonLookup:
	ld hl, SwarmWaterWildMons
	ld a, BANK(SwarmWaterWildMons)
	ld [wWildMonBank], a
	ld bc, WATER_WILDDATA_LENGTH
	call _SwarmWildmonCheck
	ret c
	call _SeasonWaterWildmonCheck
	ret c
	ld hl, WaterWildmonTables
	call _RegionWildmonTable
	ld bc, WATER_WILDDATA_LENGTH
	jr _NormalWildmonOK

_RegionWildmonTable:
; hl: a NUM_REGIONS-entry table of `db BANK(table) / dw table`.
; Returns the current region's table in hl and stores its bank in wWildMonBank.
;
; The bank is per entry because the Orange tables live in $75, not $0a.
	call GetRegion
_WildmonTableForRegion:
; Same, for a region the caller names rather than the one the player is in.
; a: region
	ld [wNestRegion], a
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	add hl, de
	ld a, [hli]
	ld [wWildMonBank], a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

MACRO wildmon_table
	db BANK(\1)
	dw \1
ENDM

GrassWildmonTables:
; entries correspond to *_REGION constants
	table_width 3
	wildmon_table JohtoGrassWildMons
	wildmon_table KantoGrassWildMons
	wildmon_table OrangeGrassWildMons
	assert_table_length NUM_REGIONS

WaterWildmonTables:
	table_width 3
	wildmon_table JohtoWaterWildMons
	wildmon_table KantoWaterWildMons
	wildmon_table OrangeWaterWildMons
	assert_table_length NUM_REGIONS

_SwarmWildmonCheck:
	call CopyCurrMapDE
	push hl
	ld hl, wSwarmFlags
	bit SWARMFLAGS_DUNSPARCE_SWARM_F, [hl]
	pop hl
	jr z, .CheckYanma
	ld a, [wDunsparceMapGroup]
	cp d
	jr nz, .CheckYanma
	ld a, [wDunsparceMapNumber]
	cp e
	jr nz, .CheckYanma
	call LookUpWildmonsForMapDE
	jr nc, .noSwarm
	scf
	ret

.CheckYanma:
	push hl
	ld hl, wSwarmFlags
	bit SWARMFLAGS_YANMA_SWARM_F, [hl]
	pop hl
	jr z, .noSwarm
	ld a, [wYanmaMapGroup]
	cp d
	jr nz, .noSwarm
	ld a, [wYanmaMapNumber]
	cp e
	jr nz, .noSwarm
	call LookUpWildmonsForMapDE
	jr nc, .noSwarm
	scf
	ret

.noSwarm:
	and a
	ret

_NormalWildmonOK:
	call CopyCurrMapDE
	jr LookUpWildmonsForMapDE

CopyCurrMapDE:
	ld a, [wMapGroup]
	ld d, a
	ld a, [wMapNumber]
	ld e, a
	ret

LookUpGrassJohtoWildmons::
	ld hl, JohtoGrassWildMons
	ld a, BANK(JohtoGrassWildMons)
	ld [wWildMonBank], a
	ld bc, GRASS_WILDDATA_LENGTH
LookUpWildmonsForMapDE:
; Reads through GetWildMonByte, not directly: the table may be the Orange one in
; bank $75. Every caller must set wWildMonBank first.
.loop
	push hl
	call GetWildMonByte
	cp -1
	jr z, .nope
	cp d
	jr nz, .next
	inc hl
	call GetWildMonByte
	cp e
	jr z, .yup

.next
	pop hl
	add hl, bc
	jr .loop

.nope
	pop hl
	and a
	ret

.yup
	pop hl
	scf
	ret

InitRoamMons:
; initialize wRoamMon structs

; species
	ld hl, RAIKOU
	call GetPokemonIDFromIndex
	ld [wRoamMon1Species], a
	call SetSeenMon
	ld hl, ENTEI
	call GetPokemonIDFromIndex
	ld [wRoamMon2Species], a
	call SetSeenMon
	ld hl, SUICUNE
	call GetPokemonIDFromIndex
	call SetSeenMon

; level
	ld a, 50
	ld [wRoamMon1Level], a
	ld [wRoamMon2Level], a

; raikou starting map
	ld a, GROUP_ROUTE_42
	ld [wRoamMon1MapGroup], a
	ld a, MAP_ROUTE_42
	ld [wRoamMon1MapNumber], a

; entei starting map
	ld a, GROUP_ROUTE_37
	ld [wRoamMon2MapGroup], a
	ld a, MAP_ROUTE_37
	ld [wRoamMon2MapNumber], a

; hp
	xor a ; generate new stats
	ld [wRoamMon1HP], a
	ld [wRoamMon2HP], a

	ret

CheckEncounterRoamMon:
	push hl
; Don't trigger an encounter if we're on water.
	call CheckOnWater
	jr z, .DontEncounterRoamMon
; Load the current map group and number to de
	call CopyCurrMapDE
; Randomly select a beast.
	call Random
	cp 100 ; 25/64 chance
	jr nc, .DontEncounterRoamMon
	and %00000011 ; Of that, a 3/4 chance.  Running total: 75/256, or around 29.3%.
	jr z, .DontEncounterRoamMon
	dec a ; 1/3 chance that it's Entei, 1/3 chance that it's Raikou
; Compare its current location with yours
	ld hl, wRoamMon1MapGroup
	ld c, a
	ld b, 0
	ld a, 7 ; length of the roam_struct
	rst AddNTimes
	ld a, d
	cp [hl]
	jr nz, .DontEncounterRoamMon
	inc hl
	ld a, e
	cp [hl]
	jr nz, .DontEncounterRoamMon
; We've decided to take on a beast, so stage its information for battle.
	dec hl
	dec hl
	dec hl
	ld a, [hli]
	ld [wTempWildMonSpecies], a
	ld a, [hl]
	ld [wCurPartyLevel], a
	ld a, BATTLETYPE_ROAMING
	ld [wBattleType], a

	pop hl
	scf
	ret

.DontEncounterRoamMon:
	pop hl
	and a
	ret

UpdateRoamMons:
	ld a, [wRoamMon1MapGroup]
	cp GROUP_N_A
	jr z, .SkipRaikou
	ld b, a
	ld a, [wRoamMon1MapNumber]
	ld c, a
	call .Update
	ld a, b
	ld [wRoamMon1MapGroup], a
	ld a, c
	ld [wRoamMon1MapNumber], a

.SkipRaikou:
	ld a, [wRoamMon2MapGroup]
	cp GROUP_N_A
	jr z, .SkipEntei
	ld b, a
	ld a, [wRoamMon2MapNumber]
	ld c, a
	call .Update
	ld a, b
	ld [wRoamMon2MapGroup], a
	ld a, c
	ld [wRoamMon2MapNumber], a

.SkipEntei:
	ld a, [wRoamMon3MapGroup]
	cp GROUP_N_A
	jr z, .Finished
	ld b, a
	ld a, [wRoamMon3MapNumber]
	ld c, a
	call .Update
	ld a, b
	ld [wRoamMon3MapGroup], a
	ld a, c
	ld [wRoamMon3MapNumber], a

.Finished:
	jmp _BackUpMapIndices

.Update:
	call Random
	and %10000000 ; 50% chance to move
	ret z
	ld hl, RoamMaps
.loop
; Are we at the end of the table?
	ld a, [hl]
	cp -1
	ret z
; Is this the correct entry?
	ld a, b
	cp [hl]
	jr nz, .next
	inc hl
	ld a, c
	cp [hl]
	jr z, .yes
; We don't have the correct entry yet, so let's continue.  A 0 terminates each entry.
.next
	ld a, [hli]
	and a
	jr nz, .next
	jr .loop

; We have the correct entry now, so let's choose a random map from it.
.yes
	inc hl
	ld d, h
	ld e, l
.update_loop
	ld h, d
	ld l, e
; Choose which map to warp to.
	call Random
	and %00011111 ; 1/8n chance it moves to a completely random map, where n is the number of roaming connections from the current map.
	jr z, JumpRoamMon
	and %11
	cp [hl]
	jr nc, .update_loop ; invalid index, try again
	inc hl
	ld c, a
	ld b, 0
	add hl, bc
	add hl, bc
	ld a, [wRoamMons_LastMapGroup]
	cp [hl]
	jr nz, .done
	inc hl
	ld a, [wRoamMons_LastMapNumber]
	cp [hl]
	jr z, .update_loop
	dec hl

.done
	ld a, [hli]
	ld b, a
	ld c, [hl]
	ret

JumpRoamMons:
	ld a, [wRoamMon1MapGroup]
	cp GROUP_N_A
	jr z, .SkipRaikou
	call JumpRoamMon
	ld a, b
	ld [wRoamMon1MapGroup], a
	ld a, c
	ld [wRoamMon1MapNumber], a

.SkipRaikou:
	ld a, [wRoamMon2MapGroup]
	cp GROUP_N_A
	jr z, .SkipEntei
	call JumpRoamMon
	ld a, b
	ld [wRoamMon2MapGroup], a
	ld a, c
	ld [wRoamMon2MapNumber], a

.SkipEntei:
	ld a, [wRoamMon3MapGroup]
	cp GROUP_N_A
	jr z, _BackUpMapIndices
	call JumpRoamMon
	ld a, b
	ld [wRoamMon3MapGroup], a
	ld a, c
	ld [wRoamMon3MapNumber], a
	jr _BackUpMapIndices

JumpRoamMon:
.loop
	ld hl, RoamMaps
.innerloop1
	; 0-15 are all valid indexes into RoamMaps,
	; so this retry loop is unnecessary
	; since NUM_ROAMMON_MAPS happens to be 16
	call Random
	maskbits NUM_ROAMMON_MAPS
	cp NUM_ROAMMON_MAPS
	jr nc, .innerloop1
	inc a
	ld b, a
.innerloop2 ; Loop to get hl to the address of the chosen roam map.
	dec b
	jr z, .ok
.innerloop3 ; Loop to skip the current roam map, which is terminated by a 0.
	ld a, [hli]
	and a
	jr nz, .innerloop3
	jr .innerloop2
; Check to see if the selected map is the one the player is currently in.  If so, try again.
.ok
	ld a, [wMapGroup]
	cp [hl]
	jr nz, .done
	inc hl
	ld a, [wMapNumber]
	cp [hl]
	jr z, .loop
	dec hl
; Return the map group and number in bc.
.done
	ld a, [hli]
	ld b, a
	ld c, [hl]
	ret

_BackUpMapIndices:
	ld a, [wRoamMons_CurMapNumber]
	ld [wRoamMons_LastMapNumber], a
	ld a, [wRoamMons_CurMapGroup]
	ld [wRoamMons_LastMapGroup], a
	ld a, [wMapNumber]
	ld [wRoamMons_CurMapNumber], a
	ld a, [wMapGroup]
	ld [wRoamMons_CurMapGroup], a
	ret

INCLUDE "data/wild/roammon_maps.asm"

ValidateTempWildMonSpecies:
; Bounded by NUM_POKEMON_AND_VARIANTS, not NUM_POKEMON: variant species are
; numbered past NUM_POKEMON and are valid wild encounters. Bounding this by
; NUM_POKEMON makes a variant in a grass or water table silently produce no
; encounter at all.
	ld a, h
	or l
	scf
	ret z
	ld a, h
	if LOW(NUM_POKEMON_AND_VARIANTS) == $FF
		cp HIGH(NUM_POKEMON_AND_VARIANTS) + 1
	else
		cp HIGH(NUM_POKEMON_AND_VARIANTS)
		ccf
		ret nz
		ld a, l
		cp LOW(NUM_POKEMON_AND_VARIANTS) + 1
	endc
	ccf
	ret

GetCallerRouteWildGrassMons:
	farcall GetCallerLocation
	ld d, b
	ld e, c
	ld hl, JohtoGrassWildMons
	ld a, BANK(JohtoGrassWildMons) ; both tables share it
	ld [wWildMonBank], a
	ld bc, GRASS_WILDDATA_LENGTH
	call LookUpWildmonsForMapDE
	jr c, .found
	ld hl, KantoGrassWildMons
	call LookUpWildmonsForMapDE
	ret nc ; no carry = no grass wild mons for that route
.found
	ld bc, 3 ; skip the map ID and the encounter rate
	add hl, bc
	call GetTimeOfDayNotEve
	ld bc, NUM_GRASSMON * 3
	rst AddNTimes
	scf
	ret

; Finds a rare wild Pokemon in the route of the trainer calling, then checks if it's been Seen already.
; The trainer will then tell you about the Pokemon if you haven't seen it.
RandomUnseenWildMon:
	call GetCallerRouteWildGrassMons
	jr nc, .done
	push hl
.randloop1
	call Random
	and %11
	jr z, .randloop1
	ld bc, 10 ; skip three mons plus the level of the fourth
	add hl, bc
	ld c, a
	add hl, bc
	add hl, bc
	add hl, bc
	; We now have the pointer to one of the last (rarest) three wild Pokemon found in that area.
	; Load the species index of this rare Pokemon
	ld a, [hli]
	ld d, [hl]
	ld e, a
	pop hl
	inc hl ; Species index of the most common Pokemon on that route
	ld b, 4
.loop2
	ld a, [hli]
	cp e ; Compare this common Pokemon with the rare one stored in de.
	ld a, [hli]
	jr nz, .next
	cp d
	jr z, .done
.next
	inc hl
	dec b
	jr nz, .loop2
; This Pokemon truly is rare.
	push de
	call CheckSeenMonIndex
	pop bc
	jr nz, .done
; Since we haven't seen it, have the caller tell us about it.
	ld de, wStringBuffer1
	call CopyName1
	ld h, b
	ld l, c
	call GetPokemonIDFromIndex
	ld [wNamedObjectIndex], a
	call GetPokemonName
	ld hl, .JustSawSomeRareMonText
	call PrintText
	xor a
	ld [wScriptVar], a
	ret

.done
	ld a, $1
	ld [wScriptVar], a
	ret

.JustSawSomeRareMonText:
	text_far _JustSawSomeRareMonText
	text_end

RandomPhoneWildMon:
	call GetCallerRouteWildGrassMons
	call Random
	and %11
	ld c, a
	ld b, 0
	add hl, bc
	add hl, bc
	add hl, bc
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call GetPokemonIDFromIndex
	ld [wNamedObjectIndex], a
	call GetPokemonName
	ld hl, wStringBuffer1
	ld de, wStringBuffer4
	ld bc, MON_NAME_LENGTH
	jmp CopyBytes

RandomPhoneMon:
; Get a random monster owned by the trainer who's calling.
	farcall GetCallerLocation
	ld hl, TrainerGroups
	ld a, d
	dec a
	ld c, a
	ld b, 0
	add hl, bc
	add hl, bc
	add hl, bc
	ld a, BANK(TrainerGroups)
	call GetFarByte
	ld [wTrainerGroupBank], a
	inc hl
	ld a, BANK(TrainerGroups)
	call GetFarWord

.skip_trainer
	dec e
	jr z, .skipped
.skip
	ld a, [wTrainerGroupBank]
	call GetFarByte
	add l
	ld l, a
	jr nc, .skip_trainer
	inc h
	jr .skip_trainer
.skipped
	inc hl

.skip_name
	ld a, [wTrainerGroupBank]
	call GetFarByte
	inc hl
	cp '@'
	jr nz, .skip_name

	ld a, [wTrainerGroupBank]
	call GetFarByte
	inc hl
	ld c, a
	ld a, 3
	bit TRAINERTYPE_ITEM_F, c
	jr z, .no_item
	inc a
	inc a
.no_item
	bit TRAINERTYPE_MOVES_F, c
	jr z, .no_moves
	add NUM_MOVES * 2
.no_moves
	ld c, a
	ld b, 0

	ld e, b
	push hl
.count_mon
	inc e
	add hl, bc
	ld a, [wTrainerGroupBank]
	call GetFarByte
	cp -1
	jr nz, .count_mon
	pop hl

.rand
	call Random
	maskbits PARTY_LENGTH
	cp e
	jr nc, .rand

	inc a
.get_mon
	dec a
	jr z, .got_mon
	add hl, bc
	jr .get_mon
.got_mon

	inc hl ; species
	ld a, [wTrainerGroupBank]
	call GetFarWord
	call GetPokemonIDFromIndex
	ld [wNamedObjectIndex], a
	call GetPokemonName
	ld hl, wStringBuffer1
	ld de, wStringBuffer4
	ld bc, MON_NAME_LENGTH
	jmp CopyBytes

INCLUDE "data/wild/johto_grass.asm"
INCLUDE "data/wild/johto_water.asm"
INCLUDE "data/wild/kanto_grass.asm"
INCLUDE "data/wild/kanto_water.asm"
; Placed down here, away from _GrassWildmonLookup, on purpose: inserting it up
; there stretches the existing jr _NormalWildmonOK past its 128-byte reach.
;
; Called after the swarm check so swarms still win -- they are event-driven and
; rarer than the ambient seasonal table. bc still holds the wilddata stride the
; swarm check was set up with.
_SeasonGrassWildmonCheck:
	ld hl, SeasonGrassTables
	jr _SeasonWildmonCheck

_SeasonWaterWildmonCheck:
	ld hl, SeasonWaterTables
_SeasonWildmonCheck:
	ld a, [wSeason]
	maskbits NUM_SEASONS ; wSeason gets poked by hand in testing; never index off the end
	ld e, a
	add a
	add e
	ld e, a
	ld d, 0
	add hl, de
	ld a, [hli]
	ld [wWildMonBank], a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CopyCurrMapDE
	jmp LookUpWildmonsForMapDE

SeasonGrassTables:
; entries correspond to SPRING_F, SUMMER_F, AUTUMN_F, WINTER_F
	table_width 3
	wildmon_table SpringGrassWildMons
	wildmon_table SummerGrassWildMons
	wildmon_table AutumnGrassWildMons
	wildmon_table WinterGrassWildMons
	assert_table_length NUM_SEASONS

SeasonWaterTables:
	table_width 3
	wildmon_table SpringWaterWildMons
	wildmon_table SummerWaterWildMons
	wildmon_table AutumnWaterWildMons
	wildmon_table WinterWaterWildMons
	assert_table_length NUM_SEASONS

INCLUDE "data/wild/swarm_grass.asm"
INCLUDE "data/wild/swarm_water.asm"

; The seasonal tables live in their own section, "Season Wild Data", in main.asm.

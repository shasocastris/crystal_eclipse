FollowerScript::
	callasm CheckFollowerVisible
	iffalse .done
	faceplayer
	callasm DoFollowerInteraction
	waitbutton
	closetext
.done
	end

CheckFollowerVisible:
	ld a, [wObject1Struct + OBJECT_FLAGS1]
	cpl
	and 1 << INVISIBLE_F
	ld [wScriptVar], a
	ret

MACRO interaction
	dw \1 ; species index, or -1
	db \2 ; type the mon must have
	db \3 ; type the mon must not have
	db \4 ; landmark
	if STRCMP("\5", "-1") == 0
		db -1, -1
	else
		map_id \5
	endc
	db \6 ; time of day mask
	db \7 ; OW_WEATHER_*
	db \8 ; status mask
	dw \9 ; event that must be set
	dw \<10> ; script
ENDM

rsreset
DEF FOLLOWER_INT_SPECIES  rw
DEF FOLLOWER_INT_TYPE_INC rb
DEF FOLLOWER_INT_TYPE_EXC rb
DEF FOLLOWER_INT_LANDMARK rb
DEF FOLLOWER_INT_MAP      rw
DEF FOLLOWER_INT_TIME     rb
DEF FOLLOWER_INT_WEATHER  rb
DEF FOLLOWER_INT_STATUS   rb
DEF FOLLOWER_INT_EVENT    rw
DEF FOLLOWER_INT_SCRIPT   rw
DEF FOLLOWER_INT_ROW_LENGTH EQU _RS

FollowerInteractionTable:
; The first row that matches every condition wins. -1 matches anything.
;	interaction species,    type-in,      type-out, landmark,                  map,                  time, weather,                    status,     event,                       script
	interaction -1,         -1,           -1,       -1,                        -1,                   -1,   -1,                         SLP_MASK,   -1,                          SleepInteraction
	interaction -1,         -1,           -1,       -1,                        -1,                   -1,   -1,                         1 << PSN,   -1,                          PoisonInteraction
	interaction -1,         -1,           -1,       -1,                        -1,                   -1,   -1,                         1 << BRN,   -1,                          BurnInteraction
	interaction -1,         -1,           -1,       -1,                        -1,                   -1,   -1,                         1 << FRZ,   -1,                          FrozenInteraction
	interaction -1,         -1,           -1,       -1,                        -1,                   -1,   -1,                         1 << PAR,   -1,                          ParalyzeInteraction
	interaction CHIKORITA,  -1,           -1,       LANDMARK_ROUTE_29,         -1,                   -1,   -1,                         -1,         -1,                          ChikoritaRoute29Interaction
	interaction TOTODILE,   -1,           -1,       LANDMARK_ROUTE_30,         -1,                   -1,   -1,                         -1,         -1,                          TotodileRoute30Interaction
	interaction CYNDAQUIL,  -1,           -1,       LANDMARK_ROUTE_31,         -1,                   -1,   -1,                         -1,         -1,                          CyndaquilRoute31Interaction
	interaction -1,         ICE,          -1,       LANDMARK_DARK_CAVE,        -1,                   -1,   -1,                         -1,         -1,                          DarkCaveInteraction
	interaction BELLSPROUT, -1,           -1,       LANDMARK_SPROUT_TOWER,     -1,                   -1,   -1,                         -1,         -1,                          BellsproutSproutTowerInteraction
	interaction UNOWN,      -1,           -1,       LANDMARK_RUINS_OF_ALPH,    -1,                   -1,   -1,                         -1,         -1,                          UnownRuinsOfAlphInteraction
	interaction -1,         FIRE,         -1,       LANDMARK_AZALEA_TOWN,      -1,                   -1,   -1,                         -1,         -1,                          AzaleaTownInteraction
	interaction SLOWPOKE,   -1,           -1,       LANDMARK_SLOWPOKE_WELL,    -1,                   -1,   -1,                         -1,         EVENT_CLEARED_SLOWPOKE_WELL, SlowpokeWellInteraction
	interaction SLOWBRO,    -1,           -1,       LANDMARK_SLOWPOKE_WELL,    -1,                   -1,   -1,                         -1,         EVENT_CLEARED_SLOWPOKE_WELL, SlowpokeWellInteraction
	interaction SLOWKING,   -1,           -1,       LANDMARK_SLOWPOKE_WELL,    -1,                   -1,   -1,                         -1,         EVENT_CLEARED_SLOWPOKE_WELL, SlowpokeWellInteraction
	interaction SLOWPOKE,   -1,           -1,       LANDMARK_SLOWPOKE_WELL,    -1,                   -1,   -1,                         -1,         -1,                          SlowpokeWellRocketInteraction
	interaction SLOWBRO,    -1,           -1,       LANDMARK_SLOWPOKE_WELL,    -1,                   -1,   -1,                         -1,         -1,                          SlowpokeWellRocketInteraction
	interaction SLOWKING,   -1,           -1,       LANDMARK_SLOWPOKE_WELL,    -1,                   -1,   -1,                         -1,         -1,                          SlowpokeWellRocketInteraction
	interaction -1,         FIRE,         -1,       LANDMARK_SLOWPOKE_WELL,    -1,                   -1,   -1,                         -1,         -1,                          SlowpokeWellFireMonInteraction
	interaction -1,         WATER,        -1,       LANDMARK_SLOWPOKE_WELL,    -1,                   -1,   -1,                         -1,         -1,                          WaterMonHappyInteraction
	interaction FARFETCH_D, -1,           -1,       LANDMARK_ILEX_FOREST,      -1,                   -1,   -1,                         -1,         -1,                          DancingHappilyInteraction
	interaction CELEBI,     -1,           -1,       LANDMARK_ILEX_FOREST,      -1,                   -1,   -1,                         -1,         -1,                          IlexForestCelebiInteraction
	interaction HERACROSS,  -1,           -1,       LANDMARK_ILEX_FOREST,      -1,                   -1,   -1,                         -1,         -1,                          HeracrossInteraction
	interaction SUDOWOODO,  -1,           -1,       LANDMARK_ROUTE_36,         -1,                   -1,   -1,                         -1,         -1,                          Route36Interaction
	interaction CLEFAIRY,   -1,           -1,       -1,                        GOLDENROD_GYM,        -1,   -1,                         -1,         -1,                          GoldenrodGymInteraction
	interaction -1,         ELECTRIC,     -1,       LANDMARK_RADIO_TOWER,      -1,                   -1,   -1,                         -1,         -1,                          RadioTowerElectricInteraction
	interaction -1,         GHOST,        -1,       LANDMARK_RADIO_TOWER,      -1,                   -1,   -1,                         -1,         -1,                          RadioTowerGhostInteraction
	interaction -1,         BUG,          -1,       LANDMARK_NATIONAL_PARK,    -1,                   -1,   -1,                         -1,         -1,                          NationalParkInteraction
	interaction PICHU,      -1,           -1,       -1,                        DANCE_THEATER,        -1,   -1,                         -1,         -1,                          DanceTheaterPichuInteraction
	interaction BELLOSSOM,  -1,           -1,       -1,                        DANCE_THEATER,        -1,   -1,                         -1,         -1,                          DanceTheaterBellossomInteraction
	interaction RAIKOU,     -1,           -1,       LANDMARK_BURNED_TOWER,     -1,                   -1,   -1,                         -1,         -1,                          LegendaryDogInteraction
	interaction ENTEI,      -1,           -1,       LANDMARK_BURNED_TOWER,     -1,                   -1,   -1,                         -1,         -1,                          LegendaryDogInteraction
	interaction SUICUNE,    -1,           -1,       LANDMARK_BURNED_TOWER,     -1,                   -1,   -1,                         -1,         -1,                          LegendaryDogInteraction
	interaction HO_OH,      -1,           -1,       LANDMARK_BURNED_TOWER,     -1,                   -1,   -1,                         -1,         -1,                          ShookTheTowerInteraction
	interaction HO_OH,      -1,           -1,       LANDMARK_TIN_TOWER,        -1,                   -1,   -1,                         -1,         -1,                          TinTowerInteraction
	interaction TAUROS,     -1,           -1,       LANDMARK_ROUTE_39,         -1,                   -1,   -1,                         -1,         -1,                          Route39TaurosInteraction
	interaction MILTANK,    -1,           -1,       LANDMARK_ROUTE_39,         -1,                   -1,   -1,                         -1,         -1,                          Route39MiltankInteraction
	interaction AMPHAROS,   -1,           -1,       LANDMARK_LIGHTHOUSE,       -1,                   -1,   -1,                         -1,         -1,                          LighthouseInteraction
	interaction KRABBY,     -1,           -1,       LANDMARK_CIANWOOD_CITY,    -1,                   -1,   -1,                         -1,         -1,                          CianwoodCityInteraction
	interaction POLIWAG,    -1,           -1,       LANDMARK_ROUTE_40,         -1,                   -1,   -1,                         -1,         -1,                          PoliwagInteraction
	interaction POLIWAG,    -1,           -1,       LANDMARK_WHIRL_ISLANDS,    -1,                   -1,   -1,                         -1,         -1,                          PoliwagInteraction
	interaction LUGIA,      -1,           -1,       LANDMARK_WHIRL_ISLANDS,    -1,                   -1,   -1,                         -1,         -1,                          WhirlIslandsLugiaInteraction
	interaction -1,         WATER,        -1,       LANDMARK_WHIRL_ISLANDS,    -1,                   -1,   -1,                         -1,         -1,                          WaterMonHappyInteraction
	interaction -1,         ROCK,         -1,       LANDMARK_ROUTE_42,         -1,                   -1,   -1,                         -1,         -1,                          Route42Interaction
	interaction DITTO,      -1,           -1,       LANDMARK_ROUTE_15,         -1,                   -1,   -1,                         -1,         -1,                          Route15DittoInteraction
	interaction -1,         FLYING,       -1,       LANDMARK_ROUTE_18,         -1,                   -1,   -1,                         -1,         -1,                          Route18FlyingInteraction
	interaction MAGIKARP,   -1,           -1,       LANDMARK_LAKE_OF_RAGE,     -1,                   -1,   -1,                         -1,         -1,                          LakeOfRageMagikarpInteraction
	interaction GYARADOS,   -1,           -1,       LANDMARK_LAKE_OF_RAGE,     -1,                   -1,   -1,                         -1,         -1,                          HowledLoudlyInteraction
	interaction ELECTRODE,  -1,           -1,       -1,                        TEAM_ROCKET_BASE_B1F, -1,   -1,                         -1,         -1,                          TeamRocketBaseInteraction
	interaction ELECTRODE,  -1,           -1,       -1,                        TEAM_ROCKET_BASE_B2F, -1,   -1,                         -1,         -1,                          TeamRocketBaseInteraction
	interaction ELECTRODE,  -1,           -1,       -1,                        TEAM_ROCKET_BASE_B3F, -1,   -1,                         -1,         -1,                          TeamRocketBaseInteraction
	interaction -1,         ICE,          -1,       LANDMARK_ICE_PATH,         -1,                   -1,   -1,                         -1,         -1,                          ColdIceMonInteraction
	interaction -1,         GRASS,        -1,       LANDMARK_ICE_PATH,         -1,                   -1,   -1,                         -1,         -1,                          ColdGrassMonInteraction
	interaction -1,         ICE,          -1,       -1,                        MAHOGANY_GYM,         -1,   -1,                         -1,         -1,                          ColdIceMonInteraction
	interaction -1,         GRASS,        -1,       -1,                        MAHOGANY_GYM,         -1,   -1,                         -1,         -1,                          ColdGrassMonInteraction
	interaction -1,         DRAGON,       -1,       LANDMARK_DRAGONS_DEN,      -1,                   -1,   -1,                         -1,         -1,                          DragonsDenInteraction
	interaction -1,         -1,           -1,       LANDMARK_SILVER_CAVE,      -1,                   -1,   -1,                         -1,         -1,                          SilverCaveInteraction
	interaction MEGANIUM,   -1,           -1,       LANDMARK_VICTORY_ROAD,     -1,                   -1,   -1,                         -1,         -1,                          VictoryRoadMeganiumInteraction
	interaction TYPHLOSION, -1,           -1,       LANDMARK_VICTORY_ROAD,     -1,                   -1,   -1,                         -1,         -1,                          VictoryRoadTyphlosionInteraction
	interaction FERALIGATR, -1,           -1,       LANDMARK_VICTORY_ROAD,     -1,                   -1,   -1,                         -1,         -1,                          VictoryRoadFeraligatrInteraction
	interaction BULBASAUR,  -1,           -1,       LANDMARK_ROUTE_1,          -1,                   -1,   -1,                         -1,         -1,                          Route1Interaction
	interaction CHARMANDER, -1,           -1,       LANDMARK_ROUTE_2,          -1,                   -1,   -1,                         -1,         -1,                          Route2CharmanderInteraction
	interaction PICHU,      -1,           -1,       LANDMARK_ROUTE_2,          -1,                   -1,   -1,                         -1,         -1,                          DancingHappilyInteraction
	interaction PIKACHU,    -1,           -1,       LANDMARK_ROUTE_2,          -1,                   -1,   -1,                         -1,         -1,                          DancingHappilyInteraction
	interaction RAICHU,     -1,           -1,       LANDMARK_ROUTE_2,          -1,                   -1,   -1,                         -1,         -1,                          DancingHappilyInteraction
	interaction HERACROSS,  -1,           -1,       LANDMARK_ROUTE_2,          -1,                   -1,   -1,                         -1,         -1,                          HeracrossInteraction
	interaction SQUIRTLE,   -1,           -1,       LANDMARK_ROUTE_3,          -1,                   -1,   -1,                         -1,         -1,                          Route3Interaction
	interaction CLEFFA,     -1,           -1,       LANDMARK_MT_MOON,          -1,                   -1,   -1,                         -1,         -1,                          MtMoonInteraction
	interaction CLEFAIRY,   -1,           -1,       LANDMARK_MT_MOON,          -1,                   -1,   -1,                         -1,         -1,                          MtMoonInteraction
	interaction CLEFABLE,   -1,           -1,       LANDMARK_MT_MOON,          -1,                   -1,   -1,                         -1,         -1,                          MtMoonInteraction
	interaction PICHU,      -1,           -1,       LANDMARK_POWER_PLANT,      -1,                   -1,   -1,                         -1,         -1,                          PowerPlantPikachuInteraction
	interaction PIKACHU,    -1,           -1,       LANDMARK_POWER_PLANT,      -1,                   -1,   -1,                         -1,         -1,                          PowerPlantPikachuInteraction
	interaction RAICHU,     -1,           -1,       LANDMARK_POWER_PLANT,      -1,                   -1,   -1,                         -1,         -1,                          PowerPlantPikachuInteraction
	interaction ONIX,       -1,           -1,       LANDMARK_ROCK_TUNNEL,      -1,                   -1,   -1,                         -1,         -1,                          RockTunnelOnixInteraction
	interaction STEELIX,    -1,           -1,       LANDMARK_ROCK_TUNNEL,      -1,                   -1,   -1,                         -1,         -1,                          RockTunnelOnixInteraction
	interaction -1,         ROCK,         -1,       LANDMARK_ROCK_TUNNEL,      -1,                   -1,   -1,                         -1,         -1,                          RockTunnelRockMonInteraction
	interaction DIGLETT,    -1,           -1,       LANDMARK_DIGLETTS_CAVE,    -1,                   -1,   -1,                         -1,         -1,                          DiglettsCaveInteraction
	interaction DUGTRIO,    -1,           -1,       LANDMARK_DIGLETTS_CAVE,    -1,                   -1,   -1,                         -1,         -1,                          DiglettsCaveInteraction
	interaction -1,         PSYCHIC_TYPE, -1,       -1,                        MR_PSYCHICS_HOUSE,    -1,   -1,                         -1,         -1,                          MrPsychicsHouseInteraction
	interaction PORYGON,    -1,           -1,       LANDMARK_CELADON_CITY,     -1,                   -1,   -1,                         -1,         -1,                          CeladonCityPorygonInteraction
	interaction -1,         GHOST,        -1,       LANDMARK_LAVENDER_TOWN,    -1,                   -1,   -1,                         -1,         -1,                          LavenderTownInteraction
	interaction LUGIA,      -1,           -1,       LANDMARK_SHAMOUTI_ISLAND,  -1,                   -1,   -1,                         -1,         -1,                          ShamoutiLegendInteraction
	interaction ARTICUNO,   -1,           -1,       LANDMARK_SHAMOUTI_ISLAND,  -1,                   -1,   -1,                         -1,         -1,                          ShamoutiLegendInteraction
	interaction ZAPDOS,     -1,           -1,       LANDMARK_SHAMOUTI_ISLAND,  -1,                   -1,   -1,                         -1,         -1,                          ShamoutiLegendInteraction
	interaction MOLTRES,    -1,           -1,       LANDMARK_SHAMOUTI_ISLAND,  -1,                   -1,   -1,                         -1,         -1,                          ShamoutiLegendInteraction
	interaction -1,         WATER,        -1,       LANDMARK_VALENCIA_ISLAND,  -1,                   -1,   -1,                         -1,         -1,                          SeaBreezeInteraction
	interaction -1,         WATER,        -1,       LANDMARK_SHAMOUTI_ISLAND,  -1,                   -1,   -1,                         -1,         -1,                          SeaBreezeInteraction
	interaction -1,         ICE,          -1,       -1,                        -1,                   -1,   OW_WEATHER_SNOW,            -1,         -1,                          ColdIceMonInteraction
	interaction -1,         FIRE,         -1,       -1,                        -1,                   -1,   OW_WEATHER_SNOW,            -1,         -1,                          SnowFireMonInteraction
	interaction -1,         -1,           -1,       -1,                        -1,                   -1,   OW_WEATHER_SNOW,            -1,         -1,                          SnowInteraction
	interaction -1,         WATER,        -1,       -1,                        -1,                   -1,   OW_WEATHER_RAIN,            -1,         -1,                          WaterMonHappyInteraction
	interaction -1,         WATER,        -1,       -1,                        -1,                   -1,   OW_WEATHER_THUNDERSTORM,    -1,         -1,                          WaterMonHappyInteraction
	interaction -1,         FIRE,         -1,       -1,                        -1,                   -1,   OW_WEATHER_RAIN,            -1,         -1,                          RainFireMonInteraction
	interaction -1,         FIRE,         -1,       -1,                        -1,                   -1,   OW_WEATHER_THUNDERSTORM,    -1,         -1,                          RainFireMonInteraction
	interaction -1,         ELECTRIC,     -1,       -1,                        -1,                   -1,   OW_WEATHER_THUNDERSTORM,    -1,         -1,                          ThunderElectricMonInteraction
	interaction -1,         GRASS,        -1,       -1,                        -1,                   -1,   OW_WEATHER_SUN,             -1,         -1,                          SunGrassMonInteraction
	interaction -1,         FIRE,         -1,       -1,                        -1,                   -1,   OW_WEATHER_SUN,             -1,         -1,                          SunGrassMonInteraction
	interaction -1,         ROCK,         -1,       -1,                        -1,                   -1,   OW_WEATHER_SANDSTORM,       -1,         -1,                          SandstormSafeInteraction
	interaction -1,         GROUND,       -1,       -1,                        -1,                   -1,   OW_WEATHER_SANDSTORM,       -1,         -1,                          SandstormSafeInteraction
	interaction -1,         STEEL,        -1,       -1,                        -1,                   -1,   OW_WEATHER_SANDSTORM,       -1,         -1,                          SandstormSafeInteraction
	interaction -1,         -1,           -1,       -1,                        -1,                   -1,   OW_WEATHER_SANDSTORM,       -1,         -1,                          SandstormInteraction
	interaction -1,         -1,           -1,       -1,                        -1,                   -1,   OW_WEATHER_CHERRY_BLOSSOMS, -1,         -1,                          CherryBlossomInteraction
	; the default must stay last
	interaction -1,         -1,           -1,       -1,                        -1,                   -1,   -1,                         -1,         -1,                          DefaultInteraction

DoFollowerInteraction:
; Call the script of the first FollowerInteractionTable row that matches.
	call StoreFollowerNickInBuffer
	ld a, [wFollowerSpriteID]
	ld [wCurSpecies], a
	call GetBaseData
	ld a, [wFollowerPartyNum]
	ld hl, wPartyMon1Status
	ld bc, PARTYMON_STRUCT_LENGTH
	rst AddNTimes
	ld d, [hl]
; e = 1 << time of day
	ld a, [wTimeOfDay]
	inc a
	ld e, a
	xor a
	scf
.time_mask
	rla
	dec e
	jr nz, .time_mask
	ld e, a
	push de
	ld a, [wFollowerSpriteID]
	call GetPokemonIndexFromID
	ld b, h
	ld c, l
	pop de
	ld hl, FollowerInteractionTable
.loop
	push hl
	call .MatchRow
	pop hl
	jr z, .found
	push de
	ld de, FOLLOWER_INT_ROW_LENGTH
	add hl, de
	pop de
	jr .loop

.found
	ld de, FOLLOWER_INT_SCRIPT
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld b, BANK(@)
	farjp ScriptCall

.MatchRow:
; Return z if row hl matches species bc, status d and time mask e.
	ld a, [hli]
	and [hl]
	inc a
	jr z, .any_species
	dec hl
	ld a, [hli]
	cp c
	ret nz
	ld a, [hl]
	cp b
	ret nz
.any_species
	inc hl
	ld a, [hli]
	cp -1
	jr z, .any_type_in
	push hl
	ld hl, wBaseType1
	cp [hl]
	inc hl
	jr z, .has_type
	cp [hl]
.has_type
	pop hl
	ret nz
.any_type_in
	ld a, [hli]
	cp -1
	jr z, .any_type_out
	push hl
	ld hl, wBaseType1
	cp [hl]
	inc hl
	jr z, .excluded
	cp [hl]
.excluded
	pop hl
	jr z, .fail
.any_type_out
	ld a, [hli]
	cp -1
	jr z, .any_landmark
	push hl
	ld hl, wCurLandmark
	cp [hl]
	pop hl
	ret nz
.any_landmark
	ld a, [hli]
	cp -1
	jr z, .any_map
	push hl
	ld hl, wMapGroup
	cp [hl]
	pop hl
	ret nz
	ld a, [hl]
	push hl
	ld hl, wMapNumber
	cp [hl]
	pop hl
	ret nz
.any_map
	inc hl
	ld a, [hli]
	cp -1
	jr z, .any_time
	and e
	jr z, .fail
.any_time
	ld a, [hli]
	cp -1
	jr z, .any_weather
	push hl
	ld hl, wCurWeather
	cp [hl]
	pop hl
	ret nz
.any_weather
	ld a, [hli]
	cp -1
	jr z, .any_status
	and d
	jr z, .fail
.any_status
	ld a, [hli]
	and [hl]
	inc a
	ret z
	push de
	push bc
	ld a, [hld]
	ld d, a
	ld e, [hl]
	ld b, CHECK_FLAG
	call EventFlagAction
	pop bc
	pop de
	and a
	jr z, .fail
	xor a
	ret

.fail
	or 1
	ret

StoreFollowerNickInBuffer:
	ld a, [wFollowerPartyNum]
	ld hl, wPartyMonNicknames
	call SkipNames
	ld de, wStringBuffer1
	ld bc, MON_NAME_LENGTH
	jmp CopyBytes

; Shared texts

SeemsVeryHappyText:
	text_ram wStringBuffer1
	text " seems"
	line "to be very happy!"
	done

ShookTheTowerText:
	text_ram wStringBuffer1
	text " shook"
	line "the tower with its"
	cont "voice!"
	done

HowledLoudlyText:
	text_ram wStringBuffer1
	text " howled"
	line "very loudly!"
	done

DancingHappilyText:
	text_ram wStringBuffer1
	text " is"
	line "dancing around"
	cont "happily!"
	done

WaterMonHappyText:
	text_ram wStringBuffer1
	text " seems"
	line "happy to be all"
	cont "wet!"
	done

UnhappyWetText:
	text_ram wStringBuffer1
	text " seems"
	line "very unhappy to be"
	cont "wet…"
	done

ColdIceMonText:
	text_ram wStringBuffer1
	text " is"
	line "cheerful because"
	cont "of the cold!"
	done

; Interaction scripts. Each one is called by FollowerScript, which
; waits for a button and closes the text box afterwards.

DefaultInteraction:
	applymovement FOLLOWER, .HopMovement
	opentext
	followcry
	random 3
	ifequal 1, .sniffing
	ifequal 2, .looking
	writetext .HappyText
	end

.sniffing
	writetext .SniffingText
	end

.looking
	writetext .LookingText
	end

.HopMovement:
	jump_in_place
	jump_in_place
	step_end

.HappyText:
	text_ram wStringBuffer1
	text " is"
	line "happy to be with"
	cont "you!"
	done

.SniffingText:
	text_ram wStringBuffer1
	text " is"
	line "sniffing around"
	cont "curiously."
	done

.LookingText:
	text_ram wStringBuffer1
	text " is"
	line "looking up at you."
	done

SleepInteraction:
	showemote EMOTE_SLEEP, FOLLOWER, 30
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "looking a little"
	cont "sleepy."
	done

PoisonInteraction:
	showemote EMOTE_SAD, FOLLOWER, 30
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " looks"
	line "rather ill."
	done

BurnInteraction:
	showemote EMOTE_SHOCK, FOLLOWER, 30
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " seems"
	line "to be in a little"
	cont "pain."
	done

FrozenInteraction:
	showemote EMOTE_SHOCK, PLAYER, 30
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "covered in ice!"
	done

ParalyzeInteraction:
	showemote EMOTE_BOLT, FOLLOWER, 30
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "looking a little"
	cont "sluggish."
	done

ChikoritaRoute29Interaction:
	opentext
	followcry
	random 2
	iftrue .twitch
	writetext .WavingText
	end

.twitch
	writetext .TwitchText
	end

.WavingText:
	text_ram wStringBuffer1
	text " is"
	line "waving its leaf"
	cont "around."
	done

.TwitchText:
	text_ram wStringBuffer1
	text " is"
	line "making its leaf"
	cont "twitch."
	done

TotodileRoute30Interaction:
	opentext
	followcry
	random 2
	iftrue .mouth
	writetext .JawText
	end

.mouth
	writetext .MouthText
	end

.JawText:
	text_ram wStringBuffer1
	text " is"
	line "moving its jaw."
	done

.MouthText:
	text_ram wStringBuffer1
	text " is"
	line "opening and"
	cont "closing its mouth."
	done

CyndaquilRoute31Interaction:
	opentext
	followcry
	random 2
	iftrue .one
	writetext .CoupleText
	end

.one
	writetext .OneText
	end

.CoupleText:
	text_ram wStringBuffer1
	text " blew"
	line "out a couple of"
	cont "fireballs."
	done

.OneText:
	text_ram wStringBuffer1
	line "blew out a"
	cont "fireball…"
	done

DarkCaveInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "cheerful that it's"
	cont "become cold."
	done

BellsproutSproutTowerInteraction:
	opentext
	followcry
	random 2
	iftrue .strange
	writetext .PleasedText
	end

.strange
	writetext .StrangeText
	end

.PleasedText:
	text_ram wStringBuffer1
	text " swayed"
	line "and danced around"
	cont "as it pleased."
	done

.StrangeText:
	text_ram wStringBuffer1
	text " swayed"
	line "around, dancing in"
	cont "a strange manner."
	done

UnownRuinsOfAlphInteraction:
	random 5
	ifequal 1, .spin
	opentext
	followcry
	ifequal 2, .growl
	ifequal 3, .still
	ifequal 4, .sing
	writetext .SoundText
	end

.spin
	applymovement FOLLOWER, .SpinMovement
	faceplayer
	opentext
	followcry
	writetext .SpinText
	end

.growl
	writetext .GrowlText
	end

.still
	writetext .StillText
	end

.sing
	writetext .SingText
	end

.SpinMovement:
rept 2
	turn_head DOWN
	step_sleep 4
	turn_head LEFT
	step_sleep 4
	turn_head UP
	step_sleep 4
	turn_head RIGHT
	step_sleep 4
endr
	step_end

.SoundText:
	text "A strange sound is"
	line "coming from"
	cont "@"
	text_ram wStringBuffer1
	text "…"
	done

.SpinText:
	text_ram wStringBuffer1
	text "…"
	line "started spinning"
	cont "around in circles."
	done

.GrowlText:
	text_ram wStringBuffer1
	text " is"
	line "growling in a way"

	para "that sounds like"
	line "speech…"
	done

.StillText:
	text_ram wStringBuffer1
	line "isn't moving."
	done

.SingText:
	text_ram wStringBuffer1
	line "seems to be"
	cont "singing something?"
	done

AzaleaTownInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "hot and cheerful!"
	done

SlowpokeWellInteraction:
	opentext
	followcry
	writetext SeemsVeryHappyText
	end

SlowpokeWellRocketInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " seems"
	line "somehow unhappy."
	done

SlowpokeWellFireMonInteraction:
	opentext
	followcry
	random 2
	iftrue .wet
	writetext .SplashText
	end

.wet
	writetext UnhappyWetText
	end

.SplashText:
	text_ram wStringBuffer1
	line "doesn't like"

	para "splashing around"
	line "on the ground."
	done

WaterMonHappyInteraction:
	opentext
	followcry
	writetext WaterMonHappyText
	end

DancingHappilyInteraction:
	opentext
	followcry
	writetext DancingHappilyText
	end

IlexForestCelebiInteraction:
	opentext
	followcry
	random 2
	iftrue .beautifully
	writetext .HappilyText
	end

.beautifully
	writetext .BeautifullyText
	end

.HappilyText:
	text_ram wStringBuffer1
	text " danced"
	line "happily!"
	done

.BeautifullyText:
	text_ram wStringBuffer1
	text " danced"
	line "beautifully!"
	done

HeracrossInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "clinging to the"
	cont "tree!"
	done

Route36Interaction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "staying completely"
	cont "still…"

	para "It is imitating"
	line "a tree!"
	done

GoldenrodGymInteraction:
	opentext
	followcry
	random 2
	iftrue .waggle
	writetext SeemsVeryHappyText
	end

.waggle
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "waggling a finger"
	cont "and dancing!"
	done

RadioTowerElectricInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " seems"
	line "to be getting an"

	para "electrifying"
	line "feeling!"
	done

RadioTowerGhostInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "feeling alert"

	para "because of"
	line "something…"
	done

NationalParkInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "a little excited."
	done

DanceTheaterPichuInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " danced"
	line "along with the"
	cont "KIMONO GIRLS!"
	done

DanceTheaterBellossomInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " danced"
	line "better than the"
	cont "KIMONO GIRLS!"
	done

LegendaryDogInteraction:
	opentext
	followcry
	random 2
	iftrue .howl
	writetext ShookTheTowerText
	end

.howl
	writetext HowledLoudlyText
	end

ShookTheTowerInteraction:
	opentext
	followcry
	writetext ShookTheTowerText
	end

HowledLoudlyInteraction:
	opentext
	followcry
	writetext HowledLoudlyText
	end

TinTowerInteraction:
	opentext
	followcry
	random 2
	iftrue .sky
	writetext ShookTheTowerText
	end

.sky
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "looking to the sky"
	cont "and shouting!"
	done

Route39TaurosInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	line "suddenly roared!"
	done

Route39MiltankInteraction:
	opentext
	followcry
	random 2
	iftrue .happy
	writetext .Text
	end

.happy
	writetext SeemsVeryHappyText
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "so happy, it"

	para "started rolling"
	line "around."
	done

LighthouseInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	line "sparkled in"

	para "concert with"
	line "AMPHY!"
	done

CianwoodCityInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " moved"
	line "sideways!"
	done

PoliwagInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " swung"
	line "its belly around."
	done

WhirlIslandsLugiaInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " moved"
	line "its long body"

	para "and let out a"
	line "great big roar!"
	done

Route42Interaction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "looking at the"

	para "mountain as if"
	line "anticipating"
	cont "climbing it."
	done

Route15DittoInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text "…Oh? @"
	text_ram wStringBuffer1
	text "'s"
	line "appearance… didn't"
	cont "change!"
	done

Route18FlyingInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "flying through the"
	cont "sky with grace!"
	done

LakeOfRageMagikarpInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "leaping around"
	cont "more than usual!"
	done

TeamRocketBaseInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "trembling!"
	done

ColdIceMonInteraction:
	opentext
	followcry
	random 3
	ifequal 1, .cheering
	ifequal 2, .happy
	writetext ColdIceMonText
	end

.cheering
	writetext .CheeringText
	end

.happy
	writetext SeemsVeryHappyText
	end

.CheeringText:
	text_ram wStringBuffer1
	text " is"
	line "cheering happily"

	para "because of the"
	line "cold!"
	done

ColdGrassMonInteraction:
	opentext
	followcry
	random 2
	iftrue .smaller
	writetext .UnhappyText
	end

.smaller
	writetext .SmallerText
	end

.UnhappyText:
	text_ram wStringBuffer1
	text " seems"
	line "unhappy about the"
	cont "cold…"
	done

.SmallerText:
	text_ram wStringBuffer1
	text " made"
	line "its body slightly"
	cont "smaller because of"
	cont "the cold…"
	done

DragonsDenInteraction:
	opentext
	followcry
	random 4
	ifequal 1, .excited
	ifequal 2, .staring
	ifequal 3, .growling
	writetext .BarkedText
	end

.excited
	writetext .ExcitedText
	end

.staring
	writetext .StaringText
	end

.growling
	writetext .GrowlingText
	end

.BarkedText:
	text_ram wStringBuffer1
	line "suddenly barked!"
	done

.ExcitedText:
	text_ram wStringBuffer1
	line "looks excited!"
	done

.StaringText:
	text_ram wStringBuffer1
	text " is"
	line "staring into"
	cont "your eyes."
	done

.GrowlingText:
	text_ram wStringBuffer1
	text " is"
	line "growling softly."
	done

SilverCaveInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " seems"
	line "tense."

	para "Someone strong"
	line "must be nearby…"
	done

VictoryRoadMeganiumInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " turned"
	line "its head and let"

	para "out a fighting"
	line "yell!"
	done

VictoryRoadTyphlosionInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	line "emitted fire"
	cont "and shouted!"
	done

VictoryRoadFeraligatrInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "swinging its arms"

	para "around and"
	line "shouting!"
	done

Route1Interaction:
	opentext
	followcry
	random 2
	iftrue .snapped
	writetext .WiggledText
	end

.snapped
	writetext .SnappedText
	end

.WiggledText:
	text_ram wStringBuffer1
	line "wiggled its vine!"
	done

.SnappedText:
	text_ram wStringBuffer1
	line "snapped its vine!"
	done

Route2CharmanderInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " flared"
	line "its fiery tail!"
	done

Route3Interaction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " fell"
	line "down and got a"
	cont "little frustrated!"
	done

MtMoonInteraction:
	opentext
	followcry
	random 2
	iftrue .dancing
	writetext .SkyText
	end

.dancing
	writetext .DancingText
	end

.SkyText:
	text_ram wStringBuffer1
	text " is"
	line "looking up at the"
	cont "sky!"
	done

.DancingText:
	text_ram wStringBuffer1
	line "suddenly started"
	cont "dancing!"
	done

PowerPlantPikachuInteraction:
	opentext
	followcry
	random 3
	ifequal 1, .fun
	ifequal 2, .so_happy
	writetext SeemsVeryHappyText
	end

.fun
	writetext .FunText
	end

.so_happy
	writetext .SoHappyText
	end

.FunText:
	text_ram wStringBuffer1
	text " had"
	line "fun dancing a"
	cont "dance!"
	done

.SoHappyText:
	text_ram wStringBuffer1
	text " is"
	line "so happy, it"
	cont "began to dance!"
	done

RockTunnelOnixInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "happily digging"

	para "itself into the"
	line "ground!"
	done

RockTunnelRockMonInteraction:
	opentext
	followcry
	random 4
	ifequal 1, .grinding
	ifequal 2, .hitting
	ifequal 3, .pounding
	writetext .RollingText
	end

.grinding
	writetext .GrindingText
	end

.hitting
	writetext .HittingText
	end

.pounding
	writetext .PoundingText
	end

.RollingText:
	text_ram wStringBuffer1
	text " is"
	line "having fun"
	cont "rolling around!"
	done

.GrindingText:
	text_ram wStringBuffer1
	line "started grinding"
	cont "at the rocks!"
	done

.HittingText:
	text_ram wStringBuffer1
	text " is"
	line "having fun hitting"
	cont "rocks together!"
	done

.PoundingText:
	text_ram wStringBuffer1
	line "started pounding"
	cont "the ground flat!"
	done

DiglettsCaveInteraction:
	opentext
	followcry
	random 2
	iftrue .relaxing
	writetext SeemsVeryHappyText
	end

.relaxing
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	line "stretched out its"

	para "body and is"
	line "relaxing!"
	done

MrPsychicsHouseInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text "…… …… …… ……"
	line "…… …… …… ……"

	para "@"
	text_ram wStringBuffer1
	line "silently nodded!"
	done

CeladonCityPorygonInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	line "stammered"
	cont "something…"
	done

LavenderTownInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "having fun"

	para "swaying back"
	line "and forth."
	done

ShamoutiLegendInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "staring out to"
	cont "sea…"
	done

SeaBreezeInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "enjoying the sea"
	cont "breeze!"
	done

SnowFireMonInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "melting the snow"
	cont "around it!"
	done

SnowInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "catching snow-"
	cont "flakes!"
	done

RainFireMonInteraction:
	opentext
	followcry
	writetext UnhappyWetText
	end

ThunderElectricMonInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "crackling with"
	cont "energy!"
	done

SunGrassMonInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "basking in the"
	cont "sunlight!"
	done

SandstormSafeInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	line "doesn't mind the"
	cont "sandstorm at all!"
	done

SandstormInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "squinting through"
	cont "the sand…"
	done

CherryBlossomInteraction:
	opentext
	followcry
	writetext .Text
	end

.Text:
	text_ram wStringBuffer1
	text " is"
	line "watching the"
	cont "petals fall."
	done

GetFirstAliveMon::
; Return the species of the first party mon that has HP and isn't an egg
; in a with nz, and its party index in e. Return z and a = 0 if none.
	ld hl, wPartySpecies
	ld bc, wPartyMon1HP
	ld e, 0
.loop
	ld a, [hli]
	cp -1
	jr z, .none
	ld d, a
	cp EGG
	jr z, .next
	ld a, [bc]
	inc bc
	push hl
	ld h, a
	ld a, [bc]
	or h
	pop hl
	dec bc
	jr z, .next
	ld a, d
	and a
	ret

.next
	inc e
	push hl
	ld hl, PARTYMON_STRUCT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	pop hl
	jr .loop

.none
	xor a
	ret

GetFollowerSpriteData::
; GetSprite for SPRITE_FOLLOWER: return the lead mon's walking sprite
; at b:de, its length in c, and WALKING_SPRITE in l, with carry.
	call GetFirstAliveMon
	ld [wFollowerSpriteID], a
	ld a, e
	ld [wFollowerPartyNum], a
	ld a, [wFollowerSpriteID]
	ld bc, 0
	and a
	jr z, .got_index
	call GetPokemonIndexFromID
	dec hl
	ld a, l
	sub LOW(NUM_POKEMON_AND_VARIANTS)
	ld a, h
	sbc HIGH(NUM_POKEMON_AND_VARIANTS)
	jr nc, .got_index
	ld b, h
	ld c, l
.got_index
	ld hl, FollowingSpritePointers
	add hl, bc
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld e, a
	ld d, [hl]
	ld c, 12
	ld h, b
	ld l, WALKING_SPRITE
	scf
	ret

GetFollowerPalette::
; Return the lead mon's overworld palette in c, shiny included.
	call GetFirstAliveMon
	ld c, PAL_OW_RED
	ret z
	call GetPokemonIndexFromID
	dec hl
	add hl, hl
	ld bc, FollowerPals
	add hl, bc
	push hl
	ld a, e
	ld hl, wPartyMon1DVs
	ld bc, PARTYMON_STRUCT_LENGTH
	rst AddNTimes
	ld b, h
	ld c, l
	farcall CheckShininess
	pop hl
	jr nc, .got_pal
	inc hl
.got_pal
	ld c, [hl]
	ret

INCLUDE "data/pokemon/follower_pals.asm"

RefreshFollowerPalette::
; The lead mon can change in a menu; give the follower its new colours.
	ld a, [wObject1Sprite]
	cp SPRITE_FOLLOWER
	ret nz
	call GetFollowerPalette
	ld hl, wObject1PalIndex
	ld a, [hl]
	cp c
	ret z
	ld [hl], c
	farjp CheckForUsedObjPals

INCLUDE "gfx/following_sprite_pointers.asm"

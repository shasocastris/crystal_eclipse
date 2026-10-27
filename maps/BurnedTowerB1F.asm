	object_const_def
	const BURNEDTOWERB1F_BOULDER
	const BURNEDTOWERB1F_RAIKOU1
	const BURNEDTOWERB1F_ENTEI1
	const BURNEDTOWERB1F_SUICUNE1
	const BURNEDTOWERB1F_RAIKOU2
	const BURNEDTOWERB1F_ENTEI2
	const BURNEDTOWERB1F_SUICUNE2
	const BURNEDTOWERB1F_POKE_BALL
	const BURNEDTOWERB1F_KAREN
	const BURNEDTOWERB1F_RAIKOU

BurnedTowerB1F_MapScripts:
	def_scene_scripts
	scene_script BurnedTowerB1FNoop1Scene, SCENE_BURNEDTOWERB1F_RELEASE_THE_BEASTS
	scene_script BurnedTowerB1FNoop2Scene, SCENE_BURNEDTOWERB1F_NOOP

	def_callbacks
	callback MAPCALLBACK_TILES, BurnedTowerB1FLadderCallback
	callback MAPCALLBACK_OBJECTS, BurnedTowerB1FRaikouCallback

BurnedTowerB1FNoop1Scene:
	end

BurnedTowerB1FNoop2Scene:
	end

BurnedTowerB1FLadderCallback:
	checkevent EVENT_RELEASED_THE_BEASTS
	iftrue .HideLadder
	changeblock 6, 14, $02 ; floor
.HideLadder:
	endcallback

BurnedTowerB1FRaikouCallback:
	checkevent EVENT_FOUGHT_RAIKOU
	iftrue .NoAppear
	checkevent EVENT_BEAT_ELITE_FOUR
	iftrue .Appear
.NoAppear:
	disappear BURNEDTOWERB1F_RAIKOU
	endcallback

.Appear:
	appear BURNEDTOWERB1F_RAIKOU
	endcallback

BurnedTowerB1FRaikou:
	faceplayer
	opentext
	writetext BurnedTowerB1FRaikouText
	cry RAIKOU
	pause 15
	closetext
	loadmonindex 0, RAIKOU
	callstd DeityTutorScript
	iftrue .Stay
	setevent EVENT_FOUGHT_RAIKOU
	disappear BURNEDTOWERB1F_RAIKOU
.Stay:
	end

BurnedTowerB1FRaikouText:
	text "Gyaroooh!"
	done

ReleaseTheBeasts:
	playmusic MUSIC_NONE
	pause 30
	appear BURNEDTOWERB1F_RAIKOU1
	turnobject PLAYER, UP
	pause 5
	disappear BURNEDTOWERB1F_RAIKOU2
	pause 15
	cry RAIKOU
	appear BURNEDTOWERB1F_ENTEI1
	turnobject PLAYER, UP
	pause 5
	disappear BURNEDTOWERB1F_ENTEI2
	pause 15
	cry ENTEI
	appear BURNEDTOWERB1F_SUICUNE1
	turnobject PLAYER, UP
	pause 5
	disappear BURNEDTOWERB1F_SUICUNE2
	pause 15
	cry SUICUNE
	pause 15
	playsound SFX_WARP_FROM
	turnobject PLAYER, LEFT
	applymovement BURNEDTOWERB1F_RAIKOU1, BurnedTowerRaikouMovement
	disappear BURNEDTOWERB1F_RAIKOU1
	waitsfx
	playsound SFX_WARP_FROM
	turnobject PLAYER, RIGHT
	applymovement BURNEDTOWERB1F_ENTEI1, BurnedTowerEnteiMovement
	disappear BURNEDTOWERB1F_ENTEI1
	waitsfx
	pause 15
	playsound SFX_WARP_FROM
	turnobject PLAYER, UP
	applymovement BURNEDTOWERB1F_SUICUNE1, BurnedTowerSuicuneMovement1
	playsound SFX_WARP_FROM
	turnobject PLAYER, DOWN
	applymovement BURNEDTOWERB1F_SUICUNE1, BurnedTowerSuicuneMovement2
	turnobject PLAYER, UP
	pause 20
	cry SUICUNE
	pause 30
	playsound SFX_WARP_FROM
	applymovement BURNEDTOWERB1F_SUICUNE1, BurnedTowerSuicuneMovement3
	turnobject PLAYER, DOWN
	disappear BURNEDTOWERB1F_SUICUNE1
	waitsfx
	special RestartMapMusic
	setscene SCENE_BURNEDTOWERB1F_NOOP
	setevent EVENT_RELEASED_THE_BEASTS
	setmapscene ECRUTEAK_GYM, SCENE_ECRUTEAKGYM_NOOP
	setmapscene CIANWOOD_CITY, SCENE_CIANWOODCITY_SUICUNE_AND_KAREN
	clearevent EVENT_SAW_SUICUNE_AT_CIANWOOD_CITY
	setevent EVENT_ECRUTEAK_GYM_GRAMPS
	clearevent EVENT_ECRUTEAK_CITY_GRAMPS
	setevent EVENT_BURNED_TOWER_MORTY
	setevent EVENT_BURNED_TOWER_1F_KAREN
	appear BURNEDTOWERB1F_KAREN
	reanchormap
	changeblock 6, 14, $1b ; ladder
	refreshmap
	closetext
	setscene SCENE_BURNEDTOWERB1F_NOOP
	end

BurnedTowerB1FKaren:
	faceplayer
	opentext
	writetext BurnedTowerB1FKarenText
	waitbutton
	closetext
	readvar VAR_FACING
	ifequal UP, .Movement2
	applymovement BURNEDTOWERB1F_KAREN, BurnedTowerB1FKarenMovement1
	sjump .Finish

.Movement2:
	applymovement BURNEDTOWERB1F_KAREN, BurnedTowerB1FKarenMovement2
.Finish:
	disappear BURNEDTOWERB1F_KAREN
	playsound SFX_EXIT_BUILDING
	waitsfx
	end

BurnedTowerB1FTMEndure:
	itemball TM_ENDURE

BurnedTowerB1FBoulder:
	jumpstd StrengthBoulderScript

BurnedTowerRaikouMovement:
	set_sliding
	fast_jump_step DOWN
	fast_jump_step LEFT
	remove_sliding
	step_end

BurnedTowerEnteiMovement:
	set_sliding
	fast_jump_step RIGHT
	fast_jump_step DOWN
	fast_jump_step RIGHT
	remove_sliding
	step_end

BurnedTowerSuicuneMovement1:
	set_sliding
	fast_jump_step RIGHT
	fast_jump_step DOWN
	fast_jump_step DOWN
	fast_jump_step LEFT
	remove_sliding
	step_end

BurnedTowerSuicuneMovement2:
	set_sliding
	fast_jump_step LEFT
	fast_jump_step UP
	big_step UP
	fast_jump_step RIGHT
	remove_sliding
	step_end

BurnedTowerSuicuneMovement3:
	set_sliding
	big_step UP
	fast_jump_step RIGHT
	fast_jump_step DOWN
	fast_jump_step DOWN
	fast_jump_step DOWN
	fast_jump_step DOWN
	remove_sliding
	step_end

BurnedTowerB1FKarenMovement2:
	step LEFT
	step LEFT
	step DOWN
	step DOWN
	step LEFT
	step DOWN
	step_end

BurnedTowerB1FKarenMovement1:
	step DOWN
	step LEFT
	step LEFT
	step LEFT
	step DOWN
	step DOWN
	step_end

BurnedTowerB1FKarenText:
	text "I've finished my"
	line "investigation."

	para "The ruins are"
	line "undisturbed, and"

	para "the legendary"
	line "#MON don't have"
	cont "to do with what-"
	cont "ever caused the"
	cont "TAUROS to rampage."

	para "The answer must"
	line "lie elsewhere…"

	para "Perhaps some other"
	line "foul play?"

	para "<PLAYER>, if you"
	line "head that way, be"
	cont "extremely careful."

	para "I need to report"
	line "my findings to the"
	cont "LEAGUE."

	para "Stay safe out"
	line "there!"
	done

BurnedTowerB1F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 10,  8, BURNED_TOWER_1F, 3
	warp_event  7, 15, BURNED_TOWER_1F, 4

	def_coord_events
	coord_event 10,  6, SCENE_BURNEDTOWERB1F_RELEASE_THE_BEASTS, ReleaseTheBeasts

	def_bg_events

	def_object_events
	object_event 17,  8, SPRITE_BOULDER, SPRITEMOVEDATA_STRENGTH_BOULDER, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, BurnedTowerB1FBoulder, -1
	object_event  7,  3, SPRITE_RAIKOU, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_BURNED_TOWER_B1F_BEASTS_1
	object_event 12,  3, SPRITE_ENTEI, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_BURNED_TOWER_B1F_BEASTS_1
	object_event 10,  4, SPRITE_SUICUNE, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_BURNED_TOWER_B1F_BEASTS_1
	object_event  7,  3, SPRITE_RAIKOU, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_SILVER, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_BURNED_TOWER_B1F_BEASTS_2
	object_event 12,  3, SPRITE_ENTEI, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_SILVER, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_BURNED_TOWER_B1F_BEASTS_2
	object_event 10,  4, SPRITE_SUICUNE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_SILVER, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_BURNED_TOWER_B1F_BEASTS_2
	object_event 16,  4, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, BurnedTowerB1FTMEndure, EVENT_BURNED_TOWER_B1F_TM_ENDURE
	object_event 10, 12, SPRITE_KAREN, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, BurnedTowerB1FKaren, EVENT_KAREN_IN_BURNED_TOWER
	object_event  7,  3, SPRITE_RAIKOU_MON, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_SCRIPT, 0, BurnedTowerB1FRaikou, EVENT_BURNED_TOWER_B1F_RAIKOU

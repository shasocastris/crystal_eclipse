	object_const_def
	const ROUTE6_POKEFAN_M1
	const ROUTE6_POKEFAN_M2
	const ROUTE6_POKEFAN_M3a

Route6_MapScripts:
	def_scene_scripts

	def_callbacks

Route6PokefanMScript:
	faceplayer
	opentext
	checkevent EVENT_BEAT_ROCKET_GRUNTM_31
	iffalse .RoadClosed
	writetext Route6RocketSeenText
	waitbutton
	closetext
	winlosstext Route6RocketBeaten_Text, 0
	loadtrainer GRUNTM, GRUNTM_3
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_ROCKET_GRUNTM_3
	opentext
	writetext Route6RocketLeaves_Text
	waitbutton
	closetext
	applymovement ROUTE6_POKEFAN_M1, Route6PokefanMovement
	playsound SFX_ENTER_DOOR
	disappear ROUTE6_POKEFAN_M1
	waitsfx
	end

.RoadClosed
	writetext Route6PokefanMText
	waitbutton
	closetext
	end

Route6PokefanMovement:
	step UP
	step_end

Route6RocketSeenText:
	text "Someone told you"
	line "about the secret"
	cont "underground path?"

	para "That idiot …"

	para "I suppose I'll"
	line "have to deal with"
	cont "you."
	done

Route6RocketBeaten_Text:
	text "What? I lost to"
	line "some brat?"
	done

Route6RocketLeaves_Text:
	text "I need to warn the"
	line "bosses. There's no"
	cont "way you will beat"
	cont "our entire crew."
	done

Route6PokefanMText:
	text "The road is closed"
	line "until the problem"

	para "at the POWER PLANT"
	line "is solved."
	done

TrainerPokefanmRex:
	trainer POKEFANM, REX, EVENT_BEAT_POKEFANM_REX, PokefanmRexSeenText, PokefanmRexBeatenText, 0, .Script

.Script:
	opentext
	writetext PokefanmRexAfterBattleText
	waitbutton
	closetext
	end

PokefanmRexSeenText:
	text "My PHANPY is the"
	line "cutest in the"
	cont "world."
	done

PokefanmRexBeatenText:
	text "My PHANPY!"
	done

PokefanmRexAfterBattleText:
	text "Look how adorable"
	line "my PHANPY acts!"

	para "Isn't it cute"
	line "enough to make"
	cont "your heart melt?"
	done

TrainerPokefanmAllan:
	trainer POKEFANM, ALLAN, EVENT_BEAT_POKEFANM_ALLAN, PokefanmAllanSeenText, PokefanmAllanBeatenText, 0, .Script

.Script:
	opentext
	writetext PokefanmAllanAfterBattleText
	waitbutton
	closetext
	end

PokefanmAllanSeenText:
	text "My TEDDIURSA is"
	line "the cutest in the"
	cont "world."
	done

PokefanmAllanBeatenText:
	text "My TEDDIURSA!"
	done

PokefanmAllanAfterBattleText:
	text "Look how adorable"
	line "my TEDDIURSA acts!"

	para "Isn't it cute"
	line "enough to make"
	cont "your heart melt?"
	done

Route6UndergroundPathSign:
	jumptext Route6UndergroundPathSignText

Route6UndergroundPathSignText:
	text "UNDERGROUND PATH"

	para "CERULEAN CITY -"
	line "VERMILION CITY"
	done

Route6_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 17,  3, ROUTE_6_UNDERGROUND_PATH_ENTRANCE, 1
	warp_event  6,  1, ROUTE_6_SAFFRON_GATE, 3

	def_coord_events

	def_bg_events
	bg_event 19,  5, BGEVENT_READ, Route6UndergroundPathSign

	def_object_events
	object_event 17,  4, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_SCRIPT, 2, Route6PokefanMScript, EVENT_BEAT_ROCKET_GRUNTM_3
	object_event  9, 12, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 0, TrainerPokefanmRex, -1
	object_event 10, 12, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 0, TrainerPokefanmAllan, -1

	object_const_def
	const ROUTE7_POKEFAN_M

Route7_MapScripts:
	def_scene_scripts

	def_callbacks

Route7PokefanMScript:
	faceplayer
	opentext
	checkevent EVENT_BEAT_ROCKET_GRUNTM_31
	iffalse .RoadClosed
	writetext Route7RocketSeenText
	waitbutton
	closetext
	winlosstext Route7RocketBeaten_Text, 0
	loadtrainer GRUNTM, GRUNTM_3
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_ROCKET_GRUNTM_3
	opentext
	writetext Route7RocketLeaves_Text
	waitbutton
	closetext
	applymovement ROUTE7_POKEFAN_M, Route7PokefanMovement
	playsound SFX_ENTER_DOOR
	disappear ROUTE7_POKEFAN_M
	waitsfx
	end

.RoadClosed
	writetext Route7PokefanMText
	waitbutton
	closetext
	end

Route7PokefanMovement:
	step UP
	step_end

Route7RocketSeenText:
	text "Someone told you"
	line "about the secret"
	cont "underground path?"

	para "That idiot …"

	para "I suppose I'll"
	line "have to deal with"
	cont "you."
	done

Route7RocketBeaten_Text:
	text "What? I lost to"
	line "some brat?"
	done

Route7RocketLeaves_Text:
	text "I need to warn the"
	line "bosses. There's no"
	cont "way you will beat"
	cont "our entire crew."
	done

Route7PokefanMText:
	text "The road is closed"
	line "until the problem"

	para "at the POWER PLANT"
	line "is solved."
	done

Route7UndergroundPathSign:
	jumptext Route7UndergroundPathSignText

Route7UndergroundPathSignText:
	text "What's this flyer?"

	para "… Uncouth trainers"
	line "have been holding"

	para "battles in the"
	line "UNDERGROUND PATH."

	para "Because of rising"
	line "complaints by lo-"
	cont "cal residents, the"
	cont "UNDERGROUND PATH"
	cont "has been sealed"
	cont "indefinitely."

	para "CELADON POLICE"
	done

Route7_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 15,  6, ROUTE_7_SAFFRON_GATE, 1
	warp_event 15,  7, ROUTE_7_SAFFRON_GATE, 2
	warp_event  6,  9, ROUTE_7_UNDERGROUND_PATH_ENTRANCE, 1

	def_coord_events

	def_bg_events
	bg_event  5, 11, BGEVENT_READ, Route7UndergroundPathSign

	def_object_events
	object_event  6, 10, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, Route7PokefanMScript, EVENT_BEAT_ROCKET_GRUNTM_3

	object_const_def
	const ROUTE39BARN_WHITNEY
	const ROUTE39BARN_MOOMOO

Route39Barn_MapScripts:
	def_scene_scripts

	def_callbacks

Route39WhitneyScript:
	faceplayer
	opentext
	checkevent EVENT_HEALED_MOOMOO
	iftrue .FeedingMooMoo
	writetext Route39BarnWhitneyMoomooIsSickText
	waitbutton
	closetext
	turnobject ROUTE39BARN_WHITNEY, UP
	end

.FeedingMooMoo:
	writetext Route39BarnWhitneyImFeedingMoomooText
	waitbutton
	closetext
	turnobject ROUTE39BARN_WHITNEY, UP
	end

MoomooScript:
	opentext
	checkevent EVENT_HEALED_MOOMOO
	iftrue .HappyCow
	writetext MoomooWeakMooText
	loadmonindex 1, MILTANK
	special PlaySlowCry
	promptbutton
	writetext Route39BarnItsCryIsWeakText
	promptbutton
	writetext Route39BarnAskGiveBerryText
	yesorno
	iffalse .Refused
	checkitem GOLD_BERRY
	iffalse .NoBerriesInBag
	playmusic MUSIC_HEAL
	writetext Route39BarnGaveBerryText
	pause 60
	promptbutton
	special RestartMapMusic
	writetext Route39BarnTotallyHealthyText
	waitbutton
	closetext
	setevent EVENT_HEALED_MOOMOO
	clearevent EVENT_QUELLED_WILD_HUNT
	setevent EVENT_ECRUTEAK_WILD_HUNT
	clearflag ENGINE_WILD_HUNT
	showemote EMOTE_SHOCK, ROUTE39BARN_WHITNEY, 30
	applymovement ROUTE39BARN_WHITNEY, Route39BarnWhitneyMovement
	turnobject ROUTE39BARN_WHITNEY, UP
	turnobject PLAYER, DOWN
	opentext
	writetext Route39BarnWhitneyCongratulationsText
	waitbutton
	closetext
	turnobject ROUTE39BARN_WHITNEY, DOWN
	applymovement ROUTE39BARN_WHITNEY, Route39BarnWhitneyLeaveMovement
	playsound SFX_EXIT_BUILDING
	disappear ROUTE39BARN_WHITNEY
	waitsfx
	end

.NoBerriesInBag:
	writetext Route39BarnNoBerriesText
	waitbutton
	closetext
	end

.Refused:
	writetext Route39BarnRefusedBerryText
	waitbutton
	closetext
	end

.HappyCow:
	writetext MoomooHappyMooText
	cry MILTANK
	waitbutton
	closetext
	end

Route39BarnWhitneyMovement:
	step RIGHT
	step_end

Route39BarnWhitneyLeaveMovement:
	step DOWN
	step DOWN
	step DOWN
	step_end

Route39BarnWhitneyMoomooIsSickText:
	text "MOOMOO is sick…"

	para "She needs a GOLD"
	line "BERRY or a"
	cont "MIRACLEBERRY."

	para "Then we can quell"
	line "the WILD HUNT."
	done

Route39BarnWhitneyImFeedingMoomooText:
	text "I'm feeding"
	line "MOOMOO!"
	done

MoomooWeakMooText:
	text "MILTANK: …Moo…"
	done

Route39BarnItsCryIsWeakText:
	text "Its cry is weak…"
	done

MoomooHappyMooText:
	text "MILTANK: Mooo!"
	done

Route39BarnAskGiveBerryText:
	text "Give a GOLD BERRY"
	line "to MILTANK?"
	done

Route39BarnGaveBerryText:
	text "<PLAYER> gave a"
	line "GOLD BERRY to"
	cont "MILTANK."
	done

Route39BarnTotallyHealthyText:
	text "MILTANK'S health"
	line "has been restored!"

	para "The sounds of the"
	line "WILD HUNT have"
	cont "begun to die down."
	done

Route39BarnNoBerriesText:
	text "<PLAYER> has no"
	line "GOLD BERRIES…"

	para "There is a tree"
	line "with GOLD BERRIES"
	cont "on ROUTE 38."
	done

Route39BarnRefusedBerryText:
	text "<PLAYER> wouldn't"
	line "give a GOLD BERRY."

	para "The TAUROS outside"
	line "are still charging"
	cont "toward ECRUTEAK."
	done

Route39BarnWhitneyCongratulationsText:
	text "WHITNEY: Oh, thank"
	line "goodness!"

	para "MOOMOO is better,"
	line "and the TAUROS"
	cont "stopped rampaging!"

	para "You saved the farm"
	line "AND ECRUTEAK CITY!"

	para "I was so worried"
	line "about my family's"
	cont "farm…"

	para "I need to tell"
	line "MORTY right away!"

	para "He'll be so happy"
	line "to hear ECRUTEAK"
	cont "is safe now!"

	para "<PLAY_G>, you're"
	line "amazing! Thank you"
	cont "so much!"
	done

Route39Barn_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  3,  7, ROUTE_39, 1
	warp_event  4,  7, ROUTE_39, 1

	def_coord_events

	def_bg_events

	def_object_events
	object_event  3,  4, SPRITE_WHITNEY, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Route39WhitneyScript, EVENT_HEALED_MOOMOO
	object_event  3,  3, SPRITE_MILTANK, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, MoomooScript, -1

	object_const_def
	const RUINSOFALPHOUTSIDE_ROCKET_M12
	const RUINSOFALPHOUTSIDE_ROCKET_F6
	const RUINSOFALPHOUTSIDE_SCIENTIST_ERWIN

RuinsOfAlphKabutoChamber_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_TILES, RuinsOfAlphKabutoChamberOpenHoleCallback

RuinsOfAlphKabutoChamberOpenHoleCallback:
	checkevent EVENT_SOLVED_KABUTO_PUZZLE
	iffalse .FloorClosed
	endcallback
.FloorClosed:
	changeblock 2, 2, $01 ; left floor
	changeblock 4, 2, $02 ; right floor
	changeblock 2, 8, $15 ; left entrance
	changeblock 4, 8, $16 ; right entrance
	endcallback

RuinsOfAlphKabutoChamberPuzzle:
	reanchormap
	setval UNOWNPUZZLE_KABUTO
	special UnownPuzzle
	closetext
	iftrue .PuzzleComplete
	end

.PuzzleComplete:
	setevent EVENT_RUINS_OF_ALPH_INNER_CHAMBER_TOURISTS
	setevent EVENT_SOLVED_KABUTO_PUZZLE
	setflag ENGINE_UNLOCKED_UNOWNS_A_TO_K
	setevent EVENT_RUINS_OF_ALPH_KABUTO_CHAMBER_RECEPTIONIST
	setmapscene RUINS_OF_ALPH_INNER_CHAMBER, SCENE_RUINSOFALPHINNERCHAMBER_STRANGE_PRESENCE
	earthquake 30
	showemote EMOTE_SHOCK, PLAYER, 15
	changeblock 2, 2, $18 ; left hole
	changeblock 4, 2, $19 ; right hole
	refreshmap
	playsound SFX_STRENGTH
	earthquake 80
	applymovement PLAYER, RuinsOfAlphKabutoChamberSkyfallTopMovement
	playsound SFX_KINESIS
	waitsfx
	pause 20
	warpcheck
	end

TrainerGruntM12:
	trainer GRUNTM, GRUNTM_12, EVENT_BEAT_ROCKET_GRUNTM_12, GruntM12SeenText, GruntM12BeatenText, 0, .Script

.Script:
	opentext
	writetext GruntM12AfterBattleText
	waitbutton
	closetext
	end

TrainerGruntF6:
		trainer GRUNTF, GRUNTF_6, EVENT_BEAT_ROCKET_GRUNTF_6, GruntF6SeenText, GruntF6BeatenText, 0, .Script

.Script:
	opentext
	writetext GruntF6AfterBattleText
	waitbutton
	closetext
	end

TrainerScientistErwin:
	trainer SCIENTIST, ERWIN, EVENT_BEAT_SCIENTIST_ERWIN, ScientistErwinSeenText, ScientistErwinBeatenText, 0, .Script

.Script:
	opentext
	writetext ScientistErwinAfterBattleText
	waitbutton
	closetext
	end

RuinsOfAlphKabutoChamberAncientReplica:
	jumptext RuinsOfAlphKabutoChamberAncientReplicaText

RuinsOfAlphKabutoChamberDescriptionSign:
	jumptext RuinsOfAlphKabutoChamberDescriptionText

RuinsOfAlphKabutoChamberSkyfallTopMovement:
	skyfall_top
	step_end

GruntM12SeenText:
	text "These ruins are"
	line "TEAM ROCKET's now!"

	para "After getting run"
	line "out from SLOWPOKE"
	cont "WELL and the LAKE"
	cont "OF RAGE,"

	para "we're not losing"
	line "here!"
	done

GruntM12BeatenText:
	text "Ugh! You're too"
	line "strong!"
	done

GruntM12AfterBattleText:
	text "The BOSS says once"
	line "we control these"
	cont "ruins, no one can"
	cont "stop us!"

	para "Not the LEAGUE."
	line "Not the RANGERS."
	cont "No one!"
	done

GruntF6SeenText:
	text "You think you can"
	line "just waltz in?"

	para "You already ruined"
	line "our plans twice!"
	done

GruntF6BeatenText:
	text "No way!"
	line "I lost?!"
	done

GruntF6AfterBattleText:
	text "The scientists are"
	line "babbling about"
	cont "symbols and forms."

	para "I don't care about"
	line "that. I just want"
	cont "to see TEAM ROCKET"
	cont "dominate JOHTO!"
	done

ScientistErwinSeenText:
	text "You! You're the"
	line "one who disrupted"
	cont "our radio wave"
	cont "experiment!"

	para "Let's test your"
	line "#MON's limits!"
	done

ScientistErwinBeatenText:
	text "Fascinating data!"
	done

ScientistErwinAfterBattleText:
	text "My hypothesis: the"
	line "symbols in each"
	cont "chamber represent"
	cont "different #MON."

	para "There are 26 in"
	line "total."

	para "We solved this" ; CHANGED: the shrine opens on the fifth puzzle
	line "chamber long ago."

	para "The real prize is"
	line "the fifth puzzle."

	para "Solve that, and"
	line "the shrine opens!"
	done


RuinsOfAlphKabutoChamberAncientReplicaText:
	text "It's a replica of"
	line "an ancient #-"
	cont "MON."
	done

RuinsOfAlphKabutoChamberDescriptionText:
	text "A #MON that hid"
	line "on the sea floor."

	para "Eyes on its back"
	line "scanned the area."
	done

RuinsOfAlphKabutoChamber_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  3,  9, RUINS_OF_ALPH_OUTSIDE, 2
	warp_event  4,  9, RUINS_OF_ALPH_OUTSIDE, 2
	warp_event  3,  3, RUINS_OF_ALPH_KABUTO_ITEM_ROOM, 1
	warp_event  4,  3, RUINS_OF_ALPH_KABUTO_ITEM_ROOM, 2

	def_coord_events

	def_bg_events
	bg_event  2,  3, BGEVENT_READ, RuinsOfAlphKabutoChamberAncientReplica
	bg_event  5,  3, BGEVENT_READ, RuinsOfAlphKabutoChamberAncientReplica
	bg_event  3,  2, BGEVENT_UP, RuinsOfAlphKabutoChamberPuzzle
	bg_event  4,  2, BGEVENT_UP, RuinsOfAlphKabutoChamberDescriptionSign

	def_object_events
	object_event  1,  8, SPRITE_ROCKET, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 3, TrainerGruntM12, EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS
	object_event  6,  8, SPRITE_ROCKET_GIRL, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 3, TrainerGruntF6, EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS
	object_event  5,  4, SPRITE_SCIENTIST, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 2, TrainerScientistErwin, EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS

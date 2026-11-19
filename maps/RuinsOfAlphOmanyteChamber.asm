	object_const_def
	const RUINSOFALPHOUTSIDE_ROCKET_F7
	const RUINSOFALPHOUTSIDE_ROCKET_F8
	const RUINSOFALPHOUTSIDE_SCIENTIST_JAYJAY

RuinsOfAlphOmanyteChamber_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_TILES, RuinsOfAlphOmanyteChamberOpenHoleCallback

RuinsOfAlphOmanyteChamberOpenHoleCallback:
	checkevent EVENT_SOLVED_OMANYTE_PUZZLE
	iffalse .FloorClosed
	endcallback
.FloorClosed:
	changeblock 2, 2, $01 ; left floor
	changeblock 4, 2, $02 ; right floor
	changeblock 2, 8, $15 ; left entrance
	changeblock 4, 8, $16 ; right entrance
	endcallback

RuinsOfAlphOmanyteChamberPuzzle:
	reanchormap
	setval UNOWNPUZZLE_OMANYTE
	special UnownPuzzle
	closetext
	iftrue .PuzzleComplete
	end

.PuzzleComplete:
	setevent EVENT_RUINS_OF_ALPH_INNER_CHAMBER_TOURISTS
	setevent EVENT_SOLVED_OMANYTE_PUZZLE
	setflag ENGINE_UNLOCKED_UNOWNS_L_TO_R
	setmapscene RUINS_OF_ALPH_INNER_CHAMBER, SCENE_RUINSOFALPHINNERCHAMBER_STRANGE_PRESENCE
	earthquake 30
	showemote EMOTE_SHOCK, PLAYER, 15
	changeblock 2, 2, $18 ; left hole
	changeblock 4, 2, $19 ; right hole
	refreshmap
	playsound SFX_STRENGTH
	earthquake 80
	applymovement PLAYER, RuinsOfAlphOmanyteChamberSkyfallTopMovement
	playsound SFX_KINESIS
	waitsfx
	pause 20
	warpcheck
	end

TrainerGruntF7:
	trainer GRUNTF, GRUNTF_7, EVENT_BEAT_ROCKET_GRUNTF_7, GruntF7SeenText, GruntF7BeatenText, 0, .Script

.Script:
	opentext
	writetext GruntF7AfterBattleText
	waitbutton
	closetext
	end

TrainerGruntF8:
	trainer GRUNTF, GRUNTF_8, EVENT_BEAT_ROCKET_GRUNTF_8, GruntF8SeenText, GruntF8BeatenText, 0, .Script

.Script:
	opentext
	writetext GruntF8AfterBattleText
	waitbutton
	closetext
	end

TrainerScientistJayJay:
	trainer SCIENTIST, JAYJAY, EVENT_BEAT_SCIENTIST_JAYJAY, ScientistJayJaySeenText, ScientistJayJayBeatenText, 0, .Script

.Script:
	opentext
	writetext ScientistJayJayAfterBattleText
	waitbutton
	closetext
	end

RuinsOfAlphOmanyteChamberAncientReplica:
	jumptext RuinsOfAlphOmanyteChamberAncientReplicaText

RuinsOfAlphOmanyteChamberDescriptionSign:
	jumptext RuinsOfAlphOmanyteChamberDescriptionText

RuinsOfAlphOmanyteChamberSkyfallTopMovement:
	skyfall_top
	step_end

GruntF7SeenText:
	text "This place gives"
	line "me the creeps…"

	para "But after causing"
	line "that WILD HUNT,"
	cont "we need a win!"
	done

GruntF7BeatenText:
	text "Finally! Now I"
	line "can leave!"
	done

GruntF7AfterBattleText:
	text "The executives say"
	line "these ruins will"
	cont "give us power over"
	cont "all of JOHTO."

	para "After that loss at"
	line "MAHOGANY TOWN, we"
	cont "need that kind of"
	cont "leverage!"
	done

GruntF8SeenText:
	text "Keep moving, kid!"

	para "We already solved" ; CHANGED: was still working on it
	line "this one. Nothing"
	cont "left for you!"
	done

GruntF8BeatenText:
	text "Argh! Useless!"
	done

GruntF8AfterBattleText:
	text "The BOSS is tired"
	line "of setbacks."

	para "He wants total"
	line "control of JOHTO."

	para "Whatever power is"
	line "hidden here, we're"
	cont "taking it!"
	done

ScientistJayJaySeenText:
	text "Excellent! Fresh"
	line "data for my"
	cont "research!"

	para "Don't worry, this"
	line "won't hurt… much!"
	done

ScientistJayJayBeatenText:
	text "Intriguing! Most"
	line "intriguing!"
	done

ScientistJayJayAfterBattleText:
	text "The wall patterns"
	line "correspond to 26"
	cont "distinct shapes."

	para "Each puzzle seems"
	line "to focus on new"
	cont "variants."

	para "Are they some sort"
	line "of primordial"
	cont "language?"
	done

RuinsOfAlphOmanyteChamberAncientReplicaText:
	text "It's a replica of"
	line "an ancient #-"
	cont "MON."
	done

RuinsOfAlphOmanyteChamberDescriptionText:
	text "This #MON"
	line "drifted in the"

	para "sea by twisting"
	line "its ten tentacles."
	done

RuinsOfAlphOmanyteChamber_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  3,  9, RUINS_OF_ALPH_OUTSIDE, 3
	warp_event  4,  9, RUINS_OF_ALPH_OUTSIDE, 3
	warp_event  3,  3, RUINS_OF_ALPH_OMANYTE_ITEM_ROOM, 1
	warp_event  4,  3, RUINS_OF_ALPH_OMANYTE_ITEM_ROOM, 2

	def_coord_events

	def_bg_events
	bg_event  2,  3, BGEVENT_READ, RuinsOfAlphOmanyteChamberAncientReplica
	bg_event  5,  3, BGEVENT_READ, RuinsOfAlphOmanyteChamberAncientReplica
	bg_event  3,  2, BGEVENT_UP, RuinsOfAlphOmanyteChamberPuzzle
	bg_event  4,  2, BGEVENT_UP, RuinsOfAlphOmanyteChamberDescriptionSign

	def_object_events
	object_event  2,  8, SPRITE_ROCKET_GIRL, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 2, TrainerGruntF7, EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS
	object_event  6,  7, SPRITE_ROCKET_GIRL, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 3, TrainerGruntF8, EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS
	object_event  3,  4, SPRITE_SCIENTIST, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 1, TrainerScientistJayJay, EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS

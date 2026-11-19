	object_const_def
	const RUINSOFALPHSUICUNECHAMBER_ROCKET
	const RUINSOFALPHSUICUNECHAMBER_SCIENTIST_NIKOLA
	const RUINSOFALPHSUICUNECHAMBER_SCIENTIST_MURRAY

RuinsOfAlphSuicuneChamber_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_TILES, RuinsOfAlphSuicuneChamberOpenHoleCallback

RuinsOfAlphSuicuneChamberOpenHoleCallback:
	checkevent EVENT_SOLVED_SUICUNE_PUZZLE
	iffalse .FloorClosed
	endcallback
.FloorClosed:
	changeblock 2, 2, $01 ; left floor
	changeblock 4, 2, $02 ; right floor
	changeblock 2, 8, $15 ; left entrance
	changeblock 4, 8, $16 ; right entrance
	endcallback

RuinsOfAlphSuicuneChamberPuzzle:
	reanchormap
	setval UNOWNPUZZLE_SUICUNE
	special UnownPuzzle
	closetext
	iftrue .PuzzleComplete
	end

.PuzzleComplete:
	setevent EVENT_SOLVED_SUICUNE_PUZZLE
	earthquake 30
	showemote EMOTE_SHOCK, PLAYER, 15
	changeblock 2, 2, $18 ; left hole
	changeblock 4, 2, $19 ; right hole
	refreshmap
	playsound SFX_STRENGTH
	earthquake 80
	applymovement PLAYER, RuinsOfAlphSuicuneChamberSkyfallTopMovement
	playsound SFX_KINESIS
	waitsfx
	pause 20
	warpcheck
	end

TrainerGruntM42:
	trainer GRUNTM, GRUNTM_42, EVENT_BEAT_ROCKET_GRUNTM_42, GruntM42SeenText, GruntM42BeatenText, 0, .Script

.Script:
	opentext
	writetext GruntM42AfterBattleText
	waitbutton
	closetext
	end

TrainerScientistNikola:
	trainer SCIENTIST, NIKOLA, EVENT_BEAT_SCIENTIST_NIKOLA, ScientistNikolaSeenText, ScientistNikolaBeatenText, 0, .Script

.Script:
	opentext
	writetext ScientistNikolaAfterBattleText
	waitbutton
	closetext
	end

TrainerScientistMurray:
	trainer SCIENTIST, MURRAY, EVENT_BEAT_SCIENTIST_MURRAY, ScientistMurraySeenText, ScientistMurrayBeatenText, 0, .Script

.Script:
	opentext
	writetext ScientistMurrayAfterBattleText
	waitbutton
	closetext
	end

RuinsOfAlphSuicuneChamberAncientReplica:
	jumptext RuinsOfAlphSuicuneChamberAncientReplicaText

RuinsOfAlphSuicuneChamberDescriptionSign:
	jumptext RuinsOfAlphSuicuneChamberDescriptionText

RuinsOfAlphSuicuneChamberSkyfallTopMovement:
	skyfall_top
	step_end

GruntM42SeenText:
	text "Nobody gets past"
	line "me! Not this"
	cont "time!"
	done

GruntM42BeatenText:
	text "Not again!"
	done

GruntM42AfterBattleText:
	text "The bosses say"
	line "this chamber is"
	cont "the big one."

	para "Something about a"
	line "legendary beast…"
	done

ScientistNikolaSeenText:
	text "Don't touch that"
	line "puzzle! We're so"
	cont "close!"
	done

ScientistNikolaBeatenText:
	text "My notes!"
	done

ScientistNikolaAfterBattleText:
	text "The carving shows"
	line "a beast of water"
	cont "and wind."

	para "Legends say it"
	line "purifies water"
	cont "with a touch."
	done

ScientistMurraySeenText:
	text "An intruder in"
	line "the last chamber?"

	para "Our data is far"
	line "too precious!"
	done

ScientistMurrayBeatenText:
	text "Data corrupted!"
	done

ScientistMurrayAfterBattleText:
	text "Every reading"
	line "here points to"
	cont "one #MON."

	para "The executives"
	line "want it for TEAM"
	cont "ROCKET."
	done

RuinsOfAlphSuicuneChamberAncientReplicaText:
	text "It's a replica of"
	line "an ancient #-"
	cont "MON."
	done

RuinsOfAlphSuicuneChamberDescriptionText:
	text "A #MON that"
	line "raced across the"

	para "land on the north"
	line "wind."
	done

RuinsOfAlphSuicuneChamber_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  3,  9, RUINS_OF_ALPH_OUTSIDE, 12
	warp_event  4,  9, RUINS_OF_ALPH_OUTSIDE, 12
	warp_event  3,  3, RUINS_OF_ALPH_SUICUNE_ITEM_ROOM, 1
	warp_event  4,  3, RUINS_OF_ALPH_SUICUNE_ITEM_ROOM, 2

	def_coord_events

	def_bg_events
	bg_event  2,  3, BGEVENT_READ, RuinsOfAlphSuicuneChamberAncientReplica
	bg_event  5,  3, BGEVENT_READ, RuinsOfAlphSuicuneChamberAncientReplica
	bg_event  3,  2, BGEVENT_UP, RuinsOfAlphSuicuneChamberPuzzle
	bg_event  4,  2, BGEVENT_UP, RuinsOfAlphSuicuneChamberDescriptionSign

	def_object_events
	object_event  6,  7, SPRITE_ROCKET, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 4, TrainerGruntM42, EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS
	object_event  2,  4, SPRITE_SCIENTIST, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 2, TrainerScientistNikola, EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS
	object_event  5,  4, SPRITE_SCIENTIST, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 2, TrainerScientistMurray, EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS

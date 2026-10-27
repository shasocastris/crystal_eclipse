	object_const_def
	const VALENCIAPORT_SAILOR1
	const VALENCIAPORT_SAILOR2
	const VALENCIAPORT_SUPER_NERD

ValenciaPort_MapScripts:
	def_scene_scripts
	scene_script ValenciaPortNoopScene,      SCENE_VALENCIAPORT_ASK_ENTER_SHIP
	scene_script ValenciaPortLeaveShipScene, SCENE_VALENCIAPORT_LEAVE_SHIP

	def_callbacks

ValenciaPortNoopScene:
	end

ValenciaPortLeaveShipScene:
	sdefer ValenciaPortLeaveShipScript
	end

ValenciaPortLeaveShipScript:
	applymovement PLAYER, ValenciaPortLeaveFastShipMovement
	appear VALENCIAPORT_SAILOR1
	setscene SCENE_VALENCIAPORT_ASK_ENTER_SHIP
; No EVENT_FAST_SHIP_* here: the express never enters the S.S.AQUA, so it must
; not advance the ship's own quest state (first trip, cabins, passengers).
	setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1
	blackoutmod VALENCIA_ISLAND ; the island holds SPAWN_VALENCIA; a non-spawn map
	                            ; here makes GetWhiteoutSpawn fall back to SPAWN_HOME
	end

ValenciaPortSailorAtGangwayScript:
	faceplayer
	opentext
	checkevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1
	iftrue ValenciaPortAlreadyRodeScript
	writetext ValenciaPortDepartingText
	waitbutton
	closetext
	turnobject VALENCIAPORT_SAILOR1, DOWN
	pause 10
	playsound SFX_EXIT_BUILDING
	disappear VALENCIAPORT_SAILOR1
	waitsfx
	applymovement PLAYER, ValenciaPortEnterFastShipMovement
	playsound SFX_EXIT_BUILDING
	special FadeOutToWhite
	waitsfx
	pause 40 ; the crossing
	appear VALENCIAPORT_SAILOR1
	setevent EVENT_VERMILION_PORT_SAILOR_AT_GANGWAY
	setmapscene VERMILION_PORT, SCENE_VERMILIONPORT_LEAVE_EXPRESS
	warp VERMILION_PORT, 7, 17
	end

ValenciaPortAlreadyRodeScript:
	writetext ValenciaPortCantBoardText
	waitbutton
	closetext
	end

ValenciaPortWalkUpToShipScript:
	turnobject VALENCIAPORT_SAILOR2, RIGHT
	checkevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1
	iftrue .skip
	checkevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_2
	iftrue .skip
	turnobject PLAYER, LEFT
	opentext
; No VAR_WEEKDAY gate: the express is not the S.S.AQUA and runs daily, so the
; player cannot be stranded on Valencia waiting for a sailing day.
	writetext ValenciaPortAskBoardingText
	yesorno
	iffalse ValenciaPortNotRidingMoveAwayScript
	writetext ValenciaPortAskPassText
	promptbutton
	checkitem ORANGE_PASS
	iffalse .NoPass
	writetext ValenciaPortOrangePassText
	waitbutton
	closetext
	setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_2
	applymovement PLAYER, ValenciaPortApproachFastShipMovement
	sjump ValenciaPortSailorAtGangwayScript

.NoPass:
	writetext ValenciaPortNoPassText
	waitbutton
	closetext
	applymovement PLAYER, ValenciaPortCannotEnterFastShipMovement
	end

.skip:
	end

ValenciaPortNotRidingScript:
	writetext ValenciaPortComeAgainText
	waitbutton
	closetext
	end

ValenciaPortNotRidingMoveAwayScript:
	writetext ValenciaPortComeAgainText
	waitbutton
	closetext
	applymovement PLAYER, ValenciaPortCannotEnterFastShipMovement
	end

ValenciaPortSailorScript:
	faceplayer
	opentext
	checkevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1
	iftrue ValenciaPortAlreadyRodeScript
	writetext ValenciaPortAskBoardingText
	yesorno
	iffalse ValenciaPortNotRidingScript
	writetext ValenciaPortAskPassText
	promptbutton
	checkitem ORANGE_PASS
	iffalse .NoPass
	writetext ValenciaPortOrangePassText
	waitbutton
	closetext
	setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_2
	applymovement PLAYER, ValenciaPortApproachFastShipRightMovement
	sjump ValenciaPortSailorAtGangwayScript

.NoPass:
	writetext ValenciaPortNoPassText
	waitbutton
	closetext
	end

ValenciaPortSuperNerdScript:
	faceplayer
	opentext
	writetext ValenciaPortSuperNerdText
	waitbutton
	closetext
	end

ValenciaPortEnterFastShipMovement:
	step DOWN
	step_end

ValenciaPortLeaveFastShipMovement:
	step UP
	step_end

ValenciaPortCannotEnterFastShipMovement:
	step RIGHT
	turn_head LEFT
	step_end

ValenciaPortApproachFastShipMovement:
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step_end

ValenciaPortApproachFastShipRightMovement:
	step RIGHT
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step_end

ValenciaPortDepartingText:
	text "We're departing"
	line "soon. Please get"
	cont "on board."
	done

ValenciaPortCantBoardText:
	text "Sorry. You can't"
	line "board now."
	done

ValenciaPortAskBoardingText:
	text "This is the"
	line "VERMILION express."

	para "Will you be board-"
	line "ing today?"
	done

ValenciaPortAskPassText:
	text "May I see your"
	line "ORANGE PASS?"
	done

ValenciaPortComeAgainText:
	text "We hope to see you"
	line "again!"
	done

ValenciaPortOrangePassText:
	text "<PLAYER> flashed"
	line "the ORANGE PASS."

	para "That's it."
	line "Thank you!"
	done

ValenciaPortNoPassText:
	text "<PLAYER> tried to"
	line "show the ORANGE"
	cont "PASS…"

	para "…But no PASS!"

	para "Sorry!"
	line "You may board only"

	para "if you have an"
	line "ORANGE PASS."
	done

ValenciaPortSuperNerdText:
	text "You came from"
	line "JOHTO?"

	para "I hear many rare"
	line "#MON live over"
	cont "there."
	done

ValenciaPort_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  9,  5, VALENCIA_ISLAND, 2
	warp_event  8,  5, VALENCIA_ISLAND, 1

	def_coord_events
	coord_event  7, 11, SCENE_VALENCIAPORT_ASK_ENTER_SHIP, ValenciaPortWalkUpToShipScript

	def_bg_events

	def_object_events
	object_event  7, 17, SPRITE_SAILOR, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ValenciaPortSailorAtGangwayScript, EVENT_VALENCIA_PORT_SAILOR_AT_GANGWAY
	object_event  6, 11, SPRITE_SAILOR, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ValenciaPortSailorScript, -1
	object_event 11, 11, SPRITE_SUPER_NERD, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 2, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ValenciaPortSuperNerdScript, -1

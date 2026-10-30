	object_const_def
	const VERMILIONPORT_SAILOR1
	const VERMILIONPORT_SAILOR2
	const VERMILIONPORT_SUPER_NERD
	const VERMILIONPORT_KOGA
	const VERMILIONPORT_RANGER

VermilionPort_MapScripts:
	def_scene_scripts
	scene_script VermilionPortNoopScene,      SCENE_VERMILIONPORT_ASK_ENTER_SHIP
	scene_script VermilionPortLeaveShipScene, SCENE_VERMILIONPORT_LEAVE_SHIP
	scene_script VermilionPortLeaveExpressScene, SCENE_VERMILIONPORT_LEAVE_EXPRESS
	scene_script VermilionPortRaidBlackoutScene, SCENE_VERMILIONPORT_RAID_BLACKOUT

	def_callbacks
	callback MAPCALLBACK_NEWMAP, VermilionPortFlypointCallback
	callback MAPCALLBACK_OBJECTS, VermilionPortKogaCallback

VermilionPortNoopScene:
	end

VermilionPortLeaveShipScene:
	sdefer VermilionPortLeaveShipScript
	end

VermilionPortLeaveExpressScene:
	sdefer VermilionPortLeaveExpressScript
	end

VermilionPortRaidBlackoutScene:
	sdefer VermilionPortRaidBlackoutScript
	end

VermilionPortFlypointCallback:
	setflag ENGINE_FLYPOINT_VERMILION
	endcallback

VermilionPortKogaCallback:
	checkevent EVENT_SS_AQUA_RAID
	iftrue .Show
	disappear VERMILIONPORT_KOGA
	disappear VERMILIONPORT_RANGER
	endcallback

.Show:
	appear VERMILIONPORT_KOGA
	appear VERMILIONPORT_RANGER
	endcallback

VermilionPortLeaveShipScript:
	applymovement PLAYER, VermilionPortLeaveFastShipMovement
	appear VERMILIONPORT_SAILOR1
	setscene SCENE_VERMILIONPORT_ASK_ENTER_SHIP
	checkevent EVENT_SS_AQUA_RAID
	iffalse .ShipHousekeeping
	scall VermilionPortKogaWalksDownScript
	opentext
	writetext VermilionPortKogaRaidOverText
	waitbutton
	closetext
	scall VermilionPortKogaWalksBackScript
	scall VermilionPortEndRaidScript
.ShipHousekeeping:
	setevent EVENT_FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN_TWIN_1
	setevent EVENT_FAST_SHIP_CABINS_SE_SSE_GENTLEMAN
	setevent EVENT_FAST_SHIP_PASSENGERS_FIRST_TRIP
	clearevent EVENT_OLIVINE_PORT_PASSAGE_POKEFAN_M
	setevent EVENT_FAST_SHIP_FIRST_TIME
	setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1
	blackoutmod VERMILION_CITY
	end

; Whiting out on the raid voyage lands the player on the pier, and Koga has
; already taken the ship. Nothing is rewarded that wasn't already given.
VermilionPortRaidBlackoutScript:
	appear VERMILIONPORT_SAILOR1
	setscene SCENE_VERMILIONPORT_ASK_ENTER_SHIP
	turnobject PLAYER, UP
	scall VermilionPortKogaWalksDownScript
	opentext
	writetext VermilionPortKogaFoundYouText
	promptbutton
	checkevent EVENT_FAST_SHIP_FOUND_GIRL
	iftrue .AlreadyRescued
	writetext VermilionPortKogaTookTheShipText
	sjump .Done

.AlreadyRescued:
	writetext VermilionPortKogaGirlToldUsText
.Done:
	waitbutton
	closetext
	scall VermilionPortKogaWalksBackScript
	scall VermilionPortEndRaidScript
	sjump VermilionPortLeaveShipScript.ShipHousekeeping

VermilionPortKogaWalksDownScript:
	applymovement VERMILIONPORT_KOGA, VermilionPortKogaWalksDownMovement
	end

VermilionPortKogaWalksBackScript:
	applymovement VERMILIONPORT_KOGA, VermilionPortKogaWalksBackMovement
	end

; close out the first-trip quest however it ended
VermilionPortEndRaidScript:
	clearevent EVENT_SS_AQUA_RAID
	setevent EVENT_FAST_SHIP_PETREL
	setevent EVENT_FAST_SHIP_FOUND_GIRL
	setevent EVENT_FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN_TWIN_2
	setevent EVENT_FAST_SHIP_CABINS_NNW_NNE_NE_SAILOR
	setevent EVENT_FAST_SHIP_1F_GENTLEMAN
	setmapscene FAST_SHIP_B1F, SCENE_FASTSHIPB1F_NOOP
	end

VermilionPortKogaScript:
	jumptextfaceplayer VermilionPortKogaAfterText

VermilionPortRangerScript:
	jumptextfaceplayer VermilionPortRangerText

VermilionPortLeaveExpressScript:
; The express never enters the S.S.AQUA, so unlike the arrival above it must not
; set any EVENT_FAST_SHIP_* -- those spawn the first-trip trainers and the
; post-quest grandpa and granddaughter.
	applymovement PLAYER, VermilionPortLeaveFastShipMovement
	appear VERMILIONPORT_SAILOR1
	setscene SCENE_VERMILIONPORT_ASK_ENTER_SHIP
	setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1
	blackoutmod VERMILION_CITY
	end

VermilionPortSailorAtGangwayScript:
	faceplayer
	opentext
	checkevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1
	iftrue VermilionPortAlreadyRodeScript
; The ORANGE PASS sails the express any day. Only a player who could also take
; the S.S.AQUA today is asked which.
	checkitem ORANGE_PASS
	iffalse .BoardAqua
	checkitem S_S_TICKET
	iffalse VermilionPortValenciaExpressScript
	checkevent EVENT_FAST_SHIP_FIRST_TIME
	iffalse VermilionPortValenciaExpressScript
	readvar VAR_WEEKDAY
	ifequal WEDNESDAY, .AskExpress
	ifequal SUNDAY, .AskExpress
	sjump VermilionPortValenciaExpressScript

.AskExpress:
	writetext VermilionPortAskExpressText
	yesorno
	iftrue VermilionPortValenciaExpressScript
.BoardAqua:
	writetext VermilionPortDepartingText
	waitbutton
	closetext
	turnobject VERMILIONPORT_SAILOR1, DOWN
	pause 10
	playsound SFX_EXIT_BUILDING
	disappear VERMILIONPORT_SAILOR1
	waitsfx
	applymovement PLAYER, VermilionPortEnterFastShipMovement
	playsound SFX_EXIT_BUILDING
	special FadeOutToWhite
	waitsfx
	setevent EVENT_FAST_SHIP_PASSENGERS_EASTBOUND
	clearevent EVENT_FAST_SHIP_PASSENGERS_WESTBOUND
	clearevent EVENT_BEAT_POKEMANIAC_ETHAN
	clearevent EVENT_BEAT_BURGLAR_COREY
	clearevent EVENT_BEAT_BUG_CATCHER_KEN
	clearevent EVENT_BEAT_GUITARIST_CLYDE
	clearevent EVENT_BEAT_POKEFANM_JEREMY
	clearevent EVENT_BEAT_POKEFANF_GEORGIA
	clearevent EVENT_BEAT_SAILOR_KENNETH
	clearevent EVENT_BEAT_TEACHER_SHIRLEY
	clearevent EVENT_BEAT_SCHOOLBOY_NATE
	clearevent EVENT_BEAT_SCHOOLBOY_RICKY
	setevent EVENT_FAST_SHIP_DESTINATION_OLIVINE
	appear VERMILIONPORT_SAILOR1
	setmapscene FAST_SHIP_1F, SCENE_FASTSHIP1F_ENTER_SHIP
	warp FAST_SHIP_1F, 25, 1
	end

VermilionPortValenciaExpressScript:
; The express does not use the S.S.AQUA interior, so none of the FAST_SHIP
; passenger or trainer events are touched -- it is a straight crossing.
	writetext VermilionPortExpressDepartingText
	waitbutton
	closetext
	turnobject VERMILIONPORT_SAILOR1, DOWN
	pause 10
	playsound SFX_EXIT_BUILDING
	disappear VERMILIONPORT_SAILOR1
	waitsfx
	applymovement PLAYER, VermilionPortEnterFastShipMovement
	playsound SFX_EXIT_BUILDING
	special FadeOutToWhite
	waitsfx
	pause 40 ; the crossing
	appear VERMILIONPORT_SAILOR1
	setevent EVENT_VALENCIA_PORT_SAILOR_AT_GANGWAY
	setmapscene VALENCIA_PORT, SCENE_VALENCIAPORT_LEAVE_SHIP
	warp VALENCIA_PORT, 7, 17
	end

VermilionPortAlreadyRodeScript:
	writetext VermilionPortCantBoardText
	waitbutton
	closetext
	end

VermilionPortWalkUpToShipScript:
	turnobject VERMILIONPORT_SAILOR2, RIGHT
	checkevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1
	iftrue .skip
	checkevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_2
	iftrue .skip
	turnobject PLAYER, LEFT
	opentext
	checkitem ORANGE_PASS
	iftrue .OrangePass
	checkevent EVENT_FAST_SHIP_FIRST_TIME
	iffalse .FirstRunFromOlivine
	readvar VAR_WEEKDAY
	ifequal MONDAY, .NextShipWednesday
	ifequal TUESDAY, .NextShipWednesday
	ifequal THURSDAY, .NextShipSunday
	ifequal FRIDAY, .NextShipSunday
	ifequal SATURDAY, .NextShipSunday
	writetext VermilionPortAskBoardingText
	yesorno
	iffalse VermilionPortNotRidingMoveAwayScript
	writetext VermilionPortAskTicketText
	promptbutton
	checkitem S_S_TICKET
	iffalse .NoTicket
	writetext VermilionPortSSTicketText
.Board:
	waitbutton
	closetext
	setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_2
	applymovement PLAYER, VermilionPortApproachFastShipMovement
	sjump VermilionPortSailorAtGangwayScript

.OrangePass:
	writetext VermilionPortAskBoardingText
	yesorno
	iffalse VermilionPortNotRidingMoveAwayScript
	writetext VermilionPortOrangePassText
	sjump .Board

.NoTicket:
	writetext VermilionPortNoTicketText
	waitbutton
	closetext
	applymovement PLAYER, VermilionPortCannotEnterFastShipMovement
	end

.NextShipWednesday:
	writetext VermilionPortSailWednesdayText
	waitbutton
	closetext
	applymovement PLAYER, VermilionPortCannotEnterFastShipMovement
	end

.NextShipSunday:
	writetext VermilionPortSailSundayText
	waitbutton
	closetext
	applymovement PLAYER, VermilionPortCannotEnterFastShipMovement
	end

.FirstRunFromOlivine:
	writetext VermilionPortFirstRunText
	waitbutton
	closetext
	applymovement PLAYER, VermilionPortCannotEnterFastShipMovement
	end

.skip:
	end

VermilionPortNotRidingScript:
	writetext VermilionPortComeAgainText
	waitbutton
	closetext
	end

VermilionPortNotRidingMoveAwayScript:
	writetext VermilionPortComeAgainText
	waitbutton
	closetext
	applymovement PLAYER, VermilionPortCannotEnterFastShipMovement
	end

VermilionPortSailorScript:
	faceplayer
	opentext
	checkevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1
	iftrue VermilionPortAlreadyRodeScript
	checkitem ORANGE_PASS
	iftrue .OrangePass
	checkevent EVENT_FAST_SHIP_FIRST_TIME
	iffalse .FirstRunFromOlivine
	readvar VAR_WEEKDAY
	ifequal MONDAY, .NextShipWednesday
	ifequal TUESDAY, .NextShipWednesday
	ifequal THURSDAY, .NextShipSunday
	ifequal FRIDAY, .NextShipSunday
	ifequal SATURDAY, .NextShipSunday
	writetext VermilionPortAskBoardingText
	yesorno
	iffalse VermilionPortNotRidingScript
	writetext VermilionPortAskTicketText
	promptbutton
	checkitem S_S_TICKET
	iffalse .NoTicket
	writetext VermilionPortSSTicketText
.Board:
	waitbutton
	closetext
	setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_2
	applymovement PLAYER, VermilionPortApproachFastShipRightMovement
	sjump VermilionPortSailorAtGangwayScript

.OrangePass:
	writetext VermilionPortAskBoardingText
	yesorno
	iffalse VermilionPortNotRidingScript
	writetext VermilionPortOrangePassText
	sjump .Board

.NoTicket:
	writetext VermilionPortNoTicketText
	waitbutton
	closetext
	end

.NextShipWednesday:
	writetext VermilionPortSailWednesdayText
	waitbutton
	closetext
	end

.NextShipSunday:
	writetext VermilionPortSailSundayText
	waitbutton
	closetext
	end

.FirstRunFromOlivine:
	writetext VermilionPortFirstRunText
	waitbutton
	closetext
	end

VermilionPortSuperNerdScript:
	faceplayer
	opentext
	writetext VermilionPortSuperNerdText
	waitbutton
	closetext
	end

VermilionPortHiddenIron:
	hiddenitem IRON, EVENT_VERMILION_PORT_HIDDEN_IRON

VermilionPortEnterFastShipMovement:
	step DOWN
	step_end

VermilionPortLeaveFastShipMovement:
	step UP
	step_end

VermilionPortKogaWalksDownMovement:
	step LEFT
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step_end

VermilionPortKogaWalksBackMovement:
	step UP
	step UP
	step UP
	step UP
	step RIGHT
	turn_head DOWN
	step_end

VermilionPortCannotEnterFastShipMovement:
	step RIGHT
	turn_head LEFT
	step_end

VermilionPortApproachFastShipMovement:
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step_end

VermilionPortApproachFastShipRightMovement:
	step RIGHT
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step_end

VermilionPortKogaRaidOverText:
	text "KOGA: Fwahahaha!"
	line "So it was you,"
	cont "<PLAY_G>!"

	para "The CAPTAIN radio-"
	line "ed ahead about a"
	cont "trainer who drove"
	cont "off TEAM ROCKET."

	para "The RANGER and I"
	line "will deal with the"
	cont "rest of the crew."

	para "As for PETREL…"
	line "He cannot hide"
	cont "from me for long."

	para "ROCKET is stirring"
	line "in KANTO. Keep"
	cont "your eyes open!"
	done

VermilionPortKogaFoundYouText:
	text "KOGA: Ah, you are"
	line "awake."

	para "We found you out"
	line "cold aboard the"
	cont "S.S.AQUA."
	done

VermilionPortKogaTookTheShipText:
	text "When she docked,"
	line "the RANGER and I"
	cont "took the ship."

	para "The girl and the"
	line "CAPTAIN are safe."

	para "PETREL slipped"
	line "away, though."

	para "ROCKET is stirring"
	line "in KANTO. Rest,"
	cont "then keep your"
	cont "eyes open!"
	done

VermilionPortKogaGirlToldUsText:
	text "The girl told us"
	line "how you saved her."

	para "PETREL slipped"
	line "away, though."

	para "ROCKET is stirring"
	line "in KANTO. Rest,"
	cont "then keep your"
	cont "eyes open!"
	done

VermilionPortKogaAfterText:
	text "KOGA: TEAM ROCKET"
	line "won't stop here."

	para "Keep your eyes"
	line "open in KANTO,"
	cont "<PLAY_G>."
	done

VermilionPortRangerText:
	text "RANGER: The stolen"
	line "#MON will be"
	cont "returned to their"
	cont "owners."
	done

VermilionPortFirstRunText:
	text "Sorry! S.S.AQUA's"
	line "next run sets out"
	cont "from OLIVINE."
	done

VermilionPortDepartingText:
	text "We're departing"
	line "soon. Please get"
	cont "on board."
	done

VermilionPortAskExpressText:
	text "The S.S.AQUA"
	line "sails for JOHTO."

	para "We also run an"
	line "express to the"
	cont "ORANGE ISLANDS."

	para "Take the express?"
	done

VermilionPortExpressDepartingText:
	text "The express is"
	line "leaving now!"

	para "Next stop:"
	line "VALENCIA ISLAND!"
	done

VermilionPortCantBoardText:
	text "Sorry. You can't"
	line "board now."
	done

VermilionPortAskBoardingText:
	text "Welcome to FAST"
	line "SHIP S.S.AQUA."

	para "Will you be board-"
	line "ing today?"
	done

VermilionPortAskTicketText:
	text "May I see your"
	line "S.S.TICKET?"
	done

VermilionPortComeAgainText:
	text "We hope to see you"
	line "again!"
	done

VermilionPortSSTicketText:
	text "<PLAYER> flashed"
	line "the S.S.TICKET."

	para "That's it."
	line "Thank you!"
	done

VermilionPortOrangePassText:
	text "<PLAYER> flashed"
	line "the ORANGE PASS."

	para "That's it."
	line "Thank you!"
	done

VermilionPortNoTicketText:
	text "<PLAYER> tried to"
	line "show the S.S."
	cont "TICKET…"

	para "…But no TICKET!"

	para "Sorry!"
	line "You may board only"

	para "if you have an"
	line "S.S.TICKET."
	done

VermilionPortSailWednesdayText:
	text "The FAST SHIP will"
	line "sail on Wednesday."
	done

VermilionPortSailSundayText:
	text "The FAST SHIP will"
	line "sail next Sunday."
	done

VermilionPortSuperNerdText:
	text "You came from"
	line "JOHTO?"

	para "I hear many rare"
	line "#MON live over"
	cont "there."
	done

VermilionPort_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  9,  5, VERMILION_PORT_PASSAGE, 5
	warp_event  7, 17, FAST_SHIP_1F, 1

	def_coord_events
	coord_event  7, 11, SCENE_VERMILIONPORT_ASK_ENTER_SHIP, VermilionPortWalkUpToShipScript

	def_bg_events
	bg_event 16, 13, BGEVENT_ITEM, VermilionPortHiddenIron

	def_object_events
	object_event  7, 17, SPRITE_SAILOR, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, VermilionPortSailorAtGangwayScript, EVENT_VERMILION_PORT_SAILOR_AT_GANGWAY
	object_event  6, 11, SPRITE_SAILOR, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, VermilionPortSailorScript, -1
	object_event 11, 11, SPRITE_SUPER_NERD, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 2, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, VermilionPortSuperNerdScript, -1
	object_event  8, 11, SPRITE_KOGA, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, VermilionPortKogaScript, EVENT_VERMILION_PORT_KOGA
	object_event  8, 10, SPRITE_OFFICER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_SCRIPT, 0, VermilionPortRangerScript, EVENT_VERMILION_PORT_KOGA

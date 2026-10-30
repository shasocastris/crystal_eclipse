	object_const_def
	const SAFFRONUNDERGROUNDWAREHOUSE_ROCKET1
	const SAFFRONUNDERGROUNDWAREHOUSE_ROCKET2
	const SAFFRONUNDERGROUNDWAREHOUSE_ROCKET3
	const SAFFRONUNDERGROUNDWAREHOUSE_PETREL
	const SAFFRONUNDERGROUNDWAREHOUSE_POKE_BALL1
	const SAFFRONUNDERGROUNDWAREHOUSE_POKE_BALL2
	const SAFFRONUNDERGROUNDWAREHOUSE_POKE_BALL3

SaffronUndergroundWarehouse_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_NEWMAP, SaffronUndergroundWarehouseResetSwitchesCallback

SaffronUndergroundWarehouseResetSwitchesCallback:
	clearevent EVENT_SWITCH_1
	clearevent EVENT_SWITCH_2
	clearevent EVENT_SWITCH_3
	clearevent EVENT_EMERGENCY_SWITCH
	clearevent EVENT_SWITCH_4
	clearevent EVENT_SWITCH_5
	clearevent EVENT_SWITCH_6
	clearevent EVENT_SWITCH_7
	clearevent EVENT_SWITCH_8
	clearevent EVENT_SWITCH_9
	clearevent EVENT_SWITCH_10
	clearevent EVENT_SWITCH_11
	clearevent EVENT_SWITCH_12
	clearevent EVENT_SWITCH_13
	clearevent EVENT_SWITCH_14
	setval 0
	writemem wUndergroundSwitchPositions
	endcallback

TrainerGruntM24:
	trainer GRUNTM, GRUNTM_24, EVENT_BEAT_ROCKET_GRUNTM_24, GruntM24SeenText, GruntM24BeatenText, 0, .Script

.Script:
	opentext
	writetext GruntM24AfterBattleText
	waitbutton
	closetext
	end

GruntM24SeenText:
	text "How did you get"
	line "this far?"

	para "I guess it can't"
	line "be helped. I'll"
	cont "dispose of you."
	done

GruntM24BeatenText:
	text "I got disposed of…"
	done

GruntM24AfterBattleText:
	text "TEAM ROCKET will"
	line "keep going, wait-"
	cont "ing for the return"
	cont "of GIOVANNI."

	para "We'll do whatever"
	line "it takes."
	done

TrainerGruntM14:
	trainer GRUNTM, GRUNTM_14, EVENT_BEAT_ROCKET_GRUNTM_14, GruntM14SeenText, GruntM14BeatenText, 0, .Script

.Script:
	opentext
	writetext GruntM14AfterBattleText
	waitbutton
	closetext
	end

GruntM14SeenText:
	text "You're not going"
	line "any farther!"

	para "I don't show mercy"
	line "to my enemies, not"
	cont "even brats!"
	done

GruntM14BeatenText:
	text "Blast it!"
	done

GruntM14AfterBattleText:
	text "I lost…"

	para "Please forgive me,"
	line "GIOVANNI!"
	done

TrainerGruntM15:
	trainer GRUNTM, GRUNTM_15, EVENT_BEAT_ROCKET_GRUNTM_15, GruntM15SeenText, GruntM15BeatenText, 0, .Script

.Script:
	opentext
	writetext GruntM15AfterBattleText
	waitbutton
	closetext
	end

GruntM15SeenText:
	text "Hyuck-hyuck-hyuck!"
	line "I remember you!"

	para "You got me good"
	line "at CERULEAN!"
	done

GruntM15BeatenText:
	text "Hyuck-hyuck-hyuck!"
	line "So, that's how?"
	done

GruntM15AfterBattleText:
	text "Hyuck-hyuck-hyuck!"
	line "That was a blast!"
	cont "I'll remember you!"
	done

SaffronUndergroundWarehousePetrelScript:
	faceplayer
	special FadeOutMusic
	pause 15
	playmusic MUSIC_ROCKET_ENCOUNTER
	opentext
	writetext PetrelWarehouseBeforeText
	waitbutton
	closetext
	winlosstext PetrelWarehouseWinText, 0
	setlasttalked SAFFRONUNDERGROUNDWAREHOUSE_PETREL
	loadtrainer EXECUTIVEM, EXECUTIVEM_3
	loadvar VAR_BATTLETYPE, BATTLETYPE_SET
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_ROCKET_EXECUTIVEM_3
	opentext
	writetext PetrelWarehouseAfterText
	promptbutton
	verbosegiveitem MACHINE_PART
	writetext PetrelWarehouseFarewellText
	waitbutton
	closetext
	disappear SAFFRONUNDERGROUNDWAREHOUSE_PETREL
	reloadmap
	special RestartMapMusic
	opentext
	writetext PetrelWarehouseSmokeBallText
	waitbutton
	closetext
	end

PetrelWarehouseBeforeText:
	text "Well. You again."

	para "I heard PROTON"
	line "got himself caught"
	cont "by a RANGER."

	para "Embarrassing."
	line "He always did"
	cont "prefer being a"
	cont "brute."

	para "Me? I prefer to"
	line "work quietly."
	cont "Nobody even knew"
	cont "this place existed"
	cont "until you showed"
	cont "up."

	para "The MACHINE PART"
	line "stays here."

	para "And so do you."
	done

PetrelWarehouseWinText:
	text "How…"
	line "uncharacteristic."
	done

PetrelWarehouseAfterText:
	text "Fine."

	para "You're better than"
	line "PROTON deserved."

	para "For what it's"
	line "worth, the POWER"
	cont "PLANT was never"
	cont "the real plan."

	para "It was a fallback."
	line "Insurance."

	para "The real plan is"
	line "already in motion"
	cont "north of CERULEAN."

	para "Go fix your POWER"
	line "PLANT."

	para "It won't matter."
	done

PetrelWarehouseFarewellText:
	text "Farewell … … …"
	done

PetrelWarehouseSmokeBallText:
	text "PETREL disappeared"
	line "with a SMOKE BALL!"
	done

SaffronUndergroundWarehouseMaxEther:
	itemball MAX_ETHER

SaffronUndergroundWarehouseTMSleepTalk:
	itemball TM_SLEEP_TALK

SaffronUndergroundWarehouseNugget:
	itemball NUGGET

SaffronUndergroundWarehouse_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2, 12, SAFFRON_UNDERGROUND_SWITCH_ROOM, 2
	warp_event  3, 12, SAFFRON_UNDERGROUND_SWITCH_ROOM, 3

	def_coord_events

	def_bg_events

	def_object_events
	object_event  9,  8, SPRITE_ROCKET, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 3, TrainerGruntM24, EVENT_RETURNED_MACHINE_PART
	object_event  8, 15, SPRITE_ROCKET, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 3, TrainerGruntM14, EVENT_RETURNED_MACHINE_PART
	object_event 14,  3, SPRITE_ROCKET, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 4, TrainerGruntM15, EVENT_RETURNED_MACHINE_PART
	object_event 12,  8, SPRITE_GENTLEMAN, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SaffronUndergroundWarehousePetrelScript, EVENT_BEAT_ROCKET_EXECUTIVEM_3
	object_event  2,  1, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, SaffronUndergroundWarehouseMaxEther, EVENT_SAFFRON_UNDERGROUND_WAREHOUSE_MAX_ETHER
	object_event 18, 15, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, SaffronUndergroundWarehouseTMSleepTalk, EVENT_SAFFRON_UNDERGROUND_WAREHOUSE_TM_SLEEP_TALK
	object_event 13,  9, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, SaffronUndergroundWarehouseNugget, EVENT_SAFFRON_UNDERGROUND_WAREHOUSE_NUGGET

	object_const_def
	const WILLSROOM_WILL

WillsRoom_MapScripts:
	def_scene_scripts
	scene_script WillsRoomLockDoorScene, SCENE_WILLSROOM_LOCK_DOOR
	scene_script WillsRoomNoopScene,     SCENE_WILLSROOM_NOOP

	def_callbacks
	callback MAPCALLBACK_TILES, WillsRoomDoorsCallback

WillsRoomLockDoorScene:
	sdefer WillsRoomDoorLocksBehindYouScript
	end

WillsRoomNoopScene:
	end

WillsRoomDoorsCallback:
	checkevent EVENT_WILLS_ROOM_ENTRANCE_CLOSED
	iffalse .KeepEntranceOpen
	changeblock 4, 14, $2a ; wall
.KeepEntranceOpen:
	checkevent EVENT_WILLS_ROOM_EXIT_OPEN
	iffalse .KeepExitClosed
	changeblock 4, 2, $16 ; open door
.KeepExitClosed:
	endcallback

WillsRoomDoorLocksBehindYouScript:
	applymovement PLAYER, WillsRoom_EnterMovement
	reanchormap $86
	playsound SFX_STRENGTH
	earthquake 80
	changeblock 4, 14, $2a ; wall
	refreshmap
	closetext
	setscene SCENE_WILLSROOM_NOOP
	setevent EVENT_WILLS_ROOM_ENTRANCE_CLOSED
	waitsfx
	end

WillScript_Battle:
	faceplayer
	opentext
	readvar VAR_BADGES
	ifequal NUM_BADGES, .WillRematch
	checkevent EVENT_BEAT_ELITE_4_WILL
	iftrue WillScript_AfterBattle
	writetext WillScript_WillBeforeText
	waitbutton
	closetext
	winlosstext WillScript_WillBeatenText, WillLossText
	loadtrainer WILL, WILL1
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_ELITE_4_WILL
	opentext
	writetext WillScript_WillDefeatText
	waitbutton
	closetext
	playsound SFX_ENTER_DOOR
	changeblock 4, 2, $16 ; open door
	refreshmap
	closetext
	setevent EVENT_WILLS_ROOM_EXIT_OPEN
	waitsfx
	end

.WillRematch:
	checkevent EVENT_BEAT_ELITE_4_WILL
	iftrue WillScript_AfterBattleRematch
	writetext WillScript_WillBeforeRematchText
	waitbutton
	closetext
	winlosstext WillScript_WillBeatenText, WillLossText
	loadtrainer WILL, WILL2
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_ELITE_4_WILL
	opentext
	writetext WillScript_WillDefeatRematchText
	waitbutton
	closetext
	playsound SFX_ENTER_DOOR
	changeblock 4, 2, $16 ; open door
	refreshmap
	closetext
	setevent EVENT_WILLS_ROOM_EXIT_OPEN
	waitsfx
	end

WillScript_AfterBattle:
	writetext WillScript_WillDefeatText
	waitbutton
	closetext
	end

WillScript_AfterBattleRematch:
	writetext WillScript_WillDefeatRematchText
	waitbutton
	closetext
	end

WillsRoom_EnterMovement:
	step UP
	step UP
	step UP
	step UP
	step_end

WillScript_WillBeforeText:
	text "Welcome to #MON"
	line "LEAGUE, <PLAYER>."

	para "The LEAGUE is"
	line "closed, but LANCE"
	cont "called us back."

	para "He says you drove"
	line "TEAM ROCKET out of"
	cont "GOLDENROD."

	para "Allow me to intro-"
	line "duce myself. I am"
	cont "WILL."

	para "I have trained all"
	line "around the world,"

	para "making my psychic"
	line "#MON powerful."

	para "And, at last, I've"
	line "been accepted into"
	cont "the ELITE FOUR."

	para "I can only keep"
	line "getting better!"

	para "Losing is not an"
	line "option!"
	done

WillScript_WillBeatenText:
	text "I… I can't…"
	line "believe it…"
	done

WillLossText:
	text "The mind bends…"
	line "yours broke."
	done

WillScript_WillDefeatText:
	text "Even though I was"
	line "defeated, I won't"
	cont "change my course."

	para "I will continue"
	line "battling until I"

	para "stand above all"
	line "trainers!"

	para "Now, <PLAYER>, move"
	line "on and experience"

	para "the true ferocity"
	line "of the ELITE FOUR."
	done

WillScript_WillBeforeRematchText:
	text "Welcome back to"
	line "my chamber."

	para "I see you've"
	line "returned for"
	cont "another match."

	para "My powers have"
	line "grown since our"
	cont "last encounter."

	para "I've mastered new"
	line "techniques you"
	cont "have yet to see."

	para "Shall we begin?"
	done

WillScript_WillDefeatRematchText:
	text "Incredible! Your"
	line "mind has grown"
	cont "even sharper!"

	para "You saw through"
	line "every one of my"
	cont "illusions."

	para "A truly psychic"
	line "battle of wills!"

	para "Proceed to the"
	line "next chamber,"
	cont "worthy challenger!"
	done

WillsRoom_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  5, 17, INDIGO_PLATEAU_POKECENTER_1F, 4
	warp_event  4,  2, KOGAS_ROOM, 1
	warp_event  5,  2, KOGAS_ROOM, 2

	def_coord_events

	def_bg_events

	def_object_events
	object_event  5,  7, SPRITE_WILL, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, WillScript_Battle, -1

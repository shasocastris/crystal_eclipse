	object_const_def
	const KOGASROOM_KOGA

KogasRoom_MapScripts:
	def_scene_scripts
	scene_script KogasRoomLockDoorScene, SCENE_KOGASROOM_LOCK_DOOR
	scene_script KogasRoomNoopScene,     SCENE_KOGASROOM_NOOP

	def_callbacks
	callback MAPCALLBACK_TILES, KogasRoomDoorsCallback

KogasRoomLockDoorScene:
	sdefer KogasRoomDoorLocksBehindYouScript
	end

KogasRoomNoopScene:
	end

KogasRoomDoorsCallback:
	checkevent EVENT_KOGAS_ROOM_ENTRANCE_CLOSED
	iffalse .KeepEntranceOpen
	changeblock 4, 14, $2a ; wall
.KeepEntranceOpen:
	checkevent EVENT_KOGAS_ROOM_EXIT_OPEN
	iffalse .KeepExitClosed
	changeblock 4, 2, $16 ; open door
.KeepExitClosed:
	endcallback

KogasRoomDoorLocksBehindYouScript:
	applymovement PLAYER, KogasRoom_EnterMovement
	reanchormap $86
	playsound SFX_STRENGTH
	earthquake 80
	changeblock 4, 14, $2a ; wall
	refreshmap
	closetext
	setscene SCENE_KOGASROOM_NOOP
	setevent EVENT_KOGAS_ROOM_ENTRANCE_CLOSED
	waitsfx
	end

KogaScript_Battle:
	faceplayer
	opentext
	readvar VAR_BADGES
	ifequal NUM_BADGES, .KogaRematch
	checkevent EVENT_BEAT_ELITE_4_KOGA
	iftrue KogaScript_AfterBattle
	writetext KogaScript_KogaBeforeText
	waitbutton
	closetext
	winlosstext KogaScript_KogaBeatenText, KogaLossText
	loadtrainer KOGA, KOGA1
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_ELITE_4_KOGA
	opentext
	writetext KogaScript_KogaDefeatText
	waitbutton
	closetext
	playsound SFX_ENTER_DOOR
	changeblock 4, 2, $16 ; open door
	refreshmap
	closetext
	setevent EVENT_KOGAS_ROOM_EXIT_OPEN
	waitsfx
	end

.KogaRematch:
    checkevent EVENT_BEAT_ELITE_4_KOGA
    iftrue KogaScript_AfterBattleRematch
    writetext KogaScript_KogaBeforeRematchText
    waitbutton
    closetext
    winlosstext KogaScript_KogaBeatenText, KogaLossText
    loadtrainer KOGA, KOGA2
    startbattle
    reloadmapafterbattle
    setevent EVENT_BEAT_ELITE_4_KOGA
    opentext
    writetext KogaScript_KogaDefeatRematchText
    waitbutton
    closetext
    playsound SFX_ENTER_DOOR
    changeblock 4, 2, $16 ; open door
    refreshmap
    closetext
    setevent EVENT_KOGAS_ROOM_EXIT_OPEN
    waitsfx
    end

KogaScript_AfterBattle:
	writetext KogaScript_KogaDefeatText
	waitbutton
	closetext
	end

KogaScript_AfterBattleRematch:
	writetext KogaScript_KogaDefeatRematchText
	waitbutton
	closetext
	end

KogasRoom_EnterMovement:
	step UP
	step UP
	step UP
	step UP
	step UP ; the follower clears the closing door
	step_end

KogaScript_KogaBeforeText:
	text "Fwahahahaha!"

	para "I am KOGA of the"
	line "ELITE FOUR."

	para "I live in shadows,"
	line "a ninja!"

	para "My spies tell me"
	line "ROCKET is stirring"
	cont "in KANTO again."

	para "Before I hunt"
	line "them, let me test"
	cont "the one who drove"
	cont "them from JOHTO!"

	para "My intricate style"
	line "will confound and"
	cont "destroy you!"

	para "Confusion, sleep,"
	line "poison…"

	para "Prepare to be the"
	line "victim of my sin-"
	cont "ister technique!"

	para "Fwahahahaha!"

	para "#MON is not"
	line "merely about brute"

	para "force--you shall"
	line "see soon enough!"
	done

KogaScript_KogaBeatenText:
	text "Ah!"
	line "You have proven"
	cont "your worth!"
	done

KogaLossText:
	text "Poison exploits"
	line "every weakness."
	done

KogaScript_KogaDefeatText:
	text "I subjected you to"
	line "everything I could"
	cont "muster."

	para "But my efforts"
	line "failed. I must"
	cont "hone my skills."

	para "Go on to the next"
	line "room, and put your"
	cont "abilities to test!"
	done

KogaScript_KogaBeforeRematchText:
	text "Fwahahahaha!"

	para "You dare return to"
	line "my poisonous"
	cont "domain?"

	para "Excellent! I have"
	line "been perfecting"
	cont "my ninja arts!"

	para "My #MON and I"
	line "have trained in"
	cont "even deadlier"
	cont "techniques!"

	para "Confusion, sleep,"
	line "poison… and now"
	cont "much worse!"

	para "You will find my"
	line "sinister methods"
	cont "have evolved!"

	para "Fwahahahaha!"
	line "Prepare yourself!"
	done

KogaScript_KogaDefeatRematchText:
	text "Impossible! Even"
	line "my enhanced ninja"
	cont "techniques failed!"

	para "Your skill has"
	line "grown beyond my"
	cont "calculations."

	para "You have truly"
	line "mastered the art"
	cont "of battle!"

	para "Continue forward,"
	line "ninja master!"
	done

KogasRoom_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4, 17, WILLS_ROOM, 2
	warp_event  5, 17, WILLS_ROOM, 3
	warp_event  4,  2, BRUNOS_ROOM, 1
	warp_event  5,  2, BRUNOS_ROOM, 2

	def_coord_events

	def_bg_events

	def_object_events
	object_event  5,  7, SPRITE_KOGA, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, KogaScript_Battle, -1

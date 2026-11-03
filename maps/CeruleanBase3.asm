	object_const_def
	const CERULEANBASE3_ARIANA
	const CERULEANBASE3_ARCHER
	const CERULEANBASE3_MEWTWO
	const CERULEANBASE3_LANCE
	const CERULEANBASE3_FIRST_RANGER
	const CERULEANBASE3_UNOWN_M
	const CERULEANBASE3_UNOWN_E
	const CERULEANBASE3_UNOWN_W

CeruleanBase3_MapScripts:
	def_scene_scripts
	scene_script CeruleanBase3ArcherScene, SCENE_CERULEANBASE3_ARCHER
	scene_script CeruleanBase3Noop,        SCENE_CERULEANBASE3_NOOP

	def_callbacks

CeruleanBase3ArcherScene:
	sdefer CeruleanBase3ArcherApproachScript
	end

CeruleanBase3Noop:
	end

TrainerExecutiveFAriana:
	trainer EXECUTIVEF, EXECUTIVEF_3, EVENT_BEAT_ROCKET_EXECUTIVEF_3, ArianaBase3BeforeText, ArianaBase3WinText, 0, .Script

.Script:
	opentext
	writetext ArianaBase3AfterText
	waitbutton
	closetext
	applymovement PLAYER, CeruleanBase3PlayerApproachArcherMovement
	end

CeruleanBase3PlayerApproachArcherMovement:
	step RIGHT
	step UP
	step UP
	step UP
	step UP
	step UP
	step UP
	step UP
	step_end

ArianaBase3BeforeText:
	text "…You again."

	para "Don't think I've"
	line "forgotten how you"
	cont "ruined our plans"
	cont "at the RUINS OF"
	cont "ALPH."

	para "You cost us months"
	line "of work in JOHTO."

	para "It is high time"
	line "you paid for"
	cont "interfering with"
	cont "our operations."
	done

ArianaBase3WinText:
	text "Impossible…"
	done

ArianaBase3AfterText:
	text "…"

	para "You have beaten"
	line "me three times."

	para "Perhaps it is for"
	line "the best."

	para "Now you can see"
	line "that all your work"
	cont "in KANTO as well"
	cont "JOHTO did nothing."

	para "You're still about"
	line "to get crushed by"
	cont "one #MON."
	done

CeruleanBase3ArcherApproachScript:
	turnobject CERULEANBASE3_ARCHER, DOWN
	showemote EMOTE_SHOCK, CERULEANBASE3_ARCHER, 15
	special FadeOutMusic
	pause 15
	playmusic MUSIC_ROCKET_ENCOUNTER
	opentext
	writetext ArcherBase3BeforeText
	waitbutton
	closetext
	winlosstext ArcherBase3WinText, 0
	setlasttalked CERULEANBASE3_ARCHER
	loadtrainer EXECUTIVEM, EXECUTIVEM_4
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_ROCKET_EXECUTIVEM_4
	playmusic MUSIC_RIVAL_AFTER
	opentext
	writetext ArcherBase3AfterText
	waitbutton
	closetext

	; Unown disappear
	pause 30
	cry UNOWN
	applymovement CERULEANBASE3_UNOWN_M, CeruleanBase3UnownDisappearMovement
	disappear CERULEANBASE3_UNOWN_M
	pause 30
	playsound SFX_WARP_FROM
	applymovement CERULEANBASE3_UNOWN_E, CeruleanBase3UnownDisappearMovement
	disappear CERULEANBASE3_UNOWN_E
	pause 30
	playsound SFX_WARP_FROM
	applymovement CERULEANBASE3_UNOWN_W, CeruleanBase3UnownDisappearMovement
	disappear CERULEANBASE3_UNOWN_W
	pause 30
	playsound SFX_WARP_FROM
	waitsfx

	; Mewtwo breaks free
	playsound SFX_STRENGTH
	earthquake 120
	cry MEWTWO
	applymovement CERULEANBASE3_MEWTWO, CeruleanBase3MewtwoFleeMovement
	turnobject CERULEANBASE3_MEWTWO, RIGHT
	turnobject PLAYER, LEFT
	turnobject CERULEANBASE3_ARCHER, LEFT
	showemote EMOTE_SHOCK, CERULEANBASE3_MEWTWO, 30
	pause 30
	playsound SFX_WARP_TO
	special FadeOutToWhite
	pause 30
	special LoadMapPalettes
	special FadeInPalettes_EnableDynNoApply
	disappear CERULEANBASE3_MEWTWO
	waitsfx
	refreshmap
	pause 30
	opentext
	writetext ArcherCursesText
	waitbutton
	writetext LanceIThinkNotText
	waitbutton
	closetext
	; Lance and First Ranger appear
	appear CERULEANBASE3_LANCE
	appear CERULEANBASE3_FIRST_RANGER
	follow CERULEANBASE3_LANCE, CERULEANBASE3_FIRST_RANGER
	applymovement CERULEANBASE3_LANCE, CeruleanBase3LanceAppearMovement
	turnobject CERULEANBASE3_LANCE, RIGHT
	turnobject CERULEANBASE3_FIRST_RANGER, RIGHT
	opentext
	writetext LanceCapturesArcherText
	waitbutton
	writetext FirstRangerThanksText
	waitbutton
	closetext
	follow CERULEANBASE3_LANCE, CERULEANBASE3_ARCHER
	applymovement CERULEANBASE3_LANCE, CeruleanBase3LanceArrestsArcherMovement
	pause 10
	applymovement CERULEANBASE3_FIRST_RANGER, CeruleanBase3FirstRangerLeavesMovement
	disappear CERULEANBASE3_LANCE
	disappear CERULEANBASE3_ARCHER
	disappear CERULEANBASE3_FIRST_RANGER
	disappear CERULEANBASE3_ARIANA
	setscene SCENE_CERULEANBASE3_NOOP
	setevent EVENT_CLEARED_CERULEAN_CAVE
	setmapscene CERULEAN_BASE_2, SCENE_CERULEANBASE2_RIVAL
	playmapmusic
	end

CeruleanBase3UnownDisappearMovement:
	rock_smash 60
	step_end

CeruleanBase3MewtwoFleeMovement:
	step DOWN
	step_end

CeruleanBase3LanceAppearMovement:
	step UP
	step UP
	step UP
	step UP
	step UP
	step UP
	step_end

CeruleanBase3LanceArrestsArcherMovement:
	step LEFT
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step_end

CeruleanBase3FirstRangerLeavesMovement:
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step_end

ArcherBase3BeforeText:
	text "ARIANA has kept me"
	line "well informed"
	cont "about the brat who"
	cont "helped KURT rescue"
	cont "the SLOWPOKE in"
	cont "AZALEA TOWN."

	para "That was small fry"
	line "which was used to"
	cont "finish funding"
	cont "this operation."

	para "And now it's"
	line "complete!"

	para "When MEWTWO fled"
	line "to this cave to"
	cont "hide, we hunted it"
	cont "down and caught it"
	cont "with a single"
	cont "MASTER BALL."

	para "That's something"
	line "not GIOVANNI was"
	cont "able to do!"

	para "Then we snuck back"
	line "into the RUINS OF"
	cont "ALPH and captured"
	cont "several UNOWN to"
	cont "help us contain"
	cont "its immense power."

	para "Thanks for solving"
	line "all those puzzles!"

	para "And now you get to"
	line "face the ultimate"
	cont "#MON, and a"
	cont "thorn in our side"
	cont "will be removed"
	cont "permanently."

	para "For the glory of"
	line "TEAM ROCKET!"
	done

ArcherBase3WinText:
	text "You are such a"
	line "wretched child…"
	done

ArcherBase3AfterText:
	text "Even the power of"
	line "the UNOWN to focus"
	cont "MEWTWO's psychic"
	cont "energy was not"
	cont "enough?"
	done

ArcherCursesText:
	text "And of course, now"
	line "the worthless"
	cont "#MON have fled."

	para "The years, the"
	line "effort, all"
	cont "wasted!"

	para "No matter. TEAM"
	line "ROCKET survived"
	cont "when GIOVANNI"
	cont "vanished."

	para "We'll recover from"
	line "this as well."
	done

LanceIThinkNotText:
	text "LANCE:"

	para "I think not."
	done

LanceCapturesArcherText:
	text "ROCKET EXECUTIVE"
	line "ARCHER…"

	para "We've finally"
	line "caught up to you."

	para "First a WILD HUNT"
	line "and then trying"
	cont "to unleash MEWTWO?"

	para "You and ARIANA"
	line "will never see"
	cont "daylight again."
	done

FirstRangerThanksText:
	text "FIRST RANGER:"

	para "You have our "
	line "deepest thanks,"
	cont "<PLAY_G>."

	para "<RIVAL>, too. He"
	line "was the one who"
	cont "lead us here after"
	cont "you found the"
	cont "entrance."

	para "He's waiting for"
	line "you upstairs."
	done

CeruleanBase3_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  5, 10, CERULEAN_BASE_2, 2

	def_coord_events

	def_bg_events

	def_object_events
	object_event  5,  9, SPRITE_ROCKET_GIRL, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 1, TrainerExecutiveFAriana, EVENT_CLEARED_CERULEAN_CAVE
	object_event  6,  2, SPRITE_ROCKET, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_CLEARED_CERULEAN_CAVE
	object_event  5,  2, SPRITE_MONSTER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_CLEARED_CERULEAN_CAVE
	object_event  5,  8, SPRITE_LANCE, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_DISCOVERED_CERULEAN_CAVE
	object_event  6,  8, SPRITE_OFFICER, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BLACK, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_DISCOVERED_CERULEAN_CAVE
	object_event  3,  2, SPRITE_UNOWN_M, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_CLEARED_CERULEAN_CAVE
	object_event  5,  0, SPRITE_UNOWN_E, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_CLEARED_CERULEAN_CAVE
	object_event  8,  2, SPRITE_UNOWN_W, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_CLEARED_CERULEAN_CAVE

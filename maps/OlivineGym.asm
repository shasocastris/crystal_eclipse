    	object_const_def
	const OLIVINEGYM_JASMINE
	const OLIVINEGYM_GYM_GUIDE

OlivineGym_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_TILES, .OlivineGymLocked

.OlivineGymLocked
	checkevent EVENT_JASMINE_RETURNED_TO_GYM
	iffalse .UnlockGym
	checkevent EVENT_BEAT_JASMINE
	iftrue .UnlockGym
	changeblock 4, 15, $10 ; floor
	changeblock 5, 15, $10 ; floor
.UnlockGym
	endcallback

OlivineGymJasmineScript:
	faceplayer
	opentext
	readvar VAR_BADGES
	ifequal NUM_BADGES, JasmineRematchScript
	checkevent EVENT_BEAT_JASMINE
	iftrue .FightDone
	writetext Jasmine_SteelTypeIntro
	waitbutton
	closetext
	winlosstext Jasmine_BetterTrainer, JasmineLossText
	loadtrainer JASMINE, JASMINE1
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_JASMINE
	opentext
	writetext Text_ReceivedMineralBadge
	playsound SFX_GET_BADGE
	waitsfx
	setflag ENGINE_MINERALBADGE
	specialphonecall SPECIALCALL_WEIRDBROADCAST
	readvar VAR_BADGES
	setevent EVENT_RUINS_OF_ALPH_ROCKETS
.FightDone:
	changeblock 4, 15, $23 ; door
	changeblock 5, 15, $23 ; door
	checkevent EVENT_GOT_TM23_IRON_TAIL
	iftrue .GotIronTail
	writetext Jasmine_BadgeSpeech
	promptbutton
	verbosegiveitem TM_IRON_TAIL
	iffalse .NoRoomForIronTail
	setevent EVENT_GOT_TM23_IRON_TAIL
	writetext Jasmine_IronTailSpeech
	waitbutton
	closetext
	end

.GotIronTail:
	writetext Jasmine_GoodLuck
	waitbutton
.NoRoomForIronTail:
	closetext
	end

JasmineRematchScript:
	checkevent EVENT_JASMINE_REMATCH
	iftrue .RematchDone
	checkevent EVENT_GOT_THUNDERSTONE_FROM_BILLS_GRANDPA
	iffalse .JasmineReject
	writetext JasmineRematchText
	waitbutton
	closetext
	winlosstext JasmineRematchWinLossText, JasmineLossText
	loadtrainer JASMINE, JASMINE2
	startbattle
	reloadmapafterbattle
	setevent EVENT_JASMINE_REMATCH
.RematchDone
	opentext
	writetext BeatenJasmineAgainText
	waitbutton
	closetext
	end

.JasmineReject
	writetext JasmineRejectText
	waitbutton
	closetext
	end

OlivineGymGuideScript:
	faceplayer
	checkevent EVENT_BEAT_JASMINE
	iftrue .OlivineGymGuideWinScript
	checkevent EVENT_JASMINE_RETURNED_TO_GYM
	iffalse .OlivineGymGuidePreScript
	opentext
	writetext OlivineGymGuideText
	waitbutton
	closetext
	end

.OlivineGymGuideWinScript:
	opentext
	writetext OlivineGymGuideWinText
	waitbutton
	closetext
	end

.OlivineGymGuidePreScript:
	opentext
	writetext OlivineGymGuidePreText
	waitbutton
	closetext
	end

OlivineGymStatue:
	checkflag ENGINE_MINERALBADGE
	iftrue .Beaten
	jumpstd GymStatue1Script
.Beaten:
	gettrainername STRING_BUFFER_4, JASMINE, JASMINE1
	jumpstd GymStatue2Script

Jasmine_SteelTypeIntro:
	text "…Thank you for"
	line "your help at the"
	cont "LIGHTHOUSE…"

	para "But this is dif-"
	line "ferent. Please"

	para "allow me to intro-"
	line "duce myself."

	para "I am JASMINE, a"
	line "GYM LEADER. I use"
	cont "the steel-type."

	para "…Do you know about"
	line "the steel-type?"

	para "It's a type that"
	line "was only recently"
	cont "discovered."

	para "…Um… May I begin?"
	done

Jasmine_BetterTrainer:
	text "…You are a better"
	line "trainer than me,"

	para "in both skill and"
	line "kindness."

	para "In accordance with"
	line "LEAGUE rules, I"

	para "confer upon you"
	line "this BADGE."
	done

JasmineLossText:
	text "I'm sorry… you did"
	line "so well."
	done

Text_ReceivedMineralBadge:
	text "<PLAYER> received"
	line "MINERALBADGE."
	done

Jasmine_BadgeSpeech:
	text "…Um… Please take"
	line "this too…"
	done

Jasmine_IronTailSpeech:
	text "…You could use"
	line "that TM to teach"
	cont "IRON TAIL."
	done

Jasmine_GoodLuck:
	text "Um… I don't know"
	line "how to say this,"
	cont "but good luck…"
	done

JasmineRematchText:
	text "I've studied steel"
	line "#MON from all"
	cont "the world."

	para "My team has become"
	line "much stronger and"
	cont "more refined."
	done

JasmineRematchWinLossText:
	text "Your skill has"
	line "grown so much"
	cont "since we met."
	done

BeatenJasmineAgainText:
	text "You've won again."

	para "I can see why"
	line "Amphy was so fond"
	cont "of you."
	done

JasmineRejectText:
	text "…Um… I'd like to"
	line "have a rematch"
	cont "with you…"

	para "But first… I"
	line "heard there's an"
	cont "old man in KANTO"
	cont "who loves #MON"

	para "He lives near"
	line "CERULEAN CITY and"
	cont "collects stories"
	cont "about #MON…"

	para "…If you could"
	line "visit him and"
	cont "help with his"
	cont "collection…"

	para "I'd love to hear"
	line "about your"
	cont "journey there…"

	para "…Please come back"
	line "when you have…"
	done

OlivineGymGuideText:
	text "JASMINE uses the"
	line "newly discovered"
	cont "steel-type."

	para "And be watch out"
	line "for the SANDSTORM"
	cont "in the gym."
	done

OlivineGymGuideWinText:
	text "That was awesome."

	para "The steel-type,"
	line "huh?"

	para "That was a close"
	line "encounter of an"
	cont "unknown kind!"
	done

OlivineGymGuidePreText:
	text "JASMINE, the GYM"
	line "LEADER, is at the"
	cont "LIGHTHOUSE."

	para "She's been tending"
	line "to a sick #MON."

	para "A strong trainer"
	line "has to be compas-"
	cont "sionate."
	done

OlivineGym_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4, 15, OLIVINE_CITY, 2
	warp_event  5, 15, OLIVINE_CITY, 2

	def_coord_events

	def_bg_events
	bg_event  3, 13, BGEVENT_READ, OlivineGymStatue
	bg_event  6, 13, BGEVENT_READ, OlivineGymStatue

	def_object_events
	object_event  5,  3, SPRITE_JASMINE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, OlivineGymJasmineScript, EVENT_OLIVINE_GYM_JASMINE
	object_event  7, 13, SPRITE_GYM_GUIDE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, OlivineGymGuideScript, -1

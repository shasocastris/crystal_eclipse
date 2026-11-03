	object_const_def
	const VIRIDIANGYM_BLUE
	const VIRIDIANGYM_GYM_GUIDE

ViridianGym_MapScripts:
	def_scene_scripts

	def_callbacks

ViridianGymBlueScript:
	faceplayer
	opentext
	readvar VAR_BADGES
	ifequal NUM_BADGES, BlueRematchScript
	checkflag ENGINE_EARTHBADGE
	iftrue .FightDone
	writetext LeaderBlueBeforeText
	waitbutton
	closetext
	winlosstext LeaderBlueWinText, LeaderBlueLossText
	loadtrainer BLUE, BLUE1
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_BLUE
	opentext
	writetext Text_ReceivedEarthBadge
	playsound SFX_GET_BADGE
	waitsfx
	setflag ENGINE_EARTHBADGE
	writetext LeaderBlueAfterText
	waitbutton
	closetext
	end

.FightDone:
	writetext LeaderBlueEpilogueText
	waitbutton
	closetext
	end

BlueRematchScript:
    checkevent EVENT_BLUE_REMATCH
    iftrue .RematchDone
    readvar VAR_DEXCAUGHT
    ifless 151, .BlueReject
    writetext BlueRematchText
    waitbutton
    closetext
    winlosstext BlueRematchWinLossText, LeaderBlueLossText
    loadtrainer BLUE, BLUE2
    startbattle
    reloadmapafterbattle
    setevent EVENT_BLUE_REMATCH
.RematchDone
    opentext
    writetext BeatenBlueAgainText
    waitbutton
    closetext
    end

.BlueReject
    writetext BlueRejectText
    waitbutton
    closetext
    end

ViridianGymGuideScript:
	faceplayer
	opentext
	checkevent EVENT_BEAT_BLUE
	iftrue .ViridianGymGuideWinScript
	writetext ViridianGymGuideText
	waitbutton
	closetext
	end

.ViridianGymGuideWinScript:
	writetext ViridianGymGuideWinText
	waitbutton
	closetext
	end

ViridianGymStatue:
	checkflag ENGINE_EARTHBADGE
	iftrue .Beaten
	jumpstd GymStatue1Script

.Beaten:
	gettrainername STRING_BUFFER_4, BLUE, BLUE1
	jumpstd GymStatue2Script

LeaderBlueBeforeText:
	text "BLUE: Yo! Finally"
	line "got here, huh?"

	para "I wasn't in the"
	line "mood at CINNABAR,"

	para "but now I'm ready"
	line "to battle you."

	para "…"

	para "You're telling me"
	line "you conquered all"
	cont "the GYMS in JOHTO?"

	para "Heh! JOHTO's GYMS"
	line "must be pretty"
	cont "pathetic then."

	para "Hey, don't worry"
	line "about it."

	para "I'll know if you"
	line "are good or not by"

	para "battling you right"
	line "now."

	para "Ready, JOHTO"
	line "CHAMP?"
	done

LeaderBlueWinText:
	text "BLUE: What?"

	para "How the heck did I"
	line "lose to you?"

	para "…"

	para "Tch, all right…"
	line "Here, take this--"
	cont "it's EARTHBADGE."
	done

LeaderBlueLossText:
	text "You're not ready"
	line "for this."
	done

Text_ReceivedEarthBadge:
	text "<PLAYER> received"
	line "EARTHBADGE."
	done

LeaderBlueAfterText:
	text "BLUE: …"

	para "All right, I was"
	line "wrong. You're the"

	para "real deal. You are"
	line "a good trainer."

	para "But I'm going to"
	line "beat you someday."

	para "Don't you forget"
	line "it!"
	done

LeaderBlueEpilogueText:
	text "BLUE: Listen, you."

	para "You'd better not"
	line "lose until I beat"
	cont "you. Got it?"
	done

BlueRematchText:
	text "What?! You've"
	line "caught 151 #MON"
	cont "or more?"

	para "That's… actually"
	line "pretty impressive."

	para "I have to admit,"
	line "not many trainers"
	cont "have that kind of"
	cont "dedication."

	para "You've really"
	line "traveled far and"
	cont "wide, haven't you?"

	para "Alright then!"
	line "You've earned this"
	cont "battle!"

	para "Let me show you"
	line "what the former"
	cont "CHAMPION can do"
	cont "when he's serious!"

	para "I won't hold back"
	line "this time!"
	done

BlueRematchWinLossText:
	text "What?! How did"
	line "you…?"

	para "Man… you really"
	line "have grown as a"
	cont "trainer."

	para "I guess catching"
	line "all those #MON"
	cont "really did teach"
	cont "you something."

	para "You've got what it"
	line "takes to be a true"
	cont "#MON master."
	done

BeatenBlueAgainText:
	text "I can't believe"
	line "you beat me again…"

	para "But I guess that's"
	line "what happens when"
	cont "you dedicate"
	cont "yourself like that."

	para "151 #MON is no"
	line "small feat."

	para "You've really"
	line "proven yourself"
	cont "as a trainer."

	para "Gramps would be"
	line "proud to see how"
	cont "far you've come."

	para "Keep it up! Maybe"
	line "one day you'll"
	cont "surpass even the"
	cont "greatest masters!"
	done

BlueRejectText:
	text "Oh, it's you."
	line "Back for another"
	cont "battle, huh?"

	para "Heh… you think"
	line "you're ready for"
	cont "my full power?"

	para "I've been training"
	line "with all kinds of"
	cont "#MON since"
	cont "becoming CHAMPION."

	para "My gramps always"
	line "said the key to"
	cont "being the best…"

	para "Is understanding"
	line "every species of"
	cont "#MON."

	para "Come back when"
	line "you've caught at"
	cont "least 151 #MON."

	para "Only then will you"
	line "have the knowledge"
	cont "to face me!"
	done

ViridianGymGuideText:
	text "Yo, CHAMP in"
	line "making!"

	para "How's it going?"
	line "Looks like you're"
	cont "on a roll."

	para "The GYM LEADER is"
	line "a guy who battled"

	para "the CHAMPION three"
	line "years ago."

	para "He's no pushover."

	para "Give it everything"
	line "you've got!"
	done

ViridianGymGuideWinText:
	text "Man, you are truly"
	line "tough…"

	para "That was a heck of"
	line "an inspirational"

	para "battle. It brought"
	line "tears to my eyes."
	done

ViridianGym_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4, 17, VIRIDIAN_CITY, 1
	warp_event  5, 17, VIRIDIAN_CITY, 1

	def_coord_events

	def_bg_events
	bg_event  3, 13, BGEVENT_READ, ViridianGymStatue
	bg_event  6, 13, BGEVENT_READ, ViridianGymStatue

	def_object_events
	object_event  5,  3, SPRITE_BLUE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ViridianGymBlueScript, EVENT_VIRIDIAN_GYM_BLUE
	object_event  7, 13, SPRITE_GYM_GUIDE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ViridianGymGuideScript, EVENT_VIRIDIAN_GYM_BLUE

	object_const_def
	const SEAFOAMGYM_BLAINE
	const SEAFOAMGYM_GYM_GUIDE

SeafoamGym_MapScripts:
	def_scene_scripts
	scene_script SeafoamGymNoopScene ; unusable

	def_callbacks

SeafoamGymNoopScene:
	end

SeafoamGymBlaineScript:
	faceplayer
	opentext
	readvar VAR_BADGES
	ifequal NUM_BADGES, BlaineRematchScript
	checkflag ENGINE_VOLCANOBADGE
	iftrue .FightDone
	writetext BlaineIntroText
	waitbutton
	closetext
	winlosstext BlaineWinLossText, BlaineLossText
	loadtrainer BLAINE, BLAINE1
	startbattle
	iftrue .ReturnAfterBattle
	appear SEAFOAMGYM_GYM_GUIDE
.ReturnAfterBattle:
	reloadmapafterbattle
	setevent EVENT_BEAT_BLAINE
	opentext
	writetext ReceivedVolcanoBadgeText
	playsound SFX_GET_BADGE
	waitsfx
	setflag ENGINE_VOLCANOBADGE
	writetext BlaineAfterBattleText
	waitbutton
	closetext
	end

.FightDone:
	writetext BlaineFightDoneText
	waitbutton
	closetext
	end

BlaineRematchScript:
    checkevent EVENT_BLAINE_REMATCH
    iftrue .RematchDone
    checkevent EVENT_FOUGHT_MEWTWO
    iffalse .BlaineReject
    writetext BlaineRematchText
    waitbutton
    closetext
    winlosstext BlaineRematchWinLossText, BlaineLossText
    loadtrainer BLAINE, BLAINE2
    startbattle
    reloadmapafterbattle
    setevent EVENT_BLAINE_REMATCH
.RematchDone
    opentext
    writetext BeatenBlaineAgainText
    waitbutton
    closetext
    end

.BlaineReject
    writetext BlaineRejectText
    waitbutton
    closetext
    end

SeafoamGymGuideScript:
	faceplayer
	opentext
	checkevent EVENT_TALKED_TO_SEAFOAM_GYM_GUIDE_ONCE
	iftrue .TalkedToSeafoamGymGuideScript
	writetext SeafoamGymGuideWinText
	waitbutton
	closetext
	setevent EVENT_TALKED_TO_SEAFOAM_GYM_GUIDE_ONCE
	end

.TalkedToSeafoamGymGuideScript:
	writetext SeafoamGymGuideWinText2
	waitbutton
	closetext
	end

BlaineIntroText:
	text "BLAINE: Waaah!"

	para "My GYM in CINNABAR"
	line "burned down."

	para "My fire-breathing"
	line "#MON and I are"

	para "homeless because"
	line "of the volcano."

	para "Waaah!"

	para "But I'm back in"
	line "business as a GYM"

	para "LEADER here in"
	line "this cave."

	para "If you can beat"
	line "me, I'll give you"
	cont "a BADGE."

	para "Ha! You'd better"
	line "have BURN HEAL!"
	done

BlaineWinLossText:
	text "BLAINE: Awesome."
	line "I've burned out…"

	para "You've earned"
	line "VOLCANOBADGE!"
	done

BlaineLossText:
	text "Ashes to ashes,"
	line "kid."
	done

ReceivedVolcanoBadgeText:
	text "<PLAYER> received"
	line "VOLCANOBADGE."
	done

BlaineAfterBattleText:
	text "BLAINE: I did lose"
	line "this time, but I'm"

	para "going to win the"
	line "next time."

	para "When I rebuild my"
	line "CINNABAR GYM,"

	para "we'll have to have"
	line "a rematch."
	done

BlaineFightDoneText:
	text "BLAINE: My fire"
	line "#MON will be"

	para "even stronger."
	line "Just you watch!"
	done

BlaineRematchText:
	text "So… you've faced"
	line "MEWTWO."

	para "Then you've seen"
	line "what my research"
	cont "helped create…"

	para "A #MON born of"
	line "pain and anger…"
	cont "suffering from our"
	cont "mistakes."

	para "I've carried this"
	line "guilt for years…"
	cont "The shame burns"
	cont "hotter than any"
	cont "flame."

	para "But if you could"
	line "face that tortured"
	cont "soul…"

	para "Then perhaps you"
	line "can help me find"
	cont "redemption through"
	cont "battle."

	para "Let my fire burn"
	line "away some of this"
	cont "regret!"
	done

BlaineRematchWinLossText:
	text "Your strength"
	line "gives me hope."
	done

BeatenBlaineAgainText:
	text "MEWTWO may have"
	line "been born from"
	cont "our arrogance…"

	para "But trainers like"
	line "you prove that"
	cont "redemption is"
	cont "possible."

	para "Thank you for"
	line "helping an old"
	cont "scientist find"
	cont "some peace."
	done

BlaineRejectText:
	text "You want another"
	line "battle? I admire"
	cont "your passion!"

	para "But first… there's"
	line "something I must"
	cont "know."

	para "Years ago, I was"
	line "part of a terrible"
	cont "experiment…"

	para "We created a"
	line "#MON of"
	cont "unimaginable"
	cont "power…"

	para "MEWTWO… born from"
	line "our scientific"
	cont "arrogance."

	para "If you've faced"
	line "that tortured"
	cont "creation…"

	para "Then you've seen"
	line "the consequences"
	cont "of playing god."

	para "Return when you've"
	line "encountered"
	cont "MEWTWO."
	done

SeafoamGymGuideWinText:
	text "Yo!"

	para "… Huh? It's over"
	line "already?"

	para "Sorry, sorry!"

	para "CINNABAR GYM was"
	line "gone, so I didn't"

	para "know where to find"
	line "you."

	para "But, hey, you're"
	line "plenty strong even"

	para "without my advice."
	line "I knew you'd win!"
	done

SeafoamGymGuideWinText2:
	text "A #MON GYM can"
	line "be anywhere as"

	para "long as the GYM"
	line "LEADER is there."

	para "There's no need"
	line "for a building."
	done

SeafoamGym_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  5,  5, ROUTE_20, 1

	def_coord_events

	def_bg_events

	def_object_events
	object_event  5,  2, SPRITE_BLAINE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_SCRIPT, 0, SeafoamGymBlaineScript, -1
	object_event  6,  5, SPRITE_GYM_GUIDE, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, SeafoamGymGuideScript, EVENT_SEAFOAM_GYM_GYM_GUIDE

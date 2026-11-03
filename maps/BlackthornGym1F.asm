	object_const_def
	const BLACKTHORNGYM1F_CLAIR
	const BLACKTHORNGYM1F_COOLTRAINER_M1
	const BLACKTHORNGYM1F_COOLTRAINER_M2
	const BLACKTHORNGYM1F_COOLTRAINER_F
	const BLACKTHORNGYM1F_GYM_GUIDE

BlackthornGym1F_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_TILES, BlackthornGym1FBouldersCallback

BlackthornGym1FBouldersCallback:
	checkevent EVENT_BEAT_CLAIR
	iftrue .UnlockGym
	changeblock 4, 17, $2D ; floor
	changeblock 5, 17, $2D ; floor
.UnlockGym
	checkevent EVENT_BOULDER_IN_BLACKTHORN_GYM_1
	iffalse .skip1
	changeblock 8, 2, $3b ; fallen boulder 3
.skip1
	checkevent EVENT_BOULDER_IN_BLACKTHORN_GYM_2
	iffalse .skip2
	changeblock 4, 8, $3a ; fallen boulder 1
.skip2
	checkevent EVENT_BOULDER_IN_BLACKTHORN_GYM_3
	iffalse .skip3
	changeblock 8, 6, $3b ; fallen boulder 2
.skip3
	endcallback

BlackthornGymClairScript:
	faceplayer
	opentext
	readvar VAR_BADGES
	ifequal NUM_BADGES, ClairRematchScript
	checkflag ENGINE_RISINGBADGE
	iftrue .AlreadyGotBadge
	checkevent EVENT_BEAT_CLAIR
	iftrue .FightDone
	writetext ClairIntroText
	waitbutton
	closetext
	winlosstext ClairWinText, ClairLossText
	loadtrainer CLAIR, CLAIR1
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_CLAIR
	opentext
	writetext ClairText_GoToDragonsDen
	waitbutton
	closetext
	changeblock 4, 17, $1C ; door
	changeblock 5, 17, $1C ; door
	setevent EVENT_BEAT_COOLTRAINERM_PAUL
	setevent EVENT_BEAT_COOLTRAINERM_CODY
	setevent EVENT_BEAT_COOLTRAINERM_MIKE
	setevent EVENT_BEAT_COOLTRAINERF_FRAN
	setevent EVENT_BEAT_COOLTRAINERF_LOLA
	clearevent EVENT_MAHOGANY_MART_OWNERS
	setevent EVENT_BLACKTHORN_CITY_GRAMPS_BLOCKS_DRAGONS_DEN
	clearevent EVENT_BLACKTHORN_CITY_GRAMPS_NOT_BLOCKING_DRAGONS_DEN
	end

.FightDone:
	writetext ClairText_TooMuchToExpect
	waitbutton
	closetext
	end

.AlreadyGotBadge:
	checkevent EVENT_GOT_TM24_DRAGONBREATH
	iftrue .GotTM24
	writetext BlackthornGymClairText_YouKeptMeWaiting
	promptbutton
	giveitem TM_DRAGONBREATH
	iffalse .BagFull
	getitemname STRING_BUFFER_3, TM_DRAGONBREATH
	writetext BlackthornGymText_ReceivedTM24
	playsound SFX_ITEM
	waitsfx
	itemnotify
	setevent EVENT_GOT_TM24_DRAGONBREATH
	writetext BlackthornGymClairText_DescribeTM24
	promptbutton
	sjump .GotTM24

.BagFull:
	writetext BlackthornGymClairText_BagFull
	waitbutton
	closetext
	end

.GotTM24:
	writetext BlackthornGymClairText_League
	waitbutton
	closetext
	end

ClairRematchScript:
	checkevent EVENT_CLAIR_REMATCH
	iftrue .RematchDone
	checkevent EVENT_GOT_DRATINI
	iffalse .ClairReject
	loadmonindex 1, DRAGONITE
	special FindPartyMonThatSpeciesYourTrainerID
	iffalse .ClairRejectNoDragonite
	writetext ClairRematchText
	waitbutton
	closetext
	winlosstext ClairRematchWinLossText, ClairLossText
	loadtrainer CLAIR, CLAIR2
	startbattle
	reloadmapafterbattle
	setevent EVENT_CLAIR_REMATCH
.RematchDone
	opentext
	writetext BeatenClairAgainText
	waitbutton
	closetext
	end

.ClairReject
	writetext ClairRejectText
	waitbutton
	closetext
	end

.ClairRejectNoDragonite
	writetext ClairRejectNoDragoniteText
	waitbutton
	closetext
	end

TrainerCooltrainermPaul:
	trainer COOLTRAINERM, PAUL, EVENT_BEAT_COOLTRAINERM_PAUL, CooltrainermPaulSeenText, CooltrainermPaulBeatenText, 0, .Script

.Script:
	opentext
	writetext CooltrainermPaulAfterBattleText
	waitbutton
	closetext
	end

TrainerCooltrainermMike:
	trainer COOLTRAINERM, MIKE, EVENT_BEAT_COOLTRAINERM_MIKE, CooltrainermMikeSeenText, CooltrainermMikeBeatenText, 0, .Script

.Script:
	opentext
	writetext CooltrainermMikeAfterBattleText
	waitbutton
	closetext
	end

TrainerCooltrainerfLola:
	trainer COOLTRAINERF, LOLA, EVENT_BEAT_COOLTRAINERF_LOLA, CooltrainerfLolaSeenText, CooltrainerfLolaBeatenText, 0, .Script

.Script:
	opentext
	writetext CooltrainerfLolaAfterBattleText
	waitbutton
	closetext
	end

BlackthornGymGuideScript:
	faceplayer
	opentext
	checkevent EVENT_BEAT_CLAIR
	iftrue .BlackthornGymGuideWinScript
	writetext BlackthornGymGuideText
	waitbutton
	closetext
	end

.BlackthornGymGuideWinScript:
	writetext BlackthornGymGuideWinText
	waitbutton
	closetext
	end

BlackthornGymStatue:
	checkflag ENGINE_RISINGBADGE
	iftrue .Beaten
	jumpstd GymStatue1Script
.Beaten:
	gettrainername STRING_BUFFER_4, CLAIR, CLAIR1
	jumpstd GymStatue2Script

ClairIntroText:
	text "I am CLAIR."

	para "The world's best"
	line "dragon master."

	para "I can hold my own"
	line "against even the"

	para "#MON LEAGUE's"
	line "ELITE FOUR."

	para "Do you still want"
	line "to take me on?"

	para "…Fine."
	line "Let's do it!"

	para "As a GYM LEADER,"
	line "I will use my full"

	para "power against any"
	line "opponent!"
	done

ClairWinText:
	text "I lost?"

	para "I don't believe"
	line "it. There must be"
	cont "some mistake…"
	done

ClairLossText:
	text "Still not worthy"
	line "of dragons."
	done

ClairText_GoToDragonsDen:
	text "I won't admit"
	line "this."

	para "I may have lost,"
	line "but you're still"

	para "not ready for the"
	line "#MON LEAGUE."

	para "I know. You should"
	line "take the dragon"
	cont "user challenge."

	para "Behind this GYM is"
	line "a place called"
	cont "DRAGON'S DEN."

	para "There is a small"
	line "shrine at its"

	para "center."
	line "Go there."

	para "If you can prove"
	line "that you've lost"

	para "your lazy ideals,"
	line "I will recognize"

	para "you as a trainer"
	line "worthy of a GYM"
	cont "BADGE!"
	done

ClairText_TooMuchToExpect:
	text "What's the matter?"

	para "Is it too much to"
	line "expect of you?"
	done

BlackthornGymClairText_YouKeptMeWaiting:
	text "You've kept me"
	line "waiting!"

	para "Here! Take this!"
	done

BlackthornGymText_ReceivedTM24:
	text "<PLAYER> received"
	line "TM24."
	done

BlackthornGymClairText_DescribeTM24:
	text "That contains"
	line "DRAGONBREATH."

	para "No, it doesn't"
	line "have anything to"
	cont "do with my breath."

	para "If you don't want"
	line "it, you don't have"
	cont "to take it."
	done

BlackthornGymClairText_BagFull:
	text "What is this? You"
	line "don't have room?"
	done

BlackthornGymClairText_League:
	text "What's the matter?"

	para "Aren't you headed"
	line "to the #MON"
	cont "LEAGUE?"

	para "Don't you know"
	line "where it is?"

	para "From here, go to"
	line "NEW BARK TOWN."

	para "Then SURF east."
	line "The route there is"
	cont "very tough."

	para "Don't you dare"
	line "lose at the #-"
	cont "MON LEAGUE!"

	para "If you do, I'll"
	line "feel even worse"

	para "about having lost"
	line "to you!"

	para "Give it every-"
	line "thing you've got."
	done

ClairRematchText:
	text "You think your"
	line "training is enough"
	cont "to face me again?"

	para "I won't hold back!"
	done

ClairRematchWinLossText:
	text "Your mastery is"
	line "undeniable. Even"
	cont "dragons bow to you."
	done

BeatenClairAgainText:
	text "Magnificent! You"
	line "truly are a master"
	cont "trainer!"

	para "I see why Lance"
	line "speaks so highly"
	cont "of you."
	done

ClairRejectText:
	text "So, you think"
	line "you're ready for"
	cont "another battle?"

	para "I won't accept"
	line "just anyone as a"
	cont "worthy opponent."

	para "Have you received"
	line "the sacred DRATINI"
	cont "from the DRAGON"
	cont "SHRINE?"

	para "Only those who"
	line "have proven their"
	cont "worth to the"
	cont "dragon elders…"

	para "And earned the"
	line "trust of a dragon"
	cont "#MON…"

	para "Are qualified to"
	line "face me at my"
	cont "full strength."

	para "Return when you"
	line "have that DRATINI."
	cont "Then we'll see if"
	cont "you're worthy."
	done

ClairRejectNoDragoniteText:
	text "I see you have the"
	line "DRATINI from the"
	cont "DRAGON SHRINE."

	para "But have you truly"
	line "bonded with it?"

	para "A dragon master"
	line "must raise their"
	cont "dragon to its"
	cont "full potential."

	para "Return when your"
	line "DRATINI has become"
	cont "a mighty"
	cont "DRAGONITE."

	para "Only then will I"
	line "recognize you as"
	cont "a true dragon"
	cont "trainer."
	done

CooltrainermPaulSeenText:
	text "Your first battle"
	line "against dragons?"

	para "I'll show you how"
	line "tough they are!"
	done

CooltrainermPaulBeatenText:
	text "My dragon #MON"
	line "lost?"
	done

CooltrainermPaulAfterBattleText:
	text "LANCE told you"
	line "that he'd like to"

	para "see you again?"
	line "Not a chance!"
	done

CooltrainermMikeSeenText:
	text "My chance of"
	line "losing? Not even"
	cont "one percent!"
	done

CooltrainermMikeBeatenText:
	text "That's odd."
	done

CooltrainermMikeAfterBattleText:
	text "I know my short-"
	line "comings now."

	para "Thanks for showing"
	line "me!"
	done

CooltrainerfLolaSeenText:
	text "Dragons are sacred"
	line "#MON."

	para "They are full of"
	line "life energy."

	para "If you're not"
	line "serious, you won't"

	para "be able to beat"
	line "them."
	done

CooltrainerfLolaBeatenText:
	text "Way to go!"
	done

CooltrainerfLolaAfterBattleText:
	text "Dragons are weak"
	line "against dragon-"
	cont "type moves."
	done

BlackthornGymGuideText:
	text "Yo! CHAMP in"
	line "making!"

	para "It's been a long"
	line "journey, but we"

	para "are almost done!"
	line "Count on me!"

	para "CLAIR uses the"
	line "mythical and sac-"
	cont "red dragon-type"
	cont "#MON."

	para "You can't damage"
	line "them very easily."

	para "But you know,"
	line "they're supposed"

	para "to be weak against"
	line "ice-type moves."
	done

BlackthornGymGuideWinText:
	text "You were great to"
	line "beat CLAIR!"

	para "All that's left is"
	line "the #MON LEAGUE"
	cont "challenge."

	para "You're on the way"
	line "to becoming the"
	cont "#MON CHAMPION!"
	done

BlackthornGym1F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4, 17, BLACKTHORN_CITY, 1
	warp_event  5, 17, BLACKTHORN_CITY, 1
	warp_event  1,  7, BLACKTHORN_GYM_2F, 1
	warp_event  7,  9, BLACKTHORN_GYM_2F, 2
	warp_event  2,  6, BLACKTHORN_GYM_2F, 3
	warp_event  7,  7, BLACKTHORN_GYM_2F, 4
	warp_event  7,  6, BLACKTHORN_GYM_2F, 5

	def_coord_events

	def_bg_events
	bg_event  3, 15, BGEVENT_READ, BlackthornGymStatue
	bg_event  6, 15, BGEVENT_READ, BlackthornGymStatue

	def_object_events
	object_event  5,  3, SPRITE_CLAIR, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, BlackthornGymClairScript, -1
	object_event  6,  6, SPRITE_COOLTRAINER_M, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 3, TrainerCooltrainermMike, -1
	object_event  1, 14, SPRITE_COOLTRAINER_M, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 3, TrainerCooltrainermPaul, -1
	object_event  9,  2, SPRITE_COOLTRAINER_F, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 1, TrainerCooltrainerfLola, -1
	object_event  7, 15, SPRITE_GYM_GUIDE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, BlackthornGymGuideScript, -1

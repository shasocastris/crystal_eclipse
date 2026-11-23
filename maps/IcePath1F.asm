	object_const_def
	const ICEPATH1F_POKE_BALL1
	const ICEPATH1F_POKE_BALL2
	const ICEPATH1F_POKE_BALL3
	const ICEPATH1F_RIVAL
	const ICEPATH1F_SKIER
	const ICEPATH1F_COOLTRAINER_F

IcePath1F_MapScripts:
	def_scene_scripts
	scene_script IcePath1FNoop1Scene, SCENE_ICEPATH1F_RIVAL
	scene_script IcePath1FNoop2Scene, SCENE_ICEPATH1F_NOOP

	def_callbacks

IcePath1FNoop1Scene:
	end

IcePath1FNoop2Scene:
	end

IcePath1F_RivalFight:
	turnobject PLAYER, UP
	showemote EMOTE_SHOCK, PLAYER, 15
	special FadeOutMusic
	pause 15
	stowfollowerif UP
	appear ICEPATH1F_RIVAL
	waitsfx
	applymovement ICEPATH1F_RIVAL, IcePath1FRivalApproachMovement
	playsound SFX_EXIT_BUILDING
	opentext
	writetext IcePath1FRivalBeforeText
	waitbutton
	closetext

	setevent EVENT_ICE_PATH_1F_RIVAL
	checkevent EVENT_GOT_TOTODILE_FROM_ELM
	iftrue .Totodile
	checkevent EVENT_GOT_CHIKORITA_FROM_ELM
	iftrue .Chikorita
	winlosstext IcePath1FRivalWinText, IcePath1FRivalLossText
	setlasttalked ICEPATH1F_RIVAL
	loadtrainer RIVAL1, RIVAL1_4_TOTODILE
	startbattle
	dontrestartmapmusic
	reloadmapafterbattle
	sjump .IcePath1F_FinishRivalBattle

.Totodile:
	winlosstext IcePath1FRivalWinText, IcePath1FRivalLossText
	setlasttalked ICEPATH1F_RIVAL
	loadtrainer RIVAL1, RIVAL1_4_CHIKORITA
	startbattle
	dontrestartmapmusic
	reloadmapafterbattle
	sjump .IcePath1F_FinishRivalBattle

.Chikorita:
	winlosstext IcePath1FRivalWinText, IcePath1FRivalLossText
	setlasttalked ICEPATH1F_RIVAL
	loadtrainer RIVAL1, RIVAL1_4_CYNDAQUIL
	startbattle
	dontrestartmapmusic
	reloadmapafterbattle
; fallthrough
.IcePath1F_FinishRivalBattle:
	playmusic MUSIC_RIVAL_AFTER
	opentext
	writetext IcePath1FRivalAfterText
	waitbutton
	closetext

	applymovement ICEPATH1F_RIVAL, IcePath1FRivalRetreatMovement
	disappear ICEPATH1F_RIVAL
	setscene SCENE_ICEPATH1F_NOOP
	playmapmusic
	appearfolloweronestep
	end

IcePath1FRivalApproachMovement:
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step_end

IcePath1FRivalRetreatMovement:
	step UP
	step UP
	step UP
	step UP
	step_end

TrainerSkierNoelle:
	trainer SKIER, NOELLE, EVENT_BEAT_SKIER_NOELLE, SkierNoelleSeenText, SkierNoelleBeatenText, 0, .Script

.Script:
	opentext
	writetext SkierNoelleAfterBattleText
	waitbutton
	closetext
	end

TrainerCooltrainerfNina:
	trainer COOLTRAINERF, NINA, EVENT_BEAT_COOLTRAINERF_NINA, CooltrainerfNinaSeenText, CooltrainerfNinaBeatenText, 0, .Script

.Script:
	opentext
	writetext CooltrainerfNinaAfterBattleText
	waitbutton
	closetext
	end


IcePath1FHMWaterfall:
	itemball HM_WATERFALL

IcePath1FPPUp:
	itemball PP_UP

IcePath1FIcyRock:
	itemball ICY_ROCK

IcePath1FRevive:
	itemball REVIVE

IcePath1FRivalBeforeText:
	text "<PLAY_G>!"

	para "I don't believe"
	line "that you handled"
	cont "TEAM ROCKET."

	para "And the rumors say"
	line "you met SUICUNE?"

	para "How? My #MON"
	line "are stronger"
	cont "than yours."

	para "I should be the"
	line "one to encounter a"
	cont "legendary #MON."

	para "I'll set things"
	line "right with this"
	cont "battle!"
	done

IcePath1FRivalWinText:
	text "…Why…"
	line "Why do I lose?"

	para "I've assembled the"
	line "toughest #MON."

	para "I didn't ease up."

	para "So why do I lose?"
	done

IcePath1FRivalAfterText:
	text "…Why do I keep"
	line "losing?"

	para "I have the best"
	line "#MON. I train"
	cont "them harder than"
	cont "anyone."

	para "So why…?"

	para "That LANCE guy"
	line "said something"
	cont "about how I treat"
	cont "my #MON."

	para "But I give them"
	line "the best training,"
	cont "the best items…"

	para "Love…"

	para "Trust…"

	para "Are those really"
	line "more important"
	cont "than raw power?"

	para "I… I need to"
	line "think about this."

	para "But I won't give"
	line "up my dream. I'll"
	cont "find the answer"
	cont "somehow."
	done

IcePath1FRivalLossText:
	text "Humph. This is my"
	line "real power, wimp."

	para "There's no way you"
	line "beat TEAM ROCKET."

	para "And I'm going to"
	line "grind that LANCE"
	cont "under my heels."
	done

SkierNoelleSeenText:
	text "The snow here is"
	line "perfect for a run!"

	para "Let's see if your"
	line "#MON can keep"
	cont "up!"
	done

SkierNoelleBeatenText:
	text "Whoa, you really"
	line "shredded me!"
	done

SkierNoelleAfterBattleText:
	text "ICE PATH is the"
	line "best slope around."

	para "It goes all the"
	line "way to BLACKTHORN!"
	done

CooltrainerfNinaSeenText:
	text "I'm training my"
	line "dragons to endure"
	cont "the bitter cold."

	para "Care to test them?"
	done

CooltrainerfNinaBeatenText:
	text "The cold got to"
	line "them after all…"
	done

CooltrainerfNinaAfterBattleText:
	text "CLAIR says a true"
	line "dragon master"

	para "overcomes every"
	line "weakness."

	para "That's why I train"
	line "here in the ice."
	done

IcePath1F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4, 19, ROUTE_44, 1
	warp_event 36, 27, BLACKTHORN_CITY, 7
	warp_event 37,  5, ICE_PATH_B1F, 1
	warp_event 37, 13, ICE_PATH_B1F, 7

	def_coord_events
	coord_event 36, 27, SCENE_ICEPATH1F_RIVAL, IcePath1F_RivalFight

	def_bg_events

	def_object_events
	object_event 31,  7, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, IcePath1FHMWaterfall, EVENT_GOT_HM07_WATERFALL
	object_event 32, 23, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, IcePath1FPPUp, EVENT_ICE_PATH_1F_PP_UP
	object_event 35,  9, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, IcePath1FIcyRock, EVENT_ICE_PATH_1F_ICY_ROCK
	object_event 36, 22, SPRITE_RIVAL, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_ICE_PATH_1F_RIVAL
	object_event 20,  2, SPRITE_BEAUTY, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 3, TrainerSkierNoelle, -1
	object_event 24, 19, SPRITE_COOLTRAINER_F, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 4, TrainerCooltrainerfNina, -1
	object_event 17, 16, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, IcePath1FRevive, EVENT_GOT_HM07_WATERFALL

	object_const_def
	const MOUNTMOON_RIVAL
	const MOUNTMOON_POKE_BALL1
	const MOUNTMOON_POKE_BALL2
	const MOUNTMOON_POKE_BALL3
	const MOUNTMOON_POKE_BALL4
	const MOUNTMOON_COOLTRAINERF
	const MOUNTMOON_COOLTRAINERM
	const MOUNTMOON_HIKER_1
	const MOUNTMOON_SUPER_NERD_1
	const MOUNTMOON_SUPER_NERD_2
	const MOUNTMOON_HIKER_2

MountMoon_MapScripts:
	def_scene_scripts
	scene_script MountMoonRivalEncounterScene, SCENE_MOUNTMOON_RIVAL_BATTLE
	scene_script MountMoonNoopScene,		   SCENE_MOUNTMOON_NOOP

	def_callbacks

MountMoonRivalEncounterScene:
	sdefer MountMoonRivalBattleScript
	end

MountMoonNoopScene:
	end

MountMoonRivalBattleScript:
	showemote EMOTE_SHOCK, PLAYER, 15
	special FadeOutMusic
	pause 15
	applymovement MOUNTMOON_RIVAL, MountMoonRivalMovementBefore
	playmusic MUSIC_RIVAL_ENCOUNTER
	opentext
	writetext MountMoonRivalTextBefore
	waitbutton
	closetext
	checkevent EVENT_GOT_TOTODILE_FROM_ELM
	iftrue .Totodile
	checkevent EVENT_GOT_CHIKORITA_FROM_ELM
	iftrue .Chikorita
	winlosstext MountMoonRivalTextWin, MountMoonRivalTextLoss
	setlasttalked MOUNTMOON_RIVAL
	loadtrainer RIVAL2, RIVAL2_1_TOTODILE
	startbattle
	dontrestartmapmusic
	reloadmapafterbattle
	sjump .FinishBattle

.Totodile:
	winlosstext MountMoonRivalTextWin, MountMoonRivalTextLoss
	setlasttalked MOUNTMOON_RIVAL
	loadtrainer RIVAL2, RIVAL2_1_CHIKORITA
	startbattle
	dontrestartmapmusic
	reloadmapafterbattle
	sjump .FinishBattle

.Chikorita:
	winlosstext MountMoonRivalTextWin, MountMoonRivalTextLoss
	setlasttalked MOUNTMOON_RIVAL
	loadtrainer RIVAL2, RIVAL2_1_CYNDAQUIL
	startbattle
	dontrestartmapmusic
	reloadmapafterbattle
; fallthrough
.FinishBattle:
	playmusic MUSIC_RIVAL_AFTER
	opentext
	writetext MountMoonRivalTextAfter
	waitbutton
	closetext
    special FadeOutToWhite
	special LoadMapPalettes
	playsound SFX_FULL_HEAL
	special HealParty
	special FadeInPalettes_EnableDynNoApply
	applymovement MOUNTMOON_RIVAL, MountMoonRivalMovementAfter
	disappear MOUNTMOON_RIVAL
	setscene SCENE_MOUNTMOON_NOOP
	setevent EVENT_BEAT_RIVAL_IN_MT_MOON
	playmapmusic
	end

MountMoonRivalMovementBefore:
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step_end

MountMoonRivalMovementAfter:
	step UP
	step UP
	step UP
	step UP
	step_end

MountMoonRivalTextBefore:
	text "<……> <……> <……>"

	para "It's been a while,"
	line "<PLAYER>."

	para "LANCE called me to"
	line "help you finish"
	cont "TEAM ROCKET once"
	cont "and for all."

	para "He thought we"
	line "might work well"
	cont "after our efforts"
	cont "in LAVENDER TOWN."

	para "He's giving me too"
	line "much credit, but"
	cont "I'm glad to help."

	para "I hate everything"
	line "TEAM ROCKET stands"
	cont "for."

	para "But before we go"
	line "in there, I need"
	cont "to know…"

	para "…Are you ready?"

	para "Since I lost to"
	line "you, I've been"
	cont "traveling with my"
	cont "#MON. Trying"
	cont "to understand"
	cont "each of them."

	para "I think I finally"
	line "do. Let me show"
	cont "you what we've"
	cont "learned together."
	done

MountMoonRivalTextWin:
	text "<……> <……> <……>"

	para "My #MON fought"
	line "harder than ever."

	para "They're not just"
	line "obeying me."
	cont "They're choosing"
	cont "to fight with me."

	para "I think I am"
	line "finally starting"
	cont "to understand what"
	cont "you've known all"
	cont "along."
	done

MountMoonRivalTextAfter:
	text "<……> <……> <……>"

	para "…You won."
	line "Good."

	para "If you couldn't"
	line "beat me here, you"
	cont "wouldn't last five"
	cont "minutes."

	para "LANCE left us his"
	line "special medicine."

	para "He said: 'go in"
	line "at full strength.'"
	cont "I'm inclined to"
	cont "agree."

	para "I'd come with you,"
	line "but this is your"
	cont "fight."

	para "I saw it in your"
	line "#MON just now."
	cont "They'd follow you"
	cont "anywhere."

	para "…There are no"
	line "weak #MON, are"
	cont "there? Just"
	cont "trainers who"
	cont "don't understand."

	para "Go. I'll be on the"
	line "lookout for the"
	cont "secret entrance"
	cont "too."
	done

MountMoonRivalTextLoss:
	text "<……> <……> <……>"

	para "…That's not good"
	line "enough, <PLAYER>."

	para "TEAM ROCKET is"
	line "waiting in that"
	cont "CAVE with"
	cont "something far"
	cont "worse than me."

	para "Rest your #MON."
	line "Come back when"
	cont "you're ready."

	para "I'll be here."
	done

TrainerCooltrainerFAmber:
	trainer COOLTRAINERF, AMBER, EVENT_BEAT_COOLTRAINERF_AMBER, CooltrainerFAmberSeenText, CooltrainerFAmberBeatenText, 0, .Script

.Script:
	opentext
	writetext CooltrainerFAmberAfterBattleText
	waitbutton
	closetext
	end

CooltrainerFAmberSeenText:
	text "You're not the"
	line "first trainer I've"
	cont "run into today."

	para "But you might be"
	line "the toughest."
	done

CooltrainerFAmberBeatenText:
	text "I stand corrected!"
	done

CooltrainerFAmberAfterBattleText:
	text "I come through"
	line "MT.MOON every few"
	cont "weeks to train."

	para "The wild #MON"
	line "here don't mess"
	cont "around."
	done


TrainerCooltrainerMTravis:
	trainer COOLTRAINERM, TRAVIS, EVENT_BEAT_COOLTRAINERM_TRAVIS, CooltrainerMTravisSeenText, CooltrainerMTravisBeatenText, 0, .Script

.Script:
	opentext
	writetext CooltrainerMTravisAfterBattleText
	waitbutton
	closetext
	end

CooltrainerMTravisSeenText:
	text "MT.MOON is one of"
	line "the best training"
	cont "spots in KANTO."

	para "I'm not letting"
	line "you through"
	cont "without a battle."
	done

CooltrainerMTravisBeatenText:
	text "Fair enough."
	done

CooltrainerMTravisAfterBattleText:
	text "Good battle."

	para "The ZUBAT in here"
	line "alone will toughen"
	cont "up any team."
	done


TrainerHikerMarcos:
	trainer HIKER, MARCOS, EVENT_BEAT_HIKER_MARCOS, HikerMarcosSeenText, HikerMarcosBeatenText, 0, .Script

.Script:
	opentext
	writetext HikerMarcosAfterBattleText
	waitbutton
	closetext
	end

HikerMarcosSeenText:
	text "I know every inch"
	line "of this mountain!"

	para "You won't find a"
	line "way around me."
	done

HikerMarcosBeatenText:
	text "You know your way"
	line "around a battle,"
	cont "I'll give you that."
	done

HikerMarcosAfterBattleText:
	text "I've been hiking"
	line "MT.MOON for twenty"
	cont "years."

	para "Never gets old."
	done


TrainerHikerClint:
	trainer HIKER, CLINT, EVENT_BEAT_HIKER_CLINT, HikerClintSeenText, HikerClintBeatenText, 0, .Script

.Script:
	opentext
	writetext HikerClintAfterBattleText
	waitbutton
	closetext
	end

HikerClintSeenText:
	text "Lot of trainers"
	line "passing through"
	cont "today."

	para "You're all getting"
	line "a battle whether"
	cont "you like it or"
	cont "not."
	done

HikerClintBeatenText:
	text "Strong team."
	done

HikerClintAfterBattleText:
	text "Watch your step"
	line "deeper in."

	para "The ground gets"
	line "uneven past the"
	cont "next chamber."
	done


TrainerSuperNerdOtto:
	trainer SUPER_NERD, OTTO, EVENT_BEAT_SUPER_NERD_OTTO, SuperNerdOttoSeenText, SuperNerdOttoBeatenText, 0, .Script

.Script:
	opentext
	writetext SuperNerdOttoAfterBattleText
	waitbutton
	closetext
	end

SuperNerdOttoSeenText:
	text "I'm conducting"
	line "field research on"
	cont "CLEFAIRY behavior."

	para "This won't take"
	line "long."
	done

SuperNerdOttoBeatenText:
	text "Fascinating."
	line "Back to my notes."
	done

SuperNerdOttoAfterBattleText:
	text "The CLEFAIRY here"
	line "are unlike any"
	cont "other population"
	cont "I've studied."

	para "Something about"
	line "the geology in"
	cont "MT.MOON draws them"
	cont "here."
	done


TrainerPokemaniacAshton:
	trainer POKEMANIAC, ASHTON, EVENT_BEAT_POKEMANIAC_ASHTON, PokemaniacAshtonSeenText, PokemaniacAshtonBeatenText, 0, .Script

.Script:
	opentext
	writetext PokemaniacAshtonAfterBattleText
	waitbutton
	closetext
	end

PokemaniacAshtonSeenText:
	text "MT.MOON is the"
	line "greatest fossil"
	cont "site in the world!"

	para "I challenge anyone"
	line "who says anything"
	cont "else!"
	done

PokemaniacAshtonBeatenText:
	text "The fossils…"
	line "forgive me…"
	done

PokemaniacAshtonAfterBattleText:
	text "DOME and HELIX"
	line "fossils have been"
	cont "found all through"
	cont "these caves."

	para "You won't find a"
	line "richer dig site"
	cont "anywhere."
	done

MountMoonNugget:
	itemball NUGGET

MountMoonPPUp:
	itemball PP_UP

MountMoonRevive:
	itemball REVIVE

MountMoonMoonStone:
	itemball MOON_STONE

MountMoonHiddenMaxPotion:
	hiddenitem MAX_POTION, EVENT_MT_MOON_HIDDEN_MAX_POTION

MountMoonHiddenMaxRepel:
	hiddenitem MAX_REPEL, EVENT_MT_MOON_HIDDEN_MAX_REPEL

MountMoonHiddenFullHeal:
	hiddenitem FULL_HEAL, EVENT_MT_MOON_HIDDEN_FULL_HEAL

MountMoonHiddenElixer:
	hiddenitem ELIXER, EVENT_MT_MOON_HIDDEN_ELIXER

MountMoon_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 15, 33, ROUTE_3, 1
	warp_event 13, 21, MOUNT_MOON_PATH, 1
	warp_event 27, 15, MOUNT_MOON_B1, 4
	warp_event 35, 31, MOUNT_MOON_B1, 3
	warp_event 15, 13, MOUNT_MOON_B1, 2
	warp_event  3,  5, MOUNT_MOON_B1, 1

	def_coord_events

	def_bg_events
	bg_event  7, 30, BGEVENT_ITEM, MountMoonHiddenMaxPotion
	bg_event 23, 32, BGEVENT_ITEM, MountMoonHiddenMaxRepel
	bg_event 14, 11, BGEVENT_ITEM, MountMoonHiddenFullHeal
	bg_event  3,  6, BGEVENT_ITEM, MountMoonHiddenElixer

	def_object_events
	object_event 15, 28, SPRITE_RIVAL, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_MT_MOON_RIVAL
	object_event  2, 22, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, MountMoonNugget, EVENT_MT_MOON_NUGGET
	object_event 36, 20, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, MountMoonPPUp, EVENT_MT_MOON_PP_UP
	object_event 15,  3, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, MountMoonRevive, EVENT_MT_MOON_REVIVE
	object_event  2, 17, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, MountMoonMoonStone, EVENT_MT_MOON_MOON_STONE
	object_event 14, 24, SPRITE_COOLTRAINER_F, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 3, TrainerCooltrainerFAmber, -1
	object_event 25, 15, SPRITE_COOLTRAINER_M, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 1, TrainerCooltrainerMTravis, -1
	object_event 28, 30, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 2, TrainerHikerMarcos, -1
	object_event 25, 02, SPRITE_SUPER_NERD, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 2, TrainerSuperNerdOtto, -1
	object_event  5, 14, SPRITE_SUPER_NERD, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 3, TrainerPokemaniacAshton, -1
	object_event  4,  4, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 1, TrainerHikerClint, -1

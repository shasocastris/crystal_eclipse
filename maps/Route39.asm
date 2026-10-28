	object_const_def
	const ROUTE39_SAILOR
	const ROUTE39_POKEFAN_M
	const ROUTE39_POKEFAN_F1
	const ROUTE39_MILTANK1
	const ROUTE39_MILTANK2
	const ROUTE39_MILTANK3
	const ROUTE39_MILTANK4
	const ROUTE39_PSYCHIC_NORMAN
	const ROUTE39_FRUIT_TREE
	const ROUTE39_POKEFAN_F2
	const ROUTE39_TAUROS_HERD_LEADER
	const ROUTE39_TAUROS_11
	const ROUTE39_TAUROS_12
	const ROUTE39_TAUROS_13
	const ROUTE39_TAUROS_14
	const ROUTE39_TAUROS_15
	const ROUTE39_TAUROS_16

Route39_MapScripts:
	def_scene_scripts
	scene_script Route39FNoop1Scene, SCENE_ROUTE39_WILD_HUNT
	scene_script Route39FNoop2Scene, SCENE_ROUTE39_TAUROS_HERD_LEADER
	scene_script Route39FNoop3Scene, SCENE_ROUTE39_NOOP

	def_callbacks
	callback MAPCALLBACK_NEWMAP, Route39WildHuntSceneCallback

Route39WildHuntSceneCallback:
	checkflag ENGINE_WILD_HUNT
	iffalse .NoHunt
	checkevent EVENT_FOUGHT_WILD_HUNT_TAUROS_17 ; herd leader
	iftrue .NoHunt
	setscene SCENE_ROUTE39_WILD_HUNT
	endcallback

.NoHunt:
	setscene SCENE_ROUTE39_NOOP
	endcallback

Route39FNoop1Scene:
	end

Route39FNoop2Scene:
	end

Route39FNoop3Scene:
	end

WildHuntFarmCantLeaveScript:
	checkevent EVENT_FOUGHT_WILD_HUNT_TAUROS_1
	iffalse .cantleave
	checkevent EVENT_FOUGHT_WILD_HUNT_TAUROS_2
	iffalse .cantleave
	checkevent EVENT_FOUGHT_WILD_HUNT_TAUROS_3
	iffalse .cantleave
	checkevent EVENT_FOUGHT_WILD_HUNT_TAUROS_4
	iffalse .cantleave
	checkevent EVENT_FOUGHT_WILD_HUNT_TAUROS_5
	iffalse .cantleave
	checkevent EVENT_FOUGHT_WILD_HUNT_TAUROS_6
	iffalse .cantleave
	checkevent EVENT_FOUGHT_WILD_HUNT_TAUROS_7
	iffalse .cantleave
	checkevent EVENT_FOUGHT_WILD_HUNT_TAUROS_8
	iffalse .cantleave
	checkevent EVENT_FOUGHT_WILD_HUNT_TAUROS_9
	iffalse .cantleave
	checkevent EVENT_FOUGHT_WILD_HUNT_TAUROS_10
	iffalse .cantleave
	checkevent EVENT_FOUGHT_WILD_HUNT_TAUROS_11
	iffalse .cantleave
	checkevent EVENT_FOUGHT_WILD_HUNT_TAUROS_12
	iffalse .cantleave
	checkevent EVENT_FOUGHT_WILD_HUNT_TAUROS_13
	iffalse .cantleave
	checkevent EVENT_FOUGHT_WILD_HUNT_TAUROS_14
	iffalse .cantleave
	checkevent EVENT_FOUGHT_WILD_HUNT_TAUROS_15
	iffalse .cantleave
	checkevent EVENT_FOUGHT_WILD_HUNT_TAUROS_16
	iffalse .cantleave
	end

.cantleave
	opentext
	writetext WildHuntFarmCantLeaveText
	waitbutton
	closetext
	applymovement PLAYER, WildHuntFarmCantLeaveMovement
	end

WildHuntOlivineCantLeaveScript:
	opentext
	writetext WildHuntOlivineCantLeaveText
	waitbutton
	closetext
	applymovement PLAYER, WildHuntOlivineCantLeaveMovement
	end

WildHuntTauros11:
	faceplayer
	showemote EMOTE_SAD, ROUTE39_TAUROS_11, 35
	opentext
	writetext Route39WildHuntTauros_Text
	cry TAUROS
	pause 15
	closetext
	setevent EVENT_FOUGHT_WILD_HUNT_TAUROS_11
	loadvar VAR_BATTLETYPE, BATTLETYPE_WILD_HUNT
	loadwildmon TAUROS, 35
	startbattle
	disappear ROUTE39_TAUROS_11
	reloadmapafterbattle
	end

WildHuntTauros12:
	faceplayer
	showemote EMOTE_SAD, ROUTE39_TAUROS_12, 35
	opentext
	writetext Route39WildHuntTauros_Text
	cry TAUROS
	pause 15
	closetext
	setevent EVENT_FOUGHT_WILD_HUNT_TAUROS_12
	loadvar VAR_BATTLETYPE, BATTLETYPE_WILD_HUNT
	loadwildmon TAUROS, 35
	startbattle
	disappear ROUTE39_TAUROS_12
	reloadmapafterbattle
	end

WildHuntTauros13:
	faceplayer
	showemote EMOTE_SAD, ROUTE39_TAUROS_13, 35
	opentext
	writetext Route39WildHuntTauros_Text
	cry TAUROS
	pause 15
	closetext
	setevent EVENT_FOUGHT_WILD_HUNT_TAUROS_13
	loadvar VAR_BATTLETYPE, BATTLETYPE_WILD_HUNT
	loadwildmon TAUROS, 35
	startbattle
	disappear ROUTE39_TAUROS_13
	reloadmapafterbattle
	end

WildHuntTauros14:
	faceplayer
	showemote EMOTE_SAD, ROUTE39_TAUROS_14, 35
	opentext
	writetext Route39WildHuntTauros_Text
	cry TAUROS
	pause 15
	closetext
	setevent EVENT_FOUGHT_WILD_HUNT_TAUROS_14
	loadvar VAR_BATTLETYPE, BATTLETYPE_WILD_HUNT
	loadwildmon TAUROS, 35
	startbattle
	disappear ROUTE39_TAUROS_14
	reloadmapafterbattle
	end

WildHuntTauros15:
	faceplayer
	showemote EMOTE_SAD, ROUTE39_TAUROS_15, 35
	opentext
	writetext Route39WildHuntTauros_Text
	cry TAUROS
	pause 15
	closetext
	setevent EVENT_FOUGHT_WILD_HUNT_TAUROS_15
	loadvar VAR_BATTLETYPE, BATTLETYPE_WILD_HUNT
	loadwildmon TAUROS, 35
	startbattle
	disappear ROUTE39_TAUROS_15
	reloadmapafterbattle
	end

WildHuntTauros16:
	faceplayer
	showemote EMOTE_SAD, ROUTE39_TAUROS_16, 35
	opentext
	writetext Route39WildHuntTauros_Text
	cry TAUROS
	pause 15
	closetext
	setevent EVENT_FOUGHT_WILD_HUNT_TAUROS_16
	loadvar VAR_BATTLETYPE, BATTLETYPE_WILD_HUNT
	loadwildmon TAUROS, 35
	startbattle
	disappear ROUTE39_TAUROS_16
	reloadmapafterbattle
	end

WildHuntTaurosHerdLeaderScript:
	turnobject PLAYER, RIGHT
	showemote EMOTE_SHOCK, PLAYER, 15
	special FadeOutMusic
	cry TAUROS
	pause 15
	appear ROUTE39_TAUROS_HERD_LEADER
	waitsfx
	applymovement ROUTE39_TAUROS_HERD_LEADER, Route39TaurosHerdLeaderMovement
	showemote EMOTE_SAD, ROUTE39_TAUROS_HERD_LEADER, 30
	setevent EVENT_TAUROS_HERD_LEADER
	setevent EVENT_FOUGHT_WILD_HUNT_TAUROS_17
	loadvar VAR_BATTLETYPE, BATTLETYPE_WILD_HUNT
	loadwildmon TAUROS, 45
	startbattle
	disappear ROUTE39_TAUROS_HERD_LEADER
	reloadmapafterbattle
	setscene SCENE_ROUTE39_NOOP
	end

Route39Miltank:
	opentext
	writetext Route39MiltankText
	cry MILTANK
	waitbutton
	callasm .Miltank
	special ShowPokedexEntry
	closetext
	end

.Miltank
	ld hl, MILTANK
	call GetPokemonIDFromIndex
	ld [wScriptVar], a
	ret

TrainerPokefanmDerek:
	trainer POKEFANM, DEREK1, EVENT_BEAT_POKEFANM_DEREK, PokefanmDerekSeenText, PokefanmDerekBeatenText, 0, .Script

.Script:
	loadvar VAR_CALLERID, PHONE_POKEFANM_DEREK
	opentext
	checkflag ENGINE_DEREK_HAS_NUGGET
	iftrue .HasNugget
	checkcellnum PHONE_POKEFANM_DEREK
	iftrue .NumberAccepted
	checkpoke PIKACHU
	iffalse .WantsPikachu
	checkevent EVENT_DEREK_ASKED_FOR_PHONE_NUMBER
	iftrue .AskedAlready
	writetext PokefanMDerekText_NotBragging
	promptbutton
	setevent EVENT_DEREK_ASKED_FOR_PHONE_NUMBER
	scall .AskNumber1
	sjump .AskForNumber

.AskedAlready:
	scall .AskNumber2
.AskForNumber:
	askforphonenumber PHONE_POKEFANM_DEREK
	ifequal PHONE_CONTACTS_FULL, .PhoneFull
	ifequal PHONE_CONTACT_REFUSED, .NumberDeclined
	gettrainername STRING_BUFFER_3, POKEFANM, DEREK1
	scall .RegisteredNumber
	sjump .NumberAccepted

.HasNugget:
	scall .Gift
	verbosegiveitem NUGGET, 3
	iffalse .NoRoom
	clearflag ENGINE_DEREK_HAS_NUGGET
	sjump .NumberAccepted

.NoRoom:
	sjump .PackFull

.WantsPikachu:
	writetext PokefanMDerekPikachuIsItText
	waitbutton
	closetext
	end

.AskNumber1:
	jumpstd AskNumber1MScript
	end

.AskNumber2:
	jumpstd AskNumber2MScript
	end

.RegisteredNumber:
	jumpstd RegisteredNumberMScript
	end

.NumberAccepted:
	jumpstd NumberAcceptedMScript
	end

.NumberDeclined:
	jumpstd NumberDeclinedMScript
	end

.PhoneFull:
	jumpstd PhoneFullMScript
	end

.Gift:
	jumpstd GiftMScript
	end

.PackFull:
	jumpstd PackFullMScript
	end

TrainerPokefanfRuth:
	trainer POKEFANF, RUTH, EVENT_BEAT_POKEFANF_RUTH, PokefanfRuthSeenText, PokefanfRuthBeatenText, 0, .Script

.Script:
	opentext
	writetext PokefanfRuthAfterBattleText
	waitbutton
	closetext
	end

TrainerSailorEugene:
	trainer SAILOR, EUGENE, EVENT_BEAT_SAILOR_EUGENE, SailorEugeneSeenText, SailorEugeneBeatenText, 0, .Script

.Script:
	opentext
	writetext SailorEugeneAfterBattleText
	waitbutton
	closetext
	end

TrainerPsychicNorman:
	trainer PSYCHIC_T, NORMAN, EVENT_BEAT_PSYCHIC_NORMAN, PsychicNormanSeenText, PsychicNormanBeatenText, 0, .Script

.Script:
	opentext
	writetext PsychicNormanAfterBattleText
	waitbutton
	closetext
	end

TrainerPokefanfJaime:
	faceplayer
	opentext
	checkevent EVENT_BEAT_POKEFANF_JAIME
	iftrue JaimeGaveParalyzGuardScript
	checktime NITE
	iffalse .NotNight
	writetext PokefanfJaimeSeenText
	waitbutton
	closetext
	winlosstext PokefanfJaimeBeatenText, 0
	loadtrainer POKEFANF, JAIME
	startbattle
	reloadmapafterbattle
	opentext
.GiveParalyzGuard
	writetext JaimeGivesParalyzGuardText
	promptbutton
	verbosegiveitem PARLYZ_GUARD
	iffalse JaimeDoneScript
	setevent EVENT_BEAT_POKEFANF_JAIME
	writetext JaimeGaveParalyzGuardText
	waitbutton
	closetext
	end
.NotNight:
	writetext PokefanfJaimeHopeItGetsDarkText
	waitbutton
	closetext
	end

JaimeGaveParalyzGuardScript:
	writetext PokefanfJaimeAfterBattleText
	waitbutton
JaimeDoneScript:
	closetext
	end

Route39Sign:
	jumptext Route39SignText

MoomooFarmSign:
	jumptext MoomooFarmSignText

Route39TrainerTips:
	jumptext Route39TrainerTipsText

Route39FruitTree:
	fruittree FRUITTREE_ROUTE_39

Route39HiddenNugget:
	hiddenitem NUGGET, EVENT_ROUTE_39_HIDDEN_NUGGET

WildHuntFarmCantLeaveMovement:
	step RIGHT
	step_end

WildHuntOlivineCantLeaveMovement:
	step UP
	step_end

Route39TaurosHerdLeaderMovement:
	set_sliding
	fast_jump_step UP
	fast_jump_step UP
	fast_jump_step LEFT
	fast_jump_step LEFT
	remove_sliding
	step_end

Route39WildHuntTauros_Text:
	text "TAUROS: RRRGGH!"
	done

WildHuntFarmCantLeaveText:
	text "I can't head to"
	line "the farm yet."

	para "There are still"
	line "TAUROS rampaging."
	done

WildHuntOlivineCantLeaveText:
	text "I'm not the sort"
	line "of #MON trainer"

	para "that runs from a"
	line "battle!"
	done

Route39MiltankText:
	text "MILTANK: Mooo!"
	done

SailorEugeneSeenText:
	text "I just got back to"
	line "OLIVINE."

	para "What's this about"
	line "a stampede?"

	para "Let's battle while"
	line "you fill me in!"
	done

SailorEugeneBeatenText:
	text "Awaaargh!"
	done

SailorEugeneAfterBattleText:
	text "A WILD HUNT caused"
	line "by TEAM ROCKET?"

	para "The seas are dan-"
	line "gerous, but at"

	para "least wild #MON"
	line "don't form massive"
	cont "hunting packs!"
	done

PokefanmDerekSeenText:
	text "My PIKACHU stayed"
	line "calm during the"
	cont "whole crisis!"

	para "Isn't that worth"
	line "bragging about?"
	done

PokefanmDerekBeatenText:
	text "I had no time to"
	line "show off PIKACHU…"
	done

PokefanMDerekText_NotBragging:
	text "I'm not listening"
	line "to your bragging!"

	para "We # FANS have"
	line "a policy of not"

	para "listening to other"
	line "people brag!"
	done

PokefanfRuthSeenText:
	text "After that fright-"
	line "ening stampede,"

	para "I want to see some"
	line "friendly #MON!"
	done

PokefanfRuthBeatenText:
	text "I don't mind"
	line "losing."
	done

PokefanfRuthAfterBattleText:
	text "Wild #MON can"
	line "be dangerous when"
	cont "provoked."

	para "But with proper"
	line "care and training,"

	para "they become our"
	line "beloveds."
	done

PokefanMDerekPikachuIsItText:
	text "PIKACHU is it!"
	line "Don't you agree?"
	done

PsychicNormanSeenText:
	text "The WILD HUNT"
	line "revealed much"

	para "about the bond"
	line "between people and"
	cont "#MON."
	done

PsychicNormanBeatenText:
	text "Ooh, your #MON"
	line "have potential."
	done

PsychicNormanAfterBattleText:
	text "Wild #MON have"
	line "instincts we can"
	cont "barely comprehend."

	para "But trainers and"
	line "#MON who trust"

	para "each other can"
	line "overcome any"
	cont "crisis together."
	done

PokefanfJaimeHopeItGetsDarkText:
	text "Ufufufu… I hope it"
	line "gets dark soon."
	done

PokefanfJaimeSeenText:
	text "The night of the"
	line "WILD HUNT, my"
	cont "PERSIAN sensed the"
	cont "danger early."

	para "Let's battle!"
	done

PokefanfJaimeBeatenText:
	text "Oh, how disap-"
	line "pointing…"
	done

PokefanfJaimeAfterBattleText:
	text "I met my PERSIAN"
	line "at night, right"
	cont "here on ROUTE 39."

	para "During the stam-"
	line "pede, it kept me"

	para "safe by sensing"
	line "when TAUROS were"
	cont "approaching."

	para "Training here has"
	line "made us even"
	cont "closer than before."
	done

JaimeGivesParalyzGuardText:
	text "After going through"
	line "that crisis, you"
	cont "deserve this."

	para "It will keep your"
	line "#MON from"
	cont "being paralyzed in"
	cont "battle."
	done

JaimeGaveParalyzGuardText:
	text "You might catch"
	line "other trainers off"
	cont "guard if it's used"
	cont "correctly."
	done

Route39SignText:
	text "ROUTE 39"

	para "OLIVINE CITY -"
	line "ECRUTEAK CITY"
	done

MoomooFarmSignText:
	text "MOOMOO FARM"

	para "Enjoy Our Fresh"
	line "and Tasty Milk"
	done

Route39TrainerTipsText:
	text "TRAINER TIPS"

	para "Use HEADBUTT on"
	line "trees to shake"
	cont "#MON out."

	para "Different kinds of"
	line "#MON drop out"
	cont "of trees."

	para "Use HEADBUTT on"
	line "any tree you see!"
	done

Route39_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  1,  3, ROUTE_39_BARN, 1
	warp_event  5,  3, ROUTE_39_FARMHOUSE, 1

	def_coord_events
	coord_event  3,  4, SCENE_ROUTE39_WILD_HUNT, WildHuntFarmCantLeaveScript
	coord_event  8, 34, SCENE_ROUTE39_WILD_HUNT, WildHuntOlivineCantLeaveScript
	coord_event  9, 34, SCENE_ROUTE39_WILD_HUNT, WildHuntOlivineCantLeaveScript
	coord_event 10, 34, SCENE_ROUTE39_WILD_HUNT, WildHuntOlivineCantLeaveScript
	coord_event 11, 34, SCENE_ROUTE39_WILD_HUNT, WildHuntOlivineCantLeaveScript
	coord_event  1,  4, SCENE_ROUTE39_WILD_HUNT, WildHuntTaurosHerdLeaderScript

	def_bg_events
	bg_event  5, 31, BGEVENT_READ, Route39TrainerTips
	bg_event  9,  5, BGEVENT_READ, MoomooFarmSign
	bg_event 15,  7, BGEVENT_READ, Route39Sign
	bg_event  5, 13, BGEVENT_ITEM, Route39HiddenNugget

	def_object_events
	object_event 13, 29, SPRITE_SAILOR, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 5, TrainerSailorEugene, EVENT_QUELLED_WILD_HUNT
	object_event 10, 22, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 4, TrainerPokefanmDerek, EVENT_QUELLED_WILD_HUNT
	object_event 11, 19, SPRITE_POKEFAN_F, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 4, TrainerPokefanfRuth, EVENT_QUELLED_WILD_HUNT
	object_event  3, 12, SPRITE_MILTANK, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Route39Miltank, EVENT_QUELLED_WILD_HUNT
	object_event  6, 11, SPRITE_MILTANK, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Route39Miltank, EVENT_QUELLED_WILD_HUNT
	object_event  4, 15, SPRITE_MILTANK, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Route39Miltank, EVENT_QUELLED_WILD_HUNT
	object_event  8, 13, SPRITE_MILTANK, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Route39Miltank, EVENT_QUELLED_WILD_HUNT
	object_event 13,  7, SPRITE_STANDING_YOUNGSTER, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 1, TrainerPsychicNorman, EVENT_QUELLED_WILD_HUNT
	object_event  9,  3, SPRITE_FRUIT_TREE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Route39FruitTree, -1
	object_event  4, 22, SPRITE_POKEFAN_F, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, TrainerPokefanfJaime, EVENT_QUELLED_WILD_HUNT
	object_event  6,  8, SPRITE_TAUROS, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_TAUROS_HERD_LEADER
	object_event 13, 10, SPRITE_TAUROS, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, WildHuntTauros11, EVENT_FOUGHT_WILD_HUNT_TAUROS_11
	object_event 14, 16, SPRITE_TAUROS, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, WildHuntTauros12, EVENT_FOUGHT_WILD_HUNT_TAUROS_12
	object_event  5, 25, SPRITE_TAUROS, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, WildHuntTauros13, EVENT_FOUGHT_WILD_HUNT_TAUROS_13
	object_event  9, 28, SPRITE_TAUROS, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, WildHuntTauros14, EVENT_FOUGHT_WILD_HUNT_TAUROS_14
	object_event  8,  6, SPRITE_TAUROS, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, WildHuntTauros15, EVENT_FOUGHT_WILD_HUNT_TAUROS_15
	object_event  8, 19, SPRITE_TAUROS, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, WildHuntTauros16, EVENT_FOUGHT_WILD_HUNT_TAUROS_16

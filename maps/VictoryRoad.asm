	object_const_def
	const VICTORYROAD_RIVAL
	const VICTORYROAD_POKE_BALL1
	const VICTORYROAD_POKE_BALL2
	const VICTORYROAD_POKE_BALL3
	const VICTORYROAD_POKE_BALL4
	const VICTORYROAD_POKE_BALL5
	const VICTORYROAD_MOLTRES
	const VICTORYROAD_JUGGLER1
	const VICTORYROAD_JUGGLER2
	const VICTORYROAD_COOLTRAINERM
	const VICTORYROAD_COOLTRAINERF1
	const VICTORYROAD_COOLTRAINERF2
	const VICTORYROAD_PSYCHIC_NATHAN

VictoryRoad_MapScripts:
	def_scene_scripts
	scene_script VictoryRoadNoop1Scene, SCENE_VICTORYROAD_RIVAL_BATTLE
	scene_script VictoryRoadNoop2Scene, SCENE_VICTORYROAD_NOOP

	def_callbacks
	callback MAPCALLBACK_OBJECTS, VictoryRoadMoltres

VictoryRoadNoop1Scene:
	end

VictoryRoadNoop2Scene:
	end

VictoryRoadRivalLeft:
	moveobject VICTORYROAD_RIVAL, 18, 11
	turnobject PLAYER, DOWN
	showemote EMOTE_SHOCK, PLAYER, 15
	special FadeOutMusic
	pause 15
	appear VICTORYROAD_RIVAL
	applymovement VICTORYROAD_RIVAL, VictoryRoadRivalBattleApproachMovement1
	scall VictoryRoadRivalNext
	applymovement VICTORYROAD_RIVAL, VictoryRoadRivalBattleExitMovement1
	disappear VICTORYROAD_RIVAL
	setscene SCENE_VICTORYROAD_NOOP
	playmapmusic
	end

VictoryRoadRivalRight:
	turnobject PLAYER, DOWN
	showemote EMOTE_SHOCK, PLAYER, 15
	special FadeOutMusic
	pause 15
	appear VICTORYROAD_RIVAL
	applymovement VICTORYROAD_RIVAL, VictoryRoadRivalBattleApproachMovement2
	scall VictoryRoadRivalNext
	applymovement VICTORYROAD_RIVAL, VictoryRoadRivalBattleExitMovement2
	disappear VICTORYROAD_RIVAL
	setscene SCENE_VICTORYROAD_NOOP
	playmapmusic
	end

VictoryRoadRivalNext:
	playmusic MUSIC_RIVAL_ENCOUNTER
	opentext
	writetext VictoryRoadRivalBeforeText
	waitbutton
	closetext
	setevent EVENT_RIVAL_VICTORY_ROAD
	checkevent EVENT_GOT_TOTODILE_FROM_ELM
	iftrue .GotTotodile
	checkevent EVENT_GOT_CHIKORITA_FROM_ELM
	iftrue .GotChikorita
	winlosstext VictoryRoadRivalDefeatText, VictoryRoadRivalVictoryText
	setlasttalked VICTORYROAD_RIVAL
	loadtrainer RIVAL1, RIVAL1_5_TOTODILE
	startbattle
	dontrestartmapmusic
	reloadmapafterbattle
	sjump .AfterBattle

.GotTotodile:
	winlosstext VictoryRoadRivalDefeatText, VictoryRoadRivalVictoryText
	setlasttalked VICTORYROAD_RIVAL
	loadtrainer RIVAL1, RIVAL1_5_CHIKORITA
	startbattle
	dontrestartmapmusic
	reloadmapafterbattle
	sjump .AfterBattle

.GotChikorita:
	winlosstext VictoryRoadRivalDefeatText, VictoryRoadRivalVictoryText
	setlasttalked VICTORYROAD_RIVAL
	loadtrainer RIVAL1, RIVAL1_5_CYNDAQUIL
	startbattle
	dontrestartmapmusic
	reloadmapafterbattle
; fallthrough
.AfterBattle:
	playmusic MUSIC_RIVAL_AFTER
	opentext
	writetext VictoryRoadRivalAfterText
	waitbutton
	closetext
	end

VictoryRoadMoltres:
	checkevent EVENT_FOUGHT_MOLTRES
	iftrue .NoAppear
	checkevent EVENT_BEAT_ELITE_FOUR
	iftrue .Appear
	sjump .NoAppear

.Appear:
	appear VICTORYROAD_MOLTRES
	endcallback

.NoAppear:
	disappear VICTORYROAD_MOLTRES
	endcallback

Moltres:
	faceplayer
	opentext
	writetext MoltresText
	cry MOLTRES
	pause 15
	closetext
	loadmonindex 0, MOLTRES
	callstd DeityTutorScript
	iftrue .Stay
	setevent EVENT_FOUGHT_MOLTRES
	disappear VICTORYROAD_MOLTRES
.Stay:
	end

MoltresText:
	text "Gyaaas!"
	done

TrainerJugglerCliff:
	trainer JUGGLER, CLIFF, EVENT_BEAT_JUGGLER_CLIFF, JugglerCliffSeenText, JugglerCliffBeatenText, 0, .Script

.Script:
	opentext
	writetext JugglerCliffAfterBattleText
	waitbutton
	closetext
	end

TrainerJugglerCaleb:
	trainer JUGGLER, CALEB, EVENT_BEAT_JUGGLER_CALEB, JugglerCalebSeenText, JugglerCalebBeatenText, 0, .Script

.Script:
	opentext
	writetext JugglerCalebAfterBattleText
	waitbutton
	closetext
	end

TrainerCooltrainermSteve:
	trainer COOLTRAINERM, STEVE, EVENT_BEAT_COOLTRAINERM_STEVE, CooltrainermSteveSeenText, CooltrainermSteveBeatenText, 0, .Script

.Script:
	opentext
	writetext CooltrainermSteveAfterBattleText
	waitbutton
	closetext
	end

TrainerCooltrainerfGalen:
	trainer COOLTRAINERF, GALEN, EVENT_BEAT_COOLTRAINERF_GALEN, CooltrainerfGalenSeenText, CooltrainerfGalenBeatenText, 0, .Script

.Script:
	opentext
	writetext CooltrainerfGalenAfterBattleText
	waitbutton
	closetext
	end

TrainerCooltrainerfKelsey:
	trainer COOLTRAINERF, KELSEY, EVENT_BEAT_COOLTRAINERF_KELSEY, CooltrainerfKelseySeenText, CooltrainerfKelseyBeatenText, 0, .Script

.Script:
	opentext
	writetext CooltrainerfKelseyAfterBattleText
	waitbutton
	closetext
	end

TrainerPsychicNathan:
	trainer PSYCHIC_T, NATHAN, EVENT_BEAT_PSYCHIC_NATHAN, PsychicNathanSeenText, PsychicNathanBeatenText, 0, .Script

.Script:
	opentext
	writetext PsychicNathanAfterBattleText
	waitbutton
	closetext
	end

VictoryRoadTMEarthquake:
	itemball TM_EARTHQUAKE

VictoryRoadMaxRevive:
	itemball MAX_REVIVE

VictoryRoadFullRestore:
	itemball FULL_RESTORE

VictoryRoadFullHeal:
	itemball FULL_HEAL

VictoryRoadHPUp:
	itemball HP_UP

VictoryRoadHiddenMaxPotion:
	hiddenitem MAX_POTION, EVENT_VICTORY_ROAD_HIDDEN_MAX_POTION

VictoryRoadHiddenFullHeal:
	hiddenitem FULL_HEAL, EVENT_VICTORY_ROAD_HIDDEN_FULL_HEAL

VictoryRoadRivalBattleApproachMovement1:
	step LEFT
	step LEFT
	step LEFT
	step LEFT
	step LEFT
	step LEFT
	step UP
	step UP
	step_end

VictoryRoadRivalBattleApproachMovement2:
	step UP
	step UP
	step LEFT
	step LEFT
	step LEFT
	step LEFT
	step LEFT
	step UP
	step UP
	step_end

VictoryRoadRivalBattleExitMovement1:
	step DOWN
	step DOWN
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step_end

VictoryRoadRivalBattleExitMovement2:
	step DOWN
	step DOWN
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step DOWN
	step DOWN
	step_end

VictoryRoadRivalBeforeText:
	text "…Are you going to"
	line "take the #MON"
	cont "LEAGUE challenge?"

	para "…I won't laugh at"
	line "you this time."

	para "I've been thinking"
	line "about what makes a"
	cont "trainer strong."

	para "It's not just"
	line "about having"
	cont "powerful #MON,"
	cont "is it?"

	para "I've been watching"
	line "how you battle."
	cont "How your #MON"
	cont "fight for you."

	para "I want to"
	line "understand that"
	cont "bond."

	para "<PLAYER>!"
	line "Show me what true"
	cont "strength looks"
	cont "like!"
	done

VictoryRoadRivalDefeatText:
	text "…I lost again."

	para "But this time…"
	line "I think I now know"
	cont "why."

	para "My #MON fought"
	line "hard, but yours…"
	cont "they fought with"
	cont "their hearts."

	para "That dragon master"
	line "was right, wasn't"
	cont "he?"

	para "True strength"
	line "comes from the"
	cont "bond between"
	cont "trainers and their"
	cont "#MON."
	done

VictoryRoadRivalAfterText:
	text "I'm not giving up"
	line "on becoming the"
	cont "greatest trainer."

	para "But I need to"
	line "change how I think"
	cont "about strength."

	para "It's not about"
	line "having the most"
	cont "powerful #MON."

	para "It's about"
	line "bringing out the"
	cont "best in every"
	cont "#MON."

	para "Even the ones I"
	line "used to think were"
	cont "weak."

	para "GOLBAT evolving"
	line "into CROBAT is a"
	cont "perfect example."

	para "When I figure this"
	line "out completely,"
	cont "I'll challenge you"
	cont "again."

	para "And next time,"
	line "we'll all be"
	cont "fighting with"
	cont "everything we"
	cont "have."

	para "…Thanks, <PLAYER>."
	line "For showing me"
	cont "what I was lacked."
	done

VictoryRoadRivalVictoryText:
	text "…Humph!"

	para "When it comes down"
	line "to it, nothing can"
	cont "beat power."

	para "I don't need any-"
	line "thing else."
	done

CooltrainermSteveSeenText:
	text "I've been training"
	line "here for months to"
	cont "challenge the"
	cont "ELITE FOUR!"

	para "Let me test my"
	line "skills against"
	cont "yours!"
	done

CooltrainermSteveBeatenText:
	text "Impressive! You"
	line "have real talent!"
	done

CooltrainermSteveAfterBattleText:
	text "The #MON here"
	line "are incredibly"
	cont "strong."

	para "Training with them"
	line "has made my team"
	cont "much tougher!"
	done

CooltrainerfGalenSeenText:
	text "Only the strongest"
	line "trainers make it"
	cont "this far."

	para "Show me what you"
	line "can do!"
	done

CooltrainerfGalenBeatenText:
	text "You really are"
	line "championship"
	cont "material!"
	done

CooltrainerfGalenAfterBattleText:
	text "VICTORY ROAD is"
	line "the ultimate test"
	cont "for any trainer."

	para "You've proven you"
	line "belong here!"
	done

CooltrainerfKelseySeenText:
	text "I can see the"
	line "determination in"
	cont "your eyes!"

	para "But determination"
	line "alone won't be"
	cont "enough here!"
	done

CooltrainerfKelseyBeatenText:
	text "Your #MON fight"
	line "with such spirit!"
	done

CooltrainerfKelseyAfterBattleText:
	text "The bond between"
	line "you and your"
	cont "#MON is clear."

	para "That's what makes"
	line "a true champion!"
	done

JugglerCliffSeenText:
	text "Watch closely!"
	line "My #MON are as"
	cont "unpredictable as"
	cont "my juggling!"

	para "Can you keep up"
	line "with the show?"
	done

JugglerCliffBeatenText:
	text "The show must"
	line "go on... even"
	cont "after a loss!"
	done

JugglerCliffAfterBattleText:
	text "Juggling and"
	line "#MON training"
	cont "both require"
	cont "perfect timing!"

	para "You've mastered"
	line "that skill!"
	done

JugglerCalebSeenText:
	text "Prepare to be"
	line "amazed by my"
	cont "spectacular"
	cont "#MON tricks!"

	para "This will be a"
	line "performance you'll"
	cont "never forget!"
	done

JugglerCalebBeatenText:
	text "What a twist!"
	line "The audience has"
	cont "become the star!"
	done

JugglerCalebAfterBattleText:
	text "A good performer"
	line "knows when they've"
	cont "been upstaged."

	para "Bravo! That was"
	line "a magnificent"
	cont "battle!"
	done

PsychicNathanSeenText:
	text "Hmmm… This is a"
	line "strange place."
	done

PsychicNathanBeatenText:
	text "…"
	done

PsychicNathanAfterBattleText:
	text "I like thinking"
	line "here."
	done

VictoryRoad_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  9, 67, VICTORY_ROAD_GATE, 5
	warp_event  1, 49, VICTORY_ROAD, 3
	warp_event  1, 35, VICTORY_ROAD, 2
	warp_event 13, 31, VICTORY_ROAD, 5
	warp_event 13, 17, VICTORY_ROAD, 4
	warp_event 17, 33, VICTORY_ROAD, 7
	warp_event 17, 19, VICTORY_ROAD, 6
	warp_event  1, 10, VICTORY_ROAD, 9
	warp_event  0, 27, VICTORY_ROAD, 8
	warp_event 13,  5, ROUTE_23, 4

	def_coord_events
	coord_event 12,  8, SCENE_VICTORYROAD_RIVAL_BATTLE, VictoryRoadRivalLeft
	coord_event 13,  8, SCENE_VICTORYROAD_RIVAL_BATTLE, VictoryRoadRivalRight

	def_bg_events
	bg_event  3, 29, BGEVENT_ITEM, VictoryRoadHiddenMaxPotion
	bg_event  3, 65, BGEVENT_ITEM, VictoryRoadHiddenFullHeal

	def_object_events
	object_event 18, 13, SPRITE_RIVAL, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_RIVAL_VICTORY_ROAD
	object_event  3, 28, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, VictoryRoadTMEarthquake, EVENT_VICTORY_ROAD_TM_EARTHQUAKE
	object_event 12, 48, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, VictoryRoadMaxRevive, EVENT_VICTORY_ROAD_MAX_REVIVE
	object_event 18, 29, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, VictoryRoadFullRestore, EVENT_VICTORY_ROAD_FULL_RESTORE
	object_event 15, 48, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, VictoryRoadFullHeal, EVENT_VICTORY_ROAD_FULL_HEAL
	object_event  7, 38, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, VictoryRoadHPUp, EVENT_VICTORY_ROAD_HP_UP
	object_event 10, 50, SPRITE_MOLTRES, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, Moltres, EVENT_VICTORY_ROAD_MOLTRES
	object_event  5, 54, SPRITE_SUPER_NERD, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 2, TrainerJugglerCliff, -1
	object_event  3, 27, SPRITE_SUPER_NERD, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 3, TrainerJugglerCaleb, -1
	object_event 15, 40, SPRITE_COOLTRAINER_M, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 2, TrainerCooltrainermSteve, -1
	object_event 10, 12, SPRITE_COOLTRAINER_F, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 2, TrainerCooltrainerfGalen, -1
	object_event  6, 64, SPRITE_COOLTRAINER_F, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 1, TrainerCooltrainerfKelsey, -1
	object_event 12, 28, SPRITE_STANDING_YOUNGSTER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 3, TrainerPsychicNathan, -1

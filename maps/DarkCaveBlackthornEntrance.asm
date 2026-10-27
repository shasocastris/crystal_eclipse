	object_const_def
	const DARKCAVEBLACKTHORNENTRANCE_PHARMACIST
	const DARKCAVEBLACKTHORNENTRANCE_POKE_BALL1
	const DARKCAVEBLACKTHORNENTRANCE_POKE_BALL2
	const DARKCAVEBLACKTHORNENTRANCE_ENTEI
	const DARKCAVEBLACKTHORNENTRANCE_BLACKBELT
	const DARKCAVEBLACKTHORNENTRANCE_SUPER_NERD

DarkCaveBlackthornEntrance_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_OBJECTS, DarkCaveEnteiCallback

DarkCaveEnteiCallback:
	checkevent EVENT_FOUGHT_ENTEI
	iftrue .NoAppear
	checkevent EVENT_BEAT_ELITE_FOUR
	iftrue .Appear
	sjump .NoAppear

.Appear:
	appear DARKCAVEBLACKTHORNENTRANCE_ENTEI
	endcallback

.NoAppear:
	disappear DARKCAVEBLACKTHORNENTRANCE_ENTEI
	endcallback

Entei:
	faceplayer
	opentext
	writetext EnteiText
	cry ENTEI
	pause 15
	closetext
	loadmonindex 0, ENTEI
	callstd DeityTutorScript
	iftrue .Stay
	setevent EVENT_FOUGHT_ENTEI
	disappear DARKCAVEBLACKTHORNENTRANCE_ENTEI
.Stay:
	end

EnteiText:
	text "Grroooar!"
	done

DarkCaveBlackthornEntrancePharmacistScript:
	faceplayer
	opentext
	checkevent EVENT_GOT_BLACKGLASSES_IN_DARK_CAVE
	iftrue .GotBlackglasses
	writetext DarkCaveBlackthornEntrancePharmacistText1
	promptbutton
	verbosegiveitem BLACKGLASSES
	iffalse .PackFull
	setevent EVENT_GOT_BLACKGLASSES_IN_DARK_CAVE
.GotBlackglasses:
	writetext DarkCaveBlackthornEntrancePharmacistText2
	waitbutton
.PackFull:
	closetext
	end

TrainerBlackbeltDomun:
	trainer BLACKBELT_T, DOMUN, EVENT_BEAT_BLACKBELT_DOMUN, BlackbeltDomunSeenText, BlackbeltDomunBeatenText, 0, .Script

.Script:
	opentext
	writetext BlackbeltDomunAfterBattleText
	waitbutton
	closetext
	end

TrainerSuperNerdDave:
	trainer SUPER_NERD, DAVE, EVENT_BEAT_SUPER_NERD_DAVE, SuperNerdDaveSeenText, SuperNerdDaveBeatenText, 0, .Script

.Script:
	opentext
	writetext SuperNerdDaveAfterBattleText
	waitbutton
	closetext
	end

DarkCaveBlackthornEntranceRevive:
	itemball REVIVE

DarkCaveBlackthornEntranceMistStone:
	itemball MIST_STONE

BlackbeltDomunSeenText:
	text "This cave is the"
	line "perfect training"
	cont "ground!"

	para "Dark, rocky, and"
	line "full of wild"
	cont "#MON!"

	para "Let me show you"
	line "real power!"
	done

BlackbeltDomunBeatenText:
	text "Your spirit burns"
	line "bright!"
	done

BlackbeltDomunAfterBattleText:
	text "I come here from"
	line "BLACKTHORN to"
	cont "train in darkness."

	para "Fighting without"
	line "sight sharpens"
	cont "all other senses!"

	para "The dragon masters"
	line "aren't the only"
	cont "tough trainers"
	cont "in this city!"
	done

SuperNerdDaveSeenText:
	text "Fascinating! This"
	line "cave connects to"
	cont "Route 31!"

	para "I'm studying how"
	line "#MON navigate"
	cont "in total darkness."

	para "Care to be a test"
	line "subject?"
	done

SuperNerdDaveBeatenText:
	text "Remarkable data!"
	done

SuperNerdDaveAfterBattleText:
	text "Did you know some"
	line "#MON use echo-"
	cont "location here?"

	para "ZUBAT family and"
	line "others have"
	cont "adapted perfectly!"

	para "The cave's unique"
	line "environment makes"
	cont "it a natural lab!"

	para "I'm documenting"
	line "every species I"
	cont "encounter here."
	done

DarkCaveBlackthornEntrancePharmacistText1:
	text "Whoa! You startled"
	line "me there!"

	para "I had my BLACK-"
	line "GLASSES on, so I"

	para "didn't notice you"
	line "at all."

	para "What am I doing"
	line "here?"

	para "Hey, don't you"
	line "worry about it."

	para "I'll give you a"
	line "pair of BLACK-"
	cont "GLASSES, so forget"
	cont "you saw me, OK?"
	done

DarkCaveBlackthornEntrancePharmacistText2:
	text "BLACKGLASSES ups"
	line "the power of dark-"
	cont "type moves."
	done

DarkCaveBlackthornEntrance_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 23,  3, ROUTE_45, 1
	warp_event  3, 25, DARK_CAVE_VIOLET_ENTRANCE, 2

	def_coord_events

	def_bg_events

	def_object_events
	object_event  7,  3, SPRITE_PHARMACIST, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, DarkCaveBlackthornEntrancePharmacistScript, -1
	object_event 21, 24, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, DarkCaveBlackthornEntranceRevive, EVENT_DARK_CAVE_BLACKTHORN_ENTRANCE_REVIVE
	object_event  7, 22, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, DarkCaveBlackthornEntranceMistStone, EVENT_DARK_CAVE_BLACKTHORN_ENTRANCE_MIST_STONE
	object_event 15, 10, SPRITE_ENTEI_MON, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, Entei, EVENT_DARK_CAVE_ENTEI
	object_event 22, 21, SPRITE_BLACK_BELT, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 2, TrainerBlackbeltDomun, -1
	object_event  8, 13, SPRITE_SUPER_NERD, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 3, TrainerSuperNerdDave, -1

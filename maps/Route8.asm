	object_const_def
	const ROUTE8_BIKER1
	const ROUTE8_BIKER2
	const ROUTE8_BIKER3
	const ROUTE8_SUPER_NERD1
	const ROUTE8_SUPER_NERD2
	const ROUTE8_FRUIT_TREE
	const ROUTE8_POKEFAN_M1
	const ROUTE8_BIG_SNORLAX
	const ROUTE8_POKEFAN_M2

Route8_MapScripts:
	def_scene_scripts

	def_callbacks

Route8Snorlax:
	opentext
	special SnorlaxAwake
	iftrue .Awake
	writetext Route8SnorlaxSleepingText
	waitbutton
	closetext
	end

.Awake:
	writetext Route8RadioNearSnorlaxText
	pause 15
	cry SNORLAX
	closetext
	loadvar VAR_BATTLETYPE, BATTLETYPE_FORCEITEM
	loadwildmon SNORLAX, 50
	startbattle
	disappear ROUTE8_BIG_SNORLAX
	setevent EVENT_FOUGHT_SNORLAX
	reloadmapafterbattle
	end

Route8SnorlaxSleepingText:
	text "SNORLAX is snoring"
	line "peacefully…"
	done

Route8RadioNearSnorlaxText:
	text "The #GEAR was"
	line "placed near the"
	cont "sleeping SNORLAX…"

	para "…"

	para "SNORLAX woke up!"
	done

TrainerBikerDwayne:
	trainer BIKER, DWAYNE, EVENT_BEAT_BIKER_DWAYNE, BikerDwayneSeenText, BikerDwayneBeatenText, 0, .Script

.Script:
	opentext
	writetext BikerDwayneAfterBattleText
	waitbutton
	closetext
	end

BikerDwayneSeenText:
	text "We're the KANTO"
	line "#MON FEDERATION"
	cont "trainer group."

	para "We'll drive you"
	line "under our wheels!"
	done

BikerDwayneBeatenText:
	text "S-sorry!"
	done

BikerDwayneAfterBattleText:
	text "The KANTO #MON"
	line "FEDERATION will"
	cont "never fall!"
	done

TrainerBikerHarris:
	trainer BIKER, HARRIS, EVENT_BEAT_BIKER_HARRIS, BikerHarrisSeenText, BikerHarrisBeatenText, 0, .Script

.Script:
	opentext
	writetext BikerHarrisAfterBattleText
	waitbutton
	closetext
	end

BikerHarrisSeenText:
	text "The cops shut down"
	line "our UNDERGROUND"

	para "PATH! That really"
	line "fries me!"
	done

BikerHarrisBeatenText:
	text "F-forgive me!"
	done

BikerHarrisAfterBattleText:
	text "Wiped out by some"
	line "punk from JOHTO…"
	done

TrainerBikerZeke:
	trainer BIKER, ZEKE, EVENT_BEAT_BIKER_ZEKE, BikerZekeSeenText, BikerZekeBeatenText, 0, .Script

.Script:
	opentext
	writetext BikerZekeAfterBattleText
	waitbutton
	closetext
	end

BikerZekeSeenText:
	text "We're the KANTO"
	line "#MON FEDERA-"
	cont "TION!"
	cont "Right on!"
	done

BikerZekeBeatenText:
	text "Yikes! Sorry!"
	done

BikerZekeAfterBattleText:
	text "We'll try not to"
	line "disturb anyone"
	cont "from now on…"
	done

TrainerSuperNerdSam:
	trainer SUPER_NERD, SAM, EVENT_BEAT_SUPER_NERD_SAM, SuperNerdSamSeenText, SuperNerdSamBeatenText, 0, .Script

.Script:
	opentext
	writetext SuperNerdSamAfterBattleText
	waitbutton
	closetext
	end

SuperNerdSamSeenText:
	text "How does the MAG-"
	line "NET TRAIN work?"
	done

SuperNerdSamBeatenText:
	text "I just want to see"
	line "the MAGNET TRAIN…"
	done

SuperNerdSamAfterBattleText:
	text "The power of mag-"
	line "nets is awesome!"
	done

TrainerSuperNerdTom:
	trainer SUPER_NERD, TOM, EVENT_BEAT_SUPER_NERD_TOM, SuperNerdTomSeenText, SuperNerdTomBeatenText, 0, .Script

.Script:
	opentext
	writetext SuperNerdTomAfterBattleText
	waitbutton
	closetext
	end

SuperNerdTomSeenText:
	text "Hm… You've got"
	line "many GYM BADGES."
	done

SuperNerdTomBeatenText:
	text "Just as I thought…"
	line "You're tough!"
	done

SuperNerdTomAfterBattleText:
	text "GYM BADGES no"
	line "longer give you"
	cont "advantages in"
	cont "battles."
	done

TrainerPokefanMJerred:
    trainer POKEFANM, JERRED, EVENT_BEAT_POKEFANM_JERRED, PokefanMJerredSeenText, PokefanMJerredBeatenText, 0, .Script

.Script:
    opentext
    writetext PokefanMJerredAfterBattleText
    waitbutton
    closetext
    end

PokefanMJerredSeenText:
    text "I just love cute"
    line "#MON so much!"

    para "My collection of"
    line "adorable #MON"
    cont "is the best!"

    para "Want to see them"
    line "in action?"
    done

PokefanMJerredBeatenText:
    text "Even in defeat,"
    line "they're still"
    cont "adorable!"
    done

PokefanMJerredAfterBattleText:
    text "Cuteness isn't"
    line "everything in"
    cont "battle, I guess."

    para "But my #MON are"
    line "still the cutest"
    cont "around!"
    done

Route8PokefanMScript:
	faceplayer
	opentext
	checkevent EVENT_BEAT_ROCKET_GRUNTM_31
	iffalse .RoadClosed
	writetext Route8RocketSeenText
	waitbutton
	closetext
	winlosstext Route8RocketBeaten_Text, 0
	loadtrainer GRUNTM, GRUNTM_3
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_ROCKET_GRUNTM_3
	opentext
	writetext Route8RocketLeaves_Text
	waitbutton
	closetext
	applymovement ROUTE8_POKEFAN_M2, Route8PokefanMovement
	playsound SFX_ENTER_DOOR
	disappear ROUTE8_POKEFAN_M2
	waitsfx
	end

.RoadClosed
	writetext Route8PokefanMText
	waitbutton
	closetext
	end

Route8PokefanMovement:
	step UP
	step_end

Route8RocketSeenText:
	text "Someone told you"
	line "about the secret"
	cont "underground path?"

	para "That idiot …"

	para "I suppose I'll"
	line "have to deal with"
	cont "you."
	done

Route8RocketBeaten_Text:
	text "What? I lost to"
	line "some brat?"
	done

Route8RocketLeaves_Text:
	text "I need to warn the"
	line "bosses. There's no"
	cont "way you will beat"
	cont "our entire crew."
	done

Route8PokefanMText:
	text "The road is closed"
	line "until the problem"

	para "at the POWER PLANT"
	line "is solved."
	done

Route8UndergroundPathSign:
	jumptext Route8UndergroundPathSignText

Route8UndergroundPathSignText:
	text "The flyer's torn."

	para "It's impossible to"
	line "read…"
	done

Route8FruitTree:
	fruittree FRUITTREE_ROUTE_8

Route8_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4,  4, ROUTE_8_SAFFRON_GATE, 3
	warp_event  4,  5, ROUTE_8_SAFFRON_GATE, 4
	warp_event 10,  5, ROUTE_8_UNDERGROUND_PATH_ENTRANCE, 1

	def_coord_events

	def_bg_events
	bg_event 11,  7, BGEVENT_READ, Route8UndergroundPathSign

	def_object_events
	object_event 10,  8, SPRITE_BIKER, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 5, TrainerBikerDwayne, -1
	object_event 10,  9, SPRITE_BIKER, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_TRAINER, 5, TrainerBikerHarris, -1
	object_event 10, 10, SPRITE_BIKER, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 5, TrainerBikerZeke, -1
	object_event 23,  2, SPRITE_SUPER_NERD, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 3, TrainerSuperNerdSam, -1
	object_event 31, 12, SPRITE_SUPER_NERD, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 4, TrainerSuperNerdTom, -1
	object_event 33,  5, SPRITE_FRUIT_TREE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Route8FruitTree, -1
	object_event 16, 11, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 4, TrainerPokefanMJerred, -1
	object_event 34,  8, SPRITE_BIG_SNORLAX, SPRITEMOVEDATA_BIGDOLLSYM, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Route8Snorlax, EVENT_ROUTE8_SNORLAX
	object_event 10,  6, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, Route8PokefanMScript, EVENT_BEAT_ROCKET_GRUNTM_3

	object_const_def
	const ROUTE38_STANDING_YOUNGSTER1
	const ROUTE38_LASS
	const ROUTE38_STANDING_YOUNGSTER2
	const ROUTE38_BEAUTY1
	const ROUTE38_SAILOR
	const ROUTE38_FRUIT_TREE
	const ROUTE38_BEAUTY2
	const ROUTE38_TAUROS_1
	const ROUTE38_TAUROS_2
	const ROUTE38_TAUROS_3
	const ROUTE38_TAUROS_4
	const ROUTE38_TAUROS_5
	const ROUTE38_TAUROS_6
	const ROUTE38_TAUROS_7
	const ROUTE38_TAUROS_8
	const ROUTE38_TAUROS_9
	const ROUTE38_TAUROS_10

Route38_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_TILES, .Route38WildHunt

.Route38WildHunt
	checkevent EVENT_QUELLED_WILD_HUNT
	iffalse .UnlockGate
	changeblock 35, 8, $01 ; ground
	changeblock 35, 9, $01 ; ground
.UnlockGate
	endcallback

TrainerBirdKeeperToby:
	trainer BIRD_KEEPER, TOBY, EVENT_BEAT_BIRD_KEEPER_TOBY, BirdKeeperTobySeenText, BirdKeeperTobyBeatenText, 0, .Script

.Script
	opentext
	writetext BirdKeeperTobyAfterBattleText
	waitbutton
	closetext
	end

TrainerSailorHarry:
	trainer SAILOR, HARRY, EVENT_BEAT_SAILOR_HARRY, SailorHarrySeenText, SailorHarryBeatenText, 0, .Script

.Script
	opentext
	writetext SailorHarryAfterBattleText
	waitbutton
	closetext
	end

TrainerLassDana1:
	trainer LASS, DANA1, EVENT_BEAT_LASS_DANA, LassDana1SeenText, LassDana1BeatenText, 0, .Script

.Script
	loadvar VAR_CALLERID, PHONE_LASS_DANA
	opentext
	checkflag ENGINE_DANA_READY_FOR_REMATCH
	iftrue .DanaRematch
	checkflag ENGINE_DANA_HAS_THUNDERSTONE
	iftrue .TryGiveThunderstone
	checkcellnum PHONE_LASS_DANA
	iftrue .NumberAccepted
	checkevent EVENT_DANA_ASKED_FOR_PHONE_NUMBER
	iftrue .SecondTimeAsking
	writetext LassDanaMoomooMilkText
	promptbutton
	setevent EVENT_DANA_ASKED_FOR_PHONE_NUMBER
	scall .AskNumber1F
	sjump .AskForPhoneNumber

.SecondTimeAsking:
	scall .AskNumber2F
.AskForPhoneNumber:
	askforphonenumber PHONE_LASS_DANA
	ifequal PHONE_CONTACTS_FULL, .PhoneFull
	ifequal PHONE_CONTACT_REFUSED, .DeclinedPhoneNumber
	gettrainername STRING_BUFFER_3, LASS, DANA1
	scall .RegisteredPhoneNumber
	sjump .NumberAccepted

.DanaRematch:
	scall .Rematch
	winlosstext LassDana1BeatenText, 0
	checkevent EVENT_CLEARED_RADIO_TOWER
	iftrue .LoadFight4
	checkflag ENGINE_FLYPOINT_CIANWOOD
	iftrue .LoadFight3
; fallthrough
	loadtrainer LASS, DANA2
	startbattle
	reloadmapafterbattle
	clearflag ENGINE_DANA_READY_FOR_REMATCH
	end

.LoadFight3:
	loadtrainer LASS, DANA3
	startbattle
	reloadmapafterbattle
	clearflag ENGINE_DANA_READY_FOR_REMATCH
	end

.LoadFight4:
	loadtrainer LASS, DANA4
	startbattle
	reloadmapafterbattle
	clearflag ENGINE_DANA_READY_FOR_REMATCH
	end

.TryGiveThunderstone:
	scall .Gift
	verbosegiveitem THUNDERSTONE, 3
	iffalse .NoRoomForThunderstone
	clearflag ENGINE_DANA_HAS_THUNDERSTONE
	setevent EVENT_DANA_GAVE_THUNDERSTONE
	sjump .NumberAccepted

.NoRoomForThunderstone:
	sjump .PackFull

.AskNumber1F:
	jumpstd AskNumber1FScript
	end

.AskNumber2F:
	jumpstd AskNumber2FScript
	end

.RegisteredPhoneNumber:
	jumpstd RegisteredNumberFScript
	end

.NumberAccepted:
	jumpstd NumberAcceptedFScript
	end

.DeclinedPhoneNumber:
	jumpstd NumberDeclinedFScript
	end

.PhoneFull:
	jumpstd PhoneFullFScript
	end

.Rematch:
	jumpstd RematchFScript
	end

.Gift:
	jumpstd GiftFScript
	end

.PackFull:
	jumpstd PackFullFScript
	end

TrainerSchoolboyChad1:
	trainer SCHOOLBOY, CHAD1, EVENT_BEAT_SCHOOLBOY_CHAD, SchoolboyChad1SeenText, SchoolboyChad1BeatenText, 0, .Script

.Script
	loadvar VAR_CALLERID, PHONE_SCHOOLBOY_CHAD
	opentext
	checkflag ENGINE_CHAD_READY_FOR_REMATCH
	iftrue .ChadRematch
	checkcellnum PHONE_SCHOOLBOY_CHAD
	iftrue .HaveChadsNumber
	checkevent EVENT_CHAD_ASKED_FOR_PHONE_NUMBER
	iftrue .SecondTimeAsking
	writetext SchoolboyChadSoManyTestsText
	promptbutton
	setevent EVENT_CHAD_ASKED_FOR_PHONE_NUMBER
	scall .AskPhoneNumber1
	sjump .AskToRegisterNumber

.SecondTimeAsking:
	scall .AskPhoneNumber2
.AskToRegisterNumber:
	askforphonenumber PHONE_SCHOOLBOY_CHAD
	ifequal PHONE_CONTACTS_FULL, .PhoneFull
	ifequal PHONE_CONTACT_REFUSED, .SaidNo
	gettrainername STRING_BUFFER_3, SCHOOLBOY, CHAD1
	scall .RegisteredChad
	sjump .HaveChadsNumber

.ChadRematch:
	scall .Rematch
	winlosstext SchoolboyChad1BeatenText, 0
	checkevent EVENT_CLEARED_RADIO_TOWER
	iftrue .LoadFight4
	checkflag ENGINE_FLYPOINT_MAHOGANY
	iftrue .LoadFight3
; fallthrough
	loadtrainer SCHOOLBOY, CHAD2
	startbattle
	reloadmapafterbattle
	clearflag ENGINE_CHAD_READY_FOR_REMATCH
	end

.LoadFight3:
	loadtrainer SCHOOLBOY, CHAD3
	startbattle
	reloadmapafterbattle
	clearflag ENGINE_CHAD_READY_FOR_REMATCH
	end

.LoadFight4:
	loadtrainer SCHOOLBOY, CHAD4
	startbattle
	reloadmapafterbattle
	clearflag ENGINE_CHAD_READY_FOR_REMATCH
	end

.AskPhoneNumber1:
	jumpstd AskNumber1MScript
	end

.AskPhoneNumber2:
	jumpstd AskNumber2MScript
	end

.RegisteredChad:
	jumpstd RegisteredNumberMScript
	end

.HaveChadsNumber:
	jumpstd NumberAcceptedMScript
	end

.SaidNo:
	jumpstd NumberDeclinedMScript
	end

.PhoneFull:
	jumpstd PhoneFullMScript
	end

.Rematch:
	jumpstd RematchMScript
	end

TrainerBeautyValerie:
	trainer BEAUTY, VALERIE, EVENT_BEAT_BEAUTY_VALERIE, BeautyValerieSeenText, BeautyValerieBeatenText, 0, .Script

.Script
	opentext
	writetext BeautyValerieAfterBattleText
	waitbutton
	closetext
	end

TrainerBeautyOlivia:
	trainer BEAUTY, OLIVIA, EVENT_BEAT_BEAUTY_OLIVIA, BeautyOliviaSeenText, BeautyOliviaBeatenText, 0, .Script

.Script
	opentext
	writetext BeautyOliviaAfterBattleText
	waitbutton
	closetext
	end

WildHuntTauros1:
	faceplayer
	showemote EMOTE_SAD, ROUTE38_TAUROS_1, 35
	opentext
	writetext WildHuntTauros_Text
	cry TAUROS
	pause 15
	closetext
	setevent EVENT_FOUGHT_WILD_HUNT_TAUROS_1
	loadvar VAR_BATTLETYPE, BATTLETYPE_WILD_HUNT
	loadwildmon TAUROS, 35
	startbattle
	disappear ROUTE38_TAUROS_1
	reloadmapafterbattle
	end

WildHuntTauros2:
	faceplayer
	showemote EMOTE_SAD, ROUTE38_TAUROS_2, 35
	opentext
	writetext WildHuntTauros_Text
	cry TAUROS
	pause 15
	closetext
	setevent EVENT_FOUGHT_WILD_HUNT_TAUROS_2
	loadvar VAR_BATTLETYPE, BATTLETYPE_WILD_HUNT
	loadwildmon TAUROS, 35
	startbattle
	disappear ROUTE38_TAUROS_2
	reloadmapafterbattle
	end

WildHuntTauros3:
	faceplayer
	showemote EMOTE_SAD, ROUTE38_TAUROS_3, 35
	opentext
	writetext WildHuntTauros_Text
	cry TAUROS
	pause 15
	closetext
	setevent EVENT_FOUGHT_WILD_HUNT_TAUROS_3
	loadvar VAR_BATTLETYPE, BATTLETYPE_WILD_HUNT
	loadwildmon TAUROS, 35
	startbattle
	disappear ROUTE38_TAUROS_3
	reloadmapafterbattle
	end

WildHuntTauros4:
	faceplayer
	showemote EMOTE_SAD, ROUTE38_TAUROS_4, 35
	opentext
	writetext WildHuntTauros_Text
	cry TAUROS
	pause 15
	closetext
	setevent EVENT_FOUGHT_WILD_HUNT_TAUROS_4
	loadvar VAR_BATTLETYPE, BATTLETYPE_WILD_HUNT
	loadwildmon TAUROS, 35
	startbattle
	disappear ROUTE38_TAUROS_4
	reloadmapafterbattle
	end

WildHuntTauros5:
	faceplayer
	showemote EMOTE_SAD, ROUTE38_TAUROS_5, 35
	opentext
	writetext WildHuntTauros_Text
	cry TAUROS
	pause 15
	closetext
	setevent EVENT_FOUGHT_WILD_HUNT_TAUROS_5
	loadvar VAR_BATTLETYPE, BATTLETYPE_WILD_HUNT
	loadwildmon TAUROS, 35
	startbattle
	disappear ROUTE38_TAUROS_5
	reloadmapafterbattle
	end

WildHuntTauros6:
	faceplayer
	showemote EMOTE_SAD, ROUTE38_TAUROS_6, 35
	opentext
	writetext WildHuntTauros_Text
	cry TAUROS
	pause 15
	closetext
	setevent EVENT_FOUGHT_WILD_HUNT_TAUROS_6
	loadvar VAR_BATTLETYPE, BATTLETYPE_WILD_HUNT
	loadwildmon TAUROS, 35
	startbattle
	disappear ROUTE38_TAUROS_6
	reloadmapafterbattle
	end

WildHuntTauros7:
	faceplayer
	showemote EMOTE_SAD, ROUTE38_TAUROS_7, 35
	opentext
	writetext WildHuntTauros_Text
	cry TAUROS
	pause 15
	closetext
	setevent EVENT_FOUGHT_WILD_HUNT_TAUROS_7
	loadvar VAR_BATTLETYPE, BATTLETYPE_WILD_HUNT
	loadwildmon TAUROS, 35
	startbattle
	disappear ROUTE38_TAUROS_7
	reloadmapafterbattle
	end

WildHuntTauros8:
	faceplayer
	showemote EMOTE_SAD, ROUTE38_TAUROS_8, 35
	opentext
	writetext WildHuntTauros_Text
	cry TAUROS
	pause 15
	closetext
	setevent EVENT_FOUGHT_WILD_HUNT_TAUROS_8
	loadvar VAR_BATTLETYPE, BATTLETYPE_WILD_HUNT
	loadwildmon TAUROS, 35
	startbattle
	disappear ROUTE38_TAUROS_8
	reloadmapafterbattle
	end

WildHuntTauros9:
	faceplayer
	showemote EMOTE_SAD, ROUTE38_TAUROS_9, 35
	opentext
	writetext WildHuntTauros_Text
	cry TAUROS
	pause 15
	closetext
	setevent EVENT_FOUGHT_WILD_HUNT_TAUROS_9
	loadvar VAR_BATTLETYPE, BATTLETYPE_WILD_HUNT
	loadwildmon TAUROS, 35
	startbattle
	disappear ROUTE38_TAUROS_9
	reloadmapafterbattle
	end

WildHuntTauros10:
	faceplayer
	showemote EMOTE_SAD, ROUTE38_TAUROS_10, 35
	opentext
	writetext WildHuntTauros_Text
	cry TAUROS
	pause 15
	closetext
	setevent EVENT_FOUGHT_WILD_HUNT_TAUROS_10
	loadvar VAR_BATTLETYPE, BATTLETYPE_WILD_HUNT
	loadwildmon TAUROS, 35
	startbattle
	disappear ROUTE38_TAUROS_10
	reloadmapafterbattle
	end

Route38Sign:
	jumptext Route38SignText

Route38TrainerTips:
	jumptext Route38TrainerTipsText

Route38FruitTree:
	fruittree FRUITTREE_ROUTE_38

WildHuntTauros_Text:
	text "TAUROS: RRRGGH!"
	done

BirdKeeperTobySeenText:
	text "My bird #MON"
	line "were terrified"
	cont "during the WILD"
	cont "HUNT!"

	para "But they're ready"
	line "to battle now!"
	done

BirdKeeperTobyBeatenText:
	text "I feel like just"
	line "flying away now."
	done

BirdKeeperTobyAfterBattleText:
	text "The wild #MON"
	line "went berserk."

	para "Even the PIDGEY"
	line "and SPEAROW were"
	cont "acting strange."

	para "I'm grateful the"
	line "RANGERS handled"
	cont "it so quickly."
	done

SchoolboyChad1SeenText:
	text "School was closed"
	line "during the crisis!"

	para "Let me show you"
	line "what I practiced!"
	done

SchoolboyChad1BeatenText:
	text "I didn't study"
	line "enough, I guess."
	done

SchoolboyChadSoManyTestsText:
	text "We had to evacuate"
	line "to ECRUTEAK CITY."

	para "Seeing the RANGERS"
	line "and trainers work"

	para "together was more"
	line "educational than"
	cont "any class!"
	done

LassDana1SeenText:
	text "That WILD HUNT was"
	line "so scary!"

	para "But you helped"
	line "stop it, right?"
	done

LassDana1BeatenText:
	text "I see. So you can"
	line "battle that way."
	done

LassDanaMoomooMilkText:
	text "I heard MILTANK"
	line "at MOOMOO FARM"
	cont "was the key!"

	para "A healthy MILTANK"
	line "calmed the raging"
	cont "TAUROS herd."

	para "That's why their"
	line "milk is special!"
	done

BeautyValerieSeenText:
	text "After seeing those"
	line "angry #MON,"

	para "I really appreci-"
	line "ate kind trainers!"
	done

BeautyValerieBeatenText:
	text "I'm glad I got to"
	line "see your #MON!"
	done

BeautyValerieAfterBattleText:
	text "The WILD HUNT was"
	line "terrifying."

	para "But seeing well-"
	line "trained #MON"

	para "working with their"
	line "trainers was so"
	cont "reassuring."
	done

SailorHarrySeenText:
	text "I've sailed the"
	line "world, but I've"

	para "never seen wild"
	line "#MON go berserk"
	cont "like that!"
	done

SailorHarryBeatenText:
	text "Your skill is"
	line "world class!"
	done

SailorHarryAfterBattleText:
	text "In all my travels,"
	line "I've seen storms,"
	cont "whirlpools, even"
	cont "TENTACRUEL swarms."

	para "But a WILD HUNT?"
	line "That's such a rare"
	cont "phenomenon."
	done

BeautyOliviaSeenText:
	text "MOOMOO FARM almost"
	line "lost everything"
	cont "in the stampede!"
	done

BeautyOliviaBeatenText:
	text "We drink MOOMOO"
	line "MILK every day."
	done

BeautyOliviaAfterBattleText:
	text "Thank goodness"
	line "their MILTANK"
	cont "recovered in time!"

	para "Now the farm is"
	line "back to selling"

	para "their delicious"
	line "milk by the dozen!"
	done

Route38SignText:
	text "ROUTE 38"

	para "OLIVINE CITY -"
	line "ECRUTEAK CITY"
	done

Route38TrainerTipsText:
	text "TRAINER TIPS"

	para "If a #MON is"
	line "trying to evolve,"
	cont "you can stop it."

	para "Press the B But-"
	line "ton during evolu-"
	cont "tion."

	para "That startles the"
	line "#MON and stops"
	cont "its evolution."
	done

Route38_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 35,  8, ROUTE_38_ECRUTEAK_GATE, 1
	warp_event 35,  9, ROUTE_38_ECRUTEAK_GATE, 2

	def_coord_events

	def_bg_events
	bg_event 33,  7, BGEVENT_READ, Route38Sign
	bg_event  5, 13, BGEVENT_READ, Route38TrainerTips

	def_object_events
	object_event  4,  1, SPRITE_STANDING_YOUNGSTER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 1, TrainerSchoolboyChad1, EVENT_QUELLED_WILD_HUNT
	object_event 15,  3, SPRITE_LASS, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 2, TrainerLassDana1, EVENT_QUELLED_WILD_HUNT
	object_event 12, 15, SPRITE_STANDING_YOUNGSTER, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 1, TrainerBirdKeeperToby, EVENT_QUELLED_WILD_HUNT
	object_event 19,  9, SPRITE_BEAUTY, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 1, TrainerBeautyValerie, EVENT_QUELLED_WILD_HUNT
	object_event 24,  5, SPRITE_SAILOR, SPRITEMOVEDATA_SPINCOUNTERCLOCKWISE, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 2, TrainerSailorHarry, EVENT_QUELLED_WILD_HUNT
	object_event 12, 10, SPRITE_FRUIT_TREE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Route38FruitTree, -1
	object_event  5,  8, SPRITE_BEAUTY, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 1, TrainerBeautyOlivia, EVENT_QUELLED_WILD_HUNT
	object_event 30,  8, SPRITE_TAUROS, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, WildHuntTauros1, EVENT_FOUGHT_WILD_HUNT_TAUROS_1
	object_event 28, 11, SPRITE_TAUROS, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, WildHuntTauros2, EVENT_FOUGHT_WILD_HUNT_TAUROS_2
	object_event 15, 12, SPRITE_TAUROS, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, WildHuntTauros3, EVENT_FOUGHT_WILD_HUNT_TAUROS_3
	object_event 20, 14, SPRITE_TAUROS, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, WildHuntTauros4, EVENT_FOUGHT_WILD_HUNT_TAUROS_4
	object_event  8, 10, SPRITE_TAUROS, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, WildHuntTauros5, EVENT_FOUGHT_WILD_HUNT_TAUROS_5
	object_event 10,  5, SPRITE_TAUROS, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, WildHuntTauros6, EVENT_FOUGHT_WILD_HUNT_TAUROS_6
	object_event 13,  1, SPRITE_TAUROS, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, WildHuntTauros7, EVENT_FOUGHT_WILD_HUNT_TAUROS_7
	object_event 24,  3, SPRITE_TAUROS, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, WildHuntTauros8, EVENT_FOUGHT_WILD_HUNT_TAUROS_8
	object_event 22, 10, SPRITE_TAUROS, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, WildHuntTauros9, EVENT_FOUGHT_WILD_HUNT_TAUROS_9
	object_event  6, 14, SPRITE_TAUROS, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, WildHuntTauros10, EVENT_FOUGHT_WILD_HUNT_TAUROS_10

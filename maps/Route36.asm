	object_const_def
	const ROUTE36_YOUNGSTER1
	const ROUTE36_YOUNGSTER2
	const ROUTE36_OFFICER
	const ROUTE36_LASS1
	const ROUTE36_FISHER
	const ROUTE36_FRUIT_TREE
	const ROUTE36_ARTHUR
	const ROUTE36_SUICUNE
	const ROUTE36_LASS2
	const ROUTE36_UNOWN_C

Route36_MapScripts:
	def_scene_scripts
	scene_script Route36Noop1Scene, SCENE_ROUTE36_NOOP
	scene_script Route36Noop2Scene, SCENE_ROUTE36_SUICUNE

	def_callbacks

Route36Noop1Scene:
	end

Route36Noop2Scene:
	end

Route36SuicuneScript:
	showemote EMOTE_SHOCK, PLAYER, 15
	pause 15
	cry SUICUNE
	applymovement ROUTE36_SUICUNE, Route36SuicuneAttackUnownMovement
	pause 15
	cry UNOWN
	applymovement ROUTE36_UNOWN_C, Route36UnownDisappearMovement
	disappear ROUTE36_UNOWN_C
	setevent EVENT_FOUGHT_UNOWN_C ; CHANGED: Suicune drove it off; only random encounters remain
	pause 15
	playsound SFX_WARP_FROM
	turnobject PLAYER, UP
	applymovement ROUTE36_SUICUNE, Route36SuicuneMovement
	disappear ROUTE36_SUICUNE
	turnobject PLAYER, DOWN
	pause 10
	setscene SCENE_ROUTE36_NOOP
	clearevent EVENT_SAW_SUICUNE_AT_CIANWOOD_CITY
	setmapscene CIANWOOD_CITY, SCENE_CIANWOODCITY_SUICUNE_AND_KAREN
	setmapscene RUINS_OF_ALPH_RESEARCH_CENTER, SCENE_RUINSOFALPHRESEARCHCENTER_ELM_PRESENT
	end

Route36RangerScript:
	faceplayer
	opentext
	writetext Route36PokemonRangerText_BeforePlainBadge
	waitbutton
	closetext
	checkflag ENGINE_PLAINBADGE
	iftrue .HeadToEcruteak
	end

.HeadToEcruteak:
	showemote EMOTE_SHOCK, ROUTE36_OFFICER, 15
	opentext
	writetext PokemonRangerText_AfterPlainBadge_Departing
	waitbutton
	closetext
	turnobject ROUTE36_OFFICER, LEFT
	applymovement ROUTE36_OFFICER, Route36RangerMovement
	disappear ROUTE36_OFFICER
	setevent EVENT_SPOKE_WITH_ROUTE_36_RANGER
	end

Route36RockSmashGuyScript:
	faceplayer
	opentext
	checkevent EVENT_GOT_TM08_PURSUIT
	iftrue .AlreadyGotRockSmash
	checkevent EVENT_SPOKE_WITH_ROUTE_36_RANGER
	iftrue .ClearedRanger
	writetext RockSmashGuyText1
	waitbutton
	closetext
	end

.ClearedRanger:
	writetext RockSmashGuyText2
	promptbutton
	verbosegiveitem TM_PURSUIT, 3
	iffalse .NoRoomForTM
	setevent EVENT_GOT_TM08_PURSUIT
.AlreadyGotRockSmash:
	writetext RockSmashGuyText3
	waitbutton
.NoRoomForTM:
	closetext
	end

Route36LassScript:
	faceplayer
	opentext
	checkevent EVENT_SPOKE_WITH_ROUTE_36_RANGER
	iftrue .ClearedRanger
	writetext Route36LassText
	waitbutton
	closetext
	end

.ClearedRanger:
	writetext Route36LassText_ClearedRanger
	waitbutton
	closetext
	end

TrainerSchoolboyAlan1:
	trainer SCHOOLBOY, ALAN1, EVENT_BEAT_SCHOOLBOY_ALAN, SchoolboyAlan1SeenText, SchoolboyAlan1BeatenText, 0, .Script

.Script:
	loadvar VAR_CALLERID, PHONE_SCHOOLBOY_ALAN
	opentext
	checkflag ENGINE_ALAN_READY_FOR_REMATCH
	iftrue .ChooseRematch
	checkflag ENGINE_ALAN_HAS_FIRE_STONE
	iftrue .GiveFireStone
	checkcellnum PHONE_SCHOOLBOY_ALAN
	iftrue .NumberAccepted
	checkevent EVENT_ALAN_ASKED_FOR_PHONE_NUMBER
	iftrue .AskAgainForPhoneNumber
	writetext SchoolboyAlanBooksText
	promptbutton
	setevent EVENT_ALAN_ASKED_FOR_PHONE_NUMBER
	scall .AskNumber1
	sjump .ContinueAskForPhoneNumber

.AskAgainForPhoneNumber:
	scall .AskNumber2
.ContinueAskForPhoneNumber:
	askforphonenumber PHONE_SCHOOLBOY_ALAN
	ifequal PHONE_CONTACTS_FULL, .PhoneFull
	ifequal PHONE_CONTACT_REFUSED, .NumberDeclined
	gettrainername STRING_BUFFER_3, SCHOOLBOY, ALAN1
	scall .RegisteredNumber
	sjump .NumberAccepted

.ChooseRematch:
	scall .Rematch
	winlosstext SchoolboyAlan1BeatenText, 0
	checkflag ENGINE_FLYPOINT_BLACKTHORN
	iftrue .LoadFight4
	checkflag ENGINE_FLYPOINT_OLIVINE
	iftrue .LoadFight3
; fallthrough
	loadtrainer SCHOOLBOY, ALAN2
	startbattle
	reloadmapafterbattle
	clearflag ENGINE_ALAN_READY_FOR_REMATCH
	end

.LoadFight3:
	loadtrainer SCHOOLBOY, ALAN3
	startbattle
	reloadmapafterbattle
	clearflag ENGINE_ALAN_READY_FOR_REMATCH
	end

.LoadFight4:
	loadtrainer SCHOOLBOY, ALAN4
	startbattle
	reloadmapafterbattle
	clearflag ENGINE_ALAN_READY_FOR_REMATCH
	end

.GiveFireStone:
	scall .Gift
	verbosegiveitem FIRE_STONE, 3
	iffalse .BagFull
	clearflag ENGINE_ALAN_HAS_FIRE_STONE
	setevent EVENT_ALAN_GAVE_FIRE_STONE
	sjump .NumberAccepted

.BagFull:
	sjump .PackFull

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

.Rematch:
	jumpstd RematchMScript
	end

.Gift:
	jumpstd GiftMScript
	end

.PackFull:
	jumpstd PackFullMScript
	end

TrainerLassNoni:
	trainer LASS, NONI, EVENT_BEAT_LASS_NONI, LassNoniSeenText, LassNoniBeatenText, 0, .Script
.Script:
	opentext
	writetext LassNoniAfterBattleText
	waitbutton
	closetext
	end

TrainerPsychicMark:
	trainer PSYCHIC_T, MARK, EVENT_BEAT_PSYCHIC_MARK, PsychicMarkSeenText, PsychicMarkBeatenText, 0, .Script
.Script:
	opentext
	writetext PsychicMarkAfterBattleText
	waitbutton
	closetext
	end

ArthurScript:
	faceplayer
	opentext
	checkevent EVENT_GOT_HARD_STONE_FROM_ARTHUR
	iftrue ArthurGaveStoneScript
	readvar VAR_WEEKDAY
	ifequal THURSDAY, .GiveHardStone
	writetext ArthurSeenText
	waitbutton
	closetext
	winlosstext ArthurBeatenText, ArthurWinsText
	loadtrainer YOUNGSTER, ARTHUR
	startbattle
	reloadmapafterbattle
	opentext
.GiveHardStone:
	writetext ArthurGivesGiftText
	promptbutton
	verbosegiveitem HARD_STONE
	iffalse ArthurDoneScript
	setevent EVENT_GOT_HARD_STONE_FROM_ARTHUR
	writetext ArthurGaveGiftText
	waitbutton
	closetext
	end

ArthurGaveStoneScript:
	writetext ArthurGaveStoneText
	waitbutton
ArthurDoneScript:
	closetext
	end

Route36Sign:
	jumptext Route36SignText

RuinsOfAlphNorthSign:
	jumptext RuinsOfAlphNorthSignText

Route36TrainerTips1:
	jumptext Route36TrainerTips1Text

Route36TrainerTips2:
	jumptext Route36TrainerTips2Text

Route36FruitTree:
	fruittree FRUITTREE_ROUTE_36

Route36RangerMovement:
	step LEFT
	step LEFT
	step LEFT
	step UP
	step UP
	step LEFT
	step UP
	step UP
	step UP
	step_end

Route36SuicuneAttackUnownMovement:
	fix_facing
	big_step UP
	big_step DOWN
	remove_fixed_facing
	step_end

Route36UnownDisappearMovement:
	rock_smash 30
	step_end

Route36SuicuneMovement:
	set_sliding
	fast_jump_step DOWN
	fast_jump_step DOWN
	fast_jump_step DOWN
	fast_jump_step RIGHT
	fast_jump_step RIGHT
	fast_jump_step RIGHT
	remove_sliding
	step_end

Route36PokemonRangerText_BeforePlainBadge:
	text "HALT!"

	para "I'm a #MON"
	line "RANGER stationed"
	cont "here by emergency"
	cont "order."

	para "The routes west of"
	line "ECRUTEAK CITY are"
	cont "extremely perilous"
	cont "right now."

	para "We're restricting"
	line "access to everyone"
	cont "but proven #MON"
	cont "trainers."
	done

PokemonRangerText_AfterPlainBadge_Departing:
	text "You have the"
	line "PLAINBADGE?"

	para "You might strong"
	line "enough to help!"

	para "I must report this"
	line "to ECRUTEAK at"
	cont "once."

	para "Head there as soon"
	line "as you can. They"
	cont "need every capable"
	cont "trainer available!"
	done

RockSmashGuyText1:
	text "Wa-hey!"

	para "I was going to"
	line "battle that"

	para "#MON RANGER"
	line "blocking the road."

	para "But he refused!"

	para "Can he do that?"
	done

RockSmashGuyText2:
	text "Did you get past"
	line "that stubborn"
	cont "RANGER?"

	para "I'm impressed!"
	line "I want you to"
	cont "have this."
	done

RockSmashGuyText3:
	text "That happens to be"
	line "PURSUIT."

	para "You can chase down"
	line "enemies trying to"

	para "switch out or wild"
	line "#MON trying to"
	cont "flee."

	para "If they do, the"
	line "attack will be"
	cont "twice as strong!"
	done

Route36LassText:
	text "There is a #MON"
	line "RANGER is guarding"
	cont "the path to"
	cont "GOLDENROD CITY."

	para "It's preventing"
	line "me from shopping."

	para "Something should"
	line "be done about it."
	done

Route36LassText_ClearedRanger:
	text "That man ran off"
	line "so quickly."

	para "Oh! He had to go"
	line "to ECRUTEAK?"
	done

LassNoniSeenText:
	text "You're going to"
	line "talk to the RANGER"
	cont "at the crossroad?"
	done

LassNoniBeatenText:
	text "Better you than"
	line "me!"
	done

LassNoniAfterBattleText:
	text "What did the"
	line "RANGER say?"
	done

PsychicMarkSeenText:
	text "I'm going to read"
	line "your thoughts!"
	done

PsychicMarkBeatenText:
	text "I misread you!"
	done

PsychicMarkAfterBattleText:
	text "I'd be strong if"
	line "only I could tell"

	para "what my opponent"
	line "was thinking."
	done

SchoolboyAlan1SeenText:
	text "Thanks to my stud-"
	line "ies, I'm ready for"
	cont "any #MON!"
	done

SchoolboyAlan1BeatenText:
	text "Oops! Computation"
	line "error?"
	done

SchoolboyAlanBooksText:
	text "Darn. I study five"
	line "hours a day too."

	para "There's more to"
	line "learning than just"
	cont "reading books."
	done

ArthurSeenText:
	text "ARTHUR: Who are"
	line "you?"

	para "I'm ARTHUR of"
	line "Thursday."

    para "That's when I hand"
    line "out HARD STONES to"
    cont "anybody who asks."

	para "Today? You'll have"
	line "to battle for it."
	done

ArthurBeatenText:
	text "Well done."
	done

ArthurWinsText:
	text "Come back another"
	line "day."
	done

ArthurGivesGiftText:
	text "Here. You can have"
	line "this."
	done

ArthurGaveStoneText:
	text "ARTHUR: I'm the"
	line "second son out of"
    cont "seven children."

	para "Don't tell MONICA,"
	line "but SANTOS is my"
	cont "favorite sibling."
	done

ArthurGaveGiftText:
	text "ARTHUR: A #MON"
	line "that uses rock-"

	para "type moves should"
	line "hold on to that."

	para "It pumps up rock-"
	line "type attacks."
	done

Route36SignText:
	text "ROUTE 36"
	done

RuinsOfAlphNorthSignText:
	text "RUINS OF ALPH"
	line "NORTH ENTRANCE"
	done

Route36TrainerTips1Text:
	text "TRAINER TIPS"

	para "#MON stats"
	line "vary--even within"
	cont "the same species."

	para "Their stats may be"
	line "similar at first."

	para "However, differ-"
	line "ences will become"

	para "pronounced as the"
	line "#MON grow."
	done

Route36TrainerTips2Text:
	text "TRAINER TIPS"

	para "Use DIG to return"
	line "to the entrance of"
	cont "any place."

	para "It is convenient"
	line "for exploring"

	para "caves and other"
	line "landmarks."
	done

Route36_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  6,  8, ROUTE_36_NATIONAL_PARK_GATE, 3
	warp_event  6,  9, ROUTE_36_NATIONAL_PARK_GATE, 4
	warp_event 35, 13, ROUTE_36_RUINS_OF_ALPH_GATE, 1
	warp_event 36, 13, ROUTE_36_RUINS_OF_ALPH_GATE, 2

	def_coord_events
	coord_event  8,  7, SCENE_ROUTE36_SUICUNE, Route36SuicuneScript
	coord_event 10,  7, SCENE_ROUTE36_SUICUNE, Route36SuicuneScript

	def_bg_events
	bg_event 17,  1, BGEVENT_READ, Route36TrainerTips2
	bg_event 33, 11, BGEVENT_READ, RuinsOfAlphNorthSign
	bg_event 43,  7, BGEVENT_READ, Route36Sign
	bg_event  9,  7, BGEVENT_READ, Route36TrainerTips1

	def_object_events
	object_event  8, 13, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 3, TrainerPsychicMark, -1
	object_event 19, 14, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 5, TrainerSchoolboyAlan1, -1
	object_event 23,  9, SPRITE_OFFICER, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_SCRIPT, 0, Route36RangerScript, EVENT_ROUTE_36_RANGER
	object_event 39,  8, SPRITE_LASS, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 2, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Route36LassScript, -1
	object_event 32,  9, SPRITE_FISHER, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Route36RockSmashGuyScript, -1
	object_event  9,  4, SPRITE_FRUIT_TREE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Route36FruitTree, -1
	object_event 34,  6, SPRITE_YOUNGSTER, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ArthurScript, EVENT_ROUTE_36_ARTHUR_OF_THURSDAY
	object_event  9,  6, SPRITE_SUICUNE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_SAW_SUICUNE_ON_ROUTE_36
	object_event 28,  6, SPRITE_LASS, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_PURPLE, OBJECTTYPE_TRAINER, 5, TrainerLassNoni, -1
	object_event  9,  5, SPRITE_UNOWN_C, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_SAW_SUICUNE_ON_ROUTE_36

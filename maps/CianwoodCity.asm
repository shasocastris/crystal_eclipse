	object_const_def
	const CIANWOODCITY_STANDING_YOUNGSTER
	const CIANWOODCITY_POKEFAN_M
	const CIANWOODCITY_LASS
	const CIANWOODCITY_ROCK1
	const CIANWOODCITY_ROCK2
	const CIANWOODCITY_ROCK3
	const CIANWOODCITY_ROCK4
	const CIANWOODCITY_ROCK5
	const CIANWOODCITY_POKEFAN_F
	const CIANWOODCITY_KAREN
	const CIANWOODCITY_SUICUNE
    const CIANWOODCITY_SWIMMER_GIRL1
	const CIANWOODCITY_OLIVINE_RIVAL1
    const CIANWOODCITY_SWIMMER_GIRL2
	const CIANWOODCITY_OLIVINE_RIVAL2
    const CIANWOODCITY_SWIMMER_GIRL3
    const CIANWOODCITY_UNOWN_G

CianwoodCity_MapScripts:
	def_scene_scripts
	scene_script CianwoodCityNoop1Scene, SCENE_CIANWOODCITY_NOOP
	scene_script CianwoodCityNoop2Scene, SCENE_CIANWOODCITY_SUICUNE_AND_KAREN

	def_callbacks
	callback MAPCALLBACK_NEWMAP, CianwoodCityFlypointAndSuicuneCallback

CianwoodCityNoop1Scene:
	end

CianwoodCityNoop2Scene:
	end

CianwoodCityFlypointAndSuicuneCallback:
	setflag ENGINE_FLYPOINT_CIANWOOD
	setevent EVENT_KAREN_IN_BURNED_TOWER
	checkevent EVENT_FOUGHT_KAREN_AT_CIANWOOD
	iffalse .Done
	disappear CIANWOODCITY_KAREN
.Done:
	endcallback

CianwoodCitySuicuneAndKaren:
	turnobject PLAYER, UP
	showemote EMOTE_SHOCK, PLAYER, 15
	pause 15
	cry SUICUNE
	applymovement CIANWOODCITY_SUICUNE, CianwoodCitySuicuneAttackUnownMovement
	pause 15
	cry UNOWN
	applymovement CIANWOODCITY_UNOWN_G, CianwoodCityUnownDisappearMovement
	disappear CIANWOODCITY_UNOWN_G
	pause 15
	playsound SFX_WARP_FROM
	applymovement CIANWOODCITY_SUICUNE, CianwoodCitySuicuneApproachMovement
	turnobject PLAYER, DOWN
	pause 15
	playsound SFX_WARP_FROM
	applymovement CIANWOODCITY_SUICUNE, CianwoodCitySuicuneDepartMovement
	disappear CIANWOODCITY_SUICUNE
	pause 10
	setscene SCENE_CIANWOODCITY_NOOP
	clearevent EVENT_SAW_SUICUNE_ON_ROUTE_42
	setmapscene ROUTE_42, SCENE_ROUTE42_SUICUNE
	checkevent EVENT_FOUGHT_KAREN_AT_CIANWOOD
	iftrue .Done
	setevent EVENT_FOUGHT_KAREN_AT_CIANWOOD
	stowfollower
	playmusic MUSIC_MYSTICALMAN_ENCOUNTER
	appear CIANWOODCITY_KAREN
	applymovement CIANWOODCITY_KAREN, CianwoodCityKarenApproachMovement
	opentext
	writetext KarenSuicuneText
	waitbutton
	closetext
	winlosstext KarenBeatenText, KarenPlayerLostText
	setlasttalked CIANWOODCITY_KAREN
	loadtrainer KAREN, KAREN1
	loadvar VAR_BATTLETYPE, BATTLETYPE_CANLOSE
	startbattle
	dontrestartmapmusic
	reloadmap
	playmusic MUSIC_MYSTICALMAN_ENCOUNTER
	opentext
	writetext KarenAfterText
	waitbutton
	closetext
	applymovement CIANWOODCITY_KAREN, CianwoodCityKarenDepartMovement
	disappear CIANWOODCITY_KAREN
	pause 20
	special FadeOutMusic
	special HealParty
	playmapmusic
	pause 10
	appearfolloweronestep
.Done:
	end

CianwoodCityChucksWife:
	faceplayer
	opentext
	checkevent EVENT_GOT_HM02_FLY
	iftrue .GotFly
	writetext ChucksWifeEasierToFlyText
	promptbutton
	checkevent EVENT_BEAT_CHUCK
	iftrue .BeatChuck
	writetext ChucksWifeBeatChuckText
	waitbutton
	closetext
	end

.BeatChuck:
	writetext ChucksWifeGiveHMText
	promptbutton
	verbosegiveitem HM_FLY
	iffalse .Done
	setevent EVENT_GOT_HM02_FLY
	writetext ChucksWifeFlySpeechText
	promptbutton
.GotFly:
	writetext ChucksWifeChubbyText
	waitbutton
.Done:
	closetext
	end

TrainerSwimmerfKatie:
	trainer SWIMMERF, KATIE, EVENT_BEAT_SWIMMERF_KATIE, SwimmerfKatieSeenText, SwimmerfKatieBeatenText, 0, .Script

.Script:
	opentext
	writetext SwimmerfKatieAfterBattleText
	waitbutton
	closetext
	end

TrainerSwimmermPaton:
	trainer SWIMMERM, PATON, EVENT_BEAT_SWIMMERM_PATON, SwimmermPatonSeenText, SwimmermPatonBeatenText, 0, .Script

.Script:
	opentext
	writetext SwimmermPatonAfterBattleText
	waitbutton
	closetext
	end

CianwoodCityTrainerSwimmerfJill:
	end

CianwoodCityTrainerSwimmermHal:
	end

CianwoodCityTrainerSwimmerfMary:
	end

CianwoodCityYoungster:
	jumptextfaceplayer CianwoodCityYoungsterText

CianwoodCityPokefanM:
	jumptextfaceplayer CianwoodCityPokefanMText

CianwoodCityLass:
	jumptextfaceplayer CianwoodCityLassText

CianwoodCitySign:
	jumptext CianwoodCitySignText

CianwoodGymSign:
	jumptext CianwoodGymSignText

CianwoodPharmacySign:
	jumptext CianwoodPharmacySignText

CianwoodPhotoStudioSign:
	jumptext CianwoodPhotoStudioSignText

CianwoodPokeSeerSign:
	jumptext CianwoodPokeSeerSignText

CianwoodPokecenterSign:
	jumpstd PokecenterSignScript

CianwoodCityRock:
	jumpstd SmashRockScript

CianwoodCityHiddenRevive:
	hiddenitem REVIVE, EVENT_CIANWOOD_CITY_HIDDEN_REVIVE

CianwoodCityHiddenMaxEther:
	hiddenitem MAX_ETHER, EVENT_CIANWOOD_CITY_HIDDEN_MAX_ETHER

CianwoodCitySuicuneAttackUnownMovement:
	fix_facing
	big_step UP
	big_step DOWN
	remove_fixed_facing
	step_end

CianwoodCityUnownDisappearMovement:
	rock_smash 30
	step_end

CianwoodCitySuicuneApproachMovement:
	set_sliding
	fast_jump_step DOWN
	fast_jump_step DOWN
	fast_jump_step RIGHT
	remove_sliding
	step_end

CianwoodCitySuicuneDepartMovement:
	set_sliding
	fast_jump_step RIGHT
	fast_jump_step UP
	fast_jump_step RIGHT
	fast_jump_step RIGHT
	remove_sliding
	step_end

CianwoodCityKarenApproachMovement:
	step UP
	step UP
	step UP
	step UP
	step_end

CianwoodCityKarenDepartMovement:
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step_end

ChucksWifeEasierToFlyText:
	text "You crossed the"
	line "sea to get here?"

	para "That must have"
	line "been hard."

	para "It would be much"
	line "easier if your"

	para "#MON knew how"
	line "to FLY…"
	done

ChucksWifeBeatChuckText:
	text "But you can't use"
	line "FLY without this"
	cont "city's GYM BADGE."

	para "If you beat the"
	line "GYM LEADER here,"
	cont "come see me."

	para "I'll have a nice"
	line "gift for you."
	done

ChucksWifeGiveHMText:
	text "That's CIANWOOD's"
	line "GYM BADGE!"

	para "Then you should"
	line "take this HM."
	done

ChucksWifeFlySpeechText:
	text "Teach FLY to your"
	line "#MON."

	para "You will be able"
	line "to FLY instantly"

	para "to anywhere you"
	line "have visited."

	para "Like SURF and"
	line "STRENGTH, small"
	cont "flying #MON"
	cont "won't be able to"
	cont "bring you from"
	cont "city to city."
	done

ChucksWifeChubbyText:
	text "My husband lost to"
	line "you, so he needs"
	cont "to train harder."

	para "That's good, since"
	line "he was getting a"
	cont "little chubby."

	para "Have you found a"
	line "flying #MON"
	cont "large enough to"
	cont "take you across"
	cont "the sea?"
	done

CianwoodCityYoungsterText:
	text "If you use FLY,"
	line "you can get back"

	para "to OLIVINE in-"
	line "stantly."
	done

CianwoodCityPokefanMText:
	text "Boulders to the"
	line "north of town can"
	cont "be crushed."

	para "They may be hiding"
	line "something."

	para "Your #MON could"
	line "use ROCK SMASH to"
	cont "break them."
	done

CianwoodCityLassText:
	text "CHUCK, the GYM"
	line "LEADER, spars with"

	para "his fighting #-"
	line "MON."
	done

KarenSuicuneText:
	text "KAREN: Well, well."
	line "<PLAYER>."

	para "I heard about what"
	line "you did during the"
	cont "WILD HUNT."

	para "Impressive work."
	line "You saved ECRUTEAK"
	cont "from disaster."

	para "The LEAGUE's been"
	line "talking about you."

	para "A rookie trainer"
	line "who can handle a"
	cont "crisis like that…"

	para "Even SUICUNE seems"
	line "to have taken an"
	cont "interest in you!"

	para "I'm curious to see"
	line "your strength for"
	cont "myself."

	para "Don't hold back,"
	line "<PLAYER>."

	para "I want to see what"
	line "you're really made"
	cont "of!"
	done

KarenBeatenText:
	text "Hm. Not bad."
	done

KarenPlayerLostText:
	text "You've got spirit."
	done

KarenAfterText:
	text "KAREN: You've got"
	line "real potential,"
	cont "<PLAYER>."

	para "That crisis would"
	line "have broken even"
	cont "veterans."

	para "But you and your"
	line "#MON fought"
	cont "with everything"
	cont "you had."

	para "That's the mark of"
	line "a true trainer."

	para "Keep growing"
	line "stronger."

	para "I look forward to"
	line "meeting you again"
	cont "at INDIGO PLATEAU."
	done

CianwoodCitySignText:
	text "CIANWOOD CITY"

	para "A Port Surrounded"
	line "by Rough Seas"
	done

CianwoodGymSignText:
	text "CIANWOOD CITY"
	line "#MON GYM"

	para "LEADER: CHUCK"

	para "His Roaring Fists"
	line "Do the Talking"
	done

CianwoodPharmacySignText:
	text "500 Years of"
	line "Tradition"

	para "CIANWOOD CITY"
	line "PHARMACY"

	para "We Await Your"
	line "Medicinal Queries"
	done

CianwoodPhotoStudioSignText:
	text "CIANWOOD CITY"
	line "PHOTO STUDIO"

	para "Take a Snapshot as"
	line "a Keepsake!"
	done

CianwoodPokeSeerSignText:
	text "THE # SEER"
	line "AHEAD"
	done

SwimmerfKatieSeenText:
	text "I swim here to"
	line "train for the gym!"

	para "CHUCK's #MON"
	line "are so tough!"

	para "Want to help me"
	line "practice?"
	done

SwimmerfKatieBeatenText:
	text "I need more ocean"
	line "training!"
	done

SwimmerfKatieAfterBattleText:
	text "The waters around"
	line "CIANWOOD are"
	cont "perfect for"
	cont "training!"

	para "Strong currents"
	line "and big waves"
	cont "build endurance."

	para "No wonder CHUCK"
	line "built his gym"
	cont "here by the sea!"
	done

SwimmermPatonSeenText:
	text "The pharmacy here"
	line "makes the best"
	cont "medicine!"

	para "I swim daily to"
	line "stay healthy and"
	cont "avoid needing it!"

	para "Care to race?"
	done

SwimmermPatonBeatenText:
	text "Maybe I do need"
	line "that medicine!"
	done

SwimmermPatonAfterBattleText:
	text "CIANWOOD's ocean"
	line "air is so fresh"
	cont "and clean!"

	para "Between swimming"
	line "and the sea"
	cont "breeze, I never"
	cont "get sick!"

	para "This city knows"
	line "the secret to"
	cont "good health!"
	done

CianwoodCity_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 17, 41, MANIAS_HOUSE, 1
	warp_event  8, 43, CIANWOOD_GYM, 1
	warp_event 23, 43, CIANWOOD_POKECENTER_1F, 1
	warp_event 15, 47, CIANWOOD_PHARMACY, 1
	warp_event  9, 31, CIANWOOD_PHOTO_STUDIO, 1
	warp_event 15, 37, CIANWOOD_LUGIA_SPEECH_HOUSE, 1
	warp_event  5, 18, POKE_SEERS_HOUSE, 1

	def_coord_events
	coord_event 11, 16, SCENE_CIANWOODCITY_SUICUNE_AND_KAREN, CianwoodCitySuicuneAndKaren

	def_bg_events
	bg_event 20, 34, BGEVENT_READ, CianwoodCitySign
	bg_event  7, 45, BGEVENT_READ, CianwoodGymSign
	bg_event 24, 43, BGEVENT_READ, CianwoodPokecenterSign
	bg_event 19, 47, BGEVENT_READ, CianwoodPharmacySign
	bg_event  8, 32, BGEVENT_READ, CianwoodPhotoStudioSign
	bg_event  8, 24, BGEVENT_READ, CianwoodPokeSeerSign
	bg_event  4, 21, BGEVENT_ITEM, CianwoodCityHiddenRevive
	bg_event  5, 29, BGEVENT_ITEM, CianwoodCityHiddenMaxEther

	def_object_events
	object_event 21, 37, SPRITE_STANDING_YOUNGSTER, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, CianwoodCityYoungster, -1
	object_event 17, 33, SPRITE_POKEFAN_M, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 1, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodCityPokefanM, -1
	object_event 14, 42, SPRITE_LASS, SPRITEMOVEDATA_WALK_UP_DOWN, 0, 2, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodCityLass, -1
	object_event  8, 16, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodCityRock, -1
	object_event  9, 17, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodCityRock, -1
	object_event  7, 26, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodCityRock, -1
	object_event  5, 29, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodCityRock, -1
	object_event  4, 21, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodCityRock, -1
	object_event 10, 46, SPRITE_POKEFAN_F, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 1, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodCityChucksWife, -1
	object_event 11, 21, SPRITE_KAREN, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_CIANWOOD_CITY_KAREN
	object_event 10, 14, SPRITE_SUICUNE, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_SAW_SUICUNE_AT_CIANWOOD_CITY
	object_event 25, 15, SPRITE_SWIMMER_GIRL, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_TRAINER, 3, TrainerSwimmerfKatie, -1
	object_event 22, 28, SPRITE_OLIVINE_RIVAL, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 2, TrainerSwimmermPaton, -1
	object_event 31,  7, SPRITE_SWIMMER_GIRL, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, CianwoodCityTrainerSwimmerfJill, -1
	object_event 32, 46, SPRITE_OLIVINE_RIVAL, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, CianwoodCityTrainerSwimmermHal, -1
	object_event 33, 27, SPRITE_SWIMMER_GIRL, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, CianwoodCityTrainerSwimmerfMary, -1
	object_event 10, 13, SPRITE_UNOWN_G, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, PAL_NPC_YELLOW, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_SAW_SUICUNE_AT_CIANWOOD_CITY

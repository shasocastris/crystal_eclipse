	object_const_def
	const FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_CAPTAIN
	const FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_GENTLEMAN
	const FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_TWIN1
	const FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_TWIN2
	const FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_POKEFAN_M1
	const FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_TWIN3
	const FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_TWIN4
	const FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_YOUNGSTER
	const FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_POKEFAN_M2
	const FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_POKEFAN_F
	const FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_SUPER_NERD
	const FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_PETREL

FastShipCabins_SE_SSE_CaptainsCabin_MapScripts:
	def_scene_scripts

	def_callbacks

SSAquaCaptain:
	faceplayer
	opentext
	checkevent EVENT_FAST_SHIP_FIRST_TIME
	iftrue .LaterTrip
	writetext SSAquaCaptainRescuedText
	waitbutton
	closetext
	end

.LaterTrip:
	writetext SSAquaCaptainHowDoYouLikeText
	waitbutton
	closetext
	end

SSAquaCaptainsCabinPetrelScript:
	checkevent EVENT_FAST_SHIP_PETREL
	iftrue .Done
	checkevent EVENT_FAST_SHIP_FIRST_TIME
	iftrue .Done
	special FadeOutMusic
	turnobject PLAYER, UP
	showemote EMOTE_SHOCK, FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_PETREL, 15
	playmusic MUSIC_ROCKET_ENCOUNTER
; Petrel steps into row 28 at x=5, then walks along it to stand over the player
	applymovement FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_PETREL, SSAquaPetrelStepDownMovement
	readvar VAR_XCOORD
.PetrelApproach:
	ifequal 5, .PetrelArrived
	ifless 5, .PetrelStepLeft
	applymovement FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_PETREL, SSAquaPetrelStepRightMovement
	addval -1
	sjump .PetrelApproach

.PetrelStepLeft:
	applymovement FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_PETREL, SSAquaPetrelStepLeftMovement
	addval 1
	sjump .PetrelApproach

.PetrelArrived:
	turnobject FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_PETREL, DOWN
	opentext
	writetext PetrelShipBeforeText
	waitbutton
	closetext
	winlosstext PetrelShipWinText, PetrelShipLossText
	setlasttalked FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_PETREL
	loadtrainer EXECUTIVEM, EXECUTIVEM_5
	startbattle
	reloadmapafterbattle
	setevent EVENT_SAVED_SS_AQUA
	opentext
	writetext PetrelShipAfterText
	waitbutton
	closetext
	special FadeOutToBlack
	special ReloadSpritesNoPalettes
	disappear FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_PETREL
	pause 15
	special FadeInFromBlack
	special RestartMapMusic
	opentext
	writetext PetrelShipSmokeBallText
	waitbutton
	writetext SSAquaCaptainRescuedText
	waitbutton
	closetext
	sjump SSAquaGranddaughterReunion

.Done:
	end

SSAquaGranddaughterBefore:
	faceplayer
SSAquaGranddaughterReunion:
	opentext
	writetext SSAquaGranddaughterRescuedText
	waitbutton
	closetext
	special FadeOutToBlack
	special ReloadSpritesNoPalettes
	callasm DisableDynPalUpdates
	disappear FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_TWIN2
; the player can be anywhere in the cabin, so walk them to the grandpa's door
.WalkX:
	readvar VAR_XCOORD
	ifequal 2, .WalkY
	ifless 2, .StepRight
	applymovement PLAYER, SSAquaPlayerStepLeftMovement
	sjump .WalkX

.StepRight:
	applymovement PLAYER, SSAquaPlayerStepRightMovement
	sjump .WalkX

.WalkY:
	readvar VAR_YCOORD
	ifequal 19, .AtGrandpasCabin
	applymovement PLAYER, SSAquaPlayerStepUpMovement
	sjump .WalkY

.AtGrandpasCabin:
	moveobject FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_TWIN1, 3, 19
	appear FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_TWIN1
	turnobject PLAYER, UP
	turnobject FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_TWIN1, UP
	loadmem wObject1Palette, 1
	callasm SetBlackObjectPals
	turnobject FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_GENTLEMAN, RIGHT
	callasm FadeInPalettes_EnableDynNoApply
	turnobject FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_GENTLEMAN, DOWN
	showemote EMOTE_SHOCK, FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_GENTLEMAN, 15
	applymovement FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_TWIN1, SSAquaGranddaughterEntersCabinMovement
	turnobject FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_GENTLEMAN, RIGHT
	checkflag ENGINE_PLAYER_IS_FEMALE
	iftrue .PlayerIsFemale
	opentext
	writetext SSAquaGranddaughterWasPlayingMText
	waitbutton
	closetext
	sjump .cont

.PlayerIsFemale:
	opentext
	writetext SSAquaGranddaughterWasPlayingFText
	waitbutton
	closetext
.cont:
	turnobject FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_TWIN2, DOWN
	applymovement FASTSHIPCABINS_SE_SSE_CAPTAINSCABIN_GENTLEMAN, SSAquaGrandpaApproachesPlayerMovement
	opentext
	writetext SSAquaEntertainedGranddaughterText
	promptbutton
	setevent EVENT_VERMILION_PORT_SAILOR_AT_GANGWAY
	setmapscene FAST_SHIP_1F, SCENE_FASTSHIP1F_NOOP
	sjump SSAquaMetalCoatAndDocking

SSAquaGrandpa:
	faceplayer
	opentext
	checkevent EVENT_GOT_METAL_COAT_FROM_GRANDPA_ON_SS_AQUA
	iftrue SSAquaGotMetalCoat
	checkevent EVENT_FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN_TWIN_2
	iftrue SSAquaFoundGranddaughter
	writetext SSAquaCantFindGranddaughterText
	waitbutton
	closetext
	setmapscene FAST_SHIP_1F, SCENE_FASTSHIP1F_NOOP
	end

SSAquaMetalCoatAndDocking:
	writetext SSAquaGrandpaHaveThisText
	promptbutton
	verbosegiveitem METAL_COAT
	iffalse .NoRoom
	setevent EVENT_GOT_METAL_COAT_FROM_GRANDPA_ON_SS_AQUA
.NoRoom:
	closetext
	waitsfx
	playsound SFX_ELEVATOR_END
	pause 30
	opentext
	writetext SSAquaHasArrivedVermilionText
	waitbutton
	setevent EVENT_FAST_SHIP_HAS_ARRIVED
	setevent EVENT_FAST_SHIP_FOUND_GIRL
	closetext
	end

SSAquaFoundGranddaughter:
	writetext SSAquaGrandpaHaveThisText
	promptbutton
	verbosegiveitem METAL_COAT
	iffalse .NoRoom
	setevent EVENT_GOT_METAL_COAT_FROM_GRANDPA_ON_SS_AQUA
.NoRoom:
	closetext
	end

SSAquaGotMetalCoat:
	writetext SSAquaGrandpaTravellingText
	waitbutton
	closetext
	end

SSAquaGranddaughterAfter:
	faceplayer
	opentext
	writetext SSAquaGranddaughterHadFunText
	waitbutton
	closetext
	end

TrainerPokefanmColin:
	trainer POKEFANM, COLIN, EVENT_BEAT_POKEFANM_COLIN, PokefanmColinSeenText, PokefanmColinBeatenText, 0, .Script

.Script:
	opentext
	writetext PokefanmColinAfterBattleText
	waitbutton
	closetext
	end

TrainerTwinsMegandpeg1:
	trainer TWINS, MEGANDPEG1, EVENT_BEAT_TWINS_MEG_AND_PEG, TwinsMegandpeg1SeenText, TwinsMegandpeg1BeatenText, 0, .Script

.Script:
	opentext
	writetext TwinsMegandpeg1AfterBattleText
	waitbutton
	closetext
	end

TrainerTwinsMegandpeg2:
	trainer TWINS, MEGANDPEG2, EVENT_BEAT_TWINS_MEG_AND_PEG, TwinsMegandpeg2SeenText, TwinsMegandpeg2BeatenText, 0, .Script

.Script:
	opentext
	writetext TwinsMegandpeg2AfterBattleText
	waitbutton
	closetext
	end

TrainerPsychicRodney:
	trainer PSYCHIC_T, RODNEY, EVENT_BEAT_PSYCHIC_RODNEY, PsychicRodneySeenText, PsychicRodneyBeatenText, 0, .Script

.Script:
	opentext
	writetext PsychicRodneyAfterBattleText
	waitbutton
	closetext
	end

TrainerPokefanmJeremy:
	trainer POKEFANM, JEREMY, EVENT_BEAT_POKEFANM_JEREMY, PokefanmJeremySeenText, PokefanmJeremyBeatenText, 0, .Script

.Script:
	opentext
	writetext PokefanmJeremyAfterBattleText
	waitbutton
	closetext
	end

TrainerPokefanfGeorgia:
	trainer POKEFANF, GEORGIA, EVENT_BEAT_POKEFANF_GEORGIA, PokefanfGeorgiaSeenText, PokefanfGeorgiaBeatenText, 0, .Script

.Script:
	opentext
	writetext PokefanfGeorgiaAfterBattleText
	waitbutton
	closetext
	end

TrainerSuperNerdShawn:
	trainer SUPER_NERD, SHAWN, EVENT_BEAT_SUPER_NERD_SHAWN, SuperNerdShawnSeenText, SuperNerdShawnBeatenText, 0, .Script

.Script:
	opentext
	writetext SuperNerdShawnAfterBattleText
	waitbutton
	closetext
	end

FastShipCaptainsCabinTrashcan:
	jumpstd TrashCanScript

SSAquaPlayerStepLeftMovement:
	big_step LEFT
	step_end

SSAquaPlayerStepRightMovement:
	big_step RIGHT
	step_end

SSAquaPlayerStepUpMovement:
	big_step UP
	step_end

SSAquaPetrelStepDownMovement:
	step DOWN
	step_end

SSAquaPetrelStepLeftMovement:
	step LEFT
	step_end

SSAquaPetrelStepRightMovement:
	step RIGHT
	step_end

SSAquaGranddaughterEntersCabinMovement:
	step UP
	step UP
	turn_head LEFT
	step_end

SSAquaGrandpaApproachesPlayerMovement:
	step DOWN
	step_end

SSAquaCaptainRescuedText:
	text "CAPTAIN: Thank"
	line "goodness!"

	para "That man took my"
	line "cabin and forced"
	cont "me to carry his"
	cont "stolen #MON!"
	done

SSAquaCaptainHowDoYouLikeText:
	text "How do you like"
	line "S.S.AQUA's ride?"

	para "She practically"
	line "skates across the"
	cont "waves."
	done

SSAquaCantFindGranddaughterText:
	text "Oh, hello…"

	para "I still can't find"
	line "my granddaughter."

	para "If she's on the"
	line "ship, that's OK."

	para "She's an energetic"
	line "child, so she may"

	para "be bugging some-"
	line "one. I'm worried…"
	done

SSAquaEntertainedGranddaughterText:
	text "<PLAY_G>, was it?"
	line "You saved my"
	cont "granddaughter from"
	cont "those crooks!"

	para "I can't thank you"
	line "enough."
	done

SSAquaGrandpaHaveThisText:
	text "I know! I'd like"
	line "you to have this!"
	done

SSAquaGrandpaTravellingText:
	text "We're traveling"
	line "around the world."
	done


SSAquaGranddaughterRescuedText:
	text "Is the scary man"
	line "gone?"

	para "Grandpa must be so"
	line "worried!"

	para "I have to go find"
	line "Grandpa!"
	done

SSAquaGranddaughterWasPlayingMText:
	text "Grandpa! A scary"
	line "man locked me up"

	para "with the CAPTAIN,"
	line "but this guy came"
	cont "and saved us!"
	done

SSAquaGranddaughterWasPlayingFText:
	text "Grandpa! A scary"
	line "man locked me up"

	para "with the CAPTAIN,"
	line "but this girl came"
	cont "and saved us!"
	done

SSAquaGranddaughterHadFunText:
	text "I had lots of fun"
	line "playing!"
	done

PokefanmColinSeenText:
	text "Hey, kid! Want to"
	line "battle with me?"
	done

PokefanmColinBeatenText:
	text "You're strong!"
	done

PokefanmColinAfterBattleText:
	text "You're traveling"
	line "all alone?"

	para "Isn't your mom"
	line "worried?"
	done

TwinsMegandpeg1SeenText:
	text "You think I'm a"
	line "baby?"
	cont "That's not fair!"
	done

TwinsMegandpeg1BeatenText:
	text "Oh! We lost!"
	done

TwinsMegandpeg1AfterBattleText:
	text "Baby is a rude"
	line "name to call us"
	cont "girls!"
	done

TwinsMegandpeg2SeenText:
	text "I'm not a baby!"

	para "That's not nice to"
	line "say to a lady!"
	done

TwinsMegandpeg2BeatenText:
	text "Oh! We lost!"
	done

TwinsMegandpeg2AfterBattleText:
	text "Sometimes, kids"
	line "are smarter than"
	cont "grown-ups!"
	done

PsychicRodneySeenText:
	text "Ssh! My brain is"
	line "picking up radio"
	cont "signals!"
	done

PsychicRodneyBeatenText:
	text "…I hear some-"
	line "thing!"
	done

PsychicRodneyAfterBattleText:
	text "I get it. You can"
	line "hear JOHTO's radio"
	cont "on the FAST SHIP."
	done

PokefanmJeremySeenText:
	text "What do you think?"
	line "My #MON are"
	cont "beautiful, yes?"
	done

PokefanmJeremyBeatenText:
	text "Oh, no! My beauti-"
	line "ful #MON!"
	done

PokefanmJeremyAfterBattleText:
	text "I must go to the"
	line "#MON SALON and"
	cont "fix them up nice!"
	done

PokefanfGeorgiaSeenText:
	text "I'm going to shop"
	line "at the DEPT.STORE"
	cont "and then…"
	done

PokefanfGeorgiaBeatenText:
	text "What was I going"
	line "to do?"
	done

PokefanfGeorgiaAfterBattleText:
	text "Oh, yes! I have to"
	line "get my #MON out"
	cont "of DAY-CARE!"
	done

SuperNerdShawnSeenText:
	text "What kinds of #"
	line "BALLS do you have"
	cont "with you?"
	done

SuperNerdShawnBeatenText:
	text "Wait! Stop! Don't!"
	line "Please!"
	done

SuperNerdShawnAfterBattleText:
	text "You should use the"
	line "right BALLS to fit"
	cont "the situation."
	done

PetrelShipBeforeText:
	text "Hey! No passengers"
	line "past this point!"

	para "…Hm? You're the"
	line "kid who wrecked"
	cont "the secret base in"
	cont "MAHOGANY TOWN!"

	para "Then there's no"
	line "need for this"
	cont "silly disguise."

	para "I'm PETREL of TEAM"
	line "ROCKET!"

	para "This ship and its"
	line "CAPTAIN are taking"
	cont "my cargo to KANTO,"
	cont "like it or not!"

	para "And the little"
	line "girl? Insurance."

	para "You won't ruin"
	line "this one, kid!"
	done

PetrelShipWinText:
	text "Not again…!"
	done

PetrelShipLossText:
	text "Ha! Some hero."

	para "Sleep it off, kid."
	line "This ship is ours!"
	done

PetrelShipAfterText:
	text "Fine. Keep the"
	line "cargo."

	para "There's plenty"
	line "more where that"
	cont "came from."

	para "We'll meet again"
	line "in KANTO, kid."
	done

PetrelShipSmokeBallText:
	text "PETREL disappeared"
	line "with a SMOKE BALL!"
	done

SSAquaHasArrivedVermilionText:
	text "FAST SHIP S.S.AQUA"
	line "has arrived in"
	cont "VERMILION CITY."
	done

FastShipCabins_SE_SSE_CaptainsCabin_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2,  7, FAST_SHIP_1F, 8
	warp_event  3,  7, FAST_SHIP_1F, 8
	warp_event  2, 19, FAST_SHIP_1F, 9
	warp_event  3, 19, FAST_SHIP_1F, 9
	warp_event  2, 33, FAST_SHIP_1F, 10
	warp_event  3, 33, FAST_SHIP_1F, 10

	def_coord_events
	coord_event  0, 29, -1, SSAquaCaptainsCabinPetrelScript
	coord_event  1, 29, -1, SSAquaCaptainsCabinPetrelScript
	coord_event  2, 29, -1, SSAquaCaptainsCabinPetrelScript
	coord_event  3, 29, -1, SSAquaCaptainsCabinPetrelScript
	coord_event  4, 29, -1, SSAquaCaptainsCabinPetrelScript
	coord_event  5, 29, -1, SSAquaCaptainsCabinPetrelScript
	coord_event  6, 29, -1, SSAquaCaptainsCabinPetrelScript
	coord_event  7, 29, -1, SSAquaCaptainsCabinPetrelScript
	coord_event  8, 29, -1, SSAquaCaptainsCabinPetrelScript
	coord_event  9, 29, -1, SSAquaCaptainsCabinPetrelScript

	def_bg_events
	bg_event  4, 25, BGEVENT_READ, FastShipCaptainsCabinTrashcan

	def_object_events
	object_event  3, 25, SPRITE_CAPTAIN, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, SSAquaCaptain, -1
	object_event  2, 17, SPRITE_GENTLEMAN, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, SSAquaGrandpa, EVENT_FAST_SHIP_CABINS_SE_SSE_GENTLEMAN
	object_event  3, 17, SPRITE_TWIN, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SSAquaGranddaughterAfter, EVENT_FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN_TWIN_1
	object_event  2, 25, SPRITE_TWIN, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SSAquaGranddaughterBefore, EVENT_FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN_TWIN_2
	object_event  5,  6, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 5, TrainerPokefanmColin, EVENT_FAST_SHIP_PASSENGERS_FIRST_TRIP
	object_event  2,  4, SPRITE_TWIN, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 1, TrainerTwinsMegandpeg1, EVENT_FAST_SHIP_PASSENGERS_FIRST_TRIP
	object_event  3,  4, SPRITE_TWIN, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 1, TrainerTwinsMegandpeg2, EVENT_FAST_SHIP_PASSENGERS_FIRST_TRIP
	object_event  5,  5, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 5, TrainerPsychicRodney, EVENT_FAST_SHIP_PASSENGERS_EASTBOUND
	object_event  2,  3, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 3, TrainerPokefanmJeremy, EVENT_FAST_SHIP_PASSENGERS_WESTBOUND
	object_event  5,  5, SPRITE_POKEFAN_F, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 1, TrainerPokefanfGeorgia, EVENT_FAST_SHIP_PASSENGERS_WESTBOUND
	object_event  1, 15, SPRITE_SUPER_NERD, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 2, TrainerSuperNerdShawn, EVENT_FAST_SHIP_PASSENGERS_EASTBOUND
	object_event  5, 27, SPRITE_SAILOR, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_FAST_SHIP_PETREL

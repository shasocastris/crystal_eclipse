	object_const_def
	const ELMSLAB_ELM
	const ELMSLAB_ELMS_AIDE
	const ELMSLAB_POKE_BALL1
	const ELMSLAB_POKE_BALL2
	const ELMSLAB_POKE_BALL3
	const ELMSLAB_OFFICER

ElmsLab_MapScripts:
	def_scene_scripts
	scene_script ElmsLabMeetElmScene, SCENE_ELMSLAB_MEET_ELM
	scene_script ElmsLabNoop1Scene,   SCENE_ELMSLAB_CANT_LEAVE
	scene_script ElmsLabNoop2Scene,   SCENE_ELMSLAB_NOOP
	scene_script ElmsLabNoop3Scene,   SCENE_ELMSLAB_MEET_OFFICER
	scene_script ElmsLabNoop4Scene,   SCENE_ELMSLAB_UNUSED
	scene_script ElmsLabNoop5Scene,   SCENE_ELMSLAB_AIDE_GIVES_POTION
	scene_const SCENE_ELMSLAB_AIDE_GIVES_POKE_BALLS

	def_callbacks
	callback MAPCALLBACK_OBJECTS, ElmsLabMoveElmCallback

ElmsLabMeetElmScene:
	sdefer ElmsLabWalkUpToElmScript
	end

ElmsLabNoop1Scene:
	end

ElmsLabNoop2Scene:
	end

ElmsLabNoop3Scene:
	end

ElmsLabNoop4Scene:
	end

ElmsLabNoop5Scene:
	end

ElmsLabMoveElmCallback:
	checkscene
	iftrue .Skip ; not SCENE_ELMSLAB_MEET_ELM
	moveobject ELMSLAB_ELM, 3, 4
.Skip:
	endcallback

ElmsLabWalkUpToElmScript:
	applymovement PLAYER, ElmsLab_WalkUpToElmMovement
	showemote EMOTE_SHOCK, ELMSLAB_ELM, 15
	turnobject ELMSLAB_ELM, RIGHT
	opentext
	writetext ElmText_Intro
.MustSayYes:
	yesorno
	iftrue .ElmGetsEmail
	writetext ElmText_Refused
	sjump .MustSayYes

.ElmGetsEmail:
if !DEF(_DEBUG)
	writetext ElmText_Accepted
	promptbutton
	writetext ElmText_ResearchAmbitions
	waitbutton
	closetext
	playsound SFX_GLASS_TING
	pause 30
	showemote EMOTE_SHOCK, ELMSLAB_ELM, 10
	turnobject ELMSLAB_ELM, DOWN
	opentext
	writetext ElmText_GotAnEmail
	waitbutton
	closetext
	opentext
	turnobject ELMSLAB_ELM, RIGHT
	writetext ElmText_MissionFromMrPokemon
	waitbutton
endc
	closetext
	applymovement ELMSLAB_ELM, ElmsLab_ElmToDefaultPositionMovement1
	turnobject PLAYER, UP
	applymovement ELMSLAB_ELM, ElmsLab_ElmToDefaultPositionMovement2
	opentext
	writetext ElmText_ChooseAPokemon
	waitbutton
	turnobject PLAYER, RIGHT
	setscene SCENE_ELMSLAB_CANT_LEAVE
	closetext
	end

ProfElmScript:
	faceplayer
	opentext
	checkevent EVENT_GOT_SS_TICKET_FROM_ELM
	iftrue ElmCheckMasterBall
	checkevent EVENT_BEAT_ELITE_FOUR
	iftrue ElmGiveTicketScript
ElmCheckMasterBall:
	checkevent EVENT_GOT_MASTER_BALL_FROM_ELM
	iftrue ElmCheckMistStone
	checkflag ENGINE_RISINGBADGE
	iftrue ElmGiveMasterBallScript
ElmCheckMistStone:
	checkevent EVENT_GOT_MIST_STONE_FROM_ELM
	iftrue ElmScript_CallYou
	checkevent EVENT_SHOWED_TOGETIC_TO_ELM
	iftrue ElmGiveMistStoneScript
	checkevent EVENT_TOLD_ELM_ABOUT_TOGETIC_OVER_THE_PHONE
	iffalse ElmCheckTogepiEvolved
	loadmonindex 1, TOGETIC
	special FindPartyMonThatSpeciesYourTrainerID
	iftrue ShowElmTogeticScript
	writetext ElmThoughtTogepiEvolvedText
	waitbutton
	closetext
	end

ElmTogepiEvolvedScript:
	loadmonindex 1, TOGETIC
	special FindPartyMonThatSpeciesYourTrainerID
	iftrue ShowElmTogeticScript
	sjump ElmCheckGotTogepiAgain

ElmCheckTogepiEvolved:
	checkevent EVENT_GOT_TOGEPI_FROM_ELMS_AIDE
	iffalse ElmCheckGotTogepiAgain
	checkevent EVENT_TOGEPI_EVOLVED
	iftrue ElmTogepiEvolvedScript
ElmCheckGotTogepiAgain:
	checkevent EVENT_GOT_TOGEPI_FROM_ELMS_AIDE ; why are we checking it again?
	iftrue ElmWaitingTogepiEvolveScript
	checkflag ENGINE_ZEPHYRBADGE
	iftrue ElmAideHasTogepiScript
	checkevent EVENT_GAVE_MYSTERY_EGG_TO_ELM
	iftrue ElmStudyingEggScript
	checkevent EVENT_GOT_MYSTERY_EGG_FROM_MR_POKEMON
	iftrue ElmAfterTheftScript
	checkevent EVENT_GOT_A_POKEMON_FROM_ELM
	iftrue ElmDescribesMrPokemonScript
	writetext ElmText_LetYourMonBattleIt
	waitbutton
	closetext
	end

LabTryToLeaveScript:
	turnobject ELMSLAB_ELM, DOWN
	opentext
	writetext LabWhereGoingText
	waitbutton
	closetext
	applymovement PLAYER, ElmsLab_CantLeaveMovement
	end

CyndaquilPokeBallScript:
	checkevent EVENT_GOT_A_POKEMON_FROM_ELM
	iftrue LookAtElmPokeBallScript
	turnobject ELMSLAB_ELM, DOWN
	refreshscreen
	pokepic CYNDAQUIL
	cry CYNDAQUIL
	waitbutton
	closepokepic
	opentext
	writetext TakeCyndaquilText
	yesorno
	iffalse DidntChooseStarterScript
	disappear ELMSLAB_POKE_BALL1
	setevent EVENT_GOT_CYNDAQUIL_FROM_ELM
	writetext ChoseStarterText
	promptbutton
	waitsfx
	getmonname STRING_BUFFER_3, CYNDAQUIL
	writetext ReceivedStarterText
	playsound SFX_CAUGHT_MON
	waitsfx
	promptbutton
	givepoke CYNDAQUIL, 5, BERRY
	closetext
	readvar VAR_FACING
	ifequal RIGHT, AfterCyndaquilRight
	applymovement PLAYER, AfterCyndaquilMovement
	sjump ElmDirectionsScript

TotodilePokeBallScript:
	checkevent EVENT_GOT_A_POKEMON_FROM_ELM
	iftrue LookAtElmPokeBallScript
	turnobject ELMSLAB_ELM, DOWN
	refreshscreen
	pokepic TOTODILE
	cry TOTODILE
	waitbutton
	closepokepic
	opentext
	writetext TakeTotodileText
	yesorno
	iffalse DidntChooseStarterScript
	disappear ELMSLAB_POKE_BALL2
	setevent EVENT_GOT_TOTODILE_FROM_ELM
	writetext ChoseStarterText
	promptbutton
	waitsfx
	getmonname STRING_BUFFER_3, TOTODILE
	writetext ReceivedStarterText
	playsound SFX_CAUGHT_MON
	waitsfx
	promptbutton
	givepoke TOTODILE, 5, BERRY
	closetext
	applymovement PLAYER, AfterTotodileMovement
	sjump ElmDirectionsScript

ChikoritaPokeBallScript:
	checkevent EVENT_GOT_A_POKEMON_FROM_ELM
	iftrue LookAtElmPokeBallScript
	turnobject ELMSLAB_ELM, DOWN
	refreshscreen
	pokepic CHIKORITA
	cry CHIKORITA
	waitbutton
	closepokepic
	opentext
	writetext TakeChikoritaText
	yesorno
	iffalse DidntChooseStarterScript
	disappear ELMSLAB_POKE_BALL3
	setevent EVENT_GOT_CHIKORITA_FROM_ELM
	writetext ChoseStarterText
	promptbutton
	waitsfx
	getmonname STRING_BUFFER_3, CHIKORITA
	writetext ReceivedStarterText
	playsound SFX_CAUGHT_MON
	waitsfx
	promptbutton
	givepoke CHIKORITA, 5, BERRY
	closetext
	applymovement PLAYER, AfterChikoritaMovement
	sjump ElmDirectionsScript

DidntChooseStarterScript:
	writetext DidntChooseStarterText
	waitbutton
	closetext
	end

ElmDirectionsScript:
	appearfolloweronestep
	turnobject PLAYER, UP
if !DEF(_DEBUG)
	opentext
	writetext ElmDirectionsText1
	waitbutton
	closetext
endc
	addcellnum PHONE_ELM
	opentext
	writetext GotElmsNumberText
	playsound SFX_REGISTER_PHONE_NUMBER
	waitsfx
	waitbutton
	closetext
	turnobject ELMSLAB_ELM, LEFT
	opentext
	writetext ElmDirectionsText2
	waitbutton
	closetext
	turnobject ELMSLAB_ELM, DOWN
	opentext
	writetext ElmDirectionsText3
	waitbutton
	closetext
	turnobject PLAYER, DOWN
	setevent EVENT_GOT_A_POKEMON_FROM_ELM
	setevent EVENT_RIVAL_CHERRYGROVE_CITY
	setscene SCENE_ELMSLAB_AIDE_GIVES_POTION
	setmapscene NEW_BARK_TOWN, SCENE_NEWBARKTOWN_NOOP
	end

ElmDescribesMrPokemonScript:
	writetext ElmDescribesMrPokemonText
	waitbutton
	closetext
	end

LookAtElmPokeBallScript:
	opentext
	writetext ElmPokeBallText
	waitbutton
	closetext
	end

ElmsLabHealingMachine:
	opentext
	checkevent EVENT_GOT_A_POKEMON_FROM_ELM
	iftrue .CanHeal
	writetext ElmsLabHealingMachineText1
	waitbutton
	closetext
	end

.CanHeal:
	writetext ElmsLabHealingMachineText2
	yesorno
	iftrue ElmsLabHealingMachine_HealParty
	closetext
	end

ElmsLabHealingMachine_HealParty:
	special StubbedTrainerRankings_Healings
	special HealParty
	playmusic MUSIC_NONE
	setval HEALMACHINE_ELMS_LAB
	special HealMachineAnim
	pause 30
	special RestartMapMusic
	closetext
	turnobject PLAYER, DOWN
	end

ElmAfterTheftDoneScript:
	waitbutton
	closetext
	end

ElmAfterTheftScript:
	writetext ElmAfterTheftText1
	checkitem MYSTERY_EGG
	iffalse ElmAfterTheftDoneScript
	promptbutton
	writetext ElmAfterTheftText2
	waitbutton
	takeitem MYSTERY_EGG
	scall ElmJumpBackScript1
	writetext ElmAfterTheftText3
	waitbutton
	scall ElmJumpBackScript2
	writetext ElmAfterTheftText4
	promptbutton
	writetext ElmAfterTheftText5
	promptbutton
	setevent EVENT_GAVE_MYSTERY_EGG_TO_ELM
	setflag ENGINE_MOBILE_SYSTEM
	clearevent EVENT_ROUTE_30_YOUNGSTER_JOEY
	setevent EVENT_ROUTE_30_BATTLE
	writetext ElmAfterTheftText6
	waitbutton
	closetext
	setscene SCENE_ELMSLAB_AIDE_GIVES_POKE_BALLS
	end

ElmStudyingEggScript:
	writetext ElmStudyingEggText
	waitbutton
	closetext
	end

ElmAideHasTogepiScript:
	writetext ElmAideHasTogepiText
	waitbutton
	closetext
	end

ElmWaitingTogepiEvolveScript:
	writetext ElmWaitingTogepiEvolveText
	waitbutton
	closetext
	end

ShowElmTogeticScript:
	writetext ShowElmTogeticText1
	waitbutton
	closetext
	showemote EMOTE_SHOCK, ELMSLAB_ELM, 15
	setevent EVENT_SHOWED_TOGETIC_TO_ELM
	opentext
	writetext ShowElmTogeticText2
	promptbutton
	writetext ShowElmTogeticText3
	promptbutton
ElmGiveMistStoneScript:
	writetext ElmGiveMistStoneText1
	promptbutton
	verbosegiveitem MIST_STONE
	iffalse ElmScript_NoRoomForMistStone
	writetext ElmGiveMistStoneText2
	waitbutton
	closetext
	setevent EVENT_GOT_MIST_STONE_FROM_ELM
	end

ElmScript_CallYou:
	writetext ElmText_CallYou
	waitbutton
ElmScript_NoRoomForMistStone:
	closetext
	end

ElmGiveMasterBallScript:
	writetext ElmGiveMasterBallText1
	promptbutton
	verbosegiveitem MASTER_BALL
	iffalse .notdone
	setevent EVENT_GOT_MASTER_BALL_FROM_ELM
	writetext ElmGiveMasterBallText2
	waitbutton
.notdone
	closetext
	end

ElmGiveTicketScript:
	writetext ElmGiveTicketText1
	promptbutton
	verbosegiveitem S_S_TICKET
	setevent EVENT_GOT_SS_TICKET_FROM_ELM
	writetext ElmGiveTicketText2
	waitbutton
	closetext
	end

ElmJumpBackScript1:
	closetext
	readvar VAR_FACING
	ifequal DOWN, ElmJumpDownScript
	ifequal UP, ElmJumpUpScript
	ifequal LEFT, ElmJumpLeftScript
	ifequal RIGHT, ElmJumpRightScript
	end

ElmJumpBackScript2:
	closetext
	readvar VAR_FACING
	ifequal DOWN, ElmJumpUpScript
	ifequal UP, ElmJumpDownScript
	ifequal LEFT, ElmJumpRightScript
	ifequal RIGHT, ElmJumpLeftScript
	end

ElmJumpUpScript:
	applymovement ELMSLAB_ELM, ElmJumpUpMovement
	opentext
	end

ElmJumpDownScript:
	applymovement ELMSLAB_ELM, ElmJumpDownMovement
	opentext
	end

ElmJumpLeftScript:
	applymovement ELMSLAB_ELM, ElmJumpLeftMovement
	opentext
	end

ElmJumpRightScript:
	applymovement ELMSLAB_ELM, ElmJumpRightMovement
	opentext
	end

AideScript_WalkPotion1:
	applymovement ELMSLAB_ELMS_AIDE, AideWalksRight1
	turnobject PLAYER, DOWN
	scall AideScript_GivePotion
	applymovement ELMSLAB_ELMS_AIDE, AideWalksLeft1
	end

AideScript_WalkPotion2:
	applymovement ELMSLAB_ELMS_AIDE, AideWalksRight2
	turnobject PLAYER, DOWN
	scall AideScript_GivePotion
	applymovement ELMSLAB_ELMS_AIDE, AideWalksLeft2
	end

AideScript_GivePotion:
	opentext
	writetext AideText_GiveYouPotion
	promptbutton
	verbosegiveitem POTION
	showemote EMOTE_SHOCK, ELMSLAB_ELMS_AIDE, 30
	writetext AideText_ReadBooksReminder
	waitbutton
	closetext
	setscene SCENE_ELMSLAB_NOOP
	setevent EVENT_BEAT_COOLTRAINERM_ANDY
	end

AideScript_WalkBalls1:
	applymovement ELMSLAB_ELMS_AIDE, AideWalksRight1
	turnobject PLAYER, DOWN
	scall AideScript_GiveYouBalls
	applymovement ELMSLAB_ELMS_AIDE, AideWalksLeft1
	end

AideScript_WalkBalls2:
	applymovement ELMSLAB_ELMS_AIDE, AideWalksRight2
	turnobject PLAYER, DOWN
	scall AideScript_GiveYouBalls
	applymovement ELMSLAB_ELMS_AIDE, AideWalksLeft2
	end

AideScript_GiveYouBalls:
	opentext
	writetext AideText_GiveYouBalls
	promptbutton
	getitemname STRING_BUFFER_4, POKE_BALL
	scall AideScript_ReceiveTheBalls
	giveitem POKE_BALL, 5
	writetext AideText_ExplainBalls
	promptbutton
	itemnotify
	closetext
	setscene SCENE_ELMSLAB_NOOP
	clearevent EVENT_BEAT_COOLTRAINERM_ANDY
	end

AideScript_ReceiveTheBalls:
	jumpstd ReceiveItemScript
	end

ElmsAideScript:
	faceplayer
	opentext
	checkevent EVENT_BEAT_ELITE_FOUR
	iftrue AideScript_CongratulationsE4Win
	checkevent EVENT_GOT_TOGEPI_FROM_ELMS_AIDE
	iftrue AideScript_AfterTheft
	checkevent EVENT_GAVE_MYSTERY_EGG_TO_ELM
	iftrue AideScript_ExplainBalls
	checkevent EVENT_GOT_MYSTERY_EGG_FROM_MR_POKEMON
	iftrue AideScript_TheftTestimony
	writetext AideText_AlwaysBusy
	waitbutton
	closetext
	end

AideScript_CongratulationsE4Win:
	writetext AideText_CongratulationsE4Win
	waitbutton
	closetext
	end

AideScript_TheftTestimony:
	writetext AideText_TheftTestimony
	waitbutton
	closetext
	end

AideScript_ExplainBalls:
	writetext AideText_ExplainBalls
	waitbutton
	closetext
	end

AideScript_AfterTheft:
	writetext AideText_AfterTheft
	waitbutton
	closetext
	end

MeetCopScript2:
	applymovement PLAYER, MeetCopScript2_StepLeft

MeetCopScript:
	applymovement PLAYER, MeetCopScript_WalkUp
CopScript:
	turnobject ELMSLAB_OFFICER, LEFT
	opentext
	writetext ElmsLabOfficerText1
	promptbutton
	special NameRival
	writetext ElmsLabOfficerText2
	waitbutton
	closetext
	applymovement ELMSLAB_OFFICER, OfficerLeavesMovement
	disappear ELMSLAB_OFFICER
	pause 10
	applymovement PLAYER, MeetCopScript_GiveEgg
	opentext
	sjump ElmAfterTheftScript

ElmsLabWindow:
	opentext
	checkflag ENGINE_FLYPOINT_VIOLET
	iftrue .Normal
	checkevent EVENT_ELM_CALLED_ABOUT_STOLEN_POKEMON
	iftrue .BreakIn
	sjump .Normal

.BreakIn:
	writetext ElmsLabWindowText2
	waitbutton
	closetext
	end

.Normal:
	writetext ElmsLabWindowText1
	waitbutton
	closetext
	end

ElmsLabTravelTip1:
	jumptext ElmsLabTravelTip1Text

ElmsLabTravelTip2:
	jumptext ElmsLabTravelTip2Text

ElmsLabTravelTip3:
	jumptext ElmsLabTravelTip3Text

ElmsLabTravelTip4:
	jumptext ElmsLabTravelTip4Text

ElmsLabTravelTip5:
	jumptext ElmsLabTravelTip5Text

ElmsLabTravelTip6:
	jumptext ElmsLabTravelTip6Text

ElmsLabTravelTip7:
	jumptext ElmsLabTravelTip7Text

ElmsLabTravelTip8:
	jumptext ElmsLabTravelTip8Text

ElmsResearchNotes1:
	jumptext ElmsResearchNotes1Text

ElmsResearchNotes2:
	jumptext ElmsResearchNotes2Text

ElmsResearchNotes3:
	jumptext ElmsResearchNotes3Text

ElmsResearchNotes4:
	jumptext ElmsResearchNotes4Text

ElmsLabTrashcan:
	jumptext ElmsLabTrashcanText

ElmsLabPC:
	jumptext ElmsLabPCText


ElmsLab_WalkUpToElmMovement:
	step UP
	step UP
	step UP
	step UP
	step UP
	step UP
	step UP
	turn_head LEFT
	step_end

ElmsLab_CantLeaveMovement:
	step UP
	step_end

MeetCopScript2_StepLeft:
	step LEFT
	step_end

MeetCopScript_WalkUp:
	step UP
	step UP
	turn_head RIGHT
	step_end

MeetCopScript_GiveEgg:
	turn_head_up
	step_end

OfficerLeavesMovement:
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step_end

AideWalksRight1:
	step RIGHT
	step RIGHT
	turn_head UP
	step_end

AideWalksRight2:
	step RIGHT
	step RIGHT
	step RIGHT
	turn_head UP
	step_end

AideWalksLeft1:
	step LEFT
	step LEFT
	turn_head DOWN
	step_end

AideWalksLeft2:
	step LEFT
	step LEFT
	step LEFT
	turn_head DOWN
	step_end

ElmJumpUpMovement:
	fix_facing
	big_step UP
	remove_fixed_facing
	step_end

ElmJumpDownMovement:
	fix_facing
	big_step DOWN
	remove_fixed_facing
	step_end

ElmJumpLeftMovement:
	fix_facing
	big_step LEFT
	remove_fixed_facing
	step_end

ElmJumpRightMovement:
	fix_facing
	big_step RIGHT
	remove_fixed_facing
	step_end

ElmsLab_ElmToDefaultPositionMovement1:
	step UP
	step_end

ElmsLab_ElmToDefaultPositionMovement2:
	step RIGHT
	step UP
	turn_head DOWN
	step_end

AfterCyndaquilMovement:
	step LEFT
	step LEFT
	step UP
	turn_head UP
	step_end

AfterCyndaquilRight:
	applymovement PLAYER, AfterCyndaquilMovementRight
	sjump ElmDirectionsScript

AfterCyndaquilMovementRight:
	step LEFT
	turn_head UP
	step_end

AfterTotodileMovement:
	step LEFT
	step LEFT
	step LEFT
	step UP
	turn_head UP
	step_end

AfterChikoritaMovement:
	step LEFT
	step LEFT
	step LEFT
	step LEFT
	step UP
	turn_head UP
	step_end

ElmText_Intro:
	text "ELM: <PLAY_G>!"
	line "There you are!"

if !DEF(_DEBUG)
	para "I needed to ask"
	line "you a favor."

	para "I'm conducting new"
	line "#MON research"

	para "right now. I was"
	line "wondering if you"

	para "could help me with"
	line "it, <PLAY_G>."

	para "You see…"

	para "I'm writing a"
	line "paper that I want"

	para "to present at a"
	line "conference."

	para "But there are some"
	line "things I don't"

	para "quite understand"
	line "yet."

	para "So!"

	para "I'd like you to"
	line "raise a #MON"

	para "that I recently"
	line "caught."
endc
	done

ElmText_Accepted:
	text "Thanks, <PLAY_G>!"

	para "You're a great"
	line "help!"
	done

ElmText_Refused:
	text "But… Please, I"
	line "need your help!"
	done

ElmText_ResearchAmbitions:
	text "When I announce my"
	line "findings, I'm sure"

	para "we'll delve a bit"
	line "deeper into the"

	para "many mysteries of"
	line "#MON."

	para "You can count on"
	line "it!"
	done

ElmText_GotAnEmail:
	text "Oh, hey! I got an"
	line "e-mail!"

	para "<……><……><……>"
	line "Hm… Uh-huh…"

	para "Okay…"
	done

ElmText_MissionFromMrPokemon:
	text "Hey, listen."

	para "I have an acquain-"
	line "tance called MR."
	cont "#MON."

	para "He keeps finding"
	line "weird things and"

	para "raving about his"
	line "discoveries."

	para "Anyway, I just got"
	line "an e-mail from him"

	para "saying that this"
	line "time it's real."

	para "It is intriguing,"
	line "but we're busy"

	para "with our #MON"
	line "research…"

	para "Wait!"

	para "I know!"

	para "<PLAY_G>, can you"
	line "go in our place?"
	done

ElmText_ChooseAPokemon:
	text "I want you to"
	line "raise one of the"

	para "#MON contained"
	line "in these BALLS."

	para "You'll be that"
	line "#MON's first"
	cont "partner, <PLAY_G>!"

	para "Go on. Pick one!"
	done

ElmText_LetYourMonBattleIt:
	text "If a wild #MON"
	line "appears, let your"
	cont "#MON battle it!"
	done

LabWhereGoingText:
	text "ELM: Wait! Where"
	line "are you going?"
	done

TakeCyndaquilText:
	text "ELM: You'll take"
	line "CYNDAQUIL, the"
	cont "fire #MON?"
	done

TakeTotodileText:
	text "ELM: Do you want"
	line "TOTODILE, the"
	cont "water #MON?"
	done

TakeChikoritaText:
	text "ELM: So, you like"
	line "CHIKORITA, the"
	cont "grass #MON?"
	done

DidntChooseStarterText:
	text "ELM: Think it over"
	line "carefully."

	para "Your partner is"
	line "important."
	done

ChoseStarterText:
	text "ELM: I think"
	line "that's a great"
	cont "#MON too!"
	done

ReceivedStarterText:
	text "<PLAYER> received"
	line "@"
	text_ram wStringBuffer3
	text "!"
	done

ElmDirectionsText1:
	text "MR.#MON lives a"
	line "little bit beyond"

	para "CHERRYGROVE, the"
	line "next city over."

	para "It's almost a"
	line "direct route"

	para "there, so you"
	line "can't miss it."

	para "But just in case,"
	line "here's my phone"

	para "number. Call me if"
	line "anything comes up!"
	done

ElmDirectionsText2:
	text "If your #MON is"
	line "hurt, you should"

	para "heal it with this"
	line "machine."

	para "Feel free to use"
	line "it anytime."
	done

ElmDirectionsText3:
	text "<PLAY_G>, I'm"
	line "counting on you!"
	done

GotElmsNumberText:
	text "<PLAYER> got ELM's"
	line "phone number."
	done

ElmDescribesMrPokemonText:
	text "MR.#MON goes"
	line "everywhere and"
	cont "finds rarities."

	para "Too bad they're"
	line "just rare and"
	cont "not very useful…"
	done

ElmPokeBallText:
	text "It contains a"
	line "#MON caught by"
	cont "PROF.ELM."
	done

ElmsLabHealingMachineText1:
	text "I wonder what this"
	line "does?"
	done

ElmsLabHealingMachineText2:
	text "Would you like to"
	line "heal your #MON?"
	done

ElmAfterTheftText1:
	text "ELM: <PLAY_G>, this"
	line "is terrible…"

	para "Oh, yes, what was"
	line "MR.#MON's big"
	cont "discovery?"
	done

ElmAfterTheftText2:
	text "<PLAYER> handed"
	line "the MYSTERY EGG to"
	cont "PROF.ELM."
	done

ElmAfterTheftText3:
	text "ELM: This?"
	done

ElmAfterTheftText4:
	text "But… Is it a"
	line "#MON EGG?"

	para "If it is, it is a"
	line "great discovery!"
	done

ElmAfterTheftText5:
	text "ELM: What?!?"

if !DEF(_DEBUG)
	para "PROF.OAK gave you"
	line "a #DEX?"

	para "<PLAY_G>, is that"
	line "true? Th-that's"
	cont "incredible!"

	para "He is superb at"
	line "seeing the poten-"
	cont "tial of people as"
	cont "trainers."

	para "Wow, <PLAY_G>. You"
	line "may have what it"

	para "takes to become"
	line "the CHAMPION."

	para "You seem to be"
	line "getting on great"
	cont "with #MON too."

	para "You should take"
	line "the #MON GYM"
	cont "challenge."

	para "The closest GYM"
	line "would be the one"
	cont "in VIOLET CITY."
endc
	done

ElmAfterTheftText6:
	text "…<PLAY_G>. The"
	line "road to the"

	para "championship will"
	line "be a long one."

	para "Before you leave,"
	line "make sure that you"
	cont "talk to your mom."
	done

ElmStudyingEggText:
	text "ELM: Don't give"
	line "up! I'll call if"

	para "I learn anything"
	line "about that EGG!"
	done

ElmAideHasTogepiText:
	text "ELM: <PLAY_G>?"
	line "Didn't you meet my"
	cont "assistant?"

	para "He should have met"
	line "you with TOGEPI"

	para "at VIOLET CITY's"
	line "#MON CENTER."

	para "You must have just"
	line "missed him. Try to"
	cont "catch him there."
	done

ElmWaitingTogepiEvolveText:
	text "ELM: Hey, has that"
	line "TOGEPI changed?"
	done

ElmThoughtTogepiEvolvedText:
	text "<PLAY_G>? I thought"
	line "TOGEPI evolved."

	para "Where is the"
	line "#MON?"
	done

ShowElmTogeticText1:
	text "ELM: <PLAY_G>, you"
	line "look great!"
	done

ShowElmTogeticText2:
	text "What?"
	line "That #MON!?!"
	done

ShowElmTogeticText3:
	text "Togepi evolved!"
	line "So, some #MON"
	cont "evolve based on"
	cont "strong feelings"
	cont "for their trainer…"

	para "And if there is"
	line "one, there are"
	cont "likely others."

	para "Wow, there's still"
	line "a lot of research"
	cont "to be done."
	done

ElmGiveMistStoneText1:
	text "Thanks, <PLAY_G>!"
	line "You're helping"

	para "unravel #MON"
	line "mysteries for us!"

	para "I want you to have"
	line "this as a token of"
	cont "our appreciation."
	done

ElmGiveMistStoneText2:
	text "That's a"
	line "MIST STONE."

	para "Some species of"
	line "#MON evolve"

	para "when they grow to"
	line "certain levels."

	para "Others evolve"
	line "when exposed to"
	cont "certain items."

	para "You'll have to"
	line "experiment to find"
	cont "out which #MON"
	cont "evolve using a"
	cont "MIST STONE."
	done

ElmText_CallYou:
	text "ELM: <PLAY_G>, I'll"
	line "call you if any-"
	cont "thing comes up."
	done

AideText_AfterTheft:
	text "…sigh… That"
	line "stolen #MON."

	para "I wonder how it's"
	line "doing."

	para "They say a #MON"
	line "raised by a bad"

	para "person turns bad"
	line "itself."
	done

ElmGiveMasterBallText1:
	text "ELM: Hi, <PLAY_G>!"
	line "Thanks to you, my"

	para "research is going"
	line "great!"

	para "Take this as a"
	line "token of my"
	cont "appreciation."
	done

ElmGiveMasterBallText2:
	text "The MASTER BALL is"
	line "the best!"

	para "It's the ultimate"
	line "BALL! It'll catch"

	para "any #MON with-"
	line "out fail."

	para "It's given only to"
	line "recognized #MON"
	cont "researchers."

	para "I think you can"
	line "make much better"

	para "use of it than I"
	line "can, <PLAY_G>!"
	done

ElmGiveTicketText1:
	text "ELM: <PLAY_G>!"
	line "There you are!"

	para "If TEAM ROCKET is"
	line "back in KANTO,"
	cont "someone has to"
	cont "find out."

	para "Would you go and"
	line "see if the rumors"
	cont "are true?"

	para "Here, take this"
	line "S.S.TICKET."
	done

ElmGiveTicketText2:
	text "The ship departs"
	line "from OLIVINE CITY."

	para "Be careful, and"
	line "give my regards to"
	cont "PROF.OAK in KANTO!"
	done

AideText_GiveYouPotion:
	text "<PLAY_G>, I want"
	line "you to have this"
	cont "for your errand."
	done

AideText_ReadBooksReminder:
	text "Oh! You might want"
	line "to read the"
	cont "professor's travel"
	cont "tips and research"
	cont "notes."

	para "They contain lots"
	line "of useful info and"
	cont "are always here"
	cont "for new trainers"
	cont "to review."
	done

AideText_AlwaysBusy:
	text "There are only two"
	line "of us, so we're"
	cont "always busy."

	para "Have you read any"
	line "of Elm's travel"
	cont "tips or research"
	cont "notes?"
	done

AideText_CongratulationsE4Win:
	text "Congratulations on"
	line "your win against"
	cont "the Elite Four!"

	para "How have your"
	line "rematches with gym"
	cont "leaders gone?"

	para "You can face them"
	line "again each time"
	cont "you defeat the"
	cont "CHAMPION."
	done

AideText_TheftTestimony:
	text "There was a loud"
	line "noise outside…"

	para "When we went to"
	line "look, someone"
	cont "stole a #MON."

	para "It's unbelievable"
	line "that anyone would"
	cont "do that!"

	para "…sigh… That"
	line "stolen #MON."

	para "I wonder how it's"
	line "doing."

	para "They say a #MON"
	line "raised by a bad"

	para "person turns bad"
	line "itself."
	done

AideText_GiveYouBalls:
	text "<PLAY_G>!"

	para "Use these on your"
	line "#DEX quest!"
	done

AideText_ExplainBalls:
	text "To add to your"
	line "#DEX, you have"
	cont "to catch #MON."

	para "Throw # BALLS"
	line "at wild #MON"
	cont "to get them."
	done

ElmsLabOfficerText1:
	text "I heard a #MON"
	line "was stolen here…"

	para "I was just getting"
	line "some information"
	cont "from PROF.ELM."

	para "Apparently, it was"
	line "a young male with"
	cont "long, red hair…"

	para "What?"

	para "You battled a"
	line "trainer like that?"

	para "Did you happen to"
	line "get his name?"
	done

ElmsLabOfficerText2:
	text "OK! So <RIVAL>"
	line "was his name."

	para "Thanks for helping"
	line "my investigation!"
	done

ElmsLabWindowText1:
	text "The window's open."

	para "A pleasant breeze"
	line "is blowing in."
	done

ElmsLabWindowText2:
	text "He broke in"
	line "through here!"
	done

ElmsLabTravelTip1Text:
	text "<PLAYER> opened a"
	line "book."

	para "Travel Tip 1:"

	para "Trainers can fight"
	line "gym leaders again"
	cont "after they collect"
	cont "all the badges in"
	cont "JOHTO and KANTO."
	done

ElmsLabTravelTip2Text:
	text "<PLAYER> opened a"
	line "book."

	para "Travel Tip 2:"

	para "Many #MON that"
	line "were thought to be"
	cont "NORMAL type are"
	cont "actually the newly"
	cont "discovered FAIRY"
	cont "type."
	done

ElmsLabTravelTip3Text:
	text "<PLAYER> opened a"
	line "book."

	para "Travel Tip 3:"

    para "A #MON gains"
    line "more experience"

    para "when it faces"
    line "stronger foes."

    para "Conversely, over-"
    line "leveled #MON"

    para "gain less from"
    line "weaker opponents."

	done

ElmsLabTravelTip4Text:
	text "<PLAYER> opened a"
	line "book."

	para "Travel Tip 4:"

	para "The clock can be"
	line "reset using the"
	cont "#GEAR."
	done

ElmsLabTravelTip5Text:
	text "<PLAYER> opened a"
	line "book."

	para "Travel Tip 5:"

	para "High level #MON"
	line "only obey if they"
	cont "are happy with"
	cont "their trainer."

	para "Nicknaming them"
	line "seems to help."
	done

ElmsLabTravelTip6Text:
	text "<PLAYER> opened a"
	line "book."

	para "Travel Tip 6:"

	para "Once you enter a"
	line "gym, it will be"
	cont "locked until you"
	cont "defeat the gym"
	cont "leader."
	done

ElmsLabTravelTip7Text:
	text "<PLAYER> opened a"
	line "book."

	para "Travel Tip 7:"

	para "Trainers can often"
	line "find rare items by"
	cont "smashing rocks and"
	cont "headbutting trees."

	para "Fishing rods also"
	line "sometimes catch"
	cont "more than just"
	cont "wild #MON."
	done

ElmsLabTravelTip8Text:
	text "<PLAYER> opened a"
	line "book."

	para "Travel Tip 8:"

	para "Wild #MON are"
	line "prone to fleeing."

	para "And be careful!"

	para "Others will keep"
	line "you trapped in an"
	cont "encounter."
	done

ElmsResearchNotes1Text:
	text "<PLAYER> opened a"
	line "set of notes."

	para "Research Notes 1:"

	para "A MIST STONE will"
	line "evolve a #MON"
	cont "we once thought"
	cont "only evolved when"
	cont "traded."
	done

ElmsResearchNotes2Text:
	text "<PLAYER> opened a"
	line "set of notes."

	para "Research Notes 2:"

	para "The radio channel"
	line "#MON Lullaby"
	cont "can help avoid"
	cont "wild encounters."

	para "This was quite"
	line "useful in the area"
	cont "beneath Mt Mortar."
	done

ElmsResearchNotes3Text:
	text "<PLAYER> opened a"
	line "set of notes."

	para "Research Notes 3:"

	para "There must be a"
	line "location where"
	cont "baby #MON are"
	cont "born and raised."

	para "There is also"
	line "probably a place"
	cont "where fully"
	cont "evolved #MON"
	cont "are very common."
	done

ElmsResearchNotes4Text:
	text "<PLAYER> opened a"
	line "set of notes."

	para "Research Notes 4:"

	para "Where are all the"
	line "legendaries? Oak"
	cont "believes they will"
	cont "reveal themselves"
	cont "to trainers only"
	cont "after they have"
	cont "proven themselves"
	cont "worthy."
	done

ElmsLabTrashcanText:
	text "The wrapper from"
	line "the snack PROF.ELM"
	cont "ate is in there…"
	done

ElmsLabPCText:
	text "OBSERVATIONS ON"
	line "#MON EVOLUTION"

	para "…It says on the"
	line "screen…"
	done

ElmsLab_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4, 11, NEW_BARK_TOWN, 1
	warp_event  5, 11, NEW_BARK_TOWN, 1

	def_coord_events
	coord_event  4,  6, SCENE_ELMSLAB_CANT_LEAVE, LabTryToLeaveScript
	coord_event  5,  6, SCENE_ELMSLAB_CANT_LEAVE, LabTryToLeaveScript
	coord_event  4,  5, SCENE_ELMSLAB_MEET_OFFICER, MeetCopScript
	coord_event  5,  5, SCENE_ELMSLAB_MEET_OFFICER, MeetCopScript2
	coord_event  4,  8, SCENE_ELMSLAB_AIDE_GIVES_POTION, AideScript_WalkPotion1
	coord_event  5,  8, SCENE_ELMSLAB_AIDE_GIVES_POTION, AideScript_WalkPotion2
	coord_event  4,  8, SCENE_ELMSLAB_AIDE_GIVES_POKE_BALLS, AideScript_WalkBalls1
	coord_event  5,  8, SCENE_ELMSLAB_AIDE_GIVES_POKE_BALLS, AideScript_WalkBalls2

	def_bg_events
	bg_event  2,  1, BGEVENT_READ, ElmsLabHealingMachine
	bg_event  6,  1, BGEVENT_READ, ElmsResearchNotes1
	bg_event  7,  1, BGEVENT_READ, ElmsResearchNotes2
	bg_event  8,  1, BGEVENT_READ, ElmsResearchNotes3
	bg_event  9,  1, BGEVENT_READ, ElmsResearchNotes4
	bg_event  0,  7, BGEVENT_READ, ElmsLabTravelTip1
	bg_event  1,  7, BGEVENT_READ, ElmsLabTravelTip2
	bg_event  2,  7, BGEVENT_READ, ElmsLabTravelTip3
	bg_event  3,  7, BGEVENT_READ, ElmsLabTravelTip4
	bg_event  6,  7, BGEVENT_READ, ElmsLabTravelTip5
	bg_event  7,  7, BGEVENT_READ, ElmsLabTravelTip6
	bg_event  8,  7, BGEVENT_READ, ElmsLabTravelTip7
	bg_event  9,  7, BGEVENT_READ, ElmsLabTravelTip8
	bg_event  9,  3, BGEVENT_READ, ElmsLabTrashcan
	bg_event  5,  0, BGEVENT_READ, ElmsLabWindow
	bg_event  3,  5, BGEVENT_DOWN, ElmsLabPC

	def_object_events
	object_event  4,  2, SPRITE_ELM, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ProfElmScript, -1
	object_event  2,  9, SPRITE_SCIENTIST, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ElmsAideScript, EVENT_ELMS_AIDE_IN_LAB
	object_event  6,  3, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CyndaquilPokeBallScript, EVENT_CYNDAQUIL_POKEBALL_IN_ELMS_LAB
	object_event  7,  3, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, TotodilePokeBallScript, EVENT_TOTODILE_POKEBALL_IN_ELMS_LAB
	object_event  8,  3, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ChikoritaPokeBallScript, EVENT_CHIKORITA_POKEBALL_IN_ELMS_LAB
	object_event  5,  3, SPRITE_OFFICER, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, CopScript, EVENT_COP_IN_ELMS_LAB

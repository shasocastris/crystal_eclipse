	object_const_def
	const RUINSOFALPHRESEARCHCENTER_SCIENTIST1
	const RUINSOFALPHRESEARCHCENTER_SCIENTIST2
	const RUINSOFALPHRESEARCHCENTER_ROCKET3
	const RUINSOFALPHRESEARCHCENTER_ELM

RuinsOfAlphResearchCenter_MapScripts:
	def_scene_scripts
	scene_script RuinsOfAlphResearchCenterClosed,     SCENE_RUINSOFALPHRESEARCHCENTER_CLOSED
	scene_script RuinsOfAlphResearchCenterElmPresent, SCENE_RUINSOFALPHRESEARCHCENTER_ELM_PRESENT
	scene_script RuinsOfAlphResearchCenterNoopScene,  SCENE_RUINSOFALPHRESEARCHCENTER_NOOP

	def_callbacks

RuinsOfAlphResearchCenterNoopScene:
	end

RuinsOfAlphResearchCenterClosed:
	sdefer ResearchCenterClosed
	end

RuinsOfAlphResearchCenterElmPresent:
	sdefer RuinsOfAlphResearchCenterElmScript
	end

RuinsOfAlphResearchCenterScientist1Script:
	faceplayer
	opentext
	checkflag ENGINE_UNOWN_DEX
	iftrue .GotUnownDex
	writetext RuinsOfAlphResearchCenterScientist1Text
	waitbutton
	showemote EMOTE_SHOCK, RUINSOFALPHRESEARCHCENTER_SCIENTIST1, 30
	writetext RuinsOfAlphResearchCenterScientist1Text_CaughtUnown
	waitbutton
	playsound SFX_BOOT_PC
	pause 60
	playsound SFX_SWITCH_POKEMON
	pause 30
	playsound SFX_TALLY
	pause 30
	playsound SFX_TRANSACTION
	pause 30
	writetext RuinsOfAlphResearchCenterModifiedDexText
	waitbutton
	playsound SFX_ITEM
	waitsfx
	setflag ENGINE_UNOWN_DEX
	writetext RuinsOfAlphResearchCenterCaughtAllUnownText
	waitbutton
	closetext
	end

.GotUnownDex:
	writetext RuinsOfAlphResearchCenterScientist1Text_GotUnownDex
	waitbutton
	closetext
	end

RuinsOfAlphResearchCenterScientist2Script:
	jumptextfaceplayer RuinsOfAlphResearchCenterScientist2Text_UnownAppeared

RuinsOfAlphResearchCenterComputer:
	opentext
	checkflag ENGINE_UNOWN_DEX
	iftrue .GotUnownDex
	writetext RuinsOfAlphResearchCenterComputerText
	waitbutton
	closetext
	end

.GotUnownDex
	writetext RuinsOfAlphResearchCenterComputerText_GotAllUnown
	waitbutton
	closetext
	end

ResearchCenterClosed:
	applymovement PLAYER, ResearchCenterPlayerStepUpMovement
	opentext
	writetext ResearchCenterClosedText
	waitbutton
	closetext
	stowfollower
	follow PLAYER, RUINSOFALPHRESEARCHCENTER_ROCKET3
	applymovement PLAYER, ResearchCenterPlayerSlowStepDownMovement
	stopfollow
	special FadeOutToWhite
	playsound SFX_ENTER_DOOR
	waitsfx
	warp RUINS_OF_ALPH_OUTSIDE, 19, 12
	end

RuinsOfAlphResearchCenterElmScript:
	appear RUINSOFALPHRESEARCHCENTER_ELM
	stowfollower
	applymovement PLAYER, ResearchCenterPlayerApproachesElmMovement
    turnobject PLAYER, RIGHT
	opentext
	checkevent EVENT_MET_ELM_AT_RESEARCH_CENTER
	iftrue .DuringBattle
	writetext RuinsOfAlphResearchCenterElmText_Searching
	waitbutton
	closetext
	setevent EVENT_MET_ELM_AT_RESEARCH_CENTER
	applymovement PLAYER, ResearchCenterPlayerLeavesElmMovement
    special FadeOutToWhite
	playsound SFX_ENTER_DOOR
	waitsfx
	warp RUINS_OF_ALPH_OUTSIDE, 19, 12
	end

.DuringBattle:
	checkevent EVENT_RUINS_OF_ALPH_ROCKETS
	iffalse .PostBattle
	writetext RuinsOfAlphResearchCenterElmText_LabSecured
	waitbutton
	closetext
    applymovement PLAYER, ResearchCenterPlayerLeavesElmMovement
    special FadeOutToWhite
	playsound SFX_ENTER_DOOR
	waitsfx
	warp RUINS_OF_ALPH_OUTSIDE, 19, 12
	end

.PostBattle:
	writetext RuinsOfAlphResearchCenterElmText_Relieved
	waitbutton
	closetext
	applymovement RUINSOFALPHRESEARCHCENTER_ELM, ResearchCenterElmLeavesMovement
	playsound SFX_ENTER_DOOR
	disappear RUINSOFALPHRESEARCHCENTER_ELM
	waitsfx
	setmapscene RUINS_OF_ALPH_RESEARCH_CENTER, SCENE_RUINSOFALPHRESEARCHCENTER_NOOP
	setevent EVENT_ELM_NOT_AT_RUINS_RESEARCH_CENTER
	appearfolloweronestep
	end

RuinsOfAlphResearchCenterBookshelf:
	jumptext RuinsOfAlphResearchCenterAcademicBooksText

ResearchCenterPlayerStepUpMovement:
	step UP
	step_end

ResearchCenterPlayerSlowStepDownMovement:
	fix_facing
	slow_step DOWN
	remove_fixed_facing
	step_end

ResearchCenterPlayerApproachesElmMovement:
	step UP
	step_end

ResearchCenterPlayerLeavesElmMovement:
	step DOWN
	step_end

ResearchCenterElmLeavesMovement:
	step DOWN
	step DOWN
	step_end

RuinsOfAlphResearchCenterScientist1Text:
	text "Thank you so much"
	line "for rescuing us"
	cont "from TEAM ROCKET!"

	para "They locked us in"
	line "here and were"
	cont "stealing our work"
	cont "on the ruins."
	done

RuinsOfAlphResearchCenterScientist1Text_CaughtUnown:
	text "What's this?"

	para "You caught all the"
	line "UNOWN?"

	para "That's a stunning"
	line "discovery."

	para "Let me add what"
	line "you found to that"
	cont "#DEX."
	done

RuinsOfAlphResearchCenterModifiedDexText:
	text "Done!"

	para "I modified your"
	line "#DEX."

	para "I added an"
	line "optional #DEX"

	para "to store data for"
	line "the new #MON."

	para "It records them in"
	line "the sequence that"
	cont "they were caught."
	done

RuinsOfAlphResearchCenterCaughtAllUnownText:
	text "And you caught so"
	line "many variants?"

	para "There really was a"
	line "secret hiding amid"
	cont "the rubble."

	para "We'll have to"
	line "explore it further"
	cont "and see what else"
	cont "can be discovered."
	done

RuinsOfAlphResearchCenterScientist1Text_GotUnownDex:
	text "I wonder if there"
	line "are other chambers"
	cont "we still haven't"
	cont "found."
	done

RuinsOfAlphResearchCenterScientist2Text_UnownAppeared:
	text "The strange #-"
	line "MON you saw in the"
	cont "RUINS?"

	para "They appear to be"
	line "very much like the"

	para "drawings on the"
	line "walls there."

	para "Hmm…"

	para "We'll need to"
	line "investigate this."
	done

RuinsOfAlphResearchCenterComputerText:
	text "RUINS OF ALPH"

	para "Exploration"
	line "Year 10"
	done

RuinsOfAlphResearchCenterComputerText_GotAllUnown:
	text "Mystery #MON"
	line "Name: UNOWN"

	para "A total of {d:NUM_UNOWN}"
	line "kinds found."
	done

RuinsOfAlphResearchCenterAcademicBooksText:
	text "There are many"
	line "academic books."

	para "Ancient Ruins…"
	line "Mysteries of the"
	cont "Ancients…"
	done

ResearchCenterClosedText:
	text "This place is"
	line "closed!"

	para "SCRAM!"
	done

RuinsOfAlphResearchCenterElmText_Searching:
    text "ELM: <PLAY_G>!"
    line "Thank goodness."

    para "TEAM ROCKET locked"
    line "the staff in here."

    para "I've secured this"
    line "GRUNT."

    para "We overheard them."
    line "They're hunting"
    cont "for a new #MON."

    para "The researchers"
    line "think there are"
    cont "26 variants hidden"
    cont "behind the four"
    cont "puzzle chambers,"

    para "and catching every"
    line "will activate the"
    cont "shrine."

    para "We're not sure why"
    line "TEAM ROCKET wants"
    cont "to do that."

    para "But they haven't"
    line "solved any puzzles"
    cont "yet."

    para "If you catch those"
    line "#MON first,"
    cont "their plan fails!"

    para "The first thing"
    line "you'll need to do"
    cont "is get past those"
    cont "guards."
    done

RuinsOfAlphResearchCenterElmText_LabSecured:
    text "ELM: I've got the"
    line "lab secured."

    para "Make sure to catch"
    line "the #MON and"
    cont "stop TEAM ROCKET."
    done

RuinsOfAlphResearchCenterElmText_Relieved:
    text "ELM: You did it!"
    line "TEAM ROCKET is"
    cont "gone."

    para "The researchers"
    line "are safe."

    para "We have a lot of"
    line "work ahead of us"
    cont "to uncover all of"
    cont "the secrets of the"
    cont "RUINS OF ALPH."

    para "Thank you,"
    line "<PLAY_G>."
    done

RuinsOfAlphResearchCenter_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2,  7, RUINS_OF_ALPH_OUTSIDE, 6
	warp_event  3,  7, RUINS_OF_ALPH_OUTSIDE, 6

	def_coord_events

	def_bg_events
	bg_event  6,  5, BGEVENT_READ, RuinsOfAlphResearchCenterBookshelf
	bg_event  3,  4, BGEVENT_READ, RuinsOfAlphResearchCenterComputer

	def_object_events
	object_event  4,  5, SPRITE_SCIENTIST, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, RuinsOfAlphResearchCenterScientist1Script, -1
	object_event  5,  2, SPRITE_SCIENTIST, SPRITEMOVEDATA_WANDER, 2, 1, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, RuinsOfAlphResearchCenterScientist2Script, -1
	object_event  2,  5, SPRITE_ROCKET, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_RUINS_OF_ALPH_RESEARCH_CENTER_ROCKET
	object_event  3,  6, SPRITE_ELM, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, RuinsOfAlphResearchCenterElmScript, EVENT_ELM_NOT_AT_RUINS_RESEARCH_CENTER
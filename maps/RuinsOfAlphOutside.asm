	object_const_def
	const RUINSOFALPHOUTSIDE_SCIENTIST_WERNER
	const RUINSOFALPHOUTSIDE_SCIENTIST_ENRICO
	const RUINSOFALPHOUTSIDE_SCIENTIST_NIELS
	const RUINSOFALPHOUTSIDE_SCIENTIST_EARNEST
	const RUINSOFALPHOUTSIDE_ROCKET
	const RUINSOFALPHOUTSIDE_ROCKET_GIRL
	const RUINSOFALPHOUTSIDE_SUICUNE

RuinsOfAlphOutside_MapScripts:
	def_scene_scripts
	scene_script RuinsOfAlphOutsideNoop1Scene, SCENE_RUINSOFALPHOUTSIDE_ROCKET_BOSS
	scene_script RuinsOfAlphOutsideNoop2Scene, SCENE_RUINSOFALPHOUTSIDE_NOOP

	def_callbacks
	callback MAPCALLBACK_TILES, RuinsOfAlphOutsideShrineCallback

RuinsOfAlphOutsideNoop1Scene:
	end

RuinsOfAlphOutsideNoop2Scene:
	end
	
RuinsOfAlphOutsideShrineCallback:
	readvar VAR_UNOWNCOUNT
	ifless NUM_UNOWN, .ShrineOff
	endcallback
.ShrineOff:
	changeblock 6, 24, $AD ; unactivated shrine
	endcallback

RuinsOfAlphOutsideScientistWerner_Script:
	faceplayer
	opentext
	checkevent EVENT_MET_ELM_AT_RESEARCH_CENTER
	iffalse .GetLost
	checkevent EVENT_RUINS_OF_ALPH_ROCKETS
	iffalse .GetLost
	writetext WernerFight_Text
	waitbutton
	closetext
	winlosstext WernerWin_Text, 0
	loadtrainer SCIENTIST, WERNER
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_SCIENTIST_WERNER
	opentext
	writetext WernerWarnOthers_Text
	waitbutton
	closetext
	applymovement RUINSOFALPHOUTSIDE_SCIENTIST_WERNER, RuinsOfAlphOutsideScientistWernerMovement
	playsound SFX_ENTER_DOOR
	disappear RUINSOFALPHOUTSIDE_SCIENTIST_WERNER
	waitsfx
	end

.GetLost
	writetext RuinsOfAlphOutsideScientistWerner_Text
	waitbutton
	closetext
	end

RuinsOfAlphOutsideScientistEnrico_Script:
	faceplayer
	opentext
	checkevent EVENT_MET_ELM_AT_RESEARCH_CENTER
	iffalse .NormalText
	checkevent EVENT_RUINS_OF_ALPH_ROCKETS
	iffalse .NormalText
	writetext EnricoFight_Text
	waitbutton
	closetext
	winlosstext EnricoWin_Text, 0
	loadtrainer SCIENTIST, ENRICO
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_SCIENTIST_ENRICO
	opentext
	writetext EnricoAfterBattle_Text
	waitbutton
	closetext
	applymovement RUINSOFALPHOUTSIDE_SCIENTIST_ENRICO, RuinsOfAlphOutsideScientistEnricoMovement
	playsound SFX_ENTER_DOOR
	disappear RUINSOFALPHOUTSIDE_SCIENTIST_ENRICO
	waitsfx
	end

.NormalText
	writetext RuinsOfAlphOutsideScientistEnrico_Text
	waitbutton
	closetext
	end

RuinsOfAlphOutsideScientistNiels_Script:
	faceplayer
	opentext
	checkevent EVENT_MET_ELM_AT_RESEARCH_CENTER
	iffalse .Research
	checkevent EVENT_RUINS_OF_ALPH_ROCKETS
	iffalse .Research
	writetext NielsFight_Text
	waitbutton
	closetext
	winlosstext NielsWin_Text, 0
	loadtrainer SCIENTIST, NIELS
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_SCIENTIST_NIELS
	opentext
	writetext NielsAfterBattle_Text
	waitbutton
	closetext
	applymovement RUINSOFALPHOUTSIDE_SCIENTIST_NIELS, RuinsOfAlphOutsideScientistNielsMovement
	playsound SFX_ENTER_DOOR
	disappear RUINSOFALPHOUTSIDE_SCIENTIST_NIELS
	waitsfx
	end

.Research
	writetext RuinsOfAlphOutsideScientistNiels_Text
	waitbutton
	closetext
	end

RuinsOfAlphOutsideScientistEarnest_Script:
	faceplayer
	opentext
	checkevent EVENT_MET_ELM_AT_RESEARCH_CENTER
	iffalse .Studying
	checkevent EVENT_RUINS_OF_ALPH_ROCKETS
	iffalse .Studying
	writetext EarnestFight_Text
	waitbutton
	closetext
	winlosstext EarnestWin_Text, 0
	loadtrainer SCIENTIST, EARNEST
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_SCIENTIST_EARNEST
	opentext
	writetext EarnestAfterBattle_Text
	waitbutton
	closetext
	applymovement RUINSOFALPHOUTSIDE_SCIENTIST_EARNEST, RuinsOfAlphOutsideScientistEarnestMovement
	playsound SFX_ENTER_DOOR
	disappear RUINSOFALPHOUTSIDE_SCIENTIST_EARNEST
	waitsfx
	end

.Studying
	writetext RuinsOfAlphOutsideScientistEarnest_Text
	waitbutton
	closetext
	end

ShrineFight:
	readvar VAR_UNOWNCOUNT
	ifequal NUM_UNOWN, .FightExecutives
	end
.FightExecutives
	appear RUINSOFALPHOUTSIDE_ROCKET
	appear RUINSOFALPHOUTSIDE_ROCKET_GIRL
	opentext
	writetext RuinsOfAlphOutsideExecutiveFHoldItText
	waitbutton
	closetext
	turnobject PLAYER, DOWN
	showemote EMOTE_SHOCK, PLAYER, 15
	applymovement PLAYER, RuinsOfAlphOutsidePlayerApproachesBossMovement
	playmusic MUSIC_ROCKET_ENCOUNTER
	applymovement RUINSOFALPHOUTSIDE_ROCKET_GIRL, RuinsOfAlphOutsideBossFApproachesPlayerMovement
	turnobject PLAYER, UP
	applymovement RUINSOFALPHOUTSIDE_ROCKET, RuinsOfAlphOutsideGruntApproachesPlayerMovement
	opentext
	writetext RuinsOfAlphOutsideBossFSeenText
	waitbutton
	closetext
	appear RUINSOFALPHOUTSIDE_SUICUNE
	cry SUICUNE
	opentext
	writetext RuinsOfAlphSuicuneRoarText
	waitbutton
	closetext
	turnobject RUINSOFALPHOUTSIDE_ROCKET_GIRL, LEFT
	turnobject PLAYER, LEFT
	applymovement RUINSOFALPHOUTSIDE_SUICUNE, RuinsOfAlphOutsideSuicuneAttacksMovement
	applymovement RUINSOFALPHOUTSIDE_ROCKET_GIRL, RuinsOfAlphOutsideBossFHitMovement
	applymovement RUINSOFALPHOUTSIDE_ROCKET, RuinsOfAlphOutsideGruntProtectsBossFMovement
	turnobject PLAYER, RIGHT
	applymovement RUINSOFALPHOUTSIDE_ROCKET_GIRL, RuinsOfAlphOutsideBossFFacesPlayerMovement
	opentext
	writetext RuinsOfAlphOutsideBossSuicuneRumorsText
	waitbutton
	closetext
	applymovement RUINSOFALPHOUTSIDE_ROCKET, RuinsOfAlphOutsideGruntBattlesSuicuneMovement
	applymovement RUINSOFALPHOUTSIDE_ROCKET_GIRL, RuinsOfAlphOutsideBossFBattlesPlayerMovement

	winlosstext RuinsOfAlphOutsideBossWinText, 0
	setlasttalked RUINSOFALPHOUTSIDE_ROCKET_GIRL
	loadtrainer EXECUTIVEF, EXECUTIVEF_2
	loadvar VAR_BATTLETYPE, BATTLETYPE_SET
	startbattle
	setevent EVENT_DEFEATED_RUINS_OF_ALPH_ROCKETS
	setevent EVENT_RUINS_OF_ALPH_RESEARCH_CENTER_ROCKET
	setevent EVENT_BEAT_ROCKET_EXECUTIVEF_2
	reloadmapafterbattle

	opentext
	writetext RuinsOfAlphOutsideBossFleeFromSuicuneText
	waitbutton
	closetext
	special FadeOutToBlack
	special ReloadSpritesNoPalettes
	disappear RUINSOFALPHOUTSIDE_ROCKET_GIRL
	disappear RUINSOFALPHOUTSIDE_ROCKET
	pause 15
	special FadeInFromBlack
	setscene SCENE_RUINSOFALPHOUTSIDE_NOOP
	setmapscene ICE_PATH_1F, SCENE_ICEPATH1F_RIVAL
	opentext
	writetext RuinsOfAlphOutsideSuicunePostBattleText
	waitbutton
	closetext
	applymovement RUINSOFALPHOUTSIDE_SUICUNE, RuinsOfAlphOutsideSuicuneMoveToPlayerMovement
	opentext
	writetext RuinsOfAlphOutsideSuicuneApproachesPlayer
	waitbutton
	closetext
	showemote EMOTE_SHOCK, RUINSOFALPHOUTSIDE_SUICUNE, 15
	applymovement RUINSOFALPHOUTSIDE_SUICUNE, RuinsOfAlphOutsideSuicuneMoveToShrineMovement
	pause 30
	applymovement RUINSOFALPHOUTSIDE_SUICUNE, RuinsOfAlphOutsideSuicuneMoveBackToPlayerMovement
	opentext
	writetext RuinsOfAlphOutsideSuicuneGivesPlayerClearBellText
	promptbutton
	verbosegiveitem CLEAR_BELL
	waitbutton
	writetext RuinsOfAlphOutsideClearBellEcruteakCityText
	waitbutton
	closetext
	applymovement RUINSOFALPHOUTSIDE_SUICUNE, RuinsOfAlphOutsideSuicuneCirclesPlayerPlayerMovement
	pause 30
	applymovement RUINSOFALPHOUTSIDE_SUICUNE, RuinsOfAlphOutsideSuicuneLeavesMovement
	disappear RUINSOFALPHOUTSIDE_SUICUNE
	setevent EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_EAST
	setmapscene MAHOGANY_TOWN, SCENE_MAHOGANYTOWN_NOOP
	setmapscene RUINS_OF_ALPH_RESEARCH_CENTER, SCENE_RUINSOFALPHRESEARCHCENTER_NOOP
	end

RuinsOfAlphOutsideMysteryChamberSign:
	jumptext RuinsOfAlphOutsideMysteryChamberSignText

RuinsOfAlphSign:
	jumptext RuinsOfAlphSignText

RuinsOfAlphResearchCenterSign:
	jumptext RuinsOfAlphResearchCenterSignText

RuinsOfAlphOutsideScientistWernerMovement:
RuinsOfAlphOutsideScientistEnricoMovement:
RuinsOfAlphOutsideScientistNielsMovement:
RuinsOfAlphOutsideScientistEarnestMovement:
	step UP
	step_end

RuinsOfAlphOutsidePlayerApproachesBossMovement:
	step RIGHT
	step RIGHT
	step_end

RuinsOfAlphOutsideBossFApproachesPlayerMovement:
	step UP
	step UP
	step UP
	step UP
	step UP
	step UP
	step LEFT
	step LEFT
	step LEFT
	turn_head DOWN
	step_end

RuinsOfAlphOutsideGruntApproachesPlayerMovement:
	step UP
	step UP
	step UP
	step UP
	step UP
	step LEFT
	step LEFT
	step_end

RuinsOfAlphOutsideSuicuneAttacksMovement:
	step UP
	set_sliding
	fast_jump_step RIGHT
	fast_jump_step RIGHT
	remove_sliding
	step_end

RuinsOfAlphOutsideBossFHitMovement:
	fix_facing
	set_sliding
	jump_step RIGHT
	remove_sliding
	remove_fixed_facing
	step_end

RuinsOfAlphOutsideGruntProtectsBossFMovement:
	big_step UP
	turn_head LEFT
	step_end

RuinsOfAlphOutsideBossFFacesPlayerMovement:
	slow_step DOWN
	turn_head LEFT
	step_end

RuinsOfAlphOutsideGruntBattlesSuicuneMovement:
	big_step LEFT
	step_end

RuinsOfAlphOutsideBossFBattlesPlayerMovement:
	big_step LEFT
	step_end

RuinsOfAlphOutsideSuicuneMoveToPlayerMovement:
	step RIGHT
	step_end

RuinsOfAlphOutsideSuicuneMoveToShrineMovement:
	step LEFT
	step_end

RuinsOfAlphOutsideSuicuneMoveBackToPlayerMovement:
	step RIGHT
	turn_head DOWN
	step_end

RuinsOfAlphOutsideSuicuneCirclesPlayerPlayerMovement:
	set_sliding
	fast_jump_step RIGHT
	fast_jump_step DOWN
	fast_jump_step LEFT
	fast_jump_step UP
	remove_sliding
	turn_head DOWN
	step_end

RuinsOfAlphOutsideSuicuneLeavesMovement:
	set_sliding
	fast_jump_step UP
	fast_jump_step RIGHT
	fast_jump_step UP
	fast_jump_step UP
	remove_sliding
	step_end

WernerFight_Text:
	text "You there! This is"
	line "a restricted area!"
	
	para "We're conducting"
	line "critical research"
	cont "on the ruins!"
	done

WernerWin_Text:
	text "The patterns on"
	line "the walls-they"
	cont "look almost like"
	cont "#MON shapes…"
	done

WernerWarnOthers_Text:
	text "Tch! I must warn"
	line "the others!"
	
	para "If you are here,"
	line "the LEAGUE will be"
	cont "just behind!"
	done

RuinsOfAlphOutsideScientistWerner_Text:
	text "These ruins are"
	line "ancient. Over"
	cont "1500 years old!"
	done

EnricoFight_Text:
	text "An intruder?"

	para "I can't let you"
	line "disrupt our latest"
	cont "operation!"
	done

EnricoWin_Text:
	text "Curses! My"
	line "calculations…"
	done

EnricoAfterBattle_Text:
	text "The wall patterns"
	line "suggest 26 unique"
	cont "symbols."

	para "If they represent"
	line "#MON as we"
	cont "suspect…"

	para "Well, that's why"
	line "we're solving the"
	cont "puzzles!"

	para "The executives"
	line "want us to confirm"
	cont "if #MON really"
	cont "live here."
	done

RuinsOfAlphOutsideScientistEnrico_Text:
	text "I'm cataloging the"
	line "different puzzle"
	cont "chambers here."
	
	para "We suspect that"
	line "each one might"
	cont "reveal something"
	cont "new!"
	done

NielsFight_Text:
	text "Have we been"
	line "discovered?"

	para "No matter, I can't"
	line "you stop our"
	cont "research."
	done

NielsWin_Text:
	text "Fascinating"
	line "results!"
	done

NielsAfterBattle_Text:
	text "The ancient texts"
	line "describe #MON"
	cont "living in these"
	cont "chambers."

	para "But in 10 years of"
	line "official research,"
	cont "no one has found"
	cont "any."
	done

RuinsOfAlphOutsideScientistNiels_Text:
	text "The text on the"
	line "ruin walls suggest"

	para "there are 26 types"
	line "of something."

	para "We believe they're"
	line "#MON. We just"
	cont "need proof."
	done

EarnestFight_Text:
	text "Another pest! We"
	line "don't have time"
	cont "for this!"

	para "We need to solve"
	line "these puzzles and"

	para "find the #MON"
	line "before the LEAGUE"
	cont "gets wind of this!"
	done

EarnestWin_Text:
	text "Blast! That hurt!"
	done

EarnestAfterBattle_Text:
	text "We haven't been"
	line "able to figure out"
	cont "the blocks in each"
	cont "chamber."

	para "Perhaps #MON"
	line "will reveal"
	cont "themselves when we"
	cont "solve the puzzles."

	para "If the rumors are"
	line "true, capturing"

	para "these #MON will"
	line "give TEAM ROCKET"
	cont "unprecedented"
	cont "power!"
	done

RuinsOfAlphOutsideScientistEarnest_Text:
	text "If #MON shaped"
	line "like these symbols"
	cont "really exist…"
	
	para "Is this where"
	line "human language"
	cont "originated?"
	done

RuinsOfAlphOutsideExecutiveFHoldItText:
	text "Get away from that"
	line "shrine!"
	done

RuinsOfAlphOutsideBossFSeenText:
	text "Well, well. The"
	line "meddling child who"

	para "has been such a"
	line "massive pain."

	para "You disrupted our"
	line "SLOWPOKE operation"

	para "and sabotaged our"
	line "LAKE OF RAGE"
	cont "broadcast."

	para "You even quelled"
	line "the WILD HUNT we"
	cont "tried to use as a"
	cont "distraction."

	para "And now you think"
	line "you can stop us"
	cont "here?"

	para "Not on our watch!"

	para "The hidden power"
	line "of the RUINS OF"
	cont "ALPH will serve"
	cont "TEAM ROCKET!"
	done

RuinsOfAlphSuicuneRoarText:
	text "A crystalline howl"
	line "echoes through the"
	cont "ruins!"
	done

RuinsOfAlphOutsideBossSuicuneRumorsText:
	text "SUICUNE?!"

	para "Even a legendary"
	line "is opposing us?"

	para "So the rumors were"
	line "true…"

	para "A legendary beast"
	line "does watch over"
	cont "JOHTO."

	para "No matter! You're"
	line "both naive if you"

	para "think this will"
	line "stop TEAM ROCKET"
	cont "from dominating"
	cont "this region!"
	done

RuinsOfAlphOutsideBossWinText:
	text "What?! How can"
	line "this be?!"
	done

RuinsOfAlphOutsideBossFleeFromSuicuneText:
	text "All units"
	line "withdraw!"

	para "This mission is"
	line "compromised!"

	para "…"

	para "Consider yourself"
	line "fortunate, child."

	para "SUICUNE won't"
	line "always be there to"
	cont "protect you!"

	para "We'll return with"
	line "the power to crush"
	cont "any resistance!"
	done

RuinsOfAlphOutsideSuicunePostBattleText:
	text "SUICUNE roars in"
	line "triumph."
	done

RuinsOfAlphOutsideSuicuneApproachesPlayer:
	text "SUICUNE approaches"
	line "you carefully."
	done

RuinsOfAlphOutsideSuicuneGivesPlayerClearBellText:
	text "SUICUNE places"
	line "something at your"
	cont "feet."

	para "It chimes in a"
	line "loud, clear tone."
	done

RuinsOfAlphOutsideClearBellEcruteakCityText:
	text "The sounds reminds"
	line "you of the TIN"
	cont "TOWER in ECRUTEAK"
	cont "CITY."
	done

RuinsOfAlphOutsideMysteryChamberSignText:
	text "MYSTERY STONE"
	line "PANEL CHAMBER"
	done

RuinsOfAlphSignText:
	text "RUINS OF ALPH"
	line "VISITORS WELCOME"
	done

RuinsOfAlphResearchCenterSignText:
	text "RUINS OF ALPH"
	line "RESEARCH CENTER"

	para "THE AUTHORITY ON"
	line "THE RUINS OF ALPH"
	done

RuinsOfAlphOutside_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2, 17, RUINS_OF_ALPH_HO_OH_CHAMBER, 1
	warp_event 16,  7, RUINS_OF_ALPH_KABUTO_CHAMBER, 1
	warp_event  4, 29, RUINS_OF_ALPH_OMANYTE_CHAMBER, 1
	warp_event 18, 33, RUINS_OF_ALPH_AERODACTYL_CHAMBER, 1
	warp_event 12, 14, RUINS_OF_ALPH_INNER_CHAMBER, 1
	warp_event 19, 11, RUINS_OF_ALPH_RESEARCH_CENTER, 1
	warp_event  6, 19, UNION_CAVE_B1F, 1
	warp_event  8, 27, UNION_CAVE_B1F, 2
	warp_event  9,  5, ROUTE_36_RUINS_OF_ALPH_GATE, 3
	warp_event 15, 20, ROUTE_32_RUINS_OF_ALPH_GATE, 1
	warp_event 15, 21, ROUTE_32_RUINS_OF_ALPH_GATE, 2

	def_coord_events
	coord_event  7, 26, SCENE_RUINSOFALPHOUTSIDE_ROCKET_BOSS, ShrineFight

	def_bg_events
	bg_event 18,  8, BGEVENT_READ, RuinsOfAlphOutsideMysteryChamberSign
	bg_event 14, 16, BGEVENT_READ, RuinsOfAlphSign
	bg_event 20, 12, BGEVENT_READ, RuinsOfAlphResearchCenterSign

	def_object_events
	object_event 16,  8, SPRITE_SCIENTIST, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, RuinsOfAlphOutsideScientistWerner_Script, EVENT_BEAT_SCIENTIST_WERNER
	object_event  2, 18, SPRITE_SCIENTIST, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, RuinsOfAlphOutsideScientistEnrico_Script, EVENT_BEAT_SCIENTIST_ENRICO
	object_event  4, 30, SPRITE_SCIENTIST, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, RuinsOfAlphOutsideScientistNiels_Script, EVENT_BEAT_SCIENTIST_NIELS
	object_event 18, 34, SPRITE_SCIENTIST, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, RuinsOfAlphOutsideScientistEarnest_Script, EVENT_BEAT_SCIENTIST_EARNEST
	object_event 12, 31, SPRITE_ROCKET, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_RUINS_OF_ALPH_OUTSIDE_EXECUTIVES
	object_event 12, 31, SPRITE_ROCKET_GIRL, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_RUINS_OF_ALPH_OUTSIDE_EXECUTIVES
	object_event  4, 26, SPRITE_SUICUNE, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_RUINS_OF_ALPH_OUTSIDE_EXECUTIVES

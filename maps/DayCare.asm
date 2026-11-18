	object_const_def
	const DAYCARE_GRAMPS
	const DAYCARE_GRANNY

DayCare_MapScripts:
	def_scene_scripts

	def_callbacks

DayCareManScript_Inside:
	faceplayer
	opentext
	checkevent EVENT_GOT_LUCKY_EGG
	iftrue .AlreadyHaveLuckyEgg
	writetext DayCareManText_GiveLuckyEgg
	promptbutton
	verbosegiveitem LUCKY_EGG
	playsound SFX_KEY_ITEM
	waitsfx
	writetext DayCareText_DescribeLuckyEgg
	waitbutton
	closetext
	setevent EVENT_GOT_LUCKY_EGG
	end

.AlreadyHaveLuckyEgg:
	special DayCareMan
	waitbutton
	closetext
	end

DayCareLadyScript:
	faceplayer
	opentext
	checkevent EVENT_GOT_LUCKY_EGG
	iffalse .AskGrampsForLuckyEgg
	special DayCareLady
	waitbutton
	closetext
	end

.AskGrampsForLuckyEgg
	writetext AskGrampsForLuckyEggText
	waitbutton
	closetext
	end

GrammsGuide1Script:
	jumptext GrammsGuide1Text

GrammsGuide2Script:
	jumptext GrammsGuide2Text

DayCareManText_GiveLuckyEgg:
	text "I'm the DAY-CARE"
	line "MAN."

	para "Do you know what"
	line "a LUCKY EGG is?"

	para "If you give it to"
	line "a #MON, it will"
	cont "grow much faster"
	cont "than normal."

	para "How incredible is"
	line "that?"

	para "Well, wouldn't you"
	line "like a one for"
	cont "yourself?"

	para "Then fine, this is"
	line "yours to keep!"
	done

DayCareText_DescribeLuckyEgg:
	text "That was being"
	line "held by a rare"
	cont "#MON Gramms and"
	cont "I once met on"
	cont "Route 44."

	para "PROF. ELM thought"
	line "it was a #MON"
	cont "EGG, but it is"
	cont "just an item"
	cont "#MON can hold."

	para "Hopefully it has"
	line "some use for a"
	cont "trainer like"
	cont "yourself."
	done

AskGrampsForLuckyEggText:
	text "I can raise a"
	line "#MON for you."

	para "But first you"
	line "should talk to"
	cont "Gramps."

	para "He has a nice gift"
	line "for you."
	done

GrammsGuide1Text:
	text "Gramms' guide on"
	line "raising #MON"

	para "#MON with very"
	line "high happiness"
	cont "have been known"
	cont "to endure hits and"
	cont "keep fighting."
	done

GrammsGuide2Text:
	text "Gramms' guide on"
	line "raising #MON"

	para "#MON are often"
	line "happier after a"
	cont "haircut, grooming,"
	cont "or photograph."

	para "They even get"
	line "excited when an"
	cont "X-item is used on"
	cont "them in battle."
	done

DayCare_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  0,  5, ROUTE_34, 3
	warp_event  0,  6, ROUTE_34, 4
	warp_event  2,  7, ROUTE_34, 5
	warp_event  3,  7, ROUTE_34, 5

	def_coord_events

	def_bg_events
	bg_event  0,  1, BGEVENT_READ, GrammsGuide1Script
	bg_event  1,  1, BGEVENT_READ, GrammsGuide2Script

	def_object_events
	object_event  2,  3, SPRITE_GRAMPS, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, DayCareManScript_Inside, -1
	object_event  5,  3, SPRITE_GRANNY, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, DayCareLadyScript, -1

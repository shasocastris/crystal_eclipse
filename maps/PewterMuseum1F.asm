	object_const_def
	const PEWTERMUSEUM1F_SCIENTIST
	const PEWTERMUSEUM1F_GRAMPS
	const PEWTERMUSEUM1F_LASS
	const PEWTERMUSEUM1F_YOUNGSTER

PewterMuseum1F_MapScripts:
	def_scene_scripts

	def_callbacks

PewterMuseum1FScientistScript:
	jumptextfaceplayer PewterMuseum1FScientistText

PewterMuseum1FScientistText:
	text "These fossils came"
	line "from MT. MOON."

	para "We're studying how"
	line "ancient POKEMON"

	para "adapted to survive"
	line "long ago."
	done

PewterMuseum1FGrampsScript:
	jumptextfaceplayer PewterMuseum1FGrampsText

PewterMuseum1FGrampsText:
	text "I visit each year."
	line "The new KABUTO"

	para "exhibit is better"
	line "than last time!"
	done

PewterMuseum1FLassScript:
	jumptextfaceplayer PewterMuseum1FLassText

PewterMuseum1FLassText:
	text "These exhibits are"
	line "so fascinating!"

	para "Did you know some"
	line "POKEMON were once"

	para "brought back from"
	line "fossils?"
	done

PewterMuseum1FYoungsterScript:
	jumptextfaceplayer PewterMuseum1FYoungsterText

PewterMuseum1FYoungsterText:
	text "Check out those"
	line "giant bones!"

	para "I bet that POKEMON"
	line "was super strong!"
	done

PewterMuseum1FDomeFossilSign:
	jumptext PewterMuseum1FDomeFossilText

PewterMuseum1FDomeFossilText:
	text "DOME FOSSIL"
	line "EXHIBIT"

	para "Estimated age:"
	line "approx. 300"
	cont "million years."

	para "Believed to belong"
	line "to KABUTO, a"
	cont "marine POKEMON"
	cont "of the ancient"
	cont "sea."
	done

PewterMuseum1FHelixFossilSign:
	jumptext PewterMuseum1FHelixFossilText


PewterMuseum1FHelixFossilText:
	text "HELIX FOSSIL"
	line "EXHIBIT"

	para "Estimated age:"
	line "approx. 300"
	cont "million years."

	para "Believed to belong"
	line "to OMANYTE, a"
	cont "molluscan POKEMON"
	cont "now thought"
	cont "extinct."
	done

PewterMuseum1F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 10,  7, PEWTER_CITY, 6
	warp_event 11,  7, PEWTER_CITY, 6
	warp_event 16,  7, PEWTER_CITY, 7
	warp_event 17,  7, PEWTER_CITY, 7
	warp_event  7,  7, PEWTER_MUSEUM_2F, 1

	def_coord_events

	def_bg_events
	bg_event  2,  3, BGEVENT_READ, PewterMuseum1FDomeFossilSign
	bg_event  2,  6, BGEVENT_READ, PewterMuseum1FHelixFossilSign

	def_object_events
	object_event 17,  3, SPRITE_SCIENTIST, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, PewterMuseum1FScientistScript, -1
	object_event  1,  4, SPRITE_GRAMPS, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_SCRIPT, 0, PewterMuseum1FGrampsScript, -1
	object_event  6,  5, SPRITE_LASS, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, PewterMuseum1FLassScript, -1
	object_event  7,  2, SPRITE_YOUNGSTER, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, PewterMuseum1FYoungsterScript, -1

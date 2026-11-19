	object_const_def
	const RUINSOFALPHINNERCHAMBER_FISHER
	const RUINSOFALPHINNERCHAMBER_TEACHER
	const RUINSOFALPHINNERCHAMBER_GRAMPS

RuinsOfAlphInnerChamber_MapScripts:
	def_scene_scripts
	scene_script RuinsOfAlphInnerChamberNoopScene,            SCENE_RUINSOFALPHINNERCHAMBER_NOOP
	scene_script RuinsOfAlphInnerChamberStrangePresenceScene, SCENE_RUINSOFALPHINNERCHAMBER_STRANGE_PRESENCE

	def_callbacks

RuinsOfAlphInnerChamberNoopScene:
	end

RuinsOfAlphInnerChamberStrangePresenceScene:
	sdefer RuinsOfAlphInnerChamberStrangePresenceScript
	end

RuinsOfAlphInnerChamberStrangePresenceScript:
	opentext
	writetext RuinsOfAlphStrangePresenceText
	waitbutton
	closetext
	setscene SCENE_RUINSOFALPHINNERCHAMBER_NOOP
	setevent EVENT_MADE_UNOWN_APPEAR_IN_RUINS
	end

RuinsOfAlphInnerChamberStatue:
	jumptext RuinsOfAlphInnerChamberStatueText

RuinsOfAlphStrangePresenceText:
	text "There is a strange"
	line "presence here…"
	done

RuinsOfAlphInnerChamberStatueText:
	text "It's a replica of"
	line "an ancient #-"
	cont "MON."
	done

RuinsOfAlphInnerChamber_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 14, 17, RUINS_OF_ALPH_OUTSIDE, 5
	warp_event  2,  9, RUINS_OF_ALPH_HO_OH_WORD_ROOM, 3
	warp_event 19,  3, RUINS_OF_ALPH_KABUTO_WORD_ROOM, 3
	warp_event 11, 30, RUINS_OF_ALPH_OMANYTE_WORD_ROOM, 3
	warp_event 23, 33, RUINS_OF_ALPH_AERODACTYL_WORD_ROOM, 3
	warp_event  2, 22, RUINS_OF_ALPH_SUICUNE_WORD_ROOM, 3 ; CHANGED

	def_coord_events

	def_bg_events
	bg_event 20,  3, BGEVENT_READ, RuinsOfAlphInnerChamberStatue
	bg_event 23,  5, BGEVENT_READ, RuinsOfAlphInnerChamberStatue
	bg_event  5, 11, BGEVENT_READ, RuinsOfAlphInnerChamberStatue
	bg_event 12, 11, BGEVENT_READ, RuinsOfAlphInnerChamberStatue
	bg_event 16, 25, BGEVENT_READ, RuinsOfAlphInnerChamberStatue
	bg_event 13, 21, BGEVENT_READ, RuinsOfAlphInnerChamberStatue
	bg_event 22, 23, BGEVENT_READ, RuinsOfAlphInnerChamberStatue
	bg_event  7, 17, BGEVENT_READ, RuinsOfAlphInnerChamberStatue
	bg_event 21, 16, BGEVENT_READ, RuinsOfAlphInnerChamberStatue
	bg_event  2, 21, BGEVENT_READ, RuinsOfAlphInnerChamberStatue
	bg_event  2, 30, BGEVENT_READ, RuinsOfAlphInnerChamberStatue
	bg_event  3, 16, BGEVENT_READ, RuinsOfAlphInnerChamberStatue
	bg_event 10, 31, BGEVENT_READ, RuinsOfAlphInnerChamberStatue
	bg_event 22, 31, BGEVENT_READ, RuinsOfAlphInnerChamberStatue
	bg_event 25, 31, BGEVENT_READ, RuinsOfAlphInnerChamberStatue

	def_object_events

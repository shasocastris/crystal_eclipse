RuinsOfAlphSuicuneWordRoom_MapScripts:
	def_scene_scripts

	def_callbacks

; The walls read: IN OUR ABSENCE / THE NORTH WIND / SHALL GUARD THEM /
; WHEN THE BELL / RINGS CLEAR WE / SHALL RETURN
; (text is in the tileset; docs/word_room/make_word_room.py rebuilds it)

RuinsOfAlphSuicuneWordRoom_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  9,  9, RUINS_OF_ALPH_SUICUNE_ITEM_ROOM, 3
	warp_event 10,  9, RUINS_OF_ALPH_SUICUNE_ITEM_ROOM, 4
	warp_event 17, 21, RUINS_OF_ALPH_INNER_CHAMBER, 6

	def_coord_events

	def_bg_events

	def_object_events

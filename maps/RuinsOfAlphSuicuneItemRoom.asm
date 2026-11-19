	object_const_def
	const RUINSOFALPHSUICUNEITEMROOM_POKE_BALL1
	const RUINSOFALPHSUICUNEITEMROOM_POKE_BALL2
	const RUINSOFALPHSUICUNEITEMROOM_POKE_BALL3
	const RUINSOFALPHSUICUNEITEMROOM_POKE_BALL4

RuinsOfAlphSuicuneItemRoom_MapScripts:
	def_scene_scripts

	def_callbacks

RuinsOfAlphSuicuneItemRoomMysticDew:
	itemball MYSTIC_DEW

RuinsOfAlphSuicuneItemRoomKingsRock:
	itemball KINGS_ROCK

RuinsOfAlphSuicuneItemRoomFreshWater:
	itemball FRESH_WATER, 50

RuinsOfAlphSuicuneItemRoomGoldLeaf:
	itemball GOLD_LEAF, 25

RuinsOfAlphSuicuneItemRoomAncientReplica:
	jumptext RuinsOfAlphSuicuneItemRoomAncientReplicaText

RuinsOfAlphSuicuneItemRoomAncientReplicaText:
	text "It's a replica of"
	line "an ancient #-"
	cont "MON."
	done

RuinsOfAlphSuicuneItemRoom_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  3,  8, RUINS_OF_ALPH_SUICUNE_CHAMBER, 5
	warp_event  4,  8, RUINS_OF_ALPH_SUICUNE_CHAMBER, 5
	; TODO(bryan): point these at the Suicune word room once it exists
	warp_event  3,  1, RUINS_OF_ALPH_INNER_CHAMBER, 6
	warp_event  4,  1, RUINS_OF_ALPH_INNER_CHAMBER, 6

	def_coord_events

	def_bg_events
	bg_event  2,  1, BGEVENT_READ, RuinsOfAlphSuicuneItemRoomAncientReplica
	bg_event  5,  1, BGEVENT_READ, RuinsOfAlphSuicuneItemRoomAncientReplica

	def_object_events
	object_event  2,  6, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, RuinsOfAlphSuicuneItemRoomMysticDew, EVENT_PICKED_UP_MYSTIC_DEW_FROM_SUICUNE_ITEM_ROOM
	object_event  5,  6, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, RuinsOfAlphSuicuneItemRoomKingsRock, EVENT_PICKED_UP_KINGS_ROCK_FROM_SUICUNE_ITEM_ROOM
	object_event  2,  4, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, RuinsOfAlphSuicuneItemRoomFreshWater, EVENT_PICKED_UP_FRESH_WATER_FROM_SUICUNE_ITEM_ROOM
	object_event  5,  4, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, RuinsOfAlphSuicuneItemRoomGoldLeaf, EVENT_PICKED_UP_GOLD_LEAF_FROM_SUICUNE_ITEM_ROOM

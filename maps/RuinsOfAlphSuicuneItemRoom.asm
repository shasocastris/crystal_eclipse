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

RuinsOfAlphSuicuneItemRoomSacredAsh:
	itemball SACRED_ASH

RuinsOfAlphSuicuneItemRoomAmuletCoin:
	itemball AMULET_COIN

RuinsOfAlphSuicuneItemRoomBrightpowder:
	itemball BRIGHTPOWDER

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
	warp_event  3,  1, RUINS_OF_ALPH_SUICUNE_WORD_ROOM, 1
	warp_event  4,  1, RUINS_OF_ALPH_SUICUNE_WORD_ROOM, 2

	def_coord_events

	def_bg_events
	bg_event  2,  1, BGEVENT_READ, RuinsOfAlphSuicuneItemRoomAncientReplica
	bg_event  5,  1, BGEVENT_READ, RuinsOfAlphSuicuneItemRoomAncientReplica

	def_object_events
	object_event  2,  6, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, RuinsOfAlphSuicuneItemRoomMysticDew, EVENT_PICKED_UP_MYSTIC_DEW_FROM_SUICUNE_ITEM_ROOM
	object_event  5,  6, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, RuinsOfAlphSuicuneItemRoomSacredAsh, EVENT_PICKED_UP_SACRED_ASH_FROM_SUICUNE_ITEM_ROOM
	object_event  2,  4, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, RuinsOfAlphSuicuneItemRoomAmuletCoin, EVENT_PICKED_UP_AMULET_COIN_FROM_SUICUNE_ITEM_ROOM
	object_event  5,  4, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, RuinsOfAlphSuicuneItemRoomBrightpowder, EVENT_PICKED_UP_BRIGHTPOWDER_FROM_SUICUNE_ITEM_ROOM

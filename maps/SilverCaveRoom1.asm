	object_const_def
	const SILVERCAVEROOM1_POKE_BALL1
	const SILVERCAVEROOM1_POKE_BALL2
	const SILVERCAVEROOM1_POKE_BALL3
	const SILVERCAVEROOM1_POKE_BALL4

SilverCaveRoom1_MapScripts:
	def_scene_scripts
	scene_script SilverCaveRoom1NoopScene,       SCENE_SILVERCAVEROOM1_NOOP
	scene_script SilverCaveRoom1RepelWarnScene,  SCENE_SILVERCAVEROOM1_REPEL_WARNING

	def_callbacks
	callback MAPCALLBACK_NEWMAP, SilverCaveRoom1RepelCheckCallback

SilverCaveRoom1RepelCheckCallback:
	readmem wRepelEffect
	iffalse .no_repel
	setscene SCENE_SILVERCAVEROOM1_REPEL_WARNING
	endcallback

.no_repel
	setscene SCENE_SILVERCAVEROOM1_NOOP
	endcallback

SilverCaveRoom1NoopScene:
	end

SilverCaveRoom1RepelWarnScene:
	sdefer SilverCaveRoom1RepelWarnScript
	end

SilverCaveRoom1RepelWarnScript:
	setscene SCENE_SILVERCAVEROOM1_NOOP
	opentext
	writetext SilverCaveRoom1RepelWarnText
	waitbutton
	closetext
	end

SilverCaveRoom1MaxElixer:
	itemball MAX_ELIXER

SilverCaveRoom1Protein:
	itemball PROTEIN

SilverCaveRoom1FullRestore:
	itemball FULL_RESTORE

SilverCaveRoom1UltraBall:
	itemball ULTRA_BALL

SilverCaveRoom1HiddenDireHit:
	hiddenitem DIRE_HIT, EVENT_SILVER_CAVE_ROOM_1_HIDDEN_DIRE_HIT

SilverCaveRoom1HiddenUltraBall:
	hiddenitem ULTRA_BALL, EVENT_SILVER_CAVE_ROOM_1_HIDDEN_ULTRA_BALL

SilverCaveRoom1RepelWarnText:
	text "A heavy presence"
	line "fills the cave…"

	para "Your REPEL has"
	line "stopped working!"
	done

SilverCaveRoom1_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  9, 33, SILVER_CAVE_OUTSIDE, 2
	warp_event 15,  2, SILVER_CAVE_UNDERBELLY, 1

	def_coord_events

	def_bg_events
	bg_event 16, 23, BGEVENT_ITEM, SilverCaveRoom1HiddenDireHit
	bg_event 17, 12, BGEVENT_ITEM, SilverCaveRoom1HiddenUltraBall

	def_object_events
	object_event  4,  9, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, SilverCaveRoom1MaxElixer, EVENT_SILVER_CAVE_ROOM_1_MAX_ELIXER
	object_event 15, 29, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, SilverCaveRoom1Protein, EVENT_SILVER_CAVE_ROOM_1_PROTEIN
	object_event  5, 30, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, SilverCaveRoom1FullRestore, EVENT_SILVER_CAVE_ROOM_1_FULL_RESTORE
	object_event  7, 18, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, SilverCaveRoom1UltraBall, EVENT_SILVER_CAVE_ROOM_1_ULTRA_BALL

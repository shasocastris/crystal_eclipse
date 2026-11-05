	object_const_def
	const SILVERCAVEROOM3_RED

SilverCaveRoom3_MapScripts:
	def_scene_scripts
	scene_script SilverCaveRoom3NoopScene,       SCENE_SILVERCAVEROOM3_NOOP
	scene_script SilverCaveRoom3RedRematchScene, SCENE_SILVERCAVEROOM3_RED_REMATCH

	def_callbacks

SilverCaveRoom3NoopScene:
	end

SilverCaveRoom3RedRematchScene:
	sdefer SilverCaveRoom3RedRematchScript
	end

; Whiting out to Red respawns the player beside him, healed.
SilverCaveRoom3RedRematchScript:
	setscene SCENE_SILVERCAVEROOM3_NOOP
	blackoutmod SILVER_CAVE_OUTSIDE
	turnobject PLAYER, RIGHT
	turnobject SILVERCAVEROOM3_RED, LEFT
	end

Red:
	special FadeOutMusic
	faceplayer
	opentext
	writetext RedSeenText
	waitbutton
	closetext
	blackoutmod SILVER_CAVE_ROOM_3
	setscene SCENE_SILVERCAVEROOM3_RED_REMATCH
	winlosstext RedWinLossText, RedRematchText
	loadtrainer RED, RED1
	startbattle
	dontrestartmapmusic
	reloadmapafterbattle
	setscene SCENE_SILVERCAVEROOM3_NOOP
	blackoutmod SILVER_CAVE_OUTSIDE
	special FadeOutMusic
	opentext
	writetext RedLeavesText
	waitbutton
	closetext
	special FadeOutToBlack
	special ReloadSpritesNoPalettes
	disappear SILVERCAVEROOM3_RED
	pause 15
	special FadeInFromBlack
	pause 30
	special HealParty
	reanchormap
	credits
	end

RedSeenText:
	text "<……>"
	line "<……>"
	done

RedWinLossText:
	text "…"
	done

RedRematchText:
	text "Have some POTIONS…"
	line "and we can fight"
	cont "again…"
	done

RedLeavesText:
	text "<……>"
	line "<……>"
	done

SilverCaveRoom3_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 10, 33, SILVER_CAVE_ROOM_2, 2

	def_coord_events

	def_bg_events

	def_object_events
	object_event 10, 10, SPRITE_RED, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, Red, EVENT_RED_IN_MT_SILVER

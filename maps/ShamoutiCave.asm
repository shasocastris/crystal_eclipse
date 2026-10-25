	object_const_def
	const SHAMOUTICAVE_ROCK1
	const SHAMOUTICAVE_ROCK2
	const SHAMOUTICAVE_ROCK3
	const SHAMOUTICAVE_MEW

ShamoutiCave_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_OBJECTS, ShamoutiCaveMewCallback

ShamoutiCaveMewCallback:
	checkevent EVENT_FOUGHT_MEW
	iftrue .NoAppear
	checkevent EVENT_BEAT_ELITE_FOUR_REMATCH
	iftrue .Appear
	sjump .NoAppear

.Appear:
	appear SHAMOUTICAVE_MEW
	endcallback

.NoAppear:
	disappear SHAMOUTICAVE_MEW
	endcallback

ShamoutiCaveMew:
	faceplayer
	opentext
	writetext ShamoutiCaveMewText
	cry MEW
	pause 15
	closetext
	loadmonindex 0, MEW
	callstd DeityTutorScript
	iftrue .Stay
	setevent EVENT_FOUGHT_MEW
	disappear SHAMOUTICAVE_MEW
.Stay:
	end

ShamoutiCaveMewText:
	text "Mew!"
	done

ShamoutiCaveRock:
	jumpstd SmashRockScript

ShamoutiCave_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  7, 15, SHAMOUTI_ISLAND, 1

	def_coord_events

	def_bg_events

	def_object_events
	object_event  4,  6, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ShamoutiCaveRock, -1
	object_event 11, 12, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ShamoutiCaveRock, -1
	object_event 15, 14, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ShamoutiCaveRock, -1
	object_event  8,  3, SPRITE_MEW, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, PAL_NPC_PINK, OBJECTTYPE_SCRIPT, 0, ShamoutiCaveMew, EVENT_SHAMOUTI_CAVE_MEW

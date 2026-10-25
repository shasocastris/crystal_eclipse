	object_const_def
	const POKEMONMANSION_ROCK1
	const POKEMONMANSION_ROCK2
	const POKEMONMANSION_ROCK3
	const POKEMONMANSION_ROCK4
	const POKEMONMANSION_MEWTWO

PokemonMansion_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_OBJECTS, PokemonMansionMewtwoCallback

PokemonMansionMewtwoCallback:
	checkevent EVENT_FOUGHT_MEWTWO
	iftrue .NoAppear
	readvar VAR_BADGES
	ifequal NUM_BADGES, .Appear
	sjump .NoAppear

.Appear:
	appear POKEMONMANSION_MEWTWO
	endcallback

.NoAppear:
	disappear POKEMONMANSION_MEWTWO
	endcallback

PokemonMansionMewtwo:
	faceplayer
	opentext
	writetext PokemonMansionMewtwoText
	cry MEWTWO
	pause 30
	closetext
	refreshscreen
	pokepic MEWTWO
	waitbutton
	closepokepic
	setevent EVENT_FOUGHT_MEWTWO
	loadvar VAR_BATTLETYPE, BATTLETYPE_FORCEITEM
	loadwildmon MEWTWO, 70
	startbattle
	disappear POKEMONMANSION_MEWTWO
	reloadmapafterbattle
	end

PokemonMansionMewtwoText:
	text "Mewtwo!"
	done

PokemonMansionRock:
	jumpstd SmashRockScript

PokemonMansion_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  6, 25, CINNABAR_ISLAND, 2
	warp_event  7, 25, CINNABAR_ISLAND, 2

	def_coord_events

	def_bg_events

	def_object_events
	object_event 17,  7, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PokemonMansionRock, -1
	object_event 11, 19, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PokemonMansionRock, -1
	object_event 27, 12, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PokemonMansionRock, -1
	object_event  8,  6, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PokemonMansionRock, -1
	object_event  4, 13, SPRITE_MONSTER, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, PAL_NPC_PINK, OBJECTTYPE_SCRIPT, 0, PokemonMansionMewtwo, EVENT_TOHJO_FALLS_MEWTWO

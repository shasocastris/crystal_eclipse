	object_const_def
	const SEAFOAM_CAVES_ARTICUNO

SeafoamCaves_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_OBJECTS, SeafoamCavesArticuno

SeafoamCavesArticuno:
	checkevent EVENT_FOUGHT_ARTICUNO
	iftrue .NoAppear
	checkevent EVENT_BEAT_BLAINE
	iftrue .Appear
	sjump .NoAppear

.Appear:
	appear SEAFOAM_CAVES_ARTICUNO
	endcallback

.NoAppear:
	disappear SEAFOAM_CAVES_ARTICUNO
	endcallback

Articuno:
	faceplayer
	opentext
	writetext ArticunoText
	cry ARTICUNO
	pause 15
	closetext
	loadmonindex 0, ARTICUNO
	callstd DeityTutorScript
	iftrue .Stay
	setevent EVENT_FOUGHT_ARTICUNO
	disappear SEAFOAM_CAVES_ARTICUNO
.Stay:
	end

ArticunoText:
	text "Gyaaas!"
	done

SeafoamCaves_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 10, 15, ROUTE_20, 2

	def_coord_events

	def_bg_events

	def_object_events
	object_event 10,  6, SPRITE_ARTICUNO, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, Articuno, EVENT_SEAFOAM_CAVES_ARTICUNO

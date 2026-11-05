	object_const_def
	const SAFARIZONE_POKE_BALL1

SafariZone_MapScripts:
	def_scene_scripts

	def_callbacks

SafariZoneProtector:
	itemball PROTECTOR

SafariZone_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  9, 23, SAFARI_ZONE_FUCHSIA_GATE, 1
	warp_event 10, 23, SAFARI_ZONE_FUCHSIA_GATE, 2

	def_coord_events

	def_bg_events

	def_object_events
	object_event 17,  2, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, SafariZoneProtector, EVENT_SAFARI_ZONE_PROTECTOR

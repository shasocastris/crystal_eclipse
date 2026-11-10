	object_const_def
	const SAFFRONHOTEL_RECEPTIONIST
	const SAFFRONHOTEL_CLERK

SaffronHotel_MapScripts:
	def_scene_scripts

	def_callbacks

SaffronHotelReceptionistScript:
	jumptextfaceplayer SaffronHotelReceptionistText

SaffronHotelClerkScript:
	jumptextfaceplayer SaffronHotelClerkText

SaffronHotelReceptionistText:
	text "Welcome to the"
	line "SAFFRON HOTEL."

	para "I'm sorry, but"
	line "we're fully booked"
	cont "tonight."
	done

SaffronHotelClerkText:
	text "Our guests come"
	line "from all over"
	cont "KANTO to do"
	cont "business with"
	cont "SILPH CO."
	done

SaffronHotel_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4,  7, SAFFRON_CITY, 16
	warp_event  5,  7, SAFFRON_CITY, 16

	def_coord_events

	def_bg_events

	def_object_events
	object_event  6,  3, SPRITE_RECEPTIONIST, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SaffronHotelReceptionistScript, -1
	object_event  3,  2, SPRITE_CLERK, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SaffronHotelClerkScript, -1

	object_const_def
	const SAFFRONHOTEL_RECEPTIONIST
	const SAFFRONHOTEL_CLERK
	const SAFFRONHOTEL_GENTLEMAN
	const SAFFRONHOTEL_BEAUTY
	const SAFFRONHOTEL_SUPER_NERD

SaffronHotel_MapScripts:
	def_scene_scripts

	def_callbacks

SaffronHotelReceptionistScript:
	jumptextfaceplayer SaffronHotelReceptionistText

SaffronHotelClerkScript:
	jumptextfaceplayer SaffronHotelClerkText

SaffronHotelGentlemanScript:
	jumptextfaceplayer SaffronHotelGentlemanText

SaffronHotelBeautyScript:
	jumptextfaceplayer SaffronHotelBeautyText

SaffronHotelSuperNerdScript:
	jumptextfaceplayer SaffronHotelSuperNerdText

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

SaffronHotelGentlemanText:
	text "This lobby is a"
	line "fine place to rest"
	cont "my old legs."
	done

SaffronHotelBeautyText:
	text "I came to SAFFRON"
	line "to see the GYM"
	cont "LEADER, SABRINA."
	done

SaffronHotelSuperNerdText:
	text "I have a meeting"
	line "at SILPH CO. in"
	cont "the morning."
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
	object_event  0,  4, SPRITE_GENTLEMAN, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SaffronHotelGentlemanScript, -1
	object_event 11,  4, SPRITE_BEAUTY, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SaffronHotelBeautyScript, -1
	object_event  8,  6, SPRITE_SUPER_NERD, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SaffronHotelSuperNerdScript, -1

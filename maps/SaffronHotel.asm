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
	faceplayer
	opentext
	writetext SaffronHotelReceptionistWelcomeText
	yesorno
	iffalse .Refused
	checkmoney YOUR_MONEY, 9800
	ifequal HAVE_LESS, .NotEnoughMoney
	writetext SaffronHotelReceptionistEnjoyStayText
	promptbutton
	writetext SaffronHotelReceptionistCheckOutWhenText
	waitbutton
	closetext
	special HotelSetCheckoutTime
	iftrue .Cancelled
	takemoney YOUR_MONEY, 9800
	special RestaurantHappiness
	reloadmap
	opentext
	writetext SaffronHotelReceptionistSeeYouThenText
	waitbutton
	closetext
	special SmoothFadeOutToBlack
	playsound SFX_ENTER_DOOR
	pause 30
	waitsfx
	reloadmap
	opentext
	writetext SaffronHotelReceptionistThanksText
	waitbutton
	closetext
	end

.Cancelled
	reloadmap
	opentext
	writetext SaffronHotelReceptionistCancelledText
	waitbutton
	closetext
	end

.NotEnoughMoney
	writetext SaffronHotelReceptionistNotEnoughText
	waitbutton
	closetext
	end

.Refused
	writetext SaffronHotelReceptionistRefusedText
	waitbutton
	closetext
	end

SaffronHotelClerkScript:
	jumptextfaceplayer SaffronHotelClerkText

SaffronHotelGentlemanScript:
	jumptextfaceplayer SaffronHotelGentlemanText

SaffronHotelBeautyScript:
	jumptextfaceplayer SaffronHotelBeautyText

SaffronHotelSuperNerdScript:
	jumptextfaceplayer SaffronHotelSuperNerdText

SaffronHotelReceptionistWelcomeText:
	text "Welcome to the"
	line "SAFFRON HOTEL."

	para "A room is ¥9800"
	line "a night."

	para "Would you like to"
	line "check in?"
	done

SaffronHotelReceptionistEnjoyStayText:
	text "Thank you! We hope"
	line "your #MON will"
	cont "also enjoy their"
	cont "stay."
	done

SaffronHotelReceptionistCheckOutWhenText:
	text "When will you be"
	line "checking out?"
	done

SaffronHotelReceptionistSeeYouThenText:
	text "Very good. I'll"
	line "see you then!"
	done

SaffronHotelReceptionistThanksText:
	text "Thank you for"
	line "staying with us!"

	para "Please come again."
	done

SaffronHotelReceptionistCancelledText:
	text "Changed your mind?"

	para "Please come again"
	line "anytime."
	done

SaffronHotelReceptionistNotEnoughText:
	text "I'm sorry, but you"
	line "don't have enough"
	cont "money on hand."
	done

SaffronHotelReceptionistRefusedText:
	text "We hope to see you"
	line "again soon."
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

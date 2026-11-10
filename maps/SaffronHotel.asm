	object_const_def
	const SAFFRONHOTEL_RECEPTIONIST
	const SAFFRONHOTEL_CLERK
	const SAFFRONHOTEL_GRANNY
	const SAFFRONHOTEL_KIMONO_GIRL
	const SAFFRONHOTEL_SCIENTIST
	const SAFFRONHOTEL_POKEFAN_M
	const SAFFRONHOTEL_LASS
	const SAFFRONHOTEL_YOUNGSTER
	const SAFFRONHOTEL_GENTLEMAN
	const SAFFRONHOTEL_BEAUTY
	const SAFFRONHOTEL_SUPER_NERD
	const SAFFRONHOTEL_GRAMPS
	const SAFFRONHOTEL_BLACK_BELT
	const SAFFRONHOTEL_POKEFAN_F

SaffronHotel_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_NEWMAP, SaffronHotelSeasonalGuestsCallback

SaffronHotelSeasonalGuestsCallback:
	setevent EVENT_SAFFRON_HOTEL_SPRING_GUESTS
	setevent EVENT_SAFFRON_HOTEL_SUMMER_GUESTS
	setevent EVENT_SAFFRON_HOTEL_AUTUMN_GUESTS
	setevent EVENT_SAFFRON_HOTEL_WINTER_GUESTS
	checkseason SPRING
	iftrue .Spring
	checkseason SUMMER
	iftrue .Summer
	checkseason AUTUMN
	iftrue .Autumn
	clearevent EVENT_SAFFRON_HOTEL_WINTER_GUESTS
	endcallback

.Spring:
	clearevent EVENT_SAFFRON_HOTEL_SPRING_GUESTS
	endcallback

.Summer:
	clearevent EVENT_SAFFRON_HOTEL_SUMMER_GUESTS
	endcallback

.Autumn:
	clearevent EVENT_SAFFRON_HOTEL_AUTUMN_GUESTS
	endcallback

SaffronHotelReceptionistScript:
	faceplayer
	opentext
	checkflag ENGINE_SAFFRON_HOTEL
	iftrue .AlreadyStayed
	checkseason SPRING
	iftrue .Spring
	checkseason SUMMER
	iftrue .Summer
	checkseason AUTUMN
	iftrue .Autumn
	writetext SaffronHotelReceptionistWinterText
	sjump .Offer

.Spring:
	writetext SaffronHotelReceptionistSpringText
	sjump .Offer

.Summer:
	writetext SaffronHotelReceptionistSummerText
	sjump .Offer

.Autumn:
	writetext SaffronHotelReceptionistAutumnText
.Offer:
	promptbutton
	writetext SaffronHotelReceptionistOfferText
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
	setflag ENGINE_SAFFRON_HOTEL
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

.AlreadyStayed
	writetext SaffronHotelReceptionistAlreadyStayedText
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
	faceplayer
	opentext
	checkseason SPRING
	iftrue .Spring
	checkseason SUMMER
	iftrue .Summer
	checkseason AUTUMN
	iftrue .Autumn
	writetext SaffronHotelClerkWinterText
	sjump .Done

.Spring:
	writetext SaffronHotelClerkSpringText
	sjump .Done

.Summer:
	writetext SaffronHotelClerkSummerText
	sjump .Done

.Autumn:
	writetext SaffronHotelClerkAutumnText
.Done:
	waitbutton
	closetext
	end

SaffronHotelGrannyScript:
	jumptextfaceplayer SaffronHotelGrannyText

SaffronHotelKimonoGirlScript:
	jumptextfaceplayer SaffronHotelKimonoGirlText

SaffronHotelScientistScript:
	jumptextfaceplayer SaffronHotelScientistText

SaffronHotelPokefanMScript:
	jumptextfaceplayer SaffronHotelPokefanMText

SaffronHotelSwimmerGirlScript:
	jumptextfaceplayer SaffronHotelSwimmerGirlText

SaffronHotelYoungsterScript:
	jumptextfaceplayer SaffronHotelYoungsterText

SaffronHotelGentlemanScript:
	jumptextfaceplayer SaffronHotelGentlemanText

SaffronHotelBeautyScript:
	jumptextfaceplayer SaffronHotelBeautyText

SaffronHotelSuperNerdScript:
	jumptextfaceplayer SaffronHotelSuperNerdText

SaffronHotelGrampsScript:
	jumptextfaceplayer SaffronHotelGrampsText

SaffronHotelBlackBeltScript:
	jumptextfaceplayer SaffronHotelBlackBeltText

SaffronHotelPokefanFScript:
	jumptextfaceplayer SaffronHotelPokefanFText

SaffronHotelReceptionistSpringText:
	text "Welcome to the"
	line "SAFFRON HOTEL."

	para "Every room has"
	line "fresh flowers this"
	cont "spring!"
	done

SaffronHotelReceptionistSummerText:
	text "Welcome to the"
	line "SAFFRON HOTEL."

	para "Please, come in"
	line "out of the heat!"
	done

SaffronHotelReceptionistAutumnText:
	text "Welcome to the"
	line "SAFFRON HOTEL."

	para "Autumn is our"
	line "busiest season,"
	cont "with SILPH CO.'s"
	cont "big conferences."
	done

SaffronHotelReceptionistWinterText:
	text "Welcome to the"
	line "SAFFRON HOTEL."

	para "Come warm up! Our"
	line "rooms are heated"
	cont "all winter long."
	done

SaffronHotelReceptionistOfferText:
	text "A room is ¥9800"
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

SaffronHotelReceptionistAlreadyStayedText:
	text "I hope you enjoyed"
	line "your stay."

	para "Please come again"
	line "soon."
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

SaffronHotelClerkSpringText:
	text "Spring is wedding"
	line "season. We've had"
	cont "three this week!"
	done

SaffronHotelClerkSummerText:
	text "Tourists from all"
	line "over come to see"
	cont "SAFFRON in summer."
	done

SaffronHotelClerkAutumnText:
	text "Our guests come"
	line "from all over"
	cont "KANTO to do"
	cont "business with"
	cont "SILPH CO."
	done

SaffronHotelClerkWinterText:
	text "The snow keeps"
	line "guests indoors."

	para "Our hot cocoa is"
	line "very popular!"
	done

SaffronHotelGrannyText:
	text "My husband and I"
	line "honeymooned here,"
	cont "fifty springs ago."
	done

SaffronHotelKimonoGirlText:
	text "Spring in KANTO is"
	line "so lovely. All the"
	cont "flowers bloom!"
	done

SaffronHotelScientistText:
	text "I'm here to show"
	line "SILPH CO. my new"
	cont "invention."
	done

SaffronHotelPokefanMText:
	text "It's too hot to go"
	line "outside. I'm just"
	cont "staying in here"
	cont "with my son."
	done

SaffronHotelSwimmerGirlText:
	text "Tomorrow I'm off"
	line "to the beach in"
	cont "VERMILION CITY!"
	done

SaffronHotelYoungsterText:
	text "It's summer break!"
	line "Mom and Dad took"
	cont "me to the city!"
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

SaffronHotelGrampsText:
	text "I stay here every"
	line "winter. It's much"
	cont "warmer than home!"
	done

SaffronHotelBlackBeltText:
	text "The DOJO's winter"
	line "training starts"
	cont "tomorrow. I need"
	cont "my rest!"
	done

SaffronHotelPokefanFText:
	text "I came to shop for"
	line "holiday gifts in"
	cont "CELADON CITY."
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
	; spring
	object_event  0,  4, SPRITE_GRANNY, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SaffronHotelGrannyScript, EVENT_SAFFRON_HOTEL_SPRING_GUESTS
	object_event 11,  4, SPRITE_KIMONO_GIRL, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SaffronHotelKimonoGirlScript, EVENT_SAFFRON_HOTEL_SPRING_GUESTS
	object_event  8,  6, SPRITE_BEAUTY, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SaffronHotelBeautyScript, EVENT_SAFFRON_HOTEL_SPRING_GUESTS
	; summer
	object_event  0,  4, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SaffronHotelPokefanMScript, EVENT_SAFFRON_HOTEL_SUMMER_GUESTS
	object_event 12,  4, SPRITE_LASS, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SaffronHotelSwimmerGirlScript, EVENT_SAFFRON_HOTEL_SUMMER_GUESTS
	object_event  0,  5, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SaffronHotelYoungsterScript, EVENT_SAFFRON_HOTEL_SUMMER_GUESTS
	; autumn
	object_event  0,  4, SPRITE_GENTLEMAN, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SaffronHotelGentlemanScript, EVENT_SAFFRON_HOTEL_AUTUMN_GUESTS
	object_event  8,  6, SPRITE_SUPER_NERD, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SaffronHotelSuperNerdScript, EVENT_SAFFRON_HOTEL_AUTUMN_GUESTS
	object_event  9,  6, SPRITE_SCIENTIST, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SaffronHotelScientistScript, EVENT_SAFFRON_HOTEL_AUTUMN_GUESTS
	; winter
	object_event  0,  5, SPRITE_GRAMPS, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SaffronHotelGrampsScript, EVENT_SAFFRON_HOTEL_WINTER_GUESTS
	object_event 10,  4, SPRITE_BLACK_BELT, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SaffronHotelBlackBeltScript, EVENT_SAFFRON_HOTEL_WINTER_GUESTS
	object_event 11,  6, SPRITE_POKEFAN_F, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SaffronHotelPokefanFScript, EVENT_SAFFRON_HOTEL_WINTER_GUESTS

	object_const_def
	const OLIVINERESTAURANT_LASS

OlivineRestaurant_MapScripts:
	def_scene_scripts

	def_callbacks

OlivineRestaurantLassScript:
	faceplayer
	opentext
	checkflag ENGINE_OLIVINE_RESTAURANT
	iftrue .AlreadyAte
	writetext OlivineRestaurantLassWelcomeText
	yesorno
	iffalse .Refused
	writetext OlivineRestaurantLassCostText
	yesorno
	iffalse .TooExpensive
	checkmoney YOUR_MONEY, 9800
	ifequal HAVE_LESS, .NotEnoughMoney
	writetext OlivineRestaurantLassPokemonEatWellText
	waitbutton
	closetext
	takemoney YOUR_MONEY, 9800
	special RestaurantHappiness
	special FadeOutToWhite
	playsound SFX_ENTER_DOOR
	pause 30
	waitsfx
	reloadmap
	setflag ENGINE_OLIVINE_RESTAURANT
	opentext
	writetext OlivineRestaurantLassPokemonFedText
	waitbutton
	random 3
	ifequal 0, .Leftovers
	opentext
	writetext OlivineRestaurantLassThanksForJoiningText
	waitbutton
	closetext
	end

.AlreadyAte
	writetext OlivineRestaurantLassAlreadyAteText
	waitbutton
	closetext
	end

.NotEnoughMoney
	writetext OlivineRestaurantLassNotEnoughText
	waitbutton
	closetext
	end

.Leftovers
	writetext OlivineRestaurantLassGiveLeftoversText
	promptbutton
	verbosegiveitem LEFTOVERS
	iffalse .NoRoom
	writetext OlivineRestaurantLassThanksForJoiningText
	waitbutton
	closetext
	end

.NoRoom
	writetext OlivineRestaurantLassNoRoomText
	waitbutton
	closetext
	end

.TooExpensive
	writetext OlivineRestaurantLassTooExpensiveText
	waitbutton

.Refused:
	writetext OlivineRestaurantLassRefusedText
	waitbutton
	closetext
	end

OlivineRestaurantYoungsterScript:
	jumptext OlivineRestaurantYoungsterText

OlivineRestaurantBeautyScript:
	jumptextfaceplayer OlivineRestaurantBeautyText

OlivineRestaurantTeacherScript:
	jumptextfaceplayer OlivineRestaurantTeacherText

OlivineRestaurantRockerScript:
	jumptextfaceplayer OlivineRestaurantRockerText

OlivineRestaurantEkansScript:
	opentext
	writetext OlivineRestaurantEkansText
	cry EKANS
	waitbutton
	callasm .Ekans
	special ShowPokedexEntry
	closetext
	end

.Ekans
	ld hl, EKANS
	call GetPokemonIDFromIndex
	ld [wScriptVar], a
	ret

OlivineRestaurantBayleefScript:
	opentext
	writetext OlivineRestaurantBayleefText
	cry BAYLEEF
	waitbutton
	callasm .Bayleef
	special ShowPokedexEntry
	closetext
	end

.Bayleef
	ld hl, BAYLEEF
	call GetPokemonIDFromIndex
	ld [wScriptVar], a
	ret

OlivineRestaurantSpearowScript:
	opentext
	writetext OlivineRestaurantSpearowText
	cry SPEAROW
	waitbutton
	callasm .Spearow
	special ShowPokedexEntry
	closetext
	end

.Spearow
	ld hl, SPEAROW
	call GetPokemonIDFromIndex
	ld [wScriptVar], a
	ret

OlivineRestaurantRhydonScript:
	opentext
	writetext OlivineRestaurantRhydonText
	cry RHYDON
	waitbutton
	callasm .Rhydon
	special ShowPokedexEntry
	closetext
	end

.Rhydon
	ld hl, RHYDON
	call GetPokemonIDFromIndex
	ld [wScriptVar], a
	ret

OlivineRestaurantLassWelcomeText:
	text "Welcome! Will you"
	line "and your #MON"
	cont "be dining with us"
	cont "today?"
	done

OlivineRestaurantLassAlreadyAteText:
	text "Your #MON ate"
	line "with us earlier"
	cont "today."

	para "We look forward to"
	line "serving them again"
	cont "tomorrow!"
	done

OlivineRestaurantLassCostText:
	text "It will be ¥9800."

	para "Is that ok?"
	done

OlivineRestaurantLassPokemonEatWellText:
	text "Excellent! We'll"
	line "make sure to feed"
	cont "them well."
	done

OlivineRestaurantLassPokemonFedText:
	text "Your #MON are"
	line "back and have been"
	cont "fed."

	para "They look very"
	line "happy!"
	done

OlivineRestaurantLassThanksForJoiningText:
	text "Thanks for joining"
	line "us and I hope to"
	cont "see you again!"
	done

OlivineRestaurantLassNotEnoughText:
	text "It looks like you"
	line "don't have enough"
	cont "money on hand."

	para "Maybe you can sell"
	line "some items and"
	cont "come again."
	done

OlivineRestaurantLassGiveLeftoversText:
	text "There were some"
	line "LEFTOVERS as well."

	para "We bagged them up"
	line "for you."
	done

OlivineRestaurantLassNoRoomText:
	text "Oh? I guess you"
	line "don't have enough"
	cont "room for them."

	para "I'll make sure"
	line "they get to the"
	cont "DAYCARE instead."
	done

OlivineRestaurantLassTooExpensiveText:
	text "No? I understand."
	done

OlivineRestaurantLassRefusedText:
	text "We look forward to"
	line "serving you at"
	cont "another time!"
	done

OlivineRestaurantYoungsterText:
	text "Hey, EKANS!"

	para "Quit trying to"
	line "slither away!"
	done

OlivineRestaurantBeautyText:
	text "I'm training my"
	line "SPEAROW until it"
	cont "evolves."

	para "Then I'll have a"
	line "FEAROW to fly me"
	cont "anywhere!"
	done

OlivineRestaurantTeacherText:
	text "The food here is"
	line "excellent."

	para "And they often let"
	line "customers take"
	cont "LEFTOVERS."
	done

OlivineRestaurantRockerText:
	text "I think seeing all"
	line "these #MON is"
	cont "so exciting."
	done

OlivineRestaurantEkansText:
	text "EKANS: Ek Ekans!"
	done

OlivineRestaurantBayleefText:
	text "BAYLEEF: Li liif!"
	done

OlivineRestaurantSpearowText:
	text "SPEAROW: Spear!"
	done

OlivineRestaurantRhydonText:
	text "RHYDON: Rhy! Rhy!"
	done

OlivineRestaurant_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2,  9, OLIVINE_CITY, 7
	warp_event  3,  9, OLIVINE_CITY, 7

	def_coord_events

	def_bg_events

	def_object_events
	object_event  5,  8, SPRITE_LASS, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BLACK, OBJECTTYPE_SCRIPT, 0, OlivineRestaurantLassScript, -1
	object_event  2,  4, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, OlivineRestaurantYoungsterScript, -1
	object_event  2,  3, SPRITE_EKANS, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, OlivineRestaurantEkansScript, -1
	object_event  5,  3, SPRITE_BAYLEEF, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, OlivineRestaurantBayleefScript, -1
	object_event  8,  4, SPRITE_BEAUTY, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, OlivineRestaurantBeautyScript, -1
	object_event 11,  3, SPRITE_SPEAROW, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, OlivineRestaurantSpearowScript, -1
	object_event 11,  4, SPRITE_RHYDON, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, OlivineRestaurantRhydonScript, -1
	object_event 11,  7, SPRITE_TEACHER, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, OlivineRestaurantTeacherScript, -1
	object_event  8,  7, SPRITE_ROCKER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, OlivineRestaurantRockerScript, -1

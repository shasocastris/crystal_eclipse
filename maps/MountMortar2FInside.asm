	object_const_def
	const MOUNTMORTAR2FINSIDE_POKE_BALL1
	const MOUNTMORTAR2FINSIDE_POKE_BALL2
	const MOUNTMORTAR2FINSIDE_POKE_BALL3
	const MOUNTMORTAR2FINSIDE_POKE_BALL4
	const MOUNTMORTAR2FINSIDE_POKE_BALL5
	const MOUNTMORTAR2FINSIDE_POKE_BALL6
	const MOUNTMORTAR2FINSIDE_SUPER_NERD
;	const MOUNTMORTAR2FINSIDE_BLACK_BELT

MountMortar2FInside_MapScripts:
	def_scene_scripts

	def_callbacks

TrainerSuperNerdHugh:
	trainer SUPER_NERD, HUGH, EVENT_BEAT_SUPER_NERD_HUGH, SuperNerdHughSeenText, SuperNerdHughBeatenText, 0, .Script

.Script:
	opentext
	writetext SuperNerdHughAfterBattleText
	waitbutton
	closetext
	end

TrainerBlackbeltTakeshi:
	trainer BLACKBELT_T, TAKESHI, EVENT_BEAT_BLACKBELT_TAKESHI, BlackbeltTakeshiSeenText, BlackbeltTakeshiBeatenText, 0, .Script

.Script:
	opentext
	writetext BlackbeltTakeshiAfterBattleText
	waitbutton
	closetext
	end

MountMortar2FInsideMaxPotion:
	itemball MAX_POTION

MountMortar2FInsideSmoothRock:
	itemball SMOOTH_ROCK

MountMortar2FInsideTMRockSlide:
	itemball TM_ROCK_SLIDE, 3

MountMortar2FInsideDragonScale:
	itemball DRAGON_SCALE

MountMortar2FInsideElixer:
	itemball ELIXER

MountMortar2FInsideScopeLens:
	itemball SCOPE_LENS

MountMortar2FInsideHiddenFullRestore:
	hiddenitem FULL_RESTORE, EVENT_MOUNT_MORTAR_2F_INSIDE_HIDDEN_FULL_RESTORE

MountMortar2FInsideHiddenRareCandy:
	hiddenitem RARE_CANDY, EVENT_MOUNT_MORTAR_2F_INSIDE_HIDDEN_RARE_CANDY

SuperNerdHughSeenText:
	text "Yo! MARKUS!"
	done

SuperNerdHughBeatenText:
	text "Sorry, my mistake."
	done

SuperNerdHughAfterBattleText:
	text "I'm investigating"
	line "MT.MORTAR, but my"
	cont "pal's gone AWOL."

	para "Have you seen a"
	line "trainer who has a"

	para "SLOWPOKE that can"
	line "use STRENGTH?"
	done

BlackbeltTakeshiSeenText:
	text "I've been training"
	line "in this cave for"
	cont "months!"

	para "The isolation and"
	line "harsh conditions"
	cont "forge true"
	cont "strength!"

	para "Show me your"
	line "fighting spirit!"
	done

BlackbeltTakeshiBeatenText:
	text "Your spirit burns"
	line "bright!"
	done

BlackbeltTakeshiAfterBattleText:
	text "This cave teaches"
	line "patience and"
	cont "endurance!"

	para "Every echo, every"
	line "drop of water is"
	cont "a lesson!"
	done

MountMortar2FInside_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 17, 33, MOUNT_MORTAR_1F_OUTSIDE, 4
	warp_event  3,  5, MOUNT_MORTAR_1F_INSIDE, 6

	def_coord_events

	def_bg_events
	bg_event 23,  8, BGEVENT_ITEM, MountMortar2FInsideHiddenFullRestore
	bg_event  2, 22, BGEVENT_ITEM, MountMortar2FInsideHiddenRareCandy

	def_object_events
	object_event 28, 22, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, MountMortar2FInsideMaxPotion, EVENT_MOUNT_MORTAR_2F_INSIDE_MAX_POTION
	object_event  2, 33, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, MountMortar2FInsideSmoothRock, EVENT_MOUNT_MORTAR_2F_INSIDE_SMOOTH_ROCK
	object_event 19, 17, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, MountMortar2FInsideTMRockSlide, EVENT_MOUNT_MORTAR_2F_INSIDE_TM_ROCK_SLIDE
	object_event 14,  5, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, MountMortar2FInsideDragonScale, EVENT_MOUNT_MORTAR_2F_INSIDE_DRAGON_SCALE
	object_event  5, 10, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, MountMortar2FInsideElixer, EVENT_MOUNT_MORTAR_2F_INSIDE_ELIXER
	object_event 28,  5, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, MountMortar2FInsideScopeLens, EVENT_MOUNT_MORTAR_2F_INSIDE_SCOPE_LENS
	object_event 13, 25, SPRITE_SUPER_NERD, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 2, TrainerSuperNerdHugh, -1
	object_event 33, 11, SPRITE_BLACK_BELT, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 1, TrainerBlackbeltTakeshi, -1

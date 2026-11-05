	object_const_def
	const ICEPATHB3F_POKE_BALL
	const ICEPATHB3F_ROCK
	const ICEPATHB2FBLACKTHORNSIDE_KIMONO_GIRL

IcePathB3F_MapScripts:
	def_scene_scripts

	def_callbacks

TrainerKimonoGirlYuki:
	trainer KIMONO_GIRL, YUKI, EVENT_BEAT_KIMONO_GIRL_YUKI, KimonoGirlYukiSeenText, KimonoGirlYukiBeatenText, 0, .Script

.Script:
	opentext
	writetext KimonoGirlYukiAfterBattleText
	waitbutton
	closetext
	end

IcePathB3FNevermeltice:
	itemball NEVERMELTICE

IcePathB3FRock:
	jumpstd SmashRockScript

KimonoGirlYukiSeenText:
	text "We meet again,"
	line "<PLAYER>."

	para "I trust the EEVEE"
	line "BILL gave you is"
	cont "thriving?"

	para "I promised we'd"
	line "talk more. But"
	cont "first--a dance"
	cont "across the ice!"
	done

KimonoGirlYukiBeatenText:
	text "Your warmth melts"
	line "even my resolve…"
	done

KimonoGirlYukiAfterBattleText:
	text "Each KIMONO GIRL"
	line "trains her own"
	cont "TYPE."

	para "My sisters chose"
	line "FIRE, WATER,"
	cont "ELECTRIC, PSYCHIC,"
	cont "GRASS, FAIRY and"
	cont "DARK."

	para "I chose the still"
	line "beauty of ICE."

	para "Let an EEVEE grow"
	line "stronger on this"
	cont "very floor, and"
	cont "it'll become"
	cont "GLACEON."

	para "The path ahead"
	line "leads to"
	cont "BLACKTHORN CITY."

	para "CLAIR is fierce."
	line "Take care."
	done

IcePathB3F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  3,  5, ICE_PATH_B2F_MAHOGANY_SIDE, 2
	warp_event 15,  5, ICE_PATH_B2F_BLACKTHORN_SIDE, 2

	def_coord_events

	def_bg_events

	def_object_events
	object_event  5,  7, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, IcePathB3FNevermeltice, EVENT_ICE_PATH_B3F_NEVERMELTICE
	object_event  6,  6, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, IcePathB3FRock, -1
	object_event 10,  3, SPRITE_KIMONO_GIRL, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, PAL_NPC_TEAL, OBJECTTYPE_TRAINER, 0, TrainerKimonoGirlYuki, -1

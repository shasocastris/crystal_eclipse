	object_const_def
	const PEWTERMUSEUM2F_SUPER_NERD
	const PEWTERMUSEUM2F_GENTLEMAN
	const PEWTERMUSEUM2F_YOUNGSTER

PewterMuseum2F_MapScripts:
	def_scene_scripts

	def_callbacks

PewterMuseum2FSuperNerdScript:
	jumptextfaceplayer PewterMuseum2FSuperNerdText

PewterMuseum2FSuperNerdText:
	text "Bone density in"
	line "old-era POKEMON"

	para "shows they could"
	line "support far larger"

	para "mass than their"
	line "modern relatives."
	done

PewterMuseum2FGentlemanScript:
	jumptextfaceplayer PewterMuseum2FGentlemanText

PewterMuseum2FGentlemanText:
	text "I provided the"
	line "funds for this"

	para "exhibit myself."
	line "The amber display"

	para "alone cost quite"
	line "a pretty penny!"
	done

PewterMuseum2FYoungsterScript:
	jumptextfaceplayer PewterMuseum2FYoungsterText

PewterMuseum2FYoungsterText:
	text "My dad says the"
	line "AERODACTYL was the"

	para "strongest ancient"
	line "POKEMON ever!"
	done

PewterMuseum2FMoonRockSign:
	jumptext PewterMuseum2FMoonRockText

PewterMuseum2FMoonRockText:
	text "MOON ROCK EXHIBIT"

	para "Fragments"
	line "recovered from"
	cont "MT. MOON."

	para "Analysis suggests"
	line "these rocks"
	cont "attract certain"
	cont "POKEMON from"
	cont "outer space."
	done

PewterMuseum2F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  7,  7, PEWTER_MUSEUM_1F, 5

	def_coord_events

	def_bg_events
	bg_event  2,  5, BGEVENT_READ, PewterMuseum2FMoonRockSign

	def_object_events
	object_event  3,  2, SPRITE_SUPER_NERD, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, PewterMuseum2FSuperNerdScript, -1
	object_event  9,  3, SPRITE_GENTLEMAN, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_SCRIPT, 0, PewterMuseum2FGentlemanScript, -1
	object_event  6,  5, SPRITE_YOUNGSTER, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, PAL_NPC_TEAL, OBJECTTYPE_SCRIPT, 0, PewterMuseum2FYoungsterScript, -1

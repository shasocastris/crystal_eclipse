	object_const_def
	const ICEPATHB2FBLACKTHORNSIDE_POKE_BALL
	const ICEPATHB2FBLACKTHORNSIDE_BOARDER

IcePathB2FBlackthornSide_MapScripts:
	def_scene_scripts

	def_callbacks

TrainerBoarderVince:
	trainer BOARDER, VINCE, EVENT_BEAT_BOARDER_VINCE, BoarderVinceSeenText, BoarderVinceBeatenText, 0, .Script

.Script:
	opentext
	writetext BoarderVinceAfterBattleText
	waitbutton
	closetext
	end

IcePathB2FBlackthornSideTMRest:
	itemball TM_REST, 3

IcePathB2FBlackthornSideHiddenIceHeal:
	hiddenitem ICE_HEAL, EVENT_ICE_PATH_B2F_BLACKTHORN_SIDE_HIDDEN_ICE_HEAL

BoarderVinceSeenText:
	text "This ice floor is"
	line "radical! Perfect"
	cont "for boarding!"

	para "Let's battle to"
	line "warm up!"
	done

BoarderVinceBeatenText:
	text "Wiped out! Total"
	line "yard sale!"
	done

BoarderVinceAfterBattleText:
	text "I came looking for"
	line "rare ice #MON."

	para "The deeper caves"
	line "have PILOSWINE and"
	cont "JYNX, you know!"
	done

IcePathB2FBlackthornSide_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  3, 15, ICE_PATH_B1F, 8
	warp_event  3,  3, ICE_PATH_B3F, 2

	def_coord_events

	def_bg_events
	bg_event  2, 10, BGEVENT_ITEM, IcePathB2FBlackthornSideHiddenIceHeal

	def_object_events
	object_event  8, 16, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, IcePathB2FBlackthornSideTMRest, EVENT_ICE_PATH_B2F_BLACKTHORN_SIDE_TM_REST
	object_event  2, 15, SPRITE_ROCKER, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 1, TrainerBoarderVince, -1
	object_const_def
	const ICEPATHHOLLOW1F_LARS
	const ICEPATHHOLLOW1F_GRETA
	const ICEPATHHOLLOW1F_NILS
	const ICEPATHHOLLOW1F_KNUT
	const ICEPATHHOLLOW1F_POKE_BALL1
	const ICEPATHHOLLOW1F_POKE_BALL2

IcePathHollow1F_MapScripts:
	def_scene_scripts

	def_callbacks

TrainerSwimmermLars:
	trainer SWIMMERM, LARS, EVENT_BEAT_SWIMMERM_LARS, SwimmermLarsSeenText, SwimmermLarsBeatenText, 0, .Script

.Script:
	opentext
	writetext SwimmermLarsAfterBattleText
	waitbutton
	closetext
	end

TrainerSkierGreta:
	trainer SKIER, GRETA, EVENT_BEAT_SKIER_GRETA, SkierGretaSeenText, SkierGretaBeatenText, 0, .Script

.Script:
	opentext
	writetext SkierGretaAfterBattleText
	waitbutton
	closetext
	end

TrainerBoarderNils:
	trainer BOARDER, NILS, EVENT_BEAT_BOARDER_NILS, BoarderNilsSeenText, BoarderNilsBeatenText, 0, .Script

.Script:
	opentext
	writetext BoarderNilsAfterBattleText
	waitbutton
	closetext
	end

TrainerFirebreatherKnut:
	trainer FIREBREATHER, KNUT, EVENT_BEAT_FIREBREATHER_KNUT, FirebreatherKnutSeenText, FirebreatherKnutBeatenText, 0, .Script

.Script:
	opentext
	writetext FirebreatherKnutAfterBattleText
	waitbutton
	closetext
	end

IcePathHollow1FBigPearl:
	itemball BIG_PEARL

IcePathHollow1FMaxElixer:
	itemball MAX_ELIXER

IcePathHollow1FHiddenStarPiece:
	hiddenitem STAR_PIECE, EVENT_ICE_PATH_HOLLOW_1F_HIDDEN_STAR_PIECE

SwimmermLarsSeenText:
	text "The water's fine!"

	para "Once you stop"
	line "feeling it."
	done

SwimmermLarsBeatenText:
	text "Brr…"
	done

SwimmermLarsAfterBattleText:
	text "The falls beat me"
	line "last year. So I"
	cont "train under them."
	done

SkierGretaSeenText:
	text "I came to watch"
	line "them fail. Then I"
	cont "wanted to try."
	done

SkierGretaBeatenText:
	text "And I failed too."
	done

SkierGretaAfterBattleText:
	text "Upstairs they"
	line "take this place"
	cont "too seriously."
	done

BoarderNilsSeenText:
	text "You can climb the"
	line "falls? Show-off!"
	done

BoarderNilsBeatenText:
	text "Show-off…"
	done

BoarderNilsAfterBattleText:
	text "I've been stuck"
	line "down here since"
	cont "the thaw."
	done

FirebreatherKnutSeenText:
	text "I keep the fire"
	line "for whoever makes"
	cont "it up the falls."

	para "Earn your seat!"
	done

FirebreatherKnutBeatenText:
	text "Sit. Warm up."
	done

FirebreatherKnutAfterBattleText:
	text "The ladder goes"
	line "to the HOLLOW."

	para "They don't like"
	line "visitors there."
	done

IcePathHollow1F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  7, 32, BLACKTHORN_CITY, 9
	warp_event  8, 32, BLACKTHORN_CITY, 10
	warp_event 27,  5, ICE_PATH_HOLLOW_2F, 1

	def_coord_events

	def_bg_events
	bg_event 29, 28, BGEVENT_ITEM, IcePathHollow1FHiddenStarPiece

	def_object_events
	object_event 17, 20, SPRITE_SWIMMER_GUY, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 4, TrainerSwimmermLars, -1
	object_event 24, 27, SPRITE_BEAUTY, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 3, TrainerSkierGreta, -1
	object_event  5, 18, SPRITE_ROCKER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 4, TrainerBoarderNils, -1
	object_event 15, 10, SPRITE_FISHER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 1, TrainerFirebreatherKnut, -1
	object_event 11, 26, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, IcePathHollow1FBigPearl, EVENT_ICE_PATH_HOLLOW_1F_BIG_PEARL
	object_event  2,  5, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, IcePathHollow1FMaxElixer, EVENT_ICE_PATH_HOLLOW_1F_MAX_ELIXER

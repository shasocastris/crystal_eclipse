	object_const_def
	const SLOWPOKEWELLB2F_GYM_GUIDE
	const SLOWPOKEWELLB2F_POKE_BALL
	const SLOWPOKEWELLB2F_SUPER_NERD

SlowpokeWellB2F_MapScripts:
	def_scene_scripts

	def_callbacks

SlowpokeWellB2FGymGuideScript:
	faceplayer
	opentext
	checkevent EVENT_GOT_KINGS_ROCK_IN_SLOWPOKE_WELL
	iftrue .GotKingsRock
	writetext SlowpokeWellB2FGymGuideText
	promptbutton
	verbosegiveitem KINGS_ROCK
	iffalse .NoRoom
	setevent EVENT_GOT_KINGS_ROCK_IN_SLOWPOKE_WELL
.NoRoom:
	closetext
	end

.GotKingsRock:
	writetext SlowpokeWellB2FGymGuideText_GotKingsRock
	waitbutton
	closetext
	end

TrainerSuperNerdStan:
	trainer SUPER_NERD, STAN, EVENT_BEAT_SUPER_NERD_STAN, SuperNerdStanText, SuperNerdStanBeatenText, 0, .Script

.Script:
	opentext
	writetext SuperNerdStanAfterBattleText
	waitbutton
	closetext
	end

SlowpokeWellB2FTMRainDance:
	itemball TM_RAIN_DANCE, 3

SuperNerdStanText:
	text "Whoa! How did you"
	line "get down here?"

	para "I've been studying"
	line "the underground"

	para "ecosystem of this"
	line "well for weeks!"

	para "My HOUNDOOM can"
	line "smell different"

	para "mineral deposits,"
	line "and GRIMER absorbs"
	cont "toxins."

	para "Care for a battle"
	line "in the depths?"
	done

SuperNerdStanBeatenText:
	text "Incredible! Your"
	line "technique echoes"
	cont "through the well!"
	done

SuperNerdStanAfterBattleText:
	text "The SLOWPOKE here"
	line "have such unique"

	para "behavior patterns"
	line "compared to"
	cont "surface ones."

	para "I think the water"
	line "affects their"

	para "psychic growth!"

	para "This underground"
	line "place is a"
	cont "natural lab!"
	done

SlowpokeWellB2FGymGuideText:
	text "I'm waiting to see"
	line "SLOWPOKE's moment"
	cont "of evolution."

	para "Through observa-"
	line "tion, I made a new"
	cont "discovery."

	para "A SLOWPOKE with a"
	line "KING'S ROCK often"

	para "gets bitten by a"
	line "SHELLDER."

	para "Here, I'll share a"
	line "KING'S ROCK with"
	cont "you."
	done

SlowpokeWellB2FGymGuideText_GotKingsRock:
	text "I'm going to be"
	line "like SLOWPOKE."

	para "I'll wait patient-"
	line "ly, so I can see"
	cont "one evolve."
	done

SlowpokeWellB2F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  9, 11, SLOWPOKE_WELL_B1F, 2

	def_coord_events

	def_bg_events

	def_object_events
	object_event  5,  4, SPRITE_GYM_GUIDE, SPRITEMOVEDATA_WANDER, 1, 2, -1, -1, 0, OBJECTTYPE_SCRIPT, 1, SlowpokeWellB2FGymGuideScript, -1
	object_event 15,  5, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, SlowpokeWellB2FTMRainDance, EVENT_SLOWPOKE_WELL_B2F_TM_RAIN_DANCE
	object_event 16,  6, SPRITE_SUPER_NERD, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 3, TrainerSuperNerdStan, -1

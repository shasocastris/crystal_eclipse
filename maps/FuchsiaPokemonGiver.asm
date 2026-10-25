object_const_def
	const FUCHSIA_POKEMON_GIVER_SAGE

FuchsiaPokemonGiver_MapScripts:
	def_scene_scripts

	def_callbacks

FuchsiaPokemonGiverSageScript:
	faceplayer
	opentext
	checkevent EVENT_GOT_KANGASKHAN_FROM_SAGE
	iftrue .AlreadyGave
	writetext SageIntroText
	promptbutton
	special GetFirstPokemonHappiness
	ifgreater 220 - 1, .HappyEnough
	writetext SageNotHappyEnoughText
	waitbutton
	closetext
	end

.HappyEnough:
	writetext SageImpressedText
	promptbutton
	writetext SageOfferPokemonText
	yesorno
	iffalse .Refused
	callasm CheckPartyFullForGift
	ifequal 1, .PartyFull
	givepoke KANGASKHAN, 60, KINGS_ROCK
	callasm SetKangaskhanMoves
	setevent EVENT_GOT_KANGASKHAN_FROM_SAGE
	writetext SageGavePokemonText
	waitbutton
	closetext
	end

.PartyFull:
	writetext SagePartyFullText
	waitbutton
	closetext
	end

.Refused:
	writetext SageRefusedText
	waitbutton
	closetext
	end

.AlreadyGave:
	writetext SageAfterGaveText
	waitbutton
	closetext
	end

CheckPartyFullForGift::
; Sets wScriptVar to 1 if party is full, 0 if room.
	ld a, [wPartyCount]
	cp PARTY_LENGTH
	jr nc, .full
	xor a
	ld [wScriptVar], a
	ret
.full
	ld a, 1
	ld [wScriptVar], a
	ret

SetKangaskhanMoves::
; Writes a custom moveset + PP and happiness to the last party mon.
	ld a, [wPartyCount]
	dec a
	ld [wCurPartyMon], a

	ld a, MON_MOVES
	call GetPartyParamLocation
	push hl

	ld hl, BODY_SLAM
	call GetMoveIDFromIndex
	pop hl
	ld [hli], a
	push hl

	ld hl, EARTHQUAKE
	call GetMoveIDFromIndex
	pop hl
	ld [hli], a
	push hl

	ld hl, SHADOW_BALL
	call GetMoveIDFromIndex
	pop hl
	ld [hli], a
	push hl

	ld hl, ROCK_SLIDE
	call GetMoveIDFromIndex
	pop hl
	ld [hl], a

	; Now fill PP
	ld a, MON_MOVES
	call GetPartyParamLocation
	push hl
	ld a, MON_PP
	call GetPartyParamLocation
	ld d, h
	ld e, l
	pop hl
	predef FillPP

	; happy enough to obey at any level
	ld a, MON_HAPPINESS
	call GetPartyParamLocation
	ld [hl], OBEY_HAPPINESS_3
	ret

SageIntroText:
	text "I am a retired"
	line "trainer."

	para "My old partner"
	line "still has some"
	cont "fight left, but"
	cont "I cannot battle"
	cont "anymore."

	para "I would give her"
	line "to a trainer who"
	cont "truly cares for"
	cont "their #MON."
	done

SageNotHappyEnoughText:
	text "Hmm… your #MON"
	line "doesn't look that"
	cont "happy, though."

	para "Come back when"
	line "you've built a"
	cont "stronger bond."
	done

SageImpressedText:
	text "I can tell your"
	line "#MON trusts you"
	cont "deeply."

	para "That kind of bond"
	line "is rare."
	done

SageOfferPokemonText:
	text "Will you take my"
	line "KANGASKHAN?"

	para "I caught her in"
	line "the SAFARI ZONE"
	cont "years ago."

	para "She's a seasoned"
	line "battler. Knows"
	cont "tricks that most"
	cont "trainers never"
	cont "learn."
	done

SageGavePokemonText:
	text "Take good care of"
	line "her."

	para "Don't let her age"
	line "fool you. She hits"
	cont "like a landslide"
	cont "and guards her"
	cont "team like her own."

	para "That's what a"
	line "mother does."
	done

SagePartyFullText:
	text "Hmm, your party"
	line "is full."

	para "Come back with an"
	line "open spot. I want"
	cont "to make sure you"
	cont "two meet properly."
	done

SageRefusedText:
	text "I see. Perhaps"
	line "another time."

	para "She'll be here"
	line "when you're ready."
	done

SageAfterGaveText:
	text "How is KANGASKHAN"
	line "doing?"

	para "I bet she's"
	line "protecting your"
	cont "whole team by now."

	para "Old habits die"
	line "hard, you know."
	done

FuchsiaPokemonGiver_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2,  7, FUCHSIA_CITY, 1
	warp_event  3,  7, FUCHSIA_CITY, 1

	def_coord_events

	def_bg_events

	def_object_events
	object_event  2,  3, SPRITE_SAGE, SPRITEMOVEDATA_STANDING_DOWN, 1, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, FuchsiaPokemonGiverSageScript, -1
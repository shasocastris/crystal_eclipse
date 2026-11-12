	object_const_def
	const ICEPATHHOLLOW_GOZO
	const ICEPATHHOLLOW_SLADE
	const ICEPATHHOLLOW_RUE
	const ICEPATHHOLLOW_COLT
	const ICEPATHHOLLOW_IVOR
	const ICEPATHHOLLOW_BRANT
	const ICEPATHHOLLOW_KAIDO
	const ICEPATHHOLLOW_TUTOR
	const ICEPATHHOLLOW_MEDIC
	const ICEPATHHOLLOW_POKE_BALL1
	const ICEPATHHOLLOW_POKE_BALL2
	const ICEPATHHOLLOW_POKE_BALL3
	const ICEPATHHOLLOW_POKE_BALL4
	const ICEPATHHOLLOW_ROCK

IcePathHollow2F_MapScripts:
	def_scene_scripts

	def_callbacks

TrainerBlackbeltGozo:
	trainer BLACKBELT_T, GOZO, EVENT_BEAT_BLACKBELT_GOZO, BlackbeltGozoSeenText, BlackbeltGozoBeatenText, 0, .Script

.Script:
	opentext
	writetext BlackbeltGozoAfterBattleText
	waitbutton
	closetext
	end

TrainerBurglarSlade:
	trainer BURGLAR, SLADE, EVENT_BEAT_BURGLAR_SLADE, BurglarSladeSeenText, BurglarSladeBeatenText, 0, .Script

.Script:
	opentext
	writetext BurglarSladeAfterBattleText
	waitbutton
	closetext
	end

TrainerCooltrainerfRue:
	trainer COOLTRAINERF, RUE, EVENT_BEAT_COOLTRAINERF_RUE, CooltrainerfRueSeenText, CooltrainerfRueBeatenText, 0, .Script

.Script:
	opentext
	writetext CooltrainerfRueAfterBattleText
	waitbutton
	closetext
	end

TrainerBoarderColt:
	trainer BOARDER, COLT, EVENT_BEAT_BOARDER_COLT, BoarderColtSeenText, BoarderColtBeatenText, 0, .Script

.Script:
	opentext
	writetext BoarderColtAfterBattleText
	waitbutton
	closetext
	end

TrainerCooltrainermIvor:
	trainer COOLTRAINERM, IVOR, EVENT_BEAT_COOLTRAINERM_IVOR, CooltrainermIvorSeenText, CooltrainermIvorBeatenText, 0, .Script

.Script:
	opentext
	writetext CooltrainermIvorAfterBattleText
	waitbutton
	closetext
	end

TrainerCooltrainermBrant:
	trainer COOLTRAINERM, BRANT, EVENT_BEAT_COOLTRAINERM_BRANT, CooltrainermBrantSeenText, CooltrainermBrantBeatenText, 0, .Script

.Script:
	opentext
	writetext CooltrainermBrantAfterBattleText
	waitbutton
	closetext
	end

IcePathHollowKaidoScript:
; EVENT_BEAT_COOLTRAINERM_KAIDO is only set once he has been answered.
; Beaten and still here means the answer was "Winning".
	faceplayer
	opentext
	checkevent EVENT_BEAT_COOLTRAINERM_KAIDO
	iftrue .Rematch
	writetext IcePathHollowKaidoIntroText
	waitbutton
	closetext
	winlosstext IcePathHollowKaidoWinText, 0
	loadtrainer COOLTRAINERM, KAIDO1
	startbattle
	reloadmapafterbattle
	opentext
	writetext IcePathHollowKaidoQuestionText
	promptbutton
	loadmenu .MenuHeader
	verticalmenu
	closewindow
	ifequal 1, .Winning
	setevent EVENT_BEAT_COOLTRAINERM_KAIDO
	writetext IcePathHollowKaidoCompanyText
	waitbutton
	closetext
	special FadeOutToBlack
	special ReloadSpritesNoPalettes
	disappear ICEPATHHOLLOW_KAIDO
	pause 30
	special FadeInFromBlack
	end

.Winning:
	writetext IcePathHollowKaidoWinningText
	promptbutton
	verbosegiveitem BERSERK_GENE
	iffalse .NoRoom
	setevent EVENT_BEAT_COOLTRAINERM_KAIDO
	writetext IcePathHollowKaidoComeBackText
	waitbutton
	closetext
	end

.NoRoom:
	writetext IcePathHollowKaidoNoRoomText
	waitbutton
	closetext
	end

.Rematch:
	checkflag ENGINE_ICE_PATH_HOLLOW_REMATCH
	iftrue .Tomorrow
	writetext IcePathHollowKaidoRematchText
	yesorno
	iffalse .Declined
	closetext
	winlosstext IcePathHollowKaidoRematchWinText, 0
	checkevent EVENT_BEAT_ELITE_FOUR
	iftrue .Stronger
	loadtrainer COOLTRAINERM, KAIDO1
	sjump .Fight

.Stronger:
	loadtrainer COOLTRAINERM, KAIDO2
.Fight:
	startbattle
	reloadmapafterbattle
	setflag ENGINE_ICE_PATH_HOLLOW_REMATCH
	opentext
.Tomorrow:
	writetext IcePathHollowKaidoTomorrowText
	waitbutton
	closetext
	end

.Declined:
	writetext IcePathHollowKaidoDeclinedText
	waitbutton
	closetext
	end

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 9, 6, SCREEN_WIDTH - 1, TEXTBOX_Y - 1
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR | STATICMENU_DISABLE_B ; flags
	db 2 ; items
	db "Winning@"
	db "Company@"

IcePathHollowTutorScript:
	faceplayer
	opentext
	writetext IcePathHollowTutorIntroText
	promptbutton
	checkitem DRAGON_SCALE
	iftrue .CanPay
	checkitem DRAGON_FANG
	iftrue .CanPay
	writetext IcePathHollowTutorNoPaymentText
	waitbutton
	closetext
	end

.CanPay:
	writetext IcePathHollowTutorAskText
	yesorno
	iffalse .Refused
	special OutrageMoveTutor
	ifequal FALSE, .Taught
	ifequal 1, .NoMove
	ifequal 3, .AlreadyKnows
	ifequal 4, .NoRoom
.Refused:
	writetext IcePathHollowTutorRefusedText
	waitbutton
	closetext
	end

.Taught:
	checkitem DRAGON_SCALE
	iftrue .TakeScale
	takeitem DRAGON_FANG
	sjump .Paid

.TakeScale:
	takeitem DRAGON_SCALE
.Paid:
	writetext IcePathHollowTutorTaughtText
	waitbutton
	closetext
	end

.NoMove:
	writetext IcePathHollowTutorNoMoveText
	waitbutton
	closetext
	end

.AlreadyKnows:
	writetext IcePathHollowTutorAlreadyKnowsText
	waitbutton
	closetext
	end

.NoRoom:
	writetext IcePathHollowTutorNoRoomText
	waitbutton
	closetext
	end

IcePathHollowMedicScript:
	faceplayer
	opentext
	checkflag ENGINE_ICE_PATH_HOLLOW_MEDIC
	iftrue .Done
	writetext IcePathHollowMedicOfferText
	yesorno
	iffalse .Refused
	closetext
	special FadeOutToBlack
	special ReloadSpritesNoPalettes
	special StubbedTrainerRankings_Healings
	playmusic MUSIC_HEAL
	special HealParty
	pause 60
	special FadeInFromBlack
	special RestartMapMusic
	setflag ENGINE_ICE_PATH_HOLLOW_MEDIC
	opentext
	writetext IcePathHollowMedicHealedText
	waitbutton
	closetext
	end

.Done:
	writetext IcePathHollowMedicDoneText
	waitbutton
	closetext
	end

.Refused:
	writetext IcePathHollowMedicRefusedText
	waitbutton
	closetext
	end

IcePathHollowWarningSign:
	jumptext IcePathHollowWarningSignText

IcePathHollowTallyWall:
	opentext
	writetext IcePathHollowTallyWallText
	checkevent EVENT_ICE_PATH_HOLLOW_KAIDO
	iffalse .Done
	promptbutton
	writetext IcePathHollowTallyWallPassedText
.Done:
	waitbutton
	closetext
	end

IcePathHollowRazorClaw:
	itemball RAZOR_CLAW

IcePathHollowRareCandy:
	itemball RARE_CANDY

IcePathHollowDragonScale:
	itemball DRAGON_SCALE

IcePathHollowPPUp:
	itemball PP_UP

IcePathHollowRock:
	jumpstd SmashRockScript

IcePathHollowHiddenMaxRevive:
	hiddenitem MAX_REVIVE, EVENT_ICE_PATH_HOLLOW_HIDDEN_MAX_REVIVE

IcePathHollowHiddenNugget:
	hiddenitem NUGGET, EVENT_ICE_PATH_HOLLOW_HIDDEN_NUGGET

IcePathHollowHiddenNevermeltice:
	hiddenitem NEVERMELTICE, EVENT_ICE_PATH_HOLLOW_HIDDEN_NEVERMELTICE

BlackbeltGozoSeenText:
	text "You came up the"
	line "falls? So you have"
	cont "eight BADGES."

	para "Good. That makes"
	line "you worth beating!"
	done

BlackbeltGozoBeatenText:
	text "Not enough. Again,"
	line "not enough!"
	done

BlackbeltGozoAfterBattleText:
	text "The ELDER said my"
	line "fists had nothing"
	cont "behind them."

	para "I'm still looking"
	line "for what he meant."
	done

BurglarSladeSeenText:
	text "Nobody watches a"
	line "washout's pockets."

	para "Let's see what's"
	line "in yours!"
	done

BurglarSladeBeatenText:
	text "Empty-handed"
	line "again…"
	done

BurglarSladeAfterBattleText:
	text "I took the test"
	line "to get the FANG."

	para "The ELDER saw"
	line "right through me."
	done

CooltrainerfRueSeenText:
	text "Twice I stood in"
	line "that SHRINE. Twice"
	cont "he shook his head."

	para "A third try needs"
	line "a stronger team!"
	done

CooltrainerfRueBeatenText:
	text "Still not it…"
	done

CooltrainerfRueAfterBattleText:
	text "My SEADRA never"
	line "got its SCALE."

	para "I keep telling it"
	line "the wait is my"
	cont "fault, not its."
	done

BoarderColtSeenText:
	text "The ice here never"
	line "melts. Neither do"
	cont "grudges!"
	done

BoarderColtBeatenText:
	text "Wiped out!"
	done

BoarderColtAfterBattleText:
	text "I only came for"
	line "the slopes. Then I"
	cont "lost to KAIDO."

	para "Now I can't leave"
	line "till I beat him."
	done

CooltrainermIvorSeenText:
	text "BRANT and I spar"
	line "all day. You'll do"
	cont "for a change!"
	done

CooltrainermIvorBeatenText:
	text "That wasn't in"
	line "the routine…"
	done

CooltrainermIvorAfterBattleText:
	text "We were DRAGON"
	line "TAMERS once. One"
	cont "DRAGONAIR each."

	para "The rest of the"
	line "team is whatever"
	cont "wins."
	done

CooltrainermBrantSeenText:
	text "Don't walk through"
	line "our ring unless"
	cont "you mean it!"
	done

CooltrainermBrantBeatenText:
	text "You meant it."
	done

CooltrainermBrantAfterBattleText:
	text "The ELDER asked"
	line "what a #MON is"
	cont "to me."

	para "I said: a weapon."

	para "He said: come back"
	line "when it isn't."
	done

IcePathHollowKaidoIntroText:
	text "So the ELDER let"
	line "another one pass."

	para "I failed his test"
	line "three times. Three"
	cont "wrong answers."

	para "So I built my own"
	line "SHRINE. Here, only"
	cont "one answer counts."

	para "Show me yours!"
	done

IcePathHollowKaidoWinText:
	text "…Again. It is"
	line "always again."
	done

IcePathHollowKaidoQuestionText:
	text "You passed. So"
	line "answer me what he"
	cont "asked me."

	para "What is a #MON"
	line "for?"
	done

IcePathHollowKaidoWinningText:
	text "Ha! Then we are"
	line "the same, and he"
	cont "was wrong to pass"
	cont "you."

	para "Take this. My"
	line "DRAGONAIR never"
	cont "needed it to hate"
	cont "losing."
	done

IcePathHollowKaidoComeBackText:
	text "Come back any day."
	line "I'll be stronger."
	done

IcePathHollowKaidoNoRoomText:
	text "Your PACK is full?"

	para "Then you haven't"
	line "won anything yet."
	done

IcePathHollowKaidoCompanyText:
	text "…Company."

	para "That's what I told"
	line "him the first"
	cont "time. Before I"
	cont "started counting."

	para "Three failures,"
	line "and I had it at"
	cont "the start."

	para "I'm going back to"
	line "the DEN. Not to"
	cont "pass. To ask."
	done

IcePathHollowKaidoRematchText:
	text "Back for more?"
	line "Good. I haven't"
	cont "slept."
	done

IcePathHollowKaidoRematchWinText:
	text "Again. Always"
	line "again!"
	done

IcePathHollowKaidoTomorrowText:
	text "Not again today."

	para "My team needs the"
	line "rest, if I don't."
	done

IcePathHollowKaidoDeclinedText:
	text "Then stop wasting"
	line "my ice."
	done

IcePathHollowTutorIntroText:
	text "I served the"
	line "SHRINE for forty"
	cont "years."

	para "OUTRAGE is the one"
	line "move the ELDER"
	cont "forbids us to"
	cont "teach."

	para "I don't serve the"
	line "SHRINE anymore."
	done

IcePathHollowTutorNoPaymentText:
	text "Bring me a DRAGON"
	line "SCALE or a DRAGON"
	cont "FANG."

	para "Rage isn't free."
	done

IcePathHollowTutorAskText:
	text "One SCALE or FANG"
	line "for one lesson."

	para "Shall I teach"
	line "OUTRAGE?"
	done

IcePathHollowTutorRefusedText:
	text "Wise, maybe."
	line "I never was."
	done

IcePathHollowTutorTaughtText:
	text "There. Don't tell"
	line "the ELDER where"
	cont "it learned that."
	done

IcePathHollowTutorNoMoveText:
	text "That one has no"
	line "dragon's temper"
	cont "in it. I can't."
	done

IcePathHollowTutorAlreadyKnowsText:
	text "It already knows"
	line "how to lose its"
	cont "temper."
	done

IcePathHollowTutorNoRoomText:
	text "Changed your mind?"
	line "Keep your payment."
	done

IcePathHollowMedicOfferText:
	text "I patch them up so"
	line "they can go lose"
	cont "again."

	para "You look worn too."
	line "Want a hand? Once"
	cont "a day, no charge."
	done

IcePathHollowMedicHealedText:
	text "There. Don't make"
	line "it a habit like"
	cont "they have."
	done

IcePathHollowMedicDoneText:
	text "I've used up"
	line "today's supplies."

	para "Come back"
	line "tomorrow."
	done

IcePathHollowMedicRefusedText:
	text "Suit yourself."
	done

IcePathHollowWarningSignText:
	text "Scratched into the"
	line "rock:"

	para "THE ELDER TURNED"
	line "US AWAY. WE STAY"
	cont "UNTIL HE IS WRONG."
	done

IcePathHollowTallyWallText:
	text "Rows of tally"
	line "marks. One for"
	cont "each failed test."

	para "The longest row"
	line "is marked KAIDO."
	done

IcePathHollowTallyWallPassedText:
	text "A new line reads:"
	line "KAIDO - ASKED."
	done

IcePathHollow2F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 17, 37, ICE_PATH_HOLLOW_1F, 3

	def_coord_events

	def_bg_events
	bg_event 17, 31, BGEVENT_READ, IcePathHollowWarningSign
	bg_event 16,  7, BGEVENT_READ, IcePathHollowTallyWall
	bg_event 33,  5, BGEVENT_ITEM, IcePathHollowHiddenMaxRevive
	bg_event  5, 33, BGEVENT_ITEM, IcePathHollowHiddenNugget
	bg_event 21, 19, BGEVENT_ITEM, IcePathHollowHiddenNevermeltice

	def_object_events
	object_event 16, 32, SPRITE_BLACK_BELT, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 3, TrainerBlackbeltGozo, -1
	object_event 11, 33, SPRITE_PHARMACIST, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 3, TrainerBurglarSlade, -1
	object_event 30, 29, SPRITE_COOLTRAINER_F, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 3, TrainerCooltrainerfRue, -1
	object_event  9, 26, SPRITE_ROCKER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 3, TrainerBoarderColt, -1
	object_event 13,  9, SPRITE_COOLTRAINER_M, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 4, TrainerCooltrainermIvor, -1
	object_event 23, 10, SPRITE_COOLTRAINER_M, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 4, TrainerCooltrainermBrant, -1
	object_event 16,  3, SPRITE_COOLTRAINER_M, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, IcePathHollowKaidoScript, EVENT_ICE_PATH_HOLLOW_KAIDO
	object_event 12,  4, SPRITE_GRAMPS, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, IcePathHollowTutorScript, -1
	object_event  4,  3, SPRITE_COOLTRAINER_F, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, IcePathHollowMedicScript, -1
	object_event  8, 20, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, IcePathHollowRazorClaw, EVENT_ICE_PATH_HOLLOW_RAZOR_CLAW
	object_event  2, 31, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, IcePathHollowRareCandy, EVENT_ICE_PATH_HOLLOW_RARE_CANDY
	object_event 26,  2, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, IcePathHollowDragonScale, EVENT_ICE_PATH_HOLLOW_DRAGON_SCALE
	object_event 21,  3, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, IcePathHollowPPUp, EVENT_ICE_PATH_HOLLOW_PP_UP
	object_event 30, 11, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, IcePathHollowRock, -1

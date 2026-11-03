	object_const_def
	const LAVRADIOTOWER5F_DIRECTOR
	const LAVRADIOTOWER5F_ROCKER
	const LAVRADIOTOWER5F_CLERK
	const LAVRADIOTOWER5F_PROTON
	const LAVRADIOTOWER5F_GRUNT_1
	const LAVRADIOTOWER5F_GRUNT_2
	const LAVRADIOTOWER5F_GRUNT_3
	const LAVRADIOTOWER5F_RANGER

LavRadioTower5F_MapScripts:
	def_scene_scripts

	def_callbacks

TrainerGruntM26:
	trainer GRUNTM, GRUNTM_26, EVENT_BEAT_ROCKET_GRUNTM_26, GruntM26SeenText, GruntM26BeatenText, 0, .Script

.Script:
	opentext
	writetext GruntM26AfterBattleText
	waitbutton
	closetext
	end

GruntM26SeenText:
	text "You've made it"
	line "this far?"

	para "You're not leaving"
	line "this floor."
	done

GruntM26BeatenText:
	text "Tch…"
	done

GruntM26AfterBattleText:
	text "It's over for me."
	line "But not for us."

	para "PROTON's been"
	line "waiting for you."

	para "You'll wish you"
	line "hadn't found him."
	done


TrainerGruntM27:
	trainer GRUNTM, GRUNTM_27, EVENT_BEAT_ROCKET_GRUNTM_27, GruntM27SeenText, GruntM27BeatenText, 0, .Script

.Script:
	opentext
	writetext GruntM27AfterBattleText
	waitbutton
	closetext
	end

GruntM27SeenText:
	text "Nobody told me"
	line "a trainer was"
	cont "coming up here."

	para "Doesn't matter."
	line "You're done."
	done

GruntM27BeatenText:
	text "Impossible!"
	done

GruntM27AfterBattleText:
	text "I don't get it."
	line "How did you beat"
	cont "everyone?"

	para "Kids these days!"
	done

TrainerGruntM30:
	trainer GRUNTM, GRUNTM_30, EVENT_BEAT_ROCKET_GRUNTM_30, GruntM30SeenText, GruntM30BeatenText, 0, .Script

.Script:
	opentext
	writetext GruntM30AfterBattleText
	waitbutton
	closetext
	end

GruntM30SeenText:
	text "This is the top"
	line "floor, kid."

	para "You aren't going"
	line "any further."
	done

GruntM30BeatenText:
	text "What…?"
	done

GruntM30AfterBattleText:
	text "Just so you know…"

	para "Hah, as if I would"
	line "snitch!"
	done

LavRadioTower5FProtonScript:
	faceplayer
	checkevent EVENT_BEAT_ROCKET_GRUNTM_32
	iffalse .NotReady
	checkevent EVENT_BEAT_ROCKET_GRUNTM_33  ; keep uncommented for testing
	iffalse .NotReady
	checkevent EVENT_BEAT_ROCKET_GRUNTM_34
	iffalse .NotReady
	checkevent EVENT_BEAT_ROCKET_GRUNTM_35  ; keep uncommented for testing
	iffalse .NotReady
	checkevent EVENT_BEAT_ROCKET_GRUNTM_36
	iffalse .NotReady
	checkevent EVENT_BEAT_ROCKET_GRUNTM_37
	iffalse .NotReady
	checkevent EVENT_BEAT_ROCKET_GRUNTF_11
	iffalse .NotReady
	checkevent EVENT_BEAT_ROCKET_GRUNTF_12
	iffalse .NotReady
	checkevent EVENT_BEAT_ROCKET_GRUNTF_13
	iffalse .NotReady
	checkevent EVENT_BEAT_ROCKET_GRUNTM_26
	iffalse .NotReady
	checkevent EVENT_BEAT_ROCKET_GRUNTM_27  ; keep uncommented for testing
	iffalse .NotReady
	checkevent EVENT_BEAT_ROCKET_GRUNTM_30
	iffalse .NotReady
	; All grunts beaten — drop disguise and battle
	special FadeOutMusic
	pause 15
	playmusic MUSIC_ROCKET_ENCOUNTER
	opentext
	writetext ProtonRevealText
	waitbutton
	closetext
	winlosstext ProtonWinText, 0
	setlasttalked LAVRADIOTOWER5F_PROTON
	loadtrainer EXECUTIVEM, EXECUTIVEM_2
	startbattle
	disappear LAVRADIOTOWER5F_GRUNT_1
	disappear LAVRADIOTOWER5F_GRUNT_2
	disappear LAVRADIOTOWER5F_GRUNT_3
	setevent EVENT_RADIO_TOWER_ROCKET_TAKEOVER
	setevent EVENT_BEAT_ROCKET_EXECUTIVEM_2
	reloadmapafterbattle
	playmusic MUSIC_RIVAL_AFTER
	opentext
	writetext LavRadioTower5FPharmacistText
	waitbutton
	closetext
	appear LAVRADIOTOWER5F_RANGER
	applymovement LAVRADIOTOWER5F_RANGER, FirstRangerArrivesMovement
    opentext
	writetext LavRadioTower5FRangerText
	waitbutton
	closetext
	applymovement PLAYER, PlayerStepBackMovement
	applymovement LAVRADIOTOWER5F_RANGER, FirstRangerArrestsProtonMovement
	opentext
	writetext FirstRangerArrestsProtonText
	waitbutton
	closetext
	pause 15
	turnobject LAVRADIOTOWER5F_RANGER, LEFT
	pause 15
	opentext
	writetext LavRadioTower5FRangerText_Cleared
	waitbutton
	closetext
	follow LAVRADIOTOWER5F_RANGER, LAVRADIOTOWER5F_PROTON
	applymovement LAVRADIOTOWER5F_RANGER, FirstRangerLeavesMovement
	stopfollow
	disappear LAVRADIOTOWER5F_PROTON
	disappear LAVRADIOTOWER5F_RANGER
	playmapmusic
	end

.NotReady:
	opentext
	writetext ProtonDisguiseText
	waitbutton
	closetext
	end

FirstRangerArrivesMovement:
	step LEFT
	step LEFT
	step LEFT
	step LEFT
	step LEFT
	step LEFT
	step DOWN
	step DOWN
	step DOWN
	step_end

PlayerStepBackMovement:
	fix_facing
	step LEFT
	remove_fixed_facing
	step_end

FirstRangerArrestsProtonMovement:
	step DOWN
	turn_head RIGHT
	step_end

FirstRangerLeavesMovement:
	step UP
	step UP
	step UP
	step UP
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step_end


ProtonDisguiseText:
	text "Hmm?"

	para "Can I help you?"
	line "I'm just one of"
	cont "the staff here."

	para "Shouldn't you"
	line "be downstairs?"
	done

ProtonRevealText:
	text "…"

	para "You actually made"
	line "it up here."

	para "I heard you coming"
	line "floor by floor."
	cont "One by one."

	para "Fine."
	line "The act's over."

	para "TEAM ROCKET doesn't"
	line "lose to children."
	cont "Prove me wrong."
	done

ProtonWinText:
	text "You actually…"
	done

LavRadioTower5FPharmacistText:
	text "Tch! You and that"
	line "red-headed menace!"

	para "You might have"
	line "caught me, but the"
	cont "others won't be as"
	cont "easy!"
	done

LavRadioTower5FRangerText:
	text "<PLAY_G>, nice to"
	line "finally meet you."

	para "I'm FIRST RANGER"
	line "for the #MON"
	cont "LEAGUE."

	para "I had a assembled"
	line "a team to defeat"
	cont "PROTON but you got"
	cont "to him first."

	para "Good work. I'll"
	line "put him away where"
	cont "he can't escape."
	done

FirstRangerArrestsProtonText:
	text "FIRST RANGER:"

	para "PROTON."
	line "You're coming"
	cont "with me."
	done

LavRadioTower5FRangerText_Cleared:
	text "He'll answer for"
	line "what happened"
	cont "here."

	para "You cleared every"
	line "floor of this"
	cont "building."

	para "The RANGERS won't"
	line "forget that."
	done

LavRadioTower5FGentlemanScript:
	faceplayer
	opentext
	checkevent EVENT_RADIO_TOWER_ROCKET_TAKEOVER
	iffalse .BeforeProton
	checkflag ENGINE_EXPN_CARD
	iftrue .GotExpnCard
	checkevent EVENT_RETURNED_MACHINE_PART
	iftrue .PowerRestored
	; Tower cleared, power not yet fixed
	writetext LavRadioTower5FGentlemanText
	waitbutton
	closetext
	end

.PowerRestored:
	writetext LavRadioTower5FGentlemanText_GiveCard
	promptbutton
	getstring STRING_BUFFER_4, .expncardname
	scall .receiveitem
	setflag ENGINE_EXPN_CARD
.GotExpnCard:
	writetext LavRadioTower5FGentlemanText_GotCard
	waitbutton
	closetext
	end

.BeforeProton:
	writetext LavRadioTower5FGentlemanText_BeforeProton
	waitbutton
	closetext
	end

.receiveitem:
	jumpstd ReceiveItemScript
	end

.expncardname
	db "EXPN CARD@"

LavRadioTower5FGentlemanText_BeforeProton:
	text "Please…"
	line "Don't antagonize"
	cont "him."

	para "He'll hurt my"
	line "staff if you"
	cont "cause a scene."

	para "But if you're"
	line "going to fight…"
	cont "please win."
	done

LavRadioTower5FGentlemanText:
	text "Thanks for getting"
	line "rid of those guys!"

	para "But we still have"
	line "to fix the POWER"
	cont "PLANT!"

	para "Come back once"
	line "it's running."
	cont "I'll have something"
	cont "for you."
	done

LavRadioTower5FGentlemanText_GiveCard:
	text "Ah! So you're the"
	line "<PLAY_G> who got"
	cont "the POWER PLANT"
	cont "back on its feet?"

	para "Thanks to you, I"
	line "can broadcast"
	cont "again."

	para "Please take this."
	line "It's the least I"
	cont "can do."
	done

LavRadioTower5FGentlemanText_GotCard:
	text "With that card"
	line "you can tune into"
	cont "the full range of"
	cont "KANTO broadcasts."

	para "CHANNEL 20."
	line "You know the one."

	para "Gahahahaha!"
	done

LavRadioTower5FRockerScript:
	faceplayer
	opentext
	checkevent EVENT_RADIO_TOWER_ROCKET_TAKEOVER
	iftrue .Cleared
	writetext LavRadioTower5FRockerText
	waitbutton
	closetext
	end

.Cleared:
	writetext LavRadioTower5FRockerText_Cleared
	waitbutton
	closetext
	end

LavRadioTower5FRockerText:
	text "I've been stuck"
	line "with these thugs"
	cont "for days."

	para "Supposedly they"
	line "need the equipment"
	cont "for some 'plan.'"
	done

LavRadioTower5FRockerText_Cleared:
	text "Do you listen"
	line "to our music?"

	para "The request lines"
	line "are already going"
	cont "crazy."
	done

LavRadioTower5FClerkScript:
	faceplayer
	opentext
	checkevent EVENT_RADIO_TOWER_ROCKET_TAKEOVER
	iftrue .Cleared
	writetext LavRadioTower5FClerkText
	waitbutton
	closetext
	end

.Cleared:
	writetext LavRadioTower5FClerkText_Cleared
	waitbutton
	closetext
	end

LavRadioTower5FClerkText:
	text "I've been sitting"
	line "at this desk for"
	cont "three days."

	para "Pretending to file"
	line "paperwork, but"
	cont "there is no"
	cont "paperwork."
	done

LavRadioTower5FClerkText_Cleared:
	text "Back to normal."

	para "Well. Almost."

	para "I keep looking"
	line "over my shoulder."
	cont "Old habit now,"
	cont "I suppose."
	done

LavRadioTower5F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 12,  0, LAV_RADIO_TOWER_4F, 1

	def_coord_events

	def_bg_events

	def_object_events
	; Always-present staff
	object_event  6,  6, SPRITE_GENTLEMAN, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, LavRadioTower5FGentlemanScript, -1
	object_event 14,  6, SPRITE_ROCKER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, LavRadioTower5FRockerScript, -1
	object_event  1,  4, SPRITE_CLERK, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, LavRadioTower5FClerkScript, -1
	object_event  5,  6, SPRITE_PHARMACIST,SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 5, LavRadioTower5FProtonScript, EVENT_RADIO_TOWER_ROCKET_TAKEOVER
	object_event 17,  5, SPRITE_ROCKET, SPRITEMOVEDATA_STANDING_RIGHT,0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 3, TrainerGruntM26, EVENT_RADIO_TOWER_ROCKET_TAKEOVER
	object_event 10,  4, SPRITE_ROCKET, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 3, TrainerGruntM27, EVENT_RADIO_TOWER_ROCKET_TAKEOVER
	object_event  0,  5, SPRITE_ROCKET, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 4, TrainerGruntM30, EVENT_RADIO_TOWER_ROCKET_TAKEOVER
	object_event 10,  2, SPRITE_OFFICER, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BLACK, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_LAV_RADIO_TOWER_RANGER_HIDDEN

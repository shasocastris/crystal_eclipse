	object_const_def
	const LAVRADIOTOWER2F_RIVAL
	const LAVRADIOTOWER2F_YOUNGSTER
	const LAVRADIOTOWER2F_GENTLEMAN
	const LAVRADIOTOWER2F_TEACHER
	const LAVRADIOTOWER2F_COOLTRAINERF
	const LAVRADIOTOWER2F_SUPER_NERD

LavRadioTower2F_MapScripts:
	def_scene_scripts
    scene_script LavRadioTower2FRivalScene, SCENE_LAVRADIOTOWER2F_RIVAL
	scene_script LavRadioTower2FNoop,       SCENE_LAVRADIOTOWER2F_NOOP

	def_callbacks

LavRadioTower2FRivalScene:
	sdefer LavRadioTower2FRivalApproachScript
	end

LavRadioTower2FNoop:
	end


LavRadioTower2FRivalApproachScript:
	applymovement PLAYER, FaceRivalMovement
	showemote EMOTE_SHOCK, LAVRADIOTOWER2F_RIVAL, 30
	playmusic MUSIC_RIVAL_ENCOUNTER
	opentext
	writetext LavRadioTower2FRivalText
	waitbutton
	closetext
	setevent EVENT_RIVAL_LAV_RADIO_TOWER_2F
	setscene SCENE_LAVRADIOTOWER2F_NOOP
	playmapmusic
	end

LavRadioTower2FRivalScript:
	faceplayer
	checkevent EVENT_RIVAL_LAV_RADIO_TOWER_2F
	iftrue .AlreadyTalked
	opentext
	writetext LavRadioTower2FRivalText
	waitbutton
	closetext
	setevent EVENT_RIVAL_LAV_RADIO_TOWER_2F
	setscene SCENE_LAVRADIOTOWER2F_NOOP
	end

.AlreadyTalked:
	jumptextfaceplayer LavRadioTower2FRivalRepeatText

FaceRivalMovement:
	step DOWN
	turn_head RIGHT
	step_end

LavRadioTower2FRivalText:
	text "<PLAY_G>."

	para "Of course you're"
	line "here too."

	para "Listen. TEAM"
	line "ROCKET has taken"
	cont "over this tower."

	para "They're not in"
	line "uniform. Hard to"
	cont "tell who's a grunt"
	cont "and who isn't."

	para "I got through"
	line "the first two"
	cont "floors before"
	cont "I hit a wall."

	para "Too many of them."
	line "I couldn't reach"
	cont "the DIRECTOR."

	para "You're stronger"
	line "than me. You"
	cont "know it and I"
	cont "know it."

	para "Get up there."
	line "Clear them out."
	cont "Find the DIRECTOR"
	cont "before it's"
	cont "too late."

	para "…I'll keep the"
	line "exit covered."
	done

LavRadioTower2FRivalRepeatText:
	text "The DIRECTOR is"
	line "still up there."

	para "Make sure to clear"
	line "out every one of"
	cont "these rotten"
	cont "#MON 'trainers.'"

	para "Go. I've got"
	line "this floor."
	done

LavRadioTower2FTeacherScript:
	faceplayer
	opentext
	checkevent EVENT_RADIO_TOWER_ROCKET_TAKEOVER
	iftrue .Cleared
	writetext LavRadioTower2FTeacherText
	waitbutton
	closetext
	end

.Cleared:
	writetext LavRadioTower2FTeacherText_Cleared
	waitbutton
	closetext
	end

LavRadioTower2FTeacherText:
	text "Oh thank goodness!"
	line "A trainer!"

	para "They came in six"
	line "days ago. Said"
	cont "they were doing"
	cont "emergency repairs."

	para "Then they locked"
	line "the doors."

	para "The DIRECTOR is"
	line "somewhere on the"
	cont "upper floors."
	cont "Please help him!"
	done

LavRadioTower2FTeacherText_Cleared:
	text "Welcome to 2F!"
	line "This is our SALES"
	cont "floor."

	para "We carry all kinds"
	line "of RADIO TOWER"
	cont "merchandise."

	para "It's good to be"
	line "back at work."
	cont "Last week feels"
	cont "like a bad dream."
	done

LavRadioTower2FCooltrainerFScript:
	faceplayer
	opentext
	checkevent EVENT_RADIO_TOWER_ROCKET_TAKEOVER
	iftrue .Cleared
	writetext LavRadioTower2FCooltrainerFText
	waitbutton
	closetext
	end

.Cleared:
	writetext LavRadioTower2FCooltrainerFText_Cleared
	waitbutton
	closetext
	end

LavRadioTower2FCooltrainerFText:
	text "I heard them"
	line "talking…"

	para "Something about"
	line "a special signal"
	cont "that can direct"
	cont "specific #MON."

	para "They kept saying"
	line "'the roads are"
	cont "already sealed.'"

	para "I don't know what"
	line "that means but it"
	cont "doesn't sound good"
	done

LavRadioTower2FCooltrainerFText_Cleared:
	text "Have you tried"
	line "tuning to CHANNEL"
	cont "20 on your"
	cont "#GEAR?"

	para "The POKE FLUTE"
	line "music is back on"
	cont "the air!"

	para "I hear it'll even"
	line "wake SNORLAX up."
	cont "Once the POWER"
	cont "PLANT is fixed,"
	cont "anyway."
	done

LavRadioTower2FYoungsterScript:
	faceplayer
	opentext
	checkevent EVENT_RADIO_TOWER_ROCKET_TAKEOVER
	iftrue .Cleared
	writetext LavRadioTower2FYoungsterText
	waitbutton
	closetext
	end

.Cleared:
	writetext LavRadioTower2FYoungsterText_Cleared
	waitbutton
	closetext
	end

LavRadioTower2FYoungsterText:
	text "I tried to go"
	line "upstairs but some"
	cont "weird guy told"
	cont "me to get lost."

	para "And there's been"
	line "all this shouting"
	cont "from up there…"

	para "Mom says we should"
	line "just go home but"
	cont "I want to hear"
	cont "the POKE FLUTE"
	cont "channel."
	done

LavRadioTower2FYoungsterText_Cleared:
	text "Did you hear?"
	line "CHANNEL 20 is"
	cont "back on the air!"

	para "The POKE FLUTE"
	line "music is so good."
	cont "My SLOWPOKE falls"
	cont "asleep every time."

	para "Is it true some"
	line "trainer saved the"
	cont "whole tower?"
	done

LavRadioTower2FPokefanMScript:
	faceplayer
	opentext
	checkevent EVENT_RADIO_TOWER_ROCKET_TAKEOVER
	iftrue .Cleared
	writetext LavRadioTower2FPokefanMText
	waitbutton
	closetext
	end

.Cleared:
	writetext LavRadioTower2FPokefanMText_Cleared
	waitbutton
	closetext
	end

LavRadioTower2FPokefanMText:
	text "I came all the way"
	line "here for an EXPN"
	cont "CARD upgrade and"
	cont "now the floors"
	cont "are all closed!"

	para "The DIRECTOR is"
	line "the only one who"
	cont "can authorize it."
	cont "5F office."

	para "But nobody will"
	line "let me up there."
	cont "Something's very"
	cont "wrong today."
	done

LavRadioTower2FPokefanMText_Cleared:
	text "I heard the tower"
	line "is selling special"
	cont "EXPN CARD upgrades"
	cont "this season!"

	para "With one of those"
	line "you can tune into"
	cont "KANTO broadcasts."

	para "The DIRECTOR"
	line "handles those"
	cont "personally, I"
	cont "think. 5F office."
	done

LavRadioTower2FSuperNerdScript:
	faceplayer
	opentext
	checkevent EVENT_RADIO_TOWER_ROCKET_TAKEOVER
	iftrue .Cleared
	writetext LavRadioTower2FSuperNerdText
	waitbutton
	closetext
	end

.Cleared:
	writetext LavRadioTower2FSuperNerdText_Cleared
	waitbutton
	closetext
	end

LavRadioTower2FSuperNerdText:
	text "Keep your voice"
	line "down."

	para "I've been watching"
	line "the broadcast log."
	cont "The signal output"
	cont "changed about a"
	cont "week ago."

	para "Something is being"
	line "piggybacked onto"
	cont "the main channels."

	para "I don't know what"
	line "it does. But it's"
	cont "not supposed to"
	cont "be there."
	done

LavRadioTower2FSuperNerdText_Cleared:
	text "I pulled the logs"
	line "from the past"
	cont "week."

	para "That sub-signal"
	line "was targeting"
	cont "delta waves. The"
	cont "kind that affect"
	cont "sleep cycles in"
	cont "large #MON."

	para "Whoever set this"
	line "up knew exactly"
	cont "what they were"
	cont "doing."

	para "Scary stuff."
	done

LavRadioTower2FSalesSign:
	jumptext LavRadioTower2FSalesSignText

LavRadioTower2FSalesSignText:
	text "2F SALES"
	done

LavRadioTower2F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 12,  0, LAV_RADIO_TOWER_3F, 1
	warp_event 15,  0, LAV_RADIO_TOWER_1F, 3

	def_coord_events
	coord_event 15,  1, SCENE_LAVRADIOTOWER2F_RIVAL, LavRadioTower2FRivalApproachScript

	def_bg_events
	bg_event  9,  0, BGEVENT_READ, LavRadioTower2FSalesSign

	def_object_events
	object_event 16,  1, SPRITE_RIVAL, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, LavRadioTower2FRivalScript, EVENT_RADIO_TOWER_ROCKET_TAKEOVER
	object_event 13,  4, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 2, LavRadioTower2FYoungsterScript, -1
	object_event 14,  4, SPRITE_POKEFAN_F, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, LavRadioTower2FPokefanMScript, -1
	object_event  0,  4, SPRITE_TEACHER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, LavRadioTower2FTeacherScript, -1
	object_event 18,  6, SPRITE_COOLTRAINER_F, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, LavRadioTower2FCooltrainerFScript, -1
	object_event  5,  6, SPRITE_SUPER_NERD, SPRITEMOVEDATA_STANDING_UP,  0, 0, -1, -1, PAL_NPC_PURPLE, OBJECTTYPE_SCRIPT,  4, LavRadioTower2FSuperNerdScript, -1
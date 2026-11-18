	object_const_def
	const LAVRADIOTOWER1F_RECEPTIONIST
	const LAVRADIOTOWER1F_OFFICER
	const LAVRADIOTOWER1F_SUPER_NERD1
	const LAVRADIOTOWER1F_SUPER_NERD2

LavRadioTower1F_MapScripts:
	def_scene_scripts

	def_callbacks

LavRadioTower1FReceptionistScript:
	faceplayer
	opentext
	checkevent EVENT_RADIO_TOWER_ROCKET_TAKEOVER
	iftrue .Cleared
	writetext LavRadioTower1FReceptionistText
	waitbutton
	closetext
	end

.Cleared:
	writetext LavRadioTower1FReceptionistText_Cleared
	waitbutton
	closetext
	end

LavRadioTower1FReceptionistText:
	text "W-welcome…"

	para "I'm sorry, the"
	line "upper floors are"
	cont "closed today."

	para "Please enjoy the"
	line "ground floor and"
	cont "then… head home."

	para "Please."
	done

LavRadioTower1FReceptionistText_Cleared:
	text "Welcome!"
	line "Feel free to look"

	para "around anywhere on"
	line "this floor."

	para "And thank you…"
	line "for what you did"
	cont "up there."

	para "I've never been"
	line "so scared in my"
	cont "life."
	done

LavRadioTower1FOfficerScript:
	faceplayer
	opentext
	checkevent EVENT_RADIO_TOWER_ROCKET_TAKEOVER
	iftrue .Cleared
	writetext LavRadioTower1FOfficerText
	waitbutton
	closetext
	end

.Cleared:
	writetext LavRadioTower1FOfficerText_Cleared
	waitbutton
	closetext
	end

LavRadioTower1FOfficerText:
	text "Sorry, but you can"
	line "only tour the"
	cont "ground floor."

	para "Ever since JOHTO's"
	line "RADIO TOWER was"

	para "taken over by a"
	line "criminal gang, we"

	para "have had to step"
	line "up our security."

	para "And yet… some of"
	line "the new staff on"
	cont "the upper floors"
	cont "seem… off."

	para "I can't put my"
	line "finger on it."
	done

LavRadioTower1FOfficerText_Cleared:
	text "I should have"
	line "caught them"
	cont "sooner."

	para "Some OFFICER I am."
	line "Didn't even notice"
	cont "they'd replaced"
	cont "the whole staff."

	para "Thank you, kid."
	done

LavRadioTower1FSuperNerd1Script:
	faceplayer
	opentext
	checkevent EVENT_RADIO_TOWER_ROCKET_TAKEOVER
	iftrue .Cleared
	writetext LavRadioTower1FSuperNerd1Text
	waitbutton
	closetext
	end

.Cleared:
	writetext LavRadioTower1FSuperNerd1Text_Cleared
	waitbutton
	closetext
	end

LavRadioTower1FSuperNerd1Text:
	text "Something is wrong"
	line "here."

	para "The new staff on"
	line "upper floors won't"
	cont "talk to any of us."

	para "And last night…"
	line "I heard shouting"
	cont "and a crash."

	para "My manager told me"
	line "to stay down here"
	cont "and act normal."

	para "I don't know what"
	line "normal is anymore."
	done

LavRadioTower1FSuperNerd1Text_Cleared:
	text "Many people are"
	line "hard at work here"

	para "in the RADIO"
	line "TOWER."

	para "They must be doing"
	line "their best to put"
	cont "on good shows."

	para "…That's what I"
	line "kept telling"
	cont "myself all week."
	cont "Now I actually"
	cont "believe it again."
	done

LavRadioTower1FSuperNerd2Script:
	faceplayer
	opentext
	checkevent EVENT_RADIO_TOWER_ROCKET_TAKEOVER
	iftrue .Cleared
	writetext LavRadioTower1FSuperNerd2Text
	waitbutton
	closetext
	end

.Cleared:
	checkflag ENGINE_EXPN_CARD
	iftrue .GotExpnCard
	writetext LavRadioTower1FSuperNerd2Text_Cleared
	waitbutton
	closetext
	end

.GotExpnCard:
	writetext LavRadioTower1FSuperNerd2Text_GotExpnCard
	waitbutton
	closetext
	end

LavRadioTower1FSuperNerd2Text:
	text "Hey there!"

	para "I am the super"
	line "MUSIC DIRECTOR!"

	para "And I have been"
	line "stuck on THIS"
	cont "floor for DAYS."

	para "The new staff said"
	line "the upper floors"
	cont "are under review."

	para "Something is very"
	line "wrong here and"
	cont "nobody will tell"
	cont "me what!"
	done

LavRadioTower1FSuperNerd2Text_Cleared:
	text "Hey there!"

	para "I am the super"
	line "MUSIC DIRECTOR!"

	para "Huh? Your #GEAR"
	line "can't tune into my"

	para "music programs."
	line "How unfortunate!"

	para "If you get an EXPN"
	line "CARD upgrade, you"

	para "can tune in. You'd"
	line "better get one!"
	done

LavRadioTower1FSuperNerd2Text_GotExpnCard:
	text "Hey there!"

	para "I am the super"
	line "MUSIC DIRECTOR!"

	para "I'm responsible"
	line "for the gorgeous"

	para "melodies that go"
	line "out over the air."

	para "Don't be square."
	line "Grab your music"
	cont "off the air!"
	done

LavRadioTower1FDirectory:
	jumptext LavRadioTower1FDirectoryText

LavRadioTower1FDirectoryText:
	text "1F RECEPTION"
	line "2F SALES"

	para "3F PERSONNEL"
	line "4F PRODUCTION"

	para "5F DIRECTOR'S"
	line "   OFFICE"
	done

LavRadioTower1FPokeFluteSign:
	jumptext LavRadioTower1FPokeFluteSignText

LavRadioTower1FPokeFluteSignText:
	text "Perk Up #MON"
	line "with Mellow Sounds"

	para "of the # FLUTE"
	line "on CHANNEL 20"
	done

LavRadioTower1F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2,  7, LAVENDER_TOWN, 7
	warp_event  3,  7, LAVENDER_TOWN, 7
	warp_event 15,  0, LAV_RADIO_TOWER_2F, 2

	def_coord_events

	def_bg_events
	bg_event 11,  0, BGEVENT_READ, LavRadioTower1FDirectory
	bg_event  5,  0, BGEVENT_READ, LavRadioTower1FPokeFluteSign

	def_object_events
	object_event  6,  6, SPRITE_RECEPTIONIST, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, LavRadioTower1FReceptionistScript, -1
	object_event 14,  1, SPRITE_OFFICER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, LavRadioTower1FOfficerScript, -1
	object_event  1,  3, SPRITE_SUPER_NERD, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, LavRadioTower1FSuperNerd1Script, -1
	object_event 14,  6, SPRITE_SUPER_NERD, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, LavRadioTower1FSuperNerd2Script, -1

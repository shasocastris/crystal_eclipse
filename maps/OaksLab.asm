	object_const_def
	const OAKSLAB_OAK
	const OAKSLAB_SCIENTIST1
	const OAKSLAB_SCIENTIST2
	const OAKSLAB_SCIENTIST3

OaksLab_MapScripts:
	def_scene_scripts

	def_callbacks

Oak:
	faceplayer
	opentext
	checkevent EVENT_OPENED_MT_SILVER
	iftrue .CheckPokedex
	checkevent EVENT_TALKED_TO_OAK_IN_KANTO
	iftrue .CheckBadges
	writetext OakWelcomeKantoText
	promptbutton
	setevent EVENT_TALKED_TO_OAK_IN_KANTO
.CheckBadges:
	checkevent EVENT_GOT_GS_BALL_FROM_OAK
	iftrue .SkipGSBall
	writetext OakGSBallText
	promptbutton
	verbosegiveitem GS_BALL
	iffalse .SkipGSBall
	setevent EVENT_GOT_GS_BALL_FROM_OAK
	setevent EVENT_CAN_GIVE_GS_BALL_TO_KURT
	closetext
	end
.SkipGSBall:
	checkevent EVENT_BEAT_ELITE_FOUR_REMATCH
	iftrue .OpenMtSilver
	readvar VAR_BADGES
	ifequal NUM_JOHTO_BADGES, .Complain
	sjump .AhGood

.CheckPokedex:
	writetext OakLabDexCheckText
	waitbutton
	special ProfOaksPCBoot
	writetext OakLabGoodbyeText
	waitbutton
	closetext
	end

.OpenMtSilver:
	writetext OakOpenMtSilverText
	promptbutton
	setevent EVENT_OPENED_MT_SILVER
	sjump .CheckPokedex

.Complain:
	writetext OakNoKantoBadgesText
	promptbutton
	sjump .CheckPokedex

.AhGood:
	writetext OakYesKantoBadgesText
	promptbutton
	sjump .CheckPokedex

OaksAssistant1Script:
	faceplayer
	opentext
	checkitem ORANGE_PASS
	iftrue .GotPass
	writetext OaksAssistant1OrangePassText
	promptbutton
	verbosegiveitem ORANGE_PASS
	iffalse .NoRoom
.GotPass:
	writetext OaksAssistant1ExpressText
	waitbutton
.NoRoom:
	closetext
	end

OaksAssistant2Script:
	faceplayer
	opentext
	checkflag ENGINE_WEATHER_MAP
	iftrue .GotUpgrade
	checkflag ENGINE_MAP_CARD
	iffalse .NoMapCard
	writetext OaksAssistant2UpgradeText
	promptbutton
	getstring STRING_BUFFER_4, .WeatherMapName
	scall .ReceiveItem
	setflag ENGINE_WEATHER_MAP
.GotUpgrade:
	writetext OaksAssistant2WeatherMapText
	waitbutton
	closetext
	end

.NoMapCard:
	writetext OaksAssistant2Text
	waitbutton
	closetext
	end

.ReceiveItem:
	jumpstd ReceiveItemScript
	end

.WeatherMapName:
	db "WEATHER MAP@"

OaksAssistant3Script:
	jumptextfaceplayer OaksAssistant3Text

OaksLabBookshelf:
	jumpstd DifficultBookshelfScript

OaksLabAdvancedStudies1:
	jumptext OaksLabAdvancedStudies1Text

OaksLabAdvancedStudies2:
	jumptext OaksLabAdvancedStudies2Text

OaksLabAdvancedStudies3:
	jumptext OaksLabAdvancedStudies3Text

OaksLabAdvancedStudies4:
	jumptext OaksLabAdvancedStudies4Text

OaksLabPoster1:
	jumptext OaksLabPoster1Text

OaksLabPoster2:
	jumptext OaksLabPoster2Text

OaksLabTrashcan:
	jumptext OaksLabTrashcanText

OaksLabPC:
	jumptext OaksLabPCText

OakWelcomeKantoText:
	text "OAK: Ah, <PLAY_G>!"
	line "It's good of you"

	para "to come all this"
	line "way to KANTO."

	para "What do you think"
	line "of the trainers"

	para "out here?"
	line "Pretty tough, huh?"
	done

OakLabDexCheckText:
	text "How is your #-"
	line "DEX coming?"

	para "Let's see…"
	done

OakLabGoodbyeText:
	text "If you're in the"
	line "area, I hope you"
	cont "come visit again."
	done

OakOpenMtSilverText:
	text "OAK: Incredible!"
	line "Simply incredible!"

	para "You've not only"
	line "defeated the ELITE"
	cont "FOUR once more…"

	para "But proven yourself"
	line "as the ultimate"
	cont "#MON trainer!"

	para "I was right in my"
	line "assessment of you."

	para "Tell you what,"
	line "<PLAY_G>. I'll make"

	para "arrangements so"
	line "that you can go to"
	cont "MT.SILVER."

	para "MT.SILVER is a big"
	line "mountain that is"

	para "home to many wild"
	line "#MON."

	para "It's too dangerous"
	line "for your average"

	para "trainer, so it's"
	line "off limits. But"

	para "after defeating"
	line "the ELITE FOUR"
	cont "twice…"

	para "We can make an"
	line "exception in your"
	cont "case, <PLAY_G>."

	para "Go up to INDIGO"
	line "PLATEAU. You can"

	para "reach MT.SILVER"
	line "from there."
	done

OakNoKantoBadgesText:
	text "OAK: Hmm? You're"
	line "not collecting"
	cont "KANTO GYM BADGES?"

	para "The GYM LEADERS in"
	line "KANTO are as tough"

	para "as any you battled"
	line "in JOHTO."

	para "I recommend that"
	line "you challenge"
	cont "them."
	done

OakYesKantoBadgesText:
	text "OAK: Ah, you're"
	line "collecting KANTO"
	cont "GYM BADGES."

	para "I imagine that"
	line "it's hard, but the"

	para "experience is sure"
	line "to help you."

	para "Once you collect"
	line "them all, you"
	cont "should try your"
	cont "skill facing the"
	cont "ELITE FOUR again."

	para "Come see me when"
	line "you've defeated"
	cont "their best teams."

	para "I'll have a gift"
	line "for you."

	para "Keep trying hard,"
	line "<PLAY_G>!"
	done

OakGSBallText:
	text "OAK: Ah, before"
	line "I forget…"

	para "I've had this for"
	line "some time now."
	cont "A peculiar BALL."

	para "Gold and Silver."
	line "I've never seen"
	cont "anything like it."

	para "I can't open it"
	line "and I can't quite"
	cont "figure out what"
	cont "it's for."

	para "You travel more"
	line "than I do these"
	cont "days. Take it."

	para "Perhaps you'll"
	line "find someone who"
	cont "knows what it is."
	done

OaksAssistant1Text:
	text "The PROF's #MON"
	line "TALK radio program"

	para "isn't aired here"
	line "in KANTO."

	para "It's a shame--I'd"
	line "like to hear it."
	done

OaksAssistant1OrangePassText:
	text "The PROF is study-"
	line "ing #MON on the"
	cont "ORANGE ISLANDS."

	para "He'd like you to"
	line "see them, too."
	cont "Here, take this!"
	done

OaksAssistant1ExpressText:
	text "Show the ORANGE"
	line "PASS at VERMILION"
	cont "PORT."

	para "The express to"
	line "VALENCIA ISLAND"
	cont "sails every day."
	done

OaksAssistant2UpgradeText:
	text "I study the way"
	line "weather moves over"
	cont "KANTO and JOHTO."

	para "Let me add my"
	line "data to your MAP"
	cont "CARD."
	done

OaksAssistant2WeatherMapText:
	text "Your #GEAR MAP"
	line "now shows today's"

	para "weather wherever"
	line "you point it."
	done

OaksAssistant2Text:
	text "Thanks to your"
	line "work on the #-"
	cont "DEX, the PROF's"

	para "research is coming"
	line "along great."
	done

OaksAssistant3Text:
	text "Don't tell anyone,"
	line "but PROF.OAK'S"

	para "#MON TALK isn't"
	line "a live broadcast."
	done

OaksLabPoster1Text:
	text "Type Mastery"
	line "Research:"

	para "Catching all"
	line "#MON of one"

	para "type strengthens"
	line "moves of that"
	cont "type!"

	para "- PROF.OAK"
	done

OaksLabPoster2Text:
	text "Type Mastery"
	line "Notes:"

	para "Legendary #MON"
	line "are excluded from"

	para "this effect. True"
	line "mastery comes from"

	para "understanding a"
	line "type's common"
	cont "#MON!"

	para "- BLUE"
	done

OaksLabTrashcanText:
	text "There's nothing in"
	line "here…"
	done

OaksLabPCText:
	text "There's an e-mail"
	line "message on the PC."

	para "…"

	para "PROF.OAK, how is"
	line "your research"
	cont "coming along?"

	para "I'm still plugging"
	line "away."

	para "I heard rumors"
	line "that <PLAY_G> is"

	para "getting quite a"
	line "reputation."

	para "I'm delighted to"
	line "hear that."

	para "ELM in NEW BARK"
	line "TOWN 8-)"
	done

OaksLabAdvancedStudies1Text:
	text "Professor Oak's"
	line "Advanced Studies:"

	para "The HOPPIP line"
	line "learns SPORE. The"
	cont "JUMPLUFF I evolved"
	cont "proved invaluable"
	cont "while traveling"
	cont "through JOHTO."
	done

OaksLabAdvancedStudies2Text:
	text "Professor Oak's"
	line "Advanced Studies:"

	para "The RAZOR CLAW,"
	line "DUBIOUS DISC, and"
	cont "PROTECTOR are now"
	cont "known to evolve"
	cont "certain #MON."
	done

OaksLabAdvancedStudies3Text:
	text "Professor Oak's"
	line "Advanced Studies:"

	para "Different types of"
	line "ROCKs are able to"
	cont "enhance different"
	cont "weather effects."
	done

OaksLabAdvancedStudies4Text:
	text "Professor Oak's"
	line "Advanced Studies:"

	para "I was told that a"
	line "RADIANT ORB could"
	cont "bring out the full"
	cont "inner strength of"
	cont "a #MON."

	para "What exactly does"
	line "that mean?"
	done

OaksLab_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4, 11, PALLET_TOWN, 3
	warp_event  5, 11, PALLET_TOWN, 3

	def_coord_events

	def_bg_events
	bg_event  6,  1, BGEVENT_READ, OaksLabAdvancedStudies1
	bg_event  7,  1, BGEVENT_READ, OaksLabAdvancedStudies2
	bg_event  8,  1, BGEVENT_READ, OaksLabAdvancedStudies3
	bg_event  9,  1, BGEVENT_READ, OaksLabAdvancedStudies4
	bg_event  0,  7, BGEVENT_READ, OaksLabBookshelf
	bg_event  1,  7, BGEVENT_READ, OaksLabBookshelf
	bg_event  2,  7, BGEVENT_READ, OaksLabBookshelf
	bg_event  3,  7, BGEVENT_READ, OaksLabBookshelf
	bg_event  6,  7, BGEVENT_READ, OaksLabBookshelf
	bg_event  7,  7, BGEVENT_READ, OaksLabBookshelf
	bg_event  8,  7, BGEVENT_READ, OaksLabBookshelf
	bg_event  9,  7, BGEVENT_READ, OaksLabBookshelf
	bg_event  4,  0, BGEVENT_READ, OaksLabPoster1
	bg_event  5,  0, BGEVENT_READ, OaksLabPoster2
	bg_event  9,  3, BGEVENT_READ, OaksLabTrashcan
	bg_event  0,  1, BGEVENT_READ, OaksLabPC

	def_object_events
	object_event  4,  2, SPRITE_OAK, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Oak, -1
	object_event  1,  8, SPRITE_SCIENTIST, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 1, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, OaksAssistant1Script, -1
	object_event  8,  9, SPRITE_SCIENTIST, SPRITEMOVEDATA_WALK_UP_DOWN, 0, 1, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, OaksAssistant2Script, -1
	object_event  1,  4, SPRITE_SCIENTIST, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, OaksAssistant3Script, -1

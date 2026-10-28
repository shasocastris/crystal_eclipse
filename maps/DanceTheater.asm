	object_const_def
	const DANCETHEATER_KIMONO_GIRL1
	const DANCETHEATER_KIMONO_GIRL2
	const DANCETHEATER_KIMONO_GIRL3
	const DANCETHEATER_KIMONO_GIRL4
	const DANCETHEATER_KIMONO_GIRL5
	const DANCETHEATER_GENTLEMAN
	const DANCETHEATER_RHYDON
	const DANCETHEATER_COOLTRAINER_M
	const DANCETHEATER_GRANNY

DanceTheater_MapScripts:
	def_scene_scripts

	def_callbacks

TrainerKimonoGirlNaoko:
	trainer KIMONO_GIRL, NAOKO, EVENT_BEAT_KIMONO_GIRL_NAOKO, KimonoGirlNaokoSeenText, KimonoGirlNaokoBeatenText, 0, .Script

.Script:
	opentext
	checkevent EVENT_HEALED_MOOMOO
	iftrue .NaokoPostHunt
	writetext KimonoGirlNaokoAfterBattleText
	waitbutton
	closetext
	end

.NaokoPostHunt:
	writetext DanceTheaterNaokoText_PostHunt
	waitbutton
	closetext
	end

TrainerKimonoGirlSayo:
	trainer KIMONO_GIRL, SAYO, EVENT_BEAT_KIMONO_GIRL_SAYO, KimonoGirlSayoSeenText, KimonoGirlSayoBeatenText, 0, .Script

.Script:
	opentext
	checkevent EVENT_HEALED_MOOMOO
	iftrue .SayoPostHunt
	writetext KimonoGirlSayoAfterBattleText
	waitbutton
	closetext
	end

.SayoPostHunt:
	writetext DanceTheaterSayoText_PostHunt
	waitbutton
	closetext
	end

TrainerKimonoGirlZuki:
	trainer KIMONO_GIRL, ZUKI, EVENT_BEAT_KIMONO_GIRL_ZUKI, KimonoGirlZukiSeenText, KimonoGirlZukiBeatenText, 0, .Script

.Script:
	opentext
	checkevent EVENT_HEALED_MOOMOO
	iftrue .ZukiPostHunt
	writetext KimonoGirlZukiAfterBattleText
	waitbutton
	closetext
	end

.ZukiPostHunt:
	writetext DanceTheaterZukiText_PostHunt
	waitbutton
	closetext
	end

TrainerKimonoGirlKuni:
	trainer KIMONO_GIRL, KUNI, EVENT_BEAT_KIMONO_GIRL_KUNI, KimonoGirlKuniSeenText, KimonoGirlKuniBeatenText, 0, .Script

.Script:
	opentext
	checkevent EVENT_HEALED_MOOMOO
	iftrue .KuniPostHunt
	writetext KimonoGirlKuniAfterBattleText
	waitbutton
	closetext
	end

.KuniPostHunt:
	writetext DanceTheaterKuniText_PostHunt
	waitbutton
	closetext
	end

TrainerKimonoGirlMiki:
	trainer KIMONO_GIRL, MIKI, EVENT_BEAT_KIMONO_GIRL_MIKI, KimonoGirlMikiSeenText, KimonoGirlMikiBeatenText, 0, .Script

.Script:
	opentext
	checkevent EVENT_HEALED_MOOMOO
	iftrue .MikiPostHunt
	writetext KimonoGirlMikiAfterBattleText
	waitbutton
	closetext
	end

.MikiPostHunt:
	writetext DanceTheaterMikiText_PostHunt
	waitbutton
	closetext
	end

DanceTheaterRockSmashGuy:
	faceplayer
	opentext
	writetext RockSmashGuyNeverLeftAScratchText
	promptbutton
	checkevent EVENT_GOT_HM08_ROCK_SMASH
	iftrue RockSmashGuyAlreadyGaveRockSmash
	checkevent EVENT_BEAT_KIMONO_GIRL_NAOKO
	iffalse .KimonoGirlsUndefeated
	checkevent EVENT_BEAT_KIMONO_GIRL_SAYO
	iffalse .KimonoGirlsUndefeated
	checkevent EVENT_BEAT_KIMONO_GIRL_ZUKI
	iffalse .KimonoGirlsUndefeated
	checkevent EVENT_BEAT_KIMONO_GIRL_KUNI
	iffalse .KimonoGirlsUndefeated
	checkevent EVENT_BEAT_KIMONO_GIRL_MIKI
	iffalse .KimonoGirlsUndefeated
	sjump .GetRockSmash

.KimonoGirlsUndefeated:
	checkflag ENGINE_PLAYER_IS_FEMALE
	iftrue .PlayerIsFemale
	writetext RockSmashGuyLadGiftText
	waitbutton
	closetext
	end

.PlayerIsFemale:
	writetext RockSmashGuyLassieGiftText
	waitbutton
	closetext
	end

.GetRockSmash:
	writetext RockSmashGuyLikeADanceText
	promptbutton
	verbosegiveitem HM_ROCK_SMASH
	setevent EVENT_GOT_HM08_ROCK_SMASH
	writetext RockSmashGuyRockSmashExplanationText
	waitbutton
	closetext
	end

RockSmashGuyAlreadyGaveRockSmash:
	writetext RockSmashGuyElegantKimonoGirlsText
	waitbutton
	closetext
	end

DanceTheaterRhydon:
	opentext
	writetext RhydonText
	cry RHYDON
	waitbutton
	callasm .Rhydon
	special ShowPokedexEntry
	closetext
	end

.Rhydon
	ld hl, RHYDON
	call GetPokemonIDFromIndex
	ld [wScriptVar], a
	ret

DanceTheaterCooltrainerMScript:
	jumptextfaceplayer DanceTheaterCooltrainerMText

DanceTheaterGrannyScript:
	jumptextfaceplayer DanceTheaterGrannyText

DanceTheaterFancyPanel:
	jumptext DanceTheaterFancyPanelText

KimonoGirlNaokoSeenText:
	text "You have lovely"
	line "#MON. May I see"
	cont "them in battle?"
	done

KimonoGirlNaokoBeatenText:
	text "Oh, you are very"
	line "strong."
	done

KimonoGirlNaokoAfterBattleText:
	text "I enjoyed that"
	line "bout. I would like"
	cont "to see you again."
	done

DanceTheaterNaokoText_PostHunt:
	text "The WILD HUNT is"
	line "over, but ECRUTEAK"
	cont "needs time to"
	cont "heal."

	para "Our FLAREON helped"
	line "drive back the"
	cont "herd near the TIN"
	cont "TOWER."

	para "TEAM ROCKET fled,"
	line "but they're still"
	cont "out there."
	done

KimonoGirlSayoSeenText:
	text "I always dance"
	line "with my #MON."

	para "Of course, I also"
	line "train them."
	done

KimonoGirlSayoBeatenText:
	text "Oh, so close!"
	line "I almost had you."
	done

KimonoGirlSayoAfterBattleText:
	text "Rhythm is impor-"
	line "tant for both"

	para "dancing and #-"
	line "MON."
	done

DanceTheaterSayoText_PostHunt:
	text "ESPEON sensed the"
	line "panic in the wild"
	cont "#MON."

	para "Something about"
	line "TEAM ROCKET's"
	cont "cruelty triggered"
	cont "a primal rage."

	para "We must ensure"
	line "this never happens"
	cont "again."
	done

KimonoGirlZukiSeenText:
	text "Isn't my barrette"
	line "pretty?"

	para "Oh. A #MON"
	line "battle?"
	done

KimonoGirlZukiBeatenText:
	text "I don't have any"
	line "#MON left…"
	done

KimonoGirlZukiAfterBattleText:
	text "I put a different"
	line "flower in my bar-"
	cont "rette every month."

	para "This month's is"
	line "wolfsbane. It's"

	para "said to ward off"
	line "evil spirits and"
	cont "rampaging beasts."
	done

DanceTheaterZukiText_PostHunt:
	text "UMBREON and I"
	line "patrolled all"
	cont "night during the"
	cont "crisis."

	para "I heard strange"
	line "reports from the"
	cont "BURNED TOWER."

	para "Travelers say they"
	line "saw SUICUNE fight-"
	cont "ing off aggressive"
	cont "wild #MON."

	para "Could the legend-"
	line "ary beast be"
	cont "protecting JOHTO?"
	done

KimonoGirlKuniSeenText:
	text "Oh, you're a cute"
	line "trainer. Would you"
	cont "like to battle?"
	done

KimonoGirlKuniBeatenText:
	text "You're stronger"
	line "than you look."
	done

KimonoGirlKuniAfterBattleText:
	text "The elders say we"
	line "may need to defend"

	para "ECRUTEAK soon. I"
	line "hope I'm ready."
	done

DanceTheaterKuniText_PostHunt:
	text "Thank goodness"
	line "MILTANK recovered"
	cont "in time."

	para "Without your help,"
	line "the TAUROS would"
	cont "have trampled"
	cont "everything."

	para "TEAM ROCKET must"
	line "answer for what"
	cont "they've done."
	done

KimonoGirlMikiSeenText:
	text "Do you like my"
	line "dancing? I'm good"
	cont "at #MON too."
	done

KimonoGirlMikiBeatenText:
	text "Ooh, you're good"
	line "at #MON too."
	done

KimonoGirlMikiAfterBattleText:
	text "I can keep dancing"
	line "because there are"

	para "people who enjoy"
	line "what I do."

	para "My #MON keep my"
	line "spirits up even"
	cont "in dark times."
	done

DanceTheaterMikiText_PostHunt:
	text "JOLTEON's speed"
	line "helped us evacuate"
	cont "citizens quickly."

	para "But TEAM ROCKET"
	line "is growing bolder."

	para "First SLOWPOKE"
	line "WELL, now this?"

	para "What are they"
	line "really planning?"
	done

RockSmashGuyNeverLeftAScratchText:
	text "Not only are the"
	line "KIMONO GIRLS great"

	para "dancers, they're"
	line "also skilled at"
	cont "#MON."

	para "I always challenge"
	line "them, but I've"

	para "never even left a"
	line "scratch…"
	done

RockSmashGuyLadGiftText:
	text "Lad! If you can"
	line "defeat all the"

	para "KIMONO GIRLS, I'll"
	line "give you a gift."
	done

RockSmashGuyLassieGiftText:
	text "Lassie, if you can"
	line "defeat all the"

	para "KIMONO GIRLS, I'll"
	line "give you a gift."
	done

RockSmashGuyLikeADanceText:
	text "The way you bat-"
	line "tled, it was like"
	cont "watching a dance."

	para "It was a rare"
	line "treat to see!"

	para "I want you to have"
	line "this. Don't worry"
	cont "--take it!"
	done

RockSmashGuyRockSmashExplanationText:
	text "That happens to be"
	line "ROCK SMASH."

	para "You can shatter"
	line "rocks with just a"

	para "single well-aimed"
	line "smack."

	para "If any rocks are"
	line "in your way, just"
	cont "smash 'em up!"
	done

RockSmashGuyElegantKimonoGirlsText:
	text "I wish my #MON"
	line "were as elegant as"
	cont "the KIMONO GIRLS…"
	done

RhydonText:
	text "RHYDON: Gugooh"
	line "gugogooh!"
	done

DanceTheaterCooltrainerMText:
	text "That man's always"
	line "with his RHYDON."

	para "Says he wants a"
	line "#MON that can"
	cont "ROCK SMASH and"
	cont "dance."

	para "Is he trying to"
	line "make a mining and"
	cont "dancing #MON?"
	done

DanceTheaterGrannyText:
	text "The KIMONO GIRLS"
	line "are so beautiful…"

	para "But they have to"
	line "go through rigor-"
	cont "ous training."

	para "And they have to"
	line "learn to follow"

	para "customs before ap-"
	line "pearing in public."

	para "They are also here"
	line "to help keep our"
	cont "city safe."
	done

DanceTheaterFancyPanelText:
	text "It's a fancy panel"
	line "that's decorated"
	cont "with flowers."
	done

DanceTheater_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  5, 13, ECRUTEAK_CITY, 8
	warp_event  6, 13, ECRUTEAK_CITY, 8

	def_coord_events

	def_bg_events
	bg_event  5,  6, BGEVENT_UP, DanceTheaterFancyPanel
	bg_event  6,  6, BGEVENT_UP, DanceTheaterFancyPanel

	def_object_events
	object_event  0,  2, SPRITE_KIMONO_GIRL, SPRITEMOVEDATA_SPINCOUNTERCLOCKWISE, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 0, TrainerKimonoGirlNaoko, EVENT_QUELLED_WILD_HUNT
	object_event  2,  1, SPRITE_KIMONO_GIRL, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_PURPLE, OBJECTTYPE_TRAINER, 0, TrainerKimonoGirlSayo, EVENT_QUELLED_WILD_HUNT
	object_event  6,  2, SPRITE_KIMONO_GIRL, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, PAL_NPC_BLACK, OBJECTTYPE_TRAINER, 0, TrainerKimonoGirlZuki, EVENT_QUELLED_WILD_HUNT
	object_event  9,  1, SPRITE_KIMONO_GIRL, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 0, TrainerKimonoGirlKuni, EVENT_QUELLED_WILD_HUNT
	object_event 11,  2, SPRITE_KIMONO_GIRL, SPRITEMOVEDATA_SPINCLOCKWISE, 0, 0, -1, -1, PAL_NPC_YELLOW, OBJECTTYPE_TRAINER, 0, TrainerKimonoGirlMiki, EVENT_QUELLED_WILD_HUNT
	object_event  7, 10, SPRITE_GENTLEMAN, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, DanceTheaterRockSmashGuy, -1
	object_event  6,  8, SPRITE_RHYDON, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, PAL_NPC_GRAY, OBJECTTYPE_SCRIPT, 0, DanceTheaterRhydon, -1
	object_event 10, 10, SPRITE_COOLTRAINER_M, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, DanceTheaterCooltrainerMScript, -1
	object_event  3,  6, SPRITE_GRANNY, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, DanceTheaterGrannyScript, -1

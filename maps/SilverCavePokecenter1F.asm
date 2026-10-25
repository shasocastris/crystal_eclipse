	object_const_def
	const SILVERCAVEPOKECENTER1F_NURSE
	const SILVERCAVEPOKECENTER1F_GRANNY
	const SILVERCAVEPOKECENTER1F_COACH

DEF SILVERCAVEPOKECENTER1F_COACH_FEE EQU STAR_PIECE ; also named in the coach's text

SilverCavePokecenter1F_MapScripts:
	def_scene_scripts

	def_callbacks

SilverCavePokecenter1FNurseScript:
	jumpstd PokecenterNurseScript

SilverCavePokecenter1FGrannyScript:
	jumptextfaceplayer SilverCavePokecenter1FGrannyText

SilverCavePokecenter1FCoachScript:
	faceplayer
	opentext
	checkflag ENGINE_PERFECT_MON_COACH
	iftrue .DoneToday
	writetext SilverCavePokecenter1FCoachIntroText
	yesorno
	iffalse .Refused
	checkitem SILVERCAVEPOKECENTER1F_COACH_FEE
	iffalse .NoFee
	writetext SilverCavePokecenter1FCoachWhichMonText
	promptbutton
	special PerfectMonSelect
	ifequal PERFECTMON_CANCEL, .Refused
	ifequal PERFECTMON_EGG, .Egg
	ifequal PERFECTMON_UNOWN, .Unown
	ifequal PERFECTMON_ALREADY, .AlreadyPerfect
	writetext SilverCavePokecenter1FCoachConfirmText
	yesorno
	iffalse .Refused
	takeitem SILVERCAVEPOKECENTER1F_COACH_FEE
	special PerfectMonApply
	setflag ENGINE_PERFECT_MON_COACH
	writetext SilverCavePokecenter1FCoachTrainText
	waitbutton
	closetext
	special FadeOutToWhite
	special LoadMapPalettes
	playmusic MUSIC_HEAL
	pause 60
	special FadeInPalettes_EnableDynNoApply
	special RestartMapMusic
	opentext
	writetext SilverCavePokecenter1FCoachDoneText
	waitbutton
	closetext
	end

.DoneToday:
	writetext SilverCavePokecenter1FCoachDoneTodayText
	waitbutton
	closetext
	end

.NoFee:
	writetext SilverCavePokecenter1FCoachNoFeeText
	waitbutton
	closetext
	end

.Egg:
	writetext SilverCavePokecenter1FCoachEggText
	waitbutton
	closetext
	end

.Unown:
	writetext SilverCavePokecenter1FCoachUnownText
	waitbutton
	closetext
	end

.AlreadyPerfect:
	writetext SilverCavePokecenter1FCoachAlreadyPerfectText
	waitbutton
	closetext
	end

.Refused:
	writetext SilverCavePokecenter1FCoachRefusedText
	waitbutton
	closetext
	end

SilverCavePokecenter1FGrannyText:
	text "Trainers who seek"
	line "power climb MT."

	para "SILVER despite its"
	line "many dangers…"

	para "With their trusted"
	line "#MON, they must"

	para "feel they can go"
	line "anywhere…"
	done

SilverCavePokecenter1FCoachIntroText:
	text "I coach #MON to"
	line "their full power."

	para "For a STAR PIECE,"
	line "I'll train one to"
	cont "perfection."

	para "Shall I?"
	done

SilverCavePokecenter1FCoachWhichMonText:
	text "Which #MON"
	line "should I train?"
	done

SilverCavePokecenter1FCoachConfirmText:
	text "I'll train"
	line "@"
	text_ram wStringBuffer3
	text "."

	para "Hand over a STAR"
	line "PIECE?"
	done

SilverCavePokecenter1FCoachTrainText:
	text "Right! Let's go!"
	done

SilverCavePokecenter1FCoachDoneText:
	text_ram wStringBuffer3
	text " is"
	line "at its peak now!"

	para "Its looks and"
	line "gender are just"
	cont "as they were."
	done

SilverCavePokecenter1FCoachDoneTodayText:
	text "That's enough"
	line "training for one"
	cont "day."

	para "Come back"
	line "tomorrow."
	done

SilverCavePokecenter1FCoachNoFeeText:
	text "You don't have a"
	line "STAR PIECE."

	para "Come back when"
	line "you find one."
	done

SilverCavePokecenter1FCoachEggText:
	text "An EGG? Come back"
	line "once it hatches."
	done

SilverCavePokecenter1FCoachUnownText:
	text "UNOWN's power is"
	line "a mystery even to"
	cont "me."
	done

SilverCavePokecenter1FCoachAlreadyPerfectText:
	text_ram wStringBuffer3
	text " is"
	line "already perfect!"
	done

SilverCavePokecenter1FCoachRefusedText:
	text "Come back anytime."
	done

SilverCavePokecenter1F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  3,  7, SILVER_CAVE_OUTSIDE, 1
	warp_event  4,  7, SILVER_CAVE_OUTSIDE, 1
	warp_event  0,  7, POKECENTER_2F, 1

	def_coord_events

	def_bg_events

	def_object_events
	object_event  3,  1, SPRITE_NURSE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SilverCavePokecenter1FNurseScript, -1
	object_event  1,  5, SPRITE_GRANNY, SPRITEMOVEDATA_STANDING_LEFT, 2, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SilverCavePokecenter1FGrannyScript, -1
	object_event  7,  2, SPRITE_COOLTRAINER_M, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SilverCavePokecenter1FCoachScript, -1

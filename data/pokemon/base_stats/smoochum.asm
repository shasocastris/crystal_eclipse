	db 0 ; species ID placeholder

	db  45,  30,  15,  65,  85,  65
	evs  0,   0,   0,   0,   1,   0
	;   hp  atk  def  spd  sat  sdf

	db ICE, PSYCHIC_TYPE ; type
	db 15 ; catch rate
	db 87 ; base exp
	dw ICE_BERRY, ICE_BERRY ; items
	db GENDER_F100 ; gender ratio
	INCBIN "gfx/pokemon/smoochum/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, CURSE, TOXIC, PSYCH_UP, HIDDEN_POWER, SWEET_SCENT, BLIZZARD, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, RETURN, PSYCHIC_M, SHADOW_BALL, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, DREAM_EATER, REST, ATTRACT, THIEF, ICE_BEAM, TELEPORT, SEISMIC_TOSS, COUNTER, REFLECT, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH
	; end

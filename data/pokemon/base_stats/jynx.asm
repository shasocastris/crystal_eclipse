	db 0 ; species ID placeholder

	db  65,  50,  35,  95, 115,  95
	evs  0,   0,   0,   0,   2,   0
	;   hp  atk  def  spd  sat  sdf

	db ICE, PSYCHIC_TYPE ; type
	db 15 ; catch rate
	db 137 ; base exp
	dw ICE_BERRY, ICE_BERRY ; items
	db GENDER_F100 ; gender ratio
	INCBIN "gfx/pokemon/jynx/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, TOXIC, PSYCH_UP, HIDDEN_POWER, SWEET_SCENT, BLIZZARD, HYPER_BEAM, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, RETURN, PSYCHIC_M, SHADOW_BALL, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, DREAM_EATER, REST, ATTRACT, THIEF, ICE_BEAM, TELEPORT, SEISMIC_TOSS, COUNTER, REFLECT, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH
	; end

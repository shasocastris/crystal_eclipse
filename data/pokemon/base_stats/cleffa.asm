	db 0 ; species ID placeholder

	db  50,  25,  28,  15,  45,  55
	evs  0,   0,   0,   0,   0,   1
	;   hp  atk  def  spd  sat  sdf

	db FAIRY, FAIRY ; type
	db 50 ; catch rate
	db 37 ; base exp
	dw MYSTERYBERRY, MOON_STONE ; items
	db GENDER_F75 ; gender ratio
	INCBIN "gfx/pokemon/cleffa/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, TOXIC, ZAP_CANNON, PSYCH_UP, HIDDEN_POWER, SUNNY_DAY, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, SOLARBEAM, IRON_TAIL, RETURN, PSYCHIC_M, SHADOW_BALL, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, FIRE_BLAST, DREAM_EATER, DETECT, REST, ATTRACT, FLASH, FLAMETHROWER, NOURISHMENT, SEISMIC_TOSS, COUNTER, REFLECT, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH
	; end

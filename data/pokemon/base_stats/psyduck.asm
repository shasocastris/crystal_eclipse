	db 0 ; species ID placeholder

	db  50,  52,  48,  55,  65,  50
	evs  0,   0,   0,   0,   1,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, WATER ; type
	db 63 ; catch rate
	db 80 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/psyduck/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, TOXIC, PSYCH_UP, HIDDEN_POWER, BLIZZARD, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, IRON_TAIL, RETURN, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, SWIFT, REST, ATTRACT, FLASH, ROCK_SMASH, ICE_BEAM, SEISMIC_TOSS, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, MEGA_KICK
	; end

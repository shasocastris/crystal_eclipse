	db 0 ; species ID placeholder

	db  65,  83,  57, 105,  95,  85
	evs  0,   0,   0,   2,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db ELECTRIC, ELECTRIC ; type
	db 15 ; catch rate
	db 156 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F25 ; gender ratio
	INCBIN "gfx/pokemon/electabuzz/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, TOXIC, ZAP_CANNON, HIDDEN_POWER, HYPER_BEAM, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, IRON_TAIL, THUNDER, RETURN, PSYCHIC_M, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, SWIFT, THUNDERPUNCH, DETECT, REST, ATTRACT, THIEF, FIRE_PUNCH, STRENGTH, FLASH, ROCK_SMASH, THUNDERBOLT, SEISMIC_TOSS, COUNTER, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH
	; end

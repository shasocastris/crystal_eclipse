	db 0 ; species ID placeholder

	db  70,  80,  65,  85,  90,  65
	evs  0,   0,   0,   0,   2,   0
	;   hp  atk  def  spd  sat  sdf

	db PSYCHIC_TYPE, DARK ; type
	db 20 ; catch rate
	db 149 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/girafarig/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, ZAP_CANNON, PSYCH_UP, HIDDEN_POWER, SUNNY_DAY, CRUNCH, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, THUNDER, EARTHQUAKE, RETURN, PSYCHIC_M, SHADOW_BALL, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, DREAM_EATER, REST, ATTRACT, THIEF, STRENGTH, ROCK_SMASH, THUNDERBOLT, TELEPORT, SEISMIC_TOSS, REFLECT, BODY_SLAM, SUBSTITUTE
	; end

	db 0 ; species ID placeholder

	db  60,  65,  60, 110, 130,  75
	evs  0,   0,   0,   0,   3,   0
	;   hp  atk  def  spd  sat  sdf

	db GHOST, DARK ; type
	db 15 ; catch rate
	db 190 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/gengar/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, TOXIC, ZAP_CANNON, PURSUIT, PSYCH_UP, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, RAIN_DANCE, GIGA_DRAIN, ENDURE, PAIN_SPLIT, THUNDER, RETURN, PSYCHIC_M, SHADOW_BALL, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, THUNDERPUNCH, DREAM_EATER, REST, ATTRACT, THIEF, FIRE_PUNCH, SHADOW_CLAW, STRENGTH, ROCK_SMASH, THUNDERBOLT, TELEPORT, SUBSTITUTE, POISON_JAB
	; end

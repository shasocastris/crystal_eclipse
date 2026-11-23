	db 0 ; species ID placeholder

	db  30,  35,  30,  80, 100,  35
	evs  0,   0,   0,   0,   1,   0
	;   hp  atk  def  spd  sat  sdf

	db GHOST, GHOST ; type
	db 63 ; catch rate
	db 95 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/gastly/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, ZAP_CANNON, PSYCH_UP, HIDDEN_POWER, SUNNY_DAY, PROTECT, RAIN_DANCE, GIGA_DRAIN, ENDURE, PAIN_SPLIT, THUNDER, RETURN, PSYCHIC_M, SHADOW_BALL, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, DREAM_EATER, REST, ATTRACT, THIEF, SHADOW_CLAW, THUNDERBOLT, TELEPORT, SUBSTITUTE, POISON_JAB
	; end

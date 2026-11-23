	db 0 ; species ID placeholder

	db  85,  80,  70,  90, 135,  75
	evs  0,   0,   0,   0,   3,   0
	;   hp  atk  def  spd  sat  sdf

	db NORMAL, NORMAL ; type
	db 30 ; catch rate
	db 241 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_UNKNOWN ; gender ratio
	INCBIN "gfx/pokemon/porygon_z/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, ZAP_CANNON, PSYCH_UP, HIDDEN_POWER, SUNNY_DAY, BLIZZARD, HYPER_BEAM, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, SOLARBEAM, THUNDER, RETURN, PSYCHIC_M, SHADOW_BALL, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, FIRE_BLAST, SWIFT, DREAM_EATER, DETECT, REST, ATTRACT, FLASH, FLAMETHROWER, THUNDERBOLT, ICE_BEAM, SUBSTITUTE
	; end

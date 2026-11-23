	db 0 ; species ID placeholder

	db  40,  45,  65,  90, 100, 120
	evs  0,   0,   0,   0,   0,   2
	;   hp  atk  def  spd  sat  sdf

	db PSYCHIC_TYPE, FAIRY ; type
	db 15 ; catch rate
	db 136 ; base exp
	dw NO_ITEM, MYSTERYBERRY ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/mr__mime/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, TOXIC, ZAP_CANNON, PSYCH_UP, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, SOLARBEAM, THUNDER, RETURN, PSYCHIC_M, SHADOW_BALL, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, THUNDERPUNCH, DREAM_EATER, REST, ATTRACT, THIEF, FIRE_PUNCH, FLASH, THUNDERBOLT, TELEPORT, SEISMIC_TOSS, REFLECT, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH
	; end

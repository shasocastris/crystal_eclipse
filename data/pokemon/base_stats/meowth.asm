	db 0 ; species ID placeholder

	db  40,  45,  35,  90,  40,  40
	evs  0,   0,   0,   1,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db NORMAL, NORMAL ; type
	db 85 ; catch rate
	db 69 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/meowth/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, ZAP_CANNON, PURSUIT, PSYCH_UP, HIDDEN_POWER, SUNNY_DAY, CRUNCH, ICY_WIND, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, THUNDER, RETURN, SHADOW_BALL, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, DREAM_EATER, DETECT, REST, ATTRACT, THIEF, SHADOW_CLAW, THUNDERBOLT, SEISMIC_TOSS, REFLECT, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, SWORDS_DANCE
	; end

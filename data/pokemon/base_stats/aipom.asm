	db 0 ; species ID placeholder

	db  55,  70,  55,  85,  40,  55
	evs  0,   0,   0,   1,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db NORMAL, NORMAL ; type
	db 15 ; catch rate
	db 94 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/aipom/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, TOXIC, ZAP_CANNON, PURSUIT, HIDDEN_POWER, SUNNY_DAY, SWEET_KISS, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, THUNDER, RETURN, SHADOW_BALL, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, SWIFT, DEFENSE_CURL, THUNDERPUNCH, DREAM_EATER, DETECT, REST, ATTRACT, THIEF, FIRE_PUNCH, FURY_CUTTER, NIGHTMARE, CUT, ROCK_SMASH, THUNDERBOLT, PAY_DAY, SEISMIC_TOSS, MIMIC, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, SWORDS_DANCE
	; end

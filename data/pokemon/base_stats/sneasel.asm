	db 0 ; species ID placeholder

	db  55,  95,  55, 115,  35,  75
	evs  0,   0,   0,   1,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db DARK, ICE ; type
	db 20 ; catch rate
	db 132 ; base exp
	dw NO_ITEM, QUICK_CLAW ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/sneasel/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, TOXIC, PURSUIT, PSYCH_UP, HIDDEN_POWER, CRUNCH, BLIZZARD, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, IRON_TAIL, RETURN, DIG, SHADOW_BALL, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, SWIFT, DREAM_EATER, DETECT, REST, ATTRACT, THIEF, FURY_CUTTER, SHADOW_CLAW, CUT, ROCK_SMASH, ICE_BEAM, SUBSTITUTE, SWORDS_DANCE, X_SCISSOR, POISON_JAB, ICICLE_CRASH
	; end

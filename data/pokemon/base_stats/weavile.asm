	db 0 ; species ID placeholder

	db  70, 120,  65, 125,  45,  85
	evs  0,   2,   0,   1,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db DARK, ICE ; type
	db 45 ; catch rate
	db 179 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/weavile/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, PSYCH_UP, HIDDEN_POWER, CRUNCH, BLIZZARD, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, RETURN, SHADOW_BALL, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, DETECT, REST, ATTRACT, THIEF, SHADOW_CLAW, ROCK_SMASH, SUBSTITUTE, X_SCISSOR, POISON_JAB, ICICLE_CRASH
	; end

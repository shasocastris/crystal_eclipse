	db 0 ; species ID placeholder

	db  75,  95, 125,  95,  45,  75
	evs  0,   0,   3,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db GROUND, FLYING ; type
	db 30 ; catch rate
	db 192 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/gliscor/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, PSYCH_UP, HIDDEN_POWER, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, DIG, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, ROCK_SLIDE, DETECT, REST, ATTRACT, THIEF, SHADOW_CLAW, ROCK_SMASH, SUBSTITUTE, X_SCISSOR, POISON_JAB
	; end

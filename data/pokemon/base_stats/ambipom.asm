	db 0 ; species ID placeholder

	db  75, 100,  66, 115,  60,  66
	evs  0,   0,   0,   2,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db NORMAL, NORMAL ; type
	db 45 ; catch rate
	db 169 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/ambipom/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, PSYCH_UP, HIDDEN_POWER, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, RETURN, SHADOW_BALL, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, DETECT, REST, ATTRACT, THIEF, SHADOW_CLAW, SUBSTITUTE, SEED_BOMB
	; end

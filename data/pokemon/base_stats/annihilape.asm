	db 0 ; species ID placeholder

	db 110, 115,  80,  90,  50,  80
	evs  0,   3,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db FIGHTING, GHOST ; type
	db 45 ; catch rate
	db 200 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/annihilape/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, PSYCH_UP, HIDDEN_POWER, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, RETURN, SHADOW_BALL, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, ROCK_SLIDE, DETECT, REST, ATTRACT, SHADOW_CLAW, ROCK_SMASH, SEISMIC_TOSS, COUNTER, BODY_SLAM, SUBSTITUTE
	; end

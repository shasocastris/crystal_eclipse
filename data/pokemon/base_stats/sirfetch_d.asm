	db 0 ; species ID placeholder

	db  62, 135,  95,  65,  68,  82
	evs  0,   3,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db FIGHTING, FIGHTING ; type
	db 45 ; catch rate
	db 177 ; base exp
	dw STICK, STICK ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/sirfetch_d/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, PSYCH_UP, HIDDEN_POWER, SWEET_KISS, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, PROTECT, REST, ATTRACT, STEEL_WING, SHADOW_BALL, SUBSTITUTE, ROCK_SMASH, COUNTER, SEISMIC_TOSS, BODY_SLAM
	; end

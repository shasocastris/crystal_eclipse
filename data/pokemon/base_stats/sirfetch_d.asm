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
	tmhm HEADBUTT, CURSE, TOXIC, PSYCH_UP, HIDDEN_POWER, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, RETURN, SHADOW_BALL, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, DETECT, REST, ATTRACT, STEEL_WING, ROCK_SMASH, SEISMIC_TOSS, COUNTER, BODY_SLAM, SUBSTITUTE
	; end

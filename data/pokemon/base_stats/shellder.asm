	db 0 ; species ID placeholder

	db  30,  65, 100,  40,  45,  25
	evs  0,   0,   1,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, WATER ; type
	db 63 ; catch rate
	db 97 ; base exp
	dw PEARL, BIG_PEARL ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/shellder/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, HIDDEN_POWER, BLIZZARD, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, REST, ATTRACT, ICE_BEAM, SUBSTITUTE
	; end

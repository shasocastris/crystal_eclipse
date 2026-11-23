	db 0 ; species ID placeholder

	db  40,  50,  40,  90,  40,  40
	evs  0,   0,   0,   1,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, WATER ; type
	db 85 ; catch rate
	db 77 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/poliwag/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, BLIZZARD, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, RETURN, PSYCHIC_M, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, REST, ATTRACT, THIEF, ICE_BEAM, BODY_SLAM, SUBSTITUTE
	; end

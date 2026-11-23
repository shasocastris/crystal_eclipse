	db 0 ; species ID placeholder

	db  35,  40, 100,  35,  90,  55
	evs  0,   0,   1,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db ROCK, WATER ; type
	db 15 ; catch rate
	db 120 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F12_5 ; gender ratio
	INCBIN "gfx/pokemon/omanyte/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, TOXIC, HIDDEN_POWER, BLIZZARD, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, ROCK_SLIDE, REST, ATTRACT, THIEF, ROCK_SMASH, ICE_BEAM, SUBSTITUTE
	; end

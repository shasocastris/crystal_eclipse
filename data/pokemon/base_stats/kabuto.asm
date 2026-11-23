	db 0 ; species ID placeholder

	db  30,  80,  90,  55,  55,  45
	evs  0,   0,   1,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db ROCK, WATER ; type
	db 15 ; catch rate
	db 119 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F12_5 ; gender ratio
	INCBIN "gfx/pokemon/kabuto/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm CURSE, ROLLOUT, TOXIC, HIDDEN_POWER, BLIZZARD, ICY_WIND, PROTECT, RAIN_DANCE, GIGA_DRAIN, ENDURE, PAIN_SPLIT, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, ROCK_SLIDE, REST, ATTRACT, THIEF, ROCK_SMASH, ICE_BEAM, SUBSTITUTE, X_SCISSOR
	; end

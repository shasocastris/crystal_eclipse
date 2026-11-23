	db 0 ; species ID placeholder

	db  60, 115, 105,  80,  65,  70
	evs  0,   2,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db ROCK, WATER ; type
	db 15 ; catch rate
	db 201 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F12_5 ; gender ratio
	INCBIN "gfx/pokemon/kabutops/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, TOXIC, HIDDEN_POWER, BLIZZARD, HYPER_BEAM, ICY_WIND, PROTECT, RAIN_DANCE, GIGA_DRAIN, ENDURE, PAIN_SPLIT, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, ROCK_SLIDE, REST, ATTRACT, THIEF, FURY_CUTTER, CUT, SURF, WHIRLPOOL, ROCK_SMASH, ICE_BEAM, SUBSTITUTE, X_SCISSOR
	; end

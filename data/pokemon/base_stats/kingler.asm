	db 0 ; species ID placeholder

	db  55, 130, 115,  75,  50,  50
	evs  0,   2,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, WATER ; type
	db 20 ; catch rate
	db 206 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/kingler/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, HIDDEN_POWER, CRUNCH, BLIZZARD, HYPER_BEAM, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, REST, ATTRACT, THIEF, FURY_CUTTER, CUT, SURF, STRENGTH, WHIRLPOOL, ROCK_SMASH, ICE_BEAM, SUBSTITUTE, X_SCISSOR, ICICLE_CRASH
	; end

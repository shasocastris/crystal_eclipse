	db 0 ; species ID placeholder

	db  50,  95, 180,  70,  85,  45
	evs  0,   0,   2,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, ICE ; type
	db 20 ; catch rate
	db 203 ; base exp
	dw PEARL, BIG_PEARL ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/cloyster/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, HIDDEN_POWER, BLIZZARD, HYPER_BEAM, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, REST, ATTRACT, SURF, WHIRLPOOL, ICE_BEAM, SUBSTITUTE, ICICLE_CRASH
	; end

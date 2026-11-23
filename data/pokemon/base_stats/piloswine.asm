	db 0 ; species ID placeholder

	db 100, 100,  80,  50,  60,  60
	evs  1,   1,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db ICE, GROUND ; type
	db 25 ; catch rate
	db 160 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/piloswine/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROAR, TOXIC, HIDDEN_POWER, CRUNCH, BLIZZARD, HYPER_BEAM, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, ROCK_SLIDE, DETECT, REST, ATTRACT, STRENGTH, ROCK_SMASH, ICE_BEAM, SUBSTITUTE, ICICLE_CRASH
	; end

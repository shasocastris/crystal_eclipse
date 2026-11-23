	db 0 ; species ID placeholder

	db  50,  50,  40,  50,  30,  30
	evs  0,   1,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db ICE, GROUND ; type
	db 75 ; catch rate
	db 78 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/swinub/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROAR, TOXIC, HIDDEN_POWER, CRUNCH, BLIZZARD, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, ROCK_SLIDE, DETECT, REST, ATTRACT, ROCK_SMASH, ICE_BEAM, SUBSTITUTE, ICICLE_CRASH
	; end

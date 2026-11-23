	db 0 ; species ID placeholder

	db  90,  85, 100,  85,  95, 125
	evs  0,   0,   0,   0,   0,   3
	;   hp  atk  def  spd  sat  sdf

	db ICE, FLYING ; type
	db 3 ; catch rate
	db 215 ; base exp
	dw MIRACLEBERRY, MIRACLEBERRY ; items
	db GENDER_UNKNOWN ; gender ratio
	INCBIN "gfx/pokemon/articuno/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm CURSE, ROAR, TOXIC, HIDDEN_POWER, SUNNY_DAY, BLIZZARD, HYPER_BEAM, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, SWIFT, DETECT, REST, STEEL_WING, FLY, ROCK_SMASH, ICE_BEAM, SUBSTITUTE
	; end

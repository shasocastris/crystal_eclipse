	db 0 ; species ID placeholder

	db  90,  85,  95,  70,  70,  90
	evs  0,   0,   3,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, FIGHTING ; type
	db 15 ; catch rate
	db 185 ; base exp
	dw NO_ITEM, KINGS_ROCK ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/poliwrath/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, BLIZZARD, HYPER_BEAM, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, PSYCHIC_M, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, DETECT, REST, ATTRACT, THIEF, SURF, STRENGTH, WHIRLPOOL, WATERFALL, ROCK_SMASH, ICE_BEAM, SEISMIC_TOSS, COUNTER, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, DOUBLE_EDGE, MEGA_KICK
	; end

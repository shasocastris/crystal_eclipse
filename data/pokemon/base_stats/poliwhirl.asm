	db 0 ; species ID placeholder

	db  65,  65,  65,  90,  50,  50
	evs  0,   0,   0,   2,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, WATER ; type
	db 40 ; catch rate
	db 131 ; base exp
	dw NO_ITEM, KINGS_ROCK ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/poliwhirl/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, BLIZZARD, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, PSYCHIC_M, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, DETECT, REST, ATTRACT, THIEF, ROCK_SMASH, ICE_BEAM, SEISMIC_TOSS, COUNTER, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, MEGA_KICK
	; end

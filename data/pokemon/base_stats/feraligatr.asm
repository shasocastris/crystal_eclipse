	db 0 ; species ID placeholder

	db  85, 105, 100,  78,  79,  83
	evs  0,   2,   1,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, WATER ; type
	db 15 ; catch rate
	db 210 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F12_5 ; gender ratio
	INCBIN "gfx/pokemon/feraligatr/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, ROAR, TOXIC, HIDDEN_POWER, CRUNCH, BLIZZARD, HYPER_BEAM, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, IRON_TAIL, EARTHQUAKE, RETURN, DIG, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, ROCK_SLIDE, DETECT, REST, ATTRACT, FURY_CUTTER, SHADOW_CLAW, CUT, SURF, STRENGTH, WHIRLPOOL, ROCK_SMASH, ICE_BEAM, SEISMIC_TOSS, COUNTER, REFLECT, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, SWORDS_DANCE, DOUBLE_EDGE, MEGA_KICK, ICICLE_CRASH
	; end

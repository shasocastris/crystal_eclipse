	db 0 ; species ID placeholder

	db  50,  65,  64,  43,  44,  48
	evs  0,   1,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, WATER ; type
	db 15 ; catch rate
	db 66 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F12_5 ; gender ratio
	INCBIN "gfx/pokemon/totodile/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, CRUNCH, BLIZZARD, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, IRON_TAIL, RETURN, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, ROCK_SLIDE, DETECT, REST, ATTRACT, SHADOW_CLAW, CUT, ICE_BEAM, SEISMIC_TOSS, COUNTER, REFLECT, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, SWORDS_DANCE, DOUBLE_EDGE, MEGA_KICK, ICICLE_CRASH
	; end

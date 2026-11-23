	db 0 ; species ID placeholder

	db  95, 125,  79,  81,  60, 100
	evs  0,   2,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, FLYING ; type
	db 15 ; catch rate
	db 214 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/gyarados/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROAR, TOXIC, ZAP_CANNON, HIDDEN_POWER, CRUNCH, BLIZZARD, HYPER_BEAM, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, DRAGONBREATH, THUNDER, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, FIRE_BLAST, REST, ATTRACT, SURF, STRENGTH, WHIRLPOOL, WATERFALL, ROCK_SMASH, FLAMETHROWER, THUNDERBOLT, ICE_BEAM, SEISMIC_TOSS, BODY_SLAM, SUBSTITUTE, SWORDS_DANCE, DOUBLE_EDGE, ICICLE_CRASH
	; end

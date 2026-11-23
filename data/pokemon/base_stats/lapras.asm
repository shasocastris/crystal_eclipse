	db 0 ; species ID placeholder

	db 130,  85,  80,  60,  85,  95
	evs  2,   0,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, ICE ; type
	db 15 ; catch rate
	db 219 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/lapras/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, ZAP_CANNON, HIDDEN_POWER, BLIZZARD, HYPER_BEAM, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, IRON_TAIL, DRAGONBREATH, THUNDER, RETURN, PSYCHIC_M, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, DREAM_EATER, REST, ATTRACT, SURF, STRENGTH, WHIRLPOOL, ROCK_SMASH, THUNDERBOLT, ICE_BEAM, SEISMIC_TOSS, REFLECT, BODY_SLAM, SUBSTITUTE, SWORDS_DANCE, DOUBLE_EDGE, ICICLE_CRASH
	; end

	db 0 ; species ID placeholder

	db 100,  50,  80,  50,  50,  80
	evs  3,   0,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, FAIRY ; type
	db 25 ; catch rate
	db 153 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/azumarill/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, ROLLOUT, TOXIC, HIDDEN_POWER, BLIZZARD, HYPER_BEAM, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, IRON_TAIL, RETURN, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, SWIFT, REST, ATTRACT, SURF, STRENGTH, WHIRLPOOL, WATERFALL, ROCK_SMASH, ICE_BEAM, SEISMIC_TOSS, COUNTER, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH
	; end

	db 0 ; species ID placeholder

	db  90, 110,  80,  95, 100,  80
	evs  0,   2,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db FIRE, FIRE ; type
	db 25 ; catch rate
	db 213 ; base exp
	dw BURNT_BERRY, BURNT_BERRY ; items
	db GENDER_F25 ; gender ratio
	INCBIN "gfx/pokemon/arcanine/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROAR, TOXIC, PURSUIT, HIDDEN_POWER, SUNNY_DAY, CRUNCH, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, DRAGONBREATH, RETURN, DIG, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, FIRE_BLAST, SWIFT, REST, ATTRACT, ROCK_SMASH, FLAMETHROWER, SEISMIC_TOSS, COUNTER, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, DOUBLE_EDGE
	; end

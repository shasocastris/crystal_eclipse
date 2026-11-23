	db 0 ; species ID placeholder

	db  80, 110, 130,  45,  55,  65
	evs  0,   0,   3,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db ROCK, GROUND ; type
	db 15 ; catch rate
	db 177 ; base exp
	dw NO_ITEM, MIST_STONE ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/golem/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, ROLLOUT, ROAR, TOXIC, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, DIG, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, FIRE_BLAST, ROCK_SLIDE, REST, ATTRACT, FIRE_PUNCH, FURY_CUTTER, STRENGTH, ROCK_SMASH, FLAMETHROWER, SEISMIC_TOSS, BODY_SLAM, SUBSTITUTE, DOUBLE_EDGE
	; end

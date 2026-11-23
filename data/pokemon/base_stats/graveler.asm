	db 0 ; species ID placeholder

	db  55,  95, 115,  35,  45,  45
	evs  0,   0,   2,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db ROCK, GROUND ; type
	db 40 ; catch rate
	db 134 ; base exp
	dw NO_ITEM, MIST_STONE ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/graveler/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, ROLLOUT, TOXIC, HIDDEN_POWER, SUNNY_DAY, PROTECT, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, FIRE_BLAST, ROCK_SLIDE, REST, ATTRACT, FIRE_PUNCH, ROCK_SMASH, FLAMETHROWER, SEISMIC_TOSS, BODY_SLAM, SUBSTITUTE, DOUBLE_EDGE
	; end

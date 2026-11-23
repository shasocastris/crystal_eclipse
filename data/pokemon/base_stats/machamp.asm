	db 0 ; species ID placeholder

	db  90, 130,  80,  55,  65,  85
	evs  0,   3,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db FIGHTING, FIGHTING ; type
	db 15 ; catch rate
	db 193 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F25 ; gender ratio
	INCBIN "gfx/pokemon/machamp/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, TOXIC, PURSUIT, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, DIG, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, FIRE_BLAST, ROCK_SLIDE, THUNDERPUNCH, DETECT, REST, ATTRACT, THIEF, FIRE_PUNCH, STRENGTH, ROCK_SMASH, FLAMETHROWER, SEISMIC_TOSS, COUNTER, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, DOUBLE_EDGE, MEGA_KICK, POISON_JAB
	; end

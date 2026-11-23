	db 0 ; species ID placeholder

	db  70,  80,  50,  35,  35,  35
	evs  0,   1,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db FIGHTING, FIGHTING ; type
	db 60 ; catch rate
	db 88 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F25 ; gender ratio
	INCBIN "gfx/pokemon/machop/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, TOXIC, PURSUIT, HIDDEN_POWER, SUNNY_DAY, PROTECT, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, FIRE_BLAST, ROCK_SLIDE, THUNDERPUNCH, DETECT, REST, ATTRACT, THIEF, FIRE_PUNCH, ROCK_SMASH, FLAMETHROWER, SEISMIC_TOSS, COUNTER, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, MEGA_KICK, POISON_JAB
	; end

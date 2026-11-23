	db 0 ; species ID placeholder

	db  60,  80, 110,  45,  50,  80
	evs  0,   0,   2,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db GROUND, GROUND ; type
	db 25 ; catch rate
	db 124 ; base exp
	dw THICK_CLUB, THICK_CLUB ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/marowak/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, BLIZZARD, HYPER_BEAM, ICY_WIND, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, EARTHQUAKE, RETURN, DIG, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, FIRE_BLAST, ROCK_SLIDE, THUNDERPUNCH, DETECT, REST, ATTRACT, THIEF, FIRE_PUNCH, STRENGTH, ROCK_SMASH, FLAMETHROWER, ICE_BEAM, COUNTER, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, SWORDS_DANCE, MEGA_KICK
	; end

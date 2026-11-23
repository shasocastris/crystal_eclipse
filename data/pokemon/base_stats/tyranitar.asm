	db 0 ; species ID placeholder

	db 100, 134, 110,  61,  95, 100
	evs  0,   3,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db ROCK, DARK ; type
	db 15 ; catch rate
	db 218 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/tyranitar/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, ROAR, TOXIC, PURSUIT, HIDDEN_POWER, SUNNY_DAY, CRUNCH, HYPER_BEAM, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, IRON_TAIL, DRAGONBREATH, EARTHQUAKE, RETURN, DIG, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, FIRE_BLAST, ROCK_SLIDE, DETECT, REST, ATTRACT, FIRE_PUNCH, FURY_CUTTER, SHADOW_CLAW, CUT, SURF, STRENGTH, ROCK_SMASH, FLAMETHROWER, THUNDERBOLT, ICE_BEAM, BODY_SLAM, SUBSTITUTE, SWORDS_DANCE, DOUBLE_EDGE
	; end

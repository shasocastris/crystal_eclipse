	db 0 ; species ID placeholder

	db  78,  84,  78, 100, 109,  85
	evs  0,   0,   0,   0,   3,   0
	;   hp  atk  def  spd  sat  sdf

	db FIRE, FLYING ; type
	db 15 ; catch rate
	db 209 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F12_5 ; gender ratio
	INCBIN "gfx/pokemon/charizard/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, ROAR, TOXIC, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, DRAGONBREATH, EARTHQUAKE, RETURN, DIG, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, FIRE_BLAST, SWIFT, ROCK_SLIDE, REST, ATTRACT, STEEL_WING, FIRE_PUNCH, FURY_CUTTER, SHADOW_CLAW, CUT, FLY, STRENGTH, ROCK_SMASH, FLAMETHROWER, SEISMIC_TOSS, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, SWORDS_DANCE, DOUBLE_EDGE, MEGA_KICK
	; end

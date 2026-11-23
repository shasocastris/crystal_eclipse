	db 0 ; species ID placeholder

	db  39,  52,  43,  65,  60,  50
	evs  0,   0,   0,   1,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db FIRE, FIRE ; type
	db 15 ; catch rate
	db 65 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F12_5 ; gender ratio
	INCBIN "gfx/pokemon/charmander/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, DRAGONBREATH, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, FIRE_BLAST, SWIFT, ROCK_SLIDE, REST, ATTRACT, FIRE_PUNCH, FURY_CUTTER, SHADOW_CLAW, CUT, ROCK_SMASH, FLAMETHROWER, SEISMIC_TOSS, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, SWORDS_DANCE, DOUBLE_EDGE, MEGA_KICK
	; end

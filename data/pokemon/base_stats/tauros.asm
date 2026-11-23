	db 0 ; species ID placeholder

	db  75, 100,  95, 110,  40,  70
	evs  0,   1,   0,   1,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db NORMAL, NORMAL ; type
	db 15 ; catch rate
	db 211 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F0 ; gender ratio
	INCBIN "gfx/pokemon/tauros/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, ZAP_CANNON, PURSUIT, HIDDEN_POWER, SUNNY_DAY, CRUNCH, BLIZZARD, HYPER_BEAM, ICY_WIND, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, THUNDER, EARTHQUAKE, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, FIRE_BLAST, ROCK_SLIDE, REST, ATTRACT, SURF, STRENGTH, ROCK_SMASH, FLAMETHROWER, THUNDERBOLT, ICE_BEAM, BODY_SLAM, SUBSTITUTE, SWORDS_DANCE, DOUBLE_EDGE, MEGA_KICK
	; end

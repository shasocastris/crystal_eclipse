	db 0 ; species ID placeholder

	db  80,  85,  95,  25,  30,  30
	evs  0,   0,   1,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db GROUND, ROCK ; type
	db 40 ; catch rate
	db 135 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/rhyhorn/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, ROAR, TOXIC, ZAP_CANNON, HIDDEN_POWER, SUNNY_DAY, CRUNCH, BLIZZARD, ICY_WIND, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, THUNDER, EARTHQUAKE, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, FIRE_BLAST, ROCK_SLIDE, REST, ATTRACT, SHADOW_CLAW, ROCK_SMASH, FLAMETHROWER, THUNDERBOLT, ICE_BEAM, SEISMIC_TOSS, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, DOUBLE_EDGE, MEGA_KICK
	; end

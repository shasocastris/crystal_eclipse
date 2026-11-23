	db 0 ; species ID placeholder

	db  60,  80,  50,  40,  50,  50
	evs  0,   1,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db NORMAL, NORMAL ; type
	db 40 ; catch rate
	db 124 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/teddiursa/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, ROLLOUT, ROAR, TOXIC, ZAP_CANNON, PURSUIT, HIDDEN_POWER, SUNNY_DAY, CRUNCH, PROTECT, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, SWIFT, ROCK_SLIDE, THUNDERPUNCH, REST, ATTRACT, THIEF, FIRE_PUNCH, FURY_CUTTER, SHADOW_CLAW, CUT, ROCK_SMASH, SEISMIC_TOSS, COUNTER, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, SWORDS_DANCE, DOUBLE_EDGE, MEGA_KICK
	; end

	db 0 ; species ID placeholder

	db  90, 120,  75,  45,  60,  60
	evs  0,   2,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db FAIRY, FAIRY ; type
	db 25 ; catch rate
	db 178 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F75 ; gender ratio
	INCBIN "gfx/pokemon/granbull/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, ROAR, TOXIC, ZAP_CANNON, HIDDEN_POWER, SUNNY_DAY, CRUNCH, HYPER_BEAM, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, THUNDER, RETURN, SHADOW_BALL, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, THUNDERPUNCH, DETECT, REST, ATTRACT, THIEF, FIRE_PUNCH, STRENGTH, ROCK_SMASH, THUNDERBOLT, SEISMIC_TOSS, COUNTER, REFLECT, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, MEGA_KICK
	; end

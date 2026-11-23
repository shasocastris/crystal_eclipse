	db 0 ; species ID placeholder

	db 110,  85,  95,  50,  80,  95
	evs  2,   0,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db NORMAL, NORMAL ; type
	db 30 ; catch rate
	db 180 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/lickilicky/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, TOXIC, PSYCH_UP, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, RETURN, SHADOW_BALL, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, FIRE_BLAST, SWIFT, DREAM_EATER, DETECT, REST, ATTRACT, FLAMETHROWER, COUNTER, REFLECT, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH
	; end

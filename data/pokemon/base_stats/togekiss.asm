	db 0 ; species ID placeholder

	db  85,  50,  95,  80, 120, 115
	evs  0,   0,   0,   0,   3,   0
	;   hp  atk  def  spd  sat  sdf

	db FAIRY, FLYING ; type
	db 30 ; catch rate
	db 220 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F12_5 ; gender ratio
	INCBIN "gfx/pokemon/togekiss/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, TOXIC, PSYCH_UP, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, RETURN, PSYCHIC_M, SHADOW_BALL, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, FIRE_BLAST, SWIFT, DREAM_EATER, DETECT, REST, ATTRACT, STEEL_WING, FLY, FLASH, REFLECT, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH
	; end

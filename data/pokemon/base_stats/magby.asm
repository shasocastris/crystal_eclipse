	db 0 ; species ID placeholder

	db  45,  75,  37,  83,  70,  55
	evs  0,   0,   0,   1,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db FIRE, FIRE ; type
	db 15 ; catch rate
	db 117 ; base exp
	dw BURNT_BERRY, BURNT_BERRY ; items
	db GENDER_F25 ; gender ratio
	INCBIN "gfx/pokemon/magby/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, RETURN, PSYCHIC_M, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, FIRE_BLAST, THUNDERPUNCH, DETECT, REST, ATTRACT, THIEF, FIRE_PUNCH, FLAMETHROWER, THUNDERBOLT, SEISMIC_TOSS, COUNTER, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH
	; end

	db 0 ; species ID placeholder

	db  75,  95,  67,  83, 125,  95
	evs  0,   0,   0,   0,   3,   0
	;   hp  atk  def  spd  sat  sdf

	db FIRE, FIRE ; type
	db 30 ; catch rate
	db 243 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F25 ; gender ratio
	INCBIN "gfx/pokemon/magmortar/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, PSYCH_UP, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, FIRE_BLAST, SWIFT, DETECT, REST, ATTRACT, FLAMETHROWER, THUNDERBOLT, SEISMIC_TOSS, COUNTER, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH
	; end

	db 0 ; species ID placeholder

	db  65,  90, 120,  60,  85,  70
	evs  0,   0,   2,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db POISON, POISON ; type
	db 20 ; catch rate
	db 173 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/weezing/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm CURSE, ROLLOUT, TOXIC, ZAP_CANNON, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, THUNDER, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, FIRE_BLAST, REST, ATTRACT, THIEF, FLAMETHROWER, THUNDERBOLT, SUBSTITUTE, POISON_JAB
	; end

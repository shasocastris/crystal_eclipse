	db 0 ; species ID placeholder

	db  95,  95,  85,  55, 125,  65
	evs  0,   0,   0,   0,   2,   0
	;   hp  atk  def  spd  sat  sdf

	db GRASS, PSYCHIC_TYPE ; type
	db 15 ; catch rate
	db 212 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/exeggutor/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, TOXIC, PSYCH_UP, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, SOLARBEAM, RETURN, PSYCHIC_M, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, DREAM_EATER, REST, ATTRACT, THIEF, STRENGTH, FLASH, TELEPORT, SUBSTITUTE, TRI_ATTACK, SEED_BOMB
	; end

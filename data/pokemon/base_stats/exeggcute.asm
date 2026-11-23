	db 0 ; species ID placeholder

	db  60,  40,  80,  40,  60,  45
	evs  0,   0,   1,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db GRASS, PSYCHIC_TYPE ; type
	db 30 ; catch rate
	db 98 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/exeggcute/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm CURSE, ROLLOUT, TOXIC, PSYCH_UP, HIDDEN_POWER, SUNNY_DAY, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, SOLARBEAM, RETURN, PSYCHIC_M, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, DREAM_EATER, REST, ATTRACT, THIEF, FLASH, TELEPORT, SUBSTITUTE, TRI_ATTACK, SEED_BOMB
	; end

	db 0 ; species ID placeholder

	db  60,  65,  70,  40,  85,  75
	evs  0,   0,   0,   0,   2,   0
	;   hp  atk  def  spd  sat  sdf

	db GRASS, POISON ; type
	db 40 ; catch rate
	db 132 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/gloom/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, SWEET_SCENT, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, SOLARBEAM, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, REST, ATTRACT, CUT, FLASH, SUBSTITUTE, SEED_BOMB
	; end

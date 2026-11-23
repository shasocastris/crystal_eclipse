	db 0 ; species ID placeholder

	db  40,  60,  40,  30,  40,  40
	evs  0,   1,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db BUG, GROUND ; type
	db 85 ; catch rate
	db 54 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/spinarak/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_FAST ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, SOLARBEAM, RETURN, PSYCHIC_M, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, REST, ATTRACT, THIEF, FLASH, SUBSTITUTE, X_SCISSOR, POISON_JAB
	; end

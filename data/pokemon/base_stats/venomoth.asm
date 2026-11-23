	db 0 ; species ID placeholder

	db  70,  65,  60,  90,  90,  75
	evs  0,   0,   0,   1,   1,   0
	;   hp  atk  def  spd  sat  sdf

	db BUG, PSYCHIC_TYPE ; type
	db 25 ; catch rate
	db 138 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/venomoth/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, SWEET_SCENT, HYPER_BEAM, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, SOLARBEAM, RETURN, PSYCHIC_M, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, SWIFT, REST, ATTRACT, THIEF, FLASH, SUBSTITUTE, POISON_JAB
	; end

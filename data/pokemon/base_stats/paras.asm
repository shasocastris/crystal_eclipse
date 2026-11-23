	db 0 ; species ID placeholder

	db  35,  70,  55,  25,  45,  55
	evs  0,   1,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db BUG, GRASS ; type
	db 63 ; catch rate
	db 70 ; base exp
	dw TINYMUSHROOM, BIG_MUSHROOM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/paras/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, SWEET_SCENT, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, SOLARBEAM, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, REST, ATTRACT, THIEF, FURY_CUTTER, CUT, FLASH, ROCK_SMASH, SUBSTITUTE, X_SCISSOR, SEED_BOMB
	; end

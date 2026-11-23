	db 0 ; species ID placeholder

	db  75,  80,  85,  50,  90, 100
	evs  0,   0,   0,   0,   0,   3
	;   hp  atk  def  spd  sat  sdf

	db GRASS, FAIRY ; type
	db 15 ; catch rate
	db 184 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/bellossom/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, SWEET_SCENT, HYPER_BEAM, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, SOLARBEAM, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, REST, ATTRACT, CUT, FLASH, SUBSTITUTE, SEED_BOMB
	; end

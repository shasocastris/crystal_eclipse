	db 0 ; species ID placeholder

	db 100, 100, 125,  50, 110,  50
	evs  0,   0,   3,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db GRASS, GRASS ; type
	db 30 ; catch rate
	db 187 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/tangrowth/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, PSYCH_UP, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, SOLARBEAM, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, DETECT, REST, ATTRACT, FLASH, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, SEED_BOMB
	; end

	db 0 ; species ID placeholder

	db  45,  49,  65,  45,  49,  65
	evs  0,   0,   0,   0,   0,   1
	;   hp  atk  def  spd  sat  sdf

	db GRASS, GRASS ; type
	db 15 ; catch rate
	db 64 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F12_5 ; gender ratio
	INCBIN "gfx/pokemon/chikorita/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, SWEET_SCENT, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, SOLARBEAM, IRON_TAIL, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, DETECT, REST, ATTRACT, CUT, FLASH, SEISMIC_TOSS, REFLECT, BODY_SLAM, SUBSTITUTE, SWORDS_DANCE, DOUBLE_EDGE, SEED_BOMB
	; end

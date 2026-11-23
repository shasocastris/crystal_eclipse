	db 0 ; species ID placeholder

	db  60,  62,  63,  60,  80,  80
	evs  0,   0,   0,   0,   1,   1
	;   hp  atk  def  spd  sat  sdf

	db GRASS, POISON ; type
	db 15 ; catch rate
	db 141 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F12_5 ; gender ratio
	INCBIN "gfx/pokemon/ivysaur/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, SWEET_SCENT, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, SOLARBEAM, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, REST, ATTRACT, FURY_CUTTER, CUT, FLASH, SEISMIC_TOSS, REFLECT, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, SWORDS_DANCE, DOUBLE_EDGE
	; end

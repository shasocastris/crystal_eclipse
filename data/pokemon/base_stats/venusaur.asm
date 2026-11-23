	db 0 ; species ID placeholder

	db  80,  82,  83,  80, 100, 100
	evs  0,   0,   0,   0,   2,   1
	;   hp  atk  def  spd  sat  sdf

	db GRASS, POISON ; type
	db 15 ; catch rate
	db 208 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F12_5 ; gender ratio
	INCBIN "gfx/pokemon/venusaur/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROAR, TOXIC, HIDDEN_POWER, SUNNY_DAY, SWEET_SCENT, HYPER_BEAM, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, SOLARBEAM, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, REST, ATTRACT, FURY_CUTTER, CUT, STRENGTH, FLASH, SEISMIC_TOSS, REFLECT, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, SWORDS_DANCE, DOUBLE_EDGE
	; end

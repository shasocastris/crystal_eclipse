	db 0 ; species ID placeholder

	db  40,  40,  35,  70,  50, 100
	evs  0,   0,   0,   0,   0,   1
	;   hp  atk  def  spd  sat  sdf

	db WATER, POISON ; type
	db 63 ; catch rate
	db 105 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/tentacool/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, HIDDEN_POWER, BLIZZARD, ICY_WIND, PROTECT, RAIN_DANCE, GIGA_DRAIN, ENDURE, PAIN_SPLIT, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, REST, ATTRACT, CUT, ICE_BEAM, SUBSTITUTE, POISON_JAB
	; end

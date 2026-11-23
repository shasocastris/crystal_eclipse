	db 0 ; species ID placeholder

	db  65,  80, 140,  70,  40,  70
	evs  0,   0,   2,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db STEEL, FLYING ; type
	db 8 ; catch rate
	db 168 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/skarmory/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, PROTECT, ENDURE, PAIN_SPLIT, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, SWIFT, DETECT, REST, ATTRACT, THIEF, STEEL_WING, CUT, FLY, SUBSTITUTE
	; end

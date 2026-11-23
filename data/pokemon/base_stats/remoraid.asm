	db 0 ; species ID placeholder

	db  35,  65,  35,  65,  65,  35
	evs  0,   0,   0,   0,   1,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, WATER ; type
	db 63 ; catch rate
	db 78 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/remoraid/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, HIDDEN_POWER, HYPER_BEAM, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, REST, ATTRACT, THIEF, FLAMETHROWER, ICE_BEAM, SUBSTITUTE
	; end

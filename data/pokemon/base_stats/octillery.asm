	db 0 ; species ID placeholder

	db  75, 105,  75,  45, 105,  75
	evs  0,   1,   0,   0,   1,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, WATER ; type
	db 25 ; catch rate
	db 164 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/octillery/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, HIDDEN_POWER, HYPER_BEAM, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, REST, ATTRACT, THIEF, SURF, WHIRLPOOL, FLAMETHROWER, ICE_BEAM, SUBSTITUTE
	; end

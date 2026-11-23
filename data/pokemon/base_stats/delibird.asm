	db 0 ; species ID placeholder

	db  45,  55,  45,  75,  65,  45
	evs  0,   0,   0,   1,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db ICE, FLYING ; type
	db 15 ; catch rate
	db 183 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/delibird/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, BLIZZARD, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, DETECT, REST, ATTRACT, THIEF, ICE_BEAM, SUBSTITUTE
	; end

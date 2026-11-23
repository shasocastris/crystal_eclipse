	db 0 ; species ID placeholder

	db  65,  40,  70,  70,  80, 140
	evs  0,   0,   0,   0,   0,   2
	;   hp  atk  def  spd  sat  sdf

	db WATER, FLYING ; type
	db 8 ; catch rate
	db 168 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/mantine/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, BLIZZARD, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, REST, ATTRACT, SURF, WHIRLPOOL, WATERFALL, ICE_BEAM, SUBSTITUTE
	; end

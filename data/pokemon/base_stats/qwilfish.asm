	db 0 ; species ID placeholder

	db  65,  95,  75,  85,  55,  55
	evs  0,   1,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, POISON ; type
	db 15 ; catch rate
	db 100 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/qwilfish/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, TOXIC, HIDDEN_POWER, BLIZZARD, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, SWIFT, REST, ATTRACT, SURF, WHIRLPOOL, WATERFALL, ICE_BEAM, SUBSTITUTE, POISON_JAB
	; end

	db 0 ; species ID placeholder

	db  75,  95,  95,  85,  95,  95
	evs  0,   1,   0,   0,   1,   1
	;   hp  atk  def  spd  sat  sdf

	db WATER, DRAGON ; type
	db 15 ; catch rate
	db 207 ; base exp
	dw NO_ITEM, DRAGON_FANG ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/kingdra/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, SWEET_KISS, BLIZZARD, HYPER_BEAM, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, DRAGONBREATH, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, REST, ATTRACT, SURF, WHIRLPOOL, WATERFALL, ICE_BEAM, SUBSTITUTE
	; end

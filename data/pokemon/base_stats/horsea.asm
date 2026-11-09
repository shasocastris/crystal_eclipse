	db 0 ; species ID placeholder

	db  30,  40,  70,  60,  70,  25
	evs  0,   0,   0,   0,   1,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, WATER ; type
	db 75 ; catch rate
	db 83 ; base exp
	dw NO_ITEM, DRAGON_FANG ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/horsea/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, SWEET_KISS, BLIZZARD, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, DRAGONBREATH, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, REST, ATTRACT, ICE_BEAM, SUBSTITUTE
	; end

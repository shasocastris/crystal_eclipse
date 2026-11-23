	db 0 ; species ID placeholder

	db  30,  45,  55,  85,  70,  55
	evs  0,   0,   0,   1,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, WATER ; type
	db 75 ; catch rate
	db 106 ; base exp
	dw STARDUST, STAR_PIECE ; items
	db GENDER_UNKNOWN ; gender ratio
	INCBIN "gfx/pokemon/staryu/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, ZAP_CANNON, PSYCH_UP, HIDDEN_POWER, BLIZZARD, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, THUNDER, RETURN, PSYCHIC_M, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, REST, ATTRACT, FLASH, THUNDERBOLT, ICE_BEAM, REFLECT, SUBSTITUTE
	; end

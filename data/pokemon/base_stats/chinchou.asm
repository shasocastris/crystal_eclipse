	db 0 ; species ID placeholder

	db  75,  38,  38,  67,  56,  56
	evs  1,   0,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, ELECTRIC ; type
	db 63 ; catch rate
	db 90 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/chinchou/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, ZAP_CANNON, HIDDEN_POWER, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, THUNDER, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, REST, ATTRACT, FLASH, THUNDERBOLT, ICE_BEAM, SUBSTITUTE
	; end

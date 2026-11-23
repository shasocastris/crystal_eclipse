	db 0 ; species ID placeholder

	db  25,  35,  70,  45,  95,  55
	evs  0,   0,   0,   0,   1,   0
	;   hp  atk  def  spd  sat  sdf

	db ELECTRIC, STEEL ; type
	db 63 ; catch rate
	db 89 ; base exp
	dw NO_ITEM, METAL_COAT ; items
	db GENDER_UNKNOWN ; gender ratio
	INCBIN "gfx/pokemon/magnemite/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm CURSE, ROLLOUT, TOXIC, ZAP_CANNON, HIDDEN_POWER, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, THUNDER, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, REST, FLASH, THUNDERBOLT, REFLECT, SUBSTITUTE
	; end

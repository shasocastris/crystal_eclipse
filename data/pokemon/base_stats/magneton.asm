	db 0 ; species ID placeholder

	db  50,  60,  95,  70, 120,  70
	evs  0,   0,   0,   0,   2,   0
	;   hp  atk  def  spd  sat  sdf

	db ELECTRIC, STEEL ; type
	db 20 ; catch rate
	db 161 ; base exp
	dw NO_ITEM, METAL_COAT ; items
	db GENDER_UNKNOWN ; gender ratio
	INCBIN "gfx/pokemon/magneton/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm CURSE, ROLLOUT, TOXIC, ZAP_CANNON, HIDDEN_POWER, HYPER_BEAM, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, THUNDER, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, REST, FLASH, THUNDERBOLT, REFLECT, SUBSTITUTE, TRI_ATTACK
	; end

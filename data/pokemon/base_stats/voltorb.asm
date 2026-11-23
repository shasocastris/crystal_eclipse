	db 0 ; species ID placeholder

	db  40,  30,  50, 100,  55,  55
	evs  0,   0,   0,   1,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db ELECTRIC, ELECTRIC ; type
	db 63 ; catch rate
	db 103 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_UNKNOWN ; gender ratio
	INCBIN "gfx/pokemon/voltorb/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, TOXIC, ZAP_CANNON, HIDDEN_POWER, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, THUNDER, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, REST, FLASH, THUNDERBOLT, SUBSTITUTE
	; end

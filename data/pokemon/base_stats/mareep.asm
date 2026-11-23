	db 0 ; species ID placeholder

	db  55,  40,  40,  35,  65,  45
	evs  0,   0,   0,   0,   1,   0
	;   hp  atk  def  spd  sat  sdf

	db ELECTRIC, ELECTRIC ; type
	db 78 ; catch rate
	db 59 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/mareep/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, ZAP_CANNON, HIDDEN_POWER, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, IRON_TAIL, THUNDER, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, REST, ATTRACT, FLASH, THUNDERBOLT, SUBSTITUTE
	; end

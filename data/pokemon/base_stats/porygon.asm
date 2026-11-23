	db 0 ; species ID placeholder

	db  65,  60,  70,  40,  85,  75
	evs  0,   0,   0,   0,   1,   0
	;   hp  atk  def  spd  sat  sdf

	db NORMAL, NORMAL ; type
	db 15 ; catch rate
	db 130 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_UNKNOWN ; gender ratio
	INCBIN "gfx/pokemon/porygon/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, ZAP_CANNON, PSYCH_UP, HIDDEN_POWER, SUNNY_DAY, BLIZZARD, HYPER_BEAM, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, IRON_TAIL, THUNDER, RETURN, PSYCHIC_M, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, DREAM_EATER, REST, THIEF, FLASH, THUNDERBOLT, ICE_BEAM, REFLECT, SUBSTITUTE, TRI_ATTACK
	; end

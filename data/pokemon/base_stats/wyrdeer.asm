	db 0 ; species ID placeholder

	db 103, 105,  72,  65, 105,  75
	evs  2,   0,   0,   0,   1,   0
	;   hp  atk  def  spd  sat  sdf

	db NORMAL, PSYCHIC_TYPE ; type
	db 35 ; catch rate
	db 190 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/wyrdeer/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, PSYCH_UP, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, RETURN, PSYCHIC_M, SHADOW_BALL, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, DETECT, REST, ATTRACT, FLASH, REFLECT, SUBSTITUTE
	; end

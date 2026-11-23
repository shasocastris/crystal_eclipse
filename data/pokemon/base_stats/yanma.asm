	db 0 ; species ID placeholder

	db  65,  65,  45,  95,  75,  45
	evs  0,   0,   0,   1,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db BUG, FLYING ; type
	db 25 ; catch rate
	db 147 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/yanma/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, SOLARBEAM, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, DETECT, REST, ATTRACT, THIEF, FLASH, SUBSTITUTE
	; end

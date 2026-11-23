	db 0 ; species ID placeholder

	db  40,  20,  30,  55,  40,  80
	evs  0,   0,   0,   0,   0,   1
	;   hp  atk  def  spd  sat  sdf

	db BUG, FAIRY ; type
	db 85 ; catch rate
	db 54 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/ledyba/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, ROLLOUT, TOXIC, HIDDEN_POWER, SUNNY_DAY, SWEET_SCENT, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, SOLARBEAM, RETURN, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, SWIFT, THUNDERPUNCH, REST, ATTRACT, THIEF, FLASH, SUBSTITUTE
	; end

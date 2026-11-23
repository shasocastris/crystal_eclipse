	db 0 ; species ID placeholder

	db  55,  35,  50,  85,  55, 110
	evs  0,   0,   0,   0,   0,   2
	;   hp  atk  def  spd  sat  sdf

	db BUG, FAIRY ; type
	db 30 ; catch rate
	db 134 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/ledian/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, ROLLOUT, TOXIC, HIDDEN_POWER, SUNNY_DAY, SWEET_SCENT, HYPER_BEAM, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, SOLARBEAM, RETURN, DIG, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, SWIFT, THUNDERPUNCH, REST, ATTRACT, THIEF, FLASH, SUBSTITUTE
	; end

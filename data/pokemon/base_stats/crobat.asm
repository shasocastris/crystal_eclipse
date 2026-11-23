	db 0 ; species ID placeholder

	db  85,  90,  80, 130,  70,  80
	evs  0,   0,   0,   3,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db POISON, FLYING ; type
	db 30 ; catch rate
	db 204 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/crobat/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, PURSUIT, HIDDEN_POWER, SUNNY_DAY, CRUNCH, HYPER_BEAM, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, DETECT, REST, ATTRACT, THIEF, STEEL_WING, FLY, SUBSTITUTE, X_SCISSOR, POISON_JAB
	; end

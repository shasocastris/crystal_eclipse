	db 0 ; species ID placeholder

	db  60,  55,  50,  45,  40,  55
	evs  0,   0,   0,   0,   0,   1
	;   hp  atk  def  spd  sat  sdf

	db BUG, POISON ; type
	db 63 ; catch rate
	db 75 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/venonat/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, SWEET_SCENT, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, SOLARBEAM, RETURN, PSYCHIC_M, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, SWIFT, REST, ATTRACT, THIEF, SUBSTITUTE, POISON_JAB
	; end

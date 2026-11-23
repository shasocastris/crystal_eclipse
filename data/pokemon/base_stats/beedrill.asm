	db 0 ; species ID placeholder

	db  65,  80,  40,  75,  45,  80
	evs  0,   2,   0,   0,   0,   1
	;   hp  atk  def  spd  sat  sdf

	db BUG, POISON ; type
	db 15 ; catch rate
	db 159 ; base exp
	dw NO_ITEM, POISON_BARB ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/beedrill/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, SWEET_SCENT, HYPER_BEAM, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, SWIFT, REST, ATTRACT, FURY_CUTTER, CUT, SUBSTITUTE, X_SCISSOR, POISON_JAB
	; end

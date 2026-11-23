	db 0 ; species ID placeholder

	db  60,  85,  69,  80,  65,  79
	evs  0,   2,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db POISON, POISON ; type
	db 30 ; catch rate
	db 147 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/arbok/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, CRUNCH, HYPER_BEAM, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, DIG, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, REST, ATTRACT, THIEF, STRENGTH, SUBSTITUTE, SWORDS_DANCE, POISON_JAB
	; end

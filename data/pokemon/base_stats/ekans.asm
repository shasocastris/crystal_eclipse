	db 0 ; species ID placeholder

	db  35,  60,  44,  55,  40,  54
	evs  0,   1,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db POISON, POISON ; type
	db 85 ; catch rate
	db 62 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/ekans/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, CRUNCH, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, REST, ATTRACT, THIEF, SUBSTITUTE, SWORDS_DANCE, POISON_JAB
	; end

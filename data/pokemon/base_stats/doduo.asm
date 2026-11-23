	db 0 ; species ID placeholder

	db  35,  85,  45,  75,  35,  35
	evs  0,   1,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db NORMAL, FLYING ; type
	db 63 ; catch rate
	db 96 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/doduo/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, PURSUIT, HIDDEN_POWER, SUNNY_DAY, PROTECT, ENDURE, PAIN_SPLIT, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, REST, ATTRACT, THIEF, STEEL_WING, SUBSTITUTE, TRI_ATTACK, SWORDS_DANCE, DOUBLE_EDGE
	; end

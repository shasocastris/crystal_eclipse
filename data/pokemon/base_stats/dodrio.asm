	db 0 ; species ID placeholder

	db  60, 110,  70, 100,  60,  60
	evs  0,   2,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db NORMAL, FLYING ; type
	db 15 ; catch rate
	db 158 ; base exp
	dw NO_ITEM, SHARP_BEAK ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/dodrio/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, PURSUIT, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, REST, ATTRACT, THIEF, STEEL_WING, FLY, SUBSTITUTE, TRI_ATTACK, SWORDS_DANCE, DOUBLE_EDGE
	; end

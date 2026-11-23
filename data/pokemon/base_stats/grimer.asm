	db 0 ; species ID placeholder

	db  80,  80,  50,  25,  40,  50
	evs  1,   0,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db POISON, POISON ; type
	db 63 ; catch rate
	db 90 ; base exp
	dw NO_ITEM, NUGGET ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/grimer/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, CURSE, TOXIC, ZAP_CANNON, HIDDEN_POWER, SUNNY_DAY, CRUNCH, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, THUNDER, RETURN, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, FIRE_BLAST, THUNDERPUNCH, REST, ATTRACT, THIEF, FIRE_PUNCH, FLAMETHROWER, THUNDERBOLT, SUBSTITUTE, POISON_JAB
	; end

	db 0 ; species ID placeholder

	db  40,  40,  40,  20,  70,  40
	evs  0,   0,   0,   0,   1,   0
	;   hp  atk  def  spd  sat  sdf

	db FIRE, FIRE ; type
	db 63 ; catch rate
	db 78 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/slugma/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm CURSE, ROLLOUT, TOXIC, HIDDEN_POWER, SUNNY_DAY, PROTECT, ENDURE, PAIN_SPLIT, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, FIRE_BLAST, ROCK_SLIDE, REST, ATTRACT, ROCK_SMASH, FLAMETHROWER, SUBSTITUTE
	; end

	db 0 ; species ID placeholder

	db  50,  50, 120,  30,  80,  80
	evs  0,   0,   2,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db FIRE, ROCK ; type
	db 25 ; catch rate
	db 154 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/magcargo/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm CURSE, ROLLOUT, TOXIC, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, FIRE_BLAST, ROCK_SLIDE, REST, ATTRACT, STRENGTH, ROCK_SMASH, FLAMETHROWER, SUBSTITUTE
	; end

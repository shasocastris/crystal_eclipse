	db 0 ; species ID placeholder

	db  55,  55,  85,  35,  65,  85
	evs  0,   0,   1,   0,   0,   1
	;   hp  atk  def  spd  sat  sdf

	db WATER, ROCK ; type
	db 20 ; catch rate
	db 113 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F75 ; gender ratio
	INCBIN "gfx/pokemon/corsola/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, TOXIC, HIDDEN_POWER, SUNNY_DAY, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, PSYCHIC_M, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, ROCK_SLIDE, REST, ATTRACT, ROCK_SMASH, ICE_BEAM, SUBSTITUTE
	; end

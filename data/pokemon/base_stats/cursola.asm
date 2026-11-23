	db 0 ; species ID placeholder

	db  60,  95,  50,  30, 110, 130
	evs  0,   0,   0,   0,   0,   2
	;   hp  atk  def  spd  sat  sdf

	db GHOST, GHOST ; type
	db 20 ; catch rate
	db 179 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F75 ; gender ratio
	INCBIN "gfx/pokemon/cursola/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, TOXIC, PSYCH_UP, HIDDEN_POWER, SUNNY_DAY, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, RETURN, PSYCHIC_M, SHADOW_BALL, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, DREAM_EATER, REST, ATTRACT, THIEF, ROCK_SMASH, SUBSTITUTE
	; end

	db 0 ; species ID placeholder

	db  55,  45,  45,  15,  25,  25
	evs  1,   0,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, GROUND ; type
	db 85 ; catch rate
	db 52 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/wooper/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, ROLLOUT, TOXIC, HIDDEN_POWER, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, IRON_TAIL, EARTHQUAKE, RETURN, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, SANDSTORM, ROCK_SLIDE, REST, ATTRACT, FLASH, ROCK_SMASH, ICE_BEAM, SUBSTITUTE, ICICLE_CRASH
	; end

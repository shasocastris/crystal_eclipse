	db 0 ; species ID placeholder

	db  95,  85,  85,  35,  65,  65
	evs  2,   0,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, GROUND ; type
	db 30 ; catch rate
	db 137 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/quagsire/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, ROLLOUT, TOXIC, HIDDEN_POWER, HYPER_BEAM, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, IRON_TAIL, EARTHQUAKE, RETURN, DIG, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, SANDSTORM, ROCK_SLIDE, REST, ATTRACT, SURF, STRENGTH, FLASH, WHIRLPOOL, ROCK_SMASH, ICE_BEAM, SUBSTITUTE, ICICLE_CRASH
	; end

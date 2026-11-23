	db 0 ; species ID placeholder

	db  20,  10, 230,  05,  10, 230
	evs  0,   0,   1,   0,   0,   1
	;   hp  atk  def  spd  sat  sdf

	db BUG, ROCK ; type
	db 63 ; catch rate
	db 80 ; base exp
	dw BERRY, BERRY ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/shuckle/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, TOXIC, HIDDEN_POWER, SUNNY_DAY, PROTECT, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, DIG, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, SANDSTORM, ROCK_SLIDE, REST, ATTRACT, STRENGTH, FLASH, ROCK_SMASH, SUBSTITUTE, X_SCISSOR
	; end

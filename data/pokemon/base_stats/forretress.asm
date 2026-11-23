	db 0 ; species ID placeholder

	db  75,  90, 140,  40,  60,  60
	evs  0,   0,   2,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db BUG, STEEL ; type
	db 25 ; catch rate
	db 118 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/forretress/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, TOXIC, HIDDEN_POWER, SUNNY_DAY, SWEET_SCENT, HYPER_BEAM, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, SOLARBEAM, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, REST, ATTRACT, STRENGTH, ROCK_SMASH, SUBSTITUTE, X_SCISSOR
	; end

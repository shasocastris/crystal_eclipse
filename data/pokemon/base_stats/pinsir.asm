	db 0 ; species ID placeholder

	db  65, 125, 100,  85,  55,  70
	evs  0,   2,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db BUG, BUG ; type
	db 15 ; catch rate
	db 200 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/pinsir/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, PURSUIT, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, ROCK_SLIDE, REST, ATTRACT, THIEF, FURY_CUTTER, CUT, STRENGTH, ROCK_SMASH, SUBSTITUTE, SWORDS_DANCE, DOUBLE_EDGE, X_SCISSOR
	; end

	db 0 ; species ID placeholder

	db  65,  75, 105,  85,  35,  65
	evs  0,   0,   1,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db GROUND, FLYING ; type
	db 20 ; catch rate
	db 108 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/gligar/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, PURSUIT, HIDDEN_POWER, SUNNY_DAY, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, SANDSTORM, SWIFT, ROCK_SLIDE, DETECT, REST, ATTRACT, THIEF, FURY_CUTTER, SHADOW_CLAW, CUT, STRENGTH, ROCK_SMASH, SUBSTITUTE, SWORDS_DANCE, X_SCISSOR, POISON_JAB
	; end

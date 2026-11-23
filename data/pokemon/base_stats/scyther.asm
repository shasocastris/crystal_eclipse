	db 0 ; species ID placeholder

	db  70, 110,  80, 105,  55,  80
	evs  0,   1,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db BUG, FLYING ; type
	db 15 ; catch rate
	db 187 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/scyther/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, PURSUIT, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, DETECT, REST, ATTRACT, THIEF, STEEL_WING, FURY_CUTTER, SHADOW_CLAW, CUT, ROCK_SMASH, SUBSTITUTE, SWORDS_DANCE, X_SCISSOR
	; end

	db 0 ; species ID placeholder

	db  35,  80,  50, 120,  50,  70
	evs  0,   0,   0,   2,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db GROUND, GROUND ; type
	db 16 ; catch rate
	db 153 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/dugtrio/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, DIG, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SLUDGE_BOMB, ROCK_SLIDE, REST, ATTRACT, THIEF, SHADOW_CLAW, CUT, ROCK_SMASH, SUBSTITUTE, TRI_ATTACK
	; end

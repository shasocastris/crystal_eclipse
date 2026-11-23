	db 0 ; species ID placeholder

	db  75, 100, 110,  65,  45,  55
	evs  0,   0,   2,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db GROUND, GROUND ; type
	db 30 ; catch rate
	db 163 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/sandslash/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, ROLLOUT, TOXIC, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, EARTHQUAKE, RETURN, DIG, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, SWIFT, ROCK_SLIDE, DETECT, REST, ATTRACT, THIEF, FURY_CUTTER, SHADOW_CLAW, CUT, STRENGTH, ROCK_SMASH, SUBSTITUTE, SWORDS_DANCE, X_SCISSOR
	; end

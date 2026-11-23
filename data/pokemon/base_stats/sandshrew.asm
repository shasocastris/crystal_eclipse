	db 0 ; species ID placeholder

	db  50,  75,  85,  40,  20,  30
	evs  0,   0,   1,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db GROUND, GROUND ; type
	db 85 ; catch rate
	db 93 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/sandshrew/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, ROLLOUT, TOXIC, HIDDEN_POWER, SUNNY_DAY, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, EARTHQUAKE, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, SWIFT, ROCK_SLIDE, DETECT, REST, ATTRACT, THIEF, FURY_CUTTER, SHADOW_CLAW, CUT, ROCK_SMASH, SUBSTITUTE, SWORDS_DANCE, X_SCISSOR
	; end

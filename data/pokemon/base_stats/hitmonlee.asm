	db 0 ; species ID placeholder

	db  50, 120,  53,  87,  35, 110
	evs  0,   2,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db FIGHTING, FIGHTING ; type
	db 15 ; catch rate
	db 139 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F0 ; gender ratio
	INCBIN "gfx/pokemon/hitmonlee/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, TOXIC, PURSUIT, HIDDEN_POWER, SUNNY_DAY, PROTECT, ENDURE, PAIN_SPLIT, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, ROCK_SLIDE, DETECT, REST, ATTRACT, THIEF, STRENGTH, ROCK_SMASH, SEISMIC_TOSS, COUNTER, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, SWORDS_DANCE, DOUBLE_EDGE, MEGA_KICK
	; end

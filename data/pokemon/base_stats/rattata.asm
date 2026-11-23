	db 0 ; species ID placeholder

	db  30,  56,  35,  72,  25,  35
	evs  0,   0,   0,   1,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db NORMAL, NORMAL ; type
	db 85 ; catch rate
	db 57 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/rattata/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, PURSUIT, HIDDEN_POWER, SUNNY_DAY, CRUNCH, BLIZZARD, ICY_WIND, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, THUNDER, RETURN, SHADOW_BALL, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, REST, ATTRACT, THIEF, ROCK_SMASH, BODY_SLAM, SUBSTITUTE, SWORDS_DANCE, DOUBLE_EDGE
	; end

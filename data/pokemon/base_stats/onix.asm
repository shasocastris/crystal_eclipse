	db 0 ; species ID placeholder

	db  35,  45, 160,  70,  30,  45
	evs  0,   0,   1,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db ROCK, GROUND ; type
	db 15 ; catch rate
	db 108 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/onix/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROAR, TOXIC, HIDDEN_POWER, SUNNY_DAY, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, EARTHQUAKE, RETURN, DIG, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, ROCK_SLIDE, REST, ATTRACT, STRENGTH, ROCK_SMASH, BODY_SLAM, SUBSTITUTE, DOUBLE_EDGE
	; end

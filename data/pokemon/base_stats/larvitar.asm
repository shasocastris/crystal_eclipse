	db 0 ; species ID placeholder

	db  50,  64,  50,  41,  45,  50
	evs  0,   1,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db ROCK, GROUND ; type
	db 15 ; catch rate
	db 67 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/larvitar/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, PURSUIT, HIDDEN_POWER, SUNNY_DAY, CRUNCH, HYPER_BEAM, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, ROCK_SLIDE, DETECT, REST, ATTRACT, SHADOW_CLAW, BODY_SLAM, SUBSTITUTE, SWORDS_DANCE, DOUBLE_EDGE
	; end

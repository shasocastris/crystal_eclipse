	db 0 ; species ID placeholder

	db  90,  60,  60,  40,  40,  40
	evs  1,   0,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db GROUND, GROUND ; type
	db 40 ; catch rate
	db 124 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/phanpy/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, ROAR, TOXIC, HIDDEN_POWER, SUNNY_DAY, PROTECT, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, ROCK_SLIDE, REST, ATTRACT, ROCK_SMASH, BODY_SLAM, SUBSTITUTE, DOUBLE_EDGE
	; end

	db 0 ; species ID placeholder

	db  90, 120, 120,  50,  60,  60
	evs  0,   1,   1,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db GROUND, GROUND ; type
	db 20 ; catch rate
	db 189 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/donphan/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, ROAR, TOXIC, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, ROCK_SLIDE, REST, ATTRACT, STRENGTH, ROCK_SMASH, BODY_SLAM, SUBSTITUTE, DOUBLE_EDGE
	; end

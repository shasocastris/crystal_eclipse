	db 0 ; species ID placeholder

	db  75,  85, 200,  30,  55,  65
	evs  0,   0,   2,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db STEEL, GROUND ; type
	db 8 ; catch rate
	db 196 ; base exp
	dw NO_ITEM, METAL_COAT ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/steelix/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, ROAR, TOXIC, HIDDEN_POWER, SUNNY_DAY, CRUNCH, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, DRAGONBREATH, EARTHQUAKE, RETURN, DIG, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, ROCK_SLIDE, REST, ATTRACT, CUT, STRENGTH, ROCK_SMASH, BODY_SLAM, SUBSTITUTE, DOUBLE_EDGE
	; end

	db 0 ; species ID placeholder

	db  55,  70,  45,  60,  70,  50
	evs  0,   1,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db FIRE, FIRE ; type
	db 63 ; catch rate
	db 91 ; base exp
	dw BURNT_BERRY, BURNT_BERRY ; items
	db GENDER_F25 ; gender ratio
	INCBIN "gfx/pokemon/growlithe/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROAR, TOXIC, PURSUIT, HIDDEN_POWER, SUNNY_DAY, CRUNCH, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, DRAGONBREATH, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, FIRE_BLAST, SWIFT, REST, ATTRACT, ROCK_SMASH, FLAMETHROWER, SEISMIC_TOSS, COUNTER, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, DOUBLE_EDGE
	; end

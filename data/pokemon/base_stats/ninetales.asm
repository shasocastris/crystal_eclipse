	db 0 ; species ID placeholder

	db  73,  76,  75, 100,  81, 100
	evs  0,   0,   0,   1,   0,   1
	;   hp  atk  def  spd  sat  sdf

	db FIRE, FIRE ; type
	db 25 ; catch rate
	db 178 ; base exp
	dw BURNT_BERRY, BURNT_BERRY ; items
	db GENDER_F75 ; gender ratio
	INCBIN "gfx/pokemon/ninetales/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROAR, TOXIC, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, RETURN, DIG, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, FIRE_BLAST, SWIFT, REST, ATTRACT, FLAMETHROWER, BODY_SLAM, SUBSTITUTE
	; end

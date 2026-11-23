	db 0 ; species ID placeholder

	db  38,  41,  40,  65,  50,  65
	evs  0,   0,   0,   1,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db FIRE, FIRE ; type
	db 63 ; catch rate
	db 63 ; base exp
	dw BURNT_BERRY, BURNT_BERRY ; items
	db GENDER_F75 ; gender ratio
	INCBIN "gfx/pokemon/vulpix/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, FIRE_BLAST, SWIFT, REST, ATTRACT, FLAMETHROWER, BODY_SLAM, SUBSTITUTE
	; end

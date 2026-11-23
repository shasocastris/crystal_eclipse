	db 0 ; species ID placeholder

	db 115, 140, 130,  40,  55,  55
	evs  0,   3,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db GROUND, ROCK ; type
	db 30 ; catch rate
	db 241 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/rhyperior/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, TOXIC, PSYCH_UP, HIDDEN_POWER, CRUNCH, BLIZZARD, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, THUNDER, EARTHQUAKE, RETURN, DIG, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, ROCK_SLIDE, DETECT, REST, ATTRACT, SHADOW_CLAW, SURF, ROCK_SMASH, COUNTER, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH
	; end

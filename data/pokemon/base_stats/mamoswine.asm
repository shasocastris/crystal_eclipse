	db 0 ; species ID placeholder

	db 110, 130,  80,  80,  70,  60
	evs  0,   3,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db ICE, GROUND ; type
	db 50 ; catch rate
	db 239 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/mamoswine/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, TOXIC, PSYCH_UP, HIDDEN_POWER, CRUNCH, BLIZZARD, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, EARTHQUAKE, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, ROCK_SLIDE, DETECT, REST, ATTRACT, ROCK_SMASH, BODY_SLAM, SUBSTITUTE, ICICLE_CRASH
	; end

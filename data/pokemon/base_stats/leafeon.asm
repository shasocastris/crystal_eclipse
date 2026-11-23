	db 0 ; species ID placeholder

	db  65, 110, 130,  95,  60,  65
	evs  0,   0,   3,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db GRASS, GRASS ; type
	db 45 ; catch rate
	db 184 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F12_5 ; gender ratio
	INCBIN "gfx/pokemon/leafeon/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, PSYCH_UP, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, GIGA_DRAIN, ENDURE, PAIN_SPLIT, SOLARBEAM, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, DETECT, REST, ATTRACT, BODY_SLAM, SUBSTITUTE, X_SCISSOR, SEED_BOMB
	; end

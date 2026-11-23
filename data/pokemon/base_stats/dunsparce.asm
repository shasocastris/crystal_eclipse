	db 0 ; species ID placeholder

	db 100,  70,  70,  45,  65,  65
	evs  1,   0,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db NORMAL, NORMAL ; type
	db 63 ; catch rate
	db 75 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/dunsparce/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, TOXIC, ZAP_CANNON, PSYCH_UP, HIDDEN_POWER, SUNNY_DAY, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, SOLARBEAM, IRON_TAIL, THUNDER, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, ROCK_SLIDE, DREAM_EATER, REST, ATTRACT, THIEF, ROCK_SMASH, FLAMETHROWER, THUNDERBOLT, BODY_SLAM, SUBSTITUTE, DOUBLE_EDGE
	; end

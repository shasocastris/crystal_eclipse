	db 0 ; species ID placeholder

	db  55,  81,  60,  97,  50,  70
	evs  0,   0,   0,   2,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db NORMAL, NORMAL ; type
	db 30 ; catch rate
	db 116 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/raticate/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROAR, TOXIC, PURSUIT, HIDDEN_POWER, SUNNY_DAY, CRUNCH, BLIZZARD, HYPER_BEAM, ICY_WIND, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, THUNDER, RETURN, DIG, SHADOW_BALL, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, REST, ATTRACT, THIEF, CUT, STRENGTH, ROCK_SMASH, THUNDERBOLT, ICE_BEAM, BODY_SLAM, SUBSTITUTE, SWORDS_DANCE, DOUBLE_EDGE
	; end

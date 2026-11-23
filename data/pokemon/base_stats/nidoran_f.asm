	db 0 ; species ID placeholder

	db  55,  47,  52,  41,  40,  40
	evs  1,   0,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db POISON, POISON ; type
	db 78 ; catch rate
	db 59 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F100 ; gender ratio
	INCBIN "gfx/pokemon/nidoran_f/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, BLIZZARD, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, IRON_TAIL, THUNDER, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, ROCK_SLIDE, DETECT, REST, ATTRACT, THIEF, SHADOW_CLAW, THUNDERBOLT, SEISMIC_TOSS, COUNTER, REFLECT, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, DOUBLE_EDGE, MEGA_KICK, POISON_JAB
	; end

	db 0 ; species ID placeholder

	db  90,  65,  65,  15,  40,  40
	evs  1,   0,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, PSYCHIC_TYPE ; type
	db 63 ; catch rate
	db 99 ; base exp
	dw NO_ITEM, KINGS_ROCK ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/slowpoke/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, ZAP_CANNON, PSYCH_UP, HIDDEN_POWER, SUNNY_DAY, BLIZZARD, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, IRON_TAIL, EARTHQUAKE, RETURN, PSYCHIC_M, SHADOW_BALL, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, FIRE_BLAST, SWIFT, DREAM_EATER, REST, ATTRACT, FLASH, FLAMETHROWER, ICE_BEAM, TELEPORT, SEISMIC_TOSS, COUNTER, REFLECT, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH
	; end

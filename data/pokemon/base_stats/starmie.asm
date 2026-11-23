	db 0 ; species ID placeholder

	db  60,  75,  85, 115, 100,  85
	evs  0,   0,   0,   2,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, PSYCHIC_TYPE ; type
	db 20 ; catch rate
	db 207 ; base exp
	dw STARDUST, STAR_PIECE ; items
	db GENDER_UNKNOWN ; gender ratio
	INCBIN "gfx/pokemon/starmie/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm CURSE, TOXIC, ZAP_CANNON, PSYCH_UP, HIDDEN_POWER, BLIZZARD, HYPER_BEAM, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, THUNDER, RETURN, PSYCHIC_M, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, DREAM_EATER, REST, ATTRACT, SURF, FLASH, WHIRLPOOL, WATERFALL, THUNDERBOLT, ICE_BEAM, TELEPORT, REFLECT, SUBSTITUTE, TRI_ATTACK
	; end

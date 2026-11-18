	db 0 ; species ID placeholder

	db  20,  40,  15,  60,  35,  35
	evs  0,   0,   0,   1,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db ELECTRIC, ELECTRIC ; type
	db 63 ; catch rate
	db 42 ; base exp
	dw BERRY, LIGHT_BALL ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/pichu/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, TOXIC, ZAP_CANNON, HIDDEN_POWER, SWEET_KISS, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, IRON_TAIL, THUNDER, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, DEFENSE_CURL, PROTECT, REST, ATTRACT, FLASH, THUNDERBOLT, SEISMIC_TOSS, REFLECT, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, SWORDS_DANCE
	; end

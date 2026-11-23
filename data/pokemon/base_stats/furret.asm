	db 0 ; species ID placeholder

	db  85,  76,  64,  90,  45,  55
	evs  0,   0,   0,   2,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db NORMAL, NORMAL ; type
	db 30 ; catch rate
	db 116 ; base exp
	dw BERRY, GOLD_BERRY ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/furret/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, ROLLOUT, TOXIC, PURSUIT, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, RETURN, DIG, SHADOW_BALL, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, SWIFT, THUNDERPUNCH, DETECT, REST, ATTRACT, THIEF, FIRE_PUNCH, FURY_CUTTER, CUT, SURF, STRENGTH, SEISMIC_TOSS, REFLECT, BODY_SLAM, MEGA_PUNCH, SWORDS_DANCE, DOUBLE_EDGE
	; end

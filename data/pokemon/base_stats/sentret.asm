	db 0 ; species ID placeholder

	db  35,  46,  34,  20,  35,  45
	evs  0,   1,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db NORMAL, NORMAL ; type
	db 85 ; catch rate
	db 57 ; base exp
	dw NO_ITEM, BERRY ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/sentret/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, ROLLOUT, TOXIC, PURSUIT, HIDDEN_POWER, SUNNY_DAY, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, RETURN, SHADOW_BALL, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, SWIFT, THUNDERPUNCH, DETECT, REST, ATTRACT, THIEF, FIRE_PUNCH, FURY_CUTTER, CUT, SEISMIC_TOSS, REFLECT, BODY_SLAM, MEGA_PUNCH, SWORDS_DANCE
	; end

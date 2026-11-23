	db 0 ; species ID placeholder

	db  70,  20,  50,  40,  20,  50
	evs  2,   0,   0,   0,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db WATER, FAIRY ; type
	db 63 ; catch rate
	db 58 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	INCBIN "gfx/pokemon/marill/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_FAST ; growth rate
	; tm/hm learnset
	tmhm DYNAMICPUNCH, HEADBUTT, CURSE, ROLLOUT, TOXIC, HIDDEN_POWER, BLIZZARD, ICY_WIND, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, IRON_TAIL, RETURN, MUD_SLAP, DOUBLE_TEAM, ICE_PUNCH, SWAGGER, SLEEP_TALK, SWIFT, REST, ATTRACT, ICE_BEAM, SEISMIC_TOSS, COUNTER, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH
	; end

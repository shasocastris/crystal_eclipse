	db 0 ; species ID placeholder

	db  55,  55,  50,  55,  45,  65
	evs  0,   0,   0,   0,   0,   1
	;   hp  atk  def  spd  sat  sdf

	db NORMAL, NORMAL ; type
	db 15 ; catch rate
	db 92 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F12_5 ; gender ratio
	INCBIN "gfx/pokemon/eevee/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, IRON_TAIL, RETURN, SHADOW_BALL, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SWIFT, DETECT, REST, ATTRACT, SEISMIC_TOSS, COUNTER, REFLECT, BODY_SLAM, SUBSTITUTE, MEGA_PUNCH, SWORDS_DANCE, DOUBLE_EDGE, MEGA_KICK
	; end

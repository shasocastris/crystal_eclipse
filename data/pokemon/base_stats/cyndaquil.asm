	db 0 ; species ID placeholder

	db  39,  52,  43,  65,  60,  50
	evs  0,   0,   0,   1,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db FIRE, FIRE ; type
	db 15 ; catch rate
	db 65 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F12_5 ; gender ratio
	INCBIN "gfx/pokemon/cyndaquil/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROLLOUT, TOXIC, HIDDEN_POWER, SUNNY_DAY, CRUNCH, PROTECT, ENDURE, PAIN_SPLIT, IRON_TAIL, RETURN, MUD_SLAP, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, FIRE_BLAST, SWIFT, DETECT, REST, ATTRACT, SHADOW_CLAW, CUT, FLAMETHROWER, SEISMIC_TOSS, BODY_SLAM, SUBSTITUTE, SWORDS_DANCE, DOUBLE_EDGE, MEGA_KICK
	; end

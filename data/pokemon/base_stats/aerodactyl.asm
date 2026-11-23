	db 0 ; species ID placeholder

	db  80, 105,  65, 130,  60,  75
	evs  0,   0,   0,   2,   0,   0
	;   hp  atk  def  spd  sat  sdf

	db ROCK, FLYING ; type
	db 15 ; catch rate
	db 202 ; base exp
	dw NO_ITEM, NO_ITEM ; items
	db GENDER_F12_5 ; gender ratio
	INCBIN "gfx/pokemon/aerodactyl/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_SLOW ; growth rate
	; tm/hm learnset
	tmhm HEADBUTT, CURSE, ROAR, TOXIC, HIDDEN_POWER, CRUNCH, HYPER_BEAM, PROTECT, RAIN_DANCE, ENDURE, PAIN_SPLIT, IRON_TAIL, DRAGONBREATH, EARTHQUAKE, RETURN, DOUBLE_TEAM, SWAGGER, SLEEP_TALK, SANDSTORM, FIRE_BLAST, SWIFT, ROCK_SLIDE, DETECT, REST, ATTRACT, STEEL_WING, FLY, ROCK_SMASH, FLAMETHROWER, SUBSTITUTE, SWORDS_DANCE, DOUBLE_EDGE
	; end

; move ids, sorted by type, then category (physical, special, status), then power;
; the legendary signature moves (see data/moves/signature_moves.asm) come last
; indexes for:
; - Moves (see data/moves/moves.asm)
; - MoveNames (see data/moves/names.asm)
; - MoveDescriptions (see data/moves/descriptions.asm)
; - BattleAnimations (see data/moves/animation_pointers.asm)
	const_def
	const NO_MOVE        ; 00
	; NORMAL
	const SELFDESTRUCT   ; 01
	const THRASH         ; 02
	const DOUBLE_EDGE    ; 03
	const TAKE_DOWN      ; 04
	const BODY_SLAM      ; 05
	const SLAM           ; 06
	const HYPER_FANG     ; 07
	const EXTREMESPEED   ; 08
	const HEADBUTT       ; 09
	const SLASH          ; 0a
	const STOMP          ; 0b
	const PAY_DAY        ; 0c
	const SCRATCH        ; 0d
	const QUICK_ATTACK   ; 0e
	const FALSE_SWIPE    ; 0f
	const RAGE           ; 10
	const RAPID_SPIN     ; 11
	const FURY_STRIKES   ; 12
	const WRAP           ; 13
	const SUPER_FANG     ; 14
	const FLAIL          ; 15
	const RETURN         ; 16
	const PRESENT        ; 17
	const HYPER_BEAM     ; 18
	const TRI_ATTACK     ; 19
	const HIDDEN_POWER   ; 1a
	const SWIFT          ; 1b
	const SONICBOOM      ; 1c
	const SWORDS_DANCE   ; 1d
	const LEER           ; 1e
	const GROWL          ; 1f
	const ROAR           ; 20
	const SING           ; 21
	const SUPERSONIC     ; 22
	const DISABLE        ; 23
	const GROWTH         ; 24
	const MIMIC          ; 25
	const SCREECH        ; 26
	const DOUBLE_TEAM    ; 27
	const RECOVER        ; 28
	const HARDEN         ; 29
	const MINIMIZE       ; 2a
	const SMOKESCREEN    ; 2b
	const DEFENSE_CURL   ; 2c
	const FOCUS_ENERGY   ; 2d
	const METRONOME      ; 2e
	const NOURISHMENT    ; 2f
	const GLARE          ; 30
	const LOVELY_KISS    ; 31
	const TRANSFORM      ; 32
	const FLASH          ; 33
	const SPLASH         ; 34
	const CONVERSION     ; 35
	const SUBSTITUTE     ; 36
	const SKETCH         ; 37
	const CONVERSION2    ; 38
	const PROTECT        ; 39
	const SCARY_FACE     ; 3a
	const BELLY_DRUM     ; 3b
	const FORESIGHT      ; 3c
	const PERISH_SONG    ; 3d
	const LOCK_ON        ; 3e
	const ENDURE         ; 3f
	const SWAGGER        ; 40
	const MEAN_LOOK      ; 41
	const ATTRACT        ; 42
	const SLEEP_TALK     ; 43
	const HEAL_BELL      ; 44
	const SAFEGUARD      ; 45
	const PAIN_SPLIT     ; 46
	const BATON_PASS     ; 47
	const ENCORE         ; 48
	const SWEET_SCENT    ; 49
	const MORNING_SUN    ; 4a
	const PSYCH_UP       ; 4b
	const STRUGGLE       ; 4c
	; FIGHTING
	const MEGA_KICK      ; 4d
	const DYNAMICPUNCH   ; 4e
	const CROSS_CHOP     ; 4f
	const SUBMISSION     ; 50
	const HI_JUMP_KICK   ; 51
	const STRENGTH       ; 52
	const VITAL_THROW    ; 53
	const ROLLING_KICK   ; 54
	const KARATE_CHOP    ; 55
	const MACH_PUNCH     ; 56
	const DOUBLE_KICK    ; 57
	const COUNTER        ; 58
	const SEISMIC_TOSS   ; 59
	const REVERSAL       ; 5a
	const DETECT         ; 5b
	; FLYING
	const DRILL_PECK     ; 5c
	const FLY            ; 5d
	const WING_ATTACK    ; 5e
	const PECK           ; 5f
	const HURRICANE      ; 60
	const AIR_SLASH      ; 61
	const GUST           ; 62
	const RAZOR_WIND     ; 63
	const MIRROR_MOVE    ; 64
	; POISON
	const POISON_JAB     ; 65
	const HORN_ATTACK    ; 66
	const POISON_STING   ; 67
	const SLUDGE_BOMB    ; 68
	const SLUDGE         ; 69
	const ACID           ; 6a
	const POISONPOWDER   ; 6b
	const TOXIC          ; 6c
	; GROUND
	const EARTHQUAKE     ; 6d
	const BONE_CLUB      ; 6e
	const DIG            ; 6f
	const BULLDOZE       ; 70
	const BONEMERANG     ; 71
	const MAGNITUDE      ; 72
	const EARTH_POWER    ; 73
	const MUD_SLAP       ; 74
	const SPIKES         ; 75
	; ROCK
	const STONE_EDGE     ; 76
	const ROCK_SLIDE     ; 77
	const ROCK_THROW     ; 78
	const ROLLOUT        ; 79
	const ROCK_BLAST     ; 7a
	const POWER_GEM      ; 7b
	const ANCIENTPOWER   ; 7c
	const SANDSTORM      ; 7d
	; BUG
	const MEGAHORN       ; 7e
	const X_SCISSOR      ; 7f
	const LEECH_LIFE     ; 80
	const CUT            ; 81
	const TWINEEDLE      ; 82
	const BIND           ; 83
	const PIN_MISSILE    ; 84
	const FURY_CUTTER    ; 85
	const BUG_BUZZ       ; 86
	const STRING_SHOT    ; 87
DEF MOVE_TABLE_SPLIT EQU const_value - 1 ; last move in the first part of each move table
	; GHOST
	const SHADOW_CLAW    ; 88
	const LICK           ; 89
	const DREAM_EATER    ; 8a
	const SHADOW_BALL    ; 8b
	const NIGHT_SHADE    ; 8c
	const CONFUSE_RAY    ; 8d
	const NIGHTMARE      ; 8e
	const SPITE          ; 8f
	const DESTINY_BOND   ; 90
	; STEEL
	const SKULL_BASH     ; 91
	const IRON_TAIL      ; 92
	const IRON_HEAD      ; 93
	const STEEL_WING     ; 94
	const METAL_CLAW     ; 95
	const ROCK_SMASH     ; 96
	const BULLET_PUNCH   ; 97
	const SPIKE_CANNON   ; 98
	const CLAMP          ; 99
	const FLASH_CANNON   ; 9a
	; CURSE_TYPE
	const CURSE          ; 9b
	; FIRE
	const FIRE_PUNCH     ; 9c
	const FLAME_WHEEL    ; 9d
	const FIRE_BLAST     ; 9e
	const FLAMETHROWER   ; 9f
	const EMBER          ; a0
	const FIRE_SPIN      ; a1
	const SUNNY_DAY      ; a2
	const WILL_O_WISP    ; a3
	; WATER
	const CRABHAMMER     ; a4
	const AQUA_TAIL      ; a5
	const WATERFALL      ; a6
	const AQUA_JET       ; a7
	const HYDRO_PUMP     ; a8
	const SURF           ; a9
	const SCALD          ; aa
	const BUBBLEBEAM     ; ab
	const OCTAZOOKA      ; ac
	const WATER_PULSE    ; ad
	const WATER_GUN      ; ae
	const BUBBLE         ; af
	const WHIRLPOOL      ; b0
	const RAIN_DANCE     ; b1
	; GRASS
	const POWER_WHIP     ; b2
	const SEED_BOMB      ; b3
	const RAZOR_LEAF     ; b4
	const VINE_WHIP      ; b5
	const CONSTRICT      ; b6
	const SOLARBEAM      ; b7
	const PETAL_DANCE    ; b8
	const ENERGY_BALL    ; b9
	const GIGA_DRAIN     ; ba
	const MEGA_DRAIN     ; bb
	const ABSORB         ; bc
	const LEECH_SEED     ; bd
	const STUN_SPORE     ; be
	const SLEEP_POWDER   ; bf
	const SPORE          ; c0
	const SYNTHESIS      ; c1
	; ELECTRIC
	const WILD_CHARGE    ; c2
	const THUNDERPUNCH   ; c3
	const SPARK          ; c4
	const THUNDER        ; c5
	const ZAP_CANNON     ; c6
	const THUNDERBOLT    ; c7
	const THUNDERSHOCK   ; c8
	const THUNDER_WAVE   ; c9
	; PSYCHIC_TYPE
	const ZEN_HEADBUTT   ; ca
	const PSYCHIC_M      ; cb
	const FUTURE_SIGHT   ; cc
	const EXTRASENSORY   ; cd
	const PSYBEAM        ; ce
	const CONFUSION      ; cf
	const PSYWAVE        ; d0
	const MIRROR_COAT    ; d1
	const HYPNOSIS       ; d2
	const MEDITATE       ; d3
	const AGILITY        ; d4
	const TELEPORT       ; d5
	const BARRIER        ; d6
	const LIGHT_SCREEN   ; d7
	const REFLECT        ; d8
	const AMNESIA        ; d9
	const REST           ; da
	; ICE
	const ICICLE_CRASH   ; db
	const ICE_PUNCH      ; dc
	const ICE_SHARD      ; dd
	const BLIZZARD       ; de
	const ICE_BEAM       ; df
	const AURORA_BEAM    ; e0
	const ICY_WIND       ; e1
	const POWDER_SNOW    ; e2
	const MIST           ; e3
	const HAZE           ; e4
	const SUDDEN_CHILL   ; e5
	const HAIL           ; e6
	; DRAGON
	const OUTRAGE        ; e7
	const DRAGON_CLAW    ; e8
	const DRAGON_PULSE   ; e9
	const DRAGONBREATH   ; ea
	const DRAGON_RAGE    ; eb
	const TWISTER        ; ec
	; DARK
	const CRUNCH         ; ed
	const NIGHT_SLASH    ; ee
	const BITE           ; ef
	const FAINT_ATTACK   ; f0
	const THIEF          ; f1
	const PURSUIT        ; f2
	const DARK_PULSE     ; f3
	; FAIRY
	const PLAY_ROUGH     ; f4
	const MEGA_PUNCH     ; f5
	const COMET_PUNCH    ; f6
	const MOONBLAST      ; f7
	const DAZZLING_GLEAM ; f8
	const DRAIN_KISS     ; f9
	const DISARM_VOICE   ; fa
	const SWEET_KISS     ; fb
	const CHARM          ; fc
	const MOONLIGHT      ; fd
	; UBER
	const AURA_SPHERE    ; fe
	const SKY_ATTACK     ; ff
	const ERUPTION       ; 100
	const SACRED_FIRE    ; 101
	const LIFE_DEW       ; 102
	const STORM_CALL     ; 103
	const INNER_LIGHT    ; 104
	const SHEER_COLD     ; 105
	const AEROBLAST      ; 106
	const FAE_BLADE      ; 107
DEF NUM_ATTACKS EQU const_value - 1

DEF CANNOT_MOVE EQU $ff

	if NUM_ATTACKS > $3fff
		fail "Too many moves defined!"
	endc

; Battle animations use the same constants as the moves
	const ANIM_SWEET_SCENT_2     ; fc
; Animations with negative IDs will play even when animations are disabled
	const_def -1, -1
	const ANIM_IN_HAIL           ;  -1 (ffff)
	const ANIM_HIT_CONFUSION     ;  -2 (fffe)
	const ANIM_SHAKE             ;  -3 (fffd)
	const ANIM_WOBBLE            ;  -4 (fffc)
	const ANIM_PLAYER_DAMAGE     ;  -5 (fffb)
	const ANIM_PLAYER_STAT_DOWN  ;  -6 (fffa)
	const ANIM_ENEMY_STAT_DOWN   ;  -7 (fff9)
	const ANIM_ENEMY_DAMAGE      ;  -8 (fff8)
	const ANIM_MISS              ;  -9 (fff7)
	DEF BATTLE_AFTERANIMS EQU ANIM_MISS
; battle anims
	const ANIM_IN_WHIRLPOOL      ;  -a (fff6)
	const ANIM_IN_NIGHTMARE      ;  -b (fff5)
	const ANIM_IN_SANDSTORM      ;  -c (fff4)
	const ANIM_IN_LOVE           ;  -d (fff3)
	const ANIM_PAR               ;  -e (fff2)
	const ANIM_FRZ               ;  -f (fff1)
	const ANIM_SAP               ; -10 (fff0)
	const ANIM_PSN               ; -11 (ffef)
	const ANIM_BRN               ; -12 (ffee)
	const ANIM_SLP               ; -13 (ffed)
	const ANIM_CONFUSED          ; -14 (ffec)
	const ANIM_RETURN_MON        ; -15 (ffeb)
	const ANIM_SEND_OUT_MON      ; -16 (ffea)
	const ANIM_THROW_POKE_BALL   ; -17 (ffe9)
DEF NUM_BATTLE_ANIMS EQU -const_value - 1

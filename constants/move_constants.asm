; move ids, sorted by type, then category (physical, special, status), then power
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
	const HORN_ATTACK    ; 0c
	const PAY_DAY        ; 0d
	const SCRATCH        ; 0e
	const QUICK_ATTACK   ; 0f
	const FALSE_SWIPE    ; 10
	const RAGE           ; 11
	const RAPID_SPIN     ; 12
	const FURY_STRIKES   ; 13
	const WRAP           ; 14
	const SUPER_FANG     ; 15
	const FLAIL          ; 16
	const RETURN         ; 17
	const PRESENT        ; 18
	const HYPER_BEAM     ; 19
	const HYPER_VOICE    ; 1a
	const TRI_ATTACK     ; 1b
	const HIDDEN_POWER   ; 1c
	const SWIFT          ; 1d
	const SONICBOOM      ; 1e
	const SWORDS_DANCE   ; 1f
	const LEER           ; 20
	const GROWL          ; 21
	const ROAR           ; 22
	const SING           ; 23
	const SUPERSONIC     ; 24
	const DISABLE        ; 25
	const GROWTH         ; 26
	const MIMIC          ; 27
	const SCREECH        ; 28
	const DOUBLE_TEAM    ; 29
	const RECOVER        ; 2a
	const HARDEN         ; 2b
	const MINIMIZE       ; 2c
	const SMOKESCREEN    ; 2d
	const DEFENSE_CURL   ; 2e
	const FOCUS_ENERGY   ; 2f
	const METRONOME      ; 30
	const NOURISHMENT    ; 31
	const GLARE          ; 32
	const LOVELY_KISS    ; 33
	const TRANSFORM      ; 34
	const FLASH          ; 35
	const SPLASH         ; 36
	const CONVERSION     ; 37
	const SUBSTITUTE     ; 38
	const SKETCH         ; 39
	const CONVERSION2    ; 3a
	const PROTECT        ; 3b
	const SCARY_FACE     ; 3c
	const BELLY_DRUM     ; 3d
	const FORESIGHT      ; 3e
	const PERISH_SONG    ; 3f
	const LOCK_ON        ; 40
	const ENDURE         ; 41
	const SWAGGER        ; 42
	const MEAN_LOOK      ; 43
	const ATTRACT        ; 44
	const SLEEP_TALK     ; 45
	const HEAL_BELL      ; 46
	const SAFEGUARD      ; 47
	const PAIN_SPLIT     ; 48
	const BATON_PASS     ; 49
	const ENCORE         ; 4a
	const SWEET_SCENT    ; 4b
	const MORNING_SUN    ; 4c
	const PSYCH_UP       ; 4d
	const STRUGGLE       ; 4e
	; FIGHTING
	const MEGA_KICK      ; 4f
	const DYNAMICPUNCH   ; 50
	const CROSS_CHOP     ; 51
	const HI_JUMP_KICK   ; 52
	const SUBMISSION     ; 53
	const STRENGTH       ; 54
	const DRAIN_PUNCH    ; 55
	const VITAL_THROW    ; 56
	const ROLLING_KICK   ; 57
	const KARATE_CHOP    ; 58
	const MACH_PUNCH     ; 59
	const DOUBLE_KICK    ; 5a
	const COUNTER        ; 5b
	const SEISMIC_TOSS   ; 5c
	const REVERSAL       ; 5d
	const AURA_SPHERE    ; 5e
	const FOCUS_BLAST    ; 5f
	const DETECT         ; 60
	; FLYING
	const SKY_ATTACK     ; 61
	const BRAVE_BIRD     ; 62
	const DRILL_PECK     ; 63
	const FLY            ; 64
	const WING_ATTACK    ; 65
	const AERIAL_ACE     ; 66
	const PECK           ; 67
	const HURRICANE      ; 68
	const AIR_SLASH      ; 69
	const GUST           ; 6a
	const RAZOR_WIND     ; 6b
	const MIRROR_MOVE    ; 6c
	; POISON
	const GUNK_SHOT      ; 6d
	const POISON_JAB     ; 6e
	const POISON_STING   ; 6f
	const SLUDGE_BOMB    ; 70
	const SLUDGE         ; 71
	const ACID           ; 72
	const POISONPOWDER   ; 73
	const TOXIC          ; 74
	; GROUND
	const ERUPTION       ; 75
	const EARTHQUAKE     ; 76
	const BONE_CLUB      ; 77
	const DIG            ; 78
	const BULLDOZE       ; 79
	const BONEMERANG     ; 7a
	const MAGNITUDE      ; 7b
	const EARTH_POWER    ; 7c
	const MUD_SLAP       ; 7d
	const SPIKES         ; 7e
	; ROCK
	const STONE_EDGE     ; 7f
	const ROCK_SLIDE     ; 80
	const ROCK_THROW     ; 81
	const ROLLOUT        ; 82
	const ROCK_BLAST     ; 83
	const POWER_GEM      ; 84
	const ANCIENTPOWER   ; 85
	const SANDSTORM      ; 86
	; BUG
	const MEGAHORN       ; 87
	const X_SCISSOR      ; 88
	const LEECH_LIFE     ; 89
	const CUT            ; 8a
	const TWINEEDLE      ; 8b
	const BIND           ; 8c
	const PIN_MISSILE    ; 8d
	const FURY_CUTTER    ; 8e
	const BUG_BUZZ       ; 8f
	const STRING_SHOT    ; 90
DEF MOVE_TABLE_SPLIT EQU const_value - 1 ; last move in the first part of each move table
	; GHOST
	const SHADOW_CLAW    ; 91
	const LICK           ; 92
	const DREAM_EATER    ; 93
	const SHADOW_BALL    ; 94
	const NIGHT_SHADE    ; 95
	const CONFUSE_RAY    ; 96
	const NIGHTMARE      ; 97
	const SPITE          ; 98
	const DESTINY_BOND   ; 99
	; STEEL
	const SKULL_BASH     ; 9a
	const IRON_TAIL      ; 9b
	const IRON_HEAD      ; 9c
	const STEEL_WING     ; 9d
	const METAL_CLAW     ; 9e
	const ROCK_SMASH     ; 9f
	const BULLET_PUNCH   ; a0
	const SPIKE_CANNON   ; a1
	const CLAMP          ; a2
	const FLASH_CANNON   ; a3
	; CURSE_TYPE
	const CURSE          ; a4
	; FIRE
	const SACRED_FIRE    ; a5
	const FIRE_PUNCH     ; a6
	const FLAME_WHEEL    ; a7
	const FIRE_BLAST     ; a8
	const FLAMETHROWER   ; a9
	const EMBER          ; aa
	const FIRE_SPIN      ; ab
	const SUNNY_DAY      ; ac
	const WILL_O_WISP    ; ad
	; WATER
	const CRABHAMMER     ; ae
	const AQUA_TAIL      ; af
	const WATERFALL      ; b0
	const AQUA_JET       ; b1
	const HYDRO_PUMP     ; b2
	const SURF           ; b3
	const SCALD          ; b4
	const BUBBLEBEAM     ; b5
	const OCTAZOOKA      ; b6
	const WATER_PULSE    ; b7
	const WATER_GUN      ; b8
	const BUBBLE         ; b9
	const WHIRLPOOL      ; ba
	const RAIN_DANCE     ; bb
	const LIFE_DEW       ; bc
	; GRASS
	const POWER_WHIP     ; bd
	const SEED_BOMB      ; be
	const RAZOR_LEAF     ; bf
	const VINE_WHIP      ; c0
	const CONSTRICT      ; c1
	const SOLARBEAM      ; c2
	const PETAL_DANCE    ; c3
	const ENERGY_BALL    ; c4
	const GIGA_DRAIN     ; c5
	const MEGA_DRAIN     ; c6
	const ABSORB         ; c7
	const LEECH_SEED     ; c8
	const STUN_SPORE     ; c9
	const SLEEP_POWDER   ; ca
	const SPORE          ; cb
	const SYNTHESIS      ; cc
	; ELECTRIC
	const WILD_CHARGE    ; cd
	const THUNDERPUNCH   ; ce
	const SPARK          ; cf
	const STORM_CALL     ; d0
	const THUNDER        ; d1
	const ZAP_CANNON     ; d2
	const THUNDERBOLT    ; d3
	const THUNDERSHOCK   ; d4
	const THUNDER_WAVE   ; d5
	const INNER_LIGHT    ; d6
	; PSYCHIC_TYPE
	const ZEN_HEADBUTT   ; d7
	const PSYCHIC_M      ; d8
	const FUTURE_SIGHT   ; d9
	const EXTRASENSORY   ; da
	const PSYBEAM        ; db
	const CONFUSION      ; dc
	const PSYWAVE        ; dd
	const MIRROR_COAT    ; de
	const HYPNOSIS       ; df
	const MEDITATE       ; e0
	const AGILITY        ; e1
	const TELEPORT       ; e2
	const BARRIER        ; e3
	const LIGHT_SCREEN   ; e4
	const REFLECT        ; e5
	const AMNESIA        ; e6
	const REST           ; e7
	; ICE
	const ICICLE_CRASH   ; e8
	const ICE_PUNCH      ; e9
	const ICE_SHARD      ; ea
	const BLIZZARD       ; eb
	const ICE_BEAM       ; ec
	const AURORA_BEAM    ; ed
	const ICY_WIND       ; ee
	const POWDER_SNOW    ; ef
	const SHEER_COLD     ; f0
	const MIST           ; f1
	const HAZE           ; f2
	const SUDDEN_CHILL   ; f3
	const HAIL           ; f4
	; DRAGON
	const OUTRAGE        ; f5
	const DRAGON_CLAW    ; f6
	const AEROBLAST      ; f7
	const DRAGON_PULSE   ; f8
	const DRAGONBREATH   ; f9
	const DRAGON_RAGE    ; fa
	const TWISTER        ; fb
	; DARK
	const CRUNCH         ; fc
	const NIGHT_SLASH    ; fd
	const BITE           ; fe
	const FAINT_ATTACK   ; ff
	const THIEF          ; 100
	const PURSUIT        ; 101
	const DARK_PULSE     ; 102
	; FAIRY
	const FAE_BLADE      ; 103
	const PLAY_ROUGH     ; 104
	const MEGA_PUNCH     ; 105
	const COMET_PUNCH    ; 106
	const MOONBLAST      ; 107
	const DAZZLING_GLEAM ; 108
	const DRAIN_KISS     ; 109
	const DISARM_VOICE   ; 10a
	const SWEET_KISS     ; 10b
	const CHARM          ; 10c
	const MOONLIGHT      ; 10d
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

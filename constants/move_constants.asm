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
	const BONEMERANG     ; 70
	const MAGNITUDE      ; 71
	const MUD_SLAP       ; 72
	const SPIKES         ; 73
	; ROCK
	const ROCK_SLIDE     ; 74
	const ROCK_THROW     ; 75
	const ROLLOUT        ; 76
	const POWER_GEM      ; 77
	const ANCIENTPOWER   ; 78
	const SANDSTORM      ; 79
	; BUG
	const MEGAHORN       ; 7a
	const X_SCISSOR      ; 7b
	const LEECH_LIFE     ; 7c
	const CUT            ; 7d
	const TWINEEDLE      ; 7e
	const BIND           ; 7f
	const PIN_MISSILE    ; 80
	const FURY_CUTTER    ; 81
	const BUG_BUZZ       ; 82
	const STRING_SHOT    ; 83
DEF MOVE_TABLE_SPLIT EQU const_value - 1 ; last move in the first part of each move table
	; GHOST
	const SHADOW_CLAW    ; 84
	const LICK           ; 85
	const DREAM_EATER    ; 86
	const SHADOW_BALL    ; 87
	const NIGHT_SHADE    ; 88
	const CONFUSE_RAY    ; 89
	const NIGHTMARE      ; 8a
	const SPITE          ; 8b
	const DESTINY_BOND   ; 8c
	; STEEL
	const SKULL_BASH     ; 8d
	const IRON_TAIL      ; 8e
	const IRON_HEAD      ; 8f
	const STEEL_WING     ; 90
	const METAL_CLAW     ; 91
	const ROCK_SMASH     ; 92
	const SPIKE_CANNON   ; 93
	const CLAMP          ; 94
	const FLASH_CANNON   ; 95
	; CURSE_TYPE
	const CURSE          ; 96
	; FIRE
	const FIRE_PUNCH     ; 97
	const FLAME_WHEEL    ; 98
	const FIRE_BLAST     ; 99
	const FLAMETHROWER   ; 9a
	const EMBER          ; 9b
	const FIRE_SPIN      ; 9c
	const SUNNY_DAY      ; 9d
	const WILL_O_WISP    ; 9e
	; WATER
	const CRABHAMMER     ; 9f
	const AQUA_TAIL      ; a0
	const WATERFALL      ; a1
	const AQUA_JET       ; a2
	const HYDRO_PUMP     ; a3
	const SURF           ; a4
	const SCALD          ; a5
	const BUBBLEBEAM     ; a6
	const OCTAZOOKA      ; a7
	const WATER_PULSE    ; a8
	const WATER_GUN      ; a9
	const BUBBLE         ; aa
	const WHIRLPOOL      ; ab
	const RAIN_DANCE     ; ac
	; GRASS
	const POWER_WHIP     ; ad
	const SEED_BOMB      ; ae
	const RAZOR_LEAF     ; af
	const VINE_WHIP      ; b0
	const CONSTRICT      ; b1
	const SOLARBEAM      ; b2
	const PETAL_DANCE    ; b3
	const ENERGY_BALL    ; b4
	const GIGA_DRAIN     ; b5
	const MEGA_DRAIN     ; b6
	const ABSORB         ; b7
	const LEECH_SEED     ; b8
	const STUN_SPORE     ; b9
	const SLEEP_POWDER   ; ba
	const SPORE          ; bb
	const SYNTHESIS      ; bc
	; ELECTRIC
	const WILD_CHARGE    ; bd
	const THUNDERPUNCH   ; be
	const SPARK          ; bf
	const THUNDER        ; c0
	const ZAP_CANNON     ; c1
	const THUNDERBOLT    ; c2
	const THUNDERSHOCK   ; c3
	const THUNDER_WAVE   ; c4
	; PSYCHIC_TYPE
	const ZEN_HEADBUTT   ; c5
	const PSYCHIC_M      ; c6
	const FUTURE_SIGHT   ; c7
	const EXTRASENSORY   ; c8
	const PSYBEAM        ; c9
	const CONFUSION      ; ca
	const PSYWAVE        ; cb
	const MIRROR_COAT    ; cc
	const HYPNOSIS       ; cd
	const MEDITATE       ; ce
	const AGILITY        ; cf
	const TELEPORT       ; d0
	const BARRIER        ; d1
	const LIGHT_SCREEN   ; d2
	const REFLECT        ; d3
	const AMNESIA        ; d4
	const REST           ; d5
	; ICE
	const ICICLE_CRASH   ; d6
	const ICE_PUNCH      ; d7
	const ICE_SHARD      ; d8
	const BLIZZARD       ; d9
	const ICE_BEAM       ; da
	const AURORA_BEAM    ; db
	const ICY_WIND       ; dc
	const POWDER_SNOW    ; dd
	const MIST           ; de
	const HAZE           ; df
	const SUDDEN_CHILL   ; e0
	const HAIL           ; e1
	; DRAGON
	const OUTRAGE        ; e2
	const DRAGON_CLAW    ; e3
	const DRAGON_PULSE   ; e4
	const DRAGONBREATH   ; e5
	const DRAGON_RAGE    ; e6
	const TWISTER        ; e7
	; DARK
	const CRUNCH         ; e8
	const NIGHT_SLASH    ; e9
	const BITE           ; ea
	const FAINT_ATTACK   ; eb
	const THIEF          ; ec
	const PURSUIT        ; ed
	const DARK_PULSE     ; ee
	; FAIRY
	const PLAY_ROUGH     ; ef
	const MEGA_PUNCH     ; f0
	const COMET_PUNCH    ; f1
	const MOONBLAST      ; f2
	const DAZZLING_GLEAM ; f3
	const DRAIN_KISS     ; f4
	const DISARM_VOICE   ; f5
	const SWEET_KISS     ; f6
	const CHARM          ; f7
	const MOONLIGHT      ; f8
	; UBER
	const AURA_SPHERE    ; f9
	const SKY_ATTACK     ; fa
	const ERUPTION       ; fb
	const SACRED_FIRE    ; fc
	const LIFE_DEW       ; fd
	const STORM_CALL     ; fe
	const INNER_LIGHT    ; ff
	const SHEER_COLD     ; 100
	const AEROBLAST      ; 101
	const FAE_BLADE      ; 102
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

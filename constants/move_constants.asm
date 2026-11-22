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
	const STONE_EDGE     ; 74
	const ROCK_SLIDE     ; 75
	const ROCK_THROW     ; 76
	const ROLLOUT        ; 77
	const ROCK_BLAST     ; 78
	const POWER_GEM      ; 79
	const ANCIENTPOWER   ; 7a
	const SANDSTORM      ; 7b
	; BUG
	const MEGAHORN       ; 7c
	const X_SCISSOR      ; 7d
	const LEECH_LIFE     ; 7e
	const CUT            ; 7f
	const TWINEEDLE      ; 80
	const BIND           ; 81
	const PIN_MISSILE    ; 82
	const FURY_CUTTER    ; 83
	const BUG_BUZZ       ; 84
	const STRING_SHOT    ; 85
DEF MOVE_TABLE_SPLIT EQU const_value - 1 ; last move in the first part of each move table
	; GHOST
	const SHADOW_CLAW    ; 86
	const LICK           ; 87
	const DREAM_EATER    ; 88
	const SHADOW_BALL    ; 89
	const NIGHT_SHADE    ; 8a
	const CONFUSE_RAY    ; 8b
	const NIGHTMARE      ; 8c
	const SPITE          ; 8d
	const DESTINY_BOND   ; 8e
	; STEEL
	const SKULL_BASH     ; 8f
	const IRON_TAIL      ; 90
	const IRON_HEAD      ; 91
	const STEEL_WING     ; 92
	const METAL_CLAW     ; 93
	const ROCK_SMASH     ; 94
	const BULLET_PUNCH   ; 95
	const SPIKE_CANNON   ; 96
	const CLAMP          ; 97
	const FLASH_CANNON   ; 98
	; CURSE_TYPE
	const CURSE          ; 99
	; FIRE
	const FIRE_PUNCH     ; 9a
	const FLAME_WHEEL    ; 9b
	const FIRE_BLAST     ; 9c
	const FLAMETHROWER   ; 9d
	const EMBER          ; 9e
	const FIRE_SPIN      ; 9f
	const SUNNY_DAY      ; a0
	const WILL_O_WISP    ; a1
	; WATER
	const CRABHAMMER     ; a2
	const AQUA_TAIL      ; a3
	const WATERFALL      ; a4
	const AQUA_JET       ; a5
	const HYDRO_PUMP     ; a6
	const SURF           ; a7
	const SCALD          ; a8
	const BUBBLEBEAM     ; a9
	const OCTAZOOKA      ; aa
	const WATER_PULSE    ; ab
	const WATER_GUN      ; ac
	const BUBBLE         ; ad
	const WHIRLPOOL      ; ae
	const RAIN_DANCE     ; af
	; GRASS
	const POWER_WHIP     ; b0
	const SEED_BOMB      ; b1
	const RAZOR_LEAF     ; b2
	const VINE_WHIP      ; b3
	const CONSTRICT      ; b4
	const SOLARBEAM      ; b5
	const PETAL_DANCE    ; b6
	const ENERGY_BALL    ; b7
	const GIGA_DRAIN     ; b8
	const MEGA_DRAIN     ; b9
	const ABSORB         ; ba
	const LEECH_SEED     ; bb
	const STUN_SPORE     ; bc
	const SLEEP_POWDER   ; bd
	const SPORE          ; be
	const SYNTHESIS      ; bf
	; ELECTRIC
	const WILD_CHARGE    ; c0
	const THUNDERPUNCH   ; c1
	const SPARK          ; c2
	const THUNDER        ; c3
	const ZAP_CANNON     ; c4
	const THUNDERBOLT    ; c5
	const THUNDERSHOCK   ; c6
	const THUNDER_WAVE   ; c7
	; PSYCHIC_TYPE
	const ZEN_HEADBUTT   ; c8
	const PSYCHIC_M      ; c9
	const FUTURE_SIGHT   ; ca
	const EXTRASENSORY   ; cb
	const PSYBEAM        ; cc
	const CONFUSION      ; cd
	const PSYWAVE        ; ce
	const MIRROR_COAT    ; cf
	const HYPNOSIS       ; d0
	const MEDITATE       ; d1
	const AGILITY        ; d2
	const TELEPORT       ; d3
	const BARRIER        ; d4
	const LIGHT_SCREEN   ; d5
	const REFLECT        ; d6
	const AMNESIA        ; d7
	const REST           ; d8
	; ICE
	const ICICLE_CRASH   ; d9
	const ICE_PUNCH      ; da
	const ICE_SHARD      ; db
	const BLIZZARD       ; dc
	const ICE_BEAM       ; dd
	const AURORA_BEAM    ; de
	const ICY_WIND       ; df
	const POWDER_SNOW    ; e0
	const MIST           ; e1
	const HAZE           ; e2
	const SUDDEN_CHILL   ; e3
	const HAIL           ; e4
	; DRAGON
	const OUTRAGE        ; e5
	const DRAGON_CLAW    ; e6
	const DRAGON_PULSE   ; e7
	const DRAGONBREATH   ; e8
	const DRAGON_RAGE    ; e9
	const TWISTER        ; ea
	; DARK
	const CRUNCH         ; eb
	const NIGHT_SLASH    ; ec
	const BITE           ; ed
	const FAINT_ATTACK   ; ee
	const THIEF          ; ef
	const PURSUIT        ; f0
	const DARK_PULSE     ; f1
	; FAIRY
	const PLAY_ROUGH     ; f2
	const MEGA_PUNCH     ; f3
	const COMET_PUNCH    ; f4
	const MOONBLAST      ; f5
	const DAZZLING_GLEAM ; f6
	const DRAIN_KISS     ; f7
	const DISARM_VOICE   ; f8
	const SWEET_KISS     ; f9
	const CHARM          ; fa
	const MOONLIGHT      ; fb
	; UBER
	const AURA_SPHERE    ; fc
	const SKY_ATTACK     ; fd
	const ERUPTION       ; fe
	const SACRED_FIRE    ; ff
	const LIFE_DEW       ; 100
	const STORM_CALL     ; 101
	const INNER_LIGHT    ; 102
	const SHEER_COLD     ; 103
	const AEROBLAST      ; 104
	const FAE_BLADE      ; 105
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

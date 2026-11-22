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
	const GUNK_SHOT      ; 65
	const POISON_JAB     ; 66
	const HORN_ATTACK    ; 67
	const POISON_STING   ; 68
	const SLUDGE_BOMB    ; 69
	const SLUDGE         ; 6a
	const ACID           ; 6b
	const POISONPOWDER   ; 6c
	const TOXIC          ; 6d
	; GROUND
	const EARTHQUAKE     ; 6e
	const BONE_CLUB      ; 6f
	const DIG            ; 70
	const BULLDOZE       ; 71
	const BONEMERANG     ; 72
	const MAGNITUDE      ; 73
	const EARTH_POWER    ; 74
	const MUD_SLAP       ; 75
	const SPIKES         ; 76
	; ROCK
	const STONE_EDGE     ; 77
	const ROCK_SLIDE     ; 78
	const ROCK_THROW     ; 79
	const ROLLOUT        ; 7a
	const ROCK_BLAST     ; 7b
	const POWER_GEM      ; 7c
	const ANCIENTPOWER   ; 7d
	const SANDSTORM      ; 7e
	; BUG
	const MEGAHORN       ; 7f
	const X_SCISSOR      ; 80
	const LEECH_LIFE     ; 81
	const CUT            ; 82
	const TWINEEDLE      ; 83
	const BIND           ; 84
	const PIN_MISSILE    ; 85
	const FURY_CUTTER    ; 86
	const BUG_BUZZ       ; 87
	const STRING_SHOT    ; 88
DEF MOVE_TABLE_SPLIT EQU const_value - 1 ; last move in the first part of each move table
	; GHOST
	const SHADOW_CLAW    ; 89
	const LICK           ; 8a
	const DREAM_EATER    ; 8b
	const SHADOW_BALL    ; 8c
	const NIGHT_SHADE    ; 8d
	const CONFUSE_RAY    ; 8e
	const NIGHTMARE      ; 8f
	const SPITE          ; 90
	const DESTINY_BOND   ; 91
	; STEEL
	const SKULL_BASH     ; 92
	const IRON_TAIL      ; 93
	const IRON_HEAD      ; 94
	const STEEL_WING     ; 95
	const METAL_CLAW     ; 96
	const ROCK_SMASH     ; 97
	const BULLET_PUNCH   ; 98
	const SPIKE_CANNON   ; 99
	const CLAMP          ; 9a
	const FLASH_CANNON   ; 9b
	; CURSE_TYPE
	const CURSE          ; 9c
	; FIRE
	const FIRE_PUNCH     ; 9d
	const FLAME_WHEEL    ; 9e
	const FIRE_BLAST     ; 9f
	const FLAMETHROWER   ; a0
	const EMBER          ; a1
	const FIRE_SPIN      ; a2
	const SUNNY_DAY      ; a3
	const WILL_O_WISP    ; a4
	; WATER
	const CRABHAMMER     ; a5
	const AQUA_TAIL      ; a6
	const WATERFALL      ; a7
	const AQUA_JET       ; a8
	const HYDRO_PUMP     ; a9
	const SURF           ; aa
	const SCALD          ; ab
	const BUBBLEBEAM     ; ac
	const OCTAZOOKA      ; ad
	const WATER_PULSE    ; ae
	const WATER_GUN      ; af
	const BUBBLE         ; b0
	const WHIRLPOOL      ; b1
	const RAIN_DANCE     ; b2
	; GRASS
	const POWER_WHIP     ; b3
	const SEED_BOMB      ; b4
	const RAZOR_LEAF     ; b5
	const VINE_WHIP      ; b6
	const CONSTRICT      ; b7
	const SOLARBEAM      ; b8
	const PETAL_DANCE    ; b9
	const ENERGY_BALL    ; ba
	const GIGA_DRAIN     ; bb
	const MEGA_DRAIN     ; bc
	const ABSORB         ; bd
	const LEECH_SEED     ; be
	const STUN_SPORE     ; bf
	const SLEEP_POWDER   ; c0
	const SPORE          ; c1
	const SYNTHESIS      ; c2
	; ELECTRIC
	const WILD_CHARGE    ; c3
	const THUNDERPUNCH   ; c4
	const SPARK          ; c5
	const THUNDER        ; c6
	const ZAP_CANNON     ; c7
	const THUNDERBOLT    ; c8
	const THUNDERSHOCK   ; c9
	const THUNDER_WAVE   ; ca
	; PSYCHIC_TYPE
	const ZEN_HEADBUTT   ; cb
	const PSYCHIC_M      ; cc
	const FUTURE_SIGHT   ; cd
	const EXTRASENSORY   ; ce
	const PSYBEAM        ; cf
	const CONFUSION      ; d0
	const PSYWAVE        ; d1
	const MIRROR_COAT    ; d2
	const HYPNOSIS       ; d3
	const MEDITATE       ; d4
	const AGILITY        ; d5
	const TELEPORT       ; d6
	const BARRIER        ; d7
	const LIGHT_SCREEN   ; d8
	const REFLECT        ; d9
	const AMNESIA        ; da
	const REST           ; db
	; ICE
	const ICICLE_CRASH   ; dc
	const ICE_PUNCH      ; dd
	const ICE_SHARD      ; de
	const BLIZZARD       ; df
	const ICE_BEAM       ; e0
	const AURORA_BEAM    ; e1
	const ICY_WIND       ; e2
	const POWDER_SNOW    ; e3
	const MIST           ; e4
	const HAZE           ; e5
	const SUDDEN_CHILL   ; e6
	const HAIL           ; e7
	; DRAGON
	const OUTRAGE        ; e8
	const DRAGON_CLAW    ; e9
	const DRAGON_PULSE   ; ea
	const DRAGONBREATH   ; eb
	const DRAGON_RAGE    ; ec
	const TWISTER        ; ed
	; DARK
	const CRUNCH         ; ee
	const NIGHT_SLASH    ; ef
	const BITE           ; f0
	const FAINT_ATTACK   ; f1
	const THIEF          ; f2
	const PURSUIT        ; f3
	const DARK_PULSE     ; f4
	; FAIRY
	const PLAY_ROUGH     ; f5
	const MEGA_PUNCH     ; f6
	const COMET_PUNCH    ; f7
	const MOONBLAST      ; f8
	const DAZZLING_GLEAM ; f9
	const DRAIN_KISS     ; fa
	const DISARM_VOICE   ; fb
	const SWEET_KISS     ; fc
	const CHARM          ; fd
	const MOONLIGHT      ; fe
	; UBER
	const AURA_SPHERE    ; ff
	const SKY_ATTACK     ; 100
	const ERUPTION       ; 101
	const SACRED_FIRE    ; 102
	const LIFE_DEW       ; 103
	const STORM_CALL     ; 104
	const INNER_LIGHT    ; 105
	const SHEER_COLD     ; 106
	const AEROBLAST      ; 107
	const FAE_BLADE      ; 108
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

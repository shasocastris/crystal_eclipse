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
	const BRAVE_BIRD     ; 5c
	const DRILL_PECK     ; 5d
	const FLY            ; 5e
	const WING_ATTACK    ; 5f
	const AERIAL_ACE     ; 60
	const PECK           ; 61
	const HURRICANE      ; 62
	const AIR_SLASH      ; 63
	const GUST           ; 64
	const RAZOR_WIND     ; 65
	const MIRROR_MOVE    ; 66
	; POISON
	const GUNK_SHOT      ; 67
	const POISON_JAB     ; 68
	const HORN_ATTACK    ; 69
	const POISON_STING   ; 6a
	const SLUDGE_BOMB    ; 6b
	const SLUDGE         ; 6c
	const ACID           ; 6d
	const POISONPOWDER   ; 6e
	const TOXIC          ; 6f
	; GROUND
	const EARTHQUAKE     ; 70
	const BONE_CLUB      ; 71
	const DIG            ; 72
	const BULLDOZE       ; 73
	const BONEMERANG     ; 74
	const MAGNITUDE      ; 75
	const EARTH_POWER    ; 76
	const MUD_SLAP       ; 77
	const SPIKES         ; 78
	; ROCK
	const STONE_EDGE     ; 79
	const ROCK_SLIDE     ; 7a
	const ROCK_THROW     ; 7b
	const ROLLOUT        ; 7c
	const ROCK_BLAST     ; 7d
	const POWER_GEM      ; 7e
	const ANCIENTPOWER   ; 7f
	const SANDSTORM      ; 80
	; BUG
	const MEGAHORN       ; 81
	const X_SCISSOR      ; 82
	const LEECH_LIFE     ; 83
	const CUT            ; 84
	const TWINEEDLE      ; 85
	const BIND           ; 86
	const PIN_MISSILE    ; 87
	const FURY_CUTTER    ; 88
	const BUG_BUZZ       ; 89
	const STRING_SHOT    ; 8a
DEF MOVE_TABLE_SPLIT EQU const_value - 1 ; last move in the first part of each move table
	; GHOST
	const SHADOW_CLAW    ; 8b
	const LICK           ; 8c
	const DREAM_EATER    ; 8d
	const SHADOW_BALL    ; 8e
	const NIGHT_SHADE    ; 8f
	const CONFUSE_RAY    ; 90
	const NIGHTMARE      ; 91
	const SPITE          ; 92
	const DESTINY_BOND   ; 93
	; STEEL
	const SKULL_BASH     ; 94
	const IRON_TAIL      ; 95
	const IRON_HEAD      ; 96
	const STEEL_WING     ; 97
	const METAL_CLAW     ; 98
	const ROCK_SMASH     ; 99
	const BULLET_PUNCH   ; 9a
	const SPIKE_CANNON   ; 9b
	const CLAMP          ; 9c
	const FLASH_CANNON   ; 9d
	; CURSE_TYPE
	const CURSE          ; 9e
	; FIRE
	const FIRE_PUNCH     ; 9f
	const FLAME_WHEEL    ; a0
	const FIRE_BLAST     ; a1
	const FLAMETHROWER   ; a2
	const EMBER          ; a3
	const FIRE_SPIN      ; a4
	const SUNNY_DAY      ; a5
	const WILL_O_WISP    ; a6
	; WATER
	const CRABHAMMER     ; a7
	const AQUA_TAIL      ; a8
	const WATERFALL      ; a9
	const AQUA_JET       ; aa
	const HYDRO_PUMP     ; ab
	const SURF           ; ac
	const SCALD          ; ad
	const BUBBLEBEAM     ; ae
	const OCTAZOOKA      ; af
	const WATER_PULSE    ; b0
	const WATER_GUN      ; b1
	const BUBBLE         ; b2
	const WHIRLPOOL      ; b3
	const RAIN_DANCE     ; b4
	; GRASS
	const POWER_WHIP     ; b5
	const SEED_BOMB      ; b6
	const RAZOR_LEAF     ; b7
	const VINE_WHIP      ; b8
	const CONSTRICT      ; b9
	const SOLARBEAM      ; ba
	const PETAL_DANCE    ; bb
	const ENERGY_BALL    ; bc
	const GIGA_DRAIN     ; bd
	const MEGA_DRAIN     ; be
	const ABSORB         ; bf
	const LEECH_SEED     ; c0
	const STUN_SPORE     ; c1
	const SLEEP_POWDER   ; c2
	const SPORE          ; c3
	const SYNTHESIS      ; c4
	; ELECTRIC
	const WILD_CHARGE    ; c5
	const THUNDERPUNCH   ; c6
	const SPARK          ; c7
	const THUNDER        ; c8
	const ZAP_CANNON     ; c9
	const THUNDERBOLT    ; ca
	const THUNDERSHOCK   ; cb
	const THUNDER_WAVE   ; cc
	; PSYCHIC_TYPE
	const ZEN_HEADBUTT   ; cd
	const PSYCHIC_M      ; ce
	const FUTURE_SIGHT   ; cf
	const EXTRASENSORY   ; d0
	const PSYBEAM        ; d1
	const CONFUSION      ; d2
	const PSYWAVE        ; d3
	const MIRROR_COAT    ; d4
	const HYPNOSIS       ; d5
	const MEDITATE       ; d6
	const AGILITY        ; d7
	const TELEPORT       ; d8
	const BARRIER        ; d9
	const LIGHT_SCREEN   ; da
	const REFLECT        ; db
	const AMNESIA        ; dc
	const REST           ; dd
	; ICE
	const ICICLE_CRASH   ; de
	const ICE_PUNCH      ; df
	const ICE_SHARD      ; e0
	const BLIZZARD       ; e1
	const ICE_BEAM       ; e2
	const AURORA_BEAM    ; e3
	const ICY_WIND       ; e4
	const POWDER_SNOW    ; e5
	const MIST           ; e6
	const HAZE           ; e7
	const SUDDEN_CHILL   ; e8
	const HAIL           ; e9
	; DRAGON
	const OUTRAGE        ; ea
	const DRAGON_CLAW    ; eb
	const DRAGON_PULSE   ; ec
	const DRAGONBREATH   ; ed
	const DRAGON_RAGE    ; ee
	const TWISTER        ; ef
	; DARK
	const CRUNCH         ; f0
	const NIGHT_SLASH    ; f1
	const BITE           ; f2
	const FAINT_ATTACK   ; f3
	const THIEF          ; f4
	const PURSUIT        ; f5
	const DARK_PULSE     ; f6
	; FAIRY
	const PLAY_ROUGH     ; f7
	const MEGA_PUNCH     ; f8
	const COMET_PUNCH    ; f9
	const MOONBLAST      ; fa
	const DAZZLING_GLEAM ; fb
	const DRAIN_KISS     ; fc
	const DISARM_VOICE   ; fd
	const SWEET_KISS     ; fe
	const CHARM          ; ff
	const MOONLIGHT      ; 100
	; UBER
	const AURA_SPHERE    ; 101
	const SKY_ATTACK     ; 102
	const ERUPTION       ; 103
	const SACRED_FIRE    ; 104
	const LIFE_DEW       ; 105
	const STORM_CALL     ; 106
	const INNER_LIGHT    ; 107
	const SHEER_COLD     ; 108
	const AEROBLAST      ; 109
	const FAE_BLADE      ; 10a
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

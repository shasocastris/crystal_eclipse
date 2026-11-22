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
	const HI_JUMP_KICK   ; 50
	const SUBMISSION     ; 51
	const STRENGTH       ; 52
	const DRAIN_PUNCH    ; 53
	const VITAL_THROW    ; 54
	const ROLLING_KICK   ; 55
	const KARATE_CHOP    ; 56
	const MACH_PUNCH     ; 57
	const DOUBLE_KICK    ; 58
	const COUNTER        ; 59
	const SEISMIC_TOSS   ; 5a
	const REVERSAL       ; 5b
	const FOCUS_BLAST    ; 5c
	const DETECT         ; 5d
	; FLYING
	const BRAVE_BIRD     ; 5e
	const DRILL_PECK     ; 5f
	const FLY            ; 60
	const WING_ATTACK    ; 61
	const AERIAL_ACE     ; 62
	const PECK           ; 63
	const HURRICANE      ; 64
	const AIR_SLASH      ; 65
	const GUST           ; 66
	const RAZOR_WIND     ; 67
	const MIRROR_MOVE    ; 68
	; POISON
	const GUNK_SHOT      ; 69
	const POISON_JAB     ; 6a
	const HORN_ATTACK    ; 6b
	const POISON_STING   ; 6c
	const SLUDGE_BOMB    ; 6d
	const SLUDGE         ; 6e
	const ACID           ; 6f
	const POISONPOWDER   ; 70
	const TOXIC          ; 71
	; GROUND
	const EARTHQUAKE     ; 72
	const BONE_CLUB      ; 73
	const DIG            ; 74
	const BULLDOZE       ; 75
	const BONEMERANG     ; 76
	const MAGNITUDE      ; 77
	const EARTH_POWER    ; 78
	const MUD_SLAP       ; 79
	const SPIKES         ; 7a
	; ROCK
	const STONE_EDGE     ; 7b
	const ROCK_SLIDE     ; 7c
	const ROCK_THROW     ; 7d
	const ROLLOUT        ; 7e
	const ROCK_BLAST     ; 7f
	const POWER_GEM      ; 80
	const ANCIENTPOWER   ; 81
	const SANDSTORM      ; 82
	; BUG
	const MEGAHORN       ; 83
	const X_SCISSOR      ; 84
	const LEECH_LIFE     ; 85
	const CUT            ; 86
	const TWINEEDLE      ; 87
	const BIND           ; 88
	const PIN_MISSILE    ; 89
	const FURY_CUTTER    ; 8a
	const BUG_BUZZ       ; 8b
	const STRING_SHOT    ; 8c
DEF MOVE_TABLE_SPLIT EQU const_value - 1 ; last move in the first part of each move table
	; GHOST
	const SHADOW_CLAW    ; 8d
	const LICK           ; 8e
	const DREAM_EATER    ; 8f
	const SHADOW_BALL    ; 90
	const NIGHT_SHADE    ; 91
	const CONFUSE_RAY    ; 92
	const NIGHTMARE      ; 93
	const SPITE          ; 94
	const DESTINY_BOND   ; 95
	; STEEL
	const SKULL_BASH     ; 96
	const IRON_TAIL      ; 97
	const IRON_HEAD      ; 98
	const STEEL_WING     ; 99
	const METAL_CLAW     ; 9a
	const ROCK_SMASH     ; 9b
	const BULLET_PUNCH   ; 9c
	const SPIKE_CANNON   ; 9d
	const CLAMP          ; 9e
	const FLASH_CANNON   ; 9f
	; CURSE_TYPE
	const CURSE          ; a0
	; FIRE
	const FIRE_PUNCH     ; a1
	const FLAME_WHEEL    ; a2
	const FIRE_BLAST     ; a3
	const FLAMETHROWER   ; a4
	const EMBER          ; a5
	const FIRE_SPIN      ; a6
	const SUNNY_DAY      ; a7
	const WILL_O_WISP    ; a8
	; WATER
	const CRABHAMMER     ; a9
	const AQUA_TAIL      ; aa
	const WATERFALL      ; ab
	const AQUA_JET       ; ac
	const HYDRO_PUMP     ; ad
	const SURF           ; ae
	const SCALD          ; af
	const BUBBLEBEAM     ; b0
	const OCTAZOOKA      ; b1
	const WATER_PULSE    ; b2
	const WATER_GUN      ; b3
	const BUBBLE         ; b4
	const WHIRLPOOL      ; b5
	const RAIN_DANCE     ; b6
	; GRASS
	const POWER_WHIP     ; b7
	const SEED_BOMB      ; b8
	const RAZOR_LEAF     ; b9
	const VINE_WHIP      ; ba
	const CONSTRICT      ; bb
	const SOLARBEAM      ; bc
	const PETAL_DANCE    ; bd
	const ENERGY_BALL    ; be
	const GIGA_DRAIN     ; bf
	const MEGA_DRAIN     ; c0
	const ABSORB         ; c1
	const LEECH_SEED     ; c2
	const STUN_SPORE     ; c3
	const SLEEP_POWDER   ; c4
	const SPORE          ; c5
	const SYNTHESIS      ; c6
	; ELECTRIC
	const WILD_CHARGE    ; c7
	const THUNDERPUNCH   ; c8
	const SPARK          ; c9
	const THUNDER        ; ca
	const ZAP_CANNON     ; cb
	const THUNDERBOLT    ; cc
	const THUNDERSHOCK   ; cd
	const THUNDER_WAVE   ; ce
	; PSYCHIC_TYPE
	const ZEN_HEADBUTT   ; cf
	const PSYCHIC_M      ; d0
	const FUTURE_SIGHT   ; d1
	const EXTRASENSORY   ; d2
	const PSYBEAM        ; d3
	const CONFUSION      ; d4
	const PSYWAVE        ; d5
	const MIRROR_COAT    ; d6
	const HYPNOSIS       ; d7
	const MEDITATE       ; d8
	const AGILITY        ; d9
	const TELEPORT       ; da
	const BARRIER        ; db
	const LIGHT_SCREEN   ; dc
	const REFLECT        ; dd
	const AMNESIA        ; de
	const REST           ; df
	; ICE
	const ICICLE_CRASH   ; e0
	const ICE_PUNCH      ; e1
	const ICE_SHARD      ; e2
	const BLIZZARD       ; e3
	const ICE_BEAM       ; e4
	const AURORA_BEAM    ; e5
	const ICY_WIND       ; e6
	const POWDER_SNOW    ; e7
	const MIST           ; e8
	const HAZE           ; e9
	const SUDDEN_CHILL   ; ea
	const HAIL           ; eb
	; DRAGON
	const OUTRAGE        ; ec
	const DRAGON_CLAW    ; ed
	const DRAGON_PULSE   ; ee
	const DRAGONBREATH   ; ef
	const DRAGON_RAGE    ; f0
	const TWISTER        ; f1
	; DARK
	const CRUNCH         ; f2
	const NIGHT_SLASH    ; f3
	const BITE           ; f4
	const FAINT_ATTACK   ; f5
	const THIEF          ; f6
	const PURSUIT        ; f7
	const DARK_PULSE     ; f8
	; FAIRY
	const PLAY_ROUGH     ; f9
	const MEGA_PUNCH     ; fa
	const COMET_PUNCH    ; fb
	const MOONBLAST      ; fc
	const DAZZLING_GLEAM ; fd
	const DRAIN_KISS     ; fe
	const DISARM_VOICE   ; ff
	const SWEET_KISS     ; 100
	const CHARM          ; 101
	const MOONLIGHT      ; 102
	; UBER
	const AURA_SPHERE    ; 103
	const SKY_ATTACK     ; 104
	const ERUPTION       ; 105
	const SACRED_FIRE    ; 106
	const LIFE_DEW       ; 107
	const STORM_CALL     ; 108
	const INNER_LIGHT    ; 109
	const SHEER_COLD     ; 10a
	const AEROBLAST      ; 10b
	const FAE_BLADE      ; 10c
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

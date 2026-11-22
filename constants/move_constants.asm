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
	const FOCUS_BLAST    ; 5e
	const DETECT         ; 5f
	; FLYING
	const BRAVE_BIRD     ; 60
	const DRILL_PECK     ; 61
	const FLY            ; 62
	const WING_ATTACK    ; 63
	const AERIAL_ACE     ; 64
	const PECK           ; 65
	const HURRICANE      ; 66
	const AIR_SLASH      ; 67
	const GUST           ; 68
	const RAZOR_WIND     ; 69
	const MIRROR_MOVE    ; 6a
	; POISON
	const GUNK_SHOT      ; 6b
	const POISON_JAB     ; 6c
	const POISON_STING   ; 6d
	const SLUDGE_BOMB    ; 6e
	const SLUDGE         ; 6f
	const ACID           ; 70
	const POISONPOWDER   ; 71
	const TOXIC          ; 72
	; GROUND
	const EARTHQUAKE     ; 73
	const BONE_CLUB      ; 74
	const DIG            ; 75
	const BULLDOZE       ; 76
	const BONEMERANG     ; 77
	const MAGNITUDE      ; 78
	const EARTH_POWER    ; 79
	const MUD_SLAP       ; 7a
	const SPIKES         ; 7b
	; ROCK
	const STONE_EDGE     ; 7c
	const ROCK_SLIDE     ; 7d
	const ROCK_THROW     ; 7e
	const ROLLOUT        ; 7f
	const ROCK_BLAST     ; 80
	const POWER_GEM      ; 81
	const ANCIENTPOWER   ; 82
	const SANDSTORM      ; 83
	; BUG
	const MEGAHORN       ; 84
	const X_SCISSOR      ; 85
	const LEECH_LIFE     ; 86
	const CUT            ; 87
	const TWINEEDLE      ; 88
	const BIND           ; 89
	const PIN_MISSILE    ; 8a
	const FURY_CUTTER    ; 8b
	const BUG_BUZZ       ; 8c
	const STRING_SHOT    ; 8d
DEF MOVE_TABLE_SPLIT EQU const_value - 1 ; last move in the first part of each move table
	; GHOST
	const SHADOW_CLAW    ; 8e
	const LICK           ; 8f
	const DREAM_EATER    ; 90
	const SHADOW_BALL    ; 91
	const NIGHT_SHADE    ; 92
	const CONFUSE_RAY    ; 93
	const NIGHTMARE      ; 94
	const SPITE          ; 95
	const DESTINY_BOND   ; 96
	; STEEL
	const SKULL_BASH     ; 97
	const IRON_TAIL      ; 98
	const IRON_HEAD      ; 99
	const STEEL_WING     ; 9a
	const METAL_CLAW     ; 9b
	const ROCK_SMASH     ; 9c
	const BULLET_PUNCH   ; 9d
	const SPIKE_CANNON   ; 9e
	const CLAMP          ; 9f
	const FLASH_CANNON   ; a0
	; CURSE_TYPE
	const CURSE          ; a1
	; FIRE
	const FIRE_PUNCH     ; a2
	const FLAME_WHEEL    ; a3
	const FIRE_BLAST     ; a4
	const FLAMETHROWER   ; a5
	const EMBER          ; a6
	const FIRE_SPIN      ; a7
	const SUNNY_DAY      ; a8
	const WILL_O_WISP    ; a9
	; WATER
	const CRABHAMMER     ; aa
	const AQUA_TAIL      ; ab
	const WATERFALL      ; ac
	const AQUA_JET       ; ad
	const HYDRO_PUMP     ; ae
	const SURF           ; af
	const SCALD          ; b0
	const BUBBLEBEAM     ; b1
	const OCTAZOOKA      ; b2
	const WATER_PULSE    ; b3
	const WATER_GUN      ; b4
	const BUBBLE         ; b5
	const WHIRLPOOL      ; b6
	const RAIN_DANCE     ; b7
	; GRASS
	const POWER_WHIP     ; b8
	const SEED_BOMB      ; b9
	const RAZOR_LEAF     ; ba
	const VINE_WHIP      ; bb
	const CONSTRICT      ; bc
	const SOLARBEAM      ; bd
	const PETAL_DANCE    ; be
	const ENERGY_BALL    ; bf
	const GIGA_DRAIN     ; c0
	const MEGA_DRAIN     ; c1
	const ABSORB         ; c2
	const LEECH_SEED     ; c3
	const STUN_SPORE     ; c4
	const SLEEP_POWDER   ; c5
	const SPORE          ; c6
	const SYNTHESIS      ; c7
	; ELECTRIC
	const WILD_CHARGE    ; c8
	const THUNDERPUNCH   ; c9
	const SPARK          ; ca
	const THUNDER        ; cb
	const ZAP_CANNON     ; cc
	const THUNDERBOLT    ; cd
	const THUNDERSHOCK   ; ce
	const THUNDER_WAVE   ; cf
	; PSYCHIC_TYPE
	const ZEN_HEADBUTT   ; d0
	const PSYCHIC_M      ; d1
	const FUTURE_SIGHT   ; d2
	const EXTRASENSORY   ; d3
	const PSYBEAM        ; d4
	const CONFUSION      ; d5
	const PSYWAVE        ; d6
	const MIRROR_COAT    ; d7
	const HYPNOSIS       ; d8
	const MEDITATE       ; d9
	const AGILITY        ; da
	const TELEPORT       ; db
	const BARRIER        ; dc
	const LIGHT_SCREEN   ; dd
	const REFLECT        ; de
	const AMNESIA        ; df
	const REST           ; e0
	; ICE
	const ICICLE_CRASH   ; e1
	const ICE_PUNCH      ; e2
	const ICE_SHARD      ; e3
	const BLIZZARD       ; e4
	const ICE_BEAM       ; e5
	const AURORA_BEAM    ; e6
	const ICY_WIND       ; e7
	const POWDER_SNOW    ; e8
	const MIST           ; e9
	const HAZE           ; ea
	const SUDDEN_CHILL   ; eb
	const HAIL           ; ec
	; DRAGON
	const OUTRAGE        ; ed
	const DRAGON_CLAW    ; ee
	const DRAGON_PULSE   ; ef
	const DRAGONBREATH   ; f0
	const DRAGON_RAGE    ; f1
	const TWISTER        ; f2
	; DARK
	const CRUNCH         ; f3
	const NIGHT_SLASH    ; f4
	const BITE           ; f5
	const FAINT_ATTACK   ; f6
	const THIEF          ; f7
	const PURSUIT        ; f8
	const DARK_PULSE     ; f9
	; FAIRY
	const PLAY_ROUGH     ; fa
	const MEGA_PUNCH     ; fb
	const COMET_PUNCH    ; fc
	const MOONBLAST      ; fd
	const DAZZLING_GLEAM ; fe
	const DRAIN_KISS     ; ff
	const DISARM_VOICE   ; 100
	const SWEET_KISS     ; 101
	const CHARM          ; 102
	const MOONLIGHT      ; 103
	; UBER
	const AURA_SPHERE    ; 104
	const SKY_ATTACK     ; 105
	const ERUPTION       ; 106
	const SACRED_FIRE    ; 107
	const LIFE_DEW       ; 108
	const STORM_CALL     ; 109
	const INNER_LIGHT    ; 10a
	const SHEER_COLD     ; 10b
	const AEROBLAST      ; 10c
	const FAE_BLADE      ; 10d
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

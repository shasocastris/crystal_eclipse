SECTION "Evolutions and Attacks 3", ROMX

EvosAttacksPointers3::
	dw ElectivireEvosAttacks
	dw MagmortarEvosAttacks
	dw AmbipomEvosAttacks
	dw AnnihilapeEvosAttacks
	dw HonchkrowEvosAttacks
	dw LeafeonEvosAttacks
	dw LickilickyEvosAttacks
	dw MamoswineEvosAttacks
	dw MismagiusEvosAttacks
	dw RhyperiorEvosAttacks
	dw SylveonEvosAttacks
	dw TogekissEvosAttacks
	dw WeavileEvosAttacks
	dw YanmegaEvosAttacks
	dw GlaceonEvosAttacks
	dw GliscorEvosAttacks
	dw MagnezoneEvosAttacks
	dw PorygonZEvosAttacks
	dw SirfetchdEvosAttacks
	dw TangrowthEvosAttacks
	dw WyrdeerEvosAttacks
	dw FarigirafEvosAttacks
	dw DudunsparceEvosAttacks
	dw UrsalunaEvosAttacks
	dw CursolaEvosAttacks
	dw CorsolaKantoEvosAttacks
	dw RaichuOrangeEvosAttacks
	dw DragoniteKantoEvosAttacks
.IndirectEnd::

ElectivireEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, QUICK_ATTACK
	dbw 1, LEER
	dbw 9, THUNDERPUNCH
	dbw 17, LIGHT_SCREEN
	dbw 21, BULLET_PUNCH
	dbw 25, SWIFT
	dbw 33, SCREECH
	dbw 41, THUNDERBOLT
	dbw 49, CROSS_CHOP
	dbw 57, THUNDER
	dbw 65, WILD_CHARGE
	db 0 ; no more level-up moves

MagmortarEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, EMBER
	dbw 7, LEER
	dbw 13, SLUDGE
	dbw 16, DRAIN_PUNCH
	dbw 19, FIRE_PUNCH
	dbw 25, SMOKESCREEN
	dbw 33, FLAMETHROWER
	dbw 41, SUNNY_DAY
	dbw 49, CROSS_CHOP
	dbw 57, FIRE_BLAST
	dbw 65, FOCUS_BLAST
	db 0 ; no more level-up moves

AmbipomEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 10, FURY_STRIKES
	dbw 15, SCREECH
	dbw 22, SLAM
	dbw 38, AGILITY
	dbw 48, BATON_PASS
	dbw 57, SWIFT
	db 0 ; no more level-up moves

AnnihilapeEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, SHADOW_CLAW
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 9, KARATE_CHOP
	dbw 17, MACH_PUNCH
	dbw 25, SEISMIC_TOSS
	dbw 33, DRAIN_PUNCH
	dbw 41, RAGE
	dbw 49, CROSS_CHOP
	dbw 57, SUBMISSION
	dbw 65, NIGHT_SHADE
	db 0 ; no more level-up moves

HonchkrowEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, PECK
	dbw 1, LEER
	dbw 9, WING_ATTACK
	dbw 17, FAINT_ATTACK
	dbw 25, SWAGGER
	dbw 33, PURSUIT
	dbw 41, MEAN_LOOK
	dbw 49, DARK_PULSE
	dbw 57, BRAVE_BIRD
	dbw 65, HYPER_BEAM
	db 0 ; no more level-up moves

LeafeonEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, RAZOR_LEAF
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 9, MUD_SLAP
	dbw 17, RAZOR_LEAF
	dbw 25, SWIFT
	dbw 33, LEECH_SEED
	dbw 41, GIGA_DRAIN
	dbw 44, SEED_BOMB
	dbw 49, SYNTHESIS
	dbw 57, SOLARBEAM
	db 0 ; no more level-up moves

LickilickyEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, LICK
	dbw 7, SUPERSONIC
	dbw 15, STOMP
	dbw 22, DISABLE
	dbw 29, WRAP
	dbw 36, SCREECH
	dbw 44, ROLLOUT
	dbw 52, SLAM
	dbw 55, POWER_WHIP
	dbw 58, BODY_SLAM
	db 0 ; no more level-up moves

MamoswineEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, HORN_ATTACK
	dbw 1, POWDER_SNOW
	dbw 10, MIST
	dbw 20, ICY_WIND
	dbw 30, ICE_SHARD
	dbw 35, FURY_STRIKES
	dbw 42, TAKE_DOWN
	dbw 50, EARTHQUAKE
	dbw 60, BLIZZARD
	dbw 65, STONE_EDGE
	db 0 ; no more level-up moves

MismagiusEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, GROWL
	dbw 1, PSYWAVE
	dbw 9, SPITE
	dbw 15, CONFUSION
	dbw 21, MEAN_LOOK
	dbw 27, SHADOW_BALL
	dbw 33, SCREECH
	dbw 39, DAZZLING_GLEAM
	dbw 45, PERISH_SONG
	dbw 49, DARK_PULSE
	dbw 53, DESTINY_BOND
	dbw 57, PSYCHIC_M
	db 0 ; no more level-up moves

RhyperiorEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, HORN_ATTACK
	dbw 1, LEER
	dbw 9, STOMP
	dbw 17, FURY_STRIKES
	dbw 25, SCARY_FACE
	dbw 33, ROCK_THROW
	dbw 41, STONE_EDGE
	dbw 49, ROCK_SLIDE
	dbw 57, EARTHQUAKE
	db 0 ; no more level-up moves

SylveonEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, DISARM_VOICE
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 9, MUD_SLAP
	dbw 17, SWIFT
	dbw 25, QUICK_ATTACK
	dbw 33, PSYCH_UP
	dbw 41, PSYCHIC_M
	dbw 44, DAZZLING_GLEAM
	dbw 49, BARRIER
	dbw 57, MOONBLAST
	db 0 ; no more level-up moves

TogekissEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, FURY_STRIKES
	dbw 1, GROWL
	dbw 9, ENCORE
	dbw 16, SWIFT
	dbw 23, SAFEGUARD
	dbw 30, ANCIENTPOWER
	dbw 37, AIR_SLASH
	dbw 44, DAZZLING_GLEAM
	dbw 51, EXTREMESPEED
	dbw 55, MOONBLAST
	dbw 60, HYPER_BEAM
	db 0 ; no more level-up moves

WeavileEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 9, QUICK_ATTACK
	dbw 17, FAINT_ATTACK
	dbw 25, ICY_WIND
	dbw 33, SLASH
	dbw 41, ICE_SHARD
	dbw 49, SCREECH
	dbw 53, CRUNCH
	dbw 57, BLIZZARD
	db 0 ; no more level-up moves

YanmegaEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, GUST
	dbw 1, FORESIGHT
	dbw 9, QUICK_ATTACK
	dbw 17, AIR_SLASH
	dbw 25, PROTECT
	dbw 33, ANCIENTPOWER
	dbw 41, BUG_BUZZ
	dbw 49, SCREECH
	dbw 57, SWIFT
	dbw 60, HYPER_BEAM
	db 0 ; no more level-up moves

GlaceonEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, ICY_WIND
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 9, ICY_WIND
	dbw 17, BITE
	dbw 25, AURORA_BEAM
	dbw 33, DOUBLE_TEAM
	dbw 41, ICE_BEAM
	dbw 49, BARRIER
	dbw 57, BLIZZARD
	db 0 ; no more level-up moves

GliscorEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, POISON_STING
	dbw 1, LEER
	dbw 9, MUD_SLAP
	dbw 17, FURY_CUTTER
	dbw 25, SCARY_FACE
	dbw 33, AERIAL_ACE
	dbw 41, EARTHQUAKE
	dbw 49, SLASH
	dbw 55, SWORDS_DANCE
	dbw 60, STONE_EDGE
	dbw 65, HYPER_BEAM
	db 0 ; no more level-up moves

MagnezoneEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, THUNDERSHOCK
	dbw 9, THUNDER_WAVE
	dbw 17, SUPERSONIC
	dbw 25, THUNDERBOLT
	dbw 33, SCREECH
	dbw 40, IRON_HEAD
	dbw 48, THUNDER
	dbw 55, FLASH
	dbw 60, FLASH_CANNON
	dbw 70, WILD_CHARGE
	dbw 80, HYPER_BEAM
	db 0 ; no more level-up moves

PorygonZEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, PSYBEAM
	dbw 9, AGILITY
	dbw 17, TRI_ATTACK
	dbw 25, RECOVER
	dbw 33, THUNDER
	dbw 41, PSYCHIC_M
	dbw 45, DARK_PULSE
	dbw 49, DOUBLE_TEAM
	dbw 57, FLASH_CANNON
	dbw 65, HYPER_BEAM
	db 0 ; no more level-up moves

SirfetchdEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, PECK
	dbw 1, LEER
	dbw 9, FURY_STRIKES
	dbw 17, AERIAL_ACE
	dbw 25, SLASH
	dbw 33, SWORDS_DANCE
	dbw 38, PROTECT
	dbw 43, IRON_HEAD
	dbw 50, CROSS_CHOP
	dbw 55, AGILITY
	dbw 60, FOCUS_BLAST
	dbw 65, HYPER_BEAM
	dbw 72, BRAVE_BIRD
	db 0 ; no more level-up moves

TangrowthEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, BIND
	dbw 1, GROWTH
	dbw 9, MEGA_DRAIN
	dbw 17, SLAM
	dbw 25, SLEEP_POWDER
	dbw 33, GIGA_DRAIN
	dbw 41, STUN_SPORE
	dbw 49, LEECH_SEED
	dbw 57, SOLARBEAM
	dbw 65, POWER_WHIP
	db 0 ; no more level-up moves

WyrdeerEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, GROWL
	dbw 9, PSYBEAM
	dbw 17, HYPNOSIS
	dbw 25, STOMP
	dbw 33, CONFUSION
	dbw 41, PSYCHIC_M
	dbw 49, AGILITY
	dbw 57, MEGAHORN
	db 0 ; no more level-up moves

FarigirafEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, GROWL
	dbw 1, CONFUSION
	dbw 1, BITE
	dbw 9, AMNESIA
	dbw 17, STOMP
	dbw 25, CRUNCH
	dbw 33, BATON_PASS
	dbw 41, FUTURE_SIGHT
	dbw 49, PSYCHIC_M
	dbw 57, HYPER_BEAM
	db 0 ; no more level-up moves

DudunsparceEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, RAGE
	dbw 1, DEFENSE_CURL
	dbw 9, MUD_SLAP
	dbw 17, GLARE
	dbw 25, BITE
	dbw 33, ANCIENTPOWER
	dbw 41, EARTHQUAKE
	dbw 49, COMET_PUNCH
	dbw 57, HYPER_BEAM
	db 0 ; no more level-up moves

UrsalunaEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 9, SLASH
	dbw 17, REST
	dbw 25, EARTHQUAKE
	dbw 33, CRUNCH
	dbw 41, THRASH
	dbw 49, SWORDS_DANCE
	dbw 57, HYPER_BEAM
	db 0 ; no more level-up moves

CorsolaKantoEvosAttacks:
	dbbw EVOLVE_LEVEL, 38, CURSOLA
	db 0 ; no more evolutions
	dbw 1, LICK
	dbw 7, HARDEN
	dbw 10, DISABLE
	dbw 13, SPITE
	dbw 16, CONFUSE_RAY
	dbw 19, AMNESIA
	dbw 22, CURSE
	dbw 25, NIGHT_SHADE
	dbw 28, PAIN_SPLIT
	dbw 31, WILL_O_WISP
	dbw 34, ANCIENTPOWER
	dbw 37, SHADOW_BALL
	dbw 40, MIRROR_COAT
	dbw 44, POWER_GEM
	db 0 ; no more level-up moves

CursolaEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, HYPNOSIS
	dbw 1, LICK
	dbw 1, HARDEN
	dbw 1, DISABLE
	dbw 1, SPITE
	dbw 16, CONFUSE_RAY
	dbw 19, AMNESIA
	dbw 22, CURSE
	dbw 25, NIGHT_SHADE
	dbw 28, PAIN_SPLIT
	dbw 31, WILL_O_WISP
	dbw 34, ANCIENTPOWER
	dbw 37, SHADOW_BALL
	dbw 42, MIRROR_COAT
	dbw 48, POWER_GEM
	dbw 54, PERISH_SONG
	db 0 ; no more level-up moves

RaichuOrangeEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, PSYCHIC_M
	dbw 1, THUNDER_WAVE
	dbw 1, DOUBLE_TEAM
	dbw 1, IRON_TAIL
	dbw 1, THUNDERBOLT
	dbw 1, CONFUSION
	db 0 ; no more level-up moves

DragoniteKantoEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, WING_ATTACK
	dbw 1, WRAP
	dbw 1, LEER
	dbw 8, THUNDER_WAVE
	dbw 15, TWISTER
	dbw 18, SUPERSONIC
	dbw 22, DRAGON_RAGE
	dbw 25, LIGHT_SCREEN
	dbw 29, SLAM
	dbw 34, MIST
	dbw 34, HAZE
	dbw 38, AGILITY
	dbw 47, SAFEGUARD
	dbw 54, WING_ATTACK
	dbw 61, OUTRAGE
	dbw 75, HYPER_BEAM
	db 0 ; no more level-up moves

ENDSECTION

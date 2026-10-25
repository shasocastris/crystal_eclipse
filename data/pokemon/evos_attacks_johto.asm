SECTION "Evolutions and Attacks 2", ROMX

EvosAttacksPointers2::
	dw ChikoritaEvosAttacks
	dw BayleefEvosAttacks
	dw MeganiumEvosAttacks
	dw CyndaquilEvosAttacks
	dw QuilavaEvosAttacks
	dw TyphlosionEvosAttacks
	dw TotodileEvosAttacks
	dw CroconawEvosAttacks
	dw FeraligatrEvosAttacks
	dw SentretEvosAttacks
	dw FurretEvosAttacks
	dw HoothootEvosAttacks
	dw NoctowlEvosAttacks
	dw LedybaEvosAttacks
	dw LedianEvosAttacks
	dw SpinarakEvosAttacks
	dw AriadosEvosAttacks
	dw CrobatEvosAttacks
	dw ChinchouEvosAttacks
	dw LanturnEvosAttacks
	dw PichuEvosAttacks
	dw CleffaEvosAttacks
	dw IgglybuffEvosAttacks
	dw TogepiEvosAttacks
	dw TogeticEvosAttacks
	dw NatuEvosAttacks
	dw XatuEvosAttacks
	dw MareepEvosAttacks
	dw FlaaffyEvosAttacks
	dw AmpharosEvosAttacks
	dw BellossomEvosAttacks
	dw MarillEvosAttacks
	dw AzumarillEvosAttacks
	dw SudowoodoEvosAttacks
	dw PolitoedEvosAttacks
	dw HoppipEvosAttacks
	dw SkiploomEvosAttacks
	dw JumpluffEvosAttacks
	dw AipomEvosAttacks
	dw SunkernEvosAttacks
	dw SunfloraEvosAttacks
	dw YanmaEvosAttacks
	dw WooperEvosAttacks
	dw QuagsireEvosAttacks
	dw EspeonEvosAttacks
	dw UmbreonEvosAttacks
	dw MurkrowEvosAttacks
	dw SlowkingEvosAttacks
	dw MisdreavusEvosAttacks
	dw UnownEvosAttacks
	dw WobbuffetEvosAttacks
	dw GirafarigEvosAttacks
	dw PinecoEvosAttacks
	dw ForretressEvosAttacks
	dw DunsparceEvosAttacks
	dw GligarEvosAttacks
	dw SteelixEvosAttacks
	dw SnubbullEvosAttacks
	dw GranbullEvosAttacks
	dw QwilfishEvosAttacks
	dw ScizorEvosAttacks
	dw ShuckleEvosAttacks
	dw HeracrossEvosAttacks
	dw SneaselEvosAttacks
	dw TeddiursaEvosAttacks
	dw UrsaringEvosAttacks
	dw SlugmaEvosAttacks
	dw MagcargoEvosAttacks
	dw SwinubEvosAttacks
	dw PiloswineEvosAttacks
	dw CorsolaEvosAttacks
	dw RemoraidEvosAttacks
	dw OctilleryEvosAttacks
	dw DelibirdEvosAttacks
	dw MantineEvosAttacks
	dw SkarmoryEvosAttacks
	dw HoundourEvosAttacks
	dw HoundoomEvosAttacks
	dw KingdraEvosAttacks
	dw PhanpyEvosAttacks
	dw DonphanEvosAttacks
	dw Porygon2EvosAttacks
	dw StantlerEvosAttacks
	dw SmeargleEvosAttacks
	dw TyrogueEvosAttacks
	dw HitmontopEvosAttacks
	dw SmoochumEvosAttacks
	dw ElekidEvosAttacks
	dw MagbyEvosAttacks
	dw MiltankEvosAttacks
	dw BlisseyEvosAttacks
	dw RaikouEvosAttacks
	dw EnteiEvosAttacks
	dw SuicuneEvosAttacks
	dw LarvitarEvosAttacks
	dw PupitarEvosAttacks
	dw TyranitarEvosAttacks
	dw LugiaEvosAttacks
	dw HoOhEvosAttacks
	dw CelebiEvosAttacks
.IndirectEnd::

ChikoritaEvosAttacks:
	dbbw EVOLVE_LEVEL, 18, BAYLEEF
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, GROWL
	dbw 4, RAZOR_LEAF
	dbw 7, REFLECT
	dbw 10, CONSTRICT
	dbw 13, POISONPOWDER
	dbw 16, FLAIL
	dbw 19, SYNTHESIS
	dbw 22, ANCIENTPOWER
	dbw 25, LEECH_SEED
	dbw 28, BODY_SLAM
	dbw 31, SEED_BOMB
	dbw 34, LIGHT_SCREEN
	dbw 37, COUNTER
	dbw 40, SAFEGUARD
	dbw 43, ENERGY_BALL
	dbw 46, SWORDS_DANCE
	dbw 50, SOLARBEAM
	db 0 ; no more level-up moves

BayleefEvosAttacks:
	dbbw EVOLVE_LEVEL, 36, MEGANIUM
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, GROWL
	dbw 4, RAZOR_LEAF
	dbw 7, REFLECT
	dbw 10, CONSTRICT
	dbw 13, POISONPOWDER
	dbw 16, FLAIL
	dbw 19, SYNTHESIS
	dbw 23, ANCIENTPOWER
	dbw 27, LEECH_SEED
	dbw 31, BODY_SLAM
	dbw 35, SEED_BOMB
	dbw 39, LIGHT_SCREEN
	dbw 43, COUNTER
	dbw 47, SAFEGUARD
	dbw 51, ENERGY_BALL
	dbw 55, SWORDS_DANCE
	dbw 59, SOLARBEAM
	db 0 ; no more level-up moves

MeganiumEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, PETAL_DANCE
	dbw 1, SCRATCH
	dbw 1, GROWL
	dbw 4, RAZOR_LEAF
	dbw 7, REFLECT
	dbw 10, CONSTRICT
	dbw 13, POISONPOWDER
	dbw 16, FLAIL
	dbw 19, SYNTHESIS
	dbw 23, ANCIENTPOWER
	dbw 27, LEECH_SEED
	dbw 31, BODY_SLAM
	dbw 35, SEED_BOMB
	dbw 39, LIGHT_SCREEN
	dbw 43, COUNTER
	dbw 47, SAFEGUARD
	dbw 51, ENERGY_BALL
	dbw 56, PETAL_DANCE
	dbw 61, SWORDS_DANCE
	dbw 66, SOLARBEAM
	db 0 ; no more level-up moves

CyndaquilEvosAttacks:
	dbbw EVOLVE_LEVEL, 18, QUILAVA
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 6, EMBER
	dbw 9, FIRE_SPIN
	dbw 12, SMOKESCREEN
	dbw 16, REVERSAL
	dbw 19, QUICK_ATTACK
	dbw 23, FLAME_WHEEL
	dbw 27, FORESIGHT
	dbw 31, THRASH
	dbw 36, SWIFT
	dbw 41, SUBMISSION
	dbw 46, FLAMETHROWER
	dbw 50, FIRE_BLAST
	db 0 ; no more level-up moves

QuilavaEvosAttacks:
	dbbw EVOLVE_LEVEL, 36, TYPHLOSION
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 6, EMBER
	dbw 9, FIRE_SPIN
	dbw 12, SMOKESCREEN
	dbw 17, REVERSAL
	dbw 21, QUICK_ATTACK
	dbw 26, FLAME_WHEEL
	dbw 31, FORESIGHT
	dbw 37, THRASH
	dbw 42, SWIFT
	dbw 48, SUBMISSION
	dbw 54, FLAMETHROWER
	dbw 60, FIRE_BLAST
	db 0 ; no more level-up moves

TyphlosionEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, KARATE_CHOP
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 6, EMBER
	dbw 9, FIRE_SPIN
	dbw 12, SMOKESCREEN
	dbw 17, REVERSAL
	dbw 21, QUICK_ATTACK
	dbw 26, FLAME_WHEEL
	dbw 31, FORESIGHT
	dbw 35, KARATE_CHOP
	dbw 38, THRASH
	dbw 45, SWIFT
	dbw 53, SUBMISSION
	dbw 60, FLAMETHROWER
	dbw 68, FIRE_BLAST
	db 0 ; no more level-up moves

TotodileEvosAttacks:
	dbbw EVOLVE_LEVEL, 18, CROCONAW
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 6, WATER_GUN
	dbw 10, RAZOR_WIND
	dbw 13, RAGE
	dbw 17, ANCIENTPOWER
	dbw 20, BITE
	dbw 23, SCARY_FACE
	dbw 27, THRASH
	dbw 30, WATERFALL
	dbw 33, CRUNCH
	dbw 36, SLASH
	dbw 40, ROCK_SLIDE
	dbw 43, SCREECH
	dbw 47, CRABHAMMER
	dbw 52, HYDRO_PUMP
	db 0 ; no more level-up moves

CroconawEvosAttacks:
	dbbw EVOLVE_LEVEL, 36, FERALIGATR
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 6, WATER_GUN
	dbw 10, RAZOR_WIND
	dbw 13, RAGE
	dbw 17, ANCIENTPOWER
	dbw 21, BITE
	dbw 24, SCARY_FACE
	dbw 28, THRASH
	dbw 32, WATERFALL
	dbw 36, CRUNCH
	dbw 40, SLASH
	dbw 44, ROCK_SLIDE
	dbw 48, SCREECH
	dbw 53, CRABHAMMER
	dbw 58, HYDRO_PUMP
	db 0 ; no more level-up moves

FeraligatrEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, CRUNCH
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 6, WATER_GUN
	dbw 10, RAZOR_WIND
	dbw 13, RAGE
	dbw 17, ANCIENTPOWER
	dbw 21, BITE
	dbw 24, SCARY_FACE
	dbw 29, THRASH
	dbw 34, WATERFALL
	dbw 38, CRUNCH
	dbw 42, SLASH
	dbw 47, ROCK_SLIDE
	dbw 52, SCREECH
	dbw 57, CRABHAMMER
	dbw 62, HYDRO_PUMP
	db 0 ; no more level-up moves

SentretEvosAttacks:
	dbbw EVOLVE_LEVEL, 15, FURRET
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 5, DEFENSE_CURL
	dbw 8, PURSUIT
	dbw 11, QUICK_ATTACK
	dbw 14, REVERSAL
	dbw 17, FURY_STRIKES
	dbw 21, FOCUS_ENERGY
	dbw 25, SLAM
	dbw 29, SLASH
	dbw 33, REST
	dbw 37, DOUBLE_EDGE
	dbw 41, AMNESIA
	db 0 ; no more level-up moves

FurretEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, AGILITY
	dbw 1, SCRATCH
	dbw 5, DEFENSE_CURL
	dbw 8, PURSUIT
	dbw 11, QUICK_ATTACK
	dbw 14, REVERSAL
	dbw 14, AGILITY
	dbw 18, FURY_STRIKES
	dbw 23, FOCUS_ENERGY
	dbw 28, SLAM
	dbw 33, SLASH
	dbw 38, REST
	dbw 43, DOUBLE_EDGE
	dbw 48, AMNESIA
	db 0 ; no more level-up moves

HoothootEvosAttacks:
	dbbw EVOLVE_LEVEL, 20, NOCTOWL
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, GROWL
	dbw 5, GUST
	dbw 8, FORESIGHT
	dbw 11, PECK
	dbw 14, SUPERSONIC
	dbw 17, CONFUSION
	dbw 20, ROAR
	dbw 23, WING_ATTACK
	dbw 26, HYPNOSIS
	dbw 29, FAINT_ATTACK
	dbw 32, REFLECT
	dbw 35, AIR_SLASH
	dbw 38, MIRROR_MOVE
	dbw 41, TAKE_DOWN
	dbw 44, HYPER_VOICE
	dbw 47, DRILL_PECK
	dbw 50, DREAM_EATER
	db 0 ; no more level-up moves

NoctowlEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, GROWL
	dbw 5, GUST
	dbw 8, FORESIGHT
	dbw 11, PECK
	dbw 14, SUPERSONIC
	dbw 17, CONFUSION
	dbw 21, ROAR
	dbw 25, WING_ATTACK
	dbw 29, HYPNOSIS
	dbw 33, FAINT_ATTACK
	dbw 37, REFLECT
	dbw 41, AIR_SLASH
	dbw 45, MIRROR_MOVE
	dbw 49, TAKE_DOWN
	dbw 53, HYPER_VOICE
	dbw 58, DRILL_PECK
	dbw 63, DREAM_EATER
	db 0 ; no more level-up moves

LedybaEvosAttacks:
	dbbw EVOLVE_LEVEL, 18, LEDIAN
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 5, SUPERSONIC
	dbw 8, LEECH_LIFE
	dbw 11, COMET_PUNCH
	dbw 14, LIGHT_SCREEN
	dbw 17, SWIFT
	dbw 20, REFLECT
	dbw 23, PSYBEAM
	dbw 26, SAFEGUARD
	dbw 29, PLAY_ROUGH
	dbw 32, BATON_PASS
	dbw 35, DAZZLING_GLEAM
	dbw 38, AGILITY
	dbw 41, BUG_BUZZ
	dbw 45, DOUBLE_EDGE
	db 0 ; no more level-up moves

LedianEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 5, SUPERSONIC
	dbw 8, LEECH_LIFE
	dbw 11, COMET_PUNCH
	dbw 15, LIGHT_SCREEN
	dbw 19, SWIFT
	dbw 23, REFLECT
	dbw 27, PSYBEAM
	dbw 31, SAFEGUARD
	dbw 35, PLAY_ROUGH
	dbw 39, BATON_PASS
	dbw 43, DAZZLING_GLEAM
	dbw 47, AGILITY
	dbw 51, BUG_BUZZ
	dbw 58, DOUBLE_EDGE
	db 0 ; no more level-up moves

SpinarakEvosAttacks:
	dbbw EVOLVE_LEVEL, 22, ARIADOS
	db 0 ; no more evolutions
	dbw 1, POISON_STING
	dbw 1, STRING_SHOT
	dbw 5, CONSTRICT
	dbw 8, SCARY_FACE
	dbw 11, PURSUIT
	dbw 14, DISABLE
	dbw 17, NIGHT_SHADE
	dbw 20, SONICBOOM
	dbw 23, LEECH_LIFE
	dbw 26, BATON_PASS
	dbw 29, FURY_STRIKES
	dbw 32, TWINEEDLE
	dbw 35, MEAN_LOOK
	dbw 38, PSYBEAM
	dbw 41, X_SCISSOR
	dbw 45, AGILITY
	dbw 49, PSYCHIC_M
	db 0 ; no more level-up moves

AriadosEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, DIG
	dbw 1, POISON_STING
	dbw 1, STRING_SHOT
	dbw 5, CONSTRICT
	dbw 8, SCARY_FACE
	dbw 11, PURSUIT
	dbw 14, DISABLE
	dbw 17, NIGHT_SHADE
	dbw 20, SONICBOOM
	dbw 21, DIG
	dbw 24, LEECH_LIFE
	dbw 27, BATON_PASS
	dbw 30, FURY_STRIKES
	dbw 34, TWINEEDLE
	dbw 37, MEAN_LOOK
	dbw 41, PSYBEAM
	dbw 44, X_SCISSOR
	dbw 48, AGILITY
	dbw 53, PSYCHIC_M
	db 0 ; no more level-up moves

CrobatEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, TOXIC
	dbw 1, LEECH_LIFE
	dbw 5, SUPERSONIC
	dbw 9, GUST
	dbw 13, BITE
	dbw 17, SLUDGE
	dbw 21, CONFUSE_RAY
	dbw 27, WING_ATTACK
	dbw 33, FAINT_ATTACK
	dbw 39, MEAN_LOOK
	dbw 45, AIR_SLASH
	dbw 51, SLUDGE_BOMB
	dbw 57, SCREECH
	dbw 63, POISON_JAB
	dbw 69, HAZE
	dbw 75, CRUNCH
	dbw 81, BRAVE_BIRD
	db 0 ; no more level-up moves

ChinchouEvosAttacks:
	dbbw EVOLVE_LEVEL, 27, LANTURN
	db 0 ; no more evolutions
	dbw 1, BUBBLE
	dbw 1, SUPERSONIC
	dbw 6, FLAIL
	dbw 9, THUNDER_WAVE
	dbw 12, WATER_GUN
	dbw 17, MUD_SLAP
	dbw 20, SPARK
	dbw 23, TAKE_DOWN
	dbw 28, BUBBLEBEAM
	dbw 31, CONFUSE_RAY
	dbw 34, THUNDERBOLT
	dbw 39, AURORA_BEAM
	dbw 42, SCREECH
	dbw 45, HYDRO_PUMP
	dbw 48, THUNDER
	db 0 ; no more level-up moves

LanturnEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, BUBBLE
	dbw 1, SUPERSONIC
	dbw 6, FLAIL
	dbw 9, THUNDER_WAVE
	dbw 12, WATER_GUN
	dbw 17, MUD_SLAP
	dbw 20, SPARK
	dbw 23, TAKE_DOWN
	dbw 30, BUBBLEBEAM
	dbw 35, CONFUSE_RAY
	dbw 40, THUNDERBOLT
	dbw 47, AURORA_BEAM
	dbw 52, SCREECH
	dbw 57, HYDRO_PUMP
	dbw 62, THUNDER
	db 0 ; no more level-up moves

PichuEvosAttacks:
	dbbw EVOLVE_HAPPINESS, TR_ANYTIME, PIKACHU
	db 0 ; no more evolutions
	dbw 1, CHARM
	dbw 1, THUNDERSHOCK
	dbw 4, LEER
	dbw 6, QUICK_ATTACK
	dbw 9, THUNDER_WAVE
	dbw 14, THUNDERPUNCH
	dbw 16, SWEET_KISS
	db 0 ; no more level-up moves

CleffaEvosAttacks:
	dbbw EVOLVE_HAPPINESS, TR_ANYTIME, CLEFAIRY
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, CHARM
	dbw 4, DISARM_VOICE
	dbw 6, ENCORE
	dbw 9, COMET_PUNCH
	dbw 13, SING
	dbw 16, MEGA_PUNCH
	dbw 18, SWEET_KISS
	db 0 ; no more level-up moves

IgglybuffEvosAttacks:
	dbbw EVOLVE_HAPPINESS, TR_ANYTIME, JIGGLYPUFF
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, CHARM
	dbw 4, DISARM_VOICE
	dbw 6, SING
	dbw 9, COMET_PUNCH
	dbw 13, DEFENSE_CURL
	dbw 16, MEGA_PUNCH
	dbw 18, SWEET_KISS
	db 0 ; no more level-up moves

TogepiEvosAttacks:
	dbbw EVOLVE_HAPPINESS, TR_ANYTIME, TOGETIC
	db 0 ; no more evolutions
	dbw 1, CHARM
	dbw 1, FURY_STRIKES
	dbw 4, METRONOME
	dbw 6, GUST
	dbw 9, MOONLIGHT
	dbw 11, DISARM_VOICE
	dbw 14, SWEET_KISS
	dbw 17, POWDER_SNOW
	dbw 20, DISABLE
	dbw 23, SWIFT
	dbw 26, ENCORE
	dbw 28, AIR_SLASH
	dbw 31, SAFEGUARD
	dbw 34, GIGA_DRAIN
	dbw 37, MIMIC
	dbw 40, DAZZLING_GLEAM
	dbw 42, GROWTH
	dbw 44, MOONBLAST
	dbw 45, MINIMIZE
	db 0 ; no more level-up moves

TogeticEvosAttacks:
	dbww EVOLVE_ITEM, SUN_STONE, TOGEKISS
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, SWIFT
	dbw 1, FURY_STRIKES
	dbw 1, CHARM
	dbw 4, GUST
	dbw 7, METRONOME
	dbw 10, DISARM_VOICE
	dbw 13, MOONLIGHT
	dbw 17, ANCIENTPOWER
	dbw 20, SWEET_KISS
	dbw 24, HEADBUTT
	dbw 28, ENCORE
	dbw 32, AIR_SLASH
	dbw 36, SAFEGUARD
	dbw 40, DAZZLING_GLEAM
	dbw 44, GROWTH
	dbw 48, GIGA_DRAIN
	dbw 52, MOONBLAST
	dbw 56, DOUBLE_EDGE
	db 0 ; no more level-up moves

NatuEvosAttacks:
	dbbw EVOLVE_LEVEL, 25, XATU
	db 0 ; no more evolutions
	dbw 1, LEER
	dbw 1, PECK
	dbw 5, QUICK_ATTACK
	dbw 9, NIGHT_SHADE
	dbw 13, TELEPORT
	dbw 17, FAINT_ATTACK
	dbw 21, FUTURE_SIGHT
	dbw 25, CONFUSE_RAY
	dbw 29, STEEL_WING
	dbw 33, HAZE
	dbw 37, AIR_SLASH
	dbw 41, DRILL_PECK
	dbw 45, PSYCHIC_M
	db 0 ; no more level-up moves

XatuEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, LEER
	dbw 1, PECK
	dbw 5, QUICK_ATTACK
	dbw 9, NIGHT_SHADE
	dbw 13, TELEPORT
	dbw 17, FAINT_ATTACK
	dbw 21, CONFUSE_RAY
	dbw 26, FUTURE_SIGHT
	dbw 32, HAZE
	dbw 38, STEEL_WING
	dbw 44, AIR_SLASH
	dbw 52, DRILL_PECK
	dbw 60, PSYCHIC_M
	db 0 ; no more level-up moves

MareepEvosAttacks:
	dbbw EVOLVE_LEVEL, 15, FLAAFFY
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, GROWL
	dbw 5, THUNDERSHOCK
	dbw 9, SCREECH
	dbw 13, BODY_SLAM
	dbw 17, THUNDER_WAVE
	dbw 21, THUNDERBOLT
	dbw 25, SAFEGUARD
	dbw 29, THUNDER
	dbw 33, LIGHT_SCREEN
	dbw 37, ZAP_CANNON
	dbw 41, REFLECT
	db 0 ; no more level-up moves

FlaaffyEvosAttacks:
	dbbw EVOLVE_LEVEL, 30, AMPHAROS
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, GROWL
	dbw 9, THUNDERSHOCK
	dbw 13, SCREECH
	dbw 18, BODY_SLAM
	dbw 22, THUNDER_WAVE
	dbw 27, THUNDERBOLT
	dbw 32, SAFEGUARD
	dbw 38, THUNDER
	dbw 44, LIGHT_SCREEN
	dbw 48, ZAP_CANNON
	dbw 51, REFLECT
	db 0 ; no more level-up moves

AmpharosEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, THUNDERPUNCH
	dbw 1, SCRATCH
	dbw 1, GROWL
	dbw 9, THUNDERSHOCK
	dbw 13, SCREECH
	dbw 18, BODY_SLAM
	dbw 22, THUNDER_WAVE
	dbw 29, THUNDERPUNCH
	dbw 36, SAFEGUARD
	dbw 42, THUNDERBOLT
	dbw 49, LIGHT_SCREEN
	dbw 57, THUNDER
	dbw 62, ZAP_CANNON
	dbw 65, REFLECT
	db 0 ; no more level-up moves

BellossomEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, MEGA_DRAIN
	dbw 1, SWEET_SCENT
	dbw 1, STUN_SPORE
	dbw 1, PETAL_DANCE
	dbw 29, LEECH_SEED
	dbw 35, SEED_BOMB
	dbw 41, MOONBLAST
	dbw 47, ENERGY_BALL
	dbw 53, PETAL_DANCE
	dbw 65, SOLARBEAM
	dbw 78, DAZZLING_GLEAM
	db 0 ; no more level-up moves

MarillEvosAttacks:
	dbbw EVOLVE_LEVEL, 18, AZUMARILL
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 3, DEFENSE_CURL
	dbw 6, LEER
	dbw 8, PRESENT
	dbw 10, WATER_GUN
	dbw 13, AMNESIA
	dbw 15, ROLLOUT
	dbw 17, BELLY_DRUM
	dbw 21, BUBBLEBEAM
	dbw 25, PERISH_SONG
	dbw 28, PLAY_ROUGH
	dbw 32, FUTURE_SIGHT
	dbw 36, RAIN_DANCE
	dbw 40, LIGHT_SCREEN
	db 0 ; no more level-up moves

AzumarillEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 3, DEFENSE_CURL
	dbw 6, LEER
	dbw 8, PRESENT
	dbw 10, WATER_GUN
	dbw 13, AMNESIA
	dbw 15, ROLLOUT
	dbw 17, BELLY_DRUM
	dbw 25, BUBBLEBEAM
	dbw 30, PERISH_SONG
	dbw 36, PLAY_ROUGH
	dbw 42, FUTURE_SIGHT
	dbw 48, RAIN_DANCE
	dbw 53, LIGHT_SCREEN
	db 0 ; no more level-up moves

SudowoodoEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, ROCK_THROW
	dbw 1, MIMIC
	dbw 10, FLAIL
	dbw 17, KARATE_CHOP
	dbw 25, ROCK_SLIDE
	dbw 33, COUNTER
	dbw 41, FAINT_ATTACK
	dbw 49, SLAM
	dbw 57, STONE_EDGE
	dbw 63, DOUBLE_EDGE
	dbw 70, SELFDESTRUCT
	db 0 ; no more level-up moves

PolitoedEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, PERISH_SONG
	dbw 1, WATER_GUN
	dbw 5, HYPNOSIS
	dbw 15, FURY_STRIKES
	dbw 25, BUBBLEBEAM
	dbw 30, SCALD
	dbw 35, BODY_SLAM
	dbw 39, AQUA_JET
	dbw 45, PERISH_SONG
	dbw 51, HYPER_VOICE
	dbw 57, SWAGGER
	dbw 66, HYDRO_PUMP
	dbw 75, RAIN_DANCE
	db 0 ; no more level-up moves

HoppipEvosAttacks:
	dbbw EVOLVE_LEVEL, 18, SKIPLOOM
	db 0 ; no more evolutions
	dbw 1, SPLASH
	dbw 1, ABSORB
	dbw 4, LEER
	dbw 6, SYNTHESIS
	dbw 8, SCRATCH
	dbw 11, POISONPOWDER
	dbw 14, CONFUSION
	dbw 16, STUN_SPORE
	dbw 19, MEGA_DRAIN
	dbw 22, ENCORE
	dbw 25, PAY_DAY
	dbw 28, SPORE
	dbw 31, AIR_SLASH
	dbw 34, LEECH_SEED
	dbw 37, GIGA_DRAIN
	dbw 40, SAFEGUARD
	dbw 43, ENERGY_BALL
	dbw 46, REFLECT
	dbw 49, AMNESIA
	db 0 ; no more level-up moves

SkiploomEvosAttacks:
	dbbw EVOLVE_LEVEL, 27, JUMPLUFF
	db 0 ; no more evolutions
	dbw 1, SPLASH
	dbw 1, ABSORB
	dbw 4, LEER
	dbw 6, SYNTHESIS
	dbw 8, SCRATCH
	dbw 11, POISONPOWDER
	dbw 14, CONFUSION
	dbw 17, STUN_SPORE
	dbw 20, MEGA_DRAIN
	dbw 23, ENCORE
	dbw 27, PAY_DAY
	dbw 31, SPORE
	dbw 35, AIR_SLASH
	dbw 39, LEECH_SEED
	dbw 43, GIGA_DRAIN
	dbw 47, SAFEGUARD
	dbw 51, ENERGY_BALL
	dbw 55, REFLECT
	dbw 59, AMNESIA
	db 0 ; no more level-up moves

JumpluffEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SPLASH
	dbw 1, ABSORB
	dbw 4, LEER
	dbw 6, SYNTHESIS
	dbw 8, SCRATCH
	dbw 11, POISONPOWDER
	dbw 14, CONFUSION
	dbw 17, STUN_SPORE
	dbw 20, MEGA_DRAIN
	dbw 24, ENCORE
	dbw 28, PAY_DAY
	dbw 33, SPORE
	dbw 38, AIR_SLASH
	dbw 43, LEECH_SEED
	dbw 48, GIGA_DRAIN
	dbw 53, SAFEGUARD
	dbw 58, ENERGY_BALL
	dbw 63, REFLECT
	dbw 68, AMNESIA
	db 0 ; no more level-up moves

AipomEvosAttacks:
	dbww EVOLVE_ITEM, MOON_STONE, AMBIPOM
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 3, SCREECH
	dbw 6, MUD_SLAP
	dbw 9, COUNTER
	dbw 12, BATON_PASS
	dbw 16, PURSUIT
	dbw 19, FURY_STRIKES
	dbw 23, SLAM
	dbw 27, SWIFT
	dbw 31, SPITE
	dbw 36, FAINT_ATTACK
	dbw 44, AGILITY
	db 0 ; no more level-up moves

SunkernEvosAttacks:
	dbww EVOLVE_ITEM, SUN_STONE, SUNFLORA
	db 0 ; no more evolutions
	dbw 1, ABSORB
	dbw 4, GROWTH
	dbw 10, MEGA_DRAIN
	dbw 19, SUNNY_DAY
	dbw 25, EMBER
	dbw 31, SYNTHESIS
	dbw 38, FIRE_SPIN
	dbw 46, GIGA_DRAIN
	db 0 ; no more level-up moves

SunfloraEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, ABSORB
	dbw 1, SCRATCH
	dbw 4, GROWTH
	dbw 10, RAZOR_LEAF
	dbw 19, SUNNY_DAY
	dbw 25, FLAME_WHEEL
	dbw 31, PETAL_DANCE
	dbw 38, FIRE_PUNCH
	dbw 46, SOLARBEAM
	db 0 ; no more level-up moves

YanmaEvosAttacks:
	dbww EVOLVE_ITEM, LEAF_STONE, YANMEGA
	db 0 ; no more evolutions
	dbw 1, GUST
	dbw 1, FORESIGHT
	dbw 7, QUICK_ATTACK
	dbw 10, LEECH_LIFE
	dbw 13, DOUBLE_TEAM
	dbw 16, SONICBOOM
	dbw 19, ROAR
	dbw 22, REVERSAL
	dbw 25, PROTECT
	dbw 28, ANCIENTPOWER
	dbw 31, SUPERSONIC
	dbw 34, WING_ATTACK
	dbw 37, SCREECH
	dbw 40, BUG_BUZZ
	db 0 ; no more level-up moves

WooperEvosAttacks:
	dbbw EVOLVE_LEVEL, 20, QUAGSIRE
	db 0 ; no more evolutions
	dbw 1, WATER_GUN
	dbw 1, LEER
	dbw 7, SLAM
	dbw 12, SAFEGUARD
	dbw 17, BODY_SLAM
	dbw 22, AMNESIA
	dbw 27, WATERFALL
	dbw 31, RAIN_DANCE
	dbw 35, EARTHQUAKE
	dbw 39, MIST
	dbw 43, ANCIENTPOWER
	dbw 47, HAZE
	db 0 ; no more level-up moves

QuagsireEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, WATER_GUN
	dbw 1, LEER
	dbw 7, SLAM
	dbw 12, SAFEGUARD
	dbw 17, BODY_SLAM
	dbw 23, AMNESIA
	dbw 29, WATERFALL
	dbw 35, RAIN_DANCE
	dbw 41, EARTHQUAKE
	dbw 47, MIST
	dbw 53, ANCIENTPOWER
	dbw 59, HAZE
	db 0 ; no more level-up moves

EspeonEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, CONFUSION
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 8, MUD_SLAP
	dbw 16, CONFUSION
	dbw 20, FLAIL
	dbw 23, QUICK_ATTACK
	dbw 27, CHARM
	dbw 30, SWIFT
	dbw 33, PSYBEAM
	dbw 36, TRI_ATTACK
	dbw 42, PSYCH_UP
	dbw 47, PSYCHIC_M
	dbw 52, MORNING_SUN
	dbw 58, DAZZLING_GLEAM
	db 0 ; no more level-up moves

UmbreonEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, PURSUIT
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 8, MUD_SLAP
	dbw 16, PURSUIT
	dbw 20, FLAIL
	dbw 23, QUICK_ATTACK
	dbw 27, CHARM
	dbw 31, FAINT_ATTACK
	dbw 35, CONFUSE_RAY
	dbw 39, MOONBLAST
	dbw 43, MEAN_LOOK
	dbw 47, SHADOW_CLAW
	dbw 51, SCREECH
	dbw 55, DARK_PULSE
	dbw 59, MOONLIGHT
	db 0 ; no more level-up moves

MurkrowEvosAttacks:
	dbww EVOLVE_ITEM, MOON_STONE, HONCHKROW
	db 0 ; no more evolutions
	dbw 1, PECK
	dbw 6, QUICK_ATTACK
	dbw 11, PURSUIT
	dbw 16, HAZE
	dbw 21, WING_ATTACK
	dbw 26, NIGHT_SHADE
	dbw 31, FAINT_ATTACK
	dbw 36, DRILL_PECK
	dbw 41, THIEF
	dbw 46, MIRROR_MOVE
	db 0 ; no more level-up moves

SlowkingEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, CURSE
	dbw 1, SCRATCH
	dbw 6, GROWL
	dbw 10, STOMP
	dbw 15, WATER_GUN
	dbw 18, SAFEGUARD
	dbw 20, CONFUSION
	dbw 25, FUTURE_SIGHT
	dbw 29, DISABLE
	dbw 32, HEADBUTT
	dbw 35, BELLY_DRUM
	dbw 38, SCALD
	dbw 43, SWAGGER
	dbw 48, ZEN_HEADBUTT
	dbw 53, AMNESIA
	dbw 58, DAZZLING_GLEAM
	dbw 62, PSYCHIC_M
	db 0 ; no more level-up moves

MisdreavusEvosAttacks:
	dbww EVOLVE_ITEM, MOON_STONE, MISMAGIUS
	db 0 ; no more evolutions
	dbw 1, GROWL
	dbw 1, PSYWAVE
	dbw 6, SPITE
	dbw 9, PSYBEAM
	dbw 13, CONFUSE_RAY
	dbw 16, SHADOW_BALL
	dbw 19, SCREECH
	dbw 23, DAZZLING_GLEAM
	dbw 27, MEAN_LOOK
	dbw 31, DARK_PULSE
	dbw 35, DESTINY_BOND
	dbw 39, PSYCHIC_M
	dbw 43, PAIN_SPLIT
	dbw 46, PERISH_SONG
	db 0 ; no more level-up moves

UnownEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, HIDDEN_POWER
	dbw 1, PSYWAVE
	dbw 1, ANCIENTPOWER
	dbw 1, FUTURE_SIGHT
	db 0 ; no more level-up moves

WobbuffetEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, COUNTER
	dbw 1, MIRROR_COAT
	dbw 1, SAFEGUARD
	dbw 1, DESTINY_BOND
	db 0 ; no more level-up moves

GirafarigEvosAttacks:
	dbbw EVOLVE_LEVEL, 32, FARIGIRAF
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 3, GROWL
	dbw 5, CONFUSION
	dbw 8, BITE
	dbw 11, AMNESIA
	dbw 14, STOMP
	dbw 17, FAINT_ATTACK
	dbw 21, TAKE_DOWN
	dbw 25, AGILITY
	dbw 29, FUTURE_SIGHT
	dbw 33, BATON_PASS
	dbw 38, PSYBEAM
	dbw 43, FORESIGHT
	dbw 48, CRUNCH
	dbw 54, PSYCH_UP
	dbw 60, PSYCHIC_M
	db 0 ; no more level-up moves

PinecoEvosAttacks:
	dbbw EVOLVE_LEVEL, 31, FORRETRESS
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, PROTECT
	dbw 8, SELFDESTRUCT
	dbw 11, PIN_MISSILE
	dbw 15, TAKE_DOWN
	dbw 19, SWIFT
	dbw 22, RAPID_SPIN
	dbw 25, REFLECT
	dbw 29, IRON_HEAD
	dbw 33, FLAIL
	dbw 43, SPIKES
	dbw 50, DOUBLE_EDGE
	db 0 ; no more level-up moves

ForretressEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, PROTECT
	dbw 8, SELFDESTRUCT
	dbw 11, PIN_MISSILE
	dbw 15, TAKE_DOWN
	dbw 19, SWIFT
	dbw 22, RAPID_SPIN
	dbw 25, REFLECT
	dbw 30, IRON_HEAD
	dbw 34, FLAIL
	dbw 49, SPIKES
	dbw 59, DOUBLE_EDGE
	db 0 ; no more level-up moves

DunsparceEvosAttacks:
	dbbw EVOLVE_LEVEL, 36, DUDUNSPARC
	db 0 ; no more evolutions
	dbw 1, RAGE
	dbw 5, DEFENSE_CURL
	dbw 9, MUD_SLAP
	dbw 13, GLARE
	dbw 18, ANCIENTPOWER
	dbw 22, SPITE
	dbw 26, PURSUIT
	dbw 28, BITE
	dbw 30, SCREECH
	dbw 34, ROCK_SLIDE
	dbw 38, TAKE_DOWN
	db 0 ; no more level-up moves

GligarEvosAttacks:
	dbww EVOLVE_ITEM, MOON_STONE, GLISCOR
	db 0 ; no more evolutions
	dbw 1, POISON_STING
	dbw 6, MUD_SLAP
	dbw 9, RAZOR_WIND
	dbw 13, HARDEN
	dbw 17, METAL_CLAW
	dbw 20, QUICK_ATTACK
	dbw 24, WING_ATTACK
	dbw 28, FAINT_ATTACK
	dbw 32, COUNTER
	dbw 36, SLASH
	dbw 40, SCREECH
	dbw 44, EARTHQUAKE
	db 0 ; no more level-up moves

SteelixEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, IRON_TAIL
	dbw 1, MUD_SLAP
	dbw 1, SCRATCH
	dbw 1, HARDEN
	dbw 1, BIND
	dbw 6, SCREECH
	dbw 9, ROCK_THROW
	dbw 14, RAGE
	dbw 17, FLAIL
	dbw 22, SANDSTORM
	dbw 25, SLAM
	dbw 30, ROCK_SLIDE
	dbw 34, DRAGONBREATH
	dbw 38, CURSE
	dbw 42, IRON_HEAD
	dbw 46, IRON_TAIL
	dbw 50, CRUNCH
	dbw 54, EARTHQUAKE
	dbw 58, BODY_SLAM
	dbw 62, SKULL_BASH
	db 0 ; no more level-up moves

SnubbullEvosAttacks:
	dbbw EVOLVE_LEVEL, 23, GRANBULL
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, SCARY_FACE
	dbw 4, FAINT_ATTACK
	dbw 6, LEER
	dbw 8, BITE
	dbw 10, CHARM
	dbw 13, LICK
	dbw 16, HEAL_BELL
	dbw 19, PRESENT
	dbw 22, REFLECT
	dbw 26, CRUNCH
	dbw 30, METRONOME
	dbw 34, PLAY_ROUGH
	dbw 39, ROAR
	dbw 43, TAKE_DOWN
	db 0 ; no more level-up moves

GranbullEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, SCARY_FACE
	dbw 4, FAINT_ATTACK
	dbw 6, LEER
	dbw 8, BITE
	dbw 10, CHARM
	dbw 13, LICK
	dbw 16, HEAL_BELL
	dbw 19, PRESENT
	dbw 22, REFLECT
	dbw 28, CRUNCH
	dbw 33, METRONOME
	dbw 38, PLAY_ROUGH
	dbw 44, ROAR
	dbw 51, TAKE_DOWN
	db 0 ; no more level-up moves

QwilfishEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SPIKES
	dbw 1, SCRATCH
	dbw 1, POISON_STING
	dbw 7, HARDEN
	dbw 11, FLAIL
	dbw 15, MINIMIZE
	dbw 19, WATER_GUN
	dbw 23, HAZE
	dbw 27, PIN_MISSILE
	dbw 31, POISON_JAB
	dbw 35, BUBBLEBEAM
	dbw 39, SUPERSONIC
	dbw 43, WATERFALL
	dbw 46, TAKE_DOWN
	dbw 50, HYDRO_PUMP
	db 0 ; no more level-up moves

ScizorEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, METAL_CLAW
	dbw 1, QUICK_ATTACK
	dbw 1, LEER
	dbw 6, FOCUS_ENERGY
	dbw 9, REVERSAL
	dbw 12, PURSUIT
	dbw 15, TWINEEDLE
	dbw 18, FALSE_SWIPE
	dbw 21, X_SCISSOR
	dbw 24, AGILITY
	dbw 27, COUNTER
	dbw 30, METAL_CLAW
	dbw 33, BATON_PASS
	dbw 36, SLASH
	dbw 40, LIGHT_SCREEN
	dbw 44, RAZOR_WIND
	dbw 48, SWORDS_DANCE
	dbw 53, BULLET_PUNCH
	dbw 58, DOUBLE_TEAM
	dbw 65, IRON_HEAD
	db 0 ; no more level-up moves

ShuckleEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, CONSTRICT
	dbw 1, HARDEN
	dbw 9, WRAP
	dbw 14, ENCORE
	dbw 23, SAFEGUARD
	dbw 37, REST
	dbw 50, SWEET_SCENT
	db 0 ; no more level-up moves

HeracrossEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 6, HORN_ATTACK
	dbw 12, ENDURE
	dbw 15, FURY_STRIKES
	dbw 19, HARDEN
	dbw 27, COUNTER
	dbw 31, FLAIL
	dbw 35, TAKE_DOWN
	dbw 40, STRENGTH
	dbw 44, REVERSAL
	dbw 49, CROSS_CHOP
	dbw 54, MEGAHORN
	db 0 ; no more level-up moves

SneaselEvosAttacks:
	dbww EVOLVE_ITEM, MOON_STONE, WEAVILE
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 9, QUICK_ATTACK
	dbw 13, BITE
	dbw 17, SCREECH
	dbw 21, ICY_WIND
	dbw 25, FAINT_ATTACK
	dbw 29, SPITE
	dbw 33, FURY_STRIKES
	dbw 37, ICE_PUNCH
	dbw 41, ICE_SHARD
	dbw 45, AGILITY
	dbw 49, SLASH
	dbw 53, REFLECT
	dbw 57, METAL_CLAW
	db 0 ; no more level-up moves

TeddiursaEvosAttacks:
	dbbw EVOLVE_LEVEL, 30, URSARING
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 8, LICK
	dbw 12, FOCUS_ENERGY
	dbw 15, FURY_STRIKES
	dbw 19, SEISMIC_TOSS
	dbw 22, FAINT_ATTACK
	dbw 25, METAL_CLAW
	dbw 29, REST
	dbw 33, TAKE_DOWN
	dbw 36, SLASH
	dbw 40, COUNTER
	dbw 47, CRUNCH
	dbw 50, THRASH
	db 0 ; no more level-up moves

UrsaringEvosAttacks:
	dbww EVOLVE_ITEM, MOON_STONE, URSALUNA
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 8, LICK
	dbw 12, FOCUS_ENERGY
	dbw 15, FURY_STRIKES
	dbw 19, SEISMIC_TOSS
	dbw 22, FAINT_ATTACK
	dbw 25, METAL_CLAW
	dbw 29, REST
	dbw 34, TAKE_DOWN
	dbw 39, SLASH
	dbw 44, COUNTER
	dbw 54, CRUNCH
	dbw 59, THRASH
	db 0 ; no more level-up moves

SlugmaEvosAttacks:
	dbbw EVOLVE_LEVEL, 38, MAGCARGO
	db 0 ; no more evolutions
	dbw 1, SLUDGE
	dbw 8, EMBER
	dbw 15, ROCK_THROW
	dbw 22, HARDEN
	dbw 29, FLAMETHROWER
	dbw 36, AMNESIA
	dbw 43, ROCK_SLIDE
	dbw 50, BODY_SLAM
	dbw 55, POWER_GEM
	dbw 60, BARRIER
	db 0 ; no more level-up moves

MagcargoEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SLUDGE
	dbw 8, EMBER
	dbw 15, ROCK_THROW
	dbw 22, HARDEN
	dbw 29, FLAMETHROWER
	dbw 36, AMNESIA
	dbw 48, ROCK_SLIDE
	dbw 58, BODY_SLAM
	dbw 64, POWER_GEM
	dbw 70, BARRIER
	db 0 ; no more level-up moves

SwinubEvosAttacks:
	dbbw EVOLVE_LEVEL, 33, PILOSWINE
	db 0 ; no more evolutions
	dbw 1, HORN_ATTACK
	dbw 10, POWDER_SNOW
	dbw 14, ANCIENTPOWER
	dbw 19, ENDURE
	dbw 24, BITE
	dbw 28, TAKE_DOWN
	dbw 32, ROCK_SLIDE
	dbw 36, ICE_SHARD
	dbw 39, MIST
	dbw 43, EARTHQUAKE
	dbw 47, BLIZZARD
	dbw 51, BODY_SLAM
	dbw 55, AMNESIA
	db 0 ; no more level-up moves

PiloswineEvosAttacks:
	dbww EVOLVE_ITEM, WATER_STONE, MAMOSWINE
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, ICY_WIND
	dbw 1, HORN_ATTACK
	dbw 10, POWDER_SNOW
	dbw 14, ANCIENTPOWER
	dbw 19, ENDURE
	dbw 24, BITE
	dbw 28, TAKE_DOWN
	dbw 32, ROCK_SLIDE
	dbw 36, ICY_WIND
	dbw 40, ICE_SHARD
	dbw 44, MIST
	dbw 49, EARTHQUAKE
	dbw 56, BLIZZARD
	dbw 63, BODY_SLAM
	dbw 70, AMNESIA
	db 0 ; no more level-up moves

CorsolaEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 7, HARDEN
	dbw 10, BUBBLE
	dbw 13, SCREECH
	dbw 16, BUBBLEBEAM
	dbw 19, SAFEGUARD
	dbw 22, SPIKE_CANNON
	dbw 25, RECOVER
	dbw 28, ROCK_SLIDE
	dbw 31, AMNESIA
	dbw 34, ANCIENTPOWER
	dbw 37, MIST
	dbw 40, MIRROR_COAT
	dbw 44, POWER_GEM
	db 0 ; no more level-up moves

RemoraidEvosAttacks:
	dbbw EVOLVE_LEVEL, 25, OCTILLERY
	db 0 ; no more evolutions
	dbw 1, WATER_GUN
	dbw 5, LOCK_ON
	dbw 8, PSYBEAM
	dbw 11, HAZE
	dbw 15, AURORA_BEAM
	dbw 19, SUPERSONIC
	dbw 23, BUBBLEBEAM
	dbw 27, SCREECH
	dbw 31, ICE_BEAM
	dbw 35, FOCUS_ENERGY
	dbw 44, HYPER_BEAM
	db 0 ; no more level-up moves

OctilleryEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, OCTAZOOKA
	dbw 1, WATER_GUN
	dbw 5, CONSTRICT
	dbw 9, HAZE
	dbw 13, PSYBEAM
	dbw 17, SUPERSONIC
	dbw 21, AURORA_BEAM
	dbw 24, OCTAZOOKA
	dbw 28, BUBBLEBEAM
	dbw 31, SCREECH
	dbw 38, FLAMETHROWER
	dbw 44, FOCUS_ENERGY
	dbw 54, ICE_BEAM
	dbw 70, HYPER_BEAM
	db 0 ; no more level-up moves

DelibirdEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, PRESENT
	dbw 11, AURORA_BEAM
	dbw 21, QUICK_ATTACK
	dbw 26, AIR_SLASH
	dbw 31, FUTURE_SIGHT
	dbw 36, ICE_BEAM
	dbw 41, RAPID_SPIN
	db 0 ; no more level-up moves

MantineEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, BUBBLE
	dbw 10, SUPERSONIC
	dbw 14, BUBBLEBEAM
	dbw 18, HAZE
	dbw 22, TWISTER
	dbw 25, TAKE_DOWN
	dbw 28, SLAM
	dbw 32, AGILITY
	dbw 36, WING_ATTACK
	dbw 40, AIR_SLASH
	dbw 44, HYDRO_PUMP
	dbw 49, CONFUSE_RAY
	dbw 55, ICE_BEAM
	db 0 ; no more level-up moves

SkarmoryEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, FURY_STRIKES
	dbw 1, PECK
	dbw 7, SPIKES
	dbw 13, METAL_CLAW
	dbw 16, PURSUIT
	dbw 19, SWIFT
	dbw 22, DRILL_PECK
	dbw 25, AGILITY
	dbw 31, ROAR
	dbw 37, MUD_SLAP
	dbw 43, IRON_HEAD
	dbw 48, STEEL_WING
	db 0 ; no more level-up moves

HoundourEvosAttacks:
	dbbw EVOLVE_LEVEL, 24, HOUNDOOM
	db 0 ; no more evolutions
	dbw 1, LEER
	dbw 1, EMBER
	dbw 4, PURSUIT
	dbw 9, SLUDGE
	dbw 14, ROAR
	dbw 17, BITE
	dbw 22, RAGE
	dbw 30, FLAME_WHEEL
	dbw 35, FAINT_ATTACK
	dbw 40, REVERSAL
	dbw 43, FLAMETHROWER
	dbw 48, CRUNCH
	dbw 53, SPITE
	dbw 58, DARK_PULSE
	dbw 62, WILL_O_WISP
	db 0 ; no more level-up moves

HoundoomEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, LEER
	dbw 1, EMBER
	dbw 4, PURSUIT
	dbw 9, SLUDGE
	dbw 14, ROAR
	dbw 17, BITE
	dbw 22, RAGE
	dbw 32, FLAME_WHEEL
	dbw 38, FAINT_ATTACK
	dbw 44, REVERSAL
	dbw 48, FLAMETHROWER
	dbw 54, CRUNCH
	dbw 60, SPITE
	dbw 66, DARK_PULSE
	dbw 72, WILL_O_WISP
	db 0 ; no more level-up moves

KingdraEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, BUBBLE
	dbw 8, SMOKESCREEN
	dbw 12, FLAIL
	dbw 15, LEER
	dbw 18, AURORA_BEAM
	dbw 22, WATER_GUN
	dbw 26, DISABLE
	dbw 29, TWISTER
	dbw 36, OCTAZOOKA
	dbw 40, AGILITY
	dbw 45, DRAGON_RAGE
	dbw 51, HYDRO_PUMP
	dbw 58, DRAGON_PULSE
	dbw 65, OUTRAGE
	db 0 ; no more level-up moves

PhanpyEvosAttacks:
	dbbw EVOLVE_LEVEL, 25, DONPHAN
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, GROWL
	dbw 9, DEFENSE_CURL
	dbw 13, WATER_GUN
	dbw 17, FLAIL
	dbw 21, FOCUS_ENERGY
	dbw 25, TAKE_DOWN
	dbw 29, ANCIENTPOWER
	dbw 33, ROLLOUT
	dbw 37, BODY_SLAM
	dbw 41, ENDURE
	dbw 45, EARTHQUAKE
	dbw 49, DOUBLE_EDGE
	db 0 ; no more level-up moves

DonphanEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, FURY_STRIKES
	dbw 1, SCRATCH
	dbw 1, GROWL
	dbw 9, DEFENSE_CURL
	dbw 13, WATER_GUN
	dbw 17, FLAIL
	dbw 21, FOCUS_ENERGY
	dbw 28, HORN_ATTACK
	dbw 33, ROLLOUT
	dbw 37, BODY_SLAM
	dbw 41, RAPID_SPIN
	dbw 49, EARTHQUAKE
	db 0 ; no more level-up moves

Porygon2EvosAttacks:
	dbww EVOLVE_ITEM, DUBIOUS_DISC, PORYGON_Z
	db 0 ; no more evolutions
	dbw 1, CONVERSION2
	dbw 1, SCRATCH
	dbw 1, CONVERSION
	dbw 9, AGILITY
	dbw 12, PSYBEAM
	dbw 20, RECOVER
	dbw 24, TRI_ATTACK
	dbw 28, LOCK_ON
	dbw 32, ZAP_CANNON
	dbw 36, DEFENSE_CURL
	dbw 45, DARK_PULSE
	dbw 60, FLASH_CANNON
	db 0 ; no more level-up moves

StantlerEvosAttacks:
	dbww EVOLVE_ITEM, SUN_STONE, WYRDEER
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 3, SPITE
	dbw 7, BITE
	dbw 10, HYPNOSIS
	dbw 13, STOMP
	dbw 16, MUD_SLAP
	dbw 21, PSYBEAM
	dbw 23, CONFUSE_RAY
	dbw 27, TAKE_DOWN
	dbw 31, PSYCH_UP
	dbw 35, DOUBLE_KICK
	dbw 39, LIGHT_SCREEN
	dbw 43, PSYCHIC_M
	dbw 49, REFLECT
	dbw 53, DOUBLE_EDGE
	dbw 58, DISABLE
	dbw 64, THRASH
	dbw 70, SWAGGER
	dbw 75, MEGAHORN
	db 0 ; no more level-up moves

SmeargleEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SKETCH
	dbw 11, SKETCH
	dbw 21, SKETCH
	dbw 31, SKETCH
	dbw 41, SKETCH
	dbw 51, SKETCH
	dbw 61, SKETCH
	dbw 71, SKETCH
	dbw 81, SKETCH
	dbw 91, SKETCH
	db 0 ; no more level-up moves

TyrogueEvosAttacks:
	dbbbw EVOLVE_STAT, 20, ATK_LT_DEF, HITMONCHAN
	dbbbw EVOLVE_STAT, 20, ATK_GT_DEF, HITMONLEE
	dbbbw EVOLVE_STAT, 20, ATK_EQ_DEF, HITMONTOP
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 25, RAPID_SPIN
	dbw 30, HI_JUMP_KICK
	dbw 35, MACH_PUNCH
	dbw 40, LOCK_ON
	db 0 ; no more level-up moves

HitmontopEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, ROLLING_KICK
	dbw 1, ROLLING_KICK
	dbw 7, FOCUS_ENERGY
	dbw 10, RAPID_SPIN
	dbw 13, PURSUIT
	dbw 19, QUICK_ATTACK
	dbw 22, MACH_PUNCH
	dbw 25, LOCK_ON
	dbw 28, COUNTER
	dbw 31, AGILITY
	dbw 37, HI_JUMP_KICK
	dbw 43, PROTECT
	db 0 ; no more level-up moves

SmoochumEvosAttacks:
	dbbw EVOLVE_LEVEL, 30, JYNX
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LICK
	dbw 9, SWEET_KISS
	dbw 13, POWDER_SNOW
	dbw 17, ICE_SHARD
	dbw 21, CONFUSION
	dbw 25, SING
	dbw 33, MEAN_LOOK
	dbw 37, PSYCHIC_M
	dbw 45, PERISH_SONG
	dbw 49, BLIZZARD
	db 0 ; no more level-up moves

ElekidEvosAttacks:
	dbbw EVOLVE_LEVEL, 30, ELECTABUZZ
	db 0 ; no more evolutions
	dbw 1, QUICK_ATTACK
	dbw 1, LEER
	dbw 9, THUNDERPUNCH
	dbw 17, LIGHT_SCREEN
	dbw 21, BULLET_PUNCH
	dbw 25, SWIFT
	dbw 33, SCREECH
	dbw 41, THUNDERBOLT
	dbw 49, THUNDER
	db 0 ; no more level-up moves

MagbyEvosAttacks:
	dbbw EVOLVE_LEVEL, 30, MAGMAR
	db 0 ; no more evolutions
	dbw 1, EMBER
	dbw 7, LEER
	dbw 13, SLUDGE
	dbw 15, DRAIN_PUNCH
	dbw 19, FIRE_PUNCH
	dbw 25, SMOKESCREEN
	dbw 31, FLAMETHROWER
	dbw 37, SUNNY_DAY
	dbw 43, FIRE_BLAST
	dbw 49, CONFUSE_RAY
	db 0 ; no more level-up moves

MiltankEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 3, GROWL
	dbw 7, STOMP
	dbw 11, DEFENSE_CURL
	dbw 14, SEISMIC_TOSS
	dbw 17, NOURISHMENT
	dbw 21, ROLLOUT
	dbw 25, PRESENT
	dbw 29, REVERSAL
	dbw 33, BODY_SLAM
	dbw 38, HEAL_BELL
	dbw 44, CRUNCH
	dbw 50, CURSE
	dbw 56, DOUBLE_EDGE
	db 0 ; no more level-up moves

BlisseyEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 5, GROWL
	dbw 9, LEER
	dbw 13, FURY_STRIKES
	dbw 18, NOURISHMENT
	dbw 23, PRESENT
	dbw 28, MINIMIZE
	dbw 33, BODY_SLAM
	dbw 38, SING
	dbw 43, ICE_BEAM
	dbw 48, METRONOME
	dbw 53, DOUBLE_EDGE
	dbw 58, DEFENSE_CURL
	dbw 63, DAZZLING_GLEAM
	dbw 68, HEAL_BELL
	dbw 73, LIGHT_SCREEN
	db 0 ; no more level-up moves

RaikouEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, LEER
	dbw 1, SPARK
	dbw 11, BITE
	dbw 21, FLASH
	dbw 31, EXTREMESPEED
	dbw 41, THUNDERBOLT
	dbw 51, REFLECT
	dbw 61, CRUNCH
	dbw 71, THUNDER
	dbw 81, IRON_TAIL
	dbw 91, ZAP_CANNON
	db 0 ; no more level-up moves

EnteiEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, LEER
	dbw 1, FLAME_WHEEL
	dbw 11, BITE
	dbw 21, HEADBUTT
	dbw 31, FIRE_SPIN
	dbw 41, FLAMETHROWER
	dbw 51, WILL_O_WISP
	dbw 61, SWAGGER
	dbw 71, FIRE_BLAST
	dbw 81, SOLARBEAM
	dbw 91, SACRED_FIRE
	db 0 ; no more level-up moves

SuicuneEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, LEER
	dbw 1, BUBBLEBEAM
	dbw 11, BITE
	dbw 21, SURF
	dbw 31, GUST
	dbw 41, ICE_BEAM
	dbw 51, MIST
	dbw 61, MIRROR_COAT
	dbw 71, HYDRO_PUMP
	dbw 81, REST
	dbw 91, BLIZZARD
	db 0 ; no more level-up moves

LarvitarEvosAttacks:
	dbbw EVOLVE_LEVEL, 30, PUPITAR
	db 0 ; no more evolutions
	dbw 1, BITE
	dbw 1, LEER
	dbw 8, SANDSTORM
	dbw 12, STOMP
	dbw 15, SCREECH
	dbw 19, FOCUS_ENERGY
	dbw 22, ROCK_SLIDE
	dbw 25, PURSUIT
	dbw 29, THRASH
	dbw 33, ANCIENTPOWER
	dbw 36, SCARY_FACE
	dbw 40, OUTRAGE
	dbw 43, CRUNCH
	dbw 50, EARTHQUAKE
	dbw 57, HYPER_BEAM
	db 0 ; no more level-up moves

PupitarEvosAttacks:
	dbbw EVOLVE_LEVEL, 55, TYRANITAR
	db 0 ; no more evolutions
	dbw 1, BITE
	dbw 1, LEER
	dbw 8, SANDSTORM
	dbw 12, STOMP
	dbw 15, SCREECH
	dbw 19, FOCUS_ENERGY
	dbw 22, ROCK_SLIDE
	dbw 25, PURSUIT
	dbw 29, THRASH
	dbw 34, ANCIENTPOWER
	dbw 38, SCARY_FACE
	dbw 42, OUTRAGE
	dbw 47, CRUNCH
	dbw 56, EARTHQUAKE
	dbw 65, HYPER_BEAM
	db 0 ; no more level-up moves

TyranitarEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, BITE
	dbw 1, LEER
	dbw 8, SANDSTORM
	dbw 12, STOMP
	dbw 15, SCREECH
	dbw 19, FOCUS_ENERGY
	dbw 22, ROCK_SLIDE
	dbw 25, PURSUIT
	dbw 29, THRASH
	dbw 34, ANCIENTPOWER
	dbw 38, SCARY_FACE
	dbw 42, OUTRAGE
	dbw 47, CRUNCH
	dbw 61, EARTHQUAKE
	dbw 75, HYPER_BEAM
	db 0 ; no more level-up moves

LugiaEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, GUST
	dbw 11, SAFEGUARD
	dbw 22, AEROBLAST
	dbw 33, RECOVER
	dbw 44, PSYCHIC_M
	dbw 55, ANCIENTPOWER
	dbw 66, SWIFT
	dbw 77, ROAR
	dbw 88, RAIN_DANCE
	dbw 99, FUTURE_SIGHT
	db 0 ; no more level-up moves

HoOhEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, GUST
	dbw 11, SAFEGUARD
	dbw 22, SACRED_FIRE
	dbw 33, RECOVER
	dbw 44, MOONBLAST
	dbw 55, ANCIENTPOWER
	dbw 66, SWIFT
	dbw 77, ROAR
	dbw 88, SUNNY_DAY
	dbw 99, FUTURE_SIGHT
	db 0 ; no more level-up moves

CelebiEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, LEECH_SEED
	dbw 1, CONFUSION
	dbw 1, RECOVER
	dbw 1, HEAL_BELL
	dbw 10, SAFEGUARD
	dbw 20, ANCIENTPOWER
	dbw 30, FUTURE_SIGHT
	dbw 35, ENERGY_BALL
	dbw 40, BATON_PASS
	dbw 50, PERISH_SONG
	db 0 ; no more level-up moves

ENDSECTION

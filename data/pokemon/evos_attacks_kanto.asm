SECTION "Evolutions and Attacks 1", ROMX

EvosAttacksPointers1::
	dw BulbasaurEvosAttacks
	dw IvysaurEvosAttacks
	dw VenusaurEvosAttacks
	dw CharmanderEvosAttacks
	dw CharmeleonEvosAttacks
	dw CharizardEvosAttacks
	dw SquirtleEvosAttacks
	dw WartortleEvosAttacks
	dw BlastoiseEvosAttacks
	dw CaterpieEvosAttacks
	dw MetapodEvosAttacks
	dw ButterfreeEvosAttacks
	dw WeedleEvosAttacks
	dw KakunaEvosAttacks
	dw BeedrillEvosAttacks
	dw PidgeyEvosAttacks
	dw PidgeottoEvosAttacks
	dw PidgeotEvosAttacks
	dw RattataEvosAttacks
	dw RaticateEvosAttacks
	dw SpearowEvosAttacks
	dw FearowEvosAttacks
	dw EkansEvosAttacks
	dw ArbokEvosAttacks
	dw PikachuEvosAttacks
	dw RaichuEvosAttacks
	dw SandshrewEvosAttacks
	dw SandslashEvosAttacks
	dw NidoranFEvosAttacks
	dw NidorinaEvosAttacks
	dw NidoqueenEvosAttacks
	dw NidoranMEvosAttacks
	dw NidorinoEvosAttacks
	dw NidokingEvosAttacks
	dw ClefairyEvosAttacks
	dw ClefableEvosAttacks
	dw VulpixEvosAttacks
	dw NinetalesEvosAttacks
	dw JigglypuffEvosAttacks
	dw WigglytuffEvosAttacks
	dw ZubatEvosAttacks
	dw GolbatEvosAttacks
	dw OddishEvosAttacks
	dw GloomEvosAttacks
	dw VileplumeEvosAttacks
	dw ParasEvosAttacks
	dw ParasectEvosAttacks
	dw VenonatEvosAttacks
	dw VenomothEvosAttacks
	dw DiglettEvosAttacks
	dw DugtrioEvosAttacks
	dw MeowthEvosAttacks
	dw PersianEvosAttacks
	dw PsyduckEvosAttacks
	dw GolduckEvosAttacks
	dw MankeyEvosAttacks
	dw PrimeapeEvosAttacks
	dw GrowlitheEvosAttacks
	dw ArcanineEvosAttacks
	dw PoliwagEvosAttacks
	dw PoliwhirlEvosAttacks
	dw PoliwrathEvosAttacks
	dw AbraEvosAttacks
	dw KadabraEvosAttacks
	dw AlakazamEvosAttacks
	dw MachopEvosAttacks
	dw MachokeEvosAttacks
	dw MachampEvosAttacks
	dw BellsproutEvosAttacks
	dw WeepinbellEvosAttacks
	dw VictreebelEvosAttacks
	dw TentacoolEvosAttacks
	dw TentacruelEvosAttacks
	dw GeodudeEvosAttacks
	dw GravelerEvosAttacks
	dw GolemEvosAttacks
	dw PonytaEvosAttacks
	dw RapidashEvosAttacks
	dw SlowpokeEvosAttacks
	dw SlowbroEvosAttacks
	dw MagnemiteEvosAttacks
	dw MagnetonEvosAttacks
	dw FarfetchDEvosAttacks
	dw DoduoEvosAttacks
	dw DodrioEvosAttacks
	dw SeelEvosAttacks
	dw DewgongEvosAttacks
	dw GrimerEvosAttacks
	dw MukEvosAttacks
	dw ShellderEvosAttacks
	dw CloysterEvosAttacks
	dw GastlyEvosAttacks
	dw HaunterEvosAttacks
	dw GengarEvosAttacks
	dw OnixEvosAttacks
	dw DrowzeeEvosAttacks
	dw HypnoEvosAttacks
	dw KrabbyEvosAttacks
	dw KinglerEvosAttacks
	dw VoltorbEvosAttacks
	dw ElectrodeEvosAttacks
	dw ExeggcuteEvosAttacks
	dw ExeggutorEvosAttacks
	dw CuboneEvosAttacks
	dw MarowakEvosAttacks
	dw HitmonleeEvosAttacks
	dw HitmonchanEvosAttacks
	dw LickitungEvosAttacks
	dw KoffingEvosAttacks
	dw WeezingEvosAttacks
	dw RhyhornEvosAttacks
	dw RhydonEvosAttacks
	dw ChanseyEvosAttacks
	dw TangelaEvosAttacks
	dw KangaskhanEvosAttacks
	dw HorseaEvosAttacks
	dw SeadraEvosAttacks
	dw GoldeenEvosAttacks
	dw SeakingEvosAttacks
	dw StaryuEvosAttacks
	dw StarmieEvosAttacks
	dw MrMimeEvosAttacks
	dw ScytherEvosAttacks
	dw JynxEvosAttacks
	dw ElectabuzzEvosAttacks
	dw MagmarEvosAttacks
	dw PinsirEvosAttacks
	dw TaurosEvosAttacks
	dw MagikarpEvosAttacks
	dw GyaradosEvosAttacks
	dw LaprasEvosAttacks
	dw DittoEvosAttacks
	dw EeveeEvosAttacks
	dw VaporeonEvosAttacks
	dw JolteonEvosAttacks
	dw FlareonEvosAttacks
	dw PorygonEvosAttacks
	dw OmanyteEvosAttacks
	dw OmastarEvosAttacks
	dw KabutoEvosAttacks
	dw KabutopsEvosAttacks
	dw AerodactylEvosAttacks
	dw SnorlaxEvosAttacks
	dw ArticunoEvosAttacks
	dw ZapdosEvosAttacks
	dw MoltresEvosAttacks
	dw DratiniEvosAttacks
	dw DragonairEvosAttacks
	dw DragoniteEvosAttacks
	dw MewtwoEvosAttacks
	dw MewEvosAttacks
.IndirectEnd::

BulbasaurEvosAttacks:
	dbbw EVOLVE_LEVEL, 16, IVYSAUR
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 3, GROWL
	dbw 6, LEECH_SEED
	dbw 9, VINE_WHIP
	dbw 12, POISONPOWDER
	dbw 15, RAZOR_WIND
	dbw 18, LIGHT_SCREEN
	dbw 21, RAZOR_LEAF
	dbw 24, SWEET_SCENT
	dbw 27, SLUDGE
	dbw 30, SLEEP_POWDER
	dbw 33, SLUDGE_BOMB
	dbw 36, SAFEGUARD
	dbw 39, ENERGY_BALL
	dbw 42, CHARM
	dbw 45, SOLARBEAM
	dbw 48, SUNNY_DAY
	dbw 51, SKULL_BASH
	dbw 54, GROWTH
	dbw 57, PETAL_DANCE
    dbw 60, SYNTHESIS
    dbw 63, POWER_WHIP
	db 0 ; no more level-up moves

IvysaurEvosAttacks:
	dbbw EVOLVE_LEVEL, 32, VENUSAUR
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 3, GROWL
	dbw 6, LEECH_SEED
	dbw 9, VINE_WHIP
	dbw 12, POISONPOWDER
	dbw 15, RAZOR_WIND
	dbw 19, LIGHT_SCREEN
	dbw 23, RAZOR_LEAF
	dbw 27, SWEET_SCENT
	dbw 30, SLUDGE
	dbw 34, SLEEP_POWDER
	dbw 38, SLUDGE_BOMB
	dbw 42, SAFEGUARD
	dbw 46, ENERGY_BALL
	dbw 50, CHARM
	dbw 54, SOLARBEAM
	dbw 58, SUNNY_DAY
	dbw 62, SKULL_BASH
	dbw 66, GROWTH
	dbw 70, PETAL_DANCE
    dbw 74, SYNTHESIS
    dbw 78, POWER_WHIP
	db 0 ; no more level-up moves

VenusaurEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, STRENGTH
	dbw 1, SCRATCH
	dbw 3, GROWL
	dbw 6, LEECH_SEED
	dbw 9, VINE_WHIP
	dbw 12, POISONPOWDER
	dbw 15, RAZOR_WIND
	dbw 19, LIGHT_SCREEN
	dbw 23, RAZOR_LEAF
	dbw 27, SWEET_SCENT
	dbw 30, SLUDGE
	dbw 35, SLEEP_POWDER
	dbw 40, SLUDGE_BOMB
	dbw 45, SAFEGUARD
	dbw 50, ENERGY_BALL
	dbw 55, CHARM
	dbw 60, SOLARBEAM
	dbw 65, SUNNY_DAY
	dbw 70, SKULL_BASH
	dbw 75, GROWTH
	dbw 80, PETAL_DANCE
    dbw 85, SYNTHESIS
    dbw 90, POWER_WHIP
	db 0 ; no more level-up moves

CharmanderEvosAttacks:
	dbbw EVOLVE_LEVEL, 16, CHARMELEON
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 3, GROWL
	dbw 6, EMBER
	dbw 9, SMOKESCREEN
	dbw 12, BITE
	dbw 15, RAGE
	dbw 18, FAINT_ATTACK
	dbw 21, SCARY_FACE
	dbw 24, FIRE_SPIN
	dbw 27, BELLY_DRUM
	dbw 30, FLAMETHROWER
	dbw 33, SLASH
	dbw 36, ROCK_SLIDE
	dbw 39, DRAGON_RAGE
	dbw 42, DRAGON_CLAW
	dbw 45, ANCIENTPOWER
	dbw 48, AIR_SLASH
	dbw 51, OUTRAGE
	dbw 54, FIRE_BLAST
	db 0 ; no more level-up moves

CharmeleonEvosAttacks:
	dbbw EVOLVE_LEVEL, 36, CHARIZARD
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 3, GROWL
	dbw 6, EMBER
	dbw 9, SMOKESCREEN
	dbw 12, BITE
	dbw 15, RAGE
	dbw 19, FAINT_ATTACK
	dbw 23, SCARY_FACE
	dbw 27, FIRE_SPIN
	dbw 31, BELLY_DRUM
	dbw 35, FLAMETHROWER
	dbw 39, SLASH
	dbw 43, ROCK_SLIDE
	dbw 47, DRAGON_RAGE
	dbw 51, DRAGON_CLAW
	dbw 55, ANCIENTPOWER
	dbw 59, AIR_SLASH
	dbw 63, OUTRAGE
	dbw 67, FIRE_BLAST
	db 0 ; no more level-up moves

CharizardEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, FLY
	dbw 1, SCRATCH
	dbw 3, GROWL
	dbw 6, EMBER
	dbw 9, SMOKESCREEN
	dbw 12, BITE
	dbw 15, RAGE
	dbw 19, FAINT_ATTACK
	dbw 23, SCARY_FACE
	dbw 27, FIRE_SPIN
	dbw 31, BELLY_DRUM
	dbw 35, FLAMETHROWER
	dbw 40, SLASH
	dbw 45, ROCK_SLIDE
	dbw 50, DRAGON_RAGE
	dbw 55, DRAGON_CLAW
	dbw 60, ANCIENTPOWER
	dbw 65, AIR_SLASH
	dbw 70, OUTRAGE
	dbw 75, FIRE_BLAST
	db 0 ; no more level-up moves

SquirtleEvosAttacks:
	dbbw EVOLVE_LEVEL, 16, WARTORTLE
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 3, LEER
	dbw 6, BUBBLE
	dbw 9, HARDEN
	dbw 12, WATER_GUN
	dbw 15, BITE
	dbw 18, HAZE
	dbw 21, CONFUSION
	dbw 24, MIST
	dbw 27, RAPID_SPIN
	dbw 30, PROTECT
	dbw 33, FLAIL
	dbw 36, RAIN_DANCE
	dbw 39, IRON_HEAD
	dbw 42, FORESIGHT
	dbw 45, SKULL_BASH
	dbw 48, MIRROR_COAT
	dbw 51, HYDRO_PUMP
	dbw 54, FLASH_CANNON
	db 0 ; no more level-up moves

WartortleEvosAttacks:
	dbbw EVOLVE_LEVEL, 36, BLASTOISE
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 3, LEER
	dbw 6, BUBBLE
	dbw 9, HARDEN
	dbw 12, WATER_GUN
	dbw 15, BITE
	dbw 19, HAZE
	dbw 23, CONFUSION
	dbw 27, MIST
	dbw 31, RAPID_SPIN
	dbw 35, PROTECT
	dbw 39, FLAIL
	dbw 43, RAIN_DANCE
	dbw 47, IRON_HEAD
	dbw 51, FORESIGHT
	dbw 55, SKULL_BASH
	dbw 59, MIRROR_COAT
	dbw 63, HYDRO_PUMP
	dbw 67, FLASH_CANNON
	db 0 ; no more level-up moves

BlastoiseEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, SURF
	dbw 1, SCRATCH
	dbw 3, LEER
	dbw 6, BUBBLE
	dbw 9, HARDEN
	dbw 12, WATER_GUN
	dbw 15, BITE
	dbw 19, HAZE
	dbw 23, CONFUSION
	dbw 27, MIST
	dbw 31, RAPID_SPIN
	dbw 35, PROTECT
	dbw 40, FLAIL
	dbw 45, RAIN_DANCE
	dbw 50, IRON_HEAD
	dbw 55, FORESIGHT
	dbw 60, SKULL_BASH
	dbw 65, MIRROR_COAT
	dbw 70, HYDRO_PUMP
	dbw 75, FLASH_CANNON
	db 0 ; no more level-up moves

CaterpieEvosAttacks:
	dbbw EVOLVE_LEVEL, 7, METAPOD
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, STRING_SHOT
	dbw 8, LEECH_LIFE
	db 0 ; no more level-up moves

MetapodEvosAttacks:
	dbbw EVOLVE_LEVEL, 10, BUTTERFREE
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, HARDEN
	dbw 1, SCRATCH
	dbw 1, STRING_SHOT
	dbw 1, HARDEN
	dbw 15, HEADBUTT
	db 0 ; no more level-up moves

ButterfreeEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, CONFUSION
	dbw 1, SCRATCH
	dbw 1, STRING_SHOT
	dbw 1, HARDEN
	dbw 1, CONFUSION
	dbw 13, POISONPOWDER
	dbw 14, STUN_SPORE
	dbw 15, SLEEP_POWDER
	dbw 18, GUST
	dbw 23, ROAR
	dbw 28, SUPERSONIC
	dbw 34, AERIAL_ACE
	dbw 40, PSYBEAM
	dbw 46, BUG_BUZZ
	dbw 52, SPORE
	db 0 ; no more level-up moves

WeedleEvosAttacks:
	dbbw EVOLVE_LEVEL, 7, KAKUNA
	db 0 ; no more evolutions
	dbw 1, POISON_STING
	dbw 1, STRING_SHOT
	dbw 8, LEECH_LIFE
	db 0 ; no more level-up moves

KakunaEvosAttacks:
	dbbw EVOLVE_LEVEL, 10, BEEDRILL
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, HARDEN
	dbw 1, POISON_STING
	dbw 1, STRING_SHOT
	dbw 1, HARDEN
	dbw 15, HEADBUTT
	db 0 ; no more level-up moves

BeedrillEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, FURY_STRIKES
	dbw 1, POISON_STING
	dbw 1, STRING_SHOT
	dbw 1, HARDEN
	dbw 15, FOCUS_ENERGY
	dbw 20, TWINEEDLE
	dbw 25, RAGE
	dbw 30, PURSUIT
	dbw 35, PIN_MISSILE
	dbw 40, POISON_JAB
	dbw 45, AGILITY
	dbw 50, X_SCISSOR
	dbw 55, BUG_BUZZ
	dbw 60, SWORDS_DANCE
	db 0 ; no more level-up moves

PidgeyEvosAttacks:
	dbbw EVOLVE_LEVEL, 18, PIDGEOTTO
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 5, MUD_SLAP
	dbw 9, GUST
	dbw 12, PURSUIT
	dbw 15, QUICK_ATTACK
	dbw 19, RAZOR_WIND
	dbw 21, ROAR
	dbw 25, FAINT_ATTACK
	dbw 29, WING_ATTACK
	dbw 33, FORESIGHT
	dbw 37, AERIAL_ACE
	dbw 41, AGILITY
	dbw 47, AIR_SLASH
	dbw 51, MIRROR_MOVE
	dbw 54, HURRICANE
	db 0 ; no more level-up moves

PidgeottoEvosAttacks:
	dbbw EVOLVE_LEVEL, 36, PIDGEOT
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 5, MUD_SLAP
	dbw 9, GUST
	dbw 12, PURSUIT
	dbw 15, QUICK_ATTACK
	dbw 21, RAZOR_WIND
	dbw 23, ROAR
	dbw 28, FAINT_ATTACK
	dbw 33, WING_ATTACK
	dbw 38, FORESIGHT
	dbw 43, AERIAL_ACE
	dbw 49, AGILITY
	dbw 55, AIR_SLASH
	dbw 60, MIRROR_MOVE
	dbw 65, HURRICANE
	db 0 ; no more level-up moves

PidgeotEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 5, MUD_SLAP
	dbw 9, GUST
	dbw 12, PURSUIT
	dbw 15, QUICK_ATTACK
	dbw 21, RAZOR_WIND
	dbw 23, ROAR
	dbw 28, FAINT_ATTACK
	dbw 33, WING_ATTACK
	dbw 41, FORESIGHT
	dbw 46, AERIAL_ACE
	dbw 52, AGILITY
	dbw 59, AIR_SLASH
	dbw 66, MIRROR_MOVE
	dbw 73, EXTREMESPEED
	dbw 78, HURRICANE
	dbw 81, BRAVE_BIRD
	db 0 ; no more level-up moves

RattataEvosAttacks:
	dbbw EVOLVE_LEVEL, 20, RATICATE
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 4, FURY_STRIKES
	dbw 7, QUICK_ATTACK
	dbw 10, SCREECH
	dbw 13, HYPER_FANG
	dbw 18, BITE
	dbw 20, FOCUS_ENERGY
	dbw 24, FLAME_WHEEL
	dbw 27, PURSUIT
	dbw 31, COUNTER
	dbw 34, SUPER_FANG
	dbw 40, REVERSAL
	dbw 46, THIEF
	db 0 ; no more level-up moves

RaticateEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, SCARY_FACE
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 4, FURY_STRIKES
	dbw 7, QUICK_ATTACK
	dbw 10, SCREECH
	dbw 13, HYPER_FANG
	dbw 18, BITE
	dbw 19, SCARY_FACE
	dbw 26, FLAME_WHEEL
	dbw 30, PURSUIT
	dbw 35, COUNTER
	dbw 40, SUPER_FANG
	dbw 45, REVERSAL
	dbw 50, THIEF
	db 0 ; no more level-up moves

SpearowEvosAttacks:
	dbbw EVOLVE_LEVEL, 20, FEAROW
	db 0 ; no more evolutions
	dbw 1, PECK
	dbw 1, GROWL
	dbw 7, LEER
	dbw 10, FALSE_SWIPE
	dbw 13, FURY_STRIKES
	dbw 18, SCARY_FACE
	dbw 22, QUICK_ATTACK
	dbw 25, PURSUIT
	dbw 28, TRI_ATTACK
	dbw 31, MIRROR_MOVE
	dbw 34, FAINT_ATTACK
	dbw 37, DRILL_PECK
	dbw 41, AERIAL_ACE
	dbw 47, SWIFT
	dbw 53, AGILITY
	db 0 ; no more level-up moves

FearowEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, PECK
	dbw 1, GROWL
	dbw 7, LEER
	dbw 10, FALSE_SWIPE
	dbw 13, FURY_STRIKES
	dbw 18, SCARY_FACE
	dbw 23, QUICK_ATTACK
	dbw 26, PURSUIT
	dbw 29, TRI_ATTACK
	dbw 32, MIRROR_MOVE
	dbw 36, FAINT_ATTACK
	dbw 40, DRILL_PECK
	dbw 45, AERIAL_ACE
	dbw 51, SWIFT
	dbw 58, AGILITY
	dbw 65, BRAVE_BIRD
	db 0 ; no more level-up moves

EkansEvosAttacks:
	dbbw EVOLVE_LEVEL, 22, ARBOK
	db 0 ; no more evolutions
	dbw 1, WRAP
	dbw 1, LEER
	dbw 9, POISON_STING
	dbw 12, PURSUIT
	dbw 15, BITE
	dbw 18, SLAM
	dbw 23, GLARE
	dbw 26, CRUNCH
	dbw 29, SCREECH
	dbw 33, SPITE
	dbw 37, ACID
	dbw 40, FAINT_ATTACK
	dbw 48, POISON_JAB
	dbw 56, HAZE
	db 0 ; no more level-up moves

ArbokEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, SLUDGE
	dbw 1, WRAP
	dbw 1, LEER
	dbw 9, POISON_STING
	dbw 12, PURSUIT
	dbw 15, BITE
	dbw 18, SLAM
	dbw 21, SLUDGE
	dbw 25, GLARE
	dbw 28, CRUNCH
	dbw 33, SCREECH
	dbw 38, SPITE
	dbw 43, ACID
	dbw 47, FAINT_ATTACK
	dbw 51, POISON_JAB
	dbw 57, HAZE
	dbw 65, GUNK_SHOT
	db 0 ; no more level-up moves

PikachuEvosAttacks:
	; Only the Orange Islands form is gated. The plain Raichu entry below is
	; deliberately ungated so it is the default everywhere else -- gating it to
	; KANTO_REGION would leave Johto with no Thunderstone evolution at all.
	db   EVOLVE_REGION, ORANGE_REGION
	dbww EVOLVE_ITEM, THUNDERSTONE, RAICHU_ORANGE
	dbww EVOLVE_ITEM, THUNDERSTONE, RAICHU
	db 0 ; no more evolutions
	dbw 1, THUNDERSHOCK
	dbw 1, CHARM
	dbw 6, LEER
	dbw 8, THUNDER_WAVE
	dbw 11, QUICK_ATTACK
	dbw 13, FURY_STRIKES
	dbw 15, DOUBLE_TEAM
	dbw 17, ENCORE
	dbw 20, SLAM
	dbw 23, REVERSAL
	dbw 26, THUNDERBOLT
	dbw 30, WILD_CHARGE
	dbw 34, IRON_TAIL
	dbw 38, AGILITY
	dbw 42, SPARK
	dbw 46, THUNDER
	dbw 50, PRESENT
	dbw 56, LIGHT_SCREEN
	db 0 ; no more level-up moves

RaichuEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, THUNDERBOLT
	dbw 1, THUNDER_WAVE
	dbw 1, DOUBLE_TEAM
	dbw 1, IRON_TAIL
	dbw 1, THUNDERBOLT
	db 0 ; no more level-up moves

SandshrewEvosAttacks:
	dbbw EVOLVE_LEVEL, 22, SANDSLASH
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 6, DEFENSE_CURL
	dbw 9, RAPID_SPIN
	dbw 11, MUD_SLAP
	dbw 14, FLAIL
	dbw 17, POISON_STING
	dbw 20, SAFEGUARD
	dbw 23, SLASH
	dbw 27, METAL_CLAW
	dbw 30, SWIFT
	dbw 33, SWORDS_DANCE
	dbw 38, FURY_STRIKES
	dbw 43, ROCK_SLIDE
	dbw 49, COUNTER
	dbw 55, SANDSTORM
	db 0 ; no more level-up moves

SandslashEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, DIG
	dbw 1, SCRATCH
	dbw 6, DEFENSE_CURL
	dbw 9, RAPID_SPIN
	dbw 11, MUD_SLAP
	dbw 14, FLAIL
	dbw 17, POISON_STING
	dbw 21, DIG
	dbw 23, SAFEGUARD
	dbw 24, SLASH
	dbw 28, METAL_CLAW
	dbw 33, SWIFT
	dbw 38, SWORDS_DANCE
	dbw 44, FURY_STRIKES
	dbw 50, ROCK_SLIDE
	dbw 56, COUNTER
	dbw 61, SANDSTORM
	dbw 67, IRON_HEAD
	db 0 ; no more level-up moves

NidoranFEvosAttacks:
	dbbw EVOLVE_LEVEL, 16, NIDORINA
	db 0 ; no more evolutions
	dbw 1, GROWL
	dbw 4, SUPERSONIC
	dbw 8, SCRATCH
	dbw 10, DISABLE
	dbw 12, DOUBLE_KICK
	dbw 15, CHARM
	dbw 17, POISON_STING
	dbw 20, TAKE_DOWN
	dbw 23, LEER
	dbw 27, FOCUS_ENERGY
	dbw 30, BITE
	dbw 34, POISON_JAB
	dbw 38, FURY_STRIKES
	dbw 43, HYPER_VOICE
	dbw 48, FAINT_ATTACK
	dbw 54, COUNTER
	db 0 ; no more level-up moves

NidorinaEvosAttacks:
	dbww EVOLVE_ITEM, MOON_STONE, NIDOQUEEN
	db 0 ; no more evolutions
	dbw 1, GROWL
	dbw 4, SUPERSONIC
	dbw 8, SCRATCH
	dbw 10, DISABLE
	dbw 12, DOUBLE_KICK
	dbw 15, CHARM
	dbw 19, POISON_STING
	dbw 23, TAKE_DOWN
	dbw 27, LEER
	dbw 31, FOCUS_ENERGY
	dbw 36, BITE
	dbw 41, POISON_JAB
	dbw 46, FURY_STRIKES
	dbw 51, HYPER_VOICE
	dbw 57, FAINT_ATTACK
	dbw 63, COUNTER
	db 0 ; no more level-up moves

NidoqueenEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 1, DOUBLE_KICK
	dbw 23, BODY_SLAM
	dbw 33, POISON_JAB
	dbw 43, EARTHQUAKE
	dbw 53, HYPER_VOICE
	dbw 63, SLUDGE_BOMB
	dbw 73, CRUNCH
	dbw 83, EARTH_POWER
	db 0 ; no more level-up moves

NidoranMEvosAttacks:
	dbbw EVOLVE_LEVEL, 16, NIDORINO
	db 0 ; no more evolutions
	dbw 1, LEER
	dbw 1, SCRATCH
	dbw 4, SUPERSONIC
	dbw 8, HORN_ATTACK
	dbw 10, DISABLE
	dbw 12, DOUBLE_KICK
	dbw 15, AMNESIA
	dbw 17, POISON_STING
	dbw 20, CONFUSION
	dbw 23, FOCUS_ENERGY
	dbw 27, TAKE_DOWN
	dbw 30, FURY_STRIKES
	dbw 34, POISON_JAB
	dbw 38, FAINT_ATTACK
	dbw 43, MEGAHORN
	dbw 48, BODY_SLAM
	dbw 55, COUNTER
	db 0 ; no more level-up moves

NidorinoEvosAttacks:
	dbww EVOLVE_ITEM, MOON_STONE, NIDOKING
	db 0 ; no more evolutions
	dbw 1, LEER
	dbw 1, SCRATCH
	dbw 4, SUPERSONIC
	dbw 8, HORN_ATTACK
	dbw 10, DISABLE
	dbw 12, DOUBLE_KICK
	dbw 15, AMNESIA
	dbw 19, POISON_STING
	dbw 23, CONFUSION
	dbw 27, FOCUS_ENERGY
	dbw 31, TAKE_DOWN
	dbw 36, FURY_STRIKES
	dbw 41, POISON_JAB
	dbw 46, FAINT_ATTACK
	dbw 51, MEGAHORN
	dbw 57, BODY_SLAM
	dbw 63, COUNTER
	db 0 ; no more level-up moves

NidokingEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, HORN_ATTACK
	dbw 1, POISON_STING
	dbw 1, DOUBLE_KICK
	dbw 23, THRASH
	dbw 33, POISON_JAB
	dbw 43, EARTHQUAKE
	dbw 53, MEGAHORN
	dbw 63, SLUDGE_BOMB
	dbw 73, SKULL_BASH
	dbw 83, EARTH_POWER
	db 0 ; no more level-up moves

ClefairyEvosAttacks:
	dbww EVOLVE_ITEM, MOON_STONE, CLEFABLE
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, GROWL
	dbw 4, ENCORE
	dbw 8, SING
	dbw 11, METRONOME
	dbw 13, FURY_STRIKES
	dbw 16, BELLY_DRUM
	dbw 19, MINIMIZE
	dbw 23, PRESENT
	dbw 26, DEFENSE_CURL
	dbw 30, DISARM_VOICE
	dbw 34, AMNESIA
	dbw 37, METRONOME
	dbw 39, MIMIC
	dbw 43, MOONBLAST
	dbw 48, MOONLIGHT
	dbw 53, DAZZLING_GLEAM
	dbw 59, LIGHT_SCREEN
	dbw 66, HYPER_VOICE
	db 0 ; no more level-up moves

ClefableEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SING
	dbw 1, MOONBLAST
	dbw 1, METRONOME
	dbw 1, MOONLIGHT
	db 0 ; no more level-up moves

VulpixEvosAttacks:
	dbww EVOLVE_ITEM, FIRE_STONE, NINETALES
	db 0 ; no more evolutions
	dbw 1, EMBER
	dbw 1, LEER
	dbw 7, QUICK_ATTACK
	dbw 10, DISABLE
	dbw 13, ROAR
	dbw 16, FAINT_ATTACK
	dbw 19, CONFUSE_RAY
	dbw 19, WILL_O_WISP
	dbw 22, FLAIL
	dbw 25, SAFEGUARD
	dbw 28, HYPNOSIS
	dbw 31, FLAMETHROWER
	dbw 34, SPITE
	dbw 37, FIRE_SPIN
	dbw 42, SHADOW_BALL
	dbw 50, DARK_PULSE
	db 0 ; no more level-up moves

NinetalesEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, EMBER
	dbw 1, QUICK_ATTACK
	dbw 33, SAFEGUARD
	dbw 38, CONFUSE_RAY
	dbw 43, FIRE_SPIN
	dbw 53, FLAMETHROWER
	db 0 ; no more level-up moves

JigglypuffEvosAttacks:
	dbww EVOLVE_ITEM, MOON_STONE, WIGGLYTUFF
	db 0 ; no more evolutions
	dbw 1, SING
	dbw 4, DEFENSE_CURL
	dbw 9, SCRATCH
	dbw 12, FAINT_ATTACK
	dbw 14, DISABLE
	dbw 19, ROLLOUT
	dbw 22, PERISH_SONG
	dbw 24, FURY_STRIKES
	dbw 29, REST
	dbw 32, PRESENT
	dbw 36, BODY_SLAM
	dbw 40, PLAY_ROUGH
	dbw 45, HYPER_VOICE
	dbw 51, DAZZLING_GLEAM
	db 0 ; no more level-up moves

WigglytuffEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SING
	dbw 1, DISABLE
	dbw 1, BODY_SLAM
	dbw 1, PLAY_ROUGH
	db 0 ; no more level-up moves

ZubatEvosAttacks:
	dbbw EVOLVE_LEVEL, 22, GOLBAT
	db 0 ; no more evolutions
	dbw 1, LEECH_LIFE
	dbw 5, SUPERSONIC
	dbw 9, GUST
	dbw 13, BITE
	dbw 17, SLUDGE
	dbw 21, CONFUSE_RAY
	dbw 25, WING_ATTACK
	dbw 29, FAINT_ATTACK
	dbw 33, MEAN_LOOK
	dbw 37, AIR_SLASH
	dbw 41, SLUDGE_BOMB
	dbw 45, SCREECH
	dbw 49, HAZE
	dbw 53, POISON_JAB
	dbw 58, CRUNCH
	db 0 ; no more level-up moves

GolbatEvosAttacks:
	dbbw EVOLVE_HAPPINESS, TR_ANYTIME, CROBAT
	db 0 ; no more evolutions
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
	dbw 63, HAZE
	dbw 69, POISON_JAB
	dbw 75, CRUNCH
	dbw 81, BRAVE_BIRD
	db 0 ; no more level-up moves

OddishEvosAttacks:
	dbbw EVOLVE_LEVEL, 21, GLOOM
	db 0 ; no more evolutions
	dbw 1, ABSORB
	dbw 5, SWEET_SCENT
	dbw 9, ACID
	dbw 13, POISONPOWDER
	dbw 15, STUN_SPORE
	dbw 17, SLEEP_POWDER
	dbw 21, MEGA_DRAIN
	dbw 25, SYNTHESIS
	dbw 25, MOONLIGHT
	dbw 29, RAZOR_LEAF
	dbw 33, SWORDS_DANCE
	dbw 37, FLAIL
	dbw 41, SEED_BOMB
	dbw 45, GIGA_DRAIN
	dbw 49, ENERGY_BALL
	dbw 54, PETAL_DANCE
	db 0 ; no more level-up moves

GloomEvosAttacks:
	dbww EVOLVE_ITEM, LEAF_STONE, VILEPLUME
	dbww EVOLVE_ITEM, SUN_STONE, BELLOSSOM
	db 0 ; no more evolutions
	dbw 1, ABSORB
	dbw 5, SWEET_SCENT
	dbw 9, ACID
	dbw 13, POISONPOWDER
	dbw 15, STUN_SPORE
	dbw 17, SLEEP_POWDER
	dbw 23, MEGA_DRAIN
	dbw 29, SYNTHESIS
	dbw 29, MOONLIGHT
	dbw 35, RAZOR_LEAF
	dbw 41, SWORDS_DANCE
	dbw 47, FLAIL
	dbw 53, SEED_BOMB
	dbw 57, GIGA_DRAIN
	dbw 62, ENERGY_BALL
	dbw 67, PETAL_DANCE
	db 0 ; no more level-up moves

VileplumeEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, MEGA_DRAIN
	dbw 1, SWEET_SCENT
	dbw 1, STUN_SPORE
	dbw 1, PETAL_DANCE
	dbw 29, LEECH_SEED
	dbw 35, SEED_BOMB
	dbw 41, FAINT_ATTACK
	dbw 47, ENERGY_BALL
	dbw 53, PETAL_DANCE
	dbw 65, SOLARBEAM
	dbw 79, DARK_PULSE
	db 0 ; no more level-up moves

ParasEvosAttacks:
	dbbw EVOLVE_LEVEL, 24, PARASECT
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 7, STUN_SPORE
	dbw 10, LIGHT_SCREEN
	dbw 13, POISONPOWDER
	dbw 16, PURSUIT
	dbw 19, LEECH_LIFE
	dbw 22, FALSE_SWIPE
	dbw 25, SPORE
	dbw 28, PSYBEAM
	dbw 31, SLASH
	dbw 34, X_SCISSOR
	dbw 37, GROWTH
	dbw 40, SCREECH
	dbw 43, GIGA_DRAIN
	dbw 46, COUNTER
	dbw 52, ENERGY_BALL
	dbw 59, FLAIL
	dbw 65, LEECH_SEED
	db 0 ; no more level-up moves

ParasectEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 7, STUN_SPORE
	dbw 10, LIGHT_SCREEN
	dbw 13, POISONPOWDER
	dbw 16, PURSUIT
	dbw 19, LEECH_LIFE
	dbw 22, FALSE_SWIPE
	dbw 28, SPORE
	dbw 32, PSYBEAM
	dbw 37, SLASH
	dbw 41, X_SCISSOR
	dbw 46, GROWTH
	dbw 50, SCREECH
	dbw 55, GIGA_DRAIN
	dbw 60, COUNTER
	dbw 64, ENERGY_BALL
	dbw 68, FLAIL
	dbw 72, LEECH_SEED
	db 0 ; no more level-up moves

VenonatEvosAttacks:
	dbbw EVOLVE_LEVEL, 31, VENOMOTH
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, DISABLE
	dbw 1, FORESIGHT
	dbw 9, SUPERSONIC
	dbw 13, BATON_PASS
	dbw 17, CONFUSION
	dbw 20, POISONPOWDER
	dbw 22, SCREECH
	dbw 25, LEECH_LIFE
	dbw 28, STUN_SPORE
	dbw 30, GIGA_DRAIN
	dbw 33, PSYBEAM
	dbw 36, SLEEP_POWDER
	dbw 41, PSYCHIC_M
	dbw 50, POISON_JAB
	dbw 57, BUG_BUZZ
	dbw 66, SLUDGE_BOMB
	db 0 ; no more level-up moves

VenomothEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, PIN_MISSILE
	dbw 1, SCRATCH
	dbw 1, DISABLE
	dbw 1, FORESIGHT
	dbw 9, SUPERSONIC
	dbw 13, BATON_PASS
	dbw 17, CONFUSION
	dbw 20, POISONPOWDER
	dbw 22, SCREECH
	dbw 25, LEECH_LIFE
	dbw 28, STUN_SPORE
	dbw 30, GIGA_DRAIN
	dbw 30, PIN_MISSILE
	dbw 36, PSYBEAM
	dbw 42, SLEEP_POWDER
	dbw 52, PSYCHIC_M
	dbw 57, POISON_JAB
	dbw 63, BUG_BUZZ
	dbw 69, SLUDGE_BOMB
	db 0 ; no more level-up moves

DiglettEvosAttacks:
	dbbw EVOLVE_LEVEL, 26, DUGTRIO
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 5, GROWL
	dbw 9, MAGNITUDE
	dbw 17, DIG
	dbw 21, PURSUIT
	dbw 25, MUD_SLAP
	dbw 29, ANCIENTPOWER
	dbw 33, SLASH
	dbw 37, FAINT_ATTACK
	dbw 41, EARTHQUAKE
	db 0 ; no more level-up moves

DugtrioEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, SCREECH
	dbw 1, SCRATCH
	dbw 5, GROWL
	dbw 9, MAGNITUDE
	dbw 17, DIG
	dbw 21, PURSUIT
	dbw 25, MUD_SLAP
	dbw 25, SCREECH
	dbw 31, ANCIENTPOWER
	dbw 37, SLASH
	dbw 43, FAINT_ATTACK
	dbw 49, EARTHQUAKE
	dbw 55, TRI_ATTACK
	db 0 ; no more level-up moves

MeowthEvosAttacks:
	dbbw EVOLVE_LEVEL, 28, PERSIAN
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, GROWL
	dbw 11, BITE
	dbw 15, HYPNOSIS
	dbw 20, PAY_DAY
	dbw 24, CHARM
	dbw 28, FAINT_ATTACK
	dbw 32, SPITE
	dbw 35, FURY_STRIKES
	dbw 38, AMNESIA
	dbw 41, SLASH
	dbw 46, SCREECH
	dbw 51, CRUNCH
	dbw 57, METAL_CLAW
	db 0 ; no more level-up moves

PersianEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, SWIFT
	dbw 1, SCRATCH
	dbw 1, GROWL
	dbw 11, BITE
	dbw 15, HYPNOSIS
	dbw 20, PAY_DAY
	dbw 24, CHARM
	dbw 27, SWIFT
	dbw 29, FAINT_ATTACK
	dbw 34, SPITE
	dbw 38, FURY_STRIKES
	dbw 42, AMNESIA
	dbw 46, SLASH
	dbw 53, SCREECH
	dbw 59, CRUNCH
	dbw 66, METAL_CLAW
	db 0 ; no more level-up moves

PsyduckEvosAttacks:
	dbbw EVOLVE_LEVEL, 33, GOLDUCK
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 5, LEER
	dbw 7, HYPNOSIS
	dbw 10, DISABLE
	dbw 13, FORESIGHT
	dbw 16, CONFUSION
	dbw 20, LIGHT_SCREEN
	dbw 23, SCREECH
	dbw 27, PSYBEAM
	dbw 31, PSYCH_UP
	dbw 36, ICE_BEAM
	dbw 40, FURY_STRIKES
	dbw 44, ZEN_HEADBUTT
	dbw 48, CROSS_CHOP
	dbw 52, HYDRO_PUMP
	dbw 56, FUTURE_SIGHT
	dbw 60, PSYCHIC_M
    dbw 65, DARK_PULSE
	db 0 ; no more level-up moves

GolduckEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 5, LEER
	dbw 7, HYPNOSIS
	dbw 10, DISABLE
	dbw 13, FORESIGHT
	dbw 16, CONFUSION
	dbw 20, LIGHT_SCREEN
	dbw 23, SCREECH
	dbw 27, PSYBEAM
	dbw 31, PSYCH_UP
	dbw 38, ICE_BEAM
	dbw 44, FURY_STRIKES
	dbw 50, ZEN_HEADBUTT
	dbw 56, CROSS_CHOP
	dbw 62, HYDRO_PUMP
	dbw 67, FUTURE_SIGHT
	dbw 72, PSYCHIC_M
	dbw 77, DARK_PULSE
	db 0 ; no more level-up moves

MankeyEvosAttacks:
	dbbw EVOLVE_LEVEL, 28, PRIMEAPE
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 13, COUNTER
	dbw 15, KARATE_CHOP
	dbw 18, FAINT_ATTACK
	dbw 21, FURY_STRIKES
	dbw 24, REVERSAL
	dbw 27, FOCUS_ENERGY
	dbw 30, FORESIGHT
	dbw 33, SEISMIC_TOSS
	dbw 36, MEDITATE
	dbw 39, CROSS_CHOP
	dbw 42, ROCK_SLIDE
	dbw 45, SCREECH
	dbw 49, MACH_PUNCH
	dbw 53, DRAIN_PUNCH
	dbw 56, THRASH
	db 0 ; no more level-up moves

PrimeapeEvosAttacks:
	dbww EVOLVE_ITEM, MOON_STONE, ANNIHILAPE
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, RAGE
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 13, COUNTER
	dbw 15, KARATE_CHOP
	dbw 18, FAINT_ATTACK
	dbw 21, FURY_STRIKES
	dbw 24, REVERSAL
	dbw 27, FOCUS_ENERGY
	dbw 27, RAGE
	dbw 32, FORESIGHT
	dbw 36, SEISMIC_TOSS
	dbw 40, MEDITATE
	dbw 45, CROSS_CHOP
	dbw 49, ROCK_SLIDE
	dbw 54, SCREECH
	dbw 59, MACH_PUNCH
	dbw 64, DRAIN_PUNCH
	dbw 70, THRASH
	dbw 75, FOCUS_BLAST
	db 0 ; no more level-up moves

GrowlitheEvosAttacks:
	dbww EVOLVE_ITEM, FIRE_STONE, ARCANINE
	db 0 ; no more evolutions
	dbw 1, BITE
	dbw 1, ROAR
	dbw 9, EMBER
	dbw 14, SAFEGUARD
	dbw 18, LEER
	dbw 22, FIRE_SPIN
	dbw 26, TAKE_DOWN
	dbw 28, WILL_O_WISP
	dbw 31, BODY_SLAM
	dbw 34, FLAME_WHEEL
	dbw 38, CRUNCH
	dbw 42, AGILITY
	dbw 46, THRASH
	dbw 50, FLAMETHROWER
	dbw 58, WILD_CHARGE
	db 0 ; no more level-up moves

ArcanineEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, ROAR
	dbw 1, LEER
	dbw 10, EMBER
	dbw 20, TAKE_DOWN
	dbw 30, CRUNCH
	dbw 40, FLAME_WHEEL
	dbw 50, EXTREMESPEED
	dbw 60, OUTRAGE
	dbw 70, WILD_CHARGE
	dbw 80, IRON_HEAD
	db 0 ; no more level-up moves

PoliwagEvosAttacks:
	dbbw EVOLVE_LEVEL, 25, POLIWHIRL
	db 0 ; no more evolutions
	dbw 1, BUBBLE
	dbw 7, HYPNOSIS
	dbw 13, WATER_GUN
	dbw 16, MIST
	dbw 16, HAZE
	dbw 19, FURY_STRIKES
	dbw 22, BUBBLEBEAM
	dbw 25, RAIN_DANCE
	dbw 28, LOCK_ON
	dbw 31, SCALD
	dbw 35, BODY_SLAM
	dbw 40, AQUA_JET
	dbw 46, BELLY_DRUM
	dbw 54, HYDRO_PUMP
	db 0 ; no more level-up moves

PoliwhirlEvosAttacks:
	dbww EVOLVE_ITEM, WATER_STONE, POLIWRATH
	dbww EVOLVE_ITEM, KINGS_ROCK, POLITOED
	db 0 ; no more evolutions
	dbw 1, BUBBLE
	dbw 7, HYPNOSIS
	dbw 13, WATER_GUN
	dbw 16, MIST
	dbw 16, HAZE
	dbw 19, FURY_STRIKES
	dbw 22, BUBBLEBEAM
	dbw 27, RAIN_DANCE
	dbw 31, LOCK_ON
	dbw 35, SCALD
	dbw 39, BODY_SLAM
	dbw 45, AQUA_JET
	dbw 51, BELLY_DRUM
	dbw 66, HYDRO_PUMP
	db 0 ; no more level-up moves

PoliwrathEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, SUBMISSION
	dbw 1, WATER_GUN
	dbw 25, BUBBLEBEAM
	dbw 30, SCALD
	dbw 35, HYPNOSIS
	dbw 40, AQUA_JET
	dbw 45, STRENGTH
	dbw 50, LOCK_ON
	dbw 65, HYDRO_PUMP
	dbw 70, DYNAMICPUNCH
	db 0 ; no more level-up moves

AbraEvosAttacks:
	dbbw EVOLVE_LEVEL, 16, KADABRA
	db 0 ; no more evolutions
	dbw 1, TELEPORT
	dbw 9, ENCORE
	dbw 15, PSYWAVE
	dbw 18, LIGHT_SCREEN
	dbw 26, BARRIER
	db 0 ; no more level-up moves

KadabraEvosAttacks:
	dbww EVOLVE_ITEM, MIST_STONE, ALAKAZAM
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, FLASH
	dbw 1, TELEPORT
	dbw 9, ENCORE
	dbw 15, PSYWAVE
	dbw 15, FLASH
	dbw 16, CONFUSION
	dbw 18, DISABLE
	dbw 21, PSYBEAM
	dbw 23, LIGHT_SCREEN
	dbw 26, RECOVER
	dbw 30, SHADOW_BALL
	dbw 34, BARRIER
	dbw 38, FUTURE_SIGHT
	dbw 42, PSYCHIC_M
	dbw 47, REFLECT
	dbw 52, PSYCH_UP
	db 0 ; no more level-up moves

AlakazamEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, FLASH
	dbw 1, TELEPORT
	dbw 9, ENCORE
	dbw 15, PSYWAVE
	dbw 15, FLASH
	dbw 16, CONFUSION
	dbw 18, DISABLE
	dbw 21, PSYBEAM
	dbw 23, LIGHT_SCREEN
	dbw 26, RECOVER
	dbw 30, SHADOW_BALL
	dbw 34, BARRIER
	dbw 38, FUTURE_SIGHT
	dbw 42, PSYCHIC_M
	dbw 47, REFLECT
	dbw 52, PSYCH_UP
	db 0 ; no more level-up moves

MachopEvosAttacks:
	dbbw EVOLVE_LEVEL, 28, MACHOKE
	db 0 ; no more evolutions
	dbw 1, LEER
	dbw 7, FOCUS_ENERGY
	dbw 13, KARATE_CHOP
	dbw 17, LIGHT_SCREEN
	dbw 19, SEISMIC_TOSS
	dbw 22, MEDITATE
	dbw 25, DRAIN_PUNCH
	dbw 28, FORESIGHT
	dbw 31, ROLLING_KICK
	dbw 34, VITAL_THROW
	dbw 37, ENCORE
	dbw 40, CROSS_CHOP
	dbw 44, BULLET_PUNCH
	dbw 48, SCARY_FACE
	dbw 54, SUBMISSION
	db 0 ; no more level-up moves

MachokeEvosAttacks:
	dbww EVOLVE_ITEM, MIST_STONE, MACHAMP
	db 0 ; no more evolutions
	dbw 1, LEER
	dbw 8, FOCUS_ENERGY
	dbw 15, KARATE_CHOP
	dbw 17, LIGHT_SCREEN
	dbw 19, SEISMIC_TOSS
	dbw 22, MEDITATE
	dbw 25, DRAIN_PUNCH
	dbw 30, FORESIGHT
	dbw 34, ROLLING_KICK
	dbw 38, VITAL_THROW
	dbw 43, ENCORE
	dbw 48, CROSS_CHOP
	dbw 53, BULLET_PUNCH
	dbw 59, SCARY_FACE
	dbw 65, SUBMISSION
	db 0 ; no more level-up moves

MachampEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, STRENGTH
	dbw 1, LEER
	dbw 8, FOCUS_ENERGY
	dbw 15, KARATE_CHOP
	dbw 17, LIGHT_SCREEN
	dbw 19, SEISMIC_TOSS
	dbw 22, MEDITATE
	dbw 25, DRAIN_PUNCH
	dbw 30, FORESIGHT
	dbw 34, ROLLING_KICK
	dbw 38, VITAL_THROW
	dbw 43, ENCORE
	dbw 48, CROSS_CHOP
	dbw 53, BULLET_PUNCH
	dbw 59, SCARY_FACE
	dbw 65, SUBMISSION
	dbw 75, FOCUS_BLAST
	db 0 ; no more level-up moves

BellsproutEvosAttacks:
	dbbw EVOLVE_LEVEL, 21, WEEPINBELL
	db 0 ; no more evolutions
	dbw 1, VINE_WHIP
	dbw 6, GROWTH
	dbw 8, ENCORE
	dbw 11, WRAP
	dbw 13, LEECH_LIFE
	dbw 15, SLEEP_POWDER
	dbw 17, POISONPOWDER
	dbw 19, STUN_SPORE
	dbw 20, SYNTHESIS
	dbw 23, ACID
	dbw 27, ENERGY_BALL
	dbw 30, SWORDS_DANCE
	dbw 33, SWEET_SCENT
	dbw 37, REFLECT
	dbw 42, RAZOR_LEAF
	dbw 47, POISON_JAB
	dbw 54, SLAM
	db 0 ; no more level-up moves

WeepinbellEvosAttacks:
	dbww EVOLVE_ITEM, LEAF_STONE, VICTREEBEL
	db 0 ; no more evolutions
	dbw 1, VINE_WHIP
	dbw 6, GROWTH
	dbw 8, ENCORE
	dbw 11, WRAP
	dbw 13, LEECH_LIFE
	dbw 15, SLEEP_POWDER
	dbw 17, POISONPOWDER
	dbw 19, STUN_SPORE
	dbw 20, SYNTHESIS
	dbw 24, SLUDGE
	dbw 28, ENERGY_BALL
	dbw 32, SWORDS_DANCE
	dbw 37, SWEET_SCENT
	dbw 42, REFLECT
	dbw 48, RAZOR_LEAF
	dbw 54, POISON_JAB
	dbw 60, SLAM
	db 0 ; no more level-up moves

VictreebelEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SLUDGE_BOMB
	dbw 1, SLEEP_POWDER
	dbw 1, SWEET_SCENT
	dbw 1, ENERGY_BALL
	dbw 30, ENERGY_BALL
	dbw 70, GUNK_SHOT
	dbw 80, POWER_WHIP
	db 0 ; no more level-up moves

TentacoolEvosAttacks:
	dbbw EVOLVE_LEVEL, 30, TENTACRUEL
	db 0 ; no more evolutions
	dbw 1, POISON_STING
	dbw 6, SUPERSONIC
	dbw 12, CONSTRICT
	dbw 15, RAPID_SPIN
	dbw 19, ACID
	dbw 22, HAZE
	dbw 25, BUBBLEBEAM
	dbw 27, SAFEGUARD
	dbw 30, WRAP
	dbw 33, MIRROR_COAT
	dbw 36, SCALD
	dbw 39, BARRIER
	dbw 43, AURORA_BEAM
	dbw 47, POISON_JAB
	dbw 51, SCREECH
	dbw 55, HYDRO_PUMP
	db 0 ; no more level-up moves

TentacruelEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, WRAP
	dbw 1, POISON_STING
	dbw 6, SUPERSONIC
	dbw 12, CONSTRICT
	dbw 15, RAPID_SPIN
	dbw 19, ACID
	dbw 22, HAZE
	dbw 25, BUBBLEBEAM
	dbw 27, SAFEGUARD
	dbw 29, WRAP
	dbw 34, MIRROR_COAT
	dbw 38, SCALD
	dbw 42, BARRIER
	dbw 46, AURORA_BEAM
	dbw 52, POISON_JAB
	dbw 57, SCREECH
	dbw 64, HYDRO_PUMP
	dbw 70, GUNK_SHOT
	db 0 ; no more level-up moves

GeodudeEvosAttacks:
	dbbw EVOLVE_LEVEL, 25, GRAVELER
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 6, DEFENSE_CURL
	dbw 11, ROCK_THROW
	dbw 16, MAGNITUDE
	dbw 21, SELFDESTRUCT
	dbw 26, ROLLOUT
	dbw 31, EARTHQUAKE
	dbw 36, ROCK_SLIDE
	dbw 46, MEGA_PUNCH
	db 0 ; no more level-up moves

GravelerEvosAttacks:
	dbww EVOLVE_ITEM, MIST_STONE, GOLEM
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 6, DEFENSE_CURL
	dbw 11, ROCK_THROW
	dbw 16, MAGNITUDE
	dbw 21, SELFDESTRUCT
	dbw 30, ROLLOUT
	dbw 36, EARTHQUAKE
	dbw 43, ROCK_SLIDE
	dbw 55, MEGA_PUNCH
	db 0 ; no more level-up moves

GolemEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 6, DEFENSE_CURL
	dbw 11, ROCK_THROW
	dbw 16, MAGNITUDE
	dbw 21, SELFDESTRUCT
	dbw 30, ROLLOUT
	dbw 36, EARTHQUAKE
	dbw 43, ROCK_SLIDE
	dbw 55, MEGA_PUNCH
	db 0 ; no more level-up moves

PonytaEvosAttacks:
	dbbw EVOLVE_LEVEL, 40, RAPIDASH
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 4, GROWL
	dbw 8, LEER
	dbw 11, DOUBLE_KICK
	dbw 13, EMBER
	dbw 16, QUICK_ATTACK
	dbw 19, STOMP
	dbw 23, FLAME_WHEEL
	dbw 26, FIRE_SPIN
	dbw 30, HYPNOSIS
	dbw 34, WILL_O_WISP
	dbw 39, TAKE_DOWN
	dbw 42, CHARM
	dbw 47, AGILITY
	dbw 53, ZEN_HEADBUTT
	dbw 59, THRASH
	dbw 67, FIRE_BLAST
	db 0 ; no more level-up moves

RapidashEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, FURY_STRIKES
	dbw 1, SCRATCH
	dbw 4, GROWL
	dbw 8, LEER
	dbw 11, DOUBLE_KICK
	dbw 13, EMBER
	dbw 16, QUICK_ATTACK
	dbw 19, STOMP
	dbw 23, FLAME_WHEEL
	dbw 26, FIRE_SPIN
	dbw 30, HYPNOSIS
	dbw 34, WILL_O_WISP
	dbw 39, TAKE_DOWN
	dbw 45, CHARM
	dbw 50, AGILITY
	dbw 56, ZEN_HEADBUTT
	dbw 62, THRASH
	dbw 68, FIRE_BLAST
	dbw 75, WILD_CHARGE
	db 0 ; no more level-up moves

SlowpokeEvosAttacks:
	dbbw EVOLVE_LEVEL, 37, SLOWBRO
	dbww EVOLVE_ITEM, KINGS_ROCK, SLOWKING
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
	dbw 32, BELLY_DRUM
	dbw 34, HEADBUTT
	dbw 38, SCALD
	dbw 43, AMNESIA
	dbw 48, ZEN_HEADBUTT
	dbw 53, PSYCHIC_M
	db 0 ; no more level-up moves

SlowbroEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, HARDEN
	dbw 1, CURSE
	dbw 1, SCRATCH
	dbw 6, GROWL
	dbw 10, STOMP
	dbw 15, WATER_GUN
	dbw 18, SAFEGUARD
	dbw 20, CONFUSION
	dbw 25, FUTURE_SIGHT
	dbw 29, DISABLE
	dbw 32, BELLY_DRUM
	dbw 34, HEADBUTT
	dbw 40, SCALD
	dbw 46, AMNESIA
	dbw 53, ZEN_HEADBUTT
	dbw 60, PSYCHIC_M
	dbw 70, HYDRO_PUMP
	db 0 ; no more level-up moves

MagnemiteEvosAttacks:
	dbbw EVOLVE_LEVEL, 30, MAGNETON
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 5, SPARK
	dbw 9, SUPERSONIC
	dbw 13, SONICBOOM
	dbw 17, THUNDER_WAVE
	dbw 22, FLASH
	dbw 26, LOCK_ON
	dbw 30, IRON_HEAD
	dbw 34, SWIFT
	dbw 38, SCREECH
	dbw 43, SPIKE_CANNON
	dbw 48, FLASH_CANNON
	dbw 55, ZAP_CANNON
	db 0 ; no more level-up moves

MagnetonEvosAttacks:
	dbww EVOLVE_ITEM, THUNDERSTONE, MAGNEZONE
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, TRI_ATTACK
	dbw 1, SCRATCH
	dbw 5, SPARK
	dbw 9, SUPERSONIC
	dbw 13, SONICBOOM
	dbw 17, THUNDER_WAVE
	dbw 22, FLASH
	dbw 26, LOCK_ON
	dbw 29, TRI_ATTACK
	dbw 33, IRON_HEAD
	dbw 38, SWIFT
	dbw 43, SCREECH
	dbw 49, SPIKE_CANNON
	dbw 55, FLASH_CANNON
	dbw 65, ZAP_CANNON
	db 0 ; no more level-up moves

FarfetchDEvosAttacks:
	dbww EVOLVE_ITEM, STICK, SIRFETCH_D
	db 0 ; no more evolutions
	dbw 1, PECK
	dbw 5, MUD_SLAP
	dbw 8, GUST
	dbw 11, LEER
	dbw 14, QUICK_ATTACK
	dbw 17, AERIAL_ACE
	dbw 20, FURY_STRIKES
	dbw 23, FLAIL
	dbw 26, SWORDS_DANCE
	dbw 29, ROCK_SMASH
	dbw 33, AGILITY
	dbw 37, MIRROR_MOVE
	dbw 41, SLASH
	dbw 45, AIR_SLASH
	dbw 50, FORESIGHT
	dbw 55, FALSE_SWIPE
	db 0 ; no more level-up moves

DoduoEvosAttacks:
	dbbw EVOLVE_LEVEL, 31, DODRIO
	db 0 ; no more evolutions
	dbw 1, PECK
	dbw 1, GROWL
	dbw 5, QUICK_ATTACK
	dbw 9, PURSUIT
	dbw 13, FURY_STRIKES
	dbw 17, SUPERSONIC
	dbw 21, WING_ATTACK
	dbw 25, RAGE
	dbw 29, FAINT_ATTACK
	dbw 33, DRILL_PECK
	dbw 37, HAZE
	dbw 41, AERIAL_ACE
	dbw 47, AGILITY
	dbw 54, FLAIL
	dbw 65, BRAVE_BIRD
	db 0 ; no more level-up moves

DodrioEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, TRI_ATTACK
	dbw 1, PECK
	dbw 1, GROWL
	dbw 5, QUICK_ATTACK
	dbw 9, PURSUIT
	dbw 13, FURY_STRIKES
	dbw 17, SUPERSONIC
	dbw 21, WING_ATTACK
	dbw 25, RAGE
	dbw 29, FAINT_ATTACK
	dbw 33, TRI_ATTACK
	dbw 38, DRILL_PECK
	dbw 43, HAZE
	dbw 49, AERIAL_ACE
	dbw 55, AGILITY
	dbw 61, FLAIL
	dbw 68, BRAVE_BIRD
	dbw 80, HYPER_VOICE
	db 0 ; no more level-up moves

SeelEvosAttacks:
	dbbw EVOLVE_LEVEL, 34, DEWGONG
	db 0 ; no more evolutions
	dbw 1, HEADBUTT
	dbw 5, GROWL
	dbw 7, AQUA_JET
	dbw 10, LICK
	dbw 14, AURORA_BEAM
	dbw 18, BUBBLEBEAM
	dbw 21, REST
	dbw 24, ICY_WIND
	dbw 27, DISABLE
	dbw 30, SUDDEN_CHILL
	dbw 33, TAKE_DOWN
	dbw 36, PECK
	dbw 40, ICE_BEAM
	dbw 45, WHIRLPOOL
	dbw 50, ENCORE
	dbw 55, WATERFALL
	dbw 65, SAFEGUARD
	db 0 ; no more level-up moves

DewgongEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, HEADBUTT
	dbw 5, GROWL
	dbw 7, AQUA_JET
	dbw 10, LICK
	dbw 14, AURORA_BEAM
	dbw 18, BUBBLEBEAM
	dbw 21, REST
	dbw 24, ICY_WIND
	dbw 27, DISABLE
	dbw 30, SUDDEN_CHILL
	dbw 33, TAKE_DOWN
	dbw 37, PECK
	dbw 42, ICE_BEAM
	dbw 48, WHIRLPOOL
	dbw 54, ENCORE
	dbw 60, WATERFALL
	dbw 66, SAFEGUARD
	dbw 73, PERISH_SONG
	db 0 ; no more level-up moves

GrimerEvosAttacks:
	dbbw EVOLVE_LEVEL, 38, MUK
	db 0 ; no more evolutions
	dbw 1, POISONPOWDER
	dbw 1, SCRATCH
	dbw 5, HARDEN
	dbw 10, DISABLE
	dbw 12, LICK
	dbw 16, SLUDGE
	dbw 20, MEAN_LOOK
	dbw 23, MINIMIZE
	dbw 27, HAZE
	dbw 31, SCREECH
	dbw 36, POISON_JAB
	dbw 42, BARRIER
	dbw 50, DARK_PULSE
	dbw 57, CRUNCH
	dbw 65, SLUDGE_BOMB
	db 0 ; no more level-up moves

MukEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, POISONPOWDER
	dbw 1, SCRATCH
	dbw 5, HARDEN
	dbw 10, DISABLE
	dbw 12, LICK
	dbw 16, SLUDGE
	dbw 20, MEAN_LOOK
	dbw 23, MINIMIZE
	dbw 27, HAZE
	dbw 31, SCREECH
	dbw 36, POISON_JAB
	dbw 43, BARRIER
	dbw 51, DARK_PULSE
	dbw 58, CRUNCH
	dbw 65, SLUDGE_BOMB
	dbw 80, GUNK_SHOT
	db 0 ; no more level-up moves

ShellderEvosAttacks:
	dbww EVOLVE_ITEM, WATER_STONE, CLOYSTER
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, HARDEN
	dbw 8, ICE_SHARD
	dbw 11, SUPERSONIC
	dbw 15, BUBBLEBEAM
	dbw 19, AURORA_BEAM
	dbw 23, RAPID_SPIN
	dbw 27, BARRIER
	dbw 30, PROTECT
	dbw 34, TAKE_DOWN
	dbw 37, LEER
	dbw 40, CLAMP
	dbw 44, SCREECH
	dbw 52, ICE_BEAM
	db 0 ; no more level-up moves

CloysterEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, HARDEN
	dbw 1, SUPERSONIC
	dbw 1, AURORA_BEAM
	dbw 1, PROTECT
	dbw 15, ICE_SHARD
	dbw 25, SCREECH
	dbw 35, SPIKES
	dbw 45, SPIKE_CANNON
	dbw 55, ICE_BEAM
	dbw 70, BLIZZARD
	db 0 ; no more level-up moves

GastlyEvosAttacks:
	dbbw EVOLVE_LEVEL, 25, HAUNTER
	db 0 ; no more evolutions
	dbw 1, HYPNOSIS
	dbw 1, LICK
	dbw 8, SPITE
	dbw 10, PSYWAVE
	dbw 13, MEAN_LOOK
	dbw 16, CURSE
	dbw 19, PERISH_SONG
	dbw 21, NIGHT_SHADE
	dbw 24, SHADOW_BALL
	dbw 28, CONFUSE_RAY
	dbw 31, HAZE
	dbw 35, DARK_PULSE
	dbw 38, DREAM_EATER
	dbw 43, PAIN_SPLIT
	dbw 47, DESTINY_BOND
	dbw 55, SLUDGE_BOMB
	db 0 ; no more level-up moves

HaunterEvosAttacks:
	dbww EVOLVE_ITEM, MIST_STONE, GENGAR
	db 0 ; no more evolutions
	dbw 1, HYPNOSIS
	dbw 1, LICK
	dbw 8, SPITE
	dbw 10, PSYWAVE
	dbw 13, MEAN_LOOK
	dbw 16, CURSE
	dbw 19, PERISH_SONG
	dbw 21, NIGHT_SHADE
	dbw 24, SHADOW_BALL
	dbw 29, CONFUSE_RAY
	dbw 33, HAZE
	dbw 37, DARK_PULSE
	dbw 42, DREAM_EATER
	dbw 48, PAIN_SPLIT
	dbw 54, DESTINY_BOND
	dbw 65, SLUDGE_BOMB
	db 0 ; no more level-up moves

GengarEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, FAINT_ATTACK
	dbw 1, HYPNOSIS
	dbw 1, LICK
	dbw 8, SPITE
	dbw 10, PSYWAVE
	dbw 13, MEAN_LOOK
	dbw 16, CURSE
	dbw 19, PERISH_SONG
	dbw 21, NIGHT_SHADE
	dbw 24, SHADOW_BALL
	dbw 29, CONFUSE_RAY
	dbw 33, HAZE
	dbw 38, DARK_PULSE
	dbw 44, DREAM_EATER
	dbw 50, PAIN_SPLIT
	dbw 56, DESTINY_BOND
	dbw 63, SLUDGE_BOMB
	db 0 ; no more level-up moves

OnixEvosAttacks:
	dbww EVOLVE_ITEM, METAL_COAT, STEELIX
	db 0 ; no more evolutions
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
	dbw 33, DRAGONBREATH
	dbw 38, CURSE
	dbw 41, IRON_TAIL
	dbw 46, EARTHQUAKE
	dbw 49, BODY_SLAM
	db 0 ; no more level-up moves

DrowzeeEvosAttacks:
	dbbw EVOLVE_LEVEL, 26, HYPNO
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, HYPNOSIS
	dbw 10, DISABLE
	dbw 14, CONFUSION
	dbw 19, LIGHT_SCREEN
	dbw 25, HEADBUTT
	dbw 28, BARRIER
	dbw 31, POISONPOWDER
	dbw 36, MEDITATE
	dbw 40, PSYCHIC_M
	dbw 43, PSYCH_UP
	dbw 45, FUTURE_SIGHT
	db 0 ; no more level-up moves

HypnoEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, HYPNOSIS
	dbw 10, DISABLE
	dbw 14, CONFUSION
	dbw 19, LIGHT_SCREEN
	dbw 25, HEADBUTT
	dbw 28, BARRIER
	dbw 33, POISONPOWDER
	dbw 40, MEDITATE
	dbw 49, PSYCHIC_M
	dbw 55, PSYCH_UP
	dbw 60, FUTURE_SIGHT
	db 0 ; no more level-up moves

KrabbyEvosAttacks:
	dbbw EVOLVE_LEVEL, 28, KINGLER
	db 0 ; no more evolutions
	dbw 1, BUBBLE
	dbw 5, LEER
	dbw 12, FURY_STRIKES
	dbw 16, HARDEN
	dbw 19, AMNESIA
	dbw 23, STOMP
	dbw 25, HAZE
	dbw 27, BUBBLEBEAM
	dbw 30, FLAIL
	dbw 34, PROTECT
	dbw 37, SLAM
	dbw 41, CRABHAMMER
	dbw 45, DIG
	db 0 ; no more level-up moves

KinglerEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, BUBBLE
	dbw 5, LEER
	dbw 12, FURY_STRIKES
	dbw 16, HARDEN
	dbw 19, AMNESIA
	dbw 23, STOMP
	dbw 25, HAZE
	dbw 27, BUBBLEBEAM
	dbw 34, FLAIL
	dbw 38, PROTECT
	dbw 43, SLAM
	dbw 49, CRABHAMMER
	dbw 52, DIG
	db 0 ; no more level-up moves

VoltorbEvosAttacks:
	dbbw EVOLVE_LEVEL, 30, ELECTRODE
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 9, SCREECH
	dbw 13, SPARK
	dbw 17, SONICBOOM
	dbw 23, SELFDESTRUCT
	dbw 29, ROLLOUT
	dbw 33, LIGHT_SCREEN
	dbw 37, SWIFT
	dbw 39, SELFDESTRUCT
	dbw 41, MIRROR_COAT
	dbw 44, FLASH
	db 0 ; no more level-up moves

ElectrodeEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 9, SCREECH
	dbw 13, SPARK
	dbw 17, SONICBOOM
	dbw 23, SELFDESTRUCT
	dbw 29, ROLLOUT
	dbw 34, LIGHT_SCREEN
	dbw 40, SWIFT
	dbw 44, SELFDESTRUCT
	dbw 48, MIRROR_COAT
	dbw 52, FLASH
	db 0 ; no more level-up moves

ExeggcuteEvosAttacks:
	dbww EVOLVE_ITEM, LEAF_STONE, EXEGGUTOR
	db 0 ; no more evolutions
	dbw 1, ABSORB
	dbw 1, HYPNOSIS
	dbw 7, REFLECT
	dbw 13, LEECH_SEED
	dbw 19, CONFUSION
	dbw 22, SYNTHESIS
	dbw 22, MOONLIGHT
	dbw 25, STUN_SPORE
	dbw 28, MEGA_DRAIN
	dbw 31, POISONPOWDER
	dbw 34, ANCIENTPOWER
	dbw 37, SLEEP_POWDER
	dbw 43, SOLARBEAM
	db 0 ; no more level-up moves

ExeggutorEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, STOMP
	dbw 1, ABSORB
	dbw 1, HYPNOSIS
	dbw 1, CONFUSION
	dbw 25, STOMP
	dbw 31, MEGA_DRAIN
	dbw 37, ANCIENTPOWER
	dbw 43, PSYBEAM
	db 0 ; no more level-up moves

CuboneEvosAttacks:
	dbbw EVOLVE_LEVEL, 28, MAROWAK
	db 0 ; no more evolutions
	dbw 1, GROWL
	dbw 5, LEER
	dbw 9, BONE_CLUB
	dbw 11, SWORDS_DANCE
	dbw 13, HEADBUTT
	dbw 15, ANCIENTPOWER
	dbw 17, LEER
	dbw 19, BELLY_DRUM
	dbw 21, FOCUS_ENERGY
	dbw 23, SCREECH
	dbw 25, BONEMERANG
	dbw 27, PERISH_SONG
	dbw 29, RAGE
	dbw 31, ROCK_SLIDE
	dbw 33, FALSE_SWIPE
	dbw 35, SKULL_BASH
	dbw 37, THRASH
	dbw 41, SCREECH
	db 0 ; no more level-up moves

MarowakEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, GROWL
	dbw 5, LEER
	dbw 9, BONE_CLUB
	dbw 11, SWORDS_DANCE
	dbw 13, HEADBUTT
	dbw 15, ANCIENTPOWER
	dbw 17, LEER
	dbw 19, BELLY_DRUM
	dbw 21, FOCUS_ENERGY
	dbw 23, SCREECH
	dbw 25, BONEMERANG
	dbw 27, PERISH_SONG
	dbw 32, RAGE
	dbw 35, ROCK_SLIDE
	dbw 39, FALSE_SWIPE
	dbw 42, SKULL_BASH
	dbw 46, THRASH
	dbw 53, SCREECH
	db 0 ; no more level-up moves

HitmonleeEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, DOUBLE_KICK
	dbw 1, DOUBLE_KICK
	dbw 6, MEDITATE
	dbw 11, ROLLING_KICK
	dbw 13, RAPID_SPIN
	dbw 16, HI_JUMP_KICK
	dbw 19, MACH_PUNCH
	dbw 21, FOCUS_ENERGY
	dbw 23, LOCK_ON
	dbw 26, HI_JUMP_KICK
	dbw 31, LOCK_ON
	dbw 36, FORESIGHT
	dbw 41, ENDURE
	dbw 46, MEGA_KICK
	dbw 51, REVERSAL
	db 0 ; no more level-up moves

HitmonchanEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, COMET_PUNCH
	dbw 1, COMET_PUNCH
	dbw 7, AGILITY
	dbw 13, PURSUIT
	dbw 17, RAPID_SPIN
	dbw 22, LOCK_ON
	dbw 26, THUNDERPUNCH
	dbw 26, ICE_PUNCH
	dbw 26, FIRE_PUNCH
	dbw 32, MACH_PUNCH
	dbw 38, MEGA_PUNCH
	dbw 44, PROTECT
	dbw 47, HI_JUMP_KICK
	dbw 50, COUNTER
	db 0 ; no more level-up moves

LickitungEvosAttacks:
	dbww EVOLVE_ITEM, MOON_STONE, LICKILICKY
	db 0 ; no more evolutions
	dbw 1, LICK
	dbw 7, SUPERSONIC
	dbw 13, DEFENSE_CURL
	dbw 16, MAGNITUDE
	dbw 19, STOMP
	dbw 22, BELLY_DRUM
	dbw 25, WRAP
	dbw 28, HEADBUTT
	dbw 31, DISABLE
	dbw 37, BODY_SLAM
	dbw 43, SCREECH
	db 0 ; no more level-up moves

KoffingEvosAttacks:
	dbbw EVOLVE_LEVEL, 35, WEEZING
	db 0 ; no more evolutions
	dbw 1, POISONPOWDER
	dbw 1, SCRATCH
	dbw 9, PSYWAVE
	dbw 13, SCREECH
	dbw 17, SLUDGE
	dbw 19, PSYWAVE
	dbw 21, SELFDESTRUCT
	dbw 25, SMOKESCREEN
	dbw 29, DESTINY_BOND
	dbw 33, HAZE
	dbw 37, PAIN_SPLIT
	dbw 41, SELFDESTRUCT
	dbw 45, DESTINY_BOND
	dbw 50, PSYBEAM
	db 0 ; no more level-up moves

WeezingEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, SLUDGE_BOMB
	dbw 1, POISONPOWDER
	dbw 1, SCRATCH
	dbw 9, PSYWAVE
	dbw 13, SCREECH
	dbw 17, SLUDGE
	dbw 19, PSYWAVE
	dbw 21, SELFDESTRUCT
	dbw 25, SMOKESCREEN
	dbw 29, DESTINY_BOND
	dbw 33, HAZE
	dbw 39, PAIN_SPLIT
	dbw 44, SELFDESTRUCT
	dbw 51, DESTINY_BOND
	dbw 54, PSYBEAM
	db 0 ; no more level-up moves

RhyhornEvosAttacks:
	dbbw EVOLVE_LEVEL, 42, RHYDON
	db 0 ; no more evolutions
	dbw 1, HORN_ATTACK
	dbw 1, LEER
	dbw 8, PURSUIT
	dbw 13, STOMP
	dbw 16, ROCK_SLIDE
	dbw 19, FURY_STRIKES
	dbw 25, MAGNITUDE
	dbw 31, SCARY_FACE
	dbw 34, CRUNCH
	dbw 37, ROCK_SLIDE
	dbw 43, REVERSAL
	dbw 49, TAKE_DOWN
	dbw 52, THRASH
	dbw 55, EARTHQUAKE
	dbw 58, COUNTER
	db 0 ; no more level-up moves

RhydonEvosAttacks:
	dbww EVOLVE_ITEM, PROTECTOR, RHYPERIOR
	db 0 ; no more evolutions
	dbw 1, HORN_ATTACK
	dbw 1, LEER
	dbw 8, PURSUIT
	dbw 13, STOMP
	dbw 16, ROCK_SLIDE
	dbw 19, FURY_STRIKES
	dbw 25, MAGNITUDE
	dbw 31, SCARY_FACE
	dbw 34, CRUNCH
	dbw 37, MEGAHORN
	dbw 46, REVERSAL
	dbw 54, TAKE_DOWN
	dbw 59, THRASH
	dbw 65, EARTHQUAKE
	dbw 72, COUNTER
	db 0 ; no more level-up moves

ChanseyEvosAttacks:
	dbbw EVOLVE_HAPPINESS, TR_ANYTIME, BLISSEY
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 5, GROWL
	dbw 9, LEER
	dbw 13, NOURISHMENT
	dbw 17, FURY_STRIKES
	dbw 23, MINIMIZE
	dbw 29, SING
	dbw 32, PRESENT
	dbw 35, BODY_SLAM
	dbw 38, METRONOME
	dbw 41, DEFENSE_CURL
	dbw 45, HEAL_BELL
	dbw 49, LIGHT_SCREEN
	dbw 57, DOUBLE_EDGE
	db 0 ; no more level-up moves

TangelaEvosAttacks:
	dbww EVOLVE_ITEM, LEAF_STONE, TANGROWTH
	db 0 ; no more evolutions
	dbw 1, CONSTRICT
	dbw 4, SLEEP_POWDER
	dbw 6, CONFUSION
	dbw 10, ABSORB
	dbw 13, POISONPOWDER
	dbw 16, REFLECT
	dbw 19, VINE_WHIP
	dbw 22, FLAIL
	dbw 25, BIND
	dbw 31, MEGA_DRAIN
	dbw 34, STUN_SPORE
	dbw 40, SLAM
	dbw 46, GROWTH
	dbw 50, AMNESIA
	db 0 ; no more level-up moves

KangaskhanEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, COMET_PUNCH
	dbw 7, LEER
	dbw 13, BITE
	dbw 16, STOMP
	dbw 19, LEER
	dbw 22, FOCUS_ENERGY
	dbw 25, MEGA_PUNCH
	dbw 28, FORESIGHT
	dbw 31, RAGE
	dbw 34, SAFEGUARD
	dbw 37, ENDURE
	dbw 40, DISABLE
	dbw 43, CRUNCH
	dbw 49, REVERSAL
	db 0 ; no more level-up moves

HorseaEvosAttacks:
	dbbw EVOLVE_LEVEL, 32, SEADRA
	db 0 ; no more evolutions
	dbw 1, BUBBLE
	dbw 8, SMOKESCREEN
	dbw 12, FLAIL
	dbw 15, LEER
	dbw 18, AURORA_BEAM
	dbw 22, WATER_GUN
	dbw 26, DISABLE
	dbw 29, TWISTER
	dbw 33, OCTAZOOKA
	dbw 36, AGILITY
	dbw 40, DRAGON_RAGE
	dbw 43, HYDRO_PUMP
	db 0 ; no more level-up moves

SeadraEvosAttacks:
	dbww EVOLVE_ITEM, DRAGON_SCALE, KINGDRA
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
	db 0 ; no more level-up moves

GoldeenEvosAttacks:
	dbbw EVOLVE_LEVEL, 33, SEAKING
	db 0 ; no more evolutions
	dbw 1, PECK
	dbw 1, LEER
	dbw 10, SUPERSONIC
	dbw 12, WATER_GUN
	dbw 15, HORN_ATTACK
	dbw 19, PSYBEAM
	dbw 24, FLAIL
	dbw 27, HAZE
	dbw 29, FURY_STRIKES
	dbw 38, HYDRO_PUMP
	dbw 43, BODY_SLAM
	dbw 52, AGILITY
	db 0 ; no more level-up moves

SeakingEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, WATERFALL
	dbw 1, PECK
	dbw 1, LEER
	dbw 10, SUPERSONIC
	dbw 12, WATER_GUN
	dbw 15, HORN_ATTACK
	dbw 19, PSYBEAM
	dbw 24, FLAIL
	dbw 27, HAZE
	dbw 29, FURY_STRIKES
	dbw 32, WATERFALL
	dbw 41, HYDRO_PUMP
	dbw 49, BODY_SLAM
	dbw 61, AGILITY
	db 0 ; no more level-up moves

StaryuEvosAttacks:
	dbww EVOLVE_ITEM, WATER_STONE, STARMIE
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, HARDEN
	dbw 7, WATER_GUN
	dbw 13, RAPID_SPIN
	dbw 19, RECOVER
	dbw 25, SWIFT
	dbw 31, BUBBLEBEAM
	dbw 37, MINIMIZE
	dbw 43, LIGHT_SCREEN
	dbw 50, HYDRO_PUMP
	db 0 ; no more level-up moves

StarmieEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, RAPID_SPIN
	dbw 1, RECOVER
	dbw 1, BUBBLEBEAM
	dbw 32, PSYBEAM
	dbw 37, CONFUSE_RAY
	dbw 45, TRI_ATTACK
	db 0 ; no more level-up moves

MrMimeEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, BARRIER
	dbw 6, CONFUSION
	dbw 11, SUBSTITUTE
	dbw 13, FUTURE_SIGHT
	dbw 16, MEDITATE
	dbw 19, HYPNOSIS
	dbw 21, FURY_STRIKES
	dbw 23, MIMIC
	dbw 26, LIGHT_SCREEN
	dbw 26, REFLECT
	dbw 31, ENCORE
	dbw 36, PSYBEAM
	dbw 41, BATON_PASS
	dbw 46, SAFEGUARD
	dbw 51, MOONBLAST
	db 0 ; no more level-up moves

ScytherEvosAttacks:
	dbww EVOLVE_ITEM, METAL_COAT, SCIZOR
	db 0 ; no more evolutions
	dbw 1, QUICK_ATTACK
	dbw 1, LEER
	dbw 6, FOCUS_ENERGY
	dbw 9, REVERSAL
	dbw 12, PURSUIT
	dbw 15, TWINEEDLE
	dbw 18, FALSE_SWIPE
	dbw 21, RAZOR_WIND
	dbw 24, AGILITY
	dbw 27, COUNTER
	dbw 30, WING_ATTACK
	dbw 33, BATON_PASS
	dbw 36, SLASH
	dbw 39, LIGHT_SCREEN
	dbw 42, SWORDS_DANCE
	dbw 48, DOUBLE_TEAM
	db 0 ; no more level-up moves

JynxEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LICK
	dbw 9, LOVELY_KISS
	dbw 13, POWDER_SNOW
	dbw 17, MEDITATE
	dbw 21, HAIL
	dbw 23, ICE_SHARD
	dbw 25, ICE_PUNCH
	dbw 30, PSYBEAM
	dbw 35, MEAN_LOOK
	dbw 41, BODY_SLAM
	dbw 46, PSYCHIC_M
	dbw 51, PERISH_SONG
	dbw 57, BLIZZARD
	db 0 ; no more level-up moves

ElectabuzzEvosAttacks:
	dbww EVOLVE_ITEM, THUNDERSTONE, ELECTIVIRE
	db 0 ; no more evolutions
	dbw 1, QUICK_ATTACK
	dbw 1, LEER
	dbw 9, THUNDERPUNCH
	dbw 13, KARATE_CHOP
	dbw 17, LIGHT_SCREEN
	dbw 19, BULLET_PUNCH
	dbw 21, BARRIER
	dbw 25, SWIFT
	dbw 30, ROLLING_KICK
	dbw 36, SCREECH
	dbw 42, MEDITATE
	dbw 47, THUNDERBOLT
	dbw 52, CROSS_CHOP
	dbw 58, THUNDER
	db 0 ; no more level-up moves

MagmarEvosAttacks:
	dbww EVOLVE_ITEM, FIRE_STONE, MAGMORTAR
	db 0 ; no more evolutions
	dbw 1, EMBER
	dbw 7, LEER
	dbw 13, FIRE_SPIN
	dbw 16, KARATE_CHOP
	dbw 17, DRAIN_PUNCH
	dbw 19, FIRE_PUNCH
	dbw 22, MEGA_PUNCH
	dbw 25, SMOKESCREEN
	dbw 29, BARRIER
	dbw 33, SUNNY_DAY
	dbw 37, SCREECH
	dbw 41, FLAMETHROWER
	dbw 45, CROSS_CHOP
	dbw 49, CONFUSE_RAY
	dbw 53, WILL_O_WISP
	dbw 57, FIRE_BLAST
	db 0 ; no more level-up moves

PinsirEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, FURY_STRIKES
	dbw 7, FOCUS_ENERGY
	dbw 13, BIND
	dbw 16, CUT
	dbw 19, SEISMIC_TOSS
	dbw 22, FURY_STRIKES
	dbw 25, HARDEN
	dbw 28, FLAIL
	dbw 31, TWINEEDLE
	dbw 37, SUBMISSION
	dbw 43, SWORDS_DANCE
	db 0 ; no more level-up moves

TaurosEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 3, LEER
	dbw 5, RAGE
	dbw 8, HORN_ATTACK
	dbw 11, SCARY_FACE
	dbw 14, QUICK_ATTACK
	dbw 17, HEADBUTT
	dbw 21, REST
	dbw 25, PURSUIT
	dbw 29, SWAGGER
	dbw 33, THRASH
	dbw 38, TAKE_DOWN
	dbw 43, SKULL_BASH
	dbw 48, BODY_SLAM
	dbw 54, CRUNCH
	dbw 60, DOUBLE_EDGE
	db 0 ; no more level-up moves

MagikarpEvosAttacks:
	dbbw EVOLVE_LEVEL, 20, GYARADOS
	db 0 ; no more evolutions
	dbw 1, SPLASH
	dbw 5, BUBBLE
	dbw 15, SCRATCH
	dbw 25, REVERSAL
	dbw 30, FLAIL
	db 0 ; no more level-up moves

GyaradosEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, BITE
	dbw 1, SPLASH
	dbw 5, BUBBLE
	dbw 15, SCRATCH
	dbw 19, BITE
	dbw 25, DRAGON_RAGE
	dbw 30, THRASH
	dbw 35, TWISTER
	dbw 40, HYDRO_PUMP
	dbw 45, RAIN_DANCE
	dbw 50, HYPER_BEAM
	db 0 ; no more level-up moves

LaprasEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, WATER_GUN
	dbw 1, GROWL
	dbw 1, SING
	dbw 8, MIST
	dbw 15, BODY_SLAM
	dbw 22, CONFUSE_RAY
	dbw 26, AURORA_BEAM
	dbw 29, SURF
	dbw 33, PERISH_SONG
	dbw 36, FORESIGHT
	dbw 43, ICE_BEAM
	dbw 50, RAIN_DANCE
	dbw 53, SAFEGUARD
	dbw 57, SUDDEN_CHILL
	dbw 61, HYDRO_PUMP
	db 0 ; no more level-up moves

DittoEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, TRANSFORM
	db 0 ; no more level-up moves

EeveeEvosAttacks:
	; Location entries come first so they win over Espeon/Umbreon.
	db   EVOLVE_LOCATION
	map_id ILEX_FOREST
	dbbw EVOLVE_LEVEL, 1, LEAFEON
	db   EVOLVE_LOCATION
	map_id ICE_PATH_B3F
	dbbw EVOLVE_LEVEL, 1, GLACEON
	dbww EVOLVE_ITEM, THUNDERSTONE, JOLTEON
	dbww EVOLVE_ITEM, WATER_STONE, VAPOREON
	dbww EVOLVE_ITEM, FIRE_STONE, FLAREON
	dbbw EVOLVE_HAPPINESS, TR_MORNDAY, ESPEON
	dbbw EVOLVE_HAPPINESS, TR_EVENITE, UMBREON
	dbww EVOLVE_ITEM, SUN_STONE, SYLVEON
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 8, MUD_SLAP
	dbw 12, GROWL
	dbw 16, GROWTH
	dbw 20, FLAIL
	dbw 23, QUICK_ATTACK
	dbw 27, CHARM
	dbw 30, BITE
	dbw 33, BELLY_DRUM
	dbw 36, BATON_PASS
	dbw 42, TAKE_DOWN
	db 0 ; no more level-up moves

VaporeonEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, WATER_GUN
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 8, MUD_SLAP
	dbw 16, WATER_GUN
	dbw 20, FLAIL
	dbw 23, QUICK_ATTACK
	dbw 27, CHARM
	dbw 30, BITE
	dbw 33, SURF
	dbw 36, AURORA_BEAM
	dbw 42, HAZE
	dbw 47, BARRIER
	dbw 52, HYDRO_PUMP
	db 0 ; no more level-up moves

JolteonEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, THUNDERSHOCK
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 8, MUD_SLAP
	dbw 16, THUNDERSHOCK
	dbw 20, FLAIL
	dbw 23, QUICK_ATTACK
	dbw 27, CHARM
	dbw 30, DOUBLE_KICK
	dbw 33, THUNDERBOLT
	dbw 36, PIN_MISSILE
	dbw 42, THUNDER_WAVE
	dbw 47, AGILITY
	dbw 52, THUNDER
	db 0 ; no more level-up moves

FlareonEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, EMBER
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 8, MUD_SLAP
	dbw 16, EMBER
	dbw 20, FLAIL
	dbw 23, QUICK_ATTACK
	dbw 27, CHARM
	dbw 30, BITE
	dbw 33, FLAMETHROWER
	dbw 36, FIRE_SPIN
	dbw 39, THIEF
	dbw 42, WILL_O_WISP
	dbw 47, DOUBLE_KICK
	dbw 52, FIRE_BLAST
	db 0 ; no more level-up moves

PorygonEvosAttacks:
	dbww EVOLVE_ITEM, UP_GRADE, PORYGON2
	db 0 ; no more evolutions
	dbw 1, CONVERSION2
	dbw 1, SCRATCH
	dbw 1, CONVERSION
	dbw 9, AGILITY
	dbw 12, PSYBEAM
	dbw 20, RECOVER
	dbw 24, HEADBUTT
	dbw 32, LOCK_ON
	dbw 36, TRI_ATTACK
	dbw 44, ZAP_CANNON
	db 0 ; no more level-up moves

OmanyteEvosAttacks:
	dbbw EVOLVE_LEVEL, 40, OMASTAR
	db 0 ; no more evolutions
	dbw 1, CONSTRICT
	dbw 1, HARDEN
	dbw 13, BITE
	dbw 19, WATER_GUN
	dbw 23, AURORA_BEAM
	dbw 27, BUBBLEBEAM
	dbw 31, LEER
	dbw 34, SLAM
	dbw 37, PROTECT
	dbw 43, SUPERSONIC
	dbw 49, ANCIENTPOWER
	dbw 52, HAZE
	dbw 55, HYDRO_PUMP
	db 0 ; no more level-up moves

OmastarEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, SPIKE_CANNON
	dbw 1, CONSTRICT
	dbw 1, HARDEN
	dbw 13, BITE
	dbw 19, WATER_GUN
	dbw 23, AURORA_BEAM
	dbw 27, BUBBLEBEAM
	dbw 31, LEER
	dbw 34, SLAM
	dbw 37, PROTECT
	dbw 39, SPIKE_CANNON
	dbw 47, SUPERSONIC
	dbw 54, ANCIENTPOWER
	dbw 60, HAZE
	dbw 65, HYDRO_PUMP
	db 0 ; no more level-up moves

KabutoEvosAttacks:
	dbbw EVOLVE_LEVEL, 40, KABUTOPS
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, HARDEN
	dbw 10, ABSORB
	dbw 14, BUBBLEBEAM
	dbw 19, LEER
	dbw 24, AURORA_BEAM
	dbw 28, MUD_SLAP
	dbw 32, RAPID_SPIN
	dbw 37, ENDURE
	dbw 42, DIG
	dbw 46, MEGA_DRAIN
	dbw 50, FLAIL
	dbw 55, ANCIENTPOWER
	db 0 ; no more level-up moves

KabutopsEvosAttacks:
	db 0 ; no more evolutions
	dbw LEARN_EVO_MOVE, SLASH
	dbw 1, SCRATCH
	dbw 1, HARDEN
	dbw 10, ABSORB
	dbw 14, BUBBLEBEAM
	dbw 19, LEER
	dbw 24, AURORA_BEAM
	dbw 28, MUD_SLAP
	dbw 32, RAPID_SPIN
	dbw 37, ENDURE
	dbw 39, SLASH
	dbw 45, DIG
	dbw 51, MEGA_DRAIN
	dbw 58, FLAIL
	dbw 65, ANCIENTPOWER
	db 0 ; no more level-up moves

AerodactylEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, WING_ATTACK
	dbw 8, AGILITY
	dbw 12, STEEL_WING
	dbw 15, BITE
	dbw 19, PURSUIT
	dbw 22, SUPERSONIC
	dbw 25, FORESIGHT
	dbw 29, ANCIENTPOWER
	dbw 33, ROCK_SLIDE
	dbw 36, SCARY_FACE
	dbw 43, TAKE_DOWN
	dbw 50, HYPER_BEAM
	db 0 ; no more level-up moves

SnorlaxEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 8, AMNESIA
	dbw 15, DEFENSE_CURL
	dbw 22, BELLY_DRUM
	dbw 29, HEADBUTT
	dbw 36, METRONOME
	dbw 36, REST
	dbw 40, LICK
	dbw 43, BODY_SLAM
	dbw 50, ROLLOUT
	dbw 57, HYPER_BEAM
	db 0 ; no more level-up moves

ArticunoEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, GUST
	dbw 1, POWDER_SNOW
	dbw 8, MIST
	dbw 13, SUDDEN_CHILL
	dbw 19, AURORA_BEAM
	dbw 25, AGILITY
	dbw 32, ANCIENTPOWER
	dbw 37, LOCK_ON
	dbw 43, ICY_WIND
	dbw 49, WING_ATTACK
	dbw 55, ICE_BEAM
	dbw 61, HAIL
	dbw 67, REFLECT
	dbw 73, PSYCH_UP
	dbw 80, BLIZZARD
	db 0 ; no more level-up moves

ZapdosEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, PECK
	dbw 1, THUNDERSHOCK
	dbw 8, PROTECT
	dbw 13, THUNDER_WAVE
	dbw 19, SPARK
	dbw 25, AGILITY
	dbw 32, ANCIENTPOWER
	dbw 37, PROTECT
	dbw 43, THUNDERBOLT
	dbw 49, DRILL_PECK
	dbw 55, LIGHT_SCREEN
	dbw 61, RAIN_DANCE
	dbw 67, THUNDER
	dbw 73, PSYCH_UP
	dbw 80, ZAP_CANNON
	db 0 ; no more level-up moves

MoltresEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, WING_ATTACK
	dbw 1, EMBER
	dbw 8, WILL_O_WISP
	dbw 13, FIRE_SPIN
	dbw 19, SMOKESCREEN
	dbw 25, AGILITY
	dbw 32, ANCIENTPOWER
	dbw 37, ENDURE
	dbw 43, SUNNY_DAY
	dbw 49, FLAMETHROWER
	dbw 55, SOLARBEAM
	dbw 61, SAFEGUARD
	dbw 67, REST
	dbw 73, SKY_ATTACK
	dbw 80, FIRE_BLAST
	db 0 ; no more level-up moves

DratiniEvosAttacks:
	dbbw EVOLVE_LEVEL, 30, DRAGONAIR
	db 0 ; no more evolutions
	dbw 1, WRAP
	dbw 1, LEER
	dbw 8, THUNDER_WAVE
	dbw 15, TWISTER
	dbw 18, SUPERSONIC
	dbw 22, DRAGON_RAGE
	dbw 25, LIGHT_SCREEN
	dbw 29, SLAM
	dbw 33, MIST
	dbw 33, HAZE
	dbw 36, AGILITY
	dbw 43, SAFEGUARD
	dbw 50, OUTRAGE
	dbw 57, HYPER_BEAM
	db 0 ; no more level-up moves

DragonairEvosAttacks:
	db   EVOLVE_REGION, KANTO_REGION
	dbbw EVOLVE_LEVEL, 55, DRAGONITE_KANTO
	dbbw EVOLVE_LEVEL, 55, DRAGONITE ; ungated fallback: every other region
	db 0 ; no more evolutions
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
	dbw 56, OUTRAGE
	dbw 65, HYPER_BEAM
	db 0 ; no more level-up moves

DragoniteEvosAttacks:
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

MewtwoEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, CONFUSION
	dbw 1, DISABLE
	dbw 11, BARRIER
	dbw 22, SWIFT
	dbw 33, PSYCH_UP
	dbw 44, SAFEGUARD
	dbw 55, RECOVER
	dbw 66, PSYCHIC_M
	dbw 77, AMNESIA
	dbw 88, DYNAMICPUNCH
	dbw 99, TRI_ATTACK
	db 0 ; no more level-up moves

MewEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 10, TRANSFORM
	dbw 20, MEGA_PUNCH
	dbw 30, METRONOME
	dbw 40, PSYCHIC_M
	dbw 50, ANCIENTPOWER
	dbw 60, MOONBLAST
	dbw 70, EXTREMESPEED
	dbw 80, PSYCH_UP
	dbw 90, HIDDEN_POWER
	dbw 100, RECOVER
	db 0 ; no more level-up moves

ENDSECTION

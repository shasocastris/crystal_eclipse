; data/pokemon/safari_move_tutor_moves.asm
;
; SafariZoneMoveTutorMoves: the curated single-move-per-species table for the Safari Zone
; Move Tutor feature. One row per species = one tutor move.
;
; Row format (see the safari_tutor_move macro): dw species, dw move, db LINE_id
;   - species / move are stored as 16-bit *indexes* (the raw constants from
;     constants/pokemon_constants.asm and constants/move_constants.asm). The
;     8-bit runtime ID <-> 16-bit index conversion is dynamic (see
;     engine/16/), so GetSafariZoneMoveTutorMove converts the chosen mon's species
;     ID to an index before matching, and the move index is converted back to
;     an ID with GetMoveIDFromIndex before teaching. Storing 16-bit indexes is
;     also what lets moves above ID 255 work here.
;   - LINE_id: LINE_* constant from data/pokemon/evo_lines.asm, used by
;     CheckLineFullyCaught to gate this row's move until every member of that
;     species' evolutionary line has been caught.
;
; Move substitution notes (constants that don't exist in this hack):
;   - PONYTA / DODUO originally listed LOW_KICK -> DOUBLE_KICK.
;   - CUBONE / LICKITUNG originally listed FURY_ATTACK / DOUBLESLAP; this hack's
;     multi-hit Normal move is FURY_STRIKES, used for both.

MACRO safari_tutor_move
; species index, move index, LINE_* id
	dw \1, \2
	db \3
ENDM

SafariZoneMoveTutorMoves:
	safari_tutor_move BULBASAUR,   ANCIENTPOWER, LINE_BULBASAUR
	safari_tutor_move CHARMANDER,  CRUNCH,       LINE_CHARMANDER
	safari_tutor_move SQUIRTLE,    ZAP_CANNON,   LINE_SQUIRTLE
	safari_tutor_move SPEAROW,     SONICBOOM,    LINE_SPEAROW
	safari_tutor_move NIDORAN_F,   SWEET_KISS,   LINE_NIDORAN_F
	safari_tutor_move NIDORAN_M,   LOVELY_KISS,  LINE_NIDORAN_M
	safari_tutor_move ZUBAT,       FLAIL,        LINE_ZUBAT
	safari_tutor_move ODDISH,      LEECH_SEED,   LINE_ODDISH
	safari_tutor_move PARAS,       SYNTHESIS,    LINE_PARAS
	safari_tutor_move PSYDUCK,     TRI_ATTACK,   LINE_PSYDUCK
	safari_tutor_move POLIWAG,     GROWTH,       LINE_POLIWAG
	safari_tutor_move ABRA,        FORESIGHT,    LINE_ABRA
	safari_tutor_move MACHOP,      FALSE_SWIPE,  LINE_MACHOP
	safari_tutor_move BELLSPROUT,  SWEET_KISS,   LINE_BELLSPROUT
	safari_tutor_move TENTACOOL,   CONFUSE_RAY,  LINE_TENTACOOL
	safari_tutor_move GEODUDE,     RAPID_SPIN,   LINE_GEODUDE
	safari_tutor_move PONYTA,      DOUBLE_KICK,  LINE_PONYTA
	safari_tutor_move MAGNEMITE,   AGILITY,      LINE_MAGNEMITE
	safari_tutor_move FARFETCH_D,  FURY_CUTTER,  LINE_FARFETCH_D
	safari_tutor_move DODUO,       DOUBLE_KICK,  LINE_DODUO
	safari_tutor_move SEEL,        FLAIL,        LINE_SEEL
	safari_tutor_move ONIX,        MEDITATE,     LINE_ONIX
	safari_tutor_move DROWZEE,     AMNESIA,      LINE_DROWZEE
	safari_tutor_move KRABBY,      METAL_CLAW,   LINE_KRABBY
	safari_tutor_move VOLTORB,     AGILITY,      LINE_VOLTORB
	safari_tutor_move EXEGGCUTE,   SWEET_SCENT,  LINE_EXEGGCUTE
	safari_tutor_move CUBONE,      FURY_STRIKES, LINE_CUBONE
	safari_tutor_move LICKITUNG,   FURY_STRIKES, LINE_LICKITUNG
	safari_tutor_move CHANSEY,     SWEET_SCENT,  LINE_CHANSEY
	safari_tutor_move TANGELA,     SYNTHESIS,    LINE_TANGELA
	safari_tutor_move KANGASKHAN,  FAINT_ATTACK, LINE_KANGASKHAN
	safari_tutor_move HORSEA,      HAZE,         LINE_HORSEA
	safari_tutor_move GOLDEEN,     SWORDS_DANCE, LINE_GOLDEEN
	safari_tutor_move STARYU,      TWISTER,      LINE_STARYU
	safari_tutor_move MR__MIME,    LOCK_ON,      LINE_MR_MIME
	safari_tutor_move SCYTHER,     SONICBOOM,    LINE_SCYTHER
	safari_tutor_move PINSIR,      ROCK_THROW,   LINE_PINSIR
	safari_tutor_move TAUROS,      QUICK_ATTACK, LINE_TAUROS
	safari_tutor_move MAGIKARP,    BUBBLEBEAM,   LINE_MAGIKARP
	safari_tutor_move LAPRAS,      BITE,         LINE_LAPRAS
	safari_tutor_move EEVEE,       GROWTH,       LINE_EEVEE
	safari_tutor_move PORYGON,     BARRIER,      LINE_PORYGON
	safari_tutor_move OMANYTE,     ROCK_THROW,   LINE_OMANYTE
	safari_tutor_move KABUTO,      ROCK_THROW,   LINE_KABUTO
	safari_tutor_move AERODACTYL,  ROCK_THROW,   LINE_AERODACTYL
	safari_tutor_move SNORLAX,     LOVELY_KISS,  LINE_SNORLAX
	safari_tutor_move DRATINI,     HYDRO_PUMP,   LINE_DRATINI
	safari_tutor_move CHIKORITA,   MOONBLAST,    LINE_CHIKORITA
	safari_tutor_move CYNDAQUIL,   DOUBLE_EDGE,  LINE_CYNDAQUIL
	safari_tutor_move TOTODILE,    SUBMISSION,   LINE_TOTODILE
	safari_tutor_move SENTRET,     SCARY_FACE,   LINE_SENTRET
	safari_tutor_move HOOTHOOT,    NIGHT_SHADE,  LINE_HOOTHOOT
	safari_tutor_move LEDYBA,      BARRIER,      LINE_LEDYBA
	safari_tutor_move SPINARAK,    GROWTH,       LINE_SPINARAK
	safari_tutor_move CHINCHOU,    LIGHT_SCREEN, LINE_CHINCHOU
	safari_tutor_move PICHU,       PETAL_DANCE,  LINE_PICHU
	safari_tutor_move CLEFFA,      SWIFT,        LINE_CLEFFA
	safari_tutor_move IGGLYBUFF,   MIMIC,        LINE_IGGLYBUFF
	safari_tutor_move TOGEPI,      HIDDEN_POWER, LINE_TOGEPI
	safari_tutor_move NATU,        SAFEGUARD,    LINE_NATU
	safari_tutor_move MARILL,      HYDRO_PUMP,   LINE_MARILL
	safari_tutor_move SUDOWOODO,   SUBSTITUTE,   LINE_SUDOWOODO
	safari_tutor_move HOPPIP,      AGILITY,      LINE_HOPPIP
	safari_tutor_move AIPOM,       MIMIC,        LINE_AIPOM
	safari_tutor_move SUNKERN,     VITAL_THROW,  LINE_SUNKERN
	safari_tutor_move YANMA,       STEEL_WING,   LINE_YANMA
	safari_tutor_move WOOPER,      BELLY_DRUM,   LINE_WOOPER
	safari_tutor_move MURKROW,     STEEL_WING,   LINE_MURKROW
	safari_tutor_move MISDREAVUS,  HYPNOSIS,     LINE_MISDREAVUS
	safari_tutor_move WOBBUFFET,   MIMIC,        LINE_WOBBUFFET
	safari_tutor_move PINECO,      SUBSTITUTE,   LINE_PINECO
	safari_tutor_move DUNSPARCE,   FURY_STRIKES, LINE_DUNSPARCE
	safari_tutor_move SNUBBULL,    LOVELY_KISS,  LINE_SNUBBULL
	safari_tutor_move QWILFISH,    DOUBLE_EDGE,  LINE_QWILFISH
	safari_tutor_move HERACROSS,   SEISMIC_TOSS, LINE_HERACROSS
	safari_tutor_move SNEASEL,     MOONLIGHT,    LINE_SNEASEL
	safari_tutor_move TEDDIURSA,   SWEET_SCENT,  LINE_TEDDIURSA
	safari_tutor_move SWINUB,      ROAR,         LINE_SWINUB
	safari_tutor_move REMORAID,    AMNESIA,      LINE_REMORAID
	safari_tutor_move DELIBIRD,    SPIKES,       LINE_DELIBIRD
	safari_tutor_move MANTINE,     GUST,         LINE_MANTINE
	safari_tutor_move SKARMORY,    FURY_CUTTER,  LINE_SKARMORY
	safari_tutor_move PHANPY,      ABSORB,       LINE_PHANPY
	safari_tutor_move STANTLER,    SAFEGUARD,    LINE_STANTLER
	safari_tutor_move TYROGUE,     RAGE,         LINE_TYROGUE
	safari_tutor_move SMOOCHUM,    METRONOME,    LINE_SMOOCHUM
	safari_tutor_move ELEKID,      PURSUIT,      LINE_ELEKID
	safari_tutor_move MAGBY,       FAINT_ATTACK, LINE_MAGBY
	safari_tutor_move MILTANK,     MEGA_KICK,    LINE_MILTANK
	safari_tutor_move LARVITAR,    RAGE,         LINE_LARVITAR
	dw -1 ; terminator (species index $ffff)

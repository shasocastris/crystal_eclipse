; Follower palettes, mostly MysticCrystal's picks (data/pokemon/menu_mon_pals.asm).
; A two-hue name like YELLOW_RED is composed at load time; see CopySpritePal.

MACRO follower_pal
	IF DEF(PAL_OW_\1)
		db PAL_OW_\1
	ELSE
		REDEF _HUE1 EQUS STRSLICE("\1", 0, STRFIND("\1", "_"))
		REDEF _HUE2 EQUS STRSLICE("\1", STRFIND("\1", "_") + 1)
		assert PAL_OW_{_HUE1} < $d && PAL_OW_{_HUE2} < $d
		db FIRST_FOLLOWER_PAIR_PAL + (PAL_OW_{_HUE1} << 4) + PAL_OW_{_HUE2}
	ENDC
ENDM

MACRO follower_pals
	follower_pal \1
	follower_pal \2
ENDM

FollowerPals:
	table_width 2
	;             normal,       shiny
	follower_pals RED_GREEN,    GREEN         ; BULBASAUR
	follower_pals RED_GREEN,    GREEN         ; IVYSAUR
	follower_pals RED_GREEN,    GREEN         ; VENUSAUR
	follower_pals ORANGE_RED,   ORANGE_YELLOW ; CHARMANDER
	follower_pals ORANGE_RED,   YELLOW_RED    ; CHARMELEON
	follower_pals YELLOW_RED,   GREEN_PURPLE  ; CHARIZARD
	follower_pals BLUE,         GREEN_TEAL    ; SQUIRTLE
	follower_pals BLUE,         GREEN_TEAL    ; WARTORTLE
	follower_pals BLUE,         GREEN_TEAL    ; BLASTOISE
	follower_pals RED_GREEN,    YELLOW_PINK   ; CATERPIE
	follower_pals GREEN,        YELLOW        ; METAPOD
	follower_pals WHITE_RED,    WHITE_PINK    ; BUTTERFREE
	follower_pals RED,          YELLOW_PINK   ; WEEDLE
	follower_pals BROWN,        YELLOW        ; KAKUNA
	follower_pals YELLOW_RED,   YELLOW_BLUE   ; BEEDRILL
	follower_pals BROWN,        YELLOW_WHITE  ; PIDGEY
	follower_pals BROWN,        YELLOW_WHITE  ; PIDGEOTTO
	follower_pals BROWN,        YELLOW_WHITE  ; PIDGEOT
	follower_pals WHITE_PURPLE, WHITE_GRAY    ; RATTATA
	follower_pals BROWN,        YELLOW        ; RATICATE
	follower_pals PINK_BROWN,   YELLOW_ORANGE ; SPEAROW
	follower_pals PINK_BROWN,   WHITE_BROWN   ; FEAROW
	follower_pals RED_PURPLE,   GRAY_WHITE    ; EKANS
	follower_pals RED_PURPLE,   PURPLE_WHITE  ; ARBOK
	follower_pals YELLOW_RED,   ORANGE_PURPLE ; PIKACHU
	follower_pals YELLOW_RED,   WHITE_ORANGE  ; RAICHU
	follower_pals BROWN,        WHITE_GRAY    ; SANDSHREW
	follower_pals BROWN,        ORANGE        ; SANDSLASH
	follower_pals BLUE_TEAL,    GREEN_PURPLE  ; NIDORAN_F
	follower_pals BLUE_TEAL,    GREEN_PURPLE  ; NIDORINA
	follower_pals BLUE,         PINK_BLACK    ; NIDOQUEEN
	follower_pals WHITE_PURPLE, GRAY_TEAL     ; NIDORAN_M
	follower_pals WHITE_PURPLE, GRAY_TEAL     ; NIDORINO
	follower_pals WHITE_PURPLE, WHITE_BLUE    ; NIDOKING
	follower_pals PINK_BROWN,   PINK_GREEN    ; CLEFAIRY
	follower_pals PINK_BROWN,   PINK_GREEN    ; CLEFABLE
	follower_pals ORANGE_RED,   YELLOW        ; VULPIX
	follower_pals YELLOW_BROWN, WHITE_GRAY    ; NINETALES
	follower_pals WHITE_PINK,   GREEN_PINK    ; JIGGLYPUFF
	follower_pals WHITE_PINK,   GREEN_PINK    ; WIGGLYTUFF
	follower_pals GRAY_BLUE,    PINK_GREEN    ; ZUBAT
	follower_pals GRAY_BLUE,    PINK_GREEN    ; GOLBAT
	follower_pals GREEN_BLACK,  YELLOW_BLACK  ; ODDISH
	follower_pals RED_BLACK,    YELLOW_BLACK  ; GLOOM
	follower_pals RED_BLACK,    YELLOW_BLACK  ; VILEPLUME
	follower_pals WHITE_RED,    WHITE_BROWN   ; PARAS
	follower_pals WHITE_RED,    WHITE_BROWN   ; PARASECT
	follower_pals RED_PURPLE,   WHITE_BLUE    ; VENONAT
	follower_pals WHITE_PURPLE, WHITE_BLUE    ; VENOMOTH
	follower_pals ORANGE_BROWN, BROWN_BLUE    ; DIGLETT
	follower_pals ORANGE_BROWN, BROWN_BLUE    ; DUGTRIO
	follower_pals BROWN,        PURPLE        ; PERSIAN
	follower_pals BROWN,        PURPLE        ; MEOWTH
	follower_pals WHITE_YELLOW, WHITE_BLUE    ; PSYDUCK
	follower_pals WHITE_BLUE,   PINK_BLUE     ; GOLDUCK
	follower_pals BROWN,        YELLOW        ; MANKEY
	follower_pals BROWN,        YELLOW        ; PRIMEAPE
	follower_pals RED,          WHITE_BROWN   ; GROWLITHE
	follower_pals RED,          WHITE_BROWN   ; ARCANINE
	follower_pals WHITE_BLUE,   WHITE_TEAL    ; POLIWAG
	follower_pals WHITE_BLUE,   WHITE_TEAL    ; POLIWHIRL
	follower_pals WHITE_BLUE,   WHITE_TEAL    ; POLIWRATH
	follower_pals BROWN,        PURPLE        ; ABRA
	follower_pals BROWN,        PURPLE        ; KADABRA
	follower_pals BROWN,        PURPLE        ; ALAKAZAM
	follower_pals BROWN,        WHITE_GRAY    ; MACHOP
	follower_pals RED_GRAY,     BLUE_GRAY     ; MACHOKE
	follower_pals WHITE_BROWN,  WHITE_GRAY    ; MACHAMP
	follower_pals GREEN,        YELLOW_PURPLE ; BELLSPROUT
	follower_pals GREEN,        YELLOW_PURPLE ; WEEPINBELL
	follower_pals GREEN,        YELLOW_BLUE   ; VICTREEBEL
	follower_pals RED_TEAL,     GREEN_TEAL    ; TENTACOOL
	follower_pals RED_TEAL,     GREEN_TEAL    ; TENTACRUEL
	follower_pals BLACK_GRAY,   GRAY_WHITE    ; GEODUDE
	follower_pals BLACK_GRAY,   GRAY_WHITE    ; GRAVELER
	follower_pals GRAY_BLACK,   GRAY_ORANGE   ; GOLEM
	follower_pals YELLOW_RED,   WHITE_BLUE    ; PONYTA
	follower_pals YELLOW_RED,   WHITE_PURPLE  ; RAPIDASH
	follower_pals PINK,         WHITE_PURPLE  ; SLOWPOKE
	follower_pals PINK,         WHITE_PURPLE  ; SLOWBRO
	follower_pals WHITE_GRAY,   WHITE_RED     ; MAGNEMITE
	follower_pals WHITE_GRAY,   WHITE_RED     ; MAGNETON
	follower_pals WHITE_BROWN,  WHITE_GREEN   ; FARFETCH_D
	follower_pals BROWN,        WHITE_YELLOW  ; DODUO
	follower_pals BROWN,        WHITE_YELLOW  ; DODRIO
	follower_pals WHITE_RED,    GRAY_RED      ; SEEL
	follower_pals GRAY_WHITE,   WHITE_GRAY    ; DEWGONG
	follower_pals WHITE_PURPLE, WHITE_GRAY    ; GRIMER
	follower_pals WHITE_PURPLE, WHITE_GREEN   ; MUK
	follower_pals RED_PURPLE,   WHITE_ORANGE  ; SHELLDER
	follower_pals WHITE_PURPLE, WHITE_BLUE    ; CLOYSTER
	follower_pals WHITE_PURPLE, WHITE_BLUE    ; GASTLY
	follower_pals RED_PURPLE,   BLUE_PURPLE   ; HAUNTER
	follower_pals WHITE_RED,    WHITE_PURPLE  ; GENGAR
	follower_pals BLACK_GRAY,   BROWN_GREEN   ; ONIX
	follower_pals YELLOW_BROWN, PINK_PURPLE   ; DROWZEE
	follower_pals YELLOW_BROWN, PINK_PURPLE   ; HYPNO
	follower_pals RED,          BROWN         ; KRABBY
	follower_pals RED,          GRAY          ; KINGLER
	follower_pals WHITE_RED,    WHITE_BLUE    ; VOLTORB
	follower_pals WHITE_RED,    WHITE_BLUE    ; ELECTRODE
	follower_pals PINK_WHITE,   YELLOW_WHITE  ; EXEGGCUTE
	follower_pals GREEN,        ORANGE        ; EXEGGUTOR
	follower_pals WHITE_BROWN,  WHITE_GRAY    ; CUBONE
	follower_pals WHITE_BROWN,  WHITE_GRAY    ; MAROWAK
	follower_pals GRAY_BROWN,   PURPLE_GREEN  ; HITMONLEE
	follower_pals BROWN_PINK,   GRAY_BLUE     ; HITMONCHAN
	follower_pals PINK_RED,     PINK          ; LICKITUNG
	follower_pals GRAY_PURPLE,  GRAY_BLUE     ; KOFFING
	follower_pals GRAY_PURPLE,  GRAY_BLUE     ; WEEZING
	follower_pals BLACK_GRAY,   GRAY_WHITE    ; RHYHORN
	follower_pals WHITE_GRAY,   GRAY_WHITE    ; RHYDON
	follower_pals WHITE_PINK,   GREEN         ; CHANSEY
	follower_pals RED_BLUE,     ORANGE_YELLOW ; TANGELA
	follower_pals BROWN,        GRAY          ; KANGASKHAN
	follower_pals BLUE,         PINK_BLUE     ; HORSEA
	follower_pals BLUE,         PINK_BLUE     ; SEADRA
	follower_pals WHITE_PINK,   WHITE_YELLOW  ; GOLDEEN
	follower_pals RED_WHITE,    WHITE_YELLOW  ; SEAKING
	follower_pals WHITE_BROWN,  BLUE_WHITE    ; STARYU
	follower_pals YELLOW_PURPLE, PINK_BLUE     ; STARMIE
	follower_pals WHITE_PINK,   PINK_YELLOW   ; MR__MIME
	follower_pals GREEN,        WHITE_ORANGE  ; SCYTHER
	follower_pals WHITE_PURPLE, WHITE_PINK    ; JYNX
	follower_pals YELLOW,       YELLOW_ORANGE ; ELECTABUZZ
	follower_pals ORANGE_RED,   PINK_PURPLE   ; MAGMAR
	follower_pals WHITE_BROWN,  WHITE_GRAY    ; PINSIR
	follower_pals BROWN,        GRAY          ; TAUROS
	follower_pals WHITE_RED,    WHITE_YELLOW  ; MAGIKARP
	follower_pals YELLOW_BLUE,  WHITE_RED     ; GYARADOS
	follower_pals BLUE,         PINK_PURPLE   ; LAPRAS
	follower_pals PINK_PURPLE,  BLUE_WHITE    ; DITTO
	follower_pals WHITE_BROWN,  WHITE_GRAY    ; EEVEE
	follower_pals WHITE_BLUE,   WHITE_PURPLE  ; VAPOREON
	follower_pals YELLOW_RED,   YELLOW_WHITE  ; JOLTEON
	follower_pals WHITE_RED,    WHITE_BROWN   ; FLAREON
	follower_pals TEAL_RED,     BLUE_PURPLE   ; PORYGON
	follower_pals BLUE,         WHITE_GRAY    ; OMANYTE
	follower_pals BLUE,         YELLOW_GRAY   ; OMASTAR
	follower_pals BROWN,        WHITE_GRAY    ; KABUTO
	follower_pals BROWN,        WHITE_GRAY    ; KABUTOPS
	follower_pals BLACK_GRAY,   BLUE_PURPLE   ; AERODACTYL
	follower_pals BLACK,        BLUE          ; SNORLAX
	follower_pals WHITE_TEAL,   WHITE_GRAY    ; ARTICUNO
	follower_pals BROWN_YELLOW, YELLOW_RED    ; ZAPDOS
	follower_pals ORANGE_RED,   WHITE_PINK    ; MOLTRES
	follower_pals BLUE,         WHITE_TEAL    ; DRATINI
	follower_pals WHITE_BLUE,   WHITE_TEAL    ; DRAGONAIR
	follower_pals YELLOW_WHITE, GRAY_WHITE    ; DRAGONITE
	follower_pals WHITE_PURPLE, WHITE_BROWN   ; MEWTWO
	follower_pals PINK,         WHITE_BLUE    ; MEW
	follower_pals GREEN,        YELLOW        ; CHIKORITA
	follower_pals GREEN,        BROWN         ; BAYLEEF
	follower_pals RED_GREEN,    YELLOW_ORANGE ; MEGANIUM
	follower_pals YELLOW_RED,   PURPLE        ; CYNDAQUIL
	follower_pals YELLOW_RED,   PURPLE        ; QUILAVA
	follower_pals YELLOW_RED,   PURPLE        ; TYPHLOSION
	follower_pals WHITE_TEAL,   BLUE_GREEN    ; TOTODILE
	follower_pals WHITE_TEAL,   BLUE_GREEN    ; CROCONAW
	follower_pals WHITE_TEAL,   BLUE_GREEN    ; FERALIGATR
	follower_pals BROWN,        PURPLE_YELLOW ; SENTRET
	follower_pals BROWN,        PURPLE_BROWN  ; FURRET
	follower_pals WHITE_BROWN,  WHITE_YELLOW  ; HOOTHOOT
	follower_pals WHITE_BROWN,  WHITE_YELLOW  ; NOCTOWL
	follower_pals RED,          YELLOW_ORANGE ; LEDYBA
	follower_pals RED,          YELLOW_ORANGE ; LEDIAN
	follower_pals GREEN,        WHITE_PURPLE  ; SPINARAK
	follower_pals PURPLE_RED,   TEAL_PURPLE   ; ARIADOS
	follower_pals WHITE_PURPLE, WHITE_PINK    ; CROBAT
	follower_pals YELLOW_BLUE,  YELLOW_GRAY   ; CHINCHOU
	follower_pals BLUE,         YELLOW_BLUE   ; LANTURN
	follower_pals YELLOW_RED,   ORANGE_PURPLE ; PICHU
	follower_pals PINK_BROWN,   PINK_GREEN    ; CLEFFA
	follower_pals PINK_RED,     PINK_GREEN    ; IGGLYBUFF
	follower_pals WHITE_RED,    WHITE_BLUE    ; TOGEPI
	follower_pals WHITE_RED,    WHITE_BLUE    ; TOGETIC
	follower_pals RED_GREEN,    TEAL          ; NATU
	follower_pals RED_GREEN,    WHITE_GREEN   ; XATU
	follower_pals YELLOW_BLUE,  WHITE_PURPLE  ; MAREEP
	follower_pals WHITE_PINK,   WHITE_PINK    ; FLAAFFY
	follower_pals YELLOW_WHITE, WHITE_PURPLE  ; AMPHAROS
	follower_pals RED_GREEN,    RED_TEAL      ; BELLOSSOM
	follower_pals WHITE_BLUE,   WHITE_PINK    ; MARILL
	follower_pals WHITE_BLUE,   WHITE_YELLOW  ; AZUMARILL
	follower_pals BROWN_GREEN,  BROWN_PINK    ; SUDOWOODO
	follower_pals YELLOW_GREEN, WHITE_GRAY    ; POLITOED
	follower_pals GREEN_RED,    GREEN         ; HOPPIP
	follower_pals YELLOW_GREEN, YELLOW_PURPLE ; SKIPLOOM
	follower_pals WHITE_BLUE,   WHITE_PURPLE  ; JUMPLUFF
	follower_pals PURPLE,       PURPLE        ; AIPOM
	follower_pals YELLOW_GREEN, GREEN         ; SUNKERN
	follower_pals YELLOW_GREEN, YELLOW_BROWN  ; SUNFLORA
	follower_pals GREEN_RED,    GREEN_BLUE    ; YANMA
	follower_pals PURPLE_BLUE,  YELLOW_PINK   ; WOOPER
	follower_pals PURPLE_BLUE,  PURPLE        ; QUAGSIRE
	follower_pals PURPLE_WHITE, WHITE_GRAY    ; ESPEON
	follower_pals YELLOW_BROWN, BLUE_WHITE    ; UMBREON
	follower_pals YELLOW_BLACK, YELLOW_PURPLE ; MURKROW
	follower_pals RED_PINK,     BLUE_PINK     ; SLOWKING
	follower_pals PINK_PURPLE,  YELLOW_BROWN  ; MISDREAVUS
	follower_pals WHITE_GRAY,   WHITE_BLUE    ; UNOWN
	follower_pals TEAL,         PURPLE        ; WOBBUFFET
	follower_pals YELLOW_PINK,  YELLOW_BLUE   ; GIRAFARIG
	follower_pals WHITE_GRAY,   YELLOW_ORANGE ; PINECO
	follower_pals PINK_RED,     YELLOW_BROWN  ; FORRETRESS
	follower_pals YELLOW_BLUE,  YELLOW_PURPLE ; DUNSPARCE
	follower_pals BLUE_PURPLE,  BLUE_WHITE    ; GLIGAR
	follower_pals WHITE_GRAY,   BROWN         ; STEELIX
	follower_pals GRAY_PINK,    PINK_GRAY     ; SNUBBULL
	follower_pals WHITE_PURPLE, WHITE_GRAY    ; GRANBULL
	follower_pals BLUE,         WHITE_RED     ; QWILFISH
	follower_pals WHITE_RED,    WHITE_YELLOW  ; SCIZOR
	follower_pals RED,          BLUE          ; SHUCKLE
	follower_pals WHITE_BLUE,   WHITE_PURPLE  ; HERACROSS
	follower_pals PINK_BLACK,   YELLOW_PURPLE ; SNEASEL
	follower_pals WHITE_BROWN,  WHITE_GREEN   ; TEDDIURSA
	follower_pals YELLOW_BROWN, WHITE_GREEN   ; URSARING
	follower_pals RED,          WHITE_GRAY    ; SLUGMA
	follower_pals GRAY_RED,     WHITE_BLUE    ; MAGCARGO
	follower_pals BROWN,        BLUE_GRAY     ; SWINUB
	follower_pals WHITE_BROWN,  WHITE_YELLOW  ; PILOSWINE
	follower_pals WHITE_PINK,   WHITE_TEAL    ; CORSOLA
	follower_pals WHITE_GRAY,   GRAY_WHITE    ; REMORAID
	follower_pals YELLOW_RED,   YELLOW_WHITE  ; OCTILLERY
	follower_pals WHITE_RED,    YELLOW_PURPLE ; DELIBIRD
	follower_pals WHITE_BLACK,  WHITE_BLUE    ; MANTINE
	follower_pals WHITE_RED,    WHITE_GREEN   ; SKARMORY
	follower_pals WHITE_RED,    WHITE_BLUE    ; HOUNDOUR
	follower_pals WHITE_RED,    WHITE_BLUE    ; HOUNDOOM
	follower_pals BLUE,         WHITE_PURPLE  ; KINGDRA
	follower_pals RED_BLUE,     RED_WHITE     ; PHANPY
	follower_pals WHITE_GRAY,   GRAY_ORANGE   ; DONPHAN
	follower_pals BLUE_RED,     BLUE_WHITE    ; PORYGON2
	follower_pals WHITE_BROWN,  WHITE_GREEN   ; STANTLER
	follower_pals BROWN,        GREEN         ; SMEARGLE
	follower_pals BROWN_PINK,   BLUE_WHITE    ; TYROGUE
	follower_pals BLUE,         WHITE_PURPLE  ; HITMONTOP
	follower_pals YELLOW_PURPLE, YELLOW_PINK   ; SMOOCHUM
	follower_pals YELLOW_WHITE, ORANGE_WHITE  ; ELEKID
	follower_pals RED,          YELLOW_ORANGE ; MAGBY
	follower_pals WHITE_PINK,   WHITE_GRAY    ; MILTANK
	follower_pals PINK_WHITE,   PURPLE_WHITE  ; BLISSEY
	follower_pals YELLOW_PURPLE, ORANGE_YELLOW ; RAIKOU
	follower_pals WHITE_RED,    WHITE_BROWN   ; ENTEI
	follower_pals TEAL_PURPLE,  WHITE_GRAY    ; SUICUNE
	follower_pals RED_GREEN,    PURPLE_GRAY   ; LARVITAR
	follower_pals WHITE_BLUE,   WHITE_PURPLE  ; PUPITAR
	follower_pals BLUE_GREEN,   PURPLE_GRAY   ; TYRANITAR
	follower_pals WHITE_BLUE,   WHITE_RED     ; LUGIA
	follower_pals RED_WHITE,    YELLOW_WHITE  ; HO_OH
	follower_pals WHITE_GREEN,  WHITE_PINK    ; CELEBI
	follower_pals YELLOW_BLACK, ORANGE_RED    ; ELECTIVIRE
	follower_pals YELLOW_RED,   YELLOW_ORANGE ; MAGMORTAR
	follower_pals PURPLE,       PINK          ; AMBIPOM
	follower_pals PURPLE,       GRAY          ; ANNIHILAPE (icon colours; no Mystic pick)
	follower_pals WHITE_BLUE,   WHITE_PINK    ; HONCHKROW
	follower_pals GREEN,        RED           ; LEAFEON
	follower_pals WHITE_PINK,   YELLOW        ; LICKILICKY
	follower_pals WHITE_BROWN,  YELLOW_BROWN  ; MAMOSWINE
	follower_pals PINK_PURPLE,  YELLOW_BROWN  ; MISMAGIUS
	follower_pals GRAY_ORANGE,  WHITE_YELLOW  ; RHYPERIOR
	follower_pals WHITE_PINK,   WHITE_BLUE    ; SYLVEON
	follower_pals WHITE_RED,    RED           ; TOGEKISS
	follower_pals ORANGE_GRAY,  PINK          ; WEAVILE
	follower_pals ORANGE_GREEN, PINK_BLUE     ; YANMEGA
	follower_pals WHITE_TEAL,   BLUE_WHITE    ; GLACEON
	follower_pals ORANGE_PURPLE, YELLOW_TEAL   ; GLISCOR
	follower_pals ORANGE_GRAY,  YELLOW_WHITE  ; MAGNEZONE
	follower_pals BLUE_RED,     PINK_BLUE     ; PORYGON_Z
	follower_pals BROWN,        GREEN         ; SIRFETCH_D (icon colours; no Mystic pick)
	follower_pals PINK_BLUE,    PINK_GREEN    ; TANGROWTH
	follower_pals BROWN,        PURPLE        ; WYRDEER (icon colours; no Mystic pick)
	follower_pals RED,          BLUE          ; FARIGIRAF (icon colours; no Mystic pick)
	follower_pals BLUE,         PINK          ; DUDUNSPARC
	follower_pals BROWN,        GREEN         ; URSALUNA (icon colours; no Mystic pick)
	follower_pals GRAY,         PURPLE        ; CURSOLA (icon colours; no Mystic pick)
	follower_pals GRAY,         PURPLE        ; CORSOLA_KANTO (icon colours; no Mystic pick)
	follower_pals BROWN,        RED           ; RAICHU_ORANGE (icon colours; no Mystic pick)
	follower_pals BLUE,         TEAL          ; DRAGONITE_KANTO (icon colours; no Mystic pick)
	assert_table_length NUM_POKEMON_AND_VARIANTS

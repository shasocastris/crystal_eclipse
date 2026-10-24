; pokemon ids
;
; Tables sized NUM_POKEMON_AND_VARIANTS -- these cover variant species too, so
; a new variant needs an entry in every one of them:
; - PokemonNames (see data/pokemon/names.asm)
; - BaseData (see data/pokemon/base_stats.asm)
; - EvosAttacksPointers (see data/pokemon/evos_attacks.asm)
; - PokemonCries (see data/pokemon/cries.asm)
; - IconPointers (see data/pokemon/icon_pointers.asm)
; - MonMenuIconPals (see data/pokemon/menu_icon_pals.asm)
; - PokemonPicPointers (see data/pokemon/pic_pointers.asm)
; - PokemonPalettes (see data/pokemon/palettes.asm)
; - FirstEvoStages (see data/pokemon/first_stages.asm)
; - AnimationPointers (see gfx/pokemon/anim_pointers.asm)
; - AnimationIdlePointers (see gfx/pokemon/idle_pointers.asm)
; - BitmasksPointers (see gfx/pokemon/bitmask_pointers.asm)
; - FramesPointers (see gfx/pokemon/frame_pointers.asm)
;
; Tables sized NUM_POKEMON -- these stop at the last real species, and variants
; must NOT be added to them. A variant reaches these through its base species
; via GetVariantBase, not on its own:
; - PokedexDataPointerTable (see data/pokemon/dex_entry_pointers.asm)
; - AlphabeticalPokedexOrder (see data/pokemon/dex_order_alpha.asm)
; - NewPokedexOrder (see data/pokemon/dex_order_new.asm)
; - Footprints (see gfx/footprints.asm)
; - wPokedexCaught / wPokedexSeen (see ram/wram.asm)
;
; Not indexed by species at all, despite their table lengths -- do not extend:
; - PokemonTypeLists (see data/types/pokemon_type_lists.asm) -- keyed by type
; - PokemonEvoLines (see data/pokemon/evo_lines.asm) -- keyed by LINE_*
	const_def 1
	const BULBASAUR  ; 01
	const IVYSAUR    ; 02
	const VENUSAUR   ; 03
	const CHARMANDER ; 04
	const CHARMELEON ; 05
	const CHARIZARD  ; 06
	const SQUIRTLE   ; 07
	const WARTORTLE  ; 08
	const BLASTOISE  ; 09
	const CATERPIE   ; 0a
	const METAPOD    ; 0b
	const BUTTERFREE ; 0c
	const WEEDLE     ; 0d
	const KAKUNA     ; 0e
	const BEEDRILL   ; 0f
	const PIDGEY     ; 10
	const PIDGEOTTO  ; 11
	const PIDGEOT    ; 12
	const RATTATA    ; 13
	const RATICATE   ; 14
	const SPEAROW    ; 15
	const FEAROW     ; 16
	const EKANS      ; 17
	const ARBOK      ; 18
	const PIKACHU    ; 19
	const RAICHU     ; 1a
	const SANDSHREW  ; 1b
	const SANDSLASH  ; 1c
	const NIDORAN_F  ; 1d
	const NIDORINA   ; 1e
	const NIDOQUEEN  ; 1f
	const NIDORAN_M  ; 20
	const NIDORINO   ; 21
	const NIDOKING   ; 22
	const CLEFAIRY   ; 23
	const CLEFABLE   ; 24
	const VULPIX     ; 25
	const NINETALES  ; 26
	const JIGGLYPUFF ; 27
	const WIGGLYTUFF ; 28
	const ZUBAT      ; 29
	const GOLBAT     ; 2a
	const ODDISH     ; 2b
	const GLOOM      ; 2c
	const VILEPLUME  ; 2d
	const PARAS      ; 2e
	const PARASECT   ; 2f
	const VENONAT    ; 30
	const VENOMOTH   ; 31
	const DIGLETT    ; 32
	const DUGTRIO    ; 33
	const MEOWTH     ; 34
	const PERSIAN    ; 35
	const PSYDUCK    ; 36
	const GOLDUCK    ; 37
	const MANKEY     ; 38
	const PRIMEAPE   ; 39
	const GROWLITHE  ; 3a
	const ARCANINE   ; 3b
	const POLIWAG    ; 3c
	const POLIWHIRL  ; 3d
	const POLIWRATH  ; 3e
	const ABRA       ; 3f
	const KADABRA    ; 40
	const ALAKAZAM   ; 41
	const MACHOP     ; 42
	const MACHOKE    ; 43
	const MACHAMP    ; 44
	const BELLSPROUT ; 45
	const WEEPINBELL ; 46
	const VICTREEBEL ; 47
	const TENTACOOL  ; 48
	const TENTACRUEL ; 49
	const GEODUDE    ; 4a
	const GRAVELER   ; 4b
	const GOLEM      ; 4c
	const PONYTA     ; 4d
	const RAPIDASH   ; 4e
	const SLOWPOKE   ; 4f
	const SLOWBRO    ; 50
	const MAGNEMITE  ; 51
	const MAGNETON   ; 52
	const FARFETCH_D ; 53
	const DODUO      ; 54
	const DODRIO     ; 55
	const SEEL       ; 56
	const DEWGONG    ; 57
	const GRIMER     ; 58
	const MUK        ; 59
	const SHELLDER   ; 5a
	const CLOYSTER   ; 5b
	const GASTLY     ; 5c
	const HAUNTER    ; 5d
	const GENGAR     ; 5e
	const ONIX       ; 5f
	const DROWZEE    ; 60
	const HYPNO      ; 61
	const KRABBY     ; 62
	const KINGLER    ; 63
	const VOLTORB    ; 64
	const ELECTRODE  ; 65
	const EXEGGCUTE  ; 66
	const EXEGGUTOR  ; 67
	const CUBONE     ; 68
	const MAROWAK    ; 69
	const HITMONLEE  ; 6a
	const HITMONCHAN ; 6b
	const LICKITUNG  ; 6c
	const KOFFING    ; 6d
	const WEEZING    ; 6e
	const RHYHORN    ; 6f
	const RHYDON     ; 70
	const CHANSEY    ; 71
	const TANGELA    ; 72
	const KANGASKHAN ; 73
	const HORSEA     ; 74
	const SEADRA     ; 75
	const GOLDEEN    ; 76
	const SEAKING    ; 77
	const STARYU     ; 78
	const STARMIE    ; 79
	const MR__MIME   ; 7a
	const SCYTHER    ; 7b
	const JYNX       ; 7c
	const ELECTABUZZ ; 7d
	const MAGMAR     ; 7e
	const PINSIR     ; 7f
	const TAUROS     ; 80
	const MAGIKARP   ; 81
	const GYARADOS   ; 82
	const LAPRAS     ; 83
	const DITTO      ; 84
	const EEVEE      ; 85
	const VAPOREON   ; 86
	const JOLTEON    ; 87
	const FLAREON    ; 88
	const PORYGON    ; 89
	const OMANYTE    ; 8a
	const OMASTAR    ; 8b
	const KABUTO     ; 8c
	const KABUTOPS   ; 8d
	const AERODACTYL ; 8e
	const SNORLAX    ; 8f
	const ARTICUNO   ; 90
	const ZAPDOS     ; 91
	const MOLTRES    ; 92
	const DRATINI    ; 93
	const DRAGONAIR  ; 94
	const DRAGONITE  ; 95
	const MEWTWO     ; 96
	const MEW        ; 97
DEF NUM_KANTO_POKEMON EQU const_value - 1
DEF JOHTO_POKEMON EQU const_value
	const CHIKORITA  ; 98
	const BAYLEEF    ; 99
	const MEGANIUM   ; 9a
	const CYNDAQUIL  ; 9b
	const QUILAVA    ; 9c
	const TYPHLOSION ; 9d
	const TOTODILE   ; 9e
	const CROCONAW   ; 9f
	const FERALIGATR ; a0
	const SENTRET    ; a1
	const FURRET     ; a2
	const HOOTHOOT   ; a3
	const NOCTOWL    ; a4
	const LEDYBA     ; a5
	const LEDIAN     ; a6
	const SPINARAK   ; a7
	const ARIADOS    ; a8
	const CROBAT     ; a9
	const CHINCHOU   ; aa
	const LANTURN    ; ab
	const PICHU      ; ac
	const CLEFFA     ; ad
	const IGGLYBUFF  ; ae
	const TOGEPI     ; af
	const TOGETIC    ; b0
	const NATU       ; b1
	const XATU       ; b2
	const MAREEP     ; b3
	const FLAAFFY    ; b4
	const AMPHAROS   ; b5
	const BELLOSSOM  ; b6
	const MARILL     ; b7
	const AZUMARILL  ; b8
	const SUDOWOODO  ; b9
	const POLITOED   ; ba
	const HOPPIP     ; bb
	const SKIPLOOM   ; bc
	const JUMPLUFF   ; bd
	const AIPOM      ; be
	const SUNKERN    ; bf
	const SUNFLORA   ; c0
	const YANMA      ; c1
	const WOOPER     ; c2
	const QUAGSIRE   ; c3
	const ESPEON     ; c4
	const UMBREON    ; c5
	const MURKROW    ; c6
	const SLOWKING   ; c7
	const MISDREAVUS ; c8
	const UNOWN      ; c9
	const WOBBUFFET  ; ca
	const GIRAFARIG  ; cb
	const PINECO     ; cc
	const FORRETRESS ; cd
	const DUNSPARCE  ; ce
	const GLIGAR     ; cf
	const STEELIX    ; d0
	const SNUBBULL   ; d1
	const GRANBULL   ; d2
	const QWILFISH   ; d3
	const SCIZOR     ; d4
	const SHUCKLE    ; d5
	const HERACROSS  ; d6
	const SNEASEL    ; d7
	const TEDDIURSA  ; d8
	const URSARING   ; d9
	const SLUGMA     ; da
	const MAGCARGO   ; db
	const SWINUB     ; dc
	const PILOSWINE  ; dd
	const CORSOLA    ; de
	const REMORAID   ; df
	const OCTILLERY  ; e0
	const DELIBIRD   ; e1
	const MANTINE    ; e2
	const SKARMORY   ; e3
	const HOUNDOUR   ; e4
	const HOUNDOOM   ; e5
	const KINGDRA    ; e6
	const PHANPY     ; e7
	const DONPHAN    ; e8
	const PORYGON2   ; e9
	const STANTLER   ; ea
	const SMEARGLE   ; eb
	const TYROGUE    ; ec
	const HITMONTOP  ; ed
	const SMOOCHUM   ; ee
	const ELEKID     ; ef
	const MAGBY      ; f0
	const MILTANK    ; f1
	const BLISSEY    ; f2
	const RAIKOU     ; f3
	const ENTEI      ; f4
	const SUICUNE    ; f5
	const LARVITAR   ; f6
	const PUPITAR    ; f7
	const TYRANITAR  ; f8
	const LUGIA      ; f9
	const HO_OH      ; fa
	const CELEBI     ; fb
DEF NUM_JOHTO_POKEMON EQU const_value - 1
	const ELECTIVIRE  ; fc
	const MAGMORTAR   ; fd
	const AMBIPOM     ; fe
	const ANNIHILAPE  ; ff
	const HONCHKROW   ; 100
	const LEAFEON     ; 101
	const LICKILICKY  ; 102
	const MAMOSWINE   ; 103
	const MISMAGIUS   ; 104
	const RHYPERIOR   ; 105
	const SYLVEON     ; 106
	const TOGEKISS    ; 107
	const WEAVILE     ; 108
	const YANMEGA     ; 109
	const GLACEON     ; 10a
	const GLISCOR     ; 10b
	const MAGNEZONE   ; 10c
	const PORYGON_Z   ; 10d
	const SIRFETCH_D  ; 10e
	const TANGROWTH   ; 10f
	const WYRDEER     ; 110
	const FARIGIRAF   ; 111
	const DUDUNSPARC  ; 112
	const URSALUNA    ; 113
	const CURSOLA     ; 114
DEF NUM_POKEMON EQU const_value - 1

DEF EGG EQU -3

; limits:
; 999: everything that prints dex counts
; 1407: size of wPokedexOrder
; 4095: hard limit; would require serious redesign to increase
if NUM_POKEMON > 999
	fail "Too many Pokémon defined!"
endc

; --- VARIANT SPECIES (no Pokédex entries) ---
; Real species with their own base stats, types, sprites and learnsets,
; numbered past NUM_POKEMON so that every table indexed by NUM_POKEMON is
; unaffected. They redirect to their base species for all Pokédex purposes
; (see GetVariantBase), which is also what makes them count toward the type
; completion boost and Prof. Oak's rating.
;
; Do NOT add these to any dex-ordered table or to the seen/caught flag arrays.
; They DO belong in data/types/pokemon_type_lists.asm and in a *Line list in
; data/pokemon/evo_lines.asm, under their own form rather than the base
; species' -- both ask CheckCaughtForm, so a variant listed there means "this
; form specifically", and listing the base means the base form specifically.
; See docs/regional_variants_implementation_context.md.
;
; APPEND ONLY. VariantBaseSpecies is indexed by position in this block, and
; assert_table_length cannot catch a reordering.
;
; This block must stay above the "Unown forms" const_def below, which resets
; const_value to 1.
DEF VARIANTS_START EQU const_value

	const CORSOLA_KANTO ; Galarian Corsola; Kanto coastal waters
	const RAICHU_ORANGE ; Alolan Raichu; Thunderstone on a Pikachu in the Orange
	                    ; Islands. See PikachuEvosAttacks.
	const DRAGONITE_KANTO ; Dragon/Flying; from a Dragonair that levels in Kanto

; --- RESERVED ROSTER (Bryan's final list) ---
; Names only. A variant is not a `const` until every species-indexed table has a
; row for it -- adding a bare one fails ~15 assert_table_length checks, because
; those tables are direct-indexed and a gap would read whatever follows.
; Promote a name to a const above when it is fleshed out.
;
; 25 of MAX_VARIANTS 32. The saved arrays are already sized for the ceiling, so
; every one of these is paid for: adding them shifts nothing in the save block.
;
;   Orange Islands (M3)     Kanto
;   -------------------     -----
;   RAICHU_ORANGE   [done]  PONYTA_KANTO
;   SANDSHREW_ORANGE        RAPIDASH_KANTO
;   SANDSLASH_ORANGE        SLOWPOKE_KANTO
;   VULPIX_ORANGE           SLOWBRO_KANTO
;   NINETALES_ORANGE        SLOWKING_KANTO
;   GROWLITHE_ORANGE        WEEZING_KANTO
;   ARCANINE_ORANGE         CORSOLA_KANTO      [done]
;   GEODUDE_ORANGE          DRAGONITE_KANTO    [done]
;   GRAVELER_ORANGE
;   GOLEM_ORANGE
;   GRIMER_ORANGE
;   MUK_ORANGE
;   EXEGGUTOR_ORANGE
;   MAROWAK_ORANGE
;   VOLTORB_ORANGE
;   ELECTRODE_ORANGE
;   DRAGONITE_ORANGE
;
; A name may reference a region that does not exist yet -- it is just an
; identifier. ORANGE_REGION itself arrives with M3; until then an _ORANGE form
; can be defined but not region-gated, and has no way to be obtained.
;
; ⚠️ DRAGONITE is the only base with TWO variants. GetSpeciesVariant returns the
; FIRST match and stops, so the Pokedex form toggle can only ever reach one of
; them. Catching, stats, typing and type lists are all fine; only the dex view
; is limited. Cycling needs a "next variant after this one" helper -- worth
; doing when DRAGONITE_ORANGE lands, not before.
;
; RAICHU_ORANGE is obtained where it belongs as of M3: Pikachu's EVOLVE_REGION
; gate names ORANGE_REGION, and Pikachu is catchable on Shamouti Island. Only
; that form is gated -- the plain RAICHU entry after it is ungated so it stays
; the default everywhere else, Johto included.

DEF NUM_VARIANTS EQU const_value - VARIANTS_START
DEF NUM_POKEMON_AND_VARIANTS EQU const_value - 1

; Ceiling on the variant roster, fixed because wVariantCaught and
; wVariantBaseCaught are saved: their size is what pins everything after them in
; the save block, so it is reserved for MAX_VARIANTS up front and NUM_VARIANTS
; may grow into it freely. Raising this is a save-format break.
DEF MAX_VARIANTS EQU 32
if NUM_VARIANTS > MAX_VARIANTS
	fail "Too many variant species -- see wVariantCaught in ram/wram.asm"
endc

; Unown forms
; indexes for:
; - UnownWords (see data/pokemon/unown_words.asm)
; - UnownPicPointers (see data/pokemon/unown_pic_pointers.asm)
; - UnownAnimationPointers (see gfx/pokemon/unown_anim_pointers.asm)
; - UnownAnimationIdlePointers (see gfx/pokemon/unown_idle_pointers.asm)
; - UnownBitmasksPointers (see gfx/pokemon/unown_bitmask_pointers.asm)
; - UnownFramesPointers (see gfx/pokemon/unown_frame_pointers.asm)
	const_def 1
	const UNOWN_A ;  1
	const UNOWN_B ;  2
	const UNOWN_C ;  3
	const UNOWN_D ;  4
	const UNOWN_E ;  5
	const UNOWN_F ;  6
	const UNOWN_G ;  7
	const UNOWN_H ;  8
	const UNOWN_I ;  9
	const UNOWN_J ; 10
	const UNOWN_K ; 11
	const UNOWN_L ; 12
	const UNOWN_M ; 13
	const UNOWN_N ; 14
	const UNOWN_O ; 15
	const UNOWN_P ; 16
	const UNOWN_Q ; 17
	const UNOWN_R ; 18
	const UNOWN_S ; 19
	const UNOWN_T ; 20
	const UNOWN_U ; 21
	const UNOWN_V ; 22
	const UNOWN_W ; 23
	const UNOWN_X ; 24
	const UNOWN_Y ; 25
	const UNOWN_Z ; 26
DEF NUM_UNOWN EQU const_value - 1 ; 26

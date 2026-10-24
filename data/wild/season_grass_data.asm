; Seasonal grass encounters -- ONE column per season.
;
; INCLUDEd four times by season_grass.asm, once per season, with SEASON_COLUMN
; selecting which column is emitted. The ROM layout is four separate tables.
;
; SUMMER is the base game. Its column is the sentinel "-, -" and the map is
; simply omitted from SummerGrassWildMons, so the lookup misses and falls
; through to the Johto/Kanto table. The trailing comment shows what that is.
;
; Those comments are checked by utils/check_season_comments.py -- run it after
; touching a base table, or it will quietly start lying.
;
; A map absent from this file entirely uses the base table in every season,
; which is how every cave and indoor map is handled.

	def_season_grass ROUTE_30, ANYSEASON & ~SUMMER
	;          SPRING        SUMMER  AUTUMN        WINTER        ; SUMMER = base
	seasonrate 10,           -,      10,           6             ; 10
	; morn
	seasonmon  3, HOPPIP,    -, -,   5, SENTRET,   4, RATTATA    ; 3, LEDYBA
	seasonmon  3, HOPPIP,    -, -,   6, SENTRET,   5, RATTATA    ; 3, MARILL
	seasonmon  4, LEDYBA,    -, -,   5, PIDGEY,    5, PIDGEY     ; 4, HOPPIP
	seasonmon  4, CATERPIE,  -, -,   5, CATERPIE,  4, SENTRET    ; 4, CATERPIE
	seasonmon  3, WEEDLE,    -, -,   5, WEEDLE,    5, SENTRET    ; 3, WEEDLE
	seasonmon  4, PIDGEY,    -, -,   6, MARILL,    5, PIDGEY     ; 4, PIDGEY
	seasonmon  4, MARILL,    -, -,   6, FURRET,    6, FURRET     ; 4, PIDGEY
	; day
	seasonmon  3, HOPPIP,    -, -,   5, SENTRET,   4, RATTATA    ; 3, LEDYBA
	seasonmon  3, HOPPIP,    -, -,   6, SENTRET,   5, RATTATA    ; 3, MARILL
	seasonmon  4, SKIPLOOM,  -, -,   5, PIDGEY,    5, PIDGEY     ; 4, HOPPIP
	seasonmon  4, CATERPIE,  -, -,   6, SKIPLOOM,  4, SENTRET    ; 4, CATERPIE
	seasonmon  3, WEEDLE,    -, -,   5, WEEDLE,    5, SENTRET    ; 3, WEEDLE
	seasonmon  4, PIDGEY,    -, -,   6, MARILL,    5, PIDGEY     ; 4, PIDGEY
	seasonmon  4, MARILL,    -, -,   6, FURRET,    6, FURRET     ; 4, PIDGEY
	; nite
	seasonmon  3, SPINARAK,  -, -,   5, HOOTHOOT,  5, HOOTHOOT   ; 3, SPINARAK
	seasonmon  3, HOOTHOOT,  -, -,   6, HOOTHOOT,  5, RATTATA    ; 3, HOOTHOOT
	seasonmon  4, POLIWAG,   -, -,   5, RATTATA,   6, HOOTHOOT   ; 4, POLIWAG
	seasonmon  4, RATTATA,   -, -,   6, SENTRET,   5, ZUBAT      ; 4, RATTATA
	seasonmon  3, ZUBAT,     -, -,   5, ZUBAT,     6, ZUBAT      ; 3, ZUBAT
	seasonmon  4, ODDISH,    -, -,   6, ODDISH,    6, NOCTOWL    ; 4, ODDISH
	seasonmon  4, HOPPIP,    -, -,   6, NOCTOWL,   6, NOCTOWL    ; 4, ODDISH
	end_season_grass

	def_season_grass ROUTE_35, ANYSEASON & ~SUMMER
	;          SPRING          SUMMER  AUTUMN           WINTER           ; SUMMER = base
	seasonrate 10,             -,      10,              6                ; 10
	; morn
	seasonmon  15, HOPPIP,     -, -,   17, SNUBBULL,    16, SNUBBULL     ; 16, SNUBBULL
	seasonmon  17, LEDYBA,     -, -,   19, MAGNEMITE,   18, MAGNEMITE    ; 18, MAGNEMITE
	seasonmon  16, SNUBBULL,   -, -,   18, SKIPLOOM,    17, VULPIX       ; 17, VULPIX
	seasonmon  14, ABRA,       -, -,   16, ABRA,        15, ABRA         ; 14, ABRA
	seasonmon  15, JIGGLYPUFF, -, -,   17, JIGGLYPUFF,  16, JIGGLYPUFF   ; 16, JIGGLYPUFF
	seasonmon  13, YANMA,      -, -,   16, YANMA,       15, MAGNEMITE    ; 14, YANMA
	seasonmon  15, YANMA,      -, -,   18, YANMA,       17, VULPIX       ; 16, YANMA
	; day
	seasonmon  15, HOPPIP,     -, -,   17, SNUBBULL,    16, SNUBBULL     ; 16, SNUBBULL
	seasonmon  17, MAGNEMITE,  -, -,   19, MAGNEMITE,   18, MAGNEMITE    ; 18, MAGNEMITE
	seasonmon  16, SKIPLOOM,   -, -,   18, GROWLITHE,   17, GROWLITHE    ; 17, GROWLITHE
	seasonmon  14, ABRA,       -, -,   16, ABRA,        15, ABRA         ; 14, ABRA
	seasonmon  15, JIGGLYPUFF, -, -,   17, JIGGLYPUFF,  16, JIGGLYPUFF   ; 16, JIGGLYPUFF
	seasonmon  13, YANMA,      -, -,   16, YANMA,       15, MAGNEMITE    ; 14, YANMA
	seasonmon  15, YANMA,      -, -,   18, YANMA,       17, GROWLITHE    ; 16, YANMA
	; nite
	seasonmon  15, SPINARAK,   -, -,   17, DROWZEE,     16, DROWZEE      ; 16, DROWZEE
	seasonmon  17, HOOTHOOT,   -, -,   20, NOCTOWL,     18, HOOTHOOT     ; 18, HOOTHOOT
	seasonmon  16, DROWZEE,    -, -,   18, HOUNDOUR,    17, HOUNDOUR     ; 17, HOUNDOUR
	seasonmon  14, ABRA,       -, -,   16, ABRA,        15, ABRA         ; 14, ABRA
	seasonmon  15, JIGGLYPUFF, -, -,   17, JIGGLYPUFF,  16, JIGGLYPUFF   ; 16, JIGGLYPUFF
	seasonmon  13, YANMA,      -, -,   16, YANMA,       15, HOOTHOOT     ; 14, YANMA
	seasonmon  15, YANMA,      -, -,   18, YANMA,       17, HOUNDOUR     ; 16, YANMA
	end_season_grass

	def_season_grass ROUTE_45, ANYSEASON & ~SUMMER
	;          SPRING         SUMMER  AUTUMN          WINTER          ; SUMMER = base
	seasonrate 15,            -,      15,             9               ; 15
	; morn
	seasonmon  31, GEODUDE,   -, -,   35, GRAVELER,   33, SWINUB      ; 33, GRAVELER
	seasonmon  32, GEODUDE,   -, -,   36, GRAVELER,   34, SWINUB      ; 33, GLIGAR
	seasonmon  33, GRAVELER,  -, -,   35, GLIGAR,     34, GRAVELER    ; 34, MAGCARGO
	seasonmon  33, GLIGAR,    -, -,   36, MAGCARGO,   35, PILOSWINE   ; 35, DONPHAN
	seasonmon  31, SKARMORY,  -, -,   33, SKARMORY,   33, SNEASEL     ; 31, SKARMORY
	seasonmon  41, RHYDON,    -, -,   44, RHYDON,     42, GOLEM       ; 42, RHYDON
	seasonmon  42, RHYDON,    -, -,   45, RHYDON,     43, GOLEM       ; 43, RHYDON
	; day
	seasonmon  31, GEODUDE,   -, -,   35, GRAVELER,   33, SWINUB      ; 33, GRAVELER
	seasonmon  32, GEODUDE,   -, -,   36, GRAVELER,   34, SWINUB      ; 33, GLIGAR
	seasonmon  33, GRAVELER,  -, -,   35, GLIGAR,     34, GRAVELER    ; 34, MAGCARGO
	seasonmon  33, GLIGAR,    -, -,   36, MAGCARGO,   35, PILOSWINE   ; 35, DONPHAN
	seasonmon  31, SKARMORY,  -, -,   37, DONPHAN,    33, SNEASEL     ; 31, SKARMORY
	seasonmon  41, RHYDON,    -, -,   44, RHYDON,     42, GOLEM       ; 42, RHYDON
	seasonmon  42, RHYDON,    -, -,   45, RHYDON,     43, GOLEM       ; 43, RHYDON
	; nite
	seasonmon  31, GEODUDE,   -, -,   35, GRAVELER,   33, SWINUB      ; 33, GRAVELER
	seasonmon  33, GRAVELER,  -, -,   36, GRAVELER,   34, SNEASEL     ; 33, GLIGAR
	seasonmon  33, GLIGAR,    -, -,   36, PILOSWINE,  35, SNEASEL     ; 34, PILOSWINE
	seasonmon  35, SKARMORY,  -, -,   37, SKARMORY,   35, PILOSWINE   ; 35, SKARMORY
	seasonmon  37, PRIMEAPE,  -, -,   39, PRIMEAPE,   34, DELIBIRD    ; 37, PRIMEAPE
	seasonmon  41, GOLEM,     -, -,   44, GOLEM,      42, GOLEM       ; 42, GOLEM
	seasonmon  42, GOLEM,     -, -,   45, GOLEM,      43, GOLEM       ; 43, GOLEM
	end_season_grass

; Kanto

	def_season_grass ROUTE_2, ANYSEASON & ~SUMMER
	;          SPRING         SUMMER  AUTUMN         WINTER        ; SUMMER = base
	seasonrate 10,            -,      10,            6             ; 10
	; morn
	seasonmon  3, CATERPIE,   -, -,   4, PIDGEY,     3, PIDGEY     ; 3, BEEDRILL
	seasonmon  3, WEEDLE,     -, -,   4, PARAS,      3, METAPOD    ; 3, LEDYBA
	seasonmon  5, LEDYBA,     -, -,   6, BEEDRILL,   5, KAKUNA     ; 5, PIDGEY
	seasonmon  7, BUTTERFREE, -, -,   8, BUTTERFREE, 7, PIDGEOTTO  ; 7, BUTTERFREE
	seasonmon  7, LEDIAN,     -, -,   8, PIDGEOTTO,  7, PIDGEY     ; 7, LEDIAN
	seasonmon  4, PIKACHU,    -, -,   5, PIKACHU,    4, PIKACHU    ; 4, PIKACHU
	seasonmon  4, HOPPIP,     -, -,   5, PIKACHU,    4, PIKACHU    ; 4, PIKACHU
	; day
	seasonmon  3, CATERPIE,   -, -,   4, PIDGEY,     3, PIDGEY     ; 3, CATERPIE
	seasonmon  3, WEEDLE,     -, -,   4, PARAS,      3, METAPOD    ; 3, PIDGEY
	seasonmon  5, PIDGEY,     -, -,   6, PIDGEY,     5, KAKUNA     ; 5, BEEDRILL
	seasonmon  7, BUTTERFREE, -, -,   8, BUTTERFREE, 7, PIDGEOTTO  ; 7, BUTTERFREE
	seasonmon  7, BEEDRILL,   -, -,   8, PIDGEOTTO,  7, PIDGEY     ; 7, PIDGEOTTO
	seasonmon  4, PIKACHU,    -, -,   5, PIKACHU,    4, PIKACHU    ; 4, PIKACHU
	seasonmon  4, HOPPIP,     -, -,   5, PIKACHU,    4, PIKACHU    ; 4, PIKACHU
	; nite
	seasonmon  3, SPINARAK,   -, -,   4, HOOTHOOT,   3, HOOTHOOT   ; 3, HOOTHOOT
	seasonmon  3, HOOTHOOT,   -, -,   4, RATTATA,    3, RATTATA    ; 3, SPINARAK
	seasonmon  5, ODDISH,     -, -,   6, PARAS,      5, HOOTHOOT   ; 5, HOOTHOOT
	seasonmon  7, VENONAT,    -, -,   8, NOCTOWL,    7, NOCTOWL    ; 7, NOCTOWL
	seasonmon  7, ARIADOS,    -, -,   8, ARIADOS,    7, RATTATA    ; 7, ARIADOS
	seasonmon  4, NOCTOWL,    -, -,   5, NOCTOWL,    4, NOCTOWL    ; 4, NOCTOWL
	seasonmon  4, NOCTOWL,    -, -,   5, NOCTOWL,    4, NOCTOWL    ; 4, NOCTOWL
	end_season_grass

	def_season_grass ROUTE_14, ANYSEASON & ~SUMMER
	;          SPRING         SUMMER  AUTUMN         WINTER         ; SUMMER = base
	seasonrate 10,            -,      10,            6              ; 10
	; morn
	seasonmon  26, HOPPIP,    -, -,   27, NIDORINO,  26, NIDORINO   ; 26, NIDORINO
	seasonmon  26, NIDORINA,  -, -,   27, NIDORINA,  26, NIDORINA   ; 26, NIDORINA
	seasonmon  28, SKIPLOOM,  -, -,   29, PIDGEOTTO, 28, PIDGEOTTO  ; 28, PIDGEOTTO
	seasonmon  28, NIDORINO,  -, -,   29, PINECO,    28, SWINUB     ; 28, HOPPIP
	seasonmon  30, SKIPLOOM,  -, -,   31, SKIPLOOM,  30, PILOSWINE  ; 30, SKIPLOOM
	seasonmon  30, JUMPLUFF,  -, -,   31, PARASECT,  30, DELIBIRD   ; 30, SKIPLOOM
	seasonmon  28, CHANSEY,   -, -,   29, CHANSEY,   28, CHANSEY    ; 28, CHANSEY
	; day
	seasonmon  26, HOPPIP,    -, -,   27, NIDORINO,  26, NIDORINO   ; 26, NIDORINO
	seasonmon  26, NIDORINO,  -, -,   27, NIDORINA,  26, NIDORINA   ; 26, NIDORINA
	seasonmon  28, SKIPLOOM,  -, -,   29, PIDGEOTTO, 28, PIDGEOTTO  ; 28, PIDGEOTTO
	seasonmon  28, PIDGEOTTO, -, -,   29, PINECO,    28, SWINUB     ; 28, HOPPIP
	seasonmon  30, SKIPLOOM,  -, -,   31, JUMPLUFF,  30, PILOSWINE  ; 30, SKIPLOOM
	seasonmon  30, JUMPLUFF,  -, -,   31, PARASECT,  30, DELIBIRD   ; 30, SKIPLOOM
	seasonmon  28, CHANSEY,   -, -,   29, CHANSEY,   28, CHANSEY    ; 28, CHANSEY
	; nite
	seasonmon  26, VENONAT,   -, -,   27, VENONAT,   26, SWINUB     ; 26, VENONAT
	seasonmon  26, ODDISH,    -, -,   27, QUAGSIRE,  26, QUAGSIRE   ; 26, QUAGSIRE
	seasonmon  28, GLOOM,     -, -,   29, NOCTOWL,   28, NOCTOWL    ; 28, NOCTOWL
	seasonmon  28, VENOMOTH,  -, -,   29, VENOMOTH,  28, SNEASEL    ; 28, VENOMOTH
	seasonmon  28, QUAGSIRE,  -, -,   29, PARASECT,  28, QUAGSIRE   ; 28, QUAGSIRE
	seasonmon  28, NOCTOWL,   -, -,   29, MURKROW,   28, NOCTOWL    ; 28, QUAGSIRE
	seasonmon  28, CHANSEY,   -, -,   29, CHANSEY,   28, CHANSEY    ; 28, CHANSEY
	end_season_grass

	def_season_grass ROUTE_25, ANYSEASON & ~SUMMER
	;          SPRING          SUMMER  AUTUMN          WINTER         ; SUMMER = base
	seasonrate 10,             -,      10,             6              ; 10
	; morn
	seasonmon  10, HOPPIP,     -, -,   11, PIDGEY,     10, PIDGEY     ; 10, CATERPIE
	seasonmon  10, CATERPIE,   -, -,   11, PARAS,      10, RATTATA    ; 10, PIDGEY
	seasonmon  12, BELLSPROUT, -, -,   13, PIDGEOTTO,  12, PIDGEOTTO  ; 12, PIDGEOTTO
	seasonmon  12, ODDISH,     -, -,   13, METAPOD,    12, METAPOD    ; 12, METAPOD
	seasonmon  10, SUNKERN,    -, -,   11, BELLSPROUT, 10, PIDGEY     ; 10, BELLSPROUT
	seasonmon  14, SKIPLOOM,   -, -,   15, BUTTERFREE, 14, PIDGEOTTO  ; 14, BUTTERFREE
	seasonmon  14, BUTTERFREE, -, -,   15, BUTTERFREE, 14, DELIBIRD   ; 14, BUTTERFREE
	; day
	seasonmon  10, HOPPIP,     -, -,   11, PIDGEY,     10, PIDGEY     ; 10, CATERPIE
	seasonmon  10, PIDGEY,     -, -,   11, PARAS,      10, RATTATA    ; 10, PIDGEY
	seasonmon  12, BELLSPROUT, -, -,   13, PIDGEOTTO,  12, PIDGEOTTO  ; 12, PIDGEOTTO
	seasonmon  12, SUNKERN,    -, -,   13, SUNKERN,    12, METAPOD    ; 12, METAPOD
	seasonmon  10, CATERPIE,   -, -,   11, BELLSPROUT, 10, PIDGEY     ; 10, BELLSPROUT
	seasonmon  14, SKIPLOOM,   -, -,   15, BUTTERFREE, 14, PIDGEOTTO  ; 14, BUTTERFREE
	seasonmon  14, BUTTERFREE, -, -,   15, BUTTERFREE, 14, DELIBIRD   ; 14, BUTTERFREE
	; nite
	seasonmon  10, ODDISH,     -, -,   11, HOOTHOOT,   10, HOOTHOOT   ; 10, ODDISH
	seasonmon  10, VENONAT,    -, -,   11, VENONAT,    10, RATTATA    ; 10, HOOTHOOT
	seasonmon  10, HOOTHOOT,   -, -,   11, PARAS,      10, HOOTHOOT   ; 10, VENONAT
	seasonmon  12, ODDISH,     -, -,   13, NOCTOWL,    12, NOCTOWL    ; 12, NOCTOWL
	seasonmon  10, BELLSPROUT, -, -,   11, ODDISH,     10, RATTATA    ; 10, BELLSPROUT
	seasonmon  14, GLOOM,      -, -,   15, NOCTOWL,    14, NOCTOWL    ; 14, NOCTOWL
	seasonmon  14, NOCTOWL,    -, -,   15, MURKROW,    14, SNEASEL    ; 14, NOCTOWL
	end_season_grass

	def_season_grass ROUTE_28, ANYSEASON & ~SUMMER
	;          SPRING          SUMMER  AUTUMN          WINTER          ; SUMMER = base
	seasonrate 10,             -,      10,             6               ; 10
	; morn
	seasonmon  69, TANGELA,    -, -,   70, TANGELA,    69, PILOSWINE   ; 69, TANGELA
	seasonmon  70, KANGASKHAN, -, -,   71, KANGASKHAN, 70, KANGASKHAN  ; 70, KANGASKHAN
	seasonmon  70, RAPIDASH,   -, -,   71, RAPIDASH,   70, DELIBIRD    ; 70, RAPIDASH
	seasonmon  72, ARBOK,      -, -,   73, URSARING,   72, WEAVILE     ; 72, ARBOK
	seasonmon  71, BEEDRILL,   -, -,   72, ARBOK,      71, JYNX        ; 71, BEEDRILL
	seasonmon  73, TANGROWTH,  -, -,   74, DODRIO,     73, DODRIO      ; 73, DODRIO
	seasonmon  73, DODRIO,     -, -,   74, URSALUNA,   73, MAMOSWINE   ; 73, DODRIO
	; day
	seasonmon  69, TANGELA,    -, -,   70, TANGELA,    69, PILOSWINE   ; 69, TANGELA
	seasonmon  70, KANGASKHAN, -, -,   71, KANGASKHAN, 70, KANGASKHAN  ; 70, KANGASKHAN
	seasonmon  70, RAPIDASH,   -, -,   71, RAPIDASH,   70, DELIBIRD    ; 70, RAPIDASH
	seasonmon  72, ARBOK,      -, -,   73, URSARING,   72, DODRIO      ; 72, ARBOK
	seasonmon  71, BEEDRILL,   -, -,   72, BEEDRILL,   71, JYNX        ; 71, BEEDRILL
	seasonmon  73, TANGROWTH,  -, -,   74, DODRIO,     73, WEAVILE     ; 73, DODRIO
	seasonmon  73, DODRIO,     -, -,   74, URSALUNA,   73, MAMOSWINE   ; 73, DODRIO
	; nite
	seasonmon  69, TANGELA,    -, -,   70, TANGELA,    69, PILOSWINE   ; 69, TANGELA
	seasonmon  70, POLIWHIRL,  -, -,   71, URSARING,   70, WEAVILE     ; 70, POLIWHIRL
	seasonmon  70, VENOMOTH,   -, -,   71, HOUNDOOM,   70, HOUNDOOM    ; 70, HOUNDOOM
	seasonmon  70, QUAGSIRE,   -, -,   71, QUAGSIRE,   70, QUAGSIRE    ; 70, QUAGSIRE
	seasonmon  72, POLIWRATH,  -, -,   73, POLIWRATH,  72, JYNX        ; 72, POLIWRATH
	seasonmon  72, CROBAT,     -, -,   73, CROBAT,     72, CROBAT      ; 72, CROBAT
	seasonmon  72, POLITOED,   -, -,   73, HONCHKROW,  72, MAMOSWINE   ; 72, CROBAT
	end_season_grass


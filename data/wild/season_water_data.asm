; Seasonal surfing encounters -- ONE column per season.
; See season_grass_data.asm. SUMMER is the base game and uses the sentinel.

	def_season_water LAKE_OF_RAGE, ANYSEASON & ~SUMMER
	;          SPRING         SUMMER  AUTUMN         WINTER         ; SUMMER = base
	seasonrate 25,            -,      18,            6              ; 20
	seasonmon  20, MAGIKARP,  -, -,   33, GYARADOS,  32, GYARADOS   ; 30, GYARADOS
	seasonmon  28, GYARADOS,  -, -,   36, GYARADOS,  26, MAGIKARP   ; 34, GYARADOS
	seasonmon  24, MAGIKARP,  -, -,   28, MAGIKARP,  30, SEEL       ; 25, MAGIKARP
	end_season_water

	def_season_water ROUTE_41, ANYSEASON & ~SUMMER
	;          SPRING          SUMMER  AUTUMN           WINTER           ; SUMMER = base
	seasonrate 15,             -,      15,              9                ; 15
	seasonmon  28, TENTACOOL,  -, -,   32, TENTACRUEL,  30, TENTACRUEL   ; 30, TENTACRUEL
	seasonmon  26, CHINCHOU,   -, -,   30, LANTURN,     31, SEEL         ; 27, LANTURN
	seasonmon  24, MANTINE,    -, -,   28, QWILFISH,    34, DEWGONG      ; 25, MANTINE
	end_season_water

; Kanto

	def_season_water ROUTE_20, ANYSEASON & ~SUMMER
	;          SPRING          SUMMER  AUTUMN          WINTER         ; SUMMER = base
	seasonrate 6,              -,      8,              4              ; 6
	seasonmon  35, TENTACOOL,  -, -,   36, TENTACOOL,  35, SEEL       ; 35, TENTACOOL
	seasonmon  30, STARYU,     -, -,   31, TENTACRUEL, 30, TENTACOOL  ; 30, TENTACOOL
	seasonmon  35, TENTACRUEL, -, -,   36, TENTACRUEL, 35, DEWGONG    ; 35, TENTACRUEL
	end_season_water

	def_season_water ROUTE_25, ANYSEASON & ~SUMMER
	;          SPRING       SUMMER  AUTUMN       WINTER       ; SUMMER = base
	seasonrate 6,           -,      4,           2            ; 4
	seasonmon  10, GOLDEEN, -, -,   11, GOLDEEN, 10, GOLDEEN  ; 10, GOLDEEN
	seasonmon  5, POLIWAG,  -, -,   6, PSYDUCK,  5, GOLDEEN   ; 5, GOLDEEN
	seasonmon  10, SEAKING, -, -,   11, SEAKING, 10, SEEL     ; 10, SEAKING
	end_season_water


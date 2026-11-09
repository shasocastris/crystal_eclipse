; data/pokemon/evo_lines.asm
;
; Evolution-line groupings used to gate the Safari Zone Move Tutor: a tutor
; move for a given species only unlocks once every member of that species'
; full evolutionary line (including branches) has been caught in the dex.
;
; Format mirrors data/types/pokemon_type_lists.asm:
;   PokemonEvoLines is a LINE_* -> pointer table, each pointer leads to a
;   dw-terminated (-1) species list consumed by CheckLineFullyCaught.
;
; Scope: only lines that actually have a row in data/pokemon/safari_move_tutor_moves.asm
; are included. Species with no tutor move (legendaries, Magikarp, Togepi,
; Mareep, Sunkern, etc.) are intentionally omitted — they'd be dead data.
;
; NOTE ON BRANCHES: branching lines (Poliwag, Eevee, Tyrogue, Oddish/Bellossom)
; require catching every branch, not just the direct ancestor chain to the
; tutor target species. See the "branching lines" design note from our move
; tutor discussion — flip this per-line to a subset list instead if you'd
; rather not require the full branching tree for lines like Eevee.

; ---------------------------------------------------------------------------
; LINE_* constants
; ---------------------------------------------------------------------------
	const_def
	; Kanto
	const LINE_BULBASAUR
	const LINE_CHARMANDER
	const LINE_SQUIRTLE
	const LINE_SPEAROW
	const LINE_NIDORAN_F
	const LINE_NIDORAN_M
	const LINE_ZUBAT
	const LINE_ODDISH
	const LINE_PARAS
	const LINE_PSYDUCK
	const LINE_POLIWAG
	const LINE_ABRA
	const LINE_MACHOP
	const LINE_BELLSPROUT
	const LINE_TENTACOOL
	const LINE_GEODUDE
	const LINE_PONYTA
	const LINE_MAGNEMITE
	const LINE_FARFETCH_D
	const LINE_DODUO
	const LINE_SEEL
	const LINE_ONIX
	const LINE_DROWZEE
	const LINE_KRABBY
	const LINE_VOLTORB
	const LINE_EXEGGCUTE
	const LINE_CUBONE
	const LINE_LICKITUNG
	const LINE_CHANSEY
	const LINE_TANGELA
	const LINE_KANGASKHAN
	const LINE_HORSEA
	const LINE_GOLDEEN
	const LINE_STARYU
	const LINE_MR_MIME
	const LINE_SCYTHER
	const LINE_PINSIR
	const LINE_TAUROS
	const LINE_MAGIKARP
	const LINE_LAPRAS
	const LINE_EEVEE
	const LINE_PORYGON
	const LINE_OMANYTE
	const LINE_KABUTO
	const LINE_AERODACTYL
	const LINE_SNORLAX
	const LINE_DRATINI
	; Johto
	const LINE_CHIKORITA
	const LINE_CYNDAQUIL
	const LINE_TOTODILE
	const LINE_SENTRET
	const LINE_HOOTHOOT
	const LINE_LEDYBA
	const LINE_SPINARAK
	const LINE_CHINCHOU
	const LINE_PICHU
	const LINE_CLEFFA
	const LINE_IGGLYBUFF
	const LINE_TOGEPI
	const LINE_NATU
	const LINE_MAREEP
	const LINE_MARILL
	const LINE_SUDOWOODO
	const LINE_HOPPIP
	const LINE_AIPOM
	const LINE_SUNKERN
	const LINE_YANMA
	const LINE_WOOPER
	const LINE_MURKROW
	const LINE_MISDREAVUS
	const LINE_WOBBUFFET
	const LINE_PINECO
	const LINE_DUNSPARCE
	const LINE_SNUBBULL
	const LINE_QWILFISH
	const LINE_HERACROSS
	const LINE_SNEASEL
	const LINE_TEDDIURSA
	const LINE_SWINUB
	const LINE_REMORAID
	const LINE_DELIBIRD
	const LINE_MANTINE
	const LINE_SKARMORY
	const LINE_PHANPY
	const LINE_STANTLER
	const LINE_TYROGUE
	const LINE_SMOOCHUM
	const LINE_ELEKID
	const LINE_MAGBY
	const LINE_MILTANK
	const LINE_LARVITAR
DEF NUM_EVO_LINES EQU const_value

; ---------------------------------------------------------------------------
; LINE_* -> species list pointer table
; ---------------------------------------------------------------------------
PokemonEvoLines:
	table_width 3
	dbw LINE_BULBASAUR, BulbasaurLine
	dbw LINE_CHARMANDER, CharmanderLine
	dbw LINE_SQUIRTLE, SquirtleLine
	dbw LINE_SPEAROW, SpearowLine
	dbw LINE_NIDORAN_F, NidoranFLine
	dbw LINE_NIDORAN_M, NidoranMLine
	dbw LINE_ZUBAT, ZubatLine
	dbw LINE_ODDISH, OddishLine
	dbw LINE_PARAS, ParasLine
	dbw LINE_PSYDUCK, PsyduckLine
	dbw LINE_POLIWAG, PoliwagLine
	dbw LINE_ABRA, AbraLine
	dbw LINE_MACHOP, MachopLine
	dbw LINE_BELLSPROUT, BellsproutLine
	dbw LINE_TENTACOOL, TentacoolLine
	dbw LINE_GEODUDE, GeodudeLine
	dbw LINE_PONYTA, PonytaLine
	dbw LINE_MAGNEMITE, MagnemiteLine
	dbw LINE_FARFETCH_D, FarfetchDLine
	dbw LINE_DODUO, DoduoLine
	dbw LINE_SEEL, SeelLine
	dbw LINE_ONIX, OnixLine
	dbw LINE_DROWZEE, DrowzeeLine
	dbw LINE_KRABBY, KrabbyLine
	dbw LINE_VOLTORB, VoltorbLine
	dbw LINE_EXEGGCUTE, ExeggcuteLine
	dbw LINE_CUBONE, CuboneLine
	dbw LINE_LICKITUNG, LickitungLine
	dbw LINE_CHANSEY, ChanseyLine
	dbw LINE_TANGELA, TangelaLine
	dbw LINE_KANGASKHAN, KangaskhanLine
	dbw LINE_HORSEA, HorseaLine
	dbw LINE_GOLDEEN, GoldeenLine
	dbw LINE_STARYU, StaryuLine
	dbw LINE_MR_MIME, MrMimeLine
	dbw LINE_SCYTHER, ScytherLine
	dbw LINE_PINSIR, PinsirLine
	dbw LINE_TAUROS, TaurosLine
	dbw LINE_MAGIKARP, MagikarpLine
	dbw LINE_LAPRAS, LaprasLine
	dbw LINE_EEVEE, EeveeLine
	dbw LINE_PORYGON, PorygonLine
	dbw LINE_OMANYTE, OmanyteLine
	dbw LINE_KABUTO, KabutoLine
	dbw LINE_AERODACTYL, AerodactylLine
	dbw LINE_SNORLAX, SnorlaxLine
	dbw LINE_DRATINI, DratiniLine
	dbw LINE_CHIKORITA, ChikoritaLine
	dbw LINE_CYNDAQUIL, CyndaquilLine
	dbw LINE_TOTODILE, TotodileLine
	dbw LINE_SENTRET, SentretLine
	dbw LINE_HOOTHOOT, HoothootLine
	dbw LINE_LEDYBA, LedybaLine
	dbw LINE_SPINARAK, SpinarakLine
	dbw LINE_CHINCHOU, ChinchouLine
	dbw LINE_PICHU, PichuLine
	dbw LINE_CLEFFA, CleffaLine
	dbw LINE_IGGLYBUFF, IgglybuffLine
	dbw LINE_TOGEPI, TogepiLine
	dbw LINE_NATU, NatuLine
	dbw LINE_MAREEP, MareepLine
	dbw LINE_MARILL, MarillLine
	dbw LINE_SUDOWOODO, SudowoodoLine
	dbw LINE_HOPPIP, HoppipLine
	dbw LINE_AIPOM, AipomLine
	dbw LINE_SUNKERN, SunkernLine
	dbw LINE_YANMA, YanmaLine
	dbw LINE_WOOPER, WooperLine
	dbw LINE_MURKROW, MurkrowLine
	dbw LINE_MISDREAVUS, MisdreavusLine
	dbw LINE_WOBBUFFET, WobbuffetLine
	dbw LINE_PINECO, PinecoLine
	dbw LINE_DUNSPARCE, DunsparceLine
	dbw LINE_SNUBBULL, SnubbullLine
	dbw LINE_QWILFISH, QwilfishLine
	dbw LINE_HERACROSS, HeracrossLine
	dbw LINE_SNEASEL, SneaselLine
	dbw LINE_TEDDIURSA, TeddiursaLine
	dbw LINE_SWINUB, SwinubLine
	dbw LINE_REMORAID, RemoraidLine
	dbw LINE_DELIBIRD, DelibirdLine
	dbw LINE_MANTINE, MantineLine
	dbw LINE_SKARMORY, SkarmoryLine
	dbw LINE_PHANPY, PhanpyLine
	dbw LINE_STANTLER, StantlerLine
	dbw LINE_TYROGUE, TyrogueLine
	dbw LINE_SMOOCHUM, SmoochumLine
	dbw LINE_ELEKID, ElekidLine
	dbw LINE_MAGBY, MagbyLine
	dbw LINE_MILTANK, MiltankLine
	dbw LINE_LARVITAR, LarvitarLine
	db -1 ; terminator, scanned by CheckLineFullyCaught

; ---------------------------------------------------------------------------
; Kanto lines
; ---------------------------------------------------------------------------
BulbasaurLine:  dw BULBASAUR, IVYSAUR, VENUSAUR, -1
CharmanderLine: dw CHARMANDER, CHARMELEON, CHARIZARD, -1
SquirtleLine:   dw SQUIRTLE, WARTORTLE, BLASTOISE, -1
SpearowLine:    dw SPEAROW, FEAROW, -1
NidoranFLine:   dw NIDORAN_F, NIDORINA, NIDOQUEEN, -1
NidoranMLine:   dw NIDORAN_M, NIDORINO, NIDOKING, -1

; Golbat -> Crobat via happiness; Crobat carries the Johto dex number
; but belongs to this line.
ZubatLine:      dw ZUBAT, GOLBAT, CROBAT, -1

; Branch: Gloom -> Vileplume (Leaf Stone) or Bellossom (Sun Stone).
; Requires catching both branch ends, per the branching-line default.
OddishLine:     dw ODDISH, GLOOM, VILEPLUME, BELLOSSOM, -1

ParasLine:      dw PARAS, PARASECT, -1
PsyduckLine:    dw PSYDUCK, GOLDUCK, -1

; Branch: Poliwhirl -> Poliwrath (Water Stone) or Politoed (King's Rock).
PoliwagLine:    dw POLIWAG, POLIWHIRL, POLIWRATH, POLITOED, -1

AbraLine:       dw ABRA, KADABRA, ALAKAZAM, -1
MachopLine:     dw MACHOP, MACHOKE, MACHAMP, -1
BellsproutLine: dw BELLSPROUT, WEEPINBELL, VICTREEBEL, -1
TentacoolLine:  dw TENTACOOL, TENTACRUEL, -1
GeodudeLine:    dw GEODUDE, GRAVELER, GOLEM, -1
PonytaLine:     dw PONYTA, RAPIDASH, -1
MagnemiteLine:  dw MAGNEMITE, MAGNETON, -1
FarfetchDLine:  dw FARFETCH_D, SIRFETCH_D, -1
DoduoLine:      dw DODUO, DODRIO, -1
SeelLine:       dw SEEL, DEWGONG, -1
OnixLine:       dw ONIX, STEELIX, -1
DrowzeeLine:    dw DROWZEE, HYPNO, -1
KrabbyLine:     dw KRABBY, KINGLER, -1
VoltorbLine:    dw VOLTORB, ELECTRODE, -1
ExeggcuteLine:  dw EXEGGCUTE, EXEGGUTOR, -1
CuboneLine:     dw CUBONE, MAROWAK, -1
LickitungLine:  dw LICKITUNG, -1 ; no evolution this generation
ChanseyLine:    dw CHANSEY, BLISSEY, -1
TangelaLine:    dw TANGELA, -1 ; no evolution this generation
KangaskhanLine: dw KANGASKHAN, -1 ; no evolution this generation
HorseaLine:     dw HORSEA, SEADRA, KINGDRA, -1
GoldeenLine:    dw GOLDEEN, SEAKING, -1
StaryuLine:     dw STARYU, STARMIE, -1
MrMimeLine:     dw MR__MIME, -1 ; no pre-evo this generation
ScytherLine:    dw SCYTHER, SCIZOR, -1
PinsirLine:     dw PINSIR, -1 ; no evolution this generation
TaurosLine:     dw TAUROS, -1 ; no evolution this generation
MagikarpLine:   dw MAGIKARP, GYARADOS, -1
LaprasLine:     dw LAPRAS, -1 ; no evolution this generation

; Branch: Eevee -> Vaporeon/Jolteon/Flareon (stones) or Espeon/Umbreon
; (happiness, day/night). All five count toward line completion.
EeveeLine:      dw EEVEE, VAPOREON, JOLTEON, FLAREON, ESPEON, UMBREON, -1

PorygonLine:    dw PORYGON, PORYGON2, -1
OmanyteLine:    dw OMANYTE, OMASTAR, -1
KabutoLine:     dw KABUTO, KABUTOPS, -1
AerodactylLine: dw AERODACTYL, -1 ; no evolution this generation
SnorlaxLine:    dw SNORLAX, -1 ; no evolution this generation
DratiniLine:    dw DRATINI, DRAGONAIR, DRAGONITE, -1

; ---------------------------------------------------------------------------
; Johto lines
; ---------------------------------------------------------------------------
ChikoritaLine:  dw CHIKORITA, BAYLEEF, MEGANIUM, -1
CyndaquilLine:  dw CYNDAQUIL, QUILAVA, TYPHLOSION, -1
TotodileLine:   dw TOTODILE, CROCONAW, FERALIGATR, -1
SentretLine:    dw SENTRET, FURRET, -1
HoothootLine:   dw HOOTHOOT, NOCTOWL, -1
LedybaLine:     dw LEDYBA, LEDIAN, -1
SpinarakLine:   dw SPINARAK, ARIADOS, -1
ChinchouLine:   dw CHINCHOU, LANTURN, -1
PichuLine:      dw PICHU, PIKACHU, RAICHU, RAICHU_ORANGE, -1
CleffaLine:     dw CLEFFA, CLEFAIRY, CLEFABLE, -1
IgglybuffLine:  dw IGGLYBUFF, JIGGLYPUFF, WIGGLYTUFF, -1
TogepiLine:     dw TOGEPI, TOGETIC, -1
NatuLine:       dw NATU, XATU, -1
MareepLine:     dw MAREEP, FLAAFFY, AMPHAROS, -1
MarillLine:     dw MARILL, AZUMARILL, -1
SudowoodoLine:  dw SUDOWOODO, -1 ; no pre-evo this generation
HoppipLine:     dw HOPPIP, SKIPLOOM, JUMPLUFF, -1
AipomLine:      dw AIPOM, -1 ; no evolution this generation
SunkernLine:    dw SUNKERN, SUNFLORA, -1
YanmaLine:      dw YANMA, -1 ; no evolution this generation
WooperLine:     dw WOOPER, QUAGSIRE, -1
MurkrowLine:    dw MURKROW, -1 ; no evolution this generation
MisdreavusLine: dw MISDREAVUS, -1 ; no evolution this generation
WobbuffetLine:  dw WOBBUFFET, -1 ; no pre-evo this generation
PinecoLine:     dw PINECO, FORRETRESS, -1
DunsparceLine:  dw DUNSPARCE, -1 ; no evolution this generation
SnubbullLine:   dw SNUBBULL, GRANBULL, -1
QwilfishLine:   dw QWILFISH, -1 ; no evolution this generation
HeracrossLine:  dw HERACROSS, -1 ; no evolution this generation
SneaselLine:    dw SNEASEL, -1 ; no evolution this generation
TeddiursaLine:  dw TEDDIURSA, URSARING, -1
SwinubLine:     dw SWINUB, PILOSWINE, -1
RemoraidLine:   dw REMORAID, OCTILLERY, -1
DelibirdLine:   dw DELIBIRD, -1 ; no evolution this generation
MantineLine:    dw MANTINE, -1 ; no pre-evo this generation
SkarmoryLine:   dw SKARMORY, -1 ; no evolution this generation
PhanpyLine:     dw PHANPY, DONPHAN, -1
StantlerLine:   dw STANTLER, -1 ; no evolution this generation

; Branch: Tyrogue -> Hitmonlee (ATK>DEF) / Hitmonchan (ATK<DEF) /
; Hitmontop (ATK=DEF). All three count toward line completion.
TyrogueLine:    dw TYROGUE, HITMONLEE, HITMONCHAN, HITMONTOP, -1

SmoochumLine:   dw SMOOCHUM, JYNX, -1
ElekidLine:     dw ELEKID, ELECTABUZZ, -1
MagbyLine:      dw MAGBY, MAGMAR, -1
MiltankLine:    dw MILTANK, -1 ; no evolution this generation
LarvitarLine:   dw LARVITAR, PUPITAR, TYRANITAR, -1

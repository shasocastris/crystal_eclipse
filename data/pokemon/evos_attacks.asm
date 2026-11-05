; Evolutions and attacks are grouped together since they're both checked at level-up.

SECTION "Evolutions and Attacks Pointers", ROMX

; Evos+attacks data structure:
; - Evolution methods:
;    * dbbw EVOLVE_LEVEL, level, species
;    * dbww EVOLVE_ITEM, used item, species
;    * dbbw EVOLVE_HAPPINESS, TR_* constant (ANYTIME, MORNDAY, EVENITE), species
;    * dbbbw EVOLVE_STAT, level, ATK_*_DEF constant (LT, GT, EQ), species
; - Gates, each guarding the one method entry after it:
;    * db EVOLVE_REGION, region
;    * db EVOLVE_LOCATION + map_id MAP
; - The first entry that matches wins.
; - db 0 ; no more evolutions
; - Learnset (in increasing level order):
;    * dbw level, move
; - db 0 ; no more level-up moves

EvosAttacksPointers::
	indirect_table 2, 1
	indirect_entries NUM_KANTO_POKEMON, EvosAttacksPointers1
	indirect_entries NUM_JOHTO_POKEMON, EvosAttacksPointers2
	indirect_entries NUM_POKEMON_AND_VARIANTS, EvosAttacksPointers3
	indirect_table_end

INCLUDE "data/pokemon/evos_attacks_kanto.asm"
INCLUDE "data/pokemon/evos_attacks_johto.asm"
INCLUDE "data/pokemon/evos_attacks_extra.asm"

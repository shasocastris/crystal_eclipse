MACRO anim_ptr
; One battle animation table entry. The bank is stored per entry, so an
; animation may live outside the bank of the table that references it --
; moves in one part reuse animations from the other. GetBattleAnimByte
; bankswitches to whatever is stored here, so a home-bank target would be
; meaningless.
	assert BANK(\1) != 0, "\1: battle animations must live in ROMX"
	db BANK(\1)
	dw \1
ENDM

BattleAnimations::
; entries correspond to constants/move_constants.asm
	indirect_table 3, 0
	indirect_entries MOVE_TABLE_SPLIT, BattleAnimationsPart1
	indirect_entries NUM_ATTACKS, BattleAnimationsPart2
	indirect_entries $ffff - NUM_BATTLE_ANIMS
	indirect_entries $ffff, BattleAnimationsNegatives
	indirect_table_end


SECTION "Battle Animations Part 1", ROMX

INCLUDE "data/moves/animations_part1.asm"


SECTION "Battle Animations Part 2", ROMX

INCLUDE "data/moves/animations_part2.asm"

SECTION "Battle Animations Gen Negatives", ROMX

INCLUDE "data/moves/animations_negatives.asm"

ENDSECTION
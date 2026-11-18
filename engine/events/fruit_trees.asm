FruitTreeScript::
	callasm GetCurTreeFruit
	opentext
	readmem wCurFruit
	getitemname STRING_BUFFER_3, USE_SCRIPT_VAR
	writetext FruitBearingTreeText
	promptbutton
	callasm TryResetFruitTrees
	callasm CheckFruitTree
	iffalse .fruit
	writetext NothingHereText
	waitbutton
	sjump .end

.fruit
	writetext HeyItsFruitText
	random 3
	ifequal 0, .pick_two
	ifequal 1, .pick_two
	readmem wCurFruit
	giveitem ITEM_FROM_MEM, 3
	iffalse .pick_two
	promptbutton
	writetext ObtainedThreeFruitText
	sjump .continue

.pick_two
	readmem wCurFruit
	giveitem ITEM_FROM_MEM, 2
	iffalse .pick_one
	promptbutton
	writetext ObtainedTwoFruitText
	sjump .continue

.pick_one
	readmem wCurFruit
	giveitem ITEM_FROM_MEM
	iffalse .packisfull
	promptbutton
	writetext FruitPackIsFullText
	promptbutton
	writetext ObtainedFruitText
	sjump .continue

.continue
	callasm PickedFruitTree
	specialsound
	itemnotify
	sjump .end

.packisfull
	promptbutton
	writetext FruitPackIsFullText
	waitbutton

.end
	closetext
	end

GetCurTreeFruit:
	ld a, [wCurFruitTree]
	dec a
	call GetFruitTreeItem
	ld [wCurFruit], a
	ret

TryResetFruitTrees:
	ld hl, wDailyFlags1
	bit DAILYFLAGS1_ALL_FRUIT_TREES_F, [hl]
	ret nz
	jr ResetFruitTrees

CheckFruitTree:
	ld b, 2
	call GetFruitTreeFlag
	ld a, c
	ld [wScriptVar], a
	ret

PickedFruitTree:
	ld b, 1
	jr GetFruitTreeFlag

ResetFruitTrees:
	xor a
	ld hl, wFruitTreeFlags
rept (NUM_FRUIT_TREES + 7) / 8 - 1
	ld [hli], a
endr
	ld [hl], a
	ld hl, wDailyFlags1
	set DAILYFLAGS1_ALL_FRUIT_TREES_F, [hl]
	ret

GetFruitTreeFlag:
	push hl
	push de
	ld a, [wCurFruitTree]
	dec a
	ld e, a
	ld d, 0
	ld hl, wFruitTreeFlags
	call FlagAction
	pop de
	pop hl
	ret

GetFruitTreeItem:
	push hl
	push de
	ld e, a
	xor a
	sla e
	adc 0
	ld d, a
	ld hl, FruitTreeItems
	add hl, de
	call GetItemIDFromHL
	pop de
	pop hl
	ret

INCLUDE "data/items/fruit_trees.asm"

FruitBearingTreeText:
	text_far _FruitBearingTreeText
	text_end

HeyItsFruitText:
	text_far _HeyItsFruitText
	text_end

ObtainedFruitText:
	text_far _ObtainedFruitText
	text_end

ObtainedTwoFruitText:
	text_far _ObtainedTwoFruitText
	text_end

ObtainedThreeFruitText:
	text_far _ObtainedThreeFruitText
	text_end

FruitPackIsFullText:
	text_far _FruitPackIsFullText
	text_end

NothingHereText:
	text_far _NothingHereText
	text_end

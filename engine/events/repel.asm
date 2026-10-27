RepelWoreOffScript::
	opentext
	writetext .RepelWoreOffText
	waitbutton
	closetext
	end

.RepelWoreOffText:
	text_far _RepelWoreOffText
	text_end

UseAnotherRepelScript::
	opentext
	writetext .text
	yesorno
	iffalse .done
	callasm SetCurItemToRepel
	callasm DoItemEffect
.done
	closetext
	end

.text
	text_far _UseAnotherRepelText
	text_end

SetCurItemToRepel::
; wRepelType is 1-3 for Repel, Super Repel, Max Repel, not an item ID: IDs don't survive a save.
; wCurItem = that item, or 0 if wRepelType holds anything else (old saves stored an ID).
	assert SUPER_REPEL == REPEL + 1 && MAX_REPEL == REPEL + 2 && HIGH(REPEL) == HIGH(MAX_REPEL)
	ld a, [wRepelType]
	dec a
	cp MAX_REPEL - REPEL + 1
	jr nc, .none
	add LOW(REPEL)
	ld l, a
	ld h, HIGH(REPEL)
	call GetItemIDFromIndex
	jr .set
.none
	xor a
.set
	ld [wCurItem], a
	ret

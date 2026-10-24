TryQuickSave:
	farcall Link_SaveGame
	sbc a
	inc a ; carry (refused) = FALSE, else TRUE
	ld [wScriptVar], a
	ret

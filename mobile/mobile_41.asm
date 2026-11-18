BackupGSBallFlag:
	ld a, BANK(sGSBallFlag)
	call OpenSRAM
	ld a, [sGSBallFlag]
	push af
	ld a, BANK(sGSBallFlagBackup)
	call OpenSRAM
	pop af
	ld [sGSBallFlagBackup], a
	jmp CloseSRAM

RestoreGSBallFlag:
	ld a, BANK(sGSBallFlagBackup)
	call OpenSRAM
	ld a, [sGSBallFlagBackup]
	push af
	ld a, BANK(sGSBallFlag)
	call OpenSRAM
	pop af
	ld [sGSBallFlag], a
	jmp CloseSRAM


ClearGSBallFlag:
	ld a, BANK(sGSBallFlag)
	call OpenSRAM
	xor a
	ld [sGSBallFlag], a
	jmp CloseSRAM


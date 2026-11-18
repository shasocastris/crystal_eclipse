CheckStringForErrors:
; Valid character ranges:
; $0, $5 - $13, $19 - $1c, $26 - $34, $3a - $3e, $40 - $48, $60 - $ff
.loop
	ld a, [de]
	inc de
	and a ; "<NULL>"
	jr z, .NextChar
	cp FIRST_REGULAR_TEXT_CHAR
	jr nc, .NextChar
	cp '<NEXT>'
	jr z, .NextChar
	cp '@'
	jr z, .Done
	cp 'ガ'
	jr c, .Fail
	cp '<PLAY_G>'
	jr c, .NextChar
	cp '<JP_18>' + 1
	jr c, .Fail
	cp '<NI>'
	jr c, .NextChar
	cp '<NO>' + 1
	jr c, .Fail
	cp '<ROUTE>'
	jr c, .NextChar
	cp '<GREEN>' + 1
	jr c, .Fail
	cp '<ENEMY>'
	jr c, .NextChar
	cp '<ENEMY>' + 1
	jr c, .Fail
	cp '<MOM>'
	jr c, .NextChar

.Fail:
	scf
	ret

.NextChar:
	dec c
	jr nz, .loop

.Done:
	and a
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parameter: [wScriptVar] = 0..1
;
; if [wScriptVar] == FALSE
;    Show japanese menu options
;    - News - News - ??? - Cancel
; if [wScriptVar] == TRUE
;    Show BattleTower-Menu with 3 options in english language
;    - Challenge - Explanation - Cancel
Menu_ChallengeExplanationCancel:
	ld a, [wScriptVar]
	and a
	jr nz, .English
	ld a, $4
	ld [wScriptVar], a
	ld hl, MenuHeader_17d26a ; Japanese Menu, where you can choose 'News' as an option
	jr .Load_Interpret

.English:
	ld a, $4
	ld [wScriptVar], a
	ld hl, MenuHeader_ChallengeExplanationCancel ; English Menu

.Load_Interpret:
	call LoadMenuHeader
	call Function17d246
	jmp CloseWindow

Function17d246:
	call VerticalMenu
	jr c, .Exit
	ld a, [wScriptVar]
	cp $5
	jr nz, .UsewMenuCursorY
	ld a, [wMenuCursorY]
	cp $3
	ret z
	jr c, .UsewMenuCursorY
	dec a
	jr .LoadToScriptVar

.UsewMenuCursorY:
	ld a, [wMenuCursorY]

.LoadToScriptVar:
	ld [wScriptVar], a
	ret

.Exit:
	ld a, $4
	ld [wScriptVar], a
	ret

MenuHeader_17d26a:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 14, 9
	dw MenuData_17d272
	db 1 ; default option

MenuData_17d272:
	db STATICMENU_CURSOR | STATICMENU_WRAP ; flags
	db 4
	db "ニュース<WO>よみこむ@"
	db "ニュース<WO>みる@"
	db "せつめい@"
	db "やめる@"

MenuHeader_ChallengeExplanationCancel:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 14, 7
	dw MenuData_ChallengeExplanationCancel
	db 1 ; default option

MenuData_ChallengeExplanationCancel:
	db STATICMENU_CURSOR | STATICMENU_WRAP ; flags
	db 3
	db "Challenge@"
	db "Explanation@"
	db "Cancel@"

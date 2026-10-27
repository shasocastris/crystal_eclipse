_InitializeStartDay:
	jmp InitializeStartDay

GetSeason::
; Returns the current season index (0-3) in a, and caches it in wSeason.
;
; Only runs on a day rollover and at new game. Everything else -- CheckSeason,
; the wild lookup, the palettes -- reads the wSeason cache, so to force a season
; in BGB poke wSeason itself. It holds an INDEX, not a mask: 0 spring, 1 summer,
; 2 autumn, 3 winter. It sticks until the next day rollover recomputes it.
;
; The RTC day counter has a period of 140 days: FixDays mods hRTCDayLo by 140,
; and FixTime then adds wStartDay without re-modding, so wCurDay runs over
; [wStartDay, wStartDay + 139] rather than 0-139. What makes the cycle continuous
; is the period, not the range -- 140 is a multiple of SEASON_CYCLE_DAYS, so at
; the wrap wCurDay drops by 139 and -139 mod 28 is +1, one day forward as normal.
;
; Do NOT replace the mod with a shift: 140 is not divisible by any power of two
; above 4, and you would get a visible season skip roughly every five months.
	ld a, [wCurDay]
.mod
	sub SEASON_CYCLE_DAYS
	jr nc, .mod
	add SEASON_CYCLE_DAYS ; 0 <= a < SEASON_CYCLE_DAYS
	ld b, SPRING_F
	cp 7
	jr c, .got
	inc b
	cp 14
	jr c, .got
	inc b
	cp 21
	jr c, .got
	inc b
.got
	ld a, b
	ld [wSeason], a
	ret

AlignStartDayToSpring::
; A new game must begin in SPRING. _InitTime leaves wStartDay congruent to
; -hRTCDayLo mod 7, so wCurDay starts on a multiple of 7 -- a season boundary --
; but not necessarily boundary zero: on a cartridge whose RTC has been running,
; hRTCDayLo of 10 gives wCurDay 14, which is AUTUMN. Only a fresh RTC lands on
; SPRING by itself, which is why this looks correct in an emulator.
;
; Add the multiple of 7 that reaches the next SPRING. Multiples of 7 preserve the
; day of the week, so the Lucky Number reset and Buena's password are unaffected,
; and wStartDay is already saved, so this costs no save-format change.
	ld b, SPRING_F
AlignStartDayToSeason:
; b = the season wanted
	push bc
	call UpdateTime ; refresh wCurDay against the wStartDay _InitTime just set
	call GetSeason
	pop bc
	sub b
	ret z ; already there
; Wind forward to the wanted season. The nudge is always a whole number of weeks,
; which is what keeps the day of the week intact -- the player picks a weekday in
; the Mom scene, and wCurDay mod 7 is what stores it. Do not "simplify" this to
; SEASON_CYCLE_DAYS - (wCurDay mod SEASON_CYCLE_DAYS): that also lands on SPRING,
; but forces wCurDay to a multiple of 28 and silently resets the weekday.
	assert NUM_SEASONS == 4
	cpl
	inc a
	and NUM_SEASONS - 1 ; seasons forward: 1, 2 or 3
	ld b, a
	xor a
.weeks
	add 7
	dec b
	jr nz, .weeks ; 7, 14 or 21
	ld hl, wStartDay
	add [hl]
	ld [hl], a
	call UpdateTime
	jr GetSeason

ResetClockKeepSeason::
; Clock reset. _InitTime rebuilds wStartDay from the weekday alone, dropping the
; whole weeks that place the calendar in its season, so the season jumped to
; wherever the RTC's day count happened to fall -- and the next Sunday rollover
; then looked skipped, doubled or missing. Put back the weeks that keep the save
; in the season it was in; the next one still starts on Sunday at midnight.
	ld a, [wSeason]
	push af
	farcall _InitTime
	pop bc ; b = the season before the reset
	jr AlignStartDayToSeason

ClearDailyTimers:
	xor a
	ld [wLuckyNumberDayTimer], a
	ld [wUnusedTwoDayTimer], a
	ld [wDailyResetTimer], a
	ret

InitCallReceiveDelay::
	xor a
	ld [wTimeCyclesSinceLastCall], a

NextCallReceiveDelay:
	ld a, [wTimeCyclesSinceLastCall]
	cp 3
	jr c, .okay
	ld a, 3

.okay
	ld e, a
	ld d, 0
	ld hl, .ReceiveCallDelays
	add hl, de
	ld a, [hl]
if DEF(_DEBUG)
	ld h, a
	ld a, BANK(sDebugTimeCyclesSinceLastCall)
	call OpenSRAM
	ld a, [sDebugTimeCyclesSinceLastCall]
	call CloseSRAM
	dec a
	cp 2
	jr nc, .debug_ok
	xor 1
	ld h, a
.debug_ok
	ld a, h
endc
	jr RestartReceiveCallDelay

.ReceiveCallDelays:
	db 20, 10, 5, 3

CheckReceiveCallTimer:
	call CheckReceiveCallDelay ; check timer
	ret nc
	ld hl, wTimeCyclesSinceLastCall
	ld a, [hl]
	cp 3
	jr nc, .ok
	inc [hl]

.ok
	call NextCallReceiveDelay ; restart timer
	scf
	ret

InitOneDayCountdown:
	ld a, 1

InitNDaysCountdown:
	ld [hl], a
	push hl
	call UpdateTime
	pop hl
	inc hl
	jmp CopyDayToHL

CheckDayDependentEventHL:
	inc hl
	push hl
	call CalcDaysSince
	call GetDaysSince
	pop hl
	dec hl
	jmp UpdateTimeRemaining

RestartReceiveCallDelay:
	ld hl, wReceiveCallDelay_MinsRemaining
	ld [hl], a
	call UpdateTime
	ld hl, wReceiveCallDelay_StartTime
	jmp CopyDayHourMinToHL

CheckReceiveCallDelay:
	ld hl, wReceiveCallDelay_StartTime
	call CalcMinsHoursDaysSince
	call GetMinutesSinceIfLessThan60
	ld hl, wReceiveCallDelay_MinsRemaining
	jmp UpdateTimeRemaining

RestartDailyResetTimer:
	ld hl, wDailyResetTimer
	jr InitOneDayCountdown

CheckDailyResetTimer::
	ld hl, wDailyResetTimer
	call CheckDayDependentEventHL
	ret nc
; Only one day rollover in seven is a season change. Clearing wSeasonalFlags
; unconditionally here would turn every once-per-season event into a daily one.
; This must stay above the xor a below, which the flag clears rely on.
	ld a, [wSeason]
	ld b, a
	call GetSeason
	cp b
	jr z, .no_season_change
	xor a
	ld [wSeasonalFlags], a
.no_season_change
	xor a
	ld hl, wDailyFlags1
rept 2
	ld [hli], a ; wDailyFlags1
endr
	ld [hli], a ; wDailyFlags2
	ld [hli], a ; wDailyFlags3
	ld [hl], a ; wSwarmFlags
	ld [wLuckyNumberShowFlag], a
	ld hl, wDailyRematchFlags
rept 3
	ld [hli], a
endr
	ld [hl], a
	ld hl, wDailyPhoneItemFlags
rept 3
	ld [hli], a
endr
	ld [hl], a
	ld hl, wDailyPhoneTimeOfDayFlags
rept 3
	ld [hli], a
endr
	ld [hl], a
	farcall ResetGreenhousePlots
	farcall FinishForgeOrder
	ld hl, wKenjiBreakTimer
	ld a, [hl]
	and a
	jr z, .RestartKenjiBreakCountdown
	dec [hl]
	jr nz, RestartDailyResetTimer
.RestartKenjiBreakCountdown:
	call SampleKenjiBreakCountdown
	jr RestartDailyResetTimer

SampleKenjiBreakCountdown:
; Generate a random number between 3 and 6
	call Random
	and %11
	add 3
	ld [wKenjiBreakTimer], a
	ret

StartBugContestTimer:
	ld a, BUG_CONTEST_MINUTES
	ld [wBugContestMinsRemaining], a
	ld a, BUG_CONTEST_SECONDS
	ld [wBugContestSecsRemaining], a
	call UpdateTime
	ld hl, wBugContestStartTime
	jmp CopyDayHourMinSecToHL

CheckBugContestTimer::
	ld hl, wBugContestStartTime
	call CalcSecsMinsHoursDaysSince
	ld a, [wDaysSince]
	and a
	jr nz, .timed_out
	ld a, [wHoursSince]
	and a
	jr nz, .timed_out
	ld a, [wSecondsSince]
	ld b, a
	ld a, [wBugContestSecsRemaining]
	sub b
	jr nc, .okay
	add 60

.okay
	ld [wBugContestSecsRemaining], a
	ld a, [wMinutesSince]
	ld b, a
	ld a, [wBugContestMinsRemaining]
	sbc b
	ld [wBugContestMinsRemaining], a
	jr c, .timed_out
	and a
	ret

.timed_out
	xor a
	ld [wBugContestMinsRemaining], a
	ld [wBugContestSecsRemaining], a
	scf
	ret

InitializeStartDay:
	call UpdateTime
	ld hl, wTimerEventStartDay
	jmp CopyDayToHL

CheckPokerusTick::
	ld hl, wTimerEventStartDay
	call CalcDaysSince
	call GetDaysSince
	and a
	jr z, .done ; not even a day has passed since game start
	ld b, a
	call ApplyPokerusTick
.done
	xor a
	ret

CheckUnusedTwoDayTimer:
	ld hl, wUnusedTwoDayTimerStartDate
	call CalcDaysSince
	call GetDaysSince
	ld hl, wUnusedTwoDayTimer



UpdateTimeRemaining:
; If the amount of time elapsed exceeds the capacity of its
; unit, skip this part.
	cp -1
	jr z, .set_carry
	ld c, a
	ld a, [hl] ; time remaining
	sub c
	jr nc, .ok
	xor a

.ok
	ld [hl], a
	jr z, .set_carry
	xor a
	ret

.set_carry
	xor a
	ld [hl], a
	scf
	ret

GetMinutesSinceIfLessThan60:
	ld a, [wDaysSince]
	and a
	jr nz, GetTimeElapsed_ExceedsUnitLimit
	ld a, [wHoursSince]
	and a
	jr nz, GetTimeElapsed_ExceedsUnitLimit
	ld a, [wMinutesSince]
	ret

GetDaysSince:
	ld a, [wDaysSince]
	ret

GetTimeElapsed_ExceedsUnitLimit:
	ld a, -1
	ret

CalcDaysSince:
	xor a
	jr _CalcDaysSince

CalcMinsHoursDaysSince:
	inc hl
	inc hl
	xor a
	jr _CalcMinsHoursDaysSince

CalcSecsMinsHoursDaysSince:
	inc hl
	inc hl
	inc hl
	ldh a, [hSeconds]
	ld c, a
	sub [hl]
	jr nc, .skip
	add 60
.skip
	ld [hl], c ; no-optimize *hl++|*hl-- = b|c|d|e (a is used) current seconds
	dec hl
	ld [wSecondsSince], a ; seconds since

_CalcMinsHoursDaysSince:
	ldh a, [hMinutes]
	ld c, a
	sbc [hl]
	jr nc, .skip
	add 60
.skip
	ld [hl], c ; no-optimize *hl++|*hl-- = b|c|d|e (a is used) current minutes
	dec hl
	ld [wMinutesSince], a ; minutes since

_CalcHoursDaysSince:
	ldh a, [hHours]
	ld c, a
	sbc [hl]
	jr nc, .skip
	add MAX_HOUR
.skip
	ld [hl], c ; no-optimize *hl++|*hl-- = b|c|d|e (a is used) current hours
	dec hl
	ld [wHoursSince], a ; hours since

_CalcDaysSince:
	ld a, [wCurDay]
	ld c, a
	sbc [hl]
	jr nc, .skip
	add 20 * 7
.skip
	ld [hl], c ; current days
	ld [wDaysSince], a ; days since
	ret

CopyDayHourMinSecToHL:
	ld a, [wCurDay]
	ld [hli], a
	ldh a, [hHours]
	ld [hli], a
	ldh a, [hMinutes]
	ld [hli], a
	ldh a, [hSeconds]
	ld [hli], a
	ret

CopyDayToHL:
	ld a, [wCurDay]
	ld [hl], a
	ret

CopyDayHourMinToHL:
	ld a, [wCurDay]
	ld [hli], a
	ldh a, [hHours]
	ld [hli], a
	ldh a, [hMinutes]
	ld [hli], a
	ret

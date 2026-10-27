LoadWeatherPal::
; Fill OB palette PAL_OW_WEATHER for the current weather.
	ld a, [wCurWeather]
	assert OW_WEATHER_NONE == 0
	and a
	ret z
	dec a
	ld hl, .Jumptable
	jmp JumpTable

.Jumptable:
	table_width 2
	dw .rain
	dw .snow
	dw .rain ; thunderstorm shares rain's palette
	dw .sand
	dw .cherry
	dw DoNothing ; sun has no particles
	dw DoNothing ; overcast has no particles
	assert_table_length NUM_OW_WEATHERS

.rain
	ld a, PAL_OW_RAIN
	jr .use_ow_weather_pal

.sand
	ld a, PAL_OW_SAND
	jr .use_ow_weather_pal

.cherry
	ld a, PAL_OW_PINK
	; fallthrough
.use_ow_weather_pal
	ld [wNeededPalIndex], a
	ld [wLoadedObjPal{d:PAL_OW_WEATHER}], a
	ld de, wOBPals1 palette PAL_OW_WEATHER
	jr CopySpritePal

.snow
; Snow is white rather than a MapObjectPals row, so byte-fill it and mark the
; slot as holding no palette; the dynamic allocator must not tie it to a sprite.
; The source marks wLoadedObjPal7 while PAL_OW_WEATHER is 6 (port guide bug #2),
; which makes DoOverworldSnow re-farcall this every weather frame.
	ld a, -1
	ld [wLoadedObjPal{d:PAL_OW_WEATHER}], a ; wLoadedObjPal6 is in BANK(wXCoord)
	ldh a, [rSVBK]
	push af
	ld a, BANK(wOBPals1)
	ldh [rSVBK], a
	ld hl, wOBPals1 palette PAL_OW_WEATHER
	ld bc, 1 palettes
	ld a, $ff
	rst ByteFill
	ld hl, wPalFlags
	bit NO_DYN_PAL_APPLY_F, [hl]
	jr nz, .skip_apply
	call ApplyOBPals
	ld a, TRUE
	ldh [hCGBPalUpdate], a
.skip_apply
	pop af
	ldh [rSVBK], a
	ret

CopyBGGreenToOBPal7:
; Some overworld effects (Fly leaves, Cut leaves, Cut trees, Headbutt trees)
; have hard-coded OB palette 7 in their OAM data.
	ld a, PAL_OW_COPY_BG_GREEN
	; fallthrough
CopySpritePalToOBPal7:
	ld [wNeededPalIndex], a
	ld [wLoadedObjPal7], a
	ld de, wOBPals1 palette 7
	; fallthrough
CopySpritePal::
	push af
	push bc
	push hl
	push de
	ld a, [wNeededPalIndex]
	sub FIRST_COPY_BG_PAL
	jr c, .not_copy_bg
	ld hl, wBGPals1
	ld bc, 1 palettes
	rst AddNTimes
	jr .got_pal

.not_copy_bg
	; check darkness
	push hl
	push de
	call GetMapTimeOfDay
	pop de
	pop hl
	or ~IN_DARKNESS
	inc a
	jr nz, .not_darkness
	ld a, [wStatusFlags]
	bit STATUSFLAGS_FLASH_F, a ; Flash
	jr nz, .not_darkness
	ld a, [wPalFlags]
	bit USE_DAYTIME_PAL_F, a
	jr nz, .not_darkness
	ld a, [wNeededPalIndex]
	cp NUM_OW_TIME_OF_DAY_PALS
	jr nc, .not_darkness
	ld hl, DarknessOBPalette
	ld bc, 1 palettes
	rst AddNTimes
	jr .got_pal

.not_darkness
	ld a, [wNeededPalIndex]
	cp NUM_OW_TIME_OF_DAY_PALS
	jr c, .time_of_day_pal
	ld hl, SingleObjectPals - NUM_OW_TIME_OF_DAY_PALS palettes
	ld bc, 1 palettes
	rst AddNTimes
	jr .got_pal

.time_of_day_pal
	ld hl, MapObjectPals
	ld bc, 1 palettes
	rst AddNTimes
.check_daytimes
	ld a, [wPalFlags]
	bit USE_DAYTIME_PAL_F, a
	ld a, 1
	jr nz, .daytime
	ld a, [wTimeOfDayPal]
.daytime
	maskbits NUM_DAYTIMES
	ld bc, NUM_OW_TIME_OF_DAY_PALS palettes
	rst AddNTimes
.got_pal
	pop de
	push de ; where the palette is going, for the dim below
	ld bc, 1 palettes
	call FarCopyColorWRAM
	pop de
	; Map objects have to darken with the map, or they stand out against it.
	farcall DimSpritePal
	ld hl, wPalFlags
	bit NO_DYN_PAL_APPLY_F, [hl]
	jr nz, .skip_apply
	call ApplyOBPals
	ld a, TRUE
	ldh [hCGBPalUpdate], a
.skip_apply
	pop af
	pop bc
	pop hl
	ret

ApplyOBPals:
	ld hl, wOBPals1
	ld de, wOBPals2
	ld bc, 8 palettes
	ld a, BANK(wGBCPalettes)
	jmp FarCopyColorWRAM

MapObjectPals:
	table_width 1 palettes
INCLUDE "gfx/overworld/npc_sprites.pal"
	assert_table_length NUM_OW_TIME_OF_DAY_PALS * NUM_DAYTIMES ; morn, day, nite, eve

SingleObjectPals:
	table_width 1 palettes
INCLUDE "gfx/overworld/npc_single_object.pal"
	assert_table_length NUM_OW_INDIVIDUAL_PALS

DarknessOBPalette:
	table_width 1 palettes
INCLUDE "gfx/overworld/npc_sprites_darkness.pal"
	assert_table_length NUM_OW_TIME_OF_DAY_PALS + NUM_OW_INDIVIDUAL_PALS

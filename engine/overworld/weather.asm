; Overworld weather particles (M4). Ported from Polished Crystal; see
; docs/weather-particles-guide.md for the design.

; Two OB tiles, taken from the top of the map-object sprite arena.
;
; GetSpriteVTile allocates 12 tiles per object struct, so structs 0-7 fill
; exactly $00-$5f of VRAM bank 0 and nothing below FIRST_VRAM1_OBJECT_STRUCT
; can reach past it. Deriving the base from that expression rather than a
; literal keeps the reservation correct if the struct split ever changes.
DEF WEATHER_TILE_1 EQU FIRST_VRAM1_OBJECT_STRUCT * 12
DEF WEATHER_TILE_2 EQU WEATHER_TILE_1 + 1

DEF RAINDROP_TILE   EQU WEATHER_TILE_1
DEF RAINSPLASH_TILE EQU WEATHER_TILE_2
DEF SNOWFLAKE_TILE  EQU WEATHER_TILE_1
; Sand is the one weather with two distinct frames. The source draws both but
; loads a count of 1, so its second scatter has never reached VRAM -- port guide
; bug #1. Spawners pick between them, which is why they must stay adjacent.
DEF SANDSTORM_TILE   EQU WEATHER_TILE_1
DEF SANDSTORM_TILE_2 EQU WEATHER_TILE_2
DEF CHERRYLEAF_TILE EQU WEATHER_TILE_1

; SpawnRandomWeatherCoords.rain derives the tile id branchlessly from this
; adjacency, so the two must stay consecutive.
	assert RAINDROP_TILE + 1 == RAINSPLASH_TILE, \
		"the raindrop and splash tiles must be adjacent"
; SpawnSandDrop picks its frame by adding a random bit to the first.
	assert SANDSTORM_TILE + 1 == SANDSTORM_TILE_2, \
		"the two sandstorm tiles must be adjacent"
; The arena above is only free because the object structs stop short of it.
	assert WEATHER_TILE_2 < $80, \
		"the weather tiles must fit in the vTiles0 object arena"

; Weather owns the first 12 shadow OAM structs, as in the source. OAM index is
; OBJ-to-OBJ draw priority on CGB, so the front is what puts particles over the
; player and NPCs; _UpdateSprites starts map objects above the window while
; FIRST_12_SPRITE_OAM_STRUCTS_RESERVED_F is set.
;
; Unlike the source, weather is capped at these 12 structs rather than spreading
; across all 40, so ten particles sharing a scanline -- the case its software
; sprite limiter exists to handle -- is rare enough to leave to the hardware.
DEF WEATHER_OAM_STRUCTS EQU NUM_WEATHER_OAM_STRUCTS
DEF WEATHER_OAM_START EQU 0

DoOverworldWeather::
	; DelayFrame runs this every frame from every loop in the game. hMapAnims is
	; "the map is live": textboxes and the start menu keep it set, while battles,
	; Hall of Fame, whiteout and faded-out menus clear it. The gate lives here
	; rather than at the call site because ROM0 has no room for it.
	ldh a, [hMapAnims]
	and a
	ret z

	push hl
	push de
	push bc
	; DelayFrame calls this from every loop in the game, so unlike the overworld
	; frame it makes no promise about the WRAM bank. Every byte below -- the
	; weather state, wStateFlags, wLoadedObjPal6, the player's step vectors -- is
	; in BANK(wCurWeather); only wShadowOAM is bank-independent.
	ldh a, [rSVBK]
	push af
	ld a, BANK(wCurWeather)
	ldh [rSVBK], a

	; Lightning waits a frame, and waiting a frame is what calls this, so refuse
	; to reenter rather than recursing.
	ld a, [wWeatherRunning]
	and a
	jr nz, .done_no_tick

	; PrintLetterDelay busy-spins on wTextDelayFrames rather than sleeping, so it
	; reaches here many times a frame. Move the particles only on the first call
	; after each VBlank, or they would race while text is printing.
	ldh a, [hVBlankCounter]
	ld hl, wLastWeatherVBlank
	cp [hl]
	jr z, .done_no_tick
	ld [hl], a

	ld a, TRUE
	ld [wWeatherRunning], a

	call SetWeatherOAMReservation

	; if weather is disabled, we are done
	ld hl, wWeatherFlags
	bit OW_WEATHER_DISABLED_F, [hl]
	jr nz, .done

	; rolling counter from 0 to 255 used to run weather
	; in 30fps or every odd frame.
	ld a, [wOverworldWeatherTimer]
	and %1
	jr z, .done

	; we are running weather, so decrement the cooldown if needed.
	ld a, [wOverworldWeatherCooldown]
	and a
	jr z, .no_cooldown
	dec a
	ld [wOverworldWeatherCooldown], a
.no_cooldown

	; if cooldown is not 0, we don't want to spawn new weather sprites
	; instead we want to slowly finishing dropping the current sprites.
	ld a, [wOverworldWeatherCooldown]
	and a
	jr nz, .on_cooldown

	ld a, [wCurWeather]
	ld hl, .DoOverworldWeather_Jumptable
	call JumpTable
.done
	; we are done, increment the weather delay rolling counter (0->255->0)
	ld hl, wOverworldWeatherTimer
	inc [hl]
	call ClipWeatherSprites
	xor a
	ld [wWeatherRunning], a
.done_no_tick
	pop af
	ldh [rSVBK], a
	jmp PopBCDEHL

.DoOverworldWeather_Jumptable:
	table_width 2
	dw DoNothing
	dw DoOverworldRain
	dw DoOverworldSnow
	dw DoOverworldRain
	dw DoOverworldSandstorm
	dw DoOverworldCherryBlossoms
	dw DoNothing ; sun is palette only
	assert_table_length NUM_OW_WEATHERS + 1

.on_cooldown
	ld a, [wPrevWeather]
	ld hl, .DoWeather_Jumptable
	call JumpTable
	; decrement the weather cooldown until it is 0
	ld a, [wOverworldWeatherCooldown]
	dec a
	jr nz, .done
	call ClearWeather
	call LoadWeatherGraphics
	jr .done

.DoWeather_Jumptable:
	table_width 2
	dw DoNothing
	dw DoRainFall
	dw DoSnowFall
	dw DoRainFall
	dw DoSandFall
	dw DoCherryBlossomFall
	dw DoNothing ; sun
	assert_table_length NUM_OW_WEATHERS + 1

SetWeatherMenuClip::
; Keep particles off the menu box that was just drawn. Read back from
; wMenuBorder* rather than from a menu header, because DrawVariableLengthMenuBox
; sizes the box to its item count. Those live in WRAM0, so the bank we select
; here for the clip state does not affect them.
	ldh a, [rSVBK]
	push af
	ld a, BANK(wWeatherMenuClipLeft)
	ldh [rSVBK], a

	ld a, [wMenuBorderLeftCoord]
	call _TileToWeatherClipX
	ld [wWeatherMenuClipLeft], a
	ld a, [wMenuBorderTopCoord]
	call _TileToWeatherClipY
	ld [wWeatherMenuClipTop], a
	ld a, [wMenuBorderRightCoord]
	inc a ; exclusive
	call _TileToWeatherClipX
	ld [wWeatherMenuClipRight], a
	ld a, [wMenuBorderBottomCoord]
	inc a ; exclusive
	call _TileToWeatherClipY
	ld [wWeatherMenuClipBottom], a
	jr _RestoreWeatherClipBank

ClearWeatherClip::
; The menu box has gone. The textbox is tracked separately, so a yes/no box
; closing over one leaves the dialogue underneath it still clipped.
	ldh a, [rSVBK]
	push af
	ld a, BANK(wWeatherMenuClipBottom)
	ldh [rSVBK], a
	xor a
	ld [wWeatherMenuClipBottom], a
	jr _RestoreWeatherClipBank

SetWeatherTextboxClip::
	ldh a, [rSVBK]
	push af
	ld a, BANK(wWeatherTextboxClip)
	ldh [rSVBK], a
	ld a, TRUE
	ld [wWeatherTextboxClip], a
	jr _RestoreWeatherClipBank

ClearWeatherTextboxClip::
	ldh a, [rSVBK]
	push af
	ld a, BANK(wWeatherTextboxClip)
	ldh [rSVBK], a
	xor a
	ld [wWeatherTextboxClip], a
	; fallthrough

_RestoreWeatherClipBank:
	pop af
	ldh [rSVBK], a
	ret

_TileToWeatherClipY:
	add a
	add a
	add a
	add TILE_WIDTH * 2 ; OAM y is offset by two tiles
	ret

_TileToWeatherClipX:
	add a
	add a
	add a
	add TILE_WIDTH ; OAM x is offset by one tile
	ret

ClipWeatherSprites:
; Hide weather-owned sprites sitting on a UI box. Done as a sweep after the
; particles move, rather than a test inside each of the four fall loops, so it
; also catches whatever was already on screen when the box opened.
	ld a, [wWeatherMenuClipBottom]
	and a
	jr z, .no_menu_box
	ld hl, wWeatherMenuClipLeft
	call .Sweep

.no_menu_box
	ld a, [wWeatherTextboxClip]
	and a
	ret z
	ld hl, .TextboxRect
	; fallthrough

.Sweep
; hl = the four rectangle bytes, in WRAM or ROM. Copied to a fixed place so the
; inner loop can keep hl for addressing OAM.
	ld de, wWeatherClipLeft
	ld c, 4
.copy_rect
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .copy_rect

	ld de, wShadowOAM + WEATHER_OAM_START
	ld b, WEATHER_OAM_STRUCTS
.loop
	ld hl, OAMA_FLAGS
	add hl, de
	ld a, [hl]
	cp PAL_OW_WEATHER
	jr nz, .next ; not ours

	ld h, d
	ld l, e
	ld a, [hli] ; y
	ld c, [hl] ; x

	ld hl, wWeatherClipTop
	cp [hl]
	jr c, .next
	ld hl, wWeatherClipBottom
	cp [hl]
	jr nc, .next

	ld a, c
	ld hl, wWeatherClipLeft
	cp [hl]
	jr c, .next
	ld hl, wWeatherClipRight
	cp [hl]
	jr nc, .next

	ld h, d
	ld l, e
	ld a, OAM_YCOORD_HIDDEN
	ld [hli], a
	xor a
	ld [hli], a
	ld [hli], a
	ld [hl], a
.next
	ld hl, OBJ_SIZE
	add hl, de
	ld d, h
	ld e, l
	dec b
	jr nz, .loop
	ret

.TextboxRect
	db TEXTBOX_X * TILE_WIDTH + TILE_WIDTH
	db TEXTBOX_Y * TILE_WIDTH + TILE_WIDTH * 2
	db (TEXTBOX_X + TEXTBOX_WIDTH) * TILE_WIDTH + TILE_WIDTH
	db (TEXTBOX_Y + TEXTBOX_HEIGHT) * TILE_WIDTH + TILE_WIDTH * 2

SetWeatherOAMReservation:
; Hold the first 12 shadow OAM structs for as long as particles can exist.
; Without this _UpdateSprites would start at struct 0 and overwrite them.
	ld a, [wCurWeather]
	ld hl, wOverworldWeatherCooldown
	or [hl]
	ld hl, wStateFlags
	jr z, .release
	set FIRST_12_SPRITE_OAM_STRUCTS_RESERVED_F, [hl]

	; Textbox and menu waits park hOAMUpdate at 1 to buy VBlank time for BG
	; work, which stops hTransferShadowOAM. Left alone that leaves particles
	; computed every frame but never transferred -- moving for as long as the
	; text is still printing, then frozen. While weather is live the transfer
	; has to keep running; the waits restore their own saved value on exit.
	xor a
	ldh [hOAMUpdate], a
	ret

.release
	res FIRST_12_SPRITE_OAM_STRUCTS_RESERVED_F, [hl]
	ret

SpawnRandomWeatherFullScreen::
	lb bc, SCREEN_WIDTH_PX, SCREEN_HEIGHT_PX
	; fallthrough
SpawnRandomWeatherCoords::
; randomize weather sprite x/y coords from (0,0) to (b,c)
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
	dw .rain
	dw .sand
	dw DoNothing ; cherry blossoms' starting positions are nonrandom
	dw DoNothing ; sun
	assert_table_length NUM_OW_WEATHERS

.sand
	call .find_oam_and_randomize
	ret c
	call _RandomSandTile
	ld [hli], a
	ld [hl], PAL_OW_WEATHER
	jr .sand

.snow
	call .find_oam_and_randomize
	ret c
	ld a, SNOWFLAKE_TILE
	ld [hli], a
	ld [hl], PAL_OW_WEATHER
	jr .snow

.rain
	call .find_oam_and_randomize
	ret c
	call Random
	cp 20 percent ; 20 percent splashes
	; a = carry ? RAINSPLASH_TILE : RAINDROP_TILE
	assert RAINDROP_TILE + 1 == RAINSPLASH_TILE
	ccf
	sbc a
	add RAINSPLASH_TILE
	ld [hli], a
	ld [hl], PAL_OW_WEATHER
	jr .rain

.find_oam_and_randomize
	push bc
	call ScanForEmptyOAM
	pop bc
	ret c
	; sprite coord is (RandomRange(0, b), RandomRange(0, c))
	ld a, c
	call RandomRange
	ld [hli], a
	ld a, b
	call RandomRange
	ld [hli], a
	or 1
	ret

DoOverworldSnow:
	; -1 marks a slot holding no MapObjectPals row, which is snow's own marker
	ld a, [wLoadedObjPal{d:PAL_OW_WEATHER}]
	inc a
	jr z, .continue
	farcall LoadWeatherPal
.continue
rept 2
	; spawn two snowflakes
	call ScanForEmptyOAM
	call nc, SpawnSnowFlake
endr
	; fallthrough
DoSnowFall:
	ld de, wShadowOAM + WEATHER_OAM_START
	ld b, WEATHER_OAM_STRUCTS
.loop
	; if the sprite is hidden, skip it
	ld hl, OAMA_Y
	add hl, de
	ld a, [hl]
	cp OAM_YCOORD_HIDDEN
	jr z, .next

	; if the sprite is not a snowflake, skip it
	ld hl, OAMA_TILEID
	add hl, de
	ld a, [hli]
	cp SNOWFLAKE_TILE
	jr nz, .next

	; if the sprite doesn't use the weather palette, skip it
	ld a, [hl]
	cp PAL_OW_WEATHER
	jr nz, .next

	; the snowflake has a 0.1% chance of despawning
	call Random
	cp 1 percent
	jr nc, .ok
	call Random
	cp 10 percent
	jr c, .despawn
.ok

	xor a
	ld hl, wWeatherFlags
	bit OW_WEATHER_IGNORE_PLAYER_Y_F, [hl]
	jr nz, .skip_y_adjust
	; double the player's step vector (may be positive or negative)
	ld a, [wPlayerStepVectorY]
	add a
.skip_y_adjust
	ld c, a

	; get the sprite's y coord and subtract the player's doubled step vector
	ld hl, OAMA_Y
	add hl, de
	ld a, [hl]
	sub c
	ld c, a

	; sprites with an even index move down 1 faster.
	call IsEvenSpriteIndex
	add c

	; minimum fall speed is 2
	add 2

	; if the sprite goes offscreen, despawn it, otherwise update its y coord
	ld hl, OAMA_Y
	add hl, de
	cp OAM_YCOORD_HIDDEN
	ld [hl], a
	jr nc, .despawn

	; double the player's step vector (may be positive or negative)
	ld a, [wPlayerStepVectorX]
	add a
	ld c, a

	; sprite has a 50% chance to wiggle left 1.
	call Random
	and 1
	ld a, c
	jr nz, .no_add_1
	inc a
.no_add_1
	ld c, a

	; get the sprite's x coord and subtract the player's doubled step vector + wiggle
	ld hl, OAMA_X
	add hl, de
	ld a, [hl]
	sub c

	; sprite can have 0 change in x coord (no wiggle or step vector)
	; so we increment a before subtracting to check for despawn (offscreen)
	inc a
	ld hl, OAMA_X
	add hl, de
	sub 1 ; no-optimize a++|a-- (need to set carry)
	ld [hl], a
	jr c, .despawn
.next
	ld hl, OBJ_SIZE
	add hl, de
	ld d, h
	ld e, l
	dec b
	jr nz, .loop
	ret

.despawn
	ld hl, OAMA_Y
	add hl, de
	ld a, OAM_YCOORD_HIDDEN
	ld [hli], a
	xor a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	jr .next

SpawnSnowFlake:
	; 40% chance of spawning a snowflake.
	call Random
	cp 40 percent
	ret nc
	; 25% chance of spawning a snowflake on the right side of the screen.
	call Random
	and %11
	jr z, .spawn_on_right

	; sprite coord is (0, RandomRange(0, SCREEN_WIDTH_PX + 7) + TILE_WIDTH)
	xor a
	ld [hli], a
	ld a, SCREEN_WIDTH_PX + 7
	call RandomRange
	; x-coord less than TILE_WIDTH is offscreen, so add TILE_WIDTH
	add TILE_WIDTH
	ld [hli], a
.finish
	ld a, SNOWFLAKE_TILE
	ld [hli], a
	ld [hl], PAL_OW_WEATHER
	ret

.spawn_on_right
	; sprite coord is (SCREEN_WIDTH_PX + TILE_WIDTH, RandomRange(0, OAM_YCOORD_HIDDEN))
	ld a, OAM_YCOORD_HIDDEN
	call RandomRange
	ld [hli], a
	ld a, SCREEN_WIDTH_PX + TILE_WIDTH
	ld [hli], a
	jr .finish

ScanForEmptyOAM:
; return a free weather OAM slot in de (and hl), or carry set if none
;
; A slot is free when it is hidden, or when it is not one of ours. The second
; test is what makes this survive a map load: ClearSprites zeroes the whole of
; shadow OAM, so the window comes back with y = 0 rather than OAM_YCOORD_HIDDEN,
; and _UpdateSprites.fill cannot put it right while the reservation is held.
	ld de, wShadowOAM + WEATHER_OAM_START
	ld b, WEATHER_OAM_STRUCTS
.loop
	ld h, d
	ld l, e
	ld a, [hl]
	cp OAM_YCOORD_HIDDEN
	ret nc ; hidden

	ld hl, OAMA_FLAGS
	add hl, de
	ld a, [hl]
	cp PAL_OW_WEATHER
	jr nz, .not_ours

	; next slot
	ld hl, OBJ_SIZE
	add hl, de
	ld d, h
	ld e, l
	dec b
	jr nz, .loop
	; no free slots
	scf
	ret

.not_ours
	ld h, d
	ld l, e
	or a ; clear carry; cp may have set it
	ret

SpawnRainDrop:
	; 50% chance of spawning a raindop on the right
	call Random
	and 1
	jr z, .spawn_on_right

	; sprite coord is (0, RandomRange(0, SCREEN_WIDTH_PX + 7) + TILE_WIDTH)
	xor a
	ld [hli], a
	ld a, SCREEN_WIDTH_PX + 7
	call RandomRange
	; x-coord less than TILE_WIDTH is offscreen, so add TILE_WIDTH
	add TILE_WIDTH
	ld [hli], a
.finish
	ld a, RAINDROP_TILE
	ld [hli], a
	ld [hl], PAL_OW_WEATHER
	ret

.spawn_on_right
	; sprite coord is (SCREEN_WIDTH_PX + TILE_WIDTH, RandomRange(0, OAM_YCOORD_HIDDEN))
	ld a, OAM_YCOORD_HIDDEN
	call RandomRange
	ld [hli], a
	ld a, SCREEN_WIDTH_PX + TILE_WIDTH
	ld [hli], a
	jr .finish

ClearWeather::
	push hl
	push de
	push bc
	call .HideWeatherSprites
	pop bc
	pop de
	pop hl
	ret

.HideWeatherSprites
; hide all visible weather-owned OAM entries
;
; The window is a fixed 12 structs, so sweep all of it. The source stops at a
; high-water mark because its window is bounded by however much of OAM the map
; objects left free, which varies frame to frame; ours does not.
	ld c, WEATHER_OAM_START + (WEATHER_OAM_STRUCTS - 1) * OBJ_SIZE
	ld de, wShadowOAM + WEATHER_OAM_START
.loop
	ld h, d
	ld l, e
	ld a, [hl]
	cp OAM_YCOORD_HIDDEN
	jr z, .next
	inc hl
	inc hl
	ld a, [hli]
	cp WEATHER_TILE_1
	jr z, .check_attr
	cp WEATHER_TILE_2
	jr nz, .next
.check_attr
	ld a, [hl]
	cp PAL_OW_WEATHER
	jr nz, .next

	ld h, d
	ld l, e
	ld a, OAM_YCOORD_HIDDEN
	ld [hli], a
	xor a
	ld [hli], a
	ld [hli], a
	ld [hl], a

.next
	ld a, e
	cp c
	ret z
	ld hl, OBJ_SIZE
	add hl, de
	ld d, h
	ld e, l
	jr .loop

DoOverworldRain:
	ld a, [wLoadedObjPal{d:PAL_OW_WEATHER}]
	cp PAL_OW_RAIN
	jr z, .continue
	farcall LoadWeatherPal
.continue
	ld a, [wCurWeather]
	cp OW_WEATHER_THUNDERSTORM
	jr nz, .no_lightning

	; LIGHTNING_CHANCE, halved by the second roll
	call Random
	cp LIGHTNING_CHANCE
	jr nc, .no_lightning
	call Random
	cp 50 percent
	call c, Lightning
.no_lightning
rept 3
	; spawn three raindrops
	call ScanForEmptyOAM
	call nc, SpawnRainDrop
endr
	; fallthrough
DoRainFall:
	ld de, wShadowOAM + WEATHER_OAM_START
	ld b, WEATHER_OAM_STRUCTS
.loop
	; if the sprite is hidden, skip it
	ld hl, OAMA_Y
	add hl, de
	ld a, [hl]
	cp OAM_YCOORD_HIDDEN
	jr z, .next

	; if the sprite is a splash, update splash.
	ld hl, OAMA_TILEID
	add hl, de
	ld a, [hli]
	cp RAINSPLASH_TILE
	jmp z, .update_splash

	; if the sprite is not a raindrop, skip it
	cp RAINDROP_TILE
	jr nz, .next

	; if the sprite doesn't use the weather palette, skip it
	ld a, [hl]
	cp PAL_OW_WEATHER
	jr nz, .next

	; raindrops have a 5% chance of splashing.
	call Random
	cp 5 percent
	jmp c, .splash

	xor a
	ld hl, wWeatherFlags
	bit OW_WEATHER_IGNORE_PLAYER_Y_F, [hl]
	jr nz, .skip_y_adjust_1
	; quadruple the player's step vector (may be positive or negative)
	ld a, [wPlayerStepVectorY]
	add a
	add a
.skip_y_adjust_1

	; get the sprite's y coord and subtract the player's quadrupled step vector
	ld c, a
	ld hl, OAMA_Y
	add hl, de
	ld a, [hl]
	sub c
	ld c, a

	; sprites with an even index move down 2 faster.
	call IsEvenSpriteIndex
	add a
	add c

	; minimum fall speed is 8
	add 8

	; if the sprite goes offscreen, despawn it, otherwise update its y coord
	ld hl, OAMA_Y
	add hl, de
	cp OAM_YCOORD_HIDDEN
	ld [hl], a
	jr nc, .despawn

	; quadruple the player's step vector (may be positive or negative)
	ld a, [wPlayerStepVectorX]
	add a
	add a
	ld c, a

	; get the sprite's x coord and subtract the player's quadrupled step vector
	ld hl, OAMA_X
	add hl, de
	ld a, [hl]
	sub c
	ld c, a

	; sprites with an even index move left 2 faster.
	call IsEvenSpriteIndex
	cpl
	inc a
	add a
	add c

	; minimum horizontal movement left is 4.
	sub 4

	; if the sprite goes offscreen, despawn it, otherwise update its x coord
	ld hl, OAMA_X
	add hl, de
	ld [hl], a
	jr c, .despawn
.next
	ld hl, OBJ_SIZE
	add hl, de
	ld d, h
	ld e, l
	dec b
	jr nz, .loop

	; we leave rain splashs on screen for approx 3.75fps.
	; we have to ignore the LSB as we only run weather every odd frame.
	ld a, [wOverworldWeatherTimer]
	and %1110
	ret nz

	ld de, wShadowOAM + WEATHER_OAM_START
	ld b, WEATHER_OAM_STRUCTS
.splash_loop
	; if sprite tile is not a rain splash, skip it
	ld hl, OAMA_TILEID
	add hl, de
	ld a, [hli]
	cp RAINSPLASH_TILE
	jr nz, .splash_next

	; hide the rain splash
	ld hl, OAMA_Y
	add hl, de
	ld [hl], OAM_YCOORD_HIDDEN ; offscreen
.splash_next
	ld hl, OBJ_SIZE
	add hl, de
	ld d, h
	ld e, l
	dec b
	jr nz, .splash_loop
	ret

.despawn
	ld hl, OAMA_Y
	add hl, de
	ld a, OAM_YCOORD_HIDDEN
	ld [hli], a
	xor a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	jr .next

.update_splash
	; if the sprite doesn't use the weather palette, skip it
	ld a, [hl]
	cp PAL_OW_WEATHER
	jr nz, .next

	xor a
	ld hl, wWeatherFlags
	bit OW_WEATHER_IGNORE_PLAYER_Y_F, [hl]
	jr nz, .skip_y_adjust_2
	; double the player's step vector
	ld a, [wPlayerStepVectorY]
	add a
.skip_y_adjust_2
	ld c, a

	; get the sprite's y coord and subtract the player's doubled step vector
	ld hl, OAMA_Y
	add hl, de
	ld a, [hl]
	sub c

	; if the sprite goes offscreen, despawn it, otherwise update its y coord
	cp OAM_YCOORD_HIDDEN
	jr nc, .despawn
	ld [hli], a

	; double the player's step vector
	ld a, [wPlayerStepVectorX]
	add a
	ld c, a

	; get the sprite's x coord and subtract the player's doubled step vector
	ld a, [hl]
	sub c
	ld [hl], a
	jr .next

.splash
	; convert raindrop to splash
	ld hl, OAMA_TILEID
	add hl, de
	ld [hl], RAINSPLASH_TILE
	jr .next

DoOverworldSandstorm:
	ld a, [wLoadedObjPal{d:PAL_OW_WEATHER}]
	cp PAL_OW_SAND
	jr z, .continue
	farcall LoadWeatherPal
.continue
rept 3
	; spawn three sand drops
	call ScanForEmptyOAM
	call nc, SpawnSandDrop
endr
	; fallthrough
DoSandFall:
	ld de, wShadowOAM + WEATHER_OAM_START
	ld b, WEATHER_OAM_STRUCTS
.loop
	; if the sprite is hidden, skip it
	ld hl, OAMA_Y
	add hl, de
	ld a, [hl]
	cp OAM_YCOORD_HIDDEN
	jr z, .next

	; if the sprite is neither sand frame, skip it
	ld hl, OAMA_TILEID
	add hl, de
	ld a, [hli]
	sub SANDSTORM_TILE
	cp SANDSTORM_TILE_2 - SANDSTORM_TILE + 1
	jr nc, .next

	; if the sprite doesn't use the weather palette, skip it
	ld a, [hl]
	cp PAL_OW_WEATHER
	jr nz, .next

	; sand drops have a 5% chance of despawning.
	call Random
	cp 5 percent
	jr c, .despawn

	xor a
	ld hl, wWeatherFlags
	bit OW_WEATHER_IGNORE_PLAYER_Y_F, [hl]
	jr nz, .skip_y_adjust
	; quadruple the player's step vector (may be positive or negative)
	ld a, [wPlayerStepVectorY]
	add a
	add a
.skip_y_adjust
	ld c, a

	; get the sprite's y coord and subtract the player's quadrupled step vector
	ld hl, OAMA_Y
	add hl, de
	ld a, [hl]
	sub c
	ld c, a

	; sprites with an even index move up 2 slower.
	call IsEvenSpriteIndex
	add a
	add c

	; minimum rise speed is 4
	sub 4

	; if the sprite goes offscreen, despawn it, otherwise update its y coord
	ld hl, OAMA_Y
	add hl, de
	cp OAM_YCOORD_HIDDEN
	ld [hl], a
	jr nc, .despawn

	; quadruple the player's step vector (may be positive or negative)
	ld a, [wPlayerStepVectorX]
	add a
	add a
	ld c, a

	; get the sprite's x coord and subtract the player's quadrupled step vector
	ld hl, OAMA_X
	add hl, de
	ld a, [hl]
	sub c
	ld c, a

	; sprites with an even index move left 2 faster.
	call IsEvenSpriteIndex
	cpl
	inc a
	add a
	add c

	; minimum horizontal movement left is 12
	sub 12

	; if the sprite goes offscreen, despawn it, otherwise update its x coord
	ld hl, OAMA_X
	add hl, de
	ld [hl], a
	jr c, .despawn
.next
	ld hl, OBJ_SIZE
	add hl, de
	ld d, h
	ld e, l
	dec b
	jr nz, .loop
	ret

.despawn
	ld hl, OAMA_Y
	add hl, de
	ld a, OAM_YCOORD_HIDDEN
	ld [hli], a
	xor a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	jr .next

SpawnSandDrop:
	; 50% chance of spawning a sand drop on the right
	call Random
	and 1
	jr z, .spawn_on_right

	; sprite coord is (RandomRange(0, SCREEN_WIDTH_PX + 7) + TILE_WIDTH, SCREEN_HEIGHT_PX + TILE_WIDTH)
	ld a, SCREEN_HEIGHT_PX + TILE_WIDTH
	ld [hli], a
	ld a, SCREEN_WIDTH_PX + 7
	call RandomRange
	add TILE_WIDTH
	ld [hli], a
.finish
	call _RandomSandTile
	ld [hli], a
	ld [hl], PAL_OW_WEATHER
	ret

.spawn_on_right
	; sprite coord is (SCREEN_WIDTH_PX + TILE_WIDTH, RandomRange(0, OAM_YCOORD_HIDDEN))
	ld a, OAM_YCOORD_HIDDEN
	call RandomRange
	ld [hli], a
	ld a, SCREEN_WIDTH_PX + TILE_WIDTH
	ld [hli], a
	jr .finish

DoOverworldCherryBlossoms:
	ld a, [wLoadedObjPal{d:PAL_OW_WEATHER}]
	cp PAL_OW_PINK
	jr z, .continue
	farcall LoadWeatherPal
.continue
	call ScanForEmptyOAM
	call nc, SpawnCherryBlossom
	; fallthrough
DoCherryBlossomFall:
	ld de, wShadowOAM + WEATHER_OAM_START
	ld b, WEATHER_OAM_STRUCTS
.loop
	; if the sprite is hidden, skip it
	ld hl, OAMA_Y
	add hl, de
	ld a, [hl]
	cp OAM_YCOORD_HIDDEN
	jr z, .next

	; if the sprite is not a cherry petal, skip it
	ld hl, OAMA_TILEID
	add hl, de
	ld a, [hli]
	cp CHERRYLEAF_TILE
	jr nz, .next

	; if the sprite doesn't use the weather palette, skip it
	ld a, [hl]
	cp PAL_OW_WEATHER
	jr nz, .next

	; the cherry petal has a 1% chance of despawning
	call Random
	cp 1 percent
	jr c, .despawn

	; double the player's step vector (may be positive or negative)
	ld a, [wPlayerStepVectorY]
	add a
	ld c, a

	; get the sprite's y coord and subtract the player's doubled step vector
	ld hl, OAMA_Y
	add hl, de
	ld a, [hl]
	sub c
	ld c, a

	; sprites with an even index move down 1 faster.
	call IsEvenSpriteIndex
	add c

	; minimum fall speed is 2
	add 2

	; if the sprite goes offscreen, despawn it, otherwise update its y coord
	ld hl, OAMA_Y
	add hl, de
	cp OAM_YCOORD_HIDDEN
	ld [hl], a
	jr nc, .despawn

	; double the player's step vector (may be positive or negative)
	ld a, [wPlayerStepVectorX]
	add a
	ld c, a

	; sprite has a 50% chance to wiggle left 1.
	call Random
	and 1
	ld a, c
	jr nz, .no_add_1
	inc a
.no_add_1
	ld c, a

	; get the sprite's x coord and subtract the player's doubled step vector + wiggle
	ld hl, OAMA_X
	add hl, de
	ld a, [hl]
	sub c

	; sprite can have 0 change in x coord (no wiggle or step vector)
	; so we increment a before subtracting to check for despawn (offscreen)
	inc a
	ld hl, OAMA_X
	add hl, de
	sub 1 ; no-optimize a++|a-- (need to set carry)
	ld [hl], a
	jr c, .despawn
.next
	ld hl, OBJ_SIZE
	add hl, de
	ld d, h
	ld e, l
	dec b
	jr nz, .loop
	ret

.despawn
	ld hl, OAMA_Y
	add hl, de
	ld a, OAM_YCOORD_HIDDEN
	ld [hli], a
	xor a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	jr .next

SpawnCherryBlossom:
	call Random
	cp 10 percent
	ret nc
	push hl ; preserve OAM slot pointer
	ldh a, [rSVBK]
	push af

	; Rarely spawn from the screen edge (top/right), like snow,
	; instead of only from cherry-leaf tiles.
	call Random
	cp 30 percent
	jmp c, .edge_spawn

	; clear candidate buffer counter
	ld a, BANK(wWeatherScratch)
	ldh [rSVBK], a
	xor a
	ld [wWeatherScratch], a

	; scan all on-screen collision cells for cherry leaves
	ld a, BANK(wXCoord)
	ldh [rSVBK], a
	ld b, SCREEN_HEIGHT / 2
	xor a
	ld e, a ; y offset
.y_loop
	ld c, SCREEN_WIDTH / 2
	xor a
	ld d, a ; x offset
.x_loop
	push de
	ld a, [wXCoord]
	add d
	ld h, a
	ld a, [wYCoord]
	add e
	ld l, a
	ld d, h
	ld e, l
	push bc
	call GetCoordTileCollision
	pop bc
	pop de
	cp COLL_CHERRY_LEAVES
	jr nz, .next_tile

	; store packed screen coords (X hi nibble | Y lo nibble)
	push bc
	push de
	ld a, BANK(wWeatherScratch)
	ldh [rSVBK], a
	ld hl, wWeatherScratch
	ld a, [hl]
	cp SCREEN_HEIGHT_PX - 1 ; don't overflow wWeatherScratch
	jr nc, .skip_store
	ld c, a
	inc a
	ld [hl], a
	ld hl, wWeatherScratch + 1
	ld b, 0
	ld a, c
	add hl, bc
	pop de
	ld a, d
	and $f
	swap a
	ld b, a
	ld a, e
	and $f
	or b
	ld [hl], a
	jr .stored
.skip_store
	pop de
.stored
	ld a, BANK(wXCoord)
	ldh [rSVBK], a
	pop bc

.next_tile
	inc d
	dec c
	jr nz, .x_loop
	inc e
	dec b
	jr nz, .y_loop

	; choose a random candidate
	ld a, BANK(wWeatherScratch)
	ldh [rSVBK], a
	ld a, [wWeatherScratch]
	and a
	jr z, .no_spawn
	ld b, a
	call RandomRange
	ld c, a
	ld hl, wWeatherScratch + 1
	ld b, 0
	add hl, bc
	ld a, [hl]
	ld d, a
	and $f
	ld e, a ; y offset
	ld a, d
	swap a
	and $f
	ld d, a ; x offset

	ld a, BANK(wXCoord)
	ldh [rSVBK], a

	; convert screen coords to pixel coords
	ld a, d
	swap a
	and $f0
	add 16
	ld d, a
	ld a, e
	swap a
	and $f0
	add 16
	ld e, a

	pop af
	ld b, a ; stash original WRAM bank
	pop hl
	ld a, e
	ld [hli], a ; Y coord
	ld a, d
	ld [hli], a ; X coord
	ld a, CHERRYLEAF_TILE
	ld [hli], a ; Tile ID
	ld [hl], PAL_OW_WEATHER ; attributes
	ld a, b
	ldh [rSVBK], a
	ret

.edge_spawn
	; 25% chance to spawn on the right side; otherwise spawn at the top.
	call Random
	and %11
	jr z, .edge_spawn_on_right

	; sprite coord is (0, RandomRange(0, SCREEN_WIDTH_PX + 7) + TILE_WIDTH)
	xor a
	ld [hli], a
	ld a, SCREEN_WIDTH_PX + 7
	call RandomRange
	add TILE_WIDTH
	ld [hli], a
	jr .edge_finish

.edge_spawn_on_right
	; sprite coord is (RandomRange(0, OAM_YCOORD_HIDDEN), SCREEN_WIDTH_PX + TILE_WIDTH)
	ld a, OAM_YCOORD_HIDDEN
	call RandomRange
	ld [hli], a
	ld a, SCREEN_WIDTH_PX + TILE_WIDTH
	ld [hli], a

.edge_finish
	ld a, CHERRYLEAF_TILE
	ld [hli], a ; Tile ID
	ld [hl], PAL_OW_WEATHER ; attributes
	pop af
	ldh [rSVBK], a
	pop hl
	ret

.no_spawn
	pop af
	ldh [rSVBK], a
	pop hl
	ret

Lightning:
; Flash the screen white for a frame, then put the map's palettes back.
;
; The source fades back in through OWFadePalettesInit and marks wPalWhiteState
; and NO_DYN_PAL_APPLY_UNTIL_RESET_F, none of which exist here. Reapplying the
; map palettes directly gives a hard flash, which is what lightning looks like.
	ld hl, wWeatherFlags
	bit OW_WEATHER_DO_FLY_F, [hl]
	ret nz ; the screen is already white
	bit OW_WEATHER_LIGHTNING_DISABLED_F, [hl]
	ret nz ; something else is managing the palettes

	; Ramp toward white and back rather than strobing to it for a frame. The
	; fades block, and each frame they wait calls the very hook we are inside --
	; safe only because DoOverworldWeather refuses to reenter.
	call SetWhitePals
	ld c, LIGHTNING_FLASH_STEPS
	call FadePalettes

	ld de, SFX_THUNDER
	call PlaySFX

	farcall LoadMapPals
	; LoadMapPals restores the map's palettes at full brightness, and the fade
	; below aims at them -- so without re-dimming here every strike would leave
	; the storm bright until the next map load.
	call DimWeatherPals
	ld c, LIGHTNING_FLASH_STEPS
	call FadePalettes

	; The fade leaves the map's own palettes staged but the sprites reassigned,
	; so put the dynamic allocations back and snap to the exact target.
	farcall ClearSavedObjPals
	farcall CheckForUsedObjPals
; ApplyPals only stages wBGPals1 into wBGPals2. Without hCGBPalUpdate, VBlank
; never pushes it to the hardware registers and nothing changes on screen.
	farcall ApplyPals
	ld a, TRUE
	ldh [hCGBPalUpdate], a
	ret

_RandomSandTile:
; One of the two sand frames, so a sandstorm is not one stamp repeated.
	call Random
	and 1
	add SANDSTORM_TILE
	ret

IsEvenSpriteIndex:
; input: e = sprite index
; output: a = is_even(e / 4)
	ld a, e
	rra
	rra ; / 4
	and 1
	ret

MACRO weather_dim
; brightness in eighths, then the colour the palette is pulled toward.
; rgbasm folds the target into a per-channel lift, so the inner loop stays a
; multiply and an add: out = component * brightness / 8 + target * (8 - brightness) / 8.
	db \1, \2 * (8 - \1) / 8
	db \1, \3 * (8 - \1) / 8
	db \1, \4 * (8 - \1) / 8
ENDM

DEF WEATHER_DIM_ENTRY_SIZE EQU 6
DEF COLORS_PER_PALETTE EQU 4

DimWeatherPals::
; Pull wBGPals1 toward the current weather's overcast colour, so rain does not
; fall through a bright noon sky.
;
; Scaling alone was the first attempt and it was not enough: multiplying every
; channel by the same factor preserves their ratios exactly, so hue and
; saturation come out untouched and the map just reads as the same sunny scene
; with the brightness down. Overcast light is diffuse -- it desaturates, cools,
; and lifts the blacks. Interpolating toward a grey-blue does all three.
;
; The source gets this from a parallel set of hand-tuned overcast palettes and a
; whole overcast tileset. This needs no new data: it transforms whatever
; LoadMapPals just produced, so it follows the season, the time of day and any
; special map palette for free.
	ldh a, [rSVBK]
	push af
	ld a, BANK(wCurWeather)
	ldh [rSVBK], a
	ld a, [wCurWeather]
	cp OW_WEATHER_SUN
	jr nz, .dim
	call SunPals
	jr .done

.dim
	call _GetWeatherDimRow
	jr nc, .done ; this weather leaves the palettes alone

	ld a, BANK(wBGPals1)
	ldh [rSVBK], a
	ld de, wBGPals1
	ld a, 8 * COLORS_PER_PALETTE
	call _DimColors

.done
	pop af
	ldh [rSVBK], a
	ret

DimSpritePal::
; de -> the palette CopySpritePal has just written into wOBPals1. Dim it the
; same way the map's own palettes are dimmed.
;
; Without this the world desaturates by half in a storm and the player does not
; move at all, so he reads as pasted onto it. The weather's own slot is exempt:
; rain catches light, and the particles have to stay legible against the ground
; they are falling on.
	ld a, e
	cp LOW(wOBPals1 palette PAL_OW_WEATHER)
	jr nz, .not_weather
	ld a, d
	cp HIGH(wOBPals1 palette PAL_OW_WEATHER)
	ret z

.not_weather
	ldh a, [rSVBK]
	push af
	push de
	ld a, BANK(wCurWeather)
	ldh [rSVBK], a
	call _GetWeatherDimRow
	pop de
	jr nc, .done

	ld a, BANK(wOBPals1)
	ldh [rSVBK], a
	ld a, COLORS_PER_PALETTE
	call _DimColors

.done
	pop af
	ldh [rSVBK], a
	ret

_GetWeatherDimRow:
; bc -> the current weather's row of WeatherDimming, with carry set if that row
; asks for any dimming at all. Needs BANK(wCurWeather) selected; clobbers de, hl.
	ld a, [wCurWeather]
	ld l, a
	ld h, 0
	add hl, hl ; * 2
	ld d, h
	ld e, l
	add hl, hl ; * 4
	add hl, de ; * 6
	ld de, WeatherDimming
	add hl, de
	ld b, h
	ld c, l
	ld a, [bc]
	cp 8 ; carry means this weather dims
	ret

_DimColors:
; de -> the first colour, a = how many of them, bc -> the weather's row.
.loop
	push af
	push bc ; the row, which _DimColor walks off the end of
	call _DimColor
	pop bc
	pop af
	dec a
	jr nz, .loop
	ret

_DimColor:
; de -> a colour, bc -> the weather's six dimming bytes. Advances de past the
; colour and bc past the row. A colour is two bytes, little-endian:
; %gggrrrrr %-bbbbbgg.
;
; de rather than hl for the palette, so hl is free to hold both bytes at once.
	ld a, [de]
	ld l, a ; low byte
	inc de
	ld a, [de]
	ld h, a ; high byte
	dec de

	; red
	ld a, l
	and %00011111
	call _ScaleComponent
	push af

	; green, which straddles the two bytes
	ld a, l
	rlca
	rlca
	rlca
	and %00000111
	ld l, a
	ld a, h
	and %00000011
	rlca
	rlca
	rlca
	or l
	call _ScaleComponent
	push af

	; blue
	ld a, h
	rrca
	rrca
	and %00011111
	call _ScaleComponent

	; and back into two bytes
	rlca
	rlca
	and %01111100
	ld h, a
	pop af ; green
	ld l, a
	rrca
	rrca
	rrca
	and %00000011
	or h
	ld h, a
	ld a, l
	and %00000111
	rrca
	rrca
	rrca
	ld l, a
	pop af ; red
	or l
	ld [de], a
	inc de
	ld a, h
	ld [de], a
	inc de
	ret

SunPals:
; A bright day: colours pushed away from their grey and warmed a touch, by day
; only. Each palette's darkest colour is left alone so outlines stay crisp.
	ld a, [wTimeOfDayPal]
	maskbits NUM_DAYTIMES
	cp NITE_F
	ret nc ; evening and night look as they always do
	ld a, BANK(wBGPals1)
	ldh [rSVBK], a
	ld de, wBGPals1
	ld a, 8
.palette
	push af
	ld a, COLORS_PER_PALETTE - 1
.color
	push af
	call _SunColor
	pop af
	dec a
	jr nz, .color
	inc de
	inc de ; skip the darkest colour
	pop af
	dec a
	jr nz, .palette
	ret

DEF SUN_LIFT_RED   EQU 2
DEF SUN_LIFT_GREEN EQU 2
DEF SUN_LIFT_BLUE  EQU 0

_SunColor:
; de -> a colour, advanced past it. Each channel becomes
; v + (v - grey) * 3 / 8 + lift, where grey = (r + 2g + b) / 4.
	push de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	ld a, l
	and %00011111
	ld b, a ; red
	ld a, l
	rlca
	rlca
	rlca
	and %00000111
	ld c, a
	ld a, h
	and %00000011
	rlca
	rlca
	rlca
	or c
	ld c, a ; green
	ld a, h
	rrca
	rrca
	and %00011111
	ld l, a ; blue
	ld a, b
	add c
	add c
	add l
	srl a
	srl a
	ld h, a ; grey
	ld e, SUN_LIFT_RED
	ld a, b
	call .Channel
	ld b, a
	ld e, SUN_LIFT_GREEN
	ld a, c
	call .Channel
	ld c, a
	ld e, SUN_LIFT_BLUE
	ld a, l
	call .Channel
	; pack: low = %gggrrrrr, high = %-bbbbbgg
	rlca
	rlca
	and %01111100
	ld l, a
	ld a, c
	rrca
	rrca
	rrca
	and %00000011
	or l
	ld h, a
	ld a, c
	and %00000111
	swap a
	rlca
	or b
	pop de
	ld [de], a
	inc de
	ld a, h
	ld [de], a
	inc de
	ret

.Channel:
; a = channel, e = lift, h = grey. Returns the new channel, clamped to 0-31.
	ld d, a
	add e
	ld e, a
	ld a, d
	sub h
	ld d, a
	add a
	add d
	sra a
	sra a
	sra a
	add e
	bit 7, a
	jr z, .positive
	xor a
	ret

.positive
	cp 1 << 5
	ret c
	ld a, (1 << 5) - 1
	ret

_ScaleComponent:
; a = a * brightness / 8 + lift, for one five-bit component. bc -> that
; channel's two bytes, and is advanced past them. Preserves de and hl.
	push hl
	ld h, a
	ld a, [bc]
	inc bc
	ld l, a ; brightness
	xor a
.multiply
	add h
	dec l
	jr nz, .multiply
	rrca
	rrca
	rrca
	and %00011111
	ld h, a
	ld a, [bc]
	inc bc
	add h ; lift
	cp 1 << 5
	jr c, .no_clamp
	ld a, (1 << 5) - 1
.no_clamp
	pop hl
	ret

WeatherDimming:
; Per weather: how much of the map's own palette survives, and the colour the
; rest of it is made of. Both are dials -- brightness for how dark, target for
; how grey and how cool.
	table_width WEATHER_DIM_ENTRY_SIZE
	weather_dim 8,  0,  0,  0 ; OW_WEATHER_NONE, untouched
	weather_dim 5, 11, 12, 15 ; OW_WEATHER_RAIN
	weather_dim 6, 17, 18, 21 ; OW_WEATHER_SNOW, bright but flat
	weather_dim 4,  9, 10, 14 ; OW_WEATHER_THUNDERSTORM, the darkest and coolest
	weather_dim 6, 20, 17, 12 ; OW_WEATHER_SANDSTORM, a warm haze rather than cool
	weather_dim 8,  0,  0,  0 ; OW_WEATHER_CHERRY_BLOSSOMS, a clear spring day
	weather_dim 8,  0,  0,  0 ; OW_WEATHER_SUN, brightened by SunPals instead
	assert_table_length NUM_OW_WEATHERS + 1

LoadWeatherGraphics::
	ld a, [wCurWeather]
	assert OW_WEATHER_NONE == 0
	and a
	ret z ; no weather, nothing to load

	; hl = WeatherGraphics + 3 * (wCurWeather - 1)
	ld hl, WeatherGraphics - 3
	ld d, 0
	ld e, a
	add hl, de
	add hl, de
	add hl, de

	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a ; de = gfx pointer
	ld c, [hl] ; c = tile count
	ld a, c
	and a
	ret z ; a weather with no particles
	ld b, BANK("Overworld Weather Graphics")
	ld hl, vTiles0 tile WEATHER_TILE_1
	; Get2bpp defers to Request2bpp while the LCD is on, so this is safe mid-map.
	jmp Get2bpp

INCLUDE "data/sprites/weather.asm"

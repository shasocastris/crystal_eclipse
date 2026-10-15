GetOvercastWeather::
; Today's weather for the map that was just loaded, in a, or OW_WEATHER_NONE.
;
; The source stores four chosen (intensity, group, map) triples, a day, and a
; live intensity -- fourteen saved bytes. M0 reserved six. So rather than store
; *which* maps are wet, we store one byte of daily seed and hash it against a
; map's own id when asked. That keeps the properties that matter: an answer that
; is stable for the whole day, identical after a reload, and independent between
; maps -- and it needs no per-map table at all, which suits a project that spent
; M3 and M4 getting away from hardcoded map ids.
	ld a, [wEnvironment]
	call CheckOutdoorMap
	jr nz, .none

	; As in the source, no weather before the player has any context for it.
	ld de, EVENT_AZALEA_TOWN_SLOWPOKES
	ld b, CHECK_FLAG
	call EventFlagAction
	ld a, c
	and a
	jr z, .none

	call .ReseedIfNewDay

	; Winter snows on some maps each day and leaves the rest clear over the
	; snowy tiles. Not the Orange Islands -- they have their own table rows.
	ld a, [wCurRegion]
	cp ORANGE_REGION
	jr z, .roll
	ld a, [wSeason]
	maskbits NUM_SEASONS
	cp WINTER_F
	jr nz, .roll
	call .HashForThisMap
	cp OVERCAST_SNOW_CHANCE
	jr nc, .none
	ld a, OW_WEATHER_SNOW
	ret

.roll
	call .HashForThisMap
	ld b, a

	; The season decides how much of the hash range counts as wet.
	call .SeasonTableIndex
	ld hl, .SeasonWetness
	add hl, de
	ld a, b
	cp [hl]
	jr nc, .dry

	; Severity comes from the same hash, so a map that is stormy today stays
	; stormy rather than flickering between the two every time it is re-entered.
	cp OVERCAST_THUNDER_LEVEL
	ld a, OW_WEATHER_THUNDERSTORM
	ret c
	ld a, OW_WEATHER_RAIN
	ret

.none
	xor a ; OW_WEATHER_NONE
	ret

.dry
; Sun takes the top of the hash range, so it never overlaps the wet bottom.
	call .SeasonTableIndex
	ld hl, .SeasonSun
	add hl, de
	ld a, [hl]
	and a
	jr z, .none ; no sun this season
	ld a, b
	cp [hl]
	jr c, .none
	ld a, OW_WEATHER_SUN
	ret

.SeasonTableIndex
; de = the season, or the season + NUM_SEASONS in the Orange Islands, whose
; rows follow the mainland's in each table.
	ld a, [wSeason]
	maskbits NUM_SEASONS
	ld e, a
	ld d, 0
	ld a, [wCurRegion]
	cp ORANGE_REGION
	ret nz
	ld a, e
	add NUM_SEASONS
	ld e, a
	ret

.ReseedIfNewDay
; Rolled lazily here rather than from the daily reset, so that it is also right
; immediately after loading a save that was made on a different day.
	ld a, [wCurDay]
	ld hl, wOvercastRandomDay
	cp [hl]
	ret z
	ld [hl], a
	call Random
	ld [wOvercastSeed], a
	ret

.HashForThisMap
; Mix the day's seed with the map's identity.
;
; The group and the map number are streamed in at separate stages rather than
; folded into one byte first: folding makes distinct maps collide outright, and
; two maps that collide then share their weather permanently.
;
; Rotations are by 3 and 5 rather than 4, and the last two rounds add rather
; than xor. A nibble-symmetric mix is the trap here -- `v xor swap v` writes
; high-xor-low into *both* nibbles, so it can only ever produce $00, $11 ... $ff,
; and it carries just four bits of the seed. That collapses the range to sixteen
; outcomes and locks maps together, while leaving the average wet rate looking
; about right, which is what made it survive review.
	ld a, [wOvercastSeed]
	rlca
	rlca
	rlca ; rotate right 5
	ld hl, wMapGroup
	add [hl]
	ld b, a
	rrca
	rrca
	rrca ; rotate right 3
	xor b
	rlca
	rlca
	rlca ; rotate right 5
	ld hl, wMapNumber
	add [hl]
	ld b, a
	rrca ; rotate right 1
	add b
	ret

.SeasonWetness
; How much of the hash range is wet, per season.
	table_width 1
	db 20 percent ; SPRING
	db 10 percent ; SUMMER -- the clear-weather bias
	db 35 percent ; AUTUMN -- the wettest
	db 0          ; WINTER -- unreached, it snows instead
	assert_table_length NUM_SEASONS
; The Orange Islands follow the Caribbean: dry from winter into spring, wet
; from summer, wettest in the autumn storm season.
	table_width 1
	db 15 percent ; SPRING
	db 25 percent ; SUMMER
	db 30 percent ; AUTUMN
	db 10 percent ; WINTER
	assert_table_length NUM_SEASONS

.SeasonSun
; Where the sunny top of the hash range starts, per season; 0 for none.
	table_width 1
	db 85 percent ; SPRING -- 15% of maps
	db 70 percent ; SUMMER -- 30% of maps
	db 0          ; AUTUMN
	db 0          ; WINTER
	assert_table_length NUM_SEASONS
; Orange Islands
	table_width 1
	db 80 percent ; SPRING -- 20% of maps
	db 90 percent ; SUMMER -- 10% of maps
	db 95 percent ; AUTUMN -- 5% of maps
	db 75 percent ; WINTER -- 25% of maps
	assert_table_length NUM_SEASONS

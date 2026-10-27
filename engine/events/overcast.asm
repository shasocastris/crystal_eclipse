GetOvercastWeather::
; Today's rolled weather for a map, in a, or OW_WEATHER_NONE.
; b = map group, c = map number, d = environment, e = region
;
; The source stores four chosen (intensity, group, map) triples, a day, and a
; live intensity -- fourteen saved bytes. M0 reserved six. So rather than store
; *which* maps are wet, we store one byte of daily seed and hash it against a
; map's own id when asked. That keeps the properties that matter: an answer that
; is stable for the whole day, identical after a reload, and independent between
; maps -- and it needs no per-map table at all, which suits a project that spent
; M3 and M4 getting away from hardcoded map ids.
	ld a, d
	call CheckOutdoorMap
	jr nz, .none

	; As in the source, no weather before the player has any context for it.
	push bc
	push de
	ld de, EVENT_AZALEA_TOWN_SLOWPOKES
	ld b, CHECK_FLAG
	call EventFlagAction
	ld a, c
	pop de
	pop bc
	and a
	jr z, .none

	call .ReseedIfNewDay

	; From here d is the row of the season tables: the season, or the season
	; + NUM_SEASONS in the Orange Islands, whose rows follow the mainland's.
	ld a, [wSeason]
	maskbits NUM_SEASONS
	ld d, a
	ld a, e
	cp ORANGE_REGION
	jr z, .orange

	; Winter snows on some maps each day and leaves the rest clear over the
	; snowy tiles. Not the Orange Islands -- they have their own table rows.
	ld a, d
	cp WINTER_F
	jr nz, .roll
	call .HashForThisMap
	ld b, a
	cp OVERCAST_SNOW_CHANCE
	jr nc, .dry
	ld a, OW_WEATHER_SNOW
	ret

.orange
	ld a, d
	add NUM_SEASONS
	ld d, a
.roll
	call .HashForThisMap
	ld b, a

	; The season decides how much of the hash range counts as wet.
	ld hl, .SeasonWetness
	call .SeasonRow
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
; Just above the wet band, or winter's snow, comes a dry but overcast one.
	ld hl, .SeasonOvercast
	call .SeasonRow
	ld a, b
	cp [hl]
	ld a, OW_WEATHER_OVERCAST
	ret c

; Sun takes the top of the hash range, so it never overlaps the wet bottom.
	ld hl, .SeasonSun
	call .SeasonRow
	ld a, [hl]
	and a
	jr z, .none ; no sun this season
	ld a, b
	cp [hl]
	jr c, .none
	ld a, OW_WEATHER_SUN
	ret

.SeasonRow
; hl += d
	ld a, d
	add l
	ld l, a
	ret nc
	inc h
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
	add b ; map group
	ld l, a
	rrca
	rrca
	rrca ; rotate right 3
	xor l
	rlca
	rlca
	rlca ; rotate right 5
	add c ; map number
	ld l, a
	rrca ; rotate right 1
	add l
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

.SeasonOvercast
; Where the overcast band ends, per season: it starts where the wet band (or
; winter's snow) does, and must end below .SeasonSun.
	table_width 1
	db 35 percent ; SPRING -- 15% of maps
	db 20 percent ; SUMMER -- 10% of maps
	db 55 percent ; AUTUMN -- 20% of maps
	db 60 percent ; WINTER -- 20% of maps, above the 40% that snow
	assert_table_length NUM_SEASONS
; Orange Islands
	table_width 1
	db 25 percent ; SPRING -- 10% of maps
	db 35 percent ; SUMMER -- 10% of maps
	db 45 percent ; AUTUMN -- 15% of maps
	db 20 percent ; WINTER -- 10% of maps
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

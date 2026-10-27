SetCurrentWeather::
; Pick the weather for the map that was just loaded.
;
; A map that names its own weather always gets it, in every season and whatever
; the day rolled: Route 45's sandstorm, Silver Cave's snow and Lake of Rage's
; storm are authored set pieces, not weather. Only maps that ask for nothing are
; left to the season and the daily roll -- which is also why an indoor map with
; an authored weather still gets it, while GetOvercastWeather refuses indoors.
;
; The reverse precedence would read more like the roadmap's sketch of "snow
; across outdoor Johto in winter", but it would bury three deliberate set pieces
; under it for a quarter of the year.
;
; A map may also name the seasons its weather happens in, in the byte's high
; nibble. Out of season it falls through to the roll like any unmarked map, so
; Cherrygrove's blossoms give way to ordinary rain and to winter's snow rather
; than to a pointedly clear sky.
;
; Everything after this is the transition, which drains the previous weather
; over WEATHER_TRANSITION_LENGTH frames instead of letting it pop.
	ld a, [wMapGroup]
	ld b, a
	ld a, [wMapNumber]
	ld c, a
	ld a, [wEnvironment]
	ld d, a
	ld a, [wCurRegion]
	ld e, a
	ld a, [wMapWeather]
	call GetMapWeather
	ld b, a

	ld a, [wWeatherFlags]
	bit OW_WEATHER_DO_FLY_F, a
	jr nz, .no_cooldown ; a Fly has already whited the screen out

	ld a, [wCurWeather]
	and a
	jr z, .no_cooldown ; nothing on screen to drain

	; Rain and thunderstorm share tiles and a palette, so there is nothing to
	; drain between them; only the lightning differs.
	ld c, a
	cp OW_WEATHER_RAIN
	jr nz, .not_rain
	ld a, b
	cp OW_WEATHER_THUNDERSTORM
	jr z, .no_cooldown
.not_rain
	ld a, c
	cp OW_WEATHER_THUNDERSTORM
	jr nz, .compare
	ld a, b
	cp OW_WEATHER_RAIN
	jr z, .no_cooldown
	ld a, c

.compare
	cp b
	jr nz, .cooldown

.no_cooldown
	ld a, b
	ld [wCurWeather], a
	farcall LoadWeatherPal
	call LoadWeatherGraphics
	xor a
	ld [wOverworldWeatherCooldown], a
	ret

.cooldown
	ld [wPrevWeather], a ; a is the weather being drained
	ld a, b
	ld [wCurWeather], a
	ld a, WEATHER_TRANSITION_LENGTH
	ld [wOverworldWeatherCooldown], a
	ret

GetMapWeather:
; Today's weather for any map, in a.
; a = its weather byte, b = map group, c = map number, d = environment,
; e = region
	and a
	jr z, .roll ; the map names nothing

	ld h, a
	and OW_WEATHER_SEASON_MASK
	jr z, .authored ; no season named, so every season

	ld l, a
	push de
	push hl
	ld a, [wSeason]
	maskbits NUM_SEASONS
	ld e, a
	ld d, 0
	ld hl, .SeasonBits
	add hl, de
	ld a, [hl]
	pop hl
	pop de
	and l
	jr z, .roll ; this map's weather is out of season

.authored
	ld a, h
	and OW_WEATHER_MASK
	ret

.roll
	jmp GetOvercastWeather

.SeasonBits
; wSeason is an index; the mask is built from bits. shift_const gives both, so
; this is only here to get from one to the other, already shifted into place.
	table_width 1
	db OW_WEATHER_SPRING
	db OW_WEATHER_SUMMER
	db OW_WEATHER_AUTUMN
	db OW_WEATHER_WINTER
	assert_table_length NUM_SEASONS

GetLandmarkWeather::
; Today's weather at landmark e, in a, for the Town Map: that of the first
; outdoor map at the landmark. A landmark with no outdoor map, a cave say,
; returns -1 -- the map shows the sky, not Silver Cave's authored snow.
	ld b, 0
.next_group
	inc b
	ld a, b
	cp NUM_MAP_GROUPS + 1
	jr nc, .none
	push de
	ld hl, MapGroupSizes - 1
	ld e, b
	ld d, 0
	add hl, de
	ld a, [hl]
	ld hl, MapGroupPointers - 2
	add hl, de
	add hl, de
	pop de
	ld d, a ; maps left in this group
	ld a, BANK(MapGroupPointers)
	call GetFarWord
	ld c, 1
.next_map
	push hl
	ld a, l
	add MAP_LOCATION
	ld l, a
	adc h
	sub l
	ld h, a
	ld a, BANK(MapGroupPointers)
	call GetFarByte
	cp e
	jr nz, .skip
	pop hl
	push hl
	ld a, l
	add MAP_ENVIRONMENT
	ld l, a
	adc h
	sub l
	ld h, a
	ld a, BANK(MapGroupPointers)
	call GetFarByte
	call CheckOutdoorMap
	jr z, .found
.skip
	pop hl
	ld a, l
	add MAP_LENGTH
	ld l, a
	adc h
	sub l
	ld h, a
	inc c
	dec d
	jr nz, .next_map
	jr .next_group

.none
	ld a, -1
	ret

.found
	pop hl
	ld d, a ; environment
	ld a, e
	call RegionForLandmark
	ld e, a
	push de
	push hl
	assert MAP_MAPATTRIBUTES_BANK == 0
	ld a, BANK(MapGroupPointers)
	call GetFarByte
	ld d, a
	pop hl
	ld a, l
	add MAP_MAPATTRIBUTES
	ld l, a
	adc h
	sub l
	ld h, a
	ld a, BANK(MapGroupPointers)
	call GetFarWord
	; the weather byte follows the attributes struct; see CopyMapAttributes
	ld a, l
	add wMapAttributesEnd - wMapAttributes
	ld l, a
	adc h
	sub l
	ld h, a
	ld a, d
	call GetFarByte
	pop de
	jmp GetMapWeather

MapGroupSizes:
; in MapGroupPointers order
	table_width 1
	db NUM_OLIVINE_MAPS
	db NUM_MAHOGANY_MAPS
	db NUM_DUNGEONS_MAPS
	db NUM_ECRUTEAK_MAPS
	db NUM_BLACKTHORN_MAPS
	db NUM_CINNABAR_MAPS
	db NUM_CERULEAN_MAPS
	db NUM_AZALEA_MAPS
	db NUM_LAKE_OF_RAGE_MAPS
	db NUM_VIOLET_MAPS
	db NUM_GOLDENROD_MAPS
	db NUM_VERMILION_MAPS
	db NUM_PALLET_MAPS
	db NUM_PEWTER_MAPS
	db NUM_FAST_SHIP_MAPS
	db NUM_INDIGO_MAPS
	db NUM_FUCHSIA_MAPS
	db NUM_LAVENDER_MAPS
	db NUM_SILVER_MAPS
	db NUM_CABLE_CLUB_MAPS
	db NUM_CELADON_MAPS
	db NUM_CIANWOOD_MAPS
	db NUM_VIRIDIAN_MAPS
	db NUM_NEW_BARK_MAPS
	db NUM_SAFFRON_MAPS
	db NUM_CHERRYGROVE_MAPS
	db NUM_VALENCIA_MAPS
	assert_table_length NUM_MAP_GROUPS

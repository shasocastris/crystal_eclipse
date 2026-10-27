; Overworld weather. Pulled forward from M4 (roadmap §6.2a) so that every map
; carries a weather value from the moment it is authored, rather than three
; regions being retrofitted once the particle engine lands.
;
; Nothing reads these yet -- SetCurrentWeather does not exist. The map attributes
; struct stores one per map and CopyMapAttributes caches it in wMapWeather.

	const_def
	const OW_WEATHER_NONE            ; 0
	const OW_WEATHER_RAIN            ; 1
	const OW_WEATHER_SNOW            ; 2
	const OW_WEATHER_THUNDERSTORM    ; 3
	const OW_WEATHER_SANDSTORM       ; 4
	const OW_WEATHER_CHERRY_BLOSSOMS ; 5
	const OW_WEATHER_SUN             ; 6
	const OW_WEATHER_OVERCAST        ; 7
; Counts the real weathers only, not NONE: every table is indexed by
; wCurWeather - 1, so this is the table length, not the constant count.
DEF NUM_OW_WEATHERS EQU const_value - 1

; The engine tests this with `and a`, so nothing may be inserted before it.
	assert OW_WEATHER_NONE == 0, "OW_WEATHER_NONE must be zero"

; A map's attributes byte carries the weather in its low nibble and, optionally,
; the seasons that weather happens in in its high nibble. No season bits means
; every season, so a byte that names only a weather behaves as it always has --
; which is what keeps the other maps' bytes working untouched.
;
; Out of season the map falls through to the daily roll, so a town whose blossoms
; are gated to spring still gets ordinary rain in summer and snow in winter
; rather than a pointedly clear sky.
DEF OW_WEATHER_MASK        EQU %00001111
DEF OW_WEATHER_SEASON_MASK EQU %11110000
	assert NUM_OW_WEATHERS <= OW_WEATHER_MASK, \
		"the weather ids must fit in the low nibble, beside the season mask"

DEF OW_WEATHER_SPRING EQU SPRING << 4
DEF OW_WEATHER_SUMMER EQU SUMMER << 4
DEF OW_WEATHER_AUTUMN EQU AUTUMN << 4
DEF OW_WEATHER_WINTER EQU WINTER << 4
	assert ANYSEASON << 4 == OW_WEATHER_SEASON_MASK, \
		"every season bit must land inside the season mask"

; Overcast: how much of a map's daily hash counts as wet, per season, lives in
; GetOvercastWeather.SeasonWetness. This is the slice of that range which is
; stormy rather than merely rainy, so it must stay below the smallest of them.
DEF OVERCAST_THUNDER_LEVEL EQU 3 percent
DEF OVERCAST_SNOW_CHANCE   EQU 40 percent ; share of maps that snow on a winter day

; Frames SetCurrentWeather spends draining the previous weather on a change.
DEF WEATHER_TRANSITION_LENGTH EQU 32

; Lightning is rolled once per weather frame and then halved by a second roll,
; so the real rate is half this. Weather runs at 30 frames a second, which makes
; this a strike about every seven seconds; 5 percent gives one about every second
; and a half, which is what play-testing it wants.
DEF LIGHTNING_CHANCE EQU 1 percent

; How far the flash ramps toward white, and how long it takes getting there.
; FadePalettes moves every colour one step per frame, so this is both the
; duration in frames of each half of the flash and how bright it gets: 6 is a
; brief swell, not the whiteout a single-frame strobe gave. Raising it makes the
; flash longer *and* brighter, and the fade blocks the overworld while it runs,
; so twice this many frames of input are dropped per strike.
DEF LIGHTNING_FLASH_STEPS EQU 6

; wWeatherFlags
	const_def
	const OW_WEATHER_DO_FLY_F             ; 0 -- a Fly animation is in progress
	const OW_WEATHER_DISABLED_F           ; 1 -- a textbox is open
	const OW_WEATHER_LIGHTNING_DISABLED_F ; 2 -- suppress the thunderstorm flash
	const OW_WEATHER_IGNORE_PLAYER_Y_F    ; 3 -- ignore player Y motion (ledge hops)

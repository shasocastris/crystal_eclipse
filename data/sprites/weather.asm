MACRO weather_gfx
; graphics pointer, tile count
	dw \1
	db \2
ENDM

WeatherGraphics:
; entries correspond to OW_WEATHER_* constants, indexed by wCurWeather - 1
; (OW_WEATHER_NONE has no row). Every pointer is in "Overworld Weather
; Graphics", so the loader takes the bank from BANK() rather than storing it.
	table_width 3
	weather_gfx RainGFX, 2          ; OW_WEATHER_RAIN
	weather_gfx SnowGFX, 1          ; OW_WEATHER_SNOW
	weather_gfx RainGFX, 2          ; OW_WEATHER_THUNDERSTORM (shares rain gfx)
	weather_gfx SandGFX, 2          ; OW_WEATHER_SANDSTORM (two grain scatters)
	weather_gfx CherryBlossomGFX, 1 ; OW_WEATHER_CHERRY_BLOSSOMS
	weather_gfx 0, 0                ; OW_WEATHER_SUN, palette only
	assert_table_length NUM_OW_WEATHERS

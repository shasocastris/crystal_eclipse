; AutomaticWeatherEffects indexes
	const_def 1
	const AUTOMATIC_SUN
	const AUTOMATIC_RAIN
	const AUTOMATIC_SANDSTORM
	const AUTOMATIC_HAIL

AutomaticWeatherMaps:
; Listed maps always fight in this weather. Unlisted outdoor maps follow the
; overworld weather instead, through OverworldBattleWeather.
MACRO auto_weather_map
	map_id \1 ; map
	db \2 ; AUTOMATIC_* weather index
ENDM
	auto_weather_map TIN_TOWER_ROOF, AUTOMATIC_SUN
	auto_weather_map SEAFOAM_GYM, AUTOMATIC_SUN
	auto_weather_map SILVER_CAVE_UNDERBELLY, AUTOMATIC_SUN
	auto_weather_map CERULEAN_GYM, AUTOMATIC_RAIN
	auto_weather_map SILVER_CAVE_ROOM_2, AUTOMATIC_RAIN
	auto_weather_map OLIVINE_GYM, AUTOMATIC_SANDSTORM
	auto_weather_map PEWTER_GYM, AUTOMATIC_SANDSTORM
	auto_weather_map SILVER_CAVE_ROOM_1, AUTOMATIC_SANDSTORM
	auto_weather_map MAHOGANY_GYM, AUTOMATIC_HAIL
	auto_weather_map ICE_PATH_1F, AUTOMATIC_HAIL
	auto_weather_map ICE_PATH_B1F, AUTOMATIC_HAIL
	auto_weather_map ICE_PATH_B2F_MAHOGANY_SIDE, AUTOMATIC_HAIL
	auto_weather_map ICE_PATH_B2F_BLACKTHORN_SIDE, AUTOMATIC_HAIL
	auto_weather_map ICE_PATH_B3F, AUTOMATIC_HAIL
	auto_weather_map SILVER_CAVE_ROOM_3, AUTOMATIC_HAIL
	db 0 ; end

OverworldBattleWeather:
; entries correspond to OW_WEATHER_* constants
	table_width 1
	db 0                   ; OW_WEATHER_NONE
	db AUTOMATIC_RAIN      ; OW_WEATHER_RAIN
	db AUTOMATIC_HAIL      ; OW_WEATHER_SNOW
	db AUTOMATIC_RAIN      ; OW_WEATHER_THUNDERSTORM
	db AUTOMATIC_SANDSTORM ; OW_WEATHER_SANDSTORM
	db 0                   ; OW_WEATHER_CHERRY_BLOSSOMS
	db AUTOMATIC_SUN       ; OW_WEATHER_SUN, by day only
	assert_table_length NUM_OW_WEATHERS + 1

AutomaticWeatherEffects:
; entries correspond to AUTOMATIC_* constants
MACRO auto_weather_effect
	db \1 ; battle weather
	dw \2 ; animation
	dw \3 ; text
ENDM
	auto_weather_effect WEATHER_SUN, SUNNY_DAY, SunGotBrightText
	auto_weather_effect WEATHER_RAIN, RAIN_DANCE, DownpourText
	auto_weather_effect WEATHER_SANDSTORM, ANIM_IN_SANDSTORM, SandstormBrewedText
	auto_weather_effect WEATHER_HAIL, ANIM_IN_HAIL, ItStartedToHailText
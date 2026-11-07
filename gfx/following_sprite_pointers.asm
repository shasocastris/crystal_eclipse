FollowingSpritePointers:
; entries correspond to species indexes - 1
; TODO (phase E): real sprites; every species shows the placeholder for now
	table_width 3
for n, NUM_POKEMON_AND_VARIANTS
	dba FollowerPlaceholderSpriteGFX
endr
	assert_table_length NUM_POKEMON_AND_VARIANTS

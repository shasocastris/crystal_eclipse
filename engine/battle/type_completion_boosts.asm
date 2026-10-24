DoTypeCompletionBoosts:
; Apply damage boost if player has caught all Pokémon of the move's type
; Replaces the traditional badge boost system with a type completion reward
; Grants 12.5% damage boost (9/8 multiplier) when all Pokémon of a type are caught

	; Don't apply boost in the Battle Tower or on enemy's turn
	ld a, [wInBattleTowerBattle]
	and a
	ret nz

	ldh a, [hBattleTurn]
	and a
	ret nz

	; Check if player has caught all Pokémon of the move's type
	ld a, [wCurType]
	call CheckAllTypeSpeciesCaught
	jr nc, .no_boost

	; Load current damage into both HL (original) and DE (for boost calculation)
	ld a, [wCurDamage]
	ld h, a
	ld d, a
	ld a, [wCurDamage + 1]
	ld l, a
	ld e, a

	; Calculate 12.5% boost by dividing by 8, with minimum boost of 1
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e

	; Minimum boost of 1
	ld a, e
	or d
	jr nz, .add_boost
	ld e, 1

.add_boost:
	; Add boost to damage and cap at $FFFF maximum
	add hl, de
	jr nc, .update

	; Cap at $ffff
	ld hl, $ffff

.update:
	; Write boosted damage back to battle variables
	ld a, h
	ld [wCurDamage], a
	ld a, l
	ld [wCurDamage + 1], a

.no_boost:
	ret


CheckAllTypeSpeciesCaught::
; Check if all Pokémon of a given type have been caught
; Input: a = type constant (NORMAL, FIRE, WATER, etc.)
; Output: carry flag set if all caught, clear if any missing
; Destroys: af, bc, de, hl

	push af

	; Search PokemonTypeLists table for matching type entry
	; Table structure: db TYPE, dw SpeciesListPointer, ..., db $FF
	ld hl, PokemonTypeLists

.find_type:
	ld a, [hli]
	cp -1
	jr z, .type_not_found

	ld b, a
	pop af
	push af
	cp b
	jr z, .found_type

	inc hl
	inc hl
	jr .find_type

.found_type:
	; Load pointer to this type's species list
	ld a, [hli]
	ld h, [hl]
	ld l, a

.check_loop:
	; Read next species (16-bit word) from list
	; Species list format: dw SPECIES1, dw SPECIES2, ..., dw -1
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a

	; Check for terminator ($FF $FF)
	ld a, e
	cp $FF
	jr nz, .not_terminator
	ld a, d
	cp $FF
	jr z, .all_caught

.not_terminator:
	; Check if this species is caught, preserving loop state
	push hl
	push de

	ld h, d
	ld l, e

	call CheckPokedexCaughtFlag

	pop de
	pop hl

	jr z, .not_all_caught
	jr .check_loop

.all_caught:
	pop af
	scf
	ret

.not_all_caught:
.type_not_found:
	pop af
	and a
	ret


CheckPokedexCaughtFlag:
; Check if a species has been caught by checking wPokedexCaught bit array
; Input: hl = 16-bit species index (BULBASAUR, PIDGEY, etc.)
; Returns: z flag set if NOT caught, nz flag set if caught
; Destroys: de
	push bc
	push de

	; A type list names a *form*, not just a species. A variant and its base
	; share one Pokédex bit that either of them sets, so the shared bit cannot
	; answer for a list that names one form specifically -- and a variant index
	; would fall in the unused tail of the array, a bit nothing ever sets.
	ld d, h
	ld e, l
	call CheckCaughtFormIndex

	pop de
	pop bc
	ret

INCLUDE "data/types/pokemon_type_lists.asm"

CountCompletedTypes:
; Count how many of the 18 types have all species caught
; Output: wScriptVar = count of completed types (0-18)
	ld hl, PokemonTypeLists
	ld b, 0 ; completed count
.loop:
	ld a, [hl]
	cp $FF
	jr z, .done
	push hl
	push bc
	call CheckAllTypeSpeciesCaught
	pop bc
	pop hl
	jr nc, .next
	inc b
.next:
	inc hl ; skip type byte (already read)
	inc hl ; skip pointer low
	inc hl ; skip pointer high
	jr .loop
.done:
	ld a, b
	ld [wScriptVar], a
	ret

CountGroupCompleted:
; Count completed types within a themed research group
; Input: wScriptVar = group ID (0=Physical, 1=Elemental, 2=Mystical)
; Output: wScriptVar = count of completed types in group (0-6)
	ld a, [wScriptVar]
	ld e, a
	ld d, 0
	ld hl, .GroupPointers
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	; hl = pointer to group's type list
	ld b, 0 ; completed count
.loop:
	ld a, [hli]
	cp $FF
	jr z, .done
	push hl
	push bc
	call CheckAllTypeSpeciesCaught
	pop bc
	pop hl
	jr nc, .not_complete
	inc b
.not_complete:
	jr .loop
.done:
	ld a, b
	ld [wScriptVar], a
	ret

.GroupPointers:
	dw .PhysicalGroup
	dw .ElementalGroup
	dw .MysticalGroup

.PhysicalGroup:
; NORMAL, FIGHTING, FLYING, GROUND, ROCK, STEEL
	db NORMAL, FIGHTING, FLYING, GROUND, ROCK, STEEL, $FF

.ElementalGroup:
; FIRE, WATER, GRASS, ELECTRIC, ICE, DRAGON
	db FIRE, WATER, GRASS, ELECTRIC, ICE, DRAGON, $FF

.MysticalGroup:
; POISON, BUG, GHOST, PSYCHIC, DARK, FAIRY
	db POISON, BUG, GHOST, PSYCHIC_TYPE, DARK, FAIRY, $FF

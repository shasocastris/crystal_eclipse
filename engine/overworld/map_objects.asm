INCLUDE "data/sprites/facings.asm"

INCLUDE "data/sprites/map_objects.asm"

DeleteMapObject::
	push bc
	ld hl, OBJECT_MAP_OBJECT_INDEX
	add hl, bc
	ld a, [hl]
	push af
	ld h, b
	ld l, c
	ld bc, OBJECT_LENGTH
	xor a
	rst ByteFill
	pop af
	cp -1
	jr z, .ok
	bit 7, a
	jr nz, .ok
	call GetMapObject
	ld hl, OBJECT_SPRITE
	add hl, bc
	ld [hl], -1
.ok
	pop bc
	farjp CheckForUsedObjPals

HandleObjectStep:
	call CheckObjectStillVisible
	ret c
	call HandleStepType
	jmp HandleObjectAction

CheckObjectStillVisible:
	ld hl, OBJECT_FLAGS2
	add hl, bc
	res OFF_SCREEN_F, [hl]
	ldh a, [hMapObjectIndex]
	and a
	jr nz, .notPlayer
; hardcode for crossing over connections
	ld a, [wYCoord]
	inc a
	jr z, .yes
	ld a, [wXCoord]
	inc a
	jr z, .yes
.notPlayer
	ld a, [wXCoord]
	ld e, a
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld a, [hl]
	inc a
	sub e
	jr c, .ok
	cp MAPOBJECT_SCREEN_WIDTH
	jr nc, .ok
	ld a, [wYCoord]
	ld e, a
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld a, [hl]
	inc a
	sub e
	jr c, .ok
	cp MAPOBJECT_SCREEN_HEIGHT
	jr c, .yes
; fallthrough
.ok
	ld hl, OBJECT_FLAGS2
	add hl, bc
	set OFF_SCREEN_F, [hl]
	ld a, [wXCoord]
	ld e, a
	ld hl, OBJECT_INIT_X
	add hl, bc
	ld a, [hl]
	inc a
	sub e
	jr c, .ok2
	cp MAPOBJECT_SCREEN_WIDTH
	jr nc, .ok2
	ld a, [wYCoord]
	ld e, a
	ld hl, OBJECT_INIT_Y
	add hl, bc
	ld a, [hl]
	inc a
	sub e
	jr c, .ok2
	cp MAPOBJECT_SCREEN_HEIGHT
	jr nc, .ok2
.yes
	and a
	ret

.ok2
	ld hl, OBJECT_FLAGS1
	add hl, bc
	bit WONT_DELETE_F, [hl]
	jr nz, .yes2
	call DeleteMapObject
	scf
	ret

.yes2
	ld hl, OBJECT_FLAGS2
	add hl, bc
	set OFF_SCREEN_F, [hl]
	and a
	ret

HandleStepType:
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld a, [hl]
	and a
	jr z, .zero
	ld hl, OBJECT_FLAGS2
	add hl, bc
	bit FROZEN_F, [hl]
	ret nz
	cp STEP_TYPE_FROM_MOVEMENT
	jr z, .one
	jr .ok3

.zero
	call StepFunction_Reset
	ld hl, OBJECT_FLAGS2
	add hl, bc
	bit FROZEN_F, [hl]
	ret nz
.one
	call StepFunction_FromMovement
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld a, [hl]
	and a
	ret z
	cp STEP_TYPE_FROM_MOVEMENT
	ret z
.ok3
	ld hl, StepTypesJumptable
	jmp JumpTable

HandleObjectAction:
	ld hl, OBJECT_FLAGS1
	add hl, bc
	bit INVISIBLE_F, [hl]
	jr nz, SetFacingStanding
	ld hl, OBJECT_FLAGS2
	add hl, bc
	bit OFF_SCREEN_F, [hl]
	jr nz, SetFacingStanding
	bit FROZEN_F, [hl]
	jr nz, _CallFrozenObjectAction
; use first column (normal)
	ld de, ObjectActionPairPointers
	jr CallObjectAction

HandleFrozenObjectAction:
	ld hl, OBJECT_FLAGS1
	add hl, bc
	bit INVISIBLE_F, [hl]
	jr nz, SetFacingStanding
_CallFrozenObjectAction:
; use second column (frozen)
	ld de, ObjectActionPairPointers + 2
; fallthrough
CallObjectAction:
	ld hl, OBJECT_ACTION
	add hl, bc
	ld a, [hl]
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jmp _hl_

INCLUDE "engine/overworld/map_object_action.asm"

CopyCoordsTileToLastCoordsTile:
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_LAST_MAP_X
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_LAST_MAP_Y
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_TILE_COLLISION
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_LAST_TILE
	add hl, bc
	ld [hl], a
	call SetTallGrassFlags
	ld hl, OBJECT_TILE_COLLISION
	add hl, bc
	ld a, [hl]
	jr UselessAndA

CopyLastCoordsToCoords:
	ld hl, OBJECT_LAST_MAP_X
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_LAST_MAP_Y
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld [hl], a
	ret

UpdateTallGrassFlags:
	ld hl, OBJECT_FLAGS2
	add hl, bc
	bit OVERHEAD_F, [hl]
	jr z, .ok
	ld hl, OBJECT_TILE_COLLISION
	add hl, bc
	ld a, [hl]
	call SetTallGrassFlags
.ok
	ld hl, OBJECT_TILE_COLLISION
	add hl, bc
	ld a, [hl]
	call UselessAndA
	ret c ; never happens
	ld hl, OBJECT_LAST_TILE
	add hl, bc
	ld a, [hl]
	jr UselessAndA

SetTallGrassFlags:
	call CheckSuperTallGrassTile
	jr z, .set
	call CheckGrassTile
	jr c, .reset
.set
	ld hl, OBJECT_FLAGS2
	add hl, bc
	set OVERHEAD_F, [hl]
	ret

.reset
	ld hl, OBJECT_FLAGS2
	add hl, bc
	res OVERHEAD_F, [hl]
	ret

UselessAndA:
	and a
	ret

EndSpriteMovement:
	xor a
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_MOVEMENT_INDEX
	add hl, bc
	ld [hli], a
	ld [hli], a ; OBJECT_STEP_INDEX
	ld [hli], a ; OBJECT_1D
	ld [hl], a  ; OBJECT_1E
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ret

InitStep:
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_FLAGS1
	add hl, bc
	bit FIXED_FACING_F, [hl]
	jr nz, GetNextTile
	add a
	add a
	and %00001100
	ld hl, OBJECT_DIRECTION
	add hl, bc
	ld [hl], a
	; fallthrough

GetNextTile:
	call GetStepVector
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], a
	ld a, d
	call GetStepVectorSign
	ld hl, OBJECT_LAST_MAP_X
	add hl, bc
	add [hl]
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld [hl], a
	ld d, a
	ld a, e
	call GetStepVectorSign
	ld hl, OBJECT_LAST_MAP_Y
	add hl, bc
	add [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld [hl], a
	ld e, a
	push bc
	call GetCoordTileCollision
	pop bc
	push de
	push af
	call UpdateFollowerVisibility
	pop af
	pop de
	ld hl, OBJECT_TILE_COLLISION
	add hl, bc
	ld [hl], a
	ret

UpdateFollowerVisibility:
; a = collision of the tile object bc is stepping onto
	ld e, a
	ldh a, [hMapObjectIndex]
	and a ; PLAYER?
	jr z, .player_step
	cp FOLLOWER
	ret nz
; the follower hides on water and comes back on land
	ld hl, OBJECT_TILE_COLLISION
	add hl, bc
	ld a, [hl]
	call GetTilePermission
	ld d, a
	ld a, e
	call GetTilePermission
	cp d
	ret z
	ld hl, wFollowerFlags
	and a
	assert LAND_TILE == 0
	jr z, .to_land
	cp WATER_TILE
	ret nz
	bit FOLLOWER_INVISIBLE_F, [hl]
	ret nz ; already in its ball
	set FOLLOWER_INVISIBLE_F, [hl]
	set FOLLOWER_IN_POKEBALL_F, [hl]
	set FOLLOWER_ON_WATER_F, [hl]
	ld hl, OBJECT_FLAGS1
	add hl, bc
	set INVISIBLE_F, [hl]
	jr SpawnPokeballClosing

.to_land
; only if the water put it away, not a script or the bike
	bit FOLLOWER_ON_WATER_F, [hl]
	ret z
	jr FollowerLeaveBall

.on_bike
; stays in its ball until the player gets off (BikeFunction)
	res FOLLOWER_INVISIBLE_ONE_STEP_F, [hl]
	bit FOLLOWER_INVISIBLE_F, [hl]
	set FOLLOWER_INVISIBLE_F, [hl]
	set FOLLOWER_IN_POKEBALL_F, [hl]
	ret nz
	ld hl, wObject1Struct + OBJECT_FLAGS1
	set INVISIBLE_F, [hl]
	jr SpawnPokeballClosing

.player_step
; after a warp, the follower reappears on the player's first step
	ld hl, wFollowerFlags
	ld a, [wPlayerState]
	cp PLAYER_BIKE
	jr z, .on_bike
	bit FOLLOWER_INVISIBLE_ONE_STEP_F, [hl]
	ret z
	res FOLLOWER_INVISIBLE_ONE_STEP_F, [hl]
	cp PLAYER_SURF
	jr z, .surfing
	cp PLAYER_SURF_PIKA
	jr nz, FollowerLeaveBall
.surfing
; it comes out when they reach land
	set FOLLOWER_ON_WATER_F, [hl]
	ret

FollowerLeaveBall::
; Show a hidden follower, out of its Poké Ball if it's in one.
	ld hl, wFollowerFlags
	res FOLLOWER_ON_WATER_F, [hl]
	bit FOLLOWER_INVISIBLE_F, [hl]
	ret z
	res FOLLOWER_INVISIBLE_F, [hl]
	bit FOLLOWER_IN_POKEBALL_F, [hl]
	res FOLLOWER_IN_POKEBALL_F, [hl]
	jr nz, SpawnPokeballOpening
ShowFollower:
	ld hl, wObject1Struct + OBJECT_FLAGS1
	res INVISIBLE_F, [hl]
	ret

; wFollowerFlags hold the follower's final state as soon as a ball
; animation starts, so a map reload mid-animation lands on it.

SpawnPokeballOpening::
	call FindFirstEmptyObjectStruct
	jr nc, ShowFollower
	ld de, PokeballOpeningObject
	jr SpawnPokeball

SpawnPokeballClosing::
	ld de, PokeballClosingObject
SpawnPokeball:
	push bc
	ld bc, wObject1Struct
	call CopyTempObjectData
	call InitTempObject
	pop bc
	ret

PokeballOpeningObject:
	; vtile, palette, movement
	db $80 | FOLLOWER_POKE_BALL_TILE, PAL_OW_POKE_BALL, SPRITEMOVEDATA_POKEBALL_OPENING

PokeballClosingObject:
	db $80 | FOLLOWER_POKE_BALL_TILE, PAL_OW_POKE_BALL, SPRITEMOVEDATA_POKEBALL_CLOSING

AddStepVector:
	call GetStepVector
	jr nc, .okay
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld a, [hl]
	and %1
	jr nz, .okay
	lb de, 0, 0
.okay
	ld hl, OBJECT_SPRITE_X
	add hl, bc
	ld a, [hl]
	add d
	ld [hl], a
	ld hl, OBJECT_SPRITE_Y
	add hl, bc
	ld a, [hl]
	add e
	ld [hl], a
	ret

GetStepVector:
; Return (x, y, duration, speed) in (d, e, a, h).
	ld hl, OBJECT_WALKING
	add hl, bc
	ld a, [hl]
	and %00001111
	add a
	add a
	ld l, a
	ld h, 0
	ld de, StepVectors
	add hl, de
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld h, [hl]
	push af
	push hl
	ld hl, OBJECT_WALKING
	add hl, bc
	ld a, [hl]
	cp (STEP_SLOW << 2 | RIGHT) + 1
	jr c, .slowStep
	pop hl
	pop af
	and a
	ret
.slowStep
	pop hl
	pop af
	scf
	ret

StepVectors:
; x,  y, duration, speed
	; slow
	db  0,  1, 32, 1
	db  0, -1, 32, 1
	db -1,  0, 32, 1
	db  1,  0, 32, 1
	; normal
	db  0,  1, 16, 2
	db  0, -1, 16, 2
	db -1,  0, 16, 2
	db  1,  0, 16, 2
	; running shoes
	db  0,  2,  8, 4
	db  0, -2,  8, 4
	db -2,  0,  8, 4
	db  2,  0,  8, 4
	; bike
	db  0,  4,  4, 8
	db  0, -4,  4, 8
	db -4,  0,  4, 8
	db  4,  0,  4, 8

GetStepVectorSign:
	add a
	ret z  ; 0 or 128 (-128)
	ld a, 1
	ret nc ; +1 to +127
	ld a, -1
	ret    ; -127 to -1

UpdatePlayerStep:
	ld hl, OBJECT_WALKING
	add hl, bc
	ld a, [hl]
	and %00000011
	ld [wPlayerStepDirection], a
	call AddStepVector
	ld a, [wPlayerStepVectorX]
	add d
	ld [wPlayerStepVectorX], a
	ld a, [wPlayerStepVectorY]
	add e
	ld [wPlayerStepVectorY], a
	ld hl, wPlayerStepFlags
	set PLAYERSTEP_CONTINUE_F, [hl]
	ret

RestoreDefaultMovement:
	ld hl, OBJECT_MAP_OBJECT_INDEX
	add hl, bc
	ld a, [hl]
	cp -1
	jr z, .ok
	push bc
	call GetMapObject
	ld hl, MAPOBJECT_MOVEMENT
	add hl, bc
	ld a, [hl]
	pop bc
	ret

.ok
	ld a, SPRITEMOVEDATA_STANDING_DOWN
	ret

ObjectMovement_IncAnonJumptableIndex:
	ld hl, OBJECT_MOVEMENT_INDEX
	add hl, bc
	inc [hl]
	ret

ObjectMovement_DecAnonJumptableIndex:
	ld hl, OBJECT_MOVEMENT_INDEX
	add hl, bc
	dec [hl]
	ret

ObjectMovement_AnonJumptable:
	ld hl, OBJECT_MOVEMENT_INDEX
	add hl, bc
	ld a, [hl]
	pop hl
	jmp JumpTable

ObjectStep_ZeroAnonJumptableIndex:
	ld hl, OBJECT_STEP_INDEX
	add hl, bc
	ld [hl], 0
	ret

ObjectStep_IncAnonJumptableIndex:
	ld hl, OBJECT_STEP_INDEX
	add hl, bc
	inc [hl]
	ret

ObjectStep_AnonJumptable:
	ld hl, OBJECT_STEP_INDEX
	add hl, bc
	ld a, [hl]
	pop hl
	jmp JumpTable

StepFunction_Reset:
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld d, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld e, [hl]
	push bc
	call GetCoordTileCollision
	pop bc
	ld hl, OBJECT_TILE_COLLISION
	add hl, bc
	ld [hl], a
	call CopyCoordsTileToLastCoordsTile
	call EndSpriteMovement
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_FromMovement:
	call ObjectStep_ZeroAnonJumptableIndex
	call GetSpriteMovementFunction
	ld a, [hl]
	ld hl, .Pointers
	jmp JumpTable

.Pointers:
; entries correspond to SPRITEMOVEFN_* constants (see constants/map_object_constants.asm)
	table_width 2
	dw DoNothing                             ; 00 MovementFunction_Null
	dw MovementFunction_RandomWalkY          ; 01
	dw MovementFunction_RandomWalkX          ; 02
	dw MovementFunction_RandomWalkXY         ; 03
	dw MovementFunction_RandomSpinSlow       ; 04
	dw MovementFunction_RandomSpinFast       ; 05
	dw MovementFunction_Standing             ; 06
	dw MovementFunction_ObeyDPad             ; 07
	dw MovementFunction_Indexed1             ; 08
	dw MovementFunction_Indexed2             ; 09
	dw MovementFunction_0a                   ; 0a
	dw MovementFunction_0b                   ; 0b
	dw MovementFunction_0c                   ; 0c
	dw MovementFunction_0d                   ; 0d
	dw MovementFunction_0e                   ; 0e
	dw MovementFunction_Follow               ; 0f
	dw MovementFunction_Script               ; 10
	dw MovementFunction_Strength             ; 11
	dw MovementFunction_FollowNotExact       ; 12
	dw MovementFunction_Shadow               ; 13
	dw MovementFunction_Emote                ; 14
	dw MovementFunction_BigStanding          ; 15
	dw MovementFunction_Bouncing             ; 16
	dw MovementFunction_ScreenShake          ; 17
	dw MovementFunction_SpinClockwise        ; 18
	dw MovementFunction_SpinCounterclockwise ; 19
	dw MovementFunction_BoulderDust          ; 1a
	dw MovementFunction_ShakingGrass         ; 1b
	dw MovementFunction_FollowerObj          ; 1c
	dw MovementFunction_PokeballOpening      ; 1d
	dw MovementFunction_PokeballClosing      ; 1e
	assert_table_length NUM_SPRITEMOVEFN

MovementFunction_RandomWalkY:
	call Random
	ldh a, [hRandomAdd]
	and %00000001
	jmp _RandomWalkContinue

MovementFunction_RandomWalkX:
	call Random
	ldh a, [hRandomAdd]
	and %00000001
	or  %00000010
	jmp _RandomWalkContinue

MovementFunction_RandomWalkXY:
	call Random
	ldh a, [hRandomAdd]
	and %00000011
	jmp _RandomWalkContinue

MovementFunction_RandomSpinSlow:
	call Random
	ldh a, [hRandomAdd]
	and %00001100
	ld hl, OBJECT_DIRECTION
	add hl, bc
	ld [hl], a
	jmp RandomStepDuration_Slow

MovementFunction_RandomSpinFast:
	ld hl, OBJECT_DIRECTION
	add hl, bc
	ld a, [hl]
	and %00001100
	ld d, a
	call Random
	ldh a, [hRandomAdd]
	and %00001100
	cp d
	jr nz, .keep
	xor %00001100
.keep
	ld [hl], a
	jmp RandomStepDuration_Fast

MovementFunction_Standing:
	call CopyLastCoordsToCoords
	call EndSpriteMovement
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_STAND
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_RESTORE
	ret

MovementFunction_ObeyDPad:
	ld hl, GetPlayerNextMovementIndex
	jmp HandleMovementData

MovementFunction_Indexed1:
	ld hl, GetIndexedMovementIndex1
	jmp HandleMovementData

MovementFunction_Indexed2:
	ld hl, GetIndexedMovementIndex2
	jmp HandleMovementData

MovementFunction_0a:
	jmp _GetMovementObject

MovementFunction_0b:
	jmp _GetMovementObject

MovementFunction_0c:
	jmp _GetMovementObject

MovementFunction_0d:
	ld hl, GetPlayerNextMovementIndex
	jmp HandleMovementData

MovementFunction_0e:
	jmp _GetMovementObject

MovementFunction_Follow:
	ld hl, GetFollowerNextMovementIndex
	jmp HandleMovementData

MovementFunction_Script:
	ld hl, GetMovementIndex
	jmp HandleMovementData

MovementFunction_Strength:
	call ObjectMovement_AnonJumptable
.anon_dw
	dw .start
	dw .stop

.start:
	ld hl, OBJECT_TILE_COLLISION
	add hl, bc
	ld a, [hl]
	call CheckPitTile
	jr z, .on_pit
	ld hl, OBJECT_FLAGS2
	add hl, bc
	bit BOULDER_MOVING_F, [hl]
	res BOULDER_MOVING_F, [hl]
	jr z, .ok
	ld hl, OBJECT_RANGE
	add hl, bc
	ld a, [hl]
	and %00000011
	call InitStep
	call CanObjectMoveInDirection
	jr c, .ok2
	ld de, SFX_STRENGTH
	call PlaySFX
	call SpawnStrengthBoulderDust
	call UpdateTallGrassFlags
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_STRENGTH_BOULDER
	ret

.ok2
	call CopyLastCoordsToCoords
.ok
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ret

.on_pit
	call ObjectMovement_IncAnonJumptableIndex
.stop:
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ret

MovementFunction_FollowerObj:
	ld a, [wFollowerFlags]
	bit FOLLOWER_FROZEN_F, a
	jr z, .follow
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_STAND
	ret

.follow
	call .CheckBackedInto
	jr c, .got_step
	call MoveFollowNotExact
	ret nc
.got_step
	push af
	ld a, [wFollowerNextMovement]
	cp FOLLOWERMOVE_NUM_TYPES
	jr c, .got_movement
	xor a
.got_movement
	ld e, a
	ld d, 0
	ld hl, .StepFunctions
	add hl, de
	add hl, de
	add hl, de
	ld a, [hli]
	ld [wFollowerNextMovement], a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop af
	jp hl

.StepFunctions:
; next movement, step function
	table_width 3
	dbw FOLLOWERMOVE_NORMAL,   .NormalStep ; FOLLOWERMOVE_NORMAL
	dbw FOLLOWERMOVE_NORMAL,   SlideStep   ; FOLLOWERMOVE_SLIDE
	dbw FOLLOWERMOVE_NORMAL,   .BigStep    ; FOLLOWERMOVE_BIG_STEP
	dbw FOLLOWERMOVE_STILL,    .TurnHead   ; FOLLOWERMOVE_STILL
	dbw FOLLOWERMOVE_BIG_STEP, .TurnHead   ; FOLLOWERMOVE_PREPARE_JUMP
	assert_table_length FOLLOWERMOVE_NUM_TYPES

.NormalStep:
	ld d, OBJECT_ACTION_STEP
	jmp NormalStep

.BigStep:
; the player hopped a ledge: jump two tiles to catch up
	ld e, a
	xor a
	ld [wFollowerNextMovement], a
	ld d, STEP_BIKE << 2
	ld a, [wPlayerStepType]
	cp STEP_TYPE_PLAYER_JUMP
	jr z, .regular
	ld a, [wPlayerState]
	cp PLAYER_BIKE
	jr z, .jump
	ld a, [wPlayerTileCollision]
	cp COLL_ICE
	jr z, .jump
.regular
	ld a, [wCurInput]
	and B_BUTTON
	jr nz, .jump
	ld d, STEP_RUN << 2
.jump
	push de
	ld de, SFX_JUMP_OVER_LEDGE
	call PlaySFX
	pop de
	ld a, e
	and %00000011
	or d
	jmp JumpStep

.TurnHead:
	and %00000011
	add a
	add a
	jmp TurnHead

.CheckBackedInto:
; A cutscene backing the player up (fix_facing) onto the follower pushes it
; back the same way instead of swapping it in front of the player.
	ld a, [wPlayerStruct + OBJECT_FLAGS1]
	bit FIXED_FACING_F, a
	ret z ; nc
	ld a, [wPlayerWalking]
	cp STANDING
	ret z ; nc
	ld a, [wPlayerMapX]
	ld hl, OBJECT_MAP_X
	add hl, bc
	cp [hl]
	jr nz, .not_backed_into
	ld a, [wPlayerMapY]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	cp [hl]
	jr nz, .not_backed_into
	ld a, [wPlayerWalking]
	scf
	ret

.not_backed_into
	and a
	ret

MovementFunction_FollowNotExact:
	call MoveFollowNotExact
	ret nc
	ld d, OBJECT_ACTION_STEP
	jmp NormalStep

MoveFollowNotExact:
; Return carry and the step to take in a if the leader moved.
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld d, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld e, [hl]
	ld hl, OBJECT_RANGE
	add hl, bc
	ld a, [hl]
	push bc
	call GetObjectStruct
	ld hl, OBJECT_WALKING
	add hl, bc
	ld a, [hl]
	cp STANDING
	jr z, .standing
	ld hl, OBJECT_LAST_MAP_X
	add hl, bc
	ld a, [hl]
	cp d
	jr z, .equal
	ld a, 3
	jr nc, .done
	ld a, 2
	jr .done

.equal
	ld hl, OBJECT_LAST_MAP_Y
	add hl, bc
	ld a, [hl]
	cp e
	jr z, .standing
	jr c, .less2
	xor a
	jr .done

.less2
	ld a, 1
.done
	ld d, a
	ld hl, OBJECT_WALKING
	add hl, bc
	ld a, [hl]
	and %00001100
	or d
	pop bc
	scf
	ret

.standing
	pop bc
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_STAND
	and a
	ret

MovementFunction_BigStanding:
	call EndSpriteMovement
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_BIG_DOLL_SYM
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_STANDING
	ret

MovementFunction_Bouncing:
	call EndSpriteMovement
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_BOUNCE
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_STANDING
	ret

MovementFunction_SpinCounterclockwise:
	call ObjectMovement_AnonJumptable
.anon_dw
	dw _MovementSpinInit
	dw _MovementSpinRepeat
	dw _MovementSpinTurnLeft

MovementFunction_SpinClockwise:
	call ObjectMovement_AnonJumptable
.anon_dw
	dw _MovementSpinInit
	dw _MovementSpinRepeat
	dw _MovementSpinTurnRight

_MovementSpinInit:
	call EndSpriteMovement
	call ObjectMovement_IncAnonJumptableIndex
	; fallthrough

_MovementSpinRepeat:
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_STAND
	ld a, $20
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_SLEEP
	jmp ObjectMovement_IncAnonJumptableIndex

_MovementSpinTurnLeft:
	ld de, .facings_counterclockwise
	call _MovementSpinNextFacing
	jr MovementFunction_SpinCounterclockwise

.facings_counterclockwise:
	db OW_RIGHT
	db OW_LEFT
	db OW_DOWN
	db OW_UP

_MovementSpinTurnRight:
	ld de, .facings_clockwise
	call _MovementSpinNextFacing
	jr MovementFunction_SpinClockwise

.facings_clockwise:
	db OW_LEFT
	db OW_RIGHT
	db OW_UP
	db OW_DOWN

_MovementSpinNextFacing:
	ld hl, OBJECT_DIRECTION
	add hl, bc
	ld a, [hl]
	and %00001100
	rrca
	rrca
	push hl
	ld l, a
	ld h, 0
	add hl, de
	ld a, [hl]
	pop hl
	ld [hl], a
	jmp ObjectMovement_DecAnonJumptableIndex

MovementFunction_Shadow:
	call InitMovementField1dField1e
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_SHADOW
	ld hl, OBJECT_STEP_DURATION
	add hl, de
	ld a, [hl]
	inc a
	add a
	add a
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_WALKING
	add hl, de
	ld a, [hl]
	maskbits NUM_DIRECTIONS
	ld d, 1 * TILE_WIDTH + 6
	cp DOWN
	jr z, .ok
	cp UP
	jr z, .ok
	ld d, 1 * TILE_WIDTH + 4
.ok
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], d
	ld hl, OBJECT_SPRITE_X_OFFSET
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_TRACKING_OBJECT
	ret

MovementFunction_Emote:
	call EndSpriteMovement
	call InitMovementField1dField1e
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_EMOTE
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], -2 * TILE_WIDTH
	ld hl, OBJECT_SPRITE_X_OFFSET
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_TRACKING_OBJECT
	ret

MovementFunction_BoulderDust:
	call EndSpriteMovement
	call InitMovementField1dField1e
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_BOULDER_DUST
	ld hl, OBJECT_STEP_DURATION
	add hl, de
	ld a, [hl]
	inc a
	add a
	add a
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_WALKING
	add hl, de
	ld a, [hl]
	and %00000011
	ld e, a
	ld d, 0
	ld hl, .dust_coords
	add hl, de
	add hl, de
	ld a, [hli]
	ld d, a
	ld e, [hl]
	ld hl, OBJECT_SPRITE_X_OFFSET
	add hl, bc
	ld [hl], d
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], e
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_TRACKING_OBJECT
	ret

.dust_coords:
	;   x,  y
	db  0, -4
	db  0,  8
	db  6,  2
	db -6,  2

MovementFunction_ShakingGrass:
	call EndSpriteMovement
	call InitMovementField1dField1e
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_GRASS_SHAKE
	ld hl, OBJECT_STEP_DURATION
	add hl, de
	ld a, [hl]
	add -1
	add a
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_TRACKING_OBJECT
	ret

MovementFunction_PokeballOpening:
	ld e, STEP_TYPE_POKEBALL_OPENING
	jr InitPokeballMovement

MovementFunction_PokeballClosing:
	ld e, STEP_TYPE_POKEBALL_CLOSING
InitPokeballMovement:
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], e
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 4
	ld hl, OBJECT_RANGE
	add hl, bc
	ld [hl], FOLLOWER
	; fallthrough

InitMovementField1dField1e:
	ld hl, OBJECT_RANGE
	add hl, bc
	ld a, [hl]
	push bc
	call GetObjectStruct
	ld d, b
	ld e, c
	pop bc
	ld hl, OBJECT_1D
	add hl, bc
	ld a, e
	ld [hli], a
	ld [hl], d ; OBJECT_1E
	ret

MovementFunction_ScreenShake:
	call EndSpriteMovement
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_00
	ld hl, OBJECT_RANGE
	add hl, bc
	ld a, [hl]
	call .GetDurationAndField1e
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], e
	ld hl, OBJECT_1E
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_SCREENSHAKE
	ret

.GetDurationAndField1e:
	ld d, a
	and %00111111
	ld e, a
	ld a, d
	rlca
	rlca
	and %00000011
	ld d, a
	inc d
	ld a, 1
.loop
	dec d
	ret z
	add a
	jr .loop

_RandomWalkContinue:
	call InitStep
	call CanObjectMoveInDirection
	jr c, .new_duration
	call UpdateTallGrassFlags
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_STEP
	ld hl, wCenteredObject
	ldh a, [hMapObjectIndex]
	cp [hl]
	jr z, .centered
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_CONTINUE_WALK
	ret

.centered
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_PLAYER_WALK
	ret

.new_duration:
	call EndSpriteMovement
	call CopyLastCoordsToCoords
	; fallthrough

RandomStepDuration_Slow:
	call Random
	ldh a, [hRandomAdd]
	and %11111110
	jr z, RandomStepDuration_Slow
	jr _SetRandomStepDuration

RandomStepDuration_Fast:
	call Random
	ldh a, [hRandomAdd]
	and %00111110
	jr z, RandomStepDuration_Fast
_SetRandomStepDuration:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_STAND
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_SLEEP
	ret

StepTypesJumptable:
; entries correspond to STEP_TYPE_* constants (see constants/map_object_constants.asm)
	table_width 2
	dw StepFunction_Reset           ; 00
	dw StepFunction_FromMovement    ; 01
	dw StepFunction_NPCWalk         ; 02
	dw StepFunction_Sleep           ; 03
	dw StepFunction_Standing        ; 04
	dw StepFunction_Restore         ; 05
	dw StepFunction_PlayerWalk      ; 06
	dw StepFunction_ContinueWalk    ; 07
	dw StepFunction_NPCJump         ; 08
	dw StepFunction_PlayerJump      ; 09
	dw StepFunction_Turn            ; 0a
	dw StepFunction_Bump            ; 0b
	dw StepFunction_TeleportFrom    ; 0c
	dw StepFunction_TeleportTo      ; 0d
	dw StepFunction_Skyfall         ; 0e
	dw StepFunction_StrengthBoulder ; 0f
	dw StepFunction_GotBite         ; 10
	dw StepFunction_RockSmash       ; 11
	dw StepFunction_DigTo           ; 12
	dw StepFunction_TrackingObject  ; 13
	dw StepFunction_14              ; 14
	dw StepFunction_ScreenShake     ; 15
	dw StepFunction_16              ; 16
	dw StepFunction_17              ; 17
	dw StepFunction_Delete          ; 18
	dw StepFunction_SkyfallTop      ; 19
	dw StepFunction_NPCJumpInPlace  ; 1a
	dw StepFunction_PokeballOpening ; 1b
	dw StepFunction_PokeballClosing ; 1c
	assert_table_length NUM_STEP_TYPES

WaitStep_InPlace:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_NPCJump:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .Jump
	dw .Land

.Jump:
	call AddStepVector
	call UpdateJumpPosition
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	call CopyCoordsTileToLastCoordsTile
	call GetNextTile
	ld hl, OBJECT_FLAGS2
	add hl, bc
	res OVERHEAD_F, [hl]
	jmp ObjectStep_IncAnonJumptableIndex

.Land:
	call AddStepVector
	call UpdateJumpPosition
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	call CopyCoordsTileToLastCoordsTile
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	xor a
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], a
	ret

StepFunction_PokeballOpening:
	ld de, .Frames
	call PokeballStep
	ret nz
; unless a script stowed it again meanwhile
	ld a, [wFollowerFlags]
	bit FOLLOWER_INVISIBLE_F, a
	call z, ShowFollower
	jmp DeleteMapObject

.Frames:
	db OW_LEFT, OW_UP, OW_DOWN ; closed, opening, open

StepFunction_PokeballClosing:
	ld de, .Frames
	call PokeballStep
	ret nz
	jmp DeleteMapObject

.Frames:
	db OW_DOWN, OW_UP, OW_LEFT ; open, closing, closed

PokeballStep:
; Show ball frame [de + step index] for 4 frames each over the follower.
; Return z after the last one.
	ld hl, OBJECT_STEP_INDEX
	add hl, bc
	ld a, [hl]
	add e
	ld e, a
	adc d
	sub e
	ld d, a
	ld a, [de]
	ld hl, OBJECT_DIRECTION
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_1D
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, OBJECT_SPRITE_X
	add hl, de
	ld a, [hli]
	ld e, [hl] ; OBJECT_SPRITE_Y
	ld hl, OBJECT_SPRITE_X
	add hl, bc
	ld [hli], a
	ld [hl], e ; OBJECT_SPRITE_Y
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld [hl], 4
	ld hl, OBJECT_STEP_INDEX
	add hl, bc
	inc [hl]
	ld a, [hl]
	cp 3
	ret

StepFunction_NPCJumpInPlace:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .Jump
	dw .Land

.Jump:
	call .Hop
	ret nz
	ld [hl], 4
	jmp ObjectStep_IncAnonJumptableIndex

.Land:
	call .Hop
	ret nz
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], 0
	ret

.Hop:
	ld h, 8
	call UpdateJumpPositionInPlace
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret

StepFunction_PlayerJump:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .initjump
	dw .stepjump
	dw .initland
	dw .stepland

.initjump
	ld hl, wPlayerStepFlags
	set PLAYERSTEP_START_F, [hl]
	call ObjectStep_IncAnonJumptableIndex
.stepjump
	call UpdateJumpPosition
	call UpdatePlayerStep
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	call CopyCoordsTileToLastCoordsTile
	ld hl, OBJECT_FLAGS2
	add hl, bc
	res OVERHEAD_F, [hl]
	ld hl, wPlayerStepFlags
	set PLAYERSTEP_STOP_F, [hl]
	set PLAYERSTEP_MIDAIR_F, [hl]
	jmp ObjectStep_IncAnonJumptableIndex

.initland
	ld a, FOLLOWERMOVE_STILL
	ld [wFollowerNextMovement], a
	call GetNextTile
	ld hl, wPlayerStepFlags
	set PLAYERSTEP_START_F, [hl]
	call ObjectStep_IncAnonJumptableIndex
.stepland
	call UpdateJumpPosition
	call UpdatePlayerStep
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld a, FOLLOWERMOVE_PREPARE_JUMP
	ld [wFollowerNextMovement], a
	ld hl, wPlayerStepFlags
	set PLAYERSTEP_STOP_F, [hl]
	call CopyCoordsTileToLastCoordsTile
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_TeleportFrom:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .InitSpin
	dw .DoSpin
	dw .InitSpinRise
	dw .DoSpinRise

.InitSpin:
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 32
	call ObjectStep_IncAnonJumptableIndex
.DoSpin:
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_SPIN
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	jmp ObjectStep_IncAnonJumptableIndex

.InitSpinRise:
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_JUMP_HEIGHT
	add hl, bc
	ld [hl], $10
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 16
	ld hl, OBJECT_FLAGS2
	add hl, bc
	res OVERHEAD_F, [hl]
	call ObjectStep_IncAnonJumptableIndex
.DoSpinRise:
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_SPIN
	ld hl, OBJECT_JUMP_HEIGHT
	add hl, bc
	inc [hl]
	ld a, [hl]
	ld d, $60
	farcall Sine
	ld a, h
	sub $60
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_TeleportTo:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .InitWait
	dw .DoWait
	dw .InitDescent
	dw .DoDescent
	dw .InitFinalSpin
	dw .DoFinalSpin
	dw .FinishStep

.InitWait:
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_00
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 32
	jmp ObjectStep_IncAnonJumptableIndex

.DoWait:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	call ObjectStep_IncAnonJumptableIndex
.InitDescent:
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_JUMP_HEIGHT
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 16
	jmp ObjectStep_IncAnonJumptableIndex

.DoDescent:
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_SPIN
	ld hl, OBJECT_JUMP_HEIGHT
	add hl, bc
	inc [hl]
	ld a, [hl]
	ld d, $60
	farcall Sine
	ld a, h
	sub $60
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	call ObjectStep_IncAnonJumptableIndex
.InitFinalSpin:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 32
	jmp ObjectStep_IncAnonJumptableIndex

.DoFinalSpin:
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_SPIN
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
.FinishStep:
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_Skyfall:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .Init
	dw .Step
	dw .Fall
	dw .Finish

.Init:
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_00
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 16
	call ObjectStep_IncAnonJumptableIndex
.Step:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_STEP
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_JUMP_HEIGHT
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 16
	call ObjectStep_IncAnonJumptableIndex
.Fall:
	ld hl, OBJECT_JUMP_HEIGHT
	add hl, bc
	inc [hl]
	ld a, [hl]
	ld d, $60
	farcall Sine
	ld a, h
	sub $60
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	call ObjectStep_IncAnonJumptableIndex
.Finish:
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_GotBite:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .Init
	dw .Run

.Init:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 8
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], 0
	call ObjectStep_IncAnonJumptableIndex
.Run:
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld a, [hl]
	xor 1
	ld [hl], a
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_RockSmash:
	call .Step
	jmp WaitStep_InPlace

.Step:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld a, [hl]
	and %00000001
	ld a, OBJECT_ACTION_STAND
	jr z, .yes
	ld a, OBJECT_ACTION_00
.yes
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], a
	ret

StepFunction_DigTo:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld a, [hl]
	and %00000001
	ld a, OBJECT_ACTION_SPIN
	jr z, .yes
	ld a, OBJECT_ACTION_SPIN_FLICKER
.yes
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], a
	jmp WaitStep_InPlace

StepFunction_Sleep:
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_Delete:
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	jmp DeleteMapObject

StepFunction_Bump:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_Restore:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .Reset
	dw StepFunction_Standing

.Reset:
	call RestoreDefaultMovement
	call GetInitialFacing
	ld hl, OBJECT_DIRECTION
	add hl, bc
	ld [hl], a
	call ObjectStep_IncAnonJumptableIndex
	; fallthrough

StepFunction_Standing:
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ret

StepFunction_NPCWalk:
	call AddStepVector
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	call CopyCoordsTileToLastCoordsTile
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_ContinueWalk:
	call AddStepVector
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	call CopyCoordsTileToLastCoordsTile
	jmp RandomStepDuration_Slow

StepFunction_PlayerWalk:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .init
	dw .step

.init
	ld hl, wPlayerStepFlags
	set PLAYERSTEP_START_F, [hl]
	call ObjectStep_IncAnonJumptableIndex
.step
	call UpdatePlayerStep
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld hl, wPlayerStepFlags
	set PLAYERSTEP_STOP_F, [hl]
	call CopyCoordsTileToLastCoordsTile
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_Turn:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .init1
	dw .step1
	dw .init2
	dw .step2

.init1
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld a, [hl]
	ld [hl], 4
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 4
	call ObjectStep_IncAnonJumptableIndex
.step1
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	call ObjectStep_IncAnonJumptableIndex
.init2
	ld hl, OBJECT_1D ; new facing
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_DIRECTION
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 4
	call ObjectStep_IncAnonJumptableIndex
.step2
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_StrengthBoulder:
	call AddStepVector
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	push bc
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld d, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld e, [hl]
	ld hl, OBJECT_MAP_OBJECT_INDEX
	add hl, bc
	ld a, [hl]
	ld b, a
	farcall CopyDECoordsToMapObject
	pop bc
	ld hl, OBJECT_FLAGS2
	add hl, bc
	res BOULDER_MOVING_F, [hl]
	call CopyCoordsTileToLastCoordsTile
	ld hl, OBJECT_WALKING
	add hl, bc
	ld [hl], STANDING
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

StepFunction_TrackingObject:
	ld hl, OBJECT_1D
	add hl, bc
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld hl, OBJECT_SPRITE
	add hl, de
	ld a, [hl]
	and a
	jr z, .nope
	ld hl, OBJECT_SPRITE_X
	add hl, de
	ld a, [hl]
	ld hl, OBJECT_SPRITE_X
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_SPRITE_Y
	add hl, de
	ld a, [hl]
	ld hl, OBJECT_SPRITE_Y
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld a, [hl]
	and a
	ret z
	dec [hl]
	dec [hl]
	ret nz
.nope
	jmp DeleteMapObject

StepFunction_14:
StepFunction_ScreenShake:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .Init
	dw .Run

.Init:
	; The hop fakes the camera's Y vector below, so weather must not compensate
	; for it or the particles jump with the player.
	ld hl, wWeatherFlags
	set OW_WEATHER_IGNORE_PLAYER_Y_F, [hl]
	xor a
	ld hl, OBJECT_1D
	add hl, bc
	ld [hl], a
	call ObjectStep_IncAnonJumptableIndex
.Run:
	ld hl, OBJECT_1D
	add hl, bc
	ld d, [hl]
	ld a, [wPlayerStepVectorY]
	sub d
	ld [wPlayerStepVectorY], a
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	jr z, .ok
	ld a, [hl]
	call .GetSign
	ld hl, OBJECT_1D
	add hl, bc
	ld [hl], a
	ld d, a
	ld a, [wPlayerStepVectorY]
	add d
	ld [wPlayerStepVectorY], a
	ret

.ok
	ld hl, wWeatherFlags
	res OW_WEATHER_IGNORE_PLAYER_Y_F, [hl]
	jmp DeleteMapObject

.GetSign:
	ld hl, OBJECT_1E
	add hl, bc
	and 1
	ld a, [hl]
	ret z
	cpl
	inc a
	ret

StepFunction_16:
	call ObjectStep_AnonJumptable
	; jumptable was dummied out here

StepFunction_17:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .null
	dw .null
	dw .null
.null

StepFunction_SkyfallTop:
	call ObjectStep_AnonJumptable
.anon_dw
	dw .Init
	dw .Run

.Init:
	ld hl, OBJECT_ACTION
	add hl, bc
	ld [hl], OBJECT_ACTION_SKYFALL
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	ld [hl], 16
	call ObjectStep_IncAnonJumptableIndex

.Run:
	ld hl, OBJECT_STEP_DURATION
	add hl, bc
	dec [hl]
	ret nz
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], $60
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld [hl], 0
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_FROM_MOVEMENT
	ret

UpdateJumpPosition:
	call GetStepVector
UpdateJumpPositionInPlace:
	ld a, h
	ld hl, OBJECT_JUMP_HEIGHT
	add hl, bc
	ld e, [hl]
	add e
	ld [hl], a
	srl e
	ld d, 0
	ld hl, .y_offsets
	add hl, de
	ld a, [hl]
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], a
	ret

.y_offsets:
	db -4, -5, -6, -7, -8, -9, -10, -11, -11, -12, -12, -12, -12, -12, -12, -12
	db -11, -11, -10, -10, -9, -9, -8, -7, -7, -6, -5, -5, -4, -2, -1, 0

GetPlayerNextMovementIndex:
; copy [wPlayerNextMovement] to [wPlayerMovement]
	ld a, [wPlayerNextMovement]
	ld hl, wPlayerMovement
	ld [hl], a
; load [wPlayerNextMovement] with movement_step_sleep
	ld a, movement_step_sleep
	ld [wPlayerNextMovement], a
; recover the previous value of [wPlayerNextMovement]
	ld a, [hl]
	ret

GetMovementIndex:
	ld hl, wMovementDataBank
	jmp _GetMovementIndex

GetIndexedMovementIndex1:
	ld hl, OBJECT_MOVEMENT_INDEX
	add hl, bc
	ld e, [hl]
	inc [hl]
	ld d, 0
	ld hl, wMovementObject
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
	ld a, [hl]
	ret

GetIndexedMovementIndex2:
	ld hl, OBJECT_MOVEMENT_INDEX
	add hl, bc
	ld e, [hl]
	inc [hl]
	ld d, 0
	ld hl, wIndexedMovement2Pointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
	ld a, [hl]
	ret

_GetMovementObject:
	ld hl, GetMovementObject
	jr HandleMovementData

GetMovementObject:
	ld a, [wMovementObject]
	ret

HandleMovementData:
	call .StorePointer
.loop
	xor a
	ld [wContinueReadingMovement], a
	call JumpMovementPointer
	call DoMovementFunction
	ld a, [wContinueReadingMovement]
	and a
	jr nz, .loop
	ret

.StorePointer:
	ld a, l
	ld [wMovementPointer], a
	ld a, h
	ld [wMovementPointer + 1], a
	ret

JumpMovementPointer:
	ld hl, wMovementPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

ContinueReadingMovement:
	ld a, TRUE
	ld [wContinueReadingMovement], a
	ret

DoMovementFunction:
	push af
	call ApplyMovementToFollower
	pop af
	ld hl, MovementPointers
	jmp JumpTable

INCLUDE "engine/overworld/movement.asm"

ApplyMovementToFollower:
	ld e, a
	ld a, [wObjectFollow_Follower]
	cp -1
	ret z
	ld a, [wObjectFollow_Leader]
	ld d, a
	ldh a, [hMapObjectIndex]
	cp d
	ret nz
	ld a, e
	cp movement_step_sleep
	ret z
	cp movement_step_end
	ret z
	cp movement_step_stop
	ret z
	cp movement_step_bump
	ret z
	cp movement_slow_step
	ret c
	push af
	ld hl, wFollowerMovementQueueLength
	inc [hl]
	ld e, [hl]
	ld d, 0
	ld hl, wFollowMovementQueue
	add hl, de
	pop af
	ld [hl], a
	ret

GetFollowerNextMovementIndex:
	ld hl, wFollowerMovementQueueLength
	ld a, [hl]
	and a
	jr z, .done
	cp -1
	jr z, .done
	dec [hl]
	ld e, a
	ld d, 0
	ld hl, wFollowMovementQueue
	add hl, de
	inc e
	ld a, -1
.loop
	ld d, [hl]
	ld [hld], a
	ld a, d
	dec e
	jr nz, .loop
	ret

.done
	call .CancelFollowIfLeaderMissing
	ret c
	ld a, movement_step_sleep
	ret

.CancelFollowIfLeaderMissing:
	ld a, [wObjectFollow_Leader]
	cp -1
	jr z, .nope
	push bc
	call GetObjectStruct
	ld hl, OBJECT_SPRITE
	add hl, bc
	ld a, [hl]
	pop bc
	and a
	jr z, .nope
	and a
	ret

.nope
	ld a, -1
	ld [wObjectFollow_Follower], a
	ld a, movement_step_end
	scf
	ret

SpawnShadow:
	push bc
	ld de, .ShadowObject
	call CopyTempObjectData
	call InitTempObject
	pop bc
	ret

.ShadowObject:
	; vtile, palette, movement
	db $80, PAL_OW_EMOTE_GRAY, SPRITEMOVEDATA_SHADOW

SpawnStrengthBoulderDust:
	push bc
	ld de, .BoulderDustObject
	call CopyTempObjectData
	call InitTempObject
	pop bc
	ret

.BoulderDustObject:
	; vtile, palette, movement
	db $80, PAL_OW_EMOTE_GRAY, SPRITEMOVEDATA_BOULDERDUST

SpawnEmote:
	push bc
	ld de, .EmoteObject
	call CopyTempObjectData
	call InitTempObject
	pop bc
	ret

.EmoteObject:
	; vtile, palette, movement
	db $80, PAL_OW_EMOTE_BLACK, SPRITEMOVEDATA_EMOTE

ShakeGrass:
	push bc
	ld de, .GrassObject
	call CopyTempObjectData
	call InitTempObject
	pop bc
	ret

.GrassObject:
	; vtile, palette, movement
	db $80, PAL_OW_COPY_BG_GREEN, SPRITEMOVEDATA_GRASS

ShakeScreen:
	push bc
	push af
	ld de, .ScreenShakeObject
	call CopyTempObjectData
	pop af
	ld [wTempObjectCopyRange], a
	call InitTempObject
	pop bc
	ret

.ScreenShakeObject:
	; vtile, palette, movement
	db $80, PAL_OW_EMOTE_GRAY, SPRITEMOVEDATA_SCREENSHAKE

DespawnEmote:
	push bc
	ldh a, [hMapObjectIndex]
	ld c, a
	call .DeleteEmote
	pop bc
	ret

.DeleteEmote:
	ld de, wObjectStructs
	ld a, NUM_OBJECT_STRUCTS
.loop
	push af
	ld hl, OBJECT_FLAGS1
	add hl, de
	bit EMOTE_OBJECT_F, [hl]
	jr z, .next
	ld hl, OBJECT_SPRITE
	add hl, de
	ld a, [hl]
	and a
	jr z, .next
	push bc
	xor a
	ld bc, OBJECT_LENGTH
	rst ByteFill
	pop bc
.next
	ld hl, OBJECT_LENGTH
	add hl, de
	ld d, h
	ld e, l
	pop af
	dec a
	jr nz, .loop
	ret

InitTempObject:
	call FindFirstEmptyObjectStruct
	ret nc
	ld d, h
	ld e, l
	farjp CopyTempObjectToObjectStruct

CopyTempObjectData:
; load into wTempObjectCopy:
; -1, -1, [de], [de + 1], [de + 2], [hMapObjectIndex], [NextMapX], [NextMapY], -1
; This spawns the object at the same place as whichever object is loaded into bc.
	ld hl, wTempObjectCopyMapObjectIndex
	ld a, -1
	ld [hli], a
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	ld [hli], a
	ldh a, [hMapObjectIndex]
	ld [hli], a
	push hl
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld d, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld e, [hl]
	pop hl
	ld a, d
	ld [hli], a
	ld a, e
	ld [hli], a
	ld [hl], -1
	ret

UpdateAllObjectsFrozen::
	ld a, [wStateFlags]
	bit SPRITE_UPDATES_DISABLED_F, a
	ret z
	ld bc, wObjectStructs
	xor a
.loop
	ldh [hMapObjectIndex], a
	call DoesObjectHaveASprite
	call nz, UpdateObjectFrozen
	ld hl, OBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	ldh a, [hMapObjectIndex]
	inc a
	cp NUM_OBJECT_STRUCTS
	jr nz, .loop
	ret

RespawnPlayerAndOpponent:
; called at battle start
	call HideAllObjects
	ld a, PLAYER
	call RespawnObject
	ld a, [wBattleScriptFlags]
	bit BATTLESCRIPT_SCRIPTED_F, a
	jr z, .skip_opponent
	ldh a, [hLastTalked]
	and a
	call nz, RespawnObject
; fallthrough
.skip_opponent
	jmp _UpdateSprites

RespawnPlayer:
	call HideAllObjects
	ld a, PLAYER
	call RespawnObject
	jmp _UpdateSprites

RespawnObject:
	cp NUM_OBJECTS
	ret nc
	call GetMapObject
	ld hl, MAPOBJECT_OBJECT_STRUCT_ID
	add hl, bc
	ld a, [hl]
	cp -1
	ret z
	cp NUM_OBJECT_STRUCTS
	ret nc
	call GetObjectStruct
	call DoesObjectHaveASprite
	ret z
	jr UpdateRespawnedObjectFrozen

HideAllObjects:
	xor a
	ld bc, wObjectStructs
.loop
	ldh [hMapObjectIndex], a
	call SetFacing_Standing
	ld hl, OBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	ldh a, [hMapObjectIndex]
	inc a
	cp NUM_OBJECT_STRUCTS
	jr nz, .loop
	ret

UpdateObjectFrozen:
	push bc
	call CheckObjectCoveredByTextbox
	pop bc
	jr c, SetFacing_Standing
	call CheckObjectOnScreen
	jr c, SetFacing_Standing
	call UpdateObjectTile
	call HandleFrozenObjectAction
	xor a
	ret

UpdateRespawnedObjectFrozen:
	call CheckObjectOnScreen
	jr c, SetFacing_Standing
	call HandleFrozenObjectAction
	xor a
	ret

SetFacing_Standing:
	ld hl, OBJECT_FACING
	add hl, bc
	ld [hl], STANDING
	scf
	ret

UpdateObjectTile:
	push bc
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld d, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld e, [hl]
	call GetCoordTileCollision
	pop bc
	ld hl, OBJECT_TILE_COLLISION
	add hl, bc
	ld [hl], a
	jmp UpdateTallGrassFlags

CheckObjectOnScreen:
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld d, [hl]
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld e, [hl]
	inc d
	inc e
	ld a, [wXCoord]
	cp d
	jr z, .equal_x
	jr nc, .nope
	add MAPOBJECT_SCREEN_WIDTH - 1
	cp d
	jr c, .nope
.equal_x
	ld a, [wYCoord]
	cp e
	jr z, .equal_y
	jr nc, .nope
	add MAPOBJECT_SCREEN_HEIGHT - 1
	cp e
	jr c, .nope
.equal_y
	xor a
	ret

.nope
	scf
	ret

CheckObjectCoveredByTextbox:
; Check whether the object fits in the screen width.
	ld a, [wPlayerBGMapOffsetX]
	ld d, a
	ld hl, OBJECT_SPRITE_X_OFFSET
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_SPRITE_X
	add hl, bc
	add [hl]
	add d
	cp $f0
	jr nc, .ok1
	cp SCREEN_WIDTH_PX
	jmp nc, .nope
.ok1
; Account for objects currently moving left/right.
	and %00000111
	ld d, 2
	cp TILE_WIDTH / 2
	jr c, .ok2
	ld d, 3
.ok2
; Convert pixels to tiles.
	ld a, [hl]
	rrca
	rrca
	rrca
	and %00011111
	cp SCREEN_WIDTH
	jr c, .ok3
	sub TILEMAP_WIDTH
.ok3
	ldh [hCurSpriteXCoord], a

; Check whether the object fits in the screen height.
	ld a, [wPlayerBGMapOffsetY]
	ld e, a
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_SPRITE_Y
	add hl, bc
	add [hl]
	add e
	cp $f0
	jr nc, .ok4
	cp SCREEN_HEIGHT_PX
	jr nc, .nope
.ok4
; Account for objects currently moving up/down.
	and %00000111
	ld e, 2
	cp TILE_WIDTH / 2
	jr c, .ok5
	ld e, 3
.ok5
; Convert pixels to tiles.
	ld a, [hl]
	rrca
	rrca
	rrca
	and %00011111
	cp SCREEN_HEIGHT
	jr c, .ok6
	sub TILEMAP_HEIGHT
.ok6
	ldh [hCurSpriteYCoord], a

; Account for big objects that are twice as wide and high.
	ld hl, OBJECT_PALETTE
	add hl, bc
	bit BIG_OBJECT_F, [hl]
	jr z, .ok7
	ld a, d
	add 2
	ld d, a
	ld a, e
	add 2
	ld e, a
.ok7
	ld a, d
	ldh [hCurSpriteXPixel], a

.loop
	ldh a, [hCurSpriteXPixel]
	ld d, a
	ldh a, [hCurSpriteYCoord]
	add e
	dec a
	cp SCREEN_HEIGHT
	jr nc, .ok9
	ld b, a
.next
	ldh a, [hCurSpriteXCoord]
	add d
	dec a
	cp SCREEN_WIDTH
	jr nc, .ok8
	ld c, a
	push bc
	call Coord2Tile
	pop bc
; NPCs disappear if standing on tile $7f or $ff,
; since those IDs are for text characters and textbox frames.
	ld a, [hl]
	cp FIRST_REGULAR_TEXT_CHAR
	jr nc, .nope
.ok8
	dec d
	jr nz, .next
.ok9
	dec e
	jr nz, .loop

	and a
	ret

.nope
	scf
	ret

HandleNPCStep::
	call .ResetStepVector
	ld bc, wObjectStructs
	xor a
.loop
	ldh [hMapObjectIndex], a
	call DoesObjectHaveASprite
	call nz, HandleObjectStep
	ld hl, OBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	ldh a, [hMapObjectIndex]
	inc a
	cp NUM_OBJECT_STRUCTS
	jr nz, .loop
	ret

.ResetStepVector
	xor a
	ld [wPlayerStepVectorX], a
	ld [wPlayerStepVectorY], a
	ld a, [wPlayerStepFlags]
	bit 6, a
	ld a, $0 ; no-optimize a = 0
	ld [wPlayerStepFlags], a
	ret nz
	dec a
	ld [wPlayerStepDirection], a
	ret

RefreshPlayerSprite:
	ld a, movement_step_sleep
	ld [wPlayerNextMovement], a
	ld [wPlayerMovement], a
	xor a
	ld [wPlayerTurningDirection], a
	ld [wPlayerStepFrame], a
	call TryResetPlayerAction
	farcall CheckWarpFacingDown
	call c, SpawnInFacingDown
	jr SpawnInCustomFacing

TryResetPlayerAction:
	ld hl, wPlayerSpriteSetupFlags
	bit PLAYERSPRITESETUP_RESET_ACTION_F, [hl]
	ret z
	xor a ; OBJECT_ACTION_00
	ld [wPlayerAction], a
	ret

SpawnInCustomFacing:
	ld hl, wPlayerSpriteSetupFlags
	bit PLAYERSPRITESETUP_CUSTOM_FACING_F, [hl]
	ret z
	ld a, [wPlayerSpriteSetupFlags]
	and PLAYERSPRITESETUP_FACING_MASK
	add a
	add a
	jr _ContinueSpawnFacing

SpawnInFacingDown:
	xor a ; DOWN
_ContinueSpawnFacing:
	push af
	ld bc, wPlayerStruct
	call SetSpriteDirection
	pop af
	ld bc, wObject1Struct
	jmp SetSpriteDirection

StartFollow::
	push bc
	ld a, b
	call SetLeaderIfVisible
	pop bc
	ret c
	ld a, c
	call SetFollowerIfVisible
	farjp QueueFollowerFirstStep

SetLeaderIfVisible:
	call CheckObjectVisibility
	ret c
	ldh a, [hObjectStructIndex]
	ld [wObjectFollow_Leader], a
	ret

StopFollow::
	call ResetLeader
	jr ResetFollower

ResetLeader:
	ld a, -1
	ld [wObjectFollow_Leader], a
	ret

SetFollowerIfVisible:
	push af
	call ResetFollower
	pop af
	call CheckObjectVisibility
	ret c
	ld hl, OBJECT_MOVEMENT_TYPE
	add hl, bc
	ld [hl], SPRITEMOVEDATA_FOLLOWING
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_RESET
	ldh a, [hObjectStructIndex]
	ld [wObjectFollow_Follower], a
	ret

ResetFollower:
	ld a, [wObjectFollow_Follower]
	cp -1
	ret z
	call GetObjectStruct
	call ResetObject
	ld a, -1
	ld [wObjectFollow_Follower], a
	ret

FreezeAllOtherObjects::
	ld a, c
	call CheckObjectVisibility
	ret c
	push bc
	call FreezeAllObjects
	pop bc
	ld hl, OBJECT_FLAGS2
	add hl, bc
	res FROZEN_F, [hl]
	xor a
	ret


FreezeAllObjects:
	ld bc, wObjectStructs
	xor a
.loop
	push af
	call DoesObjectHaveASprite
	jr z, .next
	ld hl, OBJECT_FLAGS2
	add hl, bc
	set FROZEN_F, [hl]
.next
	ld hl, OBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	pop af
	inc a
	cp NUM_OBJECT_STRUCTS
	jr nz, .loop
; the follower keeps following during scripts unless a script froze it
	ld a, [wFollowerFlags]
	bit FOLLOWER_FROZEN_F, a
	ret nz
	ld a, [wObject1MovementType]
	cp SPRITEMOVEDATA_FOLLOWEROBJ
	ret nz
	ld hl, wObject1Struct + OBJECT_FLAGS2
	res FROZEN_F, [hl]
	ret

_UnfreezeFollowerObject::
	ld a, [wObjectFollow_Leader]
	cp -1
	ret z
	push bc
	call GetObjectStruct
	ld hl, OBJECT_MAP_OBJECT_INDEX
	add hl, bc
	ld a, [hl]
	pop bc
	cp c
	ret nz
	ld a, [wObjectFollow_Follower]
	cp -1
	ret z
	call GetObjectStruct
	ld hl, OBJECT_FLAGS2
	add hl, bc
	res FROZEN_F, [hl]
	ret

UnfreezeAllObjects::
	push bc
	ld bc, wObjectStructs
	xor a
.loop
	push af
	call DoesObjectHaveASprite
	jr z, .next
	ld hl, OBJECT_FLAGS2
	add hl, bc
	res FROZEN_F, [hl]
.next
	ld hl, OBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	pop af
	inc a
	cp NUM_OBJECT_STRUCTS
	jr nz, .loop
	pop bc
	ret


ResetObject::
	ld hl, OBJECT_MAP_OBJECT_INDEX
	add hl, bc
	ld a, [hl]
	cp -1
	jr z, .set_standing
	push bc
	call GetMapObject
	ld hl, MAPOBJECT_MOVEMENT
	add hl, bc
	ld a, [hl]
	pop bc
	ld hl, OBJECT_MOVEMENT_TYPE
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_RESET
	ret

.set_standing:
	call GetSpriteDirection
	rrca
	rrca
	ld e, a
	ld d, 0
	ld hl, .standing_movefns
	add hl, de
	ld a, [hl]
	ld hl, OBJECT_MOVEMENT_TYPE
	add hl, bc
	ld [hl], a
	ld hl, OBJECT_STEP_TYPE
	add hl, bc
	ld [hl], STEP_TYPE_RESET
	ret

.standing_movefns:
	db SPRITEMOVEDATA_STANDING_DOWN
	db SPRITEMOVEDATA_STANDING_UP
	db SPRITEMOVEDATA_STANDING_LEFT
	db SPRITEMOVEDATA_STANDING_RIGHT

_UpdateSprites::
	ld a, [wStateFlags]
	bit SPRITE_UPDATES_DISABLED_F, a
	ret z
	; Start above the structs overworld weather holds, so its particles keep the
	; low OAM indexes and draw over map objects rather than behind them.
	bit FIRST_12_SPRITE_OAM_STRUCTS_RESERVED_F, a
	ld a, NUM_WEATHER_OAM_STRUCTS * OBJ_SIZE
	jr nz, .got_oam_start
	xor a
.got_oam_start
	ldh [hUsedSpriteIndex], a
	ldh a, [hOAMUpdate]
	push af
	ld a, 1
	ldh [hOAMUpdate], a
	call InitSprites
	call .fill
	pop af
	ldh [hOAMUpdate], a
	ret

.fill
	ld a, [wStateFlags]
	bit LAST_12_SPRITE_OAM_STRUCTS_RESERVED_F, a
	ld b, OAM_SIZE
	jr z, .ok
	ld b, (OAM_COUNT - 12) * OBJ_SIZE
.ok
	ldh a, [hUsedSpriteIndex]
	cp b
	ret nc
	ld l, a
	ld h, HIGH(wShadowOAM)
	ld de, OBJ_SIZE
	ld a, b
	ld c, OAM_YCOORD_HIDDEN
.loop
	ld [hl], c ; y
	add hl, de
	cp l
	jr nz, .loop
	ret

ApplyBGMapAnchorToObjects::
	push hl
	push de
	push bc
	ld a, [wPlayerBGMapOffsetX]
	ld d, a
	ld a, [wPlayerBGMapOffsetY]
	ld e, a
	ld bc, wObjectStructs
	ld a, NUM_OBJECT_STRUCTS
.loop
	push af
	call DoesObjectHaveASprite
	jr z, .skip
	ld hl, OBJECT_SPRITE_X
	add hl, bc
	ld a, [hl]
	add d
	ld [hl], a
	ld hl, OBJECT_SPRITE_Y
	add hl, bc
	ld a, [hl]
	add e
	ld [hl], a
.skip
	ld hl, OBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	pop af
	dec a
	jr nz, .loop
	xor a
	ld [wPlayerBGMapOffsetX], a
	ld [wPlayerBGMapOffsetY], a
	jmp PopBCDEHL

DEF PRIORITY_LOW  EQU $10
DEF PRIORITY_NORM EQU $20
DEF PRIORITY_HIGH EQU $30

InitSprites:
	call .DeterminePriorities
	ld c, PRIORITY_HIGH
	call .InitSpritesByPriority
	ld c, PRIORITY_NORM
	call .InitSpritesByPriority
	ld c, PRIORITY_LOW
	jr .InitSpritesByPriority

.DeterminePriorities:
	xor a
	ld hl, wObjectPriorities
	ld bc, NUM_OBJECT_STRUCTS
	rst ByteFill
	ld d, 0
	ld bc, wObjectStructs
	ld hl, wObjectPriorities
.loop
	push hl
	call DoesObjectHaveASprite
	jr z, .skip
	ld hl, OBJECT_FACING
	add hl, bc
	ld a, [hl]
	cp STANDING
	jr z, .skip
; Define the sprite priority.
	ld e, PRIORITY_LOW
	ld hl, OBJECT_FLAGS2
	add hl, bc
	bit LOW_PRIORITY_F, [hl]
	jr nz, .add
	ld e, PRIORITY_NORM
	bit HIGH_PRIORITY_F, [hl]
	jr z, .add
	ld e, PRIORITY_HIGH
	jr .add

.skip
	ld hl, OBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	pop hl
	jr .next

.add
	ld hl, OBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	pop hl
	ld a, d
	or e
	ld [hli], a
.next
	inc d
	ld a, d
	cp NUM_OBJECT_STRUCTS
	jr nz, .loop
	ret

.InitSpritesByPriority:
	ld hl, wObjectPriorities
.next_sprite
	ld a, [hli]
	ld d, a
	and $f0
	ret z
	cp c
	jr nz, .next_sprite
	push bc
	push hl
	ld a, d
	and $f
	call .GetObjectStructPointer
	call .InitSprite
	pop hl
	pop bc
	jr .next_sprite

.InitSprite:
	ld hl, OBJECT_SPRITE_TILE
	add hl, bc
	ld a, [hl]
	and ~(1 << 7)
	ldh [hCurSpriteTile], a
	xor a
	bit 7, [hl] ; tiles $80+ are in VRAM bank 0
	jr nz, .not_vram1
	or OAM_BANK1
.not_vram1
	ld hl, OBJECT_FLAGS2
	add hl, bc
	ld e, [hl]
	bit OBJ_FLAGS2_7_F, e
	jr z, .not_priority
	or OAM_PRIO
.not_priority
	bit USE_OBP1_F, e
	jr z, .not_obp_num
	or OAM_PAL1
.not_obp_num
	ld hl, OBJECT_PALETTE
	add hl, bc
	ld d, a
	ld a, [hl]
	and OAM_PALETTE
	or d
	ld d, a
	xor a
	bit OVERHEAD_F, e
	jr z, .not_overhead
	or OAM_PRIO
.not_overhead
	ldh [hCurSpriteOAMFlags], a
	ld hl, OBJECT_SPRITE_X
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_SPRITE_X_OFFSET
	add hl, bc
	add [hl]
	add 8
	ld e, a
	ld a, [wPlayerBGMapOffsetX]
	add e
	ldh [hCurSpriteXPixel], a
	ld hl, OBJECT_SPRITE_Y
	add hl, bc
	ld a, [hl]
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	add [hl]
	add 12
	ld e, a
	ld a, [wPlayerBGMapOffsetY]
	add e
	ldh [hCurSpriteYPixel], a
	ld hl, OBJECT_FACING
	add hl, bc
	ld a, [hl]
	cp STANDING
	jr z, .done
	cp NUM_FACINGS
	jr nc, .done
	ld l, a
	ld h, 0
	add hl, hl
	ld bc, Facings
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ldh a, [hUsedSpriteIndex]
	ld c, a
	ld b, HIGH(wShadowOAM)
	ld a, [hli]
	ldh [hUsedSpriteTile], a
	add c
	cp LOW(wShadowOAMEnd)
	jr nc, .full
.addsprite
	ldh a, [hCurSpriteYPixel]
	add [hl]
	inc hl
	ld [bc], a ; y
	inc c
	ldh a, [hCurSpriteXPixel]
	add [hl]
	inc hl
	ld [bc], a ; x
	inc c
	ld a, [hli]
	ld e, a
	ldh a, [hCurSpriteTile]
	bit ABSOLUTE_TILE_ID_F, e
	jr z, .nope1
	xor a
.nope1
	add [hl]
	inc hl
	ld [bc], a ; tile id
	ld a, d
	and OAM_BANK1
	jr z, .vram0
	ld a, [bc]
	cp $80
	jr c, .standing
	sub $40
	ld [bc], a
.standing
.vram0
	inc c
	ld a, e
	bit RELATIVE_ATTRIBUTES_F, a
	jr z, .nope2
	ldh a, [hCurSpriteOAMFlags]
	or e
.nope2
	and OAM_PAL1 | OAM_XFLIP | OAM_YFLIP | OAM_PRIO
	or d
	ld [bc], a ; attributes
	inc c
	ldh a, [hUsedSpriteTile]
	dec a
	ldh [hUsedSpriteTile], a
	jr nz, .addsprite
	ld a, c
	ldh [hUsedSpriteIndex], a
.done
	xor a
	ret

.full
	scf
	ret

.GetObjectStructPointer:
	ld c, a
	ld b, 0
	ld hl, .Addresses
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ret

.Addresses:
	dw wPlayerStruct
	dw wObject1Struct
	dw wObject2Struct
	dw wObject3Struct
	dw wObject4Struct
	dw wObject5Struct
	dw wObject6Struct
	dw wObject7Struct
	dw wObject8Struct
	dw wObject9Struct
	dw wObject10Struct
	dw wObject11Struct
	dw wObject12Struct

; item ids
; indexes for:
; - ItemNames (see data/items/names.asm)
; - ItemDescriptions (see data/items/descriptions.asm)
; - ItemAttributes (see data/items/attributes.asm)
; - ItemEffects (see engine/items/item_effects.asm)
	const_def
	const NO_ITEM      ; 0000
	const POTION       ; 0001
	const SUPER_POTION ; 0002
	const HYPER_POTION ; 0003
	const MAX_POTION   ; 0004

	const ANTIDOTE     ; 0005
	const BURN_HEAL    ; 0006
	const PARLYZ_HEAL  ; 0007
	const AWAKENING    ; 0008
	const ICE_HEAL     ; 0009
	const FULL_HEAL    ; 000A
	const FULL_RESTORE ; 000B

	const REVIVE       ; 000C
	const MAX_REVIVE   ; 000D

	const ETHER        ; 000E
	const MAX_ETHER    ; 000F
	const ELIXER       ; 0010
	const MAX_ELIXER   ; 0011

	const HP_UP        ; 0012
	const PROTEIN      ; 0013
	const IRON         ; 0014
	const CARBOS       ; 0015
	const CALCIUM      ; 0016
	const ZINC         ; 0017
	const RARE_CANDY   ; 0018
	const PP_UP        ; 0019

	const FRESH_WATER  ; 001A
	const SODA_POP     ; 001B
	const LEMONADE     ; 001C
	const MOOMOO_MILK  ; 001D
	const RAGECANDYBAR ; 001E

	const ENERGYPOWDER ; 001F
	const ENERGY_ROOT  ; 0020
	const HEAL_POWDER  ; 0021
	const REVIVAL_HERB ; 0022

	const SACRED_ASH   ; 0023
	const MYSTIC_DEW   ; 0024

	const BERRY_JUICE  ; 0025

	const REPEL        ; 0026
	const SUPER_REPEL  ; 0027
	const MAX_REPEL    ; 0028

	const ESCAPE_ROPE  ; 0029
	const POKE_DOLL    ; 002A

	const X_ATTACK     ; 002B
	const X_DEFEND     ; 002C
	const X_SPEED      ; 002D
	const X_SP_ATK     ; 002E
	const X_SP_DEF     ; 002F
	const X_ACCURACY   ; 0030
	const GUARD_SPEC   ; 0031
	const DIRE_HIT     ; 0032

	const LEAF_STONE   ; 0033
	const FIRE_STONE   ; 0034
	const WATER_STONE  ; 0035
	const THUNDERSTONE ; 0036
	const MOON_STONE   ; 0037
	const SUN_STONE    ; 0038
	const MIST_STONE   ; 0039

	const EXP_SHARE    ; 003A
	const LUCKY_EGG    ; 003B

	const MIRACLE_SEED ; 003C
	const SILVERPOWDER ; 003D
	const POISON_BARB  ; 003E
	const CHARCOAL     ; 003F
	const MYSTIC_WATER ; 0040
	const NEVERMELTICE ; 0041
	const MAGNET       ; 0042
	const BLACKBELT_I  ; 0043
	const HARD_STONE   ; 0044
	const SOFT_SAND    ; 0045
	const TWISTEDSPOON ; 0046
	const PINK_BOW     ; 0047
	const POLKADOT_BOW ; 0048
	const SHARP_BEAK   ; 0049
	const SPELL_TAG    ; 004A
	const BLACKGLASSES ; 004B
	const DRAGON_FANG  ; 004C
	const IRON_PLATE   ; 004D

	const BERSERK_GENE ; 004E
 	const BRIGHTPOWDER ; 004F
	const QUICK_CLAW   ; 0050
	const KINGS_ROCK   ; 0051
	const AMULET_COIN  ; 0052
	const CLEANSE_TAG  ; 0053
	const SMOKE_BALL   ; 0054
	const FOCUS_BAND   ; 0055
	const LEFTOVERS    ; 0056
	const SCOPE_LENS   ; 0057

	const LIGHT_BALL   ; 0058
	const STICK        ; 0059
	const THICK_CLUB   ; 005A
	const LUCKY_PUNCH  ; 005B
	const METAL_POWDER ; 005C

	const DRAGON_SCALE ; 005D
	const METAL_COAT   ; 005E
	const UP_GRADE     ; 005F
	const RAZOR_CLAW   ; 0060
	const DUBIOUS_DISC ; 0061
	const PROTECTOR    ; 0062

	const SILVER_LEAF  ; 0063
	const GOLD_LEAF    ; 0064

	const NUGGET       ; 0065
	const TINYMUSHROOM ; 0066
	const BIG_MUSHROOM ; 0067
	const PEARL        ; 0068
	const BIG_PEARL    ; 0069
	const STARDUST     ; 006A
	const STAR_PIECE   ; 006B
	const BRICK_PIECE  ; 006C
	const SLOWPOKETAIL ; 006D

	const NORMAL_BOX   ; 006E
	const GORGEOUS_BOX ; 006F

	const FLOWER_MAIL  ; 0070
	const SURF_MAIL    ; 0071
	const LITEBLUEMAIL ; 0072
	const PORTRAITMAIL ; 0073
	const LOVELY_MAIL  ; 0074
	const EON_MAIL     ; 0075
	const MORPH_MAIL   ; 0076
	const BLUESKY_MAIL ; 0077
	const MUSIC_MAIL   ; 0078
	const MIRAGE_MAIL  ; 0079

	const POISON_GUARD ; 007A
	const BURN_GUARD   ; 007B
	const FREEZE_GUARD ; 007C
	const SLEEP_GUARD  ; 007D
	const PARLYZ_GUARD ; 007E
	const CONFUSEGUARD ; 007F

	const DAMP_ROCK    ; 0080
	const HEAT_ROCK    ; 0081
	const SMOOTH_ROCK  ; 0082
	const ICY_ROCK     ; 0083

	const LIGHT_CLAY   ; 0084
	const GRIP_CLAW    ; 0085

	const SAFARI_LURE  ; 0086

	const RADIANCE_ORB ; 0087
	const UNOWN_AURA   ; 0088

	const MAGNA_PLANT  ; 0089
	const TROPIC_PLANT ; 008A
	const JUMBO_PLANT  ; 008B

	const PINKBED      ; 008C
	const POLKADOTBED  ; 008D
	const PIKACHUBED   ; 008E

	const NES          ; 008F
	const N64          ; 0090
	const VIRTUALBOY   ; 0091
	const FCOM         ; 0092

	const REDCARPET    ; 0093
	const BLUECARPET   ; 0094
	const YELLOWCARPET ; 0095
	const GREENCARPET  ; 0096

	const PIKACHU_POSTER    ; 0097
	const CLEFAIRY_POSTER   ; 0098
	const JIGGLYPUFF_POSTER ; 0099

DEF NUM_ITEM_POCKET EQU const_value - 1

	const_align 8 ; Key items assume the value of HIGH(FIRST_KEY_ITEM) when storing in bag.
DEF FIRST_KEY_ITEM EQU const_value
	const BICYCLE      ; 0100
	const COIN_CASE    ; 0101
	const ITEMFINDER   ; 0102
	const OLD_ROD      ; 0103
	const GOOD_ROD     ; 0104
	const SUPER_ROD    ; 0105
	const RED_SCALE    ; 0106
	const SECRETPOTION ; 0107
	const S_S_TICKET   ; 0108
	const MYSTERY_EGG  ; 0109
	const CLEAR_BELL   ; 010A
	const SILVER_WING  ; 010B
	const GS_BALL      ; 010C
	const BLUE_CARD    ; 010D
	const CARD_KEY     ; 010E
	const MACHINE_PART ; 010F
	const MACHETE      ; 0110
	const LOST_ITEM    ; 0111
	const BASEMENT_KEY ; 0112
	const PASS         ; 0113
	const SQUIRTBOTTLE ; 0114
	const RAINBOW_WING ; 0115
	const POKE_FLUTE   ; 0116
	const JACKHAMMER   ; 0117
	const ORANGE_PASS  ; 0118
DEF NUM_KEY_ITEM_POCKET EQU const_value - FIRST_KEY_ITEM
assert NUM_KEY_ITEM_POCKET <= $ff

	const_align 8; Ball items assume the value of HIGH(FIRST_BALL_ITEM) when storing in bag.
DEF FIRST_BALL_ITEM EQU const_value
	const MASTER_BALL  ; 0200
	const ULTRA_BALL   ; 0201
	const GREAT_BALL   ; 0202
	const POKE_BALL    ; 0203
	const HEAVY_BALL   ; 0204
	const LEVEL_BALL   ; 0205
	const LURE_BALL    ; 0206
	const FAST_BALL    ; 0207
	const FRIEND_BALL  ; 0208
	const MOON_BALL    ; 0209
	const LOVE_BALL    ; 020A
	const PARK_BALL    ; 020B
DEF NUM_BALL_ITEM_POCKET EQU const_value - FIRST_BALL_ITEM
assert NUM_BALL_ITEM_POCKET <= $ff

	const_align 8; Berries items assume the value of HIGH(FIRST_BERRY_ITEM) when storing in bag.
DEF FIRST_BERRY_ITEM EQU const_value
	const BERRY        ; 0300
	const GOLD_BERRY   ; 0301
	const MYSTERYBERRY ; 0302
	const MIRACLEBERRY ; 0303
	const PSNCUREBERRY ; 0304
	const PRZCUREBERRY ; 0305
	const BURNT_BERRY  ; 0306
	const ICE_BERRY    ; 0307
	const BITTER_BERRY ; 0308
	const MINT_BERRY   ; 0309

	const ATK_UP_BERRY ; 030A
	const DEF_UP_BERRY ; 030B
	const SPD_UP_BERRY ; 030C
	const SPA_UP_BERRY ; 030D
	const SPF_UP_BERRY ; 030E
	const ACC_UP_BERRY ; 030F
	const EVN_UP_BERRY ; 0310

	const WHT_APRICORN ; 0311
	const RED_APRICORN ; 0312
	const BLU_APRICORN ; 0313
	const BLK_APRICORN ; 0314
	const YLW_APRICORN ; 0315
	const GRN_APRICORN ; 0316
	const PNK_APRICORN ; 0317
DEF NUM_BERRY_ITEM_POCKET EQU const_value - FIRST_BERRY_ITEM
assert NUM_BERRY_ITEM_POCKET <= $ff
DEF NUM_ITEMS EQU const_value - 1

DEF __tmhm_value__ = 1

MACRO add_tmnum
	DEF \1_TMNUM EQU __tmhm_value__
	DEF __tmhm_value__ += 1
ENDM

MACRO add_tm
; Defines three constants:
; - TM_\1: the item id, starting at $bf
; - \1_TMNUM: the learnable TM/HM flag, starting at 1
; - TM##_MOVE: alias for the move id, equal to the value of \1
	const TM_\1
	DEF TM{02d:__tmhm_value__}_MOVE = \1
	add_tmnum \1
ENDM

	const_align 8 ; TMHM items assume the value of HIGH(FIRST_TMHM_ITEM) when storing in bag.
DEF FIRST_TMHM_ITEM EQU const_value
; see data/moves/tmhm_moves.asm for moves
DEF TM01 EQU const_value
	add_tm DYNAMICPUNCH ; 0400
	add_tm HEADBUTT     ; 0401
	add_tm CURSE        ; 0402
	add_tm ROLLOUT      ; 0403
	add_tm ROAR         ; 0404
	add_tm TOXIC        ; 0405
	add_tm ZAP_CANNON   ; 0406
	add_tm PURSUIT      ; 0407
	add_tm PSYCH_UP     ; 0408
	add_tm HIDDEN_POWER ; 0409
	add_tm SUNNY_DAY    ; 040A
	add_tm SWEET_SCENT  ; 040B
	add_tm SWEET_KISS   ; 040C
	add_tm BLIZZARD     ; 040D
	add_tm HYPER_BEAM   ; 040E
	add_tm ICY_WIND     ; 040F
	add_tm PROTECT      ; 0410
	add_tm RAIN_DANCE   ; 0411
	add_tm GIGA_DRAIN   ; 0412
	add_tm ENDURE       ; 0413
	add_tm PAIN_SPLIT   ; 0414
	add_tm SOLARBEAM    ; 0415
	add_tm IRON_TAIL    ; 0416
	add_tm DRAGONBREATH ; 0417
	add_tm THUNDER      ; 0418
	add_tm EARTHQUAKE   ; 0419
	add_tm RETURN       ; 041A
	add_tm DIG          ; 041B
	add_tm PSYCHIC_M    ; 041C
	add_tm SHADOW_BALL  ; 041D
	add_tm MUD_SLAP     ; 041E
	add_tm DOUBLE_TEAM  ; 041F
	add_tm ICE_PUNCH    ; 0420
	add_tm SWAGGER      ; 0421
	add_tm SLEEP_TALK   ; 0422
	add_tm SLUDGE_BOMB  ; 0423
	add_tm SANDSTORM    ; 0424
	add_tm FIRE_BLAST   ; 0425
	add_tm SWIFT        ; 0426
	add_tm DEFENSE_CURL ; 0427
	add_tm THUNDERPUNCH ; 0428
	add_tm DREAM_EATER  ; 0429
	add_tm DETECT       ; 042A
	add_tm REST         ; 042B
	add_tm ATTRACT      ; 042C
	add_tm THIEF        ; 042D
	add_tm STEEL_WING   ; 042E
	add_tm FIRE_PUNCH   ; 042F
	add_tm FURY_CUTTER  ; 0430
	add_tm NIGHTMARE    ; 0431
DEF NUM_TMS EQU __tmhm_value__ - 1

MACRO add_hm
; Defines three constants:
; - HM_\1: the item id, starting at $f3
; - \1_TMNUM: the learnable TM/HM flag, starting at 51
; - HM##_MOVE: alias for the move id, equal to the value of \1
	const HM_\1
	DEF HM_VALUE = __tmhm_value__ - NUM_TMS
	DEF HM{02d:HM_VALUE}_MOVE = \1
	add_tmnum \1
ENDM

DEF HM01 EQU const_value
	add_hm CUT        ; 0432
	add_hm FLY        ; 0433
	add_hm SURF       ; 0434
	add_hm STRENGTH   ; 0435
	add_hm FLASH      ; 0436
	add_hm WHIRLPOOL  ; 0437
	add_hm WATERFALL  ; 0438
	add_hm ROCK_SMASH ; 0439
DEF NUM_HMS EQU __tmhm_value__ - NUM_TMS - 1

assert (NUM_TMS + NUM_HMS) < $ff, "TMs/HMs can't exceed 255 due to GetTMHMNumber."

MACRO add_mt
; Defines two constants:
; - \1_TMNUM: the learnable TM/HM flag, starting at 58
; - MT##_MOVE: alias for the move id, equal to the value of \1
	DEF MT_VALUE = __tmhm_value__ - NUM_TMS - NUM_HMS
	DEF MT{02d:MT_VALUE}_MOVE = \1
	add_tmnum \1
ENDM

DEF MT01 EQU const_value
	add_mt FLAMETHROWER
	add_mt THUNDERBOLT
	add_mt ICE_BEAM
	add_mt NOURISHMENT
	add_mt PAY_DAY
	add_mt TELEPORT
	add_mt SEISMIC_TOSS
	add_mt COUNTER
	add_mt MIMIC
	add_mt REFLECT
	add_mt BODY_SLAM
	add_mt SUBSTITUTE
	add_mt TRI_ATTACK
	add_mt MEGA_PUNCH
	add_mt SWORDS_DANCE
	add_mt DOUBLE_EDGE
	add_mt MEGA_KICK
DEF NUM_TUTORS = __tmhm_value__ - NUM_TMS - NUM_HMS - 1

DEF NUM_TM_HM_TUTOR EQU NUM_TMS + NUM_HMS + NUM_TUTORS

DEF USE_SCRIPT_VAR EQU $00
DEF ITEM_FROM_MEM  EQU $ffff

; leftovers from red
DEF SAFARI_BALL    EQU $08 ; MOON_STONE
DEF MOON_STONE_RED EQU $0a ; BURN_HEAL
DEF FULL_HEAL_RED  EQU $34 ; X_SPEED

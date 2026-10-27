ItemDescriptions:
	indirect_table 2, 1
	indirect_entries NUM_ITEM_POCKET, ItemDescriptions1
	indirect_entries FIRST_KEY_ITEM - 1; sparse Table
	indirect_entries (FIRST_KEY_ITEM - 1) + NUM_KEY_ITEM_POCKET, ItemDescriptionsKeyItems
	indirect_entries FIRST_BALL_ITEM - 1 ; sparse Table
	indirect_entries (FIRST_BALL_ITEM - 1) + NUM_BALL_ITEM_POCKET, ItemDescriptionsBalls
	indirect_entries FIRST_BERRY_ITEM - 1 ; sparse Table
	indirect_entries (FIRST_BERRY_ITEM - 1) + NUM_BERRY_ITEM_POCKET, ItemDescriptionsBerries
	indirect_table_end

ItemDescriptions1:
; entries correspond to item ids (see constants/item_constants.asm)
	dw PotionDesc       ; 0001
	dw SuperPotionDesc  ; 0002
	dw HyperPotionDesc  ; 0003
	dw MaxPotionDesc    ; 0004

	dw AntidoteDesc     ; 0005
	dw BurnHealDesc     ; 0006
	dw ParlyzHealDesc   ; 0007
	dw AwakeningDesc    ; 0008
	dw IceHealDesc      ; 0009
	dw FullHealDesc     ; 000A
	dw FullRestoreDesc  ; 000B

	dw ReviveDesc       ; 000C
	dw MaxReviveDesc    ; 000D

	dw EtherDesc        ; 000E
	dw MaxEtherDesc     ; 000F
	dw ElixerDesc       ; 0010
	dw MaxElixerDesc    ; 0011

	dw HPUpDesc         ; 0012
	dw ProteinDesc      ; 0013
	dw IronDesc         ; 0014
	dw CarbosDesc       ; 0015
	dw CalciumDesc      ; 0016
	dw ZincDesc         ; 0017
	dw RareCandyDesc    ; 0018
	dw PPUpDesc         ; 0019

	dw FreshWaterDesc   ; 001A
	dw SodaPopDesc      ; 001B
	dw LemonadeDesc     ; 001C
	dw MoomooMilkDesc   ; 001D
	dw RageCandyBarDesc ; 001E

	dw EnergyPowderDesc ; 001F
	dw EnergyRootDesc   ; 0020
	dw HealPowderDesc   ; 0021
	dw RevivalHerbDesc  ; 0022

	dw SacredAshDesc    ; 0023
	dw MysticDewDesc    ; 0024

	dw BerryJuiceDesc   ; 0025

	dw RepelDesc        ; 0026
	dw SuperRepelDesc   ; 0027
	dw MaxRepelDesc     ; 0028

	dw EscapeRopeDesc   ; 0029
	dw PokeDollDesc     ; 002A

	dw XAttackDesc      ; 002B
	dw XDefendDesc      ; 002C
	dw XSpeedDesc       ; 002D
	dw XSpAttackDesc    ; 002E
	dw XSpDefenseDesc   ; 002F
	dw XAccuracyDesc    ; 0030
	dw GuardSpecDesc    ; 0031
	dw DireHitDesc      ; 0032

	dw LeafStoneDesc    ; 0033
	dw FireStoneDesc    ; 0034
	dw WaterStoneDesc   ; 0035
	dw ThunderStoneDesc ; 0036
	dw MoonStoneDesc    ; 0037
	dw SunStoneDesc     ; 0038
	dw MistStoneDesc    ; 0039

	dw ExpShareDesc     ; 003A
	dw LuckyEggDesc     ; 003B

	dw MiracleSeedDesc  ; 003C
	dw SilverPowderDesc ; 003D
	dw PoisonBarbDesc   ; 003E
	dw CharcoalDesc     ; 003F
	dw MysticWaterDesc  ; 0040
	dw NeverMeltIceDesc ; 0041
	dw MagnetDesc       ; 0042
	dw BlackbeltDesc    ; 0043
	dw HardStoneDesc    ; 0044
	dw SoftSandDesc     ; 0045
	dw TwistedSpoonDesc ; 0046
	dw PinkBowDesc      ; 0047
	dw PolkadotBowDesc  ; 0048
	dw SharpBeakDesc    ; 0049
	dw SpellTagDesc     ; 004A
	dw BlackGlassesDesc ; 004B
	dw DragonFangDesc   ; 004C
	dw IronPlateDesc    ; 004D

	dw BerserkGeneDesc  ; 004E
	dw BrightpowderDesc ; 004F
	dw QuickClawDesc    ; 0050
	dw KingsRockDesc    ; 0051
	dw AmuletCoinDesc   ; 0052
	dw CleanseTagDesc   ; 0053
	dw SmokeBallDesc    ; 0054
	dw FocusBandDesc    ; 0055
	dw LeftoversDesc    ; 0056
	dw ScopeLensDesc    ; 0057

	dw LightBallDesc    ; 0058
	dw StickDesc        ; 0059
	dw ThickClubDesc    ; 005A
	dw LuckyPunchDesc   ; 005B
	dw MetalPowderDesc  ; 005C

	dw DragonScaleDesc  ; 005D
	dw MetalCoatDesc    ; 005E
	dw UpGradeDesc      ; 005F
	dw RazorClawDesc    ; 0060
	dw DubiousDiscDesc  ; 0061
	dw ProtectorDesc    ; 0062

	dw SilverLeafDesc   ; 0063
	dw GoldLeafDesc     ; 0064

	dw NuggetDesc       ; 0065
	dw TinyMushroomDesc ; 0066
	dw BigMushroomDesc  ; 0067
	dw PearlDesc        ; 0068
	dw BigPearlDesc     ; 0069
	dw StardustDesc     ; 006A
	dw StarPieceDesc    ; 006B
	dw BrickPieceDesc   ; 006C
	dw SlowpokeTailDesc ; 006D

	dw NormalBoxDesc    ; 006E
	dw GorgeousBoxDesc  ; 006F

	dw FlowerMailDesc   ; 0070
	dw SurfMailDesc     ; 0071
	dw LiteBlueMailDesc ; 0072
	dw PortraitMailDesc ; 0073
	dw LovelyMailDesc   ; 0074
	dw EonMailDesc      ; 0075
	dw MorphMailDesc    ; 0076
	dw BlueSkyMailDesc  ; 0077
	dw MusicMailDesc    ; 0078
	dw MirageMailDesc   ; 0079

	dw PoisonGuardDesc  ; 007A
	dw BurnGuardDesc    ; 007B
	dw FreezeGuardDesc  ; 007C
	dw SleepGuardDesc   ; 007D
	dw ParlyzGuardDesc  ; 007E
	dw ConfuseGuardDesc ; 007F

	dw DampRockDesc     ; 0080
	dw HeatRockDesc     ; 0081
	dw SmoothRockDesc   ; 0082
	dw IcyRockDesc      ; 0083

	dw LightClayDesc    ; 0084
	dw GripClawDesc     ; 0085

	dw SafariLureDesc   ; 0086

	dw RadianceOrbDesc  ; 0087
	dw UnownAuraDesc    ; 0088

	dw MagnaPlantDesc   ; 0089
	dw TropicPlantDesc  ; 008A
	dw JumboPlantDesc   ; 008B

	dw PinkBedDesc      ; 008C
	dw PolkadotBedDesc  ; 008D
	dw PikachuBedDesc   ; 008E

	dw NESDesc          ; 008F
	dw N64Desc          ; 0090
	dw VirtualBoyDesc   ; 0091
	dw FamicomDesc      ; 0092

	dw RedCarpetDesc    ; 0093
	dw BlueCarpetDesc   ; 0094
	dw GreenCarpetDesc  ; 0095
	dw YellowCarpetDesc ; 0096

	dw PikachuPosterDesc    ; 0097
	dw ClefairyPosterDesc   ; 0098
	dw JigglypuffPosterDesc ; 0099
.IndirectEnd:

ItemDescriptionsKeyItems:
	dw BicycleDesc      ; 0100
	dw CoinCaseDesc     ; 0101
	dw ItemfinderDesc   ; 0102
	dw OldRodDesc       ; 0103
	dw GoodRodDesc      ; 0104
	dw SuperRodDesc     ; 0105
	dw RedScaleDesc     ; 0106
	dw SecretPotionDesc ; 0107
	dw SSTicketDesc     ; 0108
	dw MysteryEggDesc   ; 0109
	dw ClearBellDesc    ; 010A
	dw SilverWingDesc   ; 010B
	dw GSBallDesc       ; 010C
	dw BlueCardDesc     ; 010D
	dw CardKeyDesc      ; 010E
	dw MachinePartDesc  ; 010F
	dw MacheteDesc      ; 0110
	dw LostItemDesc     ; 0111
	dw BasementKeyDesc  ; 0112
	dw PassDesc         ; 0113
	dw SquirtBottleDesc ; 0114
	dw RainbowWingDesc  ; 0115
	dw PokeFluteDesc    ; 0116
	dw JackhammerDesc   ; 0117
	dw OrangePassDesc   ; 0118
.IndirectEnd:

ItemDescriptionsBalls:
	dw MasterBallDesc ; 0200
	dw UltraBallDesc  ; 0201
	dw GreatBallDesc  ; 0202
	dw PokeBallDesc   ; 0203
	dw HeavyBallDesc  ; 0204
	dw LevelBallDesc  ; 0205
	dw LureBallDesc   ; 0206
	dw FastBallDesc   ; 0207
	dw FriendBallDesc ; 0208
	dw MoonBallDesc   ; 0209
	dw LoveBallDesc   ; 020A
	dw ParkBallDesc   ; 020B
.IndirectEnd:

ItemDescriptionsBerries:
	dw BerryDesc        ; 0300
	dw GoldBerryDesc    ; 0301
	dw MysteryBerryDesc ; 0302
	dw MiracleBerryDesc ; 0303
	dw PsnCureBerryDesc ; 0304
	dw PrzCureBerryDesc ; 0305
	dw BurntBerryDesc   ; 0306
	dw IceBerryDesc     ; 0307
	dw BitterBerryDesc  ; 0308
	dw MintBerryDesc    ; 0309

	dw AttackUpBerryDesc    ; 030A
	dw DefenseUpBerryDesc   ; 030B
	dw SpeedUpBerryDesc     ; 030C
	dw SpAttackUpBerryDesc  ; 030D
	dw SpDefenseUpBerryDesc ; 030E
	dw AccuracyUpBerryDesc  ; 030F
	dw EvasionUpBerryDesc   ; 0310

	dw WhtApricornDesc  ; 0311
	dw RedApricornDesc  ; 0312
	dw BluApricornDesc  ; 0313
	dw BlkApricornDesc  ; 0314
	dw YlwApricornDesc  ; 0315
	dw GrnApricornDesc  ; 0316
	dw PnkApricornDesc  ; 0317
.IndirectEnd:

PotionDesc:
	db   "Restores #MON"
	next "HP by 20.@"

SuperPotionDesc:
	db   "Restores #MON"
	next "HP by 50.@"

HyperPotionDesc:
	db   "Restores #MON"
	next "HP by 200.@"

MaxPotionDesc:
	db   "Fully restores"
	next "#MON HP.@"

AntidoteDesc:
	db   "Cures poisoned"
	next "#MON.@"

BurnHealDesc:
	db   "Heals burned"
	next "#MON.@"

ParlyzHealDesc:
	db   "Heals paralyzed"
	next "#MON.@"

AwakeningDesc:
	db   "Awakens sleeping"
	next "#MON.@"

IceHealDesc:
	db   "Heals a frostbit-"
	next "ten #MON.@"

FullHealDesc:
	db   "Eliminates all"
	next "status problems.@"

FullRestoreDesc:
	db   "Fully restores HP"
	next "& status.@"

ReviveDesc:
	db   "Restores a fainted"
	next "#MON to 1/2 HP.@"

MaxReviveDesc:
	db   "Fully restores a"
	next "fainted #MON.@"

MaxElixerDesc:
	db   "Fully restores the"
	next "PP of one #MON.@"

EtherDesc:
	db   "Restores PP of one"
	next "move by 10.@"

MaxEtherDesc:
	db   "Fully restores PP"
	next "of one move.@"

ElixerDesc:
	db   "Restores PP of all"
	next "moves by 10.@"

HPUpDesc:
	db   "Raises the HP of"
	next "one #MON.@"

ProteinDesc:
	db   "Raises ATTACK of"
	next "one #MON.@"

IronDesc:
	db   "Raises DEFENSE of"
	next "one #MON.@"

CarbosDesc:
	db   "Raises SPEED of"
	next "one #MON.@"

CalciumDesc:
	db   "Raises SPCL.ATK"
	next "of one #MON.@"

ZincDesc:
	db   "Raises SPCL.DEF"
	next "of one #MON.@"

RareCandyDesc:
	db   "Raises level of a"
	next "#MON by one.@"

PPUpDesc:
	db   "Raises max PP of"
	next "a selected move.@"

FreshWaterDesc:
	db   "Restores #MON"
	next "HP by 50.@"

SodaPopDesc:
	db   "Restores #MON"
	next "HP by 60.@"

LemonadeDesc:
	db   "Restores #MON"
	next "HP by 80.@"

MoomooMilkDesc:
	db   "Restores #MON"
	next "HP by 100.@"

RageCandyBarDesc:
	db   "A self-restore"
	next "item for 50HP.@"

EnergyPowderDesc:
	db   "Restores #MON"
	next "HP by 50. Bitter.@"

EnergyRootDesc:
	db   "Restores #MON"
	next "HP by 200. Bitter.@"

HealPowderDesc:
	db   "Cures all status"
	next "problems. Bitter.@"

RevivalHerbDesc:
	db   "Revives fainted"
	next "#MON. Bitter.@"

SacredAshDesc:
	db   "Fully revives all"
	next "fainted #MON.@"

MysticDewDesc:
	db   "Fully restores HP,"
	next "PP & status.@"

BerryJuiceDesc:
	db   "Restores #MON"
	next "HP by 20.@"

RepelDesc:
	db   "Repels weak #-"
	next "MON for 100 steps.@"

SuperRepelDesc:
	db   "Repels weak #-"
	next "MON for 200 steps.@"

MaxRepelDesc:
	db   "Repels weak #-"
	next "MON for 250 steps.@"

EscapeRopeDesc:
	db   "Use for escaping"
	next "from caves, etc.@"

PokeDollDesc:
	db   "Use to escape from"
	next "a wild #MON.@"

XAttackDesc:
	db   "Raises ATTACK."
	next "(1 BTL)@"

XDefendDesc:
	db   "Raises DEFENSE."
	next "(1 BTL)@"

XSpeedDesc:
	db   "Raises SPEED."
	next "(1 BTL)@"

XSpAttackDesc:
	db   "Raises SPECIAL"
	next "ATTACK. (1 BTL)@"

XSpDefenseDesc:
	db   "Raises SPECIAL"
	next "DEFENSE. (1 BTL)@"

XAccuracyDesc:
	db   "Raises accuracy."
	next "(1 BTL)@"

GuardSpecDesc:
	db   "Prevents stats"
	next "reduction. (1 BTL)@"

DireHitDesc:
	db   "Ups critical hit"
	next "ratio. (1 BTL)@"

LeafStoneDesc:
FireStoneDesc:
WaterStoneDesc:
ThunderStoneDesc:
MoonStoneDesc:
SunStoneDesc:
MistStoneDesc:
	db   "Evolves certain"
	next "kinds of #MON.@"

ExpShareDesc:
	db   "Shares battle EXP."
	next "Points.@"

LuckyEggDesc:
	db   "Earns extra EXP."
	next "points.@"

MiracleSeedDesc:
	db   "Powers up grass-"
	next "type moves.@"

PoisonBarbDesc:
	db   "Powers up poison-"
	next "type moves.@"

SilverPowderDesc:
	db   "Powers up bug-type"
	next "moves.@"

CharcoalDesc:
	db   "Powers up fire-"
	next "type moves.@"

MysticWaterDesc:
	db   "Powers up water-"
	next "type moves.@"

NeverMeltIceDesc:
	db   "Powers up ice-type"
	next "moves.@"

MagnetDesc:
	db   "Boosts electric-"
	next "type moves.@"

BlackbeltDesc:
	db   "Boosts fighting-"
	next "type moves.@"

HardStoneDesc:
	db   "Powers up rock-"
	next "type moves.@"

SoftSandDesc:
	db   "Powers up ground-"
	next "type moves.@"

TwistedSpoonDesc:
	db   "Powers up psychic-"
	next "type moves.@"

PinkBowDesc:
	db   "Powers up normal-"
	next "type moves.@"

PolkadotBowDesc:
	db   "Powers up fairy-"
	next "type moves.@"

SharpBeakDesc:
	db   "Powers up flying-"
	next "type moves.@"

SpellTagDesc:
	db   "Powers up ghost-"
	next "type moves.@"

BlackGlassesDesc:
	db   "Powers up dark-"
	next "type moves.@"

DragonFangDesc:
	db   "Powers up dragon-"
	next "type moves.@"

IronPlateDesc:
	db   "Powers up steel-"
	next "type moves.@"

BerserkGeneDesc:
	db   "Boosts ATTACK but"
	next "causes confusion.@"

BrightpowderDesc:
	db   "Lowers the foe's"
	next "accuracy.@"

QuickClawDesc:
	db   "Raises 1st strike"
	next "ratio.@"

KingsRockDesc:
	db   "May make the foe"
	next "flinch.@"

AmuletCoinDesc:
	db   "Doubles monetary"
	next "earnings.@"

CleanseTagDesc:
	db   "Helps repel wild"
	next "#MON.@"

SmokeBallDesc:
	db   "Escape from wild"
	next "#MON.@"

FocusBandDesc:
	db   "May prevent faint-"
	next "ing.@"

LeftoversDesc:
	db   "Restores HP during"
	next "battle.@"

ScopeLensDesc:
	db   "Raises critical"
	next "hit ratio.@"

LightBallDesc:
	db   "An odd, electrical"
	next "orb.@"

StickDesc:
	db   "An ordinary stick."
	next "Sell low.@"

ThickClubDesc:
	db   "A bone of some"
	next "sort. Sell low.@"

LuckyPunchDesc:
	db   "Ups critical hit"
	next "ratio of CHANSEY.@"

MetalPowderDesc:
	db   "Raises DEFENSE of"
	next "DITTO.@"

DragonScaleDesc:
	db   "A rare dragon-type"
	next "item.@"

MetalCoatDesc:
	db   "A rare steel-type"
	next "item.@"

UpGradeDesc:
	db   "A mysterious box"
	next "made by SILPH CO.@"

RazorClawDesc:
	db   "Raises critical"
	next "hit ratio.@"

DubiousDiscDesc:
	db   "A transparent disc"
	next "of unknown origin.@"

ProtectorDesc:
	db   "A protective item."
	next "Stiff and heavy.@"

SilverLeafDesc:
	db   "A strange, silver-"
	next "colored leaf.@"

GoldLeafDesc:
	db   "A strange, gold-"
	next "colored leaf.@"

NuggetDesc:
	db   "Made of pure gold."
	next "Sell high.@"

TinyMushroomDesc:
	db   "An ordinary mush-"
	next "room. Sell low.@"

BigMushroomDesc:
	db   "A rare mushroom."
	next "Sell high.@"

PearlDesc:
	db   "A beautiful pearl."
	next "Sell low.@"

BigPearlDesc:
	db   "A big, beautiful"
	next "pearl. Sell high.@"

StardustDesc:
	db   "Pretty, red sand."
	next "Sell high.@"

StarPieceDesc:
	db   "A hunk of red gem."
	next "Sell very high.@"

BrickPieceDesc:
	db   "A rare chunk of"
	next "tile.@"

SlowpokeTailDesc:
	db   "Very tasty. Sell"
	next "high.@"

NormalBoxDesc:
	db   "Open it and see"
	next "what's inside.@"

GorgeousBoxDesc:
	db   "Open it and see"
	next "what's inside.@"

FlowerMailDesc:
	db   "Flower-print MAIL."
	next "(HOLD)@"

SurfMailDesc:
	db   "LAPRAS-print MAIL."
	next "(HOLD)@"

LiteBlueMailDesc:
	db   "DRATINI-print"
	next "MAIL.@"

PortraitMailDesc:
	db   "MAIL featuring the"
	next "holder's likeness.@"

LovelyMailDesc:
	db   "Heart-print MAIL."
	next "(HOLD)@"

EonMailDesc:
	db   "EEVEE-print MAIL."
	next "(HOLD)@"

MorphMailDesc:
	db   "DITTO-print MAIL."
	next "(HOLD)@"

BlueSkyMailDesc:
	db   "Sky-print MAIL."
	next "(HOLD)@"

MusicMailDesc:
	db   "NATU-print MAIL."
	next "(HOLD)@"

MirageMailDesc:
	db   "MEW-print MAIL."
	next "(HOLD)@"

PoisonGuardDesc:
	db	 "User can't get"
	next "poisoned.@"

BurnGuardDesc:
	db	 "User can't get"
	next "burned.@"

FreezeGuardDesc:
	db	 "User can't get"
	next "frostbite.@"

SleepGuardDesc:
	db	 "User can't fall"
	next "asleep.@"

ParlyzGuardDesc:
	db	 "User can't get"
	next "paralyzed.@"

ConfuseGuardDesc:
	db	 "User can't get"
	next "confused.@"

DampRockDesc:
	db   "Extends duration"
	next "of rain.@"

HeatRockDesc:
	db   "Extends duration"
	next "of sunlight.@"

SmoothRockDesc:
	db   "Extends duration"
	next "of sandstorms.@"

IcyRockDesc:
	db   "Extends duration"
	next "of hail.@"

LightClayDesc:
	db   "Extends duration"
	next "of barrier moves.@"

GripClawDesc:
	db   "Extends duration"
	next "of trapping moves.@"

SafariLureDesc:
	db   "Increase chance to"
	next "capture #MON.@"

RadianceOrbDesc:
	db   "Reveals true power"
	next "of #MON.@"

UnownAuraDesc:
	db   "A gift of the"
	next "UNOWN.@"

MagnaPlantDesc:
TropicPlantDesc:
JumboPlantDesc:
	db   "A new plant for"
	next "your room!@"

PinkBedDesc:
PolkadotBedDesc:
PikachuBedDesc:
	db   "A new bed for"
	next "your room!@"

NESDesc:
N64Desc:
VirtualBoyDesc:
FamicomDesc:
	db   "A new game for"
	next "your room!@"

RedCarpetDesc:
BlueCarpetDesc:
GreenCarpetDesc:
YellowCarpetDesc:
	db   "A new carpet for"
	next "your room!@"

PikachuPosterDesc:
ClefairyPosterDesc:
JigglypuffPosterDesc:
	db   "A new poster for"
	next "your room!@"

BicycleDesc:
	db   "A collapsible bike"
	next "for fast movement.@"

CoinCaseDesc:
	db   "Holds up to 9,999"
	next "game coins.@"

ItemfinderDesc:
	db   "Checks for unseen"
	next "items in the area.@"

OldRodDesc:
	db   "Use by water to"
	next "fish for #MON.@"

GoodRodDesc:
	db   "A good ROD for"
	next "catching #MON.@"

SuperRodDesc:
	db   "The best ROD for"
	next "catching #MON.@"

RedScaleDesc:
	db   "A scale from the"
	next "red GYARADOS.@"

SecretPotionDesc:
	db   "Fully heals any"
	next "#MON.@"

SSTicketDesc:
	db   "A ticket for the"
	next "S.S.AQUA.@"

MysteryEggDesc:
	db   "An EGG obtained"
	next "from MR.#MON.@"

ClearBellDesc:
	db   "Makes a gentle"
	next "ringing.@"

SilverWingDesc:
	db   "A strange, silver-"
	next "colored feather.@"

GSBallDesc:
	db   "The mysterious"
	next "BALL.@"

BlueCardDesc:
	db   "Card to save"
	next "points.@"

CardKeyDesc:
	db   "Opens shutters in"
	next "the RADIO TOWER.@"

MachinePartDesc:
	db   "A machine part for"
	next "the POWER PLANT.@"

MacheteDesc:
    db   "Carves through"
    next "thick undergrowth.@"

LostItemDesc:
	db   "The # DOLL lost"
	next "by the COPYCAT.@"

BasementKeyDesc:
	db   "Opens doors.@"

PassDesc:
	db   "A ticket for the"
	next "MAGNET TRAIN.@"

SquirtBottleDesc:
	db   "A bottle used for"
	next "watering plants.@"

RainbowWingDesc:
	db   "A mystical feather"
	next "of rainbow colors.@"

PokeFluteDesc:
	db   "Plays a pleasant"
	next "melody.@"

JackhammerDesc:
	db   "Smashes boulders"
	next "and loose rocks.@"

OrangePassDesc:
	db   "A pass for the"
	next "ORANGE express.@"

MasterBallDesc:
	db   "The best BALL. It"
	next "never misses.@"

UltraBallDesc:
	db   "A BALL with a high"
	next "rate of success.@"

GreatBallDesc:
	db   "A BALL with a de-"
	next "cent success rate.@"

PokeBallDesc:
	db   "An item for catch-"
	next "ing #MON.@"

HeavyBallDesc:
	db   "A BALL for catch-"
	next "ing heavy #MON.@"

LevelBallDesc:
	db   "A BALL for lower-"
	next "level #MON.@"

LureBallDesc:
	db   "A BALL for #MON"
	next "hooked by a ROD.@"

FastBallDesc:
	db   "A BALL for catch-"
	next "ing fast #MON.@"

FriendBallDesc:
	db   "A BALL that makes"
	next "#MON friendly.@"

MoonBallDesc:
	db   "A BALL for MOON"
	next "STONE evolvers.@"

LoveBallDesc:
	db   "For catching the"
	next "opposite gender.@"

ParkBallDesc:
	db   "The Bug-Catching"
	next "Contest BALL.@"

BerryDesc:
	db   "A self-restore"
	next "item for 10HP.@"

GoldBerryDesc:
	db   "A self-restore"
	next "item for 30HP.@"

MysteryBerryDesc:
	db   "A self-restore"
	next "item for 5 PP.@"

MiracleBerryDesc:
	db   "Self-cure for all"
	next "status problems.@"

PsnCureBerryDesc:
	db   "A self-cure for"
	next "poison.@"

PrzCureBerryDesc:
	db   "A self-cure for"
	next "paralysis.@"

BurntBerryDesc:
	db   "A self-cure for"
	next "frostbite.@"

IceBerryDesc:
	db   "A self-heal for a"
	next "burn.@"

BitterBerryDesc:
	db   "A self-cure for"
	next "confusion.@"

MintBerryDesc:
	db   "A self-awakening"
	next "for sleep.@"

AttackUpBerryDesc:
	db   "A self-stat boost"
	next "for ATTACK.@"

DefenseUpBerryDesc:
	db   "A self-stat boost"
	next "for DEFENSE.@"

SpeedUpBerryDesc:
	db   "A self-stat boost"
	next "for SPEED.@"

SpAttackUpBerryDesc:
	db   "A self-stat boost"
	next "for SP.ATK.@"

SpDefenseUpBerryDesc:
	db   "A self-stat boost"
	next "for SP.DEF.@"

AccuracyUpBerryDesc:
	db   "A self-stat boost"
	next "for ACCURACY.@"

EvasionUpBerryDesc:
	db   "A self-stat boost"
	next "for EVASION.@"

WhtApricornDesc:
	db   "A white APRICORN.@"

RedApricornDesc:
	db   "A red APRICORN.@"

BluApricornDesc:
	db   "A blue APRICORN.@"

BlkApricornDesc:
	db   "A black APRICORN.@"

YlwApricornDesc:
	db   "A yellow APRICORN.@"

GrnApricornDesc:
	db   "A green APRICORN.@"

PnkApricornDesc:
	db   "A pink APRICORN.@"

QuestionMarkDesc:
	db   "?@"


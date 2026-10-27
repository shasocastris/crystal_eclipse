MoveDescriptions::
; entries correspond to move ids (see constants/move_constants.asm)
	indirect_table 2, 1
	indirect_entries MOVE_TABLE_SPLIT, MoveDescriptionsPart1
	indirect_entries NUM_ATTACKS, MoveDescriptionsPart2
	indirect_table_end

MoveDescriptionsPart1:
	; NORMAL
	dw SelfdestructDescription
	dw ThrashDescription
	dw DoubleEdgeDescription
	dw TakeDownDescription
	dw BodySlamDescription
	dw SlamDescription
	dw HyperFangDescription
	dw ExtremespeedDescription
	dw HeadbuttDescription
	dw SlashDescription
	dw StompDescription
	dw HornAttackDescription
	dw PayDayDescription
	dw ScratchDescription
	dw QuickAttackDescription
	dw FalseSwipeDescription
	dw RageDescription
	dw RapidSpinDescription
	dw FurySwipesDescription
	dw WrapDescription
	dw SuperFangDescription
	dw FlailDescription
	dw ReturnDescription
	dw PresentDescription
	dw HyperBeamDescription
	dw HyperVoiceDescription
	dw TriAttackDescription
	dw HiddenPowerDescription
	dw SwiftDescription
	dw SonicboomDescription
	dw SwordsDanceDescription
	dw LeerDescription
	dw GrowlDescription
	dw RoarDescription
	dw SingDescription
	dw SupersonicDescription
	dw DisableDescription
	dw GrowthDescription
	dw MimicDescription
	dw ScreechDescription
	dw DoubleTeamDescription
	dw RecoverDescription
	dw HardenDescription
	dw MinimizeDescription
	dw SmokescreenDescription
	dw DefenseCurlDescription
	dw FocusEnergyDescription
	dw MetronomeDescription
	dw SoftboiledDescription
	dw GlareDescription
	dw LovelyKissDescription
	dw TransformDescription
	dw FlashDescription
	dw SplashDescription
	dw ConversionDescription
	dw SubstituteDescription
	dw SketchDescription
	dw Conversion2Description
	dw ProtectDescription
	dw ScaryFaceDescription
	dw BellyDrumDescription
	dw ForesightDescription
	dw PerishSongDescription
	dw LockOnDescription
	dw EndureDescription
	dw SwaggerDescription
	dw MeanLookDescription
	dw AttractDescription
	dw SleepTalkDescription
	dw HealBellDescription
	dw SafeguardDescription
	dw PainSplitDescription
	dw BatonPassDescription
	dw EncoreDescription
	dw SweetScentDescription
	dw MorningSunDescription
	dw PsychUpDescription
	dw StruggleDescription
	; FIGHTING
	dw MegaKickDescription
	dw DynamicpunchDescription
	dw CrossChopDescription
	dw HiJumpKickDescription
	dw SubmissionDescription
	dw StrengthDescription
	dw DrainPunchDescription
	dw VitalThrowDescription
	dw RollingKickDescription
	dw KarateChopDescription
	dw MachPunchDescription
	dw DoubleKickDescription
	dw CounterDescription
	dw SeismicTossDescription
	dw ReversalDescription
	dw AuraSphereDescription
	dw FocusBlastDescription
	dw DetectDescription
	; FLYING
	dw SkyAttackDescription
	dw BraveBirdDescription
	dw DrillPeckDescription
	dw FlyDescription
	dw WingAttackDescription
	dw AerialAceDescription
	dw PeckDescription
	dw HurricaneDescription
	dw AirSlashDescription
	dw GustDescription
	dw RazorWindDescription
	dw MirrorMoveDescription
	; POISON
	dw GunkShotDescription
	dw PoisonJabDescription
	dw PoisonStingDescription
	dw SludgeBombDescription
	dw SludgeDescription
	dw AcidDescription
	dw PoisonpowderDescription
	dw ToxicDescription
	; GROUND
	dw EruptionDescription
	dw EarthquakeDescription
	dw BoneClubDescription
	dw DigDescription
	dw BulldozeDescription
	dw BonemerangDescription
	dw MagnitudeDescription
	dw EarthPowerDescription
	dw MudSlapDescription
	dw SpikesDescription
	; ROCK
	dw StoneEdgeDescription
	dw RockSlideDescription
	dw RockThrowDescription
	dw RolloutDescription
	dw RockBlastDescription
	dw PowerGemDescription
	dw AncientpowerDescription
	dw SandstormDescription
	; BUG
	dw MegahornDescription
	dw XScissorDescription
	dw LeechLifeDescription
	dw CutDescription
	dw TwineedleDescription
	dw BindDescription
	dw PinMissileDescription
	dw FuryCutterDescription
	dw BugBuzzDescription
	dw StringShotDescription
.IndirectEnd::

MoveDescriptionsPart2:
	; GHOST
	dw ShadowClawDescription
	dw LickDescription
	dw DreamEaterDescription
	dw ShadowBallDescription
	dw NightShadeDescription
	dw ConfuseRayDescription
	dw NightmareDescription
	dw SpiteDescription
	dw DestinyBondDescription
	; STEEL
	dw SkullBashDescription
	dw IronTailDescription
	dw IronHeadDescription
	dw SteelWingDescription
	dw MetalClawDescription
	dw RockSmashDescription
	dw BulletPunchDescription
	dw SpikeCannonDescription
	dw ClampDescription
	dw FlashCannonDescription
	; CURSE_TYPE
	dw CurseDescription
	; FIRE
	dw SacredFireDescription
	dw FirePunchDescription
	dw FlameWheelDescription
	dw FireBlastDescription
	dw FlamethrowerDescription
	dw EmberDescription
	dw FireSpinDescription
	dw SunnyDayDescription
	dw WillOWispDescription
	; WATER
	dw CrabhammerDescription
	dw AquaTailDescription
	dw WaterfallDescription
	dw AquaJetDescription
	dw HydroPumpDescription
	dw SurfDescription
	dw ScaldDescription
	dw BubblebeamDescription
	dw OctazookaDescription
	dw WaterPulseDescription
	dw WaterGunDescription
	dw BubbleDescription
	dw WhirlpoolDescription
	dw RainDanceDescription
	dw LifeDewDescription
	; GRASS
	dw PowerWhipDescription
	dw SeedBombDescription
	dw RazorLeafDescription
	dw VineWhipDescription
	dw ConstrictDescription
	dw SolarbeamDescription
	dw PetalDanceDescription
	dw EnergyBallDescription
	dw GigaDrainDescription
	dw MegaDrainDescription
	dw AbsorbDescription
	dw LeechSeedDescription
	dw StunSporeDescription
	dw SleepPowderDescription
	dw SporeDescription
	dw SynthesisDescription
	; ELECTRIC
	dw WildChargeDescription
	dw ThunderpunchDescription
	dw SparkDescription
	dw StormCallDescription
	dw ThunderDescription
	dw ZapCannonDescription
	dw ThunderboltDescription
	dw ThundershockDescription
	dw ThunderWaveDescription
	dw InnerLightDescription
	; PSYCHIC_TYPE
	dw ZenHeadbuttDescription
	dw PsychicMDescription
	dw FutureSightDescription
	dw ExtrasensoryDescription
	dw PsybeamDescription
	dw ConfusionDescription
	dw PsywaveDescription
	dw MirrorCoatDescription
	dw HypnosisDescription
	dw MeditateDescription
	dw AgilityDescription
	dw TeleportDescription
	dw BarrierDescription
	dw LightScreenDescription
	dw ReflectDescription
	dw AmnesiaDescription
	dw RestDescription
	; ICE
	dw IcicleCrashDescription
	dw IcePunchDescription
	dw IceShardDescription
	dw BlizzardDescription
	dw IceBeamDescription
	dw AuroraBeamDescription
	dw IcyWindDescription
	dw PowderSnowDescription
	dw SheerColdDescription
	dw MistDescription
	dw HazeDescription
	dw SuddenChillDescription
	dw HailDescription
	; DRAGON
	dw OutrageDescription
	dw DragonClawDescription
	dw AeroblastDescription
	dw DragonPulseDescription
	dw DragonbreathDescription
	dw DragonRageDescription
	dw TwisterDescription
	; DARK
	dw CrunchDescription
	dw NightSlashDescription
	dw BiteDescription
	dw FaintAttackDescription
	dw ThiefDescription
	dw PursuitDescription
	dw DarkPulseDescription
	; FAIRY
	dw FaeBladeDescription
	dw PlayRoughDescription
	dw MegaPunchDescription
	dw CometPunchDescription
	dw MoonblastDescription
	dw DazzlingGleamDescription
	dw DrainKissDescription
	dw DisarmVoiceDescription
	dw SweetKissDescription
	dw CharmDescription
	dw MoonlightDescription
.IndirectEnd::

InvalidMoveDescription:
	db "?@"


KarateChopDescription:
	db   "Has a high criti-"
	line "cal hit ratio.@"


CometPunchDescription:
	db   "Repeatedly punches"
	line "2-5 times.@"

MegaPunchDescription:
	db   "A powerful punch"
	line "thrown very hard.@"

PayDayDescription:
	db   "Throws coins. Gets"
	line "them back later.@"

FirePunchDescription:
	db   "A fiery punch. May"
	line "cause a burn.@"

IcePunchDescription:
	db   "An icy punch. May"
	line "cause frostbite.@"

ThunderpunchDescription:
	db   "An electric punch."
	line "It may paralyze.@"

ScratchDescription:
	db   "Scratches with"
	line "sharp claws.@"



RazorWindDescription:
	db   "Traps the foe for"
	line "2-5 turns.@"

SwordsDanceDescription:
	db   "A dance that in-"
	line "creases ATTACK.@"

CutDescription:
	db   "Cuts using claws,"
	line "scythes, etc.@"

GustDescription:
	db   "Whips up a strong"
	line "gust of wind.@"

WingAttackDescription:
	db   "Strikes the target"
	line "with wings.@"


FlyDescription:
	db   "1st turn: Fly"
	line "2nd turn: Attack@"

BindDescription:
	db   "Binds the target"
	line "for 2-5 turns.@"

SlamDescription:
	db   "Slams the foe with"
	line "a tail, vine, etc.@"

VineWhipDescription:
	db   "Whips the foe with"
	line "slender vines.@"

StompDescription:
	db   "An attack that may"
	line "cause flinching.@"

DoubleKickDescription:
	db   "A double kicking"
	line "attack.@"

MegaKickDescription:
	db   "A powerful kicking"
	line "attack.@"


RollingKickDescription:
	db   "A fast, spinning"
	line "kick.@"


HeadbuttDescription:
	db   "An attack that may"
	line "make foe flinch.@"

HornAttackDescription:
	db   "An attack using a"
	line "horn to jab.@"




BodySlamDescription:
	db   "An attack that may"
	line "cause paralysis.@"

WrapDescription:
	db   "Squeezes the foe"
	line "for 2-5 turns.@"

TakeDownDescription:
	db   "A tackle that also"
	line "hurts the user.@"

ThrashDescription:
	db   "Works 2-3 turns"
	line "and confuses user.@"

DoubleEdgeDescription:
	db   "A tackle that also"
	line "hurts the user.@"


PoisonStingDescription:
	db   "An attack that may"
	line "poison the target.@"

TwineedleDescription:
	db   "Jabs the foe twice"
	line "using stingers.@"

PinMissileDescription:
	db   "Fires pins that"
	line "strike 2-5 times.@"

LeerDescription:
	db   "Reduces the foe's"
	line "DEFENSE.@"

BiteDescription:
	db   "An attack that may"
	line "cause flinching.@"

GrowlDescription:
	db   "Reduces the foe's"
	line "ATTACK.@"

RoarDescription:
	db   "Scares wild foes"
	line "to end battle.@"

SingDescription:
	db   "May cause the foe"
	line "to fall asleep.@"

SupersonicDescription:
	db   "Sound waves that"
	line "cause confusion.@"

SonicboomDescription:
	db   "Always inflicts"
	line "20HP damage.@"

DisableDescription:
	db   "Disables the foe's"
	line "most recent move.@"

AcidDescription:
	db   "An attack that may"
	line "lower DEFENSE.@"

EmberDescription:
	db   "An attack that may"
	line "inflict a burn.@"

FlamethrowerDescription:
	db   "An attack that may"
	line "inflict a burn.@"

MistDescription:
	db   "Prevents stat"
	line "reduction.@"

WaterGunDescription:
	db   "Squirts water to"
	line "attack.@"

HydroPumpDescription:
	db   "A powerful water-"
	line "type attack.@"

SurfDescription:
	db   "A strong water-"
	line "type attack.@"

IceBeamDescription:
	db   "An attack that may"
	line "cause frostbite.@"

BlizzardDescription:
	db   "An attack that may"
	line "cause frostbite.@"

PsybeamDescription:
	db   "An attack that may"
	line "confuse the foe.@"

BubblebeamDescription:
	db   "An attack that may"
	line "lower SPEED.@"

AuroraBeamDescription:
	db   "An attack that may"
	line "lower ATTACK.@"

HyperBeamDescription:
	db   "1st turn: Attack"
	line "2nd turn: Rest@"

PeckDescription:
	db   "Jabs the foe with"
	line "a beak, etc.@"

DrillPeckDescription:
	db   "A strong, spin-"
	line "ning-peck attack.@"

SubmissionDescription:
	db   "An attack that al-"
	line "so hurts the user.@"


CounterDescription:
	db   "Returns a physical"
	line "blow double.@"

SeismicTossDescription:
	db   "The user's level"
	line "equals damage HP.@"

StrengthDescription:
	db   "A powerful physi-"
	line "cal attack.@"

AbsorbDescription:
	db   "Steals 1/2 of the"
	line "damage inflicted.@"

MegaDrainDescription:
	db   "Steals 1/2 of the"
	line "damage inflicted.@"

LeechSeedDescription:
	db   "Steals HP from the"
	line "foe on every turn.@"

GrowthDescription:
	db   "Raises the SPCL."
	line "ATK rating.@"

RazorLeafDescription:
	db   "Has a high criti-"
	line "cal hit ratio.@"

SolarbeamDescription:
	db   "1st turn: Prepare"
	line "2nd turn: Attack@"

PoisonpowderDescription:
	db   "A move that may"
	line "poison the foe.@"

StunSporeDescription:
	db   "A move that may"
	line "paralyze the foe.@"

SleepPowderDescription:
	db   "May cause the foe"
	line "to fall asleep.@"

PetalDanceDescription:
	db   "Works 2-3 turns"
	line "and confuses user.@"

StringShotDescription:
	db   "A move that lowers"
	line "the foe's SPEED.@"

DragonRageDescription:
	db   "Always inflicts"
	line "40HP damage.@"

FireSpinDescription:
	db   "Traps foe in fire"
	line "for 2-5 turns.@"

ThundershockDescription:
	db   "An attack that may"
	line "cause paralysis.@"

ThunderboltDescription:
	db   "An attack that may"
	line "cause paralysis.@"

ThunderWaveDescription:
	db   "A move that may"
	line "cause paralysis.@"

ThunderDescription:
	db   "An attack that may"
	line "cause paralysis.@"

RockThrowDescription:
	db   "Drops rocks on the"
	line "enemy.@"

EarthquakeDescription:
	db   "Tough but useless"
	line "vs. flying foes.@"


DigDescription:
	db   "1st turn: Burrow"
	line "2nd turn: Attack@"

ToxicDescription:
	db   "A poison move with"
	line "increasing damage.@"

ConfusionDescription:
	db   "An attack that may"
	line "cause confusion.@"

PsychicMDescription:
	db   "An attack that may"
	line "lower SPCL.DEF.@"

HypnosisDescription:
	db   "May put the foe to"
	line "sleep.@"

MeditateDescription:
	db   "Raises the user's"
	line "ATTACK.@"

AgilityDescription:
	db   "Sharply increases"
	line "the user's SPEED.@"

QuickAttackDescription:
	db   "Lets the user get"
	line "in the first hit.@"

RageDescription:
	db   "Raises ATTACK if"
	line "the user is hit.@"

TeleportDescription:
	db   "A move for fleeing"
	line "from battle.@"

NightShadeDescription:
	db   "The user's level"
	line "equals damage HP.@"

MimicDescription:
	db   "Copies a move used"
	line "by the foe.@"

ScreechDescription:
	db   "Sharply reduces"
	line "the foe's DEFENSE.@"

DoubleTeamDescription:
	db   "Heightens evasive-"
	line "ness.@"

RecoverDescription:
	db   "Restores HP by 1/2"
	line "the max HP.@"

HardenDescription:
	db   "Raises the user's"
	line "DEFENSE.@"

MinimizeDescription:
	db   "Heightens evasive-"
	line "ness.@"

SmokescreenDescription:
	db   "Lowers the foe's"
	line "accuracy.@"

ConfuseRayDescription:
	db   "A move that causes"
	line "confusion.@"


DefenseCurlDescription:
	db   "Heightens the"
	line "user's DEFENSE.@"

BarrierDescription:
	db   "Sharply increases"
	line "user's DEFENSE.@"

LightScreenDescription:
	db   "Ups SPCL.DEF with"
	line "a wall of light.@"

HazeDescription:
	db   "Eliminates all"
	line "stat changes.@"

ReflectDescription:
	db   "Raises DEFENSE"
	line "with a barrier.@"

FocusEnergyDescription:
	db   "Raises the criti-"
	line "cal hit ratio.@"


MetronomeDescription:
	db   "Randomly uses any"
	line "#MON move.@"

MirrorMoveDescription:
	db   "Counters with the"
	line "same move.@"

SelfdestructDescription:
	db   "Powerful but makes"
	line "the user faint.@"


LickDescription:
	db   "An attack that may"
	line "cause paralysis.@"


SludgeDescription:
	db   "An attack that may"
	line "poison the foe.@"

BoneClubDescription:
	db   "An attack that may"
	line "cause flinching.@"

FireBlastDescription:
	db   "An attack that"
	line "may cause a burn.@"

WaterfallDescription:
	db   "An aquatic charge"
	line "attack.@"

ClampDescription:
	db   "Traps the foe for"
	line "2-5 turns.@"

SwiftDescription:
	db   "An attack that"
	line "never misses.@"

SkullBashDescription:
	db   "1st turn: Prepare"
	line "2nd turn: Attack@"

SpikeCannonDescription:
	db   "Fires spikes to"
	line "hit 2-5 times.@"

ConstrictDescription:
	db   "An attack that may"
	line "lower SPEED.@"

AmnesiaDescription:
	db   "Sharply raises the"
	line "user's SPCL.DEF.@"


SoftboiledDescription:
	db   "Restores HP by 1/2"
	line "the user's max HP.@"

HiJumpKickDescription:
	db   "May miss and hurt"
	line "the user.@"

GlareDescription:
	db   "A move that may"
	line "cause paralysis.@"

DreamEaterDescription:
	db   "Steals HP from a"
	line "sleeping victim.@"



LeechLifeDescription:
	db   "Steals 1/2 of the"
	line "damage inflicted.@"

LovelyKissDescription:
	db   "May cause the foe"
	line "to fall asleep.@"

SkyAttackDescription:
	db   "Sharply cuts the"
	line "foe's accuracy.@"

TransformDescription:
	db   "The user assumes"
	line "the foe's guise.@"

BubbleDescription:
	db   "An attack that may"
	line "reduce SPEED.@"


SporeDescription:
	db   "A move that"
	line "induces sleep.@"

FlashDescription:
	db   "Blinds the foe to"
	line "reduce accuracy.@"

PsywaveDescription:
	db   "Traps the foe for"
	line "2-5 turns.@"

SplashDescription:
	db   "Has no effect"
	line "whatsoever.@"


CrabhammerDescription:
	db   "Has a high criti-"
	line "cal hit ratio.@"


FurySwipesDescription:
	db   "Quickly scratches"
	line "2-5 times.@"

BonemerangDescription:
	db   "An attack that"
	line "strikes twice.@"

RestDescription:
	db   "Sleep for 2 turns"
	line "to fully recover.@"

RockSlideDescription:
	db   "An attack that may"
	line "cause flinching.@"

HyperFangDescription:
	db   "An attack that may"
	line "cause flinching.@"


ConversionDescription:
	db   "Change user's type"
	line "to a move's type.@"

TriAttackDescription:
	db   "Fires three kinds"
	line "of beams at once.@"

SuperFangDescription:
	db   "Cuts the foe's HP"
	line "by 1/2.@"

SlashDescription:
	db   "Has a high criti-"
	line "cal hit ratio.@"

SubstituteDescription:
	db   "Makes a decoy with"
	line "1/4 user's max HP.@"

StruggleDescription:
	db   "Used only if all"
	line "PP are exhausted.@"

SketchDescription:
	db   "Copies the foe's"
	line "move permanently.@"


ThiefDescription:
	db   "An attack that may"
	line "steal a held item.@"



NightmareDescription:
	db   "A sleeper loses"
	line "1/4 HP every turn.@"

FlameWheelDescription:
	db   "An attack that may"
	line "cause a burn.@"


CurseDescription:
	db   "Works differently"
	line "for ghost-types.@"

FlailDescription:
	db   "Stronger if the"
	line "user's HP is low.@"

Conversion2Description:
	db   "The user's type is"
	line "made resistant.@"

AeroblastDescription:
	db   "A vacuum blast"
	line "that may flinch.@"


ReversalDescription:
	db   "Stronger if the"
	line "user's HP is low.@"

SpiteDescription:
	db   "Cuts the PP of the"
	line "foe's last move.@"

PowderSnowDescription:
	db   "An attack that may"
	line "cause frostbite.@"

ProtectDescription:
	db   "Foils attack that"
	line "turn. It may fail.@"

MachPunchDescription:
	db   "A fast punch that"
	line "lands first.@"

ScaryFaceDescription:
	db   "Sharply reduces"
	line "the foe's SPEED.@"

FaintAttackDescription:
	db   "An attack that"
	line "never misses.@"

SweetKissDescription:
	db   "A move that causes"
	line "confusion.@"

BellyDrumDescription:
	db   "Reduces own HP to"
	line "maximize ATTACK.@"

SludgeBombDescription:
	db   "An attack that may"
	line "poison the foe.@"

MudSlapDescription:
	db   "Reduces the foe's"
	line "accuracy.@"

OctazookaDescription:
	db   "An attack that may"
	line "reduce accuracy.@"

SpikesDescription:
	db   "Hurts foes when"
	line "they switch out.@"

ZapCannonDescription:
	db   "An attack that"
	line "always paralyzes.@"

ForesightDescription:
	db   "Negates accuracy"
	line "reduction moves.@"

DestinyBondDescription:
	db   "The foe faints if"
	line "the user does.@"

PerishSongDescription:
	db   "Both user and foe"
	line "faint in 3 turns.@"

IcyWindDescription:
	db   "An icy attack that"
	line "lowers SPEED.@"

DetectDescription:
	db   "Evades attack that"
	line "turn. It may fail.@"


LockOnDescription:
	db   "Ensures the line"
	line "attack will hit.@"

OutrageDescription:
	db   "Works 2-3 turns"
	line "and confuses user.@"

SandstormDescription:
	db   "Inflicts damage"
	line "every turn.@"

GigaDrainDescription:
	db   "Steals 1/2 of the"
	line "damage inflicted.@"

EndureDescription:
	db   "Always leaves at"
	line "least 1HP.@"

CharmDescription:
	db   "Sharply lowers the"
	line "foe's ATTACK.@"

RolloutDescription:
	db   "Attacks 5 turns"
	line "with rising power.@"

FalseSwipeDescription:
	db   "Leaves the foe"
	line "with at least 1HP.@"

SwaggerDescription:
	db   "Causes confusion"
	line "and raises ATTACK.@"


SparkDescription:
	db   "An attack that may"
	line "cause paralysis.@"

FuryCutterDescription:
	db   "Successive hits"
	line "raise power.@"

SteelWingDescription:
	db   "Stiff wings strike"
	line "the foe.@"

MeanLookDescription:
	db   "Prevents fleeing"
	line "or switching.@"

AttractDescription:
	db   "Makes the opposite"
	line "gender infatuated.@"

SleepTalkDescription:
	db   "Randomly attacks"
	line "while asleep.@"

HealBellDescription:
	db   "Eliminates all"
	line "status problems.@"

ReturnDescription:
	db   "An attack that is"
	line "based on loyalty.@"

PresentDescription:
	db   "A bomb that may"
	line "restore HP.@"


SafeguardDescription:
	db   "Prevents all"
	line "status problems.@"

PainSplitDescription:
	db   "Adds user & foe's"
	line "HPs. Shares total.@"

SacredFireDescription:
	db   "May burn the foe."
	line "Makes it sunny.@"

MagnitudeDescription:
	db   "A ground attack"
	line "with random power.@"

DynamicpunchDescription:
	db   "An attack that"
	line "always confuses.@"

MegahornDescription:
	db   "A powerful charge"
	line "attack.@"

DragonbreathDescription:
	db   "A strong breath"
	line "attack.@"

BatonPassDescription:
	db   "Switches while"
	line "keeping effects.@"

EncoreDescription:
	db   "Makes the foe re-"
	line "peat 2-6 times.@"

PursuitDescription:
	db   "Heavily strikes"
	line "switching #MON.@"

RapidSpinDescription:
	db   "A high-speed"
	line "spinning attack.@"

SweetScentDescription:
	db   "Reduces the foe's"
	line "evasiveness.@"

IronTailDescription:
	db   "An attack that may"
	line "reduce DEFENSE.@"

MetalClawDescription:
	db   "An attack that may"
	line "up user's ATTACK.@"

VitalThrowDescription:
	db   "A 2nd-strike move"
	line "that never misses.@"

MorningSunDescription:
	db   "Restores HP"
	line "(varies by time).@"

SynthesisDescription:
	db   "Restores HP"
	line "(varies by time).@"

MoonlightDescription:
	db   "Restores HP"
	line "(varies by time).@"

HiddenPowerDescription:
	db   "The power varies"
	line "with the #MON.@"

CrossChopDescription:
	db   "Has a high criti-"
	line "cal hit ratio.@"

TwisterDescription:
	db   "Whips up a tornado"
	line "to attack.@"

RainDanceDescription:
	db   "Boosts water-type"
	line "moves for 5 turns.@"

SunnyDayDescription:
	db   "Boosts fire-type"
	line "moves for 5 turns.@"

CrunchDescription:
	db   "An attack that may"
	line "lower SPCL.DEF.@"

MirrorCoatDescription:
	db   "Counters a SPCL."
	line "ATK move double.@"

PsychUpDescription:
	db   "Copies the foe's"
	line "stat changes.@"

ExtremespeedDescription:
	db   "A powerful first-"
	line "strike move.@"

AncientpowerDescription:
	db   "An attack that may"
	line "raise all stats.@"

ShadowBallDescription:
	db   "An attack that may"
	line "lower SPCL.DEF.@"

FutureSightDescription:
	db   "An attack that"
	line "hits on 3rd turn.@"

RockSmashDescription:
	db   "An attack that may"
	line "lower DEFENSE.@"

WhirlpoolDescription:
	db   "Traps the foe for"
	line "2-5 turns.@"


MoonblastDescription:
	db   "An attack that may"
	line "lower SPCL.ATK.@"

PlayRoughDescription:
	db   "An attack that may"
	line "lower ATTACK.@"

WillOWispDescription:
	db   "A move that will"
	line "burn the foe."

SuddenChillDescription:
	db   "A move that will"
	line "freeze the foe."

HailDescription:
	db   "Inflicts damage"
	line "every turn.@"

DragonClawDescription:
	db   "Slashes with sharp"
	line "dragon claws.@"

DragonPulseDescription:
	db   "Fires a dragon"
	line "energy pulse.@"

AerialAceDescription:
	db   "A flying strike"
	line "that never misses.@"

AirSlashDescription:
	db   "Slashes with wings."
	line "May cause flinch.@"

BraveBirdDescription:
	db   "A reckless flying"
	line "tackle. Damages user.@"

ShadowClawDescription:
	db   "Slashes with a"
	line "shadow claw.@"

IronHeadDescription:
	db   "Strikes with iron"
	line "head. May flinch.@"

FlashCannonDescription:
	db   "Fires a steel beam."
	line "May lower SPCL.DEF.@"

BulletPunchDescription:
	db   "A fast steel punch"
	line "that strikes first.@"

StoneEdgeDescription:
	db   "Hurls sharp rocks"
	line "with great force.@"

PowerGemDescription:
	db   "Fires gem-like rays"
	line "at the foe.@"

RockBlastDescription:
	db   "Hurls rocks at the"
	line "foe 2-5 times.@"

EarthPowerDescription:
	db   "Taps the earth's"
	line "power. Lowers SPCL.DEF.@"

BulldozeDescription:
	db   "Stomps the ground."
	line "Lowers foe's SPEED.@"

IceShardDescription:
	db   "An ice shard thrown"
	line "to strike first.@"

IcicleCrashDescription:
	db   "Drops icicles on"
	line "foe. May cause flinch.@"

WildChargeDescription:
	db   "A wild electric"
	line "tackle. Damages user.@"

ScaldDescription:
	db   "Scalding water."
	line "May cause a burn.@"

AquaJetDescription:
	db   "A water strike"
	line "that goes first.@"

AquaTailDescription:
	db   "Strikes with tail"
	line "like a wave.@"

WaterPulseDescription:
	db   "A water pulse that"
	line "may cause confusion.@"

EnergyBallDescription:
	db   "A grass energy ball."
	line "May lower SPCL.DEF.@"

SeedBombDescription:
	db   "Explodes a barrage"
	line "of hard seeds.@"

PowerWhipDescription:
	db   "Violently whips the"
	line "foe with vines.@"

DrainPunchDescription:
	db   "A punch that steals"
	line "the foe's HP.@"

FocusBlastDescription:
	db   "Focuses power into"
	line "an intense blast.@"

XScissorDescription:
	db   "Slashes the foe"
	line "with crossed claws.@"

BugBuzzDescription:
	db   "A vibrating buzz"
	line "may lower SPCL.DEF.@"

DarkPulseDescription:
	db   "A dark pulse that"
	line "may cause flinching.@"

NightSlashDescription:
	db   "Slashes when the"
	line "foe lets its guard down.@"

AuraSphereDescription:
	db   "Strikes first and"
	line "never misses.@"

DazzlingGleamDescription:
	db   "Attacks with a"
	line "dazzling gleam.@"

DisarmVoiceDescription:
	db   "An attack that"
	line "never misses.@"

DrainKissDescription:
	db   "A kiss that drains"
	line "the foe's HP.@"

ZenHeadbuttDescription:
	db   "A focused headbutt."
	line "May cause flinching.@"

ExtrasensoryDescription:
	db   "Attacks with a"
	line "powerful 6th sense.@"

GunkShotDescription:
	db   "Shoots filthy junk"
	line "at the foe.@"

PoisonJabDescription:
	db   "A poisonous jab"
	line "that may poison.@"

HyperVoiceDescription:
	db   "A loud, echoing"
	line "voice attack.@"

HurricaneDescription:
	db   "Whips up a storm"
	line "that may confuse.@"

SheerColdDescription:
	db   "A one-hit KO that"
	line "brings hail.@"

InnerLightDescription:
	db   "Raises all stats"
	line "to the maximum.@"

EruptionDescription:
	db   "A fiery quake that"
	line "whips up sand.@"

StormCallDescription:
	db   "Calls lightning"
	line "and summons rain.@"

LifeDewDescription:
	db   "Fully heals user,"
	line "cures the party.@"

FaeBladeDescription:
	db   "A fey slash that"
	line "inflicts status.@"

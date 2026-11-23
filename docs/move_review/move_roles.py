import re, sys
sys.path.insert(0, "utils")
from trainer_lint import Source, Dex, parse_parties, strip

KEEP = "X_SCISSOR BUG_BUZZ DARK_PULSE DRAGON_PULSE WILD_CHARGE AIR_SLASH SHADOW_CLAW ENERGY_BALL POISON_JAB ZEN_HEADBUTT POWER_GEM".split()
CUT = ("HYPER_VOICE DRAIN_PUNCH FOCUS_BLAST BRAVE_BIRD AERIAL_ACE HURRICANE GUNK_SHOT BULLDOZE EARTH_POWER STONE_EDGE "
       "ROCK_BLAST IRON_HEAD BULLET_PUNCH FLASH_CANNON AQUA_TAIL AQUA_JET SCALD WATER_PULSE POWER_WHIP SEED_BOMB "
       "EXTRASENSORY ICICLE_CRASH ICE_SHARD DRAGON_CLAW NIGHT_SLASH PLAY_ROUGH MOONBLAST DAZZLING_GLEAM DRAIN_KISS DISARM_VOICE").split()
UBER = set("AURA_SPHERE SKY_ATTACK ERUPTION SACRED_FIRE LIFE_DEW STORM_CALL INNER_LIGHT SHEER_COLD AEROBLAST FAE_BLADE".split())
GONE = set(CUT) | UBER

src = Source()
dex = Dex(src)
files = [m.group(1) for m in re.finditer(r'INCLUDE\s+"(data/pokemon/base_stats/[^"]+)"', src.read("data/pokemon/base_stats.asm"))]
stats = {}
for sp, path in zip(dex.species, files):
    t = src.read(path)
    nums = [int(x) for x in re.search(r"db\s+(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+)", t).groups()]
    types = re.search(r"db (\w+), (\w+) ; type", t).groups()
    stats[sp] = (nums[1], nums[4], set(types))

effects = {}
for l in open("data/moves/moves.asm"):
    m = re.match(r"\tmove (\w+),\s*(\d+),\s*(\w+),\s*(\w+),\s*(\d+),\s*(\d+),\s*(\d+).*;(\w+)", l)
    if m:
        effects[m.group(8)] = (m.group(1).replace("EFFECT_", ""), int(m.group(5)), int(m.group(7)))

def can_learn(sp):
    s = {mv for _, mv in dex.learnset[sp]} | dex.tmhm[sp] | dex.tutor.get(sp, set())
    return s

def alt(sp, ty, cat, ex=None):
    best = sorted(((p, mv) for mv in can_learn(sp) if mv not in GONE and mv != ex
                   for (t, c, p) in [dex.moves[mv]] if t == ty and c == cat and p > 1), reverse=True)
    return f"{best[0][1]} {best[0][0]}" if best else "none"

trainers = parse_parties(src)
for mv in KEEP + CUT:
    ty, cat, pw = dex.moves[mv]
    eff, acc, ch = effects[mv]
    print(f"\n## {mv}  {ty} {cat} {pw}pw {acc}% {eff}{f' {ch}%' if ch else ''}")
    for sp in dex.species:
        lv = [l for l, m in dex.learnset[sp] if m == mv]
        if not lv and mv not in dex.tutor.get(sp, set()):
            continue
        atk, sat, types = stats[sp]
        how = ("Lv" + "/".join("evo" if l == 0 else str(l) for l in lv)) if lv else "tutor"
        lean = "phys" if atk > sat + 10 else "spec" if sat > atk + 10 else "mixed"
        stab = "STAB" if ty in types else "cov"
        print(f"  {sp:12} {how:7} {'/'.join(sorted(types)):18} atk {atk:3} sat {sat:3} {lean:5} {stab:4} alt={alt(sp, ty, cat, mv)}")
    users = [f"{tr['label']}:{m['species']}" for tr in trainers for m in tr['mons'] if m['moves'] and mv in m['moves']]
    if users:
        print("  parties:", ", ".join(users))

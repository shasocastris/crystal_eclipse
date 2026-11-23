# Pseudo-Abilities

Pseudo-abilities are species-specific passive effects that mimic Gen 3+ abilities without a formal ability system. They are hardcoded per Pokémon species and trigger via hooks in the overworld step counter, battle engine, or encounter logic.

## Design Decisions

- Fainted Pokémon still trigger field effects unless noted otherwise (consistent with Crystal Clear's Suction Cups/Compound Eyes).
- Step-based curing abilities hook into the existing 256-step tick used by `StepHappiness` in `engine/overworld/events.asm`.
- Pokémon lists are thematic/canon (matching the species that canonically received the ability in Gen 3+) and can be expanded.

---

## Field / Overworld Effects (from Crystal Clear)

### Pickup
**Effect:** Certain Pokémon have a small chance of finding a random item on each happiness step (every 256 steps).
**Pokémon:** Meowth, Aipom, Teddiursa, Phanpy, Murkrow, Swinub
**Hook:** `StepHappiness` or the 256-step tick in `engine/overworld/events.asm`

### Suction Cups
**Effect:** Increases fishing success chance from 50% to 80% when this Pokémon is in the first party slot, even while fainted.
**Pokémon:** Grimer, Muk, Octillery, Bellsprout, Weepinbell, Victreebel, Mr. Mime, Tangela, Ditto, Omanyte, Omastar, Teddiursa, Shuckle, Aipom, Politoed
**Hook:** `Fish` / `.Fish` in `engine/events/fish.asm` — modify the `Random` threshold check at the top of `.Fish`

### Compound Eyes
**Effect:** Increases the chance of wild Pokémon holding an item when this Pokémon is in the first party slot, even while fainted. Raises the 25% chance to 70% and the 8% chance to 20%.
**Pokémon:** Butterfree, Venonat, Venomoth, Yanma, Togepi, Togetic, Murkrow, Paras, Parasect, Spinarak, Ariados, Ledyba, Ledian
**Hook:** Wild Pokémon item assignment in the encounter setup logic

---

## Step-Based Status Curing

All of these hook into the 256-step tick in `engine/overworld/events.asm`. The curing Pokémon may be anywhere in the party (not required to be first slot). Whether fainted Pokémon trigger the effect is TBD.

### Flame Body
**Effect:** If a Fire-type Pokémon is in the party, frozen party members thaw after X steps.
**Pokémon:** Cyndaquil, Quilava, Typhlosion, Growlithe, Arcanine, Vulpix, Ninetales, Ponyta, Rapidash, Magmar, Flareon
**Note:** Flame Body was chosen over egg-hatching (no breeding in this hack). Fire thaws ice.

### Shed Skin
**Effect:** 1/3 chance each 256-step tick to cure any poisoned party member.
**Pokémon:** Ekans, Arbok, Dratini, Dragonair, Metapod, Kakuna
**Note:** Probabilistic rather than guaranteed, reflecting the Gen 3 in-battle version.

### Early Bird
**Effect:** Sleeping party members wake up after fewer steps when this Pokémon is in the party.
**Pokémon:** Noctowl, Doduo, Dodrio, Hoppip, Skiploom, Jumpluff, Ledyba, Ledian, Girafarig
**Note:** Exact step reduction TBD — halving the sleep duration is a reasonable starting point.

### Limber
**Effect:** Paralyzed party members recover after X steps when this Pokémon is in the party.
**Pokémon:** Persian, Hitmonchan, Hitmonlee, Hitmontop, Machop, Machoke, Machamp, Aipom
**Note:** Pokémon always in fluid motion; paralysis cannot take hold.

### Water Veil
**Effect:** Burned party members are cured after X steps when a Water Veil Pokémon is in the party.
**Pokémon:** Tentacool, Tentacruel, Marill, Azumarill, Goldeen, Seaking
**Note:** Water douses fire. Separate from Flame Body (which cures freeze, not burn).

---

## Other Field Effects

### Stench
**Effect:** Lowers the wild encounter rate when this Pokémon is in the first party slot.
**Pokémon:** Grimer, Muk, Koffing, Weezing, Gloom
**Hook:** Encounter rate check in the overworld step logic — reduce the encounter roll threshold.

### Illuminate
**Effect:** Raises the wild encounter rate when this Pokémon is in the first party slot.
**Pokémon:** Chinchou, Lanturn, Staryu, Starmie
**Hook:** Same as Stench but increases the encounter roll threshold.

---

## Battle Effects

### Run Away
**Effect:** This Pokémon can always escape from wild battles, bypassing trapping effects.
**Pokémon:** Eevee, Rattata, Raticate, Ponyta, Rapidash, Doduo, Dodrio, Sentret, Furret, Magikarp, Aipom
**Hook:** Flee attempt logic in the battle engine — skip the trap check for these species.

### Arena Trap / Shadow Tag
**Effect:** Wild Pokémon cannot flee when this Pokémon is on the field.
**Pokémon:** Diglett, Dugtrio (Arena Trap); Wobbuffet (Shadow Tag)
**Hook:** Wild Pokémon flee attempt — return "can't flee" for these matchups.

### Intimidate
**Effect:** Wild Pokémon below a certain level threshold flee immediately at the start of battle.
**Pokémon:** Gyarados, Arcanine, Snubbull, Granbull, Tyranitar
**Hook:** Battle start routine — check player lead species and wild Pokémon level, trigger flee if below threshold.
**Note:** Threshold TBD — likely ~10 levels below the Intimidate Pokémon's level.

### Frisk
**Effect:** The held item of the wild Pokémon is revealed at the start of battle before any action.
**Pokémon:** Gastly, Haunter, Gengar, Misdreavus
**Hook:** Battle start — display `wEnemyMonItem` if nonzero.

### Pressure
**Effect:** All of the wild Pokémon's stats (Attack, Defense, Special Attack, Special Defense, Speed, Evasion, Accuracy) are lowered by one stage at the start of battle.
**Pokémon:** Lugia, Ho-Oh, Entei, Raikou, Suicune, Mewtwo, Articuno, Zapdos, Moltres
**Hook:** Battle start — apply one-stage drop to all seven stat modifier slots for the enemy.
**Note:** Makes legendary encounters feel oppressive and distinct from ordinary battles.

# No Pokemon Center Design — Session Notes (2026-05-18/19)

Design exploration for a Pokemon game where Pokemon Centers are removed as the primary healing mechanic.

---

## Core Premise

Replace Pokemon Centers with a distributed system of field moves, items, rare landmarks, and NPC healers. PC box access still available at hotels / waypoints / inns — healing function removed entirely.

Goal: shift the game toward survival / resource management rather than treating healing as a free reset.

---

## HP Restoration

**Field moves (primary):**
- Milk Drink / Soft-Boiled: redistribute HP across the party rather than generating it. Makes a "healer" Pokemon a genuine party role.
- Synthesis / Moonlight / Morning Sun: weather-dependent options that reward world traversal.
- Rest: party-wide heal, but see the rest mechanic section below.

**Landmarks:**
- Hot springs as rare free full-heals. Mt. Silver is a strong candidate — remote, late-game, thematically appropriate. Sparse, not one per town.

**NPC healers:**
- Traveling doctors / nurses on major routes. Cost money. Since money is always grindable, this acts as a resource floor — the player is never truly stuck as long as they can win one battle.

---

## PP Restoration

The hardest resource to manage — invisible pressure that sneaks up on players.

- No reliable field source without Ethers / Elixirs.
- **Leppa Berry farming** becomes the primary loop: plant → tend → harvest.
- Leppa Berries should also be findable as hidden items in dungeons (not just purchasable) — one per major dungeon area as a floor.
- "Slack Off as field move" concept: one Pokemon meditates and restores its own move PP.
- A party at 0 PP across all moves can only Struggle (recoil damage every turn) → eventually faints → blackout. So Leppa availability is critical to avoid a slow, miserable lock.

---

## Status Curing

**Items:** Antidote, Burn Heal, etc. remain but are scarce.

**Berries:** Pecha (poison), Cheri (paralysis), Rawst (burn), etc. become the primary cure resource. Rewards exploration and farming.

**Field moves:**
- Heal Bell / Aromatherapy: party-wide cure, costs a move slot — the nuclear option.

**Pseudo-abilities (passive):**
- Poison immunity or between-battle cure
- Burn immunity (fire-type affinity)
- Paralysis immunity (Limber-style)
- Sleep immunity (Insomnia-style)
- General Shed Skin-style: chance to cure any status between battles

**Design implication:** Status is now genuinely threatening. Poison in a long dungeon with no Antidote can cascade into a blackout. Trainer/wild status moves go from flavor to real danger. Early Poison-type routes need careful resource density.

---

## Rest Mechanic

Party-wide full restore. **Once per day** (RTC-based — resets at midnight or 24h from last use; TBD).

**Encounter risk:** High chance of wild Pokemon encounter during rest. One party member stays awake as the **watch Pokemon**. The watch Pokemon handles the encounter(s) solo and does not get healed.

**Watch Pokemon strategic layer:**
- Who to leave on watch is a real decision: Speed (first strike), Bulk (absorb hits), or a pseudo-ability like "Vigilance" that reduces encounter chance.
- If the watch Pokemon faints → rest fails, daily use is burned.
- Watch Pokemon loses HP/PP that the resting party recovers — there's a cost even on a clean win.

**Items that interact with rest:**
- "Tent" / "Bedroll" consumable: eliminates encounter chance entirely. Rare, expensive, or craftable — a premium escape valve.
- Smoke Ball-style held item for the watch Pokemon: guarantees escape if overwhelmed.

**Day/night interaction:** Resting at night could carry lower encounter chance vs. midday (nocturnal instinct, less foot traffic). Fits Crystal's existing RTC.

**Alternate HP distribution idea:** Instead of the resting party healing fully, the watch Pokemon's HP is distributed evenly across the party. Makes the watcher's HP pool matter even more.

---

## Soft Lock Prevention

### Redesigned Blackout (non-negotiable baseline)

Instead of warping to the last Pokemon Center, the player wakes up at the last visited waypoint / hotel. Party healed to minimum viability. Money penalty. "Out of resources" becomes a loss with consequence, not an unrecoverable lock.

**Key world design requirement:** Every dungeon and route must have a reachable exit back to a waypoint. The player can always retreat.

### Emergency NPC Healers

NPC healers will heal for money even when the player has no items. Money is always grindable (win one battle with Struggle if needed), so this is a true floor. The player is never completely without recourse.

### Visible Desperation Warnings

Dialogue or UI that warns the player before entering deep areas if the party is in bad shape. Makes resource depletion the player's informed decision rather than a trap.

### Required Story Fights

Checkpoint heal before scripted required battles (rival fights, gym leaders, evil team bosses). These can't be avoided and can't be re-entered — a safety valve is necessary.

### Roguelite Alternative

Accept "out of resources" as a clean loss condition: reload your save. Valid design if:
- Communicated clearly upfront (this is a survival game)
- Dungeons are short enough that a reload isn't punishing
- Goes harder than typical Pokemon player expectations — a deliberate tone choice

---

## Depth and Secondary Issues

### Team Composition Pressure

Healer Pokemon (Chansey, Miltank) risk becoming near-mandatory. Mitigate by spreading healing coverage across enough species that no single Pokemon is required. Offensive power vs. self-sufficiency becomes a new team-building axis.

### Move Slot Economy

Dedicating a slot to Soft-Boiled is a real tradeoff against coverage. TM and move tutor access timing for healing moves becomes a meaningful design decision.

### Berry Ecosystem

Berries are underused in Crystal-era games; this design justifies building them out fully. Farming loop (plant / tend / harvest) has real payoff. Room for new berries: one that skips the watch encounter once, for example.

### Environmental Hazards

Poison swamps, sandstorm / hail routes, cold areas that drain resources during travel. These must be telegraphed clearly to feel fair rather than punishing. Adds consequence to world traversal.

### The Grinding Problem

Grinding battles cost resources under this system. Wild Pokemon that loosely level-scale to the party prevents grinding from becoming a resource arms race.

### Early Game Is the Hardest Problem

Starter has no healing moves, player has no money, no items. Must be addressed with at least one of:
- A generous starter item kit
- An early NPC who fills the "nurse" role temporarily
- A very forgiving first dungeon

First impressions matter most — a hard block in the first hour loses players before they understand the system.

### Narrative Justification

The world needs a reason for absent Pokemon Centers. Options:
- Centers exist in cities but not remote areas (most grounded)
- Centers destroyed/disabled by story events (Team Rocket, disaster)
- Player operates outside official channels (fugitive, explorer)

The reason shapes the game's tone significantly.

### Additional Mechanics to Explore

- **Pokemon morale/fatigue:** Prolonged poor condition degrades performance independently of HP. Rewards actually healing.
- **Rescue item (Mystery Dungeon-style):** Exit a dungeon at the cost of losing progress but retaining resources. Emergency escape valve.
- **Trainer healers:** Defeated trainers occasionally offer to patch up the player's team as a concession — gives money a rival in the "reward for winning" slot.

---

## Open Questions

- What does "once a day" mean mechanically? Real-time midnight? 24h cooldown? Reset on story beat?
- How does the watch mechanic interact with HM slaves that aren't combat-ready?
- Is this the whole game or a mode/toggle?
- Difficulty level: TBD (shelved).
- Does the watch Pokemon fight one encounter or potentially multiple?
- Can the watch Pokemon call for help (like wild encounters in Sun/Moon)?

# Branch 32: happiness-based obedience (research report)

**Branch state:** `32-add-obedience-checks` sits at `9a2f44528` with 0 commits of its own and is 626 commits behind `core`. Its `CheckObedience` is identical to core's. Start the branch fresh from `core` (or rebase it) rather than reusing it.

## 1. Current logic, `engine/battle/effect_commands.asm` (core)

`BattleCommand_CheckObedience` is at lines 603-882, with `IgnoreSleepOnly` at 884-909. It is at `0d:43aa`, in SECTION "Effect Commands" (main.asm:151). **Bank $0d has only $29 = 41 bytes free in both release and debug** (crystal_eclipse.map:194-197, _debug.map:197-200). Bank $0e next door has $e74 free.

**Gates. The mon always obeys if any of these is true:**
- It is the enemy's turn (605-607).
- It is charging (609-610).
- `wAlreadyDisobeyed` is already set (613-615).
- It is a link battle, via `wLinkMode` (622-624).
- It is a Battle Tower battle, via `wInBattleTowerBattle` (626-628).
- Its OT ID matches `wPlayerID`, 2 bytes, checked through `BattlePartyAttr MON_OT_ID` (632-641, `ret z`). Only the ID is compared, not the OT name.

Lines 617-618 (`xor a / ld [wAlreadyDisobeyed], a`) are dead code. `a` is already 0 and so is the variable, so these 4 bytes can be freed.

**Badge cap (643-668), Johto badges only:**

| Badge held | Obeys up to level |
|---|---|
| Rising | 101 (`MAX_LEVEL+1`, all levels) |
| Storm | 70 |
| Fog | 50 |
| Hive | 30 |
| None | 10 |

This block is 29 bytes (`.obeylevel` $43d6 to `.getlevel` $43f3). The OT gate is 17 bytes.

**The roll (670-704):**
- `c` = cap, `d` = `wBattleMonLevel`, `b` = c+d (saturates at $ff).
- If `c >= d`, the mon obeys (690-692).
- Otherwise `.rand1` draws a uniform value in [0,b) by rejection (`BattleRandom`, `swap a`), and the mon obeys if it is below c. So **P(obey) = c/(c+d)**: about 50% at one level over the cap, falling as the level rises.

**Disobedience outcomes:**
1. **Sleeping:** `IgnoreSleepOnly` (708, 884-905). If the chosen move is Sleep Talk and the user is asleep, it prints `IgnoredSleepingText` and the turn ends. The comment mentions Snore, but SNORE no longer exists (constants/move_constants.asm has only SLEEP_TALK at :192), so the comment is stale. The list uses `dw` 16-bit indices through `CheckMoveInList`, so it survives move renumbering.
2. **Use another move:** a second roll `.rand2` (712-719). If it comes in below c, `.UseInstead` (778-869) picks a random other move that has PP and runs `DoMove`. It sets `wAlreadyDisobeyed` = 1, which makes `used_move_text.asm:47-52` print "instead,". It falls back to `.DoNothing` if the mon has one move, a Disabled move, or only one move with PP.
3. **Otherwise,** with b = d - c (levels over the cap):
   - **Nap** with chance b/256 (729-732, 743-753). It sets random sleep turns and prints `BeganToNapText`.
   - **Hurt itself** with chance about b/256 (734-741). It prints `WontObeyText` and calls `HitConfusion`.
   - **Do nothing** otherwise (755-772). It picks one of four texts at random: Loafing / WontObey / TurnedAway / IgnoredOrders.
4. **`.EndDisobedience`** (871-882) clears the last-move bytes, breaks Encore, and jumps to `EndMoveEffect`.

**Text:** data/text/battle.asm:519-553 (`LoafingAroundText`, `BeganToNapText`, `WontObeyText`, `TurnedAwayText`, `IgnoredOrdersText`, `IgnoredSleepingText`). This file is in bank $20 (`20:50d7`), which has $ed free in release and $d2 in debug.

**Other users of `wAlreadyDisobeyed`:** effect_commands.asm:124 (reset each turn), 5507 (`IgnoredOrders2Text` when charging), 6307; core.asm:1654 (Future Sight).

**map_objects.asm match:** `MovementFunction_ObeyDPad` (engine/overworld/map_objects.asm:530, 608-610), the player's D-pad-driven sprite movement (`SPRITEMOVEFN_OBEY_DPAD`, data/sprites/map_objects.asm:94). **It has nothing to do with obedience.**

## 2. Open design questions and recommended defaults

| Question | Recommendation |
|---|---|
| All player mons, or only traded ones? | **All player mons.** "Instead of the badge check" means happiness replaces the gate. If it only applied to traded mons, it would barely matter. |
| Below level 25? | **Always obey.** |
| Thresholds | **A step function**, written as an obedience cap so the vanilla roll is reused unchanged: happiness ≥220 → cap 101; ≥160 → cap 54; ≥110 → cap 39; otherwise cap 24. That gives exactly "levels 25-39 need 110, 40-54 need 160, 55+ need 220" (`cp d / ret nc` obeys when level ≤ cap). |
| Below the threshold | **Keep vanilla's probabilistic roll** (c/(c+d), plus nap/hurt chances scaled by levels over the cap). It costs 0 new bytes. A hard "always disobey" rule makes mons that fall just short unusable. Scaling by the happiness shortfall needs new arithmetic in a bank with 41 bytes free. |
| Keep the badge check for traded mons? | **No, drop it.** Traded and NPC-trade mons arrive at 70 happiness, so for anything at level 25+ the happiness gate is already stricter than the badge gate. Dropping both blocks frees about 20 bytes, which branch 39 may need in bank $0d (see §4). If shasocastris wants to keep it: compute the badge cap in `e` only when the OT ID doesn't match, and take min(c, e). That costs about +30 net bytes, so it fits only just, or the routine moves to bank $0e behind a `farcall`. |
| Link / Battle Tower | **Keep the existing skips** at 622-628 (7 bytes). |
| Overworld field moves | **No change.** Obedience never gated field moves; HM use stays gated by badges. |
| Enemy side | **Unchanged** (605-607). |

## 3. Happiness economy in Eclipse (verified)

**Starting happiness:**
- `BASE_HAPPINESS` = 70 for every source (constants/pokemon_data_constants.asm:289): wild catches (core.asm:6482, move_mon.asm:226/289/745), gifts via `givepoke` (move_mon.asm:458), and NPC trades (`TryAddMonToParty`, npc_trade.asm:212).
- Base data has no per-species happiness.
- **Friend Ball** gives 200 (item_effects.asm:647-657, 709-714). It costs ¥400 in **MartAzalea** (marts.asm:89) and **MartSafari** (:434), and Kurt makes it too.
- There is no Luxury Ball and no Soothe Bell.
- There are no eggs. pseudo_abilities.md says "no breeding in this hack". Togepi is a plain `givepoke` (VioletPokecenter1F.asm:27).

**Gains and losses:** `ChangeHappiness` reads the table at data/events/happiness_changes.asm. The three numbers are the change when happiness is below 100 / below 200 / 200 or more.

| Event | Change | Notes |
|---|---|---|
| Level up | +5 / +3 / +2 | Also from Rare Candy (item_effects.asm:1439) |
| Level up at the catch location | +10 / +6 / +4 | `level_up_happiness.asm` |
| Vitamin | +5 / +3 / +2 | The EV system allows ~51 vitamins per mon (≤100 per stat, 510 total) |
| Gym leader battle | +3 / +2 / +1 | Non-fainted party (core.asm:8411) |
| Learned a move (TM, tutor, Safari tutor) | +1 | |
| Step | +1 / +1 / **+0** | Every 256 steps, events.asm:868-876. Eclipse changed vanilla's every-512 steps to ChangeHappiness (51cc114cd). **Steps can never pass 200.** |
| Restaurant, whole party | +10 / +6 / +4 | Daily, ¥9800 (OlivineRestaurant.asm, restaurant.asm; Eclipse 5f9e2dcb2) |
| Cianwood photo, one mon | +10 / +6 / +4 | Daily. It uses the `HAPPINESS_GROOMING` row (happiness_probabilities.asm), so `HAPPINESS_PHOTOGRAPH` is unused. |
| Daisy's grooming, one mon | +10 / +6 / +4 | Daily |
| Haircut brothers | about +2 to +10 | Daily |
| Faint | -1 | core.asm:2790 |
| Faint to a foe 30+ levels higher | -5 / -5 / -10 | |
| Poison faint | -5 / -5 / -10 | |
| Bitter herbs | -5 to -20 | |

**Where happiness is visible:**
- The 4th stats page (Orange page) shows "HAPPINESS:" with the raw number (stats_screen.asm:751, 823-846; commit 3d0ec2423).
- The Goldenrod Happiness Rater exists.
- The Fuchsia Sage requires the lead mon to have happiness ≥220 (FuchsiaPokemonGiver.asm:16-17).

**Return / Frustration:** power = happiness×10/25 and (255−h)×10/25 (move_effects/return.asm, frustration.asm). There is no interaction with obedience.

**Time to reach the thresholds, from a level-ups-only sim** (`/tmp/claude-1000/-home-bryan-Documents-Romhacks-crystal-eclipse/2d70e333-cae6-412c-bf2d-cf4827cd6419/scratchpad/happy_sim.py`):

| Mon | At L25 | At L40 | At L55 | At L70 |
|---|---|---|---|---|
| Starter (70 at L5) | 142 ✓ | 187 ✓ | **222 ✓ (barely)** | 252 |
| Wild catch at L30 (70) | | 112 ✗ (needs 160) | 157 ✗ | 202 ✗ |
| Wild catch at L40 (70) | | | 127 ✗ | 172 ✗ |
| Friend Ball catch at L40 (200) | | | 230 ✓ | |

- From 70, it takes 10 / 26 / 49 level-ups to reach 110 / 160 / 220.
- **The thresholds look tuned to a mon raised from L5.** A few faints, at -1 each, push a starter just under 220 at L55. A mon caught at L30 or higher at 70 happiness **never catches up through leveling alone.**
- Roughly estimated daily-routine yield for one mon (Daisy + photo + haircut + restaurant): about 35/day below 100, about 25/day from 100-199, about 13/day at 200+. Daisy needs Kanto access.
- So without a Friend Ball, a fresh L30+ catch needs about 1-4 in-game days of routines.
- Disobedience odds at 70 happiness: L30 → 44% obey, L60 → 29%, L70 → 26%.
- **The Friend Ball is the main mitigation and it's cheap (¥400 at Azalea).** That's probably acceptable as a design lever, but it makes Friend Ball the default ball for any mon at L25+.

**`docs/no_pokemon_center_design.md`:** no mention of happiness, Return, or obedience (grep). Any HP loss or fainting it adds feeds the -1 / -5 faint penalties *(inferred)*.

## 4. Interactions

**Gifts.** Gifts use the player's OT, so they always obey today. All arrive at 70:
- **Kangaskhan L60** (FuchsiaPokemonGiver.asm:31). The sage only gives it if your lead has 220 happiness, and then hands over a 70-happiness L60 mon, about 29% obedient. **Must fix:** set its happiness in the existing `SetKangaskhanMoves` callasm, or add a happiness argument to the gift.
- **Larvitar L40** (CeladonGameCornerPrizeRoom.asm:192), about 38% obedient.
- **Eevee L20, Dratini L15, Tyrogue L10, Spearow L10** (`RANDY_OT_ID`, move_mon.asm:1233), and the starters: no issue below 25.

**Debug party.** PlayersHouse2F.asm:164-198 gives Mewtwo / Mew / Lanturn at L100, others at 50, and Dratini at L54, all at 70. **That debug party will disobey.** Set happiness to 255 there, or skip the check under `IF DEF(_DEBUG)` *(recommended)*.

**NPC trades.** 14 entries, 7 of them Eclipse "Wonder" trades (data/events/npc_trades.asm). The received mon's level equals the given mon's level (npc_trade.asm:201-205), and happiness is 70. These are gated by happiness instead of badges, which is generally stricter.

**Branch 30** ("perfect" DV/EV mon events): 0 commits, no spec found in docs/memory. Recommend its gift mons be created at 255 happiness or with the player's OT plus happiness set, otherwise high-level perfect mons are unusable *(inferred)*.

**Branch 39** (memory says 2 WIP commits; core work is new moves and `EFFECT_SWITCH_HIT`, with Battle Core in bank $0f 3 bytes over):
- `BattleCommand_SwitchOut` is added to effect_commands.asm, i.e. **bank $0d**, so branch 39 competes for the same 41 bytes. Freeing about 20 bytes here helps.
- **Mewtwo is a static L70** (PokemonMansion.asm:42). At 70 happiness, P(obey) = 24/94 ≈ 26%. With a Friend Ball (200, cap 54), 54/124 ≈ 44%. It still needs +20, which is about 2 days of routines or 10 level-ups.
- Other legendaries in core: Articuno/Zapdos/Moltres L70, Ho-Oh L60, Suicune L50, Mew/Celebi L30. If they become tutors instead, that problem goes away, but Mewtwo needs a decision. Recommend a ball choice or a scripted happiness boost.
- Wild mons go up to L90 (johto_grass.asm).

**Branch 11** (link removal, 0 commits): `wLinkMode` is used at line 622 and also at events.asm:856 and effect_commands.asm:13/2130/6468. Keep the 4-byte check unless branch 11 deletes the variable outright. It is harmless either way.

**Branch 49** (pseudo-abilities): none touch obedience or happiness gain. Pickup / step-cures share the 256-step tick with `StepHappiness` (pseudo_abilities.md:8,16-18); edits there must keep the `farcall StepHappiness` path. Truant is not planned.

**Branch 24** (move renumbering): the obedience code references only `dw SLEEP_TALK` through the 16-bit `CheckMoveInList`, so it is safe.

**Side findings (happiness-adjacent):**
- **Friendship-endure looks buggy** (effect_commands.asm:2137-2150). `cp 255/220/180` with `jr z` tests *equality*, and the fallthrough loads b = 12%+1, so **every player mon at any happiness gets a 12% endure.** That is almost certainly meant to be `jr nc`, with values below 180 skipping to `.focus_band`. The fix is 0-2 bytes in bank $0d. If this branch makes happiness matter more, fix it alongside.
- **The restaurant `.BuffHappiness` callasm is suspect** (OlivineRestaurant.asm:45-49). It calls `GetPokemonIDFromIndex` with hl = a WRAM address, which may allocate a junk species ID slot *(inferred; not traced)*. It looks like leftover code and is probably deletable.

## 5. Implementation plan

**A. Constants** (constants/pokemon_data_constants.asm, near :289):

```
DEF OBEY_HAPPINESS_1 EQU 110 ; obeys to OBEY_LEVEL_1
DEF OBEY_HAPPINESS_2 EQU 160
DEF OBEY_HAPPINESS_3 EQU 220
DEF OBEY_LEVEL_0 EQU 24
DEF OBEY_LEVEL_1 EQU 39
DEF OBEY_LEVEL_2 EQU 54
```

**B. effect_commands.asm:**
- Delete 617-618 (-4 bytes, optional).
- Delete the OT gate 630-641 (-17 bytes).
- Replace 643-668 (29 bytes) with the block below (26 bytes):

```
.obeylevel
	ld a, [wBattleMonHappiness]
	ld b, a
	cp OBEY_HAPPINESS_3
	ld a, MAX_LEVEL + 1
	jr nc, .getlevel
	ld a, b
	cp OBEY_HAPPINESS_2
	ld a, OBEY_LEVEL_2
	jr nc, .getlevel
	ld a, b
	cp OBEY_HAPPINESS_1
	ld a, OBEY_LEVEL_1
	jr nc, .getlevel
	ld a, OBEY_LEVEL_0
```

`ld` doesn't touch flags, and `b` is overwritten at 675. `.getlevel` onward (670-882) stays unchanged.

- **Net: about -20 bytes** (-24 with 617-618). The `.obeylevel` label can be dropped since nothing jumps to it any more.
- `wBattleMonHappiness` is kept live: it is loaded at switch-in (battle_struct mirrors the party *(inferred from vanilla)*), and updated by `ChangeHappiness` during battle when the active mon levels (happiness_egg.asm:69-76).

**C. Variant that keeps badges for foreign OT:** leave 630-641, but change `ret z` into a branch that skips the badge block. Compute the badge cap into `e`, then `ld a, e / cp c / jr nc / ld c, e` after the happiness cap. That is about +30 bytes, which is tight against 41 and fights branch 39. Prefer a `farcall` to a new helper in bank $0e if this variant is chosen.

**D. Text (optional):**
- The existing texts work as they are. For flavor, `WontObeyText` could become "doesn't trust you yet". Keep lines ≤18 chars, e.g. `text " doesn't"` / `line "trust you yet!"`.
- Bank $20 has $d2 free in debug.
- Consider a Happiness Rater or Sage line hinting that "a happy #MON listens better" (≤18 chars per line).

**E. Data and script fixes:**
- Kangaskhan gift happiness (FuchsiaPokemonGiver `SetKangaskhanMoves`).
- Larvitar prize happiness, or accept it as is.
- Debug party (PlayersHouse2F) at 255, or skip the check under `IF DEF(_DEBUG)`.
- Decide on Mewtwo per branch 39.

**F. Static verification:**
- `make` and `make crystal_debug`.
- Check that bank $0d free space in both .map files grew by about 20.
- Check `BattleCommand_CheckObedience` .sym offsets (`.checklevel` - start shrinks).
- Run the `utils/optimize.py` diff per AGENTS.md (the new `jr nc`s are all short).
- Grep that nothing else referenced `.obeylevel`.

**G. Python model (recommended, and cheap).** Mirror the asm exactly:
- The cap selection from happiness (the `cp` / `jr nc` chain, with carry semantics).
- `b = min(c+d, 255)`.
- The rand1 rejection loop with `swap a`.
- The rand2 / UseInstead / Nap / HitConfusion / DoNothing branches, with their thresholds.

Enumerate the full 256-value `BattleRandom` space for each roll, so the results are exact probabilities rather than Monte Carlo. Then:
- Sweep level 1-100 × happiness 0-255.
- Assert P(obey) = 1 exactly in the "always obey" region: L≤24 at any happiness, L≤39 with h≥110, L≤54 with h≥160, and all levels with h≥220.
- Emit a CSV or heatmap of obey / other-move / nap / hurt / loaf, so shasocastris can see the cliff at each boundary (about 50% at cap+1).
- Pair it with the happiness-growth sim above for the "starter vs. caught L30/L40/L60 vs. Friend Ball" trajectories, including fainting penalties and daily routines.

**Not verified:** play behaviour (no emulator; shasocastris must play-test), branch 30's design, branch 39's final legendary/Mewtwo plan, and the restaurant callasm side effect.

# v1.0 regression: items, evolution and economy

Tests: `docs/regression/harness/v10_items.py` (18 tests). Run with:

    CE_REPO=<tree> runner.py v10_items --rom <tree>/crystal_eclipse_debug.gbc --jobs 1

- **HEAD (1fb549fdf):** 18 pass, 0 fail. Report `reports/20261105-141744-de6bac77d41e`.
- **v0.9:** 3 pass, 13 fail, 2 skip. Report `reports/20261105-142034-ffdb7206c8d6`. Every v0.9 failure is a change the commits meant to make (see the table).

**No game bugs found.** Every commit in scope behaves as its commit message says.

## Tests

| Test | Checks | HEAD | v0.9 | Intended? |
|---|---|---|---|---|
| items_evo_changed_items | **Changed evolutions.** Razor Claw → Gliscor and Weavile, Protector → Rhyperior, Sun Stone → Sylveon, Dubious Disc → Porygon-Z. The old items now do nothing. The new items don't evolve the wrong species. Checked through `EvolvePokemon` and through the party menu's ABLE check (`DetermineEvolutionItemResults`). | pass | fail: Moon Stone/Sun Stone still evolve, new items don't | yes (0e9ae6837) |
| items_evo_item_sweep | **Every `EVOLVE_ITEM` entry in the source (49 at HEAD).** The forced item gives the species the table predicts: first match wins, region and location gates honoured. Checked both in-game and in the party menu. | pass | pass (51 entries) | n/a |
| items_evo_use_from_pack | **Using the item from the pack.** The real USE path is `DoItemEffect` → party menu → evolution scene. On a valid target the mon evolves and one item is used up. On a wrong target (Moon Stone on Gligar, Sun Stone on Rhydon) the game says it has no effect and the item is kept. The attribute rows are ITEM pocket and `ITEMMENU_PARTY`. | pass | fail (old mapping) | yes |
| items_loc_all_maps | **Location gate across all 427 maps**, plus 4 fake IDs that match only the group or only the number. Only ILEX_FOREST gives Leafeon and only ICE_PATH_B3F gives Glaceon. 102 maps share a group or number with one of them and none evolve. | pass | fail (no gate) | yes (ac5272006) |
| items_loc_battle_levelup | **Level-up in a real wild battle.** Eevee is 1 exp short and KOs a Rattata. It evolves and learns its evolution move in Ilex Forest and on B3F. It stays an Eevee on Route 34 and in the Ilex/Azalea gate. | pass | fail | yes |
| items_loc_rare_candy | **Rare Candy from the pack** on the same 4 maps. Same results as the battle test, and exactly one candy is used. | pass | fail | yes |
| items_loc_party_order_and_nonlead | **Two Eevees after one Ilex battle.** The one that levelled evolves; the one that didn't stays an Eevee. | pass | fail | yes |
| items_evo_move_full_moveset | **Evolution move with a full moveset.** An Eevee with 4 moves is asked to forget one for Razor Leaf. Answering No, then "stop learning", keeps all 4 moves. An Eevee that already knows Razor Leaf doesn't learn it a second time. | pass | fail (no Leafeon) | yes (a24fa4daf) |
| items_evo_move_table | **First learnset entry of each Eeveelution** (after `SkipEvolutions`): Leafeon, Glaceon and Sylveon have `LEARN_EVO_MOVE` first. The 5 older Eeveelutions are unchanged. | pass | fail | yes |
| items_balls_flags | **Item-ball flags.** Each of the 4 balls gives the right item. Each flag (630, 632, 634, 636) is unique among all event flags and is referenced only by its own map. In v0.9 these slots belonged to no flag (`const_skip`). No flag is set in the debug fixture, and all are below `NUM_EVENTS`. | pass | fail (no balls) | yes (c8628144b) |
| items_balls_reachable | **Static reachability** from the map's warps, using built-ROM blocks, tileset collision, permissions, ledges and blocking objects. See the HM summary below and the map drawings in `v10/items/ball_reach_ascii.txt`. | pass | fail | yes |
| items_balls_pickup | **Picking up each ball for real.** Warp next to it, face it, press A: the bag count goes up by 1 and the flag is set. Reloading the map doesn't hand it out again. | pass | fail | yes |
| items_mart_cap_unit | **Model check of `Buy_CapQuantityToMoney`** over 455 cases, against min(99, max(1, money // price)). Cases include zero money, exact money, one short, 999999, and prices where 99× the price overflows 16 bits (663+), 99× > 999999 (10102+), 65535 and 0. A starting quantity below the cap is never raised. | pass | skip (no routine) | n/a |
| items_mart_buy_e2e | **Buying at the Cherrygrove clerk** through the real menus. Exact money for 3: the selector tops out at 3 and buying 3 leaves ¥0. One short: tops out at 2. ¥0: tops out at 1 and buying says "not enough money" with nothing changed. ¥999999: 99. 99× price: buying 99 leaves ¥0. | pass | fail: always offers 99 | yes (d7954685a) |
| items_mart_tm_and_rooftop | **Every real price through the cap**, at ¥999999, at 3× the price and at ¥0. That is 87 standard-mart items (TMs, and decor up to 65000) and 13 rooftop-sale items. | pass | skip | n/a |
| items_repel_kinds | **Repel, Super Repel and Max Repel**, with no save involved. Using one stores kind 1/2/3 and 100/200/250 steps. Using a second while one is active is refused and not consumed. At wear-off, "Use another?" → Yes re-uses the same kind; No keeps the item and Repel ends. Using the last one removes it from the pocket. With none of that kind left but the other two in the bag, the game only says "wore off" (no prompt). | pass | fail: `wRepelType` holds the item ID (43…) | yes (da77fc591); re-use itself works in v0.9 too |
| items_debug_items_given | **Debug radio items.** Every `giveitem` in the debug radio script is in the bag with the right quantity. The item pocket uses 31 of 40 slots, so nothing was dropped (Star Piece ×10, Dubious Disc, Razor Claw ×2, Protector). | pass | pass | n/a (6e4015230, 709ce7532) |
| items_coach_star_piece | **Silver Cave coach.** The script is `SilverCavePokecenter1FCoachScript`; the coach itself predates v0.9. Yes → pick a mon → Yes takes exactly 1 Star Piece, sets max EVs and perfect DVs, and sets `ENGINE_PERFECT_MON_COACH`. A second talk the same day doesn't ask or charge. With no Star Piece the game says "You don't have a STAR PIECE." and no party menu opens. | pass | pass (test supplies the Star Pieces) | n/a |

**HMs needed to reach the new balls:**
- **No HM:** Safari Zone Protector (17,2), Seafoam Caves Razor Claw (5,5) and Rock Tunnel B1F Razor Claw (27,4).
- **Rock Smash:** Pokémon Mansion Dubious Disc (2,2) needs three rocks smashed: (27,12), (17,7) and (8,6). The Mewtwo area was already gated this way in v0.9, so this looks deliberate.

## Game bugs

None confirmed.

## Suspicious / notes (not confirmed bugs)

1. **Each new evolution item has exactly one source.** There is 1 Protector, 1 Dubious Disc and 2 Razor Claws (one for Gligar, one for Sneasel). Nothing else gives them: no mart, no wild held item, no NPC. All three are tossable and sellable (price 2100, `_CheckTossableItem` passes), so a player who sells or tosses one can never evolve that line. Consider making them `CANT_TOSS` or adding a second source. Severity: low, a design choice.
2. **Moon Ball side effect.** `MoonBallMultiplier` (engine/items/item_effects.asm:1007) asks `DetermineEvolutionItemResults` whether the species evolves by Moon Stone. Gligar, Sneasel and Eevee no longer do, so the Moon Ball loses its ×4 against them. This follows from the change; just be aware of it.
3. **Misleading comment in `CountItemInBag`** (home/item.asm:71). The comment says it returns the count in `a`, but `ld a, b` / `rst Bankswitch` clobber `a`; only `wBuffer1` holds the count. The only caller (engine/items/mart.asm:396) reads `wBuffer1`, so nothing is broken today. A future caller that trusts `a` would be.
4. **No in-game hint points to Ilex Forest for Leafeon.** Yuki on Ice Path B3F hints Glaceon. Kimono Girl Hana (Route 30) mentions Leafeon but not the forest. No text anywhere still mentions the old stone methods.

## Harness faults hit (fixed in my file, not game bugs)

- **Constant-name lookups.** Reverse lookups by value must keep the first name: Unown letter constants reuse species values (RAICHU showed up as UNOWN_Z).
- **`overworld.answer`** presses A 4 frames after `YesNoBox`, which is too early for the Mart's confirm box. I wait 30 frames first.
- **`Battle.turn`** returns False when the battle ends inside the turn. Use `stop='CleanUpBattleRAM'` rather than calling `finish()` afterwards.
- **`CountItemInBag`'s `a`** is useless (note 3); read `wBuffer1`.

## Not testable headlessly (for shasocastris's playthrough)

- Use each new item from the actual Pack screen and check the party menu shows ABLE/NOT ABLE correctly. I drove `DoItemEffect` directly, not the Pack UI.
- Walk to the Mansion Dubious Disc, smashing the three rocks, and check that each ball sprite and palette looks right on its map.
- Evolution animation and evolution-move text for Leafeon, Glaceon and Sylveon, by eye.
- The Mart quantity selector display at the capped value: the ×NN digits and the price shown as you scroll.

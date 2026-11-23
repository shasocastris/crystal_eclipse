# New Johto areas: hand-designed concepts

Eight concepts. Names are placeholders, and none of them takes a route number (HGSS already
used 47 and 48). "Johto-buildable" means every block is already in the 181-block Johto
tileset. **[BUILT]** means there is a block map in this folder.

There is room for them on the Johto map. The land south of Mt. Mortar and east of Route 37
is blank on the Town Map, and so is the land behind Route 30/31's eastern forest. Route 42
already has a south-edge alcove (blocks 13-14, row 8, where the three apricorn trees stand)
that touches the map's bottom edge. Move those trees and it becomes a south exit.

---

## 1. Orchard Road (route, 30x11) [BUILT]
**Hook:** an apricorn orchard with farm fences, where the route is the farm's lanes.
- **Layout:** you enter from the west on a raised meadow. A one-way grass ledge drops you onto
  the south lane. The middle third is the orchard: three tree rows (block 65) split by a
  north-south lane that runs from the farmhouse (2x2 wooden house) down to a south exit.
  The farmhouse yard has a white picket fence. At the east end is a fishing pond with
  forested banks. The east exit runs along its north shore.
- **Beats:** a Picnicker watches the meadow grass. A Bug Catcher looks west down the
  orchard aisle. A Youngster covers the south lane. A Fisher stands at the pond. Three
  apricorn fruit trees sit at the ends of the aisles; this hack adds new apricorn sources,
  and Kurt is already central to it. A Cut tree east of the pond guards an item and a hidden
  item. You can also reach that nook by Surfing across the pond, so either HM works. A
  hidden item sits beside the ledge.
- **Landmark:** the orchard rows. They are readable at a glance and look like nothing else
  in Johto.
- **Attach:** W to Route 37's east forest, E to Hearthhollow, S as a stub for later (toward
  the Dark Cave / Route 45 side).
- **Seasons:** the farmhouse NPC can comment on the harvest by season (`checkseason`). A
  winter render is included.

## 2. Hearthhollow (town, 20x16) [BUILT]
**Hook:** a hot-spring village at the south foot of Mt. Mortar. It has an inn instead of a
Pokémon Center, which fits the no-Center design notes (inns with a PC, a free hot spring).
- **Layout:** Mt. Mortar's cliff face runs along the north edge. A pass in it climbs to
  Route 42, and a cave mouth is a back door into Mt. Mortar. The upper terrace holds a wide
  Ecruteak-style inn (3x2), cherry trees, and a boulder-ringed hot spring. A ledge line
  separates it from the lower village, with one-way hops down and a gap at the main road.
  The lower village has two wooden houses, two small shops (tea house, etc.), flower beds
  and a stone foot-bath basin (block 82) under cherry trees.
- **Beats:** the spring heals your party for free (bg_event on the water, or an old man
  next to it). The inn keeps the PC. A Kimono Girl stands under the cherries, as a hook for
  the hack's Eeveelution kimono girls. A hidden item sits behind the inn, and an item ball
  at the end of the terrace ledge.
- **Weather:** the cherry blocks (ac) are COLL_CHERRY_LEAVES, so the existing
  cherry-blossom weather drops petals here with no extra work.
- **Attach:** N to Route 42 (open the fruit-tree alcove), W to Orchard Road, S stub,
  CAVE to Mt. Mortar.

## 3. Whisperwood Shrine (special area, 18x16) [BUILT]
**Hook:** a hidden grove behind a Cut tree. A straight stone approach between tree avenues
leads to a fenced courtyard with a spring basin, ringed by cherry trees.
- **Layout:** a Lake of Rage-style "woods made of small trees" border rather than solid
  forest. The central approach is flanked by tree avenues. A ledge band crosses the grove,
  with the approach as its only up-path. On the east side are a Cut-gated tall-grass pocket
  and a small fishing pond. The west side has tall grass and a hidden nook.
- **Beats:** a Sage and a Medium face the approach from both sides, so you must fight
  through. A Bug Catcher patrols the west grass. A shrine maiden stands at the basin.
  Hidden items are at the basin and in a dead-end corridor. A rare item sits behind the
  Cut tree.
- **Use:** a natural home for one of the "signature move" encounters, or a seasonal
  headliner (spring = cherry). It can also be a free heal point: the basin is a spring.
- **Attach:** off Route 30's east forest or Route 31's north edge, through a Cut tree.

## 4. Driftbank Ford (route, about 12x36, vertical)
**Hook:** a river route where the water runs *along* the route and you cross it three
times on stepping-stone shallows (boulders) and one long Surf stretch.
- **Layout:** a meandering river (58/59 banks, 79/7a inner corners) zig-zags down the map.
  The path crosses it at boulder fords (0a in the water, as on Route 42). The middle third
  is a Surf-only stretch with a small island holding an item.
- **Beats:** Fishers on each bank with long sightlines across the water. Swimmers in the
  Surf stretch. A ledge cascade on the east bank works as a one-way shortcut back down.
- **Johto-buildable:** yes, but there are no south-shore pieces. In Johto, water always
  meets trees or path flush, so do the same.
- **Attach:** between Route 37 and Route 38/39 (west), or as Hearthhollow's south exit.

## 5. Mortar Foothills (route, 30x9, mountain)
**Hook:** Route 42's rough sibling. A dirt mountain route of mesas, two cave mouths and a
Strength-boulder puzzle.
- **Layout:** Blackthorn/Route 42 mountain grammar: 71 dirt, 6a/70/6b mesa tops, 72 cliff
  faces, 73 caves, 81 cliff stairs. Two levels: the lower path is open, and the upper mesa
  is reachable only by a cliff staircase behind a Strength boulder (an object).
- **Beats:** Hikers and Blackbelts. One cave is a tiny side room with a TM. Rock Smash rocks
  (objects) hide items.
- **Attach:** links Hearthhollow's east side to Mahogany's south.

## 6. Pinefall Lake Campsite (special area, 20x14)
**Hook:** a lakeside campsite, a prototype for the "rest + watch" camping mechanic.
- **Layout:** a large irregular lake (Lake of Rage shoreline pieces) fills the north half.
  The south shore has a clearing with a ring of signs and boulders as tents and a fire
  pit, short boardwalk spits, and a fishing pier made from gate-house wood blocks
  (needs testing).
- **Beats:** camping NPCs who trade or teach. The rest/heal-at-a-cost mechanic. Night-only
  trainers. A Surf island with a hidden item.
- **Needs:** a real tent or campfire would need 2-4 new tiles. The rest is
  Johto-buildable.
- **Attach:** Lake of Rage's east shore (Route 43 side) or the end of Orchard Road's south
  stub.

## 7. Stoneway (route, 14x30, ruins)
**Hook:** an old processional road lined with gray stone walls, a cousin of the Ruins of
Alph.
- **Layout:** the gray fence pieces (40-46) form walled lanes. The Burned Tower rubble
  blocks (20/21) and the Ruins' stone well (82) make broken monuments. Tall grass grows
  through the paving.
- **Beats:** Psychics/Mediums. An Unown sign puzzle (bg_events) that opens a hidden item.
  It ties into the Alph shrine gate.
- **Attach:** Route 32's north-west, toward the Ruins.

## 8. Sunleaf Terraces (town, 20x18)
**Hook:** a tiered farming town cut into a hillside, with ledges as stepped terraces and a
berry-planting system.
- **Layout:** four terraces of soil (dirt 71) and grass, each reached by one gap. Ledges
  give fast one-way descents. A windmill would need new tiles. The Pokémon Center sits at
  the bottom and the farm house at the top.
- **Beats:** Leppa-berry farming (the no-PC design calls for findable Leppa sources). A
  "harvest each season" NPC.
- **Attach:** north of Violet, beyond Route 36's tree wall.

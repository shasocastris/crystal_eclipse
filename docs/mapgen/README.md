# Map-making tools (2026-10-28)

Experiments in making new maps. Untracked on purpose; nothing here touches the build.
**Resuming? Read `CONTEXT.md` first**: everything designed, tileset findings, open decisions and the integration checklist.
Open `gallery/index.html` for the comparison page with renders.

Everything needs `make` to have run once (the renderer reads built `.2bpp` tile graphics).

| Path | What it is |
|---|---|
| `render_ablk.py FILE.ablk W OUT.png [--ref Map] [--grid] [--scale 2] [--season S] [--time T]` | Renders any `.ablk` with real tiles and palettes. `--ref` borrows an existing map's tileset, group and environment. `--atlas OUT.png` draws every Johto block, labelled. |
| `handmade/amap.py FILE.amap` | Text-grid maps: one character per block plus `key X=hh` lines. Writes the `.ablk`, plain, grid and marked renders, and a walkability report; `--time nite --suffix _nite` (or `--season winter --suffix _winter`) adds a palette variant. Put `tileset NAME` before `key` lines for non-Johto maps. Doors are only checked when also listed as `exit` lines. Built maps: `orchard_road`, `hearthhollow`, `whisperwood`. Ideas: `concepts.md`. |
| `structured/structgen.py {forest,lake,town} --seed N [--w W --h H] [--out DIR]` | Layout-first generator: plans path, branches, gates, ponds and buildings, then autotiles Johto blocks. Writes `.ablk`, renders, a semantic PNG and a JSON of exits, events and checks. `adj.py` prints neighbour counts for a block. |
| `caves/gen.py SEED` | TILESET_CAVE generator: tunnel, cavern with lake, river, two floors with ladders. `final.py` regenerates the picked seeds; `mine.py` mines edge rules from vanilla caves. Writes into `caves/`. |
| `wfc/wfc.py ...` | Wave function collapse from existing maps. Kept as a record; not recommended. |
| `batch2/`, `batch3/` | Designed maps as `.amap` sources with renders. Batch 2: 12 outdoor maps and 2 mansions. Batch 3: 6 Goldenrod-style Johto Modern cities (`a/` Marigold, Sorrel; `b/` Cinderwick, Vellum; `c/` Morrowmere, Vespera). `batch3/a/tools/doors.py` lists door step coords. |
| `expand/` | Expanded vanilla maps (New Bark, Route 29, Cherrygrove) modelled on pokefollow's expanded Kanto; `README.md` there has the analysis. `render_other.py` renders other hacks' maps; `rough.py` makes forest edges ragged. |
| `icepath/` | Ice Path Hollow (2F, plus the river floor in `f1/`), a secret Ice Path dungeon behind Blackthorn's waterfall. Built, and hand-edited by shasocastris since, so `from_build.py MapName WIDTH DIR NAME` regenerates each `.amap` from the built map. `amap_ice.py FILE.amap` is amap with ice sliding and Rock Smash rocks; `trace.py` prints a route; `river.py` and `slides.py` check reachability and slide counts with Surf and Waterfall. `build.py` (sketch autotiler) and `water/apply.py` (wrote the first water blocks) are retired; old sketches are in `superseded/`. `water/mock.py` renders water mock-ups (PNGs only); `water/blocks_40_53.png` is the atlas of the water blocks as built. |
| `tooling/newmap.py NAME --size WxH --group G --landmark L ...` | Prints the snippets (with insert lines) for every file a new map touches. Never writes to the repo. `report.md` has the integration checklist and the bank-space pitfalls. |

Finish maps in Polished Map++ (`/usr/local/bin/polishedmap-plusplus`). Plain Polished Map drops the per-block attributes.

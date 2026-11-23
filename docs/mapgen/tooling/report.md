# Tooling & integration report (from the tooling agent; saved by the parent session)

- Polished Map++ 2.7.1 is installed at /usr/local/bin/polishedmap-plusplus and supports .ablk + *_attributes.bin. Plain Polished Map 4.7.1 (/usr/local/bin/polishedmap) does NOT: don't use it on this repo.
- PM++ finds the project root by walking up to main.asm/layout.link; reads size/tileset from map_constants + maps.asm; unregistered maps can be named Name.WxH.johto.ablk.
- It does not show seasonal/winter palettes: preview with render_ablk.py --season/--time.
- Tiled + converter: only worth it for large terrain jobs (stale atlas, no collision, second source of truth).

## New outdoor map checklist (from Valencia f6a18a33b / Shamouti 702b193c1)
1. constants/map_constants.asm: map_const at END of a group; (W+6)(H+6) <= 1300.
2. data/maps/maps.asm: header row; env TOWN/ROUTE (env gates weather/seasons/roofs/Dig).
3. data/maps/attributes.asm: map_attributes + connections N,S,W,E; mirror each on the neighbour. That bank is full to 1 byte (floating section).
4. data/maps/blocks.asm: INCBIN before last ENDSECTION; "Map Blocks 3" bank $2c has 5876 B free.
5. data/maps/scripts.asm + maps/<Name>.asm: "Map Scripts 29" (bank $08) has 2 B free, so start "Map Scripts 30".
6. scenes.asm only if scenes; missing scene_var fails silently; scene bytes can't be appended (reuse a dead one).
7. Landmarks: reuse if possible; ids are saved; region is decided by landmark range (one appended at the end counts as Orange).
8. Wild data: bank $0a has 10 B free and is fragile; seasonal tables in bank $75 are the lower-risk route (unverified).
9. New map group: roofs.asm, sgb_roof_pal_inds.asm, roofs.pal, roofs_winter.pal, MapGroupSizes in engine/events/weather.asm (all assert-checked).
10. Fly point: spawn/fly constants, spawn_points, flypoints, ENGINE_FLYPOINT_ at the end; shrink the reserved block after wVisitedSpawns.
11. Event flags: 29 const_skip slots remain; claim one.

Scaffold: newmap.py prints the snippets (never writes to the repo).

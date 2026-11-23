#!/usr/bin/env python3
"""Regenerate the four picked caves as best_*.ablk/.png/_reach.png and verify connectivity."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen
from cavelib import *

def coll_at(b, w, p): return quad_grid(b, w)[p[1]][p[0]]

g, b, w, wp = gen.winding_tunnel(7)
save('best_A_tunnel', b, w)
print('A tunnel', w, len(b)//w, 'warps', wp, 'roundtrip', strongly_connected(b, w, wp)); gen.report('best_A_tunnel', b, w, wp)

g, b, w, wp = gen.ca_cavern(7)
save('best_B_cavern_lake', b, w)
print('B cavern', w, len(b)//w, 'mat/mouth/stairs/plateau-item', wp, 'roundtrip', strongly_connected(b, w, wp)); gen.report('best_B_cavern_lake', b, w, wp)

g, b, w, wp = gen.river_cave(1)
save('best_C_river', b, w)
walk = bfs(b, w, {wp[0]}); surf = bfs(b, w, {wp[0]}, surf=True)
m = (wp[1][0], wp[1][1] + 1)
print('C river', w, len(b)//w, 'warps', wp, 'walk reaches mouth', m in walk, 'surf reaches mouth', m in surf)
overlay_reach('best_C_river', b, w, surf, wp)

(g1, b1, w1), (g2, b2, w2), w = gen.two_floor(9)
save('best_D_1F', b1, w); save('best_D_B1F', b2, w)
mat, mouth, lA, lB = w1
r = bfs(b1, w, {mat})
print('D 1F', w, len(b1)//w, 'mat', mat, 'mouth', mouth, 'ladderA', lA, 'ladderB', lB)
print('   1F from mat: ladderA', lA in r, 'ladderB', lB in r, 'mouth', (mouth[0], mouth[1]+1) in r)
r2 = bfs(b2, w, {lA}); print('   B1F ladderA->ladderB', lB in r2)
r3 = bfs(b1, w, {lB}); print('   1F from ladderB: mouth', (mouth[0], mouth[1]+1) in r3)
overlay_reach('best_D_1F', b1, w, r | r3, w1); overlay_reach('best_D_B1F', b2, w, r2, w2)

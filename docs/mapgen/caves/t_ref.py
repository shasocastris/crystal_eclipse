import os, sys; sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from cavelib import *
d=open(REPO+'/maps/UnionCave1F.ablk','rb').read()
warps=[(5,3),(3,37),(17,35),(17,7)]
r=bfs(d,10,set(warps))
print(len(r))
overlay_reach('t_unioncave1f',d,10,r,warps)

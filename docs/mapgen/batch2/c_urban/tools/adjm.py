#!/usr/bin/env python3
"""Neighbour miner for johto_modern maps. usage: adjm.py BLOCKHEX [...]"""
import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../../../../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import sys
from collections import Counter, defaultdict
R=f'{_REPO_ROOT}/maps/'
M={'GoldenrodCity':21,'AzaleaTown':20,'Route34':10,'Route33':10}
nb=defaultdict(lambda: defaultdict(Counter))
for m,w in M.items():
    d=open(R+m+'.ablk','rb').read(); h=len(d)//w
    for y in range(h):
        for x in range(w):
            b=d[y*w+x]
            for dn,(dx,dy) in {'R':(1,0),'L':(-1,0),'D':(0,1),'U':(0,-1)}.items():
                if 0<=x+dx<w and 0<=y+dy<h: nb[b][dn][d[(y+dy)*w+x+dx]]+=1
for a in sys.argv[1:]:
    b=int(a,16); print('%02x'%b)
    for dn in 'ULRD': print(' ',dn,' '.join('%02x:%d'%kv for kv in nb[b][dn].most_common(10)))

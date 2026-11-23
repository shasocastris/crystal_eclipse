import sys, os
D=os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, D)
import render_ablk as R
REPO=R.REPO
import re
def dims():
    d={}
    for l in open(REPO+'/constants/map_constants.asm'):
        m=re.match(r'\s*map_const\s+(\w+),\s*(\d+),\s*(\d+)',l)
        if m: d[m.group(1)]=(int(m.group(2)),int(m.group(3)))
    return d
def blockpaths():
    # label -> path
    lab={}; cur=[]
    for l in open(REPO+'/data/maps/blocks.asm'):
        m=re.match(r'(\w+)_Blocks:',l)
        if m: cur.append(m.group(1)); continue
        m=re.search(r'INCBIN\s+"([^"]+)"',l)
        if m:
            for c in cur: lab[c]=REPO+'/'+m.group(1)
            cur=[]
    return lab

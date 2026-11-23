import sys, collections, re
sys.argv = sys.argv[:1]
import tp
def passable(mapname, x, y):
    c = tp.coll(mapname, x, y)
    return c.startswith('LAND')
def bfs(mapname, start, goals, blocked):
    q = collections.deque([start]); seen = {start}
    while q:
        p = q.popleft()
        if p in goals: return True
        for dx, dy in ((1,0),(-1,0),(0,1),(0,-1)):
            n = (p[0]+dx, p[1]+dy)
            if n in seen or n in blocked or not passable(mapname, *n): continue
            seen.add(n); q.append(n)
    return False
M = 'Route38EcruteakGate'
objs = tp.objects(M)
print('grid:')
w, h = tp.dims[tp.MAPCONST[M]]
for y in range(2*h):
    print(''.join(('#' if not passable(M,x,y) else '.') for x in range(2*w)))
states = {
 'before_pryce': dict(EVENT_BEAT_PRYCE=0, EVENT_ECRUTEAK_WILD_HUNT=1, EVENT_ROUTE38_GATE_OFFICER=1),
 'after_pryce_hunt_pending': dict(EVENT_BEAT_PRYCE=1, EVENT_ECRUTEAK_WILD_HUNT=0, EVENT_ROUTE38_GATE_OFFICER=1),
 'after_hunt': dict(EVENT_BEAT_PRYCE=1, EVENT_ECRUTEAK_WILD_HUNT=1, EVENT_ROUTE38_GATE_OFFICER=0),
 'v09_before_pryce': None,
}
for name, st in states.items():
    if st is None: continue
    vis = [(o[0], o[1], o[3]) for o in objs if o[4] == '-1' or not st.get(o[4], 0)]
    blocked = {(x, y) for x, y, _ in vis}
    ok = bfs(M, (8, 4), {(1, 4), (1, 5)}, blocked) or bfs(M, (8, 5), {(1, 4), (1, 5)}, blocked)
    print(name, 'east->west passable:', ok, 'visible:', [s for _,_,s in vis])

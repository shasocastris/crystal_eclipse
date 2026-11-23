import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
# Standability around an object, read from the built ROM: map blocks + tileset collision + CollisionPermissionTable.
import re, sys
R = f'{_REPO_ROOT}/'
rom = open(R + 'crystal_eclipse_debug.gbc', 'rb').read()
sym = {}
for l in open(R + 'crystal_eclipse_debug.sym'):
    m = re.match(r'([0-9a-f]+):([0-9a-f]+) (\S+)', l)
    if m: sym[m.group(3)] = (int(m.group(1), 16), int(m.group(2), 16))
def off(name):
    b, a = sym[name]
    return a if b == 0 else b * 0x4000 + (a - 0x4000)
maps = {}
for l in open(R + 'data/maps/maps.asm'):
    m = re.match(r'\s*map (\w+),\s*TILESET_(\w+),', l)
    if m: maps[m.group(1)] = m.group(2)
dims = {}
for l in open(R + 'constants/map_constants.asm'):
    m = re.match(r'\s*map_const (\w+),\s*(\d+),\s*(\d+)', l)
    if m: dims[m.group(1)] = (int(m.group(2)), int(m.group(3)))
def camel(s): return ''.join(w.capitalize() for w in s.split('_'))
def snake(name): return re.sub(r'(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])', '_', name).upper()
perm = off('CollisionPermissionTable')
def coll(mapname, x, y):
    w, h = dims[MAPCONST[mapname]]
    if not (0 <= x < 2 * w and 0 <= y < 2 * h): return 'OOB'
    blk = rom[off(mapname + '_Blocks') + (y // 2) * w + x // 2]
    c = rom[off('Tileset' + camel(maps[mapname]) + 'Coll') + blk * 4 + (y % 2) * 2 + x % 2]
    p = rom[perm + c]
    kind = {0: 'LAND', 1: 'WATER', 0xf: 'WALL'}.get(p & 0xf, hex(p))
    return f'{kind}{"+TALK" if p & 0x10 else ""}(coll ${c:02x})'
MAPCONST = {}
for l in open(R + 'data/maps/attributes.asm'):
    m = re.match(r'\s*map_attributes (\w+), (\w+),', l)
    if m: MAPCONST[m.group(1)] = m.group(2)
def objects(mapname):
    out = []
    for l in open(R + f'maps/{mapname}.asm'):
        m = re.match(r'\s*object_event\s+(\d+),\s*(\d+),\s*(\w+),.*?,\s*(\w+),\s*(-?\w+)\s*$', l)
        if m: out.append((int(m.group(1)), int(m.group(2)), m.group(3), m.group(4), m.group(5)))
    return out
if __name__ == '__main__':
    mapname, x, y = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
    objs = objects(mapname)
    occ = {(o[0], o[1]): o[2] for o in objs}
    print(mapname, MAPCONST[mapname], dims[MAPCONST[mapname]], 'tileset', maps[mapname])
    for d, (dx, dy), face in (('above', (0, -1), 'DOWN'), ('below', (0, 1), 'UP'), ('left', (-1, 0), 'RIGHT'), ('right', (1, 0), 'LEFT')):
        t = (x + dx, y + dy)
        print(f'  {d:5} {t}: {coll(mapname, *t):22} face {face:5} {"OBJ " + occ[t] if t in occ else ""}')

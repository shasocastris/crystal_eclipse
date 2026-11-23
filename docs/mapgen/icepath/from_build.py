#!/usr/bin/env python3
"""from_build.py MapName WIDTH DIR NAME -- write DIR/NAME.amap from the BUILT map.

The built maps (maps/MapName.ablk + .asm) are the source of truth since shasocastris edits them by hand.
The grid comes from the .ablk, exits and objects from the .asm events; DIR/head.txt supplies the
header comments. Then run amap_ice.py (renders) and river.py (reachability) on the result.
"""
import os, re, sys
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
name, w, d, out = sys.argv[1], int(sys.argv[2]), os.path.join(HERE, sys.argv[3]), sys.argv[4]
data = open(f'{REPO}/maps/{name}.ablk', 'rb').read()
sym = {0x19: '#', 0x02: '.', 0x1f: 'i'}
CH = '0123456789abcdefghjklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
for b in data:
	if b not in sym:
		sym[b] = next(c for c in CH if c not in sym.values())
rows = [''.join(sym[b] for b in data[y * w:(y + 1) * w]) for y in range(len(data) // w)]
keys = [f'{c}={b:02x}' for b, c in sorted(sym.items())]
DIRS = {'DOWN': 'down', 'UP': 'up', 'LEFT': 'left', 'RIGHT': 'right'}
tail = []
for line in open(f'{REPO}/maps/{name}.asm'):
	parts = line.split(';')[0].strip().split(None, 1)
	a = [x.strip() for x in parts[1].split(',')] if len(parts) == 2 else []
	if line.strip().startswith('warp_event'):
		tail.append((0, f'exit W{sum(t[0] == 0 for t in tail) + 1}_{a[2]} {a[0]} {a[1]}'))
	elif line.strip().startswith('bg_event'):
		tail.append((2, f"obj {'hidden' if a[2] == 'BGEVENT_ITEM' else 'sign'} {a[0]} {a[1]} {a[3]}"))
	elif line.strip().startswith('object_event'):
		x, y, sprite, move, typ, rng, script = a[0], a[1], a[2], a[3], a[9], a[10], a[11]
		face = next((v for k, v in DIRS.items() if move.endswith(k)), 'down')
		if typ == 'OBJECTTYPE_TRAINER':
			tail.append((1, f'obj trainer {x} {y} {script} {face} {rng}'))
		elif typ == 'OBJECTTYPE_ITEMBALL':
			tail.append((1, f'obj item {x} {y} {script}'))
		elif sprite == 'SPRITE_ROCK':
			tail.append((1, f'obj rock {x} {y} {script}'))
		else:
			tail.append((1, f'obj npc {x} {y} {script} {face}'))
txt = open(os.path.join(d, 'head.txt')).read().rstrip('\n') + '\ntileset ice_path\nref IcePath1F\n'
for i in range(0, len(keys), 12):
	txt += 'key ' + ' '.join(keys[i:i + 12]) + '\n'
txt += 'grid:\n' + '\n'.join(rows) + '\nend\n' + '\n'.join(t for _, t in sorted(tail, key=lambda t: t[0])) + '\n'
open(os.path.join(d, out + '.amap'), 'w').write(txt)
print('wrote', os.path.join(sys.argv[3], out + '.amap'))

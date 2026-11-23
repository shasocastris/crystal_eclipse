"""Trigger every coord_event cutscene with a follower and report where it overlaps the follower.

python follower_sweep.py --rom <debug ROM> [--maps NewBarkTown,CherrygroveCity] [--out report.json]

For each coord_event script (first trigger tile with a clear approach), set the map's scene, warp two
tiles out, step once so the follower appears behind, step onto the trigger and drive the script
(B through text, yes to questions, win battles) while sampling object positions.
"""
import argparse
import json
import os
import re
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from gb import REPO  # noqa: E402
from consts import resolve  # noqa: E402
from fixtures import fixture  # noqa: E402
from follower_watch import Watch  # noqa: E402
from overworld import in_control  # noqa: E402
from v10_story import run_script, step  # noqa: E402
import overworld as ow  # noqa: E402

DIRS = {'up': (0, -1), 'down': (0, 1), 'left': (-1, 0), 'right': (1, 0)}


def load_tables():
    attrs = {}
    for l in open(os.path.join(REPO, 'data/maps/attributes.asm')):
        m = re.match(r'\s*map_attributes\s+(\w+),\s*(\w+),', l)
        if m:
            attrs[m.group(1)] = m.group(2)
    scenevar = {}
    for l in open(os.path.join(REPO, 'data/maps/scenes.asm')):
        m = re.match(r'\s*scene_var\s+(\w+),\s*(\w+)', l)
        if m:
            scenevar[m.group(1)] = m.group(2)
    tilesets = {}
    for l in open(os.path.join(REPO, 'data/maps/maps.asm')):
        m = re.match(r'\s*map (\w+),\s*TILESET_(\w+),', l)
        if m:
            tilesets[m.group(1)] = m.group(2)
    dims = {}
    for l in open(os.path.join(REPO, 'constants/map_constants.asm')):
        m = re.match(r'\s*map_const (\w+),\s*(\d+),\s*(\d+)', l)
        if m:
            dims[m.group(1)] = (int(m.group(2)), int(m.group(3)))
    return attrs, scenevar, tilesets, dims


def script_body(src, label):
    """Lines of a script from its label to the end of its block (next top-level label after an end)."""
    lines = src.split('\n')
    try:
        i = next(k for k, l in enumerate(lines) if l.startswith(label + ':'))
    except StopIteration:
        return ''
    out = []
    for l in lines[i + 1:]:
        if re.match(r'^[A-Za-z_]\w*:', l) and out and re.match(r'^\t(end|sjump|jumptext|jumpstd|return)\b', out[-1].strip() and '\t' + out[-1].strip() or ''):
            break
        out.append(l)
        if len(out) > 400:
            break
    return '\n'.join(out)


def object_scenes(name):
    """(x, y, script) for script objects whose script moves something."""
    src = open(os.path.join(REPO, 'maps', name + '.asm')).read()
    out = []
    for x, y, script in re.findall(r'^\s*object_event\s+(\d+),\s*(\d+),[^;\n]*OBJECTTYPE_SCRIPT,\s*\d+,\s*(\w+)', src, re.M):
        body = script_body(src, script)
        if re.search(r'\b(applymovement|follow)\b', body):
            out.append((int(x), int(y), script))
    return out


def entry_scenes(name):
    """(scene index, script) for scene scripts that sdefer something that moves."""
    src = open(os.path.join(REPO, 'maps', name + '.asm')).read()
    out = []
    for i, label in enumerate(re.findall(r'^\s*scene_script\s+(\w+),', src, re.M)):
        m = re.search(r'^%s:\n((?:\t.*\n)*?)\tend' % label, src, re.M)
        if not m:
            continue
        for target in re.findall(r'sdefer\s+(\w+)', m.group(1)):
            if re.search(r'\b(applymovement|follow)\b', script_body(src, target)):
                out.append((i, target))
    return out


def warps(name):
    src = open(os.path.join(REPO, 'maps', name + '.asm')).read()
    return [(int(x), int(y)) for x, y in re.findall(r'^\s*warp_event\s+(\d+),\s*(\d+),', src, re.M)]


def coord_events(name):
    src = open(os.path.join(REPO, 'maps', name + '.asm')).read()
    scenes = re.findall(r'^\s*scene_script\s+\w+,\s*(\w+)', src, re.M)
    out = []
    for x, y, sc, script in re.findall(r'^\s*coord_event\s+(\d+),\s*(\d+),\s*([\w-]+),\s*(\w+)', src, re.M):
        out.append((int(x), int(y), scenes.index(sc) if sc in scenes else None, script))
    return out


class Coll:
    def __init__(self, rom, sym, tilesets, dims):
        self.rom = open(rom, 'rb').read()
        self.sym = {}
        for l in open(sym):
            m = re.match(r'([0-9a-f]+):([0-9a-f]+) (\S+)', l)
            if m:
                self.sym[m.group(3)] = (int(m.group(1), 16), int(m.group(2), 16))
        self.tilesets, self.dims = tilesets, dims
        self.perm = self.off('CollisionPermissionTable')
        self._blocks = {}

    def off(self, name):
        b, a = self.sym[name]
        return a if b == 0 else b * 0x4000 + (a - 0x4000)

    def land(self, name, const, x, y):
        w, h = self.dims[const]
        if not (0 <= x < 2 * w and 0 <= y < 2 * h):
            return False
        want = ('Tileset' + self.tilesets[name].replace('_', '') + 'Coll').lower()
        label = next(k for k in self.sym if k.lower() == want)
        if name not in self._blocks:
            from mapblocks import map_blocks
            self._blocks[name] = map_blocks(self.rom, self.off(name + '_Blocks'), w * h, self.sym)
        blk = self._blocks[name][(y // 2) * w + x // 2]
        c = self.rom[self.off(label) + blk * 4 + (y % 2) * 2 + x % 2]
        return self.rom[self.perm + c] & 0xff == 0  # plain land, no talk/ledge flags


def approaches(coll, name, const, x, y, trig, objects):
    out = []
    for d, (dx, dy) in DIRS.items():
        n = 3 if objects else 2
        path = [(x - k * dx, y - k * dy) for k in range(n, 0, -1)]
        if all(coll.land(name, const, *p) and (objects or p not in trig) for p in path):
            out.append((d, (dx, dy)))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--rom', required=True)
    ap.add_argument('--maps')
    ap.add_argument('--entry', action='store_true', help='scenes that start on map entry')
    ap.add_argument('--all-dirs', action='store_true', help='try every approach, not just the first')
    ap.add_argument('--resume', action='store_true', help='keep and skip scenes already in --out')
    ap.add_argument('--objects', action='store_true', help='talk-triggered scripts instead of coord events')
    ap.add_argument('--out', default=os.path.join(HERE, '..', 'followers', 'sweep.json'))
    a = ap.parse_args()
    attrs, scenevar, tilesets, dims = load_tables()
    coll = Coll(a.rom, a.rom[:-4] + '.sym', tilesets, dims)
    kind = 'object_event ' if a.objects else 'sdefer ' if a.entry else 'coord_event '
    names = a.maps.split(',') if a.maps else sorted(n for n in attrs if os.path.exists(
        os.path.join(REPO, 'maps', n + '.asm')) and kind in open(os.path.join(REPO, 'maps', n + '.asm')).read())
    g = fixture('debug_party', rom=a.rom, render=True)
    base = g.state()
    report = json.load(open(a.out)) if a.resume and os.path.exists(a.out) else {}
    os.makedirs(os.path.dirname(a.out), exist_ok=True)
    if a.entry:
        from v10_story import raw_warp
        for name in names:
            const = attrs[name]
            if const not in scenevar:
                continue
            for sc, script in entry_scenes(name):
                for wx, wy in warps(name)[:2]:
                    key = '%s.%s.%d_%d' % (name, script, wx, wy)
                    if key in report:
                        continue
                    t0 = time.time()
                    g.load(base)
                    r = {'scene': sc, 'warp': (wx, wy)}
                    try:
                        w = Watch()
                        raw_warp(g, const, wx, wy, before=lambda g, sc=sc: g.write(scenevar[const], sc))
                        out = run_script(g, yes=[True] * 20, menu=[0] * 10, battle='win', max_steps=1500,
                                         tick=w.sample)
                        r['texts'] = len(out['texts'])
                        w.finish(g, max_presses=50)
                        r['overlaps'] = w.result()
                        r['end'] = (g.read('wXCoord'), g.read('wYCoord'), g.read('wObject1MapX') - 4,
                                    g.read('wObject1MapY') - 4, not g.read('wObject1Flags') & 1)
                        g.screenshot(os.path.join(os.path.dirname(a.out), 'sweep_%s.png' % key))
                    except Exception as e:
                        r['error'] = '%s: %s' % (type(e).__name__, str(e)[:300])
                    r['secs'] = round(time.time() - t0, 1)
                    report[key] = r
                    print(key, json.dumps(r, default=str), flush=True)
                    json.dump(report, open(a.out, 'w'), indent=1, default=str)
        return
    for name in names:
        const = attrs[name]
        if a.objects:
            src = open(os.path.join(REPO, 'maps', name + '.asm')).read()
            labels = re.findall(r'^\s*scene_script\s+(\w+),', src, re.M)
            noop = next((i for i, l in enumerate(labels) if 'noop' in l.lower()), None)
            evs = [(x, y, noop, sc) for x, y, sc in object_scenes(name)]
            trig = set()
        else:
            evs = coord_events(name)
            trig = {(x, y) for x, y, _, _ in evs}
        if not evs:
            continue
        done = set()
        todo = []
        for x, y, sc, script in evs:
            if script in done:
                continue
            try:
                found = approaches(coll, name, const, x, y, trig, a.objects)
            except Exception as e:
                report['%s.%s' % (name, script)] = {'skip': 'collision lookup: %s' % e}
                continue
            if not found:
                continue
            done.add(script)
            for d, delta in (found if a.all_dirs else found[:1]):
                todo.append((x, y, sc, script, d, delta))
        for script in {e[3] for e in evs} - done:
            report.setdefault('%s.%s' % (name, script), {'skip': 'no straight approach'})
        for x, y, sc, script, d, (dx, dy) in todo:
            key = '%s.%s' % (name, script) + ('.' + d if a.all_dirs else '')
            if key in report:
                continue
            n = 3 if a.objects else 2
            start = (x - n * dx, y - n * dy)
            t0 = time.time()
            g.load(base)
            r = {'trigger': (x, y), 'from': d}
            try:
                def before(g, sc=sc):
                    if sc is not None and const in scenevar:
                        g.write(scenevar[const], sc)
                ow.warp(g, const, start[0], start[1], before=before)
                for _ in range(n - 1):
                    step(g, d, script=False)
                    in_control(g, 30)
                r['follower_before'] = (g.read('wObject1MapX') - 4, g.read('wObject1MapY') - 4,
                                        not g.read('wObject1Flags') & 1)
                w = Watch()
                if a.objects:
                    ow.face(g, d)
                    g.press('a', hold=4, after=2)
                    fired = any(g.frames(1) or g.read('wScriptRunning') for _ in range(40))
                else:
                    fired = step(g, d)
                r['fired'] = fired
                if fired:
                    out = run_script(g, yes=[True] * 20, menu=[0] * 10, battle='win', max_steps=1500,
                                     tick=w.sample)
                    r['texts'] = len(out['texts'])
                    r['battles'] = len(out['battles'])
                    w.finish(g, max_presses=50)
                r['overlaps'] = w.result()
                r['samples'] = w.samples
                g.screenshot(os.path.join(os.path.dirname(a.out), 'sweep_%s.png' % key))
            except Exception as e:  # keep sweeping
                r['error'] = '%s: %s' % (type(e).__name__, str(e)[:300])
            r['secs'] = round(time.time() - t0, 1)
            report[key] = r
            print(key, json.dumps(r, default=str), flush=True)
            json.dump(report, open(a.out, 'w'), indent=1, default=str)


if __name__ == '__main__':
    main()

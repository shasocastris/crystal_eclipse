"""Watch the follower during a cutscene: report any moment it shares a tile with the player or a
visible NPC (an NPC or a push walking through it)."""
from overworld import in_control

N_STRUCTS = 13


def objects(g):
    base = g.addr('wPlayerStruct')
    stride = g.addr('wObject1Struct')[1] - base[1]
    off = {k: g.addr('wPlayer' + k)[1] - base[1] for k in ('MapObjectIndex', 'Flags', 'MapX', 'MapY')}
    raw = g.read('wPlayerStruct', stride * N_STRUCTS)
    out = []
    for i in range(N_STRUCTS):
        o = raw[i * stride:(i + 1) * stride]
        out.append({'i': i, 'sprite': o[0], 'idx': o[off['MapObjectIndex']],
                    'hidden': bool(o[off['Flags']] & 1), 'pos': (o[off['MapX']], o[off['MapY']])})
    return out


def overlaps(g):
    objs = objects(g)
    f = objs[1]
    if not f['sprite'] or f['hidden']:
        return []
    hits = []
    for o in objs:
        if o['i'] == 1 or not o['sprite'] or o['hidden'] or o['idx'] == 0xff:
            continue
        if o['pos'] == f['pos']:
            hits.append((o['i'], o['idx'], o['sprite'], f['pos']))
    return hits


class Watch:
    def __init__(self):
        self.hits = set()
        self.samples = 0

    def sample(self, g):
        self.samples += 1
        for h in overlaps(g):
            self.hits.add(h)

    def frames(self, g, n, every=4):
        for _ in range(0, n, every):
            g.frames(every)
            self.sample(g)

    def finish(self, g, key='b', max_presses=400):
        """Like overworld.finish, sampling between presses."""
        for _ in range(max_presses):
            self.frames(g, 8)
            if in_control(g, 6):
                return True
            g.press(key, hold=3, after=3)
        return False

    def result(self):
        return sorted(self.hits)

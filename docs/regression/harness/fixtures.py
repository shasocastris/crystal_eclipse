"""Save-state fixtures, rebuilt per ROM (a state holds PCs and banks, so it can't move between builds).

Cached under docs/regression/fixtures/<rom sha256 prefix>/.
"""
import hashlib
import os

from gb import Game, HERE

FIXDIR = os.path.join(HERE, '..', 'fixtures')


def rom_id(rom):
    with open(rom, 'rb') as f:
        return hashlib.sha256(f.read()).hexdigest()[:12]


def in_control(g, max_frames=20):
    """True once the overworld loop is polling for player input."""
    return g.run_until('PlayerEvents', max_frames)


def mash_until_control(g, key='a', limit=600):
    for _ in range(limit):
        if in_control(g):
            return True
        g.press(key, after=6)
    return False


def new_game(g):
    """Title -> New Game -> intro (default answers, typed name) -> bedroom, player in control."""
    g.run_until('MainMenu', 3000)
    g.press('a', after=30)
    if not mash_until_control(g):
        raise RuntimeError('new game: never reached the overworld')
    # let the map settle, then confirm we're in the player's room
    for _ in range(3):
        g.frames(30)
        in_control(g)
    return g


def debug_party(g):
    """Read the bedroom radio in the debug ROM: full debug party, badges and flags."""
    # radio is the bg_event at (3,1); stand at (3,2) facing up
    while g.read('wYCoord') > 2:
        g.press('up', hold=16, after=16)
        in_control(g)
    g.press('up', hold=2, after=8)
    g.press('a', after=10)
    if not mash_until_control(g):
        raise RuntimeError('debug party: script never returned control')
    if g.read('wPartyCount') != 6:
        raise RuntimeError('debug party: party count is %d' % g.read('wPartyCount'))
    return g


STEPS = {'new_game': [new_game], 'debug_party': [new_game, debug_party]}


def fixture(name, rom=None, render=False):
    """Return a Game positioned at fixture `name`, building and caching its state if needed."""
    g = Game(rom=rom, render=render)
    path = os.path.join(FIXDIR, rom_id(g.rom), name + '.state')
    if os.path.exists(path):
        with open(path, 'rb') as f:
            g.load(f.read())
        return g
    for step in STEPS[name]:
        step(g)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    tmp = '%s.%d.tmp' % (path, os.getpid())
    with open(tmp, 'wb') as f:
        f.write(g.state())
    os.replace(tmp, path)
    return g

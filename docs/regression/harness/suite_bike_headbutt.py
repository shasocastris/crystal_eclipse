"""Bike headbutt: ramming a headbutt tree on the BICYCLE, and the bike shop kid who mentions it."""
from consts import value
from game import mon_write, set_event
from overworld import answer, face, finish, in_control, party_moves, settle, wait_for, warp
from registry import check, test
from visual import screen_text

TREE_SPOT = ('ROUTE_29', 29, 7, 'down')  # tree at (29, 8)


def _strip_headbutt(g):
    hb = value('HEADBUTT')
    for slot in range(g.read('wPartyCount')):
        moves = party_moves(g, slot)
        if hb in moves:
            ids = [g.call('GetMoveIDFromIndex', hl=m)['a'] for m in moves if m and m != hb]
            mon_write(g, slot, 'MON_MOVES', (ids + [0, 0, 0, 0])[:4])


def _at_tree(g, bike):
    _strip_headbutt(g)
    name, x, y, d = TREE_SPOT
    warp(g, name, x, y)
    if bike:
        g.write('wPlayerState', value('PLAYER_BIKE'))
    settle(g)
    face(g, d)
    g.frames(2)
    g.press('a', hold=4, after=4)


@test('bike_headbutt')
def bike_rams_tree(g):
    """On the bike with no HEADBUTT in the party, A on a tree asks to ram it and shakes the tree."""
    _at_tree(g, bike=True)
    check(wait_for(g, 'YesNoBox', max_presses=60), 'no yes/no prompt at the tree')
    ask = screen_text(g)
    check('BICYCLE' in ask, 'prompt is not the bike prompt', screen=ask)
    answer(g, yes=True)
    rammed = ''
    for _ in range(40):  # the ram text is a prompt, so it waits on screen
        g.frames(10)
        if 'rammed' in screen_text(g):
            rammed = screen_text(g)
            break
    check(wait_for(g, 'ShakeHeadbuttTree', max_presses=60), 'tree never shook')
    check('rammed' in rammed, 'no ram text', screen=rammed)
    # either a battle or "Nope. Nothing" / item; get back to the overworld
    for _ in range(40):
        if finish(g, max_presses=50):
            break
        g.press('a', hold=3, after=3)
    check(in_control(g, 60), 'no control after ramming')
    return {'ask': ask.splitlines()[-5:], 'state': g.read('wPlayerState')}


@test('bike_headbutt')
def bike_decline_returns_control(g):
    """Answering NO leaves the player in control and on the bike."""
    _at_tree(g, bike=True)
    check(wait_for(g, 'YesNoBox', max_presses=60), 'no yes/no prompt at the tree')
    answer(g, yes=False)
    check(finish(g), 'no control after declining')
    check(g.read('wPlayerState') == value('PLAYER_BIKE'), 'fell off the bike', state=g.read('wPlayerState'))


@test('bike_headbutt')
def walking_without_headbutt_does_nothing(g):
    """On foot with no HEADBUTT, A on a tree still does nothing."""
    _at_tree(g, bike=False)
    check(not g.run_until('YesNoBox', 60), 'a prompt opened on foot without HEADBUTT')
    check(in_control(g, 30), 'lost control on foot')


@test('bike_headbutt')
def headbutt_mon_still_preferred(g):
    """With a HEADBUTT user in the party, the bike uses the normal HEADBUTT prompt."""
    mon_write(g, 0, 'MON_MOVES', [g.call('GetMoveIDFromIndex', hl=value('HEADBUTT'))['a'], 0, 0, 0])
    name, x, y, d = TREE_SPOT
    warp(g, name, x, y)
    g.write('wPlayerState', value('PLAYER_BIKE'))
    settle(g)
    face(g, d)
    g.frames(2)
    g.press('a', hold=4, after=4)
    check(wait_for(g, 'YesNoBox', max_presses=60), 'no yes/no prompt at the tree')
    ask = screen_text(g)
    check('HEADBUTT' in ask and 'BICYCLE' not in ask, 'wrong prompt with a HEADBUTT mon', screen=ask)
    answer(g, yes=False)
    check(finish(g), 'no control after declining')


def _talk_kid(g, got_bike):
    warp(g, 'GOLDENROD_BIKE_SHOP', 3, 5, before=lambda g: set_event(g, 'EVENT_GOT_BICYCLE', got_bike))
    face(g, 'right')
    g.frames(2)
    g.press('a', hold=4, after=4)
    pages = []
    for _ in range(12):
        g.frames(60)
        pages.append(screen_text(g))
        if in_control(g, 6):
            break
        g.press('a', hold=3, after=3)
    return pages


@test('bike_headbutt')
def bike_shop_kid(g):
    """The bike shop kid explains bike headbutting, then reacts once the player has a bike."""
    before = '\n'.join(_talk_kid(g, False))
    check('tree' in before and 'HEADBUTT' in before, 'kid never mentioned trees', screen=before)
    after = '\n'.join(_talk_kid(g, True))
    check('No fair' in after, 'kid has no got-bike line', screen=after)

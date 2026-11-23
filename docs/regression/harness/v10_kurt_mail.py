"""SAMUEL's MAIL at Kurt's house: Oak's Dragonite delivers the letter straight into the PC mailbox.

Talking to the Dragonite only gets a cry. Talking to Kurt stows the follower, shows the letter,
files it in the PC mailbox, walks the Dragonite out (4 down, right, down onto the mat) and brings
the follower back one step later.

Run: runner.py v10_kurt_mail -k samuels_mail --jobs 1
Screenshots go to docs/regression/v10/kurt_mail/.
"""
import os

import gb
from game import event, set_event
from overworld import face, in_control, warp
from registry import check, test
from v10_overworld import here, map_id, pos
from v10_suicune import resolve_events

EVID = os.path.join(gb.HERE, '..', 'v10', 'kurt_mail')
MAIL_LEN = 0x2f


def enc(text):
    out = []
    for ch in text:
        if ch == '|': out.append(0x4e)          # <NEXT>
        elif ch == '@': out.append(0x50)
        elif ch == ' ': out.append(0x7f)
        elif ch == '?': out.append(0xe6)
        elif ch.isdigit(): out.append(0xf6 + int(ch))
        elif ch.isupper(): out.append(0x80 + ord(ch) - ord('A'))
        else: out.append(0xa0 + ord(ch) - ord('a'))
    return out


def shot(g, name):
    os.makedirs(EVID, exist_ok=True)
    g.screenshot(os.path.join(EVID, name + '.png'))


def follower_out(g):
    return not g.read('wObject1Flags') & 1


def walk(g, d):
    g.press(d, hold=16, after=4)
    check(in_control(g, 60), 'stuck after a step', dir=d, at=pos(g))


def _mailbox(g):
    n = g.read('sMailboxCount')
    return n, [g.read('sMailboxes+%d' % (i * MAIL_LEN), MAIL_LEN) for i in range(n)]


def _setup(g, start, step_dir):
    set_event(g, 'EVENT_CLEARED_SLOWPOKE_WELL', True)
    set_event(g, 'EVENT_KURTS_HOUSE_DRAGONITE', False)
    warp(g, 'KURTS_HOUSE', *start)
    check(here(g) == map_id('KURTS_HOUSE'), 'warp failed', at=here(g))
    walk(g, step_dir)
    check(follower_out(g), 'no follower before talking', at=pos(g))


def _kurt(g, start, step_dir, talk_dir, tag):
    _setup(g, start, step_dir)
    n0, _ = _mailbox(g)
    shot(g, tag + '_1_before')
    face(g, talk_dir)
    g.frames(2)
    g.press('a', hold=4, after=4)
    saw_mail, stowed_at_mail = False, None
    for i in range(400):
        if g.run_until_any(['ReadAnyMail.loop'], 8) == 'ReadAnyMail.loop':
            saw_mail = True
            g.frames(30)
            shot(g, tag + '_2_mail_screen')
            g.press('b', hold=4, after=20)
            # ExitAllMenus redraws the map; the follower must still be in its ball
            for _ in range(3):
                g.press('b', hold=2, after=6)
            stowed_at_mail = not follower_out(g)
            for j in range(160):
                g.press('b', hold=2, after=6)
                if j % 2:
                    shot(g, '%s_3_walk_%03d' % (tag, j))
                if in_control(g, 1):
                    break
            break
        if in_control(g, 4):
            break
        g.press('b', hold=3, after=3)
    log = []
    check(resolve_events(g, log), 'stuck after the mail scene', at=pos(g))
    shot(g, tag + '_4_after')
    n1, slots = _mailbox(g)
    r = {'mail_screen': saw_mail, 'stowed_at_mail': stowed_at_mail, 'mailbox_before': n0,
         'mailbox_after': n1, 'dragonite_gone': event(g, 'EVENT_KURTS_HOUSE_DRAGONITE'),
         'follower_after_scene': follower_out(g), 'pos': pos(g)}
    check(saw_mail, 'mail screen never opened', **r)
    check(stowed_at_mail, 'follower was not in its ball during the scene', **r)
    check(n1 == n0 + 1, 'letter not added to the mailbox', **r)
    last = slots[-1]
    check(last[0x21:0x29] == enc('SAMUEL@@'), 'author is not SAMUEL', author=last[0x21:0x29], **r)
    check(last[:0x21] == enc('Catch all 26 and|who knows what?@'), 'message differs', message=last[:0x21], **r)
    check(last[MAIL_LEN - 1] != 0, 'mail type not set', **r)
    check(r['dragonite_gone'], 'Dragonite did not leave', **r)
    check(tuple(r['pos']) == (3, 3), 'player should end in front of Kurt, beside the Dragonite', **r)
    walk(g, {'up': 'down', 'left': 'right'}[talk_dir])
    r['follower_after_step'] = follower_out(g)
    shot(g, tag + '_5_follower_back')
    check(r['follower_after_step'], 'follower did not come back one step after', **r)
    return r


def _dragonite_only(g):
    """Talking to the Dragonite itself: a cry, no mail, it stays."""
    _setup(g, (2, 4), 'up')                     # now at (2,3), below it
    n0, _ = _mailbox(g)
    face(g, 'up')
    g.frames(2)
    g.press('a', hold=4, after=30)
    shot(g, 'a_dragonite_cry')
    log = []
    check(resolve_events(g, log), 'stuck after talking to the Dragonite', at=pos(g))
    n1, _ = _mailbox(g)
    r = {'mailbox_before': n0, 'mailbox_after': n1,
         'dragonite_hidden': event(g, 'EVENT_KURTS_HOUSE_DRAGONITE'), 'follower': follower_out(g)}
    check(n1 == n0 and not r['dragonite_hidden'], 'talking to the Dragonite should only cry', **r)
    check(r['follower'], 'talking to the Dragonite should leave the follower out', **r)
    return r


@test('v10_kurt_mail')
def samuels_mail_from_dragonite(g):
    g.render(True)
    base = g.state()
    out = {'dragonite': _dragonite_only(g)}
    g.load(base)
    out['kurt_below'] = _kurt(g, (3, 4), 'up', 'up', 'b_kurt_below')
    g.load(base)
    out['kurt_right'] = _kurt(g, (5, 2), 'left', 'left', 'c_kurt_right')
    return out

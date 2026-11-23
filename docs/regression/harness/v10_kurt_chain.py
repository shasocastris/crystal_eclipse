"""SAMUEL's MAIL, the whole chain: Route 42 Suicune scene -> Kurt's special call (outside only) ->
Kurt's house -> letter in the PC mailbox. Plus the full-mailbox path and the mail type after a save GC.

Imports v10_kurt_mail / v10_suicune / v10_overworld, so always pass -k:
    runner.py v10_kurt_chain -k kurt_chain --jobs 1
Screenshots go to docs/regression/v10/kurt_chain/.
"""
import os

import gb
from consts import resolve, value
from game import event, set_event, set_engine
from overworld import face, in_control, warp
from registry import check, test
from v10_kurt_mail import MAIL_LEN, enc, follower_out
from v10_overworld import here, map_id, pos
from v10_suicune import resolve_events
from visual import text_rows

EVID = os.path.join(gb.HERE, '..', 'v10', 'kurt_chain')
# scene_const values live in maps/Route42.asm (not visible to includes.asm): NOOP 0, SUICUNE 1
SCENE_ROUTE42_NOOP, SCENE_ROUTE42_SUICUNE = 0, 1


def shot(g, name):
    os.makedirs(EVID, exist_ok=True)
    g.screenshot(os.path.join(EVID, name + '.png'))


def screen(g):
    return '\n'.join(text_rows(g)[12:18])


# --- objects ---
def objects(g):
    v = resolve('OBJECT_LENGTH', 'OBJECT_SPRITE', 'OBJECT_MAP_X', 'OBJECT_MAP_Y', 'NUM_OBJECT_STRUCTS')
    out = []
    for i in range(v['NUM_OBJECT_STRUCTS']):
        b = i * v['OBJECT_LENGTH']
        spr = g.read('wObjectStructs+%d' % (b + v['OBJECT_SPRITE']))
        if spr:
            out.append((i, spr, g.read('wObjectStructs+%d' % (b + v['OBJECT_MAP_X'])) - 4,
                        g.read('wObjectStructs+%d' % (b + v['OBJECT_MAP_Y'])) - 4))
    return out


def dragonite(g):
    """(x, y) of the Dragonite's object struct, or None when it is not loaded."""
    spr = value('SPRITE_DRAGONITE')
    for i, s, x, y in objects(g):
        if s == spr and i:
            return (x, y)
    return None


# --- mailbox (SRAM) ---
def mailbox(g):
    n = g.read('sMailboxCount')
    return n, [g.read('sMailboxes+%d' % (i * MAIL_LEN), MAIL_LEN) for i in range(n)]


def filler(i, mail_type):
    msg = enc('Letter %d|keep me@' % i)
    msg += [0x50] * (0x21 - len(msg))
    return msg + enc('FILLER@@') + [0, 0, 0, 0, 0, mail_type]


def write_mailbox(g, letters):
    """Write the PC mailbox through the bus with SRAM opened by the game's own OpenSRAM."""
    bank, base = g.addr('sMailboxes')
    cb, cnt = g.addr('sMailboxCount')
    g.call('OpenSRAM', a=bank)
    flat = [b for l in letters for b in l]
    flat += [0] * (value('MAILBOX_CAPACITY') * MAIL_LEN - len(flat))
    g.write((-1, base), flat)
    g.write((-1, cnt), len(letters))
    g.call('CloseSRAM')
    n, got = mailbox(g)
    check(n == len(letters) and got == letters, 'mailbox write did not stick', n=n)


# --- movement with phone-call watch ---
def kurt_called(g):
    cc = g.read('wCallerContact', 2)
    return cc[0] == 0 and cc[1] == value('PHONECONTACT_KURT')


def step_watch(g, d, screens, tag=None):
    """One step; then press B through anything that starts (a call) until control returns."""
    g.write('wCallerContact', [0xff, 0xff])
    g.press(d, hold=16, after=4)
    rang = False
    for i in range(400):
        if in_control(g, 6):
            break
        s = screen(g)
        if not screens or screens[-1] != s:
            screens.append(s)
            if tag and 'KURT' in s:
                shot(g, '%s_call_%02d' % (tag, len(screens)))
        rang = True
        g.press('b', hold=3, after=3)
    else:
        check(False, 'stuck after a step', dir=d, at=pos(g), screen=screen(g))
    return {'kurt': kurt_called(g), 'interrupted': rang, 'pos': pos(g), 'map': here(g)}


def step_moved(g, dirs, screens, tag=None):
    """Step in the first direction of `dirs` that actually moves the player (a bump counts no step)."""
    for d in dirs:
        p0, m0 = pos(g), here(g)
        r = step_watch(g, d, screens, tag)
        if pos(g) != p0 and here(g) == m0:
            r['dir'] = d
            return r
    check(False, 'could not take a step', dirs=dirs, at=pos(g))


def talk_kurt(g, tag):
    """Face up from (3,3) and talk to Kurt; follow v10_kurt_mail's handling of the mail screen."""
    face(g, 'up')
    g.frames(2)
    g.press('a', hold=4, after=4)
    screens, saw_mail, stowed_seen = [], False, False
    for i in range(500):
        if g.run_until_any(['ReadAnyMail.loop'], 8) == 'ReadAnyMail.loop':
            saw_mail = True
            g.frames(30)
            shot(g, tag + '_mail_screen')
            g.press('b', hold=4, after=20)
            continue
        if not follower_out(g):
            stowed_seen = True
        s = screen(g)
        if not screens or screens[-1] != s:
            screens.append(s)
        if in_control(g, 4):
            break
        g.press('b', hold=3, after=3)
    check(resolve_events(g, []), 'stuck after talking to Kurt', at=pos(g), screen=screen(g))
    return {'mail_screen': saw_mail, 'stowed_seen': stowed_seen,
            'saw_full_text': any('MAILBOX' in s for s in screens) and any('full' in s for s in screens),
            'screens': len(screens)}


def _azalea_into_kurts(g, log):
    """From Azalea Town below Kurt's door, walk in and up to (3,3) under Kurt."""
    warp(g, 'AZALEA_TOWN', 9, 6)
    g.press('up', hold=16, after=4)
    check(resolve_events(g, log), 'stuck entering Kurt\'s house')
    check(here(g) == map_id('KURTS_HOUSE'), 'door did not lead into Kurt\'s house', at=here(g), pos=pos(g))
    arrive = pos(g)
    while pos(g)[1] > 3:
        y = pos(g)[1]
        g.press('up', hold=16, after=4)
        check(resolve_events(g, log), 'stuck walking to Kurt', at=pos(g))
        check(pos(g)[1] < y, 'blocked walking up to Kurt', at=pos(g))
    check(pos(g) == (3, 3), 'not under Kurt', at=pos(g), arrive=arrive)
    return arrive


def _common_flags(g):
    set_event(g, 'EVENT_CLEARED_SLOWPOKE_WELL', True)
    set_engine(g, 'ENGINE_KURT_MAKING_BALLS', False)


# ======================================================================================
# (a) Route 42 scene -> call -> Kurt's house
# ======================================================================================
@test('v10_kurt_chain')
def kurt_chain_route42_call_house(g):
    g.render(True)
    _common_flags(g)
    log, out = [], {}
    out['dragonite_flag_at_start'] = event(g, 'EVENT_KURTS_HOUSE_DRAGONITE')
    check(out['dragonite_flag_at_start'], 'new game should start with the Dragonite hidden')
    g.write('wSpecialPhoneCallID', 0)
    n0, slots0 = mailbox(g)

    # --- before the scene: no Dragonite in Kurt's house, talking to Kurt gives no mail ---
    warp(g, 'KURTS_HOUSE', 3, 4)
    out['dragonite_before_scene'] = dragonite(g)
    shot(g, 'a1_house_before_scene')
    check(out['dragonite_before_scene'] is None, 'Dragonite shown before the Route 42 scene', objs=objects(g))
    g.press('up', hold=16, after=4)
    check(resolve_events(g, log), 'stuck')
    r = talk_kurt(g, 'a1')
    check(not r['mail_screen'] and mailbox(g)[0] == n0, 'Kurt gave mail before the scene', **r)

    # --- the Route 42 scene, set up the way the Cianwood Suicune scene leaves it ---
    def before(g):
        g.write('wRoute42SceneID', SCENE_ROUTE42_SUICUNE)
        set_event(g, 'EVENT_SAW_SUICUNE_ON_ROUTE_42', False)
        set_event(g, 'EVENT_FOUGHT_UNOWN_S', False)
        g.write('wBugContestStartTime', [0x12, 0x34, 0x56, 0x78])
    base = g.state()
    hit = None
    for sx, sy, d in [(23, 14, 'right'), (25, 14, 'left'), (24, 13, 'down'), (24, 15, 'up')]:
        g.load(base)
        try:
            warp(g, 'ROUTE_42', sx, sy, before=before)
        except AssertionError:
            continue
        shot(g, 'a2_route42_before_%d_%d' % (sx, sy))
        g.press(d, hold=16, after=4)
        check(resolve_events(g, log, limit=1500), 'stuck in the Route 42 scene', at=pos(g))
        if event(g, 'EVENT_FOUGHT_UNOWN_S'):
            hit = (sx, sy, d)
            break
    check(hit, 'could not trigger the Route 42 Suicune scene from any side')
    out['bug_contest_time'] = g.read('wBugContestStartTime', 4)
    check(out['bug_contest_time'] == [0x12, 0x34, 0x56, 0x78],
          'specialphonecall wrote past wSpecialPhoneCallID', got=out['bug_contest_time'])
    shot(g, 'a3_route42_after_scene')
    out['scene_from'] = hit
    out['after_scene'] = {
        'scene_id': g.read('wRoute42SceneID'),
        'suicune_hidden': event(g, 'EVENT_SAW_SUICUNE_ON_ROUTE_42'),
        'unown_s_fought': event(g, 'EVENT_FOUGHT_UNOWN_S'),
        'dragonite_flag': event(g, 'EVENT_KURTS_HOUSE_DRAGONITE'),
        'call_id': g.read('wSpecialPhoneCallID'),
        'route36_suicune_cleared': not event(g, 'EVENT_SAW_SUICUNE_ON_ROUTE_36'),
        'pos': pos(g)}
    a = out['after_scene']
    check(a['scene_id'] == SCENE_ROUTE42_NOOP and a['suicune_hidden'] and a['unown_s_fought'],
          'scene aftermath wrong', **a)
    check(not a['dragonite_flag'], 'scene did not show the Dragonite', **a)
    check(a['call_id'] == value('SPECIALCALL_KURT'), 'Kurt call not queued', want=value('SPECIALCALL_KURT'), **a)
    after_scene = g.state()

    # --- (a1) the next step on Route 42 rings straight away ---
    screens = []
    # the follower stands on the tile we came from; step any other free way
    r = step_moved(g, ('right', 'down', 'up', 'left'), screens, 'a4_route42')
    out['route42_next_step'] = dict(r, call_id_after=g.read('wSpecialPhoneCallID'),
                                    text_kurt_here=any('KURT here' in s for s in screens),
                                    text_azalea=any('AZALEA' in s for s in screens))
    check(r['kurt'], 'Kurt did not call on the first step outside', screens=screens[-6:], **r)
    check(out['route42_next_step']['text_kurt_here'], 'call text not seen', screens=screens)
    check(g.read('wSpecialPhoneCallID') == 0, 'call still queued after it rang')

    # --- (a2) indoors: no call; then outside in Azalea it rings once; then Kurt's house ---
    g.load(after_scene)
    warp(g, 'KURTS_HOUSE', 3, 4)
    out['dragonite_after_scene'] = dragonite(g)
    shot(g, 'a5_house_dragonite_waiting')
    check(out['dragonite_after_scene'] == (2, 2), 'Dragonite not waiting at (2,2)', objs=objects(g))
    indoor = []
    for d in ('right', 'right', 'down', 'left', 'left', 'up'):
        indoor.append(step_watch(g, d, []))
    out['indoor_steps'] = indoor
    check(not any(s['kurt'] for s in indoor), 'Kurt called indoors', steps=indoor)
    check(g.read('wSpecialPhoneCallID') == value('SPECIALCALL_KURT'), 'call lost while indoors',
          call_id=g.read('wSpecialPhoneCallID'))

    warp(g, 'AZALEA_TOWN', 9, 6)
    screens = []
    r = step_moved(g, ('down', 'left', 'right'), screens, 'a6_azalea')
    out['azalea_first_step'] = r
    check(r['kurt'] and any('KURT here' in s for s in screens), 'Kurt did not call in Azalea', screens=screens[-6:], **r)
    back = {'down': 'up', 'up': 'down', 'left': 'right', 'right': 'left'}[r['dir']]
    later = [step_moved(g, (back if k % 2 == 0 else r['dir'],), []) for k in range(6)]
    out['azalea_later_steps_kurt'] = [s['kurt'] for s in later]
    check(not any(s['kurt'] for s in later), 'Kurt called again', steps=later)

    # --- walk in through the door and get the letter ---
    n1, slots1 = mailbox(g)
    out['house_arrive'] = _azalea_into_kurts(g, log)
    check(dragonite(g) == (2, 2), 'Dragonite not there on arrival', objs=objects(g))
    shot(g, 'a7_under_kurt')
    r = talk_kurt(g, 'a8')
    n2, slots2 = mailbox(g)
    r.update(mailbox_before=n1, mailbox_after=n2, dragonite_flag=event(g, 'EVENT_KURTS_HOUSE_DRAGONITE'),
             dragonite_obj=dragonite(g), pos=pos(g), follower=follower_out(g))
    shot(g, 'a9_after_mail')
    out['mail'] = r
    check(r['mail_screen'], 'mail screen never opened', **r)
    check(n2 == n1 + 1 and slots2[:n1] == slots1, 'letter not appended cleanly', **r)
    check(slots2[-1][0x21:0x29] == enc('SAMUEL@@'), 'author is not SAMUEL', **r)
    check(r['dragonite_flag'] and r['dragonite_obj'] is None, 'Dragonite did not leave', **r)
    check(event(g, 'EVENT_GOT_SAMUELS_MAIL'), 'delivery did not set EVENT_GOT_SAMUELS_MAIL')
    g.press('down', hold=16, after=4)
    check(resolve_events(g, log), 'stuck after the scene')
    out['follower_after_step'] = follower_out(g)
    check(out['follower_after_step'], 'follower did not come back')
    # Kurt is back to normal afterwards
    g.press('up', hold=16, after=4)
    check(resolve_events(g, log), 'stuck')
    r2 = talk_kurt(g, 'a10_kurt_again')
    check(not r2['mail_screen'] and mailbox(g)[0] == n2, 'Kurt gave the letter twice', **r2)
    shot(g, 'a10_kurt_normal')
    return out


# ======================================================================================
# (b) Full mailbox: the Dragonite waits, nothing is lost, the follower comes back
# ======================================================================================
def _full_setup(g):
    _common_flags(g)
    set_event(g, 'EVENT_KURTS_HOUSE_DRAGONITE', False)
    t = g.call('GetItemIDFromIndex', hl=value('FLOWER_MAIL'))['a']
    letters = [filler(i + 1, t) for i in range(value('MAILBOX_CAPACITY'))]
    write_mailbox(g, letters)
    return letters


@test('v10_kurt_chain')
def kurt_chain_mailbox_full(g):
    g.render(True)
    log, out = [], {}
    letters = _full_setup(g)
    warp(g, 'KURTS_HOUSE', 3, 4)
    g.press('up', hold=16, after=4)
    check(resolve_events(g, log), 'stuck')
    check(follower_out(g), 'no follower before talking')
    shot(g, 'b1_before')
    base = g.state()

    r = talk_kurt(g, 'b2_full')
    n, got = mailbox(g)
    r.update(mailbox=n, unchanged=got == letters, dragonite_flag=event(g, 'EVENT_KURTS_HOUSE_DRAGONITE'),
             dragonite_obj=dragonite(g), pos=pos(g), follower_at_end=follower_out(g))
    shot(g, 'b2_full_after')
    out['full_1'] = r
    check(not r['mail_screen'], 'mail screen opened with a full mailbox', **r)
    check(r['saw_full_text'], 'no "MAILBOX is full" text', **r)
    check(r['unchanged'] and n == len(letters), 'mailbox changed', **r)
    check(not r['dragonite_flag'] and r['dragonite_obj'] is not None, 'Dragonite should wait', **r)
    check(r['stowed_seen'], 'follower was never stowed', **r)
    after_full = g.state()

    # follower: one step and it is back
    g.press('down', hold=16, after=4)
    check(resolve_events(g, log), 'stuck')
    out['follower_after_step'] = follower_out(g)
    shot(g, 'b3_follower_back')
    check(out['follower_after_step'], 'follower did not come back after the full-mailbox path')

    # --- retry in the same visit, mailbox still full: where does the Dragonite go? ---
    g.load(after_full)
    drift = [dragonite(g)]
    for k in range(3):
        rr = talk_kurt(g, 'b4_retry%d' % k)
        drift.append(dragonite(g))
        shot(g, 'b4_retry%d_after' % k)
        check(not rr['mail_screen'] and mailbox(g)[1] == letters, 'retry changed the mailbox', **rr)
    out['retry_dragonite_positions'] = drift
    out['retry_drift'] = len(set(drift)) > 1
    check(drift == [(2, 2)] * 4, 'Dragonite drifts on mailbox-full retries', positions=drift)

    # --- make room in the same visit (no map reload), then talk again ---
    g.load(after_full)
    g.call('DeleteMailFromPC', bc=0 << 8)
    rr = talk_kurt(g, 'b5_room_same_visit')
    n, got = mailbox(g)
    rr.update(mailbox=n, kept=got[:9] == letters[1:], last_author=got[-1][0x21:0x29] == enc('SAMUEL@@'),
              dragonite_flag=event(g, 'EVENT_KURTS_HOUSE_DRAGONITE'), dragonite_obj=dragonite(g), pos=pos(g))
    shot(g, 'b5_room_same_visit_after')
    out['room_same_visit'] = rr
    check(rr['mail_screen'] and rr['kept'] and rr['last_author'] and rr['dragonite_flag'],
          'making room in the same visit did not give the letter', **rr)
    check(rr['dragonite_obj'] is None, 'Dragonite did not walk out after a same-visit retry', **rr)

    # --- make room the real way round: leave, delete one letter, come back ---
    g.load(after_full)
    warp(g, 'AZALEA_TOWN', 9, 6)
    g.call('DeleteMailFromPC', bc=0 << 8)
    n, got = mailbox(g)
    check(n == 9 and got == letters[1:], 'DeleteMailFromPC did not shift the mailbox', n=n)
    _azalea_into_kurts(g, log)
    out['dragonite_on_return'] = dragonite(g)
    check(out['dragonite_on_return'] == (2, 2), 'Dragonite not back at (2,2)', objs=objects(g))
    rr = talk_kurt(g, 'b6_after_room')
    n, got = mailbox(g)
    rr.update(mailbox=n, kept=got[:9] == letters[1:], last=got[-1][:0x21] == enc('Catch all 26 and|who knows what?@'),
              dragonite_flag=event(g, 'EVENT_KURTS_HOUSE_DRAGONITE'), dragonite_obj=dragonite(g), pos=pos(g))
    shot(g, 'b6_after_room_after')
    out['after_room'] = rr
    check(rr['mail_screen'] and n == 10 and rr['kept'] and rr['last'], 'letter not delivered after making room', **rr)
    check(rr['dragonite_flag'] and rr['dragonite_obj'] is None, 'Dragonite did not leave', **rr)
    g.press('down', hold=16, after=4)
    check(resolve_events(g, log), 'stuck')
    out['follower_after_room'] = follower_out(g)
    check(out['follower_after_room'], 'follower did not come back after the letter')
    return out


# ======================================================================================
# (c) The letter's mail type is an 8-bit item ID; the save-time GC does not scan the mailbox
# ======================================================================================
@test('v10_kurt_chain')
def kurt_chain_mail_type_after_gc(g):
    g.render(True)
    _common_flags(g)
    set_event(g, 'EVENT_KURTS_HOUSE_DRAGONITE', False)
    write_mailbox(g, [])
    warp(g, 'KURTS_HOUSE', 3, 4)
    g.press('up', hold=16, after=4)
    check(resolve_events(g, []), 'stuck')
    r = talk_kurt(g, 'c1')
    n, got = mailbox(g)
    check(r['mail_screen'] and n == 1, 'letter not given', **r)
    mail_t = got[0][MAIL_LEN - 1]
    idx = lambda: g.call('GetItemIndexFromID', a=mail_t)['hl']
    out = {'type_id': mail_t, 'index_before': idx(), 'mirage_mail': value('MIRAGE_MAIL')}
    check(out['index_before'] == out['mirage_mail'], 'mail type is not MIRAGE_MAIL to begin with', **out)
    g.call('ForceGarbageCollection')            # what every save does (SaveIndexTables)
    out['index_after_gc'] = idx()
    mirage = value('MIRAGE_MAIL')
    for i in range(1, value('NUM_ITEMS') + 1):  # a long game touches many item types
        if i != mirage:
            g.call('GetItemIDFromIndex', hl=i)
    out['index_after_allocs'] = idx()
    out['mirage_id_now'] = g.call('GetItemIDFromIndex', hl=mirage)['a']
    check(out['index_after_allocs'] == mirage,
          'PC-mailbox mail type no longer maps to MIRAGE_MAIL after a save GC + item allocations', **out)
    return out


@test('v10_kurt_chain')
def kurt_chain_gc_restores_sram(g):
    """ForceGarbageCollection now opens the mail bank; it must leave SRAM as the caller had it."""
    out = {}
    g.call('CloseSRAM')
    g.call('ForceGarbageCollection')
    out['closed'] = g.read('hSRAMBank')
    g.call('OpenSRAM', a=1)
    g.call('ForceGarbageCollection')
    out['bank1'] = g.read('hSRAMBank')
    g.call('CloseSRAM')
    check(out == {'closed': 0xff, 'bank1': 1}, 'SRAM state not restored', out=out)
    return out


@test('v10_kurt_chain')
def kurt_chain_mail_species_after_gc(g):
    """A PC-mailbox letter's species byte is an 8-bit Pokémon ID; a save GC must keep it mapped."""
    sp = value('NUM_POKEMON')                  # last species: not in the debug party
    sid = g.call('GetPokemonIDFromIndex', hl=sp)['a']
    letter = filler(1, 0)
    letter[MAIL_LEN - 2] = sid
    write_mailbox(g, [letter])
    out = {'species': sp, 'id': sid}
    g.call('ForceGarbageCollection')            # what every save does
    for i in range(1, sp):                      # push it off the recent list, like a long game
        g.call('GetPokemonIDFromIndex', hl=i)
    g.call('ForceGarbageCollection')
    out['index_after_gc'] = g.call('GetPokemonIndexFromID', a=sid)['hl']
    check(out['index_after_gc'] == sp, 'mail species freed by the GC', **out)
    return out

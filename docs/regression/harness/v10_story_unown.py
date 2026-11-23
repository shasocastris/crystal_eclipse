"""v1.0 story regression, Unown in the story (Alph merge, plan section 3): TRAINERTYPE_DVS parties,
Archer's Unown A in the Slowpoke Well, Petrel's Unown Z and the Unown machine in the Rocket hideout,
the Suicune sightings' driven-off Unown, and the Wild Hunt's Unown W/T.

Run (imports v10_story, so always -k):
    flock <lock> timeout 1800 python3 -u runner.py v10_story_unown -k story_unown --jobs 1
Evidence: docs/regression/v10/story_unown/. Helper, not committed.
"""
import os
import re

import gb
from battle import fast_options
from consts import resolve, value
from game import engine, event, mon_word, rom_byte, set_engine, set_event, species_id
from overworld import answer, in_control, interact, warp
from registry import check, test
from v10_story import HUNT_STATES, inject, map_name, solo_party, step, text_label

SUITE = 'story_unown'
EVID = os.path.join(gb.HERE, '..', 'v10', 'story_unown')
NAME_END = 0x50  # '@'


def shot(g, name):
    os.makedirs(EVID, exist_ok=True)
    g.render(True)
    g.frames(2)
    g.screenshot(os.path.join(EVID, name + '.png'))
    g.render(False)


def _src(path):
    return open(os.path.join(gb.REPO, path)).read()


def obj_index(map_file, const):
    """Map object number of an object_const (object_const_def is const_def 2 in CSE)."""
    names = re.findall(r'^\s*const\s+(\w+)', _src('maps/%s.asm' % map_file).split('_MapScripts:')[0], re.M)
    return 2 + names.index(const)


def scene_index(map_file, scene):
    names = re.findall(r'scene_script\s+\w+,\s*(\w+)', _src('maps/%s.asm' % map_file))
    return names.index(scene)


def safe_call(g, label, **kw):
    """g.call from inside a running routine (battle menus): restore the registers afterwards."""
    regs = {r: g.reg(r) for r in ('af', 'bc', 'de', 'hl')}
    out = g.call(label, **kw)
    for r, v in regs.items():
        g.set_reg(r, v)
    return out


def species_of(g, rid):
    return safe_call(g, 'GetPokemonIndexFromID', a=rid)['hl'] if rid else 0


def item_of(g, rid):
    return safe_call(g, 'GetItemIndexFromID', a=rid)['hl'] if rid else 0


def unown_letter(dv):
    """GetUnownLetter in Python: middle two bits of each DV nibble, /10, 1-based."""
    a, b = dv
    v = ((a >> 5) & 3) << 6 | ((a >> 1) & 3) << 4 | ((b >> 5) & 3) << 2 | ((b >> 1) & 3)
    return v // (0xff // 26 + 1) + 1


def calc_stats(base, dv, level):
    """CalcMonStats with b = FALSE (no EVs): [HP, Atk, Def, Spd, SAtk, SDef]."""
    a, b = dv
    atk, df, spd, spc = a >> 4, a & 15, b >> 4, b & 15
    hp = (atk & 1) << 3 | (df & 1) << 2 | (spd & 1) << 1 | (spc & 1)
    out = []
    for i, d in enumerate((hp, atk, df, spd, spc, spc)):
        v = (base[i] + d) * 2 * level // 100 + (level + 10 if i == 0 else 5)
        out.append(min(v, 999))
    return out


def base_stats(g, species_const_value):
    rid = g.call('GetPokemonIDFromIndex', hl=species_const_value)['a']
    g.write('wCurSpecies', rid)
    g.call('GetBaseData')
    return g.read('wBaseStats', 6)


# --- battles ---------------------------------------------------------------------------------
def _snapshot(g):
    mode = g.read('wBattleMode')
    s = dict(mode=mode, type=g.read('wBattleType'), species=species_of(g, g.read('wEnemyMonSpecies')),
             level=g.read('wEnemyMonLevel'), dvs=g.read('wEnemyMonDVs', 2), letter=g.read('wUnownLetter'),
             item=item_of(g, g.read('wEnemyMonItem')), maxhp=g.read16('wEnemyMonMaxHP'),
             stats=[g.read16('wEnemyMonStats+%d' % (2 * i)) for i in range(5)],
             confused=bool(g.read('wEnemySubStatus3') >> value('SUBSTATUS_CONFUSED') & 1))
    if s['species'] == value('UNOWN'):
        g._unown_shots = getattr(g, '_unown_shots', 0) + 1
        shot(g, 'battle_unown_%d_%s_dv%02x%02x' % (g._unown_shots, mode, s['dvs'][0], s['dvs'][1]))
    if mode == 2:
        cur = g.read('wCurOTMon')
        s['slot'] = cur
        s['party_dvs'] = g.read('wOTPartyMon1DVs+%d' % (cur * value('PARTYMON_STRUCT_LENGTH')), 2)
        s['trainer_items'] = [item_of(g, g.read('wEnemyTrainerItem1')), item_of(g, g.read('wEnemyTrainerItem2'))]
    return s


def fight(g, win):
    """From StartBattle to CleanUpBattleRAM, recording each enemy mon at its first menu.
    win: foe at 1 HP and Normal-typed each menu; lose: ours at 1 HP with no PP (Struggle)."""
    fast_options(g)
    rec = {'mons': [], 'trainer': (g.read('wOtherTrainerClass'), g.read('wOtherTrainerID'))}
    seen = set()
    labels = ['LoadBattleMenu', 'CleanUpBattleRAM', 'PartyMenuSelect', 'YesNoBox']
    for _ in range(4000):
        hit = g.run_until_any(labels, 20)
        if hit is None:
            g.hold('a', True)
            hit = g.run_until_any(labels, 3)
            g.hold('a', False)
            if hit is None:
                continue
        if hit == 'CleanUpBattleRAM':
            rec['result'] = g.read('wBattleResult') & 3
            return rec
        if hit == 'PartyMenuSelect':
            alive = [i for i in range(g.read('wPartyCount')) if mon_word(g, i, 'MON_HP')]
            check(alive, 'switch menu with no mon left')
            g.frames(20)
            g.write('wMenuCursorY', alive[0] + 1)
            g.press('a', hold=4, after=20)
            continue
        if hit == 'YesNoBox':
            g.frames(4)
            g.press('b', hold=4, after=10)
            continue
        key = g.read('wCurOTMon') if g.read('wBattleMode') == 2 else 0
        if key not in seen:
            seen.add(key)
            rec['mons'].append(_snapshot(g))
        if win:
            g.write('wEnemyMonHP', [0, 1])
            g.write('wEnemyMonType', [0, 0])
            g.write('wBattleMonHP', g.read('wBattleMonMaxHP', 2))
        else:
            g.write('wBattleMonHP', [0, 1])
            g.write('wBattleMonPP', [0, 0, 0, 0])
            g.write('wEnemyMonHP', [0x27, 0x0f])
            g.write('wEnemyMonMaxHP', [0x27, 0x0f])
        g.hold('a', True)
        g.run_until_any(['CleanUpBattleRAM'], 3)
        g.hold('a', False)
    raise AssertionError('battle never ended')


def run_script(g, battles=(), yes=(), max_steps=1200):
    """v10_story.run_script with a per-battle outcome list and recorded enemy mons."""
    battles, yes = list(battles), list(yes)
    out = {'texts': [], 'battles': []}
    labels = ['MapTextbox', 'YesNoBox', 'StartBattle']
    for _ in range(max_steps):
        hit = g.run_until_any(labels, 6)
        if hit is None and not (g.read('wScriptRunning') == 0 and g.read('wMapStatus') == 2 and in_control(g, 6)):
            g.hold('b', True)
            hit = g.run_until_any(labels, 3)
            g.hold('b', False)
            if hit is None:
                continue
        if hit == 'MapTextbox':
            out['texts'].append(text_label(g))
            g.frames(1)
            continue
        if hit == 'YesNoBox':
            check(yes, 'unexpected yes/no box', texts=out['texts'][-3:])
            answer(g, yes.pop(0))
            continue
        if hit == 'StartBattle':
            check(battles, 'unexpected battle', texts=out['texts'][-3:])
            g.frames(1)
            r = fight(g, battles.pop(0) == 'win')
            r['map'] = map_name(g)
            out['battles'].append(r)
            continue
        if hit is None:
            break
    else:
        raise AssertionError('script never handed back control: %s' % out['texts'][-4:])
    out['pos'] = (g.read('wXCoord'), g.read('wYCoord'))
    out['map'] = map_name(g)
    return out


def flags(g, *names):
    return {n: event(g, n) for n in names}


def unlocked(g):
    return {s: engine(g, 'ENGINE_UNLOCKED_UNOWNS_' + s) for s in ('A_TO_K', 'L_TO_R', 'S_TO_W', 'X_TO_Z')}


def _talk_or_inject(g, direction, script, index):
    """Talk to the object in front; if no script starts (object moved, odd tile), queue its script."""
    interact(g, direction)
    for _ in range(30):
        g.frames(1)
        if g.read('wScriptRunning'):
            return 'talked'
    check(inject(g, script, index), 'script did not start', script=script)
    return 'injected'


# --- party data ------------------------------------------------------------------------------
def _rom(g):
    if not hasattr(g, '_rom'):
        with open(g.rom, 'rb') as f:
            g._rom = f.read()
    return g._rom


def _rb(g, bank, addr, n=1):
    off = addr if addr < 0x4000 else bank * 0x4000 + addr - 0x4000
    return list(_rom(g)[off:off + n])


def parse_rom_parties(g):
    """Every trainer party, walked from the ROM with the type-dependent entry size and checked
    against the list_item boundaries in the .sym. Returns ({(class, id): party}, problems)."""
    ncls = value('NUM_TRAINER_CLASSES')
    tb, ta = g.addr('TrainerGroups')
    rev = {}
    for name, loc in g.syms.items():
        if name.endswith('Group') and '.' not in name:
            rev[loc] = name
    f = resolve('TRAINERTYPE_MOVES_F', 'TRAINERTYPE_ITEM_F', 'TRAINERTYPE_DVS_F')
    parties, problems = {}, []
    for c in range(1, ncls + 1):
        bank, lo, hi = _rb(g, tb, ta + (c - 1) * 3, 3)
        loc = (bank, hi << 8 | lo)
        grp = rev.get(loc)
        if not grp:
            problems.append('class %d: no Group label at %02x:%04x' % (c, bank, loc[1]))
            continue
        items = []
        k = 0
        while '%s.__item%d' % (grp, k) in g.syms:
            items.append(g.syms['%s.__item%d' % (grp, k)][1])
            k += 1
        for tid in range(1, len(items)):
            start, end = items[tid - 1], items[tid]
            p = start
            ln = _rb(g, bank, p)[0]
            if ln != end - start:
                problems.append('%s %d: length byte %d, labels say %d' % (grp, tid, ln, end - start))
            p += 1
            name = []
            while _rb(g, bank, p)[0] != NAME_END and p < end:
                name.append(_rb(g, bank, p)[0])
                p += 1
            p += 1
            ttype = _rb(g, bank, p)[0]
            p += 1
            if ttype & ~0x07:
                problems.append('%s %d: unknown type bits %02x' % (grp, tid, ttype))
            mons = []
            while p < end:
                lvl = _rb(g, bank, p)[0]
                p += 1
                if lvl == 0xff:
                    break
                sp = _rb(g, bank, p, 2)
                p += 2
                m = dict(level=lvl, species=sp[0] | sp[1] << 8)
                if ttype >> f['TRAINERTYPE_DVS_F'] & 1:
                    m['dvs'] = _rb(g, bank, p, 2)
                    p += 2
                if ttype >> f['TRAINERTYPE_ITEM_F'] & 1:
                    it = _rb(g, bank, p, 2)
                    m['item'] = it[0] | it[1] << 8
                    p += 2
                if ttype >> f['TRAINERTYPE_MOVES_F'] & 1:
                    mv = _rb(g, bank, p, 8)
                    m['moves'] = [mv[2 * i] | mv[2 * i + 1] << 8 for i in range(4)]
                    p += 8
                mons.append(m)
            if p != end:
                problems.append('%s %d: walk ended at %04x, party ends at %04x' % (grp, tid, p, end))
            if not mons or len(mons) > 6:
                problems.append('%s %d: %d mons' % (grp, tid, len(mons)))
            for m in mons:
                if not 1 <= m['level'] <= 100:
                    problems.append('%s %d: level %d' % (grp, tid, m['level']))
            parties[(c, tid)] = dict(group=grp, type=ttype, mons=mons, bank=bank, start=start)
    return parties, problems


def parse_source_dvs_parties():
    """TRAINERTYPE_DVS parties straight from data/trainers/parties.asm: {(group, id): [mons]}."""
    out = {}
    grp, tid, cur = None, 0, None
    for raw in _src('data/trainers/parties.asm').splitlines():
        line = raw.split(';')[0].strip()
        m = re.match(r'^(\w+Group):$', line)
        if m:
            grp, tid, cur = m.group(1), 0, None
            continue
        if line.startswith('next_list_item'):
            tid += 1
            cur = None
            continue
        if line.startswith('db "') and 'TRAINERTYPE_DVS' in line.split(',', 1)[1]:
            cur = out.setdefault((grp, tid), [])
            continue
        if cur is None or not line:
            continue
        if re.match(r'^db\s+-1', line):
            cur = None
            continue
        m = re.match(r'^db\s+(\d+)$', line)
        if m:
            cur.append({'level': int(m.group(1))})
            continue
        m = re.match(r'^dw\s+(\w+)$', line)
        if m and 'species' not in cur[-1]:
            cur[-1]['species_name'] = m.group(1)
            cur[-1]['species'] = value(m.group(1))
            continue
        m = re.match(r'^dn\s+(\d+),\s*(\d+),\s*(\d+),\s*(\d+)$', line)
        if m:
            a, b, c, d = map(int, m.groups())
            cur[-1]['dvs'] = [a << 4 | b, c << 4 | d]
            continue
        m = re.match(r'^unown_dvs\s+(\w)$', line)
        if m:
            v = resolve('ATKDEFDV_UNOWN_' + m.group(1), 'SPDSPCDV_UNOWN_' + m.group(1))
            cur[-1]['dvs'] = list(v.values())
            cur[-1]['letter'] = ord(m.group(1)) - ord('A') + 1
    return out


def class_dvs(g, cls):
    return rom_byte(g, 'TrainerClassDVs', (cls - 1) * 2, 2)


@test(SUITE)
def story_unown_party_data_parse(g):
    """Static: every party in the ROM walks to its terminator with the type-dependent entry size
    (DVS adds 2 bytes after the species), and the DVS parties match parties.asm byte for byte."""
    parties, problems = parse_rom_parties(g)
    check(not problems, 'party data misaligned', n=len(problems), problems=problems[:20])
    dvs_f = value('TRAINERTYPE_DVS_F')
    rom_dvs = {(p['group'], k[1]): p for k, p in parties.items() if p['type'] >> dvs_f & 1}
    src = parse_source_dvs_parties()
    check(set(rom_dvs) == set(src), 'DVS party set differs ROM vs source', rom=sorted(rom_dvs), src=sorted(src))
    out = {'parties': len(parties), 'dvs_parties': {}}
    for key, smons in src.items():
        rmons = rom_dvs[key]['mons']
        check(len(rmons) == len(smons), 'mon count differs', party=key, rom=rmons, src=smons)
        for r, s in zip(rmons, smons):
            check((r['level'], r['species'], r['dvs']) == (s['level'], s['species'], s['dvs']),
                  'mon differs', party=key, rom=r, src=s)
            if 'letter' in s:
                check(unown_letter(r['dvs']) == s['letter'], 'Unown DVs give the wrong letter', party=key,
                      dvs=r['dvs'], letter=unown_letter(r['dvs']), want=s['letter'])
        out['dvs_parties']['%s %d' % key] = [(s.get('species_name'), s['level'], ['%02x' % x for x in s['dvs']])
                                             for s in smons]
    # Archer and Petrel's non-Unown mons keep their class DVs
    for (grp, tid), cls in ((('GruntMGroup', 1), 'GRUNTM'), (('ExecutiveMGroup', 1), 'EXECUTIVEM')):
        cd = class_dvs(g, value(cls))
        for m in src[(grp, tid)]:
            if 'letter' not in m:
                check(m['dvs'] == cd, 'non-Unown mon lost its class DVs', party=(grp, tid), mon=m, class_dvs=cd)
    return out


@test(SUITE)
def story_unown_party_reader_all(g):
    """Runtime: ReadTrainerParty for every trainer of every class, compared with the ROM walk:
    species, level, DVs (per-mon for DVS, class DVs otherwise), item, moves, HP refilled.
    DVS parties also get their stats recomputed from base stats + DVs."""
    check(in_control(g, 60), 'not in the overworld')
    parties, problems = parse_rom_parties(g)
    check(not problems, 'party data misaligned', problems=problems[:10])
    v = resolve('PARTYMON_STRUCT_LENGTH', 'MON_SPECIES', 'MON_ITEM', 'MON_MOVES', 'MON_DVS', 'MON_LEVEL',
                'MON_HP', 'MON_MAXHP', 'MON_STATS', 'TRAINERTYPE_DVS_F')
    L = v['PARTYMON_STRUCT_LENGTH']
    bad, checked, stats_checked = [], 0, []
    g.write('wInBattleTowerBattle', 0)
    for (cls, tid), p in sorted(parties.items()):
        g.write('wBattleMode', 2)
        g.write('wOtherTrainerClass', cls)
        g.write('wOtherTrainerID', tid)
        g.call('ReadTrainerParty', max_frames=120)
        g.write('wBattleMode', 0)
        n = g.read('wOTPartyCount')
        tag = '%s %d' % (p['group'], tid)
        if n != len(p['mons']):
            bad.append((tag, 'count', n, len(p['mons'])))
            continue
        cdv = class_dvs(g, cls)
        raw = g.read('wOTPartyMon1', L * n)
        for i, m in enumerate(p['mons']):
            s = raw[i * L:(i + 1) * L]
            sp = g.call('GetPokemonIndexFromID', a=s[v['MON_SPECIES']])['hl']
            dvs = s[v['MON_DVS']:v['MON_DVS'] + 2]
            want_dvs = m.get('dvs', cdv)
            hp = s[v['MON_HP']] << 8 | s[v['MON_HP'] + 1]
            maxhp = s[v['MON_MAXHP']] << 8 | s[v['MON_MAXHP'] + 1]
            got = dict(species=sp, level=s[v['MON_LEVEL']], dvs=dvs)
            want = dict(species=m['species'], level=m['level'], dvs=want_dvs)
            if 'item' in m:
                got['item'] = g.call('GetItemIndexFromID', a=s[v['MON_ITEM']])['hl'] if s[v['MON_ITEM']] else 0
                want['item'] = m['item']
            if 'moves' in m:
                got['moves'] = [g.call('GetMoveIndexFromID', a=x)['hl'] if x else 0
                                for x in s[v['MON_MOVES']:v['MON_MOVES'] + 4]]
                want['moves'] = m['moves']
            if got != want:
                bad.append((tag, i, got, want))
            if hp != maxhp or not maxhp:
                bad.append((tag, i, 'hp', hp, maxhp))
            if p['type'] >> v['TRAINERTYPE_DVS_F'] & 1:
                st = [maxhp] + [s[v['MON_STATS'] + 2 * k] << 8 | s[v['MON_STATS'] + 2 * k + 1] for k in range(5)]
                exp = calc_stats(base_stats(g, m['species']), want_dvs, m['level'])
                stats_checked.append((tag, i, st, exp))
                if st != exp:
                    bad.append((tag, i, 'stats', st, exp))
            checked += 1
    check(not bad, 'trainer parties read wrong', n=len(bad), bad=bad[:15])
    check(len(stats_checked) == 6, 'expected 6 DVS mons with stats checked', got=len(stats_checked))
    # informational, pre-existing: SetTrainerBattleLevel (battle transition) walks TrainerGroups
    # with a 2-byte stride and without paging the group bank
    lv = {}
    for cls, tid, name in ((value('GRUNTM'), 1, 'archer'), (value('EXECUTIVEM'), 1, 'petrel'),
                           (value('FALKNER'), 1, 'falkner')):
        g.write('wOtherTrainerClass', cls)
        g.write('wOtherTrainerID', tid)
        g.write('wInBattleTowerBattle', 0)
        try:
            g.call('SetTrainerBattleLevel', max_frames=60)
            lv[name] = (g.read('wCurPartyLevel'), parties[(cls, tid)]['mons'][0]['level'])
        except Exception as e:  # noqa: BLE001
            lv[name] = str(e)[:80]
    g.write('wOtherTrainerClass', 0)
    return dict(parties=len(parties), mons=checked, dvs_stats=stats_checked,
                set_trainer_battle_level_got_vs_first_mon=lv)


# --- Slowpoke Well: Archer and his Unown A ------------------------------------------------------
WELL_FLAGS = dict(EVENT_SLOWPOKE_WELL_ROCKETS=False, EVENT_BEAT_ROCKET_GRUNTM_1=False,
                  EVENT_BEAT_ROCKET_GRUNTM_29=True, EVENT_BEAT_ROCKET_GRUNTM_2=True, EVENT_BEAT_ROCKET_GRUNTF_1=True,
                  EVENT_SLOWPOKE_WELL_B1F_UNOWN=True, EVENT_FOUGHT_UNOWN_A=False,
                  EVENT_CLEARED_SLOWPOKE_WELL=False, EVENT_SLOWPOKE_WELL_KURT=False)


def _well(g):
    solo_party(g)

    def before(g):
        for k, on in WELL_FLAGS.items():
            set_event(g, k, on)
    warp(g, 'SLOWPOKE_WELL_B1F', 5, 4, before=before)  # Archer (5,2) sees 1 tile
    check(not event(g, 'EVENT_SLOWPOKE_WELL_ROCKETS'), 'rockets hidden')
    shot(g, 'well_1_before')
    return step(g, 'up')


def _expect_archer(g, b):
    cd = class_dvs(g, value('GRUNTM'))
    A = resolve('ATKDEFDV_UNOWN_A', 'SPDSPCDV_UNOWN_A')
    want = [('UNOWN', 15, [A['ATKDEFDV_UNOWN_A'], A['SPDSPCDV_UNOWN_A']]), ('EEVEE', 15, cd), ('KOFFING', 17, cd)]
    check(b['trainer'] == (value('GRUNTM'), 1) and b['result'] == 0, 'Archer battle wrong', b=b)
    got = [(m['species'], m['level'], m['dvs'], m['party_dvs']) for m in b['mons']]
    check(got == [(value(s), lv, dv, dv) for s, lv, dv in want], 'Archer party in battle wrong', got=got,
          want=want)
    check(unown_letter(b['mons'][0]['dvs']) == 1, 'Archer\'s Unown is not A', dvs=b['mons'][0]['dvs'])
    exp = calc_stats(base_stats(g, value('UNOWN')), want[0][2], 15)
    got_st = [b['mons'][0]['maxhp']] + b['mons'][0]['stats']
    check(got_st == exp, 'Archer\'s Unown stats not from its DVs', got=got_st, want=exp)
    items = b['mons'][0]['trainer_items']
    check(items == [value('FULL_HEAL'), value('HYPER_POTION')], 'GRUNTM trainer items', got=items)


def _expect_wild_unown(b, letter, level, btype):
    check(len(b['mons']) == 1, 'wild battle mons', b=b)
    m = b['mons'][0]
    check(m['mode'] == 1, 'Unown battle is not a wild battle', mode=m['mode'], b=b)
    check((m['species'], m['level'], m['type']) == (value('UNOWN'), level, value(btype)),
          'wild Unown wrong', got=m, want=(letter, level, btype))
    check(unown_letter(m['dvs']) == letter, 'wild Unown DVs give the wrong letter', dvs=m['dvs'],
          got=unown_letter(m['dvs']), want=letter)


@test(SUITE)
def story_unown_archer_well(g):
    """Slowpoke Well: talk to Archer; his party in battle is Unown A (fixed DVs, stats from them),
    Eevee, Koffing with class DVs; then his Unown A stays behind as a wild Unown A Lv15; afterwards
    FOUGHT_UNOWN_A, the Unown hidden, the well cleared, warped to Kurt's house."""
    before_unlock = unlocked(g)
    check(_well(g), 'Archer did not start a script')
    rec = run_script(g, battles=['win', 'win'])
    shot(g, 'well_2_after')
    out = dict(texts=rec['texts'], map=rec['map'], battles=rec['battles'])
    check(len(rec['battles']) == 2, 'expected Archer + Unown A', **out)
    _expect_archer(g, rec['battles'][0])
    _expect_wild_unown(rec['battles'][1], 1, 15, 'BATTLETYPE_UNOWN_A')
    st = flags(g, 'EVENT_BEAT_ROCKET_GRUNTM_1', 'EVENT_FOUGHT_UNOWN_A', 'EVENT_SLOWPOKE_WELL_B1F_UNOWN',
               'EVENT_CLEARED_SLOWPOKE_WELL', 'EVENT_SLOWPOKE_WELL_ROCKETS')
    out['flags'] = st
    check(all(st.values()), 'well aftermath flags', **out)
    check(rec['map'] == 'KURTS_HOUSE', 'not warped to Kurt\'s house', **out)
    check('KurtLeaveSlowpokeWellText' in rec['texts'], 'Kurt\'s line missing', **out)
    check(unlocked(g) == before_unlock, 'Unown sets not relocked to what they were', before=before_unlock,
          after=unlocked(g))
    # the Unown stays gone
    warp(g, 'SLOWPOKE_WELL_B1F', 5, 3)
    shot(g, 'well_3_revisit')
    check(event(g, 'EVENT_SLOWPOKE_WELL_B1F_UNOWN'), 'Unown back on revisit')
    return out


@test(SUITE)
def story_unown_archer_well_whiteout_retry(g):
    """Lose to the Unown A: whiteout, the Unown stays at (5,2) unfought and the well uncleared;
    talking to it re-runs the fight and finishes Kurt's part."""
    check(_well(g), 'Archer did not start a script')
    rec = run_script(g, battles=['win', 'lose'])
    out = dict(first=dict(map=rec['map'], battles=[(b['trainer'], b['result']) for b in rec['battles']],
                          texts=rec['texts'][-4:]))
    st = flags(g, 'EVENT_BEAT_ROCKET_GRUNTM_1', 'EVENT_FOUGHT_UNOWN_A', 'EVENT_SLOWPOKE_WELL_B1F_UNOWN',
               'EVENT_CLEARED_SLOWPOKE_WELL')
    out['after_loss'] = st
    shot(g, 'well_4_whiteout')
    check(len(rec['battles']) == 2 and rec['battles'][1]['result'] == 1, 'Unown battle not lost', **out)
    check(rec['map'] != 'SLOWPOKE_WELL_B1F', 'no whiteout', **out)
    check(st['EVENT_BEAT_ROCKET_GRUNTM_1'] and not st['EVENT_FOUGHT_UNOWN_A']
          and not st['EVENT_SLOWPOKE_WELL_B1F_UNOWN'] and not st['EVENT_CLEARED_SLOWPOKE_WELL'],
          'state after losing to the Unown', **out)
    solo_party(g)
    warp(g, 'SLOWPOKE_WELL_B1F', 5, 3)
    shot(g, 'well_5_unown_waits')
    how = _talk_or_inject(g, 'up', 'SlowpokeWellB1FUnownScript', obj_index('SlowpokeWellB1F', 'SLOWPOKEWELLB1F_UNOWN'))
    rec2 = run_script(g, battles=['win'])
    shot(g, 'well_6_retry_done')
    out['retry'] = dict(how=how, map=rec2['map'], texts=rec2['texts'], mons=rec2['battles'][0]['mons'] if rec2['battles'] else None)
    check(how == 'talked', 'Unown at (5,2) could not be talked to', **out)
    check(len(rec2['battles']) == 1, 'retry battle missing', **out)
    _expect_wild_unown(rec2['battles'][0], 1, 15, 'BATTLETYPE_UNOWN_A')
    st2 = flags(g, 'EVENT_FOUGHT_UNOWN_A', 'EVENT_SLOWPOKE_WELL_B1F_UNOWN', 'EVENT_CLEARED_SLOWPOKE_WELL')
    out['after_retry'] = st2
    check(all(st2.values()) and rec2['map'] == 'KURTS_HOUSE', 'retry did not finish the well', **out)
    return out


# --- Rocket hideout B3F: Petrel and his Unown Z --------------------------------------------------
@test(SUITE)
def story_unown_petrel_b3f(g):
    """Step on the boss trigger: Petrel (EXECUTIVEM_1) fields Golbat/Raticate with class DVs and an
    Unown Z (all-15 DVs); trainer items FULL_RESTORE x2; then his Unown Z stays behind as a wild
    Lv34 Unown Z. With the Ho-Oh chamber unsolved the forced Z still appears and X-Z is relocked."""
    solo_party(g)

    def before(g):
        for k, on in dict(EVENT_TEAM_ROCKET_BASE_B3F_EXECUTIVE=False, EVENT_BEAT_ROCKET_EXECUTIVEM_1=False,
                          EVENT_TEAM_ROCKET_BASE_B3F_UNOWN=True, EVENT_FOUGHT_UNOWN_Z=False,
                          EVENT_OPENED_DOOR_TO_GIOVANNIS_OFFICE=True, EVENT_TEAM_ROCKET_BASE_POPULATION=True,
                          EVENT_RIVAL_TEAM_ROCKET_BASE=True, EVENT_TEAM_ROCKET_BASE_B3F_LANCE_PASSWORDS=True,
                          EVENT_SOLVED_HO_OH_PUZZLE=False).items():
            set_event(g, k, on)
        set_engine(g, 'ENGINE_UNLOCKED_UNOWNS_X_TO_Z', False)
        g.write('wTeamRocketBaseB3FSceneID', scene_index('TeamRocketBaseB3F', 'SCENE_TEAMROCKETBASEB3F_ROCKET_BOSS'))
    warp(g, 'TEAM_ROCKET_BASE_B3F', 10, 9, before=before)
    shot(g, 'b3f_1_before')
    pre = unlocked(g)
    check(step(g, 'up'), 'boss trigger did not start')
    rec = run_script(g, battles=['win', 'win'])
    shot(g, 'b3f_2_after')
    out = dict(map=rec['map'], pos=rec['pos'], battles=rec['battles'], texts=rec['texts'], unlocked_before=pre)
    check(len(rec['battles']) == 2, 'expected Petrel + Unown Z', **out)
    b = rec['battles'][0]
    cd = class_dvs(g, value('EXECUTIVEM'))
    want = [(value('GOLBAT'), 33, cd), (value('RATICATE'), 33, cd), (value('UNOWN'), 34, [0xff, 0xff])]
    got = [(m['species'], m['level'], m['dvs']) for m in b['mons']]
    check(b['trainer'] == (value('EXECUTIVEM'), 1) and b['result'] == 0, 'Petrel battle wrong', **out)
    check(got == want, 'Petrel party in battle wrong', got=got, want=want)
    check(unown_letter(b['mons'][2]['dvs']) == 26, 'Petrel\'s Unown is not Z', dvs=b['mons'][2]['dvs'])
    check(b['mons'][0]['trainer_items'] == [value('FULL_RESTORE')] * 2, 'EXECUTIVEM trainer items',
          got=b['mons'][0]['trainer_items'])
    exp = calc_stats(base_stats(g, value('UNOWN')), [0xff, 0xff], 34)
    got_st = [b['mons'][2]['maxhp']] + b['mons'][2]['stats']
    check(got_st == exp, 'Petrel\'s Unown stats not from its DVs', got=got_st, want=exp)
    _expect_wild_unown(rec['battles'][1], 26, 34, 'BATTLETYPE_UNOWN_Z')
    st = flags(g, 'EVENT_BEAT_ROCKET_EXECUTIVEM_1', 'EVENT_FOUGHT_UNOWN_Z', 'EVENT_TEAM_ROCKET_BASE_B3F_UNOWN',
               'EVENT_TEAM_ROCKET_BASE_B3F_EXECUTIVE')
    out['flags'] = st
    out['unlocked_after'] = unlocked(g)
    check(all(st.values()), 'B3F aftermath flags', **out)
    check(out['unlocked_after'] == pre and not pre['X_TO_Z'], 'X-Z set not relocked', **out)
    check(rec['map'] == 'TEAM_ROCKET_BASE_B3F', 'left B3F', **out)
    return out


# --- Rocket hideout B2F: the Unown machine ------------------------------------------------------
MACHINE = [  # (script, object const, talk-from y, player letter, Lance's letter, battle type)
    ('RocketElectrode1', 'TEAMROCKETBASEB2F_ELECTRODE1', 5, 'H', 'F', 'BATTLETYPE_UNOWN_H'),
    ('RocketElectrode2', 'TEAMROCKETBASEB2F_ELECTRODE2', 7, 'O', 'M', 'BATTLETYPE_UNOWN_O'),
    ('RocketElectrode3', 'TEAMROCKETBASEB2F_ELECTRODE3', 9, 'U', 'Q', 'BATTLETYPE_UNOWN_U'),
]


def _b2f_before(g):
    for i in (1, 2, 3):
        set_event(g, 'EVENT_TEAM_ROCKET_BASE_B2F_ELECTRODE_%d' % i, False)
    for L in 'FHMOQU':
        set_event(g, 'EVENT_FOUGHT_UNOWN_' + L, False)
    for k, on in dict(EVENT_TEAM_ROCKET_BASE_POPULATION=True, EVENT_TEAM_ROCKET_BASE_B2F_LANCE=True,
                      EVENT_TEAM_ROCKET_BASE_B2F_EXECUTIVE=True, EVENT_TEAM_ROCKET_BASE_B2F_DRAGONITE=True,
                      EVENT_CLEARED_ROCKET_HIDEOUT=False, EVENT_GOT_HM03_SURF=False).items():
        set_event(g, k, on)
    g.write('wTeamRocketBaseB2FSceneID', scene_index('TeamRocketBaseB2F', 'SCENE_TEAMROCKETBASEB2F_ELECTRODES'))


@test(SUITE)
def story_unown_rocket_machine(g):
    """B2F machine: a loss leaves the Unown H in place and nothing flagged; then beating H, O, U
    (forced letters, Lv44, wild) flags each and Lance's F, M, Q as fought; the third ends with Lance."""
    solo_party(g)
    out = {}
    warp(g, 'TEAM_ROCKET_BASE_B2F', 8, 5, before=_b2f_before)
    shot(g, 'b2f_1_machine')
    script, const, y, mine, lance, btype = MACHINE[0]
    idx = obj_index('TeamRocketBaseB2F', const)
    out['loss_how'] = _talk_or_inject(g, 'left', script, idx)
    rec = run_script(g, battles=['lose'])
    st = flags(g, 'EVENT_FOUGHT_UNOWN_H', 'EVENT_FOUGHT_UNOWN_F', 'EVENT_TEAM_ROCKET_BASE_B2F_ELECTRODE_1')
    out['loss'] = dict(map=rec['map'], result=[b['result'] for b in rec['battles']], flags=st)
    shot(g, 'b2f_2_after_loss')
    check(rec['battles'] and rec['battles'][0]['result'] == 1, 'machine battle not lost', **out)
    check(not any(st.values()), 'a lost machine battle flagged something', **out)
    solo_party(g)
    warp(g, 'TEAM_ROCKET_BASE_B2F', 8, 5, before=lambda g: g.write(
        'wTeamRocketBaseB2FSceneID', scene_index('TeamRocketBaseB2F', 'SCENE_TEAMROCKETBASEB2F_ELECTRODES')))
    out['wins'] = []
    for n, (script, const, y, mine, lance, btype) in enumerate(MACHINE):
        if (g.read('wXCoord'), g.read('wYCoord')) != (8, y) or map_name(g) != 'TEAM_ROCKET_BASE_B2F':
            warp(g, 'TEAM_ROCKET_BASE_B2F', 8, y)
        how = _talk_or_inject(g, 'left', script, obj_index('TeamRocketBaseB2F', const))
        rec = run_script(g, battles=['win'])
        letter = ord(mine) - ord('A') + 1
        st = flags(g, 'EVENT_FOUGHT_UNOWN_' + mine, 'EVENT_FOUGHT_UNOWN_' + lance,
                   'EVENT_TEAM_ROCKET_BASE_B2F_ELECTRODE_%d' % (n + 1))
        r = dict(how=how, mons=rec['battles'][0]['mons'] if rec['battles'] else None, flags=st, map=rec['map'],
                 texts=rec['texts'][-6:])
        out['wins'].append(r)
        shot(g, 'b2f_3_won_%s' % mine)
        check(len(rec['battles']) == 1, 'machine battle missing', n=n, **r)
        _expect_wild_unown(rec['battles'][0], letter, 44, btype)
        check(all(st.values()), 'machine flags not set', n=n, **r)
    end = flags(g, 'EVENT_CLEARED_ROCKET_HIDEOUT', 'EVENT_GOT_HM03_SURF')
    out['end'] = end
    check(all(end.values()), 'Lance\'s wrap-up did not run', **out)
    return out


# --- Suicune sightings ---------------------------------------------------------------------
SIGHTINGS = {
    'ROUTE_36': ('Route36', 'SCENE_ROUTE36_SUICUNE', 'wRoute36SceneID', [(8, 7), (10, 7)],
                 'EVENT_SAW_SUICUNE_ON_ROUTE_36', 'C'),
    'CIANWOOD_CITY': ('CianwoodCity', 'SCENE_CIANWOODCITY_SUICUNE_AND_KAREN', 'wCianwoodCitySceneID', [(11, 16)],
                      'EVENT_SAW_SUICUNE_AT_CIANWOOD_CITY', 'G'),
    'ROUTE_42': ('Route42', 'SCENE_ROUTE42_SUICUNE', 'wRoute42SceneID', [(24, 14)],
                 'EVENT_SAW_SUICUNE_ON_ROUTE_42', 'S'),
}
APPROACH = [((0, 1), 'up'), ((-1, 0), 'right'), ((1, 0), 'left'), ((0, -1), 'down')]


def _sighting(g, mapname, arm=True, extra=None):
    """Arm (optionally) and trigger one sighting by stepping onto its coord event. Returns the
    script record, or None if no approach started it."""
    mf, scene, var, coords, hide, letter = SIGHTINGS[mapname]
    base = g.state()

    def before(g):
        if arm:
            g.write(var, scene_index(mf, scene))
            set_event(g, hide, False)
        set_event(g, 'EVENT_FOUGHT_KAREN_AT_CIANWOOD', True)
        if extra:
            extra(g)
    for cx, cy in coords:
        for (dx, dy), d in APPROACH:
            g.load(base)
            warp(g, mapname, cx + dx, cy + dy, before=before)
            vis = not event(g, hide)
            if step(g, d):
                rec = run_script(g)
                rec['from'] = (cx + dx, cy + dy, d)
                rec['visible_before'] = vis
                return rec
    g.load(base)
    return None


@test(SUITE)
def story_unown_suicune_sightings(g):
    """Each sighting (Route 36 C, Cianwood G, Route 42 S): the Unown is shown, the scene runs,
    the Unown hides and its FOUGHT flag is set; the next sighting is armed."""
    solo_party(g)
    base = g.state()
    out = {}
    nxt = {'ROUTE_36': ('wCianwoodCitySceneID', 'CianwoodCity', 'SCENE_CIANWOODCITY_SUICUNE_AND_KAREN'),
           'CIANWOOD_CITY': ('wRoute42SceneID', 'Route42', 'SCENE_ROUTE42_SUICUNE'),
           'ROUTE_42': ('wRoute36SceneID', 'Route36', 'SCENE_ROUTE36_SUICUNE')}
    for mapname, (mf, scene, var, coords, hide, letter) in SIGHTINGS.items():
        g.load(base)
        set_event(g, 'EVENT_FOUGHT_UNOWN_' + letter, False)
        rec = _sighting(g, mapname)
        check(rec, 'sighting never triggered', map=mapname)
        shot(g, 'sighting_%s' % mapname.lower())
        nv, nmf, nscene = nxt[mapname]
        r = dict(start=rec['from'], unown_visible_before=rec['visible_before'], map=rec['map'],
                 fought=event(g, 'EVENT_FOUGHT_UNOWN_' + letter), hidden_after=event(g, hide),
                 scene_after=g.read(var), next_armed=g.read(nv) == scene_index(nmf, nscene), texts=rec['texts'])
        if mapname == 'ROUTE_42':
            r['phonecall'] = g.read('wSpecialPhoneCallID')
            r['dragonite_hidden'] = event(g, 'EVENT_KURTS_HOUSE_DRAGONITE')
        out[mapname] = r
        check(r['unown_visible_before'], 'Unown not shown before the sighting', where=mapname, **r)
        check(r['fought'], 'driven-off Unown not flagged as fought', where=mapname, letter=letter, **r)
        check(r['hidden_after'] and r['scene_after'] == 0, 'sighting did not close', where=mapname, **r)
        check(r['next_armed'], 'next sighting not armed', where=mapname, **r)
    check(out['ROUTE_42']['phonecall'] == value('SPECIALCALL_KURT') and not out['ROUTE_42']['dragonite_hidden'],
          'Route 42 did not queue Kurt / show the Dragonite', r=out['ROUTE_42'])
    return out


@test(SUITE)
def story_unown_suicune_cycle_rearms_kurt(g):
    """The sightings re-arm each other in a loop (36 -> Cianwood -> 42 -> 36 ...) until Tin Tower.
    Once SAMUEL's MAIL is delivered (Dragonite flag set again), a second Route 42 sighting must not
    clear EVENT_KURTS_HOUSE_DRAGONITE or queue Kurt's call again."""
    solo_party(g)
    out = {'laps': []}
    set_event(g, 'EVENT_FOUGHT_SUICUNE', False)
    for lap in range(2):
        if lap == 1:
            set_event(g, 'EVENT_KURTS_HOUSE_DRAGONITE', True)  # the mail was delivered
            set_event(g, 'EVENT_GOT_SAMUELS_MAIL', True)
            g.write('wSpecialPhoneCallID', 0)
        lap_rec = {}
        for mapname in ('ROUTE_36', 'CIANWOOD_CITY', 'ROUTE_42'):
            rec = _sighting(g, mapname, arm=(lap == 0 and mapname == 'ROUTE_36'))
            lap_rec[mapname] = rec['from'] if rec else None
            check(rec, 'sighting did not trigger in the loop', lap=lap, map=mapname, out=out)
        lap_rec['dragonite_hidden'] = event(g, 'EVENT_KURTS_HOUSE_DRAGONITE')
        lap_rec['phonecall'] = g.read('wSpecialPhoneCallID')
        lap_rec['route36_rearmed'] = g.read('wRoute36SceneID') == scene_index('Route36', 'SCENE_ROUTE36_SUICUNE')
        out['laps'].append(lap_rec)
        g.write('wSpecialPhoneCallID', 0)
    shot(g, 'cycle_end')
    second = out['laps'][1]
    check(second['dragonite_hidden'] and second['phonecall'] != value('SPECIALCALL_KURT'),
          'second Route 42 sighting re-arms SAMUEL\'s MAIL (Dragonite back + Kurt calls again)', **out)
    return out


# --- Wild Hunt: Unown W (Route 38) and T (Route 39) ------------------------------------------
@test(SUITE)
def story_unown_wild_hunt_w_t(g):
    """During the hunt the Unown W (Route 38) and T (Route 39) objects fight as forced-letter Lv35
    Unown with Wild Hunt rules (Berserk Gene held), set their herd flag and FOUGHT_UNOWN flag, hide,
    and leave the unlocked sets as they were."""
    solo_party(g)
    base = g.state()
    out = {}
    for mapname, mf, const, script, (x, y), herd, letter in (
            ('ROUTE_38', 'Route38', 'ROUTE38_TAUROS_5', 'WildHuntTauros5', (8, 11), 'EVENT_FOUGHT_WILD_HUNT_TAUROS_5', 'W'),
            ('ROUTE_39', 'Route39', 'ROUTE39_TAUROS_16', 'WildHuntTauros16', (8, 20), 'EVENT_FOUGHT_WILD_HUNT_TAUROS_16', 'T')):
        g.load(base)

        def before(g, herd=herd, letter=letter):
            for f, on in HUNT_STATES['during_hunt']['flags'].items():
                set_event(g, f, bool(on))
            set_engine(g, 'ENGINE_WILD_HUNT', True)
            set_event(g, herd, False)
            set_event(g, 'EVENT_FOUGHT_UNOWN_' + letter, False)
        warp(g, mapname, x, y, before=before)
        shot(g, 'hunt_%s_before' % letter)
        pre = unlocked(g)
        check(inject(g, script, obj_index(mf, const)), 'hunt script did not start', map=mapname)
        rec = run_script(g, battles=['win'])
        shot(g, 'hunt_%s_after' % letter)
        st = flags(g, herd, 'EVENT_FOUGHT_UNOWN_' + letter)
        r = dict(mons=rec['battles'][0]['mons'] if rec['battles'] else None, flags=st, texts=rec['texts'],
                 unlocked_before=pre, unlocked_after=unlocked(g))
        out[letter] = r
        check(len(rec['battles']) == 1, 'hunt battle missing', **r)
        _expect_wild_unown(rec['battles'][0], ord(letter) - ord('A') + 1, 35, 'BATTLETYPE_UNOWN_' + letter)
        check(r['mons'][0]['confused'], 'no Wild Hunt Berserk Gene (enemy not confused at its first menu)', **r)
        check(all(st.values()), 'hunt flags not set', **r)
        check(r['unlocked_after'] == pre, 'unlocked sets changed', **r)
    # outside the hunt the same battle type is an ordinary forced-letter Unown (no Berserk Gene)
    g.load(base)
    warp(g, 'ROUTE_38', 8, 11, before=lambda g: (set_engine(g, 'ENGINE_WILD_HUNT', False),
                                                set_event(g, 'EVENT_FOUGHT_WILD_HUNT_TAUROS_5', False)))
    check(inject(g, 'WildHuntTauros5', obj_index('Route38', 'ROUTE38_TAUROS_5')), 'script did not start')
    rec = run_script(g, battles=['win'])
    out['no_hunt'] = rec['battles'][0]['mons'] if rec['battles'] else None
    check(out['no_hunt'] and not out['no_hunt'][0]['confused'],
          'Berserk Gene outside the hunt', got=out['no_hunt'])
    return out


@test(SUITE)
def story_unown_battle_level_all(g):
    """SetTrainerBattleLevel (battle transition) gives every party's first-mon level, and 255 in the
    Battle Tower."""
    check(in_control(g, 60), 'not in the overworld')
    parties, problems = parse_rom_parties(g)
    check(not problems, 'party data misaligned', problems=problems[:10])
    g.write('wInBattleTowerBattle', 0)
    bad = []
    for (cls, tid), p in sorted(parties.items()):
        g.write('wOtherTrainerClass', cls)
        g.write('wOtherTrainerID', tid)
        g.call('SetTrainerBattleLevel', max_frames=60)
        got, want = g.read('wCurPartyLevel'), p['mons'][0]['level']
        if got != want:
            bad.append(('%s %d' % (p['group'], tid), got, want))
    g.write('wInBattleTowerBattle', 1)
    g.call('SetTrainerBattleLevel', max_frames=60)
    tower = g.read('wCurPartyLevel')
    g.write('wInBattleTowerBattle', 0)
    g.write('wOtherTrainerClass', 0)
    check(not bad and tower == 255, 'battle level wrong', n=len(bad), bad=bad[:15], tower=tower)
    return dict(parties=len(parties), tower=tower)

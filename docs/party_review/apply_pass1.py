"""First party-review pass: illegal moves, same-type category fixes, overdue evolutions."""
import sys, re
from pathlib import Path
sys.path.insert(0, 'docs/party_review'); sys.argv = [sys.argv[0]]
from view import dex, parse_parties, src, PARTIES

P = Path(PARTIES)
L = P.read_text().splitlines(keepends=True)
log = []
trainers = parse_parties(src)

def find(label, sp):
    hits = [(t, m) for t in trainers if t['label'].startswith(label) for m in t['mons'] if m['species'] == sp]
    assert hits, (label, sp)
    return hits

def set_moves(t, m, moves):
    i = m['moves_line'] - 1
    L[i] = re.sub(r'(\tdw ).*', r'\g<1>' + ', '.join(moves), L[i])
    log.append(f"{t['label']}: {m['species']} {m['moves']} -> {moves}")
    m['moves'] = moves

def swap(t, m, old, new):
    mv = [new if x == old else x for x in m['moves']]
    set_moves(t, m, mv)

def set_item(t, m, item):
    i = m['species_line']  # item line follows species line
    old = L[i].split()[1]
    L[i] = L[i].replace(old, item)
    log.append(f"{t['label']}: {m['species']} item {old} -> {item}")

def evolve(t, m, into):
    i = m['species_line'] - 1
    L[i] = L[i].replace(m['species'], into)
    log.append(f"{t['label']}: {m['species']} -> {into}")
    m['species'] = into

# ---- specific decisions
for t, m in find('FALKNER (2)', 'PIDGEOT'): set_moves(t, m, ['HURRICANE', 'AIR_SLASH', 'STEEL_WING', 'QUICK_ATTACK'])
for t, m in find('BUGSY (1)', 'BEEDRILL'): swap(t, m, 'GIGA_DRAIN', 'LEECH_LIFE'); set_item(t, m, 'POISON_BARB')
for t, m in find('BUGSY (2)', 'SCYTHER'): swap(t, m, 'TWINEEDLE', 'X_SCISSOR')
for t, m in find('BUGSY (2)', 'PINSIR'): set_moves(t, m, ['X_SCISSOR', 'SUBMISSION', 'DOUBLE_EDGE', 'SWORDS_DANCE'])
for t, m in find('BUGSY (2)', 'QUAGSIRE'): swap(t, m, 'ANCIENTPOWER', 'ICE_PUNCH')
for t, m in find('WHITNEY (2)', 'DONPHAN'): swap(t, m, 'ROCK_SLIDE', 'ROLLOUT')
for t, m in find('MORTY (1)', 'MISDREAVUS'): set_moves(t, m, ['CONFUSE_RAY', 'MEAN_LOOK', 'PSYBEAM', 'SHADOW_BALL'])
for t, m in find('PRYCE (1)', 'CLOYSTER'): swap(t, m, 'SPIKE_CANNON', 'ICICLE_CRASH')
for t, m in find('CLAIR (1)', 'DRAGONAIR'):
    if 'EXTREMESPEED' in m['moves']: swap(t, m, 'EXTREMESPEED', 'BODY_SLAM')
for t, m in find('CLAIR (2)', 'GYARADOS'): swap(t, m, 'EARTHQUAKE', 'THRASH')
for t, m in find('KOGA (2)', 'ARIADOS'): swap(t, m, 'PSYBEAM', 'X_SCISSOR')
for t, m in find('LANCE (5)', 'DRAGONITE'): swap(t, m, 'DRAGONBREATH', 'OUTRAGE')

# ---- same-type, wrong-category fixes (only where the new move is legal and not already known)
RULES = [
    ({'CROBAT', 'ARBOK', 'MUK', 'BEEDRILL'}, ['SLUDGE_BOMB'], ['POISON_JAB']),
    ({'FLAREON', 'RAPIDASH'}, ['FLAMETHROWER', 'FIRE_BLAST'], ['FLARE_BLITZ']),
    ({'KABUTOPS', 'QUAGSIRE', 'GYARADOS', 'QWILFISH', 'FERALIGATR'}, ['SURF', 'BUBBLEBEAM', 'BUBBLE'], ['WATERFALL']),
    ({'BUTTERFREE', 'VENOMOTH'}, ['LEECH_LIFE', 'PIN_MISSILE'], ['BUG_BUZZ']),
    ({'VENUSAUR', 'VILEPLUME'}, ['RAZOR_LEAF'], ['PETAL_DANCE', 'GIGA_DRAIN']),
    ({'HOUNDOOM'}, ['CRUNCH'], ['DARK_PULSE']),
    ({'VILEPLUME'}, ['FAINT_ATTACK'], ['DARK_PULSE']),
    ({'JYNX'}, ['ICE_PUNCH'], ['ICE_BEAM']),
    ({'CHARIZARD'}, ['FLY'], ['AIR_SLASH']),
    ({'XATU'}, ['PECK', 'DRILL_PECK'], ['AIR_SLASH']),
    ({'MAGNETON'}, ['SPIKE_CANNON'], ['FLASH_CANNON']),
    ({'TYRANITAR', 'AERODACTYL'}, ['ANCIENTPOWER'], ['ROCK_SLIDE']),
    ({'MAGCARGO'}, ['ROCK_SLIDE', 'ROCK_THROW'], ['POWER_GEM']),
    ({'PILOSWINE', 'MAMOSWINE'}, ['ICE_BEAM', 'BLIZZARD'], ['ICICLE_CRASH']),
    ({'PARASECT', 'LEAFEON'}, ['GIGA_DRAIN'], ['SEED_BOMB']),
    ({'TANGELA'}, ['VINE_WHIP'], ['GIGA_DRAIN']),
    ({'STARMIE', 'MANTINE'}, ['WATERFALL'], ['SURF']),
    ({'MANTINE'}, ['WING_ATTACK'], ['AIR_SLASH']),
    ({'LEDIAN'}, ['COMET_PUNCH'], ['MOONBLAST']),
]
for t in trainers:
    for m in t['mons']:
        if not m['moves']: continue
        for species, olds, news in RULES:
            if m['species'] not in species: continue
            legal = dex.legal_moves(m['species'], m['level'])
            for old in olds:
                if old not in m['moves']: continue
                new = next((n for n in news if n in legal and n not in m['moves']), None)
                if new: swap(t, m, old, new)

# ---- overdue evolutions on leader / E4 / executive / rival teams at Lv60+
KEY = re.compile(r'^(FALKNER|BUGSY|WHITNEY|MORTY|CHUCK|JASMINE|PRYCE|CLAIR|BROCK|MISTY|LT_SURGE|ERIKA|JANINE|SABRINA|BLAINE|BLUE|WILL|KOGA|BRUNO|KAREN|CHAMPION|LANCE|RIVAL|RED|EXECUTIVE)')
SKIP = {'SCYTHER', 'PIKACHU'}  # Scizor is Jasmine's/Sabrina's; Red's Pikachu stays
for t in trainers:
    if not KEY.match(t['label']): continue
    for m in t['mons']:
        if m['level'] < 60 or m['species'] in SKIP: continue
        for e in dex.evos.get(m['species'], []):
            if (e['level'] and m['level'] >= e['level'] + 10) or (not e['level'] and m['level'] >= 50):
                evolve(t, m, e['into']); break

P.write_text(''.join(L))
Path('docs/party_review/pass1_log.txt').write_text('\n'.join(log) + '\n')
print(len(log), 'edits')

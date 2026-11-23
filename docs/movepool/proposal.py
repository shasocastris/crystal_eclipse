"""TM/tutor proposal (docs/tm_tutor_proposal.txt) as data for matrix.py."""

TM_SWAPS = {                 # old move -> new move (same TM number)
    'NIGHTMARE': 'SHADOW_CLAW',
    'DEFENSE_CURL': 'ROCK_SLIDE',
    'SWEET_KISS': 'CRUNCH',
}
TUTOR_DROP = ['MIMIC', 'PAY_DAY']
TUTOR_ADD = ['X_SCISSOR', 'POISON_JAB', 'ICICLE_CRASH', 'SEED_BOMB']

# Who can use each new TM/tutor. 'LEVELUP' = everyone who learns it by level-up
# (whole evolution line). Name a final form to grant its whole line;
# a trailing '!' grants that species only (e.g. Eeveelutions).
GRANTS = {
    'ROCK_SLIDE': ['LEVELUP', 'KABUTOPS', 'OMASTAR', 'SHUCKLE', 'DUGTRIO', 'QUAGSIRE', 'DONPHAN',
                   'NIDOKING', 'NIDOQUEEN', 'GLISCOR', 'URSALUNA', 'KANGASKHAN', 'MACHAMP',
                   'HITMONLEE', 'HITMONCHAN', 'HITMONTOP', 'TAUROS', 'SNORLAX', 'PINSIR', 'HERACROSS'],
    'CRUNCH': ['LEVELUP', 'GYARADOS!', 'WEAVILE', 'UMBREON!', 'SNORLAX', 'TYPHLOSION', 'KINGLER',
               'RATICATE', 'AERODACTYL', 'MAMOSWINE'],
    'SHADOW_CLAW': ['LEVELUP', 'WEAVILE', 'SANDSLASH', 'GLISCOR', 'CHARIZARD', 'FERALIGATR', 'PERSIAN',
                    'NIDOKING', 'NIDOQUEEN', 'URSALUNA', 'TYRANITAR', 'KANGASKHAN', 'GENGAR', 'SCIZOR',
                    'TYPHLOSION', 'DUGTRIO', 'AMBIPOM', 'RHYPERIOR'],
    'X_SCISSOR': ['LEVELUP', 'SANDSLASH', 'KINGLER', 'GLISCOR', 'WEAVILE', 'CROBAT', 'SHUCKLE',
                  'FORRETRESS', 'KABUTOPS', 'LEAFEON!'],
    'POISON_JAB': ['LEVELUP', 'WEEZING', 'GLISCOR', 'GENGAR', 'WEAVILE', 'MACHAMP', 'ARIADOS', 'SEAKING'],
    'ICICLE_CRASH': ['LEVELUP', 'DEWGONG', 'LAPRAS', 'GYARADOS!', 'DRAGONITE', 'DRAGONITE_KANTO',
                     'FERALIGATR', 'KINGLER', 'QUAGSIRE', 'NIDOKING'],
    'SEED_BOMB': ['LEVELUP', 'JUMPLUFF', 'EXEGGUTOR', 'CELEBI', 'SUNFLORA', 'SNORLAX', 'AMBIPOM'],
}

# Extra compat for moves that are already TMs/tutors (move -> species).
EXTRA = {
    'THUNDERBOLT': ['MAGMORTAR'],
}

# Imports MysticCrystal's follower sheets into gfx/following/ and regenerates
# gfx/following_sprites.asm and gfx/following_sprite_pointers.asm.
# Run from the repo root: python3 docs/followers/import_follower_sprites.py
import os, re
from PIL import Image
E = os.getcwd()
M = os.path.join(E, '..', 'MysticCrystal', 'gfx', 'following')

# Eclipse name -> Mystic file, where they differ.
RENAME = {
    'MR__MIME': 'mr_mime',
    'PORYGON_Z': 'porygonz',
    'DUDUNSPARC': 'dudunspars',
    'RAICHU_ORANGE': 'raichu_alolan',
}
# No sprite anywhere: borrow the pre-evolution (or base form). Needs art.
BORROW = {
    'DRAGONITE_KANTO': 'dragonite',  # Pokedex pic is Dragonite's; only the palette differs
}

# Drawn for Eclipse: gfx/following/<name>.png is the source, not Mystic.
ECLIPSE_ART = {
    'ANNIHILAPE', 'SIRFETCH_D', 'WYRDEER', 'FARIGIRAF',
    'URSALUNA', 'CURSOLA', 'CORSOLA_KANTO',
}

rows = []
for l in open(os.path.join(E, 'data/pokemon/follower_pals.asm')):
    m = re.match(r'\s*follower_pals\s+\w+,\s*\w+\s*;\s*(\w+)', l)
    if m:
        rows.append(m.group(1))


def lum(c):
    return 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2]


def convert(src, dst):
    im = Image.open(src).convert('RGB')
    assert im.size == (16, 96), src
    cols = sorted(set(im.getdata()), key=lum)
    # merge stray near-duplicate shades, then expect exactly four
    groups = []
    for c in cols:
        if groups and lum(c) - lum(groups[-1][-1]) < 12:
            groups[-1].append(c)
        else:
            groups.append([c])
    assert len(groups) == 4, (src, groups)
    levels = [0, 85, 170, 255]
    shade = {c: levels[i] for i, g in enumerate(groups) for c in g}
    out = Image.new('L', im.size)
    out.putdata([shade[c] for c in im.getdata()])
    out.save(dst)


def label(name):
    return ''.join(p.capitalize() for p in name.split('_')) + 'FollowerGFX'


src_of = {}
for r in rows:
    src_of[r] = BORROW.get(r) or RENAME.get(r) or r.lower()
    if r in ECLIPSE_ART:
        assert os.path.exists(os.path.join(E, 'gfx/following', src_of[r] + '.png')), r
    else:
        assert os.path.exists(os.path.join(M, src_of[r] + '.png')), r

order = []
for r in rows:
    if src_of[r] not in order:
        order.append(src_of[r])
UNOWN = ['unown_' + chr(c) for c in range(ord('a'), ord('z') + 1)]
for name in UNOWN:
    convert(os.path.join(M, name.upper() + '.png'), os.path.join(E, 'gfx/following', name + '.png'))
order += UNOWN
for name in order:
    if name in UNOWN or name.upper() in ECLIPSE_ART:
        continue
    convert(os.path.join(M, name + '.png'), os.path.join(E, 'gfx/following', name + '.png'))

with open(os.path.join(E, 'gfx/following_sprites.asm'), 'w') as f:
    f.write('SECTION "Following Sprites 1", ROMX\n\n')
    f.write('FollowerPlaceholderSpriteGFX:: INCBIN "gfx/following/placeholder.2bpp"\n')
    # one floating section each: free space is fragmented, and pinned
    # sections are placed first, so these only fill leftover gaps
    for name in order:
        f.write('\nSECTION "Follower %s", ROMX\n' % name)
        f.write('%s:: INCBIN "gfx/following/%s.2bpp"\n' % (label(name), name))

with open(os.path.join(E, 'gfx/following_sprite_pointers.asm'), 'w') as f:
    f.write('FollowingSpritePointers:\n; entries correspond to species indexes - 1\n')
    f.write('\ttable_width 3\n')
    for r in rows:
        note = ' (borrowed, needs art)' if r in BORROW else ''
        f.write('\tdba %-24s ; %s%s\n' % (label(src_of[r]), r, note))
    f.write('\tassert_table_length NUM_POKEMON_AND_VARIANTS\n')
    f.write('\nUnownFollowingSpritePointers:\n; entries correspond to UNOWN_* letters - 1\n')
    f.write('\ttable_width 3\n')
    for name in UNOWN:
        f.write('\tdba %s\n' % label(name))
    f.write('\tassert_table_length NUM_UNOWN\n')
print(len(rows), 'species,', len(order), 'sheets')

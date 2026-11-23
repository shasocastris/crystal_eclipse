"""Rewrite every base_stats tmhm line from docs/movepool/proposal.py.

Run ONCE, before constants/item_constants.asm is edited (matrix.py reads the
current TM/tutor list to apply the proposal). Lines are emitted in
TM -> HM -> tutor order using the post-proposal numbering.
"""
import re, sys
from pathlib import Path
sys.argv = ['matrix.py']
sys.path.insert(0, 'docs/movepool')
import matrix as M
import proposal as P

order = []
for l in Path('constants/item_constants.asm').read_text().splitlines():
    m = re.match(r'\s*add_(tm|hm|mt)\s+(\w+)', l)
    if m:
        mv = P.TM_SWAPS.get(m.group(2), m.group(2))
        if mv not in P.TUTOR_DROP:
            order.append(mv)
order += P.TUTOR_ADD
rank = {mv: i for i, mv in enumerate(order)}

files = [m.group(1) for m in re.finditer(r'INCLUDE\s+"(data/pokemon/base_stats/[^"]+)"',
                                          Path('data/pokemon/base_stats.asm').read_text())]
assert len(files) == len(M.dex.species)
changed = 0
for sp, path in zip(M.dex.species, files):
    moves = M.compat[sp]
    bad = moves - rank.keys()
    if bad: sys.exit(f'{sp}: not a TM/HM/tutor after proposal: {bad}')
    p = Path(path); t = p.read_text()
    new = re.sub(r'^(\s*)tmhm\b.*$', lambda m: (m.group(1) + 'tmhm ' + ', '.join(sorted(moves, key=rank.get))).rstrip(),
                 t, count=1, flags=re.M)
    if new != t:
        p.write_text(new); changed += 1
print(f'{changed} files changed; {len(order)} TM/HM/tutor slots')

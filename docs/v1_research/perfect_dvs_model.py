# Model of GetPerfectDVs (branch 30) against GetGender / CheckShininess, over every DV pair and gender ratio.
def shiny(d0, d1):
    return d0 >= 0xc0 and (d0 & 15) >= 12 and d1 >= 0xc0 and (d1 & 15) >= 12
def gender(d0, d1, ratio):  # GetGender: 1 male, 0 female, None genderless
    if ratio == 255: return None
    if ratio == 0: return 1
    if ratio == 254: return 0
    b = ((~d0 >> 4) & 1) << 5 | (d0 & 1) << 6 | ((~d1) & 1) << 7
    return 1 if ratio < b else 0
def perfect(d0, d1, ratio):
    c = 0xff if shiny(d0, d1) else 0xbf
    b = 0xff
    g = gender(d0, d1, ratio)
    if g is None: return b, c
    for cand in ((b, c), (b, c - 1)):
        if gender(*cand, ratio) == g: return cand
    return b - 1, c
ratios = [0, 31, 63, 127, 191, 254, 255]
for r in ratios:
    for d0 in range(256):
        for d1 in range(256):
            p = perfect(d0, d1, r)
            assert gender(*p, r) == gender(d0, d1, r), (r, d0, d1, p)
            assert shiny(*p) == shiny(d0, d1), (r, d0, d1, p)
            assert perfect(*p, r) == p   # idempotent: a second visit is "already perfect"
print('all ratios x all DVs: gender and shininess kept, result stable')
from collections import Counter
print(Counter((r, '%02X%02X' % perfect(d0, d1, r)) for r in ratios for d0 in range(256) for d1 in range(256)))

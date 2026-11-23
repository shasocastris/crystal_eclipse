# Exact model of BattleCommand_CheckObedience (branch 32), enumerating BattleRandom.
from fractions import Fraction as F
swap = lambda a: ((a << 4) | (a >> 4)) & 0xff
def cap(h):
    if h >= 220: return 101
    if h >= 160: return 54
    a = h
    carry = a < 110                       # cp OBEY_HAPPINESS_1
    a = 0xff if carry else 0              # sbc a
    a &= (24 - 39) & 0xff                 # and LOW(OBEY_LEVEL_0 - OBEY_LEVEL_1)
    return (a + 39) & 0xff                # add OBEY_LEVEL_1
def odds(h, d):
    c = cap(h); b = d
    if c >= d: return dict(obey=F(1), other=F(0), nap=F(0), hurt=F(0), loaf=F(0))
    r1 = [swap(x) for x in range(256) if swap(x) < b]          # rejection loop
    p_obey = F(sum(v < c for v in r1), len(r1))
    r2 = [x for x in range(256) if x < b]
    p_other = F(sum(v < c for v in r2), len(r2))
    bb = d - c
    nap = hurt = loaf = 0
    for x in range(256):
        a = swap(x) - bb
        if a < 0: nap += 1
        elif a < bb: hurt += 1
        else: loaf += 1
    q = (1 - p_obey) * (1 - p_other)
    return dict(obey=p_obey, other=(1 - p_obey) * p_other, nap=q*F(nap,256), hurt=q*F(hurt,256), loaf=q*F(loaf,256))
# asserts: always-obey regions and cap thresholds
for h in range(256):
    for d in range(1, 101):
        o = odds(h, d)
        if d <= 24 or (h >= 110 and d <= 39) or (h >= 160 and d <= 54) or h >= 220:
            assert o['obey'] == 1, (h, d)
        else:
            assert o['obey'] == F(cap(h), d), (h, d)
        assert sum(o.values()) == 1
assert [cap(h) for h in (0, 109, 110, 159, 160, 219, 220, 255)] == [24, 24, 39, 39, 54, 54, 101, 101]
print('asserts pass')
print('happiness  level  obey  other-move  nap  hurt  loaf')
for h, lv in [(70, (25, 30, 40, 55, 60, 70, 100)), (110, (40, 55, 70)), (160, (55, 70, 100)), (200, (55, 70, 100))]:
    for d in lv:
        o = odds(h, d)
        print(f'{h:>9}  {d:>5}  ' + '  '.join(f'{float(o[k])*100:5.1f}%' for k in ('obey','other','nap','hurt','loaf')))

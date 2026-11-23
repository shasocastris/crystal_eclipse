# Cycle-level model of the `.rand1` rejection loop in BattleCommand_CheckObedience:
#   .rand1: call BattleRandom / swap a / cp b / jr nc, .rand1
# Random adds/subtracts rDIV, which ticks every 64 M-cycles, so consecutive calls in a tight loop
# are correlated. Starting RNG bytes and divider phase are sampled uniformly.
import random, sys
ITER = 45            # M-cycles per loop pass
R1, R2 = 13, 24      # M-cycle offsets of the two rDIV reads within a pass
swap = lambda a: ((a << 4) | (a >> 4)) & 0xff

def rand1(b, rng):
    add, sub, t = rng.randrange(256), rng.randrange(256), rng.randrange(1 << 14)
    carry = 1                         # `cp d / ret nc` leaves carry set on entry
    while True:
        d1 = ((t + R1) >> 6) & 0xff
        s = add + d1 + carry; add = s & 0xff; carry = s >> 8
        d2 = ((t + R2) >> 6) & 0xff
        s = sub - d2 - carry; sub = s & 0xff; carry = 1 if s < 0 else 0
        t += ITER
        a = swap(sub)
        if a < b:
            return a
        carry = 0                     # jr nc taken: carry clear

def p_obey(cap, level, n=400000, seed=1):
    rng = random.Random(seed)
    return sum(rand1(level, rng) < cap for _ in range(n)) / n

if __name__ == '__main__':
    for cap, lv in [(54, 55), (39, 55), (24, 50), (54, 60), (54, 70), (39, 40), (24, 30), (54, 100)]:
        print('cap %3d level %3d  model %.4f  loop %.4f' % (cap, lv, cap / lv, p_obey(cap, lv)))

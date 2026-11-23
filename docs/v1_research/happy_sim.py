def ch(h,row):
    i=0 if h<100 else (1 if h<200 else 2)
    d=row[i]; return max(0,min(255,h+d))
LV=(5,3,2)
def levels(h,l0,l1):
    for _ in range(l1-l0): h=ch(h,LV)
    return h
for start,l0 in ((70,5),(70,30),(70,40),(200,40),(70,60)):
    out=[]
    for tgt in (25,40,55,70):
        if tgt>l0: out.append(f"L{tgt}:{levels(start,l0,tgt)}")
    print(f"start h={start} L{l0}:",' '.join(out))
# levels needed to reach thresholds
for start in (70,):
    for thr in (110,160,220):
        h=start;n=0
        while h<thr: h=ch(h,LV);n+=1
        print(f"from {start}: {n} level-ups to {thr}")
# obedience prob, vanilla roll with cap
def cap(h): return 101 if h>=220 else 54 if h>=160 else 39 if h>=110 else 24
for lvl,h in ((25,70),(30,70),(40,70),(55,200),(60,70),(70,70),(40,200)):
    c=cap(h)
    p=1.0 if lvl<=c else c/(c+lvl)
    print(f"L{lvl} h{h} cap{c} P(obey first roll)={p:.2f}")

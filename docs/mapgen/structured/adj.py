import sys, collections
from corpus import load_maps
ms = load_maps()
R = collections.defaultdict(collections.Counter); D = collections.defaultdict(collections.Counter); freq=collections.Counter()
for n,(w,h,d) in ms.items():
	for y in range(h):
		for x in range(w):
			b=d[y*w+x]; freq[b]+=1
			if x+1<w: R[b][d[y*w+x+1]]+=1
			if y+1<h: D[b][d[(y+1)*w+x]]+=1
L=collections.defaultdict(collections.Counter); U=collections.defaultdict(collections.Counter)
for a in R:
	for b,c in R[a].items(): L[b][a]+=c
for a in D:
	for b,c in D[a].items(): U[b][a]+=c
def f(c): return ' '.join(f'{k:02x}:{v}' for k,v in c.most_common(7))
for s in sys.argv[1:]:
	b=int(s,16)
	print(f'== {b:02x} n={freq[b]}\n  L {f(L[b])}\n  R {f(R[b])}\n  U {f(U[b])}\n  D {f(D[b])}')

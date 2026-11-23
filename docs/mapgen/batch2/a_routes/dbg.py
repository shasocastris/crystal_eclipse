import sys; sys.argv=['x',sys.argv[1],sys.argv[2],sys.argv[3]]
import amap2 as A
ref,w,h,data,objs,exits,ts=A.parse(sys.argv[1])
g=A.cells(w,h,data,A.load_coll(ts))
ex=dict((n,(x,y)) for n,x,y in exits)
r=A.reach(g,ex[sys.argv[2]],sys.argv[3]=='1',sys.argv[3]=='1')
for y in range(len(g)):
  print(f'{y:2d} '+''.join(('~' if g[y][x] in A.WATER else '#') if (x,y) in r else ('.' if A.kind(g[y][x],0,0) else ' ') for x in range(len(g[0]))))

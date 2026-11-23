import os, sys
from PIL import Image
D=os.path.dirname(os.path.abspath(__file__)) + '/'
out=sys.argv[1]; files=sys.argv[2:]
ims=[Image.open(D+f) for f in files]
sc=0.5
ims=[i.resize((int(i.width*sc),int(i.height*sc))) for i in ims]
W=sum(i.width for i in ims)+8*len(ims); Hh=max(i.height for i in ims)
s=Image.new('RGB',(W,Hh),(255,255,255)); x=0
for i in ims: s.paste(i,(x,0)); x+=i.width+8
s.save(D+out)

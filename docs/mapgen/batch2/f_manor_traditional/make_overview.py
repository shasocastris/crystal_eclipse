import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../../../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
from PIL import Image, ImageDraw, ImageFont
import os
os.chdir(f'{_REPO_ROOT}/docs/mapgen/batch2/f_manor_traditional')
try: F=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',18); f=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',14)
except: F=f=ImageFont.load_default()
S=0.75  # 24 px per step cell
maps={ # name: (file, title, pos)
 'study':('oborozuki_study_2f','2F  Master\'s Study + hidden room (12x8)',(20,60)),
 'shrine':('oborozuki_moon_shrine','3F  Moon Shrine - TOWER tileset (10x8)',(640,60)),
 'genkan':('oborozuki_genkan','1F  Genkan & Great Hall (14x10)',(20,520)),
 'engawa':('oborozuki_engawa','1F  East Engawa veranda (20x6)',(720,520)),
 'kagura':('oborozuki_kagura_hall','1F  Kagura Hall stage (10x9)',(1280,60)),
 'dojo':('oborozuki_dojo','Sunken Dojo (12x8)',(720,860)),
 'kura':('oborozuki_kura_b1f','B1F  Kura storehouse (10x7)',(1340,860)),
}
warps=[ # letter, map, cell
 ('A','genkan',13.5,19),('A','grounds',0,0),
 ('B','genkan',27,12.5),('B','engawa',5.5,11),
 ('C','genkan',27,2),('C','study',3,3),
 ('D','engawa',39,6.5),('D','kagura',9.5,17),
 ('E','engawa',37,5),('E','dojo',1,2),
 ('F','dojo',22,2),('F','kura',19,2),
 ('G','study',20,2),('G','shrine',10,14),
]
cols={'A':(255,255,255),'B':(255,80,80),'C':(80,200,255),'D':(255,200,0),'E':(120,255,120),'F':(255,120,255),'G':(255,160,60)}
W,H=1960,1470
o=Image.new('RGB',(W,H),(30,30,36)); d=ImageDraw.Draw(o)
d.text((20,15),'OBOROZUKI MANOR (traditional Johto estate interior) - warp letters pair up; A = front door to estate grounds',font=F,fill=(255,255,255))
pts={}
for k,(fn,t,(x,y)) in maps.items():
  im=Image.open(fn+'.png'); im=im.resize((int(im.width*S),int(im.height*S)),Image.NEAREST)
  o.paste(im,(x,y+24)); d.text((x,y),t,font=F,fill=(255,230,150))
  pts[k]=(x,y+24)
for L,m,cx,cy in warps:
  if m=='grounds': continue
  x0,y0=pts[m]; px=x0+cx*16*S*2/2*1+8*S*2/2; py=y0+cy*24+12
  px=x0+cx*24+12
  d.ellipse([px-13,py-13,px+13,py+13],fill=(0,0,0),outline=cols[L],width=3)
  d.text((px-6,py-10),L,font=F,fill=cols[L])
legend=['A  Genkan front mats (13,19)(14,19)  <->  Estate grounds front door',
 'B  Genkan east carpet (27,12)(27,13)  <->  Engawa stone mats (5,11)(6,11)',
 'C  Genkan stairs 39 (27,2)  <->  Study stairs 1e (3,3)   [steward scene until tea ceremony]',
 'D  Engawa east carpet (39,6)(39,7)  <->  Kagura Hall mats (9,17)(10,17)',
 'E  Engawa stairs 1e (37,5)  <->  Dojo stairs 39 (1,2)',
 'F  Dojo ladder 27 (22,2)  <->  Kura stairs 39 (19,2)   [locked until Genkuro beaten]',
 'G  Study ladder 27 (20,2)  <->  Moon Shrine ladder 1f (10,14)   [hidden room, bookcase (9,2) $1a->$04]']
for i,l in enumerate(legend):
  d.text((20,1290+i*24),l,font=f,fill=cols[l[0]])
o.save('oborozuki_overview.png'); print(o.size)

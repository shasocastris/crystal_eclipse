fn='violet.amap'; s=[l for l in open(fn).read().split('\n') if not l.startswith('# ')]
s=[l for l in s if not (l.startswith('exit ') and l.split()[1] in ('SproutTower','Gym','Academy'))]
hdr=open('violet_header.txt').read().rstrip('\n')
objs=open('violet_objs.txt').read().rstrip('\n')
open(fn,'w').write(hdr+'\n'+'\n'.join(s).rstrip('\n')+'\n'+objs+'\n')

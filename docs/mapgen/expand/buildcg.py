R=[
'T'*13+'..'+'T'*13,
'TTTTTTTTT'+',*,,'+'..'+',,,,cd,ab,kTT',
'^o^^oo..,'+'12,,'+'..'+',,,,ef,gh,*TT',
'rrR~~....'+'.,,,'+'..'+',,,,.,,.,,,,T',
'o~Y~~....'+'....'+'..'+'.'*13,
'~Xo[~~~..'+'....'+'..'+'.'*13,
'~XoM[~~~o'+'*k*,'+'..'+',*k*,,,ab,,,T',
'~X^^{~Zo]'+'*,*,'+'..'+',*,*,,,mn,,,T',
'~orRWWV~]'+',,,,'+'..'+',,,,,,,.,,,,T',
'~~~~~~~~]'+',,,,'+'..'+',,,,,,,,,,,,T',
'~~~~~~~~]'+'12,,'+'..'+',,12,,,12,,,T',
'~~~~BBBBB'+'....'+'..'+'............T',
'~~R~~~~~]'+',,k,'+'..'+',kk,,kk,,k,,T',
'~~~~~~~~]'+',kk,'+'..'+'kkk,*kkk,,kkT',
'~~~~~~~~]'+'*,,k'+'......'+',kkk,,,kT',
'~~~r~~~~]'+'k,,,'+'k,kk..'+',kk,*,,kT',
'~~~~~~~~]'+',*,k'+'kkkk..'+'......,kT',
'~~~~~~~~]'+'kk,,'+'k,kk,,'+'kk,**,,kT',
'~~~~~~~~]'+'kkk,'+'kkkkkk'+'kkk,,kkkT',
'~~~~~~~~]'+'T'*19,
]
for i,r in enumerate(R): assert len(r)==28,(i,len(r),r)
open('cherrygrove.amap','w').write('''# Cherrygrove City (expanded) -- draft 2
ref CherrygroveCity
key a=18 b=19 g=1a h=1b m=16 n=17 c=2c d=2d e=2e f=2f 1=14 2=15 k=ac B=89
key r=31 R=32 o=0a X=36 Y=3a [=58 M=71 {=79 Z=30 W=39 V=34
grid:
'''+'\n'.join(R)+'''
end
exit N 27 0
exit E 55 9
exit PIER 8 22
obj warp 19 5 EvolutionHouse
obj warp 39 5 Cafe
obj warp 45 5 PokeCenter
obj warp 45 15 Mart
obj warp 19 21 GuideGentsHouse
obj warp 35 21 GymSpeechHouse
obj warp 43 21 House
''')

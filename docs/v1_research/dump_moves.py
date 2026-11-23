#!/usr/bin/env python3
"""Dump per-move records from a built ROM, keyed by move NAME.
usage: dump_moves.py ROM.gbc ROM.sym [repo_root] > out.txt"""
import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import sys,re,os
rom=open(sys.argv[1],'rb').read(); symf=sys.argv[2]
R=sys.argv[3] if len(sys.argv)>3 else f'{_REPO_ROOT}'
sym={};rev={}
for l in open(symf):
    m=re.match(r'([0-9a-f]+):([0-9a-f]+) (\S+)',l)
    if m:
        b,a,n=int(m.group(1),16),int(m.group(2),16),m.group(3)
        sym[n]=(b,a); rev.setdefault((b,a),n) if '.' not in n else None
def off(b,a): return a if a<0x4000 else b*0x4000+(a-0x4000)
def at(n): return off(*sym[n])
def w(o): return rom[o]|rom[o+1]<<8
cm={}
for l in open(R+'/constants/charmap.asm'):
    m=re.match(r'\s*charmap\s+"([^"]+)",\s*\$([0-9a-f]+)',l)
    if m and int(m.group(2),16) not in cm: cm[int(m.group(2),16)]=m.group(1)
def text(o,stop=0x50,maxn=200):
    s=''
    for i in range(maxn):
        c=rom[o+i]
        if c==stop: return s
        s+=cm.get(c,'{%02x}'%c)
    return s+'...'
def indirect(name,idx):
    o=at(name); hdr=w(o); size=hdr&0x7fff; cur=hdr>>15; o+=2
    while True:
        cnt=rom[o]
        if cnt==0: return None
        bank,ptr=rom[o+1],w(o+2)
        if idx<cur+cnt:
            if bank==0 and ptr==0: return None
            return off(bank,ptr+(idx-cur)*size), bank
        cur+=cnt; o+=4
# names
o=at('MoveNames'); names=['NO_MOVE']
while True:
    s=text(o); 
    if len(names)>1 and s.startswith('...'): break
    names.append(s); o+=len(s.encode('latin1','replace')) if False else 0
    # advance by raw bytes
    k=0
    while rom[o+k]!=0x50: k+=1
    o+=k+1
    if len(names)>600: break
n_att=None
recs={}
for i in range(1,len(names)):
    r=indirect('Moves',i)
    if r is None: n_att=i-1; break
    mo,_=r; eff,pw,tp,acc,pp,ch=rom[mo:mo+6]
    d=indirect('MoveDescriptions',i); dp=w(d[0]); desc=text(off(d[1],dp)).replace('\n','/')
    a=indirect('BattleAnimations',i); ab,ap=rom[a[0]],w(a[0]+1)
    recs[i]=(names[i],f'eff={eff:02x} pow={pw} type={tp&0x3f:02x} cat={tp>>6} acc={acc} pp={pp} chance={ch} anim={rev.get((ab,ap),"%02x:%04x"%(ab,ap))} desc="{desc}"')
names=names[:n_att+1] if n_att else names
idx2name={i:v[0] for i,v in recs.items()}; idx2name[0]='NO_MOVE'
for i in sorted(recs,key=lambda i:recs[i][0]): print('MOVE',recs[i][0],'|',recs[i][1])
def wordlist(label,term):
    o=at(label); out=[]
    while True:
        v=w(o); o+=2
        if v==term: break
        out.append(idx2name.get(v,'#%04x'%v))
        if len(out)>400: out.append('!overrun'); break
    return out
print('LIST TMHMMoves',wordlist('TMHMMoves',0))
for L in ('CriticalHitMoves','MetronomeExcepts'):
    print('SET',L,sorted(wordlist(L,0xffff)))
# AI move lists: every label defined in data/battle/ai/*.asm
for f in sorted(os.listdir(R+'/data/battle/ai')):
    src=open(R+'/data/battle/ai/'+f).read()
    if not re.search(r'^\s*dw\s+[A-Z]',src,re.M): continue
    for l in src.split('\n'):
        m=re.match(r'(\w+):',l)
        if m and m.group(1) in sym: print('SET',m.group(1),sorted(wordlist(m.group(1),0xffff)))
print('NUM_ATTACKS',n_att)

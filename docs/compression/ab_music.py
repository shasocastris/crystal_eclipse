"""ROM-level A/B: flatten each music channel's executed bytecode on two ROMs and compare."""
import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import re, sys, glob
R=f'{_REPO_ROOT}'
def sym(p):
    d={}
    for l in open(p):
        m=re.match(r'([0-9a-f]+):([0-9a-f]+) (\S+)',l)
        if m: d.setdefault(m.group(3),(int(m.group(1),16),int(m.group(2),16)))
    return d
chans=[]
for f in sorted(glob.glob(R+'/audio/music/*.asm')):
    for l in open(f):
        m=re.match(r'\s+channel\s+(\d+),\s*(\S+)',l)
        if m: chans.append((m.group(2),int(m.group(1))))
LEN={0xd9:2,0xda:3,0xdb:2,0xdc:2,0xdd:2,0xde:2,0xdf:1,0xe0:3,0xe1:3,0xe2:2,0xe4:2,0xe5:2,0xe6:3,0xe7:2,0xe8:2,0xe9:3,0xec:1,0xed:1,0xef:2}
def flat(rom,syms,label,ch,steps=60000):
    bank,addr=syms[label]
    rd=lambda a: rom[bank*0x4000+(a-0x4000)]
    out=[];ret=None;looping=False;count=0;noise=False;depth=1
    budget=steps*4
    while len(out)<steps and budget:
        budget-=1
        assert 0x4000<=addr<0x8000,(label,hex(addr))
        op=rd(addr)
        if op<0xd8: out.append((op,)); addr+=1
        elif op==0xd8:
            n=2 if ch==4 else 3; out.append(tuple(rd(addr+k) for k in range(n))); addr+=n
        elif op==0xe3:
            if not noise: out.append((op,rd(addr+1))); addr+=2
            else: out.append((op,)); addr+=1
            noise=not noise
        elif op in LEN:
            n=LEN[op]; out.append(tuple(rd(addr+k) for k in range(n))); addr+=n
        elif op==0xfc: addr=rd(addr+1)|rd(addr+2)<<8
        elif op==0xfd:
            n=rd(addr+1); tgt=rd(addr+2)|rd(addr+3)<<8; jump=True
            if not looping and n: looping,count=True,n-1
            if looping:
                if count==0: looping,jump=False,False
                else: count-=1
            addr=tgt if jump else addr+4
        elif op==0xfe:
            if ret is not None: depth=2; break
            ret=addr+3; addr=rd(addr+1)|rd(addr+2)<<8
        elif op==0xff:
            if ret is None: break
            addr,ret=ret,None
        else: raise SystemExit('%s: opcode %02x at %04x'%(label,op,addr))
    return out,depth
a=open(sys.argv[1],'rb').read(); sa=sym(sys.argv[1][:-3]+'sym')
b=open(sys.argv[2],'rb').read(); sb=sym(sys.argv[2][:-3]+'sym')
bad=0;tot=0
for label,ch in chans:
    x=flat(a,sa,label,ch); y=flat(b,sb,label,ch); tot+=len(x[0])
    if x!=y or y[1]>1: bad+=1; print('DIFF',label,len(x[0]),len(y[0]),y[1])
print('channels',len(chans),'commands compared',tot,'differences',bad)

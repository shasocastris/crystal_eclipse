import re,subprocess,sys
labels=[]
for f in ['ram/wram.asm','ram/sram.asm','ram/hram.asm']:
    for i,l in enumerate(open(f),1):
        m=re.match(r'^([wsh][A-Za-z0-9_]+)::',l)
        if m: labels.append((f,i,m.group(1)))
src=subprocess.run("git ls-files '*.asm' '*.inc' | grep -v '^ram/'",shell=True,capture_output=True,text=True).stdout.split()
text="\n".join(open(p,errors='ignore').read() for p in src)
ramtext=open('ram/wram.asm').read()+open('ram/sram.asm').read()
pat=re.compile(sys.argv[1]) if len(sys.argv)>1 else None
for f,i,n in labels:
    if pat and not pat.search(n): continue
    used=re.search(r'\b'+re.escape(n)+r'\b',text)
    # ram-internal uses (e.g. sizeof via End - start)
    ram_uses=len(re.findall(r'\b'+re.escape(n)+r'\b',ramtext))
    print(("USED  " if used else "UNREF ")+f"{f}:{i} {n}"+(f" (ram refs {ram_uses})" if ram_uses>1 else ""))

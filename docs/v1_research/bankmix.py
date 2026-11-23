import re,sys
pinned=set()
for l in open('layout.link'):
    m=re.match(r'\s*"([^"]+)"',l)
    if m: pinned.add(m.group(1))
# also sections declared with explicit BANK[] in source
import subprocess
out=subprocess.run(r"git grep -hoE 'SECTION (UNION |FRAGMENT )?\"[^\"]+\", ROMX, BANK\[' -- '*.asm'",shell=True,capture_output=True,text=True).stdout
for m in re.finditer(r'"([^"]+)"',out): pinned.add(m.group(1))
mp=sys.argv[1]; banks=[int(b,16) for b in sys.argv[2:]]
cur=None
for l in open(mp):
    m=re.match(r'ROMX bank #(\d+):',l)
    if m: cur=int(m.group(1)); continue
    if re.match(r'(ROM0|WRAM|SRAM|VRAM|HRAM|OAM)',l): cur=None
    if cur in banks:
        m=re.match(r'\s+SECTION: \$(\w+)-\$(\w+) \(\$(\w+) bytes?\) \["(.+)"\]',l)
        if m: print(f"{cur:02x} {'PIN ' if m.group(4) in pinned else 'FLT '} {int(m.group(3),16):5d} {m.group(4)}")

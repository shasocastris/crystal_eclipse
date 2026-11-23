import re, subprocess, sys, os
REPO = sys.argv[1]
os.chdir(REPO)
files = subprocess.run(['git','diff','--name-only','v0.9..1fb549fdf','--','maps/'],capture_output=True,text=True).stdout.split()
files = [f for f in files if f.endswith('.asm')]
EXP = {'<PLAYER>':7,'<RIVAL>':7,'<MOM>':7,'<RED>':7,'<GREEN>':7,'<PLAY_G>':7,'#':4,'<PKMN>':2,'<POKE>':4,
       '<PC>':2,'<TM>':2,'<TRAINER>':7,'<ROCKET>':6,'<……>':2,'<USER>':11,'<TARGET>':11,'<ENEMY>':10,
       "'d":1,"'l":1,"'m":1,"'r":1,"'s":1,"'t":1,"'v":1,'<LV>':1,'<ID>':1,'<BOLD_V>':1,'<BOLD_S>':1}
TOK = re.compile('|'.join(re.escape(k) for k in sorted(EXP, key=len, reverse=True)) + r'|<[A-Z_]+>|.')
def L(s):
    n=0
    for t in TOK.findall(s):
        if t=='@': continue
        n += EXP.get(t, 1 if not (t.startswith('<') and len(t)>1) else 0)
    return n
# old strings for "new?" marker
def old_strings(f):
    r = subprocess.run(['git','show','v0.9:'+f],capture_output=True,text=True)
    return set(re.findall(r'"([^"]*)"', r.stdout)) if r.returncode==0 else set()
CMD = re.compile(r'^\s*(text|line|cont|para|next|page|text_start)\s+"([^"]*)"')
RAM = re.compile(r'^\s*(text_ram|text_decimal|text_buffer|text_move)\b')
for f in files:
    olds = old_strings(f)
    lines = open(f).read().split('\n')
    prev_ram=False; prev_str=None
    for i,l in enumerate(lines,1):
        m = CMD.match(l)
        if m:
            s = m.group(2); n = L(s)
            cont_line = prev_ram and m.group(1)=='text'
            tag = 'NEW' if s not in olds else 'old'
            if n>18:
                print('%s:%d: %d chars [%s] %s' % (f,i,n,tag,l.strip()))
            elif cont_line:
                print('%s:%d: CONCAT after text_ram (check manually) [%s] %s' % (f,i,tag,l.strip()))
            prev_ram=False
        elif RAM.match(l):
            prev_ram=True
        elif l.strip() and not l.strip().startswith(';'):
            prev_ram = prev_ram and False

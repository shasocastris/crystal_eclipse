import re, subprocess, os, sys, collections
os.chdir(sys.argv[1])
files = [f for f in subprocess.run(['git','diff','--name-only','v0.9..1fb549fdf','--','maps/'],capture_output=True,text=True).stdout.split() if f.endswith('.asm')]
idx = collections.defaultdict(collections.Counter)
for f in subprocess.run(['git','ls-files','*.asm'],capture_output=True,text=True).stdout.split():
    for line in open(f, errors='replace'):
        line = line.split(';')[0]
        m = re.match(r'\s*(\w+)', line)
        if not m: continue
        for fl in re.findall(r'\bEVENT_\w+', line):
            idx[fl][m.group(1)] += 1
for f in files:
    s = open(f).read()
    consts = re.findall(r'^\s*const (\w+)', s.split('_MapScripts:')[0], re.M)
    objs = re.findall(r'^\s*object_event\b.*$', s, re.M)
    if consts and len(consts) != len(objs):
        print('%s: %d object consts vs %d object_events' % (f, len(consts), len(objs)))
    for fl in sorted(set(re.findall(r'\bEVENT_\w+', s))):
        if fl.startswith('EVENT_TEMPORARY'): continue
        u = idx[fl]
        w = u['setevent'] + u['clearevent'] + u['trainer'] + u['hiddenitem'] + u['itemball'] + u['disappear'] + u['appear']
        r = u['checkevent'] + u['object_event'] + u['trainer'] + u['hiddenitem'] + u['itemball']
        if w == 0 or r == 0:
            print('%s: %s %s' % (f, fl, dict(u)))

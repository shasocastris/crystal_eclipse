# meta.py NAME: wrap NAME.amap with NAME_header.txt and append NAME_objs.txt
import sys
n = sys.argv[1]; fn = n + '.amap'
s = [l for l in open(fn).read().split('\n') if not l.startswith('#') and not l.startswith('obj ')]
open(fn, 'w').write(open(n + '_header.txt').read().rstrip('\n') + '\n' + '\n'.join(s).rstrip('\n') + '\n'
                    + open(n + '_objs.txt').read().rstrip('\n') + '\n')

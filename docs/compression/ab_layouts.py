"""A/B: apply every SCGB_* layout on two ROMs from the same fixture and compare palettes + attrmap."""
import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import re, sys
R=f'{_REPO_ROOT}'
sys.path.insert(0, R+'/docs/regression/harness')
from fixtures import fixture
names=re.findall(r'^\s*const (SCGB_\w+)', open(R+'/constants/scgb_constants.asm').read(), re.M)
def dump(rom):
    g=fixture('debug_party', rom=rom)
    assert g.run_until('PlayerEvents', 600)
    base=g.state(); res={}
    for i,n in enumerate(names):
        g.load(base)
        try:
            g.call('GetSGBLayout', bc=i<<8)
            wbk=g.read('rWBK') if 'rWBK' in g.syms else None
            res[n]=(bytes(g.read('wBGPals1',64)),bytes(g.read('wOBPals1',64)),bytes(g.read('wBGPals2',64)),bytes(g.read('wOBPals2',64)),bytes(g.read('wAttrmap',360)),g.read('wDefaultSGBLayout'))
        except Exception as e:
            res[n]='ERR %s'%type(e).__name__
    return res
a=dump(sys.argv[1]); b=dump(sys.argv[2])
bad=[n for n in names if a[n]!=b[n]]; err=[n for n in names if isinstance(a[n],str) or isinstance(b[n],str)]
print('layouts',len(names),'mismatch',len(bad),bad,'errors',len(err),[(n,a[n] if isinstance(a[n],str) else 'ok',b[n] if isinstance(b[n],str) else 'ok') for n in err])

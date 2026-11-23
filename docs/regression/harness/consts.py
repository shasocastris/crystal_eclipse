"""Resolve assembler constants (event flags, species, items...) by asking rgbasm itself."""
import os
import re
import subprocess
import tempfile

from gb import REPO

_cache = {}


def resolve(*names, debug=True):
    """Return {name: value} for each constant, as the debug (or release) build sees it."""
    todo = [n for n in names if (n, debug) not in _cache]
    if todo:
        lines = ['INCLUDE "includes.asm"'] + ['PRINTLN "{0}=", {0}'.format(n) for n in todo]
        with tempfile.NamedTemporaryFile('w', suffix='.asm', dir=REPO, delete=False) as f:
            f.write('\n'.join(lines) + '\n')
            src = f.name
        try:
            cmd = ['rgbasm', '-Q8', '-o', os.devnull, src]
            if debug:
                cmd[1:1] = ['-D', '_DEBUG']
            out = subprocess.run(cmd, cwd=REPO, capture_output=True, text=True)
        finally:
            os.unlink(src)
        if out.returncode:
            raise RuntimeError(out.stderr.strip()[-2000:])
        for m in re.finditer(r'^(\w+)=\$?(-?[0-9A-Fa-f]+)$', out.stdout, re.M):
            _cache[(m.group(1), debug)] = int(m.group(2), 16)
    return {n: _cache[(n, debug)] for n in names}


def value(name, debug=True):
    return resolve(name, debug=debug)[name]

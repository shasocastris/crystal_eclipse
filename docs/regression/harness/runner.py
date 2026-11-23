"""Test registry and runner. Each test gets a fresh Game loaded from a fixture.

    python runner.py [suite ...] [--rom PATH] [--jobs N]

Writes docs/regression/reports/<timestamp>-<rom id>/report.{json,md}; exits nonzero on any failure.
"""
import argparse
import datetime
import importlib
import json
import os
import sys
import time
import traceback
from multiprocessing import Pool

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

from gb import REPO  # noqa: E402
from fixtures import fixture, rom_id  # noqa: E402

import glob  # noqa: E402
SUITES = sorted(os.path.basename(f)[:-3] for f in glob.glob(os.path.join(HERE, 'suite_*.py')))
from registry import TESTS, Skip  # noqa: E402


def _run_one(args):
    name, rom, shots = args
    for mod in SUITES:
        importlib.import_module(mod)
    fn, fix = TESTS[name]
    t = time.time()
    result = {'test': name, 'status': 'pass', 'detail': None}
    g = None
    try:
        g = fixture(fix, rom=rom)
        g.shots = shots
        out = fn(g)
        if out:
            result['detail'] = out
    except Skip as e:
        result.update(status='skip', detail=str(e))
    except AssertionError as e:
        result.update(status='fail', detail=str(e))
    except Exception:
        result.update(status='error', detail=traceback.format_exc()[-3000:])
    finally:
        if g:
            if result['status'] in ('fail', 'error'):
                try:
                    g.render(True)
                    g.frames(2)
                    g.screenshot(os.path.join(shots, name + '.png'))
                except Exception:
                    pass
            g.close()
    result['seconds'] = round(time.time() - t, 2)
    return result


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('suites', nargs='*')
    ap.add_argument('--rom', default=os.path.join(REPO, 'crystal_eclipse_debug.gbc'))
    ap.add_argument('--jobs', type=int, default=1)
    ap.add_argument('-k', default='', help='only tests whose name contains this')
    a = ap.parse_args()
    global SUITES
    if a.suites:
        SUITES = a.suites
    for mod in SUITES:
        importlib.import_module(mod)
    names = [n for n in TESTS if a.k in n]
    rid = rom_id(a.rom)
    # build fixtures once, serially, before fanning out
    for fix in sorted({TESTS[n][1] for n in names}):
        fixture(fix, rom=a.rom).close()
    stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
    out = os.path.join(HERE, '..', 'reports', '%s-%s' % (stamp, rid))
    shots = os.path.join(out, 'shots')
    os.makedirs(shots, exist_ok=True)
    jobs = [(n, a.rom, shots) for n in names]
    if a.jobs > 1:
        with Pool(a.jobs) as p:
            results = p.map(_run_one, jobs)
    else:
        results = []
        for j in jobs:
            r = _run_one(j)
            print('%-5s %s (%ss)' % (r['status'].upper(), r['test'], r['seconds']), flush=True)
            results.append(r)
    counts = {s: sum(r['status'] == s for r in results) for s in ('pass', 'fail', 'error', 'skip')}
    report = {'rom': a.rom, 'rom_id': rid, 'when': stamp, 'counts': counts, 'results': results}
    with open(os.path.join(out, 'report.json'), 'w') as f:
        json.dump(report, f, indent=1, default=str)
    with open(os.path.join(out, 'report.md'), 'w') as f:
        f.write('# Regression report %s\n\nROM `%s` (%s)\n\n' % (stamp, os.path.relpath(a.rom, REPO), rid))
        f.write('pass %(pass)d, fail %(fail)d, error %(error)d, skip %(skip)d\n\n' % counts)
        f.write('| Test | Status | Seconds | Detail |\n|---|---|---|---|\n')
        for r in results:
            d = (str(r['detail'] or '')).replace('\n', ' ').replace('|', '/')[:300]
            f.write('| %s | %s | %s | %s |\n' % (r['test'], r['status'], r['seconds'], d))
    for r in results:
        print('%-5s %s %s' % (r['status'].upper(), r['test'], '' if r['status'] == 'pass' else (str(r['detail'])[:400])))
    print(counts, '->', os.path.relpath(out, REPO))
    sys.exit(1 if counts['fail'] or counts['error'] else 0)


if __name__ == '__main__':
    main()

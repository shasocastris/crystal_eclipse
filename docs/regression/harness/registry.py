"""Shared test registry (kept apart from runner.py so `python runner.py` and suites see one copy)."""
import json

TESTS = {}


class Skip(Exception):
    pass


def test(suite, fixture_name='debug_party'):
    def deco(fn):
        TESTS['%s.%s' % (suite, fn.__name__)] = (fn, fixture_name)
        return fn
    return deco


def check(cond, msg, **detail):
    if not cond:
        raise AssertionError(msg + (' ' + json.dumps(detail, default=str) if detail else ''))

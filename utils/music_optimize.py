#!/usr/bin/env python3
"""Shrink pokecrystal-style music by factoring repeated command runs into sound_call subroutines.

Usage:
    python3 utils/music_optimize.py [--dry-run] [audio/music/*.asm]

All music files are read together, because songs call each other's subroutines.
Files are rewritten in place. Nothing is written unless every channel of every
song plays the same command stream before and after (see `verify`).

Rules the engine imposes:
- One return address per channel, so a sound_call may not sit in code that is
  itself reached through a sound_call.
- A subroutine must be in the same bank as its caller, so each new subroutine is
  appended to the file that uses it.

Savings are scored in ROM bytes: a run of B bytes used k times costs k*3 + B + 1
after factoring, instead of k*B.
"""
import argparse
import glob
import os
import re
import sys

CONTROL = {'sound_call', 'sound_jump', 'sound_jump_if', 'sound_loop', 'sound_ret'}
CALL_BYTES = 3
RET_BYTES = 1
VERIFY_STEPS = 60000


def command_size(name, nargs):
    """ROM bytes of a plain sound command, or None if it must not be moved."""
    fixed = {'note': 1, 'rest': 1, 'drum_note': 1, 'octave': 1, 'volume_envelope': 2, 'drum_speed': 2,
             'stereo_panning': 2, 'duty_cycle': 2, 'vibrato': 3, 'tempo': 3, 'volume': 2, 'pitch_offset': 3,
             'transpose': 2, 'pitch_slide': 3}
    if name in fixed:
        return fixed[name]
    if name == 'note_type':
        return 2 if nargs == 1 else 3
    if name == 'toggle_noise':
        return 1 if nargs == 0 else 2
    return None


class Line:
    __slots__ = ('text', 'kind', 'name', 'args', 'token', 'size', 'label', 'called')

    def __init__(self, text, parent):
        self.text = text
        self.called = False
        self.kind, self.name, self.args, self.token, self.size, self.label = 'other', '', [], '', None, None
        code = text.split(';', 1)[0].rstrip()
        if not code.strip():
            self.kind = 'blank'
            return
        if not code[0].isspace():
            name = code.strip().rstrip(':')
            self.kind = 'label'
            self.label = parent + name if name.startswith('.') else name
            return
        parts = code.split(None, 1)
        self.name = parts[0]
        self.args = [a.strip() for a in parts[1].split(',')] if len(parts) > 1 else []
        self.token = self.name + ' ' + ','.join(self.args)
        if self.name in CONTROL:
            self.kind = 'control'
        else:
            self.size = command_size(self.name, len(self.args))
            self.kind = 'command' if self.size is not None else 'other'


class Song:
    def __init__(self, path):
        self.path = path
        with open(path, encoding='utf-8', newline='') as f:
            raw = f.read()
        self.eol = '\r\n' if '\r\n' in raw else '\n'
        self.lines = []
        self.parents = []
        parent = ''
        for text in raw.split(self.eol):
            line = Line(text, parent)
            if line.kind == 'label' and '.' not in line.label:
                parent = line.label
            self.lines.append(line)
            self.parents.append(parent)
        if self.lines and self.lines[-1].text == '':
            self.lines.pop()
            self.parents.pop()

    def target(self, i):
        """Full label a control command at line i points to."""
        t = self.lines[i].args[-1]
        return self.parents[i] + t if t.startswith('.') else t


def index_labels(songs):
    labels = {}
    for s in songs:
        for i, line in enumerate(s.lines):
            if line.kind == 'label':
                if line.label in labels:
                    raise SystemExit('duplicate label %s' % line.label)
                labels[line.label] = (s, i)
    return labels


def mark_called_code(songs, labels):
    """Flag every line reachable from a sound_call target without returning."""
    work = []
    for s in songs:
        for i, line in enumerate(s.lines):
            if line.name == 'sound_call':
                work.append(labels[s.target(i)])
    while work:
        s, i = work.pop()
        while i < len(s.lines) and not s.lines[i].called:
            line = s.lines[i]
            line.called = True
            if line.kind == 'control':
                if line.name == 'sound_ret':
                    break
                if line.name != 'sound_call':
                    work.append(labels[s.target(i)])
                if line.name == 'sound_jump' or (line.name == 'sound_loop' and line.args[0] == '0'):
                    break
            i += 1


def play(songs, labels, song, start, steps=VERIFY_STEPS):
    """The plain commands a channel executes from `start`, following calls, loops and jumps the way
    the engine does. Returns (tokens, deepest call seen)."""
    out = []
    s, i = labels[start]
    ret, looping, count = None, False, 0
    budget = steps * 4
    while len(out) < steps and budget:
        budget -= 1
        if i >= len(s.lines):
            raise SystemExit('%s: %s runs off the end of %s' % (song.path, start, s.path))
        line = s.lines[i]
        if line.kind == 'command' or line.kind == 'other':
            out.append(line.token)
        elif line.kind == 'control':
            if line.name == 'sound_ret':
                if ret is None:
                    break
                (s, i), ret = ret, None
                continue
            if line.name == 'sound_call':
                if ret is not None:
                    return out, 2
                ret = (s, i + 1)
                s, i = labels[s.target(i)]
                continue
            if line.name == 'sound_jump':
                s, i = labels[s.target(i)]
                continue
            if line.name == 'sound_loop':
                n = int(line.args[0])
                jump = True
                if not looping:
                    if n:
                        looping, count = True, n - 1
                if looping:
                    if count == 0:
                        looping, jump = False, False
                    else:
                        count -= 1
                if jump:
                    s, i = labels[s.target(i)]
                    continue
            else:
                raise SystemExit('%s: unsupported %s' % (s.path, line.name))
        i += 1
    return out, 1


def channels(song):
    return [song.lines[i].args[-1] for i in range(len(song.lines)) if song.lines[i].name == 'channel']


def streams(songs):
    labels = index_labels(songs)
    res = {}
    for s in songs:
        for ch in channels(s):
            res[(s.path, ch)] = play(songs, labels, s, ch)
    return res


def best_pattern(song):
    """Most profitable repeated run of plain commands in one file: (saving, length, [start lines])."""
    lines = song.lines
    ok = [l.kind == 'command' and not l.called for l in lines]
    groups = {}
    for i in range(len(lines) - 1):
        if ok[i] and ok[i + 1]:
            groups.setdefault((lines[i].token, lines[i + 1].token), []).append(i)
    groups = [g for g in groups.values() if len(g) > 1]
    best = (0, 0, [])
    length = 2
    while groups:
        nxt = []
        for g in groups:
            size = sum(lines[g[0] + k].size for k in range(length))
            chosen, end = [], -1
            for i in g:
                if i >= end:
                    chosen.append(i)
                    end = i + length
            if len(chosen) > 1:
                saving = len(chosen) * (size - CALL_BYTES) - (size + RET_BYTES)
                if saving > best[0]:
                    best = (saving, length, chosen)
            split = {}
            for i in g:
                j = i + length
                if j < len(lines) and ok[j]:
                    split.setdefault(lines[j].token, []).append(i)
            nxt.extend(v for v in split.values() if len(v) > 1)
        groups = nxt
        length += 1
    return best


def optimize(song, used_labels):
    """Factor repeated runs out of one song. Returns the ROM bytes saved."""
    base = next(l.label for l in song.lines if l.kind == 'label')
    last = next(l for l in reversed(song.lines) if l.kind in ('command', 'control', 'other'))
    if not (last.name in ('sound_ret', 'sound_jump') or (last.name == 'sound_loop' and last.args[0] == '0')):
        return 0
    defs = []
    saved = 0
    n = 0
    while True:
        saving, length, starts = best_pattern(song)
        if saving <= 0:
            break
        n += 1
        while '%s_Ditty%d' % (base, n) in used_labels:
            n += 1
        label = '%s_Ditty%d' % (base, n)
        used_labels.add(label)
        body = song.lines[starts[0]:starts[0] + length]
        defs.append((label, [l.text for l in body], [l.token for l in body], sum(l.size for l in body)))
        indent = body[0].text[:len(body[0].text) - len(body[0].text.lstrip())]
        for i in reversed(starts):
            song.lines[i:i + length] = [Line('%ssound_call %s' % (indent, label), '')]
            song.parents[i:i + length] = ['']
        saved += saving

    # A subroutine that is the tail of a longer one shares its bytes.
    defs.sort(key=lambda d: -len(d[2]))
    hosts = []
    for label, texts, tokens, size in defs:
        for host in hosts:
            if host['tokens'][-len(tokens):] == tokens:
                host['entries'].setdefault(len(host['tokens']) - len(tokens), []).append(label)
                saved += size + RET_BYTES
                break
        else:
            hosts.append({'tokens': tokens, 'texts': texts, 'entries': {0: [label]}})
    for host in reversed(hosts):
        out = ['']
        for k, text in enumerate(host['texts']):
            out.extend('%s:' % l for l in host['entries'].get(k, []))
            out.append(text)
        out.append('\tsound_ret')
        for text in out:
            song.lines.append(Line(text, ''))
            song.lines[-1].called = True
            song.parents.append('')
    return saved


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('files', nargs='*')
    ap.add_argument('--dry-run', action='store_true', help='report savings without writing')
    args = ap.parse_args()
    paths = sorted(args.files or glob.glob(os.path.join(os.path.dirname(__file__), '..', 'audio', 'music', '*.asm')))

    before = streams([Song(p) for p in paths])
    for key, (tokens, depth) in before.items():
        if depth > 1:
            raise SystemExit('%s %s already nests sound_call' % key)

    songs = [Song(p) for p in paths]
    labels = index_labels(songs)
    mark_called_code(songs, labels)
    used = set(labels)
    total = 0
    changed = []
    for s in songs:
        saved = optimize(s, used)
        if saved:
            total += saved
            changed.append((saved, s))

    after = streams(songs)
    for key in before:
        if after[key][1] > 1:
            raise SystemExit('verify failed: %s %s nests sound_call' % key)
        if after[key][0] != before[key][0]:
            raise SystemExit('verify failed: %s %s plays differently' % key)

    for saved, s in sorted(changed, key=lambda c: -c[0]):
        print('%6d  %s' % (saved, os.path.relpath(s.path)), file=sys.stderr)
        if not args.dry_run:
            with open(s.path, 'w', encoding='utf-8', newline='') as f:
                f.write(s.eol.join(l.text for l in s.lines) + s.eol)
    print('%d bytes saved in %d files; %d channels verified%s' % (
        total, len(changed), len(before), ' (dry run)' if args.dry_run else ''), file=sys.stderr)


if __name__ == '__main__':
    main()

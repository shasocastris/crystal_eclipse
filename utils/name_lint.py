#!/usr/bin/env python3
"""Report mentions of a personal name in the repo.

Matches the name case-insensitively with y/i spellings swapped
(bryan, Bryan's, BRIAN, ...). Game content is skipped: an all-caps match
(the trainer constants BRYAN, BRIAN, BRIANA) or one inside an identifier
(BirdKeeperBryan, CooltrainermBrian).

Usage: name_lint.py [--name NAME]... [--all] [PATH...]
"""

import argparse
import os
import re
import subprocess
import sys

REPO = subprocess.run(['git', 'rev-parse', '--show-toplevel'], capture_output=True,
	text=True, check=True).stdout.strip()


def pattern(names):
	alts = []
	for name in names:
		alts.append(''.join('[yi]' if c in 'yi' else re.escape(c) for c in name.lower()))
	return re.compile('|'.join(alts), re.IGNORECASE)


def is_game_content(line, m):
	before = line[m.start() - 1] if m.start() else ''
	if m.group().isupper():
		# BRYAN, BRIANA, EVENT_BEAT_BIRD_KEEPER_BRYAN; not BRYAN_SAV
		after = re.match(r'\w*', line[m.end():]).group()
		return not before.isalnum() and '_' not in after
	return before.isalpha()


def main():
	ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
	ap.add_argument('--name', action='append', help='name to look for (default: bryan)')
	ap.add_argument('--all', action='store_true', help='also show skipped game content')
	ap.add_argument('paths', nargs='*')
	args = ap.parse_args()
	rx = pattern(args.name or ['bryan'])

	cmd = ['git', 'ls-files', '-z', '--cached', '--others', '--exclude-standard', '--'] + args.paths
	files = [f for f in subprocess.run(cmd, cwd=REPO, capture_output=True,
		check=True).stdout.decode().split('\0') if f]
	self_path = os.path.relpath(os.path.abspath(__file__), REPO)

	found = 0
	for path in files:
		if path == self_path:
			continue
		try:
			data = open(os.path.join(REPO, path), 'rb').read()
		except (IsADirectoryError, FileNotFoundError):
			continue
		if b'\0' in data:
			continue
		text = data.decode('utf-8', errors='replace')
		if not rx.search(text):
			continue
		for no, line in enumerate(text.splitlines(), 1):
			for m in rx.finditer(line):
				skip = is_game_content(line, m)
				if skip and not args.all:
					continue
				tag = 'game' if skip else 'name'
				print(f'{path}:{no}:{m.start() + 1}: {tag}: {line.strip()[:120]}')
				found += not skip
	print(f'{found} mention(s)', file=sys.stderr)
	return 1 if found else 0


if __name__ == '__main__':
	sys.exit(main())

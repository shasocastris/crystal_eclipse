#!/usr/bin/env python3
"""Find absolute home-directory paths in the repo, and optionally fix them.

A path under ~/Documents/Romhacks/ (the repo's parent) is fixable:
  scripts (.py, .sh)  the path is computed at run time from the script's own
                      location: <Romhacks>/crystal_eclipse becomes the repo
                      root, any other <Romhacks>/X becomes a sibling of it
  everything else     the prefix is replaced with ~/
Any other /home/<user>/ path is reported but left alone.

Usage: home_path_lint.py [--fix] [PATH...]   (default: tracked + untracked,
non-ignored files)
"""

import argparse
import ast
import os
import re
import subprocess
import sys

REPO = subprocess.run(['git', 'rev-parse', '--show-toplevel'], capture_output=True,
	text=True, check=True).stdout.strip()
REPO_NAME = os.path.basename(REPO)
PREFIX = r'/home/[^/\s\'"]+/Documents/Romhacks/'
FIXABLE = re.compile(PREFIX)
ANY_HOME = re.compile(r'/home/[^/\s\'"]+/')

# a string literal that starts with the prefix
PY_LITERAL = re.compile(r'(?P<pre>[rRfF]{0,2})(?P<q>[\'"])(?P<path>' + PREFIX + r')(?P<rest>[^\'"\n]*)(?P=q)')
SH_PATH = re.compile(PREFIX + r'(?P<rest>[^\s\'"}]*)')


def list_files(paths):
	cmd = ['git', 'ls-files', '-z', '--cached', '--others', '--exclude-standard', '--'] + paths
	out = subprocess.run(cmd, cwd=REPO, capture_output=True, check=True).stdout
	return [f for f in out.decode().split('\0') if f]


def read_text(path):
	try:
		data = open(os.path.join(REPO, path), 'rb').read()
	except (IsADirectoryError, FileNotFoundError):
		return None
	if b'\0' in data:
		return None
	try:
		return data.decode('utf-8')
	except UnicodeDecodeError:
		return None


def split_rest(rest):
	"""'crystal_eclipse/maps/x' -> ('{_REPO_ROOT}', '/maps/x')"""
	head, sep, tail = rest.partition('/')
	if head == REPO_NAME:
		return '{_REPO_ROOT}', sep + tail
	return '{_ROMHACKS}/', rest


def fix_python(path, text):
	def repl(m):
		pre, q, rest = m['pre'], m['q'], m['rest']
		if 'f' not in pre.lower():
			rest = rest.replace('{', '{{').replace('}', '}}')
			pre = 'f' + pre
		root, tail = split_rest(rest)
		return f'{pre}{q}{root}{tail}{q}'

	new, n = PY_LITERAL.subn(repl, text)
	if not n:
		return text
	depth = len(os.path.dirname(path).split('/')) if os.path.dirname(path) else 0
	up = "'" + '/'.join(['..'] * depth) + "'" if depth else "'.'"
	header = ('import os as _os\n'
		f'_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), {up}))\n'
		'_ROMHACKS = _os.path.dirname(_REPO_ROOT)\n')
	lines = new.splitlines(keepends=True)
	at = 0
	if lines and lines[0].startswith('#!'):
		at = 1
	try:
		tree = ast.parse(text)
		for node in tree.body:
			is_doc = (isinstance(node, ast.Expr) and isinstance(node.value, ast.Constant)
				and isinstance(node.value.value, str) and node is tree.body[0])
			is_future = isinstance(node, ast.ImportFrom) and node.module == '__future__'
			if not (is_doc or is_future):
				break
			at = max(at, node.end_lineno)
	except SyntaxError:
		pass
	lines.insert(at, header)
	return ''.join(lines)


def fix_shell(path, text):
	def repl(m):
		root, tail = split_rest(m['rest'])
		root = root.replace('{_REPO_ROOT}', '$_REPO_ROOT').replace('{_ROMHACKS}', '$_ROMHACKS')
		return root + tail

	new, n = SH_PATH.subn(repl, text)
	if not n:
		return text
	header = ('_REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"\n'
		'_ROMHACKS="$(dirname "$_REPO_ROOT")"\n')
	lines = new.splitlines(keepends=True)
	at = 1 if lines and lines[0].startswith('#!') else 0
	lines.insert(at, header)
	return ''.join(lines)


def fix_text(path, text):
	return FIXABLE.sub('~/', text)


def main():
	ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
	ap.add_argument('--fix', action='store_true', help='rewrite fixable paths in place')
	ap.add_argument('paths', nargs='*')
	args = ap.parse_args()

	self_path = os.path.relpath(os.path.abspath(__file__), REPO)
	found = fixed = 0
	for path in list_files(args.paths):
		if path == self_path:
			continue
		text = read_text(path)
		if text is None or not ANY_HOME.search(text):
			continue
		if args.fix and FIXABLE.search(text):
			if path.endswith('.py'):
				new = fix_python(path, text)
			elif path.endswith('.sh'):
				new = fix_shell(path, text)
			else:
				new = fix_text(path, text)
			if new != text:
				open(os.path.join(REPO, path), 'w', encoding='utf-8').write(new)
				fixed += 1
				text = new
		for no, line in enumerate(text.splitlines(), 1):
			for m in ANY_HOME.finditer(line):
				kind = 'fixable' if FIXABLE.match(line, m.start()) else 'manual'
				print(f'{path}:{no}: {kind}: {line.strip()[:120]}')
				found += 1
	if args.fix:
		print(f'{fixed} file(s) rewritten', file=sys.stderr)
	return 1 if found else 0


if __name__ == '__main__':
	sys.exit(main())

#!/usr/bin/env python3
"""Lint text/line/cont/para dialogue in RGBDS sources.

Models how home/text.asm reads the bytes: a TX_* command (text_ram,
text_decimal, ...) leaves the engine in command mode, so the next thing
must be `text`, `text_start` or another command, never a bare
line/cont/para/done.

Checks:
  error    width       a printed line is wider than the text box (18 tiles)
  warning  width-approx same, but the line includes a value of guessed width
  error    charmap     a character with no charmap entry
  error    cmd-mode    line/cont/para/done/prompt while in command mode
  error    line-twice  `line` while already on the bottom row (overwrites it)
  error    unterminated a text block runs to the end of the file
  warning  fallthrough  a text block runs into the next label (shared tails do this)
  warning  cont-top    `cont` straight after text/para (scrolls a lone line)
  warning  trail-space trailing space at the end of a printed line
  style    para-blank  no blank line before `para`
  style    indent      indented with spaces instead of a tab
  style    lead-space  leading space (often deliberate: centred signs)
  style    dbl-space   two spaces in a row

Usage:
  utils/dialogue_lint.py                      # lint maps/ and engine/
  utils/dialogue_lint.py maps/Foo.asm ...     # specific files or dirs
  utils/dialogue_lint.py --changed core       # only lines changed vs a ref
  utils/dialogue_lint.py --style --strict     # include style; warnings fail

Exits 1 when any error is reported (or any warning, with --strict).
"""

import argparse
import os
import re
import subprocess
import sys

BOX_WIDTH = 18
NAME_WIDTH = 7  # PLAYER_NAME_LENGTH - 1
MON_WIDTH = 10  # MON_NAME_LENGTH - 1

TOKEN_WIDTHS = {
	'#': 4, '<POKE>': 2, '<PKMN>': 2, '<PC>': 2, '<TM>': 2,
	'<TRAINER>': 7, '<ROCKET>': 6, '<……>': 2,
	'<PLAYER>': NAME_WIDTH, '<PLAY_G>': NAME_WIDTH, '<RIVAL>': NAME_WIDTH,
	'<RED>': NAME_WIDTH, '<GREEN>': NAME_WIDTH, '<MOM>': NAME_WIDTH,
	'<USER>': MON_WIDTH, '<TARGET>': MON_WIDTH, '<ENEMY>': 6,
	'<WBR>': 0, '<NULL>': 0, '<LF>': 0, '<CR>': 0, '<SCROLL>': 0,
	'<MOBILE>': 0, '<DEXEND>': 0, '@': 0,
}

# text_ram targets whose width is known; anything else counts as 0 and
# marks the line as approximate.
RAM_WIDTHS = {
	'wPlayerName': NAME_WIDTH, 'wRivalName': NAME_WIDTH,
	'wMomsName': NAME_WIDTH, 'wRedsName': NAME_WIDTH,
	'wGreensName': NAME_WIDTH,
}

STRING_CMDS = {'text', 'line', 'cont', 'para', 'next', 'page'}
END_CMDS = {'done', 'prompt'}
TX_CMDS = {
	'text_ram', 'text_bcd', 'text_move', 'text_box', 'text_low',
	'text_promptbutton', 'text_scroll', 'text_decimal', 'text_pause',
	'text_dots', 'text_waitbutton', 'text_buffer', 'text_today',
	'sound_dex_fanfare_50_79', 'sound_dex_fanfare_20_49', 'sound_item',
	'sound_caught_mon', 'sound_dex_fanfare_80_109', 'sound_fanfare',
	'sound_slot_machine_start',
}
# The text engine stops interpreting after these.
LEAVE_CMDS = {'text_end', 'text_asm'}

DIRECTIVES = {'if', 'elif', 'else', 'endc', 'rept', 'endr', 'for', 'include',
	'section', 'def', 'macro', 'endm', 'assert', 'static_assert', 'charmap',
	'pushs', 'pops', 'load', 'endl', 'export', 'opt', 'pusho', 'popo'}

LABEL_RE = re.compile(r'^([A-Za-z_.][\w.]*):{0,2}(?=\s|;|$)')
CMD_RE = re.compile(r'^(\s+)([a-z_0-9]+)\b\s*(.*)$')


def repo_root():
	return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def load_charmap(root):
	keys = set()
	pat = re.compile(r'^\s*charmap\s+"((?:[^"\\]|\\.)*)"')
	with open(os.path.join(root, 'constants/charmap.asm'), encoding='utf-8') as f:
		for line in f:
			m = pat.match(line)
			if m:
				keys.add(m.group(1).encode().decode('unicode_escape')
					if '\\' in m.group(1) else m.group(1))
	return keys


def load_numeric_constants(root):
	"""Best effort: DEF X EQU <int> for {d:X} interpolation."""
	consts = {}
	pat = re.compile(r'^\s*DEF\s+(\w+)\s+EQU\s+(\$[0-9a-fA-F]+|%[01]+|\d+)\s*(;.*)?$')
	for dirpath, _, files in os.walk(os.path.join(root, 'constants')):
		for fn in files:
			if not fn.endswith('.asm'):
				continue
			with open(os.path.join(dirpath, fn), encoding='utf-8') as f:
				for line in f:
					m = pat.match(line)
					if m:
						v = m.group(2)
						consts[m.group(1)] = int(v[1:], 16) if v[0] == '$' else \
							int(v[1:], 2) if v[0] == '%' else int(v)
	return consts


def split_comment(rest):
	"""Return (code, comment) splitting on the first ; outside a string."""
	in_str = False
	esc = False
	for i, c in enumerate(rest):
		if in_str:
			if esc:
				esc = False
			elif c == '\\':
				esc = True
			elif c == '"':
				in_str = False
		elif c == '"':
			in_str = True
		elif c == ';':
			return rest[:i], rest[i:]
	return rest, ''


def parse_string(arg):
	"""Return the literal inside the first "..." of arg, or None."""
	m = re.match(r'\s*"((?:[^"\\]|\\.)*)"', arg)
	return m.group(1) if m else None


class Linter:
	def __init__(self, root):
		self.charkeys = load_charmap(root)
		self.maxkey = max(len(k) for k in self.charkeys)
		self.consts = load_numeric_constants(root)
		self.issues = []

	def report(self, path, lineno, sev, code, msg):
		self.issues.append((path, lineno, sev, code, msg))

	def measure(self, s, path, lineno):
		"""Display width of a string literal; (width, exact)."""
		width = 0
		exact = True
		i = 0
		while i < len(s):
			if s[i] == '{':
				j = s.find('}', i)
				if j < 0:
					self.report(path, lineno, 'error', 'charmap', 'unclosed { in string')
					return width, False
				expr = s[i + 1:j]
				fmt, _, sym = expr.rpartition(':')
				if sym in self.consts and fmt in ('d', 'u', ''):
					width += len(str(self.consts[sym]))
				else:
					exact = False
					width += 2
				i = j + 1
				continue
			if s[i] == '\\' and i + 1 < len(s):
				i += 2
				width += 1
				continue
			for n in range(min(self.maxkey, len(s) - i), 0, -1):
				tok = s[i:i + n]
				if tok in self.charkeys:
					width += TOKEN_WIDTHS.get(tok, 1)
					i += n
					break
			else:
				self.report(path, lineno, 'error', 'charmap',
					f'no charmap entry for {s[i]!r}')
				width += 1
				i += 1
		return width, exact

	def lint_file(self, path):
		try:
			with open(path, encoding='utf-8') as f:
				lines = f.read().split('\n')
		except UnicodeDecodeError:
			return

		mode = None       # None, 'char', 'cmd'
		row = None        # 'top', 'bottom'
		width = 0
		exact = True
		block_start = 0
		block_label = None
		cur_label = None
		prev_blank = True
		# pending trailing-space check: (lineno, string) of the last printed
		# segment, resolved by whatever comes next.
		pending_tail = None
		continuing = False

		def flush_tail(continues_same_line):
			nonlocal pending_tail
			if pending_tail and not continues_same_line:
				ln, s = pending_tail
				if s.endswith(' '):
					self.report(path, ln, 'warning', 'trail-space',
						f'trailing space on printed line: "{s}"')
			pending_tail = None

		def check_width(ln, s):
			if width > BOX_WIDTH:
				if exact:
					self.report(path, ln, 'error', 'width',
						f'line is {width} tiles wide, max {BOX_WIDTH}: "{s}"')
				else:
					self.report(path, ln, 'warning', 'width-approx',
						f'line is at least ~{width} tiles wide, max {BOX_WIDTH}: "{s}"')

		for idx, raw in enumerate(lines):
			ln = idx + 1
			code, _ = split_comment(raw)
			stripped = code.strip()
			if not stripped:
				prev_blank = True
				continue

			first = stripped.split(None, 1)[0].lower()
			if first.rstrip(':') in DIRECTIVES or first.startswith(('if', 'endc', 'else')) and '(' in first:
				# Conditional assembly inside a block: keep tracking through it.
				if first in ('if', 'elif', 'else', 'endc'):
					prev_blank = True if first == 'endc' and prev_blank else prev_blank
					continue
				if mode is not None:
					flush_tail(False)
					mode = None
				continue

			lm = LABEL_RE.match(code)
			if lm and not code[0].isspace():
				label = lm.group(1)
				if mode is not None and not label.startswith('.'):
					self.report(path, block_start, 'warning', 'fallthrough',
						f'text block {block_label or ""} runs into label {label}')
					mode = None
				if not label.startswith('.'):
					cur_label = label
				rest = code[lm.end():]
				if not rest.strip():
					prev_blank = False
					continue
				code = ' ' + rest.strip()

			cm = CMD_RE.match(code)
			if not cm:
				prev_blank = False
				continue
			indent, cmd, arg = cm.groups()

			if cmd in STRING_CMDS or cmd in END_CMDS or cmd in TX_CMDS \
					or cmd in LEAVE_CMDS or cmd in ('text_start', 'text_far'):
				if ' ' in indent.replace('\t', '') and indent.startswith(' '):
					self.report(path, ln, 'style', 'indent', 'indented with spaces')

			if cmd in STRING_CMDS:
				s = parse_string(arg)
				if s is None:
					prev_blank = False
					continue
				if cmd == 'text':
					if mode == 'cmd':
						flush_tail(True)
						continuing = True
					else:
						flush_tail(False)
						if mode is None:
							block_start = ln
							block_label = cur_label
						row, width, exact, continuing = 'top', 0, True, False
					mode = 'char'
				else:
					if mode == 'cmd':
						self.report(path, ln, 'error', 'cmd-mode',
							f'`{cmd}` after a text command needs `text_start` first')
					elif mode is None:
						prev_blank = False
						continue  # not dialogue (e.g. a bare db context)
					flush_tail(False)
					if cmd == 'para':
						if not prev_blank:
							self.report(path, ln, 'style', 'para-blank',
								'no blank line before `para`')
						row = 'top'
					elif cmd == 'line':
						if row == 'bottom':
							self.report(path, ln, 'error', 'line-twice',
								'`line` while already on the bottom row; use `cont`')
						row = 'bottom'
					elif cmd == 'cont':
						if row == 'top' and s.strip('@'):
							self.report(path, ln, 'warning', 'cont-top',
								'`cont` right after a top-row line; use `line`')
						row = 'bottom'
					width, exact, continuing = 0, True, False
					mode = 'char'
				w, ex = self.measure(s, path, ln)
				width += w
				exact = exact and ex
				check_width(ln, s)
				if not continuing and s.startswith(' '):
					self.report(path, ln, 'style', 'lead-space',
						f'leading space on printed line: "{s}"')
				if '  ' in s:
					self.report(path, ln, 'style', 'dbl-space', f'double space: "{s}"')
				pending_tail = (ln, s)
				if '@' in s:
					# '@' ends the string; the engine is back in command mode.
					# Whatever is spliced in next continues this line.
					pending_tail = None
					mode = 'cmd'

			elif cmd in END_CMDS:
				if mode == 'cmd':
					self.report(path, ln, 'error', 'cmd-mode',
						f'`{cmd}` after a text command needs `text_start` first')
				flush_tail(False)
				mode = None

			elif cmd == 'text_start':
				if mode is None:
					block_start, block_label = ln, cur_label
					row, width, exact = 'top', 0, True
				mode = 'char'

			elif cmd in TX_CMDS:
				if mode is None:
					block_start, block_label = ln, cur_label
					row, width, exact = 'top', 0, True
				flush_tail(cmd in ('text_ram', 'text_decimal', 'text_bcd',
					'text_buffer', 'text_today', 'text_dots'))
				if cmd == 'text_ram':
					sym = arg.split(',')[0].strip()
					if sym in RAM_WIDTHS:
						width += RAM_WIDTHS[sym]
					else:
						exact = False
				elif cmd == 'text_decimal':
					parts = [p.strip() for p in arg.split(',')]
					try:
						width += int(parts[2])
					except (IndexError, ValueError):
						exact = False
				elif cmd in ('text_buffer', 'text_bcd', 'text_today'):
					exact = False
				elif cmd in ('text_promptbutton', 'text_waitbutton', 'text_scroll'):
					pass
				mode = 'cmd'

			elif cmd == 'text_far':
				flush_tail(False)
				if mode is None:
					block_start, block_label = ln, cur_label
				mode = 'cmd'

			elif cmd in LEAVE_CMDS:
				flush_tail(False)
				if cmd == 'text_end' and mode == 'char':
					mode = 'cmd'  # '@' ends the string; still need a TX_END
				else:
					mode = None

			elif mode is not None:
				# Any other directive inside a text block (db, dw, IF...)
				# means we can't follow it; stop tracking quietly.
				flush_tail(False)
				mode = None

			prev_blank = False

		if mode is not None:
			self.report(path, block_start, 'error', 'unterminated',
				f'text block {block_label or ""} runs to end of file')


def changed_lines(ref, root):
	"""{path: set(lines)} added/modified vs ref, including the worktree."""
	out = subprocess.run(['git', 'diff', '-U0', ref, '--', '*.asm'],
		cwd=root, capture_output=True, text=True, check=True).stdout
	result = {}
	path = None
	for line in out.split('\n'):
		if line.startswith('+++ '):
			p = line[4:]
			path = p[2:] if p.startswith('b/') else None
			if path:
				result.setdefault(path, set())
		elif line.startswith('@@') and path:
			m = re.search(r'\+(\d+)(?:,(\d+))?', line)
			start, count = int(m.group(1)), int(m.group(2) or 1)
			result[path].update(range(start, start + count))
	untracked = subprocess.run(['git', 'ls-files', '--others', '--exclude-standard', '--', '*.asm'],
		cwd=root, capture_output=True, text=True, check=True).stdout.split()
	for p in untracked:
		result[p] = None  # whole file
	return result


def main():
	ap = argparse.ArgumentParser(description=__doc__,
		formatter_class=argparse.RawDescriptionHelpFormatter)
	ap.add_argument('paths', nargs='*', help='files or directories (default: maps engine)')
	ap.add_argument('--changed', metavar='REF',
		help='only report issues on lines added/changed since REF')
	ap.add_argument('--style', action='store_true', help='include style issues')
	ap.add_argument('--strict', action='store_true', help='warnings also fail')
	ap.add_argument('--summary', action='store_true', help='print counts per check only')
	args = ap.parse_args()

	root = repo_root()
	os.chdir(root)
	linter = Linter(root)

	only = None
	if args.changed:
		only = changed_lines(args.changed, root)
		files = sorted(p for p in only if os.path.exists(p))
		if args.paths:
			files = [f for f in files if any(f == p or f.startswith(p.rstrip('/') + '/')
				for p in args.paths)]
	else:
		files = []
		for p in args.paths or ['maps', 'engine']:
			if os.path.isdir(p):
				for dirpath, _, fns in os.walk(p):
					files += [os.path.join(dirpath, fn) for fn in fns if fn.endswith('.asm')]
			else:
				files.append(p)
		files.sort()

	for f in files:
		linter.lint_file(f)

	shown = []
	for path, ln, sev, code, msg in linter.issues:
		if sev == 'style' and not args.style:
			continue
		if only is not None:
			lines = only.get(path)
			if lines is not None and ln not in lines:
				continue
		shown.append((path, ln, sev, code, msg))

	if args.summary:
		counts = {}
		for _, _, sev, code, _ in shown:
			counts[(sev, code)] = counts.get((sev, code), 0) + 1
		for (sev, code), n in sorted(counts.items()):
			print(f'{n:6d}  {sev:7s} {code}')
	else:
		for path, ln, sev, code, msg in shown:
			print(f'{path}:{ln}: {sev}: [{code}] {msg}')

	errors = sum(1 for s in shown if s[2] == 'error')
	warnings = sum(1 for s in shown if s[2] == 'warning')
	print(f'{len(files)} files, {errors} errors, {warnings} warnings', file=sys.stderr)
	if errors or (args.strict and warnings):
		sys.exit(1)


if __name__ == '__main__':
	main()

#!/usr/bin/env python3
"""Render named maps from another pret hack: render_other.py REPO OUTDIR Map [Map...] [--grid]"""
import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import os, sys
sys.path.insert(0, f'{_REPO_ROOT}/utils')
import render_overworld as ro
from PIL import Image, ImageDraw
args = [a for a in sys.argv[1:] if not a.startswith('--')]
grid = '--grid' in sys.argv
repo, out, names = os.path.abspath(args[0]), os.path.abspath(args[1]), args[2:]
os.chdir(repo)
name = next(n for n, e in ro.ENGINES.items() if e.detect())
eng = ro.ENGINES[name]('summer', 'day')
maps = eng.load_maps()
for n in names:
	m = maps[n]
	meta, attr, vram, pals = eng.render_inputs(m)
	w, h = m['w'], m['h']
	data = m['blocks'] if isinstance(m['blocks'], (bytes, bytearray)) else open(m['blocks'], 'rb').read()
	img = Image.new('RGB', (w * 32, h * 32)); d = ImageDraw.Draw(img)
	for i, b in enumerate(data[:w * h]):
		x, y = (i % w) * 32, (i // w) * 32
		img.paste(ro.render_block(b, meta, attr, vram, pals), (x, y))
	if grid:
		for i, b in enumerate(data[:w * h]):
			x, y = (i % w) * 32, (i // w) * 32
			d.rectangle([x, y, x + 31, y + 31], outline=(255, 0, 255))
			d.text((x + 2, y + 2), f'{b:02x}', fill=(255, 255, 255), stroke_width=1, stroke_fill=(0, 0, 0))
	p = os.path.join(out, n + ('_grid' if grid else '') + '.png'); img.save(p); print(p, w, h, name)

#!/usr/bin/env python3
"""Render a raw .ablk (1 byte per 32x32 metatile) with the real Johto tileset.

  python render_ablk.py FILE.ablk WIDTH OUT.png [--ref Route30] [--grid] [--time day] [--season summer]
  python render_ablk.py --atlas OUT.png [--ref Map]  # every block of --ref's tileset, labelled

--ref picks an existing TILESET_JOHTO map whose group/env/palette to borrow
(roof colours come from the map group). --grid overlays block indices.
"""
import os as _os
_REPO_ROOT = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '../..'))
_ROMHACKS = _os.path.dirname(_REPO_ROOT)
import argparse, os, sys
REPO = f'{_REPO_ROOT}'
sys.path.insert(0, os.path.join(REPO, 'utils'))
_CWD = os.getcwd()
os.chdir(REPO)
import render_overworld as ro
from PIL import Image, ImageDraw

def engine_and_ref(ref, season, time):
	eng = ro.CSE(season, time)
	maps = eng.load_maps()
	return eng, maps[ref]

def render(blocks, w, eng, ref, grid=False, scale=1):
	meta, attr, vram, pals = eng.render_inputs(ref)
	h = len(blocks) // w
	img = Image.new('RGB', (w * 32, h * 32))
	cache = {}
	for i, b in enumerate(blocks[:w * h]):
		if b not in cache:
			cache[b] = ro.render_block(b, meta, attr, vram, pals)
		img.paste(cache[b], ((i % w) * 32, (i // w) * 32))
	if grid:
		d = ImageDraw.Draw(img)
		for i, b in enumerate(blocks[:w * h]):
			x, y = (i % w) * 32, (i // w) * 32
			d.rectangle([x, y, x + 31, y + 31], outline=(255, 0, 255))
			d.text((x + 2, y + 2), f'{b:02x}', fill=(255, 255, 255), stroke_width=1, stroke_fill=(0, 0, 0))
	if scale != 1:
		img = img.resize((img.width * scale, img.height * scale), Image.NEAREST)
	return img

if __name__ == '__main__':
	ap = argparse.ArgumentParser()
	ap.add_argument('file', nargs='?'); ap.add_argument('width', nargs='?', type=int); ap.add_argument('out', nargs='?')
	ap.add_argument('--ref', default='Route30'); ap.add_argument('--grid', action='store_true')
	ap.add_argument('--atlas'); ap.add_argument('--time', default='day'); ap.add_argument('--season', default='summer')
	ap.add_argument('--scale', type=int, default=1)
	a = ap.parse_args()
	for k in ('file', 'out', 'atlas'):
		if getattr(a, k): setattr(a, k, os.path.join(_CWD, getattr(a, k)))
	eng, ref = engine_and_ref(a.ref, a.season, a.time)
	if a.atlas:
		n = len(open(eng.tilesets[ref['tileset']]['meta'], 'rb').read()) // 16
		img = render(bytes(range(n)) + bytes((16 - n % 16) % 16), 16, eng, ref, grid=True, scale=2)
		img.save(a.atlas); print(a.atlas, n, 'blocks')
	else:
		data = open(a.file, 'rb').read()
		render(data, a.width, eng, ref, grid=a.grid, scale=a.scale).save(a.out); print(a.out)

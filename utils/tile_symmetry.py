#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Usage: python tile_symmetry.py [tileset.png ...]

Report tiles in each tileset that duplicate another tile exactly or as an
H, V or HV flip, i.e. tiles that block attribute flip bits could replace.
Defaults to every gfx/tilesets/*.png. Blank (single-color) tiles are skipped.
"""

import glob
import os
import sys

from PIL import Image

def get_tiles(path):
	im = Image.open(path).convert('L')
	w, h = im.size
	px = im.load()
	return [tuple(tuple(px[tx*8+x, ty*8+y] for x in range(8)) for y in range(8))
		for ty in range(h // 8) for tx in range(w // 8)]

def hflip(t):
	return tuple(r[::-1] for r in t)

def vflip(t):
	return t[::-1]

def is_blank(t):
	return len(set(sum(t, ()))) == 1

FLIPS = (('H', hflip), ('V', vflip), ('HV', lambda t: hflip(vflip(t))))

def main():
	paths = sys.argv[1:] or sorted(glob.glob('gfx/tilesets/*.png'))
	print(f"{'tileset':24}{'size':>5}{'blank':>6}{'selfH':>6}{'dup':>5}{'H':>4}{'V':>4}{'HV':>4}{'save':>5}  pairs")
	total = 0
	for path in paths:
		tiles = get_tiles(path)
		seen = {}
		counts = {'dup': 0, 'H': 0, 'V': 0, 'HV': 0}
		pairs = []
		for i, t in enumerate(tiles):
			if is_blank(t):
				continue
			if t in seen:
				counts['dup'] += 1
				pairs.append(f'={seen[t]:02x}>{i:02x}')
				continue
			for kind, flip in FLIPS:
				f = flip(t)
				if f != t and f in seen:
					counts[kind] += 1
					pairs.append(f'{kind}{seen[f]:02x}>{i:02x}')
					break
			else:
				seen[t] = i
		save = sum(counts.values())
		total += save
		num_blank = sum(map(is_blank, tiles))
		self_h = sum(1 for t in tiles if not is_blank(t) and t == hflip(t))
		name = os.path.splitext(os.path.basename(path))[0]
		print(f"{name:24}{len(tiles):>5}{num_blank:>6}{self_h:>6}{counts['dup']:>5}"
			f"{counts['H']:>4}{counts['V']:>4}{counts['HV']:>4}{save:>5}  {' '.join(pairs)}")
	print('total reclaimable:', total)

if __name__ == '__main__':
	main()

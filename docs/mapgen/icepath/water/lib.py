"""Shared helpers for the Ice Path water experiments (design only; never touches the build)."""
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..'))
os.chdir(REPO)
sys.path.insert(0, os.path.join(REPO, "utils")); sys.path.insert(0, HERE)
import render_overworld as ro
from PIL import Image, ImageDraw

def tiles_of(name):
	d = open(f'gfx/tilesets/{name}.2bpp', 'rb').read()
	return [d[i:i + 16] for i in range(0, len(d), 16)]

def px(tile):
	"""16 bytes -> 8 rows of 8 colour indexes."""
	return [[((tile[2 * y] >> (7 - x)) & 1) | (((tile[2 * y + 1] >> (7 - x)) & 1) << 1) for x in range(8)] for y in range(8)]

def unpx(rows):
	out = bytearray()
	for r in rows:
		lo = hi = 0
		for x, c in enumerate(r):
			lo |= (c & 1) << (7 - x); hi |= (c >> 1) << (7 - x)
		out += bytes([lo, hi])
	return bytes(out)

def pals_of(name):
	return [list(p) for p in ro.palettes_of(ro.parse_rgb(f'gfx/tilesets/{name}.pal'))[:8]]

def rgb(c):
	return tuple(c)  # parse_rgb already returns 8-bit

def draw_tile(img, x, y, tile, pal, xflip=False, yflip=False):
	p = px(tile)
	for j in range(8):
		for i in range(8):
			c = p[7 - j if yflip else j][7 - i if xflip else i]
			img.putpixel((x + i, y + j), rgb(pal[c]))

def draw_block(img, bx, by, b, meta, attr, tiles, pals):
	for k in range(16):
		t, a = meta[b * 16 + k], attr[b * 16 + k]
		idx = t + (128 if a & 8 else 0) if t < 128 else t
		tile = tiles[idx] if idx < len(tiles) else bytes(16)
		draw_tile(img, bx + (k % 4) * 8, by + (k // 4) * 8, tile, pals[a & 7], bool(a & 0x20), bool(a & 0x40))

def atlas(meta, attr, tiles, pals, cols=16, scale=3, label=True):
	n = len(meta) // 16
	rows = (n + cols - 1) // cols
	img = Image.new('RGB', (cols * 32, rows * 32))
	for b in range(n):
		draw_block(img, (b % cols) * 32, (b // cols) * 32, b, meta, attr, tiles, pals)
	img = img.resize((img.width * scale, img.height * scale), Image.NEAREST)
	if label:
		d = ImageDraw.Draw(img)
		for b in range(n):
			x, y = (b % cols) * 32 * scale, (b // cols) * 32 * scale
			d.rectangle([x, y, x + 32 * scale - 1, y + 32 * scale - 1], outline=(255, 0, 255))
			d.text((x + 2, y + 2), f'{b:02x}', fill=(255, 255, 255), stroke_width=1, stroke_fill=(0, 0, 0))
	return img

def sheet(tiles, pal, cols=16, scale=4):
	rows = (len(tiles) + cols - 1) // cols
	img = Image.new('RGB', (cols * 8, rows * 8))
	for i, t in enumerate(tiles):
		draw_tile(img, (i % cols) * 8, (i // cols) * 8, t, pal)
	img = img.resize((img.width * scale, img.height * scale), Image.NEAREST)
	d = ImageDraw.Draw(img)
	for i in range(len(tiles)):
		x, y = (i % cols) * 8 * scale, (i // cols) * 8 * scale
		d.rectangle([x, y, x + 8 * scale - 1, y + 8 * scale - 1], outline=(255, 0, 255))
	return img

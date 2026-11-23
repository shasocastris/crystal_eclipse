from lib import *
S = os.environ.get('OUT', HERE)
def labelled(tiles, pal, base, scale=6, cols=16):
	img = sheet(tiles, pal, cols, scale)
	big = Image.new('RGB', (img.width + 30, img.height + 14), (40, 40, 40)); big.paste(img, (30, 14))
	d = ImageDraw.Draw(big)
	for c in range(cols): d.text((30 + c * 8 * scale + 16, 1), f'{c:x}', fill=(255, 255, 0))
	for r in range((len(tiles) + cols - 1) // cols): d.text((2, 14 + r * 8 * scale + 16), f'{base + r * 16:02x}', fill=(255, 255, 0))
	return big
ip = pals_of('ice_path'); t = tiles_of('ice_path')
labelled(t[128:], ip[6], 0).save(f'{S}/ice_bank1.png')
labelled(t[:128], ip[5], 0).save(f'{S}/ice_bank0.png')
bg = [list(p) for p in ro.palettes_of(ro.parse_rgb('gfx/tilesets/bg_tiles.pal'))]
labelled(tiles_of('cave'), ip[6], 0).save(f'{S}/cave_in_ice_pal.png')
m = open('data/tilesets/ice_path_metatiles.bin', 'rb').read(); a = open('data/tilesets/ice_path_attributes.bin', 'rb').read()
for want in (0x31, 0x35):
	print(hex(want), 'bank0 used by blocks', sorted({hex(i // 16) for i in range(len(m)) if m[i] == want and not a[i] & 8}))
print('bank0 used ids', sorted({hex(m[i]) for i in range(len(m)) if not a[i] & 8}))
c = tiles_of('cave')
for i in (0x14, 0x40): print(hex(i), px(c[i]))

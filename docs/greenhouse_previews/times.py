# times.py OUT.png — each option in day/nite/winter using the engine's real palettes
import sys
sys.path.insert(0, 'utils'); sys.path.insert(0, 'docs/greenhouse_previews')
import render_overworld as R
import draft
from PIL import Image
SLOT = {'gray': 0, 'red': 1, 'green': 2, 'water': 3, 'yellow': 4, 'brown': 5, 'roof': 6}
rows = []
for season, time in (('summer', 'day'), ('summer', 'nite'), ('winter', 'day')):
	e = R.ENGINES['cse'](season, time)
	m = e.load_maps()['CeladonCity']
	pals = e.render_inputs(m)[3]
	city = R.render_map(e, m)
	draft.PAL = {k: pals[v] for k, v in SLOT.items()}
	row = []
	for rp in ('water', 'roof', 'gray'):
		c = city.copy(); c.paste(draft.building(rp)[0], (32, 13 * 32))
		row.append(c.crop((0, 12 * 32 + 16, 8 * 32, 15 * 32 + 16)))
	rows.append(row)
pw, ph = rows[0][0].size
sheet = Image.new('RGB', (3 * (pw + 6), 3 * (ph + 6)), (255, 255, 255))
for j, row in enumerate(rows):
	for i, p in enumerate(row):
		sheet.paste(p, (i * (pw + 6), j * (ph + 6)))
sheet.resize((sheet.width * 2, sheet.height * 2), Image.NEAREST).save(sys.argv[1])

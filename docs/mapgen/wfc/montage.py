import sys
from PIL import Image
out, files = sys.argv[1], sys.argv[2:]
ims = [Image.open(f) for f in files]
c = Image.new('RGB', (sum(i.width for i in ims) + 10 * (len(ims) - 1), max(i.height for i in ims)), (255, 0, 255))
x = 0
for i in ims:
	c.paste(i, (x, 0)); x += i.width + 10
c.save(out)

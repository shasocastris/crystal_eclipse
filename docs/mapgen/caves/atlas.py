from common import *
eng, ref = R.engine_and_ref('UnionCave1F','summer','day')
print(eng.tilesets.keys() if hasattr(eng.tilesets,'keys') else '')
meta=eng.tilesets['TILESET_CAVE']['meta']; print(meta)
n=len(open(meta,'rb').read())//16
img=R.render(bytes(range(n))+bytes((16-n%16)%16),16,eng,ref,grid=True,scale=2)
img.save(D+'/caves/cave_atlas.png'); print(n)

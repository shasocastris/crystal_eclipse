import sys
p='engine/battle/core.asm'
s=open(p).read()
CHK="\tldh a, [hSerialConnectionStatus]\n\tcp USING_EXTERNAL_CLOCK\n\tjr z, {rev}\n"
def strip(func, rev, upto):
    global s
    f=s.index("\n"+func+":\n")+1
    hdr=func+":\n"+CHK.format(rev=rev.rstrip(":"))
    assert s[f:f+len(hdr)]==hdr, (func, s[f:f+len(hdr)+40])
    s=s[:f]+func+":\n"+s[f+len(hdr):]
    a=s.index("\n"+rev+"\n",f)+1
    b=s.index("\n"+upto+"\n",a)+1
    print("== "+func+" removed:\n"+s[a:b])
    s=s[:a]+s[b:]
for func,rev,upto in [
 ("HandleEncore",".player_1",".do_player"),
 ("HandlePerishSong",".EnemyFirst:",".do_it"),
 ("HandleWrap",".EnemyFirst:",".do_it"),
 ("HandleLeftovers",".DoEnemyFirst:",".do_it"),
 ("HandleMysteryberry",".DoEnemyFirst:",".do_it"),
 ("HandleFutureSight",".enemy_first",".do_it"),
 ("HandleSafeguard",".player1",".CheckPlayer:"),
 ("HandleScreens",".Both:",".CheckPlayer:"),
]:
    strip(func,rev,upto)
open(p,'w').write(s)

# Regression baselines

These are frozen builds for differential tests. Each is built in its own detached worktree under the session scratchpad, so the main working tree is untouched.

- Scratchpad: `/tmp/claude-1000/-home-bryan-Documents-Romhacks-crystal-eclipse/2d70e333-cae6-412c-bf2d-cf4827cd6419/scratchpad`. It is wiped on reboot. To rebuild, run `git worktree add --detach <path> <commit>` and then `make -j12 crystal_eclipse.gbc crystal_eclipse_debug.gbc`.
- Worktrees: `<scratchpad>/worktrees/{pre11,post11,v09}`.
- Copies of each build's ROM, .sym and .map (release and debug): `<scratchpad>/roms/{pre11,post11,v09}/`.

| Name | Commit | What it is |
|---|---|---|
| pre11 | `4d064f0f6` | Core just before link removal: V0's five bug fixes, with the full link engine still present |
| post11 | `480adfab8` | The last branch-11 commit, with the link, trade, Time Capsule and serial code gone |
| v09 | `2f2a153e6` | Tag `v0.9`. **The tag is the logo commit, which sits one commit after `9a507d462`** |

Branch 11 spans `89209c9e8..480adfab8`, six commits:
1. move the trade animation and TryQuickSave out of the link files
2. drop the link specials
3. strip the battle engine
4. strip home, overworld and menus
5. delete the engines and the serial handler
6. remove the link RAM

## SHA-256

```
fc9508eb9fcc393aee526bb8017a2971d8b194f2877f89bc178185c02e40ee03  pre11/crystal_eclipse.gbc
64ba081725e4b2c44ec069569f1cba885c36b298c98134a7391ea1f6fbaac92e  pre11/crystal_eclipse.sym
e024e4fdec5abb691ac0eca84e7d011fc8641f2b6fab1edee23a3f51835ffeec  pre11/crystal_eclipse.map
97700cee393d3236594fb76fafeebc3dd9d6d0c6506ffdfee11e2a1e27d92c8f  pre11/crystal_eclipse_debug.gbc
9e058599f4ba68dc1db22be2b25563c6dd882da492669a5db10904da9c916b45  pre11/crystal_eclipse_debug.sym
24061ea05aef8822e1a71081eaff0be5da88b177f7f778e53ace6a8b93c86cfe  pre11/crystal_eclipse_debug.map
c5e5bf39cfdf8be70871c199b9b68511ef342e44d2b0acd9c792ff477187a06f  post11/crystal_eclipse.gbc
4fa3dc6b8b1a13993bc9946d9e45d1d1294c3536912eee04638d2b1b7707ecdc  post11/crystal_eclipse.sym
d62378d425f29c115f0e09621fe3299e43a7512cec57672e39ef7d182db1302d  post11/crystal_eclipse.map
0a7a844b2953736ee7c72057571a2f1c5ae1586a8918fb523f14f5a78053a129  post11/crystal_eclipse_debug.gbc
2089d693c1597752b72b8022ad7d0357072cb23325948a02d5dcf23e15c40c80  post11/crystal_eclipse_debug.sym
29ef00933df19372b1ad835597866e310c83f980fdfbe58ea3813a2cd91a4f99  post11/crystal_eclipse_debug.map
aaf64b7a2d1e682e4c1ba66e09b25607ca8fe697ed2c0d69de4fcd62606fed32  v09/crystal_eclipse.gbc
43cf66a6e33eca257b9684969f7658ad62fb10a769e14176445b0fbc40e1c80c  v09/crystal_eclipse.sym
f713a96e86400e11cf127244aed9a9e9544e3edef246e73c5cba9fb35b8d3017  v09/crystal_eclipse.map
ffdb7206c8d60ecb33816c4c6217891086242fb2e534598f39a2e75a839d6745  v09/crystal_eclipse_debug.gbc
0723c01457be5ee8f885ac850e981310758b93a9e575c688d4619f103dcd6a3b  v09/crystal_eclipse_debug.sym
3b24a00c19991c5c9db6e1750eaad2599ba2a81a7a5b9210502846bd7176ad58  v09/crystal_eclipse_debug.map
```

## What branch 11 changed in the battle engine (pre11 → post11)

Diff scope: `engine/battle/` and `home/`, 22 files changed, +17 / −1785 lines. The bulk is `core.asm` (−1080 lines) and `home/serial.asm` (deleted).

1. **RNG.** `BattleRandom` is now a second label on `Random`. The banked `_BattleRandom` (link-sync PRNG) wrapper is gone.
   - Battle rolls now come from the hardware-based `Random`.
   - So a pre11-vs-post11 differential test with identical inputs **will not match bit for bit**. Compare outcome distributions, or seed both through hooks.
2. **Move order** (`DetermineMoveOrder`). Three `hSerialConnectionStatus == USING_INTERNAL_CLOCK` "player 2" arms are removed: Quick Claw, priority and speed ties. **This is the highest-value target: speed ties, Quick Claw, priority moves, and the order after a switch.**
3. **Fainting.** `CheckFaint_EnemyThenPlayer` is deleted, and `HandleBetweenTurnEffects` uses only `CheckFaint_PlayerThenEnemy`. Test double KOs (Destiny Bond, Explosion, recoil, end-of-turn residual damage that faints both sides).
4. **Turn loop.** `BattleTurn` no longer calls `EnemyTriesToFlee` (link opponent ran) or does the player-2 action swap. `ParsePlayerAction` lost a serial check.
5. **End-of-turn handlers.** These all lost their serial "who goes first" branch:
   - `ResidualDamage`, `HandlePerishSong`, `HandleLeftovers`, `HandleMysteryberry`
   - `HandleFutureSight`, `HandleSafeguard`, `HandleWeather` (three spots)
   - `HandleBerserkGene`, `HandleRadiantStatBoost`, `SwitchTurnCore`

   Test each end-of-turn effect with both sides active.
6. **Faint and switch.** `HandleEnemyMonFaint` and the switch paths lost serial checks, and the link-only `EnemyMonEntrance` is deleted. Test forced switches, Roar/Whirlwind, and the trainer's next Pokémon.
7. **Baton Pass.** `BatonPass_LinkPlayerSwitch` and `BatonPass_LinkEnemySwitch` are removed, plus two `jmp`→`jr`. Test player and enemy Baton Pass.
8. **Thief, Sketch, Beat Up.** Their link guards are removed (Thief's item transfer, Sketch's permanent copy).
9. **DoBattle / start.** Link intro, `ShowLinkBattleParticipants`, the link result and record screens, and the link battle music branch are all gone. Also the wild-flee and link-cancel exit (`WildFled_EnemyFled_LinkBattleCanceled`). Test running from wild battles and trainer battle start/end.
10. **AI and items.** Link guards are gone from `ai/items.asm`, `ai/move.asm`, `read_trainer_party.asm`, `read_trainer_attributes.asm`, `trainer_huds.asm` and `type_completion_boosts.asm`. Home `text`, `vblank`, `joypad`, `gfx` and `init` lost link and serial hooks.

## Later commits that touched the battle engine (post11 → v0.9)

A pre11 vs v0.9 comparison mixes these in:
- `9837a916a`: dead Beat Up engine removed (V1.5); effect IDs renumbered
- `cee53beda`: ten signature moves added (39B; new commands in $0d, SKY_ATTACK/AEROBLAST/SACRED_FIRE/AURA_SPHERE redefined)
- `840a21c70`: move constants sorted by type (24); every move ID changed, but dump-verified identical by name
- `4748aec0e`: obedience by happiness (32)

So isolate branch 11's own effect with **pre11 vs post11**. Use post11 vs v09 for 39B, 24 and 32.

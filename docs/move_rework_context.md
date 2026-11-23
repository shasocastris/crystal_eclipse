# Move / learnset / party rework: handoff context

Read this first to continue in a new session. Status as of 2026-11-22,
branch `99-party-review` (HEAD `c52baffbc` "Update parties", clean tree apart
from untracked docs/tools).

## Goal
shasocastris wants to revisit trainer teams in `data/trainers/parties.asm`. Steps:
1. Shrink the later-gen moveset (done).
2. Fix party movesets against it (two passes done, open list remains).
3. **Now:** widen how mons can learn coverage moves (TMs and tutors), instead
   of trimming trainer sets to fit thin movepools. Then finish the party
   open list using the new options.

## History (branches/commits)
- `97-uber-moves`: the 10 legendary signature moves are in their own `; UBER`
  block at the end of the move list.
- `98-move-review`: one commit per type, cutting or adding later-gen moves
  (269 moves became 246). Decisions, chosen levels and deviations are in
  `docs/move_roles.txt` (DECISION LOG plus "APPLIED on branch 98").
  - FLARE_BLITZ added (new EFFECT_FLARE_BLITZ, recoil + burn, Flame Wheel
    animation).
  - ICICLE_CRASH is now used (Swinub line, Sneasel, Weavile, Cloyster).
- `99-party-review` (off 98):
  - `855d19515` party pass 1. shasocastris's edits on top: Pidgeot Extremespeed,
    Lv28 Misdreavus Destiny Bond and Clair (1) Dragonair Extremespeed are
    **kept on purpose although trainer_lint flags them** (3 errors).
  - `b4026d6d5`, `3f58ca73a`, `80feb7fe6` (another session):
    - DETECT is now a player-facing item-detect move. Its TM and learners
      are restored. Keep it out of parties.
    - FUTURE_SIGHT is fully removed, engine code included. Its WRAM is `ds`
      padding, so no addresses moved.
  - `c52baffbc` party pass 2 (open-list rounds 1–2).
- Now 245 moves. Saves break (move IDs shifted).

## Party review: rules and decisions so far
Log: `docs/party_review.txt`. Per-edit log of pass 1:
`docs/party_review/pass1_log.txt`.
- Pass 1 rules:
  - Fix illegal moves.
  - Same-type wrong-category attacks become the right category (Sludge Bomb
    → Poison Jab, Surf → Waterfall on physical mons, Flamethrower → Flare
    Blitz on Flareon/Rapidash, Crunch → Dark Pulse on Houndoom, ...).
  - Evolve overdue mons on leader/E4/exec/rival teams at Lv60+.
    Exceptions: Scyther stays (Scizor is Jasmine's/Sabrina's), Red's
    Pikachu, Brock (1) Onix, the Radio Tower exec's Golbat.
- Round 1:
  - Alakazam: punches → Shadow Ball + Zap Cannon. Sabrina's two keep Fire
    Punch.
  - Ampharos: Thunderpunch → Thunderbolt; its physical coverage is kept.
  - Blue (2) Gengar gets Shadow Ball + Hypnosis. **Rule: Gengar gets a
    Ghost OR a Dark move, never both.**
- Round 2:
  - Jolteon: Shadow Ball / Thunder Wave / Double Team in place of Double
    Kick and Pin Missile.
  - Rival 1 Haunter: Lick → Night Shade (Lv25) or Hypnosis (Lv50).
  - Flareon: Shadow Ball → Iron Tail.
  - Route 43 Butterfree: Headbutt → Gust or Giga Drain.
- Off-type coverage moves in the wrong category were left for a decision.
  Run `python3 docs/party_review/candidates.py` for the current list
  (~95 mons): Skarmory Swift, Gyarados Ice Beam/Zap Cannon, Dodrio Tri
  Attack, Feraligatr ice, Kingler water, ...

## Current work: TM / tutor proposal (sections 1–2 APPROVED)
Spec: `docs/tm_tutor_proposal.txt`. As data: `docs/movepool/proposal.py`.
- TM swaps (same number and location):

  | TM | Old move | Location | New move |
  |---|---|---|---|
  | TM50 | Nightmare | Route 31 | SHADOW_CLAW |
  | TM40 | Defense Curl | Mt Mortar 2F | ROCK_SLIDE |
  | TM13 | Sweet Kiss | Route 39 farmhouse | CRUNCH |

  (CRUNCH was planned for the DETECT TM until DETECT came back.)
- Viridian drink tutor (`maps/ViridianRetiredChampionHouse.asm`, unlocked
  after the trainer house). Mimic and Pay Day are dropped.

  | Drink | Moves |
  |---|---|
  | Fresh Water | Seismic Toss, Counter, Reflect, Substitute |
  | Soda Pop | Body Slam, Tri Attack, Mega Punch, X_SCISSOR |
  | Lemonade | Swords Dance, Double-Edge, Mega Kick, POISON_JAB |
  | Berry Juice | Teleport, Nourishment, ICICLE_CRASH, SEED_BOMB |

- Tutors go from 17 to 19. The tmhm bitfield is (TM+HM+MT+7)/8 bytes: 77 of
  80 bits used, so no growth.
- **Section 3 is SETTLED (2026-11-22).** Final lists are `GRANTS`/`EXTRA`
  in proposal.py and section 3 of the spec. A trailing `!` (e.g.
  `'UMBREON!'`) grants one species only; shasocastris wants that for
  Eeveelutions. Magmortar's line gets Thunderbolt; Alakazam, Ampharos and
  Typhlosion get no special Fire/Electric grant.
  - Still thin, by choice: Skarmory (0), Fearow, Dodrio, Qwilfish,
    Rapidash, Honchkrow, Ariados, Beedrill.
  - Unfixable by any grant: special Fighting and physical Psychic (Focus
    Blast and Zen Headbutt were cut).
- **APPLIED and COMMITTED 2026-11-22** (`9b7bee718`):
  constants, events/labels, Route 31 / farmhouse text, Viridian menus,
  270 base_stats tmhm lines (via the one-shot `docs/movepool/apply_tmhm.py`),
  and 6 parties that used retired moves. Build clean, optimize OK,
  `trainer_lint --new-vs HEAD` clean. matrix.py with and without `--now` now
  agree.
- Party open list rounds 3-4 (25 + 23 swaps) are committed with the
  TM/tutor change as `9b7bee718`.
  `candidates.py` lists 51 lines; each is logged in docs/party_review.txt
  as kept on purpose or having no good legal option. The party review is
  done unless shasocastris revisits those.

## Tools (all untracked, listed in docs/helper_scripts.md)
- `docs/movepool/matrix.py`. Applies proposal.py; `--now` shows the game
  as it is.
  - `SPECIES...`: grid of best move per type × category, plus channel
    (L<lv>, TM, HM, MT, Safari).
  - `--gaps`: one line per final form with lean, STAB, coverage count, and
    party moves in the wrong category (`->none` = no fix exists).
  - `--move MOVE`: who learns a move, by channel.
  - Saved output: `docs/movepool/gaps_now.txt`, `gaps_proposal.txt`.
- `docs/party_review/view.py <Group|label> [-v]`: annotated parties.
- `docs/party_review/audit.py`, `candidates.py`: flag and propose party
  fixes.
- `docs/move_review/mvlib.py`: table and learnset editing. `cut(name)`,
  `put`, `renumber`, `ls_add`/`ls_remove`/`ls_replace`, `learners`,
  `party_replace`. Use with `sys.path.insert(0,'docs/move_review')`.
  `dump.py` / `compare.py` check that the 5 positional move tables stay in
  sync.
- `utils/trainer_lint.py [--new-vs REF] [--errors-only]`: legality of party
  moves (level-up across the line, TM/HM/tutor, Safari tutor). The 3
  errors above are expected.

## Working agreements
- shasocastris reviews **staged** changes before committing, and commits himself
  (often from his IDE). Stage only; write a commit message file. Re-check
  HEAD and the index before staging, because other sessions commit to this
  branch too.
- Never `git add -A`; stage specific files and check `git diff --cached`.
- Commit messages end with `Co-Authored-By: Claude Opus 5.5
  <noreply@anthropic.com>`. Keep source comments short; rationale goes in
  the commit message.
- Before staging, check that the build is clean (`make -j"$(nproc)"`,
  release + debug), that `python utils/optimize.py` shows no new warnings,
  and that `trainer_lint.py --new-vs HEAD` reports nothing new.
- Damaging-move category comes from `data/moves/moves.asm`. Base stats
  order is HP, Atk, Def, Spd, SpA, SpD. A mon "leans" physical or special
  when the gap is more than 10 (more than 25 for coverage fixes).
- Open follow-ups from the move review: `BattleAnim_BoneRush` is
  unreferenced; Victreebel learns Petal Dance at 1 and 30.

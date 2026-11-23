"""Move-table, learnset and party editing helpers for the branch-98 apply pass."""
import re, sys, os
sys.path.insert(0, "utils")
from pathlib import Path
from trainer_lint import Source, species_order, parse_parties, EVOS_FILES, PARTIES

CONST = Path("constants/move_constants.asm")
MOVES = Path("data/moves/moves.asm")
NAMES = Path("data/moves/names.asm")
DESCS = Path("data/moves/descriptions.asm")
ANIM1 = Path("data/moves/animations_part1.asm")
ANIM2 = Path("data/moves/animations_part2.asm")


def rd(p): return p.read_text().splitlines(keepends=True)
def wr(p, lines): p.write_text("".join(lines))


# ---------------------------------------------------------------- positional tables
def const_order():
    L = rd(CONST)
    s = next(i for i, l in enumerate(L) if "const NO_MOVE" in l)
    e = next(i for i, l in enumerate(L) if l.startswith("DEF NUM_ATTACKS"))
    out = []
    for i in range(s + 1, e):
        m = re.match(r"\tconst (\w+)", L[i])
        if m: out.append((m.group(1), i))
    return out  # index 1..N in list order


class Table:
    """One positional list. entries(): [(path, line_no)] in move-index order (1..N)."""
    def __init__(self, kind): self.kind = kind

    def entries(self):
        if self.kind == "const":
            return [(CONST, i) for _, i in const_order()]
        if self.kind == "moves":
            L = rd(MOVES)
            return [(MOVES, i) for i, l in enumerate(L) if l.startswith("\tmove ")]
        if self.kind == "names":
            L = rd(NAMES)
            end = next(i for i, l in enumerate(L) if "assert_list_length" in l)
            return [(NAMES, i) for i in range(end) if L[i].startswith("\tli ")]
        if self.kind == "descs":
            L = rd(DESCS)
            last = max(i for i, l in enumerate(L) if l.startswith(".IndirectEnd::"))
            return [(DESCS, i) for i in range(last) if re.match(r"\tdw \w+Description\b", L[i])]
        if self.kind == "anims":
            out = []
            for p in (ANIM1, ANIM2):
                L = rd(p)
                t = next(i for i, l in enumerate(L) if l.startswith(".IndirectEnd::"))
                out += [(p, i) for i in range(t) if L[i].startswith("\tanim_ptr ")]
            return out[1:]  # drop the NO_MOVE dummy at index 0


TABLES = [Table(k) for k in ("const", "moves", "names", "descs", "anims")]


def idx_of(name):
    names = [n for n, _ in const_order()]
    return names.index(name)  # 0-based within 1..N


def take(name):
    """Remove a move's line from every table; return {kind: line}."""
    i = idx_of(name)
    got = {}
    for t in TABLES:
        p, ln = t.entries()[i]
        L = rd(p)
        got[t.kind] = L[ln]
        del L[ln]
        wr(p, L)
    return got


def put(lines, before=None, after=None):
    """Insert {kind: line} before/after another move's entries."""
    ref = before or after
    i = idx_of(ref)
    for t in TABLES:
        p, ln = t.entries()[i]
        L = rd(p)
        L.insert(ln if before else ln + 1, lines[t.kind])
        wr(p, L)


def renumber():
    L = rd(CONST)
    n = 1
    for name, i in const_order():
        L[i] = f"\tconst {name:<14} ; {n:02x}\n"
        n += 1
    wr(CONST, L)


def grep_refs(word, exclude=()):
    import subprocess
    r = subprocess.run(["grep", "-rnw", word, "--include=*.asm", "--include=*.inc", "."],
                       capture_output=True, text=True).stdout.splitlines()
    return [x for x in r if not x.startswith("./docs") and not any(e in x for e in exclude)]


def cut(name, drop_desc_body=True):
    """Delete a move. Refuses if anything outside the 5 tables still names it."""
    refs = grep_refs(name, exclude=[str(p) for p in (CONST, MOVES, NAMES, DESCS, ANIM1, ANIM2)])
    if refs:
        raise SystemExit(f"{name} still referenced:\n  " + "\n  ".join(refs))
    got = take(name)
    if drop_desc_body:
        lab = re.search(r"dw (\w+Description)", got["descs"]).group(1)
        L = rd(DESCS)
        if not any(re.search(r"\b%s\b" % lab, l) for l in L if not l.startswith(lab + ":")):
            s = next(i for i, l in enumerate(L) if l.startswith(lab + ":"))
            e = s + 1
            while e < len(L) and L[e].strip():
                e += 1
            if e < len(L): e += 1  # trailing blank line
            del L[s:e]
            wr(DESCS, L)
    renumber()
    return got


# ---------------------------------------------------------------- learnsets
def _evos_index():
    src = Source()
    species = species_order(src)
    labels = []
    for path in EVOS_FILES:
        for line in Path(path).read_text().splitlines():
            m = re.match(r"\s*dw\s+(\w+EvosAttacks)\s*$", line)
            if m: labels.append(m.group(1))
    assert len(labels) == len(species)
    return dict(zip(species, labels))


EVO_LABEL = _evos_index()


def _body(sp):
    lab = EVO_LABEL[sp]
    for path in EVOS_FILES:
        p = Path(path)
        L = rd(p)
        for i, l in enumerate(L):
            if l.startswith(lab + ":"):
                j = i + 1
                while not L[j].strip().startswith("db 0"):  # evolutions
                    j += 1
                s = j + 1
                e = s
                while not L[e].strip().startswith("db 0"):
                    e += 1
                return p, L, s, e  # moves are L[s:e]
    raise KeyError(sp)


def _parse(l):
    m = re.match(r"\s*dbw\s+(\w+)\s*,\s*(\w+)", l)
    return (m.group(1), m.group(2)) if m else None


def learnset(sp):
    p, L, s, e = _body(sp)
    return [_parse(l) for l in L[s:e] if _parse(l)]


def ls_remove(sp, move, level=None):
    p, L, s, e = _body(sp)
    hit = [i for i in range(s, e) if _parse(L[i]) and _parse(L[i])[1] == move
           and (level is None or _parse(L[i])[0] == str(level))]
    assert hit, (sp, move, level)
    for i in reversed(hit):
        del L[i]
    wr(p, L)
    return len(hit)


def ls_add(sp, level, move):
    p, L, s, e = _body(sp)
    if any(_parse(L[i]) and _parse(L[i])[1] == move and _parse(L[i])[0] == str(level) for i in range(s, e)):
        return
    pos = s
    for i in range(s, e):
        a = _parse(L[i])
        if not a: continue
        lv = 0 if a[0] == "LEARN_EVO_MOVE" else int(a[0])
        if lv <= level:
            pos = i + 1
    L.insert(pos, f"\tdbw {level}, {move}\n")
    wr(p, L)


def ls_replace(sp, old, new, level=None):
    """Swap old -> new in place (same level). Drops it if sp already has new at that level."""
    p, L, s, e = _body(sp)
    n = 0
    for i in range(s, e):
        a = _parse(L[i])
        if a and a[1] == old and (level is None or a[0] == str(level)):
            L[i] = re.sub(r"\b%s\b" % old, new, L[i])
            n += 1
    assert n, (sp, old)
    wr(p, L)


def ls_move(sp, move, new_level):
    """Re-level an entry (keeps order)."""
    ls_remove(sp, move)
    ls_add(sp, new_level, move)


def learners(move):
    return [sp for sp in EVO_LABEL if any(m == move for _, m in learnset(sp))]


# ---------------------------------------------------------------- parties
def party_replace(label_prefix, species, old, new):
    src = Source()
    trs = [t for t in parse_parties(src) if t["label"].startswith(label_prefix)]
    assert trs, label_prefix
    L = rd(Path(PARTIES))
    n = 0
    for t in trs:
        for m in t["mons"]:
            if m["species"] == species and m["moves"] and old in m["moves"]:
                ln = m["moves_line"] - 1
                L[ln] = re.sub(r"\b%s\b" % old, new, L[ln])
                n += 1
    assert n, (label_prefix, species, old)
    wr(Path(PARTIES), L)
    return n


def party_users(move):
    src = Source()
    return [(t["label"], m["species"]) for t in parse_parties(src) for m in t["mons"]
            if m["moves"] and move in m["moves"]]

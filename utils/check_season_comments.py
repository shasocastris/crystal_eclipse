#!/usr/bin/env python3
"""Check the base-table comments in data/wild/season_*_data.asm.

Seasons whose column is the "-, -" sentinel fall through to the base
Johto/Kanto table. The trailing comment on each row records what that fallback
actually is, so the file can be read without cross-referencing. Comments drift;
this checks them.

Also verifies that every sentinel column really is omitted from the map's
season mask, and vice versa -- a column of real data in a season the mask does
not list is silently dead, which no assembler check would catch.

Exits non-zero on any mismatch. Run alongside utils/optimize.py.
"""

import re
import sys
import os

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SEASONS = ["SPRING", "SUMMER", "AUTUMN", "WINTER"]

PAIRS = [
    ("data/wild/season_grass_data.asm", "grass",
     ["data/wild/johto_grass.asm", "data/wild/kanto_grass.asm"]),
    ("data/wild/season_water_data.asm", "water",
     ["data/wild/johto_water.asm", "data/wild/kanto_water.asm"]),
]


def read(path):
    with open(os.path.join(REPO, path)) as f:
        return f.read()


def base_tables(paths, kind):
    """map id -> (rate, [(level, species), ...]) from the base tables."""
    out = {}
    for p in paths:
        pat = rf'def_{kind}_wildmons (\w+)(.*?)end_{kind}_wildmons'
        for m in re.finditer(pat, read(p), re.S):
            body = m.group(2)
            rate = int(re.search(r'db (\d+) percent', body).group(1))
            mons = [(int(a), b) for a, b in re.findall(r'dbw (\d+), (\w+)', body)]
            out[m.group(1)] = (rate, mons)
    return out


def check(colpath, kind, basepaths):
    base = base_tables(basepaths, kind)
    src = read(colpath)
    problems = []

    pat = rf'def_season_{kind} (\w+),([^\n]*)\n(.*?)end_season_{kind}'
    entries = list(re.finditer(pat, src, re.S))
    if not entries:
        problems.append(f"{colpath}: no def_season_{kind} entries found -- has the format changed?")
        return problems

    for m in entries:
        name, mask, body = m.group(1), m.group(2).strip(), m.group(3)

        if name not in base:
            # A map with no base entry is fine if it never falls through.
            if mask.replace(" ", "") == "ANYSEASON" and not re.search(r'[\s,]-\s*,', body):
                continue
            problems.append(
                f"{colpath}: {name} has no entry in the base table. A sentinel column "
                f"would fall through to nothing.")
            continue
        brate, bmons = base[name]

        # which seasons does the mask claim to define?
        defined = [s for s in SEASONS if
                   (s in mask) != ("~" + s in mask or f"~ {s}" in mask)]
        if "ANYSEASON" in mask:
            defined = [s for s in SEASONS if f"~{s}" not in mask.replace(" ", "")]

        # rate row
        rm = re.search(r'seasonrate ([^;\n]+);\s*(\d+)', body)
        if not rm:
            problems.append(f"{colpath}: {name}: could not read the seasonrate row")
        else:
            cols = [c.strip() for c in rm.group(1).split(',')]
            if int(rm.group(2)) != brate:
                problems.append(
                    f"{colpath}: {name}: rate comment says {rm.group(2)}, "
                    f"base table says {brate}")
            for i, s in enumerate(SEASONS):
                if i < len(cols):
                    is_sentinel = cols[i] == '-'
                    if is_sentinel and s in defined:
                        problems.append(
                            f"{colpath}: {name}: {s} rate is the sentinel but {s} IS in the mask")
                    if not is_sentinel and s not in defined:
                        problems.append(
                            f"{colpath}: {name}: {s} rate has data but {s} is NOT in the mask "
                            f"-- that column is dead")

        # mon rows
        rows = re.findall(r'seasonmon\s+([^;\n]+);\s*(\d+),\s*(\w+)', body)
        if len(rows) != len(bmons):
            problems.append(
                f"{colpath}: {name}: {len(rows)} seasonmon rows but the base table has "
                f"{len(bmons)} -- the comment column cannot line up")
            continue
        for i, (cols_s, clvl, cspc) in enumerate(rows):
            blvl, bspc = bmons[i]
            if (int(clvl), cspc) != (blvl, bspc):
                problems.append(
                    f"{colpath}: {name} row {i + 1}: comment says "
                    f"{clvl}, {cspc} -- base table says {blvl}, {bspc}")
            toks = [t.strip() for t in cols_s.split(',')]
            for si, s in enumerate(SEASONS):
                lvl = toks[si * 2] if si * 2 < len(toks) else ''
                is_sentinel = lvl == '-'
                if is_sentinel and s in defined:
                    problems.append(
                        f"{colpath}: {name} row {i + 1}: {s} is the sentinel but "
                        f"{s} IS in the mask")
                if not is_sentinel and s not in defined:
                    problems.append(
                        f"{colpath}: {name} row {i + 1}: {s} has data but {s} is NOT "
                        f"in the mask -- that column is dead")
    return problems


def main():
    problems = []
    for colpath, kind, basepaths in PAIRS:
        problems += check(colpath, kind, basepaths)

    if problems:
        print("Seasonal fallback comments are out of date:\n")
        for p in problems:
            print(f"  {p}")
        print(f"\n{len(problems)} problem(s). The '; level, SPECIES' comments record what "
              f"a sentinel column\nfalls through to. Update them, or regenerate them "
              f"from the base tables.")
        return 1

    print("Seasonal fallback comments match the base tables.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

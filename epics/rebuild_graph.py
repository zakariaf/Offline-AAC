#!/usr/bin/env python3
"""Recompute every task's `Blocks` row as the true inverse of `Depends on`.

`Blocks` is not an independent fact — it is derivable. Authoring it by hand
produced 43 edges that disagreed with their own inverse, including three that
asserted a sequencing constraint the downstream task did not acknowledge. So
it gets computed here and never hand-edited again.

Run from anywhere:  python3 epics/rebuild_graph.py [--check]

--check exits non-zero without writing, so CI can assert the graph is coherent.
"""

from __future__ import annotations

import re
import sys
from collections import defaultdict
from pathlib import Path

EPICS = Path(__file__).resolve().parent
TASK_ID = re.compile(r"^#\s+(E\d\d-T\d\d)\b")
ROW = re.compile(r"^\|\s*\*\*(Depends on|Blocks|Size)\*\*\s*\|\s*(.+?)\s*\|\s*$", re.M)
REF = re.compile(r"E\d\d-T\d\d")

# Dependencies the review found asserted by an upstream `Blocks` row but absent
# from the downstream `Depends on` row. Adding them rather than deleting the
# claim, because in both cases the claim is correct:
#   - You cannot configure a signed bundle before deciding whether it is
#     obfuscated; the decision changes the build invocation.
#   - main() cannot land a user on a working grid before the grid reads the
#     repository.
EXTRA_DEPS = {
    "E11-T02": ["E11-T03"],
    "E01-T06": ["E05-T08"],
}


def parse(path: Path) -> tuple[str, dict[str, str]] | None:
    text = path.read_text()
    m = TASK_ID.search(text)
    if not m:
        return None
    return m.group(1), {k: v for k, v in ROW.findall(text)}


def main() -> int:
    check_only = "--check" in sys.argv

    files: dict[str, Path] = {}
    rows: dict[str, dict[str, str]] = {}
    for p in sorted(EPICS.glob("E*/T*.md")):
        got = parse(p)
        if not got:
            print(f"!! no task id in {p.name}")
            return 2
        tid, r = got
        files[tid], rows[tid] = p, r

    # Build the forward edges, then invert.
    deps: dict[str, set[str]] = {}
    for tid, r in rows.items():
        found = set(REF.findall(r.get("Depends on", "")))
        found |= set(EXTRA_DEPS.get(tid, []))
        deps[tid] = found

    unknown = {d for ds in deps.values() for d in ds} - set(files)
    if unknown:
        print(f"!! dependencies on non-existent tasks: {sorted(unknown)}")
        return 2

    blocks: dict[str, set[str]] = defaultdict(set)
    for tid, ds in deps.items():
        for d in ds:
            blocks[d].add(tid)

    # A cycle here would mean the plan cannot be executed in any order.
    colour: dict[str, int] = {}

    def cyclic(n: str, path: list[str]) -> list[str] | None:
        colour[n] = 1
        for m in sorted(deps.get(n, ())):
            if colour.get(m) == 1:
                return path + [n, m]
            if colour.get(m, 0) == 0:
                got = cyclic(m, path + [n])
                if got:
                    return got
        colour[n] = 2
        return None

    for t in sorted(files):
        if colour.get(t, 0) == 0:
            cyc = cyclic(t, [])
            if cyc:
                print(f"!! CYCLE: {' -> '.join(cyc)}")
                return 2

    def fmt(ids: set[str]) -> str:
        return ", ".join(sorted(ids)) if ids else "Nothing"

    changed = []
    for tid, path in files.items():
        text = original = path.read_text()

        want_dep, want_blk = fmt(deps[tid]), fmt(blocks[tid])
        text = re.sub(r"(^\|\s*\*\*Depends on\*\*\s*\|).*?(\|\s*$)",
                      lambda m: f"{m.group(1)} {want_dep} {m.group(2)}", text, count=1, flags=re.M)
        text = re.sub(r"(^\|\s*\*\*Blocks\*\*\s*\|).*?(\|\s*$)",
                      lambda m: f"{m.group(1)} {want_blk} {m.group(2)}", text, count=1, flags=re.M)
        # Size: bare bucket only. The legend lives in the epics README, once.
        text = re.sub(r"(^\|\s*\*\*Size\*\*\s*\|\s*)(XS|S|M|L)\b[^|]*(\|\s*$)",
                      lambda m: f"{m.group(1)}{m.group(2)} {m.group(3)}", text, count=1, flags=re.M)

        if text != original:
            changed.append(tid)
            if not check_only:
                path.write_text(text)

    roots = sorted(t for t in files if not deps[t])
    leaves = sorted(t for t in files if not blocks[t])
    edges = sum(len(d) for d in deps.values())

    print(f"{len(files)} tasks · {edges} edges · acyclic")
    print(f"entry points (nothing blocks them): {', '.join(roots)}")
    print(f"terminal tasks: {', '.join(leaves)}")
    print(f"{'would rewrite' if check_only else 'rewrote'}: {len(changed)} files")

    if check_only and changed:
        print("!! graph rows are stale — run without --check")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

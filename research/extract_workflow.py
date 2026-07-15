#!/usr/bin/env python3
"""Extract every agent's prompt + result from a Claude Code workflow run into readable Markdown.

Why this exists: a deep-research workflow costs millions of tokens. The synthesized
brief is only the tip — the per-agent findings, the adversarial fact-checks, and
above all the PROMPTS are reusable across future projects. This turns an ephemeral
run into a durable, greppable archive.

Usage:
    python3 research/extract_workflow.py                 # extract all known runs
    python3 research/extract_workflow.py wf_3a8e3c64-43a # extract one run

Input  (per run, under the session's subagents/workflows/<runId>/):
    journal.jsonl          one {"type":"result", "agentId":..., "result":...} per finished agent
    agent-<id>.jsonl       full transcript; row 0 is the user message = the prompt
Output:
    research/<NN-slug>/{_INDEX.md,_workflow_script.js,research/,verify/,critique/,author/}
"""

from __future__ import annotations

import json
import re
import shutil
import sys
from collections import Counter
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
RESEARCH_DIR = REPO / "research"

SESSION = (
    Path.home()
    / ".claude/projects/-Users-zakariafatahi-50-apps-challenge-Offline-AAC"
    / "894d23b4-edde-414c-90f6-a0c3d1367fdd"
)
WF_ROOT = SESSION / "subagents/workflows"
SCRIPT_ROOT = SESSION / "workflows/scripts"

# runId -> (output dir name, human title)
RUNS = {
    "wf_3a8e3c64-43a": ("01-product-and-market", "Product & market research — offline adult AAC"),
    "wf_12b14467-451": ("02-flutter-engineering", "Flutter architecture, coding standards & testing"),
    "wf_f237e8a6-694": ("03-design-system", "Design system — contemporary, creative, accessible"),
}

# ---------------------------------------------------------------- classification

# Ordered: FIRST MATCH WINS, and order is load-bearing.
#
# Author prompts embed the critics' *output* verbatim, and a critic who titles its
# own memo ("...as a SKEPTICAL STAFF ENGINEER") would otherwise capture the author.
# So: match authors first, anchored on the `===` delimiter from the prompt template,
# which only ever appears in the instructions we wrote — never in an agent's prose.
ROLE_PATTERNS: list[tuple[str, str, str]] = [
    (r"===\s*YOUR DOCUMENT:\s*(?:docs/)?([A-Z_]+)\.md", "author", None),  # slug from capture
    (r"You are the lead product engineer", "author", "product-brief"),
    (r"ADVERSARIAL FACT-CHECKER", "verify", "fact-check"),
    (r"You are the COMPLETENESS CRITIC", "critique", "completeness-critic"),
    (r"You are a SKEPTICAL SENIOR PRODUCT LEAD", "critique", "skeptic-product-lead"),
    (r"You are a SKEPTICAL STAFF ENGINEER", "critique", "skeptic-staff-engineer"),
    (r"You are an AAC-experienced SPEECH-LANGUAGE PATHOLOGIST", "critique", "slp-clinical-review"),
    (r"You are a TEST ENGINEER specializing", "critique", "test-engineer-review"),
    (r"You are a working ART DIRECTOR", "critique", "art-director"),
    (r"You are an ACCESSIBILITY-SPECIALIST DESIGNER", "critique", "a11y-designer"),
    (r"autistic adult who uses AAC part-time", "critique", "autistic-user-lens"),
    (r"YOUR DIMENSION", "research", None),  # slug from the dimension line
]


def slugify(text: str, maxlen: int = 52) -> str:
    s = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
    if len(s) > maxlen:
        s = s[:maxlen].rstrip("-")
    return s or "untitled"


def dimension_keys(script: Path) -> dict[str, str]:
    """Map slugified 'YOUR DIMENSION' line -> the script's own dimension key.

    The prompts don't carry their key, but the workflow script pairs each
    `key: 'foo'` with the prompt that follows it. Recovering the real keys makes
    the archive navigable by concept (`competitive`) instead of by truncated prose.
    """
    if not script.exists():
        return {}
    text = script.read_text()
    pairs = re.findall(r"key:\s*'([^']+)'[\s\S]*?YOUR DIMENSION:\s*(.+)", text)
    return {slugify(line): key for key, line in pairs}


def classify(prompt: str, keymap: dict[str, str] | None = None) -> tuple[str, str]:
    """Return (phase, slug) for an agent, derived from its prompt."""
    for pattern, phase, fixed_slug in ROLE_PATTERNS:
        m = re.search(pattern, prompt)
        if not m:
            continue
        if fixed_slug:
            return phase, fixed_slug
        if phase == "author":
            return phase, slugify(m.group(1))
        if phase == "research":
            line = re.search(r"YOUR DIMENSION:\s*(.+)", prompt)
            raw = slugify(line.group(1) if line else "dimension")
            return phase, (keymap or {}).get(raw, raw)
    return "other", "unclassified"


def verify_slug(prompt: str) -> str:
    """Fact-checkers name their dimension and the claim under test."""
    dim = re.search(r'(?:researching the dimension|studying)\s*"([^"]+)"', prompt)
    claim = re.search(r"CLAIM:\s*(.+)", prompt)
    parts = [slugify(dim.group(1), 28) if dim else "unknown"]
    if claim:
        parts.append(slugify(claim.group(1), 44))
    return "--".join(parts)


# ---------------------------------------------------------------- rendering

def render_result(raw) -> str:
    """Schema'd agents return JSON (sometimes pre-parsed); critics/authors return prose."""
    if isinstance(raw, (dict, list)):
        data = raw
    else:
        try:
            data = json.loads(raw)
        except (json.JSONDecodeError, TypeError):
            return str(raw).strip()
    if not isinstance(data, dict):
        return f"```json\n{json.dumps(data, indent=2)}\n```"

    out: list[str] = []

    def heading(text: str) -> None:
        out.append(f"\n## {text}\n")

    if "summary" in data:
        heading("Summary")
        out.append(str(data["summary"]))

    # Fact-check verdicts
    if "verdict" in data:
        heading("Verdict")
        out.append(f"**{data['verdict']}**" + ("  (refuted)" if data.get("refuted") else ""))
        for key, label in (("correction", "Correction"), ("evidence", "Evidence")):
            if data.get(key):
                out.append(f"\n**{label}:** {data[key]}")

    for item in data.get("findings", []) or []:
        flags = [item.get("confidence", "?")]
        if item.get("loadBearing"):
            flags.append("**LOAD-BEARING**")
        out.append(f"\n### {item.get('claim', '(no claim)')}\n")
        out.append(f"*Confidence: {', '.join(flags)}*\n")
        out.append(str(item.get("detail", "")))
        for src in item.get("sources", []) or []:
            out.append(f"\n- {src}")

    for key, label, fmt in (
        ("productImplications", "Product implications",
         lambda d: f"- **[{d.get('priority','?')}]** {d.get('implication','')}\n  - {d.get('rationale','')}"),
        ("recommendations", "Recommendations",
         lambda d: f"- **[{d.get('priority','?')}]** {d.get('rule','')}\n  - {d.get('rationale','')}"),
        ("designMoves", "Design moves",
         lambda d: f"- **{d.get('move','')}**\n  - Why: {d.get('why','')}\n  - Risk: {d.get('risk','—')}"),
        ("references", "References",
         lambda d: f"- **{d.get('name','')}** {d.get('url','')}\n  - Steal: {d.get('steal','')}"),
    ):
        items = data.get(key) or []
        if items:
            heading(label)
            out.extend(fmt(d) for d in items)

    for ex in data.get("codeExamples", []) or []:
        out.append(f"\n### {ex.get('title','Example')}\n")
        out.append(f"```{ex.get('language','dart')}\n{ex.get('code','')}\n```")
        if ex.get("note"):
            out.append(f"\n{ex['note']}")

    # Never silently drop a field the schema grew later.
    known = {
        "summary", "findings", "productImplications", "recommendations", "designMoves",
        "references", "codeExamples", "dimension", "verdict", "refuted", "correction",
        "evidence", "sources",
    }
    extra = {k: v for k, v in data.items() if k not in known}
    if extra:
        heading("Other fields")
        out.append(f"```json\n{json.dumps(extra, indent=2)}\n```")

    rendered = "\n".join(out).strip()
    return rendered or f"```json\n{json.dumps(data, indent=2)}\n```"


def read_prompt(path: Path) -> str:
    with path.open() as fh:
        for line in fh:
            if not line.strip():
                continue
            row = json.loads(line)
            content = row.get("message", {}).get("content")
            if isinstance(content, list):  # content blocks
                content = "\n".join(b.get("text", "") for b in content if isinstance(b, dict))
            return content or ""
    return ""


# ---------------------------------------------------------------- extraction

def extract(run_id: str, dir_name: str, title: str) -> dict:
    src = WF_ROOT / run_id
    if not (src / "journal.jsonl").exists():
        print(f"  !! no journal for {run_id} — still running or never started?")
        return {}

    results: dict[str, str] = {}
    order: list[str] = []
    with (src / "journal.jsonl").open() as fh:
        for line in fh:
            if not line.strip():
                continue
            row = json.loads(line)
            if row.get("type") == "result":
                results[row["agentId"]] = row.get("result") or ""
                order.append(row["agentId"])

    out_root = RESEARCH_DIR / dir_name
    for phase in ("research", "verify", "critique", "author", "other"):
        shutil.rmtree(out_root / phase, ignore_errors=True)
    out_root.mkdir(parents=True, exist_ok=True)

    # Copy the script first: it is the methodology, and it carries the dimension keys.
    script_dst = out_root / "_workflow_script.js"
    for script in SCRIPT_ROOT.glob(f"*{run_id}*.js"):
        shutil.copy(script, script_dst)
    keymap = dimension_keys(script_dst)

    entries: list[dict] = []
    used: Counter[str] = Counter()

    for agent_id in order:
        tx = src / f"agent-{agent_id}.jsonl"
        prompt = read_prompt(tx) if tx.exists() else ""
        phase, slug = classify(prompt, keymap)
        if phase == "verify":
            slug = verify_slug(prompt)

        used[f"{phase}/{slug}"] += 1
        n = used[f"{phase}/{slug}"]
        fname = f"{slug}.md" if n == 1 else f"{slug}-{n}.md"

        (out_root / phase).mkdir(parents=True, exist_ok=True)
        body = render_result(results[agent_id])
        doc = (
            f"# {slug}\n\n"
            f"> Phase: **{phase}** · Agent `{agent_id}` · Run `{run_id}`\n\n"
            f"## Result\n\n{body}\n\n"
            f"---\n\n"
            f"<details>\n<summary>The prompt that produced this (reusable — this is the template)</summary>\n\n"
            f"````\n{prompt.strip()}\n````\n\n</details>\n"
        )
        (out_root / phase / fname).write_text(doc)
        entries.append({"phase": phase, "slug": slug, "file": f"{phase}/{fname}", "chars": len(body)})

    by_phase: dict[str, list[dict]] = {}
    for e in entries:
        by_phase.setdefault(e["phase"], []).append(e)

    lines = [
        f"# {title}",
        "",
        f"`{run_id}` · **{len(entries)} agents** · every agent's result + the prompt that produced it.",
        "",
        "The methodology is in [`_workflow_script.js`](_workflow_script.js) — the fan-out, the schemas,",
        "and the adversarial verification pass. Re-run or adapt it rather than rewriting it.",
        "",
    ]
    for phase in ("research", "verify", "critique", "author", "other"):
        items = by_phase.get(phase)
        if not items:
            continue
        blurb = {
            "research": "One agent per dimension, each doing independent web research.",
            "verify": "Adversarial fact-checkers, one per load-bearing claim, each told to *refute* it.",
            "critique": "Cross-cutting critics reading the whole corpus.",
            "author": "Synthesis — the final documents.",
            "other": "Unclassified.",
        }[phase]
        lines += [f"## {phase} ({len(items)})", "", blurb, ""]
        for e in sorted(items, key=lambda x: x["slug"]):
            lines.append(f"- [{e['slug']}]({e['file']}) — {e['chars']:,} chars")
        lines.append("")

    (out_root / "_INDEX.md").write_text("\n".join(lines))
    print(f"  {dir_name}: {len(entries)} agents -> " + ", ".join(f"{k}:{len(v)}" for k, v in sorted(by_phase.items())))
    return {"title": title, "dir": dir_name, "run_id": run_id, "count": len(entries), "by_phase": by_phase}


def main() -> None:
    wanted = sys.argv[1:] or list(RUNS)
    summaries = []
    for run_id in wanted:
        if run_id not in RUNS:
            print(f"!! unknown run {run_id}; known: {', '.join(RUNS)}")
            continue
        dir_name, title = RUNS[run_id]
        print(f"Extracting {run_id} ...")
        s = extract(run_id, dir_name, title)
        if s:
            summaries.append(s)
    total = sum(s["count"] for s in summaries)
    print(f"\nDone. {total} agents across {len(summaries)} runs -> {RESEARCH_DIR}")


if __name__ == "__main__":
    main()

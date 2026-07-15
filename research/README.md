# Research archive

Raw output from every agent in every deep-research workflow run for this project — the findings, the adversarial fact-checks, the critiques, and **the prompts that produced them**.

This exists so the research is spent once. Each run costs millions of tokens; most of what came back is not specific to this app.

## What's here

| Directory | Run | Agents | Tokens | Reusable elsewhere? |
|---|---|---|---:|---|
| [`01-product-and-market/`](01-product-and-market/_INDEX.md) | `wf_3a8e3c64-43a` | 100 | 3.9M | **Partly** — see below |
| [`02-flutter-engineering/`](02-flutter-engineering/_INDEX.md) | `wf_12b14467-451` | 103 | 4.5M | **Almost entirely** |
| [`03-design-system/`](03-design-system/_INDEX.md) | `wf_f237e8a6-694` | 93 | 4.5M | **Mostly** |

**296 agents · ~12.9M tokens · ~3.5 hours of wall clock.**

Each run directory contains:

```
_INDEX.md              every agent, grouped by phase, with sizes
_workflow_script.js    the methodology: fan-out, schemas, verification pass
research/              one file per dimension — independent web research
verify/                one file per load-bearing claim — an agent told to REFUTE it
critique/              cross-cutting critics who read the whole corpus
author/                synthesis — the final documents
```

Every file has the agent's result **and** the prompt that produced it, in a collapsible block at the bottom.

## How to reuse this for a different app

**Start with the workflow scripts, not the findings.** `_workflow_script.js` in each run is the reusable asset — the dimension decomposition, the JSON schemas, the adversarial-verification pipeline, the critic panel. Adapt the prompts; keep the structure. Re-run with:

```
Workflow({ scriptPath: "research/02-flutter-engineering/_workflow_script.js" })
```

**Then mine the findings that don't depend on this app being an AAC app:**

*Reusable for any Flutter project:*
- `02-flutter-engineering/` — nearly all of it. Architecture, project structure, Riverpod's current API, Dart 3 idioms, error handling, the whole testing corpus (widget/golden/a11y/migration/platform-channel), lints, CI, performance.
- `03-design-system/` — Material 3 Expressive status in Flutter, colour systems, typography and font licensing, what Flutter can actually render, design tokens via `ThemeExtension`.
- `01-product-and-market/research/flutter-vs-rn.md` — the framework decision, with the accessibility analysis.
- `01-product-and-market/research/data-architecture.md` — local DB landscape (drift vs sqflite vs the dead ones), backup without a server.
- `01-product-and-market/research/flutter-tts.md` — TTS, audio sessions, on-device speech.

*Reusable for any app you plan to ship:*
- `01-product-and-market/research/legal-regulatory.md` — App Store / Play rules, privacy labels and Data Safety (required **even when you collect nothing**), medical-device thresholds, symbol/font/icon licensing.
- `01-product-and-market/research/business-model.md` — pricing, the Small Business Program, distribution channels.

*Specific to this app, keep for context only:*
- `user-needs`, `aac-clinical`, `competitive`, `design-distress`, `platform-integration`, `failure-modes`.

## How to read it

The **`verify/`** directory is the most valuable and least obvious part. Each file is an agent that was handed one load-bearing claim and told to refute it. That pass is what caught, in this project:

- a competitor that already ships the entire proposed MVP, at 1/10th the assumed price, on both platforms
- an OS feature that does half the product for free
- a licence that changed (Piper: MIT → GPL-3.0), making it App-Store-incompatible
- an Android architecture fact that invalidates the app's core privacy claim (TTS runs in a *separate app* with its own network permission)
- a widely-repeated statistic that appears to be fabricated

**Findings marked `LOAD-BEARING` were fact-checked; the rest were not.** When a fact-checker disagreed with a researcher, *the fact-checker is usually right* — they checked primary sources against a specific claim, while the researcher was surveying. The synthesized documents already apply these corrections; the `research/` files do **not**. Read `research/` for breadth, then check `verify/` before trusting any specific number, price, version, or licence.

**Everything here has a date.** Captured 2026-07-15. Package versions, prices, store policies, and API surfaces rot fast — the whole reason the verification pass exists. Re-verify before relying on a specific value.

### One known bad premise, and what it teaches

All three runs were told **"Flutter stable is 3.44.0."** That was asserted, not checked. The Flutter actually installed here is **3.41.2** (Feb 2026, Dart 3.11). Nothing verified it because it arrived as *given context* rather than as a claim — the fact-checkers were pointed at what the researchers said, not at what the brief assumed.

It was caught only because a design author compiled its own code samples against the real toolchain and found `ShapedInputBorder` missing. That doc now carries the correction inline with a 3.41 fallback.

The blast radius is small (~10 references, none in `TESTING.md` or `ARCHITECTURE.md`), but the lesson generalises to any future run: **a premise in the prompt is the one claim nobody checks.** State the environment as a question ("verify the installed Flutter version first") rather than as a fact, or verify it yourself before launching.

## Regenerating

```bash
python3 research/extract_workflow.py                 # all known runs
python3 research/extract_workflow.py wf_3a8e3c64-43a # one run
```

Idempotent — it rewrites each phase directory from the source journals. Add new runs to the `RUNS` map at the top of the script.

Source data lives in the Claude Code session directory (`subagents/workflows/<runId>/`). **That is not permanent.** This archive is the durable copy.

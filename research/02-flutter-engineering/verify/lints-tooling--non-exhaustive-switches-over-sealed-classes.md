# lints-tooling--non-exhaustive-switches-over-sealed-classes

> Phase: **verify** · Agent `a2198220874eff7ee` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Two specifics are wrong; the conclusion is not. (1) "Unsuppressable by lint config" — not true of the analyzer. `analyzer: errors: {non_exhaustive_switch_statement: ignore}` or a `// ignore:` comment makes `dart analyze`/`flutter analyze` report "No issues found!". The error is unsuppressable only at COMPILE time (`flutter build` / `dart compile`), which still fails regardless of analysis_options. Restate as: "breaks the build, and cannot be silenced from analysis_options — but only if CI actually compiles; an analyze-only gate can be bypassed with one ignore comment." (2) "`exhaustive_cases` only covers enums and static-const-instance classes" — drop "enums". Per dart.dev and a local probe, `exhaustive_cases` covers ONLY enum-like classes (concrete class, private constructors, 2+ static const fields of the enclosing type — the pre-Dart-2.17 hand-rolled enum idiom). Native enums are covered by the compiler's `non_exhaustive_switch_statement`, identically to sealed classes — which actually strengthens the claim's thesis, since it means both enums and sealed types get compiler-grade exhaustiveness and the lint is a legacy-pattern backstop only.

**Evidence:** I could not refute the core claim — it reproduced verbatim on the SDK actually installed (Dart 3.11.0 / Flutter 3.41.2, not the 3.44/Dart 3.12 named in the brief; irrelevant here since exhaustiveness has been stable since Dart 3.0).

PROBE 1 — core claim CONFIRMED, message matches character-for-character. A `sealed class SpeechFailure` with `EngineSilent`/`EngineBusy` subtypes and a switch omitting `EngineSilent`:
  error - bin/main.dart:6:3 - The type 'SpeechFailure' isn't exhaustively matched by the switch cases since it doesn't match the pattern 'EngineSilent()'. - non_exhaustive_switch_statement
Severity is `error`, diagnostic name is exact, and it is emitted with an empty analysis_options.yaml and zero lints enabled. This is the compiler's check, not the linter's. Confirmed against dart.dev/tools/diagnostics/non_exhaustive_switch_statement.

PROBE 2 — "unsuppressable by lint config" is FALSE AS STATED. Both suppression paths fully silence the ANALYZER:
  - analysis_options.yaml `analyzer: errors: {non_exhaustive_switch_statement: ignore}` → `dart analyze` prints "No issues found!"
  - a `// ignore: non_exhaustive_switch_statement` comment above the switch → "No issues found!"
The guarantee survives only one level down: with the analyzer silenced, `dart compile exe` STILL refuses to build ("Error: The type 'SpeechFailure' is not exhaustively matched... AOT compilation failed"). So the build-break comes from the CFE at `flutter build`, NOT from `flutter analyze`. This matters for the project decision: a CI gate that runs only `flutter analyze` (very common, and the likely gate here) CAN be made to pass with a one-line ignore. The unsuppressable property requires an actual compile step in CI.

PROBE 3 — the `exhaustive_cases` parenthetical is FALSE on the "enums" half. Switching non-exhaustively on a native `enum OutputMode { speak, display, both }` with `exhaustive_cases` enabled produced `non_exhaustive_switch_statement` (the compiler check) — `exhaustive_cases` did not fire at all. dart.dev defines its scope as "enum-like classes" ONLY: concrete classes with private constructors and two-or-more static const fields of the enclosing type. Native enums get compiler exhaustiveness, same as sealed — they were never the lint's job.

PROBE 4 — collateral facts check out. `exhaustive_cases` is stable/recommended (not deprecated), and IS present in VGA at /Users/zakariafatahi/.pub-cache/hosted/pub.dev/very_good_analysis-10.2.0/lib/analysis_options.10.2.0.yaml:86, which is the ruleset /Users/zakariafatahi/50-apps-challenge/Offline-AAC/analysis_options.yaml pins (line 30) and promotes to `error` (line 113). VGA is alive: publisher Very Good Ventures, latest 10.3.0, published ~27 days ago, not discontinued. No dead packages, no invented APIs — `non_exhaustive_switch_statement` and `non_exhaustive_switch_expression` (probed, for the expression form) are both real diagnostic names.

The engineering recommendation stands and is well-founded: modelling SpeechFailure/OutputMode as sealed does break the build at every call site when a new failure mode is added, and this is a genuinely stronger guarantee than any lint. Note the sibling caveat, which the claim gets right: adding a `default` clause or `_` wildcard silently forfeits the entire guarantee — that, not lint config, is the realistic way this protection gets lost in practice.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "lints-tooling" made this claim, and a project decision depends on it.

CLAIM: Non-exhaustive switches over sealed classes are already a COMPILE ERROR — no lint is needed, and this is the strongest argument for modelling failures as sealed classes.
DETAIL: Verified: omitting a subtype yields `error • The type 'SpeechFailure' isn't exhaustively matched by the switch cases since it doesn't match the pattern 'EngineSilent()' • non_exhaustive_switch_statement` — from the compiler, not the linter, and unsuppressable by lint config. Concrete consequence: model SpeechFailure/OutputMode as `sealed class`, and adding a new failure mode breaks the build at every call site instead of falling through to silence. The `exhaustive_cases` lint (already in VGA) only covers enums and static-const-instance classes.
CLAIMED SOURCES: local probe
CONFIDENCE: high

REFUTE IT. Use WebSearch and WebFetch against PRIMARY sources: pub.dev package pages (for real current versions, publisher, and maintenance status), api.flutter.dev (for real API signatures), dart.dev, docs.flutter.dev, and the actual GitHub repos (for whether something is archived/discontinued).

The failure modes you are hunting for, in order of likelihood:
1. **Version rot** — the claim was true in 2023. APIs get deprecated and removed; `setMockMethodCallHandler` moved; `window` was deprecated; formatters changed.
2. **Dead packages presented as alive** — golden_toolkit, dart_code_metrics, isar, hive, mockito-vs-mocktail. CHECK THE REPO: is it archived? When was the last publish? Does pub.dev show it as discontinued?
3. **Invented or misremembered API signatures.** If the claim names a method, class, or parameter, VERIFY IT EXISTS with that exact name on api.flutter.dev or the package docs. LLM-plausible API names are a specific hazard here.
4. **Cargo cult** — presenting a team practice or a large-app practice as universal, when the actual source doesn't say that.
5. **Overstated consensus** — "the community recommends X" when it's one blog post.

Default to refuted=true if you cannot independently substantiate it. CONFIRMED if it checks out. PARTIALLY_TRUE + a correction if directionally right but wrong in specifics (name the exact right version/API). UNVERIFIABLE if no source settles it — and say that plainly rather than guessing.
````

</details>

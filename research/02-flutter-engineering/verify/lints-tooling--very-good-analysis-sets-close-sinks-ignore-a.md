# lints-tooling--very-good-analysis-sets-close-sinks-ignore-a

> Phase: **verify** · Agent `a9343ecf10862b4f6` · Run `wf_12b14467-451`

## Result

## Verdict

**REFUTED**  (refuted)

**Correction:** VGA 10.2.0 does set `close_sinks: ignore` — the quotation is accurate — but the inference is backwards on three counts.

(a) VGA never enables `close_sinks` in its `linter: rules:` list (210 rules; close_sinks absent), so "re-enabled" has no referent — the rule was never on.

(b) `analyzer: errors: close_sinks: error` CANNOT enable it. `errors:` only changes severity of diagnostics already generated. Verified empirically on Dart 3.11.0: the project's exact config emits nothing on a leaked StreamController. The override is a NO-OP — decorative, precisely what the claim denies. To actually get it, the file must add:
    linter:
      rules:
        - close_sinks
(keeping `errors: close_sinks: error` to promote info→error). This is the only one of the file's 17 `errors:` entries that is broken; the other 16 (including `cancel_subscriptions`) are enabled by VGA and work as written.

(c) Even properly enabled, close_sinks would not flag the described design. It only tracks sinks created and closed within one function ("This rule does not track all patterns of Sink instantiations and closures", sdk#57882); a controller held as a field and closed in `dispose()` yields no diagnostic — confirmed by probe. For a field-held controller the real protection is a `dispose()` plus a test asserting closure, not this lint.

Additionally, the premise is not yet true: the repo contains zero Dart files, so no StreamController exists. RESEARCH.md:363 itself calls the TTS voice-availability reactivity "not load-bearing."

Correct characterization: VGA's `close_sinks: ignore` is vestigial (ignoring a rule it never enables, unchanged 2.3.0→10.3.0), and the project's override is currently decorative. It can be made load-bearing only by enabling the rule under `linter: rules:` — and even then it will not cover the field-held controller the comment describes.

**Evidence:** The QUOTATION is accurate; the CONCLUSION drawn from it is inverted. `close_sinks: error` is the one override in this file that does nothing.

**1. The quoted YAML is verbatim correct.** `/Users/zakariafatahi/.pub-cache/hosted/pub.dev/very_good_analysis-10.2.0/lib/analysis_options.10.2.0.yaml` lines 1-20 match the DETAIL exactly: `close_sinks: ignore`, the other five `errors:` entries, `language: {strict-casts, strict-inference, strict-raw-types: true}`, and `formatter: trailing_commas: preserve`. The sub-claim that those need no restating is CORRECT. VGA 10.3.0 on GitHub main is byte-identical in this block. VGA is alive: publisher verygood.ventures (verified), latest 10.3.0 (~June 2026), not discontinued.

**2. VGA never ENABLES close_sinks — so there is nothing to "re-enable."** `close_sinks` does not appear in VGA's 210-rule `linter: rules:` list (grep of the awk-extracted linter block: absent; `cancel_subscriptions` is present at line 65). VGA's `close_sinks: ignore` is vestigial/defensive — it ignores a rule it never turns on. It has been that way in every cached version from 2.3.0 through 10.3.0.

**3. `analyzer: errors:` cannot enable a disabled lint — it only re-severities diagnostics already produced.** dart.dev/tools/analysis: severity overrides apply to rules already active; enabling requires `linter: rules:`. Proven empirically on the SDK actually installed (Dart 3.11.0 / Flutter 3.41.2), fresh probe with VGA 10.2.0 resolved (no include_file_not_found), textbook leaked `StreamController`:
- THE PROJECT'S CONFIG (VGA include + `errors: close_sinks: error`) → **no close_sinks diagnostic** (only an unrelated `cascade_invocations` info).
- Add `linter: rules: - close_sinks` → `error - Unclosed instance of 'Sink' - close_sinks` fires.
- `errors: close_sinks: error` with no include, rule not enabled → No issues found.
- Typo control (`close_sinks_bogus_name`) → `undefined_lint`, so the name is genuinely recognized; silence is non-enablement, not a bad rule name.

**4. Even once enabled, close_sinks would NOT catch the pattern the claim invokes.** A `StreamController` held as a long-lived FIELD produced no diagnostic in the probe even with the rule enabled. The rule only tracks sinks created and closed in the same function — its own message says "Try invoking 'close' in the function in which the 'Sink' was created," and dart.dev/tools/linter-rules/close_sinks states "This rule does not track all patterns of Sink instantiations and closures" (sdk#57882). A controller on a service/notifier closed in `dispose()` is exactly the case it misses. So the rule is doubly non-load-bearing for the stated use case.

**5. The factual premise is false: this project holds no StreamController, because it holds no code.** `git ls-files "*.dart"` → 0. The repo is RESEARCH.md, idea.md, analysis_options.yaml, research/. The only "StreamController" string in the repo is inside the analysis_options.yaml comment asserting it. RESEARCH.md:363 mentions reacting to "TTS voice-availability changes" via Riverpod and explicitly says "be honest: **this is not load-bearing**." Also note flutter_tts exposes handler setters, not a voice-availability stream, so any such controller would be app-authored and hypothetical.

**6. Precision of the defect:** auditing all 17 rules the project promotes/demotes via `errors:` against VGA's rule list, 16 are enabled by VGA and their overrides work. `close_sinks` is the *single* no-op — and it is the exact one the claim singles out as load-bearing.

The claim inverts its own thesis: the override is decorative, not load-bearing. It is the only line in a 200-line, heavily-reasoned lint file that silently does nothing, in a file whose stated purpose is that "the analyzer and the test suite are the ONLY two things between a defect and a user tapping 'I need to leave' and hearing NOTHING."

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "lints-tooling" made this claim, and a project decision depends on it.

CLAIM: very_good_analysis sets `close_sinks: ignore` — a rule this project specifically needs, so the override is load-bearing rather than decorative.
DETAIL: VGA 10.2.0's own analyzer block: `errors: {close_sinks: ignore, unrelated_type_equality_checks: warning, collection_methods_unrelated_type: warning, missing_return: error, missing_required_param: error, record_literal_one_positional_no_trailing_comma: error}`. This project holds a StreamController for TTS voice-availability changes, so `close_sinks: error` is re-enabled explicitly. VGA also already sets `language: {strict-casts: true, strict-inference: true, strict-raw-types: true}` and `formatter: trailing_commas: preserve`, so those need no restating.
CLAIMED SOURCES: ~/.pub-cache/hosted/pub.dev/very_good_analysis-10.2.0/lib/analysis_options.10.2.0.yaml
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

# lints-tooling--discarded-futures-and-unawaited-futures-both

> Phase: **verify** · Agent `a2b8a98885307c1bd` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Evidence:** I independently reproduced the entire probe rather than trusting the report. The project's local toolchain is genuinely Dart 3.11.0 (stable, 2026-02-09), and very_good_analysis resolved to exactly 10.2.0 as claimed.

Probe file: /private/tmp/claude-501/-Users-zakariafatahi-50-apps-challenge-Offline-AAC/894d23b4-edde-414c-90f6-a0c3d1367fdd/scratchpad/probe/lib/main.dart

`flutter analyze` output, all four results match the claim exactly:
- (A) line 10, `GestureDetector(onTap: () => tts.speak('A'))` → NO DIAGNOSTIC. Confirmed.
- (B) line 11, block body → `info • 'Future'-returning calls in a non-'async' function • 11:47 • discarded_futures`. Confirmed.
- (C) line 12, `() async {}` → `info • Missing an 'await' for the 'Future' computed by this expression • 12:53 • unawaited_futures`. Confirmed.
- (D) line 13, sync method `_onTapD` → `discarded_futures` at 13:22. Confirmed.
- Mitigation (`void speakNow` wrapping `unawaited(_speak(p).catchError(...))`, called from an arrow callback) → analyzes clean, zero futures diagnostics. Confirmed.

I checked two failure modes the researcher did NOT address, and the claim survived both:
1. Rule-enablement artifact: my first run force-enabled both rules in analysis_options.yaml, which could have manufactured B/C/D. I re-ran with STOCK very_good_analysis (bare `include:`, no overrides) — identical output. Both rules are on by default in vga 10.2.0, so the result is not an artifact of hand-enabling.
2. Package liveness: very_good_analysis is NOT dead. pub.dev shows publisher verygood.ventures (verified), last publish 27 days ago, not discontinued.

Mechanism is corroborated by the primary source, not just plausible reasoning. dart.dev states discarded_futures flags "Future-returning calls in synchronous functions **unless they are assigned or returned**." An arrow body IS a return, so `() => tts.speak('A')` returns the Future and escapes the rule — while the target type VoidCallback discards it. The claim's explanation is precisely correct.

Corroborating primary source for the gap being real and unfixed: dart-lang/sdk issue #56921, "Analysis of `discarded_futures` and `unawaited_futures` does not work for tearoffs used as arguments and, in closures, is dependent on whether enclosing function is `async`" — still OPEN, labeled linter-false-negative / type-bug / P3. A related false-negative, #59204, was closed Mar 2026, but did not cover this case.

Scope caveats (do not change the verdict, but bound it):
- The claim is verified on Dart 3.11.0, not on today's stable (Flutter 3.44.0 / Dart 3.12). I did not upgrade the user's toolchain to test 3.12. Since discarded_futures is an SDK analyzer rule (vga only enables it), behavior tracks the Dart version — and #56921 being open with no fix landed indicates the gap persists on 3.12.
- very_good_analysis latest is 10.3.0, newer than the claimed 10.2.0. This is NOT version rot: 10.3.0 requires SDK >=3.12.0 and will not resolve on Dart 3.11.0 (`version solving failed`). For this project's toolchain, 10.2.0 is the correct and latest resolvable version. The claim's version pairing is self-consistent and accurate.

I was asked to refute this and could not. The claim is empirically reproducible, correctly explained, correctly versioned, and backed by an open upstream bug. The project decision can rest on it. The one thing worth doing before relying on it long-term: re-run the probe after upgrading to Flutter 3.44 stable, since the claim's guarantee is pinned to Dart 3.11.0.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "lints-tooling" made this claim, and a project decision depends on it.

CLAIM: `discarded_futures` and `unawaited_futures` both FAIL to catch the arrow-closure callback idiom `onTap: () => tts.speak('x')`, which is precisely this project's silence bug.
DETAIL: Verified empirically on Dart 3.11.0 with very_good_analysis 10.2.0. Probe results by line: (A) `GestureDetector(onTap: () => tts.speak('A'))` → NO DIAGNOSTIC. (B) `onTap: () { tts.speak('B'); }` block body → discarded_futures fires. (C) `onTap: () async { tts.speak('C'); }` → unawaited_futures fires. (D) sync method `void _onTapD() { tts.speak('D'); }` → discarded_futures fires. The arrow form escapes because the closure body IS the invocation, so the rule treats the Future as 'returned' — but the target type is VoidCallback, so it is dropped along with any error. Mitigation verified to analyze clean: a void-returning `void speakNow(String p) { unawaited(_speak(p).catchError((Object e, StackTrace s) { /* crash log + visible banner */ })); }` — the callback then never holds a Future.
CLAIMED SOURCES: local probe: flutter analyze, Dart 3.11.0 / very_good_analysis 10.2.0, https://dart.dev/tools/linter-rules/discarded_futures
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

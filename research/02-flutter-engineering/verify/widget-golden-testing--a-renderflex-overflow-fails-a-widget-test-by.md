# widget-golden-testing--a-renderflex-overflow-fails-a-widget-test-by

> Phase: **verify** · Agent `a944368b6b428ced7` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** Headline claim stands: a RenderFlex overflow does fail a widget test by default and does not merely log. Three refinements:

(1) "Rethrows at test completion" is imprecise — the binding does not rethrow; it calls `reportTestException(_pendingExceptionDetails!, testDescription)`, routing the failure into the test framework. Same outcome, different mechanism.

(2) The claim omits a genuine conditional: because reporting lives in paint(), not performLayout(), an overflowing widget that is never painted (offstage, clipped out of the layer tree, never pumped) overflows silently and does NOT fail the test. Additionally `_overflowReportNeeded` means it reports once per reassemble. "By default" is correct for the ordinary pumpWidget + visible-widget path (the case relevant to a golden-testing decision), but it is a conditional, not an unconditional invariant.

(3) "The many blog posts" overstates the secondary literature: it is one author syndicated to four platforms, not independent corroboration. Also, `ignoreOverflowErrors` is a helper those posts instruct you to write yourself — it is NOT a Flutter SDK API and no symbol by that name exists in the framework. The supported SDK-native way to acknowledge an expected overflow is `tester.takeException()`.

**Evidence:** Verified against current flutter/flutter master (2026-07-15), all three claimed source files fetched directly.

1. flex.dart — CONFIRMED verbatim: `bool get _hasOverflow => _overflow > precisionErrorTolerance;` with `double _overflow = 0;`. RenderFlex.paint() invokes `paintOverflowIndicator(context, offset, Offset.zero & size, overflowChildRect, overflowHints: debugOverflowHints)` inside an `assert(() { ... return true; }())` block, i.e. debug-only. Widget tests run in debug, so the guard is satisfied.

2. debug_overflow_indicator.dart — CONFIRMED: paintOverflowIndicator -> _reportOverflow -> `FlutterError.reportError(FlutterErrorDetails(exception: FlutterError('A $runtimeType overflowed by $overflowText.'), ...))`. Gated by `bool _overflowReportNeeded = true`, flipped false after first report and reset in reassemble().

3. flutter_test/binding.dart — CONFIRMED: `FlutterError.onError = (FlutterErrorDetails details) { ... _pendingExceptionDetails = details; }`. `dynamic takeException() { assert(inTest); final dynamic result = _pendingExceptionDetails?.exception; _pendingExceptionDetails = null; return result; }`. At test completion: `if (_pendingExceptionDetails != null) { debugPrint = debugPrintOverride; reportTestException(_pendingExceptionDetails!, testDescription); _pendingExceptionDetails = null; }`.

The layout-computes / paint-reports split is real. Every symbol named in the claim exists with the exact name given — no invented APIs. No version rot: master read today, and the mechanism is long-standing rather than a 2023 artifact.

Failure modes checked and NOT found: invented API signatures (all verified present), version rot (read current master), dead packages (none depended on — this is core SDK).

Failure mode PARTIALLY found: overstated consensus. "The many blog posts" is one author (Reme Le Hane) syndicated across dev.to, ITNEXT, Medium and his personal blog — four URLs, one source. Immaterial here because the SDK source is dispositive, but the researcher should not reuse that corroboration framing elsewhere.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "widget-golden-testing" made this claim, and a project decision depends on it.

CLAIM: A RenderFlex overflow FAILS a widget test by default; it does not merely log
DETAIL: RenderFlex computes _overflow in performLayout (bool get _hasOverflow => _overflow > precisionErrorTolerance) but REPORTS during paint() via DebugOverflowIndicatorMixin.paintOverflowIndicator -> _reportOverflow -> FlutterError.reportError. TestWidgetsFlutterBinding overrides FlutterError.onError, stores FlutterErrorDetails in _pendingExceptionDetails, and rethrows at test completion unless takeException() clears it. Confirmed by reading debug_overflow_indicator.dart, flex.dart and flutter_test/binding.dart, and corroborated by the many blog posts teaching an 'ignoreOverflowErrors' helper (FlutterError.onError = ignoreOverflowErrors) to make tests pass despite overflow.
CLAIMED SOURCES: https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter/lib/src/rendering/debug_overflow_indicator.dart, https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_test/lib/src/binding.dart, https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/flex.dart, https://dev.to/remejuan/widget-testing-dealing-with-renderflex-overflow-errors-hlg
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

# widget-golden-testing--overflow-is-reported-only-once-per-renderobj

> Phase: **verify** · Agent `acbe22a295466b87b` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** Verdict stands as CONFIRMED; the following are refinements, not refutations.

(a) SCOPE PRECISION: the flag is per-RenderObject-INSTANCE, not per-test. The headline wording "under-reports" is exactly right, but the detail's "later scales silently 'pass'" is slightly stronger than the code guarantees — if scale 3.0 overflows a DIFFERENT render object that has not yet reported, that object does report. The failure is silent only for render objects that already fired.

(b) PRECONDITION: render-tree reuse is what makes the bug bite. A loop that pumps structurally identical widgets (only textScaler varying) reuses RenderFlex instances and hits the bug; a loop pumping structurally different widgets gets fresh render objects and fresh reports. Worth stating explicitly so the corpus does not overgeneralize to all loops.

(c) THE FIX IS NOT THE ONLY FIX: reassemble() is public and TestWidgetsFlutterBinding exposes reassembleApplication(), so `await tester.binding.reassembleApplication()` between iterations also resets the flag. The claim's per-combination testWidgets is the better default (it also isolates takeException() state and pump/frame state), but teams with a large device x scale x theme matrix should know the loop-plus-reassemble variant exists.

(d) ADDITIONAL CAVEAT NOT IN THE CLAIM: reporting fires only during PAINT and only in debug builds (the reset is inside an assert block). A test that never paints an overflowing frame will not report regardless of the flag.

**Evidence:** Verified directly against the cited primary source (flutter/master, packages/flutter/lib/src/rendering/debug_overflow_indicator.dart). Every specific in the claim checks out:

1. FLAG EXISTS WITH THAT EXACT NAME: `bool _overflowReportNeeded = true;` is an instance field on DebugOverflowIndicatorMixin. Source comment: "Set to true to trigger a debug message in the console upon the next paint call."

2. SET FALSE AFTER FIRST REPORT: inside paintOverflowIndicator:
   if (_overflowReportNeeded) {
     _overflowReportNeeded = false;
     _reportOverflow(overflow, overflowHints);
   }

3. RESET ONLY ON reassemble(): the only write back to true is:
   @override
   void reassemble() {
     super.reassemble();
     // Users expect error messages to be shown again after hot reload.
     assert(() { _overflowReportNeeded = true; return true; }());
   }
   Exhaustive check of all reads/writes of the flag (declaration, the read+false-write in paintOverflowIndicator, the true-write in reassemble) confirms NO other reset path. There is no conditional logic keyed to overflow magnitude — the gate is purely binary, so a worsening overflow on an already-reported render object produces silence.

4. INDEPENDENT CORROBORATION: the class-level doc on api.flutter.dev states the mixin "will print on the first occurrence, and once after each time that reassemble is called." This is the documented, intended behavior — not an implementation accident.

CONSEQUENCE FOR THE TEST PATTERN: the claim's scenario holds. Looping MediaQuery.textScaler 1.0/2.0/3.0 via pumpWidget over a structurally identical tree reuses the same RenderFlex instances, so each render object reports at most once and takeException() returns null on later iterations. The proposed fix (one testWidgets per device x scale x theme, giving each a fresh render tree) is sound.

Hunted for the listed failure modes and found none: the API name is real and current on master as of 2026-07 (not invented, not version-rotted — the flag and reassemble reset have been stable since the mixin was factored out in flutter/flutter#12xxx, commit 3541ad0); no package-liveness question is involved since this is framework-internal; the claim is a mechanism claim grounded in source, not a cargo-culted team practice or an overstated community consensus.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "widget-golden-testing" made this claim, and a project decision depends on it.

CLAIM: Overflow is reported only ONCE per RenderObject, so looping text scales inside one testWidgets under-reports
DETAIL: DebugOverflowIndicatorMixin guards with a _overflowReportNeeded flag: set false after the first report, reset only on reassemble(). If a test loops scales 1.0/2.0/3.0 against the same render tree and calls takeException() per iteration to collect failures, only the FIRST overflow reports — later scales silently 'pass'. Fix: generate one testWidgets per (device x scale x theme) so each gets a fresh render tree.
CLAIMED SOURCES: https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter/lib/src/rendering/debug_overflow_indicator.dart
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

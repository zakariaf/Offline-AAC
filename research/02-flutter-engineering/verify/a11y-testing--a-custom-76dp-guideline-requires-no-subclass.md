# a11y-testing--a-custom-76dp-guideline-requires-no-subclass

> Phase: **verify** · Agent `a427c892e48bc41bb` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** The claim is correct on everything the decision rests on. Two peripheral inaccuracies worth fixing in the corpus, neither of which changes the conclusion:

1. Evaluation.fail signature is misquoted. Claim says `Evaluation.fail(String reason)` — required positional, non-nullable. Actual: `const Evaluation.fail([this.reason]);` i.e. `Evaluation.fail([String? reason])` — OPTIONAL positional and NULLABLE. `Evaluation.fail()` with no argument is legal. Relatedly, `operator +` takes a nullable `Evaluation? other` (returns `this` when other is null), not a non-null Evaluation.

2. The causal framing of @visibleForTesting is inverted. The claim says the analyzer accepts the class in test/ "because of @visibleForTesting". That is backwards: @visibleForTesting is a RESTRICTION, not a grant. MinimumTapTargetGuideline is a public exported class and would be usable anywhere without the annotation; the annotation is what would trigger a lint OUTSIDE test/. Net effect inside test/ is identical (no lint), so the practical advice stands — but the mechanism is "public class, and the annotation's restriction doesn't bite in test/", not "the annotation unlocks it".

3. Minor omission: LabeledTapTargetGuideline is ALSO annotated @visibleForTesting (the claim mentions only its private constructor). Doesn't affect the contrast being drawn.

Also note for implementers: the `size` is in logical pixels, and the guideline is intended to be passed to `expectLater(tester, meetsGuideline(myGuideline))` — the 76dp instance should be a top-level `const`, mirroring how Flutter declares androidTapTargetGuideline.

**Evidence:** I attempted to refute this on four fronts and it survived all of them. Every load-bearing element verified verbatim against primary sources on BOTH master and the stable branch (they are identical — no version rot; this is current in Flutter 3.44.0, not a 2023 artifact).

1. MinimumTapTargetGuideline — CONFIRMED EXACTLY. flutter/flutter stable + master, packages/flutter_test/lib/src/accessibility.dart:
   @visibleForTesting
   class MinimumTapTargetGuideline extends AccessibilityGuideline {
     const MinimumTapTargetGuideline({required this.size, required this.link});
   api.flutter.dev independently confirms the constructor is public and const with required named `size` (Size) and `link` (String). So `const MinimumTapTargetGuideline(size: Size(76,76), link: '...')` compiles. NO subclassing required — the core claim is correct. Corroborated by the framework's own usage: `const AccessibilityGuideline androidTapTargetGuideline = MinimumTapTargetGuideline(size: Size(48.0,48.0), link: '...')` and iOSTapTargetGuideline at Size(44,44) — Flutter itself re-parameterizes this class via the public const constructor, which is exactly the pattern the claim proposes at 76dp.

2. LabeledTapTargetGuideline private constructor — CONFIRMED. Source reads `const LabeledTapTargetGuideline._();`. Private ctor means no external subclassing or re-parameterization; only the `labeledTapTargetGuideline` const is usable. Claim correct.

3. AccessibilityGuideline extendable — CONFIRMED. Plain `abstract class AccessibilityGuideline { const AccessibilityGuideline(); FutureOr<Evaluation> evaluate(WidgetTester tester); String get description; }`. No sealed/base/final class modifier, so it is externally extendable. api.flutter.dev lists implementers: CustomMinimumContrastGuideline, LabeledTapTargetGuideline, MinimumTapTargetGuideline, MinimumTextContrastGuideline.

4. operator + semantics — CONFIRMED. Returns `Evaluation._(passed && other.passed, ...)` and writes `buffer.writeln()` between the two reasons. It does AND results and newline-join reasons, as claimed.

THE ONE REAL ATTACK, and why it failed: the @visibleForTesting lint claim looked refutable. The official dartdoc for `meta.visibleForTesting` explicitly says a reference is only allowed in the defining library or "a library which is in the `test` folder of THE DEFINING PACKAGE" — which, read literally, would mean a Flutter app's own test/ dir does NOT qualify (flutter_test is a different package), and the claim would fail. dart.dev's diagnostic page is ambiguous ("a library in the `test` directory", unqualified). I resolved it against the analyzer implementation, which is what actually decides: in pkg/analyzer/lib/src/error/best_practices_verifier.dart, `_InvalidAccessVerifier` computes `inTestDirectory` from the REFERENCING library (`this._library`), passed in at construction, and `_checkForOtherInvalidAccess` short-circuits with `if (_inTestDirectory || _inExportDirective(node)) return;`. The check is on the referencing code's location, NOT the defining package's test folder. So consuming MinimumTapTargetGuideline inside your own test/ produces no invalid_use_of_visible_for_testing_member lint. Claim's practical conclusion holds — the docs are wrong/stale, not the claim.

No dead-package or maintenance risk: flutter_test is a first-party SDK package, not a third-party dependency.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "a11y-testing" made this claim, and a project decision depends on it.

CLAIM: A custom 76dp guideline requires NO subclassing — MinimumTapTargetGuideline's const constructor is public and the class is @visibleForTesting.
DETAIL: `@visibleForTesting class MinimumTapTargetGuideline extends AccessibilityGuideline { const MinimumTapTargetGuideline({required this.size, required this.link}); final Size size; final String link; ... }`. So `const MinimumTapTargetGuideline(size: Size(76,76), link: '<your docs url>')` works, and because of @visibleForTesting the analyzer accepts it inside test/ with no lint. Contrast: `LabeledTapTargetGuideline` has a PRIVATE constructor (`const LabeledTapTargetGuideline._()`) so it cannot be re-parameterized or subclassed — only the `labeledTapTargetGuideline` const is usable. `AccessibilityGuideline` itself is a public, extendable abstract class: `abstract class AccessibilityGuideline { const AccessibilityGuideline(); FutureOr<Evaluation> evaluate(WidgetTester tester); String get description; }`, with `Evaluation.pass()`, `Evaluation.fail(String reason)`, `final bool passed`, `final String? reason`, and `operator +` that ANDs results and newline-joins reasons.
CLAIMED SOURCES: https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_test/lib/src/accessibility.dart, https://api.flutter.dev/flutter/flutter_test/AccessibilityGuideline-class.html
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

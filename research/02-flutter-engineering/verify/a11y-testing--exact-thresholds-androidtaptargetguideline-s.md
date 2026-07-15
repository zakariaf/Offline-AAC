# a11y-testing--exact-thresholds-androidtaptargetguideline-s

> Phase: **verify** · Agent `ab392fbabab43b03f` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Evidence:** Attempted refutation on all five hunted failure modes; none landed. Every checkable value matched exactly.

TAP TARGETS — confirmed by BOTH the raw master source and api.flutter.dev (independent confirmation, not one source echoed twice):
- `const AccessibilityGuideline androidTapTargetGuideline = MinimumTapTargetGuideline(size: Size(48.0, 48.0), link: 'https://support.google.com/accessibility/android/answer/7101858?hl=en');` — matches claim verbatim, including the link.
- `const AccessibilityGuideline iOSTapTargetGuideline = MinimumTapTargetGuideline(size: Size(44.0, 44.0), link: 'https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/adaptivity-and-layout/');` — the claim left the HIG URL as a placeholder, so no conflict.

CONTRAST CONSTANTS — each verified on its OWN api.flutter.dev per-constant page, not just the class page:
- `static const double kMinimumRatioNormalText = 4.5;`
- `static const double kMinimumRatioLargeText = 3.0;`
- `static const int kLargeTextMinimumSize = 18;` (note: `int`, not double)
- `static const int kBoldTextMinimumSize = 14;` (note: `int`)
All four names exist with exactly those names — mode 3 (invented/misremembered API names) ruled out. `MinimumTextContrastGuideline` and `MinimumTapTargetGuideline` are both live, documented classes in flutter_test.

UNITS — confirmed: `final Size candidateSize = paintBounds.size / view.devicePixelRatio;` then compared against `size.width`/`size.height`. So the comparison is in logical pixels (dp), as claimed. This also confirms the claim is current, not version-rotted: it uses `view.devicePixelRatio`, the post-`window`-deprecation API. A 2023-era claim would have said `window.devicePixelRatio`. Mode 1 ruled out.

MODE 2 (dead package) is not applicable — flutter_test is a first-party SDK package, not a pub.dev third party. Modes 4/5 are not applicable — this is a source-code claim, not a practice or consensus claim.

CAVEATS (do not change the verdict, but scope the confidence):
1. The two PRIVATE constants — `_kDefaultFontSize = 12.0` and `_tolerance = -0.01` — rest on a SINGLE source (the raw GitHub fetch). Private members are not published to api.flutter.dev, so I could not double-source them. They are the weakest links in an otherwise doubly-confirmed claim.
2. The tap-target size comparison in the source uses `precisionErrorTolerance` (the framework-wide constant), NOT `_tolerance`. The claim files `_tolerance` under MinimumTextContrastGuideline, which is consistent with what I saw — but a reader could wrongly infer `-0.01` governs tap-target checks. It does not.
3. The claim's illustration "Size(76,76) means 76dp" appears to be a stray artifact from a different claim — 76 corresponds to no guideline here (they are 48 and 44). The unit point it makes is nonetheless correct.
4. "master" is a moving target; this reflects master as of 2026-07-15.

Practical note for the decision that depends on this: the values are safe to rely on, but they are pinned to WCAG 2.0 large-text definitions and the constants are compared in logical pixels — so a Size(48,48) assertion means 48dp regardless of device pixel ratio, which is the behavior the claim describes.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "a11y-testing" made this claim, and a project decision depends on it.

CLAIM: Exact thresholds: androidTapTargetGuideline = Size(48,48); iOSTapTargetGuideline = Size(44,44); contrast 4.5 normal / 3.0 large; large text = 18px or 14px bold; default assumed font size 12.
DETAIL: Read from packages/flutter_test/lib/src/accessibility.dart master. `const AccessibilityGuideline androidTapTargetGuideline = MinimumTapTargetGuideline(size: Size(48.0, 48.0), link: 'https://support.google.com/accessibility/android/answer/7101858?hl=en');` and `iOSTapTargetGuideline = MinimumTapTargetGuideline(size: Size(44.0, 44.0), link: <HIG url>)`. In MinimumTextContrastGuideline: `kMinimumRatioNormalText = 4.5`, `kMinimumRatioLargeText = 3.0`, `kLargeTextMinimumSize = 18`, `kBoldTextMinimumSize = 14`, `_kDefaultFontSize = 12.0`, `_tolerance = -0.01`. Sizes are compared in logical pixels (`paintBounds.size / view.devicePixelRatio`), so Size(76,76) means 76dp.
CLAIMED SOURCES: https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_test/lib/src/accessibility.dart
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

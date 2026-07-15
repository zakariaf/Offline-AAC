# ci-release--golden-tests-are-os-dependent-the-2026-conse

> Phase: **verify** · Agent `a98e548e53d45a125` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Replace "Flutter defaults to the Ahem font (renders boxes)" with: "Flutter's default test font has been FlutterTest, not Ahem, since March 2023 (engine PRs #40188/#40352). It still renders boxes, so you must still load real fonts via flutter_test_config.dart — but Ahem is now opt-in via an explicit fontFamily. Alchemist's CI mode is one of the few places Ahem is still pinned deliberately."

Replace the #36667 citation with flutter/flutter#184182, where a Flutter team member states goldens "are generally only reliable when run on a machine with the exact same configuration (OS version, OS settings, etc) as the one used to produce the original image." #36667 is real but CLOSED and dates to 2019.

Downgrade "the 2026 consensus" to "one widely-cited May 2025 blog post recommends." No primary source establishes consensus, and the ecosystem is visibly split: Alchemist (alive, betterment.dev, v0.14.0) implements the opposite strategy — deliberately platform-agnostic CI goldens via box-glyph rendering.

Fix option (b): Alchemist is not "separate CI/local golden folders" — it is two test modes (platform tests with real text vs CI tests with text replaced by colored squares).

Also worth noting for the ci-release decision: OS-matching is necessary but not sufficient. #184182 shows a macOS POINT RELEASE (26.4) invalidated goldens on the same OS family, so "match CI OS to dev OS" still breaks on OS updates unless the runner image is pinned. That strengthens the case for making CI authoritative — but for a reason the claim never gives.

**Evidence:** CORE MECHANISM: CONFIRMED. Golden tests genuinely are OS-dependent, and this is not folklore — it is stated by the Flutter team itself.

1. Issue #36667 is REAL and the title is quoted accurately: "Golden files are not consistent between Flutter versions and different OS versions" (labels: a: tests, c: contributor-productivity, framework; assignee Piinks). BUT the claim presents it as live evidence of an open problem — it is CLOSED. Citing a closed 2019 issue as the load-bearing source for a "2026 consensus" is weak sourcing.

2. Much stronger primary evidence the claim missed: flutter/flutter#184182 ("Goldens images changed after upgrade to macOS 26.4", closed). A Flutter team member states directly: "golden testing: these tests are highly sensitive to the environment and are generally only reliable when run on a machine with the exact same configuration (OS version, OS settings, etc) as the one used to produce the original image." The team confirmed macOS 26.4 changed system-level font rendering and that this is outside Flutter's scope. This is the citation the researcher should be using — it is recent, authoritative, and says exactly what they want to claim.

FOUR DEFECTS:

A. VERSION ROT — "Flutter defaults to the Ahem font" is FALSE and has been since 2023. docs.flutter.dev/release/breaking-changes/rendering-changes: "The FlutterTest font replaced Ahem as the default font in tests: when fontFamily isn't specified, or the font families specified are not registered, tests use the FlutterTest font to render text. The Ahem font is still available in tests if specified as the fontFamily to use." Landed via engine PR #39809 (font added), #40188 + #40352 (made default), merged March 17 2023. flutter/flutter docs/contributing/testing/Flutter-Test-Fonts.md confirms: "the default test font FlutterTest will be used." Ahem is now opt-in only. This error almost certainly propagated from the third cited source (hevawu blog, dated April 13 2022) which pre-dates the change by a year. NOTE: the practical advice survives — FlutterTest also renders boxes (Square glyph "a box that fills the em square"), so you still must load real fonts via flutter_test_config.dart. Only the font NAME is wrong. Metrics differ: FlutterTest ascent/descent 0.75/0.25 em vs Ahem 0.8/0.2 em, 1024 upem vs 1000.

B. ALCHEMIST MISCHARACTERIZED — the claim calls option (b) "Alchemist's separate CI/local golden folders." That is not what Alchemist does. Per pub.dev/packages/alchemist it is two test MODES: platform tests (human-readable text, host-dependent) vs CI tests, which "replace text blocks with colored squares" and "are always run using the Ahem font family ... to ensure that CI tests are platform agnostic — their output is always consistent regardless of the host platform." (This is one place Ahem IS still correct — Alchemist pins it explicitly.)

C. OVERSTATED / SELF-CONTRADICTING CONSENSUS — "The May-2025-onward recommendation is to match environments rather than make tests platform-agnostic" rests on ONE blog post: the cited Medium article by Valentyna Polienova, published May 1 2025. That is where "May 2025" comes from. The article recommends splitting CI (unit on ubuntu-latest, goldens on macos-latest) but does NOT claim community consensus. Worse, option (b) in the researcher's own list refutes the thesis: Alchemist's entire design goal is to make CI tests platform-agnostic — the exact strategy the claim says the community abandoned. You cannot cite Alchemist as a live option and simultaneously claim the field moved away from platform-agnostic testing.

D. PACKAGE STATUS — this one is clean, no dead-package problem. Alchemist is ALIVE: v0.14.0, published ~4 months ago (early 2026), publisher betterment.dev (verified), not discontinued. (Contrast golden_toolkit, which is discontinued — the researcher correctly avoided it.)

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "ci-release" made this claim, and a project decision depends on it.

CLAIM: Golden tests are OS-dependent; the 2026 consensus is to make CI authoritative rather than chase cross-platform tolerance
DETAIL: macOS applies font smoothing that Linux doesn't; goldens generated on macOS fail on ubuntu-latest runners (flutter/flutter#36667 — goldens are inconsistent across both OS versions and Flutter versions). Options: (a) match CI OS to dev OS, (b) Alchemist's separate CI/local golden folders, (c) per-platform tolerance. The May-2025-onward recommendation is to match environments rather than make tests platform-agnostic. Flutter defaults to the Ahem font (renders boxes) unless you load real fonts via flutter_test_config.dart.
CLAIMED SOURCES: https://github.com/flutter/flutter/issues/36667, https://medium.com/@m1nori/flutter-golden-tests-fail-in-github-actions-why-and-how-to-fix-65e3b69ee86e, https://hevawu.github.io/blog/2022/04/13/Run-Flutter-Golden-Tests-Between-MacOS-And-CI
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

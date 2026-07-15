# testing-strategy--flutter-test-coverage-omits-files-that-no-te

> Phase: **verify** · Agent `a1235ea422cf8a223` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** Two specifics need fixing, neither overturning the claim. (1) Replace "Tracked as" — both issues are closed, not open. #40948 was closed 2019-09-20 purely as a duplicate of #27997 (its "COMPLETED" state is a dupe-closing artifact, not a fix), and #27997 was closed NOT_PLANNED on 2025-06-27 as explicit WONTFIX. This strengthens the claim (no upstream fix is coming) but the wording implies an open, pending issue. (2) Fix (a) recommends abandonware: dlcov 4.2.1 was last published 2022-05-10, its repo last pushed the same day (10 stars, unverified uploader), and its SDK bound ">=2.12.0 <3.0.0" only permits Dart 3 via pub's null-safe upper-bound relaxation. It is neither discontinued nor archived and still works, but the current, maintained equivalent — proposed in the #27997 thread itself — is "discover" v0.4.0 (published 2025-04-21, SDK ^3.5.0, verified publisher mobile-tools.dev): dart pub global activate discover && discover scan. Prefer discover, or fix (b) (the generated coverage_helper_test.dart barrel import), which has no dependency-rot risk at all.

**Evidence:** Attempted refutation failed; claim survives primary-source verification.

CORE MECHANISM — CONFIRMED BY FLUTTER TEAM, RECENTLY. flutter/flutter#27997 was closed NOT_PLANNED on 2025-06-27 by Flutter team member matanlurey with an explicit statement: "If a file is not reachable by the entrypoint that executes coverage, then because the VM has never loaded the library it doesn't return any coverage information for us. This is still true - we don't plan to change it at the time." This is VM-level coverage-collection behavior (unloaded library => no coverage data emitted), not a fixable tooling bug, so it holds in Flutter 3.44. Explicitly WONTFIX as of 13 months ago — no version rot.

ISSUE IDs/TITLES — EXACT. #27997 "Flutter test coverage will not report untested files" (created 2019-02-15, closed 2025-06-27, NOT_PLANNED). #40948 "Include untested files in test coverage" (created 2019-09-20, closed 2019-09-20).

DIRECTION OF ERROR — CONFIRMED. Untested/unimported files contribute zero lines to the denominator rather than 0%-covered lines, so the percentage inflates. dlcov's own documentation independently states Flutter's native coverage excludes unreferenced files, "potentially inflating coverage percentages." The one-tested-file/twenty-untested ~100% illustration is arithmetically sound given zero-denominator contribution.

FIX (a) API NAME — EXACT, NOT INVENTED. dlcov documents --include-untested-files ("do not ignore untested files during the analysis"), default false.

FIX (b) — CONFIRMED. The generated barrel-import test file is the long-standing community workaround, originating in pdblasi's comment on #27997 (issuecomment-1144247839) and corroborated by other thread participants.

TWO CORRECTIONS (secondary, do not overturn the verdict):

1. "Tracked as" is wrong — both issues are CLOSED, not open/tracked. #40948's GitHub stateReason "COMPLETED" is an artifact of duplicate-closing; the closing comment reads "Duplicate of #27997 which is open" — it was NOT fixed. #27997 is wontfix. No upstream fix is coming; do not wait on one.

2. dlcov is stale abandonware. Version 4.2.1 published 2022-05-10 (over 4 years ago); repo github.com/emanuel-braz/dlcov last pushed 2022-05-10, 10 stars, unverified uploader. SDK constraint is ">=2.12.0 <3.0.0" — it runs on Dart 3 only via pub's upper-bound relaxation for null-safe packages. pub.dev tags it is:dart3-compatible, 150/160 points, NOT discontinued and NOT archived, so it still functions — but presenting it as a live recommendation overstates its health.

MISSED BETTER OPTION: "discover" v0.4.0, published 2025-04-21, SDK ^3.5.0, verified publisher mobile-tools.dev, repo github.com/PiotrFLEURY/discover — written by PiotrFLEURY specifically in response to #27997 and discussed in that thread. Usage: dart pub global activate discover; discover scan. Actively maintained relative to dlcov.

The decision-relevant reasoning (a coverage number that lies upward is worse than no number in a project with no other safety net) is fully substantiated.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "testing-strategy" made this claim, and a project decision depends on it.

CLAIM: `flutter test --coverage` omits files that no test imports, silently INFLATING the coverage percentage — the opposite of the safe failure direction
DETAIL: Tracked as flutter/flutter#27997 ('Flutter test coverage will not report untested files') and related #40948 ('Include untested files in test coverage'). A file with zero tests contributes zero lines to the denominator rather than counting as 0% covered. A codebase with one well-tested file and twenty untested ones can report ~100%. Fixes: (a) `dlcov --include-untested-files=true`, or (b) generate a test/coverage_helper_test.dart that imports every lib/ file. This matters here because a coverage number that lies UPWARD is worse than no number at all in a project with no other safety net.
CLAIMED SOURCES: https://github.com/flutter/flutter/issues/27997, https://github.com/flutter/flutter/issues/40948, https://pub.dev/documentation/dlcov/latest/
CONFIDENCE: medium

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

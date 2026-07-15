# testing-strategy--the-widely-cited-70-20-10-or-60-25-10-5-flut

> Phase: **verify** · Agent `afecf62a13532658b` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Do not say the ratios have "no authoritative source." Say instead: the 70/20/10 split originates in Google's Testing Grouplet small/medium/large test-SIZE heuristic (Mike Bland, 2011), whose author states the numbers "essentially were pulled out of a hat" — no empirical basis. It was defined over test size, not Flutter's unit/widget/integration taxonomy, and Google itself later moved to ~80/20 narrow/broad in Software Engineering at Google. Flutter docs, VGV, and flutter/flutter publish no ratio; VGV's actual published standard is 100% line coverage (very_good_coverage), which is a coverage threshold, not a test-type distribution. Also drop the assertion that "Flutter widget tests cost roughly the same as unit tests" — docs.flutter.dev/testing/overview's tradeoff table rates widget tests equal to unit tests on execution speed ("Quick"/"Quick") but explicitly HIGHER on maintenance cost and dependencies. Correct framing: widget tests are cheap to run but not cheap to maintain.

**Evidence:** ATTEMPTED REFUTATION FAILED — core claim survives, two specifics in the DETAIL are wrong.

CONFIRMED:
1. docs.flutter.dev/testing/overview publishes NO ratio. Actual text: "Generally speaking, a well-tested app has many unit and widget tests, tracked by code coverage, plus enough integration tests to cover all the important use cases." Qualitative only.
2. testsigma.com/blog/flutter-testing/ states verbatim "Aim for 70% unit, 20% widget, and 10% integration tests" with ZERO citation or empirical support. Matches the claim's characterization exactly.
3. Very Good Ventures (guide-to-flutter-testing) states no percentage split between test types. VGV's actual published position is a COVERAGE threshold (100% line coverage, enforced via very_good_coverage GitHub Action) — a different axis, not a distribution across test types. The claim is correct that VGV publishes no ratio.
4. flutter/flutter repo/wiki: no ratio guidance found.
5. Searches surface the percentages only on SEO/content-marketing domains (testsigma, tftus, getautonoma, drizz.dev, Medium reposts, yrkan.com), asserting mutually inconsistent splits (70/20/10 vs 60/25/10/5), none citing a source.

CORRECTION 1 — "no authoritative source" is imprecise; there IS a traceable origin the researcher missed. The numbers descend from Google's Testing Grouplet 70/20/10 small/medium/large test-SIZE split (Mike Bland, 2011; Google Testing Blog 2010 "Test Sizes" / 2015 "Just Say No to More End-to-End Tests"). Mike Bland's own words: "roughly 70% small, 20% medium, and 10% large for the common case. Yes, these numbers essentially were pulled out of a hat." The originator explicitly disclaims empirical basis. This STRENGTHENS the researcher's operative conclusion while correcting its phrasing: the split is not sourceless folklore but an admittedly arbitrary Google heuristic, defined over test SIZE (small/medium/large), mis-transplanted onto Flutter's unrelated unit/widget/integration taxonomy. Additionally, Software Engineering at Google (abseil.io SWE book) later revised to ~80% narrow-scope / 20% broader — Google itself did not retain 70/20/10.

CORRECTION 2 — the DETAIL's cost premise is contradicted by Flutter's own docs. The claim asserts blogs fail to "engage with the fact that Flutter widget tests cost roughly the same as unit tests." The tradeoff table at docs.flutter.dev/testing/overview says: Confidence Unit=Low/Widget=Higher/Integration=Highest; Maintenance cost Unit=Low/Widget=Higher/Integration=Highest; Dependencies Few/More/Most; Execution speed Quick/Quick/Slow. So only EXECUTION SPEED is equivalent (both "Quick"); Flutter explicitly rates widget tests HIGHER maintenance cost and more dependencies than unit tests. The researcher should not lean on "cost roughly the same" as stated.

META-FINDING: the WebSearch summarizer itself returned "The 70/20/10 ratio is widely recognized as industry best practice for building fast, reliable, and maintainable Flutter test suites," sourced entirely to the same SEO blogs. The overstated-consensus laundering mechanism is active in search/LLM surfaces and will keep regenerating this claim.

NET: The actionable conclusion — treat any specific Flutter percentage split as unsourced — is CONFIRMED and better warranted than the researcher had it, since the numbers' own originator calls them arbitrary. Downgraded to PARTIALLY_TRUE only because "no authoritative source" overstates (a documented, self-disclaiming origin exists) and the widget-vs-unit cost premise conflicts with Flutter's published tradeoff table.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "testing-strategy" made this claim, and a project decision depends on it.

CLAIM: The widely-cited 70/20/10 (or 60/25/10/5) Flutter test ratios are folklore with no authoritative source
DETAIL: Searches surface these numbers only in SEO content-marketing blogs (testsigma, tftus, getautonoma, Medium reposts), each asserting slightly different splits (70/20/10 vs 60/25/10/5) with no citation. None engage with the fact that Flutter widget tests cost roughly the same as unit tests. Flutter's own docs, Very Good Ventures, and the flutter/flutter repo publish no such ratio. Treat any specific percentage split as unsourced.
CLAIMED SOURCES: https://docs.flutter.dev/testing/overview, https://testsigma.com/blog/flutter-testing/
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

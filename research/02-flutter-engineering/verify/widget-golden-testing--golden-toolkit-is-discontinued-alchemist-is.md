# widget-golden-testing--golden-toolkit-is-discontinued-alchemist-is

> Phase: **verify** · Agent `adcdce3c3c2b255eb` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Strike the assertion that "the brief's attribution of alchemist to Very Good Ventures is incorrect." Alchemist was co-created by Very Good Ventures and Betterment — released by VGV in association with Betterment in February 2022 — and the README still credits "Developed with 💙 by Very Good Ventures 🦄 and Betterment ☀️" alongside the VGV logo. The accurate phrasing: alchemist's pub.dev verified publisher is betterment.dev and the repo is hosted at github.com/Betterment/alchemist, but it is a joint VGV/Betterment project, so attributing it to VGV is not an error. Everything else in the claim stands verbatim: golden_toolkit v0.15.0 discontinued with no suggested replacement (publisher eBay.com, ~3 years since last publish); alchemist v0.14.0 published ~4 months ago (2026-03-13), 160 pub points, 220 likes, ~305k weekly downloads. Add one nuance: eBay/flutter_glove_box is pub.dev-discontinued and README-declared unmaintained, but is not formally GitHub-archived.

**Evidence:** Every quantitative specific in the DETAIL checked out against primary sources; the only failure is the claim's own corrective assertion about attribution.

CONFIRMED — golden_toolkit (pub.dev/packages/golden_toolkit): v0.15.0, explicitly marked DISCONTINUED, no suggested replacement, last published ~3 years ago, publisher eBay.com (verified), 150 pub points, 488 likes, ~387k weekly downloads. The upstream repo (github.com/eBay/flutter_glove_box) README states directly: "Unfortunately we have made the tough decision to no longer actively maintain this repository. While the package has served us and the community well, we don't have the capacity to give it the attention it deserves." Last commit Dec 8, 2022. The team notes they expect "the community will rally... around more actively maintained packages" but names no specific successor — matching the claim's "no suggested replacement."

CAVEAT on repo status: flutter_glove_box is NOT formally GitHub-archived. It is functionally abandoned and pub.dev-discontinued, but an automated "is the repo archived?" check returns false. Relevant if the corpus keys on archive status as the signal.

CONFIRMED — alchemist (pub.dev/packages/alchemist): v0.14.0, verified publisher betterment.dev, published ~4 months ago (v0.14.0 released 2026-03-13 per GitHub releases), 160 pub points, 220 likes, ~305k weekly downloads, not discontinued, repo not archived, 21 releases. All five figures in the DETAIL match exactly.

REFUTED — the attribution correction. The claim asserts alchemist "is Betterment's, not Very Good Ventures'" and that "The brief's attribution of alchemist to Very Good Ventures is incorrect." This is false, and it inverts the actual history. The Betterment/alchemist README credits: "Developed with 💙 by Very Good Ventures 🦄 and Betterment ☀️", and displays the Very Good Ventures logo at the top of the documentation. Alchemist was released by Very Good Ventures in association with Betterment on 2022-02-23; VGV continues to publish first-party tutorials for it (verygood.ventures/blog/alchemist-golden-tests-tutorial/). It is a joint project, not an either/or.

Root cause of the researcher's error: pub.dev's verified-publisher field is betterment.dev and the repo is under github.com/Betterment. Both are true observations, but "pub.dev verified publisher" and "GitHub org" are not the same thing as authorship/origin. The researcher generalized from hosting metadata to provenance. The brief was not wrong; the correction overshot into a false claim of error — a fact-check inventing a defect. Flagged because it was rated high confidence.

Supporting detail the claim omits: alchemist's README describes it as "heavily inspired by eBay Motor's golden_toolkit package," so the golden_toolkit-to-alchemist migration implied by the decision is a real and intentional path.

Decision impact: the load-bearing part (golden_toolkit is dead; alchemist is alive and maintained) is fully substantiated and safe to act on. Only the provenance sentence needs striking.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "widget-golden-testing" made this claim, and a project decision depends on it.

CLAIM: golden_toolkit is DISCONTINUED; alchemist is maintained but is Betterment's, not Very Good Ventures'
DETAIL: pub.dev shows golden_toolkit explicitly marked discontinued, v0.15.0, last published ~3 years ago, with no suggested replacement. alchemist: v0.14.0 published ~4 months ago, verified publisher betterment.dev, 160 pub points, 220 likes, ~305k weekly downloads. The brief's attribution of alchemist to Very Good Ventures is incorrect.
CLAIMED SOURCES: https://pub.dev/packages/golden_toolkit, https://pub.dev/packages/alchemist, https://github.com/Betterment/alchemist
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

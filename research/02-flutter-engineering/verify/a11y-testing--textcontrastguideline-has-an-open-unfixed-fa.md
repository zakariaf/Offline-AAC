# a11y-testing--textcontrastguideline-has-an-open-unfixed-fa

> Phase: **verify** · Agent `a29bbb781d1588d4c` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** No factual correction needed. Two qualifications: (1) the issue's state_reason is "reopened" (closed then reopened; currently open, last updated 2025-12-19), so it is not an untouched-since-2022 report; (2) the normative conclusion "must not be the contrast gate" is the researcher's inference, not language from the issue — the sourced version is "cannot be relied on as the sole contrast gate; pair it with static color-pair assertions or manual/vision-based checks, especially for text drawn via CustomPainter or rendered as an image, which the guideline cannot see at all."

**Evidence:** Attempted refutation on all five failure axes; the claim survives each.

1. ISSUE STATUS (GitHub REST API, api.github.com/repos/flutter/flutter/issues/103235): state=open, labels include P2, "a: tests", framework, "has reproducible steps", team-framework, triaged-framework. created_at 2022-05-06, updated_at 2025-12-19. Title verbatim: "`meetsGuideline(textContrastGuideline)` passes with white text on almost-white background". Matches the claim's "still open, P2" exactly. No fix PR located; nearby PRs (#31000 heuristic improvement, #133861 image disposal) do not address it.

2. THE BUG SPECIFICS: white text 0xffffff on 0xfafafa background (default counter app's "0") — meetsGuideline(textContrastGuideline) PASSES when it should fail. Matches claim exactly, including the hex values.

3. MECHANISM (verified against actual master source, packages/flutter_test/lib/src/accessibility.dart — this is where invented API names were most likely, and none were found):
   - screenshots render layer: layer.toImage(renderView.paintBounds, pixelRatio: ratio) -> image.toByteData()
   - color histogram over paint bounds: final Map<Color, int> colorHistogram = _colorsWithinRect(byteData, paintBoundsWithOffset, image.width, image.height)
   - exact finder as claimed: find.text(text).hitTestable().evaluate()
   - text not findable via find.text is silently skipped (loop simply does not execute; no failure reported) — confirms the CustomPainter/image-text blind spot

4. FLUTTER'S OWN DOCS CORROBORATE THE DEFECT: api.flutter.dev/flutter/flutter_test/textContrastGuideline-constant.html describes "a very naive partitioning of the colors into 'light' and 'dark'", taking the most frequent color in each partition as representative. This independently explains the mis-attribution: 0xffffff and 0xfafafa both fall in the "light" partition, so the selected fg/bg pair is not the real one. API surface (textContrastGuideline constant, MinimumTextContrastGuideline class, meetsGuideline function) all exist with the exact names claimed.

CAVEATS (do not refute, but should qualify any citation):
(a) The issue's state_reason is "reopened" — it was closed at some point and reopened, so it has a non-linear history rather than being untouched since 2022.
(b) "must not be the contrast gate" is the researcher's prescriptive conclusion, not a statement in the issue. It follows reasonably from a silent false-negative but is an inference layered on the sourced facts. The defensible sourced phrasing is "cannot be relied on as the sole contrast gate."

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "a11y-testing" made this claim, and a project decision depends on it.

CLAIM: textContrastGuideline has an open, unfixed false-negative and must not be the contrast gate.
DETAIL: flutter/flutter#103235: `meetsGuideline(textContrastGuideline)` PASSES with white text (0xffffff) on 0xfafafa. Still open, P2. Mechanism: the guideline screenshots the render layer and samples pixels, picking foreground/background from a color histogram over the text's paint bounds (`find.text(text).hitTestable()`), so it mis-attributes which color is 'background' in low-variance regions and on anti-aliased/blended text. It also only evaluates nodes whose label/value text is findable via `find.text`, so text drawn in a CustomPainter or as an image is invisible to it.
CLAIMED SOURCES: https://github.com/flutter/flutter/issues/103235
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

# tile-grid-design--flutter-s-continuousrectangleborder-is-not-a

> Phase: **verify** · Agent `a9f42a87169d4fc5e` · Run `wf_f237e8a6-694`

## Result

## Verdict

**CONFIRMED**

**Correction:** Three softenings, none of which change the design decision:

(a) PERF CLAIM IS AN INFERENCE, NOT A MEASUREMENT. The study says GPU support means it "should not introduce any significant performance degradation" — the author's reasoning, not a benchmark. Flutter's own blog simultaneously calls the shape "under active development" with performance optimizations ongoing. Accurate framing: no known perf cliff; NOT measured parity with a rounded rect.

(b) THE WEB/DESKTOP FALLBACK IS LIKELY STALE. True at 3.32; the study's own later build on Flutter 3.38.3 notes "it works on WEB too" (its README carries both statements unreconciled). At current stable 3.44, re-verify before repeating "falls back on web."

(c) "MUST NOT BE USED" OVERSTATES A CONDITIONAL. The study's finding is conditional: IF FigmaSquircle faithfully represents iOS squircles, THEN ContinuousRectangleBorder is "NOT at all an acceptable option." ContinuousRectangleBorder is not deprecated and is not broken as what it advertises — it is simply the wrong tool for an iOS squircle. "Not a usable squircle" (the claim's lead) is accurate; the "must not be used" tail is rhetoric.

**Evidence:** Attempted refutation across all five failure modes; the claim survives on primary sources.

1) ANDROID SUPPORT (decision-critical) — CONFIRMED verbatim from the official Flutter 3.32 blog: "Please note that the rounded superellipse is under active development. Currently, it's only supported on iOS and Android, otherwise the behavior falls back to a standard rounded rectangle." Android-first is the supported case.

2) API EXISTS — RoundedSuperellipseBorder is live on api.flutter.dev (painting library), as are ClipRSuperellipse (widgets) and RSuperellipse (dart:ui). No version/name rot.

3) VERSION/DATE — Flutter 3.32.0 shipped May 2025. rydmike study states "On May 21, 2025 the RoundedSuperellipseBorder was added to the Flutter stable channel in version 3.32.0"; other sources cite May 20 release. One-day spread is a publish-vs-tag artifact, immaterial.

4) 2.3529 MULTIPLIER — real, traceable past the blog to Flutter issue #91523: "a ContinuousRectangleBorder that has its border radius multiplied with 2.3529 becomes close to an iOS squircle."

5) TIE FIGHTER + STROKE ALIGN — both verbatim in the study: "we can still observe the TIE-fighter shape at higher border radius. The attempt to prevent this shape is thus not completely successful." and "Does center stroke align regardless of what BorderSide uses, that actually defaults to inside."

6) ISSUE #170593 / PR #171351 — CONFIRMED on GitHub. BorderSide drawn outside the render box, confirmed 3.32.1–3.32.4 and 3.33, P2, engine-level, closed as fixed via PR #171351 (label "r: fixed"). Not an invented citation.

No invented specifics, no marketing-as-research, no license issues. Notably, Flutter's own docs for ContinuousRectangleBorder never claim it is an iOS squircle — they describe "a rectangular border with smooth continuous transitions between the straight sides and the rounded corners" — which is consistent with, not contrary to, the claim.

SOURCE-INDEPENDENCE CAVEAT: the GitHub repo (rydmike/squircle_study) and the flutterawesome article are the same author, not two corroborating sources. The claim survives regardless because Android support, API existence, and the issue/PR verify independently on blog.flutter.dev, api.flutter.dev, and github.com/flutter/flutter.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "tile-grid-design" made this claim, and a design decision depends on it.

CLAIM: Flutter's ContinuousRectangleBorder is NOT a usable squircle and must not be used; RoundedSuperellipseBorder is the correct API and it supports Android
DETAIL: ContinuousRectangleBorder requires its borderRadius to be multiplied by ~2.3529 to approximate an iOS squircle (a cornerRadius of ~10.2 needs a value of ~24), degenerates into an undesired 'TIE fighter' shape at higher radii (and does so EARLIER because of the 2.35x multiplier), and its stroke alignment is broken — it centers strokes regardless of the BorderSide strokeAlign specified. RoundedSuperellipseBorder landed in Flutter stable 3.32.0 (21 May 2025); it is the only shape that matches iOS, maintains continuous curvature at all radii and aspect ratios, correctly implements copyWith/lerp/strokeAlign, and has GPU implementation support so there is no meaningful perf cost vs a rounded rect. Platform support is iOS + Android (falls back to RoundedRectangleBorder on web/desktop) — Android-first is exactly the supported case. Caveat: issue #170593 (BorderSide drawn outside the render box) affected 3.32.1–3.33 and was fixed by PR #171351 — be on a recent stable and visually verify if you draw a hairline border.
CLAIMED SOURCES: https://github.com/rydmike/squircle_study, https://flutterawesome.com/a-flutter-study-and-comparision-of-different-squircle-shapeborder-options/, https://github.com/flutter/flutter/issues/170593, https://blog.flutter.dev/whats-new-in-flutter-3-32-40c1086bab6e
CONFIDENCE: high

REFUTE IT. Use WebSearch and WebFetch against PRIMARY sources: m3.material.io, developer.apple.com, api.flutter.dev, docs.flutter.dev, the actual type foundry, the actual paper.

Hunt for these failure modes, in order of likelihood:
1. **Marketing repeated as research.** Google's M3 Expressive claims (46 studies, 18,000 participants, "4x faster") and Lexend's readability claims are the specific hazards. Did anyone publish a methodology? Is it peer-reviewed, or is it a blog post? If a number has no methodology behind it, SAY SO — a design direction is being justified with it.
2. **Design folklore presented as evidence.** "Autistic people prefer muted colors", "sans-serif is more legible", "the aesthetic-usability effect", color psychology. Find the actual study, check the sample and whether it replicated, and check whether the popular claim matches what the paper found.
3. **Version/API rot.** Flutter lags the Material spec — a spec feature is NOT a Flutter feature. If the claim says Flutter can do something, VERIFY on api.flutter.dev or the release notes. Check whether a named API exists with that exact name.
4. **Invented specifics** — hex values, token names, type sizes, shape counts, font axes, license terms. If it's specific, verify it's real.
5. **License claims** about typefaces or assets. Verify against the actual foundry/repo.

Default to refuted=true if you cannot substantiate it. CONFIRMED if it checks out. PARTIALLY_TRUE + correction if directionally right but wrong in the specifics. UNVERIFIABLE if nothing settles it — say so plainly rather than guessing.
````

</details>

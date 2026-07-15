# flutter-design-capability--backdropfilter-is-the-most-expensive-thing-f

> Phase: **verify** · Agent `ace4e0b27dd81e1bd` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Accurate: BackdropFilter is "relatively expensive" per its own docs, and BackdropGroup + BackdropFilter.grouped + BackdropKey shipped in Flutter 3.29 exactly as named, optimizing the many-blurs case this app doesn't have.

Inaccurate and decision-relevant: (a) Both cited issues are CLOSED as completed — #126353 since 2023-05-22, #161297 since 2025-01-29. There are no "open performance regressions" as cited. (b) The "6-9ms at sigma:20 on mid-tier Android" figure and the "most expensive thing Flutter ships" superlative appear in none of the six claimed sources; both come from one Medium post with no device model, no Flutter version, and no methodology. Flutter's own benchmark infra publishes no comparable figure. (c) The claim skips the documented single-blur mitigation: BackdropFilter's docs explicitly direct single-widget blurs to ImageFiltered, where "performance will be improved dramatically for complex filters like blurs." (d) Apple's HIG does not support "text-over-blur is an a11y cost"; it says regular glass is legible by default and adapts to Reduce Transparency/Increase Contrast. The "backlash" is commentary, not primary guidance.

Defensible restatement: "Blur is expensive enough to justify avoiding in a latency-sensitive AAC app. Flutter's docs call it 'relatively expensive,' the 3.29 BackdropGroup work targets the many-blur case we don't have, and ImageFiltered — the documented single-blur alternative — is worth measuring before we commit either way. We have no measured cost on our target device; the 6-9ms figure circulating for this is an unsourced blog number and should not be cited. Legibility of text over blur is a real design risk to test with our users, not a settled a11y finding." Confidence should drop from high to low-moderate: the direction survives, the evidence base does not.

**Evidence:** CONFIRMED PARTS:
1. API existence — no version/API rot. BackdropGroup, BackdropFilter.grouped, and BackdropKey all exist with those exact names on api.flutter.dev. BackdropGroup docs: "To opt into using a shared BackdropGroup, the special BackdropFilter.grouped constructor must be used"; backdropKey is "The backdrop key this backdrop group will use with shared child layers."
2. Flutter 3.29 attribution is CORRECT. The Flutter blog post states verbatim: "Applications that display multiple backdrop filters can now use the new widget BackdropGroup and a new BackdropFilter.grouped constructor" and "These can improve performance of multiple blurs above and beyond what was possible on the Skia backend," under a "Backdrop filter optimizations" heading.
3. Mechanism/expense is directionally right. BackdropFilter docs: "This effect is relatively expensive, especially if the filter is non-local, such as a blur."
4. Both issue numbers resolve to real issues with substantially the stated titles (#126353 actual title carries an "[Impeller]" prefix the claim drops).

REFUTED PARTS (the ones carrying the decision):
1. "There are open performance regressions" — FALSE. GitHub API: #126353 state=closed, state_reason=completed, closed_at=2023-05-22T19:10:42Z (three years ago). #161297 state=closed, state_reason=completed, closed_at=2025-01-29T14:08:55Z (~18 months ago). Neither is open. This is load-bearing: "open regression" implies a live unfixed hazard. Additionally, #126353's own data (Skia 6ms avg / Impeller 16ms avg, iPhone 12) reports Impeller as SLOWER than Skia, which cuts against the claim's own "Impeller GPU-accelerates it" framing; and it is a multiple-blur ListView case — exactly the case BackdropGroup addresses, not the single-blur case the claim says the app has.
2. "6-9ms of raster alone for a single full-width BackdropFilter at sigma:20 on mid-tier Android" — appears in NONE of the six claimed sources. I checked each. It originates in a single Medium post (Mouaz M. Al-Shahmeh, "Flutter Performance Deep Dive"), which states "a mid-tier Android" with NO device model, NO Flutter version, and NO measurement methodology. The same post is the sole origin of "the most expensive widget Flutter ships" — an unfalsifiable editorial superlative, not a Flutter finding. The claim reproduces both while citing api.flutter.dev and GitHub, lending primary-source authority to a number that has none. This is marketing/blog repeated as research.
3. No primary benchmark corroborates the figure. Flutter engine's impeller/docs/benchmarks.md defines three blur benchmarks (Animated Blur Backdrop Filter, Animated Advanced Blend, Backdrop Filter Perf) on Pixel 7 Pro (Vulkan/OpenGLES) and iPhone 11 (Metal), but publishes only dashboard links — no headline ms values. There is no primary number to check 6-9ms against.
4. The "ban blur" conclusion is a non sequitur that omits the documented mitigation. The claim correctly notes BackdropGroup optimizes the many-blurs case the app lacks, then jumps to "no blur anywhere." But the BackdropFilter docs prescribe a remedy for exactly the single-blur case: using BackdropFilter to blur a single widget is inefficient; use ImageFiltered instead, and "the performance will be improved dramatically for complex filters like blurs." The claim never mentions ImageFiltered. The single-blur case was not ruled out; it was skipped.
5. The legibility half is folklore, and Apple's primary docs contradict it. The "iOS Liquid Glass legibility backlash" is press/social commentary, not Apple guidance. Apple HIG/Technology Overviews state regular glass is "designed to be legible by default," that small elements/symbols/glyphs "flip from light to dark, so the material is discernible," that "the amount of tint and the dynamic range shift to always ensure buttons remain legible," and that Liquid Glass adapts to Reduce Transparency, Increase Contrast, and Reduce Motion. Apple distinguishes regular glass (legible by default) from clear glass (requires care) — a distinction the claim collapses. No primary source establishes text-over-blur as a categorical a11y cost.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "flutter-design-capability" made this claim, and a design decision depends on it.

CLAIM: BackdropFilter is the most expensive thing Flutter ships and should be banned from this app on latency AND legibility grounds.
DETAIL: BackdropFilter composes a saveLayer plus an ImageFilter (Gaussian blur) sampling the backdrop. Reported cost: 6-9ms of raster alone for a single full-width BackdropFilter at sigma:20 on mid-tier Android. Impeller GPU-accelerates it but the cost remains significant, and there are open performance regressions (flutter/flutter#126353 'Blur BackdropFilter performance degradation', #161297 'iOS BackdropFilter Performance Issues with Impeller'). Flutter 3.29 added BackdropGroup + BackdropFilter.grouped + BackdropKey so multiple blurs share ONE backdrop pass — genuinely useful, but it optimizes the many-blurs case this app doesn't have. Combined with the cursor-blink finding and the a11y cost of text-over-blur (the iOS Liquid Glass legibility backlash), the verdict is: no blur anywhere.
CLAIMED SOURCES: https://api.flutter.dev/flutter/widgets/BackdropFilter-class.html, https://api.flutter.dev/flutter/widgets/BackdropGroup-class.html, https://api.flutter.dev/flutter/widgets/BackdropFilter/BackdropFilter.grouped.html, https://github.com/flutter/flutter/issues/126353, https://github.com/flutter/flutter/issues/161297, https://blog.flutter.dev/whats-new-in-flutter-3-29-f90c380c2317
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

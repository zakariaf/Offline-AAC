# flutter-design-capability--the-dynamicschemevariant-enum-has-exactly-9

> Phase: **verify** · Agent `a4080581aefffcd2c` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** The enumeration is correct and should be trusted: DynamicSchemeVariant has exactly 9 values with the descriptions as quoted, and it was added to ColorScheme.fromSeed by Hixie in PR #144805 (merged 2024-04-03), live on Flutter 3.44.0 as `dynamicSchemeVariant`, defaulting to tonalSpot.

The conclusion should not be trusted. Three fixes:

1. Six variants preserve the seed hue, not two. Only expressive, rainbow, and fruitSalad rotate hue away from the seed. tonalSpot, fidelity, monochrome, neutral, vibrant, and content all keep the hue and differ in chroma retention. The claim's dichotomy is wrong.

2. For a sensory-sensitivity brief, fidelity/content are the wrong recommendation — they are the HIGH-chroma-faithful variants, matching the seed "even if the seed color is very bright." tonalSpot (the default, "low chroma") or neutral ("a hint of chroma") are the muted-first choices. The claim recommends the brightest hue-faithful option on a brief about not being bright.

3. No variant guarantees the exact seed hex. content puts the seed in primaryContainer "adjusted to ensure contrast with surfaces." If exact hexes matter, use fromSeed's explicit primary/secondary/tertiary override parameters — that is the correct lever for 2-5 intentional hues, since fromSeed only accepts one seedColor and the variant enum cannot express a multi-hue palette at all.

Net: right about the enum, wrong about what to do with it. Do not let the verified 9-value list lend its credibility to the fidelity/content recommendation.

**Evidence:** FACTUAL CORE: FULLY CONFIRMED. I could not break it.

1. Count — CONFIRMED. api.flutter.dev/flutter/material/DynamicSchemeVariant.html lists exactly 9 values, and the master source (packages/flutter/lib/src/material/color_scheme.dart) independently confirms 9. No drift between the published docs and master as of Flutter 3.44.0. Order matches the claim exactly: tonalSpot, fidelity, monochrome, neutral, vibrant, expressive, content, rainbow, fruitSalad.

2. Descriptions — CONFIRMED VERBATIM. Every quoted description matches the doc text word-for-word, including the ones most likely to be paraphrased from memory. vibrant: "Pastel colors, high chroma palettes. The primary palette's chroma is at maximum." expressive: "Pastel colors, medium chroma palettes. The primary palette's hue is different from the seed color, for variety." The claim's note that rainbow and fruitSalad carry the SAME description ("A playful theme - the seed color's hue does not appear in the theme") is correct and is exactly the kind of oddity a fabricator would smooth over. The claim also correctly truncates rather than invents — content's full doc has a trailing sentence the claim omitted ("The tertiary palette is analogue of the seed color") but the claim included it. Nothing invented.

3. PR #144805 — CONFIRMED. Real PR, titled "Enhance ColorScheme.fromSeed with a new `variant` parameter", authored by Hixie, merged 2024-04-03. Attribution is correct.

4. API existence — CONFIRMED. fromSeed does take dynamicSchemeVariant, defaulting to tonalSpot. No version rot: this shipped and is live on current stable.

WHERE IT BREAKS — the analysis, not the facts:

A. "Only fidelity/content preserve your chosen hex" is FALSE, and it's the load-bearing sentence. Per the docs' own wording, hue rotation occurs in only THREE variants: expressive ("hue is different from the seed color"), rainbow and fruitSalad ("the seed color's hue does not appear"). The other six — tonalSpot, fidelity, monochrome, neutral, vibrant, content — all preserve the seed HUE and differ only in how much CHROMA they retain. So fidelity/content are not the only hue-faithful options; they are the only MAX-CHROMA-faithful options. Separately, NO variant reproduces the literal seed hex. content's own doc says primaryContainer is the seed color "adjusted to ensure contrast with surfaces" — explicitly not the exact hex. I confirmed the fromSeed doc makes no exact-hex guarantee for any variant.

B. The recommendation is backwards for the stated brief. The brief is sensory sensitivity / muted color. fidelity is defined as matching the seed "even if the seed color is very bright (high chroma)" — it is precisely the variant that REMOVES the chroma-damping safety net. It is fidelity to whatever you hand it, not a muting force. The muted-first variants are tonalSpot ("low chroma") and neutral ("close to grayscale, a hint of chroma"). The claim reasons its way to recommending the one hue-preserving variant that maximally preserves brightness, on a brief whose whole point is not being bright.

C. Category error in the framing. The claim says expressive "takes away the exact control a designer picking 2-5 intentional muted hues needs." But fromSeed takes ONE seedColor. If a designer has 2-5 intentional hues, the variant enum is the wrong lever entirely — fromSeed accepts explicit primary/secondary/tertiary/error overrides (confirmed in the parameter list), which bypass the variant algorithm for those roles regardless of which variant is set. The design decision here should hang on the override params, not on picking among 9 variants.

D. Minor: the parameter was named `variant` in PR #144805's title but shipped as `dynamicSchemeVariant`, and issue #148380 ("dynamicSchemeVariant is missing from ColorScheme.fromSeed") shows it landed incompletely in 3.22 before being cherry-picked to stable via #148916. Doesn't affect the claim, but the "added via PR #144805" story is tidier than the actual rollout.

No marketing-numbers hazard here (no 46-studies/18,000-participants/4x claims, no Lexend, no color-psychology folklore) — this claim stayed on verifiable API ground, which is why the facts survive. The failure is reasoning, not sourcing. Notably the confidence rating of "high" is warranted for the enumeration and unwarranted for the conclusion, and those were bundled together.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "flutter-design-capability" made this claim, and a design decision depends on it.

CLAIM: The DynamicSchemeVariant enum has exactly 9 values, and the two that 'sound relevant' (vibrant, expressive) are the two that actively fight this brief.
DETAIL: Verified from api.flutter.dev: tonalSpot ('Default for Material theme colors. Builds pastel palettes with a low chroma'), fidelity ('The resulting color palettes match seed color, even if the seed color is very bright (high chroma)'), monochrome ('All colors are grayscale, no chroma'), neutral ('Close to grayscale, a hint of chroma'), vibrant ('Pastel colors, high chroma palettes. The primary palette's chroma is at maximum'), expressive ('Pastel colors, medium chroma palettes. The primary palette's hue is DIFFERENT from the seed color, for variety'), content ('Almost identical to fidelity. Tokens and palettes match the seed color'), rainbow ('A playful theme - the seed color's hue does not appear in the theme'), fruitSalad (same description). Analysis: `vibrant` maxes primary chroma — directly violates the sensory-sensitivity constraint. `expressive` ROTATES the primary hue away from your seed — i.e. it takes away the exact control a designer picking 2-5 intentional muted hues needs. `rainbow`/`fruitSalad` are self-evidently out. Only `fidelity`/`content` preserve your chosen hex. Added to fromSeed via Hixie's PR #144805.
CLAIMED SOURCES: https://api.flutter.dev/flutter/material/DynamicSchemeVariant.html, https://github.com/flutter/flutter/pull/144805, https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html
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

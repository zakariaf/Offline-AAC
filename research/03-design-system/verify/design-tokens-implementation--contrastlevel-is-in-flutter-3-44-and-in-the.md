# design-tokens-implementation--contrastlevel-is-in-flutter-3-44-and-in-the

> Phase: **verify** · Agent `ab5797ce41a95671e` · Run `wf_f237e8a6-694`

## Result

## Verdict

**CONFIRMED**

**Correction:** No correction required to any load-bearing element. Two optional precision notes: (1) ColorScheme.highContrastLight/.highContrastDark are const generative constructors rather than factories, and they are hardcoded legacy (M2-era) palettes that are NOT seed-derived — they do not compose with fromSeed, so anyone later reaching for them expecting a seeded high-contrast scheme will get a fixed blue-based palette instead. The claim merely lists them as available and does not rely on them. (2) The architecture decision itself is a design judgment, not a factual claim, and was not (and cannot be) fact-checked — only its factual premises were, and those hold.

**Evidence:** Attempted refutation on all five failure modes; the claim survived every check. Independently reproduced rather than trusted.

API EXISTENCE (primary source, api.flutter.dev): ColorScheme.fromSeed carries `double contrastLevel = 0.0` in its published signature. Doc text verbatim: "The `contrastLevel` parameter indicates the contrast level between color pairs, such as `primary` and `onPrimary`. 0.0 is the default (normal); -1.0 is the lowest; 1.0 is the highest. From Material Design guideline, the medium and high contrast correspond to 0.5 and 1.0 respectively." Range, default, and the 0.5/1.0 medium/high mapping are all exact — not approximated or invented.

INSTALLED SDK: `flutter --version` confirms 3.41.2 (Dart 3.11.0, revision 90673a4eef), matching the claim. In packages/flutter/lib/src/material/color_scheme.dart: `double contrastLevel = 0.0` at line 313 (fromSeed) and 1926; runtime assert at 2181: `contrastLevel >= -1.0 && contrastLevel <= 1.0, 'contrastLevel must be between -1.0 and 1.0 inclusive.'` ColorScheme.highContrastLight at :752 and ColorScheme.highContrastDark at :887 both exist.

COMPILE CLAIM REPRODUCED: built a throwaway package against the real 3.41.2 toolchain calling `ColorScheme.fromSeed(seedColor: Colors.teal, contrastLevel: 1.0)`, `const ColorScheme.highContrastLight()`, `const ColorScheme.highContrastDark()`. `flutter analyze` → "No issues found!" The "VERIFIED by compilation" assertion is truthful.

SOURCE CITATION: github.com/flutter/flutter/issues/149683 is real and correctly cited — "Support `contrastLevel` in `ColorScheme.fromSeed`", closed via PR #149779. No version rot: feature is long-landed, present in 3.41.2, undeprecated, and reflected in current-stable (3.44) docs.

TWO NON-LOAD-BEARING FOOTNOTES: (1) highContrastLight/highContrastDark are const generative constructors, not "factories," and more substantively are hardcoded legacy palettes that do NOT compose with fromSeed — the claim only lists them as available and builds nothing on them, so the decision is unaffected. (2) The doc's own scoping of contrastLevel to "color pairs" within the tonal palette actively corroborates the rationale that it cannot express hue-dropping, 3dp borders, or pure #000/#FFF.

SCOPE NOTE: the architecture decision ("3 discrete themes, not 2 × contrast modifier"; the 2D-switcher argument) is design judgment, not a falsifiable factual claim — outside what a fact-check can settle. Flagged so it is not mistaken for something verified. Its factual premises hold and the reasoning is internally consistent: passing contrastLevel: 1.0 inside the HC theme to fix un-overridden roles is compatible with the API's documented behavior.

No marketing-as-research, no design folklore, no invented specifics, no license claims. Stated confidence of "high" is calibrated.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "design-tokens-implementation" made this claim, and a design decision depends on it.

CLAIM: `contrastLevel` IS in Flutter 3.44 (and in the installed 3.41.2 — I compiled against it). But high-contrast should still be a discrete third theme, not `contrastLevel: 1.0` on the other two.
DETAIL: VERIFIED by compilation on Flutter 3.41.2: `ColorScheme.fromSeed(seedColor: x, contrastLevel: 1.0)` analyzes clean. Range -1.0..1.0, default 0.0; Material's medium/high contrast correspond to 0.5 and 1.0. Also available: `ColorScheme.highContrastLight()` / `.highContrastDark()` factories. ARCHITECTURE DECISION — 3 discrete themes, not 2 × contrast modifier. Rationale: contrastLevel only stretches the tonal palette. It cannot express the actual high-contrast design decisions this app needs: drop category hues entirely (they collapse to a single black face, findability degrading to position — which the fixed grid already guarantees), swap the 1dp hairline border for a 3dp load-bearing one, go to pure #000/#FFF. Those are design choices, not a math parameter. A '2 themes × contrast level' matrix would also make the one-tap switcher a 2D control, which is wrong for a user in a shutdown with reduced decision-making — one tap must cycle a flat list of 3. I still PASS contrastLevel: 1.0 inside the HC theme, because it correctly fixes the ~25 roles I don't override. Both/and, not either/or.
CLAIMED SOURCES: https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html, https://github.com/flutter/flutter/issues/149683
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

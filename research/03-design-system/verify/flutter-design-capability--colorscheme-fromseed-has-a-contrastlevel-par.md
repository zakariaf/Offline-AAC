# flutter-design-capability--colorscheme-fromseed-has-a-contrastlevel-par

> Phase: **verify** · Agent `abc115110fbd4def8` · Run `wf_f237e8a6-694`

## Result

## Verdict

**CONFIRMED**

**Correction:** No correction needed to the claim as stated. One non-contradicting addition that reinforces it: contrastLevel: 1.0 is now the documented replacement for the deprecated ColorScheme.highContrastLight / ColorScheme.highContrastDark constructors under Material 3. This makes contrastLevel the correct modern API for the ColorScheme layer — which sharpens rather than softens the caveat, since teams migrating off highContrastLight/Dark may assume they have swapped in a complete high-contrast theme when in fact only the ColorScheme roles migrated and every ThemeExtension token still needs a hand-authored high-contrast set.

**Evidence:** Attempted refutation on all five failure modes; none landed.

1. API ROT — CHECKED, CLEAN. api.flutter.dev shows the fromSeed signature exactly as claimed: factory ColorScheme.fromSeed({required Color seedColor, Brightness brightness = Brightness.light, DynamicSchemeVariant dynamicSchemeVariant = DynamicSchemeVariant.tonalSpot, double contrastLevel = 0.0, ...}). contrastLevel exists under that exact name, with that exact default. Not deprecated — the only deprecated params on this constructor are background, onBackground, surfaceVariant (all "deprecated after v3.18.0-0.1.pre"), none of which the claim relies on.

2. INVENTED SPECIFICS — CHECKED, CLEAN. Every optional override named in the DETAIL is real, including the easily-fabricated fixed family: primary, onPrimary, primaryContainer, primaryFixed, primaryFixedDim, onPrimaryFixed, onPrimaryFixedVariant, plus full secondary/tertiary/error/surface/outline families (surfaceDim, surfaceBright, surfaceContainerLowest/Low/Container/High/Highest, outlineVariant, inverseSurface, inversePrimary, shadow, scrim, surfaceTint). No hallucinated parameter names found.

3. DOCS QUOTE — VERBATIM MATCH. Source doc comment reads: "The contrastLevel parameter indicates the contrast level between color pairs, such as [primary] and [onPrimary]. 0.0 is the default (normal); -1.0 is the lowest; 1.0 is the highest. From Material Design guideline, the medium and high contrast correspond to 0.5 and 1.0 respectively." The claim's quote is accurate, not paraphrased.

4. THE LOAD-BEARING CAVEAT — INDEPENDENTLY CONFIRMED AT SOURCE LEVEL. This is the part a design decision hangs on, so I verified the mechanism rather than the prose. In color_scheme.dart, contrastLevel is passed to _buildDynamicScheme(brightness, seedColor, dynamicSchemeVariant, contrastLevel), which constructs a material_color_utilities DynamicScheme (e.g. SchemeTonalSpot(sourceColorHct:, isDark:, contrastLevel:)). Role values are then read via MaterialDynamicColors.*.getArgb(scheme) and assigned to ColorScheme fields. That is the complete blast radius: contrastLevel influences tonal palette generation and emits nothing but ColorScheme fields. ThemeExtension is an unrelated generic interface whose subclasses need only implement copyWith() and lerp(); it has no hook into seed/contrast generation and no automatic tonal regeneration. A hand-authored ThemeExtension holding tile colors is therefore genuinely untouched by contrastLevel. The researcher's "do not let this parameter create false confidence" warning is correct, not overcautious.

5. MARKETING/FOLKLORE — NOT APPLICABLE. The claim cites no study, participant count, or efficacy statistic. It makes a pure API-behavior claim sourced to primary docs, and correctly scopes what the API does NOT do. Nothing here is a design-research number needing methodology.

Verified against Flutter master source, consistent with stable 3.44.0. Claimed source (api.flutter.dev fromSeed page) is primary and supports the claim.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "flutter-design-capability" made this claim, and a design decision depends on it.

CLAIM: ColorScheme.fromSeed has a contrastLevel parameter that gets you most of a high-contrast theme in one line — but it only touches ColorScheme roles, not your ThemeExtension tokens.
DETAIL: Verified signature: ColorScheme.fromSeed({required Color seedColor, Brightness brightness = Brightness.light, DynamicSchemeVariant dynamicSchemeVariant = DynamicSchemeVariant.tonalSpot, double contrastLevel = 0.0, ...plus optional overrides for every color role including primary/onPrimary/primaryContainer/primaryFixed/primaryFixedDim/onPrimaryFixed/onPrimaryFixedVariant and the secondary/tertiary/error/surface/outline families}). Docs quote: '0.0 is the default (normal); -1.0 is the lowest; 1.0 is the highest. From Material Design guideline, the medium and high contrast correspond to 0.5 and 1.0 respectively.' LOAD-BEARING CAVEAT: contrastLevel regenerates the ColorScheme's tonal roles. If (as recommended) your tile colors live in a hand-authored ThemeExtension, contrastLevel does nothing to them. You must author the high-contrast token set yourself. Do not let this parameter create false confidence.
CLAIMED SOURCES: https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html
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

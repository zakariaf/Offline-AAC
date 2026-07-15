# design-tokens-implementation--colorscheme-fromseed-accepts-per-role-overri

> Phase: **verify** · Agent `a13a3d1fec9ca12db` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Keep the approach; fix the specifics. (1) The seed generates 38 remaining roles, not ~25 — there are 46 non-deprecated optional Color params on fromSeed. (2) Drop the error-pairing contrast figures as "proof" — they have no stated seed, variant, contrastLevel, or tool, and because M3's error palette is near fixed-hue they would read roughly the same for almost any seed. They are not evidence that this seed choice pays off. The 18.43:1 figure additionally requires contrastLevel: 1.0, not the default 0.0. (3) Add the caveat the docs omit: overrides are applied post-hoc and do not propagate. Overriding primary does not regenerate onPrimary or primaryContainer. Hand-authoring 8 roles means you own every contrast seam between them and the 38 generated roles you did not touch — measure those pairings explicitly. If you need overrides that actually reseed the tonal palettes rather than patch outputs, that is what flex_seed_scheme does; fromSeed cannot.

**Evidence:** CORE CLAIM CONFIRMED AGAINST PRIMARY SOURCE. api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html returns the exact signature claimed: factory ColorScheme.fromSeed({required Color seedColor, Brightness brightness = Brightness.light, DynamicSchemeVariant dynamicSchemeVariant = DynamicSchemeVariant.tonalSpot, double contrastLevel = 0.0, Color? primary, Color? onPrimary, ... Color? surfaceTint, @Deprecated Color? background, @Deprecated Color? onBackground, @Deprecated Color? surfaceVariant}). The quoted doc sentence is verbatim: "If any of the optional color parameters are non-null they will be used in place of the generated colors for that field in the resulting color scheme." No API rot; no invented API. Deprecation claim confirmed: background, onBackground, surfaceVariant deprecated after v3.18.0-0.1.pre (replacements: surface, onSurface, surfaceContainerHighest). "All 5 surfaceContainer tones" confirmed (Lowest, Low, base, High, Highest).

DEFECT 1 - INVENTED/WRONG COUNT. Claim says seed generates "the ~25 you will never look at". Actual count from the fetched signature: 46 non-deprecated optional Color params (8 primary-family, 8 secondary-family, 8 tertiary-family, 4 error-family, 2 outline, 2 surface, 7 surface tonal/container, onSurfaceVariant, 3 inverse/inversePrimary, shadow, scrim, surfaceTint). Hand-authoring 8 leaves 38 generated, not ~25.

DEFECT 2 - UNSUBSTANTIATED NUMBERS PRESENTED AS PROOF. The "PROOF THIS PAYS" figures (6.46:1 light, 7.72:1 dark, 18.43:1 HC) have no stated seed color, no dynamicSchemeVariant, no contrastLevel, and no measurement tool. They are self-reported and not reproducible from any primary source. They also do not support the inference drawn from them: M3's error palette is essentially fixed-hue and near-invariant across seeds, so these ratios are a property of the M3 algorithm rather than evidence about this particular seed/design. The 18.43:1 "HC" figure silently implies contrastLevel: 1.0, which is a different constructor call than the one the claim advertises.

DEFECT 3 - MATERIAL OMISSION. Overrides are applied post-hoc and do NOT propagate. Overriding primary does not regenerate onPrimary or primaryContainer against it. ColorScheme class docs state the design expectation that "the 'on' colors should have a contrast ratio with their matching colors of at least 4.5:1 in order to be readable" but issue NO warning that manual overrides can break this. Hand-authoring 8 roles therefore means owning contrast both among those 8 and across every seam with the 38 generated neighbors (e.g. hand-authored surface vs generated onSurfaceVariant; hand-authored outline vs generated surfaceContainerHigh). This is the documented motivation for rydmike/flex_seed_scheme, which reseeds tonal palettes from separate key colors rather than patching generated outputs.

NET: The design decision the researcher wants to make is sound. "Seed vs hand-authored" is genuinely a false binary and it is genuinely one constructor call. The API claim is fully verified. What fails is the supporting arithmetic, the evidentiary status of the contrast figures, and the unstated non-propagation caveat.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "design-tokens-implementation" made this claim, and a design decision depends on it.

CLAIM: `ColorScheme.fromSeed` accepts per-role overrides — so 'seed vs hand-authored' is a false binary. Seed AND override is the right answer and it is one constructor call.
DETAIL: VERIFIED signature: `ColorScheme.fromSeed({required Color seedColor, Brightness brightness = Brightness.light, DynamicSchemeVariant dynamicSchemeVariant = DynamicSchemeVariant.tonalSpot, double contrastLevel = 0.0, Color? primary, Color? onPrimary, Color? primaryContainer, ..., Color? surface, Color? onSurface, Color? outline, ...})`. Docs: 'If any of the optional color parameters are non-null they will be used in place of the generated colors for that field.' So: hand-author the ~8 roles that carry the design (primary, onPrimary, primaryContainer, onPrimaryContainer, secondary, surface, onSurface, outline), let the seed generate the ~25 you will never look at (error, inverseSurface, scrim, surfaceTint, all 5 surfaceContainer tones). PROOF THIS PAYS: the seed-generated error pairings measured 6.46:1 (light), 7.72:1 (dark), 18.43:1 (HC) — passing AA with zero design effort. You get M3 tonal correctness for free on the boring roles and exact control where the design lives. Deprecated params to avoid: `background`, `onBackground`, `surfaceVariant`.
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

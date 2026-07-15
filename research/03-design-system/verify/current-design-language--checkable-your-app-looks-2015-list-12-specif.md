# current-design-language--checkable-your-app-looks-2015-list-12-specif

> Phase: **verify** · Agent `a0a0121e5e95cc283` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Recast as "a taste checklist, unsourced" and fix four specifics: (1) M2 cards default to 4dp corner RADIUS (1dp is default elevation) — the tell is real but the stated reason is inverted; drop the "1–2dp radius" premise. (2) Reverse tell #2: surface tint / tonal elevation is the DEPRECATED pattern — api.flutter.dev says surfaceTintColor is "not recommended for use" and "the intention is to eventually remove surface tint color from the framework"; M3 now uses tone-based surface containers (surfaceContainerLow/High) AND shadows. An elevation number with a shadow is current M3, not 2015. The 2015 tell is a grey UMBRA on a PURE-GREY surface, not the existence of a shadow. (3) #141218 is a Neutral tone (N10), not a neutral-variant tone; Neutral is chroma 4, Neutral Variant chroma 8 and maps to outline/surfaceVariant. (4) Strike both citations: the uxdesign.cc post is a Medium opinion piece containing no such list, and pub.dev material_design is a third-party package with no spec authority. If M3E is invoked at all, label Google's "4x faster / 46 studies / 18,000 participants" as unpublished in-house marketing with no methodology, no dataset, and no peer review. Keep tell #6 (the M2 500-series hexes) — it verifies.

**Evidence:** The list is defensible TASTE marketed as a "CHECKABLE" sourced finding. Neither cited source supports it, and three of the four load-bearing technical specifics are wrong.

SOURCES DO NOT SUPPORT THE CLAIM.
1. The uxdesign.cc article exists (Benjamin C.J. W, UX Collective) but is a Medium opinion post, not primary, and contains NO 12-item "looks 2015" list. It relays Google's M3 Expressive marketing.
2. pub.dev material_design/M3Corners exists (v0.28.1, 11 constants 0–48dp + full=9999dp) but is a THIRD-PARTY pub package — not Google, not the Flutter SDK, not a spec. Citing it as authority for M3 shape is citing a stranger's Dart constants.
3. The number the article carries ("four times faster") traces to design.google's M3E research page: "46 separate research studies... more than 18,000 participants," "87%," "four times faster," "32% increase in subculture perception." That page links NO paper, NO dataset, NO methodology, and is not peer-reviewed. This is exactly the marketing-as-research hazard. A design direction is being justified with an unfalsifiable in-house number.

TELL #1 IS SELF-REFUTING. "M2 cards rested at 1–2dp radius" is FALSE. The M2 shape spec sets Medium components (cards) at 4dp corner radius. 1dp is the M2 card default ELEVATION — the author conflated elevation with radius, then declared "a 4dp radius... is THE tell." 4dp IS the M2 card default radius, so the stated premise contradicts the conclusion.

TELL #2 IS BACKWARDS ON CURRENT API (version rot). "M3 replaced shadow-elevation with TONAL elevation" was the 2021 position. Current api.flutter.dev (Card.surfaceTintColor) states: "This is not recommended for use. Material 3 spec introduced a set of tone-based surfaces and surface containers in its ColorScheme, which provide more flexibility" and "The intention is to eventually remove surface tint color from the framework." Default surfaceTintColor is now transparent, and shadows were re-defaulted ON in M3 mode. So "if your Card has an elevation number and a grey shadow, it's 2015" is false — elevation plus shadow is current M3 Flutter behavior. Surface tint is the deprecated thing, not the shadow.

TELL #8 MIS-ATTRIBUTES THE PALETTE. #141218 is plausibly the M3 baseline dark surface, but it is a NEUTRAL palette tone (surface = N10 dark / N99 light), NOT a "neutral-VARIANT tone." Neutral Variant (chroma 8) maps to outline/surfaceVariant/outlineVariant; Neutral is chroma 4. The directional point survives — M3 neutrals carry chroma ~4 and are hue-tinted, not pure grey — but the named mechanism is wrong.

WHAT CHECKS OUT: Tell #6 is correct. #2196F3, #4CAF50, #F44336 are genuinely M2 Blue 500, Green 500, Red 500.

UNVERIFIABLE AESTHETIC ASSERTION (8 of 12): Tells #3, #4, #5, #7, #9, #10, #11, #12 have no measurable referent and no primary source. "2026 defaults to 500–700" is asserted with zero sourcing. "Corporate Memphis peaked 2019–21, now actively derided" is taste stated as fact. These may be good judgment, but they are not checkable and must not be cited as evidence.

BOTTOM LINE: usable as a style opinion; not usable as a sourced finding. The word "CHECKABLE" is the part that fails. Confidence should drop from medium to low.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "current-design-language" made this claim, and a design decision depends on it.

CLAIM: CHECKABLE 'your app looks 2015' list — 12 specific tells
DETAIL: (1) Circular-arc corners at 2–8dp on large elements — M2 cards rested at 1–2dp radius; a 4dp radius on a 100dp tile is THE tell. (2) Drop shadows as elevation: `elevation: 1/4/6/8` with hard grey umbra — M3 replaced shadow-elevation with TONAL elevation (seed-tinted surface containers); if your Card has an elevation number and a grey shadow, it's 2015. (3) The M2 triad: FAB + hamburger + 4dp AppBar shadow. (4) Thin type: weight 300 at large sizes, centered — Roboto Light / iOS 7 Helvetica Neue UltraLight hangover. 2026 defaults to 500–700. (5) Compressed type-size scale — everything 14/16/18/20, within 1.4x. (6) The literal M2 palette hexes: #2196F3 blue500, #4CAF50 green500, #F44336 red500 — these are a fingerprint; using them is like leaving the Bootstrap #007BFF in. (7) Flat 1.0: pure #FFFFFF cards on #F5F5F5, separated by 1px #E0E0E0 dividers — dividers themselves are a tell; 2026 separates with SPACE and tonal surface steps. (8) PURE neutrals: #FFFFFF/#808080/#000000 with zero hue. 2026 neutrals are hue-tinted — M3's own dark surface #141218 is a neutral-VARIANT tone carrying the seed's hue, not grey. (9) Long shadows / skeuomorphic bevels (2013–14, dead). (10) Corporate Memphis / 'Alegria' flat illustration — disproportionate limbs, faceless figures; peaked 2019–21, now actively derided (banned here regardless). (11) 2014-style gradients: linear, 2-stop, top-to-bottom, high-chroma, lightness-shifted, visible banding. (12) Uniform density: identical padding everywhere, no rhythm, everything obedient to one 8dp grid.
CLAIMED SOURCES: https://uxdesign.cc/material-3-expressive-building-on-the-failures-of-flat-design-d7a9bb627298, https://pub.dev/documentation/material_design/latest/material_design/M3Corners-class.html
CONFIDENCE: medium

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

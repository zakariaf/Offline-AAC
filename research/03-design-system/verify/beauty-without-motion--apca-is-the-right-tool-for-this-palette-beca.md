# beauty-without-motion--apca-is-the-right-tool-for-this-palette-beca

> Phase: **verify** · Agent `ab492a4e541181814` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** APCA is a luminance-only model — it converts sRGB to achromatic luminance (Y) and discards hue/saturation entirely, per its own docs ("Color contrast, meaning hue/saturation, does not play a major role in readability"). It is not "perceptually uniform across muted/desaturated colors"; it is blind to saturation. WCAG 2.x is chroma-blind in exactly the same way, so it cannot "misbehave on muted colors" in any way APCA corrects. The failure modes APCA actually documents for WCAG 2.x are DARK colors near black ("4.5:1 can be functionally unreadable"; unusable for dark mode) and SPATIAL FREQUENCY (font size/weight, which WCAG 2.x ignores). Since this palette is described as muted hues at HIGH luminance contrast, it sits in the regime where APCA and WCAG 2.x most closely agree — APCA's real value is at low luminance/dark mode and in accounting for type size/weight. Additionally, Lc values are polarity-signed and NOT interchangeable (Lc 60 = darker text on lighter bg; Lc -60 = lighter text on darker bg, with different font lookup tables), so "regardless of how light or dark the two colors are" is wrong as stated. The thresholds are correct as given (Lc 75 @ 18px/400 body, Lc 60 non-body, range Lc 0 to ±106). The compliance caveat is correct and should be stronger: APCA was exploratory-only in WCAG 3 and was removed from the draft in July 2023; it is not in the normative WCAG 3.0 draft, which is itself a Working Draft with a Recommendation no earlier than 2028, while WCAG 2.2 AA is the operative legal benchmark. KEEP the practice (WCAG 2.x AA as floor, APCA to discriminate among passing pairs) but REPLACE the justification: use APCA because it accounts for font size and weight and for dark-end luminance behavior — not because of anything to do with muted or desaturated color.

**Evidence:** The numbers check out. The REASON does not — and the reason is what the design decision rests on.

WHAT SURVIVES:
1. "Lc 75 is the floor for body text at 18px/400" — CONFIRMED, near-verbatim. APCAeasyIntro: "Lc 75 - The minimum level for columns of body text with a font no smaller than 18px/400."
2. "Lc 60 is the floor for non-body text you actually want read" — CONFIRMED. Nutshell sets Lc 60 as minimum for content text that is not body/column/block text.
3. "Lc 0 to ±106" — CONFIRMED as written. APCAeasyIntro: "APCA reports contrast as an Lc value (lightness contrast) from Lc 0 to ±Lc 106." (Minor: apcacontrast.com gives the asymmetric 106 / -108. Not load-bearing.)
4. The compliance caveat — CONFIRMED and STRONGER than stated. This is the most defensible part of the claim.

WHAT IS REFUTED — the stated rationale:

(a) APCA DOES NOT MODEL SATURATION AT ALL. It is a luminance-only model: sRGB is collapsed to achromatic luminance Y via sRGBtoY() before any contrast math happens. Chroma is discarded, by design. APCAeasyIntro states outright: "Color contrast, meaning hue/saturation, does not play a major role in readability." So "APCA is perceptually uniform across muted/desaturated colors" attributes to APCA a saturation-handling property that APCA does not implement. It is not uniform across saturation — it is BLIND to saturation.

(b) THE WCAG-2 FAILURE MODE IS MISIDENTIFIED. WCAG 2.x is ALSO luminance-only (a relative-luminance ratio). Both models ignore saturation in identical fashion. There is therefore no mechanism by which WCAG 2.x could "misbehave on muted colors" in a way APCA fixes — the two are equally chroma-blind. WhyAPCA never lists muted/desaturated colors as a failure mode. The failures it actually documents are: DARK colors ("4.5:1 can be functionally unreadable when one of the colors in a pair is near black"; "WCAG 2.x contrast cannot be used for guidance designing 'dark mode'"), SPATIAL FREQUENCY (font size/weight, which WCAG 2.x ignores entirely), and binary pass/fail. The claim swapped "dark" for "muted."

(c) THE BRIEF INVOKES APCA IN ITS WEAKEST REGIME. The claim says the palette is "muted hues at HIGH luminance contrast." APCA's divergence from WCAG 2.x is concentrated at LOW luminance / near-black / dark mode. At high luminance contrast on light backgrounds the two models broadly agree. So APCA is being recruited for (i) a property it doesn't have (chroma sensitivity) in (ii) the exact regime where it adds least differentiation. "APCA will correctly tell you which muted pairs are genuinely readable and WCAG will not" is unsupported by any primary source — neither model reads saturation.

(d) POLARITY OVERSTATED. "An Lc value represents the same perceived readability contrast regardless of how light or dark the two colors are" drops the sign. Polarity is NOT interchangeable: APCAeasyIntro — "A negative Lc value, such as Lc -60 means the text is lighter than the background. A positive value Lc 60 means the text is darker than the background." Lc 60 and Lc -60 are distinct conditions with distinct font lookup tables. The ± is a polarity sign, not an absolute-value convenience. Also, the docs' uniformity language ("a contrast value of Lc 60 represents the same perceived readability contrast," "halving or doubling the APCA value relates to halving or doubling the perceived contrast") is a stated design goal within a polarity, not a demonstrated invariance across the whole color space — no peer-reviewed validation was located.

(e) THE CAVEAT UNDERSTATES ITS OWN CASE. "APCA is not the legal standard" is true but soft. As of 2026: WCAG 2.2 AA is the operative benchmark (ADA case law, EN 301 549 / European Accessibility Act reference WCAG 2.1). WCAG 3.0 remains a Working Draft with a Recommendation no earlier than 2028. APCA was only ever EXPLORATORY in WCAG 3 and was removed from the draft in the W3C's July 2023 update; it is not in the normative WCAG 3.0 draft today. APCA also carries its own licensing terms (APCA-W3 repo) rather than being unencumbered.

BOTTOM LINE: right conclusion, wrong reason. "Ship WCAG 2.x AA as the floor, use APCA to choose among passing palettes" is sound practice and I'd keep it. But it cannot be justified by "muted colors" — that rationale is fabricated, and it happens to point at the one regime where APCA buys the least. If the palette genuinely is muted hues at high luminance contrast, APCA will mostly rank-order the same pairs WCAG does, and the decision it drives will be near-arbitrary. If the real concern is muted colors being hard to read, NEITHER tool addresses it — that requires reasoning about luminance separation directly, plus font size/weight, which is the thing APCA actually adds over WCAG 2.x and which this brief never mentions.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "beauty-without-motion" made this claim, and a design decision depends on it.

CLAIM: APCA is the right tool for this palette because it is perceptually uniform across muted/desaturated colors, where WCAG 2.x ratios are known to misbehave.
DETAIL: APCA reports Lc 0 to ±106. Lc 75 is the floor for body text at 18px/400. Lc 60 is the floor for non-body text you actually want read. The key property: an Lc value represents the same perceived readability contrast regardless of how light or dark the two colors are — which is exactly the property WCAG 2.x lacks and exactly the property this brief needs, since the whole palette is muted hues at high luminance contrast. Caveat, load-bearing: APCA is not the legal standard. It is a design tool. Ship WCAG 2.x AA/AAA as the compliance floor and use APCA to choose among the many palettes that pass, because APCA will correctly tell you which muted pairs are genuinely readable and WCAG will not.
CLAIMED SOURCES: https://git.apcacontrast.com/documentation/APCA_in_a_Nutshell.html, https://git.apcacontrast.com/documentation/WhyAPCA, https://apcacontrast.com/
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

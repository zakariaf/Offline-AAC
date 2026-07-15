# beauty-without-motion--variable-font-axes-worth-caring-about-here-a

> Phase: **verify** · Agent `a261a13fc7dc373db` · Run `wf_f237e8a6-694`

## Result

## Verdict

**CONFIRMED**

**Correction:** No correction to the claim's substance. Two additions recommended for precision: (1) GRAD is a foundry-defined/Google-registry axis, not an OpenType-registered one (the OpenType 1.9.1 registry contains only ital, opsz, slnt, wdth, wght), so GRAD availability is font-by-font with no platform guarantee. (2) Atkinson Hyperlegible Next is confirmed wght-only (200-800) per shipped file, with ital as a separate axis in the source design space -- so the manual per-size-bracket tracking fallback is the actual plan of record, and no GRAD-dependent design should be pursued with this typeface.

**Evidence:** Attempted refutation on all five failure modes; the claim survives. (1) GRAD's no-reflow property is confirmed verbatim from the Google Fonts axis registry primary source (Lib/axisregistry/data/grade.textproto), which defines GRAD as: "Finesse the style from lighter to bolder in typographic color, without any changes overall width, line breaks or page layout." Default 0, range -1000..1000, units matching wght, based on the Type Network OpenType 1.8 Axis Proposal. The claim's core design argument -- that GRAD darkens type for a high-contrast theme without relaying out a fixed-position grid -- is precisely the axis's specified purpose. (2) opsz behavior is confirmed from the OpenType spec (dvaraxistag_opsz): optical size adaptations involve "adapting glyph proportions, stem weights, and details to be appropriate to specific sizes of displayed text... ensuring legibility at smaller sizes and refinement of fine details and overall width at larger sizes." This matches the claim's "thicker/wider small text, finer large headlines." Scale is text size in typographic points; recommended Regular value 10-16. (3) The claim's explicitly flagged load-bearing uncertainty resolves in the direction it predicted: Atkinson Hyperlegible Next's design space is wght 200-800 plus ital (0/1), per METADATA.pb in google/fonts and sources/config.yaml in googlefonts/atkinson-hyperlegible-next. No GRAD. No opsz. On Google Fonts it ships as two variable files (Roman, Italic), so per-file it is genuinely wght-only. The "fake optical sizing by hand with per-size-bracket tracking" fallback is therefore the operative path, not the contingency. (4) No invented specifics found -- every named axis tag is real and every described behavior matches spec. (5) No marketing-as-research, design folklore, or Flutter API rot present; the claim makes no Flutter or license assertions. Two caveats worth appending rather than refutations: (a) GRAD is NOT an OpenType-registered axis -- the Microsoft OpenType 1.9.1 registry lists exactly five (ital, opsz, slnt, wdth, wght). GRAD is a foundry-defined tag (all-caps, per the spec's reservation of uppercase-only tags for custom axes) documented only in Google's own registry, so it carries no platform-level guarantees and exists only where a foundry cut it. This strengthens rather than undermines the claim's "(if present)" hedge, but "worth caring about" should not be read as implying portability. (b) On Flutter reachability: dart:ui FontVariation exists and has named constructors for weight/width/slant/opticalSize/italic but none for grade; the unnamed constructor FontVariation(String axis, double value) accepts arbitrary tags, so FontVariation('GRAD', 100) works if a font ever exposes it. The claim is better calibrated than its stated medium confidence -- it flagged its own uncertainty and that uncertainty resolved as predicted.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "beauty-without-motion" made this claim, and a design decision depends on it.

CLAIM: Variable-font axes worth caring about here are wght and (if present) GRAD; opsz is a nice-to-have you will likely have to fake by hand.
DETAIL: opsz auto-adjusts design by display size — thicker/wider small text, finer large headlines — mimicking print's optical sizing. GRAD increases apparent weight/darkness WITHOUT changing character width, so it does not reflow text — which is why it is the correct axis for compensating stroke weight in high-contrast or small-text conditions. In a fixed-position grid where reflow is banned outright, GRAD's no-width-change property is unusually valuable: it lets you darken type for the high-contrast theme without a single tile relaying out. Load-bearing uncertainty: I did not verify which axes Atkinson Hyperlegible Next's variable version actually exposes — it is likely wght-only. Verify before designing around GRAD/opsz. If only wght exists, fake optical sizing manually with per-size-bracket tracking (see design moves).
CLAIMED SOURCES: https://fonts.google.com/knowledge/glossary/grade_axis, https://ultimatedesigntools.com/blog/how-to-use-variable-fonts-css/, https://allbestfonts.com/articles/variable-fonts-guide
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

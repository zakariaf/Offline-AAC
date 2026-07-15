# typography-system--atkinson-hyperlegible-next-shipped-nov-2024

> Phase: **verify** · Agent `ac9806839485a01e8` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Atkinson Hyperlegible Next v2.001 (Nov 20 2024, announced Feb 10 2025, SIL OFL 1.1) has exactly ONE variable axis: wght 200–800. There is no `ital` axis, no opsz, and no GRAD. Italic ships as a SEPARATE variable font file (AtkinsonHyperlegibleNext-Italic[wght].ttf), also wght-only — so italic cannot be interpolated or animated, and requires registering a second font asset (in Flutter: a `style: italic` entry, NOT FontVariation('ital', 1), which would no-op). 7 weights ExtraLight(200)–ExtraBold(800) is correct, despite Braille Institute's page saying "Light to Extrabold" and the repo README saying "six weights" — both are stale; the fvar table has 7 named instances. Glyph count is 392/style, not ~370 (369 is the ORIGINAL font's count). "Tighter spacing" is backwards: a–z advance widths are ~0.7% wider than the original (12570 → 12655). Taller ascenders (b: 668→708, now above the 668 cap height) and a lightened Bold (I stem 344→332.4, Regular unchanged) are both real and verified. Mono lives at googlefonts/atkinson-hyperlegible-next-mono, same wght-only structure. The repo has no GitHub Releases or tags — "v2.001 first release" is a README changelog line.

**Evidence:** MOST OF THE CLAIM SURVIVES, BUT THE LOAD-BEARING AXIS DETAIL IS WRONG.

I did not rely on secondary sources. I downloaded the shipping binaries from the googlefonts repo and read the fvar/name/OS2/hmtx tables directly with fontTools. That settles every specific.

=== THE REFUTATION: there is no `ital` axis ===
Both variable fonts expose exactly ONE axis:
  AtkinsonHyperlegibleNext[wght].ttf        -> AXES: [('wght', 200.0, 400.0, 800.0)]
  AtkinsonHyperlegibleNext-Italic[wght].ttf -> AXES: [('wght', 200.0, 400.0, 800.0)]
The filenames themselves encode it: the Google Fonts bracket convention lists the axes, and both read `[wght]` — not `[ital,wght]`. Google Fonts METADATA.pb for the family lists a single `axes { tag: "wght" min 200 max 800 }` block and nothing else.

Italic ships as a SEPARATE font file, not as an axis inside one file. The claim's "wght (200–800) + ital axes" describes a font that does not exist.

Fontsource is the source of the error. Its axes table renders "ital 0 to 1" alongside "wght 200-800", but that is Fontsource's UI convention meaning "italic files are available" — its own install page emits two stylesheets (`wght.css` and `wght-italic.css`), i.e. two files. The researcher read a packaging convention as an fvar axis. The claim cites Fontsource as the confirming source for the axes specifically, and Fontsource is exactly what cannot confirm it.

WHY THIS MATTERS FOR THE DESIGN DECISION: you cannot interpolate or animate between roman and italic, and you must ship/register two font assets. In Flutter, `FontVariation('ital', 1)` would silently no-op — italic requires a second `fonts:` family entry with `style: italic`, resolved via `FontStyle.italic`, not via the variable axis machinery. A design system built on the assumption of a single 2-axis file would be built on sand.

=== TWO MORE INVENTED/TRANSPOSED SPECIFICS ===
"~370 glyphs/style" — WRONG, and revealingly so. Next has 392 glyphs. 369 is the glyph count of the ORIGINAL Atkinson Hyperlegible. The number was lifted from the old font.
"tighter spacing" — UNSUPPORTED, and backwards. Sum of a–z advance widths: original 12570, Next 12655. Next is ~0.7% WIDER, not tighter.

=== WHAT CHECKS OUT (verified in the binaries) ===
- v2.001: name ID 5 = "Version 2.001". Nov 20 2024 confirmed via README changelog. CAVEAT: the repo has ZERO GitHub Releases and ZERO tags (`gh api .../releases` and `.../tags` both return `[]`). "The repo shows v2.001 'first release'" is a README line, not a tagged release.
- Feb 10 2025 announcement: confirmed, PRNewswire.
- OFL 1.1: confirmed in the binary itself (name ID 13 = "This Font Software is licensed under the SIL Open Font License, Version 1.1").
- NO opsz, NO GRAD: confirmed. This half of the claim is right.
- 7 weights ExtraLight–ExtraBold: CONFIRMED, and the claim is more accurate here than the primary sources. fvar carries exactly 7 named instances (ExtraLight 200 → ExtraBold 800), plus 14 static TTFs. Note two primary sources are wrong/stale: brailleinstitute.org/freefont says "Seven weights—Light to Extrabold" (internally inconsistent — Light→ExtraBold is six), and the repo README still says "six weights". The binaries settle it at 7.
- 150+ languages up from 27, 2→7 weights: confirmed (Braille Institute + PRNewswire).
- Mono: confirmed, but the repo is `googlefonts/atkinson-hyperlegible-next-mono` (family name "Atkinson Hyperlegible Mono"). Same structure: wght 200–800 only, separate Roman/Italic VFs, OFL. GF date_added 2024-11-20.
- "Taller ascenders, now above cap height": CONFIRMED by measurement. Original: 'b' top = 668, cap height = 668 (exactly equal). Next: 'b' top = 708 vs cap 668. The ascender genuinely crossed above cap height.
- "Lightened Bold": CONFIRMED by measurement. 'I' stem width at Bold: original 344 → Next 332.4. Regular is unchanged at 282, so the lightening is specific to the heavy end, exactly as claimed.

=== NOTE ON THE CONFIDENCE RATING ===
"high" confidence was not warranted on the axes. The four cited sources include only one that can speak to fvar contents (the repo), and the researcher took the axis list from Fontsource, an aggregator, instead. The two claims the researcher could only have gotten from real inspection (ascenders, lightened Bold) are correct; the ones taken from aggregators (ital axis, glyph count) are wrong. That is the signature of a claim assembled from secondary sources with a couple of real observations mixed in.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "typography-system" made this claim, and a design decision depends on it.

CLAIM: Atkinson Hyperlegible Next shipped Nov 2024 (v2.001) / announced Feb 2025, is SIL OFL 1.1, and has ONLY wght (200–800) + ital axes — no opsz, no GRAD
DETAIL: Braille Institute announced Feb 10 2025; the googlefonts/atkinson-hyperlegible-next repo shows v2.001 'first release' dated Nov 20 2024 under OFL-1.1. Expanded from 2 to 7 weights (ExtraLight–ExtraBold) + matching obliques, 150+ languages (up from 27), ~370 glyphs/style. Fontsource confirms axes: wght 200–800, ital 0–1. Atkinson Hyperlegible Mono also shipped, 7 weights + variable. Next adds taller ascenders (now above cap height), tighter spacing, and a LIGHTENED Bold vs the original.
CLAIMED SOURCES: https://github.com/googlefonts/atkinson-hyperlegible-next, https://www.brailleinstitute.org/freefont/, https://fontsource.org/fonts/atkinson-hyperlegible-next, https://www.prnewswire.com/news-releases/braille-institute-launches-enhanced-atkinson-hyperlegible-font-to-make-reading-easier-302371657.html
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

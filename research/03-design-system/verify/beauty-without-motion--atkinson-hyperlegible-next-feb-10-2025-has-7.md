# beauty-without-motion--atkinson-hyperlegible-next-feb-10-2025-has-7

> Phase: **verify** · Agent `a1baa0770b8073f7d` · Run `wf_f237e8a6-694`

## Result

## Verdict

**CONFIRMED**

**Correction:** No correction to the claim's facts. Two implementation clarifications: (a) the OFL 1.1 license applies to the Google Fonts/GitHub distribution — the brailleinstitute.org/freefont download is governed by a separate End-User License Agreement, so source from Google Fonts if license terms matter; (b) the Mono is a separate font family (atkinson-hyperlegible-next-mono), not an eighth style inside Next, so "one family" applies to the seven weights only. Separately, note that googlefonts/atkinson-hyperlegible-next README.md erroneously says "six" weights — it is stale and contradicted by the shipping METADATA.pb (wght 200-800); do not cite that README.

**Evidence:** Every specific in the claim substantiates against primary sources; an attempt to refute failed.

DATE: Braille Institute newsroom and PRNewswire both date the launch to February 10, 2025. CONFIRMED.

SEVEN WEIGHTS, UP FROM TWO: Braille Institute newsroom states verbatim "seven font weights (up from two)". brailleinstitute.org/freefont lists the exact names claimed: "ExtraLight, Light, Regular, Medium, SemiBold, Bold, and ExtraBold", each with upright and italic. CONFIRMED, including the weight-name list.

ORIGINAL HAD 2 WEIGHTS: freefont page describes the original as "Four fonts, including two weights for regular, bold, italics, and italic bold". Wikipedia corroborates "four styles, each of 335 glyphs: regular, bold, italics, and italics bold". CONFIRMED.

VARIABLE VERSION: The decisive artifact is google/fonts METADATA.pb for atkinsonhyperlegiblenext, which declares axes tag "wght", min_value 200.0, max_value 800.0. Fontsource API independently enumerates weights 200/300/400/500/600/700/800 in normal and italic. CONFIRMED at the shipping-artifact level, not just marketing prose.

150+ LANGUAGES, UP FROM 27: newsroom states "support of over 150 languages (up from 27)". CONFIRMED.

FREE / GOOGLE FONTS / FREEFONT: newsroom states "free to download and free to use" via "Google Fonts and BrailleInstitute.org/freefont". METADATA.pb declares license "OFL"; Fontsource reports OFL-1.1. CONFIRMED.

CONTRADICTORY EVIDENCE FOUND AND RESOLVED: googlefonts/atkinson-hyperlegible-next README.md states "the two previous weights has increased to six, all in upright and italic" — six, not seven. This is the strongest available counter-evidence and it does not hold: it is contradicted by METADATA.pb from the same GitHub org (wght axis 200-800, spanning seven named instances) and by Fontsource's enumeration of seven weights. The README is stale descriptive prose; the metadata is the shipped artifact. Seven stands.

DESIGN INFERENCE CHECK: the operative payoff — "a 600 tile label against a 300 secondary and a 700 show-mode display" — maps to SemiBold/Light/Bold, all within the verified 200-800 wght range. Mechanically sound.

CAVEATS (do not refute, but affect implementation):
1. LICENSE MECHANISM DIFFERS BY SOURCE. The Google Fonts / GitHub distribution is SIL OFL 1.1 (verified in METADATA.pb). The brailleinstitute.org/freefont page routes downloads through an "End-User License Agreement" and does not state OFL. "Free" is true for both, but if modification/redistribution/embedding terms matter, source the font from Google Fonts or the GitHub repo and do not cite OFL for the foundry copy without reading their EULA.
2. MONO IS A SEPARATE FAMILY, NOT A STYLE OF NEXT. Distributed as googlefonts/atkinson-hyperlegible-next-mono. Naming is inconsistent at the source itself: newsroom says "Atkinson Hyperlegible Monospace", freefont page says "Atkinson Hyperlegible Mono". The claim's "one family with matched letterforms" holds for the seven weights but the Mono must be loaded as a second family.
3. UNSUPPORTED CAUSAL RIDER. The factual claim is confirmed, but the surrounding reasoning ("with 2 weights you cannot build weight hierarchy... which is exactly what makes accessible apps look like spreadsheets") is the researcher's editorial position. No source establishes that size-only hierarchy caused poor aesthetics in accessible apps. The confirmed font facts should not launder this unconfirmed causal claim.

No Flutter/API claim was made, so no api.flutter.dev version-rot check applied.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "beauty-without-motion" made this claim, and a design decision depends on it.

CLAIM: Atkinson Hyperlegible Next (Feb 10, 2025) has 7 weights and a variable version — up from 2 weights. This is the fact that makes typography-led beauty possible in this app at all.
DETAIL: Braille Institute launched Next on 2025-02-10: ExtraLight, Light, Regular, Medium, SemiBold, Bold, ExtraBold, each with italics, plus a variable version and a Mono version, and 150+ language support (up from 27). Free, on Google Fonts and brailleinstitute.org/freefont. The original Atkinson Hyperlegible had only Regular and Bold — with 2 weights you cannot build weight hierarchy, so every prior 'use Atkinson' recommendation implicitly forced you into size-only hierarchy, which is exactly what makes accessible apps look like spreadsheets. Next removes that excuse: you can now set a 600 tile label against a 300 secondary and a 700 show-mode display in one family with matched letterforms.
CLAIMED SOURCES: https://www.brailleinstitute.org/about-us/news/braille-institute-launches-enhanced-atkinson-hyperlegible-font-to-make-reading-easier/, https://www.prnewswire.com/news-releases/braille-institute-launches-enhanced-atkinson-hyperlegible-font-to-make-reading-easier-302371657.html, https://www.printmag.com/type-tuesday/atkinson-hyperlegible-next-applied-design/
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

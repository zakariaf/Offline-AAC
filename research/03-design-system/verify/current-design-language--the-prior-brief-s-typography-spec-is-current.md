# current-design-language--the-prior-brief-s-typography-spec-is-current

> Phase: **verify** · Agent `a34dd330b8da38575` · Run `wf_f237e8a6-694`

## Result

## Verdict

**CONFIRMED**

**Correction:** Adopt the ACTION (specify Atkinson Hyperlegible Next Variable), but fix three details before it enters the corpus:

1. AXIS RANGE UNDERSTATED. The claim says the variable axis is "Light->ExtraBold." It is actually 200-800, i.e. ExtraLight->ExtraBold (Google Fonts metadata: wght min 200.0, max 800.0, default 400.0; corroborated by Fontsource). The claim understates its own case; the full ExtraLight-ExtraBold range is available.

2. FLUTTER FAILURE MODE MISCHARACTERIZED. The claim says Flutter "would synthesize a fake weight or snap to 400/700." Only the second half is right. Flutter follows the CSS font-matching algorithm: a w500 request against a 400/700-only family resolves DOWN to 400, and w600 resolves UP to 700. Flutter does not synthesize arbitrary intermediate weights (synthetic bold exists only in narrow fallback cases). This matters practically: the failure is a silent wrong weight, not a visibly distorted one, so it will not be caught by eye during review.

3. LICENSE IS TWO REGIMES, NOT ONE. "Free" is accurate but imprecise. Google Fonts distributes Atkinson Hyperlegible Next under OFL. brailleinstitute.org/freefont requires accepting a custom End-User License Agreement at download. These are not interchangeable. For a shipped application, source the font from Google Fonts and rely on the OFL rather than the foundry EULA.

Suggested corpus wording: "Specify Atkinson Hyperlegible Next Variable (wght 200-800, OFL via Google Fonts). The original Atkinson Hyperlegible is static 400/700 only; requesting w500/w600 against it silently resolves to 400/700 per CSS font matching."

**Evidence:** Attempted refutation failed; the load-bearing core is substantiated by primary sources.

1. PREMISE CONFIRMED (original font cannot render 500-600). Google Fonts metadata endpoint for "Atkinson Hyperlegible" returns exactly: 400, 400i, 700, 700i, and "Axes: none" (static, no variable axis), license OFL. There is no Medium (500) or SemiBold (600). The Braille Institute foundry page independently states the original ships 2 weights (Regular/Bold), upright+italic, 335+ glyphs, 27 languages. The prior brief's "weight 500-600" is therefore unrenderable in the original font.

2. REPLACEMENT CONFIRMED. brailleinstitute.org/freefont (primary/foundry) lists Atkinson Hyperlegible Next: 7 weights (ExtraLight, Light, Regular, Medium, SemiBold, Bold, ExtraBold), upright+italic each, variable font yes, 370 glyphs, 150+ languages. Also confirms Atkinson Hyperlegible Mono (7 weights, variable, monospaced, 373 glyphs, 150+ languages).

3. DATE CONFIRMED. PR Newswire release is dated February 10, 2025, and confirms seven weights (up from two), a variable version, a monospace cut for coding, 150+ languages (up from 27), download on Google Fonts and BrailleInstitute.org/freefont, "free to download and free to use."

4. GOOGLE FONTS AVAILABILITY CONFIRMED. Google Fonts metadata for "Atkinson Hyperlegible Next": weights 200/300/400/500/600/700/800 plus italics, axis wght min 200 max 800 default 400, license OFL, category Sans Serif, open source. Medium (500) and SemiBold (600) are real named instances, not interpolated approximations.

5. FLUTTER BUILDABILITY OF THE ACTION VERIFIED (claim did not check this; it holds). flutter/flutter#148026 proposed consolidating FontWeight and FontVariation('wght') because using fontWeight alone "fails with variable fonts." This could have invalidated the recommendation. However api.flutter.dev FontVariation.weight docs currently state applications should "declare font weight by specifying a FontWeight," which handles the attribute implicitly, and that FontVariation.weight supersedes FontWeight when both are given. So TextStyle(fontWeight: FontWeight.w500) against Atkinson Hyperlegible Next Variable resolves correctly on current Flutter. The ACTION is buildable.

TWO SPECIFICS ARE WRONG (neither changes the ACTION) - see correction field.

SCOPE LIMIT: This verifies the font-capability claim only. It establishes that the original font cannot render 500-600 and that Next can. It does NOT validate whether 17pt/~20pt/weight 500-600 is an appropriate typography spec for AAC tile labels — no legibility research was evaluated, and none is cited by the claim. That remains an independent open question.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "current-design-language" made this claim, and a design decision depends on it.

CLAIM: The prior brief's typography spec is currently unbuildable: original Atkinson Hyperlegible has only 2 weights. 'Weight 500-600' requires Atkinson Hyperlegible Next (Feb 2025)
DETAIL: Original Atkinson Hyperlegible (Braille Institute, 2020) ships Regular (400) and Bold (700) only, each with italic — there is no Medium (500) or SemiBold (600). The prior brief specifies 'tile labels min 17pt, default ~20pt, weight 500-600', which the original font cannot render (Flutter would synthesize a fake weight or snap to 400/700). Atkinson Hyperlegible Next launched 2025-02-10: SEVEN weights (ExtraLight, Light, Regular, Medium, SemiBold, Bold, ExtraBold), each with italic, PLUS a variable font (Light→ExtraBold axis) and a monospace cut. Language support expanded from 27 to 150+. Free, on Google Fonts and brailleinstitute.org/freefont. The variable font also unlocks the ratio-expansion move below (arbitrary weight along the axis) at one file's download cost. ACTION: specify Atkinson Hyperlegible Next Variable, not Atkinson Hyperlegible.
CLAIMED SOURCES: https://www.brailleinstitute.org/freefont/, https://www.prnewswire.com/news-releases/braille-institute-launches-enhanced-atkinson-hyperlegible-font-to-make-reading-easier-302371657.html, https://www.printmag.com/type-tuesday/atkinson-hyperlegible-next-applied-design/, https://pimpmytype.com/font/atkinson-hyperlegible-next/
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

# color-system--at-iso-lightness-muted-category-colors-colla

> Phase: **verify** · Agent `a707be7bd0aca7d6c` · Run `wf_f237e8a6-694`

## Result

## Verdict

**REFUTED**  (refuted)

**Correction:** Cap at 4 if you want to, but do not justify it as color science — it is a taste call, and the brief should say so. Three corrections: (a) 5 muted CVD-distinct categories ARE achievable — an existence proof at chroma<=0.082 with staggered lightness scores 10.4 worst-case across normal/protan/deutan, clearing the researcher's own dE>=10 bar; (b) the collapse is caused by iso-lightness + chroma 0.060, not by colorblindness — at C=0.060 even NORMAL trichromats only fit 3 hues past a dE-10 bar (4 hues = 7.95, 5 hues = 6.34), so the fix is to vary lightness, which the researcher already demonstrated and then discarded; (c) the dE>=10 threshold is invented and should be dropped — it fails Okabe-Ito (deutan 8.0), a 7-category palette in successful use since 2002, per the researcher's own control run. Additionally, restate the tritan figures as unsourced: Vienot 1999 provides no tritan matrix and single-matrix tritan simulation is invalid; re-run tritan under Brettel 1997 before quoting any tritan number. Keep the redundant position + text label recommendation — WCAG 1.4.1 Level A requires it regardless of how many colors you ship.

**Evidence:** The measurements reproduce exactly, but the conclusion drawn from them is false. I ran the researcher's own cat.py/cat2.py and audited color.py (the OKLab/OKLCH/sRGB primitives are correct, dE is scaled x100).

1) CONSTRUCTIVE REFUTATION — 5 muted CVD-distinct categories exist. Random search over chroma<=0.090 with staggered L found: #532E2E #3C0804 #645019 #174269 #27123B (max chroma 0.082, L 0.235-0.441, all >=5.5:1 text contrast vs #DCD9D3, i.e. WCAG AA). Scores normal 10.7 / protan 10.4 / deutan 10.6 -> worst 10.4, which CLEARS THE RESEARCHER'S OWN dE>=10 BAR. This was found by naive random search, not optimization, so 10.4 is a lower bound. "Not achievable / color-science impossibility" is simply false.

2) MISATTRIBUTED CAUSATION — colorblindness is not the binding constraint; the chroma choice is. At iso-L with C=0.060, every color lies on a circle of radius 0.060 in the (a,b) plane, so the maximum possible dE between ANY two colors is the diameter = 12.0. Clearing dE>=10 requires a chord >=0.10, i.e. hue separation >= 112.9 deg, so at most 360/112.9 = 3.19 -> 3 hues fit ON THE CIRCLE BEFORE ANY CVD IS APPLIED. Measured, evenly spaced, NORMAL TRICHROMATIC VISION ONLY: N=2 -> 11.5 (pass), N=3 -> 10.3 (pass), N=4 -> 7.95 (FAIL), N=5 -> 6.34 (FAIL). Normal vision already caps this at 3; CVD only takes 3->2. The "5 collapses to 2" result is produced by C=0.060 + a threshold of 10, both of which are self-imposed aesthetic choices. This is the exact opposite of the claim's punchline that it is "not a taste failure."

3) THE THRESHOLD IS UNSOURCED AND IS FALSIFIED BY THE RESEARCHER'S OWN CONTROL. cat.py:44 hard-codes `flags = [x for x in ds if x[0] < 10]`; the "dE~10 comfort threshold" has no published basis — OKLab has no established JND, and Ottosson never defined one. cat2.py:44 already scores Okabe-Ito, the field's CVD-validated 7-color standard (Color Universal Design, 2002; popularized by Wong, Nature Methods 2011), on this same metric: protan 9.1, deutan 8.0, tritan 6.8 — ALL BELOW 10. The metric declares the gold standard a failure at 7 categories while it demonstrably works. The threshold is wrong, not the palette. (Caveat: Okabe-Ito is designed for light backgrounds and scores 1.1:1 against this dark-mode text color, so it is not a drop-in — but that does not rescue the dE bar.)

4) THE TRITAN NUMBERS ARE NOT FROM THE CITED SOURCE. Vienot, Brettel & Mollon 1999 (Color Res Appl 24:243-251) covers PROTANOPIA AND DEUTERANOPIA ONLY — its entire contribution is that for those two the reduced gamut collapses onto a SINGLE plane in LMS, so one matrix suffices. The tritan matrix at cat.py:8 has no provenance in that paper, and a single 3x3 matrix is provably invalid for tritanopia: the tritan gamut is TWO half-planes and requires Brettel 1997 (JOSA A 14:2647-2655), where the choice of projection matrix depends on which side of a separation plane the stimulus falls. DaltonLens states plainly: "the Brettel 1997 one is required for accurate tritanopia simulation." So "tritan 1.3", "tritan 10.1", "tritan 3.0" are computed from an unattributed matrix and cannot be cited as "Vienot 1999."

WHAT SURVIVES: The specific collisions reproduce exactly and are real — Blue(250)~Violet(300) deutan 0.7, Teal(175)~Rose(10) deutan 1.4. Deutan does compress the red-green axis. Iso-lightness at very low chroma IS genuinely hostile to categorical coding. Lightness stagger IS the correct fix (the researcher found it, measured 5.6, then dismissed it against the bogus bar). WCAG 1.4.1 Use of Color (Level A) does require that color not be the sole visual means of conveying information, so redundant position + text label is independently correct — but it is correct as baseline conformance, not as a consolation prize for an impossibility that does not exist.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "color-system" made this claim, and a design decision depends on it.

CLAIM: At iso-lightness, muted category colors collapse under colorblind simulation — only 2 survive, not 5
DETAIL: I implemented Viénot 1999 dichromat simulation and measured pairwise OKLab dE. At L=0.290 uniform, chroma 0.060: 2 hues (blue 250° + clay 55°) → min dE 10.1–11.9 across normal/protan/deutan/tritan = safe. 3 hues → 3.0–7.1. 4 hues → deutan 1.4, tritan 1.3 = indistinguishable. Blue(250°)~Violet(300°) hits deutan dE 0.7. Teal(175°)~Rose(10°) hits deutan 1.4 — because deutan destroys the red-green axis and teal/rose sit at opposite ends of exactly that axis. The surviving axis under deutan is blue-yellow, which affords ~2 categories. Adding lightness stagger (L 0.215–0.355) lifts 4 hues to deutan dE 5.6 — better, still under the dE~10 comfort threshold. Conclusion: 5 muted CVD-distinct categories is not achievable; it is a color-science impossibility, not a taste failure. Cap at 4 and make color strictly redundant with position + text label (which WCAG 1.4.1 Use of Color requires anyway, and which the brief's 'position IS the retrieval mechanism' already establishes).
CLAIMED SOURCES: computed: /private/tmp/.../scratchpad/cat.py, cat2.py (Viénot 1999 matrices, OKLab dE)
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

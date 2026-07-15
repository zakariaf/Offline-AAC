# color-system--the-3x4-grid-is-not-a-pattern-glare-risk-but

> Phase: **verify** · Agent `a1c952d22a2ff6169` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Keep the debunk, drop the justification. Defensible version: "The tile grid is not a pattern-glare risk. At 35cm (38.5 dp/deg), a 130dp 3-col grid has a fundamental of 0.30 cpd and a 192dp 2-col grid 0.20 cpd — roughly 10x below the ~3 cpd peak identified by Wilkins et al. (1984), and below the 0.5 cpd control plate of the Pattern Glare Test (Evans & Stevenson 2008). Real tile grids also have a low duty cycle rather than the 50% that maximizes the effect, so the margin is larger than the frequency alone suggests. A plausible-sounding worry is retired."

Do NOT carry the type-floor half. Specifically: (a) delete the Shepherd 2013 citation for the autism sentence — that paper is about color and spatial frequency in migraine and never mentions autism; if the autism/visual-stress overlap is asserted at all, cite it as reported-but-under-studied, not "strongly comorbid"; (b) delete the "2-5 cpd band" — it appears in neither source, and the literature describes a tuning curve with personalized thresholds, not a step function; (c) if the text figures are retained, state the actual per-size line-height multipliers used (1.4/1.4/1.3/1.2) — under a uniform 1.4 the values are 11pt = 2.50 cpd and 9pt = 3.05 cpd, not 2.69 and 3.56; (d) note that 17pt at 35cm = 1.62 cpd falls inside Wilkins' own 1-6 cpd range for printed text, so these numbers do not certify 17pt as safe.

Most important: pattern glare gives a gradient, not a floor — it says "larger is better" without bound and therefore cannot select 17 over 20 or 24. Legibility and the WCAG/M3 accessibility guidance should remain the sole justification for the type floor; presenting pattern glare as a second independent pillar overstates the evidence and would not survive review. The contrast corollary ("don't ship #FFF-on-#000") is directionally supported by Wilkins/Haigh on contrast dependence and by Shepherd's finding that chromatic gratings provoke fewer illusions than black/white at equal luminance contrast — but cite those for contrast, not Shepherd for a contrast effect he held constant, and note Shepherd's effect peaked at 12 cpd.

**Evidence:** SUBSTANTIATED (the debunk half):

1. Source 1 is real and on point. PubMed 18565084 = Evans & Stevenson (2008), "The Pattern Glare Test: a review and determination of normative values," Ophthalmic Physiol Opt 28(4):295-309. Peer-reviewed, establishes normative thresholds (>3 on the 3cpd grating, or >1 on the 3-12cpd difference). Migraine group reported more distortions than controls. Note the attribution slip: the test is Wilkins & Evans; the 3cpd/50%-duty/high-contrast finding originates in Wilkins et al. (1984), not the 2008 paper.

2. The core physiology is verbatim correct. Multiple primary sources: "Patterns of high contrast having a striped configuration with spatial frequency around 3 cycles/degree, and with stripes of equal width and spacing (duty cycle of ~50%), tend to produce maximum effect."

3. The optics arithmetic checks out exactly. I recomputed: 2*350mm*tan(0.5deg) = 6.1088mm/deg; 25.4/160 = 0.15875mm/dp; therefore 38.481 dp/deg. Grid: 38.481/130 = 0.296 cpd; 38.481/192 = 0.200 cpd. Both confirmed.

4. The grid conclusion is correct and actually stronger than argued. At ~0.30 cpd the grid is ~10x below peak, and Wilkins' own test uses 0.5 cpd as the LOW control plate. Additionally, real tile grids are large tiles with thin gaps — a low duty cycle, not the 50% that Wilkins says maximizes the effect. So the grid is safe for two reasons, not one. This debunk is the claim's most valuable and best-supported finding.

5. The "text approximates a grating" caveat is honest and correctly attributed. Wilkins' position is documented: printed text presents a grating-like stimulus with spatial frequencies "between 1-6 cycles/degree, high contrast, and 50% duty cycle."

REFUTED (the constructive half — the type-floor argument):

6. FATAL: Source 2 does not say what it is cited for. DOI 10.1111/head.12062 = Shepherd, Hine & Beaumont (2013), "Color and Spatial Frequency Are Related to Visual Pattern Sensitivity in Migraine," Headache 53:1087-1103 (n=28 migraine, 14 controls). It contains no mention of autism whatsoever. The sentence it is attached to — "Migraine and visual stress are strongly comorbid with autistic sensory sensitivity" — is uncited. That sentence is the entire bridge from migraine research to the AAC user population, and it is the load-bearing link.

7. "Strongly comorbid" overstates an open question. The autism/visual-stress literature reports symptom overlap but is explicit that it is under-studied: "few studies have provided further characterization of visual sensory issues in autistic individuals, particularly in adults, and future work should investigate whether the visual experiences of autistic people are at ALL related to Meares-Irlen syndrome." That is a research gap, not strong comorbidity.

8. Two of four text numbers are not reproducible from the stated method. The claim states "20pt/1.4 line pitch" as the method. Reverse-engineering the claimed cpd values recovers the implied multiplier: 20pt->1.40, 14pt->1.40, 11pt->1.30, 9pt->1.20. The line-height multiplier silently tightens for exactly the two sizes the argument needs to push into the danger band. Under the stated uniform 1.4: 11pt = 2.50 cpd (not 2.69), 9pt = 3.05 cpd (not 3.56). Tightening leading at small sizes is defensible Material practice, but it was not disclosed, and it inflates the small sizes toward the peak.

9. The "2-5 cpd band" is invented. Neither cited source states it. Wilkins gives ~3 cpd as the PEAK; the Pattern Glare Test samples 0.5/3/12. The primary literature describes a tuning curve with individual thresholds — one source explicitly declines to set a safety bound, "implying personalized thresholds rather than universal safety limits." There is no cliff at 2.0 cpd. The band boundary is doing all the argumentative work and it is the researcher's own construction.

10. THE ARGUMENT DOES NOT SELECT 17pt. Under the claim's own uniform-1.4 method, the 17pt floor at 35cm = 1.62 cpd — which sits INSIDE Wilkins' own stated 1-6 cpd range for printed text. The numbers do not place 17pt outside the risk zone; they place it outside a line the researcher drew. And because sensitivity falls off smoothly below 3 cpd, the argument is monotone: bigger is always better, with no natural stopping point. It endorses 20pt, 24pt, and 40pt exactly as well as 17pt. An argument with no floor cannot justify a floor. Wilkins' actual point is that ordinary reading is inherently somewhat provocative — not that there exists a size that clears the band.

11. The contrast corollary cites the wrong paper. Shepherd 2013 held contrast FIXED at 0.9 Michelson and varied color; it cannot support "glare requires HIGH contrast." That dependence comes from Wilkins/Haigh, not Shepherd. Worse, Shepherd's actual finding cuts across the claim: the color benefit was "not color-specific" and was GREATEST at 12 cpd — a frequency the claim classifies as outside the danger band entirely.

12. Unflagged construct risk. The claim leans on the visual-stress/Meares-Irlen edifice, which is contested: the British Psychological Society has cautioned against definitive efficacy claims for overlays/tinted lenses, and systematic reviews find effects small and hard to separate from placebo. Pattern glare as a measured phenomenon is more robust than Irlen lenses as a treatment, but "medium" confidence does not reflect this.

NET: The claim is two arguments. "The 3x4 grid is not a pattern-glare risk" is CONFIRMED and worth keeping. "This is an independent physiological argument for the type floor" is REFUTED — it rests on an uncited autism bridge, an invented frequency band, two irreproducible numbers, and a monotone argument that cannot pick a threshold. It is not independent evidence for 17pt; it is a restatement of "larger text is more comfortable," which legibility already establishes on much firmer ground.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "color-system" made this claim, and a design decision depends on it.

CLAIM: The 3x4 grid is NOT a pattern-glare risk — but small text is. This is an independent physiological argument for the type floor
DETAIL: Wilkins' pattern glare peaks at 3 cycles/degree square-wave, high contrast, 50% duty; the 2-5 cpd band provokes illusory colors, distortion, nausea, and is implicated in visually-induced migraine. Migraine and visual stress are strongly comorbid with autistic sensory sensitivity. I computed actual spatial frequencies at 35cm viewing (1° = 6.11mm; 1dp = 0.15875mm): the 3-col tile grid at ~130dp pitch = 0.30 cpd; 2-col large mode = 0.20 cpd. That is 10× BELOW the glare peak — the grid is inherently safe, and a plausible-sounding worry is debunked. But stacked text: 20pt/1.4 line pitch = 1.37 cpd (safe); 14pt = 1.96; 11pt caption = 2.69 cpd (IN BAND); 9pt = 3.56 cpd (IN BAND, near peak). So the 17pt floor is justified twice over — legibility AND pattern glare. Caveat: applying grating research to text/tile arrays is an extrapolation, though Wilkins himself argues text approximates a grating and that this is why reading provokes visual stress. Corollary: glare requires HIGH contrast, so small text at max contrast is the worst case — another reason not to ship #FFF-on-#000.
CLAIMED SOURCES: https://pubmed.ncbi.nlm.nih.gov/18565084/, https://headachejournal.onlinelibrary.wiley.com/doi/abs/10.1111/head.12062, computed: spatial frequency at 35cm, 160dpi baseline
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

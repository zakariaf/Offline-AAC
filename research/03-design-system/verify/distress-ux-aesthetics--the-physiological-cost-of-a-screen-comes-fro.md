# distress-ux-aesthetics--the-physiological-cost-of-a-screen-comes-fro

> Phase: **verify** · Agent `a0333f2070ba53ef8` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Keep the complexity half; drop the chroma half — it is the one thing the evidence cannot buy you.

DEFENSIBLE: "Tuch et al. (2009) found that higher visual complexity in web page screenshots was associated with increased arousal, more negative valence, and increased corrugator (frowning) EMG. Tuch et al. (2012) found perceived beauty decreased monotonically with complexity — but only when prototypicality was high; in low-prototypicality pages the ordering broke down. Berlyne's inverted-U predicts simple = boring, but the authors note empirical support for it is mixed and their own data showed a linear relation, so 'simple' does not automatically read as 'boring' — conditional on the design meeting user expectations."

NOT DEFENSIBLE: "...not from chroma." No study cited manipulated, measured, or controlled color. The 2012 paper explicitly names color as an uncontrolled underlying factor of complexity and calls for future research on it. And because 2009 operationalized complexity as JPEG file size — which grows with saturation and color variety — chroma is confounded WITH complexity, not contrasted against it. The honest statement is "these studies say nothing about chroma," not "chroma is exonerated."

Also fix: complexity was SELECTED (via subjective pre-ratings / JPEG size on real websites), not MANIPULATED. Say "the varied variable" or "the graded variable," not "the manipulated variable" — the word implies experimental control that was never exercised.

And the biggest structural problem for "beautiful material, simple structure": the 2012 paper's larger effect is PROTOTYPICALITY (ηp² = .812), not complexity (ηp² = .581), and prototypicality means CONVENTIONAL. The paper supports "simple structure" and "conventional layout." It is silent on "beautiful material" and mildly hostile to it if the beauty is unconventional. If you want the aesthetic latitude, take it in surface treatment that does not disturb the expected object placement — and note that as a design bet, not as a finding.

Finally: none of this evidence reaches a sensory-sensitive audience. It is 107 neurotypical Swiss psychology undergrads rating company homepages in sub-second flashes. Cite it as a plausibility argument for simplicity, not as a physiological result about your users. If the sensory-sensitivity claim is load-bearing, it needs its own source.

**Evidence:** SOURCING IS CLEAN — unusually so. Every quote in the DETAIL is verbatim from the real paper, which I read in full (free preprint: research.google.com/pubs/archive/38315.pdf = Tuch, Presslaber, Stöcklin, Opwis, Bargas-Avila, IJHCS 70(11), 794–811, DOI 10.1016/j.ijhcs.2012.06.003 — the claimed DOI resolves correctly).

VERIFIED VERBATIM (p. text lines cited from extracted PDF):
1. Tuch 2009 quote — EXACT: "in a study of Tuch et al. (2009), VC of web pages was related to increased experienced arousal, more negative valence appraisal, and increased facial muscle tension (musculus corrugator)."
2. Berlyne/boring — EXACT: "stimuli with high arousal potential are experienced as unpleasant, and stimuli with low arousal are experienced as boring."
3. Martindale caveat — near-exact: "However, the empirical support for this inverted U-shaped relation is mixed, several studies found a linear rather than a quadratic relation (for a critical examination see Martindale et al., 1990)." (Claim drops "for a critical examination see" — cosmetic.) Ref verified: Martindale, Moore, Borkum, 1990, Am. J. Psychology 103(1), 53–80.
4. The high-PT monotonic claim — CORRECT, and impressively precise: "all three levels of VC differ significantly from each other in the high PT condition, but not in the low PT condition." In low PT, "web pages of high VC are preferred over web pages [of medium VC]" — against the authors' own expectations. Significant VC x PT interaction, F(1.7, 96.1) = 85.273, p < .001, ηp² = .604. So "simple does not read as boring — but only when prototypicality is high" is a fair reading of the data.

WHERE IT BREAKS — the "not from chroma" half:
Neither study manipulated, measured, or controlled chroma. "Not from chroma" is not a finding; it is an absence of evidence, and the paper says so explicitly in its own Limitations, §6.4(4): "Complexity and prototypicality are influenced by many factors (e.g. form, COLOR, shape, location to name just a few). In this study these underlying factors are not controlled, analyzed or understood in depth, nor can we derive conclusions about which factors lead to high or low complexity/prototypicality." The Conclusions repeat it: "Further studies are needed to understand other factors such as COLOUR, grouping, structure, or amount of text and pictures."

Worse — chroma is plausibly INSIDE the complexity construct, not separable from it:
- Tuch et al. 2009 (IJHCS 67(9), 703–715) operationalized visual complexity as JPEG FILE SIZE (r=.80 with subjective ratings). JPEG file size rises with colorfulness/saturation; "variety of colors" is a documented dimension of perceived visual complexity. So the very corrugator effect being cited was driven by a proxy contaminated by chroma. The study cannot exonerate chroma — its design makes chroma a candidate CONTRIBUTOR to the frowning.

"THE MANIPULATED VARIABLE WAS COMPLEXITY" IS ALSO WRONG:
Both studies are quasi-experimental, not manipulations. 2012: screenshots of 270 REAL company homepages, pre-rated by 267 people, allocated to VC×PT cells by rating score. 2009: 36 real website screenshots binned by JPEG size. Nothing was held constant — color, text density, imagery, and brand all travel with the complexity levels.

AUDIENCE TRANSFER IS UNSUPPORTED:
Study 1 n=59 (45 female), Basel undergrad psychology students, mean age 25.4, explicitly "no education in either visual design or web design"; 2009 n=48. Zero sensory-sensitive or autistic participants. The paper's own limitations flag culture, age, and website type as bounds. Stimuli were COMPANY HOMEPAGES viewed for 17–1000 ms — first-impression aesthetics, not sustained use of an AAC app.

ALSO NOTE, AGAINST THE DESIGN DIRECTION: the 2012 win condition is low VC + HIGH PROTOTYPICALITY — "looks like a typical company website." Low-PT pages were judged unattractive at EVERY complexity level. If "beautiful material" means unconventional/novel styling, it LOWERS prototypicality, which is the larger main effect here (ηp² = .812 for PT vs .581 for VC). The paper's closing advice is the opposite of expressive: "Designs that contradict what users typically expect of a website may trigger a suboptimal first impression."

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "distress-ux-aesthetics" made this claim, and a design decision depends on it.

CLAIM: The physiological cost of a screen comes from COMPLEXITY, not from chroma. This is the finding that makes 'beautiful material, simple structure' defensible for a sensory-sensitive audience.
DETAIL: Tuch et al. (2009), cited within the 2012 paper: visual complexity of web pages 'was related to increased experienced arousal, more negative valence appraisal, and increased facial muscle tension (musculus corrugator)' — i.e. measurable frowning. The manipulated variable was complexity. Also relevant and load-bearing against over-claiming: Berlyne's (1974) inverted-U predicts MODERATE complexity is most pleasurable and that low-arousal stimuli are experienced as BORING — but Tuch et al. note 'the empirical support for this inverted U-shaped relation is mixed, several studies found a linear rather than a quadratic relation (Martindale et al., 1990),' and their own data found complexity monotonically decreased beauty in the high-PT condition. So 'simple' does not empirically read as 'boring' here — but only when prototypicality is high.
CLAIMED SOURCES: https://dl.acm.org/doi/10.1016/j.ijhcs.2012.06.003
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

# distress-ux-aesthetics--that-same-paper-contains-the-maya-principle

> Phase: **verify** · Agent `a44f421be47138ce1` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Corrected version: Hekkert, Snelders & van Wieringen (2003), "'Most advanced, yet acceptable': Typicality and novelty as joint predictors of aesthetic preference in industrial design," British Journal of Psychology 94(1):111–124 — NOT Tuch et al. — is the source of the MAYA principle. Across three studies on physical consumer products (sanders, teakettles, telephones, cars; Delft University samples, Study 2 n=22), it found typicality and novelty act as mutual suppressor variables: neither correlated significantly with aesthetic preference on its own, and each became highly significant only when the other was partialled out. The conclusion is symmetric — preference goes to "products with an optimal combination of both aspects" — not "novelty is free until it damages prototypicality." Tuch et al. (2012, IJHCS 70(11):794–811, DOI 10.1016/j.ijhcs.2012.06.003) merely cites this in one sentence, never mentions MAYA or Loewy, and never studied novelty; its own finding is that high prototypicality with LOW visual complexity produced the best first impressions and low prototypicality depressed beauty ratings regardless of complexity — which constrains rather than licenses a novelty brief. The M3 Expressive line is a fabricated quotation: the page actually says "When basic interaction paradigms are broken, expressive design can lead to poor usability or negative sentiment," and it is an unmethodologized, non-peer-reviewed vendor blog post, not an independent replication. The SURFACE/AFFORDANCE operational rule appears in no cited source and should be labeled as the team's own design judgment. Confidence should drop from "high" to low-to-moderate, and the entry should cite Hekkert directly rather than secondhand through Tuch.

**Evidence:** I pulled the actual PDF of the cited paper (Google Research archive copy of the accepted manuscript) and searched its full text. Results:

**1. The quoted sentence is REAL and VERBATIM — this part survives.**
DOI 10.1016/j.ijhcs.2012.06.003 = Tuch, Presslaber, Stöcklin, Opwis & Bargas-Avila (2012), "The role of visual complexity and prototypicality regarding first impression of websites," IJHCS 70(11):794–811. Section 2, verbatim: "Hekkert et al. (2003) explored how prototypicality and novelty influence the aesthetic preference of products. They found that people prefered novel designs only as long as the novelty did not affect prototypicality." (Tuch's own typo "prefered" is in the manuscript.) The researcher quoted this accurately. Credit where due.

**2. "That same paper contains the MAYA principle" is FALSE.**
Full-text keyword counts on the paper: **"MAYA" = 0. "Loewy" = 0.** The string "Most advanced, yet acceptable" appears exactly once — in the reference list, as the *title* of the Hekkert paper being cited. Tuch et al. never name MAYA, never mention Loewy, and never articulate MAYA as a principle. The paper contains a one-sentence secondhand citation, not the principle. MAYA lives in Hekkert 2003 (British Journal of Psychology 94(1):111–124), which does explicitly invoke Loewy. The claim attributes to Tuch something that is only in Tuch's bibliography.

**3. The "license" reading misrepresents what Hekkert actually found.**
Hekkert's own abstract (PubMed 12648393) states the result is a **suppression effect**, and it is **symmetric**: "typicality... and novelty are jointly and equally effective... but that they suppress each other's effect. **Direct correlations between both variables and aesthetic preference were not significant**, but each relationship became highly significant when the influence of the other variable was partialed out... people prefer novel designs as long as the novelty does not affect typicality, **or, phrased differently, they prefer typicality given that this is not to the detriment of novelty**. Preferred are products with an **optimal combination of both**."
That is not "novelty is rewarded right up to a ceiling." Novelty *on its own predicted nothing* (n.s. zero-order correlation). The finding is a two-way balance, and the claim quotes only the half that authorizes the founder's brief while dropping the half that constrains it. Note also Hekkert says **typicality**; **prototypicality** is Tuch's substitution.

**4. Tuch's own data cuts AGAINST using this paper as a novelty license.**
Tuch et al. never manipulated or measured novelty at all — their variables were visual complexity (VC) and prototypicality (PT). Their actual result, verbatim from the discussion: "as soon as VC is too high or PT too low, web pages receive lower beauty ratings, **regardless of the characteristics of the other factor**. Overall, websites of high PT and low VC are perceived as being the most beautiful, whereas websites of low PT and high VC trigger the worst first impression." And their gloss on Hekkert: "novelty only affects aesthetic judgments **given high PT**." Citing this paper to justify surface novelty is citing a paper whose headline finding is that high prototypicality + LOW complexity wins.

**5. The M3 Expressive corroboration is a FABRICATED QUOTE from a marketing blog.**
The claim puts in quotation marks: "Violating established UI patterns reduced usability despite visual appeal." That sentence does not exist on the cited page. The actual text reads: "When basic interaction paradigms are broken, expressive design can lead to poor usability or negative sentiment." A paraphrase has been dressed as a citation. Worse, "Google's own M3 Expressive research **independently reproduced** this caveat" is false on three counts: (a) it is a self-published design.google blog post, not research — **no methodology, no preregistration, no peer review, no published data** for the 46 studies / 18,000+ participants / "4x faster" figures; (b) it is not independent — Bargas-Avila, a Tuch co-author, was Google/YouTube UX Research, the same lineage; (c) an anecdotal design caution is not a replication of a suppression-variable regression result. This is exactly the marketing-repeated-as-research failure mode: an unfalsifiable vendor number being used to ratify a design direction.

**6. The "operational rule" is invented and attributed to nobody.**
"Novelty unlimited in the SURFACE (color, type, material, geometry), zero in the AFFORDANCE" appears in neither paper. Neither study decomposes designs along a surface/affordance axis. Hekkert's stimuli were **physical consumer products** — sanders, teakettles, telephones, 20 medium-size cars — rated by **Delft University students and staff** (Study 2 was n=22: 11 experts, 11 non-experts). Tuch's were website screenshots flashed for 50–1000 ms. Neither tested touch UI, neither tested AAC, neither tested disabled or AAC-using participants, and a 22-person Delft car-rating study is a thin plank for a product decision. The surface/affordance split may be a fine design heuristic — but it is the researcher's own reasoning, and it must be owned as such, not laundered through a citation.

**Bottom line for the design decision:** the underlying citation is genuine, so the corpus entry is salvageable — but as written it is not usable. MAYA is in Hekkert, not Tuch. Hekkert's result is a symmetric balance where novelty alone predicted nothing, not a novelty permit with a prototypicality ceiling. The M3 "quote" is fabricated and its backing is unpublished vendor marketing. If the founder's brief is being justified by "the research says novelty is rewarded until it breaks prototypicality," the research does not say that.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "distress-ux-aesthetics" made this claim, and a design decision depends on it.

CLAIM: That same paper contains the MAYA principle, which is the precise license for the founder's brief: novelty is rewarded right up to the point it damages prototypicality.
DETAIL: Tuch et al. cite Hekkert, Snelders & van Wieringen (2003): 'They found that people preferred novel designs only as long as the novelty did not affect prototypicality.' This is Raymond Loewy's MAYA (Most Advanced Yet Acceptable) with an evidence base. Operational rule for this product: novelty is unlimited in the SURFACE (color, type, material, geometry) and zero in the AFFORDANCE (the thing must instantly read as 'buttons that speak'). Google's own M3 Expressive research independently reproduced this caveat: 'Violating established UI patterns reduced usability despite visual appeal.'
CLAIMED SOURCES: https://dl.acm.org/doi/10.1016/j.ijhcs.2012.06.003, https://design.google/library/expressive-material-design-google-research
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

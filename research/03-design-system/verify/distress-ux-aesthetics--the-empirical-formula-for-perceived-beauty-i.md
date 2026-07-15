# distress-ux-aesthetics--the-empirical-formula-for-perceived-beauty-i

> Phase: **verify** · Agent `a7987aa66d61b7dfa` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** The paper supports "low visual complexity + high prototypicality = highest perceived beauty," but NOT the claim's two riders.

(a) PT is not established as the stronger lever. The eta2p .812 vs .581 gap is a Study 1 main-effects comparison that the paper explicitly warns against interpreting given the significant VC x PT interaction ("suggesting caution in interpreting related main effects"). Study 2 finds VC .52 vs PT .55 — effectively tied — and at 17ms PT is weaker than VC, with PT only reaching parity as exposure lengthens.

(b) Causally, VC is the gating variable, not PT. The claim's own cited simple effects show PT's benefit collapses from d=1.96/1.79 (low/medium VC) to d=0.24 (high VC). The paper's framing is a conjunction: "as soon as VC is too high or PT too low, web pages receive lower beauty ratings, regardless of the characteristics of the other factor." You cannot bank PT and spend complexity; high VC nullifies PT.

(c) "The fixed grid delivers prototypicality for free" is unsupported. PT is not a structural property of a layout — it is a rated measure of representativeness relative to a class of objects (Leder et al. 2004), operationalized here only against COMPANY HOMEPAGES, a category chosen because users were known to hold a consistent mental model of it. The paper never links grids/regularity to PT. Whether an AAC grid is prototypical of AAC apps is unmeasured and would require its own study.

(d) Not "Google-funded": no funding statement exists; the paper is University of Basel work with one co-author (Bargas-Avila) then at Google/YouTube UX Research Zurich. Acknowledgements thank only Anna Hanchar for running Study 2.

(e) Scope: n=59 mostly Basel psychology undergraduates, DV = perceived beauty of static screenshots at 17-1000ms exposure. This is first-impression aesthetics of 2012 corporate homepages, not sustained use of a communication tool.

Actionable correction: keep low visual complexity as the primary, non-negotiable lever — it is the factor that gates whether prototypicality pays off at all. Treat the grid's prototypicality as an untested assumption to validate with your own users, not as a delivered win.

**Evidence:** VERIFIED AGAINST FULL TEXT of the paper (Google-hosted preprint, research.google.com/pubs/archive/38315.pdf -> static.googleusercontent.com/media/research.google.com/en//pubs/archive/38315.pdf; extracted to /private/tmp/claude-501/-Users-zakariafatahi-50-apps-challenge-Offline-AAC/894d23b4-edde-414c-90f6-a0c3d1367fdd/scratchpad/tuch2012.txt).

WHAT CHECKS OUT (unusually clean — every number is verbatim):
- Citation: Tuch, Presslaber, Stoecklin, Opwis, Bargas-Avila (2012), Int. J. Human-Computer Studies 70(11), 794-811. CONFIRMED. Peer-reviewed, real, both claimed URLs resolve.
- 119 company-website screenshots, VC (low/med/high) x PT (low/high), presentation 50/500/1000ms. CONFIRMED.
- Study 1 main effects, verbatim: "significant main effects for VC (F(1.8, 99.9) = 77.607, p < .001, eta2p = .581) and PT (F(1.0, 56.0) = 241.365, p < .001, eta2p = .812)". CONFIRMED.
- Interaction, verbatim: "there was a significant VC x PT interaction (F(1.7, 96.1) = 85.273, p < .001, eta2p = .604)". CONFIRMED.
- Interaction direction, verbatim: "VC affects perceived beauty more strongly within the high PT condition, respectively the effect of PT on perceived beauty is blunted if VC is high". CONFIRMED exactly as claimed.
- Simple effects, verbatim: "the effect is much more pronounced for the low and medium (cohen's d = 1.96, respectively 1.79) than for the high complexity level (d = .24)". CONFIRMED.
- 50ms / study 2 at 17ms. CONFIRMED.
- The VC-definition point. CONFIRMED verbatim: "the present study is not interested in giving a specific definition for VC. We rather follow the reasoning of Edmonds (1995)... Consequently, we are primarily interested in the subjectively perceived complexity and not in a objective definition of VC". The researcher's gloss (VC = subjective busyness/clutter, NOT element count, NOT chroma, NOT craft) is a fair reading. Edmonds 1995 is in the reference list.

WHAT IS REFUTED — the load-bearing inference:

1. "PT is the STRONGER lever" — this is the one claim the paper explicitly forbids. Ranking .812 > .581 is comparing main effects, and the paper says of the very interaction the claim cites: "suggesting caution in interpreting related main effects" and "these main effects must be interpreted in regard to the significant VC x PT interaction". The claim quotes the interaction and then reasons as if it weren't there.

2. The .812 vs .581 gap DOES NOT REPLICATE. Study 2 (Table 4, and paper's own summary): "study 2: eta2p VC = .52 and eta2p PT = .55" — a 0.03 gap, effectively tied. And at 17ms the abstract states PT is WEAKER: "the effect of PT is less pronounced than the one of VC... With increasing presentation time the effect of PT becomes as influential as the VC eff32ect." So the claim cites Study 2's 17ms replication as support while Study 2 is the study that kills "PT is stronger."

3. The claim is self-defeating. It concedes d=0.24 at high VC. That means PT's leverage is CONDITIONAL ON VC BEING LOW — VC is the gating variable, the opposite of PT being the lever you get "for free." The paper's own framing is a conjunction, not a ranking: "as soon as VC is too high or PT too low, web pages receive lower beauty ratings, regardless of the characteristics of the other factor." Neither factor is "the stronger lever"; you need both.

4. "which the fixed grid already delivers for free" — unsupported extrapolation, and the real problem for the design decision. PT in this paper is not a structural property you can build in. It was MEASURED per-screenshot by human raters as representativeness relative to one specific class: COMPANY HOMEPAGES. The authors restricted to that category deliberately ("we decided to only include company websites in our sample") because Roth et al. (2010) had shown users hold a consistent mental model for that category specifically. PT is defined (Leder et al. 2004, p.496) as "the amount to which an object is representative of a class of objects" — a fact about the viewer's mental model, not about the artifact's layout. Nothing in the paper says a grid, or regularity, or alignment = high PT. Whether an AAC grid is prototypical OF AAC APPS is an unmeasured empirical question this paper does not address.

5. "Google-funded" — OVERSTATED. There is NO funding statement in the paper. Acknowledgements read in full: "The authors would like to thank Anna Hanchar for conducting the experiments for study 2." The work is University of Basel, Dept. of Psychology; co-author Bargas-Avila was affiliated with Google/YouTube User Experience Research, Zurich. A Google-employed co-author is not "Google-funded."

SCOPE LIMITS THE CLAIM OMITS: n=59, mainly undergraduate psychology students at University of Basel, 45/59 female, mean age 25.4 (Study 1). DV is "perceived beauty" of a static screenshot flashed for 17-1000ms — a first-impression aesthetic rating, not sustained usability, learnability, or communication efficacy. Stimuli are 2012 corporate homepages at 1000x800. Generalizing a 50ms beauty rating of a Fortune-500-style homepage by Swiss psych undergrads to an offline AAC tool used daily by a speech-impaired user is a leap the paper does not license.

TRIVIA: claim's quote says "not in an objective definition"; the paper reads "not in a objective definition" (typo in original). Immaterial.

BOTTOM LINE: The formula "low VC + high PT = highest beauty" is CONFIRMED and is the paper's actual conclusion ("websites with low VC and high PT were perceived as highly appealing"). The two riders bolted onto it — that PT is the stronger lever, and that the grid supplies PT for free — are refuted by the paper's own text and by the interaction the claim itself quotes. If a design decision rests on "PT is handled, so we can let complexity ride," that is precisely backwards: at high VC, PT is worth d=0.24, i.e. nothing.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "distress-ux-aesthetics" made this claim, and a design decision depends on it.

CLAIM: The empirical formula for perceived beauty is low visual complexity + high prototypicality — and prototypicality is the STRONGER lever, which the fixed grid already delivers for free.
DETAIL: Tuch, Presslaber, Stöcklin, Opwis & Bargas-Avila (2012), Int. J. Human-Computer Studies 70(11), Google-funded, 119 website screenshots. Main effects: PT η²p=.812, VC η²p=.581. Significant VC×PT interaction (F(1.7,96.1)=85.273, p<.001, η²p=.604): VC affects beauty MORE strongly in the high-PT condition, and the PT effect is BLUNTED when VC is high. Simple effects: PT differences were huge at low/medium complexity (Cohen's d=1.96, 1.79) but collapsed at high complexity (d=0.24). Effects appear within 50ms, and study 2 replicated at 17ms. Crucially, the paper explicitly declines to define VC objectively: 'we are primarily interested in the subjectively perceived complexity and not in an objective definition of VC' (following Edmonds 1995). So VC = perceived busyness/clutter, NOT element count, NOT chroma, NOT craft.
CLAIMED SOURCES: https://research.google/pubs/the-role-of-visual-complexity-and-prototypicality-regarding-first-impression-of-websites-working-towards-understanding-aesthetic-judgments/, https://dl.acm.org/doi/10.1016/j.ijhcs.2012.06.003
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

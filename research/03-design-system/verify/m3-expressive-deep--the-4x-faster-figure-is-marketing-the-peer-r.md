# m3-expressive-deep--the-4x-faster-figure-is-marketing-the-peer-r

> Phase: **verify** · Agent `a5ac78f67400f0a49` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** The claim is directionally sound and unusually well-sourced — the peer-reviewed paper is real and every method detail and figure checks out. Two corrections:

1. The "~12x gap" is arithmetically wrong. It divides 400% by 33%, treating a speed multiplier and a percentage improvement as the same unit. "4x faster" is a 300% improvement / 4.0x speed ratio; "33% faster" is a ~1.33-1.49x speed ratio. The real gap is ~3x. Do not cite 12x.

2. "The 4x figure is marketing, the 33% is the peer-reviewed number" implies two separate evidence bases. There is one. Google Design's described method (eye-tracking glasses, 10 apps, M3E vs current M3, randomized order) is the CHI '26 study itself. The 4x is the per-element best case from that same study; 33% is its aggregate.

The defensible version: Google Design reports "up to four times faster" from a single best-case element (the Send button in an email app, which was enlarged, moved above the keyboard, and given a secondary color). The peer-reviewed aggregate across 48 participants and 10 apps is 33% faster fixation and 20% faster task completion (Bentley et al., CHI '26, DOI 10.1145/3772318.3790373). "Up to" is doing real work: a per-element best case should not be cited as a system-wide effect. That criticism stands on its own without the inflated 12x.

For the design decision: unusually, this is a case where the marketing claim IS backed by published methodology — rarer than the default assumption. Plan against 33% / 20%, not 4x.

**Evidence:** ATTEMPTED REFUTATION; CORE SURVIVED. Every substantive element verifies against primary sources.

VERIFIED:
- DOI 10.1145/3772318.3790373 resolves to dl.acm.org, CHI '26 proceedings. Paper listed in CHI 2026 TOC (researchr) and on Google's own "Google at CHI 2026" page.
- Authors exact: Frank Bentley, Lennard Lukas Schmidt, Alyssa Sheehan, Bianca Gallardo, Ying Wang. Venue exact: CHI '26, Barcelona, April 13-17 2026.
- Method exact: 48 diverse participants, tasks across 10 applications, M3 Expressive vs previous Material.
- Both numbers confirmed on research.google (primary): "fixated on the correct screen element for a task 33% faster"; tasks "completed 20% faster"; "rated experiences more positively". The phrase "while maintaining or increasing aesthetic judgments" is verbatim abstract text.
- Marketing quote verbatim on design.google: "participants were able to spot key UI elements up to four times faster in the M3 Expressive designs." The 46 studies / 18,000 participants figure also present.
- Provenance of the 4x verified: design.google states participants asked to "send the email" saw the button 4x faster; Expressive Send button is larger, above the keyboard, secondary color, vs small and in the top toolbar in non-Expressive. Eye-tracking glasses, 10 apps, randomized order all confirmed.

DEFECT 1 - "~12x gap" is a unit error. It derives from 400% / 33%, conflating a speed multiplier with a percentage improvement. "4x faster" = 300% improvement (speed ratio 4.0). "33% faster" = speed ratio ~1.33-1.49. Actual gap ~3x, not ~12x. This is the claim's rhetorical payload and it is the one number in the claim that is not real.

DEFECT 2 - "Marketing vs peer-reviewed" is the wrong frame; there is one study, not two. design.google's described method (eye-tracking glasses, 10 apps, M3E vs current M3, randomized) IS the CHI '26 study. The 4x is not a methodology-free marketing number contradicted by the paper; it is the per-element best case from the same dataset whose aggregate is 33%. The claim states this correctly ("4x is a per-element best case; 33% is the aggregate") then contradicts itself by calling it a gap between "the marketing number and the published number." A max and a mean from one distribution are not in tension.

NOT ESTABLISHED: "full paper" vs another track. dl.acm.org returned 403; neither researchr TOC nor Google's CHI page states the track. Not a defect, merely unconfirmed.

SOURCING CAVEAT: the 20% figure is confirmed on research.google and in search-surfaced abstract text, but the ACM publisher page was never read directly (403). The 33% appears in every rendering of the abstract; the 20% was absent from one search-generated summary but present in the research.google fetch and a targeted abstract search. Treated as confirmed with that caveat.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "m3-expressive-deep" made this claim, and a design decision depends on it.

CLAIM: The '4x faster' figure is marketing. The peer-reviewed number is 33% faster fixation / 20% faster task completion, n=48.
DETAIL: Peer-reviewed source EXISTS and I did not expect it: Frank Bentley, Lennard Lukas Schmidt, Alyssa Sheehan, Bianca Gallardo, Ying Wang, 'Usability Hasn't Peaked: Exploring How Expressive Design Overcomes the Usability Plateau', CHI '26 full paper, Barcelona, April 13-17 2026, DOI 10.1145/3772318.3790373. Method: 48 diverse participants, tasks across 10 applications, M3 Expressive designs vs previous Material. Results: fixated on the correct screen element 33% faster, completed tasks 20% faster, rated experiences more positively, 'while maintaining or increasing aesthetic judgments'. Compare Google Design's marketing: 'Participants were able to spot key UI elements up to four times faster in the M3 Expressive designs' — note 'up to', and the task was specifically finding the Send button in an email app using eye-tracking glasses. 4x is a per-element best case; 33% is the aggregate. A ~12x gap between the marketing number and the published number.
CLAIMED SOURCES: https://doi.org/10.1145/3772318.3790373, https://research.google/pubs/usability-hasnt-peaked-exploring-how-expressive-design-overcomes-the-usability-plateau/, https://design.google/library/expressive-material-design-google-research
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

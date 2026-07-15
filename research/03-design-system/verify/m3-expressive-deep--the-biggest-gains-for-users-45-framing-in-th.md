# m3-expressive-deep--the-biggest-gains-for-users-45-framing-in-th

> Phase: **verify** · Agent `a68ec2b1486964e99` · Run `wf_f237e8a6-694`

## Result

## Verdict

**REFUTED**  (refuted)

**Correction:** The brief's "biggest gains for users 45+" framing IS supported by Google's own published wording — the 45+ cutoff is Google's, the differential (erasure of an age gap) is Google's, and the 87%/18-24 figure is on the cited Google primary source. The claim is wrong that these are absent or reshaped. However, the researcher's LOW-confidence conclusion should be RETAINED on different and better grounds: design.google is vendor marketing, not peer-reviewed research; no methodology, effect size, CI, or per-study n is published; no number is attached to the age result specifically ("4x faster" is the overall fixation figure); and "up to 87%" / "up to 4x" are ceiling values, not effects. Recommended posture: treat the age-effects result as a directional vendor assertion with zero published methodology. Do not design around a specific magnitude, and do not cite it as research. But do not tell the team the brief misquoted Google — it did not, and that error is checkable in one fetch and would discredit the rest of the (correct) methodological critique.

**Evidence:** The claim's two load-bearing, checkable specifics are both false against the single source it itself cites (https://design.google/library/expressive-material-design-google-research).

1. "The '45+' cutoff does not appear in Google's own article." FALSE. It appears verbatim: "we've seen a dramatic erasure of age effects in fixation times, helping 45-plus-year-old users perform on par with their younger counterparts." The 45+ cutoff is Google's own wording, not a downstream invention.

2. "The separate '87% preference among 18-24 year olds' figure appears in secondary coverage but I could not confirm it on a Google primary source." FALSE. It is on the primary source, in the same article: "well-applied, expressive design is strongly preferred by people of all ages, with that preference being particularly strong — up to 87% — among 18-to-24-year-olds."

3. "No ages, no n" — FALSE as stated. Two age bands are published (45-plus, 18-to-24) and a participant count is published (46 studies, 18,000+ participants, 10 apps). What is genuinely absent is per-study n, effect sizes, and CIs.

4. "Parity, not 'biggest gains'" — this framing distinction does not survive either. Google's own construction is differential by explicit design: the stated baseline is "usability tests typically find that older adults take longer to visually locate key UI elements," and the stated result is that this gap was "erased." A gap that exists at baseline and is erased at treatment logically means the 45+ group improved MORE than the younger group. "Biggest gains for users 45+" is a compressed but faithful reading of Google's wording, not a distortion of it.

5. The CHI paper sub-point is moot: searches surfaced no CHI paper on M3 Expressive at all, so "the CHI paper's public abstract does not surface an age-effects result" rests on a paper I could not establish exists. It cannot support the refutation.

WHAT SURVIVES (the researcher's real point, correctly stated): design.google is a marketing blog post, not peer-reviewed research. There is no published methodology, no effect size, no CI, no per-study n, no per-condition sample, no preregistration, and no linked paper. The "up to four times faster" figure is the OVERALL fixation result and is NOT attached to the age result — no number is attached to the age-erasure claim specifically. "Up to 87%" and "up to four times" are both ceiling figures, not central tendencies, and a ceiling figure is not an effect. So the age-effects claim is an unquantified assertion from a vendor blog about its own product. That is a sound reason for LOW confidence and for not designing around it. But the correct objection is "unsubstantiated by methodology," NOT "misquoted / differently shaped / absent from the source" — the brief quotes Google accurately.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "m3-expressive-deep" made this claim, and a design decision depends on it.

CLAIM: The 'biggest gains for users 45+' framing in the brief is not supported by any published number — and the actual claim is weaker and differently shaped.
DETAIL: Google Design's exact wording: 'M3 Expressive design enabled older users to spot key interactive elements on the screen just as fast as younger users across 10 apps tested', described as 'a dramatic erasure of age effects in fixation times', against the baseline that 'Usability tests typically find that older adults take longer to visually locate key UI elements'. Note: this is parity, not 'biggest gains', and no ages, no effect sizes, no n, no CI are published. The '45+' cutoff does not appear in Google's own article. The CHI paper's public abstract does not surface an age-effects result. The separate '87% preference among 18-24 year olds' figure appears in secondary coverage but I could not confirm it on a Google primary source. LOW confidence on all age claims — do not design around them.
CLAIMED SOURCES: https://design.google/library/expressive-material-design-google-research
CONFIDENCE: low

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

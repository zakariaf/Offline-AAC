# m3-expressive-deep--the-46-studies-18-000-participants-umbrella

> Phase: **verify** · Agent `af3c5c32017445195` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** The claim's thrust is correct but three specifics are wrong, and it misses the biggest problem. (a) The Google Design page DOES contain an academic citation (Caleb Warren et al. 2019, linked) and DOES report statistics (87%, 32%, 34%, 30%) — what it lacks is methodology: no sample sizes, CIs, or significance tests for its own figures. Say "methodology-free," not "citation-free." (b) The claim contradicts itself by asserting "no peer-reviewed papers" while also asserting one study is published; the n=48 study IS peer-reviewed — Bentley, Schmidt, Sheehan, Gallardo & Wang, "Usability Hasn't Peaked: Exploring How Expressive Design Overcomes the Usability Plateau," CHI '26, DOI 10.1145/3772318.3790373. (c) The "2022-2025" range is inferred; the page says "over the past three years" with a 2022 origin story. MOST IMPORTANTLY, the claim should have flagged that Google's "up to four times faster" contradicts its own peer-reviewed paper, which reports 33% faster fixation and 20% faster task completion at n=48. Use 33%/20% or nothing; discard "4x."

**Evidence:** CORE THESIS: SURVIVES. The 46/18,000 figure is real program framing, and exactly one peer-reviewed study underpins the usability claims, n=48.

VERIFIED TRUE:
1. design.google states verbatim: "Through 46 separate research studies with hundreds of designs, and more than 18,000 participants from around the world." Methods listed exactly as claimed: eye tracking, surveys and focus groups, experiments, usability.
2. Three-year duration confirmed: "Over the past three years, we've explored the implications of this conversation, iterating through dozens of rounds of design and research..." The 2022 start is corroborated by the page's own origin story (a 2022 research intern studying Material Design sentiment). The explicit "2022-2025" range is a reasonable reconstruction, not a page quote.
3. Exactly ONE published study exists. research.google's "Google at CHI 2026" accepted-papers list contains one expressive-design paper and no others: "Usability Hasn't Peaked: Exploring How Expressive Design Overcomes the Usability Plateau," Bentley, Schmidt, Sheehan, Gallardo, Wang — CHI '26, Barcelona, April 13-17 2026, DOI 10.1145/3772318.3790373. Sample: 48 participants, 10 applications, in-lab eyetracking glasses, randomized order, Expressive vs. M3 baseline.
4. The design.google page contains NO link to that CHI paper, and never discloses the n=48 sample size or any sample size for the eye-tracking study. It credits seven researchers by name (Patrie, Barnes, Herdel, Thornley, Price, Khwaja, Simpson) — none of whom are the CHI paper's authors — with no links to published work.

REFUTED SPECIFICS (three errors):
1. "No peer-reviewed papers, citations... are provided" is FALSE. The page DOES carry an external academic citation — Caleb Warren et al. (2019) on product trendiness — with a live link (goo.gle/44pZMdd).
2. "No statistical analysis details are provided" is FALSE as written. The page provides numerous statistics: "up to 87% — among 18-to-24-year-olds," "32% increase in subculture perception," "34% boost in modernity," "30% jump in rebelliousness." What is actually absent is METHODOLOGY behind them — no sample sizes, no confidence intervals, no significance tests, no denominators. That is a different and more precise criticism.
3. The claim is internally inconsistent: it asserts "no peer-reviewed papers" while simultaneously asserting "only one study (n=48) is published." The n=48 study is not merely "published" — it is peer-reviewed at CHI, the top HCI venue. The claim understates its own evidence base.

MATERIAL FINDING THE CLAIM MISSED — this strengthens the researcher's skepticism and is the real hazard:
The headline "four times faster" does NOT match the peer-reviewed paper. design.google says: "Participants were able to spot key UI elements up to four times faster in the M3 Expressive designs." The CHI paper reports users "fixated on the correct screen element for a task 33% faster, completed tasks 20% faster." 33% faster is not four times faster — 4x implies ~300%, an order of magnitude above the published effect. The blog's "up to" is doing enormous work; it appears to report a cherry-picked best-case cell (the page also cites an email-button example: "their eyes saw the button four times faster"), not the study's aggregate result. The defensible, peer-reviewed numbers to design against are 33% fixation / 20% task completion, n=48.

BOTTOM LINE: Treat 46/18,000 as program-scale marketing framing, exactly as the researcher argues — that part is sound and the design decision can rest on it. But correct the reasoning: the page is not citation-free or statistics-free; it is methodology-free. And do not carry "4x faster" forward at all — it is unsupported by the only peer-reviewed evidence, which reports 33%.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "m3-expressive-deep" made this claim, and a design decision depends on it.

CLAIM: The '46 studies / 18,000 participants' umbrella figure is real as a program description but is NOT the evidence base for any specific claim — only one study (n=48) is published.
DETAIL: Google Design states 46 separate research studies, 18,000+ participants worldwide, 3-year duration (2022-2025), dozens of design iterations. Methods listed: eye tracking, surveys and focus groups, experiments, usability. But: 'No peer-reviewed papers, citations, or statistical analysis details are provided' on the Google Design page — it credits researchers by name with no links to published studies. So 46/18,000 is a program-scale number being used to lend weight to claims whose actual published sample is 48. Treat the 18,000 as marketing framing, not as statistical power behind the usability claims.
CLAIMED SOURCES: https://design.google/library/expressive-material-design-google-research, https://www.androidauthority.com/google-material-3-expressive-features-changes-availability-supported-devices-3556392/
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

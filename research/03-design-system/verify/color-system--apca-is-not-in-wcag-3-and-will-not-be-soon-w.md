# color-system--apca-is-not-in-wcag-3-and-will-not-be-soon-w

> Phase: **verify** · Agent `a347a8c6700dafe05` · Run `wf_f237e8a6-694`

## Result

## Verdict

**CONFIRMED**

**Correction:** The claim is substantively correct and the design decision it supports is sound. Four refinements:

(1) SOURCING ERROR — "the draft states verbatim" points to the wrong document. The sentence appears only in the WCAG 3 Editor's Draft (w3c.github.io/wcag3/guidelines/, 8 April 2026). The published TR Working Draft (w3.org/TR/wcag-3.0/, 03 March 2026) contains no such statement. Cite the Editor's Draft.

(2) CITATION DOES NOT SUPPORT ITS CLAIM — APCA_in_a_Nutshell.html never mentions BridgePCA. Correct sources are github.com/Myndex/bridge-pca and bridgepca.com. Additionally that page asserts APCA is "the candidate contrast method for the future WCAG 3," which is false as of 2026 and should not be propagated.

(3) "No replacement algorithm is proposed" is true but slightly overstated. The editor's note presupposes the eventual algorithm "will include a size/weight factor" — a property APCA has and WCAG 2's math lacks — and w3c/wcag3 issue #29 (APCA peer review / visual contrast guideline) remains OPEN with activity into 2025. Roselli himself: "I have no idea if APCA, whatever version, will come back to WCAG3." The door is ajar, not shut. This does not weaken the recommendation; uncertainty about WCAG 3's algorithm is a further reason to ship 2.x AA.

(4) "ADA" is imprecise. The WCAG 2.1 AA technical standard is ADA Title II (state/local government entities) only; Title III (private business) has no adopted technical standard and courts reference WCAG by convention. For an AAC app this cuts toward the claim rather than against it, since AAC is heavily procured by school districts, which are Title II entities — meaning WCAG 2.1 AA may be a hard procurement requirement, not just a norm.

(5) UNVERIFIED DEPENDENCY — "The proposed palette clears AAA (7:1) on all primary text pairs" was not checked; no hex values were provided. Verify against real pairs before relying on it to dissolve the tension.

**Evidence:** Attempted refutation failed; every load-bearing assertion verified against primary sources.

1. VERBATIM QUOTE — CONFIRMED, but in the Editor's Draft, not the TR draft. w3c.github.io/wcag3/guidelines/ contains the editor's note: "The contrast algorithm used in WCAG 3 is yet to be determined. For this draft, the requirement assumes the algorithm will include a size/weight factor." The TR Working Draft (w3.org/TR/wcag-3.0/, dated 03 March 2026) contains NO such sentence and does not mention APCA at all.

2. APCA REMOVAL — CONFIRMED. Roselli (adrianroselli.com/2026/04/wcag3-contrast-as-of-april-2026.html, 10 Apr 2026, upd. 13 Apr) documents APCA marked exploratory, removed in the July 2023 WD after failing to gain WG support within the 6-month exploratory window. Neither the TR WD nor the Editor's Draft mentions APCA.

3. ~2030 ESTIMATE — CONFIRMED verbatim: "WCAG3 is years away from being done, perhaps 2030 at the soonest."

4. REGULATORY ANCHOR (the strongest part) — CONFIRMED. EN 301 549 v3.2.1 (incorporating WCAG 2.1 AA) is the in-force presumption-of-conformance standard for the EAA, enforcement began June 2026; V4 in late-stage drafting still targets WCAG 2.2 — still 2.x. DOJ ADA Title II final rule (24 Apr 2024) adopts WCAG 2.1 Level AA; compliance dates were EXTENDED in April 2026 (Fed. Reg. 2026-07663) to 26 Apr 2027 / 26 Apr 2028. No regulatory instrument references WCAG 3.

5. BRIDGEPCA — CONFIRMED as existing and doing what is claimed. github.com/Myndex/bridge-pca: "A simplified version of the APCA math to bridge from WCAG_2 contrast math to the future, while being 100% backwards compatible with WCAG_2 contrast." Somers, commenting on Roselli's post: "designed for exactly that — it automatically passes WCAG 2, but extends improved accommodation using APCA."

6. THRESHOLDS — 4.5:1 body / 3:1 large+non-text are correct WCAG 2 AA values.

7. RECOMMENDATION MATCHES SOURCE — Roselli advises APCA users either (1) choose colors that also meet WCAG 2, or (2) document non-compliant choices and prepare legally. The claim's practical consequence is what the cited source actually recommends.

MARKETING-VS-RESEARCH CHECK: The cited APCA_in_a_Nutshell page self-describes APCA as "the candidate contrast method for the future WCAG 3" — false as of 2026. This is author (Somers/Myndex) framing, not W3C position. The researcher cited this page but reached the OPPOSITE, correct conclusion; they did not repeat the marketing. Credit where due, but the citation is a hazard for downstream readers.

NOT VERIFIABLE: "The proposed palette clears AAA (7:1) on all primary text pairs" — no palette or hex values supplied. This clause is what makes the tension "never actually bind," so it carries real weight and should be computed against actual color pairs before being relied on.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "color-system" made this claim, and a design decision depends on it.

CLAIM: APCA is not in WCAG 3 and will not be soon; WCAG 2.x remains the only compliance target through this app's lifetime
DETAIL: APCA was marked exploratory and removed from the WCAG 3 working draft in July 2023 after failing to gain working-group consensus. As of April 2026 the draft states verbatim: 'The contrast algorithm used in WCAG 3 is yet to be determined.' No replacement algorithm is proposed. Roselli estimates WCAG 3 completion ~2030 or later. Practical consequence: ship WCAG 2.x AA (4.5:1 body / 3:1 large+non-text) as the compliance floor because that is what EAA/ADA/Play Store expectations reference, and use APCA Lc as the design tool for dark-mode judgment. Somers' own BridgePCA exists precisely to satisfy both. The proposed palette clears AAA (7:1) on all primary text pairs, so this tension never actually binds.
CLAIMED SOURCES: https://adrianroselli.com/2026/04/wcag3-contrast-as-of-april-2026.html, https://git.apcacontrast.com/documentation/APCA_in_a_Nutshell.html
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

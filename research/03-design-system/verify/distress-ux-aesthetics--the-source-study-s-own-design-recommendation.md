# distress-ux-aesthetics--the-source-study-s-own-design-recommendation

> Phase: **verify** · Agent `afaab5c9ecac806a7` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** The quotes are accurate; the framing is not. Correct version: Martin & Nagalakshmi §6.5 (v3 only) propose same-app simplification as one of three *research directions* they explicitly flag as untested — "we have not found any evidence of research or products" doing it — and they tell implementers to prototype and test with the target user base. It is a well-sourced hypothesis, not "the architectural answer," and citing it as non-speculative misrepresents the paper.

Constraint (a) — user-invoked, never automatic — is the strongest part of the claim and survives: §5.8.1 gives 6/12 rejecting automatic personalization, the highest "never" rating of any feature. Treat that as the paper's real load-bearing finding.

Constraint (b) does NOT license "may change color, must never move a tile." The paper says only "does not impede motor plans," and its own item (2) contemplates simplifying "colors or board." The geometry-invariance rule is a sound inference from AAC motor-planning literature, but it is the researcher's design decision, not the study's finding — so it cannot be cited to this paper. If you want it evidence-backed, source it to the motor-planning literature directly.

Practical upshot: the design decision (user-triggered, color-only, fixed geometry) is defensible and consistent with the paper. Just log it as "our inference, aligned with an untested research direction in a 12-participant preprint," not "the study says so." Cite as §6.5, arXiv:2404.17730v3 — pin the version, or the citation breaks.

**Evidence:** QUOTES: ALL EXACT. I extracted the full text of arXiv:2404.17730 with pypdf and grepped it directly (not via a summarizer). Against v3 (4 Aug 2025, current), §6.5 "Same-app Switching" reads verbatim:

"We identify three examples that we believe would be worthwhile research directions for same-app switching. (1) Easily switching between direct and indirect input (§5.1.6), (2) simplifying the app's colors or board when the user is overwhelmed (§5.3.3), and (3) combining symbol-based and text-based AAC within the same app (§5.1.2,5.3.1). The application should integrate these in an intentional way that keeps the user in control (§5.8.1) and does not impede motor plans (§5.1.1)."

Confirmed: §6.5 title; item (2) of 3; the constraint sentence immediately following; all three cross-refs resolve in v3 (§5.3.3 General customization, §5.8.1 Control of features, §5.1.1 Typing). "needing to swap motor plans back and forth a lot" is a real participant quote in §5.1.1. Constraint (a) is WELL supported — §5.8.1: "half of our participants (6) said that automatic personalization was never a good feature, more than any other feature," plus "if it's automatically adjusting itself in response to how I interact with it, I hate that." The researcher did not invent anything.

FOUR FAILURE MODES SURVIVE:

1. "NOT SPECULATIVE" IS FALSE — the paper says the opposite, in its own words. §6 is titled "Research Directions," not recommendations. Its intro: "these guidelines should be treated as such: guidelines. Any AAC applications that are being made should be prototyped and tested with their target user base." §6.5 itself: "We have not found any evidence of research or products that attempt to switch between the two separate modalities." The conclusion calls them "seven novel research directions." The word "recommendation" never appears in §6.5. This is an untested hypothesis the authors flagged for future work — the claim inverts its epistemic status.

2. CONSTRAINT (b)'s GLOSS IS THE RESEARCHER'S, NOT THE PAPER'S — and the paper's own text cuts against it. "may change COLOR but must never move a tile" appears nowhere; the paper never discusses tile geometry or position invariance. Worse, item (2) says simplify "the app's colors OR BOARD" — simplifying the *board* is precisely a geometry change. The paper's own recommendation contains the tension the claim says it resolves. "Progressive disclosure" and "release valve" appear nowhere in the paper.

3. THE MOTOR-PLAN COMPLAINT IS n=1 AND ABOUT A DIFFERENT THING — one participant, about swapping between an in-app keyboard and an OS-native keyboard (§5.1.1 Typing), not tile positions within a board. Calling it "a named complaint" oversells a single data point, and the domain transfer is unstated.

4. VERSION FRAGILITY — §6.5 does NOT exist in v2 (27 Sep 2024), which restructured §6 into "Guidelines for Improving AAC Use" (only 6.1–6.3) and deleted Same-app Switching entirely; §-numbering also shifts (v2's §5.8.1 is "Communication not being taken seriously," not "Control of features"). A bare "§6.5" citation is version-dependent and resolves only against v3.

PROVENANCE: 12 interviewees, thematic analysis, arXiv preprint (CC BY 4.0), no stated venue or peer review. The color evidence is thin: "no bright colors (3)" and "not visually overwhelming (2)" — 3 and 2 of 12.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "distress-ux-aesthetics" made this claim, and a design decision depends on it.

CLAIM: The source study's own design recommendation IS the low-stimulus release valve — including its two binding constraints. This is the architectural answer and it is not speculative.
DETAIL: Martin & Nagalakshmi §6.5 'Same-app Switching', verbatim recommendation (2) of 3: 'simplifying the app's colors or board when the user is overwhelmed (§5.3.3)'. Followed immediately by: 'The application should integrate these in an intentional way that keeps the user in control (§5.8.1) and does not impede motor plans (§5.1.1).' Two constraints fall out: (a) user-invoked, never automatic; (b) must not disturb motor plans — i.e. it may change COLOR but must never move a tile. A participant elsewhere in the paper: 'motor plans back and forth a lot' was a named complaint. This directly answers 'does progressive disclosure break the fixed-layout rule?' — No, provided only the surface changes and the geometry is invariant.
CLAIMED SOURCES: https://arxiv.org/pdf/2404.17730
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

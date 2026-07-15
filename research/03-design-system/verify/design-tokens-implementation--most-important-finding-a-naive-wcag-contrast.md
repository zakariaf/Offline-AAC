# design-tokens-implementation--most-important-finding-a-naive-wcag-contrast

> Phase: **verify** · Agent `af835b8d892b0458e` · Run `wf_f237e8a6-694`

## Result

## Verdict

**CONFIRMED**

**Correction:** The claim is correct as stated. Two gaps concern what the replacement assertion now fails to cover:

1. "AND STATES" — The SC reads "required to identify user interface components AND STATES." A text label self-identifies the COMPONENT but not the STATE. For an AAC app with selected/pressed tiles in a sentence bar, whatever conveys "selected" IS required-to-identify information and does need 3:1 against adjacent colors. The invoked exemption covers component identification only. (Nuance, per the same doc: 1.4.11 "does not directly compare the focused and unfocused states" — state-vs-state delta is not required, but the state indicator against its adjacent color is.) `max(fillStep, borderStep) >= 1.5` does not encode this. Recommend a separate state-affordance assertion.

2. FOCUS INDICATOR IS THE SURVIVING 3:1 — Same doc: "Even when a control does not need to have a visual boundary indicating its hit area, it will still need to have a sufficiently contrasting focus indication." AAC is switch-scanned/keyboard-driven, so this binds harder here than in most products. The suite just removed its only 3:1 assertion; if nothing replaced it on the focus surface, a genuinely applicable guard is now unguarded. Bindingness precision: 2.4.7 Focus Visible is AA; 2.4.13 Focus Appearance (the actual 3:1 focused-vs-unfocused, 2 CSS px perimeter rule) is AAA — do not overstate it as AA.

Ironically, the claim's own stated lesson applied one clause further — to "and states" — would have caught gap 1.

**Evidence:** Tasked with refuting; could not — the cited primary source substantiates the claim nearly verbatim.

CORE CLAIM CONFIRMED. The W3C Understanding doc for SC 1.4.11 states: "If a control has visible content (such as text or a sufficiently contrasting icon), which helps users identify the presence of the control, then a border or other indication of the overall boundary of the hit area is not required, as is therefore not subject to non-text contrast requirements." This is a direct confirmation of the claim's "the border is decorative / same exemption a borderless text button gets." The borderless-button example is literally in the doc: "a button without a visual boundary – the button's text is sufficient to indicate the presence of the control."

NORMATIVE TEXT VERIFIED (w3.org/TR/WCAG22/): 3:1 applies to "Visual information required to identify user interface components and states, except for inactive components or where the appearance of the component is determined by the user agent and not modified by the author." The applicability clause the claim relies on is real and was read correctly. A phrase tile carrying its own 4.5:1 text label is self-identifying; the tileBorder-vs-surface 1.52:1/1.78:1 failures were a mis-encoded assertion, not a palette defect. Diagnosis and remedy are both sound.

BRIEFED FAILURE MODES — NONE PRESENT: no marketing stat repeated as research (no M3 Expressive / Lexend numbers invoked); no design folklore; no Flutter version/API rot (no Flutter API named); no invented specifics (the cited source is the correct canonical URL and says what is claimed); no license claims. Unverifiable project internals (1.52:1/1.78:1 measurements, 12 tiles, 3dp border, 9-line comment) are internal state, not claims about the world — not counted against the claim. The claim is also epistemically well-behaved: it explicitly names its replacement rule non-WCAG rather than laundering it as a standard.

TWO GAPS IN COVERAGE (scope of the replacement test, not errors in the claim) — see correction.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "design-tokens-implementation" made this claim, and a design decision depends on it.

CLAIM: MOST IMPORTANT FINDING: a naive WCAG contrast test actively pushes this design toward the grey rectangle grid the founder banned. The 3:1 border rule does not apply to these tiles.
DETAIL: My first test run failed on tileBorder-vs-surface at 1.52:1/1.78:1 against WCAG 1.4.11's 3:1 for non-text UI components. The naive fix — darken the borders — draws a hard 3:1 line around all 12 tiles, which IS the 2014 enterprise grid. But 1.4.11 requires 3:1 only where the visual information is REQUIRED TO IDENTIFY the component. A phrase tile carries its own 4.5:1 text label; it is self-identifying, the same exemption a borderless text button gets. The border is decorative. So the assertion was wrong, not the palette. Replaced with an honestly-named non-WCAG rule: 'edge findability' asserts `max(fillStep, borderStep) >= 1.5` for light/dark and `>= 3.0` for high-contrast (where the 3dp border IS load-bearing). Requiring BOTH fill separation and a border is what produces heavy-handed UI — asserting the max lets the designer choose which carries the edge. The rationale is a 9-line comment in the test, because the next person WILL try to 'fix' this to 3:1. This is the general lesson: a design system verified by CI is only as good as whether the assertions encode the right rule, and copying WCAG thresholds without reading the applicability clause makes the tests a force for ugliness.
CLAIMED SOURCES: https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html
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

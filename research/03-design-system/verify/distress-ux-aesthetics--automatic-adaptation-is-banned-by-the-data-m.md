# distress-ux-aesthetics--automatic-adaptation-is-banned-by-the-data-m

> Phase: **verify** · Agent `acb57c16522890ece` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Keep the design conclusion "the low-stimulus mode must be user-initiated, not automatic" — that is supported. Drop the justification and the stronger inference.

Accurate restatement: In Martin & Nagalakshmi (arXiv:2404.17730, n=12 autistic adults, preprint), 6/12 participants rated "saving personalized information automatically" as a feature they would never allow — the most "never" ratings of the 7 features tested (§5.8.1, Figure 4). That item was a PRIVACY/data-retention question, not a question about auto-adapting interfaces. Participant quotes do independently express dislike of interfaces that adapt themselves ("if it's automatically adjusting itself in response to how I interact with it, I hate that"), and the same participant explicitly endorses the alternative: "I'm fine with it if I'm choosing to make the changes like deliberately adjusting settings."

Correct the implication, which is inverted. The paper's §6.3 recommends, citing §5.8.1: any non-core feature should be "opt-in rather than opt-out... users must know that the feature is there so that they can decide whether or not to turn it on." And §6.5 names "simplifying the app's colors or board when the user is overwhelmed" as a worthwhile direction that "should integrate these in an intentional way that keeps the user in control (§5.8.1)." So the paper supports shipping a discoverable, off-by-default, manually triggered low-stimulus mode — not omitting the capability. The "mere presence of the knob is objectionable" reading generalizes a single participant (n=1 code) against the authors' own stated guideline.

Also fix: the quote is "automatically adjusting itself," not "dynamically adjusting itself." And do not describe this as "banned by the data" or as a quantitative finding — it is descriptive counts from 12 qualitative interviews in a preprint with placeholder ACM ISBN/DOI, with no peer-reviewed venue confirmed.

**Evidence:** QUOTES VERIFIED. Paper is real: "Aging Up AAC: An Introspection on Augmentative and Alternative Communication Applications for Autistic Adults," Lara J. Martin & Malathy Nagalakshmi, arXiv:2404.17730, 18pp, n=12 in-depth interviews with autistic adults. Extracted full text from the PDF. §5.8.1 exists and reads verbatim: "Further, half of our participants (6) said that automatic personalization was never a good feature, more than any other feature in our quantitative analysis (Figure 4)." The ClaroCom quote is exact, including "I don't even like that it has those knobs. I'd rather it just plain didn't do any of that."

MISQUOTE: paper says "if it's AUTOMATICALLY adjusting itself in response to how I interact with it, I hate that" — not "dynamically." The researcher also truncated the preceding clause, which is pro-manual-control, not anti-feature: "I'm fine with it if I'm choosing to make the changes like deliberately adjusting settings or changing the layout of AAC app, for instance."

REFUTATION 1 — CONSTRUCT SWAP. The rated feature (Appendix B.3, row 4) is "saving personalized information (e.g. favorite TV show, best friend's name) automatically." The battery was administered "with the framing of privacy" and the scale measures DATA PERSISTENCE (Never Allow / Current Conversation / Across Conversations / Okay). The 6/12 "never" concerns automatic DATA RETENTION, not automatic UI adaptation. An auto-detect-distress mode persists no data. The claim silently substitutes one construct for the other.

REFUTATION 2 — THE PAPER'S OWN §6.3 CONTRADICTS THE IMPLICATION, CITING §5.8.1 AS ITS BASIS: "Any feature that is not considered part of the core functionality of the application should be 'opt-in' rather than 'opt-out' (§5.8.1). That is, users must know that the feature is there so that they can decide whether or not to turn it on." The claim reads §5.8.1 as "don't ship the knob at all"; the authors read their own §5.8.1 as "ship the knob, off by default, and make it discoverable." The "mere presence of the knob was objectionable" reading rests on one participant — the paper codes it n=1 ("People do not want to be forced into certain features (1)").

REFUTATION 3 — THE PAPER EXPLICITLY RECOMMENDS BUILDING THE LOW-STIMULUS MODE. §6.5 Same-app Switching lists as a worthwhile research direction: "simplifying the app's colors or board when the user is overwhelmed (§5.3.3)... The application should integrate these in an intentional way that keeps the user in control (§5.8.1) and does not impede motor plans." §5.3.3 supports the need: 7/12 wanted an app that does not feel overwhelming; 3 specified "no bright colors — especially when they are already feeling overwhelmed."

REFUTATION 4 — OVERCLAIM ON EVIDENCE STRENGTH. "Banned by the data" rests on descriptive counts from n=12. 6/12 "never" also means half did not say never. "More than any other feature" holds only on the never-count axis; on a different axis the paper notes verbatim logging was rejected more universally ("none of our participants were comfortable having logging verbatim always on"). Figure 4 is a 12-person rating table, not a powered quantitative analysis. The arXiv PDF carries placeholder ACM metadata (ISBN 978-x-xxxx-xxxx-x/YY/MM, DOI 10.1145/nnnnnnn.nnnnnnn); no peer-reviewed venue confirmed — treat as preprint.

NET: sourcing is unusually accurate; the inference drawn from it is not. "Low-stimulus mode should be manual/user-initiated" is genuinely supported. "Do not ship an auto-detect feature even switched off by default" is contradicted by the cited section's own guideline.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "distress-ux-aesthetics" made this claim, and a design decision depends on it.

CLAIM: Automatic adaptation is banned by the data — more strongly than any other feature tested. The low-stimulus mode must be manual.
DETAIL: Martin & Nagalakshmi §5.8.1: 'half of our participants (6) said that automatic personalization was never a good feature, more than any other feature in our quantitative analysis (Figure 4).' Participant quote: 'if it's dynamically adjusting itself in response to how I interact with it, I hate that.' Another: 'I turned off every single prediction that ClaroCom [has], including its built-in support for learning automatically. I don't even like that it has those knobs. I'd rather it just plain didn't do any of that.' Note the second quote goes further than opt-out: the mere PRESENCE of the knob was objectionable. Implication: don't ship an auto-detect-distress feature even switched off by default.
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

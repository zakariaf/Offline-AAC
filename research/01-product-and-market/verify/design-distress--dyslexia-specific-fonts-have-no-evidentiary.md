# design-distress--dyslexia-specific-fonts-have-no-evidentiary

> Phase: **verify** · Agent `a00f9c683e2621dad` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Corrected claim: "There is no replicated evidence that dyslexia-specific fonts improve reading performance, and one 2017 Annals of Dyslexia study (Wery & Diliberto, n=12 children aged 9-12) found OpenDyslexic measurably decreased reading fluency and accuracy versus Arial and Times New Roman (IRD -49.65% to -88.65% fluency, -63.62% to -73.53% accuracy), with no participant in that study preferring it. A 2020 systematic review (Kuster et al., Res Dev Disabil 103:103672) reached the same null conclusion. HOWEVER: (a) the evidence base is children on isolated word/letter-naming tasks, not adults reading connected text or scanning AAC tiles; (b) the one adult eye-tracking study — Franzen, Stark & Johnson 2019, a conference abstract never published in full — reported OpenDyslexic IMPROVED comprehension in adults with dyslexia; (c) Broadbent (2023) found 58% of preference-expressing students preferred OpenDyslexic on aesthetics, with no score difference, so 'nobody prefers it' is false; (d) letterform gimmickry is unsupported (Galliussi et al. 2020: 'no effect from the letterform'), but the proposed alternative levers are not evenly evidenced — Galliussi found increased inter-letter spacing without matched inter-word spacing REDUCES reading speed, and size/weight/contrast guidance comes from WCAG, not dyslexia font research. Design implication: make OpenDyslexic an optional user-selectable setting rather than a default or an exclusion."

**Evidence:** CORE CLAIM SURVIVES — and the strongest wording checks out.

1) Wery & Diliberto, "The effect of a specialized dyslexia font, OpenDyslexic, on reading rate and accuracy," Annals of Dyslexia (2017 issue; online 2016), DOI 10.1007/s11881-016-0127-1, PMC5629233. VERIFIED against the PMC full text. Single-subject alternating-treatment design, OpenDyslexic vs Arial and Times New Roman on letter naming, word reading, nonsense word reading. Authors state verbatim: "OD produced negative results, or decreased students' outcomes compared to both Arial and TNR." IRD effect sizes: fluency -49.65% to -88.65%; accuracy -63.62% to -73.53%; CIs exclude zero. Authors define a negative IRD as occurring "when the treatment deteriorates below baseline levels." So "actively reduced speed and accuracy" — the part I most expected to be an overreach — is accurate, not embellished. Preference finding verified: "none of the participants reported preferring to read material presented in that font."

2) Kuster et al., "Dyslexie font does not benefit reading in children with or without dyslexia," Annals of Dyslexia 68:25-42 (2018). VERIFIED. The DOI the researcher cited (10.1007/s11881-017-0154-6) resolves correctly to this paper — I initially flagged it as a mismatch and it is not. Two experiments (n=170; n=102 dyslexic + 45 non-dyslexic): no faster/more accurate reading in Dyslexie; participants preferred Arial/TNR.

3) The 2020 systematic review exists: Kuster, van Weerdenburg, Gompel & Bosman, "Dyslexia and font style: A systematic review of reading performance," Research in Developmental Disabilities 103:103672. DOI 10.1016/j.ridd.2020.103672 resolves to Elsevier S0891422220301025; title confirmed on Semantic Scholar. CAVEAT: paywalled — I could NOT read the primary text. The quoted sentence ("There is currently no evidence that these fonts lead to improved reading performance") is attributed consistently across multiple independent secondary sources but I could not verify it verbatim at source. Treat the quotation marks as unconfirmed.

FOUR CORRECTIONS:

A) "No evidentiary support" is OVERSTATED. Franzen, Stark & Johnson (2019), "The dyslexia font OpenDyslexic facilitates visual processing of text and improves reading comprehension in adult dyslexia," Annals of Eye Science AB004 — eye-tracking study of ADULTS with and without dyslexia reading IReST texts, reporting OpenDyslexic IMPROVED comprehension (larger gains for dyslexics), with reduced fixation duration and fixation-to-saccade ratio. Speed unaffected. This is a conference abstract that appears never to have been published as a full peer-reviewed paper (the authors' 2020/2021 full papers are on a different topic — visual sampling strategy, not fonts). It is weak, unreplicated evidence — but it is not zero, and it is the only study in this literature run on adults reading connected text. Correct framing: "no reliable or replicated evidence," not "no evidentiary support."

B) The preference generalization is REFUTED for the target population. Broadbent (2023, UCL EdD thesis) compared Arial and OpenDyslexic with dyslexic and non-dyslexic students: of the 86% who expressed any preference, 58% preferred OpenDyslexic, citing aesthetics — with no difference in test scores. So "no participant preferred it" is true ONLY of Wery's 12 children, not of the literature. This directly undercuts the dignity argument: some readers actively like the letterforms.

C) POPULATION MISMATCH — the biggest problem for this product. Wery is n=12 elementary students aged 9-12 on isolated letter/word/nonsense-word naming. Kuster is children. This app targets autistic ADULTS and teens. The authors themselves flag that they "did not measure comprehension of connected text — the end goal of reading," call it a pilot needing replication, and note single-subject designs require "multiple independent studies with similar results" before an intervention is deemed evidence-based. Generalizing a 12-child nonsense-word-naming result to adult AAC phrase-tile scanning is a real inferential leap — and the one adult study that exists (Franzen) points the other way.

D) "The reliable typographic levers are size, weight, line spacing, and contrast" is the researcher's OWN inference, NOT supported by any cited source, and partly CONTRADICTED. The Nessy page recommends only spacing — nothing on size, weight, or contrast. Worse, Galliussi et al. (2020, PMC7188700) found increased inter-letter spacing NOT paired with adequate inter-word spacing DECREASED reading speed for both dyslexic and typical readers — spacing is not an unconditionally safe lever. Galliussi does independently corroborate the letterform point: "no effect from the letterform." Weight/contrast guidance traces to general accessibility standards (WCAG 4.5:1 normal text, 3:1 large text), not the dyslexia font literature.

E) "Weighted-bottom letterforms signal 'special needs product'" is unsourced opinion — reasonable as a design position, but it is not a research finding and Broadbent's 58% preference cuts against it.

NET FOR THE PRODUCT DECISION: The decision "don't ship OpenDyslexic as a default/accommodation" survives — the performance evidence is genuinely against it and the researcher did not overstate the central study. But do not carry "no evidentiary support" or "no one prefers it" into the design doc; both are falsified by sources the researcher missed. Safest defensible position: OpenDyslexic has no replicated performance benefit and one study showing decrements in children, so don't impose it as a default — but offer it as an OPTIONAL user-selectable font, since a majority of students in the one preference study that offered a real choice picked it. For a dignity-and-distress product where user control IS the dignity, opt-in beats both imposing it and refusing it.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
PRODUCT IDEA UNDER RESEARCH — "Dignified offline AAC for adults & teens with situational speech loss"

Who it's for: Autistic adults and teens who go non-speaking during shutdowns/meltdowns/sensory overload, plus people with selective mutism, aphasia, or post-seizure speech loss. Communities: r/autism, r/AutisticAdults, r/selectivemutism, AAC communities.
The problem: Mainstream AAC apps are built for young children — cartoon avatars, "parental" account gates, kiddie vocabulary — infantilizing for adults, so they abandon them. Premium options (Proloquo2Go/TouchChat/LAMP) run ~$299 and are iOS-only.
Why offline is essential: It's a disability accommodation, not a networked service. The user must be able to "speak" instantly — in a shop, an ER, a car with no signal, mid-shutdown — with zero login, zero loading, full privacy.
The core job: Tap a phrase/symbol tile (or type) and the phone speaks it aloud, instantly, offline, adult-appropriate design, no account.
MVP: grid of large customizable phrase tiles + "type to speak" box + on-device TTS. Editable categories. No sign-up. Nothing leaves device. Dark, calm, adult visual design.
Risks: TTS must sound acceptable; design must feel adult without being cold; must be usable one-handed by someone in distress.
Target stack: Flutter (cross-platform iOS + Android; user prefers Flutter over React Native).
Today's date: 2026-07-15. Prefer recent sources (2024-2026).


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "design-distress". A product decision depends on it, so it must be right.

CLAIM: Dyslexia-specific fonts have no evidentiary support and one study found OpenDyslexic actively reduced reading speed and accuracy
THEIR DETAIL: A 2017 study (Annals of Dyslexia / PMC5629233) using an alternating-treatment design found no improvement in reading rate or accuracy for individual students with dyslexia or the group as a whole using OpenDyslexic, and no participant preferred reading material in it; the font reduced speed and accuracy. A separate study found the Dyslexie font does not benefit reading in children with or without dyslexia. A 2020 systematic review of several dyslexia fonts concluded there is 'currently no evidence that these fonts lead to improved reading performance.' The reliable typographic levers are size, weight, line spacing, and contrast — not letterform gimmickry. This is also a dignity win: OpenDyslexic's weighted-bottom letterforms visually signal 'special needs product.'
THEIR CLAIMED SOURCES: https://pmc.ncbi.nlm.nih.gov/articles/PMC5629233/, https://link.springer.com/article/10.1007/s11881-017-0154-6, https://www.nessy.com/en-us/dyslexia-explained/understanding-dyslexia/dyslexia-fonts-do-they-work
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>

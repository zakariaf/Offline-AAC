# tile-grid-design--iso-13850-resolves-the-stop-colour-tension-r

> Phase: **verify** · Agent `a265d33d55f2d88fb` · Run `wf_f237e8a6-694`

## Result

## Verdict

**REFUTED**  (refuted)

**Correction:** ISO 13850 does not support "muted red." It does the opposite. The safety-colour system it belongs to specifies red as a bounded, high-chroma region — ISO 3864-4:2011 Table 1 fixes safety red at corner points x 0,705/0,592/0,574/0,663, y 0,295/0,291/0,351/0,337 with luminance factor β 0,07–0,20, against yellow at β 0,45–0,70. Desaturating the red walks it out of that region and collapses the figure/ground contrast the claim says it wants to keep. Exclusivity and conspicuity are complements in the standard, not substitutes.

Three specific corrections: (a) "shall be reserved exclusively for emergency stop applications" is NFPA 79 language that Rockwell explicitly describes as going a step BEYOND the ISO/IEC colour requirements — it is not verified as ISO 13850's own mandate; (b) the faster-than-text claim is stated in the source as what "is expected," a committee hypothesis with no study behind it, not a measured finding; (c) ISO 13850:2015 does not mandate a mushroom head — palm buttons, wires, ropes, bars, handles and foot pedals are all permitted, so the actuator is not uniquely shape-coded, and the shape requirement is ergonomic (palm-operable under stress) rather than a reserved code.

The mechanism also does not transfer. Reservation works because a legally-enforced installed base trained the prior across decades; an app cannot reserve a colour in a first-time user's head.

If the researcher wants a muted stop bar, the honest argument is the one in their own final sentence — a persistent control is furniture, not an alarm, and an AAC app is not a machine that can maim someone in the 300 ms an operator hesitates. That argument stands on its own. It should be made on those grounds, and ISO 13850 should be dropped from it rather than cited in support, because the standard's actual answer to the STOP-colour question is "use a saturated safety red on a high-contrast yellow field."

**Evidence:** The colour FACTS are right; the load-bearing INFERENCE ("so a muted red satisfies both constraints") is refuted by the safety-colour system's own numbers, and two of the three "quotes" are misattributed.

1. CONFIRMED — red on yellow. EN ISO 13850:2015 cl. 4.3.6: "The actuator of the emergency stop device shall be coloured RED. As far as the background exists behind the actuator and as far as it is practicable, the background shall be coloured YELLOW." (gt-engineering, quoting the clause.)

2. CONFIRMED — text/symbols. Cl. 4.3.7: "Neither the actuator nor the background SHOULD be labelled with texts or symbols. Where a symbol is needed for clarification, the symbol from IEC 60417-5638 must be used." Note "should" = recommendation. The claim says "recommends," which is correct.

3. REFUTED — the decisive point. Safety red is colorimetrically SPECIFIED AS SATURATED. I extracted ISO 3864-4:2011 Table 1 from the standard's own text (corner points, CIE D65, 2° observer):
   RED:    x 0,705 0,592 0,574 0,663 | y 0,295 0,291 0,351 0,337 | luminance factor β 0,07–0,20
   YELLOW: x 0,475 0,538 0,470 0,427 | y 0,525 0,462 0,424 0,472 | β 0,45–0,70
The D65 white point is (0,3127, 0,3290). The red region sits at x 0,574–0,705 — hard against the spectral locus, far from white. Muting a red = moving it toward the white point = leaving the region. Saturation is not incidental to safety red; it is the specification. "Muted red" is out of gamut by definition.

4. REFUTED — the claim inverts its own mechanism. It praises "two-channel figure/ground coding" while discarding loudness, but the figure/ground coding IS the loudness: red β 0,07–0,20 against yellow β 0,45–0,70 is an engineered ~3–9x luminance ratio plus maximal chroma separation. Desaturating the red collapses the chromatic channel of the very two-channel code the claim relies on. Exclusivity and conspicuity are complements in the standard, not alternatives — it does all of them at once (saturated red + high-contrast yellow + reservation + palm shape + no text).

5. SELF-CONTRADICTION. The claim cites, as the standard's rationale, "high visibility even in low-light environments or when an operator is under stress" — then concludes visibility isn't the mechanism. Low-light visibility is a luminance/chroma property. You cannot cite conspicuity as the rationale and then discard conspicuity.

6. MISATTRIBUTED QUOTE. The quoted mandate "The RED/YELLOW color combination shall be reserved exclusively for emergency stop applications" is NFPA 79 (US) language, not ISO 13850. Rockwell's whitepaper 800-WP008 is explicit: "NFPA 79 has the same aforementioned color requirements, but TAKES IT A STEP FURTHER stating: 'The RED/YELLOW color combination shall be reserved exclusively for emergency stop applications.'" — i.e. the exclusivity mandate is what NFPA adds BEYOND the ISO/IEC colour requirements. IDEC (a switch manufacturer) repeats the sentence under an "ISO 13850" heading; the claim then quotes it as ISO 13850's mandate. I could not confirm it in ISO 13850's own text (see caveat below). Since the whole claim rests on the word RESERVED, this provenance matters.

7. MARKETING/EXPECTATION AS RESEARCH. The claim states recognition of the colour combination "is FASTER than recognition of text or symbols." The actual source wording (IDEC) is: "it is also EXPECTED that actuation following the recognition of only the color combination of red and yellow is faster than actuation following the recognition of texts/symbols." That is a drafting committee's expectation — no study, no methodology, no sample, no effect size, no citation. The claim upgrades a hypothesis into a finding.

8. OVERSTATED — shape coding. ISO 13850:2015 does NOT mandate a mushroom head. Permitted actuators include push buttons easily activated by the palm of a hand, wires, ropes, bars, handles, and foot pedals without protective cover. Ropes and pedals share no shape with a mushroom, so "uniquely shape-coded" fails; the 2015 revision broadened this precisely away from mushroom-only. (Rockwell says mushroom IS required by EN ISO 13850, but that whitepaper predates the 2015 revision — itself a version-rot trap.) The shape requirement is ergonomic — palm-operable under stress, fast, no fine motor control — not a reserved distinctive code.

9. MECHANISM DOES NOT TRANSFER. Reservation is enforced across a legally-governed installed base: every machine, every factory, decades of exposure, backed by NFPA 79 / IEC 60204-1 conformity. That is a population-level learned prior. A single app cannot "reserve" a colour in a user's head — on first run the user has no prior over the app's palette. Exclusivity within one app is a convention the designer asserts, not a code the user already knows.

SOURCE HYGIENE. Two of three cited URLs do not resolve: machinerysafety101.com/2026/05/18/... returns HTTP 403, and us.idec.com/RD/safety/law/iso-iec/iso13850 302-redirects to the IDEC homepage. The "low-light environments / operator under stress" phrasing traces to the machinerysafety101 blog post, not to ISO 13850 text, yet is quoted as "the standard's stated rationale."

CAVEAT (stated plainly). I obtained a scanned BS EN ISO 13850:2015 PDF but it has no text layer (CCITTFaxDecode images; pdfminer/pypdf return 0 chars), so I could not read clauses 4.3.6/4.3.7 in the primary document myself. Points 1, 2, 6 and 8 rest on sources quoting the clauses (gt-engineering, Rockwell, IDEC, Control Design). Accordingly, the exclusivity and low-light attributions are UNSUBSTANTIATED rather than proven absent. Point 3 — the refutation that carries the decision — does not depend on this: it comes from ISO 3864-4:2011 Table 1, which I extracted from the standard's own text.

WHAT SURVIVES. The design instinct in the last sentence is defensible on its own merits and does not need ISO 13850: an always-present stop control is furniture, and an e-stop genuinely is permanent furniture rather than an appearing alarm. That argument stands by itself. What fails is the appeal to authority — ISO 13850 does not license a muted red, and does not "resolve" the tension. It resolves it in the opposite direction: it specifies a saturated red against a high-luminance yellow.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "tile-grid-design" made this claim, and a design decision depends on it.

CLAIM: ISO 13850 resolves the STOP colour tension: red is findable because it is RESERVED, not because it is loud — so a muted red satisfies both constraints
DETAIL: ISO 13850 requires the emergency-stop actuator be RED on a YELLOW background, and mandates that this red/yellow combination 'shall be reserved exclusively for emergency stop applications.' The standard's stated rationale: the colour scheme ensures high visibility 'even in low-light environments or when an operator is under stress,' and recognition of the colour combination alone is FASTER than recognition of text or symbols — which is why the standard recommends AVOIDING text/symbols on the actuator. It is also shape-coded (mushroom head: palm-operable, physically larger). The transferable insight: the mechanism is exclusivity + two-channel figure/ground coding + shape difference, NOT arousal. Alarm is a property of saturation, motion and sound — none of which this app uses. A large, muted-red, uniquely-shaped bar that is ALWAYS present is furniture, not an alarm; an alarm is something that appears.
CLAIMED SOURCES: https://machinerysafety101.com/2026/05/18/iso-13850-emergency-stop-requirements/, https://us.idec.com/RD/safety/law/iso-iec/iso13850, https://incompliancemag.com/understanding-symbols-emergency-stop/
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

# aac-clinical--arasaac-12-909-symbols-is-cc-by-nc-sa-and-le

> Phase: **verify** · Agent `a635d7d6583d3422d` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**CONFIRMED**

**Correction:** The claim is confirmed. Two refinements: (1) ARASAAC's own terms cite CC BY-NC-SA **4.0** (OpenSymbols still lists 3.0 — the licensor's statement controls). (2) The assertion that CC's NonCommercial definition definitively "covers ad-supported apps" is overstated — CC's own NonCommercial interpretation wiki calls the definition "intentionally flexible" and acknowledges ad-funded models are a case-by-case grey area. The conclusion survives anyway because ARASAAC's own terms are stricter than baseline CC-NC, excluding use "within any product or publication for commercial purposes." Also: the terms do reference "written authorization of the owners of the Copyright" and ARASAAC runs a contact page, so a negotiated grant is undocumented and unprecedented rather than formally impossible. Additional risk the claim omits: ARASAAC is a registered Gobierno de Aragón trademark (collection registered as a collective work, Legal Deposit Z 901-2013), so trademark exposure stacks on copyright; and ShareAlike would contaminate any derivative symbol set independently of the NC issue.

**Evidence:** I attempted to refute this on five attack surfaces. All failed; the claim holds.

1. THE VERBATIM QUOTE — CONFIRMED. aulaabierta.arasaac.org/en/terms-of-use states exactly: "The use of these resources within any product or publication for commercial purposes is therefore excluded from this permission," alongside "DO NOT MAKE COMMERCIAL USE OF THEM." The Spanish original (aulaabierta.arasaac.org/condiciones-de-uso) matches: "NO SE HAGA UN USO COMERCIAL DE LOS MISMOS."

2. THE 12,909 COUNT — CONFIRMED exactly. OpenSymbols lists "12,909 symbols shared" for the ARASAAC repository. Not rounded, not stale.

3. LICENSE + ATTRIBUTION — CONFIRMED, with a version detail the claim wisely left open. ARASAAC's own Spanish terms hyperlink CC BY-NC-SA **4.0**; OpenSymbols still lists **3.0** — a live discrepancy between the two sources the researcher cited. The claim said only "CC BY-NC-SA," so it isn't wrong, but the team should treat 4.0 (the licensor's own statement) as controlling. Attribution requirements confirmed: authors, provenance (Aula Abierta + URL), license type, and copyright holder (Gobierno de Aragón); derivatives must carry the same BY-NC-SA license; the signage guidance separately requires the ARASAAC logo. Ownership confirmed and stronger than stated: the collection is registered in the General Register of Intellectual Property as a collective work of the Diputación General de Aragón (Legal Deposit Z 901-2013), and ARASAAC is a Gobierno de Aragón trademark — so trademark risk stacks on top of copyright.

4. NO DOCUMENTED COMMERCIAL ROUTE — CONFIRMED. No published exception procedure, fee schedule, or commercial-license tier exists on any ARASAAC property. I also searched for precedent of any commercial app holding ARASAAC authorization and found none — the two app-store products surfaced (ChatterBoards AAC, Search on Arasaac) both merely restate the BY-NC-SA notice rather than claim a commercial grant.

5. THE ONE GENUINE OVERSTATEMENT — and it does not change the decision. The claim asserts CC's NC definition "covers paid apps, ad-supported apps, and monetized products" as settled. It isn't. CC's own NonCommercial interpretation wiki says the definition is "intentionally flexible," that "the inclusion of 'primarily' recognizes that no activity is completely disconnected from commercial activity," and concedes "gray areas" exist; CC's own 2009 "Defining Noncommercial" study found genuine uncertainty outside direct resale. Under *generic* CC-NC, ad-supported is a case-by-case question, not an automatic violation. BUT this grey area is closed for ARASAAC specifically, because ARASAAC's own terms are stricter than baseline CC-NC — excluding use "within any product or publication for commercial purposes" — and the licensor's own stated interpretation is what a court would weigh. So the researcher reached the right answer via slightly overconfident reasoning.

Minor: the claim renders CC's definition as "primarily intended for or directed toward commercial advantage or monetary compensation." The actual text is "**not** primarily intended for or directed **towards**..." — the researcher quoted the prohibited-use side without the negation. Cosmetic, not material.

BOTTOM LINE FOR THE PRODUCT DECISION: the conclusion is sound and the confidence level (high) is warranted. ARASAAC is unusable in a paid or ad-supported build without written authorization from the Gobierno de Aragón. One refinement to the framing: the terms do explicitly contemplate "written authorization of the owners of the Copyright," and ARASAAC operates a contact page (arasaac.org/contact-us) that invites questions about initiatives — so a negotiated grant is undocumented and unprecedented, not formally foreclosed. "Only viable if permanently non-monetized" is the correct default planning assumption, but a disability-accommodation AAC app is exactly the sympathetic ask a public-sector licensor might entertain. Asking costs nothing; shipping on the assumption of permission would be reckless. Note also the ShareAlike trap independent of NC: derivatives inherit BY-NC-SA, which could contaminate a custom symbol set built on ARASAAC even if monetization were resolved.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "aac-clinical". A product decision depends on it, so it must be right.

CLAIM: ARASAAC (12,909 symbols) is CC BY-NC-SA and legally unusable — the NonCommercial clause blocks a paid app AND an ad-supported free app
THEIR DETAIL: ARASAAC's own Terms of Use state: 'The use of these resources within any product or publication for commercial purposes is therefore excluded from this permission.' License is CC BY-NC-SA; symbols by Sergio Palao, owned by the Government of Aragón. CC defines NonCommercial as 'primarily intended for or directed toward commercial advantage or monetary compensation' — this covers paid apps, ad-supported apps, and monetized products. Attribution must cite authors (ARASAAC team), source (Aula Abierta de ARASAAC + URL), license type, and property ownership (Government of Aragón), and derivatives must carry the same license and include the ARASAAC logo. ARASAAC's published terms do not document an exception procedure or a paid commercial license route. This is a trap: ARASAAC is the largest free-looking set and is widely used, so the team will be tempted. It is only viable if the app is permanently, entirely non-monetized — which is a business-model decision, not a design one.
THEIR CLAIMED SOURCES: https://aulaabierta.arasaac.org/en/terms-of-use, https://www.opensymbols.org/repositories/arasaac, https://arasaac.org/, https://www.opensymbols.org/
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>

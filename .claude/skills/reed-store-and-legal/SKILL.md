---
name: reed-store-and-legal
description: Binding external constraints on Reed — FDA 890.3710 posture, EU MDR Class I geo-restriction, Play Health apps and Data Safety declarations, App Store 1.2/5.1.1, symbol/font/voice licensing (Mulberry, ARASAAC, OFL, Kokoro). Use when picking a symbol set, font, or TTS engine, writing store listing copy, choosing categories or launch countries, or asking whether a feature may ship. Not for wording of privacy or data-collection claims, nor keystores, version codes, or upload mechanics.
---

# Reed — store, regulatory and licensing constraints

External constraints, not preferences. Getting one wrong costs a rejected submission, a takedown, or a regulatory obligation measured in months. Decide these before writing the feature, not after.

## 1. Medical device — US

**The exemption is not what protects Reed. The marketing posture is.**

21 CFR 890.3710 "Powered communication system" (product code ILQ) is Class II but codified 510(k)-exempt. That exemption is *not* why AAC apps ship without clearance. 890.3710 only reaches devices "intended for medical purposes." Hardware SGD makers (Tobii Dynavox, Prentke Romich, ProxTalker) **are** FDA-registered under ILQ; app-only makers (AssistiveWare/Proloquo2Go, Saltillo, TouchChat) are **not registered at all**. They ship clean because they are not marketed as intended for a medical purpose. The exemption is also not blanket — 38 510(k)s exist under ILQ, and 510(k)-exempt devices still must register, list, and — ILQ is not GMP-exempt — comply with CGMP/QMSR.

So: **the operative safeguard is what the listing says.** Guard the copy the way a crash path gets guarded.

**The exemption is conditional and can void.** Under 21 CFR 890.9 it is void for a device with an intended use different from a legally marketed device, or one that **"operates using a different fundamental scientific technology."** Tap-a-tile and type-to-speak sit comfortably inside existing SGD characteristics. LLM phrase generation plausibly does not.

> **Therefore: LLM phrase generation is a regulatory decision, not a feature decision.** Never scope it as a sprint item. Price the regulatory cost before the engineering cost. Same test applies to anything that infers, predicts, or generates on the user's behalf.

## 2. Medical device — EU

EU guidance names this exact app. MDCG 2019-11 Rev.1 (17 June 2025), page 35:

> "MDSW app intended to assist persons with a communication disorder (e.g. cerebral palsy, **autism (ASD), selective mutism**, MS, MND, Down's syndrome, **aphasia**, etc.) talk by converting a set of selected symbols into spoken language… This MDSW app should be classified as class I per Rule 11c."

That names three of the four target segments, and the example was **added in Rev.1** — the 2019 original has zero hits for "aphasia," "autism," "mutism," or "symbol." This is settled, not arguable.

Class I is self-certified — no notified body, no clinical investigation. It still requires: Annex II/III technical file, clinical evaluation, Art. 10(9) QMS, a PRRC (Art. 15), UDI, EUDAMED registration (mandatory since 28 May 2026), post-market surveillance, CE marking, and an **EU Authorised Representative** for a manufacturer established outside the EU.

**Do not try to write around it.** MDR Art. 2(12) defines intended purpose by "the data supplied by the manufacturer on the label, in the instructions for use or in promotional or sales materials" — claims are the lever, and in the EU compensating for a disability **is** the medical purpose. Rev.1 also narrows the "simple search" carve-out ("would not be considered… 'Simple search' if it contributes to achieving a medical purpose"). Gaming the technical exemption is the route that does not work; the industry path is to declare the AAC purpose honestly and self-certify Class I.

**Verdict: geo-restrict the EU at launch.** One checkbox in Play Console / App Store Connect now; months and five figures later. Treat "add EU countries" as a project, never a config change.

## 3. Store declarations — submission blockers

| Obligation | Rule |
|---|---|
| **Play Health apps declaration** | Mandatory for every developer with a published app — **including closed and open testing**. Under Policy > App content. Apps regulated as a medical device must be declared as such, get a "Medical Device" label, and "must provide proof of approval, clearance or certification by the relevant authority upon request." Non-device health apps must carry "a clear disclaimer… that the app is not a medical device." |
| **Play Data Safety form** | Required even collecting nothing: "Even developers with apps that do not collect any user data must complete the Data Safety form and provide a link to their privacy policy." |
| **Apple App Privacy** | Required on every submission. Per guideline **5.1.1(i)** a privacy policy link must appear **in App Store Connect metadata AND inside the app**. Privacy manifests required for the app and any third-party SDK. |
| **Apple 1.4.1** | Low risk. Its teeth aim at sensor-measurement claims ("apps that claim to take x-rays, measure blood pressure… using only the sensors on the device are not permitted"). Reed measures nothing and diagnoses nothing. "If your medical app **has** received regulatory clearance, please submit a link" is permissive, not a precondition. |

**"No data" ≠ "no paperwork."** These are hard submission blockers. Build the privacy policy page and the in-app link during the MVP, not at submission. Upside: the policy is three honest paragraphs and is the strongest marketing page available — no accounts, no network, no telemetry.

**Resolve the disclaimer tension by scoping it.** Play pushes non-device health apps to say "not a medical device." Asserting that to EU users contradicts the Commission's own classification example and could become evidence of a false statement. **Scope any "not a medical device" language to non-EU storefronts.** Use the pattern the category leader ships: as-is + limitation of liability + "does not, and will never, provide medical advice. The Material is by no means intended to be a substitute for professional medical advice, diagnosis, or treatment."

**Never imply emergency-grade reliability.** No competitor disclaims emergency failure specifically, and no copy should invite the reliance.

## 4. UGC, ratings, categories

**A local-only free-text field is NOT user-generated content.** Apple 1.2's obligations — filter objectionable material "from being posted to the app," provide a reporting mechanism, block abusive users, publish contact info — all presuppose content being posted / reaching another user. Nothing typed into the speak field leaves the device: no moderation surface, no counterparty to block. Same logic for IARC/Play content rating, which asks whether users can share UGC, interact, or message — all **no**. Expect 4+ / Everyone.

> **This flips the moment board sharing, cloud sync, or import-from-URL ships.** Any of those creates a counterparty and drags in moderation, reporting, blocking, a published contact address, and a re-rating. Treat them as policy features, not sync features.

**Never enrol in Apple's Kids Category.** Extra restrictions, and it pushes exactly the infantilizing framing the product exists to reject. In Play, declare the app **not primarily child-directed** to stay out of the Families programme. COPPA is not triggered regardless — it attaches to *collection* of personal information, and there is none, even if a 12-year-old uses the app.

## 5. Store copy — describe function, not medical benefit

Write what the app does. Never what it treats.

**Good:** "Tap a tile or type; your phone speaks it aloud or shows it in large type. Offline. No account."

**Banned words:** treats, therapy, improves language outcomes, clinically proven, diagnoses, prescribed, medical-grade, emergency.

**Use the literature's own vocabulary — "part-time AAC," "unreliable speech," "intermittent speech."** These are what the audience actually searches, and they read as a credibility signal to SLPs. Honest limit: this framing buys nothing in the EU, because compensating for a disability *is* the medical purpose there. Function-not-benefit copy is a US posture, not an EU escape.

## 6. Symbols

**Ship text-only, and keep text-only first-class forever.** It dodges the entire licensing question, and for many literate adults text is what they actually want — not a downgrade path.

When symbols ship, the commercially safe adult-capable sets are **Mulberry and Blissymbolics** — plural, not Mulberry alone.

| Set | Licence | Verdict |
|---|---|---|
| **Mulberry** (~3,436 SVGs, v3.5.2) | Contested — `LICENSE.txt` links CC BY-SA 4.0; website/README say "CC BY-SA 2.0 UK: England & Wales"; GitHub returns NOASSERTION; copyright may be two holders (Garry Paxton 2008–2017, Steve Lee 2018–2020) | Only set marketed on the adult thesis. **Resolve the version with Steve Lee before shipping.** The widely cited 3,116 count is OpenSymbols' stale index. |
| **Blissymbolics** (5,819) | CC BY-SA 4.0, usable "in any project or product, commercial or otherwise," attribution, no royalty | Safe. The "royalty required for commercial products" claim is outdated 3.0-era text. Fit for adult phrase tiles is a design question, not a legal one. |
| **OpenMoji** (~3,540) | CC BY-SA 4.0 | Safe. The stronger Twemoji substitute — `twitter/twemoji` is archived. |
| **Twemoji** (2,770) / **Tawasol** (950) | CC BY 4.0 / CC BY-SA | Safe. |
| **ARASAAC** (12,909–15,560) | CC BY-NC-SA | **Not in a monetised app.** "The use of these resources within any product or publication for commercial purposes is therefore excluded from this permission." Licensable only with written authorisation from the Government of Aragón. |
| **Sclera** (11,443) | CC BY-NC | **Not in a monetised app.** |
| Noun Project / IcoMoon / IconArchive | Mixed | Never bulk-ship. Per-symbol clearance required. |
| **PCS** (Tobii Dynavox) / **SymbolStix** (n2y/Everway) | Proprietary | Negotiable but gated. PCS: Maker Business tier, needs Boardmaker + 10–15 business day review. SymbolStix: ~$250 CDN/yr, org seat model. |

**CC NonCommercial covers paid AND ad-supported apps** — "primarily intended for or directed toward commercial advantage or monetary compensation." A free app with a tip jar is *arguably* clear of NC, but a tip jar may itself read as monetary compensation. Ask before relying on it; it costs an email and ARASAAC is 4× the set.

**Mulberry's extra non-CC condition:** "you may charge for your product or added value, but you must not charge for the symbols themselves." A paid app containing them is fine; **a symbol-pack IAP is not.**

**ShareAlike does not reach the Dart code.** Unmodified symbols + proprietary code is a collection / mere aggregation (CC BY-SA 2.0 UK §§1.3/2.3; CC BY-SA 4.0 §3(b)). SA bites only on *modifying* a symbol, and even then licensing the adapted symbols BY-SA as distributed in the app suffices — no obligation to publish a standalone restyled set or ship source SVGs.

**The real risk is not code infection — it is the anti-TPM/DRM clause vs Apple's FairPlay, and it applies to distributing the symbols at all, not just adaptations.** Mere aggregation does not dodge it. CC 4.0 largely defuses it; 2.0 UK does not. That is exactly why the Mulberry version question is load-bearing.

**The path that dodges all of it — and is the better engineering choice anyway:** ship symbol SVGs **unmodified** and do dark-theme/high-contrast adaptation **at runtime** via tint / `ColorFilter` / shader. Never bake a theme into a shipped asset file. Runtime tinting creates **no Adapted Material at all**, and a themable grid wants runtime tinting regardless.

> **Rule: no build step, script, or design pass may write a recoloured symbol back to `assets/`.** The moment a modified SVG ships, ShareAlike attaches and the mere-aggregation position is gone.

## 7. Voices, icons, fonts

**There is no iOS SLA prohibition on pre-rendering `AVSpeechSynthesizer` output.** The "Apple SLA §2.F bans recording System Voices" claim is **macOS-only** — the macOS Sequoia/Tahoe SLA §2.F ("Voices; Live Captions") says it verbatim and binds macOS end users. The iOS/iPadOS 26 SLA has no system-voice restriction: its parallel §2(f) defines "System Characters" as Genmoji/Memoji and restricts only Live Captions and Personal Voice. The Xcode and Apple SDKs Agreement mentions voice / speech / TTS **zero times**. Reasons not to pre-render are engineering reasons; the restriction binds only a macOS build.

**Personal Voice is genuinely unresolved.** iOS SLA §2(f) restricts it commercially. Apple's own WWDC23-10033 says "usage of Personal Voice is sensitive and should be primarily used for augmentative or alternative communication apps" and demos an AAC app; published implementations report no entitlement and no Info.plist key required. **Ask App Review before investing in it.** Do not treat either side as settled.

**Neural TTS:** `rhasspy/piper` (MIT) was archived 2025-10-06 and its successor is **GPL-3.0** — effectively App-Store-incompatible for a proprietary app, so Piper is not available. **Kokoro-82M is Apache-2.0** with no commercial restrictions; it is the escape hatch.

**SF Symbols: unusable.** Licensed as system-provided images under the Xcode/SDK agreements, which contemplate use on Apple platforms via the system — shipping them in an Android build is out. Also barred from app icons, logos, and trademark use; Apple-technology glyphs (iCloud, AirPlay, FaceTime) are reserved.

**Apple system fonts: unusable in the Android build.** macOS SLA §2.E permits using bundled fonts to display and print content *while running the Apple Software* only.

**Use:** Material Symbols (Apache 2.0) and SIL OFL fonts (Inter, Atkinson Hyperlegible, Lexend, Noto). OFL permits bundling in commercial software; the only real constraints are that the font may not be sold alone and Reserved Font Names may not be reused on modified versions — so **never rename-and-subset an OFL font under its own name**. Platform-native emoji rendered *as text* are fine; that redistributes no font.

## 8. Accessibility law — what actually binds

**No US law compels WCAG for a private app.** The DOJ 2024 web/mobile rule (WCAG 2.1 AA) binds **Title II** — state and local government — only, and DOJ extended those compliance dates again in April 2026. ADA Title III reaches private public accommodations and courts have applied it to apps, but **there is no adopted technical standard**: the exposure is litigation risk, not a checklist. Section 508 binds federal procurement.

**The EAA almost certainly does not apply.** Directive (EU) 2019/882 Art. 2 is a **closed list** — consumer computers and their OSes, self-service terminals, terminal equipment for e-comms and AV media, e-readers; services: e-comms, AV media access, transport, banking, e-books, e-commerce. A third-party AAC app is not an OS and is not on the services list. "E-commerce services" (Art. 3(30)) is cumulative and requires "with a view to concluding a consumer contract" — selling via Apple/Google IAP makes **the store** the e-commerce service, not the app. Belt and braces: the microenterprise exemption (<10 employees AND ≤€2m turnover/balance sheet) exempts services anyway.

**Accessibility here is not compelled by law — which changes nothing.** Build to WCAG-equivalent behaviour because an inaccessible accessibility app is a total failure with this audience, and because there is no telemetry: nobody will report the tile TalkBack cannot reach. **A VPAT is voluntary but a commercial door-opener** — AAC is bought by school districts, state voc-rehab agencies and hospitals, all Title II/508-adjacent buyers who ask for one before purchase.

## 9. The stop list

Do not ship, and do not scope, without a budgeted regulatory decision made first:

- **EU launch** — MDR Class I obligations attach on the first EU install.
- **LLM phrase generation** — voids the 890.9 exemption on "different fundamental scientific technology."
- **Board sharing / cloud sync / import-from-URL** — converts a local text field into UGC and drags in Apple 1.2 in full.
- **Kids Category / Families programme** — extra restrictions and the wrong framing.
- **Symbol-pack IAP** — breaches Mulberry's charge-for-the-symbols condition.
- **Recoloured symbol assets in the build** — creates Adapted Material where runtime tinting creates none.
- **ARASAAC or Sclera in anything monetised** — including ad-supported; ask about the tip-jar case rather than assuming.

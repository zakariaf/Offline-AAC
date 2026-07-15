# legal-regulatory

> Phase: **research** · Agent `a3ad5cd467a87ad3a` · Run `wf_3a8e3c64-43a`

## Result

## Summary

Two findings reshape this product. First, the EU has already decided this question against you: MDCG 2019-11 Rev.1 (June 2025), the Commission's own software guidance, contains a near-verbatim description of this exact app — "MDSW app intended to assist persons with a communication disorder (e.g. cerebral palsy, autism (ASD), selective mutism, MS, MND, Down's syndrome, aphasia, etc.) talk by converting a set of selected symbols into spoken language" — and classifies it as a Class I medical device under MDR Rule 11(c). The hook is the MDR's "compensation for... a disability" limb of the device definition. Class I is self-certified (no notified body) but still demands a technical file, ISO 13485-ish QMS, a PRRC, UDI, EUDAMED registration, post-market surveillance and CE marking — a real burden for a solo dev, and Google Play's health policy now asks for exactly this proof. Second, the US is the opposite and is the good news: AAC is FDA product code ILQ, 21 CFR 890.3710 "Powered communication system," Class II but explicitly 510(k)-EXEMPT. That is the real answer to "why do AAC apps ship without clearance" — not a loophole, an actual codified exemption. Elsewhere: ARASAAC's NC clause does rule it out for a paid app, but Mulberry Symbols (CC BY-SA, ~3,150 symbols, explicitly "adult oriented symbols — most proprietary sets are designed for children") is an almost perfect fit for this product's thesis. The sharpest hidden landmine is Apple's macOS SLA §2.F, which permits System Voices only for "personal, non-commercial use" and bans "recording, publishing or redistribution... in a profit... context" — live TTS is fine, but pre-rendering and shipping Apple TTS audio is not. EAA almost certainly does not apply (closed scope list), and a local-only text field is not UGC.

### The EU's official software guidance explicitly names this exact app as a Class I medical device — the example is almost a description of the MVP

*Confidence: high, **LOAD-BEARING***

MDCG 2019-11 Rev.1 (published 17 June 2025), page 35, Annex example list: 'MDSW app intended to assist persons with a communication disorder (e.g. cerebral palsy, autism (ASD), selective mutism, MS, MND, Down's syndrome, aphasia, etc.) talk by converting a set of selected symbols into spoken language. Depending on the patient's medical status, the selection can be done through various means such as a touch screen, head tracking or eye gaze. This MDSW app should be classified as class I per Rule 11c.' Verified by extracting the PDF text directly, not via a summarizer. The example names autism, selective mutism and aphasia — three of the four target populations in the product brief. This example was ADDED in Rev.1; it is not in the 2019 original (I checked the original PDF: zero hits for 'aphasia', 'autism', 'mutism', 'symbol').

- https://health.ec.europa.eu/document/download/b45335c5-1679-4c71-a91c-fc7a4d37f12b_en?filename=md_mdcg_2019_11_guidance_qualification_classification_software_en.pdf

- https://health.ec.europa.eu/latest-updates/update-mdcg-2019-11-rev1-qualification-and-classification-software-regulation-eu-2017745-and-2025-06-17_en

### The MDR hook is 'compensation for a disability' — you cannot dodge it by avoiding medical claims, because helping someone speak IS the compensation

*Confidence: high, **LOAD-BEARING***

MDR Art. 2(1) defines a medical device as intended for '...diagnosis, monitoring, treatment, alleviation of, or compensation for, an injury or disability.' An AAC app's entire purpose is compensating for a speech disability. Unlike a wellness app, there is no framing that removes the medical purpose while keeping the product's value — the intended purpose IS the trigger. Marketing it as a 'note-taking app that reads text aloud' would technically move it out of scope but destroys discoverability for the actual audience. This is the single largest strategic tension in the product.

- https://health.ec.europa.eu/document/download/b45335c5-1679-4c71-a91c-fc7a4d37f12b_en?filename=md_mdcg_2019_11_guidance_qualification_classification_software_en.pdf

### US FDA: AAC is a Class II device but is CODIFIED as 510(k)-exempt — this is the real reason AAC apps ship without clearance

*Confidence: high, **LOAD-BEARING***

21 CFR 890.3710 'Powered communication system': 'an AC- or battery-powered device intended for medical purposes that is used to transmit or receive information' for 'persons unable to use standard communication methods due to physical impairment.' Classification: 'Class II (special controls)... exempt from the premarket notification procedures in subpart E of part 807 of this chapter subject to § 890.9.' FDA product code is ILQ, review panel Physical Medicine. So there is no 510(k), no clearance, no FDA review for a US AAC app. The exemption is not discretionary or a grey area — it is written into the regulation.

- https://www.law.cornell.edu/cfr/text/21/890.3710

- https://www.ecfr.gov/current/title-21/chapter-I/subchapter-H/part-890/subpart-D/section-890.3710

- https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfpcd/classification.cfm?id=5535

### The FDA exemption is conditional on 21 CFR 890.9 — a novel intended use or novel technology voids it

*Confidence: high, **LOAD-BEARING***

890.9 limits the exemption to devices with 'existing or reasonably foreseeable characteristics of commercially distributed devices' in that category. A 510(k) becomes required if the device (1) has an intended use different from a legally marketed device, or (2) 'operates using a different fundamental scientific technology.' A tap-a-tile / type-to-speak AAC app is squarely within existing SGD characteristics, so the exemption holds comfortably. Flag for later: bolting on AI/LLM phrase prediction or any inference about the user's state could arguably be 'different fundamental scientific technology' and is the kind of feature that would need re-analysis before shipping.

- https://www.law.cornell.edu/cfr/text/21/890.9

### Apple's macOS SLA bans recording/redistributing system TTS voices commercially — live playback is fine, pre-rendered audio files are not

*Confidence: high, **LOAD-BEARING***

macOS Sequoia SLA §2.F 'Voices; Live Captions' (extracted verbatim from Apple's own PDF): 'you may: (i) use the system voices included in the Apple Software ("System Voices") (1) while running the Apple Software and (2) to create your own original content and projects for your personal, non-commercial use... No other creation or use of the System Voices, Live Captions or Personal Voice is permitted by this License, including but not limited to the use, reproduction, display, performance, recording, publishing or redistribution of any of the System Voices, Live Captions or Personal Voice in a profit, non-profit, public sharing or commercial context.' Reading: AVSpeechSynthesizer live playback on the user's own device is the normal, universally-practiced use ('while running the Apple Software') and is what every commercial AAC app does. But using AVSpeechSynthesizer.write(_:toBufferCallback:) to pre-render phrase audio and SHIP those files in the app binary is recording + redistribution in a commercial context — prohibited. On-device caching for that user only is grey but defensible; shipping is not.

- https://www.apple.com/legal/sla/docs/macOSSequoia.pdf

- https://www.apple.com/legal/sla/docs/macOSVentura.pdf

### ARASAAC's NC clause is confirmed and does block a paid app; Mulberry Symbols is the clean answer and is explicitly designed for adults

*Confidence: high, **LOAD-BEARING***

ARASAAC: CC BY-NC-SA. ARASAAC's own terms state 'The use of these resources within any product or publication for commercial purposes is therefore excluded from this permission.' Attribution must name Sergio Palao / Government of Aragon / ARASAAC. The NC clause is fatal for a paid app (and arguably for a free app with IAP). Mulberry Symbols: ~3,150 SVG symbols, © Steve Lee, CC BY-SA 2.0 UK (England & Wales). Its own site markets it on exactly this product's thesis — 'Adult oriented symbols - most proprietary sets are designed for children' — and states you may use symbols in commercial projects with clear attribution, keeping derived symbols under the same license, and that you may 'charge for your product or added value, but you must not charge for the symbols themselves.' Other sets: Sclera CC BY-NC (blocked). Blissymbolics — CC BY-SA for free/copyleft/non-commercial use, but a 'royalty based' license from BCI is required for all commercial products (avoid). SymbolStix (n2y/Everway) and PCS/Boardmaker are proprietary commercial licenses requiring direct negotiation — SymbolStix Prime end-user subscriptions run ~$250/yr and permit personal use only, not redistribution in your app.

- https://aulaabierta.arasaac.org/en/terms-of-use

- https://mulberrysymbols.org/

- https://github.com/mulberrysymbols/mulberry-symbols

- https://www.openaac.org/symbols.html

- https://www.blissymbolics.org/index.php/licensing

- https://www.neilsquire.ca/symbolstix-prime-an-aac-app-by-everway/

### CC BY-SA on symbols does NOT infect your Flutter app code — ShareAlike reaches adaptations of the symbols, not the app bundling them

*Confidence: medium, **LOAD-BEARING***

This is the standard fear that pushes teams to pay for proprietary sets unnecessarily. Under CC BY-SA, shipping unmodified symbols alongside proprietary code is a 'collection'/mere aggregation: the app remains proprietary, the symbols stay CC BY-SA. ShareAlike bites only if you MODIFY a symbol (recolor, restyle for the dark theme, redraw) — those adapted symbols must themselves be released under CC BY-SA 2.0 UK or a compatible license. Practical consequence: if you restyle Mulberry symbols to fit the calm dark aesthetic, you must publish the restyled symbol set. That is cheap, and is arguably good community marketing for this audience.

- https://mulberrysymbols.org/

- https://github.com/mulberrysymbols/mulberry-symbols

### SF Symbols is unusable for a Flutter cross-platform app; Material Symbols and open emoji sets are the safe icon fallbacks

*Confidence: high*

All SF Symbols are 'system-provided images as defined in the Xcode and Apple SDKs license agreements' — the license contemplates use on Apple platforms via the system, so shipping them in an Android build is out. Also barred from app icons/logos/trademark use, and Apple-technology glyphs (iCloud, AirPlay, FaceTime) are reserved. Safe alternatives: Material Symbols (Apache 2.0, commercial OK), OpenMoji (CC BY-SA), Twemoji (CC BY 4.0), Noto Color Emoji (OFL). Platform-native emoji rendered as text are fine (you are not redistributing the font). Noun Project free tier is CC BY (attribution, no trademark use); its Pro royalty-free license removes attribution but read redistribution terms before shipping icons inside a binary.

- https://developer.apple.com/forums/thread/724523

- https://developer.apple.com/fonts/

- https://help.thenounproject.com/hc/en-us/articles/200509798-What-licenses-do-you-offer-for-icons

- https://thenounproject.com/legal/creator-terms/icons/

### Google Play now forces the medical-device question into the submission flow — you cannot stay silent about it

*Confidence: medium, **LOAD-BEARING***

Play's Health Content and Services policy requires ALL developers with a published app (including closed/open testing) to complete the Health apps declaration form (Policy > App content). Apps regulated as a medical device 'must be declared as such' and will be 'identified as a "Medical Device" on Google Play', and 'must provide proof of approval, clearance or certification by the relevant authority upon request.' Non-device health apps must include 'a clear disclaimer in their app description indicating that the app is not a medical device and does not diagnose, treat, cure, or prevent any medical condition' and must remind users to consult a healthcare professional. Reporting caveat: multiple secondary sources say the Jan-2026 update adds an EU 'Medical Device' label and pulls MDCG guidance into the policy, but I could not confirm any MDCG/MDR/CE text on Google's own policy page — treat the EU-label specifics as unverified.

- https://support.google.com/googleplay/android-developer/answer/16679511?hl=en

- https://support.google.com/googleplay/android-developer/answer/14738291?hl=en

- https://support.google.com/googleplay/android-developer/answer/13996367?hl=en

### Apple guideline 1.4.1 is a low risk for this app — its teeth are aimed at sensor-based measurement claims, which this app makes none of

*Confidence: high*

1.4.1 verbatim: 'Medical apps that could provide inaccurate data or information, or that could be used for diagnosing or treating patients may be reviewed with greater scrutiny. Apps must clearly disclose data and methodology to support accuracy claims relating to health measurements, and if the level of accuracy or methodology cannot be validated, we will reject your app. For example, apps that claim to take x-rays, measure blood pressure, body temperature, blood glucose levels, or blood oxygen levels using only the sensors on the device are not permitted. Apps should remind users to check with a doctor... If your medical app has received regulatory clearance, please submit a link to that documentation.' An AAC app measures nothing and diagnoses nothing — it speaks text the user chose. Note 'if your medical app HAS received clearance, please submit a link' is permissive, not a precondition. No 1.4.1 blocker expected.

- https://developer.apple.com/app-store/review/guidelines/

### A local-only free-text field is NOT user-generated content under Apple 1.2 — the hypothesis in the brief is correct

*Confidence: medium, **LOAD-BEARING***

Apple 1.2 obligations (filtering objectionable material 'from being posted to the app', reporting mechanism, blocking abusive users, published contact info) are all predicated on content being posted/shared to other users. Nothing in a type-to-speak box leaves the device or reaches another user, so there is no moderation surface and no counterparty to block. Same logic for IARC/Play content rating: the questionnaire asks whether users can share UGC, interact, or message — all 'no' here. Expect 4+ / Everyone. This flips the moment you add phrase-board sharing, cloud sync, or import-from-URL — that single feature would import the whole UGC compliance regime.

- https://developer.apple.com/app-store/review/guidelines/

- https://support.google.com/googleplay/android-developer/answer/9898843?hl=en

- https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions/

### The EU Accessibility Act almost certainly does NOT apply — its scope is a closed list, and a standalone AAC app is not on it

*Confidence: medium, **LOAD-BEARING***

Contrary to the widespread 'EAA applies to all apps from June 2025' framing, EAA (Directive (EU) 2019/882) Art. 2 enumerates a finite scope: consumer general-purpose computer hardware and their operating systems, self-service terminals (ATMs, ticketing), consumer terminal equipment for electronic communications and audiovisual media services, e-readers; and services: electronic communications, audiovisual media access, transport, banking, e-books, and e-commerce services. A third-party AAC app is not an OS and not on the services list. 'E-commerce services' (Art. 3(30)) is cumulative — provided at a distance, by electronic means, at the individual request of a consumer, 'with a view to concluding a consumer contract'. Selling via Apple/Google IAP makes the STORE the e-commerce service, not your app. Belt and braces: the microenterprise exemption (<10 employees AND ≤€2m turnover/balance sheet) exempts services anyway, which covers a solo developer.

- https://en.wikipedia.org/wiki/European_Accessibility_Act

- https://www.twobirds.com/en/insights/2025/a-guide-to-navigating-the-european-accessibility-act-for-online-retailers-service-providers-and-plat

- https://www.levelaccess.com/compliance-overview/european-accessibility-act-eaa/

- https://krisrivenburgh.com/microenterprises-exempt-eaa-requirements/

### No US accessibility law compels WCAG conformance for this app, and no VPAT is legally required — but a VPAT is a commercial door-opener

*Confidence: high*

The DOJ's 2024 web/mobile-app rule (WCAG 2.1 AA) binds Title II entities — state and local government — only, not private developers; DOJ extended those compliance dates in April 2026. ADA Title III reaches private 'public accommodations' and courts have applied it to apps, but there is still NO adopted technical standard, so exposure is litigation risk rather than a compliance checklist. Section 508 binds federal agencies' procurement, not private apps. A VPAT is voluntary. However: AAC is bought by school districts, state voc-rehab agencies, and hospitals — all Title II/508-adjacent buyers who ask for a VPAT before purchasing. WCAG 2.1 AA / EN 301 549 conformance is therefore commercially advisable, not legally mandatory. Also deeply on-brand: an inaccessible accessibility app is a credibility failure with this specific audience.

- https://www.ada.gov/resources/2024-03-08-web-rule/

- https://www.federalregister.gov/documents/2026/04/20/2026-07663/extension-of-compliance-dates-for-nondiscrimination-on-the-basis-of-disability-accessibility-of-web

- https://www.americanbar.org/groups/business_law/resources/business-law-today/2025-august/digital-accessibility-under-title-iii-ada/

- https://www.levelaccess.com/blog/ada-guidelines-compliance/

### 'Nothing leaves the device' still requires a published privacy policy and both store disclosure forms — zero collection is a value to declare, not an exemption

*Confidence: high, **LOAD-BEARING***

Google Play: 'Even developers with apps that do not collect any user data must complete the Data Safety form and provide a link to their privacy policy' — the form and policy simply declare no collection. Apple requires App Privacy details (nutrition label) for every submission, plus, per guideline 5.1.1(i), a privacy policy link in App Store Connect metadata AND in the app, identifying what data is collected, confirming third parties provide equal protection, and explaining retention/deletion. For this app the policy is short and is a marketing asset: no account, no network calls, no analytics, phrase data local, deletion = delete app. Privacy manifests are also required for the app and third-party SDKs on Apple platforms.

- https://support.google.com/googleplay/android-developer/answer/10787469?hl=en

- https://developer.apple.com/app-store/review/guidelines/

- https://termly.io/resources/articles/google-play-store-privacy-policy-updates/

### Adding Firebase/Crashlytics would break the privacy promise in a way users can see on the store listing; Sentry is milder; neither is worth it for the MVP

*Confidence: medium, **LOAD-BEARING***

Crashlytics collects stack traces, device/OS info, and any custom keys/logs/user IDs; critically, even Crashlytics-only integration pulls in the Firebase core SDK, which declares ADDITIONAL data categories — so the nutrition label lists more collection with Firebase than with Sentry. Sentry's privacy manifest declares diagnostics (crash logs, device model, OS/app version) and performance, but no advertising ID, user identifier, or analytics. Either way the app can no longer say 'nothing leaves the device' — and the target communities (r/autism, AAC users) are unusually literate about exactly this claim. The 'privacy-preserving analytics' answer for this product is not a vendor: it is local-only crash logs the user can optionally view and manually export/email when they choose.

- https://firebase.google.com/docs/ios/app-store-data-collection

- https://techconcepts.org/blog/sentry-vs-crashlytics-ios-crash-reporting

- https://www.termsfeed.com/blog/crashlytics-privacy-policy/

### COPPA is not triggered: it attaches to collection of personal information, and the app collects none

*Confidence: medium*

COPPA applies to operators of online services directed to children under 13 that COLLECT personal information online. With no account, no network transmission, and no data collection, there is no COPPA obligation even if a 12-year-old uses it. Teens (13+) raise nothing additional. Two practical rules: do NOT enroll in Apple's Kids Category (it imposes extra restrictions and pushes exactly the infantilizing framing the product exists to reject), and in Play declare the app is not primarily child-directed to stay out of the Families policy program. 4+/Everyone rating with a general audience target is both accurate and strategically correct.

- https://developer.apple.com/app-store/review/guidelines/

- https://support.google.com/googleplay/android-developer/answer/9898843?hl=en

### Industry-standard AAC disclaimers are ordinary as-is/liability language plus a no-medical-advice line — nobody disclaims emergency failure specifically

*Confidence: high, **LOAD-BEARING***

AssistiveWare (Proloquo2Go, the category leader) uses: 'THE INFORMATION CONTAINED IN THE MATERIAL IS FOR GENERAL INFORMATION PURPOSES ONLY AND IS PROVIDED IN "AS IS" BASIS'; 'IN NO EVENT WILL ASSISTIVEWARE BE LIABLE FOR ANY LOSS OR DAMAGE, DIRECTLY, INDIRECTLY OR CONSEQUENTIALLY, ARISING OUT OF, OR IN CONNECTION WITH, THE USE OF THE MATERIAL'; and 'AssistiveWare does not, and will never, provide medical advice. The Material is by no means intended to be a substitute for professional medical advice, diagnosis, or treatment.' Notably I found NO emergency-reliance disclaimer in their terms. Note the tension: Play requires a 'not a medical device' disclaimer for non-device health apps, but asserting that in the EU while the MDCG example says otherwise is a claim you'd be making against the Commission's own guidance. Keep the disclaimer about medical ADVICE and reliance, and avoid a flat 'this is not a medical device' assertion in EU-facing copy.

- https://www.assistiveware.com/terms-conditions

- https://www.assistiveware.com/legal

- https://support.google.com/googleplay/android-developer/answer/16679511?hl=en

### Bundled fonts need an embedding-permissive license; Apple's own system fonts are display-only under the SLA

*Confidence: medium*

macOS SLA §2.E: 'you may use the fonts included with the Apple Software to display and print content while running the Apple Software; however, you may only embed fonts in content if that is permitted by the embedding restrictions accompanying the font in question.' So SF Pro / New York cannot be shipped inside a Flutter Android build. Use SIL Open Font License fonts (Inter, Atkinson Hyperlegible, Lexend, Noto) — OFL permits bundling in commercial software; the only real constraints are you cannot sell the font alone and Reserved Font Names cannot be reused on modified versions. Atkinson Hyperlegible (Braille Institute, OFL) is designed for low-vision legibility and is a strong fit for a distress-usable adult UI.

- https://www.apple.com/legal/sla/docs/macOSSequoia.pdf

- https://developer.apple.com/fonts/

## Product implications

- **[must-have-mvp]** Ship Mulberry Symbols as the default symbol set — do not ship ARASAAC
  - Mulberry is CC BY-SA (commercial use explicitly permitted with attribution), ~3,150 SVGs, and is the only major free set positioned on this product's exact thesis: 'Adult oriented symbols - most proprietary sets are designed for children.' The license and the product strategy point the same way. ARASAAC's NC clause blocks any paid/monetized use, SymbolStix and PCS require costly proprietary negotiation, Sclera is NC, and Blissymbolics needs a royalty deal for commercial products. Add a visible attribution screen ('Symbols by Steve Lee, CC BY-SA'), and if you restyle symbols for the dark theme, publish the restyled set under CC BY-SA — cheap, compliant, and good community signal.
- **[must-have-mvp]** Use live on-device TTS only; never pre-render and ship Apple TTS audio files
  - macOS/iOS SLA §2.F bans 'recording, publishing or redistribution' of System Voices 'in a profit... context'. Live AVSpeechSynthesizer playback is what every AAC app does and is fine. Pre-rendering phrase audio into the app binary is a licensing violation that also silently breaks the product promise (a shipped audio file cannot speak an edited phrase). Live synthesis is also strictly better for the core job: instant, offline, works on arbitrary typed text. If latency ever demands caching, cache on-device for that user only and never ship or sync the audio.
- **[must-have-mvp]** Launch US-first (and UK/CA/AU); treat EU as a deliberate, later, budgeted decision
  - The regulatory asymmetry is stark and should drive geography. US: 21 CFR 890.3710 / product code ILQ is Class II but codified 510(k)-exempt — ship legally with no FDA submission. EU: the Commission's own MDCG 2019-11 Rev.1 example places this exact app in Class I MDR, requiring technical file, QMS, PRRC, UDI, EUDAMED registration, post-market surveillance and CE marking — plausibly months and five figures for a solo dev, and Google Play can ask for the proof. Geo-restricting the EU at launch is a one-checkbox decision in App Store Connect / Play Console; discovering the MDR obligation after an EU launch is not.
- **[must-have-mvp]** Write app store copy that describes function, not medical benefit
  - Intended purpose — stated in your own marketing — is what triggers device classification, and store copy is the primary evidence a regulator or reviewer reads. Describe what it does ('tap a tile or type, your phone speaks it aloud, offline, no account') and who it's for in community language ('for adults and teens who lose speech during shutdowns, selective mutism, aphasia'). Avoid therapeutic claims ('treats', 'improves language outcomes', 'clinically proven'). This keeps you findable by the actual audience — who search those exact words — while not manufacturing extra medical-purpose evidence against yourself. Note the honest limit: in the EU this framing does not save you, because 'compensation for a disability' is itself the medical purpose.
- **[must-have-mvp]** Ship zero analytics and zero crash reporting in v1; make 'no network code' a verifiable claim
  - Adding Crashlytics drags in the Firebase core SDK and inflates the nutrition label beyond crash data; Sentry is milder but still means data leaves the device. This audience reads privacy labels adversarially and the offline promise is the product's core differentiator against $299 incumbents — breaking it for crash telemetry is a bad trade. Better: local-only crash log the user can view and choose to export. Consider shipping with no networking permission/entitlement at all, so the claim is structurally verifiable rather than merely asserted.
- **[must-have-mvp]** Complete the Play Health apps declaration and Data Safety form, and publish a short privacy policy — 'no data' is not 'no paperwork'
  - Play requires the Data Safety form plus a privacy policy link from every app including zero-collection apps and closed-testing tracks; the Health apps declaration is mandatory for health/medical apps; Apple requires App Privacy details and a policy link both in App Store Connect and in-app (5.1.1(i)). These are submission blockers, not nice-to-haves. Upside: the policy is three honest paragraphs and doubles as the strongest marketing page you have.
- **[must-have-mvp]** Adopt AssistiveWare-style as-is + no-medical-advice disclaimers; do not write a flat 'this is not a medical device' line into EU-facing copy
  - Category-leader practice is ordinary as-is/limitation-of-liability language plus 'does not provide medical advice... not a substitute for professional medical advice, diagnosis, or treatment' — notably with no emergency-reliance disclaimer. Play's policy pushes non-device health apps to state 'not a medical device', but asserting that to EU users contradicts the Commission's own classification example and could itself become evidence of a false statement. Resolve by keeping the disclaimer about medical advice and reliance, scoping any 'not a medical device' language to non-EU storefronts, and never implying emergency-grade reliability.
- **[should-have-v1]** Keep phrase data strictly local — no sharing, sync, or board import — for v1
  - Local-only free text is not UGC: Apple 1.2's duties (filter content posted to the app, report mechanism, block abusive users) all presuppose content reaching another user, and the IARC questionnaire asks about sharing and interaction. This keeps the rating at 4+/Everyone with no moderation surface. But it is one feature away from flipping: any board-sharing, cloud sync, or import-from-URL imports the entire UGC regime — moderation, reporting, blocking, published contact info — plus data collection disclosures. If sharing is ever added, export/import via local file rather than a service keeps you out of scope.
- **[should-have-v1]** Build to WCAG 2.1 AA / EN 301 549 and produce a VPAT — for market access, not legal compliance
  - No US law compels it for a private app: the DOJ 2024 rule is Title II only (and its dates slipped again in April 2026), Title III has no adopted technical standard, and Section 508 binds federal procurement. But AAC's institutional buyers — school districts, state voc-rehab, hospitals — are exactly the Title II/508-adjacent entities that request a VPAT before purchase, so it unlocks revenue an individual-consumer app can't reach. And for this product it is table stakes on credibility: an inaccessible accessibility app will be judged harshly by the very communities you're launching into.
- **[should-have-v1]** Use Material Symbols and OFL fonts for UI chrome; avoid SF Symbols and Apple system fonts entirely
  - SF Symbols are licensed as system-provided images under the Xcode/SDK agreements and cannot ship in the Android half of a Flutter build; Apple's SLA §2.E limits bundled system fonts to display/print while running Apple software. Material Symbols (Apache 2.0) and OFL fonts are cross-platform-safe. Atkinson Hyperlegible (OFL, Braille Institute) is worth a look — it is engineered for legibility under visual stress, which aligns with the requirement to be usable one-handed mid-shutdown.
- **[explicitly-avoid]** Treat AI/LLM phrase prediction as a regulatory decision, not a feature decision
  - The US 510(k) exemption survives only under 21 CFR 890.9, which voids it if the device has a different intended use or 'operates using a different fundamental scientific technology' than legally marketed devices. Tap-a-tile and type-to-speak are core existing SGD characteristics and sit safely inside the exemption. LLM-generated phrase suggestions are a plausible 'different fundamental scientific technology' argument, and MDCG Rev.1 introduces 'MDAI' (medical device AI) as a new category of regulatory attention. Adding AI could convert a zero-paperwork US product into a 510(k) submission — so if it's ever on the roadmap, price the regulatory cost before the engineering cost.
- **[nice-to-have-later]** If the EU becomes strategically necessary, budget Class I MDR self-certification rather than assuming a workaround
  - Class I is the mildest MDR tier — self-certified, no notified body — so it is achievable solo, unlike Class IIa. It requires an Annex II/III technical file, a clinical evaluation, an Article 10(9) QMS, a PRRC (Article 15), UDI, EUDAMED registration, post-market surveillance, CE marking, and an EU Authorised Representative if you're established outside the EU. Do not plan on arguing your way out: the Commission's guidance names autism, selective mutism and aphasia in the example itself, so a notified body or competent authority has a pre-written answer. Sequence it after US/UK traction proves the product is worth the overhead.

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


YOUR DIMENSION: Legal, regulatory, app store, and licensing constraints.

Research using WebSearch and WebFetch.

Answer specifically:
- Is an AAC app a regulated MEDICAL DEVICE? Check FDA (US) — is AAC software a device? What about the FDA's stance on "general wellness" / low-risk devices and the enforcement discretion policy? Check EU MDR (EU) — is AAC software Class I? Does the EU MDR / MDCG 2019-11 guidance capture communication aids? What about UK MHRA? Real answer needed — many AAC apps ship without clearance, why? Is there a specific exemption/classification? (Look for FDA product codes, e.g. for "augmentative communication device", and the "Speech Generating Device" classification, and whether SOFTWARE-ONLY is treated differently.)
- App Store / Play Store: any special rules for medical/accessibility apps? Apple guideline 1.4.1 (physical harm) / 5.1 medical data? Any risk of rejection for an app that claims medical benefit? How should the app describe itself to avoid trouble while still being findable?
- Age rating implications: an AAC app with a fully editable text-to-speech field can speak ANY text. Any store issue with UGC? (An app with a free-text field is technically UGC only if shared — it's local, so probably fine. Verify.)
- Accessibility law: does the EU Accessibility Act (EAA, applicable June 2025) apply to a mobile app like this? What compliance does it require? What about ADA/Section 508 (US) — do private apps have obligations? Does the app need a VPAT? Would EN 301 549 / WCAG 2.1/2.2 AA conformance be required or advisable?
- Privacy law: if truly nothing leaves the device, what's still required? Apple Privacy Nutrition Label (must be filled even if "no data collected"), Google Play Data Safety section, and what about crash reporting/analytics — does adding Sentry/Firebase break the privacy promise? Is there a privacy-preserving analytics option? What must a privacy policy say? Is a privacy policy required at all by both stores? (Yes for Play — verify.)
- COPPA / children: audience includes TEENS. Any implications? Age rating choice?
- Symbol licensing (CRITICAL): exact license and cost for ARASAAC (CC BY-NC-SA — the NC clause is a problem for a paid app! verify), Mulberry Symbols (CC BY-SA 2.0?), SymbolStix (commercial license, cost?), PCS/Boardmaker (commercial, cost?), Open Symbols aggregator, Blissymbolics, Sclera, Tawasol, Global Symbols. Which can a commercial/paid app legally ship? What about Noun Project, Material Symbols, SF Symbols (SF Symbols license restricts to Apple platforms and to system-like use — verify)? Emoji? Give a concrete, safe recommendation.
- Voice licensing: are OS TTS voices free to use in a commercial app? Any Apple/Google restriction on using the system synthesizer in a paid app? Any restriction on RECORDING TTS output to a file (Apple's AVSpeechSynthesizer write API and terms)? THIS MATTERS if pre-rendering audio.
- Font licensing for any bundled font.
- Liability: what if the app fails at a critical moment (medical emergency)? What disclaimer is standard? Look at what existing AAC apps disclaim.

Be precise and cite sources. Flag anything that could kill or reshape the product.
````

</details>

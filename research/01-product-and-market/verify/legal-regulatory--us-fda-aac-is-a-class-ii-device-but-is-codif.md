# legal-regulatory--us-fda-aac-is-a-class-ii-device-but-is-codif

> Phase: **verify** · Agent `a8b81ba6452e8b217` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** 21 CFR 890.3710 ("Powered communication system," product code ILQ, Physical Medicine panel) is indeed Class II and codified as 510(k)-exempt — but the exemption is expressly conditional under § 890.9 (lost if intended use differs from legally marketed devices of that generic type, or if it uses a different fundamental scientific technology), and 38 510(k)s exist under ILQ including one cleared in 2017 (K162817, Voxello Noddle). It is therefore not a grey-area-free blanket exemption. More importantly, this exemption is NOT why AAC apps ship without clearance: 890.3710 only reaches devices "intended for medical purposes," and 510(k)-exempt devices must still register, list, and (since ILQ is not GMP-exempt) comply with CGMP/QMSR. FDA registration data shows hardware SGD makers (Tobii Dynavox, Prentke Romich, ProxTalker) ARE registered under ILQ, while app-only makers (AssistiveWare/Proloquo2Go, Saltillo, TouchChat) are not registered at all — i.e. AAC apps ship without clearance because they are not marketed as devices intended for a medical purpose, not because of the 510(k) exemption. The operative safeguard for this product is marketing/intended-use posture (avoid therapeutic/medical claims), not 890.3710. Also: the quoted CFR phrase is "normal communication methods because of physical impairment," not "standard communication methods due to physical impairment," and the cited FDA URL id=5535 is dead (use ID=ILQ / the openFDA API).

**Evidence:** The REGULATORY FACTS are confirmed; the CAUSAL CLAIM and the "not a grey area" framing are refuted.

CONFIRMED:
- 21 CFR 890.3710 "Powered communication system" exists, is Class II (special controls), and is "exempt from the premarket notification procedures in subpart E of part 807 of this chapter subject to § 890.9." (Cornell LII, primary CFR text.)
- openFDA classification API for product_code ILQ returns verbatim: device_class="2", regulation_number="890.3710", medical_specialty_description="Physical Medicine", review_panel="PM", submission_type_id="4", device_name="System, Communication, Powered". API last_updated 2026-07-06.
- I independently calibrated submission_type_id rather than trusting the label: KGX (adhesive bandage, known exempt)=4; NXQ (medication reminder, known exempt)=4; FRN (infusion pump, known 510(k)-required)=1; LZG (insulin pump)=1. So 4 = 510(k)-exempt. The exemption is real and codified.

REFUTED #1 — "the exemption is not discretionary or a grey area": False. § 890.9 (fetched verbatim, Cornell) states the exemption applies "only to the extent that the device has existing or reasonably foreseeable characteristics of commercially distributed devices within that generic type," and a 510(k) IS required when the device is "intended for a use different from the intended use of a legally marketed device" or "operates using a different fundamental scientific technology." Those are judgment calls — i.e. exactly a grey area. Empirically: openFDA lists 38 K-numbers under ILQ, including K162817 (Voxello "Noddle", Iowa Adaptive Technologies, cleared 2017-01-18, Substantially Equivalent, Traditional) — a post-exemption clearance under the supposedly blanket-exempt code.

REFUTED #2 — "this is the real reason AAC apps ship without clearance": Unsupported, and the evidence points elsewhere. 890.3710 only reaches devices "intended for medical purposes." The threshold question is whether a consumer AAC app is a device at all, not whether it is exempt. Decisive test: 510(k)-exempt status does NOT exempt a firm from establishment registration and device listing, and ILQ's gmp_exempt_flag = "N" (not GMP-exempt). So if AAC apps were shipping as exempt-but-regulated ILQ devices, their makers would appear in FDA registration & listing. I queried openFDA registrationlisting: HARDWARE SGD makers do appear (Tobii Dynavox LLC — ILQ; Prentke Romich Co. — ILQ; ProxTalker.com LLC — ILQ; LingraphiCare America — ILQ; 45 ILQ registrants total). Pure APP makers do NOT appear at all: AssistiveWare (Proloquo2Go), Saltillo, and TouchChat return zero registrations. They are not registered as devices under any code — meaning they are not relying on the 890.3710 exemption; they are not treating themselves as devices in the first place. That is a different mechanism than the claim asserts.

REFUTED #3 — misquote presented as verbatim: The CFR says persons unable to use "normal communication methods because of physical impairment," not "standard communication methods due to physical impairment." Minor, but it is offered inside quotation marks.

REFUTED #4 — dead source: Their third cited source, accessdata.fda.gov/.../classification.cfm?id=5535, returns HTTP 404. The working record is classification.cfm?ID=ILQ (also 404 to automated fetch; the durable primary is the openFDA API).

MATERIAL OMISSION relevant to the product decision: "No 510(k), no clearance, no FDA review" is true ONLY conditional on the app not being a device. If the app were marketed with medical-purpose intent, exemption from 510(k) would still leave establishment registration, device listing, MDR, and — because ILQ is not GMP-exempt — full CGMP. Note the QMSR took effect 2026-02-02, replacing the old QSR by incorporating ISO 13485:2016 into 21 CFR 820. So the exemption is not the safe harbor; the marketing/intended-use posture is. Also note FDA's 2019 "Policy for Device Software Functions and Mobile Medical Applications" (the governing software guidance, 45 pp.) never mentions 890.3710 or AAC at all — I extracted and grepped the full text; its only Part 890 citations are 890.5050 (NXQ, daily activity assist) and 890.5740. A search snippet claiming the guidance ties 890.3710 to daily activity assist devices is wrong — the guidance says 890.5050.

PRACTICAL UPSHOT: The researcher's conclusion (a US AAC app can ship without FDA clearance) survives, but their reasoning is wrong, and the wrong reasoning is dangerous because it implies the exemption protects you regardless of how you market. It does not. The protection comes from staying outside "intended for medical purposes" — which means avoiding medical/therapeutic claims in App Store copy and marketing. Confidence should be MEDIUM, not high.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "legal-regulatory". A product decision depends on it, so it must be right.

CLAIM: US FDA: AAC is a Class II device but is CODIFIED as 510(k)-exempt — this is the real reason AAC apps ship without clearance
THEIR DETAIL: 21 CFR 890.3710 'Powered communication system': 'an AC- or battery-powered device intended for medical purposes that is used to transmit or receive information' for 'persons unable to use standard communication methods due to physical impairment.' Classification: 'Class II (special controls)... exempt from the premarket notification procedures in subpart E of part 807 of this chapter subject to § 890.9.' FDA product code is ILQ, review panel Physical Medicine. So there is no 510(k), no clearance, no FDA review for a US AAC app. The exemption is not discretionary or a grey area — it is written into the regulation.
THEIR CLAIMED SOURCES: https://www.law.cornell.edu/cfr/text/21/890.3710, https://www.ecfr.gov/current/title-21/chapter-I/subchapter-H/part-890/subpart-D/section-890.3710, https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfpcd/classification.cfm?id=5535
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>

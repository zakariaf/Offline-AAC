# business-model--a-subscription-model-actively-disqualifies-t

> Phase: **verify** · Agent `a2e49399a94fde1b6` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Corrected claim: Auto-renewing subscription billing creates real friction with the AAC agency/institutional procurement channel — corroborated by two independent vendors (AssistiveWare offering non-auto-renewing 1-5 year licenses explicitly as the alternative, and Tobii Dynavox distributors reporting agencies cannot process monthly payments). But it does not "disqualify the app," and no state/Medicaid policy document establishing a categorical subscription exclusion could be found; the sole direct support is one anonymous App Store review from September 2023. The constraint is on the billing mechanism, not the business model: prepaid multi-year licenses are recurring revenue and are accepted. Product implication: if the agency channel is ever targeted, ship a non-auto-renewing perpetual or multi-year license option alongside any subscription — that fully resolves the constraint. But for this product's stated audience (adults self-purchasing, no account, no SLP gatekeeper), the agency channel is mostly irrelevant, so this should not be treated as a decisive argument against subscription pricing. The stronger arguments against subscription for THIS product are audience-fit and the offline/no-account premise (recurring billing implies entitlement checks, which conflicts with "zero login, works in an ER with no signal"), not funding disqualification.

**Evidence:** VERIFIED: The quote is verbatim. App Store reviewer "mzdnsy55" (Sept 2023) on the US Proloquo listing states exactly: "state programs that offer funding will not accept this as this is a subscription." AssistiveWare's developer response is real, points to www.assistiveware.com/products/proloquo-licenses "including 3 and 5 year licenses," notes these are non-auto-renewing and purchasable via multiple payment methods, and says the 5-year term aligns with typical insurance re-evaluation cycles. Proloquo is indeed subscription-priced ($9.99/mo, $99.99/yr) with 1-5 year licenses ($99.99-$499.99) as the alternative.

INDEPENDENT CORROBORATION the researcher did not cite (strengthens the direction): Tobii Dynavox moved TD Snap to subscription on 2024-05-22, discontinuing one-time purchases ($79.99/$310.00). Its Australian distributor reported that agencies "are unable to process monthly payments" and that administrative overhead made supporting participants procuring TD Snap through traditional agency processes commercially non-viable. Two unrelated AAC vendors independently hitting the same procurement wall is materially better evidence than one anonymous review.

WHERE THE CLAIM OVERSTATES:
1. No policy mechanism was substantiated. I searched for a state/Medicaid/CMS rule categorically excluding subscription-billed AAC apps and found none. The evidence base is one anonymous reviewer's assertion plus vendor-side workarounds — that is inference about procurement friction, not the "concrete mechanism" the claim asserts.
2. Wrong object: subscription does not disqualify "the app." AssistiveWare was never locked out — it added non-auto-renewing multi-year licenses and remained in the channel. The incompatibility is with AUTO-RENEWING RECURRING BILLING (and App Store IAP rails), not with recurring revenue per se. A 3- or 5-year prepaid license IS recurring revenue and IS accepted. The vendor response is better read as evidence the problem is SOLVABLE, not as an admission of disqualification.
3. A search-engine summary fabricated the strongest-looking lead: it asserted "As of May 21, 2024, Oklahoma ABLE Tech cannot vend subscription-based AAC apps due to insurance restrictions." Direct fetch of okabletech.org/community/aac-funding-information/ shows no such statement. The page actually says that as of 2026-06-24 ABLE Tech will NOT vend iPads, AAC apps, keyguards, or cases for individuals at all — a blanket exit unrelated to subscriptions. Likewise omazingkidsllc.com (updated 5/20/26) only notes TD Snap now requires a subscription; it does not say funders exclude subscriptions. The researcher's "high" confidence may rest partly on synthesized-but-false snippets of this kind.
4. Relevance gap for THIS product: the purchase-order/agency channel is SGD/AAC funding gated by SLP evaluation, medical-necessity documentation, and accredited-vendor status. That is a pediatric/prescribed-AAC pathway. This product targets autistic adults and teens self-purchasing with zero accounts and zero gatekeepers. The claim's kicker — "the channel AAC buyers actually use" — is true of prescribed pediatric AAC, not of the self-identifying adult segment. For a self-pay indie app the agency channel is largely a non-factor unless deliberately pursued.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "business-model". A product decision depends on it, so it must be right.

CLAIM: A subscription model actively disqualifies the app from state/agency funding — a concrete mechanism, not just sentiment
THEIR DETAIL: A Proloquo App Store reviewer states plainly: 'state programs that offer funding will not accept this as this is a subscription.' This converts the subscription question from a preference issue into a distribution-channel issue: recurring billing locks you out of the purchase-order/agency channel that AAC buyers actually use. AssistiveWare's own response — pointing organizations to 3- and 5-year licenses — is effectively an admission of this problem.
THEIR CLAIMED SOURCES: https://apps.apple.com/us/app/proloquo/id1521978238, https://www.assistiveware.com/products/proloquo-licenses
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>

# business-model--assistiveware-s-move-to-subscription-with-pr

> Phase: **verify** · Agent `a09af0b9fbddd0ee0` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Proloquo launched in December 2021 (not 2023), and AssistiveWare has NOT "moved to subscription" — it runs both models in parallel, with Proloquo2Go still sold at $249.99 one-time and explicitly not slated for discontinuation. Proloquo is rated 4.0/5 (142 US ratings) vs Proloquo2Go's 4.8/5 (~12,000), but this gap is not clean evidence of subscription rejection: it is confounded by a severe selection effect (a $249.99 paid app is rated only by people who already committed $249.99; a free-download app is rated by everyone who bounces off the paywall) and by large non-price product differences (Proloquo's locked base vocabulary and single 48-button grid vs Proloquo2Go's 23 grid sizes and full editability). Counter-evidence cuts against "received markedly worse": Proloquo won the 2023 App Store Award for Cultural Impact — the first AAC app ever to do so — and AssistiveWare now recommends Proloquo as the default for "the vast majority of English-language iPad users." The defensible version: subscription pricing in AAC carries documented, structural friction — most importantly that state/disability funding programs and institutions cannot purchase subscriptions, a limitation AssistiveWare concedes in developer responses and works around with time-limited (1–5 year, $99.99–$499.99) non-auto-renewing licenses, with no perpetual option available for Proloquo. That funding-eligibility point, not the star-rating gap, is the real signal for a business-model decision.

**Evidence:** EVERY NUMBER IN "THEIR DETAIL" CHECKS OUT. I independently confirmed against primary sources:
- Proloquo2Go (id308368164): $249.99 one-time, 4.8/5, ~12,000 US ratings, $149.99 Gateway vocabulary IAP. CONFIRMED.
- Proloquo (id1521978238): free download, $9.99/mo, $99.99/yr, 4.0/5, 142 US ratings. CONFIRMED.
- License ladder $99.99 (1yr) / $199.99 (2yr) / $299.99 (3yr) / $399.99 (4yr) / $499.99 (5yr), all time-limited, no perpetual option anywhere on the page. CONFIRMED.
- The review quote wishing for "a way to just buy this app instead of paying a subscription like Proloquo2Go." CONFIRMED verbatim.
- Developer response defending the model via 24/7 in-app AAC expert support + Proloquo Coach. CONFIRMED (also found a second, stronger response: institutions/state funding programs "will not accept this as this is a subscription," to which AssistiveWare offers non-auto-renewing licenses and says "AssistiveWare will never leave an AAC user without their communication system for financial reasons").

BUT THE CLAIM'S LOAD-BEARING FRAMING IS WRONG ON FOUR COUNTS:

1. DATE IS OFF BY ~2 YEARS. The "Introducing Proloquo and Proloquo Coach" blog post is dated December 2, 2021 — not 2023. NWACS's independent June 2022 review corroborates, saying AssistiveWare "began to advertise" Proloquo "several months ago." The researcher likely mistook the Nov 2023 developer response date (or the Nov 29, 2023 App Store Award) for the launch. This inverts their own caveat: they excused the low rating COUNT as "partly age," but Proloquo is ~4.5 years old, not ~2.5. 142 ratings in 4.5 years (~32/yr) vs Proloquo2Go's ~700/yr is a thinner-adoption story than they told — their caveat was too generous to their own thesis in one direction and too harsh in another.

2. THERE WAS NO "MOVE TO SUBSCRIPTION." This is the biggest error. AssistiveWare did not migrate; it runs a dual track. Proloquo2Go is STILL sold at $249.99 one-time today, and AssistiveWare states explicitly: "We want to reassure you - there are no plans to discontinue Proloquo2Go. It is still an excellent AAC app." Their own comparison page lists Proloquo2Go's model as "One time purchase." The claim describes a migration that never happened.

3. "RECEIVED MARKEDLY WORSE" IS CONTRADICTED BY HARD COUNTER-EVIDENCE. Proloquo won the 2023 App Store Award for Cultural Impact (announced Nov 29, 2023) — the first AAC app ever to receive one. And AssistiveWare now recommends Proloquo as the default for "the vast majority of English-language iPad users," steering to Proloquo2Go only for non-English/bilingual users or those with significant fine-motor/vision needs. A company does not make a rejected product its recommended default. No evidence of organized backlash surfaced in any search.

4. THE CAUSAL ATTRIBUTION IS CONFOUNDED — the 0.8-star gap is NOT clean evidence about subscriptions:
   (a) SELECTION EFFECT, and it is severe. A $249.99 paid app is rated only by people who already paid $249.99 — an enormous pre-purchase commitment filter that systematically inflates ratings. A free-download app is rated by everyone who bounces off the paywall. This mechanism alone can generate a ~0.8-star gap carrying zero information about subscription preference. The two apps are not comparable rating populations, so "within the same company and brand" does not control for what the researcher thinks it controls for.
   (b) THE PRODUCTS DIFFER ENORMOUSLY, independent of price. Proloquo LOCKS its base vocabulary (users cannot remove/move/change words) and ships ONE grid size (48 buttons); Proloquo2Go offers 23 grid sizes (9–144 buttons) and full editability. AssistiveWare maintains an entire defensive blog post titled "Why can't I change the base vocabulary of Proloquo?" — strong evidence that rigidity, not pricing, is the recurring gripe. Any of these could drive the 0.8 stars.
   (c) 142 ratings is a tiny sample; a handful of 1-stars moves 4.0 materially.

WHAT SURVIVES (and is decision-useful): subscription-for-AAC does carry real, documented, product-specific friction that a one-time purchase does not — most concretely that disability/state funding programs and institutions cannot purchase subscriptions at all, which AssistiveWare itself concedes and works around with non-auto-renewing licenses. That is a genuine structural finding for the business-model dimension, and it is stronger than the star-rating argument the researcher built. Note also that even AssistiveWare's "non-subscription" escape hatch is time-limited (max 5yr/$499.99) — no perpetual option exists for Proloquo. Their CONFIDENCE: high is not warranted; the numbers are high-confidence, the inference is not.

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

CLAIM: AssistiveWare's move to subscription with 'Proloquo' (2023) has been received markedly worse than its one-time-purchase flagship, within the same company and brand
THEIR DETAIL: Proloquo2Go: $249.99 one-time, 4.8/5 stars, ~12,000 iOS ratings, plus a $149.99 Gateway vocabulary IAP. Proloquo (the newer subscription product): $9.99/month or $99.99/year, 4.0/5 stars, only 142 iOS ratings. Direct-license alternatives exist at $99.99 (1yr), $199.99 (2yr), $299.99 (3yr), $399.99 (4yr), $499.99 (5yr) — i.e. even the 'non-subscription' option is time-limited. Reviews include a user wishing for 'a way to just buy this app instead of paying a subscription.' AssistiveWare's Nov 2023 developer response acknowledges disappointment and defends the model via 24/7 expert support and Proloquo Coach. Caveat: Proloquo launched later, so lower rating COUNT is partly age; but the 0.8-star rating GAP within one publisher is the meaningful signal.
THEIR CLAIMED SOURCES: https://apps.apple.com/us/app/proloquo/id1521978238, https://apps.apple.com/us/app/proloquo2go-aac/id308368164, https://www.assistiveware.com/products/proloquo-licenses, https://www.assistiveware.com/blog/introducing-proloquo-proloquo-coach
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>

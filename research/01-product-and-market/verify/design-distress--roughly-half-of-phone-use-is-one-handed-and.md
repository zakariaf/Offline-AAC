# design-distress--roughly-half-of-phone-use-is-one-handed-and

> Phase: **verify** · Agent `adfe2e3bcb80c69b5` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Corrected version: Hoober's 2013 observational study (1,333 observations; 780 screen-touching) found 49% one-handed, 36% cradled, 15% two-handed grips, with ~75% of interactions thumb-driven — but Hoober cautions these are not population-level shares and that grip changes every few seconds. A 2018 Yonsei study (Kim & Ji, IEA 2018) found that on 4.7-5.2in phones, the NATURAL thumb zone (the area reached without shifting grip) covered >50% of the screen for long-thumbed users but only ~30% for small/medium-thumbed users; it also found that BOTH the upper-left region AND the lowermost region fall outside the natural zone. No study tested 6.7-6.8in devices, and Hoober himself (2014) argues reach charts are "flawed" because users simply re-grip, recommending key controls go in the MIDDLE of the screen rather than the bottom. For AAC: the defensible design conclusion is to place highest-value tiles in the lower-CENTER arc — avoiding both the upper-left and the extreme bottom edge — and to treat "a distressed user cannot re-grip" as a hypothesis to test with the target population rather than an established finding.

**Evidence:** The two headline statistics are real and correctly sourced, but the design-relevant half of the claim is overstated, rests on an unsupported extrapolation, and is contradicted both by the claim's own peer-reviewed source and by Hoober himself.

WHAT CHECKS OUT:
1. Hoober's 75% / 49%: CONFIRMED at primary source. UXmatters (Feb 2013), 1,333 observations over two months ending 2013-01-08; 780 involved touching the screen. Among those: 49% one-handed, 36% cradled, 15% two-handed. The 75% thumb figure is derivable (49% + 72% of the 36% cradled = ~75%). LukeW attributes both to Hoober's 1,333 observations, so attributing 75% to Hoober is defensible (Smashing credits Josh Clark).
2. Yonsei >50% vs ~30%: CONFIRMED VERBATIM. Kim, H.C. & Ji, Y.G., "Natural Thumb Zone on Smartphone with One-Handed Interaction: Effects of Thumb Length and Screen Size," IEA 2018 proceedings (pub. 2019). Abstract: "In large group, the thumb zone occupied more than 50% of the touch screen, while small and medium groups occupied only about 30% in all smartphones of different sizes."

WHAT IS WRONG:
1. THE EXTRAPOLATION IS UNSUPPORTED. The Yonsei study tested 4.7in, 5.1in, and 5.2in phones only — a 0.5in range of devices that are small by 2026 standards. It says nothing about 6.7-6.8in Pro Max / S Ultra hardware. "Across device sizes" borrows the paper's phrasing while silently widening its range by ~1.5in. Nothing in the cited paper licenses "the top zone is practically inaccessible" on a 6.7in device.
2. THE OWN SOURCE CONTRADICTS THE "EASY ZONE = BOTTOM THIRD" MODEL. Yonsei abstract: "The lowermost region AND the upper-left region of the smartphone touchscreen are not commonly included in natural thumb zone, regardless of the thumb-length groups." The natural zone is a mid/lower-center arc, not the bottom third. The claim's own peer-reviewed backing contraindicates putting high-value AAC tiles flush at the screen bottom — which is the practical inverse of what the claim implies.
3. IT IS THE UPPER-LEFT, NOT "THE TOP ENTIRELY." Both Yonsei and LukeW's heat map identify the upper-LEFT corner (for a right thumb) as the hardest region — not the whole top band.
4. HOOBER HIMSELF REFUTES THE "HARD ZONE" FRAMING. In "The Rise of the Phablet" (UXmatters, Nov 2014) he calls Josh Clark's one-handed reach charts "classic, but flawed," says "people can easily shift their hold to touch anywhere on the screen," and that reaching the periphery "seems to present no particular burden — most users simply slow down and add a hand to stabilize the device." His actual recommendation is the opposite of the claim's implied fix: "Put key content and controls in the MIDDLE of the screen, and place only secondary controls along the edges." Invoking Hoober as foundation for "top is inaccessible" inverts his conclusion.
5. "ROUGHLY HALF OF PHONE USE IS ONE-HANDED" OVERREADS THE DATA. The 49% is a share of observed screen-touch instants in public spaces in 2013, with no demographics collected, and Hoober explicitly cautions the data "doesn't represent total population percentages" and that grip "is not a static state" — users change grips "sometimes every few seconds." It is not a share of use time.
6. CATEGORY ERROR: "natural thumb zone" measures where the thumb travels WITHOUT shifting grip. It is not a measure of what is reachable or accessible. Treating a non-natural region as "excluded entirely" conflates the two.
7. DATA AGE: the evidence base is 2013 (Hoober) and 2018 data (Yonsei). No post-2020 peer-reviewed replication on 6.5in+ hardware surfaced. Blog claims circulating in 2024-2026 ("Google Android UX Research: every 0.5in reduces one-handed usability 23%", "Journal of Hand Therapy: 73% report thumb strain") trace to no locatable primary source and appear to be SEO fabrication — do not rely on them.

IMPORTANT NUANCE FOR THE AAC PRODUCT DECISION: Hoober's dismissal rests on an assumption that fails precisely in this product's target scenario — that a user can freely re-grip or add a second hand. Someone mid-shutdown, holding a bag in a shop, or post-seizure may not be able to. So the researcher's design instinct (don't put the highest-value tiles where a re-grip is required) may well be right for THIS population — but it is an untested hypothesis about a distressed, one-handed-constrained user, NOT an established finding, and the cited sources do not support it. It should be validated with the actual user group, not asserted from Hoober/Yonsei.

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

CLAIM: Roughly half of phone use is one-handed and thumb reach on modern large phones excludes the top of the screen entirely for small/medium hands
THEIR DETAIL: Hoober's foundational research: ~75% of users interact primarily with thumbs, ~49% operate one-handed. Screens divide into an easy zone (bottom third), stretch zone (middle third), and hard zone (top third requiring grip repositioning). Heat-map analysis found that for large-hand groups the comfortable thumb zone covered >50% of the screen, but for small and medium hand groups only ~30% — across device sizes. With 6.7-6.8in devices (iPhone Pro Max, Galaxy S Ultra) now standard, the top zone is 'practically inaccessible' one-handed for smaller hands. Peer-reviewed backing: Yonsei study on natural thumb zone effects of thumb length and screen size. Consequence for AAC: the conventional top-left-first reading-order grid puts the highest-value tiles in the least reachable region.
THEIR CLAIMED SOURCES: https://www.smashingmagazine.com/2016/09/the-thumb-zone-designing-for-mobile-users/, https://link.springer.com/chapter/10.1007/978-3-319-96071-5_50, https://parachutedesign.ca/blog/thumb-zone-ux/, https://www.lukew.com/ff/entry.asp?1927=
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>

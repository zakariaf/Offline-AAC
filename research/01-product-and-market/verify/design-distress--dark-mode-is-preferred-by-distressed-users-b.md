# design-distress--dark-mode-is-preferred-by-distressed-users-b

> Phase: **verify** · Agent `ad37b672aa0ef5ef0` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Corrected claim: "Distressed users show a documented preference for dark, subtle palettes (Homan, Smashing Magazine, Jul 2026, citing DOI 10.1177/14604582241295948). The reading-performance evidence against dark mode is real but narrower than commonly stated: Piepenbrock et al. (Ergonomics, 2013) found a positive-polarity advantage in visual ACUITY (large: d=2.17 younger, d=0.58 older) and proofreading ACCURACY (small: eta-squared=0.06), but explicitly found NO reading-speed difference (p=0.69). A separate paper (Piepenbrock, Mayr & Buchner, Ergonomics 2014, 57(11):1670-7) did find faster proofreading in positive polarity. No credible source reports a '26%' reading-speed drop — that figure appears fabricated. Dobres, Chahine & Reimer (Applied Ergonomics, 2017, 60:68-73) — NOT a 2024 arXiv study — found polarity effects concentrated under dark ambient illumination, with negative polarity worst at night. The pupil-dilation/aberration mechanism behind halation is supported, but the '30-50% of astigmatics' figure is a misread of astigmatism PREVALENCE in the general population (Hashemi 2017: 40.4% of adults); no peer-reviewed source quantifies the halation-affected fraction. Critically, dark mode is measurably BETTER for some impaired users: Legge et al. (1985) found observers with cloudy ocular media read 10-15% better in negative polarity. The individual-differences picture is confirmed by While & Sarvghad (arXiv:2409.10841, 2024), which found each polarity benefits comparable proportions of users and recommends shipping both. CONCLUSION: the product decision — ship both modes with an accessible toggle, and do not hard-default to either — is CORRECT and is in fact better supported by the corrected evidence than by the original overstated version, since dark mode actively helps part of this app's disabled target population rather than merely being a preference concession."

**Evidence:** The claim's practical conclusion (dark/light must be a user choice) is correct and well-supported, but nearly every load-bearing specific is wrong, and the flagship citation contradicts the claim.

1. PIEPENBROCK 2013 CONTRADICTS THE "FASTER READING" CLAIM. I extracted the primary PDF (Ergonomics 56(7), Piepenbrock, Mayr, Mund & Buchner). Results 3.2 states verbatim: "Reading rate was at comparable levels in the positive and in the negative polarity condition for younger as well as for older participants... there was a significant effect neither of polarity, F(1,165)=0.16, p=0.69, h2<0.01." The Discussion reuses this null: "Speed-accuracy trade-offs can be ruled out because participants' reading rate was comparable in both conditions." The real positive-polarity advantages were in visual ACUITY (F(1,163)=69.31, h2=0.30; d=2.17 younger, d=0.58 older) and proofreading ACCURACY (F(1,165)=9.92, h2=0.06 — small). So "faster... reading in positive polarity" is false for the cited paper.

2. THE "26%" FIGURE DOES NOT EXIST. Regex search of the full extracted text found no 26% reading-speed figure; the only "26" hits are SDs, ages, and page numbers. The paper reports F-statistics and eta-squared and never reports percentage reading-speed drops. Likely a garbled transposition of the "around 36%" average percent difference in TIME from the arXiv paper (a different construct, varying in both directions).

3. THE ARXIV CITATION IS A DIFFERENT PAPER. arXiv 2409.10841 is While & Sarvghad, "Dark Mode or Light Mode? Exploring the Impact of Contrast Polarity on Visualization Performance Between Age Groups" — a data-visualization study (134 participants). It contains NO daytime/nighttime finding and NO font-size finding. Its actual conclusion is the opposite of a light-mode advantage: "each polarity benefiting comparable proportions of participants" and it recommends "making visualizations available in both contrast polarities." The day/night + font-size finding actually belongs to Dobres, Chahine & Reimer (2017), Applied Ergonomics 60:68-73 (PubMed 28166901) — 2017, not 2024, and not arXiv.

4. THE 30-50% ASTIGMATISM/HALATION FIGURE IS A CATEGORY ERROR. The ~40-47% numbers in the literature are the PREVALENCE OF ASTIGMATISM IN THE GENERAL POPULATION, not the fraction of astigmatics who experience halation. Hashemi et al. (2017, J Current Ophthalmology) estimated pooled prevalence 40.4% (95% CI 34.3-46.6) in adults; Level Access cites 47.4% of ~11,000 UK glasses-wearers having >=0.75D. BOIA's ~47% is likewise population prevalence, and its halation support is a UX Medium post by H. Locke, not ophthalmology research. No peer-reviewed source quantifies what share of astigmatics experience halation; the widely-cited "50%" traces to unreferenced work by Jason Harrison. The underlying mechanism (pupil dilation amplifying optical aberration) IS supported — Dobres 2017 attributes the effect to "brighter illumination produces pupillary contraction that reduces optical aberrations" — but the specific 30-50%-of-astigmatics number is unsupported.

5. A CITED SOURCE DOESN'T SAY WHAT IT WAS CITED FOR. Stephanie Walter's article contains no percentage claims about astigmatism/halation and makes no mention of Piepenbrock or reading-speed research.

6. COUNTER-EVIDENCE INSIDE THE RESEARCHER'S OWN CITATION. Piepenbrock 2013 reviews Legge, Rubin et al. (1985): observers with corneal scattering, cataract or vitreous debris (cloudy media) were "10-15% better at reading negative than positive polarity text," with no polarity effect for low-vision observers with clear media or normal observers. Dark mode is measurably BETTER for some visually impaired groups. This is material for an AAC app serving disabled adults and argues against a light-mode default.

7. WHAT SURVIVES: The Smashing Magazine article is real and accurately quoted — Kat Homan, "Designing For Distressed Users: Why Mental Health Apps Shouldn't Follow Every UI Fashion," Jul 9 2026: users in distress "long for dark palettes, sleek and sophisticated looks, and clean, uncluttered aesthetics," citing DOI 10.1177/14604582241295948. Caveat: the "too bright, too happy, and too overwhelming" quote is Bear Room's internal product research, not peer-reviewed.

CONFIDENCE ASSESSMENT: "high" was unwarranted. Notably, my own web searches reproduced the identical "read text faster and more accurately in positive polarity" misreading of Piepenbrock 2013 — this is a widely circulating secondary-source error that the researcher inherited without checking the primary text.

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

CLAIM: Dark mode is preferred by distressed users but measurably degrades reading for the general population and causes halation for a large minority of astigmatics
THEIR DETAIL: Piepenbrock et al. (Ergonomics, 2013) found faster, more accurate reading in positive polarity (dark text on light) vs negative polarity; reported reading-speed drops of up to 26% in negative polarity for normally-sighted users. Dark backgrounds dilate the pupil, which amplifies optical aberration; white-on-black text appears to bleed/halo for roughly 30-50% of adults with astigmatism, with moderate-to-high astigmatism most affected. A 2024 arXiv study found no significant polarity difference in daytime conditions but light mode outperforming dark at night, especially at small font sizes. Meanwhile distressed users in mental-health app research explicitly prefer 'dark palettes, sleek and sophisticated looks' and reject interfaces that are 'too bright, too happy, and too overwhelming'. These are not reconcilable by picking one — they require a user choice.
THEIR CLAIMED SOURCES: https://www.boia.org/blog/dark-mode-can-improve-text-readability-but-not-for-everyone, https://arxiv.org/pdf/2409.10841, https://stephaniewalter.design/blog/dark-mode-accessibility-myth-debunked/, https://www.smashingmagazine.com/2026/07/designing-distressed-users-mental-health-apps-ui/
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>

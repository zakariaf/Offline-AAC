# aac-clinical--core-vocabulary-is-empirically-real-for-adul

> Phase: **verify** · Agent `a93589a057936bff8` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**CONFIRMED**

**Correction:** The claim itself is accurate and needs no correction. Corrections to the supporting apparatus: (1) The "174 words = 72%, 250 words = 78%" figures do NOT appear on the cited aacinstitute.org page — they come from minspeak.com, a vendor page, which miscites the title as "Most Frequently Occurring Words of Older Adults"; the actual paper is Stuart, Beukelman & King (1997), "Vocabulary use during extended conversations by two cohorts of older adults," AAC 13(1), 40-47. These figures remain unverified against the primary article. (2) The praacticalaac.org citation cites no studies at all and should be dropped as evidence. (3) Mean age is 45.47, not 45.5. (4) Balandin & Iacono (1999) should be cited with its actual finding — 347 core words = 78% coverage across 34 workers — which strengthens the argument. (5) Add caveats: BNC spoken data is British English collected 1991-1994, and the 80.62% coverage is in-sample rather than cross-validated.

**Evidence:** PRIMARY SOURCE VERIFIED EXACTLY. Shin, S., Park, H., & Hill, K. (2021), "Identifying the Core Vocabulary for Adults With Complex Communication Needs From the British National Corpus by Analyzing Grouped Frequency Distributions," Journal of Speech, Language, and Hearing Research 64(11), 4329-4343. PMID 34705517. Every load-bearing figure in the claim matched the PubMed primary abstract: 66 adults (29 men, 37 women); mean age 45.47 (SD 16.07) — claim said 45.5, immaterial; 330,000 spoken words; British National Corpus; distinct pattern emerging at the 0.1 per mille frequency level; 671 candidate words accounting for 90.94%; 80% minimum speaker-commonality threshold; final list of 203 words with 80.62% overall accountability rate. This is not a paraphrase — the numbers are identical.

CORROBORATOR 2 VERIFIED EXACTLY. Balandin, S. & Iacono, T. (1999), "Crews, Wusses, and Whoppas: core and fringe vocabularies of Australian meal-break conversations in the workplace," Augmentative and Alternative Communication 15(2), 95-109 — journal, volume, issue and page range all confirmed as cited. Independently adds supporting data the researcher did not cite: 34 nondisabled workers across four worksites, core vocabulary of 347 words accounting for 78% of the conversational sample. This is a second, independent adult population (Australian workplace) replicating the same coverage curve.

CORROBORATOR 3 PARTIALLY VERIFIED. Stuart, S., Beukelman, D., & King, J. (1997), "Vocabulary use during extended conversations by two cohorts of older adults," AAC 13(1), 40-47 — the paper is real and the citation is accurate.

PROBLEMS FOUND (none fatal to the decision):

1. SOURCE-ATTRIBUTION ERROR. The 174 words = 72% / 250 words = 78% figures are attributed to aacinstitute.org. I fetched that page: those numbers are NOT on it. It states only "With a few hundred words, a person can say over 80% of what is needed (Vanderheiden and Kelso, 1987)" and lists Stuart et al. in references without statistics. The 174/250 figures actually trace to minspeak.com (a PRC/Minspeak vendor page), which cites a nonexistent title ("Stuart, S. and Beukelman, D. (1997). Most Frequently Occurring Words of Older Adults"). The real title is "Vocabulary use during extended conversations by two cohorts of older adults." These specific figures are vendor-sourced only; I could not verify them against the primary article (paywalled).

2. THE praacticalaac.org CITATION IS NOT EVIDENCE. I fetched it: it asserts "core vocabulary... make up about 75-80% of the words we use everyday" with ZERO study citations and no adult/child distinction. It is circular support for the exact proposition under test.

3. UNFLAGGED CAVEATS. (a) The BNC spoken conversational component was collected 1991-1994, so the 2021 paper analyzes ~32-year-old British English speech, not contemporary American speech. (b) The 80.62% is in-sample — derived from and measured on the same corpus — not out-of-sample validation; the true generalization figure would be somewhat lower. (c) Stuart (1997) studied older adults/seniors specifically, not adults generally, so it narrows rather than broadens the generalization.

VERDICT RATIONALE. Marked CONFIRMED rather than PARTIALLY_TRUE because the headline claim ("~200 words cover ~80% of adult conversational speech; core vocabulary is not a kid-AAC artifact") and its principal peer-reviewed citation verified precisely against the primary source, with an independent second adult study (Balandin & Iacono) replicating it. The defects are in two ancillary citations that do not support what was attributed to them, which slightly overstates the breadth of the evidence base but does not touch the conclusion.

PRODUCT IMPACT: The ~200-tile core-vocabulary design bet is empirically safe for an adult AAC grid. Caveat for implementation: the 203-word list is British English circa 1991-1994 and should not be shipped verbatim as an American-English adult default without review; and none of these corpora cover the specific register this product targets (shutdown/distress/medical-emergency phrases), where fringe vocabulary and whole-phrase tiles — not core words — will carry the load.

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

CLAIM: Core vocabulary is empirically real for adults, not just children — roughly 200 words cover ~80% of adult conversational speech
THEIR DETAIL: Shin, Park & Hill (2021, JSLHR) analyzed 330,000 spoken words from 66 adults (mean age 45.5) in the British National Corpus: 671 candidate words at the 0.1‰ threshold covered 90.94% of the sample; after applying an 80% speaker-commonality criterion, a final high-frequency list of 203 words accounted for 80.62% coverage. Corroborating: Stuart, Beukelman & King (1997) found 174 words = 72% of what older adults said across all environments/topics, 250 words = 78%, including shopping and phone calls. Balandin & Iacono (1999) established core/fringe vocabularies of adult workplace meal-break conversations (AAC 15(2), 95-109). So the '75-80% from a few hundred core words' claim is NOT a kid-AAC artifact — it replicates in adults.
THEIR CLAIMED SOURCES: https://pubmed.ncbi.nlm.nih.gov/34705517/, https://pubs.asha.org/doi/abs/10.1044/2021_JSLHR-21-00211, https://aacinstitute.org/core-vocabulary-and-the-aac-performance-report/, https://praacticalaac.org/strategy/join-together-core-fringe-vocabulary/
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
